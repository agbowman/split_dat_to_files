CREATE PROGRAM bed_rec_assays_no_ref_rnge
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   v500_event_set_explode ese,
   v500_event_set_code esc,
   working_view_item wvi,
   code_value cv1,
   code_value cv2,
   reference_range_factor rrf
  PLAN (dta
   WHERE dta.active_ind=1)
   JOIN (ese
   WHERE ese.event_cd=dta.event_cd
    AND ese.event_set_level=0)
   JOIN (esc
   WHERE esc.event_set_cd=ese.event_set_cd)
   JOIN (wvi
   WHERE wvi.primitive_event_set_name=esc.event_set_name)
   JOIN (cv1
   WHERE cv1.code_value=dta.default_result_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=dta.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd))
  ORDER BY dta.mnemonic, dta.task_assay_cd
  HEAD dta.task_assay_cd
   IF (rrf.task_assay_cd=0)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
