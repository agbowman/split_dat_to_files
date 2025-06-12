CREATE PROGRAM bhs_rpt_msg_errinmsgcntr_dir
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 DECLARE rxmessage_cv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"RXMESSAGE"))
 SELECT INTO  $OUTDEV
  msg_created = format(ta.task_create_dt_tm,"MM/DD/YYYY HH:MM;;d"), msg_subject = ta.msg_subject,
  msg_text = lt.long_text,
  msg_status = uar_get_code_display(ta.task_status_cd), msg_event_cd = ta.event_cd, msg_sender_id =
  ta.msg_sender_id,
  patient_id = ta.person_id, encounter_id = ta.encntr_id, order_id = ta.order_id
  FROM task_activity ta,
   long_text lt
  PLAN (ta
   WHERE ta.task_type_cd=rxmessage_cv
    AND ta.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ta.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (lt
   WHERE ta.msg_text_id=lt.long_text_id)
  ORDER BY msg_created
  WITH nocounter, format, separator = " "
 ;end select
END GO
