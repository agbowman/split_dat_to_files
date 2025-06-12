CREATE PROGRAM chk_auth_for_location:dba
 RECORD reply(
   1 auth_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 IF ((reqinfo->updt_app IN (200012, 200035, 200020)))
  SET reply->auth_ind = 0
 ELSE
  SET reply->auth_ind = 1
 ENDIF
END GO
