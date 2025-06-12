CREATE PROGRAM bhs_athn_get_patient_lock
 FREE RECORD out_rec
 RECORD out_rec(
   1 success = i2
   1 status = c1
   1 lock_id = i4
   1 lock_prsnl_id = f8
   1 lock_prsnl_name = vc
 ) WITH protect
 FREE RECORD req360005
 RECORD req360005(
   1 patientid = f8
   1 entityid = f8
   1 entityname = vc
   1 expire_minutes = i2
   1 lockingapplication = vc
 ) WITH protect
 FREE RECORD rep360005
 RECORD rep360005(
   1 success = i2
   1 lockprsnlid = f8
   1 lockacquiredttm = dq8
   1 lockexpiredttm = dq8
   1 lockkeyid = i4
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
   1 lockingapplication = vc
 ) WITH protect
 DECLARE callentitylock(null) = i2
 DECLARE getlockuserdetails(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET out_rec->status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callentitylock(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF ((out_rec->lock_prsnl_id > 0))
  SET stat = getlockuserdetails(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
 FREE RECORD req360005
 FREE RECORD rep360005
 SUBROUTINE callentitylock(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(600060)
   DECLARE requestid = i4 WITH protect, constant(360005)
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $4
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req360005->patientid =  $2
   IF (cnvtint( $3) > 0)
    SET req360005->expire_minutes = cnvtint( $3)
   ELSE
    SET req360005->expire_minutes = 15
   ENDIF
   SET req360005->lockingapplication = "POWERORDERS"
   CALL echorecord(req360005)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req360005,
    "REC",rep360005,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep360005)
   IF ((rep360005->status_data.status="S"))
    SET out_rec->success = rep360005->success
    SET out_rec->status = rep360005->status_data.status
    SET out_rec->lock_id = rep360005->lockkeyid
    SET out_rec->lock_prsnl_id = rep360005->lockprsnlid
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE getlockuserdetails(null)
   SELECT INTO "NL:"
    FROM person p
    PLAN (p
     WHERE (p.person_id=out_rec->lock_prsnl_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < sysdate
      AND p.end_effective_dt_tm > sysdate)
    HEAD p.person_id
     out_rec->lock_prsnl_name = p.name_full_formatted
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
