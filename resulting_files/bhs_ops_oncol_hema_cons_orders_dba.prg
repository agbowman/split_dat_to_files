CREATE PROGRAM bhs_ops_oncol_hema_cons_orders:dba
 EXECUTE bhs_ma_email_file
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE mf_onco_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTONCOLOGYADULT"))
 DECLARE mf_hema_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTHEMATOLOGYADULT"))
 DECLARE mf_alias_acct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_alias_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_action_new_ord_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ms_field_sep = vc WITH protect, constant(",")
 DECLARE ms_rundate = vc WITH protect, constant(format(curdate,"mm-dd-yy;;d"))
 DECLARE ms_file_name = vc WITH protect, constant(concat("hema_oncol_cons_rpt_",ms_rundate,".csv"))
 DECLARE ms_eml_subject = vc WITH protect, constant(concat(
   "Hematology and Oncology Consults Report - ",ms_rundate))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_ops_oncol_hema_cons_orders/"))
 DECLARE ms_output = vc WITH protect, constant(build(ms_loc_dir,ms_file_name))
 DECLARE ms_recipients = vc WITH protect, noconstant("")
 SET frec->file_name = ms_output
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="BHS_OPS_ONCOL_HEMA_CONS_ORDERS")
  DETAIL
   ms_recipients = d.info_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   encounter e,
   encntr_alias a,
   encntr_alias m,
   person p,
   prsnl op
  PLAN (o
   WHERE o.active_ind=1
    AND o.orig_order_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(curdate,curtime),- (31.0)))
    AND o.orig_order_dt_tm <= cnvtdatetime(curdate,curtime)
    AND o.catalog_cd IN (mf_onco_consult_cd, mf_hema_consult_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_action_new_ord_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
   JOIN (a
   WHERE e.encntr_id=a.encntr_id
    AND a.encntr_alias_type_cd=mf_alias_acct_cd)
   JOIN (m
   WHERE e.encntr_id=m.encntr_id
    AND m.encntr_alias_type_cd=mf_alias_mrn_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (op
   WHERE oa.order_provider_id=op.person_id)
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   frec->file_buf = concat('"',"Registration Date/Time",'"',ms_field_sep,'"',
    "Account",'"',ms_field_sep,'"',"MRN",
    '"',ms_field_sep,'"',"Full Name",'"',
    ms_field_sep,'"',"Order Date/Time",'"',ms_field_sep,
    '"',"Order Mnemonic",'"',ms_field_sep,'"',
    "Reason",'"',ms_field_sep,'"',"Ordering Provider",
    '"',ms_field_sep,'"',"Encounter ID",'"',
    ms_field_sep,'"',"Order ID",'"',ms_field_sep,
    '"',"Catalog CD",'"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
  DETAIL
   row + 1, frec->file_buf = concat('"',trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3),'"',
    ms_field_sep,'"',
    trim(cnvtstring(a.alias),3),'"',ms_field_sep,'"',trim(cnvtstring(m.alias),3),
    '"',ms_field_sep,'"',trim(p.name_full_formatted,3),'"',
    ms_field_sep,'"',trim(format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"),3),'"',ms_field_sep,
    '"',trim(o.order_mnemonic,3),'"',ms_field_sep,'"',
    trim(o.clinical_display_line,3),'"',ms_field_sep,'"',trim(op.name_full_formatted,3),
    '"',ms_field_sep,'"',trim(cnvtstring(e.encntr_id),3),'"',
    ms_field_sep,'"',trim(cnvtstring(o.order_id),3),'"',ms_field_sep,
    '"',trim(cnvtstring(o.catalog_cd),3),'"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
  WITH nocounter
 ;end select
 SET stat = cclio("CLOSE",frec)
 CALL emailfile(ms_output,ms_output,ms_recipients,ms_eml_subject,0)
#exit_script
END GO
