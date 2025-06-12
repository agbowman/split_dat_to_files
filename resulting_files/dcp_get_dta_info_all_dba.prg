CREATE PROGRAM dcp_get_dta_info_all:dba
 IF (validate(reply,0)=0)
  RECORD reply(
    1 dta[*]
      2 task_assay_cd = f8
      2 active_ind = i2
      2 mnemonic = vc
      2 description = vc
      2 event_cd = f8
      2 activity_type_cd = f8
      2 activity_type_disp = vc
      2 activity_type_desc = vc
      2 activity_type_mean = vc
      2 default_result_type_cd = f8
      2 default_result_type_disp = c40
      2 default_result_type_desc = c60
      2 default_result_type_mean = vc
      2 code_set = i4
      2 equation[*]
        3 equation_id = f8
        3 equation_description = vc
        3 equation_postfix = vc
        3 script = vc
        3 species_cd = f8
        3 sex_cd = f8
        3 age_from_minutes = i4
        3 age_to_minutes = i4
        3 service_resource_cd = f8
        3 unknown_age_ind = i2
        3 e_comp_cnt = i4
        3 e_comp[*]
          4 constant_value = f8
          4 default_value = f8
          4 units_cd = f8
          4 included_assay_cd = f8
          4 name = vc
          4 result_req_flag = i2
          4 look_time_direction_flag = i2
          4 time_window_minutes = i4
          4 time_window_back_minutes = i4
          4 event_cd = f8
        3 age_from = i4
        3 age_to = i4
        3 age_from_units_cd = f8
        3 age_to_units_cd = f8
        3 age_from_units_meaning = vc
        3 age_to_units_meaning = vc
      2 ref_range_factor[*]
        3 species_cd = f8
        3 sex_cd = f8
        3 age_from_minutes = i4
        3 age_to_minutes = i4
        3 service_resource_cd = f8
        3 encntr_type_cd = f8
        3 specimen_type_cd = f8
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
        3 feasible_ind = i2
        3 feasible_low = f8
        3 feasible_high = f8
        3 units_cd = f8
        3 units_disp = c40
        3 units_desc = c60
        3 code_set = i4
        3 minutes_back = i4
        3 def_result_ind = i2
        3 default_result = vc
        3 default_result_value = f8
        3 unknown_age_ind = i2
        3 alpha_response_ind = i2
        3 alpha_responses_cnt = i4
        3 alpha_responses[*]
          4 nomenclature_id = f8
          4 source_string = vc
          4 short_string = vc
          4 mnemonic = c25
          4 sequence = i4
          4 default_ind = i2
          4 description = vc
          4 result_value = f8
          4 multi_alpha_sort_order = i4
          4 concept_identifier = vc
          4 concept_cki = vc
        3 age_from = i4
        3 age_to = i4
        3 age_from_units_cd = f8
        3 age_to_units_cd = f8
        3 age_from_units_meaning = vc
        3 age_to_units_meaning = vc
        3 categories[*]
          4 category_id = f8
          4 expand_flag = i2
          4 category_name = vc
          4 sequence = i4
          4 alpha_responses[*]
            5 nomenclature_id = f8
            5 source_string = vc
            5 short_string = vc
            5 mnemonic = c25
            5 sequence = i4
            5 default_ind = i2
            5 description = vc
            5 result_value = f8
            5 multi_alpha_sort_order = i4
            5 concept_identifier = vc
            5 concept_cki = vc
      2 data_map[*]
        3 data_map_type_flag = i2
        3 result_entry_format = i4
        3 max_digits = i4
        3 min_digits = i4
        3 min_decimal_places = i4
        3 service_resource_cd = f8
      2 modifier_ind = i2
      2 single_select_ind = i2
      2 default_type_flag = i2
      2 version_number = f8
      2 io_flag = i2
      2 io_total_definition_id = f8
      2 label_template_id = f8
      2 template_script_cd = f8
      2 event_set_cd = f8
      2 dta_offset_mins[*]
        3 dta_offset_min_id = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 offset_min_nbr = i4
        3 offset_min_type_cd = f8
      2 witness_required_ind = i2
    1 cond_exp[*]
      2 cond_expression_id = f8
      2 cond_expression_name = c100
      2 cond_expression_text = c512
      2 cond_postfix_txt = c512
      2 multiple_ind = i2
      2 prev_cond_expression_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 exp_comp[*]
        3 active_ind = i2
        3 beg_effective_dt_tm = dq8
        3 cond_comp_name = c30
        3 cond_expression_comp_id = f8
        3 end_effective_dt_tm = dq8
        3 operator_cd = f8
        3 parent_entity_id = f8
        3 parent_entity_name = c60
        3 prev_cond_expression_comp_id = f8
        3 required_ind = i2
        3 trigger_assay_cd = f8
        3 result_value = f8
        3 cond_expression_id = f8
      2 cond_dtas[*]
        3 active_ind = i2
        3 age_from_nbr = f8
        3 age_from_unit_cd = f8
        3 age_to_nbr = f8
        3 age_to_unit_cd = f8
        3 beg_effective_dt_tm = dq8
        3 conditional_assay_cd = f8
        3 conditional_dta_id = f8
        3 end_effective_dt_tm = dq8
        3 gender_cd = f8
        3 location_cd = f8
        3 position_cd = f8
        3 prev_conditional_dta_id = f8
        3 required_ind = i2
        3 unknown_age_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD flat_reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 dta_idx = i4
     2 reference_range_factor_id = f8
     2 reference_range_idx = i4
 )
 RECORD expand_record(
   1 qual[*]
     2 id = f8
     2 index = i4
 )
 SET modify = predeclare
 DECLARE task_assay_cd = f8 WITH private, noconstant(0.0)
 DECLARE dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE reply_dta_index = i4 WITH protect, noconstant(0)
 DECLARE rr_cnt = i4 WITH protect, noconstant(0)
 DECLARE flat_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtainx = i4 WITH protect, noconstant(0)
 DECLARE expand_blocks = i4 WITH protect, noconstant(0)
 DECLARE total_items = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(0)
 DECLARE expand_stop = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE exp_cnt = i4 WITH protect, noconstant(0)
 DECLARE comp_cnt = i4 WITH protect, noconstant(0)
 DECLARE cond_dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtaoffsetmin_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_dt_tm = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE expand_size = i4 WITH protect, constant(100)
 DECLARE getdtas(null) = null
 DECLARE getreferencerange(null) = null
 DECLARE getalpharesponses(null) = null
 DECLARE getparenteventcode(null) = null
 DECLARE getdatamap(null) = null
 DECLARE getequations(null) = null
 DECLARE getiototaldefinition(null) = null
 DECLARE getcategories(null) = null
 DECLARE geteventsetname(null) = null
 DECLARE getcondexpressions(null) = null
 DECLARE getcondexpressioncomps(null) = null
 DECLARE getconditionaldtas(null) = null
 DECLARE getdtaoffsetmins(null) = null
 DECLARE getwitnessrequired(null) = null
 SET reply->status_data.status = "F"
 SET dta_cnt = size(request->dta,5)
 IF (dta_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  task_assay_cd = cnvtreal(request->dta[d1.seq].task_assay_cd)
  FROM (dummyt d1  WITH seq = value(dta_cnt))
  PLAN (d1
   WHERE (request->dta[d1.seq].task_assay_cd != 0))
  ORDER BY task_assay_cd
  HEAD REPORT
   dta_cnt = 0
  HEAD task_assay_cd
   dta_cnt += 1
   IF (dta_cnt > size(reply->dta,5))
    stat = alterlist(reply->dta,(dta_cnt+ 10))
   ENDIF
   reply->dta[dta_cnt].task_assay_cd = request->dta[d1.seq].task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->dta,dta_cnt)
  WITH nocounter
 ;end select
 CALL getdtas(null)
 IF (dta_cnt=0)
  GO TO exit_script
 ENDIF
 CALL getreferencerange(null)
 CALL getalpharesponses(null)
 CALL getcategories(null)
 CALL getparenteventcode(null)
 CALL getdatamap(null)
 CALL getequations(null)
 CALL getiototaldefinition(null)
 CALL geteventsetname(null)
 CALL getcondexpressions(null)
 CALL getcondexpressioncomps(null)
 CALL getconditionaldtas(null)
 CALL getdtaoffsetmins(null)
 CALL getwitnessrequired(null)
