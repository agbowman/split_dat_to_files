CREATE PROGRAM dcp_chg_note_type:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET note_cnt = cnvtint(size(request->note_type,5))
 SELECT
  nt.default_level_flag, nt.override_level_ind
  FROM note_type nt,
   (dummyt d  WITH seq = value(note_cnt))
  PLAN (d)
   JOIN (nt
   WHERE (nt.note_type_id=request->note_type[d.seq].note_type_id))
  DETAIL
   IF ((request->note_type[d.seq].level_valid_ind != 1))
    request->note_type[d.seq].default_level_flag = nt.default_level_flag, request->note_type[d.seq].
    override_level_ind = nt.override_level_ind
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM note_type nt,
   (dummyt d  WITH seq = value(note_cnt))
  SET nt.data_status_ind = request->note_type[d.seq].data_status_ind, nt.banner_ind = request->
   note_type[d.seq].banner_ind, nt.device_name = request->note_type[d.seq].device_name,
   nt.publish_level = request->note_type[d.seq].publish_level, nt.default_level_flag = request->
   note_type[d.seq].default_level_flag, nt.override_level_ind = request->note_type[d.seq].
   override_level_ind,
   nt.updt_dt_tm = cnvtdatetime(curdate,curtime3), nt.updt_id = reqinfo->updt_id, nt.updt_task =
   reqinfo->updt_task,
   nt.updt_applctx = reqinfo->updt_applctx, nt.updt_cnt = (nt.updt_cnt+ 1)
  PLAN (d)
   JOIN (nt
   WHERE (nt.note_type_id=request->note_type[d.seq].note_type_id))
  WITH nocounter
 ;end update
 IF (curqual != note_cnt)
  SET reply->status_data.status = "F"
 ENDIF
 FOR (i = 0 TO note_cnt)
   IF ((request->note_type[i].data_status_ind=0))
    DELETE  FROM note_type_list nt
     WHERE (nt.note_type_id=request->note_type[i].note_type_id)
     WITH counter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE_TYPE"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
