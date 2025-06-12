CREATE PROGRAM dodfr_get_dtas:dba
 RECORD reply(
   1 dta_list[*]
     2 task_assay_cd = f8
     2 standard_assay_id = f8
     2 activity_type_cd = f8
     2 default_result_type_cd = f8
     2 event_cd = f8
     2 mnemonic = c50
     2 description = c100
     2 icd_code_ind = i2
     2 active_ind = i2
     2 specific_result_type_code_set = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 related_assay_ind = i2
     2 delta_lvl_flag = i2
     2 modifier_ind = i2
     2 single_select_ind = i2
     2 default_type_flag = i2
     2 concept_cki = c255
     2 blood_bank_result_processing_cd = f8
     2 radiology_section_type_cd = f8
     2 version_number = f8
     2 io_flag = i2
     2 io_total_definition_id = f8
     2 signature_line_ind = i2
     2 label_template_id = f8
     2 template_script_cd = f8
     2 reference_range_list[*]
       3 reference_range_factor_id = f8
       3 species_cd = f8
       3 service_resource_cd = f8
       3 active_ind = i2
       3 unknown_age_ind = i2
       3 sex_cd = f8
       3 age_from_units_cd = f8
       3 age_from_minutes = i4
       3 age_to_units_cd = f8
       3 age_to_minutes = i4
       3 specimen_type_cd = f8
       3 reference_range_online_code_set = i4
       3 precedence_sequence = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 encntr_type_cd = f8
       3 default_result = f8
       3 review_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 sensitive_ind = i2
       3 sensitive_low = f8
       3 sensitive_high = f8
       3 normal_ind = i2
       3 normal_low = f8
       3 normal_high = f8
       3 critical_ind = i2
       3 critical_low = f8
       3 critical_high = f8
       3 units_cd = f8
       3 mins_back = i4
       3 default_result_ind = i2
       3 linear_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 feasible_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 delta_check_type_cd = f8
       3 delta_minutes = i4
       3 delta_value = f8
       3 rrf_rule_list[*]
         4 ref_range_factor_rule_id = f8
         4 from_gestation_days = i4
         4 to_gestation_days = i4
         4 from_weight = i4
         4 from_weight_unit_cd = f8
         4 to_weight = i4
         4 to_weight_unit_cd = f8
         4 from_height = i4
         4 from_height_unit_cd = f8
         4 to_height = i4
         4 to_height_unit_cd = f8
         4 location_cd = f8
         4 normal_limit_ind = i2
         4 normal_low = f8
         4 normal_high = f8
         4 critical_limit_ind = i2
         4 critical_low = f8
         4 critical_high = f8
         4 feasible_ind = i2
         4 feasible_low = f8
         4 feasible_high = f8
         4 ar_rule_list[*]
           5 alpha_response_id = f8
           5 nomenclature_id = f8
           5 ref_range_factor_id = f8
       3 advanced_delta_list[*]
         4 active_ind = i2
         4 advanced_delta_id = f8
         4 delta_ind = i2
         4 delta_low = f8
         4 delta_high = f8
         4 delta_check_type_cd = f8
         4 delta_minutes = i4
         4 delta_value = f8
       3 alpha_response_list[*]
         4 alpha_response_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
         4 use_units_ind = i2
         4 result_process_cd = f8
         4 default_ind = i2
         4 description = c100
         4 active_ind = i2
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 result_value = f8
         4 reference_ind = i2
         4 multi_alpha_sort_order = i4
         4 ref_range_factor_id = f8
         4 concept_cki = c255
       3 alpha_response_cat_list[*]
         4 id = f8
         4 name = c100
         4 expand_ind = i2
     2 data_map_list[*]
       3 data_map_type_flag = i2
       3 max_digits = i4
       3 min_decimal_places = i4
       3 min_digits = i4
       3 service_resource_cd = f8
       3 active_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 interp_list[*]
       3 interp_data_id = f8
       3 service_resource_cd = f8
       3 long_text_id = f8
       3 long_text = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
     2 equation_list[*]
       3 equation_id = f8
       3 service_resource_cd = f8
       3 species_cd = f8
       3 age_from_units_cd = f8
       3 age_from_minutes = i4
       3 age_to_units_cd = f8
       3 age_to_minutes = i4
       3 sex_cd = f8
       3 unknown_age_ind = i2
       3 equation_description = c2000
       3 active_ind = i2
       3 active_dt_tm = dq8
       3 inactive_dt_tm = dq8
       3 default_ind = i2
       3 equation_postfix = c2000
       3 equation_comp_list[*]
         4 component_flag = i2
         4 constant_value = f8
         4 cross_drawn_dt_tm_ind = i2
         4 default_value = f8
         4 included_assay_cd = f8
         4 look_time_direction_flag = i2
         4 name = c50
         4 result_req_flag = i2
         4 result_status_cd = f8
         4 sequence = i4
         4 time_window_back_minutes = i4
         4 time_window_minutes = i4
         4 units_cd = f8
     2 expression_list[*]
       3 expression_id = f8
     2 witness_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD flat_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 task_assay_cd = f8
     2 dta_list_index = i4
     2 rr_list_index = i4
     2 rr_factor_id = f8
 )
 RECORD eq_flat_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 task_assay_cd = f8
     2 dta_list_index = i4
     2 eq_list_index = i4
     2 equation_id = f8
 )
 RECORD rrfr_flat_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 dta_list_index = i4
     2 rr_list_index = i4
     2 rrfr_list_index = i4
     2 rrfr_id = f8
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE num3 = i4 WITH noconstant(0), public
 DECLARE locateval_start = i4 WITH noconstant(1), public
 DECLARE included_assay_cd_pos = i4 WITH noconstant(0), public
 DECLARE duplicate_dta_index = i4 WITH noconstant(0), public
 DECLARE duplicate_assay_cd = i4 WITH noconstant(0), public
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE reply_size = i4 WITH protect, noconstant(0)
 DECLARE flat_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE eq_flat_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE rrfr_flat_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(50)
 DECLARE dta_index = i4 WITH protect, noconstant(0)
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_cnt = i4 WITH protect, noconstant(0)
 DECLARE getdtas(null) = null
 DECLARE getreferenceranges(null) = null
 DECLARE getrefrangefactorrules(null) = null
 DECLARE getalpharesponserules(null) = null
 DECLARE getalpharesponses(null) = null
 DECLARE getalpharesponsecategories(null) = null
 DECLARE getdatamaps(null) = null
 DECLARE getinterpretations(null) = null
 DECLARE getequations(null) = null
 DECLARE getequationcomponents(null) = null
 DECLARE getadvanceddeltas(null) = null
 DECLARE getexpressionids(null) = null
 DECLARE getparenteventcode(null) = null
 DECLARE getiototaldefids(null) = null
 DECLARE getcodevalueextension(null) = null
 IF ((((request->load_alpha_response_ind > 0)) OR ((request->load_advanced_delta_ind > 0))) )
  SET request->load_reference_range_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d11  WITH seq = value(size(request->task_assay_cd_list,5))),
   discrete_task_assay dta5
  PLAN (d11)
   JOIN (dta5
   WHERE (dta5.task_assay_cd=request->task_assay_cd_list[d11.seq].task_assay_cd))
  ORDER BY request->task_assay_cd_list[d11.seq].task_assay_cd
  HEAD REPORT
   cnt3 = 0
  HEAD d11.seq
   cnt3 = (cnt3+ 1), stat = alterlist(reply->dta_list,cnt3), reply->dta_list[cnt3].task_assay_cd =
   dta5.task_assay_cd
  WITH nocounter
 ;end select
 IF ((request->load_equation_ind > 0))
  CALL getequations(null)
  IF ((eq_flat_reply->qual_cnt > 0))
   CALL getequationcomponents(null)
  ENDIF
 ENDIF
 SET dta_cnt = size(reply->dta_list,5)
 IF (dta_cnt=0)
  CALL checkforerrors("Main")
  GO TO exit_script
 ENDIF
 CALL getdtas(null)
 IF ((request->load_reference_range_ind > 0))
  CALL getreferenceranges(null)
  IF ((flat_reply->qual_cnt > 0))
   CALL getrefrangefactorrules(null)
   IF ((rrfr_flat_reply->qual_cnt > 0))
    CALL getalpharesponserules(null)
   ENDIF
  ENDIF
  IF ((request->load_advanced_delta_ind > 0))
   IF ((flat_reply->qual_cnt > 0))
    CALL getadvanceddeltas(null)
   ENDIF
  ENDIF
  IF ((request->load_alpha_response_ind > 0))
   IF ((flat_reply->qual_cnt > 0))
    CALL getalpharesponses(null)
    CALL getalpharesponsecategories(null)
   ENDIF
  ENDIF
 ENDIF
 IF ((request->load_data_map_ind > 0))
  CALL getdatamaps(null)
 ENDIF
 IF ((request->load_interpretation_ind > 0))
  CALL getinterpretations(null)
 ENDIF
 IF ((request->load_cond_expression_ind > 0))
  CALL getexpressionids(null)
 ENDIF
 IF ((request->load_io_total_definition_ind > 0))
  CALL getiototaldefids(null)
 ENDIF
 CALL getparenteventcode(null)
 CALL getcodevalueextension(null)
