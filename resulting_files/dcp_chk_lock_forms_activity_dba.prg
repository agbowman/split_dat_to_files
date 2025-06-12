CREATE PROGRAM dcp_chk_lock_forms_activity:dba
 RECORD reply(
   1 prsnl_id = f8
   1 forms_activity_id = f8
   1 lock_create_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE validaterequest(null) = null
 DECLARE findlockbyactivityid(argactid=f8) = null
 SET trace = debug
 SET reply->status_data.status = "F"
 CALL validaterequest(null)
 CALL findlockbyactivityid(request->forms_activity_id)
#failure
 IF (failure_ind=true)
  CALL echo("*Check Lock Forms Activity Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE validaterequest(null)
   IF ((request->forms_activity_id=0.0))
    SET reply->status_data.subeventstatus.targetobjectvalue = "No activity ID was found in request"
    SET failure_ind = true
    GO TO failure
   ELSEIF ( NOT (validate(request->prsnl_id)))
    SET reply->status_data.subeventstatus.targetobjectvalue = "No Personnel ID was found in request"
    SET failure_ind = true
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE findlockbyactivityid(argactid)
  SELECT INTO "nl:"
   FROM dcp_forms_activity fa
   WHERE fa.dcp_forms_activity_id=argactid
    AND fa.active_ind=true
   DETAIL
    reply->forms_activity_id = fa.dcp_forms_activity_id
    IF ((fa.lock_prsnl_id != request->prsnl_id))
     zero_ind = true
    ENDIF
    reply->prsnl_id = fa.lock_prsnl_id, reply->lock_create_dt_tm = fa.lock_create_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus.targetobjectvalue =
   "Unable to find an activity for the given activity id"
   SET failure_ind = true
   GO TO failure
  ENDIF
 END ;Subroutine
END GO
