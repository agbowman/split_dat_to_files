CREATE PROGRAM cv_del_fld_reg_event:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET deleted = "F"
 SET count = 0
 SET tot_rec = 0
 SET reply->status_data.status = "F"
 DELETE  FROM cv_registry_event reg
  WHERE (reg.registry_event_id != request->reg_rec[t.seq].registry_event_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET deleted = "F"
  GO TO selection_failure
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_program
#selection_failure
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_del_fld_reg_event"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].operationname = "selecte"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_del_fld_rreg_event"
 GO TO exit_script
#exit_script
 IF (deleted="T")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  GO TO end_program
 ENDIF
#end_program
END GO
