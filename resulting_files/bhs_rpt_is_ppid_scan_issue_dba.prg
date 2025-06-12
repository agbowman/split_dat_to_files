CREATE PROGRAM bhs_rpt_is_ppid_scan_issue:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg_time" = "SYSDATE",
  "end_time" = "SYSDATE"
  WITH outdev, beg_time, end_time
 SELECT DISTINCT INTO  $1
  maa.event_dt_tm, alert_type = uar_get_code_display(maa.alert_type_cd), username = p
  .name_full_formatted,
  patient = pe.name_full_formatted, fin = e.alias, maa_nurse_unit_disp = uar_get_code_display(maa
   .nurse_unit_cd),
  scan_item = m.bar_code_ident
  FROM med_admin_alert maa,
   med_admin_ident_error m,
   med_admin_med_error ma,
   prsnl p,
   person pe,
   encntr_alias e
  PLAN (maa
   WHERE maa.alert_type_cd=64095391.00
    AND maa.event_dt_tm BETWEEN cnvtdatetime(curdate,080000) AND cnvtdatetime(curdate,100000))
   JOIN (m
   WHERE m.prsnl_id=maa.prsnl_id
    AND m.alert_type_cd=maa.alert_type_cd
    AND maa.event_dt_tm=m.event_dt_tm)
   JOIN (ma
   WHERE ma.med_admin_alert_id=maa.med_admin_alert_id)
   JOIN (p
   WHERE p.person_id=m.prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ma.encounter_id
    AND e.encntr_alias_type_cd=1077)
   JOIN (pe
   WHERE pe.person_id=ma.person_id)
  WITH separator = " ", format, time = 300,
   macrec = 100000
 ;end select
END GO