#exit_script
 IF (size(reply->dta_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE getdtas(null)
   DECLARE d_start = i4 WITH noconstant(1)
   DECLARE d_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE d_total = i4 WITH noconstant((d_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,d_total)
   FOR (i = (dta_cnt+ 1) TO d_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(d_loop_cnt)),
     discrete_task_assay dta
    PLAN (d
     WHERE assign(d_start,evaluate(d.seq,1,1,(d_start+ expand_size))))
     JOIN (dta
     WHERE expand(num,d_start,((d_start+ expand_size) - 1),dta.task_assay_cd,reply->dta_list[num].
      task_assay_cd))
    DETAIL
     d_index = locateval(num,1,dta_cnt,dta.task_assay_cd,reply->dta_list[num].task_assay_cd)
     WHILE (d_index > 0)
       reply->dta_list[d_index].task_assay_cd = dta.task_assay_cd, reply->dta_list[d_index].
       standard_assay_id = dta.strt_assay_id, reply->dta_list[d_index].activity_type_cd = dta
       .activity_type_cd,
       reply->dta_list[d_index].default_result_type_cd = dta.default_result_type_cd, reply->dta_list[
       d_index].event_cd = dta.event_cd, reply->dta_list[d_index].mnemonic = dta.mnemonic,
       reply->dta_list[d_index].description = dta.description, reply->dta_list[d_index].icd_code_ind
        = dta.icd_code_ind, reply->dta_list[d_index].active_ind = dta.active_ind,
       reply->dta_list[d_index].specific_result_type_code_set = dta.code_set, reply->dta_list[d_index
       ].beg_effective_dt_tm = dta.beg_effective_dt_tm, reply->dta_list[d_index].end_effective_dt_tm
        = dta.end_effective_dt_tm,
       reply->dta_list[d_index].related_assay_ind = dta.rel_assay_ind, reply->dta_list[d_index].
       delta_lvl_flag = dta.delta_lvl_flag, reply->dta_list[d_index].modifier_ind = dta.modifier_ind,
       reply->dta_list[d_index].single_select_ind = dta.single_select_ind, reply->dta_list[d_index].
       default_type_flag = dta.default_type_flag, reply->dta_list[d_index].concept_cki = dta
       .concept_cki,
       reply->dta_list[d_index].blood_bank_result_processing_cd = dta.bb_result_processing_cd, reply
       ->dta_list[d_index].radiology_section_type_cd = dta.rad_section_type_cd, reply->dta_list[
       d_index].version_number = dta.version_number,
       reply->dta_list[d_index].io_flag = dta.io_flag, reply->dta_list[d_index].signature_line_ind =
       dta.signature_line_ind, reply->dta_list[d_index].label_template_id = dta.label_template_id,
       reply->dta_list[d_index].template_script_cd = dta.template_script_cd, d_index = locateval(num,
        (d_index+ 1),dta_cnt,dta.task_assay_cd,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetDtas")
 END ;Subroutine
 SUBROUTINE getreferenceranges(null)
   DECLARE rr_start = i4 WITH noconstant(1)
   DECLARE rr_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE rr_total = i4 WITH noconstant((rr_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,rr_total)
   FOR (i = (dta_cnt+ 1) TO rr_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(rr_loop_cnt)),
     reference_range_factor rrf
    PLAN (d1
     WHERE assign(rr_start,evaluate(d1.seq,1,1,(rr_start+ expand_size))))
     JOIN (rrf
     WHERE expand(num,rr_start,((rr_start+ expand_size) - 1),rrf.task_assay_cd,reply->dta_list[num].
      task_assay_cd))
    ORDER BY rrf.task_assay_cd
    HEAD REPORT
     rrf_cnt = 0
    HEAD rrf.task_assay_cd
     rrf_cnt = 0
    DETAIL
     rr_index = locateval(num,1,dta_cnt,rrf.task_assay_cd,reply->dta_list[num].task_assay_cd),
     rrf_cnt = (rrf_cnt+ 1)
     WHILE (rr_index > 0)
       stat = alterlist(reply->dta_list[rr_index].reference_range_list,rrf_cnt), reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].reference_range_factor_id = rrf
       .reference_range_factor_id, reply->dta_list[rr_index].reference_range_list[rrf_cnt].species_cd
        = rrf.species_cd,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].service_resource_cd = rrf
       .service_resource_cd, reply->dta_list[rr_index].reference_range_list[rrf_cnt].active_ind = rrf
       .active_ind, reply->dta_list[rr_index].reference_range_list[rrf_cnt].unknown_age_ind = rrf
       .unknown_age_ind,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].sex_cd = rrf.sex_cd, reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].age_from_units_cd = rrf.age_from_units_cd, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].age_from_minutes = rrf.age_from_minutes,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].age_to_units_cd = rrf.age_to_units_cd,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].age_to_minutes = rrf.age_to_minutes,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].specimen_type_cd = rrf
       .specimen_type_cd,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].reference_range_online_code_set = rrf
       .code_set, reply->dta_list[rr_index].reference_range_list[rrf_cnt].precedence_sequence = rrf
       .precedence_sequence, reply->dta_list[rr_index].reference_range_list[rrf_cnt].
       beg_effective_dt_tm = rrf.beg_effective_dt_tm,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].end_effective_dt_tm = rrf
       .end_effective_dt_tm, reply->dta_list[rr_index].reference_range_list[rrf_cnt].encntr_type_cd
        = rrf.encntr_type_cd, reply->dta_list[rr_index].reference_range_list[rrf_cnt].default_result
        = rrf.default_result,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].review_ind = rrf.review_ind, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].review_low = rrf.review_low, reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].review_high = rrf.review_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].sensitive_ind = rrf.sensitive_ind,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].sensitive_low = rrf.sensitive_low,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].sensitive_high = rrf.sensitive_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].normal_ind = rrf.normal_ind, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].normal_low = rrf.normal_low, reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].normal_high = rrf.normal_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].critical_ind = rrf.critical_ind, reply
       ->dta_list[rr_index].reference_range_list[rrf_cnt].critical_low = rrf.critical_low, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].critical_high = rrf.critical_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].units_cd = rrf.units_cd, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].mins_back = rrf.mins_back, reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].default_result_ind = rrf.def_result_ind,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].linear_ind = rrf.linear_ind, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].linear_low = rrf.linear_low, reply->dta_list[
       rr_index].reference_range_list[rrf_cnt].linear_high = rrf.linear_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].feasible_ind = rrf.feasible_ind, reply
       ->dta_list[rr_index].reference_range_list[rrf_cnt].feasible_low = rrf.feasible_low, reply->
       dta_list[rr_index].reference_range_list[rrf_cnt].feasible_high = rrf.feasible_high,
       reply->dta_list[rr_index].reference_range_list[rrf_cnt].delta_check_type_cd = rrf
       .delta_check_type_cd, reply->dta_list[rr_index].reference_range_list[rrf_cnt].delta_minutes =
       rrf.delta_minutes, reply->dta_list[rr_index].reference_range_list[rrf_cnt].delta_value = rrf
       .delta_value,
       flat_reply_cnt = (flat_reply_cnt+ 1), stat = alterlist(flat_reply->qual,flat_reply_cnt),
       flat_reply->qual[flat_reply_cnt].rr_factor_id = rrf.reference_range_factor_id,
       flat_reply->qual[flat_reply_cnt].task_assay_cd = rrf.task_assay_cd, flat_reply->qual[
       flat_reply_cnt].dta_list_index = rr_index, flat_reply->qual[flat_reply_cnt].rr_list_index =
       rrf_cnt,
       flat_reply->qual_cnt = flat_reply_cnt, rr_index = locateval(num,(rr_index+ 1),dta_cnt,rrf
        .task_assay_cd,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetReferenceRanges")
 END ;Subroutine
 SUBROUTINE getrefrangefactorrules(null)
   DECLARE rrfr_start = i4 WITH noconstant(1)
   DECLARE rrfr_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(flat_reply_cnt)/ expand_size)))
   DECLARE rrfr_total = i4 WITH noconstant((rrfr_loop_cnt * expand_size))
   SET stat = alterlist(flat_reply->qual,rrfr_total)
   FOR (i = (flat_reply_cnt+ 1) TO rrfr_total)
     SET flat_reply->qual[i].rr_factor_id = flat_reply->qual[flat_reply_cnt].rr_factor_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d2a  WITH seq = value(rrfr_loop_cnt)),
     ref_range_factor_rule rrfr
    PLAN (d2a
     WHERE assign(rrfr_start,evaluate(d2a.seq,1,1,(rrfr_start+ expand_size))))
     JOIN (rrfr
     WHERE expand(num,rrfr_start,((rrfr_start+ expand_size) - 1),rrfr.reference_range_factor_id,
      flat_reply->qual[num].rr_factor_id))
    ORDER BY rrfr.reference_range_factor_id
    HEAD REPORT
     rrfr_cnt = 0
    HEAD rrfr.reference_range_factor_id
     rrfr_cnt = 0
    DETAIL
     rrfr_index = locateval(num,1,flat_reply->qual_cnt,rrfr.reference_range_factor_id,flat_reply->
      qual[num].rr_factor_id), rrfr_cnt = (rrfr_cnt+ 1)
     WHILE (rrfr_index > 0)
       dtaindex = flat_reply->qual[rrfr_index].dta_list_index, rrindex = flat_reply->qual[rrfr_index]
       .rr_list_index, stat = alterlist(reply->dta_list[dtaindex].reference_range_list[rrindex].
        rrf_rule_list,rrfr_cnt),
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].critical_high
        = rrfr.critical_high, reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
       rrfr_cnt].critical_limit_ind = rrfr.critical_limit_ind, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].critical_low = rrfr.critical_low,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].feasible_high
        = rrfr.feasible_high, reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
       rrfr_cnt].feasible_ind = rrfr.feasible_limit_ind, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].feasible_low = rrfr.feasible_low,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].
       from_gestation_days = rrfr.from_gestation_days, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].from_height = rrfr.from_height, reply->
       dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].from_height_unit_cd
        = rrfr.from_height_unit_cd,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].from_weight =
       rrfr.from_weight, reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
       rrfr_cnt].from_weight_unit_cd = rrfr.from_weight_unit_cd, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].location_cd = rrfr.location_cd,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].normal_high =
       rrfr.normal_high, reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
       rrfr_cnt].normal_limit_ind = rrfr.normal_limit_ind, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].normal_low = rrfr.normal_low,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].
       ref_range_factor_rule_id = rrfr.ref_range_factor_rule_id, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].to_gestation_days = rrfr
       .to_gestation_days, reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
       rrfr_cnt].to_height = rrfr.to_height,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].
       to_height_unit_cd = rrfr.to_height_unit_cd, reply->dta_list[dtaindex].reference_range_list[
       rrindex].rrf_rule_list[rrfr_cnt].to_weight = rrfr.to_weight, reply->dta_list[dtaindex].
       reference_range_list[rrindex].rrf_rule_list[rrfr_cnt].to_weight_unit_cd = rrfr
       .to_weight_unit_cd,
       rrfr_flat_reply_cnt = (rrfr_flat_reply_cnt+ 1), stat = alterlist(rrfr_flat_reply->qual,
        rrfr_flat_reply_cnt), rrfr_flat_reply->qual[rrfr_flat_reply_cnt].rrfr_id = rrfr
       .ref_range_factor_rule_id,
       rrfr_flat_reply->qual[rrfr_flat_reply_cnt].dta_list_index = dta_index, rrfr_flat_reply->qual[
       rrfr_flat_reply_cnt].rr_list_index = rrindex, rrfr_flat_reply->qual[rrfr_flat_reply_cnt].
       rrfr_list_index = rrfr_cnt,
       rrfr_flat_reply->qual_cnt = rrfr_flat_reply_cnt, rrfr_index = locateval(num,(rrfr_index+ 1),
        flat_reply->qual_cnt,rrfr.reference_range_factor_id,flat_reply->qual[num].rr_factor_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
   CALL checkforerrors("GetRefRangeFactorRules")
 END ;Subroutine
 SUBROUTINE getalpharesponserules(null)
   DECLARE arr_start = i4 WITH noconstant(1)
   DECLARE arr_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(rrfr_flat_reply_cnt)/ expand_size)))
   DECLARE arr_total = i4 WITH noconstant((arr_loop_cnt * expand_size))
   SET stat = alterlist(rrfr_flat_reply->qual,arr_total)
   FOR (i = (rrfr_flat_reply_cnt+ 1) TO arr_total)
     SET rrfr_flat_reply->qual[i].rrfr_id = rrfr_flat_reply->qual[rrfr_flat_reply_cnt].rrfr_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d2b  WITH seq = value(arr_loop_cnt)),
     alpha_response_rule arr
    PLAN (d2b
     WHERE assign(arr_start,evaluate(d2b.seq,1,1,(arr_start+ expand_size))))
     JOIN (arr
     WHERE expand(num,arr_start,((arr_start+ expand_size) - 1),arr.ref_range_factor_rule_id,
      rrfr_flat_reply->qual[num].rrfr_id))
    ORDER BY arr.ref_range_factor_rule_id
    HEAD REPORT
     arr_cnt = 0
    HEAD arr.ref_range_factor_rule_id
     arr_cnt = 0
    DETAIL
     arr_index = locateval(num,1,rrfr_flat_reply->qual_cnt,arr.ref_range_factor_rule_id,
      rrfr_flat_reply->qual[num].rrfr_id), arr_cnt = (arr_cnt+ 1)
     WHILE (arr_index > 0)
       dtaindex = rrfr_flat_reply->qual[arr_index].dta_list_index, rrindex = rrfr_flat_reply->qual[
       arr_index].rr_list_index, rrfrindex = rrfr_flat_reply->qual[arr_index].rrfr_list_index,
       stat = alterlist(reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[
        rrfrindex].ar_rule_list,arr_cnt), reply->dta_list[dtaindex].reference_range_list[rrindex].
       rrf_rule_list[rrfrindex].ar_rule_list[arr_cnt].alpha_response_id = 0.0, reply->dta_list[
       dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfrindex].ar_rule_list[arr_cnt].
       nomenclature_id = arr.nomenclature_id,
       reply->dta_list[dtaindex].reference_range_list[rrindex].rrf_rule_list[rrfrindex].ar_rule_list[
       arr_cnt].ref_range_factor_id = arr.reference_range_factor_id, arr_index = locateval(num,(
        arr_index+ 1),rrfr_flat_reply->qual_cnt,arr.ref_range_factor_rule_id,rrfr_flat_reply->qual[
        num].rrfr_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(rrfr_flat_reply->qual,rrfr_flat_reply_cnt)
   CALL checkforerrors("GetAlphaResponseRules")
 END ;Subroutine
 SUBROUTINE getalpharesponses(null)
   DECLARE ar_start = i4 WITH noconstant(1)
   DECLARE ar_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(flat_reply_cnt)/ expand_size)))
   DECLARE ar_total = i4 WITH noconstant((ar_loop_cnt * expand_size))
   SET stat = alterlist(flat_reply->qual,ar_total)
   FOR (i = (flat_reply_cnt+ 1) TO ar_total)
     SET flat_reply->qual[i].rr_factor_id = flat_reply->qual[flat_reply_cnt].rr_factor_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d2a  WITH seq = value(ar_loop_cnt)),
     alpha_responses ar
    PLAN (d2a
     WHERE assign(ar_start,evaluate(d2a.seq,1,1,(ar_start+ expand_size))))
     JOIN (ar
     WHERE expand(num,ar_start,((ar_start+ expand_size) - 1),ar.reference_range_factor_id,flat_reply
      ->qual[num].rr_factor_id))
    ORDER BY ar.reference_range_factor_id, ar.sequence
    HEAD REPORT
     ar_cnt = 0
    HEAD ar.reference_range_factor_id
     ar_cnt = 0
    DETAIL
     ar_index = locateval(num,1,flat_reply->qual_cnt,ar.reference_range_factor_id,flat_reply->qual[
      num].rr_factor_id), ar_cnt = (ar_cnt+ 1)
     WHILE (ar_index > 0)
       dtaindex = flat_reply->qual[ar_index].dta_list_index, rrindex = flat_reply->qual[ar_index].
       rr_list_index, stat = alterlist(reply->dta_list[dtaindex].reference_range_list[rrindex].
        alpha_response_list,ar_cnt),
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_list[ar_cnt].
       nomenclature_id = ar.nomenclature_id, reply->dta_list[dtaindex].reference_range_list[rrindex].
       alpha_response_list[ar_cnt].alpha_response_id = 0.0, reply->dta_list[dtaindex].
       reference_range_list[rrindex].alpha_response_list[ar_cnt].sequence = ar.sequence,
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_list[ar_cnt].
       use_units_ind = ar.use_units_ind, reply->dta_list[dtaindex].reference_range_list[rrindex].
       alpha_response_list[ar_cnt].result_process_cd = ar.result_process_cd, reply->dta_list[dtaindex
       ].reference_range_list[rrindex].alpha_response_list[ar_cnt].default_ind = ar.default_ind,
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_list[ar_cnt].
       description = ar.description, reply->dta_list[dtaindex].reference_range_list[rrindex].
       alpha_response_list[ar_cnt].active_ind = ar.active_ind, reply->dta_list[dtaindex].
       reference_range_list[rrindex].alpha_response_list[ar_cnt].beg_effective_dt_tm = ar
       .beg_effective_dt_tm,
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_list[ar_cnt].
       end_effective_dt_tm = ar.end_effective_dt_tm, reply->dta_list[dtaindex].reference_range_list[
       rrindex].alpha_response_list[ar_cnt].result_value = ar.result_value, reply->dta_list[dtaindex]
       .reference_range_list[rrindex].alpha_response_list[ar_cnt].reference_ind = ar.reference_ind,
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_list[ar_cnt].
       multi_alpha_sort_order = ar.multi_alpha_sort_order, reply->dta_list[dtaindex].
       reference_range_list[rrindex].alpha_response_list[ar_cnt].ref_range_factor_id = ar
       .reference_range_factor_id, reply->dta_list[dtaindex].reference_range_list[rrindex].
       alpha_response_list[ar_cnt].concept_cki = ar.concept_cki,
       ar_index = locateval(num,(ar_index+ 1),flat_reply->qual_cnt,ar.reference_range_factor_id,
        flat_reply->qual[num].rr_factor_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
   CALL checkforerrors("GetAlphaResponses")
 END ;Subroutine
 SUBROUTINE getalpharesponsecategories(null)
   DECLARE arc_start = i4 WITH noconstant(1)
   DECLARE arc_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(flat_reply_cnt)/ expand_size)))
   DECLARE arc_total = i4 WITH noconstant((arc_loop_cnt * expand_size))
   SET stat = alterlist(flat_reply->qual,arc_total)
   FOR (i = (flat_reply_cnt+ 1) TO arc_total)
     SET flat_reply->qual[i].rr_factor_id = flat_reply->qual[flat_reply_cnt].rr_factor_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d2a  WITH seq = value(arc_loop_cnt)),
     alpha_responses_category arc
    PLAN (d2a
     WHERE assign(arc_start,evaluate(d2a.seq,1,1,(arc_start+ expand_size))))
     JOIN (arc
     WHERE expand(num,arc_start,((arc_start+ expand_size) - 1),arc.reference_range_factor_id,
      flat_reply->qual[num].rr_factor_id))
    ORDER BY arc.reference_range_factor_id
    HEAD REPORT
     arc_cnt = 0
    HEAD arc.reference_range_factor_id
     arc_cnt = 0
    DETAIL
     arc_index = locateval(num,1,flat_reply->qual_cnt,arc.reference_range_factor_id,flat_reply->qual[
      num].rr_factor_id), arc_cnt = (arc_cnt+ 1)
     WHILE (arc_index > 0)
       dtaindex = flat_reply->qual[arc_index].dta_list_index, rrindex = flat_reply->qual[arc_index].
       rr_list_index, stat = alterlist(reply->dta_list[dtaindex].reference_range_list[rrindex].
        alpha_response_cat_list,arc_cnt),
       reply->dta_list[dtaindex].reference_range_list[rrindex].alpha_response_cat_list[arc_cnt].id =
       arc.alpha_responses_category_id, reply->dta_list[dtaindex].reference_range_list[rrindex].
       alpha_response_cat_list[arc_cnt].name = arc.category_name, reply->dta_list[dtaindex].
       reference_range_list[rrindex].alpha_response_cat_list[arc_cnt].expand_ind = arc.expand_flag,
       arc_index = locateval(num,(arc_index+ 1),flat_reply->qual_cnt,arc.reference_range_factor_id,
        flat_reply->qual[num].rr_factor_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
   CALL checkforerrors("GetAlphaResponseCategories")
 END ;Subroutine
 SUBROUTINE getadvanceddeltas(null)
   DECLARE ad_start = i4 WITH noconstant(1)
   DECLARE ad_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(flat_reply_cnt)/ expand_size)))
   DECLARE ad_total = i4 WITH noconstant((ad_loop_cnt * expand_size))
   SET stat = alterlist(flat_reply->qual,ad_total)
   FOR (i = (flat_reply_cnt+ 1) TO ad_total)
     SET flat_reply->qual[i].rr_factor_id = flat_reply->qual[flat_reply_cnt].rr_factor_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d8  WITH seq = value(ad_loop_cnt)),
     advanced_delta ad
    PLAN (d8
     WHERE assign(ad_start,evaluate(d8.seq,1,1,(ad_start+ expand_size))))
     JOIN (ad
     WHERE expand(num,ad_start,((ad_start+ expand_size) - 1),ad.reference_range_factor_id,flat_reply
      ->qual[num].rr_factor_id))
    ORDER BY ad.reference_range_factor_id
    HEAD REPORT
     ad_cnt = 0
    HEAD ad.reference_range_factor_id
     ad_cnt = 0
    DETAIL
     ad_index = locateval(num,1,size(flat_reply->qual,5),ad.reference_range_factor_id,flat_reply->
      qual[num].rr_factor_id), ad_cnt = (ad_cnt+ 1)
     WHILE (ad_index > 0)
       dtaindex2 = flat_reply->qual[ad_index].dta_list_index, rrindex2 = flat_reply->qual[ad_index].
       rr_list_index, stat = alterlist(reply->dta_list[dtaindex2].reference_range_list[rrindex2].
        advanced_delta_list,ad_cnt),
       reply->dta_list[dtaindex2].reference_range_list[rrindex2].advanced_delta_list[ad_cnt].
       active_ind = ad.active_ind, reply->dta_list[dtaindex2].reference_range_list[rrindex2].
       advanced_delta_list[ad_cnt].advanced_delta_id = ad.advanced_delta_id, reply->dta_list[
       dtaindex2].reference_range_list[rrindex2].advanced_delta_list[ad_cnt].delta_ind = ad.delta_ind,
       reply->dta_list[dtaindex2].reference_range_list[rrindex2].advanced_delta_list[ad_cnt].
       delta_low = ad.delta_low, reply->dta_list[dtaindex2].reference_range_list[rrindex2].
       advanced_delta_list[ad_cnt].delta_high = ad.delta_high, reply->dta_list[dtaindex2].
       reference_range_list[rrindex2].advanced_delta_list[ad_cnt].delta_check_type_cd = ad
       .delta_check_type_cd,
       reply->dta_list[dtaindex2].reference_range_list[rrindex2].advanced_delta_list[ad_cnt].
       delta_minutes = ad.delta_minutes, reply->dta_list[dtaindex2].reference_range_list[rrindex2].
       advanced_delta_list[ad_cnt].delta_value = ad.delta_value, ad_index = locateval(num,(ad_index+
        1),flat_reply->qual_cnt,ad.reference_range_factor_id,flat_reply->qual[num].rr_factor_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
   CALL checkforerrors("GetAdvancedDeltas")
 END ;Subroutine
 SUBROUTINE getdatamaps(null)
   DECLARE dm_start = i4 WITH noconstant(1)
   DECLARE dm_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE dm_total = i4 WITH noconstant((dm_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,dm_total)
   FOR (i = (dta_cnt+ 1) TO dm_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d3  WITH seq = value(dm_loop_cnt)),
     data_map dm
    PLAN (d3
     WHERE assign(dm_start,evaluate(d3.seq,1,1,(dm_start+ expand_size))))
     JOIN (dm
     WHERE expand(num,dm_start,((dm_start+ expand_size) - 1),dm.task_assay_cd,reply->dta_list[num].
      task_assay_cd))
    ORDER BY dm.task_assay_cd
    HEAD REPORT
     dm_cnt = 0
    HEAD dm.task_assay_cd
     dm_cnt = 0
    DETAIL
     dm_index = locateval(num,1,dta_cnt,dm.task_assay_cd,reply->dta_list[num].task_assay_cd), dm_cnt
      = (dm_cnt+ 1)
     WHILE (dm_index > 0)
       stat = alterlist(reply->dta_list[dm_index].data_map_list,dm_cnt), reply->dta_list[dm_index].
       data_map_list[dm_cnt].data_map_type_flag = dm.data_map_type_flag, reply->dta_list[dm_index].
       data_map_list[dm_cnt].max_digits = dm.max_digits,
       reply->dta_list[dm_index].data_map_list[dm_cnt].min_decimal_places = dm.min_decimal_places,
       reply->dta_list[dm_index].data_map_list[dm_cnt].min_digits = dm.min_digits, reply->dta_list[
       dm_index].data_map_list[dm_cnt].service_resource_cd = dm.service_resource_cd,
       reply->dta_list[dm_index].data_map_list[dm_cnt].active_ind = dm.active_ind, reply->dta_list[
       dm_index].data_map_list[dm_cnt].beg_effective_dt_tm = dm.beg_effective_dt_tm, reply->dta_list[
       dm_index].data_map_list[dm_cnt].end_effective_dt_tm = dm.end_effective_dt_tm,
       dm_index = locateval(num,(dm_index+ 1),dta_cnt,dm.task_assay_cd,reply->dta_list[num].
        task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetDataMaps")
 END ;Subroutine
 SUBROUTINE getinterpretations(null)
   DECLARE id_start = i4 WITH noconstant(1)
   DECLARE id_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE id_total = i4 WITH noconstant((id_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,id_total)
   FOR (i = (dta_cnt+ 1) TO id_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d5  WITH seq = value(id_loop_cnt)),
     interp_data id,
     long_text lt
    PLAN (d5
     WHERE assign(id_start,evaluate(d5.seq,1,1,(id_start+ expand_size))))
     JOIN (id
     WHERE expand(num,id_start,((id_start+ expand_size) - 1),id.task_assay_cd,reply->dta_list[num].
      task_assay_cd))
     JOIN (lt
     WHERE lt.long_text_id=id.long_text_id)
    ORDER BY id.task_assay_cd
    HEAD REPORT
     id_cnt = 0
    HEAD id.task_assay_cd
     id_cnt = 0
    DETAIL
     id_index = locateval(num,1,dta_cnt,id.task_assay_cd,reply->dta_list[num].task_assay_cd), id_cnt
      = (id_cnt+ 1)
     WHILE (id_index > 0)
       stat = alterlist(reply->dta_list[id_index].interp_list,id_cnt), reply->dta_list[id_index].
       interp_list[id_cnt].interp_data_id = id.interp_data_id, reply->dta_list[id_index].interp_list[
       id_cnt].service_resource_cd = id.service_resource_cd,
       reply->dta_list[id_index].interp_list[id_cnt].long_text_id = id.long_text_id, reply->dta_list[
       id_index].interp_list[id_cnt].long_text = lt.long_text, reply->dta_list[id_index].interp_list[
       id_cnt].beg_effective_dt_tm = id.beg_effective_dt_tm,
       reply->dta_list[id_index].interp_list[id_cnt].end_effective_dt_tm = id.end_effective_dt_tm,
       reply->dta_list[id_index].interp_list[id_cnt].active_ind = id.active_ind, id_index = locateval
       (num,(id_index+ 1),dta_cnt,id.task_assay_cd,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetInterpretations")
 END ;Subroutine
 SUBROUTINE getequations(null)
   DECLARE eq_dta_cnt = i4 WITH noconstant(size(reply->dta_list,5))
   IF (eq_dta_cnt=0)
    RETURN(null)
   ENDIF
   DECLARE eq_start = i4 WITH noconstant(1)
   DECLARE eq_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(eq_dta_cnt)/ expand_size)))
   DECLARE eq_total = i4 WITH noconstant((eq_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,eq_total)
   FOR (i = (eq_dta_cnt+ 1) TO eq_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[eq_dta_cnt].task_assay_cd
   ENDFOR
   SET count = 0
   SELECT INTO "nl:"
    FROM (dummyt d6  WITH seq = value(eq_loop_cnt)),
     equation eq
    PLAN (d6
     WHERE assign(eq_start,evaluate(d6.seq,1,1,(eq_start+ expand_size))))
     JOIN (eq
     WHERE expand(num,eq_start,((eq_start+ expand_size) - 1),eq.task_assay_cd,reply->dta_list[num].
      task_assay_cd))
    ORDER BY eq.task_assay_cd
    HEAD REPORT
     eq_cnt = 0
    HEAD eq.task_assay_cd
     eq_cnt = 0
    DETAIL
     eq_index = locateval(num,1,eq_dta_cnt,eq.task_assay_cd,reply->dta_list[num].task_assay_cd),
     eq_cnt = (eq_cnt+ 1)
     WHILE (eq_index > 0)
       stat = alterlist(reply->dta_list[eq_index].equation_list,eq_cnt), reply->dta_list[eq_index].
       equation_list[eq_cnt].equation_id = eq.equation_id, reply->dta_list[eq_index].equation_list[
       eq_cnt].service_resource_cd = eq.service_resource_cd,
       reply->dta_list[eq_index].equation_list[eq_cnt].species_cd = eq.species_cd, reply->dta_list[
       eq_index].equation_list[eq_cnt].age_from_units_cd = eq.age_from_units_cd, reply->dta_list[
       eq_index].equation_list[eq_cnt].age_from_minutes = eq.age_from_minutes,
       reply->dta_list[eq_index].equation_list[eq_cnt].age_to_units_cd = eq.age_to_units_cd, reply->
       dta_list[eq_index].equation_list[eq_cnt].age_to_minutes = eq.age_to_minutes, reply->dta_list[
       eq_index].equation_list[eq_cnt].sex_cd = eq.sex_cd,
       reply->dta_list[eq_index].equation_list[eq_cnt].unknown_age_ind = eq.unknown_age_ind, reply->
       dta_list[eq_index].equation_list[eq_cnt].equation_description = eq.equation_description, reply
       ->dta_list[eq_index].equation_list[eq_cnt].active_ind = eq.active_ind,
       reply->dta_list[eq_index].equation_list[eq_cnt].active_dt_tm = eq.active_dt_tm, reply->
       dta_list[eq_index].equation_list[eq_cnt].inactive_dt_tm = eq.inactive_dt_tm, reply->dta_list[
       eq_index].equation_list[eq_cnt].default_ind = eq.default_ind,
       reply->dta_list[eq_index].equation_list[eq_cnt].equation_postfix = eq.equation_postfix,
       eq_flat_reply_cnt = (eq_flat_reply_cnt+ 1), stat = alterlist(eq_flat_reply->qual,
        eq_flat_reply_cnt),
       eq_flat_reply->qual[eq_flat_reply_cnt].task_assay_cd = eq.task_assay_cd, eq_flat_reply->qual[
       eq_flat_reply_cnt].dta_list_index = eq_index, eq_flat_reply->qual[eq_flat_reply_cnt].
       eq_list_index = eq_cnt,
       eq_flat_reply->qual[eq_flat_reply_cnt].equation_id = eq.equation_id, eq_flat_reply->qual_cnt
        = eq_flat_reply_cnt, eq_index = locateval(num,(eq_index+ 1),eq_dta_cnt,eq.task_assay_cd,reply
        ->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,eq_dta_cnt)
   CALL checkforerrors("GetEquations")
 END ;Subroutine
 SUBROUTINE getequationcomponents(null)
   DECLARE eqc_start = i4 WITH noconstant(1)
   DECLARE eqc_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(eq_flat_reply_cnt)/ expand_size)))
   DECLARE eqc_total = i4 WITH noconstant((eqc_loop_cnt * expand_size))
   SET stat = alterlist(eq_flat_reply->qual,eqc_total)
   FOR (i = (eq_flat_reply_cnt+ 1) TO eqc_total)
     SET eq_flat_reply->qual[i].equation_id = eq_flat_reply->qual[eq_flat_reply_cnt].equation_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d7  WITH seq = value(eqc_loop_cnt)),
     equation_component eqc
    PLAN (d7
     WHERE assign(eqc_start,evaluate(d7.seq,1,1,(eqc_start+ expand_size))))
     JOIN (eqc
     WHERE expand(num,eqc_start,((eqc_start+ expand_size) - 1),eqc.equation_id,eq_flat_reply->qual[
      num].equation_id))
    ORDER BY eqc.equation_id, eqc.sequence
    HEAD REPORT
     eqc_cnt = 0
    HEAD eqc.equation_id
     eqc_cnt = 0, included_assay_cd_pos = 0
    DETAIL
     IF (((eqc.included_assay_cd > 0) OR (eqc.component_flag=3)) )
      eqc_index = locateval(num,1,eq_flat_reply->qual_cnt,eqc.equation_id,eq_flat_reply->qual[num].
       equation_id), eqc_cnt = (eqc_cnt+ 1)
      WHILE (eqc_index > 0)
        dtaindex3 = eq_flat_reply->qual[eqc_index].dta_list_index, eqindex = eq_flat_reply->qual[
        eqc_index].eq_list_index, stat = alterlist(reply->dta_list[dtaindex3].equation_list[eqindex].
         equation_comp_list,eqc_cnt),
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].component_flag
         = eqc.component_flag, reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[
        eqc_cnt].constant_value = eqc.constant_value, reply->dta_list[dtaindex3].equation_list[
        eqindex].equation_comp_list[eqc_cnt].cross_drawn_dt_tm_ind = eqc.cross_drawn_dt_tm_ind,
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].default_value
         = eqc.default_value, reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[
        eqc_cnt].included_assay_cd = eqc.included_assay_cd, reply->dta_list[dtaindex3].equation_list[
        eqindex].equation_comp_list[eqc_cnt].look_time_direction_flag = eqc.look_time_direction_flag,
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].name = eqc.name,
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].result_req_flag
         = eqc.result_req_flag, reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[
        eqc_cnt].result_status_cd = eqc.result_status_cd,
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].sequence = eqc
        .sequence, reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].
        time_window_back_minutes = eqc.time_window_back_minutes, reply->dta_list[dtaindex3].
        equation_list[eqindex].equation_comp_list[eqc_cnt].time_window_minutes = eqc
        .time_window_minutes,
        reply->dta_list[dtaindex3].equation_list[eqindex].equation_comp_list[eqc_cnt].units_cd = eqc
        .units_cd, included_assay_cd_pos = locateval(num,locateval_start,size(reply->dta_list,5),eqc
         .included_assay_cd,reply->dta_list[num].task_assay_cd)
        IF (included_assay_cd_pos=0)
         count = (size(reply->dta_list,5)+ 1), stat = alterlist(reply->dta_list,count)
         IF (eqc.included_assay_cd > 0)
          reply->dta_list[count].task_assay_cd = eqc.included_assay_cd
         ENDIF
        ENDIF
        eqc_index = locateval(num,(eqc_index+ 1),eq_flat_reply->qual_cnt,eqc.equation_id,
         eq_flat_reply->qual[num].equation_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(eq_flat_reply->qual,eq_flat_reply_cnt)
   CALL checkforerrors("GetEquationComponents")
 END ;Subroutine
 SUBROUTINE getexpressionids(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->task_assay_cd_list,5))),
     cond_expression_comp cec
    PLAN (d)
     JOIN (cec
     WHERE (cec.trigger_assay_cd=request->task_assay_cd_list[d.seq].task_assay_cd))
    ORDER BY cec.trigger_assay_cd
    HEAD REPORT
     expression_cnt = 0
    HEAD cec.trigger_assay_cd
     expression_cnt = 0
    DETAIL
     dm_index = locateval(num,1,dta_cnt,cec.trigger_assay_cd,reply->dta_list[num].task_assay_cd),
     expression_cnt = (expression_cnt+ 1)
     WHILE (dm_index > 0)
       stat = alterlist(reply->dta_list[dm_index].expression_list,expression_cnt), reply->dta_list[
       dm_index].expression_list[expression_cnt].expression_id = cec.cond_expression_id, dm_index =
       locateval(num,(dm_index+ 1),dta_cnt,cec.trigger_assay_cd,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetExpressionIds")
 END ;Subroutine
 SUBROUTINE getiototaldefids(null)
   DECLARE io_start = i4 WITH noconstant(1)
   DECLARE io_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE io_total = i4 WITH noconstant((io_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,io_total)
   FOR (i = (dta_cnt+ 1) TO io_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(io_loop_cnt)),
     io_total_definition itd
    PLAN (d1
     WHERE assign(io_start,evaluate(d1.seq,1,1,(io_start+ expand_size))))
     JOIN (itd
     WHERE expand(num,io_start,((io_start+ expand_size) - 1),itd.task_assay_cd,reply->dta_list[num].
      task_assay_cd)
      AND itd.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY itd.task_assay_cd
    HEAD REPORT
     io_cnt = 0
    HEAD itd.task_assay_cd
     io_cnt = 0
    DETAIL
     io_index = locateval(num,1,dta_cnt,itd.task_assay_cd,reply->dta_list[num].task_assay_cd), io_cnt
      = (io_cnt+ 1)
     WHILE (io_index > 0)
      reply->dta_list[io_index].io_total_definition_id = itd.io_total_definition_id,io_index =
      locateval(num,(io_index+ 1),dta_cnt,itd.task_assay_cd,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetIoTotalDefIds")
 END ;Subroutine
 SUBROUTINE getparenteventcode(null)
   DECLARE pec_start = i4 WITH noconstant(1)
   DECLARE pec_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE pec_total = i4 WITH noconstant((pec_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,pec_total)
   FOR (i = (dta_cnt+ 1) TO pec_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d9  WITH seq = value(pec_loop_cnt)),
     code_value_event_r cver
    PLAN (d9
     WHERE assign(pec_start,evaluate(d9.seq,1,1,(pec_start+ expand_size))))
     JOIN (cver
     WHERE expand(num,pec_start,((pec_start+ expand_size) - 1),cver.parent_cd,reply->dta_list[num].
      task_assay_cd))
    DETAIL
     pec_index = locateval(num,1,dta_cnt,cver.parent_cd,reply->dta_list[num].task_assay_cd)
     WHILE (pec_index > 0)
      IF ((reply->dta_list[pec_index].event_cd=0))
       reply->dta_list[pec_index].event_cd = cver.event_cd
      ENDIF
      ,pec_index = locateval(num,(pec_index+ 1),dta_cnt,cver.parent_cd,reply->dta_list[num].
       task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetParentEventCode")
 END ;Subroutine
 SUBROUTINE getcodevalueextension(null)
   DECLARE cve_start = i4 WITH noconstant(1)
   DECLARE cve_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(dta_cnt)/ expand_size)))
   DECLARE cve_total = i4 WITH noconstant((cve_loop_cnt * expand_size))
   SET stat = alterlist(reply->dta_list,cve_total)
   FOR (i = (dta_cnt+ 1) TO cve_total)
     SET reply->dta_list[i].task_assay_cd = reply->dta_list[dta_cnt].task_assay_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt dcve  WITH seq = value(cve_loop_cnt)),
     code_value_extension cve
    PLAN (dcve
     WHERE assign(cve_start,evaluate(dcve.seq,1,1,(cve_start+ expand_size))))
     JOIN (cve
     WHERE expand(num,cve_start,((cve_start+ expand_size) - 1),cve.code_value,reply->dta_list[num].
      task_assay_cd)
      AND cve.code_set=14003
      AND cve.field_name="dta_witness_required_ind")
    DETAIL
     cve_index = locateval(num,1,dta_cnt,cve.code_value,reply->dta_list[num].task_assay_cd)
     WHILE (cve_index > 0)
      reply->dta_list[cve_index].witness_ind = cnvtint(cve.field_value),cve_index = locateval(num,(
       cve_index+ 1),dta_cnt,cve.code_value,reply->dta_list[num].task_assay_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->dta_list,dta_cnt)
   CALL checkforerrors("GetCodeValueExtension")
 END ;Subroutine
 SUBROUTINE checkforerrors(operation)
   SET errcode = 1
   WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET error_cnt = (error_cnt+ 1)
     IF (size(reply->status_data.subeventstatus,5) < error_cnt)
      SET stat = alterlist(reply->status_data.subeventstatus,error_cnt)
     ENDIF
     SET reply->status_data.subeventstatus[error_cnt].operationname = substring(1,25,trim(operation))
     SET reply->status_data.subeventstatus[error_cnt].targetobjectname = cnvtstring(errcode)
     SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = errmsg
    ENDIF
   ENDWHILE
   IF (error_cnt > 0)
    SET errcode = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
END GO
