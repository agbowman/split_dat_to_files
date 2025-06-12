CREATE PROGRAM cqm_del_lconfig_app
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DELETE  FROM cqm_listener_config l
  WHERE l.application_name=value(trim(request->app_name))
  WITH nocounter
 ;end delete
#exit_script
 SET reply->status_data.status = "S"
 IF (validate(reqinfo->commit_ind,0) != 0)
  SET reqinfo->commit_ind = 1
 ELSE
  COMMIT
 ENDIF
END GO
