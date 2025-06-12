CREATE PROGRAM dcp_get_pw_detail:dba
 RECORD reply(
   1 pathway_cnt = i4
   1 qual_pathway[*]
     2 pathway_id = f8
     2 component_cnt = i4
     2 qual_component[*]
       3 act_pw_comp_id = f8
       3 sequence = i4
       3 pathway_comp_id = f8
       3 act_time_frame_id = f8
       3 act_care_cat_id = f8
       3 comp_type_cd = f8
       3 comp_type_disp = vc
       3 comp_type_mean = c12
       3 ref_prnt_ent_name = vc
       3 ref_prnt_ent_id = f8
       3 repeat_ind = i2
       3 required_ind = i2
       3 comp_status_cd = f8
       3 comp_status_disp = vc
       3 comp_status_mean = c12
       3 encntr_id = f8
       3 person_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 orig_prnt_entity_id = f8
       3 existing_ind = i2
       3 comp_label = vc
       3 comp_text = vc
       3 text_updt_cnt = i4
       3 related_comp_id = f8
       3 after_qty = i4
       3 age_units_cd = f8
       3 age_units_disp = vc
       3 age_units_mean = c12
       3 created_dt_tm = dq8
       3 included_ind = i2
       3 included_dt_tm = dq8
       3 canceled_ind = i2
       3 canceled_dt_tm = dq8
       3 activated_ind = i2
       3 activated_dt_tm = dq8
       3 active_ind = i2
       3 orc_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_mnemonic = vc
       3 synonym_id = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 catalog_cd = f8
       3 oe_format_id = f8
       3 order_sentence_id = f8
       3 clinical_display_line = vc
       3 sentence_detail_cnt = i4
       3 qual_sentence_detail[*]
         4 sequence = i4
         4 order_sentence_id = f8
         4 oe_field_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_meaning_id = f8
         4 oe_field_type_flag = i2
       3 duration_seq = i4
       3 duration_unit_seq = i4
       3 frequency_seq = i4
       3 order_comment_ind = i2
       3 order_status_cd = f8
       3 order_status_disp = vc
       3 order_status_mean = c12
       3 order_last_updt_cnt = i4
       3 dept_status_cd = f8
       3 need_doctor_cosign_ind = i2
       3 need_nurse_review_ind = i2
       3 ref_text_mask = i4
       3 cki = vc
       3 ingredient_ind = i2
       3 template_order_flag = i2
       3 suspend_ind = i2
       3 resume_ind = i2
       3 constant_ind = i2
       3 prn_ind = i2
       3 current_start_dt_tm = dq8
       3 projected_stop_dt_tm = dq8
       3 dcp_clin_cat_cd = f8
       3 orderable_type_flag = i2
       3 med_order_type_cd = f8
       3 stop_type_cd = f8
       3 comment_type_mask = i4
       3 order_comment_text = vc
       3 additive_cnt = i4
       3 cs_flag = i2
       3 freq_type_flag = i2
       3 rx_mask = i4
       3 resume_effective_dt_tm = dq8
       3 suspend_effective_dt_tm = dq8
       3 task_description = vc
       3 task_status_cd = f8
       3 task_status_disp = vc
       3 task_status_mean = c12
       3 updt_cnt = i4
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 duration_unit_disp = c40
       3 duration_unit_mean = c12
       3 task_assay_cd = f8
       3 event_cd = f8
       3 result_type_cd = f8
       3 result_type_disp = c40
       3 result_type_mean = c12
       3 outcome_operator_cd = f8
       3 outcome_operator_disp = c40
       3 outcome_operator_mean = c12
       3 result_value = f8
       3 result_units_cd = f8
       3 result_units_disp = c40
       3 result_units_mean = c12
       3 outcome_forms_ref_id = f8
       3 capture_variance_ind = i2
       3 variance_required_ind = i2
       3 reference_task_id = f8
       3 dcp_forms_ref_id = f8
       3 linked_to_tf_ind = i2
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
       3 cond_ind = i2
       3 cond_desc = vc
       3 cond_note_id = f8
       3 cond_note = vc
       3 ctext_updt_cnt = i4
       3 cond_module_name = vc
       3 cond_false_ind = i2
       3 cond_eval_dt_tm = dq8
       3 cond_eval_ind = i2
       3 cond_eval_result_ind = i2
       3 cond_sys_eval_ind = i2
       3 cond_eval_prsnl_id = f8
       3 rrf_age_qty = i4
       3 rrf_age_units_cd = f8
       3 rrf_age_units_disp = c40
       3 rrf_age_units_mean = c12
       3 rrf_sex_cd = f8
       3 rrf_sex_disp = c40
       3 rrf_sex_mean = c12
       3 outcome_value_descript = vc
       3 event_set_disp = vc
       3 shared_comp_cnt = i2
       3 qual_shared_comp[*]
         4 pathway_id = f8
         4 act_pw_comp_id = f8
         4 comp_status_cd = f8
         4 comp_status_disp = vc
         4 comp_status_mean = c12
       3 comp_focus_cnt = i4
       3 qual_comp_focus[*]
         4 act_pw_comp_focus_r_id = f8
         4 nomenclature_id = f8
         4 nom_source_string = vc
         4 primary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET cnt1 = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET cnt4 = 0
 SET var_cnt = 0
 SET path_cnt = 0
 SET cf_cnt = 0
 SET echo_label = fillstring(30," ")
 SET idpathway = 0
 SET idlongtext = 0
 SET idtimeframe = 0
 SET idcarecategory = 0
 SET idcomponent = 0
 SET shrcnt = 0
 SET osd_cnt = 0
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET note_meaning = "NOTE"
 SET order_create_meaning = "ORDER CREATE"
 SET label_meaning = "LABEL"
 SET outcome_create_meaning = "OUTCOME CREA"
 SET task_create_meaning = "TASK CREATE"
 SET result_outcome_meaning = "RESULT OUTCO"
 SET pw_text_id = 0
 SET comp_text_id = 0
 SET ent_rel_id = 0
 SET parent_entity_name = fillstring(32," ")
 SET rrf_age_qty = 0
 SET rrf_age_units_mean = fillstring(12," ")
 SET task_assay_cd = 0.0
 SET rrf_sex_cd = 0.0
 SET result_value = 0.0
 SET outcome_value_descript = fillstring(255," ")
 SET duration_mean_id = 0.0
 SET duration_unit_mean_id = 0.0
 SET frequency_mean_id = 0.0
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE mar_note_mask = i4 WITH constant(2)
 DECLARE admin_note_mask = i4 WITH constant(128)
 DECLARE add_cnt = i4 WITH noconstant(0)
 SET code_set = 16750
 SET cdf_meaning = note_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = order_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET order_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = label_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET label_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = outcome_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET outcome_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = task_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = result_outcome_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "2"
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "5"
 EXECUTE cpm_get_cd_for_cdf
 SET multi_type_cd = code_value
 SELECT INTO "nl:"
  ofm.oe_field_meaning_id, ofm.oe_field_meaning
  FROM oe_field_meaning ofm
  WHERE ((ofm.oe_field_meaning="DURATION") OR (((ofm.oe_field_meaning="DURATIONUNIT") OR (ofm
  .oe_field_meaning="FREQ")) ))
  DETAIL
   IF (ofm.oe_field_meaning="DURATION")
    duration_mean_id = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="DURATIONUNIT")
    duration_unit_mean_id = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="FREQ")
    frequency_mean_id = ofm.oe_field_meaning_id
   ENDIF
  WITH nocounter
 ;end select
 SET pathways_to_get = cnvtint(size(request->pathway_list,5))
 SELECT INTO "nl:"
  d.seq, apc.pathway_id, apc.act_pw_comp_id
  FROM (dummyt d  WITH seq = value(pathways_to_get)),
   act_pw_comp apc,
   (dummyt d1  WITH seq = 1),
   act_pw_comp_focus_r acf,
   nomenclature nom
  PLAN (d)
   JOIN (apc
   WHERE (apc.pathway_id=request->pathway_list[d.seq].pathway_id))
   JOIN (d1)
   JOIN (acf
   WHERE acf.act_pw_comp_id=apc.act_pw_comp_id
    AND acf.active_ind=1)
   JOIN (nom
   WHERE nom.nomenclature_id=acf.nomenclature_id)
  ORDER BY apc.pathway_id, apc.act_pw_comp_id
  HEAD REPORT
   ncnt = 0, cnt1 = 0, cnt2 = 0
  HEAD apc.pathway_id
   cnt1 = 0, ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->qual_pathway,5))
    stat = alterlist(reply->qual_pathway,(ncnt+ 10))
   ENDIF
   reply->qual_pathway[ncnt].pathway_id = apc.pathway_id
  HEAD apc.act_pw_comp_id
   cf_cnt = 0, cnt1 = (cnt1+ 1)
   IF (cnt1 > size(reply->qual_pathway[ncnt].qual_component,5))
    stat = alterlist(reply->qual_pathway[ncnt].qual_component,(cnt1+ 10))
   ENDIF
   reply->qual_pathway[ncnt].qual_component[cnt1].act_pw_comp_id = apc.act_pw_comp_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].sequence = apc.sequence, reply->qual_pathway[ncnt].
   qual_component[cnt1].pathway_comp_id = apc.pathway_comp_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].act_time_frame_id = apc.act_time_frame_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].act_care_cat_id = apc.act_care_cat_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].comp_type_cd = apc.comp_type_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].ref_prnt_ent_name = apc.ref_prnt_ent_name, reply->
   qual_pathway[ncnt].qual_component[cnt1].ref_prnt_ent_id = apc.ref_prnt_ent_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].repeat_ind = apc.repeat_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].required_ind = apc.required_ind, reply->
   qual_pathway[ncnt].qual_component[cnt1].comp_status_cd = apc.comp_status_cd, reply->qual_pathway[
   ncnt].qual_component[cnt1].encntr_id = apc.encntr_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].person_id = apc.person_id, reply->qual_pathway[ncnt
   ].qual_component[cnt1].parent_entity_name = apc.parent_entity_name, reply->qual_pathway[ncnt].
   qual_component[cnt1].parent_entity_id = apc.parent_entity_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].orig_prnt_entity_id = apc.orig_prnt_ent_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].existing_ind = apc.existing_ind, reply->qual_pathway[ncnt]
   .qual_component[cnt1].comp_label = apc.comp_label,
   reply->qual_pathway[ncnt].qual_component[cnt1].related_comp_id = apc.related_comp_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].after_qty = apc.after_qty, reply->qual_pathway[ncnt].
   qual_component[cnt1].age_units_cd = apc.age_units_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].age_units_mean = uar_get_code_meaning(apc
    .age_units_cd), reply->qual_pathway[ncnt].qual_component[cnt1].created_dt_tm = cnvtdatetime(apc
    .created_dt_tm), reply->qual_pathway[ncnt].qual_component[cnt1].included_ind = apc.included_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].included_dt_tm = cnvtdatetime(apc.included_dt_tm),
   reply->qual_pathway[ncnt].qual_component[cnt1].canceled_ind = apc.canceled_ind, reply->
   qual_pathway[ncnt].qual_component[cnt1].canceled_dt_tm = cnvtdatetime(apc.canceled_dt_tm),
   reply->qual_pathway[ncnt].qual_component[cnt1].activated_ind = apc.activated_ind, reply->
   qual_pathway[ncnt].qual_component[cnt1].activated_dt_tm = cnvtdatetime(apc.activated_dt_tm), reply
   ->qual_pathway[ncnt].qual_component[cnt1].active_ind = apc.active_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].updt_cnt = apc.updt_cnt, reply->qual_pathway[ncnt].
   qual_component[cnt1].duration_qty = apc.duration_qty, reply->qual_pathway[ncnt].qual_component[
   cnt1].duration_unit_cd = apc.duration_unit_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].task_assay_cd = apc.task_assay_cd, reply->
   qual_pathway[ncnt].qual_component[cnt1].event_cd = apc.event_cd, reply->qual_pathway[ncnt].
   qual_component[cnt1].result_type_cd = apc.result_type_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].outcome_operator_cd = apc.outcome_operator_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].result_value = apc.result_value, reply->
   qual_pathway[ncnt].qual_component[cnt1].result_units_cd = apc.result_units_cd,
   reply->qual_pathway[ncnt].qual_component[cnt1].capture_variance_ind = apc.capture_variance_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].variance_required_ind = apc.variance_required_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].reference_task_id = apc.reference_task_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].outcome_forms_ref_id = apc.outcome_forms_ref_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].dcp_forms_ref_id = apc.dcp_forms_ref_id, reply->
   qual_pathway[ncnt].qual_component[cnt1].linked_to_tf_ind = apc.linked_to_tf_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].start_dt_tm = cnvtdatetime(apc.start_dt_tm), reply
   ->qual_pathway[ncnt].qual_component[cnt1].end_dt_tm = cnvtdatetime(apc.end_dt_tm), reply->
   qual_pathway[ncnt].qual_component[cnt1].cond_ind = apc.cond_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].cond_desc = apc.cond_desc, reply->qual_pathway[ncnt
   ].qual_component[cnt1].cond_note_id = apc.cond_note_id, reply->qual_pathway[ncnt].qual_component[
   cnt1].cond_module_name = apc.cond_module_name,
   reply->qual_pathway[ncnt].qual_component[cnt1].cond_false_ind = apc.cond_false_ind, reply->
   qual_pathway[ncnt].qual_component[cnt1].cond_eval_dt_tm = cnvtdatetime(apc.cond_eval_dt_tm), reply
   ->qual_pathway[ncnt].qual_component[cnt1].cond_eval_ind = apc.cond_eval_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].cond_eval_result_ind = apc.cond_eval_result_ind,
   reply->qual_pathway[ncnt].qual_component[cnt1].cond_sys_eval_ind = apc.cond_sys_eval_ind, reply->
   qual_pathway[ncnt].qual_component[cnt1].cond_eval_prsnl_id = apc.cond_eval_prsnl_id,
   reply->qual_pathway[ncnt].qual_component[cnt1].rrf_age_qty = apc.rrf_age_qty, reply->qual_pathway[
   ncnt].qual_component[cnt1].rrf_age_units_cd = apc.rrf_age_units_cd, reply->qual_pathway[ncnt].
   qual_component[cnt1].rrf_sex_cd = apc.rrf_sex_cd
  DETAIL
   cf_cnt = (cf_cnt+ 1)
   IF (cf_cnt > size(reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus,5))
    stat = alterlist(reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus,(cf_cnt+ 10))
   ENDIF
   reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus[cf_cnt].act_pw_comp_focus_r_id =
   acf.act_pw_comp_focus_r_id, reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus[cf_cnt]
   .nomenclature_id = acf.nomenclature_id, reply->qual_pathway[ncnt].qual_component[cnt1].
   qual_comp_focus[cf_cnt].nom_source_string = nom.source_string,
   reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus[cf_cnt].primary_ind = acf
   .primary_ind
  FOOT  apc.act_pw_comp_id
   IF (cf_cnt > 0)
    stat = alterlist(reply->qual_pathway[ncnt].qual_component[cnt1].qual_comp_focus,cf_cnt)
   ENDIF
   reply->qual_pathway[ncnt].qual_component[cnt1].comp_focus_cnt = cf_cnt
  FOOT  apc.pathway_id
   stat = alterlist(reply->qual_pathway[ncnt].qual_component,cnt1), reply->qual_pathway[ncnt].
   component_cnt = cnt1
  FOOT REPORT
   stat = alterlist(reply->qual_pathway,ncnt), reply->pathway_cnt = ncnt
  WITH nocounter, outerjoin = d1
 ;end select
 IF (ncnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FOR (path_cnt = 1 TO reply->pathway_cnt)
   FOR (cnt3 = 1 TO reply->qual_pathway[path_cnt].component_cnt)
    CASE (reply->qual_pathway[path_cnt].qual_component[cnt3].comp_type_cd)
     OF note_type_cd:
      EXECUTE FROM note_comp TO note_comp_end
     OF order_create_type_cd:
      IF ((reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id=0))
       EXECUTE FROM get_oroc_comp_ref TO get_oroc_comp_ref_end
      ELSE
       EXECUTE FROM get_oroc_comp TO get_oroc_comp_end
      ENDIF
     OF outcome_create_type_cd:
      IF ((reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id=0))
       EXECUTE FROM get_oroc_comp_ref TO get_oroc_comp_ref_end
      ELSE
       EXECUTE FROM get_oroc_comp TO get_oroc_comp_end
      ENDIF
     OF task_create_type_cd:
      IF ((reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id=0))
       EXECUTE FROM get_task_comp_ref TO get_task_comp_ref_end
      ELSE
       EXECUTE FROM get_task_comp TO get_task_comp_end
      ENDIF
     OF result_outcome_type_cd:
      EXECUTE FROM get_result_outcome_comp TO get_result_outcome_comp_end
    ENDCASE
    IF ((reply->qual_pathway[path_cnt].qual_component[cnt3].cond_ind=1))
     SELECT INTO "nl:"
      lt.long_text_id
      FROM long_text lt
      WHERE (lt.parent_entity_id=reply->qual_pathway[path_cnt].qual_component[cnt3].pathway_comp_id)
       AND lt.parent_entity_name="PATHWAY_COMP"
       AND (lt.long_text_id=reply->qual_pathway[path_cnt].qual_component[cnt3].cond_note_id)
      HEAD REPORT
       reply->qual_pathway[path_cnt].qual_component[cnt3].cond_note = lt.long_text, reply->
       qual_pathway[path_cnt].qual_component[cnt3].ctext_updt_cnt = lt.updt_cnt
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
 ENDFOR
 GO TO exit_script
#note_comp
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  WHERE (lt.parent_entity_id=reply->qual_pathway[path_cnt].qual_component[cnt3].act_pw_comp_id)
   AND lt.parent_entity_name="ACT_PW_COMP"
  HEAD REPORT
   reply->qual_pathway[path_cnt].qual_component[cnt3].comp_text = lt.long_text, reply->qual_pathway[
   path_cnt].qual_component[cnt3].text_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
#note_comp_end
#get_oroc_comp
 SELECT INTO "nl:"
  o.order_id
  FROM orders o,
   orders ot
  PLAN (o
   WHERE (o.order_id=reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id))
   JOIN (ot
   WHERE ot.order_id=o.template_order_id)
  DETAIL
   reply->qual_pathway[path_cnt].qual_component[cnt3].orc_mnemonic = o.hna_order_mnemonic, reply->
   qual_pathway[path_cnt].qual_component[cnt3].hna_order_mnemonic = o.hna_order_mnemonic, reply->
   qual_pathway[path_cnt].qual_component[cnt3].ordered_as_mnemonic = o.ordered_as_mnemonic,
   reply->qual_pathway[path_cnt].qual_component[cnt3].order_mnemonic = o.order_mnemonic, reply->
   qual_pathway[path_cnt].qual_component[cnt3].synonym_id = o.synonym_id, reply->qual_pathway[
   path_cnt].qual_component[cnt3].catalog_cd = o.catalog_cd,
   reply->qual_pathway[path_cnt].qual_component[cnt3].catalog_type_cd = o.catalog_type_cd, reply->
   qual_pathway[path_cnt].qual_component[cnt3].activity_type_cd = o.activity_type_cd, reply->
   qual_pathway[path_cnt].qual_component[cnt3].oe_format_id = o.oe_format_id,
   reply->qual_pathway[path_cnt].qual_component[cnt3].clinical_display_line = o.clinical_display_line,
   reply->qual_pathway[path_cnt].qual_component[cnt3].order_comment_ind = o.order_comment_ind, reply
   ->qual_pathway[path_cnt].qual_component[cnt3].order_status_cd = o.order_status_cd,
   reply->qual_pathway[path_cnt].qual_component[cnt3].order_last_updt_cnt = o.updt_cnt, reply->
   qual_pathway[path_cnt].qual_component[cnt3].dept_status_cd = o.dept_status_cd, reply->
   qual_pathway[path_cnt].qual_component[cnt3].need_doctor_cosign_ind = o.need_doctor_cosign_ind,
   reply->qual_pathway[path_cnt].qual_component[cnt3].ref_text_mask = o.ref_text_mask, reply->
   qual_pathway[path_cnt].qual_component[cnt3].cki = o.cki, reply->qual_pathway[path_cnt].
   qual_component[cnt3].ingredient_ind = o.ingredient_ind,
   reply->qual_pathway[path_cnt].qual_component[cnt3].template_order_flag = o.template_order_flag,
   reply->qual_pathway[path_cnt].qual_component[cnt3].suspend_ind = o.suspend_ind, reply->
   qual_pathway[path_cnt].qual_component[cnt3].resume_ind = o.resume_ind,
   reply->qual_pathway[path_cnt].qual_component[cnt3].constant_ind = o.constant_ind, reply->
   qual_pathway[path_cnt].qual_component[cnt3].prn_ind = o.prn_ind, reply->qual_pathway[path_cnt].
   qual_component[cnt3].current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm),
   reply->qual_pathway[path_cnt].qual_component[cnt3].projected_stop_dt_tm = cnvtdatetime(o
    .projected_stop_dt_tm), reply->qual_pathway[path_cnt].qual_component[cnt3].dcp_clin_cat_cd = o
   .dcp_clin_cat_cd, reply->qual_pathway[path_cnt].qual_component[cnt3].orderable_type_flag = o
   .orderable_type_flag,
   reply->qual_pathway[path_cnt].qual_component[cnt3].med_order_type_cd = o.med_order_type_cd, reply
   ->qual_pathway[path_cnt].qual_component[cnt3].stop_type_cd = o.stop_type_cd, reply->qual_pathway[
   path_cnt].qual_component[cnt3].cs_flag = o.cs_flag,
   reply->qual_pathway[path_cnt].qual_component[cnt3].freq_type_flag = o.freq_type_flag, reply->
   qual_pathway[path_cnt].qual_component[cnt3].rx_mask = o.rx_mask, reply->qual_pathway[path_cnt].
   qual_component[cnt3].resume_effective_dt_tm = cnvtdatetime(o.resume_effective_dt_tm),
   reply->qual_pathway[path_cnt].qual_component[cnt3].suspend_effective_dt_tm = cnvtdatetime(o
    .suspend_effective_dt_tm)
   IF (o.template_order_id > 0)
    reply->qual_pathway[path_cnt].qual_component[cnt3].comment_type_mask = bor(o.comment_type_mask,
     band(ot.comment_type_mask,admin_note_mask)), reply->qual_pathway[path_cnt].qual_component[cnt3].
    comment_type_mask = bor(reply->qual_pathway[path_cnt].qual_component[cnt3].comment_type_mask,band
     (ot.comment_type_mask,mar_note_mask)), reply->qual_pathway[path_cnt].qual_component[cnt3].
    need_nurse_review_ind = ot.need_nurse_review_ind
   ELSE
    reply->qual_pathway[path_cnt].qual_component[cnt3].comment_type_mask = o.comment_type_mask, reply
    ->qual_pathway[path_cnt].qual_component[cnt3].need_nurse_review_ind = o.need_nurse_review_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (band(reply->qual_pathway[path_cnt].qual_component[cnt3].comment_type_mask,order_comment_mask)=
 order_comment_mask)
  SELECT INTO "nl:"
   FROM order_comment oc,
    long_text lt
   PLAN (oc
    WHERE (oc.order_id=reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id)
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
    reply->qual_pathway[path_cnt].qual_component[cnt3].order_comment_text = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM order_ingredient oi
  WHERE (oi.order_id=reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id)
   AND (oi.action_sequence=
  (SELECT
   max(oi2.action_sequence)
   FROM order_ingredient oi2
   WHERE oi2.order_id=oi.order_id))
   AND ((oi.ingredient_type_flag=1) OR (oi.ingredient_type_flag=3))
  ORDER BY oi.order_id
  HEAD oi.order_id
   add_cnt = 0
  DETAIL
   add_cnt = (add_cnt+ 1)
  FOOT  oi.order_id
   reply->qual_pathway[path_cnt].qual_component[cnt3].additive_cnt = add_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  apc.act_pw_comp_id
  FROM act_pw_comp apc
  WHERE (apc.parent_entity_id=reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id)
   AND apc.parent_entity_name="ORDERS"
   AND (apc.pathway_id != reply->qual_pathway[path_cnt].pathway_id)
  HEAD REPORT
   shrcnt = 0
  DETAIL
   shrcnt = (shrcnt+ 1), stat = alterlist(reply->qual_pathway[path_cnt].qual_component[cnt3].
    qual_shared_comp,shrcnt), reply->qual_pathway[path_cnt].qual_component[cnt3].qual_shared_comp[
   shrcnt].pathway_id = apc.pathway_id,
   reply->qual_pathway[path_cnt].qual_component[cnt3].qual_shared_comp[shrcnt].act_pw_comp_id = apc
   .act_pw_comp_id, reply->qual_pathway[path_cnt].qual_component[cnt3].qual_shared_comp[shrcnt].
   comp_status_cd = apc.comp_status_cd
  FOOT REPORT
   reply->qual_pathway[path_cnt].qual_component[cnt3].shared_comp_cnt = shrcnt
  WITH nocounter
 ;end select
#get_oroc_comp_end
#get_oroc_comp_ref
 SELECT INTO "nl:"
  pc.pathway_comp_id, pc.parent_entity_id, pc.order_sentence_id,
  ocs.synonym_id, ocs.catalog_cd, ocs.mnemonic,
  ocs.oe_format_id, os.order_sentence_id, os.order_sentence_display_line,
  osd.order_sentence_id, check = decode(ocs.seq,"o",os.seq,"s","z")
  FROM pathway_comp pc,
   order_catalog_synonym ocs,
   order_sentence os,
   order_sentence_detail osd,
   (dummyt d  WITH seq = 1)
  PLAN (pc
   WHERE (pc.pathway_comp_id=reply->qual_pathway[path_cnt].qual_component[cnt3].pathway_comp_id))
   JOIN (d)
   JOIN (((ocs
   WHERE ocs.synonym_id=pc.parent_entity_id)
   ) ORJOIN ((os
   WHERE os.order_sentence_id=pc.order_sentence_id)
   JOIN (osd
   WHERE osd.order_sentence_id=pc.order_sentence_id)
   ))
  HEAD REPORT
   osd_cnt = 0, reply->qual_pathway[path_cnt].qual_component[cnt3].orc_mnemonic = ocs.mnemonic, reply
   ->qual_pathway[path_cnt].qual_component[cnt3].synonym_id = pc.parent_entity_id,
   reply->qual_pathway[path_cnt].qual_component[cnt3].catalog_cd = ocs.catalog_cd, reply->
   qual_pathway[path_cnt].qual_component[cnt3].catalog_type_cd = ocs.catalog_type_cd, reply->
   qual_pathway[path_cnt].qual_component[cnt3].activity_type_cd = ocs.activity_type_cd,
   reply->qual_pathway[path_cnt].qual_component[cnt3].oe_format_id = ocs.oe_format_id, reply->
   qual_pathway[path_cnt].qual_component[cnt3].order_sentence_id = pc.order_sentence_id, reply->
   qual_pathway[path_cnt].qual_component[cnt3].dcp_clin_cat_cd = ocs.dcp_clin_cat_cd,
   reply->qual_pathway[path_cnt].qual_component[cnt3].orderable_type_flag = ocs.orderable_type_flag,
   reply->qual_pathway[path_cnt].qual_component[cnt3].ref_text_mask = ocs.ref_text_mask
  DETAIL
   IF (check="s")
    reply->qual_pathway[path_cnt].qual_component[cnt3].clinical_display_line = os
    .order_sentence_display_line, osd_cnt = (osd_cnt+ 1)
    IF (osd_cnt > size(reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail,5))
     stat = alterlist(reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail,(
      osd_cnt+ 5))
    ENDIF
    reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail[osd_cnt].sequence = osd
    .sequence, reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail[osd_cnt].
    order_sentence_id = osd.order_sentence_id, reply->qual_pathway[path_cnt].qual_component[cnt3].
    qual_sentence_detail[osd_cnt].oe_field_id = osd.oe_field_id,
    reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail[osd_cnt].oe_field_value
     = osd.oe_field_value, reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail[
    osd_cnt].oe_field_display_value = osd.oe_field_display_value, reply->qual_pathway[path_cnt].
    qual_component[cnt3].qual_sentence_detail[osd_cnt].oe_field_meaning_id = osd.oe_field_meaning_id,
    reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail[osd_cnt].
    oe_field_type_flag = osd.field_type_flag
    IF (osd.oe_field_meaning_id=duration_mean_id)
     reply->qual_pathway[path_cnt].qual_component[cnt3].duration_seq = osd_cnt
    ENDIF
    IF (osd.oe_field_meaning_id=duration_unit_mean_id)
     reply->qual_pathway[path_cnt].qual_component[cnt3].duration_unit_seq = osd_cnt
    ENDIF
    IF (osd.oe_field_meaning_id=frequency_mean_id)
     reply->qual_pathway[path_cnt].qual_component[cnt3].frequency_seq = osd_cnt
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET stat = alterlist(reply->qual_pathway[path_cnt].qual_component[cnt3].qual_sentence_detail,osd_cnt
  )
 SET reply->qual_pathway[path_cnt].qual_component[cnt3].sentence_detail_cnt = osd_cnt
#get_oroc_comp_ref_end
#get_task_comp
 SELECT INTO "nl:"
  ta.task_id, ot.reference_task_id
  FROM task_activity ta,
   order_task ot
  PLAN (ta
   WHERE (ta.task_id=reply->qual_pathway[path_cnt].qual_component[cnt3].parent_entity_id))
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
  DETAIL
   reply->qual_pathway[path_cnt].qual_component[cnt3].task_description = ot.task_description, reply->
   qual_pathway[path_cnt].qual_component[cnt3].task_status_cd = ta.task_status_cd
  WITH nocounter
 ;end select
#get_task_comp_end
#get_task_comp_ref
 SELECT INTO "nl:"
  ot.reference_task_id
  FROM order_task ot
  WHERE (ot.reference_task_id=reply->qual_pathway[path_cnt].qual_component[cnt3].ref_prnt_ent_id)
  DETAIL
   reply->qual_pathway[path_cnt].qual_component[cnt3].task_description = ot.task_description
  WITH nocounter
 ;end select
#get_task_comp_ref_end
#get_result_outcome_comp
 SELECT INTO "nl:"
  vec.event_cd
  FROM v500_event_code vec,
   v500_event_set_code vesc
  PLAN (vec
   WHERE (vec.event_cd=reply->qual_pathway[path_cnt].qual_component[cnt3].event_cd))
   JOIN (vesc
   WHERE cnvtupper(vesc.event_set_name)=cnvtupper(vec.event_set_name))
  HEAD REPORT
   reply->qual_pathway[path_cnt].qual_component[cnt3].event_set_disp = vesc.event_set_cd_disp
  WITH nocounter
 ;end select
 IF ((((reply->qual_pathway[path_cnt].qual_component[cnt3].result_type_cd=alpha_type_cd)) OR ((reply
 ->qual_pathway[path_cnt].qual_component[cnt3].result_type_cd=multi_type_cd))) )
  SET rrf_age_qty = reply->qual_pathway[path_cnt].qual_component[cnt3].rrf_age_qty
  SET rrf_age_units_mean = reply->qual_pathway[path_cnt].qual_component[cnt3].rrf_age_units_mean
  SET task_assay_cd = reply->qual_pathway[path_cnt].qual_component[cnt3].task_assay_cd
  SET rrf_sex_cd = reply->qual_pathway[path_cnt].qual_component[cnt3].rrf_sex_cd
  SET result_value = reply->qual_pathway[path_cnt].qual_component[cnt3].result_value
  SET outcome_value_descript = fillstring(255," ")
  SET count1 = 0
  SET rr_id = 0.00
  SET first_one = "Y"
  SET age_in_minutes = 0.0
  SET code_set = 226
  SET cdf_meaning = "HUMAN"
  EXECUTE cpm_get_cd_for_cdf
  SET human_type_cd = code_value
  IF (rrf_age_units_mean="HOURS")
   SET age_in_minutes = (rrf_age_qty * 60)
  ELSEIF (rrf_age_units_mean="DAYS")
   SET age_in_minutes = ((rrf_age_qty * 60) * 24)
  ELSEIF (rrf_age_units_mean="WEEKS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 7)
  ELSEIF (rrf_age_units_mean="MONTHS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 30)
  ELSEIF (rrf_age_units_mean="YEARS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 365.25)
  ENDIF
  SELECT INTO "nl:"
   r.reference_range_factor_id, a.reference_range_factor_id, a.nomenclature_id,
   a.description
   FROM reference_range_factor r,
    alpha_responses a,
    (dummyt d1  WITH seq = 1)
   PLAN (r
    WHERE r.task_assay_cd=task_assay_cd
     AND r.active_ind=1
     AND r.species_cd=human_type_cd
     AND r.organism_cd=0.00
     AND r.service_resource_cd=0.00
     AND r.gestational_ind=0
     AND r.unknown_age_ind=0
     AND ((r.sex_cd=rrf_sex_cd) OR (r.sex_cd=0.00))
     AND r.age_from_minutes <= age_in_minutes
     AND r.age_to_minutes >= age_in_minutes)
    JOIN (d1)
    JOIN (a
    WHERE a.reference_range_factor_id=r.reference_range_factor_id)
   ORDER BY r.sex_cd DESC, r.precedence_sequence, r.reference_range_factor_id
   HEAD REPORT
    rr_id = 0.00, first_one = "Y"
   HEAD r.reference_range_factor_id
    count1 = 0
    IF (first_one="Y")
     rr_id = r.reference_range_factor_id
    ENDIF
   DETAIL
    IF (((rr_id=r.reference_range_factor_id) OR (first_one="Y")) )
     first_one = "N"
     IF (a.reference_range_factor_id > 0)
      IF (a.result_value=result_value)
       count1 = (count1+ 1)
       IF (count1=1)
        outcome_value_descript = a.description
       ELSE
        outcome_value_descript = concat(trim(outcome_value_descript),", ",trim(a.description))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET reply->qual_pathway[path_cnt].qual_component[cnt3].outcome_value_descript = trim(
   outcome_value_descript)
 ENDIF
#get_result_outcome_comp_end
 GO TO exit_script
#exit_script
 SET echo = 0
 IF (echo=1)
  FOR (x = 1 TO reply->pathway_cnt)
    SET echo_label = build("pw",x," ")
    CALL echo(build(echo_label,"pathway_id: ",reply->qual_pathway[x].pathway_id))
    CALL echo(build(echo_label,"component_cnt: ",reply->qual_pathway[x].component_cnt))
    FOR (y = 1 TO reply->qual_pathway[x].component_cnt)
      SET comp_label = build("component-",y,"-")
      CALL echo(build(comp_label,"act_pw_comp_id: ",reply->qual_pathway[x].qual_component[y].
        act_pw_comp_id))
      CALL echo(build(comp_label,"sequence: ",reply->qual_pathway[x].qual_component[y].sequence))
      CALL echo(build(comp_label,"pathway_comp_id: ",reply->qual_pathway[x].qual_component[y].
        pathway_comp_id))
      CALL echo(build(comp_label,"act_time_frame_id: ",reply->qual_pathway[x].qual_component[y].
        act_time_frame_id))
      CALL echo(build(comp_label,"act_care_cat_id: ",reply->qual_pathway[x].qual_component[y].
        act_care_cat_id))
      CALL echo(build(comp_label,"comp_type_mean: ",reply->qual_pathway[x].qual_component[y].
        comp_type_mean))
      CALL echo(build(comp_label,"parent_entity_name: ",reply->qual_pathway[x].qual_component[y].
        parent_entity_name))
      CALL echo(build(comp_label,"parent_entity_id: ",reply->qual_pathway[x].qual_component[y].
        parent_entity_id))
      CALL echo(build(comp_label,"comp_label: ",reply->qual_pathway[x].qual_component[y].comp_label))
      CALL echo(build(comp_label,"comp_text: ",reply->qual_pathway[x].qual_component[y].comp_text))
      CALL echo(build(comp_label,"orc_mnemonic: ",reply->qual_pathway[x].qual_component[y].
        orc_mnemonic))
      CALL echo(build(comp_label,"hna_order_mnemonic: ",reply->qual_pathway[x].qual_component[y].
        hna_order_mnemonic))
      CALL echo(build(comp_label,"ordered_as_mnemonic: ",reply->qual_pathway[x].qual_component[y].
        ordered_as_mnemonic))
      CALL echo(build(comp_label,"order_mnemonic: ",reply->qual_pathway[x].qual_component[y].
        order_mnemonic))
      CALL echo(build(comp_label,"order_status_disp: ",reply->qual_pathway[x].qual_component[y].
        order_status_disp))
      CALL echo(build(comp_label,"task_description: ",reply->qual_pathway[x].qual_component[y].
        task_description))
      CALL echo(build(comp_label,"task_status_disp: ",reply->qual_pathway[x].qual_component[y].
        task_status_disp))
      CALL echo(build("sentence_detail_cnt: ",reply->qual_pathway[x].qual_component[y].
        sentence_detail_cnt))
      FOR (z = 1 TO size(reply->qual_pathway[x].qual_component[y].qual_sentence_detail,5))
        CALL echo(build("sequence: ",reply->qual_pathway[x].qual_component[y].qual_sentence_detail[z]
          .sequence))
        CALL echo(build("order_sentence_id: ",reply->qual_pathway[x].qual_component[y].
          qual_sentence_detail[z].order_sentence_id))
        CALL echo(build("oe_field_id: ",reply->qual_pathway[x].qual_component[y].
          qual_sentence_detail[z].oe_field_id))
        CALL echo(build("oe_field_value: ",reply->qual_pathway[x].qual_component[y].
          qual_sentence_detail[z].oe_field_value))
        CALL echo(build("oe_field_display_value: ",reply->qual_pathway[x].qual_component[y].
          qual_sentence_detail[z].oe_field_display_value))
      ENDFOR
      CALL echo(build("duration_seq: ",reply->qual_pathway[x].qual_component[y].duration_seq))
      CALL echo(build("duration_unit_seq: ",reply->qual_pathway[x].qual_component[y].
        duration_unit_seq))
      CALL echo(build("frequency_seq: ",reply->qual_pathway[x].qual_component[y].frequency_seq))
    ENDFOR
  ENDFOR
 ENDIF
END GO
