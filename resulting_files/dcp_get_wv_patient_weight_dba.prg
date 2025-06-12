CREATE PROGRAM dcp_get_wv_patient_weight:dba
 DECLARE exec_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 IF (validate(debug_ind,0) != 1)
  SET debug_ind = 0
 ENDIF
 SET modify = predeclare
 RECORD reply(
   1 patient_id = f8
   1 patient_weight = vc
   1 weight_unit_cd = f8
   1 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE inerror1 = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE inerror2 = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE inerror3 = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE inerror4 = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE inprogress = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE unauth = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE placeholder = f8 WITH public, noconstant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 IF (((inerror1 <= 0.0) OR (((inerror2 <= 0.0) OR (((inerror3 <= 0.0) OR (inerror4 <= 0.0)) )) )) )
  GO TO exit_program
 ENDIF
 SELECT
  IF ((request->encntr_id > 0.0))
   WHERE (ce.person_id=request->person_id)
    AND (ce.event_cd=request->weight_cd)
    AND ce.event_end_dt_tm < cnvtdatetime(request->anchor_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ((ce.encntr_id+ 0)=request->encntr_id)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM clinical_event ce2
    WHERE ce2.clinical_event_id=ce.clinical_event_id
     AND ((ce2.event_class_cd=placeholder) OR (ce2.result_status_cd IN (inerror1, inerror2, inerror3,
    inerror4, inprogress,
    unauth))) )))
  ELSE
  ENDIF
  INTO "nl:"
  ce.result_val, ce.result_units_cd, ce.event_id
  FROM clinical_event ce
  WHERE (ce.person_id=request->person_id)
   AND (ce.event_cd=request->weight_cd)
   AND ce.event_end_dt_tm < cnvtdatetime(request->anchor_dt_tm)
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM clinical_event ce2
   WHERE ce2.clinical_event_id=ce.clinical_event_id
    AND ((ce2.event_class_cd=placeholder) OR (ce2.result_status_cd IN (inerror1, inerror2, inerror3,
   inerror4, inprogress,
   unauth))) )))
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   reply->patient_id = request->person_id, reply->patient_weight = ce.result_val, reply->
   weight_unit_cd = ce.result_units_cd,
   reply->event_id = ce.event_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 IF (debug_ind=1)
  CALL echo("*********************")
  CALL echo("*	 CODE VALUES    *")
  CALL echo("*********************")
  CALL echo(build("IN ERROR=",inerror1))
  CALL echo(build("TINERRNOMUT= ",inerror2))
  CALL echo(build("INERRNOVIEW=",inerror3))
  CALL echo(build("INERROR= ",inerror4))
  CALL echo("*********************")
  CALL echo("*	 THE REQUEST    *")
  CALL echo("*********************")
  CALL echorecord(request)
  CALL echo("*********************")
  CALL echo("*	  THE REPLY     *")
  CALL echo("*********************")
  CALL echorecord(reply)
  CALL echo("*********************")
  CALL echo("*	  EXEC TIME     *")
  CALL echo("*********************")
  CALL echo(build("TOTAL EXECUTION TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),
     exec_dt_tm,5)))
 ENDIF
END GO
