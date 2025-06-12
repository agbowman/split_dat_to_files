CREATE PROGRAM aps_chg_image_user_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET nbr_groups = cnvtint(size(request->group_qual,5))
 SET nbr_items = cnvtint(size(request->item_qual,5))
 SET case_mode_type_flag = 1
 SET folder_mode_type_flag = 2
 SET retrieval_mode_type_flag = 3
 SET multi_image_type_flag = 4
 SET folder_type_flag = 5
 DELETE  FROM ap_image_group_ini aigi
  WHERE (aigi.person_id=request->person_id)
  WITH nocounter
 ;end delete
 DELETE  FROM ap_image_item_ini aiii
  WHERE (aiii.person_id=request->person_id)
  WITH nocounter
 ;end delete
 INSERT  FROM ap_image_group_ini aigi,
   (dummyt d  WITH seq = value(nbr_groups))
  SET aigi.person_id = request->person_id, aigi.name = request->group_qual[d.seq].name, aigi.sequence
    = request->group_qual[d.seq].sequence,
   aigi.updt_dt_tm = cnvtdatetime(curdate,curtime3), aigi.updt_id = reqinfo->updt_id, aigi.updt_task
    = reqinfo->updt_task,
   aigi.updt_cnt = 0, aigi.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (aigi
   WHERE 1=1)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_groups)
  GO TO insert_aigi_failed
 ENDIF
 INSERT  FROM ap_image_item_ini aiii,
   (dummyt d  WITH seq = value(nbr_items))
  SET aiii.person_id = request->person_id, aiii.parent_sequence = request->item_qual[d.seq].
   parent_sequence, aiii.sequence = request->item_qual[d.seq].sequence,
   aiii.type_flag = request->item_qual[d.seq].type_flag, aiii.name =
   IF ((request->item_qual[d.seq].type_flag=folder_type_flag)) " "
   ELSE request->item_qual[d.seq].name
   ENDIF
   , aiii.parent_entity_name =
   IF ((request->item_qual[d.seq].type_flag=folder_type_flag)) "AP_FOLDER"
   ELSE " "
   ENDIF
   ,
   aiii.parent_entity_id = request->item_qual[d.seq].item_id, aiii.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), aiii.updt_id = reqinfo->updt_id,
   aiii.updt_task = reqinfo->updt_task, aiii.updt_cnt = 0, aiii.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (aiii
   WHERE 1=1)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_items)
  GO TO insert_aiii_failed
 ENDIF
 GO TO exit_script
#insert_aigi_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_IMAGE_GROUP_INI"
 SET failed = "T"
 GO TO exit_script
#insert_aiii_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_IMAGE_ITEM_INI"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
