CREATE PROGRAM bhs_rpt_si_norespwpat4out
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT DISTINCT INTO  $OUTDEV
  org_name = org.org_name, provider = prsnl.name_full_formatted, erx_send_create_date = format(sa
   .msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  erx_send_action = sa.msg_trig_action_txt, patient = p.name_full_formatted, medication = o
  .ordered_as_mnemonic,
  med_details = o.clinical_display_line, erx_send_message_ident = sa.msg_ident, erx_send_error = sa
  .error_text,
  erx_send_sender_id = sa.send_app_ident, erx_send_order_id = sa.parent_entity_id
  FROM si_audit sa,
   orders o,
   prsnl prsnl,
   person p,
   order_action oa,
   organization org,
   encounter e
  PLAN (sa
   WHERE sa.si_audit_id != 0
    AND sa.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND sa.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND sa.updt_dt_tm < cnvtdatetime( $END_DATE)
    AND sa.parent_entity_name="ORDERS"
    AND  NOT ( EXISTS (
   (SELECT
    sa2.refer_to_msg_ident
    FROM si_audit sa2
    WHERE sa.msg_ident=sa2.refer_to_msg_ident))))
   JOIN (o
   WHERE sa.parent_entity_id=o.order_id)
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd IN (2550))
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (prsnl
   WHERE prsnl.person_id=oa.order_provider_id)
   JOIN (org
   WHERE e.organization_id=org.organization_id)
  ORDER BY sa.msg_creation_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
