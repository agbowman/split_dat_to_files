CREATE PROGRAM dcp_del_code_value_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 DELETE  FROM code_value_group cvg
  WHERE (cvg.parent_code_value=request->code_value)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  GO TO cvg_failed
 ENDIF
 UPDATE  FROM code_value c
  SET c.active_ind = 0
  WHERE (c.code_value=request->code_value)
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO cv_failed
 ENDIF
 DELETE  FROM pip_prefs pp
  WHERE (pp.merge_id=request->code_value)
  WITH nocounter
 ;end delete
#cv_failed
 SET reply->status_data.subeventstatus[1].operationname = "delete"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET cfailed = "T"
 GO TO exit_script
#cvg_failed
 SET reply->status_data.subeventstatus[1].operationname = "delete"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "code_value_group"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_GROUP"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP PIP Tool"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO DELETE"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
