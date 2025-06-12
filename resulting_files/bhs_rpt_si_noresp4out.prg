CREATE PROGRAM bhs_rpt_si_noresp4out
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT DISTINCT INTO  $OUTDEV
  si_send_create_date = format(sa.msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), si_send_action = sa
  .msg_trig_action_txt, si_send_status = uar_get_code_display(sa.status_cd),
  si_send_parent_name = sa.parent_entity_name, si_send_parent_id = sa.parent_entity_id,
  si_send_audit_id = sa.si_audit_id,
  si_send_message_ident = sa.msg_ident, si_send_error = sa.error_text, si_send_sys_direction =
  uar_get_code_display(sa.sys_direction_cd),
  si_send_sender = sa.send_app_ident, si_send_receive = sa.recv_app_ident
  FROM si_audit sa
  PLAN (sa
   WHERE sa.si_audit_id != 0
    AND sa.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND sa.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND sa.updt_dt_tm < cnvtdatetime( $END_DATE)
    AND  NOT ( EXISTS (
   (SELECT
    sa2.refer_to_msg_ident
    FROM si_audit sa2
    WHERE sa.msg_ident=sa2.refer_to_msg_ident))))
  ORDER BY sa.msg_creation_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
END GO
