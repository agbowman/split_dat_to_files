CREATE PROGRAM bhs_rpt_msg_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  type = sa.msg_trig_action_txt, pharmacy_id = ma.pharmacy_identifier, ma_rx_id = ma.rx_identifier,
  ma_status_cd = uar_get_code_display(ma.status_cd), ma_error_cd = uar_get_code_display(ma.error_cd),
  ma_audit_cd = uar_get_code_display(ma.audit_type_cd),
  order_id = ma.order_id, person_id = ma.person_id, ord_provider = p.name_full_formatted,
  update_dt_tm = format(ma.updt_dt_tm,"MM/DD/YYYY HH:MM;;d"), prsnl_id = p.person_id, sa_message_id
   = sa.msg_ident,
  sa_entity_name = sa.parent_entity_name, sa_order_id = sa.parent_entity_id, message_text = lt
  .long_text
  FROM messaging_audit ma,
   si_audit sa,
   prsnl p,
   long_text lt
  PLAN (ma
   WHERE ma.status_cd != 0
    AND ma.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ma.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (sa
   WHERE sa.msg_ident=ma.rx_identifier)
   JOIN (p
   WHERE p.person_id=ma.ordering_phys_id)
   JOIN (lt
   WHERE ma.msg_text_id=lt.long_text_id)
  ORDER BY ma.updt_dt_tm DESC, ma.rx_identifier
  WITH nocounter, format, separator = " "
 ;end select
END GO
