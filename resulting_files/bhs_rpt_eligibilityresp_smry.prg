CREATE PROGRAM bhs_rpt_eligibilityresp_smry
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  person_name = p.name_full_formatted, trans_cd = uar_get_code_display(et.transaction_cd),
  trans_status = uar_get_code_display(et.trans_status_cd),
  trans_meaning = et.transaction_meaning, send_dt_tm = format(eed.sent_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  reply_dt_tm = format(eed.reply_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  query_time_sec = datetimediff(eed.reply_dt_tm,eed.sent_dt_tm,5), trans_data = uar_get_code_display(
   et.trans_data_cd), begin_date = format(et.beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  poll_expire = format(et.poll_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), data_expire = format(et
   .data_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), interchange_id = et.interchange_id
  FROM eem_transaction et,
   eem_rx_elig_detail eed,
   person p
  PLAN (et
   WHERE et.beg_effective_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND et.beg_effective_dt_tm < cnvtdatetime( $END_DATE)
    AND et.transaction_meaning="ELIG_RX")
   JOIN (eed
   WHERE et.interchange_id=eed.interchange_id)
   JOIN (p
   WHERE eed.person_id=p.person_id)
  ORDER BY eed.sent_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
