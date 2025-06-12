CREATE PROGRAM bed_clr_os_rebuild_logging:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE logerror(message=vc,details=vc) = null
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET ierrcode = 0
 DELETE  FROM os_rbld_msg
  WHERE os_rbld_msg_id > 0
  WITH check
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on os_rbld_msg delete",serrmsg)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM os_rbld_ord_sent_det
  WHERE os_rbld_ord_sent_det_id > 0
  WITH check
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on os_rbld_ord_sent_det delete",serrmsg)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM os_rbld_ord_sent
  WHERE os_rbld_ord_sent_id > 0
  WITH check
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on os_rbld_ord_sent delete",serrmsg)
 ENDIF
 SUBROUTINE logerror(message,details)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = message
   SET reply->status_data.subeventstatus[1].targetobjectvalue = details
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
