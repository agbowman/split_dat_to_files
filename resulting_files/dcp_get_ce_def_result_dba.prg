CREATE PROGRAM dcp_get_ce_def_result:dba
 RECORD reply(
   1 task_assay_cd = f8
   1 service_resource_cd = f8
   1 precedence_sequence = i4
   1 reference_range_factor_id = f8
   1 species_cd = f8
   1 organism_cd = f8
   1 gestational_ind = i2
   1 unknown_age_ind = i2
   1 sex_cd = f8
   1 age_from_units_cd = f8
   1 age_from_minutes = i4
   1 age_to_units_cd = f8
   1 age_to_minutes = i4
   1 specimen_type_cd = f8
   1 patient_condition_cd = f8
   1 review_ind = i2
   1 review_low = f8
   1 review_high = f8
   1 sensitive_ind = i2
   1 sensitive_low = f8
   1 sensitive_high = f8
   1 normal_ind = i2
   1 normal_low = f8
   1 normal_high = f8
   1 critical_ind = i2
   1 critical_low = f8
   1 critical_high = f8
   1 units_cd = f8
   1 units_disp = c40
   1 units_desc = c60
   1 delta_check_type_cd = f8
   1 delta_minutes = f8
   1 delta_value = f8
   1 code_set = i4
   1 default_result = vc
   1 alpha_responses_cnt = i4
   1 alpha_responses[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 sequence = i4
     2 use_units_ind = i2
     2 result_process_cd = f8
     2 default_ind = i2
     2 description = vc
   1 call_event_server_ind = i2
   1 oe_field_type_flag = i2
   1 oe_field_dt_tm_value = dq8
   1 oe_field_value = f8
   1 oe_field_code_set = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4
 DECLARE cnt = i4
 DECLARE q_cnt = i4
 DECLARE a_cnt = i4
 DECLARE species_value = i4
 DECLARE specimen_type_value = i4
 DECLARE sex_value = i4
 DECLARE age_value = i4
 DECLARE resource_ts_value = i4
 DECLARE resource_ts_group_value = i4
 DECLARE pat_cond_value = i4
 DECLARE tot_value = i4
 DECLARE highest_tot_value = i4
 SELECT INTO "nl:"
  rr_exists = decode(rr.seq,"Y","N"), reference_range_factor_id
  FROM reference_range_factor rr
  WHERE (rr.task_assay_cd=request->task_assay_cd)
   AND rr.active_ind=1
  ORDER BY rr.task_assay_cd, rr.precedence_sequence
  HEAD REPORT
   cnt = 0, q_cnt = 0, species_value = 32,
   specimen_type_value = 16, sex_value = 8, age_value = 4,
   resource_ts_value = 2, resource_ts_group_value = 1, pat_cond_value = 0,
   tot_value = 0, highest_tot_value = - (1), reply->task_assay_cd = request->task_assay_cd,
   highest_tot_value = 0
  DETAIL
   IF (rr_exists="Y")
    tot_value = 0
    IF ((rr.species_cd=request->species_cd))
     tot_value = (tot_value+ species_value),
     CALL echo(build("Matched on species ",rr.species_cd))
    ENDIF
    IF ((rr.sex_cd=request->sex_cd))
     tot_value = (tot_value+ sex_value),
     CALL echo(build("Matched on sex ",rr.sex_cd))
    ENDIF
    IF ((rr.age_from_minutes <= request->age_in_minutes)
     AND (rr.age_to_minutes >= request->age_in_minutes))
     tot_value = (tot_value+ age_value),
     CALL echo(build("Matched on age ",rr.age_from_minutes))
    ENDIF
    IF ((rr.service_resource_cd=request->service_resource_cd))
     tot_value = (tot_value+ resource_ts_value)
    ENDIF
    IF (tot_value > highest_tot_value)
     highest_tot_value = tot_value, reply->task_assay_cd = rr.task_assay_cd, reply->
     service_resource_cd = rr.service_resource_cd,
     reply->precedence_sequence = rr.precedence_sequence, reply->reference_range_factor_id = rr
     .reference_range_factor_id, reply->species_cd = rr.species_cd,
     reply->organism_cd = rr.organism_cd, reply->gestational_ind = rr.gestational_ind, reply->
     unknown_age_ind = rr.unknown_age_ind,
     reply->sex_cd = rr.sex_cd, reply->age_from_units_cd = rr.age_from_units_cd, reply->
     age_from_minutes = rr.age_from_minutes,
     reply->age_to_units_cd = rr.age_to_units_cd, reply->age_to_minutes = rr.age_to_minutes, reply->
     specimen_type_cd = rr.specimen_type_cd,
     reply->patient_condition_cd = rr.patient_condition_cd, reply->default_result = cnvtstring(rr
      .default_result), reply->review_ind = rr.review_ind,
     reply->review_low = rr.review_low, reply->review_high = rr.review_high, reply->sensitive_ind =
     rr.sensitive_ind,
     reply->sensitive_low = rr.sensitive_low, reply->sensitive_high = rr.sensitive_high, reply->
     normal_ind = rr.normal_ind,
     reply->normal_low = rr.normal_low, reply->normal_high = rr.normal_high, reply->critical_ind = rr
     .critical_ind,
     reply->critical_low = rr.critical_low, reply->critical_high = rr.critical_high, reply->units_cd
      = rr.units_cd,
     reply->delta_check_type_cd = rr.delta_check_type_cd, reply->delta_minutes = rr.delta_minutes,
     reply->delta_value = rr.delta_value,
     reply->code_set = rr.code_set, reply->alpha_responses_cnt = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ar.nomenclature_id, ar.sequence, n.nomenclature_id,
  n.source_string
  FROM dummyt d1,
   alpha_responses ar,
   nomenclature n
  PLAN (d1)
   JOIN (ar
   WHERE (ar.reference_range_factor_id=reply->reference_range_factor_id)
    AND ar.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id
    AND n.active_ind=1
    AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
  ORDER BY ar.reference_range_factor_id, ar.sequence
  HEAD REPORT
   cnt = 0, a_cnt = 0
  DETAIL
   a_cnt = (a_cnt+ 1)
   IF (mod(a_cnt,10)=1)
    stat = alterlist(reply->alpha_responses,(a_cnt+ 10))
   ENDIF
   reply->alpha_responses_cnt = a_cnt, reply->alpha_responses[a_cnt].nomenclature_id = n
   .nomenclature_id, reply->alpha_responses[a_cnt].source_string = n.source_string,
   reply->alpha_responses[a_cnt].sequence = ar.sequence, reply->alpha_responses[a_cnt].use_units_ind
    = ar.use_units_ind, reply->alpha_responses[a_cnt].result_process_cd = ar.result_process_cd,
   reply->alpha_responses[a_cnt].default_ind = ar.default_ind, reply->alpha_responses[a_cnt].
   description = ar.description
  WITH nocounter
 ;end select
#resize_reply
 IF (q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->call_event_server_ind = 1
 SET reply->status_data.status = "S"
 CALL echo(build("default result = ",reply->default_result))
 CALL echo(build("units_cd = ",reply->units_cd))
 CALL echo(build("units_disp =",reply->units_disp))
 CALL echo(build("units_descr=",reply->units_desc))
END GO
