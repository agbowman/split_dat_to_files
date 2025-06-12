CREATE PROGRAM bhs_rpt_medhistresp_smry
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  person_name = p.name_full_formatted, trans_cd = uar_get_code_display(et.transaction_cd),
  trans_status = uar_get_code_display(emd.trans_data_cd),
  trans_meaning = et.transaction_meaning, response_cd = uar_get_code_display(emd.response_cd),
  send_dt_tm = format(emd.sent_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  reply_dt_tm = format(emd.reply_dt_tm,"MM/DD/YYYY HH:MM;;d"), query_time_sec = datetimediff(emd
   .reply_dt_tm,emd.sent_dt_tm,5), begin_date = format(et.beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  poll_expire = format(et.poll_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), data_expire = format(et
   .data_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), interchange_id = et.interchange_id
  FROM eem_transaction et,
   eem_rx_med_hist_detail emd,
   person p
  PLAN (et
   WHERE et.beg_effective_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND et.beg_effective_dt_tm < cnvtdatetime( $END_DATE)
    AND et.transaction_meaning="MED_HIST_RX")
   JOIN (emd
   WHERE et.interchange_id=emd.interchange_id)
   JOIN (p
   WHERE emd.person_id=p.person_id)
  ORDER BY emd.sent_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
