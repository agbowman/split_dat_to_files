CREATE PROGRAM bed_get_assay_prompt:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 prompt_ind = i2
     2 interp_ind = i2
     2 species_not_human_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET assay_cnt = size(request->assays,5)
 IF (assay_cnt=0)
  GO TO exit_script
 ENDIF
 SET alpha_code_value = 0.0
 SET interp_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning IN ("2", "4")
   AND cv.code_set=289
  DETAIL
   CASE (cv.cdf_meaning)
    OF "2":
     alpha_code_value = cv.code_value
    OF "4":
     interp_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET human_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning="HUMAN"
   AND cv.code_set=226
  DETAIL
   human_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->assays,assay_cnt)
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = assay_cnt)
  DETAIL
   reply->assays[d.seq].code_value = request->assays[d.seq].code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = assay_cnt),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d
   WHERE (reply->assays[d.seq].prompt_ind=0))
   JOIN (ptr
   WHERE ptr.active_ind=1
    AND ptr.item_type_flag=1
    AND (ptr.task_assay_cd=reply->assays[d.seq].code_value))
   JOIN (dta
   WHERE (dta.task_assay_cd=reply->assays[d.seq].code_value)
    AND dta.active_ind=1
    AND dta.default_result_type_cd=alpha_code_value)
  DETAIL
   reply->assays[d.seq].prompt_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = assay_cnt),
   discrete_task_assay dta
  PLAN (d
   WHERE (reply->assays[d.seq].interp_ind=0))
   JOIN (dta
   WHERE dta.active_ind=1
    AND dta.default_result_type_cd=interp_code_value
    AND (dta.task_assay_cd=reply->assays[d.seq].code_value))
  DETAIL
   reply->assays[d.seq].interp_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = assay_cnt),
   assay_processing_r apr
  PLAN (d
   WHERE (reply->assays[d.seq].interp_ind=0))
   JOIN (apr
   WHERE apr.active_ind=1
    AND apr.default_result_type_cd=interp_code_value
    AND (apr.task_assay_cd=reply->assays[d.seq].code_value))
  DETAIL
   reply->assays[d.seq].interp_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = assay_cnt),
   reference_range_factor rrf
  PLAN (d
   WHERE (reply->assays[d.seq].species_not_human_ind=0))
   JOIN (rrf
   WHERE rrf.active_ind=1
    AND (rrf.task_assay_cd=reply->assays[d.seq].code_value)
    AND rrf.species_cd != human_code_value)
  DETAIL
   reply->assays[d.seq].species_not_human_ind = 1
  WITH nocounter
 ;end select
#exit_script
 IF (assay_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
