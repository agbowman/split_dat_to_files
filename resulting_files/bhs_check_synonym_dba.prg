CREATE PROGRAM bhs_check_synonym:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  o.active_ind, o_active_status_disp = uar_get_code_display(o.active_status_cd), o
  .active_status_dt_tm,
  o.active_status_prsnl_id, o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o
  .ad_hoc_order_flag,
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o_catalog_type_disp = uar_get_code_display(o
   .catalog_type_cd), o.cki,
  o.clinical_display_line, o.comment_type_mask, o.constant_ind,
  o_contributor_system_disp = uar_get_code_display(o.contributor_system_cd), o.cs_flag, o.cs_order_id,
  o.current_start_dt_tm, o.current_start_tz, o_dcp_clin_cat_disp = uar_get_code_display(o
   .dcp_clin_cat_cd),
  o.dept_misc_line, o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o
  .discontinue_effective_dt_tm,
  o.discontinue_effective_tz, o.discontinue_ind, o_discontinue_type_disp = uar_get_code_display(o
   .discontinue_type_cd),
  o.encntr_financial_id, o.encntr_id, o.eso_new_order_ind,
  o.frequency_id, o.freq_type_flag, o.group_order_flag,
  o.group_order_id, o.hide_flag, o.hna_order_mnemonic,
  o.incomplete_order_ind, o.ingredient_ind, o.interest_dt_tm,
  o.interval_ind, o.iv_ind, o.last_action_sequence,
  o.last_core_action_sequence, o.last_ingred_action_sequence, o.last_update_provider_id,
  o.link_nbr, o.link_order_flag, o.link_order_id,
  o.link_type_flag, o_med_order_type_disp = uar_get_code_display(o.med_order_type_cd), o
  .modified_start_dt_tm,
  o.need_doctor_cosign_ind, o.need_nurse_review_ind, o.need_physician_validate_ind,
  o.need_rx_verify_ind, o.oe_format_id, o.orderable_type_flag,
  o.ordered_as_mnemonic, o.order_comment_ind, o.order_detail_display_line,
  o.order_id, o.order_mnemonic, o_order_status_disp = uar_get_code_display(o.order_status_cd),
  o.orig_order_convs_seq, o.orig_order_dt_tm, o.orig_order_tz,
  o.orig_ord_as_flag, o.override_flag, o.pathway_catalog_id,
  o.person_id, o.prn_ind, o.product_id,
  o.projected_stop_dt_tm, o.projected_stop_tz, o.ref_text_mask,
  o.remaining_dose_cnt, o.resume_effective_dt_tm, o.resume_effective_tz,
  o.resume_ind, o.rowid, o.rx_mask,
  o_sch_state_disp = uar_get_code_display(o.sch_state_cd), o.soft_stop_dt_tm, o.soft_stop_tz,
  o.status_dt_tm, o.status_prsnl_id, o_stop_type_disp = uar_get_code_display(o.stop_type_cd),
  o.suspend_effective_dt_tm, o.suspend_effective_tz, o.suspend_ind,
  o.synonym_id, o.template_core_action_sequence, o.template_order_flag,
  o.template_order_id, o.updt_applctx, o.updt_cnt,
  o.updt_dt_tm, o.updt_id, o.updt_task,
  o.valid_dose_dt_tm
  FROM orders o
  WHERE o.synonym_id=1864228.00
   AND o.catalog_cd=782408
  WITH nocounter, separator = " ", format
 ;end select
END GO
