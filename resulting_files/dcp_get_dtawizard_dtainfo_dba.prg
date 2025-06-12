CREATE PROGRAM dcp_get_dtawizard_dtainfo:dba
 SET modify = predeclare
 DECLARE category_cnt = i4 WITH protect, noconstant(0)
 DECLARE refrangeidx = i4 WITH protect, noconstant(0)
 DECLARE locateindex = i4 WITH protect, noconstant(0)
 FREE RECORD reply
 RECORD reply(
   1 task_assay_cd = f8
   1 mnemonic = vc
   1 activity_type_cd = f8
   1 default_result_type_cd = f8
   1 default_result_type_disp = c40
   1 default_result_type_desc = c60
   1 default_result_type_mean = vc
   1 description = vc
   1 event_cd = f8
   1 data_map_type_flag = i2
   1 result_entry_format = i4
   1 max_digits = i4
   1 min_digits = i4
   1 min_decimal_places = i4
   1 code_set = i4
   1 display = vc
   1 ref_range_qual[*]
     2 reference_range_factor_id = f8
     2 gestational_ind = i2
     2 sex_cd = f8
     2 age_from_units_cd = f8
     2 age_from_units_disp = c40
     2 age_from_units_desc = c60
     2 age_from_units_mean = vc
     2 age_from_minutes = i4
     2 age_to_units_cd = f8
     2 age_to_units_disp = c40
     2 age_to_units_desc = c60
     2 age_to_units_mean = vc
     2 age_to_minutes = i4
     2 mins_back = i4
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
     2 feasible_ind = i2
     2 feasible_low = f8
     2 feasible_high = f8
     2 linear_ind = i2
     2 linear_low = f8
     2 linear_high = f8
     2 units_cd = f8
     2 units_disp = c40
     2 units_desc = c60
     2 code_set = i4
     2 def_result_ind = i2
     2 default_result = f8
     2 service_resource_cd = f8
     2 organism_cd = f8
     2 unknown_age_ind = i2
     2 specimen_type_cd = f8
     2 patient_condition_cd = f8
     2 delta_check_type_cd = f8
     2 delta_minutes = i4
     2 delta_value = f8
     2 delta_chk_flag = i2
     2 precedence_sequence = i4
     2 alpha_response_ind = i2
     2 encntr_type_cd = f8
     2 dilute_ind = i2
     2 species_cd = f8
     2 category_cnt = i4
     2 category[*]
       3 category_id = f8
       3 category_name = vc
       3 display_seq = i4
       3 expand_flag = i2
     2 alpha_responses_cnt = i4
     2 alpha_responses[*]
       3 nomenclature_id = f8
       3 source_string = vc
       3 sequence = i4
       3 default_ind = i2
       3 result_value = f8
       3 description = vc
       3 multi_alpha_sort_order = i4
       3 reference_ind = i2
       3 category_id = f8
       3 concept_cki = vc
       3 concept_name = vc
       3 concept_identifier = vc
       3 truth_state_cd = f8
       3 truth_state_disp = vc
     2 rule_ind = i2
     2 rule_cnt = i4
     2 rule[*]
       3 rule_id = f8
       3 gestational_age_ind = i2
       3 gestation_from_age_in_days = i4
       3 gestation_to_age_in_days = i4
       3 from_weight = i4
       3 to_weight = i4
       3 from_weight_unit_cd = f8
       3 to_weight_unit_cd = f8
       3 from_height = i4
       3 to_height = i4
       3 from_height_unit_cd = f8
       3 to_height_unit_cd = f8
       3 location_cd = f8
       3 normal_ind = i2
       3 normal_low = f8
       3 normal_high = f8
       3 critical_ind = i2
       3 critical_low = f8
       3 critical_high = f8
       3 feasible_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 units_cd = f8
       3 unit_disp = c40
       3 def_result_ind = i2
       3 default_result = f8
       3 alpha_rule_cnt = i4
       3 alpha_rule[*]
         4 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 modifier_ind = i2
   1 single_select_ind = i2
   1 default_type_flag = i2
   1 version_number = f8
   1 io_flag = i2
   1 event_cd_disp = vc
   1 io_total_definition_id = f8
   1 template_script_cd = f8
   1 template_script_disp = vc
   1 concept_cki = vc
   1 concept_name = vc
   1 concept_identifier = vc
   1 offset_min_cnt = i4
   1 offset_mins[*]
     2 offset_min_type_cd = f8
     2 offset_min_nbr = i4
     2 offset_min_type_mean = vc
   1 witness_required_ind = i2
 )
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE ref_range_cnt = i4 WITH protect, noconstant(0)
 DECLARE alpha_cnt = i4 WITH protect, noconstant(0)
 DECLARE junk_ptr = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(false)
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET reply->max_digits = 0
 SET reply->min_digits = 0
 SET reply->min_decimal_places = 0
 SELECT INTO "nl:"
  d.task_assay_cd, r.reference_range_factor_id, a.nomenclature_id,
  n.source_string, cs.display, check = decode(d.seq,"d",r.seq,"r",a.seq,
   "a","z")
  FROM discrete_task_assay d,
   (dummyt d1  WITH seq = 1),
   reference_range_factor r,
   (dummyt d2  WITH seq = 1),
   alpha_responses_category arc,
   alpha_responses a,
   nomenclature n,
   code_value_set cs,
   dummyt d3,
   dummyt d4
  PLAN (d
   WHERE (d.task_assay_cd=request->task_assay_cd)
    AND d.active_ind=1)
   JOIN (d3)
   JOIN (cs
   WHERE cs.code_set=d.code_set)
   JOIN (d1)
   JOIN (r
   WHERE r.task_assay_cd=d.task_assay_cd
    AND r.active_ind=1
    AND r.reference_range_factor_id > 0)
   JOIN (((d4)
   JOIN (arc
   WHERE arc.reference_range_factor_id=r.reference_range_factor_id)
   ) ORJOIN ((d2)
   JOIN (a
   WHERE a.reference_range_factor_id=r.reference_range_factor_id
    AND a.active_ind=1)
   JOIN (n
   WHERE a.nomenclature_id=n.nomenclature_id)
   ))
  ORDER BY r.reference_range_factor_id, arc.alpha_responses_category_id, a.sequence
  HEAD REPORT
   count1 = 0
  HEAD d.task_assay_cd
   reply->task_assay_cd = request->task_assay_cd, reply->mnemonic = d.mnemonic, reply->
   activity_type_cd = d.activity_type_cd,
   reply->default_result_type_cd = d.default_result_type_cd, reply->description = d.description,
   reply->event_cd = d.event_cd,
   reply->event_cd_disp = uar_get_code_display(reply->event_cd), reply->modifier_ind = d.modifier_ind,
   reply->default_type_flag = d.default_type_flag,
   reply->single_select_ind = d.single_select_ind, reply->version_number = d.version_number, reply->
   code_set = d.code_set,
   reply->display = cs.display, reply->io_flag = d.io_flag, reply->concept_cki = d.concept_cki,
   reply->template_script_cd = validate(d.template_script_cd,0.0), reply->template_script_disp =
   uar_get_code_display(reply->template_script_cd), ref_range_cnt = 0
  HEAD r.reference_range_factor_id
   ref_range_cnt += 1
   IF (ref_range_cnt > size(reply->ref_range_qual,5))
    stat = alterlist(reply->ref_range_qual,(ref_range_cnt+ 1))
   ENDIF
   reply->ref_range_qual[ref_range_cnt].reference_range_factor_id = r.reference_range_factor_id,
   reply->ref_range_qual[ref_range_cnt].review_ind = r.review_ind, reply->ref_range_qual[
   ref_range_cnt].review_low = r.review_low,
   reply->ref_range_qual[ref_range_cnt].review_high = r.review_high, reply->ref_range_qual[
   ref_range_cnt].sensitive_ind = r.sensitive_ind, reply->ref_range_qual[ref_range_cnt].sensitive_low
    = r.sensitive_low,
   reply->ref_range_qual[ref_range_cnt].sensitive_high = r.sensitive_high, reply->ref_range_qual[
   ref_range_cnt].normal_ind = r.normal_ind, reply->ref_range_qual[ref_range_cnt].normal_low = r
   .normal_low,
   reply->ref_range_qual[ref_range_cnt].normal_high = r.normal_high, reply->ref_range_qual[
   ref_range_cnt].critical_ind = r.critical_ind, reply->ref_range_qual[ref_range_cnt].critical_low =
   r.critical_low,
   reply->ref_range_qual[ref_range_cnt].critical_high = r.critical_high, reply->ref_range_qual[
   ref_range_cnt].feasible_ind = r.feasible_ind, reply->ref_range_qual[ref_range_cnt].feasible_low =
   r.feasible_low,
   reply->ref_range_qual[ref_range_cnt].feasible_high = r.feasible_high, reply->ref_range_qual[
   ref_range_cnt].linear_ind = r.linear_ind, reply->ref_range_qual[ref_range_cnt].linear_low = r
   .linear_low,
   reply->ref_range_qual[ref_range_cnt].linear_high = r.linear_high, reply->ref_range_qual[
   ref_range_cnt].units_cd = r.units_cd, reply->ref_range_qual[ref_range_cnt].code_set = r.code_set,
   reply->ref_range_qual[ref_range_cnt].def_result_ind = r.def_result_ind, reply->ref_range_qual[
   ref_range_cnt].gestational_ind = r.gestational_ind, reply->ref_range_qual[ref_range_cnt].sex_cd =
   r.sex_cd,
   reply->ref_range_qual[ref_range_cnt].age_from_units_cd = r.age_from_units_cd, reply->
   ref_range_qual[ref_range_cnt].age_from_minutes = r.age_from_minutes, reply->ref_range_qual[
   ref_range_cnt].age_to_units_cd = r.age_to_units_cd,
   reply->ref_range_qual[ref_range_cnt].age_to_minutes = r.age_to_minutes, reply->ref_range_qual[
   ref_range_cnt].mins_back = r.mins_back, reply->ref_range_qual[ref_range_cnt].default_result = r
   .default_result,
   reply->ref_range_qual[ref_range_cnt].service_resource_cd = r.service_resource_cd, reply->
   ref_range_qual[ref_range_cnt].organism_cd = r.organism_cd, reply->ref_range_qual[ref_range_cnt].
   unknown_age_ind = r.unknown_age_ind,
   reply->ref_range_qual[ref_range_cnt].specimen_type_cd = r.specimen_type_cd, reply->ref_range_qual[
   ref_range_cnt].patient_condition_cd = r.patient_condition_cd, reply->ref_range_qual[ref_range_cnt]
   .delta_check_type_cd = r.delta_check_type_cd,
   reply->ref_range_qual[ref_range_cnt].delta_minutes = r.delta_minutes, reply->ref_range_qual[
   ref_range_cnt].delta_value = r.delta_value, reply->ref_range_qual[ref_range_cnt].delta_chk_flag =
   r.delta_chk_flag,
   reply->ref_range_qual[ref_range_cnt].precedence_sequence = r.precedence_sequence, reply->
   ref_range_qual[ref_range_cnt].alpha_response_ind = r.alpha_response_ind, reply->ref_range_qual[
   ref_range_cnt].encntr_type_cd = r.encntr_type_cd,
   reply->ref_range_qual[ref_range_cnt].dilute_ind = r.dilute_ind, reply->ref_range_qual[
   ref_range_cnt].species_cd = r.species_cd, alpha_cnt = 0,
   category_cnt = 0
  DETAIL
   IF (arc.reference_range_factor_id > 0)
    category_cnt += 1
    IF (category_cnt > size(reply->ref_range_qual[ref_range_cnt].category,5))
     stat = alterlist(reply->ref_range_qual[ref_range_cnt].category,(category_cnt+ 10))
    ENDIF
    reply->ref_range_qual[ref_range_cnt].category[category_cnt].category_id = arc
    .alpha_responses_category_id, reply->ref_range_qual[ref_range_cnt].category[category_cnt].
    category_name = arc.category_name, reply->ref_range_qual[ref_range_cnt].category[category_cnt].
    display_seq = arc.display_seq,
    reply->ref_range_qual[ref_range_cnt].category[category_cnt].expand_flag = arc.expand_flag
   ENDIF
   IF (a.reference_range_factor_id > 0)
    alpha_cnt += 1
    IF (alpha_cnt > size(reply->ref_range_qual[ref_range_cnt].alpha_responses,5))
     stat = alterlist(reply->ref_range_qual[ref_range_cnt].alpha_responses,(alpha_cnt+ 1))
    ENDIF
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].nomenclature_id = a
    .nomenclature_id, reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].sequence = a
    .sequence, reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].default_ind = a
    .default_ind,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].description = n.source_string,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].result_value = a.result_value,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].multi_alpha_sort_order = a
    .multi_alpha_sort_order,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].truth_state_cd = a.truth_state_cd,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].truth_state_disp =
    uar_get_code_display(a.truth_state_cd), reply->ref_range_qual[ref_range_cnt].alpha_responses[
    alpha_cnt].concept_cki = a.concept_cki,
    reply->ref_range_qual[ref_range_cnt].alpha_responses[alpha_cnt].category_id = a
    .alpha_responses_category_id
   ENDIF
  FOOT  r.reference_range_factor_id
   reply->ref_range_qual[ref_range_cnt].alpha_responses_cnt = alpha_cnt, stat = alterlist(reply->
    ref_range_qual[ref_range_cnt].alpha_responses,alpha_cnt), reply->ref_range_qual[ref_range_cnt].
   category_cnt = category_cnt,
   stat = alterlist(reply->ref_range_qual[ref_range_cnt].category,category_cnt)
  FOOT  d.task_assay_cd
   stat = alterlist(reply->ref_range_qual,ref_range_cnt)
  FOOT REPORT
   junk_ptr = junk_ptr
  WITH check, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4
 ;end select
 IF (curqual=0)
  SET failed = "T"
 ENDIF
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE num2 = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM ref_range_factor_rule rrfr,
   alpha_response_rule arr,
   (dummyt d2  WITH seq = 1)
  PLAN (rrfr
   WHERE expand(num1,1,ref_range_cnt,rrfr.reference_range_factor_id,reply->ref_range_qual[num1].
    reference_range_factor_id)
    AND rrfr.active_ind=1)
   JOIN (d2)
   JOIN (arr
   WHERE rrfr.ref_range_factor_rule_id=arr.ref_range_factor_rule_id
    AND arr.active_ind=1)
  ORDER BY rrfr.reference_range_factor_id, rrfr.ref_range_factor_rule_id
  HEAD rrfr.reference_range_factor_id
   refrangeidx += 1, rule_cnt = 0
  HEAD rrfr.ref_range_factor_rule_id
   IF (rrfr.ref_range_factor_rule_id > 0)
    rule_cnt += 1
    IF (rule_cnt > size(reply->ref_range_qual[refrangeidx].rule,5))
     stat = alterlist(reply->ref_range_qual[refrangeidx].rule,(rule_cnt+ 1))
    ENDIF
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].rule_id = rrfr.ref_range_factor_rule_id, reply
    ->ref_range_qual[refrangeidx].rule[rule_cnt].gestation_from_age_in_days = rrfr
    .from_gestation_days, reply->ref_range_qual[refrangeidx].rule[rule_cnt].gestation_to_age_in_days
     = rrfr.to_gestation_days,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].from_weight = rrfr.from_weight, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].to_weight = rrfr.to_weight, reply->ref_range_qual[
    refrangeidx].rule[rule_cnt].from_weight_unit_cd = rrfr.from_weight_unit_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].to_weight_unit_cd = rrfr.to_weight_unit_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].from_height = rrfr.from_height, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].to_height = rrfr.to_height,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].from_height_unit_cd = rrfr.from_height_unit_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].to_height_unit_cd = rrfr.to_height_unit_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].location_cd = rrfr.location_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].normal_ind = rrfr.normal_limit_ind, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].normal_low = rrfr.normal_low, reply->ref_range_qual[
    refrangeidx].rule[rule_cnt].normal_high = rrfr.normal_high,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].critical_ind = rrfr.critical_limit_ind, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].critical_low = rrfr.critical_low, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].critical_high = rrfr.critical_high,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].feasible_ind = rrfr.feasible_limit_ind, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].feasible_low = rrfr.feasible_low, reply->
    ref_range_qual[refrangeidx].rule[rule_cnt].feasible_high = rrfr.feasible_high,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].units_cd = rrfr.result_measurement_unit_cd,
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].def_result_ind = rrfr.default_result_ind, reply
    ->ref_range_qual[refrangeidx].rule[rule_cnt].default_result = rrfr.default_result_value
   ENDIF
   alpha_rule_cnt = 0
  DETAIL
   IF (arr.nomenclature_id > 0)
    alpha_rule_cnt += 1
    IF (alpha_rule_cnt > size(reply->ref_range_qual[refrangeidx].rule[rule_cnt].alpha_rule,5))
     stat = alterlist(reply->ref_range_qual[refrangeidx].rule[rule_cnt].alpha_rule,(alpha_rule_cnt+ 1
      ))
    ENDIF
    reply->ref_range_qual[refrangeidx].rule[rule_cnt].alpha_rule[alpha_rule_cnt].nomenclature_id =
    arr.nomenclature_id
   ENDIF
  FOOT  rrfr.ref_range_factor_rule_id
   reply->ref_range_qual[refrangeidx].rule[rule_cnt].alpha_rule_cnt = alpha_rule_cnt
  FOOT  rrfr.reference_range_factor_id
   reply->ref_range_qual[refrangeidx].rule_cnt = rule_cnt
   IF (rule_cnt < size(reply->ref_range_qual[refrangeidx].rule,5))
    stat = alterlist(reply->ref_range_qual[refrangeidx].rule,rule_cnt)
   ENDIF
   CALL echo(build("rule_cnt in foot:",rule_cnt))
   IF (rule_cnt > 0)
    reply->ref_range_qual[refrangeidx].rule_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 IF ( NOT ((reply->concept_cki="")))
  SELECT INTO "nl:"
   FROM cmt_concept c
   PLAN (c
    WHERE (c.concept_cki=reply->concept_cki))
   HEAD c.concept_cki
    reply->concept_name = c.concept_name, reply->concept_identifier = c.concept_identifier
   WITH nocounter
  ;end select
 ENDIF
 DECLARE alpha_idx = i4 WITH protect, noconstant(0)
 DECLARE cnt_loop = i4 WITH protect, noconstant(0)
 DECLARE size_alpha = i4 WITH protect, noconstant(0)
 FOR (cnt_loop = 1 TO ref_range_cnt)
   SET alpha_idx = 0
   SET size_alpha = size(reply->ref_range_qual[cnt_loop].alpha_responses,5)
   IF (size_alpha > 0)
    SELECT INTO "nl:"
     FROM alpha_responses ar,
      cmt_concept c,
      (dummyt d7  WITH seq = 1)
     PLAN (ar
      WHERE (ar.reference_range_factor_id=reply->ref_range_qual[cnt_loop].reference_range_factor_id)
       AND ar.active_ind=1)
      JOIN (d7)
      JOIN (c
      WHERE c.concept_cki=ar.concept_cki)
     ORDER BY ar.sequence
     HEAD ar.nomenclature_id
      alpha_idx += 1,
      CALL echo(build(" alpha_idx: ",alpha_idx)),
      CALL echo(build(" concept_cki: ",c.concept_cki)),
      reply->ref_range_qual[cnt_loop].alpha_responses[alpha_idx].concept_name = c.concept_name, reply
      ->ref_range_qual[cnt_loop].alpha_responses[alpha_idx].concept_identifier = c.concept_identifier
     WITH outerjoin = d7
    ;end select
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  m.task_assay_cd
  FROM data_map m
  WHERE (m.task_assay_cd=request->task_assay_cd)
   AND m.service_resource_cd=0
  DETAIL
   reply->max_digits = m.max_digits, reply->min_digits = m.min_digits, reply->min_decimal_places = m
   .min_decimal_places
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM io_total_definition i
  WHERE (i.task_assay_cd=request->task_assay_cd)
   AND i.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   reply->io_total_definition_id = i.io_total_definition_id
  WITH nocounter
 ;end select
 DECLARE offset_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dta_offset_min dom
  WHERE (dom.task_assay_cd=request->task_assay_cd)
   AND dom.active_ind=1
   AND dom.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND dom.end_effective_dt_tm >= cnvtdatetime(sysdate)
  HEAD dom.task_assay_cd
   offset_cnt = 0
  DETAIL
   offset_cnt += 1
   IF (offset_cnt > size(reply->offset_mins,5))
    stat = alterlist(reply->offset_mins,(offset_cnt+ 3))
   ENDIF
   reply->offset_mins[offset_cnt].offset_min_type_cd = dom.offset_min_type_cd, reply->offset_mins[
   offset_cnt].offset_min_nbr = dom.offset_min_nbr, reply->offset_mins[offset_cnt].
   offset_min_type_mean = uar_get_code_meaning(dom.offset_min_type_cd)
  FOOT REPORT
   reply->offset_min_cnt = offset_cnt, stat = alterlist(reply->offset_mins,offset_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE (cve.code_value=request->task_assay_cd)
   AND cve.field_name="dta_witness_required_ind"
   AND cve.field_value="1"
   AND cve.code_set=14003
  DETAIL
   reply->witness_required_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_dtawizard_dtainfo",error_msg)
 ELSEIF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE script_version = vc WITH private, noconstant("011 22/05/13")
 CALL echo(build("Script Version: ",script_version))
 SET modify = nopredeclare
END GO
