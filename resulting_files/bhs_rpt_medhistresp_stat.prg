CREATE PROGRAM bhs_rpt_medhistresp_stat
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  request_date = format(et.beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;d"), response_date = format(sa
   .msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), request_eem = et.transaction_meaning,
  response_sa = sa.msg_trig_action_txt, eem_poll_expire = format(et.poll_expire_dt_tm,
   "MM/DD/YYYY HH:MM;;d"), eem_data_expire = format(et.data_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  eem_trans_cd = uar_get_code_display(et.transaction_cd), eem_trans_status = uar_get_code_display(et
   .trans_status_cd), eem_trans_data = uar_get_code_display(et.trans_data_cd),
  sa_error = sa.error_text, spi = sa.recv_app_ident, sa_refer_message_ident = sa.refer_to_msg_ident,
  sa_message_id = sa.msg_ident, eem_id = et.interchange_id
  FROM eem_transaction et,
   si_audit sa
  PLAN (et
   WHERE et.beg_effective_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND et.beg_effective_dt_tm < cnvtdatetime( $END_DATE)
    AND et.transaction_meaning="MED_HIST_RX")
   JOIN (sa
   WHERE sa.refer_to_msg_ident=concat("RXHREQ",trim(cnvtstring(et.interchange_id))))
  ORDER BY request_date DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
