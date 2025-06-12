CREATE PROGRAM dfr_order_test:dba
 SELECT DISTINCT
  o.active_status_cd, o_active_status_disp = uar_get_code_display(o.active_status_cd), o.catalog_cd,
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o.clinical_display_line, o.order_id,
  o.ordered_as_mnemonic, o.orig_order_dt_tm"@SHORTDATETIME", o.last_action_sequence,
  oa.action_sequence, od.action_sequence, oa.action_dt_tm"@SHORTDATETIME",
  oa.action_type_cd, oa_action_type_disp = uar_get_code_display(oa.action_type_cd), oa
  .communication_type_cd,
  oa_communication_type_disp = uar_get_code_display(oa.communication_type_cd), oa.dept_status_cd,
  oa_dept_status_disp = uar_get_code_display(oa.dept_status_cd),
  oa.order_status_cd, oa_order_status_disp = uar_get_code_display(oa.order_status_cd), oa.updt_dt_tm
  "@SHORTDATETIME",
  od.detail_sequence, od.oe_field_display_value, od.oe_field_dt_tm_value,
  od.oe_field_id, od.oe_field_meaning, od.oe_field_meaning_id,
  od.oe_field_tz, od.oe_field_value, od.order_id,
  od.parent_action_sequence, od.updt_applctx, od.updt_cnt,
  od.updt_dt_tm, od.updt_id, od.updt_task,
  cv.display, cv.code_value, cv.display_key,
  ofo.accept_flag, ofo.action_type_cd, ofo_action_type_disp = uar_get_code_display(ofo.action_type_cd
   ),
  ofo.clin_line_ind, ofo.clin_line_label, ofo.clin_suffix_ind,
  ofo.core_ind, ofo.def_prev_order_ind, ofo.default_parent_entity_id,
  ofo.default_parent_entity_name, ofo.default_value, ofo.dept_line_ind,
  ofo.dept_line_label, ofo.dept_suffix_ind, ofo.disp_dept_yes_no_flag,
  ofo.disp_yes_no_flag, ofo.epilog_method, ofo.field_seq,
  ofo.filter_params, ofo.group_seq, ofo.input_mask,
  ofo.label_text, ofo.max_nbr_occur, ofo.oe_field_id,
  ofo.oe_format_id, ofo.prolog_method, ofo.require_cosign_ind,
  ofo.require_review_ind, ofo.require_verify_ind, ofo.status_line,
  ofo.updt_applctx, ofo.updt_cnt, ofo.updt_dt_tm,
  ofo.updt_id, ofo.updt_task, ofo.value_required_ind
  FROM orders o,
   order_action oa,
   order_detail od,
   code_value cv,
   oe_format_fields ofo
  PLAN (o
   WHERE o.person_id IN (763730, 858241)
    AND o.encntr_id IN (1135587, 2443872)
    AND o.template_order_id=0
    AND o.status_dt_tm BETWEEN cnvtdatetime((curdate - 2),0000) AND cnvtdatetime(curdate,curtime3)
    AND o.order_status_cd IN (2550, 2549, 643466, 2551, 2548,
   2546)
    AND o.cs_flag=0
    AND o.order_id=3346382)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd IN (2533, 2534, 2535))
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.oe_field_id != 12731)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=16449
    AND cv.cdf_meaning="DETAIL"
    AND cv.code_value=od.oe_field_id)
   JOIN (ofo
   WHERE ofo.oe_field_id=od.oe_field_id
    AND ofo.accept_flag IN (0, 1)
    AND ofo.oe_format_id=o.oe_format_id)
  ORDER BY o.order_id DESC, oa.action_sequence, oa.action_type_cd,
   od.detail_sequence, od.oe_field_id
  WITH check
 ;end select
END GO
