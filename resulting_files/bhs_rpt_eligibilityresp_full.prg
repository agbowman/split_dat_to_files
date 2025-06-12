CREATE PROGRAM bhs_rpt_eligibilityresp_full
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  triggering_user = substring(1,40,prsnl1.name_full_formatted), provider_spi_used = substring(1,40,
   prsnl2.name_full_formatted), organization = org.org_name,
  person_name = p.name_full_formatted, trans_cd = uar_get_code_display(et.transaction_cd),
  trans_meaning = et.transaction_meaning,
  send_dt_tm = format(eed.sent_dt_tm,"MM/DD/YYYY HH:MM;;d"), reply_dt_tm = format(eed.reply_dt_tm,
   "MM/DD/YYYY HH:MM;;d"), query_time_sec = datetimediff(eed.reply_dt_tm,eed.sent_dt_tm,5),
  trans_status = uar_get_code_display(et.trans_status_cd), trans_data = uar_get_code_display(et
   .trans_data_cd), begin_date = format(et.beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  poll_expire = format(et.poll_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), data_expire = format(et
   .data_expire_dt_tm,"MM/DD/YYYY HH:MM;;d"), send_system = uar_get_code_display(eed
   .contributor_system_cd),
  send_ln = eed.ob_last_name, send_fn = eed.ob_first_name, send_dob = eed.ob_birth_dt_tm_txt,
  send_gender = uar_get_code_display(eed.ob_gender_cd), send_zip = eed.ob_postal_code, receive_ln =
  eed.ib_last_name,
  receive_fn = eed.ib_first_name, receive_mi = eed.ib_middle_name, receive_dob = eed
  .ib_birth_dt_tm_txt,
  receive_gender = uar_get_code_display(eed.ib_gender_cd), receive_address = eed.ib_address_line_1,
  receive_city = eed.ib_city,
  receive_state = eed.ib_state, receive_zip = eed.ib_postal_code, receive_rx_plan_admin_ident = eed
  .plan_admin_ident,
  receive_rx_plan_name = eed.prescription_plan_name, receive_cardholder_ident = eed.cardholder_ident,
  receive_cardholder_name = eed.cardholder_name,
  receive_rx_plan_ident = eed.prescription_plan_ident, receive_group_ident = eed.group_ident,
  receive_formulary_list_key = eed.formulary_list_key,
  receive_formulary_alt_list_key = eed.formulary_alt_list_key, receive_copay_list_key = eed
  .copay_list_key, receive_coverage_list_key = eed.coverage_list_key,
  interchange_id = et.interchange_id
  FROM eem_transaction et,
   eem_rx_elig_detail eed,
   prsnl prsnl1,
   prsnl prsnl2,
   organization org,
   person p
  PLAN (et
   WHERE et.beg_effective_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND et.beg_effective_dt_tm < cnvtdatetime( $END_DATE)
    AND et.transaction_meaning="ELIG_RX")
   JOIN (eed
   WHERE et.interchange_id=eed.interchange_id)
   JOIN (p
   WHERE eed.person_id=p.person_id)
   JOIN (prsnl1
   WHERE eed.sender_prsnl_id=prsnl1.person_id)
   JOIN (prsnl2
   WHERE eed.prescriber_prsnl_id=prsnl2.person_id)
   JOIN (org
   WHERE eed.organization_id=org.organization_id)
  ORDER BY eed.sent_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
