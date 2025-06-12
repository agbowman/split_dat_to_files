CREATE PROGRAM bhs_athn_patient_unlock
 FREE RECORD out_rec
 RECORD out_rec(
   1 success = i2
   1 status = c1
 ) WITH protect
 FREE RECORD req360009
 RECORD req360009(
   1 patientid = f8
   1 entityid = f8
   1 entityname = vc
   1 lockkeyid = i4
 ) WITH protect
 FREE RECORD rep360009
 RECORD rep360009(
   1 success = i2
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callentityunlock(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET out_rec->status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID LOCK ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callentityunlock(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
 FREE RECORD req360009
 FREE RECORD rep360009
 SUBROUTINE callentityunlock(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(600060)
   DECLARE requestid = i4 WITH protect, constant(360009)
   SET req360009->lockkeyid =  $2
   CALL echorecord(req360009)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req360009,
    "REC",rep360009,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep360009)
   IF ((rep360009->status_data.status="S"))
    SET out_rec->success = rep360009->success
    SET out_rec->status = rep360009->status_data.status
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