#exit_script
 FREE RECORD flat_reply
 FREE RECORD expand_record
 IF (dta_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE getdtas(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     SELECT INTO "nl:"
      FROM discrete_task_assay dta
      PLAN (dta
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dta.task_assay_cd,
        expand_record->qual[expand_index].id,
        expand_size)
        AND dta.active_ind=1
        AND ((dta.beg_effective_dt_tm=null) OR (dta.beg_effective_dt_tm != null
        AND dta.beg_effective_dt_tm <= cnvtdatetime(current_dt_tm)
        AND ((dta.end_effective_dt_tm=null) OR (dta.end_effective_dt_tm != null
        AND dta.end_effective_dt_tm >= cnvtdatetime(current_dt_tm))) )) )
      ORDER BY dta.task_assay_cd
      HEAD dta.task_assay_cd
       reply_dta_index += 1, reply->dta[reply_dta_index].task_assay_cd = dta.task_assay_cd, reply->
       dta[reply_dta_index].mnemonic = dta.mnemonic,
       reply->dta[reply_dta_index].event_cd = dta.event_cd, reply->dta[reply_dta_index].description
        = dta.description, reply->dta[reply_dta_index].default_result_type_cd = dta
       .default_result_type_cd,
       reply->dta[reply_dta_index].activity_type_cd = dta.activity_type_cd, reply->dta[
       reply_dta_index].code_set = dta.code_set, reply->dta[reply_dta_index].active_ind = 1,
       reply->dta[reply_dta_index].modifier_ind = dta.modifier_ind, reply->dta[reply_dta_index].
       default_type_flag = dta.default_type_flag, reply->dta[reply_dta_index].single_select_ind = dta
       .single_select_ind,
       reply->dta[reply_dta_index].version_number = dta.version_number, reply->dta[reply_dta_index].
       io_flag = dta.io_flag, reply->dta[reply_dta_index].label_template_id = dta.label_template_id,
       reply->dta[reply_dta_index].template_script_cd = dta.template_script_cd, reply->dta[
       reply_dta_index].witness_required_ind = 0
      WITH nocounter
     ;end select
   ENDWHILE
   SET dta_cnt = reply_dta_index
   SET stat = alterlist(reply->dta,dta_cnt)
 END ;Subroutine
 SUBROUTINE getreferencerange(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM reference_range_factor rrf
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),rrf.task_assay_cd,
       expand_record->qual[expand_index].id,
       expand_size)
       AND rrf.active_ind=1
      ORDER BY rrf.task_assay_cd
      HEAD REPORT
       pos = 0, dta_index = 0
      HEAD rrf.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,rrf.task_assay_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index, rr_cnt = 0
      DETAIL
       IF (rrf.task_assay_cd != 0
        AND rrf.reference_range_factor_id != 0)
        rr_cnt += 1, stat = alterlist(reply->dta[dta_index].ref_range_factor,rr_cnt), reply->dta[
        dta_index].ref_range_factor[rr_cnt].age_from_minutes = rrf.age_from_minutes,
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_to_minutes = rrf.age_to_minutes, reply->
        dta[dta_index].ref_range_factor[rr_cnt].age_from_units_cd = rrf.age_from_units_cd, reply->
        dta[dta_index].ref_range_factor[rr_cnt].age_to_units_cd = rrf.age_to_units_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_from_units_meaning = uar_get_code_meaning(
         rrf.age_from_units_cd), reply->dta[dta_index].ref_range_factor[rr_cnt].age_to_units_meaning
         = uar_get_code_meaning(rrf.age_to_units_cd), reply->dta[dta_index].ref_range_factor[rr_cnt].
        age_from = compute_age(rrf.age_from_minutes,uar_get_code_meaning(rrf.age_from_units_cd)),
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_to = compute_age(rrf.age_to_minutes,
         uar_get_code_meaning(rrf.age_to_units_cd)), reply->dta[dta_index].ref_range_factor[rr_cnt].
        alpha_response_ind = rrf.alpha_response_ind, reply->dta[dta_index].ref_range_factor[rr_cnt].
        code_set = rrf.code_set,
        reply->dta[dta_index].ref_range_factor[rr_cnt].critical_high = rrf.critical_high, reply->dta[
        dta_index].ref_range_factor[rr_cnt].critical_ind = rrf.critical_ind, reply->dta[dta_index].
        ref_range_factor[rr_cnt].critical_low = rrf.critical_low,
        reply->dta[dta_index].ref_range_factor[rr_cnt].def_result_ind = rrf.def_result_ind, reply->
        dta[dta_index].ref_range_factor[rr_cnt].default_result = cnvtstring(rrf.default_result),
        reply->dta[dta_index].ref_range_factor[rr_cnt].default_result_value = rrf.default_result,
        reply->dta[dta_index].ref_range_factor[rr_cnt].encntr_type_cd = rrf.encntr_type_cd, reply->
        dta[dta_index].ref_range_factor[rr_cnt].feasible_high = rrf.feasible_high, reply->dta[
        dta_index].ref_range_factor[rr_cnt].feasible_ind = rrf.feasible_ind,
        reply->dta[dta_index].ref_range_factor[rr_cnt].feasible_low = rrf.feasible_low, reply->dta[
        dta_index].ref_range_factor[rr_cnt].minutes_back = rrf.mins_back, reply->dta[dta_index].
        ref_range_factor[rr_cnt].normal_high = rrf.normal_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].normal_ind = rrf.normal_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].normal_low = rrf.normal_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].review_high = rrf.review_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].review_ind = rrf.review_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].review_low = rrf.review_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].sensitive_high = rrf.sensitive_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].sensitive_ind = rrf.sensitive_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].sensitive_low = rrf.sensitive_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].service_resource_cd = rrf.service_resource_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].sex_cd = rrf.sex_cd, reply->dta[dta_index].
        ref_range_factor[rr_cnt].species_cd = rrf.species_cd, reply->dta[dta_index].ref_range_factor[
        rr_cnt].specimen_type_cd = rrf.specimen_type_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].units_cd = rrf.units_cd, reply->dta[dta_index]
        .ref_range_factor[rr_cnt].unknown_age_ind = rrf.unknown_age_ind, flat_reply_cnt += 1
        IF (mod(flat_reply_cnt,10)=1)
         stat = alterlist(flat_reply->qual,(flat_reply_cnt+ 9))
        ENDIF
        flat_reply->qual[flat_reply_cnt].reference_range_factor_id = rrf.reference_range_factor_id,
        flat_reply->qual[flat_reply_cnt].task_assay_cd = rrf.task_assay_cd, flat_reply->qual[
        flat_reply_cnt].dta_idx = dta_index,
        flat_reply->qual[flat_reply_cnt].reference_range_idx = rr_cnt
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
 END ;Subroutine
 SUBROUTINE getalpharesponses(null)
   SET expand_blocks = ceil(((flat_reply_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > flat_reply_cnt)
      SET expand_record->qual[x].id = expand_record->qual[flat_reply_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->qual[x].reference_range_factor_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < flat_reply_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > flat_reply_cnt)
      SET expand_stop = flat_reply_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM alpha_responses ar,
       nomenclature n
      PLAN (ar
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),ar
        .reference_range_factor_id,expand_record->qual[expand_index].id,
        expand_size)
        AND ar.active_ind=1)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1
        AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
        AND n.beg_effective_dt_tm <= cnvtdatetime(current_dt_tm)
        AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
        AND n.end_effective_dt_tm >= cnvtdatetime(current_dt_tm))) )) )
      ORDER BY ar.reference_range_factor_id, ar.sequence, ar.nomenclature_id
      HEAD REPORT
       flat_index = 0, pos = 0
      HEAD ar.reference_range_factor_id
       ar_cnt = 0, pos = locateval(pos,expand_start,expand_stop,ar.reference_range_factor_id,
        expand_record->qual[pos].id), flat_index = expand_record->qual[pos].index,
       dtainx = flat_reply->qual[flat_index].dta_idx, rr_cnt = flat_reply->qual[flat_index].
       reference_range_idx
      DETAIL
       ar_cnt += 1
       IF (ar_cnt > size(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,5))
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,(ar_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].default_ind = ar
       .default_ind, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].description
        = ar.description, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       multi_alpha_sort_order = ar.multi_alpha_sort_order,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].result_value = ar
       .result_value, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].sequence =
       ar.sequence, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].concept_cki
        = n.concept_cki,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].concept_identifier = n
       .concept_identifier, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       mnemonic = n.mnemonic, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       nomenclature_id = n.nomenclature_id,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].short_string = n
       .short_string, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       source_string = n.source_string
      FOOT  ar.reference_range_factor_id
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,ar_cnt), reply->
       dta[dtainx].ref_range_factor[rr_cnt].alpha_responses_cnt = ar_cnt
      WITH nocounter, orahintcbo("index(ar xpkalpha_responses)","index(n xpknomenclature)")
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getparenteventcode(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM code_value_event_r cver
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cver.parent_cd,
       expand_record->qual[expand_index].id,
       expand_size)
      HEAD REPORT
       pos = 0
      DETAIL
       pos = locateval(pos,expand_start,expand_stop,cver.parent_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index
       IF ((reply->dta[dta_index].event_cd=0)
        AND cver.event_cd > 0)
        reply->dta[dta_index].event_cd = cver.event_cd
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getdatamap(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      dm.task_assay_cd
      FROM data_map dm
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dm.task_assay_cd,
       expand_record->qual[expand_index].id,
       expand_size)
       AND dm.active_ind=1
      ORDER BY dm.task_assay_cd
      HEAD REPORT
       pos = 0
      HEAD dm.task_assay_cd
       data_map_cnt = 0, pos = locateval(pos,expand_start,expand_stop,dm.task_assay_cd,expand_record
        ->qual[pos].id), dta_index = expand_record->qual[pos].index
      DETAIL
       data_map_cnt += 1
       IF (mod(data_map_cnt,5)=1)
        stat = alterlist(reply->dta[dta_index].data_map,(data_map_cnt+ 4))
       ENDIF
       reply->dta[dta_index].data_map[data_map_cnt].data_map_type_flag = dm.data_map_type_flag, reply
       ->dta[dta_index].data_map[data_map_cnt].result_entry_format = dm.result_entry_format, reply->
       dta[dta_index].data_map[data_map_cnt].max_digits = dm.max_digits,
       reply->dta[dta_index].data_map[data_map_cnt].min_digits = dm.min_digits, reply->dta[dta_index]
       .data_map[data_map_cnt].min_decimal_places = dm.min_decimal_places, reply->dta[dta_index].
       data_map[data_map_cnt].service_resource_cd = dm.service_resource_cd
      FOOT  dm.task_assay_cd
       stat = alterlist(reply->dta[dta_index].data_map,data_map_cnt)
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getequations(null)
   DECLARE comp_events_cnt = i4 WITH protect, noconstant(0)
   RECORD component_events(
     1 qual[*]
       2 task_assay_cd = f8
       2 dta_index = i4
       2 eq_index = i4
       2 eq_comp_index = i4
   )
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM equation e,
       equation_component ec,
       discrete_task_assay dta_ec
      PLAN (e
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),e.task_assay_cd,
        expand_record->qual[expand_index].id,
        expand_size)
        AND e.active_ind=1)
       JOIN (ec
       WHERE ec.equation_id=e.equation_id)
       JOIN (dta_ec
       WHERE dta_ec.task_assay_cd=ec.included_assay_cd)
      ORDER BY e.task_assay_cd, e.equation_id, ec.sequence
      HEAD REPORT
       ecomp_cnt = 0, pos = 0
      HEAD e.task_assay_cd
       e_cnt = 0, pos = locateval(pos,expand_start,expand_stop,e.task_assay_cd,expand_record->qual[
        pos].id), reply_index = expand_record->qual[pos].index
      HEAD e.equation_id
       e_cnt += 1, stat = alterlist(reply->dta[reply_index].equation,e_cnt), reply->dta[reply_index].
       equation[e_cnt].age_from_minutes = e.age_from_minutes,
       reply->dta[reply_index].equation[e_cnt].age_to_minutes = e.age_to_minutes, reply->dta[
       reply_index].equation[e_cnt].age_from_units_cd = e.age_from_units_cd, reply->dta[reply_index].
       equation[e_cnt].age_to_units_cd = e.age_to_units_cd,
       reply->dta[reply_index].equation[e_cnt].age_from_units_meaning = uar_get_code_meaning(e
        .age_from_units_cd), reply->dta[reply_index].equation[e_cnt].age_to_units_meaning =
       uar_get_code_meaning(e.age_to_units_cd), reply->dta[reply_index].equation[e_cnt].age_from =
       compute_age2(e.age_from_minutes,uar_get_code_meaning(e.age_from_units_cd)),
       reply->dta[reply_index].equation[e_cnt].age_to = compute_age2(e.age_to_minutes,
        uar_get_code_meaning(e.age_to_units_cd)), reply->dta[reply_index].equation[e_cnt].equation_id
        = e.equation_id, reply->dta[reply_index].equation[e_cnt].equation_description = e
       .equation_description,
       reply->dta[reply_index].equation[e_cnt].equation_postfix = e.equation_postfix, reply->dta[
       reply_index].equation[e_cnt].script = e.script, reply->dta[reply_index].equation[e_cnt].
       service_resource_cd = e.service_resource_cd,
       reply->dta[reply_index].equation[e_cnt].sex_cd = e.sex_cd, reply->dta[reply_index].equation[
       e_cnt].species_cd = e.species_cd, reply->dta[reply_index].equation[e_cnt].unknown_age_ind = e
       .unknown_age_ind,
       ecomp_cnt = 0
      HEAD ec.sequence
       ecomp_cnt += 1
       IF (ecomp_cnt > size(reply->dta[reply_index].equation[e_cnt].e_comp,5))
        stat = alterlist(reply->dta[reply_index].equation[e_cnt].e_comp,(ecomp_cnt+ 5))
       ENDIF
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].constant_value = ec.constant_value,
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].default_value = ec.default_value,
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].included_assay_cd = ec
       .included_assay_cd,
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].name = ec.name, reply->dta[
       reply_index].equation[e_cnt].e_comp[ecomp_cnt].result_req_flag = ec.result_req_flag, reply->
       dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].units_cd = ec.units_cd,
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].look_time_direction_flag = ec
       .look_time_direction_flag, reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].
       time_window_minutes = ec.time_window_minutes, reply->dta[reply_index].equation[e_cnt].e_comp[
       ecomp_cnt].time_window_back_minutes = ec.time_window_back_minutes,
       reply->dta[reply_index].equation[e_cnt].e_comp[ecomp_cnt].event_cd = dta_ec.event_cd
       IF (dta_ec.event_cd=0)
        comp_events_cnt += 1
        IF (mod(comp_events_cnt,10)=1)
         stat = alterlist(component_events->qual,(comp_events_cnt+ 9))
        ENDIF
        component_events->qual[comp_events_cnt].task_assay_cd = dta_ec.task_assay_cd,
        component_events->qual[comp_events_cnt].dta_index = reply_index, component_events->qual[
        comp_events_cnt].eq_index = e_cnt,
        component_events->qual[comp_events_cnt].eq_comp_index = ecomp_cnt
       ENDIF
       reply->dta[reply_index].equation[e_cnt].e_comp_cnt = ecomp_cnt
      FOOT  e.equation_id
       stat = alterlist(reply->dta[reply_index].equation[e_cnt].e_comp,ecomp_cnt)
      WITH nocounter, orahintcbo("index(e xak1equation)","index(ec xpkequation_component)")
     ;end select
   ENDWHILE
   SET stat = alterlist(component_events->qual,comp_events_cnt)
   IF (comp_events_cnt > 0)
    SET expand_blocks = ceil(((comp_events_cnt * 1.0)/ expand_size))
    SET total_items = (expand_blocks * expand_size)
    SET stat = alterlist(expand_record->qual,total_items)
    FOR (x = 1 TO total_items)
      IF (x > comp_events_cnt)
       SET expand_record->qual[x].id = expand_record->qual[comp_events_cnt].id
       SET expand_record->qual[x].index = - (1)
      ELSE
       SET expand_record->qual[x].id = component_events->qual[x].task_assay_cd
       SET expand_record->qual[x].index = x
      ENDIF
    ENDFOR
    SET expand_start = 0
    SET expand_stop = 0
    WHILE (expand_stop < comp_events_cnt)
      SET expand_start = (expand_stop+ 1)
      SET expand_stop += expand_size
      IF (expand_stop > comp_events_cnt)
       SET expand_stop = comp_events_cnt
      ENDIF
      SELECT INTO "nl:"
       FROM code_value_event_r cver
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cver.parent_cd,
        expand_record->qual[expand_index].id,
        expand_size)
       HEAD REPORT
        pos = 0, pos_detail = 0, index = 0,
        reply_index = 0, eq_index = 0, eq_comp_index = 0
       HEAD cver.parent_cd
        pos = locateval(pos,expand_start,expand_stop,cver.parent_cd,expand_record->qual[pos].id),
        pos_detail = pos
       DETAIL
        pos = pos_detail
        IF (cver.event_cd > 0)
         WHILE (pos != 0)
           index = expand_record->qual[pos].index, reply_index = component_events->qual[index].
           dta_index, eq_index = component_events->qual[index].eq_index,
           eq_comp_index = component_events->qual[index].eq_comp_index, reply->dta[reply_index].
           equation[eq_index].e_comp[eq_comp_index].event_cd = cver.event_cd, pos = locateval(pos,(
            pos+ 1),expand_stop,cver.parent_cd,expand_record->qual[pos].id)
         ENDWHILE
        ENDIF
       WITH nocounter
      ;end select
    ENDWHILE
   ENDIF
   FREE RECORD component_events
 END ;Subroutine
 SUBROUTINE (compute_age(age_in_minutes=i4,age_units_cd=vc) =i4)
   DECLARE age = i4 WITH noconstant(0)
   IF (age_in_minutes=0)
    RETURN(age)
   ENDIF
   CASE (age_units_cd)
    OF "SECONDS":
     SET age = (age_in_minutes * 60)
    OF "MINUTES":
     SET age = age_in_minutes
    OF "HOURS":
     SET age = (age_in_minutes/ 60)
    OF "DAYS":
     SET age = ((age_in_minutes/ 60)/ 24)
    OF "WEEKS":
     SET age = (((age_in_minutes/ 60)/ 24)/ 7)
    OF "MONTHS":
     SET age = floor((((age_in_minutes/ 60)/ 24)/ 31))
    OF "YEARS":
     SET age = (((age_in_minutes/ 60)/ 24)/ 365)
    ELSE
     SET age = age_in_minutes
   ENDCASE
   RETURN(age)
 END ;Subroutine
 SUBROUTINE compute_age2(age_in_minutes,age_units)
   DECLARE age = i4 WITH noconstant(0)
   IF (age_in_minutes=0)
    RETURN(age)
   ENDIF
   CASE (age_units)
    OF "2":
     SET age = (age_in_minutes * 60)
    OF "3":
     SET age = age_in_minutes
    OF "4":
     SET age = (age_in_minutes/ 60)
    OF "5":
     SET age = ((age_in_minutes/ 60)/ 24)
    OF "6":
     SET age = (((age_in_minutes/ 60)/ 24)/ 7)
    OF "7":
     SET age = floor((((age_in_minutes/ 60)/ 24)/ 30))
    OF "8":
     SET age = (((age_in_minutes/ 60)/ 24)/ 365)
    ELSE
     SET age = age_in_minutes
   ENDCASE
   RETURN(age)
 END ;Subroutine
 SUBROUTINE getiototaldefinition(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM io_total_definition i
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),i.task_assay_cd,
       expand_record->qual[expand_index].id,
       expand_size)
       AND i.end_effective_dt_tm=cnvtdatetime(max_dt_tm)
      HEAD REPORT
       pos = 0
      DETAIL
       pos = locateval(pos,expand_start,expand_stop,i.task_assay_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index, reply->dta[dta_index].io_total_definition_id = i
       .io_total_definition_id
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getcategories(null)
   SET expand_blocks = ceil(((flat_reply_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > flat_reply_cnt)
      SET expand_record->qual[x].id = expand_record->qual[flat_reply_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->qual[x].reference_range_factor_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < flat_reply_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop += expand_size
     IF (expand_stop > flat_reply_cnt)
      SET expand_stop = flat_reply_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM alpha_responses_category arc,
       alpha_responses ar,
       nomenclature n
      PLAN (arc
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),arc
        .reference_range_factor_id,expand_record->qual[expand_index].id,
        expand_size))
       JOIN (ar
       WHERE ar.alpha_responses_category_id=arc.alpha_responses_category_id
        AND ar.active_ind=1)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1
        AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
        AND n.beg_effective_dt_tm <= cnvtdatetime(current_dt_tm)
        AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
        AND n.end_effective_dt_tm >= cnvtdatetime(current_dt_tm))) )) )
      ORDER BY arc.reference_range_factor_id, arc.display_seq, ar.sequence
      HEAD REPORT
       flat_index = 0, pos = 0
      HEAD arc.reference_range_factor_id
       arc_cnt = 0, pos = locateval(pos,expand_start,expand_stop,arc.reference_range_factor_id,
        expand_record->qual[pos].id), flat_index = expand_record->qual[pos].index,
       dtainx = flat_reply->qual[flat_index].dta_idx, rr_cnt = flat_reply->qual[flat_index].
       reference_range_idx
      HEAD arc.display_seq
       alpha_cnt = 0, arc_cnt += 1
       IF (mod(arc_cnt,10)=1)
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories,(arc_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].category_id = arc
       .alpha_responses_category_id, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
       expand_flag = arc.expand_flag, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt]
       .category_name = arc.category_name,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].sequence = arc.display_seq
      HEAD ar.sequence
       alpha_cnt += 1
       IF (mod(alpha_cnt,10)=1)
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
         alpha_responses,(alpha_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       default_ind = ar.default_ind, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
       alpha_responses[alpha_cnt].description = ar.description, reply->dta[dtainx].ref_range_factor[
       rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].multi_alpha_sort_order = ar
       .multi_alpha_sort_order,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       result_value = ar.result_value, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt
       ].alpha_responses[alpha_cnt].sequence = ar.sequence, reply->dta[dtainx].ref_range_factor[
       rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].concept_cki = n.concept_cki,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       concept_identifier = n.concept_identifier, reply->dta[dtainx].ref_range_factor[rr_cnt].
       categories[arc_cnt].alpha_responses[alpha_cnt].mnemonic = n.mnemonic, reply->dta[dtainx].
       ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].nomenclature_id = n
       .nomenclature_id,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       short_string = n.short_string, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt]
       .alpha_responses[alpha_cnt].source_string = n.source_string
      FOOT  arc.display_seq
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
        alpha_responses,alpha_cnt)
      FOOT  arc.reference_range_factor_id
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories,arc_cnt)
      WITH nocounter, orahintcbo("index(arc xak1alpha_responses_category)",
        "index(ar xie2alpha_responses)","index(n xpknomenclature)")
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE geteventsetname(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].event_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   CALL echorecord(expand_record)
   SET expand_start = 1
   SET dtainx = 0
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = expand_blocks),
     v500_event_set_explode vese
    PLAN (d2
     WHERE assign(expand_start,evaluate(d2.seq,1,1,(expand_start+ expand_size))))
     JOIN (vese
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),vese.event_cd,
      expand_record->qual[expand_index].id,
      expand_size)
      AND vese.event_set_level=0.0)
    DETAIL
     pos = 0, pos = locateval(pos,1,dta_cnt,vese.event_cd,expand_record->qual[pos].id)
     IF (pos != 0.0)
      dtainx = expand_record->qual[pos].index, reply->dta[dtainx].event_set_cd = vese.event_set_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getcondexpressions(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   SET exp_cnt = 0
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   CALL echorecord(expand_record)
   SET expand_start = 1
   SELECT INTO "nl:"
    FROM (dummyt d3  WITH seq = expand_blocks),
     cond_expression_comp cec,
     cond_expression ce
    PLAN (d3
     WHERE assign(expand_start,evaluate(d3.seq,1,1,(expand_start+ expand_size))))
     JOIN (cec
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cec.trigger_assay_cd,
      expand_record->qual[expand_index].id,
      expand_size))
     JOIN (ce
     WHERE ce.active_ind=1
      AND ce.cond_expression_id=cec.cond_expression_id)
    ORDER BY ce.cond_expression_id
    HEAD ce.cond_expression_id
     IF (ce.cond_expression_id > 0)
      exp_cnt += 1
      IF (mod(exp_cnt,5)=1)
       stat = alterlist(reply->cond_exp,(exp_cnt+ 4))
      ENDIF
      reply->cond_exp[exp_cnt].cond_expression_id = ce.cond_expression_id, reply->cond_exp[exp_cnt].
      beg_effective_dt_tm = ce.beg_effective_dt_tm, reply->cond_exp[exp_cnt].cond_expression_name =
      ce.cond_expression_name,
      reply->cond_exp[exp_cnt].cond_expression_text = ce.cond_expression_txt, reply->cond_exp[exp_cnt
      ].cond_postfix_txt = ce.cond_postfix_txt, reply->cond_exp[exp_cnt].end_effective_dt_tm = ce
      .end_effective_dt_tm,
      reply->cond_exp[exp_cnt].multiple_ind = ce.multiple_ind, reply->cond_exp[exp_cnt].
      prev_cond_expression_id = ce.prev_cond_expression_id
     ENDIF
    WITH nocounter, orahintcbo("index(cec xie1cond_expression_comp)","index(ce xpkcond_expression)")
   ;end select
   SET stat = alterlist(reply->cond_exp,exp_cnt)
 END ;Subroutine
 SUBROUTINE getcondexpressioncomps(null)
   CALL echo("GetCondExpressionComps")
   SET expand_blocks = ceil(((exp_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > exp_cnt)
      SET expand_record->qual[x].id = expand_record->qual[exp_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->cond_exp[x].cond_expression_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   IF (exp_cnt > 0)
    SET expand_start = 1
    SELECT INTO "nl:"
     FROM (dummyt d4  WITH seq = expand_blocks),
      cond_expression_comp cec
     PLAN (d4
      WHERE assign(expand_start,evaluate(d4.seq,1,1,(expand_start+ expand_size))))
      JOIN (cec
      WHERE cec.active_ind=1
       AND expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cec.cond_expression_id,
       expand_record->qual[expand_index].id,
       expand_size))
     ORDER BY cec.cond_expression_id, cec.cond_expression_comp_id
     HEAD cec.cond_expression_id
      pos = locateval(expand_index,1,size(reply->cond_exp,5),cec.cond_expression_id,reply->cond_exp[
       expand_index].cond_expression_id), comp_cnt = 0
     DETAIL
      IF (pos != 0)
       comp_cnt += 1
       IF (mod(comp_cnt,5)=1)
        stat = alterlist(reply->cond_exp[pos].exp_comp,(comp_cnt+ 4))
       ENDIF
       reply->cond_exp[pos].exp_comp[comp_cnt].active_ind = cec.active_ind, reply->cond_exp[pos].
       exp_comp[comp_cnt].beg_effective_dt_tm = cec.beg_effective_dt_tm, reply->cond_exp[pos].
       exp_comp[comp_cnt].cond_comp_name = cec.cond_comp_name,
       reply->cond_exp[pos].exp_comp[comp_cnt].cond_expression_comp_id = cec.cond_expression_comp_id,
       reply->cond_exp[pos].exp_comp[comp_cnt].end_effective_dt_tm = cec.end_effective_dt_tm, reply->
       cond_exp[pos].exp_comp[comp_cnt].operator_cd = cec.operator_cd,
       reply->cond_exp[pos].exp_comp[comp_cnt].parent_entity_id = cec.parent_entity_id, reply->
       cond_exp[pos].exp_comp[comp_cnt].parent_entity_name = cec.parent_entity_name, reply->cond_exp[
       pos].exp_comp[comp_cnt].prev_cond_expression_comp_id = cec.prev_cond_expression_comp_id,
       reply->cond_exp[pos].exp_comp[comp_cnt].required_ind = cec.required_ind, reply->cond_exp[pos].
       exp_comp[comp_cnt].trigger_assay_cd = cec.trigger_assay_cd, reply->cond_exp[pos].exp_comp[
       comp_cnt].result_value = cec.result_value,
       reply->cond_exp[pos].exp_comp[comp_cnt].cond_expression_id = cec.cond_expression_id
      ENDIF
     FOOT  cec.cond_expression_id
      IF (pos != 0)
       stat = alterlist(reply->cond_exp[pos].exp_comp,comp_cnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("GetCondExpressionComps - end")
 END ;Subroutine
 SUBROUTINE getconditionaldtas(null)
   CALL echo("GetConditionalDTAs")
   SET expand_blocks = ceil(((exp_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > exp_cnt)
      SET expand_record->qual[x].id = expand_record->qual[exp_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->cond_exp[x].cond_expression_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   IF (size(expand_record->qual,5) > 0)
    SET expand_start = 1
    SELECT INTO "nl:"
     FROM (dummyt d4  WITH seq = expand_blocks),
      conditional_dta cd
     PLAN (d4
      WHERE assign(expand_start,evaluate(d4.seq,1,1,(expand_start+ expand_size))))
      JOIN (cd
      WHERE cd.active_ind=1
       AND expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cd.cond_expression_id,
       expand_record->qual[expand_index].id,
       expand_size))
     ORDER BY cd.cond_expression_id, cd.conditional_dta_id
     HEAD cd.cond_expression_id
      pos = 0, pos = locateval(pos,1,size(reply->cond_exp,5),cd.cond_expression_id,reply->cond_exp[
       pos].cond_expression_id), cond_dta_cnt = 0
     DETAIL
      IF (pos != 0)
       cond_dta_cnt += 1
       IF (mod(cond_dta_cnt,5)=1)
        stat = alterlist(reply->cond_exp[pos].cond_dtas,(cond_dta_cnt+ 4))
       ENDIF
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].active_ind = cd.active_ind, reply->cond_exp[pos].
       cond_dtas[cond_dta_cnt].age_from_nbr = cd.age_from_nbr, reply->cond_exp[pos].cond_dtas[
       cond_dta_cnt].age_from_unit_cd = cd.age_from_unit_cd,
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].age_to_nbr = cd.age_to_nbr, reply->cond_exp[pos].
       cond_dtas[cond_dta_cnt].age_to_unit_cd = cd.age_to_unit_cd, reply->cond_exp[pos].cond_dtas[
       cond_dta_cnt].beg_effective_dt_tm = cd.beg_effective_dt_tm,
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].conditional_assay_cd = cd.conditional_assay_cd,
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].conditional_dta_id = cd.conditional_dta_id, reply
       ->cond_exp[pos].cond_dtas[cond_dta_cnt].end_effective_dt_tm = cd.end_effective_dt_tm,
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].gender_cd = cd.gender_cd, reply->cond_exp[pos].
       cond_dtas[cond_dta_cnt].location_cd = cd.location_cd, reply->cond_exp[pos].cond_dtas[
       cond_dta_cnt].position_cd = cd.position_cd,
       reply->cond_exp[pos].cond_dtas[cond_dta_cnt].prev_conditional_dta_id = cd
       .prev_conditional_dta_id, reply->cond_exp[pos].cond_dtas[cond_dta_cnt].required_ind = cd
       .required_ind, reply->cond_exp[pos].cond_dtas[cond_dta_cnt].unknown_age_ind = cd
       .unknown_age_ind
      ENDIF
     FOOT  cd.cond_expression_id
      IF (pos != 0)
       stat = alterlist(reply->cond_exp[pos].cond_dtas,cond_dta_cnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("GetConditionalDTAs - end")
 END ;Subroutine
 SUBROUTINE getdtaoffsetmins(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   IF (total_items > dta_cnt)
    SET stat = alterlist(reply->dta,total_items)
    FOR (x = (dta_cnt+ 1) TO total_items)
      SET reply->dta[x].task_assay_cd = reply->dta[dta_cnt].task_assay_cd
    ENDFOR
   ENDIF
   SET expand_start = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = expand_blocks),
     dta_offset_min dtaoffsetmin
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (dtaoffsetmin
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dtaoffsetmin
      .task_assay_cd,reply->dta[expand_index].task_assay_cd,
      expand_size)
      AND dtaoffsetmin.end_effective_dt_tm=cnvtdatetime(max_dt_tm)
      AND dtaoffsetmin.active_ind=1)
    ORDER BY dtaoffsetmin.task_assay_cd
    HEAD REPORT
     pos = 0
    HEAD dtaoffsetmin.task_assay_cd
     dtaoffsetmin_cnt = 0, pos = locateval(pos,1,size(reply->dta,5),dtaoffsetmin.task_assay_cd,reply
      ->dta[pos].task_assay_cd)
    DETAIL
     IF (pos != 0)
      dtaoffsetmin_cnt += 1
      IF (mod(dtaoffsetmin_cnt,5)=1)
       stat = alterlist(reply->dta[pos].dta_offset_mins,(dtaoffsetmin_cnt+ 4))
      ENDIF
      reply->dta[pos].dta_offset_mins[dtaoffsetmin_cnt].dta_offset_min_id = dtaoffsetmin
      .dta_offset_min_id, reply->dta[pos].dta_offset_mins[dtaoffsetmin_cnt].beg_effective_dt_tm =
      dtaoffsetmin.beg_effective_dt_tm, reply->dta[pos].dta_offset_mins[dtaoffsetmin_cnt].
      end_effective_dt_tm = dtaoffsetmin.end_effective_dt_tm,
      reply->dta[pos].dta_offset_mins[dtaoffsetmin_cnt].offset_min_nbr = dtaoffsetmin.offset_min_nbr,
      reply->dta[pos].dta_offset_mins[dtaoffsetmin_cnt].offset_min_type_cd = dtaoffsetmin
      .offset_min_type_cd
     ENDIF
    FOOT  dtaoffsetmin.task_assay_cd
     stat = alterlist(reply->dta[pos].dta_offset_mins,dtaoffsetmin_cnt)
    WITH nocounter, orahintcbo("index(dtaoffsetmin xak1dta_offset_min)")
   ;end select
   SET stat = alterlist(reply->dta,dta_cnt)
 END ;Subroutine
 SUBROUTINE getwitnessrequired(null)
   CALL echo("GetWitnessRequired")
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET expand_start = 1
   SET stat = alterlist(reply->dta,total_items)
   SELECT INTO "nl:"
    FROM code_value_extension cve,
     (dummyt d  WITH seq = expand_blocks)
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (cve
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cve.code_value,reply->
      dta[expand_index].task_assay_cd)
      AND cve.field_name="dta_witness_required_ind"
      AND cve.field_value="1"
      AND cve.code_set=14003)
    ORDER BY cve.code_value
    HEAD REPORT
     pos = 0
    HEAD cve.code_value
     pos = locateval(expand_index,1,total_items,cve.code_value,reply->dta[expand_index].task_assay_cd
      )
     IF (pos > 0)
      reply->dta[pos].witness_required_ind = 1
     ENDIF
    WITH nocounter, orahintcbo("index(cve xpkcode_value_extension)")
   ;end select
   SET stat = alterlist(reply->dta,dta_cnt)
   CALL echo("GetWitnessRequired - end")
 END ;Subroutine
END GO
