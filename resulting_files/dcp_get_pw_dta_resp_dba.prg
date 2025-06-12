CREATE PROGRAM dcp_get_pw_dta_resp:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 reference_range_factor_id = f8
     2 age_in_minutes = f8
     2 age_from_units_cd = f8
     2 age_from_minutes = i4
     2 age_to_units_cd = f8
     2 age_to_minutes = i4
     2 specimen_type_cd = f8
     2 patient_condition_cd = f8
     2 alpha_response_ind = i2
     2 default_result = f8
     2 units_cd = f8
     2 units_disp = vc
     2 units_mean = c12
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
     2 updt_cnt = i4
     2 numeric_ind = i2
     2 data_map_type_flag = i2
     2 result_entry_format = i4
     2 max_digits = i4
     2 min_digits = i4
     2 min_decimal_places = i4
     2 alpha_ind = i2
     2 alpha_cnt = i4
     2 alpha[*]
       3 sequence = i4
       3 nomenclature_id = f8
       3 result_value = f8
       3 default_ind = i2
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET max2 = 1
 SET rr_id = 0.00
 SET first_one = "Y"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 226
 SET cdf_meaning = "HUMAN"
 EXECUTE cpm_get_cd_for_cdf
 SET human_type_cd = code_value
 CALL echo(build("human_type_cd = ",human_type_cd))
 SET total1 = 0.0
 SET x = 0.0
 SET nbr_to_get = cnvtint(size(request->dta_list,5))
 SET stat = alterlist(reply->qual,nbr_to_get)
 FOR (dta_cnt = 1 TO size(request->dta_list,5))
  SET reply->qual[dta_cnt].task_assay_cd = request->dta_list[dta_cnt].task_assay_cd
  IF ((request->dta_list[dta_cnt].age_units="HOURS"))
   SET reply->qual[dta_cnt].age_in_minutes = (request->dta_list[dta_cnt].age_qty * 60)
  ELSEIF ((request->dta_list[dta_cnt].age_units="DAYS"))
   SET reply->qual[dta_cnt].age_in_minutes = ((request->dta_list[dta_cnt].age_qty * 60) * 24)
  ELSEIF ((request->dta_list[dta_cnt].age_units="WEEKS"))
   SET reply->qual[dta_cnt].age_in_minutes = (((request->dta_list[dta_cnt].age_qty * 60) * 24) * 7)
  ELSEIF ((request->dta_list[dta_cnt].age_units="MONTHS"))
   SET reply->qual[dta_cnt].age_in_minutes = (((request->dta_list[dta_cnt].age_qty * 60) * 24) * 30)
  ELSEIF ((request->dta_list[dta_cnt].age_units="YEARS"))
   SET reply->qual[dta_cnt].age_in_minutes = (((request->dta_list[dta_cnt].age_qty * 60) * 24) *
   365.25)
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  r.reference_range_factor_id, table_used = decode(dm.seq,"N",a.seq,"A"), dm.task_assay_cd,
  dm.data_map_type_flag, a.reference_range_factor_id, a.nomenclature_id,
  a.description
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   reference_range_factor r,
   alpha_responses a,
   data_map dm,
   (dummyt d1  WITH seq = 1)
  PLAN (d)
   JOIN (r
   WHERE (r.task_assay_cd=request->dta_list[d.seq].task_assay_cd)
    AND r.active_ind=1
    AND r.species_cd=human_type_cd
    AND r.organism_cd=0.00
    AND r.service_resource_cd=0.00
    AND r.gestational_ind=0
    AND r.unknown_age_ind=0
    AND (((r.sex_cd=request->dta_list[d.seq].sex_cd)) OR (r.sex_cd=0.00))
    AND (r.age_from_minutes <= reply->qual[d.seq].age_in_minutes)
    AND (r.age_to_minutes >= reply->qual[d.seq].age_in_minutes))
   JOIN (d1)
   JOIN (((dm
   WHERE dm.task_assay_cd=r.task_assay_cd)
   ) ORJOIN ((a
   WHERE a.reference_range_factor_id=r.reference_range_factor_id)
   ))
  ORDER BY d.seq, r.sex_cd DESC, r.precedence_sequence,
   r.reference_range_factor_id
  HEAD REPORT
   count1 = 0
  HEAD d.seq
   count1 = 0, max2 = 0, rr_id = 0.00,
   first_one = "Y"
  HEAD r.reference_range_factor_id
   IF (first_one="Y")
    rr_id = r.reference_range_factor_id, count1 = (count1+ 1), count2 = 0,
    reply->qual[d.seq].reference_range_factor_id = r.reference_range_factor_id, reply->qual[d.seq].
    age_from_units_cd = r.age_from_units_cd, reply->qual[d.seq].age_from_minutes = r.age_from_minutes,
    reply->qual[d.seq].age_to_units_cd = r.age_to_units_cd, reply->qual[d.seq].age_to_minutes = r
    .age_to_minutes, reply->qual[d.seq].specimen_type_cd = r.specimen_type_cd,
    reply->qual[d.seq].patient_condition_cd = r.patient_condition_cd, reply->qual[d.seq].
    alpha_response_ind = r.alpha_response_ind, reply->qual[d.seq].default_result = r.default_result,
    reply->qual[d.seq].units_cd = r.units_cd, reply->qual[d.seq].review_ind = r.review_ind, reply->
    qual[d.seq].review_low = r.review_low,
    reply->qual[d.seq].review_high = r.review_high, reply->qual[d.seq].sensitive_ind = r
    .sensitive_ind, reply->qual[d.seq].sensitive_low = r.sensitive_low,
    reply->qual[d.seq].sensitive_high = r.sensitive_high, reply->qual[d.seq].normal_ind = r
    .normal_ind, reply->qual[d.seq].normal_low = r.normal_low,
    reply->qual[d.seq].normal_high = r.normal_high, reply->qual[d.seq].critical_ind = r.critical_ind,
    reply->qual[d.seq].critical_low = r.critical_low,
    reply->qual[d.seq].critical_high = r.critical_high, reply->qual[d.seq].delta_check_type_cd = r
    .delta_check_type_cd, reply->qual[d.seq].delta_minutes = r.delta_minutes,
    reply->qual[d.seq].delta_value = r.delta_value, reply->qual[d.seq].updt_cnt = r.updt_cnt
   ENDIF
  DETAIL
   IF (((rr_id=r.reference_range_factor_id) OR (first_one="Y")) )
    first_one = "N"
    IF (table_used="A")
     IF (a.reference_range_factor_id > 0)
      count2 = (count2+ 1)
      IF (count2 > max2)
       max2 = count2, stat = alterlist(reply->qual[d.seq].alpha,max2)
      ENDIF
      reply->qual[d.seq].alpha_ind = 1, reply->qual[d.seq].alpha[count2].sequence = a.sequence, reply
      ->qual[d.seq].alpha[count2].nomenclature_id = a.nomenclature_id,
      reply->qual[d.seq].alpha[count2].result_value = a.result_value, reply->qual[d.seq].alpha[count2
      ].default_ind = a.default_ind, reply->qual[d.seq].alpha[count2].description = a.description
     ENDIF
    ELSEIF (table_used="N")
     IF (dm.task_assay_cd > 0)
      reply->qual[d.seq].numeric_ind = 1, reply->qual[d.seq].data_map_type_flag = dm
      .data_map_type_flag, reply->qual[d.seq].result_entry_format = dm.result_entry_format,
      reply->qual[d.seq].max_digits = dm.max_digits, reply->qual[d.seq].min_digits = dm.min_digits,
      reply->qual[d.seq].min_decimal_places = dm.min_decimal_places
     ENDIF
    ENDIF
   ENDIF
  FOOT  d.seq
   reply->qual[d.seq].alpha_cnt = count2
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
