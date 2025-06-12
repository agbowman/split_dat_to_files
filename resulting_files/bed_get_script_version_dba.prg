CREATE PROGRAM bed_get_script_version:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 version = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->version = "1.205.0"
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
