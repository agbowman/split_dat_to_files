CREATE PROGRAM bed_get_problem_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prob_results[*]
      2 concept_cki = vc
      2 results[*]
        3 event_set_name = vc
        3 event_set_display = vc
        3 sequence = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE problem_result_cd = f8
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=29753
    AND cv.cdf_meaning="PROBRESULT"
    AND cv.active_ind=1)
  DETAIL
   problem_result_cd = cv.code_value
  WITH nocounter
 ;end select
 SET prb_cnt = 0
 SET result_cnt = 0
 SELECT INTO "nl:"
  FROM concept_cki_entity_r cer,
   v500_event_set_code v
  PLAN (cer
   WHERE cer.reltn_type_cd=problem_result_cd
    AND cer.active_ind=1)
   JOIN (v
   WHERE v.event_set_name=cer.event_set_name)
  ORDER BY cer.concept_cki, cer.group_seq, cer.event_set_name
  HEAD cer.concept_cki
   prb_cnt = (prb_cnt+ 1), result_cnt = 0, stat = alterlist(reply->prob_results,prb_cnt),
   reply->prob_results[prb_cnt].concept_cki = cer.concept_cki
  HEAD cer.event_set_name
   result_cnt = (result_cnt+ 1), stat = alterlist(reply->prob_results[prb_cnt].results,result_cnt),
   reply->prob_results[prb_cnt].results[result_cnt].event_set_name = cer.event_set_name,
   reply->prob_results[prb_cnt].results[result_cnt].event_set_display = v.event_set_cd_disp, reply->
   prob_results[prb_cnt].results[result_cnt].sequence = cer.group_seq
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from concept_cki_entity_r table")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
