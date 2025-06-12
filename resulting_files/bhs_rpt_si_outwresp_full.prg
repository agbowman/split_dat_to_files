CREATE PROGRAM bhs_rpt_si_outwresp_full
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  si_send_create_date = format(sa.msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), si_receive_create_date
   = format(sa2.msg_creation_dt_tm,"MM/DD/YYYY HH:MM;;d"), time_lapse = datetimediff(sa2.updt_dt_tm,
   sa.updt_dt_tm,5),
  si_send_action = sa.msg_trig_action_txt, si_send_status = uar_get_code_display(sa.status_cd),
  si_receive_action = sa2.msg_trig_action_txt,
  si_receive_status = uar_get_code_display(sa2.status_cd), si_send_parent_name = sa
  .parent_entity_name, si_send_parent_id = sa.parent_entity_id,
  si_send_audit_id = sa.si_audit_id, si_receive_audit_id = sa2.si_audit_id, si_send_message_ident =
  sa.msg_ident,
  si_receive_message_ident = sa2.msg_ident, si_send_refer_message_ident = sa.refer_to_msg_ident,
  si_receive_refer_message_ident = sa2.refer_to_msg_ident,
  si_send_error = sa.error_text, si_receive_error = sa2.error_text, si_send_sys_direction =
  uar_get_code_display(sa.sys_direction_cd),
  si_receive_sys_direction = uar_get_code_display(sa2.sys_direction_cd), si_send_sender = sa
  .send_app_ident, si_send_receive = sa.recv_app_ident,
  si_receive_sender = sa2.send_app_ident, si_receive_receive = sa2.recv_app_ident
  FROM si_audit sa,
   si_audit sa2,
   dummyt d1
  PLAN (sa
   WHERE sa.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND sa.updt_dt_tm < cnvtdatetime( $END_DATE)
    AND sa.si_audit_id != 0
    AND sa.msg_trig_action_txt IN ("NEWRX", "REFRES"))
   JOIN (d1)
   JOIN (sa2
   WHERE sa2.refer_to_msg_ident=sa.msg_ident
    AND ((sa2.msg_trig_action_txt IN ("STATUS")) OR (sa2.msg_trig_action_txt IN ("ERROR"))) )
  ORDER BY sa.msg_creation_dt_tm DESC
  WITH outerjoin = d1, format, separator = " "
 ;end select
END GO
