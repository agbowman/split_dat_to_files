CREATE PROGRAM dcp_get_event_dta:dba
 RECORD reply(
   1 task_assay_cd = f8
   1 default_result_type_cd = f8
   1 default_result_type_disp = vc
   1 default_result_type_mean = c12
   1 dta_description = vc
   1 dta_mnemonic = vc
   1 valid_dta_ind = i2
   1 dta_qual = i2
   1 def_event_class_cd = f8
   1 def_event_class_disp = vc
   1 def_event_class_mean = c12
   1 valid_event_code_ind = i2
   1 event_code_alpha_ind = i2
   1 event_code_num_ind = i2
   1 flex_found_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(30," ")
 SET event_cd_text_meaning = "TXT"
 SET event_cd_count_meaning = "COUNT"
 SET event_cd_num_meaning = "NUM"
 SET dta_alpha_meaning = "ALPHA"
 SET dta_multi_meaning = "MULTI"
 SET dta_count_meaning = "COUNT"
 SET dta_numeric_meaning = "NUMERIC"
 SET dta_calc_meaning = "CALCULATION"
 SET reply->valid_event_code_ind = 1
 SET reply->event_code_alpha_ind = 0
 SET reply->event_code_num_ind = 0
 SET reply->flex_found_ind = 0
 SET code_set = 53
 SET cdf_meaning = event_cd_text_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET text_type_code = code_value
 SET code_set = 53
 SET cdf_meaning = event_cd_count_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET count_type_code = code_value
 SET code_set = 53
 SET cdf_meaning = event_cd_num_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET num_type_code = code_value
 SELECT INTO "nl:"
  vec.def_event_class_cd, vec.event_cd
  FROM v500_event_code vec
  PLAN (vec
   WHERE (vec.event_cd=request->event_cd))
  DETAIL
   reply->def_event_class_cd = vec.def_event_class_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 IF ((reply->def_event_class_cd=text_type_code))
  SET reply->event_code_alpha_ind = 1
 ELSEIF ((reply->def_event_class_cd=count_type_code))
  SET reply->event_code_num_ind = 1
 ELSEIF ((reply->def_event_class_cd=num_type_code))
  SET reply->event_code_num_ind = 1
 ELSE
  SET reply->valid_event_code_ind = 0
 ENDIF
 IF ((reply->valid_event_code_ind=1))
  SET reply->task_assay_cd = 0
  SELECT INTO "nl:"
   dta.event_cd, dta.default_result_type_cd, dta.task_assay_cd
   FROM discrete_task_assay dta
   WHERE (dta.event_cd=request->event_cd)
    AND dta.active_ind=1
   HEAD REPORT
    cnt = 0
   DETAIL
    reply->task_assay_cd = dta.task_assay_cd, reply->default_result_type_cd = dta
    .default_result_type_cd, reply->dta_description = dta.description,
    reply->dta_mnemonic = dta.mnemonic, cnt = (cnt+ 1)
   WITH nocounter
  ;end select
  SET reply->dta_qual = cnt
  IF (curqual > 0)
   EXECUTE FROM check_for_valid_dta TO check_for_valid_dta_end
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->valid_event_code_ind=1)
  AND (reply->task_assay_cd=0))
  SELECT INTO "nl:"
   cve.event_cd, cve.parent_cd
   FROM code_value_event_r cve,
    discrete_task_assay dta
   PLAN (cve
    WHERE (cve.event_cd=request->event_cd))
    JOIN (dta
    WHERE dta.task_assay_cd=cve.parent_cd)
   HEAD REPORT
    cnt = 0
   DETAIL
    reply->flex_found_ind = 1, reply->task_assay_cd = cve.parent_cd, reply->default_result_type_cd =
    dta.default_result_type_cd,
    reply->dta_description = dta.description, reply->dta_mnemonic = dta.mnemonic, cnt = (cnt+ 1)
   WITH nocounter
  ;end select
  SET reply->dta_qual = cnt
  IF (curqual > 0)
   EXECUTE FROM check_for_valid_dta TO check_for_valid_dta_end
   GO TO exit_script
  ENDIF
 ENDIF
#check_for_valid_dta
 SET valid_dta_ind = 0
 SET code_set = 289
 SET cdf_meaning = "2"
 EXECUTE cpm_get_cd_for_cdf
 SET dta_alpha_type_code = code_value
 SET code_set = 289
 SET cdf_meaning = "5"
 EXECUTE cpm_get_cd_for_cdf
 SET dta_multi_type_code = code_value
 SET code_set = 289
 SET cdf_meaning = "13"
 EXECUTE cpm_get_cd_for_cdf
 SET dta_count_type_code = code_value
 SET code_set = 289
 SET cdf_meaning = "3"
 EXECUTE cpm_get_cd_for_cdf
 SET dta_numeric_type_code = code_value
 SET code_set = 289
 SET cdf_meaning = "8"
 EXECUTE cpm_get_cd_for_cdf
 SET dta_calc_type_code = code_value
 CALL echo(build("dta_numeric_type_code = ",dta_numeric_type_code))
 IF ((reply->default_result_type_cd=dta_alpha_type_code)
  AND (reply->event_code_alpha_ind=1))
  SET reply->valid_dta_ind = 1
 ELSEIF ((reply->default_result_type_cd=dta_multi_type_code)
  AND (reply->event_code_alpha_ind=1))
  SET reply->valid_dta_ind = 1
 ELSEIF ((reply->default_result_type_cd=dta_count_type_code)
  AND (reply->event_code_num_ind=1))
  SET reply->valid_dta_ind = 1
 ELSEIF ((reply->default_result_type_cd=dta_numeric_type_code)
  AND (reply->event_code_num_ind=1))
  SET reply->valid_dta_ind = 1
 ELSEIF ((reply->default_result_type_cd=dta_calc_type_code)
  AND (reply->event_code_num_ind=1))
  SET reply->valid_dta_ind = 1
 ELSE
  SET reply->valid_dta_ind = 0
 ENDIF
#check_for_valid_dta_end
#exit_script
 IF ((reply->def_event_class_cd > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("def_envent_class_cd  = ",reply->def_event_class_cd))
 CALL echo(build("valid event code ind  = ",reply->valid_event_code_ind))
 CALL echo(build("alpha ind  = ",reply->event_code_alpha_ind))
 CALL echo(build("num_ind  = ",reply->event_code_num_ind))
 CALL echo(build("flex ind  = ",reply->flex_found_ind))
 CALL echo(build("task_assay_cd  = ",reply->task_assay_cd))
 CALL echo(build("default_result_type_cd  = ",reply->default_result_type_cd))
 CALL echo(build("dta_description  = ",reply->dta_description))
 CALL echo(build("dta_mnemonic  = ",reply->dta_mnemonic))
 CALL echo(build("valid_dta_ind = ",reply->valid_dta_ind))
 CALL echo(build("CUR_QUAL = ",reply->dta_qual))
END GO
