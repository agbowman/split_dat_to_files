CREATE PROGRAM dcp_get_ord_chart_info2:dba
 SET modify = predeclare
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 hna_order_mnemonic = vc
   1 ordered_as_mnemonic = vc
   1 order_mnemonic = vc
   1 synonym_id = f8
   1 catalog_cd = f8
   1 event_cd = f8
   1 action_sequence = i4
   1 last_action_sequence = i4
   1 updt_cnt = i4
   1 iv_ind = i2
   1 clinical_display_line = vc
   1 effective_dt_tm = dq8
   1 effective_tz = i4
   1 orig_order_dt_tm = dq8
   1 orig_order_tz = i4
   1 order_provider_id = f8
   1 order_status_cd = f8
   1 template_order_id = f8
   1 template_core_action_sequence = f8
   1 need_rx_verify_ind = i2
   1 need_rx_clin_review_flag = i2
   1 prn_ind = i2
   1 orderable_type_flag = i2
   1 dcp_clin_cat_cd = f8
   1 med_order_type_cd = f8
   1 oe_format_id = f8
   1 product_action_seq = i4
   1 root_event_id = f8
   1 need_nurse_review_ind = i2
   1 comment_type_mask = i4
   1 order_comment_text = vc
   1 order_id = f8
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 dispense_category_cd = f8
   1 ingred_action_seq = i4
   1 plan_ind = i2
   1 taper_ind = i2
   1 detail_qual[*]
     2 oe_field_display_value = vc
     2 oe_field_dt_tm_value = dq8
     2 oe_field_tz = i4
     2 oe_field_id = f8
     2 oe_field_meaning_id = f8
     2 oe_field_value = f8
     2 detail_value[*]
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
     2 min_val = f8
     2 max_val = f8
     2 input_mask = vc
     2 label_text = vc
     2 filter_params = vc
     2 oe_field_meaning = vc
   1 ingred_qual[*]
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 ingredient_type_flag = i2
     2 ingredient_source_flag = i2
     2 comp_sequence = i4
     2 strength = f8
     2 strength_unit = f8
     2 volume = f8
     2 volume_unit = f8
     2 freetext_dose = vc
     2 ordered_dose = f8
     2 ordered_dose_unit_cd = f8
     2 ordered_dose_unit_cd_disp = vc
     2 ordered_dose_unit_cd_desc = vc
     2 ordered_dose_unit_cd_mean = vc
     2 freq_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 event_cd = f8
     2 include_in_total_volume_flag = i2
     2 iv_seq = i4
     2 dose_quantity = f8
     2 dose_quantity_unit = f8
     2 witness_required_ind = i2
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 normalized_rate_unit_cd_disp = vc
     2 normalized_rate_unit_cd_desc = vc
     2 normalized_rate_unit_cd_mean = vc
     2 concentration = f8
     2 concentration_unit_cd = f8
     2 concentration_unit_cd_disp = vc
     2 concentration_unit_cd_desc = vc
     2 concentration_unit_cd_mean = vc
     2 ingredient_rate_conversion_ind = i2
     2 clinically_significant_flag = i2
     2 display_additives_first_ind = i2
     2 last_admin_disp_basis_flag = i2
     2 med_interval_warn_flag = i2
     2 autoprog_syn_ind = i2
     2 autoprogramming_id = f8
     2 adjusted_weight = f8
     2 adjusted_weight_cd = f8
     2 adjusted_height = f8
     2 adjusted_height_cd = f8
     2 final_dose = f8
     2 final_dose_unit_cd = f8
     2 actual_final_dose = f8
     2 actual_final_dose_unit_cd = f8
     2 dose_type_applied = i2
     2 standard_dose = f8
     2 standard_dose_unit_cd = f8
     2 actual_standard_dose = f8
     2 actual_standard_dose_unit_cd = f8
   1 freq_type_flag = i2
   1 immunization_ind = i2
   1 parent_order_last_action_seq = i4
   1 dosing_method_flag = i2
   1 template_dose_seq = i4
   1 core_action_sequence = i4
   1 applicable_fields_bit = i4
   1 finished_bags_cnt = i4
   1 total_bags_nbr = i4
   1 order_iv_info_updt_cnt = i4
   1 iv_sequence_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD map_request(
   1 mapping_ind = i2
   1 map_from_value = i2
 )
 RECORD map_reply(
   1 map_to_value = i2
 )
 FREE RECORD temp_autoprogramming
 RECORD temp_autoprogramming(
   1 autoprog_list[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 autoprog_syn_ind = i2
 )
 DECLARE ingred_cnt = i4 WITH noconstant(0)
 DECLARE detail_cnt = i4 WITH noconstant(0)
 DECLARE detail_value_cnt = i4 WITH noconstant(0)
 DECLARE debug_cnt = i4 WITH noconstant(0)
 DECLARE order_ingredient_where = vc WITH noconstant(fillstring(500," "))
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE mar_note_mask = i4 WITH constant(2)
 DECLARE admin_note_mask = i4 WITH constant(128)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE parent_entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE freqmeanid = i4 WITH protect, constant(2011)
 DECLARE template_order_query_id = f8 WITH noconstant(0.0)
 DECLARE template_core_action_seq = i4 WITH noconstant(0)
 DECLARE template_order_id = f8 WITH noconstant(0.0)
 DECLARE next_core_action_found = i2 WITH noconstant(0)
 DECLARE action_sequence_sent_in = i2 WITH noconstant(1)
 DECLARE seq_for_searching = i4 WITH noconstant(0)
 DECLARE action_seq_for_ingreds = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE routemeanid = i4 WITH protect, constant(2050)
 DECLARE ratemeanid = i4 WITH protect, constant(2043)
 DECLARE infusemeanmeanid = i4 WITH protect, constant(118)
 DECLARE ratemeanunitid = i4 WITH protect, constant(2044)
 DECLARE infusemeanunitid = i4 WITH protect, constant(2064)
 DECLARE formmeanid = f8 WITH protect, constant(2014.00)
 DECLARE verify_action_seq = i4 WITH protect, constant(2)
 DECLARE volumemeanid = i4 WITH protect, constant(2058)
 DECLARE volumeunitmeanid = i4 WITH protect, constant(2059)
 DECLARE xml_height = c22 WITH protect, constant('<height type="double">')
 DECLARE xml_height_end = c9 WITH protect, constant("</height>")
 DECLARE xml_height_unit_cd = c28 WITH protect, constant('<heightunitcd type="double">')
 DECLARE xml_height_unit_cd_end = c15 WITH protect, constant("</heightunitcd>")
 DECLARE xml_adjusted_weight = c30 WITH protect, constant('<adjustedweight type="double">')
 DECLARE xml_adjusted_weight_end = c17 WITH protect, constant("</adjustedweight>")
 DECLARE xml_adjusted_weight_unit_cd = c36 WITH protect, constant(
  '<adjustedweightunitcd type="double">')
 DECLARE xml_adjusted_weight_unit_cd_end = c23 WITH protect, constant("</adjustedweightunitcd>")
 DECLARE xml_final_dose = c25 WITH protect, constant('<finaldose type="double">')
 DECLARE xml_final_dose_end = c12 WITH protect, constant("</finaldose>")
 DECLARE xml_final_dose_unit_cd = c31 WITH protect, constant('<finaldoseunitcd type="double">')
 DECLARE xml_final_dose_unit_cd_end = c18 WITH protect, constant("</finaldoseunitcd>")
 DECLARE xml_actual_final_dose = c31 WITH protect, constant('<actualfinaldose type="double">')
 DECLARE xml_actual_final_dose_end = c18 WITH protect, constant("</actualfinaldose>")
 DECLARE xml_actual_final_dose_unit_cd = c37 WITH protect, constant(
  '<actualfinaldoseunitcd type="double">')
 DECLARE xml_actual_final_dose_unit_cd_end = c24 WITH protect, constant("</actualfinaldoseunitcd>")
 DECLARE xml_dose_type_applied = c28 WITH protect, constant('<dosetypeapplied type="int">')
 DECLARE xml_dose_type_applied_end = c18 WITH protect, constant("</dosetypeapplied>")
 DECLARE xml_standard_dose = c28 WITH protect, constant('<standarddose type="double">')
 DECLARE xml_standard_dose_end = c15 WITH protect, constant("</standarddose>")
 DECLARE xml_standard_dose_unit_cd = c34 WITH protect, constant('<standarddoseunitcd type="double">')
 DECLARE xml_standard_dose_unit_cd_end = c21 WITH protect, constant("</standarddoseunitcd>")
 DECLARE xml_actual_standard_dose = c34 WITH protect, constant('<actualstandarddose type="double">')
 DECLARE xml_actual_standard_dose_end = c21 WITH protect, constant("</actualstandarddose>")
 DECLARE xml_actual_standard_dose_unit_cd = c40 WITH protect, constant(
  '<actualstandarddoseunitcd type="double">')
 DECLARE xml_actual_standard_dose_unit_cd_end = c27 WITH protect, constant(
  "</actualstandarddoseunitcd>")
 FREE RECORD action_compare
 RECORD action_compare(
   1 qual[*]
     2 orig_struct_index = i4
     2 template_order_id = f8
     2 action_qual[2]
       3 form_cd = f8
       3 route_cd = f8
       3 needs_verify_ind = i2
       3 core_ind = i2
       3 non_diluent_count = i4
       3 ingred_list[*]
         4 catalog_cd = f8
         4 freetext_dose = vc
         4 strength = f8
         4 strength_unit_cd = f8
         4 volume = f8
         4 volume_unit_cd = f8
         4 ingredient_type = i2
 )
 FREE RECORD items_to_check
 RECORD items_to_check(
   1 check_parent_ind = i2
   1 qual[*]
     2 order_id = f8
     2 template_core_action_sequence = i4
     2 template_dose_seq = i4
     2 verify_success_ind = i2
     2 second_action_core_ind = i2
 )
 FREE RECORD future_check
 RECORD future_check(
   1 qual[*]
     2 template_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 FREE RECORD protocol_check
 RECORD protocol_check(
   1 qual[*]
     2 protocol_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 DECLARE detail_form_meaning_id = f8 WITH protect, constant(2014.0)
 DECLARE detail_route_meaning_id = f8 WITH protect, constant(2050.0)
 DECLARE ingredient_type_diluent = i2 WITH protect, constant(2)
 DECLARE ingredient_type_compchild = i4 WITH protect, constant(5)
 DECLARE nv_not_needed = i4 WITH protect, constant(0)
 DECLARE nv_verified = i4 WITH protect, constant(3)
 DECLARE checkactionsequencecompatibility(null) = null
 DECLARE getnextdueorderids(null) = null
 DECLARE getnextdueprotocolids(null) = null
 SUBROUTINE (comparedosefields(order_index=i4,action1_index=i4,action2_index=i4) =i2)
   DECLARE bdosemismatch = i2 WITH private, noconstant(0)
   IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength > 0))
    OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength > 0)))
   )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSEIF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume > 0)
   ) OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume > 0))) )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSE
    IF ((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].freetext_dose
     != action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].freetext_dose))
     SET bdosemismatch = 1
    ENDIF
   ENDIF
   RETURN(bdosemismatch)
 END ;Subroutine
 SUBROUTINE checkactionsequencecompatibility(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE actionindex = i4 WITH protect, noconstant(0)
   DECLARE ingredindex = i4 WITH protect, noconstant(0)
   DECLARE nindex = i4 WITH protect, noconstant(0)
   DECLARE bmismatch = i2 WITH protect, noconstant(0)
   DECLARE bexactmatch = i4 WITH protect, noconstant(0)
   DECLARE bfulldiluentmatchneeded = i2 WITH protect, noconstant(0)
   DECLARE catalogmatchindex = i4 WITH protect, noconstant(0)
   DECLARE ord2ingredindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(items_to_check->qual,5))),
     orders o,
     order_action oa,
     order_ingredient oi,
     order_detail od
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=items_to_check->qual[d.seq].order_id)
      AND o.dosing_method_flag=0)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence <= 2)
     JOIN (oi
     WHERE oi.order_id=oa.order_id
      AND oi.action_sequence=oa.action_sequence
      AND oi.ingredient_type_flag != ingredient_type_compchild)
     JOIN (od
     WHERE (od.order_id= Outerjoin(oa.order_id))
      AND (od.action_sequence= Outerjoin(oa.action_sequence)) )
    ORDER BY d.seq, oa.action_sequence, oi.catalog_cd
    HEAD d.seq
     actionindex = 0, ordercount += 1
     IF (mod(ordercount,10)=1)
      stat = alterlist(action_compare->qual,(ordercount+ 9))
     ENDIF
     action_compare->qual[ordercount].template_order_id = oi.order_id, action_compare->qual[
     ordercount].orig_struct_index = d.seq
    HEAD oa.action_sequence
     ingredindex = 0, actionindex += 1
     IF (actionindex <= 2)
      action_compare->qual[ordercount].action_qual[actionindex].needs_verify_ind = oa
      .needs_verify_ind, action_compare->qual[ordercount].action_qual[actionindex].core_ind = oa
      .core_ind, action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count = 0
     ENDIF
    HEAD oi.catalog_cd
     IF (actionindex <= 2)
      IF (oi.ingredient_type_flag != ingredient_type_diluent)
       action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count += 1
      ENDIF
      ingredindex += 1, stat = alterlist(action_compare->qual[ordercount].action_qual[actionindex].
       ingred_list,ingredindex)
      IF ((((items_to_check->qual[d.seq].template_core_action_sequence=1)) OR ((items_to_check->qual[
      d.seq].template_core_action_sequence=0)
       AND (items_to_check->check_parent_ind=1))) )
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = oi.catalog_cd, action_compare->qual[ordercount].action_qual[actionindex].ingred_list[
       ingredindex].freetext_dose = oi.freetext_dose, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].strength = oi.strength,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       strength_unit_cd = oi.strength_unit, action_compare->qual[ordercount].action_qual[actionindex]
       .ingred_list[ingredindex].volume = oi.volume, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].volume_unit_cd = oi.volume_unit,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       ingredient_type = oi.ingredient_type_flag
      ELSE
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = actionindex
      ENDIF
     ENDIF
    DETAIL
     IF (actionindex <= 2)
      IF (od.oe_field_meaning_id=detail_form_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].form_cd = od.oe_field_value
      ELSEIF (od.oe_field_meaning_id=detail_route_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].route_cd = od.oe_field_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL alterlist(action_compare->qual,ordercount)
   FOR (nindex = 1 TO ordercount BY 1)
     SET bmismatch = 0
     SET bfulldiluentmatchneeded = 0
     IF ((action_compare->qual[nindex].action_qual[1].needs_verify_ind=nv_verified)
      AND (action_compare->qual[nindex].action_qual[2].needs_verify_ind=nv_not_needed))
      IF ((action_compare->qual[nindex].action_qual[1].non_diluent_count=0)
       AND (action_compare->qual[nindex].action_qual[2].non_diluent_count=0))
       IF (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)=size(action_compare->qual[
        nindex].action_qual[2].ingred_list,5))
        SET bmismatch = 1
       ELSE
        SET bfulldiluentmatchneeded = 1
       ENDIF
      ELSEIF ((action_compare->qual[nindex].action_qual[1].non_diluent_count != action_compare->qual[
      nindex].action_qual[2].non_diluent_count))
       SET bmismatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].route_cd != action_compare->qual[nindex].
      action_qual[2].route_cd))
       SET bmismatch = 1
      ENDIF
      IF (bmismatch=0)
       FOR (ingredindex = 1 TO size(action_compare->qual[nindex].action_qual[1].ingred_list,5) BY 1)
        SET ord2ingredindex = locateval(catalogmatchindex,1,size(action_compare->qual[nindex].
          action_qual[2].ingred_list,5),action_compare->qual[nindex].action_qual[1].ingred_list[
         ingredindex].catalog_cd,action_compare->qual[nindex].action_qual[2].ingred_list[
         catalogmatchindex].catalog_cd)
        IF (ord2ingredindex > 0)
         IF ((((action_compare->qual[nindex].action_qual[1].ingred_list[ingredindex].ingredient_type
          != ingredient_type_diluent)) OR (bfulldiluentmatchneeded=1)) )
          SET bmismatch = comparedosefields(nindex,ingredindex,ord2ingredindex)
          IF (bmismatch=1)
           SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
          ENDIF
         ENDIF
        ELSE
         SET bmismatch = 1
         SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET bmismatch = 1
     ENDIF
     IF (bmismatch=0)
      SET bmismatch = 1
      IF ((((action_compare->qual[nindex].action_qual[1].form_cd=0)) OR ((action_compare->qual[nindex
      ].action_qual[2].form_cd=0))) )
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].form_cd != action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 1
       SELECT
        cvg2.child_code_value
        FROM code_value_group cvg1,
         code_value_group cvg2,
         code_value cv
        PLAN (cvg1
         WHERE (cvg1.child_code_value=action_compare->qual[nindex].action_qual[1].form_cd))
         JOIN (cv
         WHERE cv.code_value=cvg1.parent_code_value
          AND cv.code_set=4003329)
         JOIN (cvg2
         WHERE cvg2.parent_code_value=cv.code_value
          AND (cvg2.child_code_value=action_compare->qual[nindex].action_qual[2].form_cd))
        DETAIL
         bmismatch = 0, bexactmatch = 1
        WITH nocounter
       ;end select
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd=action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF (bmismatch=0
       AND bexactmatch=1)
       SET bexactmatch = 0
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].verify_success_ind =
       1
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].
       second_action_core_ind = action_compare->qual[nindex].action_qual[2].core_ind
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getnextdueorderids(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[idxnum].
      template_order_id)
      AND o.template_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.template_order_id, ta.task_dt_tm
    HEAD o.template_order_id
     ordercount += 1, future_check->qual[ordercount].next_due_ord_id = o.order_id, future_check->
     qual[ordercount].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(future_check->qual,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnextdueprotocolids(null)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
      idxnum].protocol_order_id)
      AND o.protocol_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.protocol_order_id, ta.task_dt_tm
    HEAD o.protocol_order_id
     rowcnt += 1, protocol_check->qual[rowcnt].next_due_ord_id = o.order_id, protocol_check->qual[
     rowcnt].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(protocol_check->qual,rowcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.order_id=request->order_id)
  HEAD REPORT
   stat = alterlist(items_to_check->qual,1)
  DETAIL
   template_order_id = o.template_order_id, seq_for_searching = o.template_core_action_sequence
   IF ((request->action_sequence=0))
    action_sequence_sent_in = 0, request->action_sequence = o.last_action_sequence
    IF (template_order_id=0)
     reply->core_action_sequence = o.last_core_action_sequence
    ELSE
     reply->core_action_sequence = 1, items_to_check->check_parent_ind = 0, items_to_check->qual[1].
     order_id = template_order_id,
     items_to_check->qual[1].template_core_action_sequence = seq_for_searching
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE new_action_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_status_cd = f8 WITH noconstant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE group_class_cd = f8 WITH noconstant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE iv_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18309,"IV"))
 IF (template_order_id > 0.0)
  SET reply->core_action_sequence = 1
  SELECT INTO "nl:"
   FROM order_action oa
   WHERE oa.order_id=template_order_id
    AND oa.action_sequence >= seq_for_searching
   ORDER BY oa.action_sequence
   DETAIL
    IF (seq_for_searching=oa.action_sequence)
     action_seq_for_ingreds = oa.action_sequence
    ELSE
     IF (next_core_action_found=0
      AND oa.core_ind=0)
      action_seq_for_ingreds = oa.action_sequence
     ELSE
      IF (oa.core_ind=1)
       next_core_action_found = 1
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET action_seq_for_ingreds = request->action_sequence
 ENDIF
 IF (template_order_id=0.0
  AND action_sequence_sent_in=1)
  SELECT INTO "nl:"
   FROM order_action oa
   WHERE (oa.order_id=request->order_id)
    AND (oa.action_sequence <= request->action_sequence)
   ORDER BY oa.action_sequence
   DETAIL
    IF (oa.core_ind=1)
     reply->core_action_sequence = oa.action_sequence
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL checkactionsequencecompatibility(null)
 IF ((items_to_check->qual[1].verify_success_ind=1))
  SET action_seq_for_ingreds = verify_action_seq
 ENDIF
 SELECT INTO "nl:"
  o.order_id, oa.order_id, oa.action_sequence,
  od.order_id, od.action_sequence, od.oe_field_id,
  oef.oe_field_id, oef.field_type_flag, off.oe_format_id,
  off.action_type_cd, off.oe_field_id
  FROM orders o,
   orders ot,
   order_action oa,
   code_value_event_r cve,
   (dummyt d1  WITH seq = 1),
   order_detail od,
   (dummyt d3  WITH seq = 1),
   oe_format_fields off,
   (dummyt d2  WITH seq = 1),
   order_entry_fields oef
  PLAN (o
   WHERE (o.order_id=request->order_id))
   JOIN (ot
   WHERE ot.order_id=o.template_order_id)
   JOIN (oa
   WHERE (oa.order_id=request->order_id)
    AND (oa.action_sequence=request->action_sequence))
   JOIN (cve
   WHERE (cve.parent_cd= Outerjoin(o.catalog_cd)) )
   JOIN (d1)
   JOIN (od
   WHERE ((od.order_id=oa.order_id
    AND (od.action_sequence=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id
     AND (od2.action_sequence <= request->action_sequence)))) OR (((od.order_id=ot.order_id
    AND od.oe_field_meaning_id=freqmeanid
    AND (od.action_sequence=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id))) OR (od.order_id=ot.order_id
    AND od.oe_field_meaning_id IN (routemeanid, ratemeanid, infusemeanmeanid, ratemeanunitid,
   infusemeanunitid,
   formmeanid, volumemeanid, volumeunitmeanid)
    AND (items_to_check->qual[1].verify_success_ind=1)
    AND (od.action_sequence=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id
     AND od2.action_sequence <= 2)))) )) )
   JOIN (d3)
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.action_type_cd=new_action_type_cd
    AND off.oe_field_id=od.oe_field_id)
   JOIN (d2)
   JOIN (oef
   WHERE oef.oe_field_id=od.oe_field_id
    AND ((oef.field_type_flag=1) OR (oef.field_type_flag=2)) )
  ORDER BY o.order_id, oa.order_id, od.oe_field_id,
   od.detail_sequence
  HEAD REPORT
   detail_cnt = 0
  HEAD o.order_id
   reply->order_id = o.order_id, reply->person_id = o.person_id, reply->encntr_id = o.encntr_id,
   reply->hna_order_mnemonic = o.hna_order_mnemonic, reply->ordered_as_mnemonic = o
   .ordered_as_mnemonic, reply->order_mnemonic = o.order_mnemonic,
   reply->catalog_cd = o.catalog_cd, reply->iv_ind = o.iv_ind, reply->orig_order_dt_tm = cnvtdatetime
   (o.orig_order_dt_tm),
   reply->orig_order_tz = o.orig_order_tz, reply->template_order_id = ot.order_id, reply->
   template_core_action_sequence = o.template_core_action_sequence,
   reply->need_rx_verify_ind = o.need_rx_verify_ind, reply->need_rx_clin_review_flag = o
   .need_rx_clin_review_flag, reply->prn_ind = o.prn_ind,
   reply->orderable_type_flag = o.orderable_type_flag, reply->dcp_clin_cat_cd = o.dcp_clin_cat_cd,
   reply->med_order_type_cd = o.med_order_type_cd,
   reply->event_cd = cve.event_cd, reply->catalog_type_cd = o.catalog_type_cd, reply->
   activity_type_cd = o.activity_type_cd,
   reply->freq_type_flag = o.freq_type_flag, reply->last_action_sequence = o.last_action_sequence,
   reply->updt_cnt = o.updt_cnt,
   reply->oe_format_id = o.oe_format_id, reply->synonym_id = o.synonym_id, reply->dosing_method_flag
    = o.dosing_method_flag,
   reply->template_dose_seq = o.template_dose_sequence
   IF (o.pathway_catalog_id > 0)
    reply->plan_ind = 1
   ELSE
    reply->plan_ind = 0
   ENDIF
   IF (o.template_order_id > 0)
    template_order_query_id = o.template_order_id, parent_entity_id = o.template_order_id, reply->
    need_nurse_review_ind = ot.need_nurse_review_ind,
    reply->comment_type_mask = bor(o.comment_type_mask,band(ot.comment_type_mask,admin_note_mask)),
    reply->comment_type_mask = bor(reply->comment_type_mask,band(ot.comment_type_mask,mar_note_mask)),
    order_ingredient_where = concat(trim(order_ingredient_where),"oi.order_id = ",trim(cnvtstring(o
       .template_order_id,20,2))," and oi.action_sequence = (select max(oi2.action_sequence)",
     " from order_ingredient oi2",
     " where oi2.order_id = oi.order_id and"," oi2.action_sequence <= ",trim(cnvtstring(
       action_seq_for_ingreds)),")")
   ELSE
    reply->parent_order_last_action_seq = o.last_action_sequence, parent_entity_id = o.order_id,
    reply->need_nurse_review_ind = o.need_nurse_review_ind,
    reply->comment_type_mask = o.comment_type_mask, order_ingredient_where = concat(trim(
      order_ingredient_where),"oi.order_id = ",trim(cnvtstring(o.order_id,20,2)),
     " and oi.action_sequence = (select max(oi2.action_sequence)"," from order_ingredient oi2",
     " where oi2.order_id = oi.order_id and"," oi2.action_sequence <= ",trim(cnvtstring(
       action_seq_for_ingreds)),")")
   ENDIF
  HEAD oa.order_id
   reply->clinical_display_line = oa.clinical_display_line, reply->effective_dt_tm = cnvtdatetime(oa
    .effective_dt_tm), reply->effective_tz = oa.effective_tz,
   reply->order_status_cd = oa.order_status_cd, reply->action_sequence = oa.action_sequence
   IF (oa.order_provider_id > 0)
    reply->order_provider_id = oa.order_provider_id
   ENDIF
  HEAD od.oe_field_id
   detail_cnt += 1
   IF (detail_cnt > size(reply->detail_qual,5))
    stat = alterlist(reply->detail_qual,(detail_cnt+ 5))
   ENDIF
   reply->detail_qual[detail_cnt].oe_field_display_value = trim(od.oe_field_display_value), reply->
   detail_qual[detail_cnt].oe_field_dt_tm_value = cnvtdatetime(od.oe_field_dt_tm_value), reply->
   detail_qual[detail_cnt].oe_field_tz = od.oe_field_tz,
   reply->detail_qual[detail_cnt].oe_field_id = od.oe_field_id, reply->detail_qual[detail_cnt].
   oe_field_meaning_id = od.oe_field_meaning_id, reply->detail_qual[detail_cnt].oe_field_value = od
   .oe_field_value,
   reply->detail_qual[detail_cnt].min_val = oef.min_val, reply->detail_qual[detail_cnt].max_val = oef
   .max_val, reply->detail_qual[detail_cnt].input_mask = off.input_mask,
   reply->detail_qual[detail_cnt].label_text = off.label_text, reply->detail_qual[detail_cnt].
   filter_params = off.filter_params, reply->detail_qual[detail_cnt].oe_field_meaning = od
   .oe_field_meaning
   IF (od.oe_field_meaning_id=2007)
    reply->dispense_category_cd = od.oe_field_value
   ENDIF
   detail_value_cnt = 0
  HEAD od.detail_sequence
   detail_value_cnt += 1
   IF (detail_value_cnt > size(reply->detail_qual[detail_cnt].detail_value,5))
    stat = alterlist(reply->detail_qual[detail_cnt].detail_value,detail_value_cnt)
   ENDIF
   reply->detail_qual[detail_cnt].detail_value[detail_value_cnt].oe_field_value = od.oe_field_value,
   reply->detail_qual[detail_cnt].detail_value[detail_value_cnt].oe_field_display_value = trim(od
    .oe_field_display_value), reply->detail_qual[detail_cnt].detail_value[detail_value_cnt].
   oe_field_dt_tm_value = cnvtdatetime(od.oe_field_dt_tm_value),
   reply->detail_qual[detail_cnt].detail_value[detail_value_cnt].oe_field_tz = od.oe_field_tz
  FOOT REPORT
   stat = alterlist(reply->detail_qual,detail_cnt)
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF ((reply->need_rx_clin_review_flag=0))
  SET map_request->mapping_ind = 1
  SET map_request->map_from_value = reply->need_rx_verify_ind
  SET modify = nopredeclare
  EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
   "MAP_REPLY")
  SET modify = predeclare
  SET reply->need_rx_clin_review_flag = map_reply->map_to_value
 ENDIF
 IF (order_ingredient_where != null)
  SELECT INTO "nl:"
   FROM order_ingredient oi,
    code_value_event_r cve,
    order_catalog_synonym ocs,
    order_ingredient_dose oid,
    long_text lt
   PLAN (oi
    WHERE parser(order_ingredient_where)
     AND oi.ingredient_type_flag != icompoundchild)
    JOIN (cve
    WHERE (cve.parent_cd= Outerjoin(oi.catalog_cd)) )
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(oi.synonym_id)) )
    JOIN (oid
    WHERE (oid.order_id= Outerjoin(oi.order_id))
     AND (oid.action_sequence= Outerjoin(oi.action_sequence))
     AND (oid.comp_sequence= Outerjoin(oi.comp_sequence))
     AND (oid.dose_sequence= Outerjoin(reply->template_dose_seq)) )
    JOIN (lt
    WHERE (lt.long_text_id= Outerjoin(oi.dose_calculator_long_text_id)) )
   HEAD REPORT
    ingred_cnt = 0, reply->ingred_action_seq = oi.action_sequence
   HEAD oi.comp_sequence
    ingred_cnt += 1
    IF (ingred_cnt > size(reply->ingred_qual,5))
     stat = alterlist(reply->ingred_qual,(ingred_cnt+ 5))
    ENDIF
    reply->ingred_qual[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->ingred_qual[
    ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic, reply->ingred_qual[ingred_cnt].
    order_mnemonic = oi.order_mnemonic,
    reply->ingred_qual[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag, reply->
    ingred_qual[ingred_cnt].comp_sequence = oi.comp_sequence, reply->ingred_qual[ingred_cnt].freq_cd
     = oi.freq_cd,
    reply->ingred_qual[ingred_cnt].catalog_cd = oi.catalog_cd, reply->ingred_qual[ingred_cnt].
    catalog_type_cd = oi.catalog_type_cd, reply->ingred_qual[ingred_cnt].synonym_id = oi.synonym_id,
    reply->ingred_qual[ingred_cnt].event_cd = cve.event_cd, reply->ingred_qual[ingred_cnt].
    include_in_total_volume_flag = oi.include_in_total_volume_flag, reply->ingred_qual[ingred_cnt].
    iv_seq = oi.iv_seq,
    reply->ingred_qual[ingred_cnt].witness_required_ind = ocs.witness_flag, reply->ingred_qual[
    ingred_cnt].normalized_rate = oi.normalized_rate, reply->ingred_qual[ingred_cnt].
    normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
    reply->ingred_qual[ingred_cnt].concentration = oi.concentration, reply->ingred_qual[ingred_cnt].
    concentration_unit_cd = oi.concentration_unit_cd, reply->ingred_qual[ingred_cnt].
    ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
    reply->ingred_qual[ingred_cnt].clinically_significant_flag = oi.clinically_significant_flag,
    reply->ingred_qual[ingred_cnt].ingredient_source_flag = oi.ingredient_source_flag, reply->
    ingred_qual[ingred_cnt].last_admin_disp_basis_flag = ocs.last_admin_disp_basis_flag,
    reply->ingred_qual[ingred_cnt].med_interval_warn_flag = ocs.med_interval_warn_flag, reply->
    ingred_qual[ingred_cnt].autoprog_syn_ind = ocs.autoprog_syn_ind
    IF (validate(ocs.display_additives_first_ind))
     reply->ingred_qual[ingred_cnt].display_additives_first_ind = ocs.display_additives_first_ind
    ENDIF
    IF (ocs.autoprog_syn_ind=0)
     reply->ingred_qual[ingred_cnt].autoprogramming_id = oi.catalog_cd
    ELSEIF (ocs.autoprog_syn_ind=1)
     reply->ingred_qual[ingred_cnt].autoprogramming_id = oi.synonym_id
    ENDIF
    IF (validate(lt.long_text))
     reply->ingred_qual[ingred_cnt].adjusted_height = cnvtreal(substring((findstring(xml_height,
        cnvtlower(lt.long_text))+ size(xml_height)),(findstring(xml_height_end,cnvtlower(lt.long_text
         )) - (findstring(xml_height,cnvtlower(lt.long_text))+ size(xml_height))),lt.long_text)),
     reply->ingred_qual[ingred_cnt].adjusted_height_cd = cnvtreal(substring((findstring(
        xml_height_unit_cd,cnvtlower(lt.long_text))+ size(xml_height_unit_cd)),(findstring(
        xml_height_unit_cd_end,cnvtlower(lt.long_text)) - (findstring(xml_height_unit_cd,cnvtlower(lt
         .long_text))+ size(xml_height_unit_cd))),lt.long_text)), reply->ingred_qual[ingred_cnt].
     adjusted_weight = cnvtreal(substring((findstring(xml_adjusted_weight,cnvtlower(lt.long_text))+
       size(xml_adjusted_weight)),(findstring(xml_adjusted_weight_end,cnvtlower(lt.long_text)) - (
       findstring(xml_adjusted_weight,cnvtlower(lt.long_text))+ size(xml_adjusted_weight))),lt
       .long_text)),
     reply->ingred_qual[ingred_cnt].adjusted_weight_cd = cnvtreal(substring((findstring(
        xml_adjusted_weight_unit_cd,cnvtlower(lt.long_text))+ size(xml_adjusted_weight_unit_cd)),(
       findstring(xml_adjusted_weight_unit_cd_end,cnvtlower(lt.long_text)) - (findstring(
        xml_adjusted_weight_unit_cd,cnvtlower(lt.long_text))+ size(xml_adjusted_weight_unit_cd))),lt
       .long_text)), reply->ingred_qual[ingred_cnt].final_dose = cnvtreal(substring((findstring(
        xml_final_dose,cnvtlower(lt.long_text))+ size(xml_final_dose)),(findstring(xml_final_dose_end,
        cnvtlower(lt.long_text)) - (findstring(xml_final_dose,cnvtlower(lt.long_text))+ size(
        xml_final_dose))),lt.long_text)), reply->ingred_qual[ingred_cnt].final_dose_unit_cd =
     cnvtreal(substring((findstring(xml_final_dose_unit_cd,cnvtlower(lt.long_text))+ size(
        xml_final_dose_unit_cd)),(findstring(xml_final_dose_unit_cd_end,cnvtlower(lt.long_text)) - (
       findstring(xml_final_dose_unit_cd,cnvtlower(lt.long_text))+ size(xml_final_dose_unit_cd))),lt
       .long_text)),
     reply->ingred_qual[ingred_cnt].actual_final_dose = cnvtreal(substring((findstring(
        xml_actual_final_dose,cnvtlower(lt.long_text))+ size(xml_actual_final_dose)),(findstring(
        xml_actual_final_dose_end,cnvtlower(lt.long_text)) - (findstring(xml_actual_final_dose,
        cnvtlower(lt.long_text))+ size(xml_actual_final_dose))),lt.long_text)), reply->ingred_qual[
     ingred_cnt].actual_final_dose_unit_cd = cnvtreal(substring((findstring(
        xml_actual_final_dose_unit_cd,cnvtlower(lt.long_text))+ size(xml_actual_final_dose_unit_cd)),
       (findstring(xml_actual_final_dose_unit_cd_end,cnvtlower(lt.long_text)) - (findstring(
        xml_actual_final_dose_unit_cd,cnvtlower(lt.long_text))+ size(xml_actual_final_dose_unit_cd))),
       lt.long_text)), reply->ingred_qual[ingred_cnt].dose_type_applied = cnvtreal(substring((
       findstring(xml_dose_type_applied,cnvtlower(lt.long_text))+ size(xml_dose_type_applied)),(
       findstring(xml_dose_type_applied_end,cnvtlower(lt.long_text)) - (findstring(
        xml_dose_type_applied,cnvtlower(lt.long_text))+ size(xml_dose_type_applied))),lt.long_text)),
     reply->ingred_qual[ingred_cnt].standard_dose = cnvtreal(substring((findstring(xml_standard_dose,
        cnvtlower(lt.long_text))+ size(xml_standard_dose)),(findstring(xml_standard_dose_end,
        cnvtlower(lt.long_text)) - (findstring(xml_standard_dose,cnvtlower(lt.long_text))+ size(
        xml_standard_dose))),lt.long_text)), reply->ingred_qual[ingred_cnt].standard_dose_unit_cd =
     cnvtreal(substring((findstring(xml_standard_dose_unit_cd,cnvtlower(lt.long_text))+ size(
        xml_standard_dose_unit_cd)),(findstring(xml_standard_dose_unit_cd_end,cnvtlower(lt.long_text)
        ) - (findstring(xml_standard_dose_unit_cd,cnvtlower(lt.long_text))+ size(
        xml_standard_dose_unit_cd))),lt.long_text)), reply->ingred_qual[ingred_cnt].
     actual_standard_dose = cnvtreal(substring((findstring(xml_actual_standard_dose,cnvtlower(lt
         .long_text))+ size(xml_actual_standard_dose)),(findstring(xml_actual_standard_dose_end,
        cnvtlower(lt.long_text)) - (findstring(xml_actual_standard_dose,cnvtlower(lt.long_text))+
       size(xml_actual_standard_dose))),lt.long_text)),
     reply->ingred_qual[ingred_cnt].actual_standard_dose_unit_cd = cnvtreal(substring((findstring(
        xml_actual_standard_dose_unit_cd,cnvtlower(lt.long_text))+ size(
        xml_actual_standard_dose_unit_cd)),(findstring(xml_actual_standard_dose_unit_cd_end,cnvtlower
        (lt.long_text)) - (findstring(xml_actual_standard_dose_unit_cd,cnvtlower(lt.long_text))+ size
       (xml_actual_standard_dose_unit_cd))),lt.long_text))
    ENDIF
    IF (oid.order_ingredient_dose_id > 0)
     reply->ingred_qual[ingred_cnt].strength = oid.strength_dose_value, reply->ingred_qual[ingred_cnt
     ].strength_unit = oid.strength_dose_unit_cd, reply->ingred_qual[ingred_cnt].volume = oid
     .volume_dose_value,
     reply->ingred_qual[ingred_cnt].volume_unit = oid.volume_dose_unit_cd, reply->ingred_qual[
     ingred_cnt].ordered_dose = oid.ordered_dose_value, reply->ingred_qual[ingred_cnt].
     ordered_dose_unit_cd = oid.ordered_dose_unit_cd
     IF (oid.strength_dose_value_display != "")
      reply->ingred_qual[ingred_cnt].order_detail_display_line = oid.strength_dose_value_display
     ELSEIF (oid.volume_dose_value_display != "")
      reply->ingred_qual[ingred_cnt].order_detail_display_line = oid.volume_dose_value_display
     ELSEIF (oid.ordered_dose_value_display != "")
      reply->ingred_qual[ingred_cnt].order_detail_display_line = oid.ordered_dose_value_display
     ENDIF
    ELSE
     reply->ingred_qual[ingred_cnt].strength = oi.strength, reply->ingred_qual[ingred_cnt].
     strength_unit = oi.strength_unit, reply->ingred_qual[ingred_cnt].volume = oi.volume,
     reply->ingred_qual[ingred_cnt].volume_unit = oi.volume_unit, reply->ingred_qual[ingred_cnt].
     ordered_dose = oi.ordered_dose, reply->ingred_qual[ingred_cnt].ordered_dose_unit_cd = oi
     .ordered_dose_unit_cd,
     reply->ingred_qual[ingred_cnt].freetext_dose = oi.freetext_dose, reply->ingred_qual[ingred_cnt].
     dose_quantity = oi.dose_quantity, reply->ingred_qual[ingred_cnt].dose_quantity_unit = oi
     .dose_quantity_unit,
     reply->ingred_qual[ingred_cnt].order_detail_display_line = oi.order_detail_display_line
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->ingred_qual,ingred_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->ingred_action_seq > 1))
  DECLARE curr_ingred_cnt = i4 WITH noconstant(0)
  DECLARE init_order_ingred_cnt = i4 WITH noconstant(0)
  DECLARE i = i4 WITH noconstant(0)
  DECLARE j = i4 WITH noconstant(0)
  DECLARE usecatalogcd = i2 WITH constant(0)
  DECLARE usesynonymid = i2 WITH constant(1)
  SELECT INTO "n1:"
   FROM order_ingredient oi,
    order_catalog_synonym ocs
   WHERE oi.order_id=evaluate(reply->template_order_id,0.0,request->order_id,reply->template_order_id
    )
    AND oi.action_sequence=1
    AND oi.catalog_cd=ocs.catalog_cd
    AND oi.synonym_id=ocs.synonym_id
    AND ocs.active_ind=1
   ORDER BY oi.catalog_cd
   HEAD REPORT
    ingred_cnt = 0, stat = alterlist(temp_autoprogramming->autoprog_list,5)
   HEAD oi.catalog_cd
    ingred_cnt += 1
    IF (ingred_cnt > size(temp_autoprogramming->autoprog_list,5))
     stat = alterlist(temp_autoprogramming->autoprog_list,(ingred_cnt+ 4))
    ENDIF
    temp_autoprogramming->autoprog_list[ingred_cnt].catalog_cd = oi.catalog_cd, temp_autoprogramming
    ->autoprog_list[ingred_cnt].synonym_id = oi.synonym_id, temp_autoprogramming->autoprog_list[
    ingred_cnt].autoprog_syn_ind = ocs.autoprog_syn_ind
   FOOT REPORT
    stat = alterlist(temp_autoprogramming->autoprog_list,ingred_cnt)
   WITH nocounter
  ;end select
  SET init_order_ingred_cnt = size(temp_autoprogramming->autoprog_list,5)
  SET curr_ingred_cnt = size(reply->ingred_qual,5)
  FOR (i = 1 TO curr_ingred_cnt)
    FOR (j = 1 TO init_order_ingred_cnt)
      IF ((reply->ingred_qual[i].catalog_cd=temp_autoprogramming->autoprog_list[j].catalog_cd))
       SET reply->ingred_qual[i].autoprog_syn_ind = temp_autoprogramming->autoprog_list[j].
       autoprog_syn_ind
       IF ((temp_autoprogramming->autoprog_list[j].autoprog_syn_ind=usecatalogcd))
        SET reply->ingred_qual[i].autoprogramming_id = temp_autoprogramming->autoprog_list[j].
        catalog_cd
       ELSEIF ((temp_autoprogramming->autoprog_list[j].autoprog_syn_ind=usesynonymid))
        SET reply->ingred_qual[i].autoprogramming_id = temp_autoprogramming->autoprog_list[j].
        synonym_id
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE (ce.order_id=request->order_id)
   AND ce.parent_event_id=ce.event_id
   AND ce.event_class_cd=group_class_cd
  DETAIL
   reply->root_event_id = ce.parent_event_id
  WITH nocounter
 ;end select
 IF (band(reply->comment_type_mask,order_comment_mask)=order_comment_mask)
  SELECT INTO "nl:"
   FROM order_comment oc,
    long_text lt
   PLAN (oc
    WHERE (oc.order_id=request->order_id)
     AND oc.comment_type_cd=order_comment_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=oc.order_id
      AND oc2.comment_type_cd=order_comment_cd)))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id)
   DETAIL
    reply->order_comment_text = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 SET reply->immunization_ind = 0
 SELECT INTO "nl:"
  cve.code_set, cve.field_name, cve.field_type,
  cve.field_value, cve.code_value
  FROM code_value_extension cve
  PLAN (cve
   WHERE cve.code_set=200
    AND cve.field_name="IMMUNIZATIONIND"
    AND cve.field_value="1"
    AND (cve.code_value=reply->catalog_cd))
  DETAIL
   reply->immunization_ind = 1
  WITH nocounter
 ;end select
 DECLARE iv_sequence_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 IF (order_ingredient_where != null
  AND parent_entity_id > 0.0)
  SELECT INTO "nl:"
   FROM act_pw_comp apc,
    pathway pw
   PLAN (apc
    WHERE apc.parent_entity_id=parent_entity_id
     AND apc.parent_entity_name="ORDERS"
     AND apc.active_ind=1)
    JOIN (pw
    WHERE pw.pathway_id=apc.pathway_id)
   DETAIL
    IF (trim(pw.type_mean)="TAPERPLAN")
     reply->taper_ind = 1
    ELSE
     reply->taper_ind = 0
    ENDIF
    IF (iv_sequence_type_cd=pw.pathway_type_cd)
     reply->iv_sequence_ind = 1
    ELSE
     reply->iv_sequence_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (template_order_query_id > 0.0)
  SELECT INTO "nl:"
   FROM orders o
   WHERE o.order_id=template_order_query_id
   DETAIL
    reply->parent_order_last_action_seq = o.last_action_sequence
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  oiv.applicable_fields_bit, oiv.finished_bags_cnt, oiv.total_bags_nbr,
  oiv.updt_cnt
  FROM orders o,
   order_iv_info oiv
  PLAN (o
   WHERE (o.order_id=request->order_id))
   JOIN (oiv
   WHERE oiv.order_id=o.order_id)
  DETAIL
   reply->applicable_fields_bit = oiv.applicable_fields_bit, reply->finished_bags_cnt = oiv
   .finished_bags_cnt, reply->total_bags_nbr = oiv.total_bags_nbr,
   reply->order_iv_info_updt_cnt = oiv.updt_cnt
  WITH nocounter
 ;end select
 IF (((detail_cnt > 0) OR (ingred_cnt > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "074"
 SET mod_date = "05/04/2017"
 SET modify = nopredeclare
END GO
