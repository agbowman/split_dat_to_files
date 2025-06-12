CREATE PROGRAM bhs_rpt_si_newrxwresp
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT DISTINCT INTO  $OUTDEV
  out_audit_id = sa.si_audit_id, out_message_ident = sa.msg_ident, out_create_date = format(sa
   .msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  in_outcome_create_date = format(sa1.msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), time_lapse =
  datetimediff(sa1.updt_dt_tm,sa.updt_dt_tm,5), out_action = sa.msg_trig_action_txt,
  in_outcome = sa1.msg_trig_action_txt, out_sender = sa.send_app_ident, out_receiver = sa
  .recv_app_ident,
  in_sender = sa1.send_app_ident, in_receiver = sa1.recv_app_ident, org = org.org_name,
  ord_provider = prsnl.name_full_formatted, patient = p.name_full_formatted, order_mnemonic = o
  .ordered_as_mnemonic,
  ord_detail = o.clinical_display_line, order_date = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  in_refer_to_msg_id = sa1.refer_to_msg_ident,
  out_status = uar_get_code_display(sa.status_cd), out_sys_direction = uar_get_code_display(sa
   .sys_direction_cd), in_sys_direction = uar_get_code_display(sa1.sys_direction_cd),
  org_provider_id = prsnl.person_id, org_id = org.organization_id, patient_id = p.person_id
  FROM si_audit sa,
   si_audit sa1,
   prsnl prsnl,
   prsnl_alias pa,
   orders o,
   person p,
   encounter e,
   organization org,
   dummyt d1
  PLAN (sa
   WHERE sa.msg_trig_action_txt IN ("NEWRX")
    AND sa.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND sa.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (pa
   WHERE sa.send_app_ident=pa.alias)
   JOIN (prsnl
   WHERE prsnl.person_id=pa.person_id)
   JOIN (o
   WHERE o.order_id=sa.parent_entity_id)
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (org
   WHERE e.organization_id=org.organization_id)
   JOIN (d1)
   JOIN (sa1
   WHERE sa.msg_ident=sa1.refer_to_msg_ident)
  ORDER BY sa.msg_creation_dt_tm
  WITH outerjoin = d1, nocounter, format,
   separator = " "
 ;end select
END GO
