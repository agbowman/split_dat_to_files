CREATE PROGRAM bhs_rpt_si_direct
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  si_audit_id = sa.si_audit_id, si_message_ident = sa.msg_ident, si_refer_message_ident = sa
  .refer_to_msg_ident,
  si_create_date = format(sa.msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), si_action = sa
  .msg_trig_action_txt, si_status = uar_get_code_display(sa.status_cd),
  si_error = sa.error_text, si_sys_direction = uar_get_code_display(sa.sys_direction_cd), si_send =
  sa.send_app_ident,
  si_receive = sa.recv_app_ident, si_send_parent_name = sa.parent_entity_name, si_send_parent_id = sa
  .parent_entity_id
  FROM si_audit sa
  PLAN (sa
   WHERE sa.si_audit_id != 0
    AND sa.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND sa.updt_dt_tm < cnvtdatetime( $END_DATE))
  ORDER BY sa.updt_dt_tm
  WITH nocounter, format, separator = " "
 ;end select
END GO
