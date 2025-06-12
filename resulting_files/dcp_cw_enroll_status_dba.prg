CREATE PROGRAM dcp_cw_enroll_status:dba
 DECLARE timeout_var = vc WITH public, noconstant(fillstring(30," "))
 DECLARE timeout_pos = i4 WITH public, noconstant(0)
 DECLARE timeout_length = i4 WITH protect, constant(7)
 FREE RECORD reply
 RECORD reply(
   1 enrolled_flag = i2
   1 new_connections = i4
   1 json = gvc
   1 cw_timeout = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE mp_pv_get_cw_status "MINE", request->person_id, request->encntr_id,
 request->action_flag WITH replace(commonwellreply,reply)
 SET timeout_pos = findstring("timeout",reply->status_data.subeventstatus[1].targetobjectvalue)
 IF (timeout_pos > 0)
  SET timeout_var = substring(timeout_pos,timeout_length,reply->status_data.subeventstatus[1].
   targetobjectvalue)
  IF (timeout_var="timeout")
   SET reply->cw_timeout = 1
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
