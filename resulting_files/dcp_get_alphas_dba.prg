CREATE PROGRAM dcp_get_alphas:dba
 RECORD reply(
   1 qual[1]
     2 reference_range_factor_id = f8
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 organism_cd = f8
     2 default_ind = i2
     2 species_cd = f8
     2 sex_cd = f8
     2 unknown_age_ind = i2
     2 age_from_units_cd = f8
     2 age_from_minutes = i4
     2 age_to_units_cd = f8
     2 age_to_minutes = i4
     2 specimen_type_cd = f8
     2 patient_condition_cd = f8
     2 alpha_response_ind = i2
     2 default_result = f8
     2 units_cd = f8
     2 review_ind = i2
     2 review_low = f8
     2 review_high = f8
     2 sensitive_ind = i2
     2 sensitive_low = f8
     2 sensitive_high = f8
     2 normal_ind = i2
     2 normal_low = f8
     2 normal_high = f8
     2 critical_ind = i2
     2 critical_low = f8
     2 critical_high = f8
     2 delta_check_type_cd = f8
     2 delta_minutes = f8
     2 delta_value = f8
     2 gestational_ind = i2
     2 precedence_sequence = i4
     2 updt_cnt = i4
     2 alpha_ind = i2
     2 alpha_cnt = i4
     2 alpha[1]
       3 sequence = i4
       3 nomenclature_id = f8
       3 use_units_ind = i2
       3 result_process_cd = f8
       3 default_ind = i2
       3 description = vc
       3 result_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET max2 = 1
 SELECT INTO "nl:"
  r.task_assay_cd, r.reference_range_factor_id, r.service_resource_cd,
  a.reference_range_factor_id, a.nomenclature_id, n.source_string
  FROM reference_range_factor r,
   alpha_responses a,
   nomenclature n,
   (dummyt d2  WITH seq = 1)
  PLAN (r
   WHERE (r.task_assay_cd=request->task_assay_cd)
    AND r.active_ind=1)
   JOIN (d2)
   JOIN (a
   WHERE a.reference_range_factor_id=r.reference_range_factor_id)
   JOIN (n
   WHERE a.nomenclature_id=n.nomenclature_id)
  ORDER BY a.sequence
  HEAD REPORT
   count1 = 0, max2 = 1
  HEAD r.reference_range_factor_id
   count2 = 0, count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].reference_range_factor_id = r.reference_range_factor_id, reply->qual[count1].
   service_resource_cd = r.service_resource_cd, reply->qual[count1].task_assay_cd = r.task_assay_cd,
   reply->qual[count1].species_cd = r.species_cd, reply->qual[count1].organism_cd = r.organism_cd,
   reply->qual[count1].sex_cd = r.sex_cd,
   reply->qual[count1].unknown_age_ind = r.unknown_age_ind, reply->qual[count1].age_from_units_cd = r
   .age_from_units_cd, reply->qual[count1].age_from_minutes = r.age_from_minutes,
   reply->qual[count1].age_to_units_cd = r.age_to_units_cd, reply->qual[count1].age_to_minutes = r
   .age_to_minutes, reply->qual[count1].specimen_type_cd = r.specimen_type_cd,
   reply->qual[count1].patient_condition_cd = r.patient_condition_cd, reply->qual[count1].
   alpha_response_ind = r.alpha_response_ind, reply->qual[count1].default_result = r.default_result,
   reply->qual[count1].units_cd = r.units_cd, reply->qual[count1].review_ind = r.review_ind, reply->
   qual[count1].review_low = r.review_low,
   reply->qual[count1].review_high = r.review_high, reply->qual[count1].sensitive_ind = r
   .sensitive_ind, reply->qual[count1].sensitive_low = r.sensitive_low,
   reply->qual[count1].sensitive_high = r.sensitive_high, reply->qual[count1].normal_ind = r
   .normal_ind, reply->qual[count1].normal_low = r.normal_low,
   reply->qual[count1].normal_high = r.normal_high, reply->qual[count1].critical_ind = r.critical_ind,
   reply->qual[count1].critical_low = r.critical_low,
   reply->qual[count1].critical_high = r.critical_high, reply->qual[count1].delta_check_type_cd = r
   .delta_check_type_cd, reply->qual[count1].delta_minutes = r.delta_minutes,
   reply->qual[count1].delta_value = r.delta_value, reply->qual[count1].gestational_ind = r
   .gestational_ind, reply->qual[count1].precedence_sequence = r.precedence_sequence,
   reply->qual[count1].updt_cnt = r.updt_cnt
  DETAIL
   IF (a.reference_range_factor_id > 0)
    count2 = (count2+ 1)
    IF (count2 > max2)
     max2 = count2, stat = alter(reply->qual.alpha,max2)
    ENDIF
    reply->qual[count1].alpha_ind = 1, reply->qual[count1].alpha[count2].sequence = a.sequence, reply
    ->qual[count1].alpha[count2].nomenclature_id = a.nomenclature_id,
    reply->qual[count1].alpha[count2].use_units_ind = a.use_units_ind, reply->qual[count1].alpha[
    count2].result_process_cd = a.result_process_cd, reply->qual[count1].alpha[count2].default_ind =
    a.default_ind,
    reply->qual[count1].alpha[count2].description = n.source_string, reply->qual[count1].alpha[count2
    ].result_value = a.result_value
   ENDIF
  FOOT  r.task_assay_cd
   reply->qual[count1].alpha_cnt = count2
  WITH nocounter, outerjoin = d2
 ;end select
 IF (count1 > 0)
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
