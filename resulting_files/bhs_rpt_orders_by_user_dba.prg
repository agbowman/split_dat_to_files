CREATE PROGRAM bhs_rpt_orders_by_user:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Select position(s):" = 0,
  "Select users:" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  f_position_cd, f_prsnl_id
 DECLARE mf_radiology_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,
   "RADIOLOGY"))
 DECLARE mf_ct_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"CT"))
 DECLARE mf_mr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"MR"))
 DECLARE mf_nm_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"NM"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
 SET ms_end_dt_tm = concat( $S_END_DT," 23:59:59")
 SELECT INTO  $OUTDEV
  catalog_type = uar_get_code_display(oc.catalog_type_cd), modality = uar_get_code_display(oc
   .activity_subtype_cd), order_date = o.orig_order_dt_tm,
  o.order_mnemonic, o.clinical_display_line, powerplan_catalog_id = o.pathway_catalog_id,
  powerplan_name = pw.description, ordering_doc = p.name_full_formatted, fin = ea.alias
  FROM order_action oa,
   orders o,
   order_catalog oc,
   prsnl p,
   encntr_alias ea,
   pathway_catalog pw
  PLAN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND oa.action_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND (oa.order_provider_id= $F_PRSNL_ID)
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.catalog_type_cd=mf_radiology_cat_type_cd
    AND o.template_order_id=0)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd
    AND oc.active_ind > 0
    AND oc.activity_subtype_cd IN (mf_ct_cd, mf_mr_cd, mf_nm_cd))
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR")))
   JOIN (pw
   WHERE (pw.pathway_catalog_id= Outerjoin(o.pathway_catalog_id)) )
  ORDER BY p.person_id, o.orig_order_dt_tm DESC
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
