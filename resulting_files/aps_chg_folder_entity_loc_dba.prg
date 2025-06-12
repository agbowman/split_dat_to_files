CREATE PROGRAM aps_chg_folder_entity_loc:dba
 RECORD temp_entity(
   1 qual[*]
     2 prev_table = vc
     2 prev_id = f8
     2 new_table = vc
     2 new_id = f8
 )
#script
 SET failed = "F"
 SET chg_loc_reply->status_data.status = "F"
 SET input_rec_cnt = cnvtint(size(input_rec->qual,5))
 SET update_cnt = 0
 SELECT INTO "nl:"
  afe.entity_id
  FROM ap_folder_entity afe,
   (dummyt d1  WITH seq = value(input_rec_cnt))
  PLAN (d1)
   JOIN (afe
   WHERE (afe.parent_entity_id=input_rec->qual[d1.seq].prev_id)
    AND (afe.parent_entity_name=input_rec->qual[d1.seq].prev_table))
  DETAIL
   update_cnt = (update_cnt+ 1)
   IF (mod(update_cnt,10)=1)
    stat = alterlist(temp_entity->qual,(update_cnt+ 9))
   ENDIF
   temp_entity->qual[update_cnt].prev_id = input_rec->qual[d1.seq].prev_id, temp_entity->qual[
   update_cnt].prev_table = input_rec->qual[d1.seq].prev_table, temp_entity->qual[update_cnt].new_id
    = input_rec->qual[d1.seq].new_id,
   temp_entity->qual[update_cnt].new_table = input_rec->qual[d1.seq].new_table
  FOOT REPORT
   stat = alterlist(temp_entity->qual,update_cnt)
  WITH nocounter, forupdate(afe)
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM ap_folder_entity afe,
   (dummyt d1  WITH seq = value(update_cnt))
  SET afe.parent_entity_name = temp_entity->qual[d1.seq].new_table, afe.parent_entity_id =
   temp_entity->qual[d1.seq].new_id, afe.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   afe.updt_id = reqinfo->updt_id, afe.updt_task = reqinfo->updt_task, afe.updt_applctx = reqinfo->
   updt_applctx,
   afe.updt_cnt = (afe.updt_cnt+ 1)
  PLAN (d1)
   JOIN (afe
   WHERE (afe.parent_entity_id=temp_entity->qual[d1.seq].prev_id)
    AND (afe.parent_entity_name=temp_entity->qual[d1.seq].prev_table))
  WITH nocounter
 ;end update
 IF (curqual != update_cnt)
  GO TO update_folders_failed
 ENDIF
 GO TO exit_script
#update_folders_failed
 SET chg_loc_reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET chg_loc_reply->status_data.subeventstatus[1].operationstatus = "F"
 SET chg_loc_reply->status_data.subeventstatus[1].targetobjectname = "AP_FOLDER_ENTITY"
 SET chg_loc_reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating rows"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET chg_loc_reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
