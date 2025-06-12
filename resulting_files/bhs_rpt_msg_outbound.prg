CREATE PROGRAM bhs_rpt_msg_outbound
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  pharmacy = od.oe_field_display_value, type = sa.msg_trig_action_txt, pharmacy_id = ma
  .pharmacy_identifier,
  ma_rx_id = ma.rx_identifier, ma_status_cd = uar_get_code_display(ma.status_cd), ma_error_cd =
  uar_get_code_display(ma.error_cd),
  patient = o.person_id, encounter = o.encntr_id, ord_provider = p.name_full_formatted,
  org = org.org_name, order_date = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"), order_mnemonic
   = o.ordered_as_mnemonic,
  ord_detail = o.clinical_display_line, lt_message = substring(1,300,lt.long_text), ma_updt_dt_tm =
  format(ma.updt_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  encounter_id = o.encntr_id, order_id = o.order_id, prsnl_id = p.person_id
  FROM messaging_audit ma,
   si_audit sa,
   prsnl p,
   organization org,
   order_detail od,
   orders o,
   long_text lt,
   dummyt d1,
   dummyt d2,
   dummyt d3
  PLAN (ma
   WHERE ma.status_cd != 0
    AND ma.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ma.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (sa
   WHERE sa.msg_ident=ma.rx_identifier)
   JOIN (p
   WHERE p.person_id=ma.ordering_phys_id)
   JOIN (org
   WHERE org.organization_id=ma.org_id)
   JOIN (d1)
   JOIN (lt
   WHERE lt.long_text_id=ma.msg_text_id)
   JOIN (d2)
   JOIN (o
   WHERE o.order_id=ma.order_id)
   JOIN (d3)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="ROUTINGPHARMACYNAME")
  ORDER BY ma.updt_dt_tm DESC, ma.rx_identifier, lt.long_text DESC
  WITH format, outerjoin = d1, d2,
   d3, nocounter, separator = " "
 ;end select
END GO
