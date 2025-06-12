CREATE PROGRAM bhs_rpt_ppid_detail_w_pt_info:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg_time" = "SYSDATE",
  "end_time" = "SYSDATE"
  WITH outdev, beg_time, end_time
 SELECT INTO  $OUTDEV
  fin = ea.alias, o.order_id, o.order_mnemonic,
  o.order_detail_display_line, schedule_dt_tim = format(maa.scheduled_dt_tm,";;Q"), admin_date_time
   = format(maa.admin_dt_tm,";;Q"),
  reason = uar_get_code_display(maa.reason_cd), alert = uar_get_code_display(mad.alert_type_cd)
  FROM med_admin_med_error maa,
   orders o,
   encntr_alias ea,
   med_admin_alert mad
  PLAN (maa
   WHERE maa.admin_dt_tm BETWEEN cnvtdatetime( $BEG_TIME) AND cnvtdatetime( $END_TIME))
   JOIN (ea
   WHERE ea.encntr_id=maa.encounter_id
    AND ea.encntr_alias_type_cd=1077)
   JOIN (o
   WHERE o.order_id=maa.order_id)
   JOIN (mad
   WHERE mad.med_admin_alert_id=maa.med_admin_alert_id)
  WITH separator = " ", format, time = 300,
   macrec = 100000
 ;end select
END GO
