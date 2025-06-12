CREATE PROGRAM bhs_rpt_ppid_scan_issue:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg_time" = "SYSDATE",
  "end_time" = "SYSDATE"
  WITH outdev, beg_time, end_time
 SELECT INTO  $OUTDEV
  user_name = p.name_full_formatted, alert_reason = uar_get_code_display(maa.alert_type_cd),
  scan_item = trim(maa.bar_code_ident),
  murse_unit = uar_get_code_display(maa.nurse_unit_cd), action_date_time = format(maa.event_dt_tm,
   ";;Q"), maa.med_admin_ident_error_id
  FROM med_admin_ident_error maa,
   prsnl p
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime( $BEG_TIME) AND cnvtdatetime( $END_TIME))
   JOIN (p
   WHERE maa.prsnl_id=p.person_id)
  WITH separator = " ", format, time = 300,
   macrec = 100000
 ;end select
END GO
