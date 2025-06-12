CREATE PROGRAM bhs_athn_get_order_sentence_v2
 FREE RECORD result
 RECORD result(
   1 encntr_group_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req500379
 RECORD req500379(
   1 synonym_id = f8
   1 usage_flag = i2
   1 order_encntr_group_cd = f8
   1 facility_cd = f8
   1 patient_demographic
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
   1 detail_filters[*]
     2 order_detail
       3 field_id = f8
       3 field_meaning_id = f8
       3 field_type_flag = i2
       3 values[*]
         4 display_value = vc
         4 value = f8
     2 filter_type_flag = i2
 ) WITH protect
 FREE RECORD rep500379
 RECORD rep500379(
   1 ordsents[*]
     2 order_sentence_id = f8
     2 order_sentence_disp_line = vc
     2 order_sent_comment = vc
     2 order_sent_comment_id = f8
     2 usage_flag = i2
     2 applicable_ind = i2
     2 applicable_to_patient_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetordersentence(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID SYNONYM_ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0.0))
  CALL echo("INVALID ENCNTR_ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $6 <= 0.0))
  CALL echo("INVALID FACILITY_CD PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM encounter e,
   code_value_group cvg
  PLAN (e
   WHERE (e.encntr_id= $5))
   JOIN (cvg
   WHERE cvg.child_code_value=e.encntr_type_cd
    AND cvg.code_set=71)
  HEAD REPORT
   result->encntr_group_cd = cvg.parent_code_value
  WITH nocounter, time = 30, maxrec = 1
 ;end select
 SET stat = callgetordersentence(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  FREE RECORD out_rec
  RECORD out_rec(
    1 sentences[*]
      2 order_sentence_id = vc
      2 order_sentence_detail = vc
  ) WITH protect
  SET stat = alterlist(out_rec->sentences,size(rep500379->ordsents,5))
  FOR (idx = 1 TO size(rep500379->ordsents,5))
   SET out_rec->sentences[idx].order_sentence_id = cnvtstring(rep500379->ordsents[idx].
    order_sentence_id)
   SET out_rec->sentences[idx].order_sentence_detail = rep500379->ordsents[idx].
   order_sentence_disp_line
  ENDFOR
  IF (validate(_memory_reply_string))
   SET _memory_reply_string = cnvtrectojson(out_rec)
  ELSE
   CALL echojson(out_rec,moutputdevice)
  ENDIF
  FREE RECORD out_rec
 ENDIF
 FREE RECORD result
 FREE RECORD req500379
 FREE RECORD rep500379
 SUBROUTINE callgetordersentence(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(500196)
   DECLARE requestid = i4 WITH constant(500379)
   SET req500379->synonym_id =  $2
   SET req500379->usage_flag = 1
   SET req500379->order_encntr_group_cd = result->encntr_group_cd
   SET req500379->facility_cd =  $6
   SET req500379->patient_demographic.birth_dt_tm = cnvtdatetime( $7)
   SET req500379->patient_demographic.birth_tz = app_tz
   CALL echorecord(req500379)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500379,
    "REC",rep500379,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500379)
   IF ((rep500379->status_data.status="F"))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
