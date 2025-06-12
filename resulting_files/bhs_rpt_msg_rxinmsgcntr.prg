CREATE PROGRAM bhs_rpt_msg_rxinmsgcntr
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 DECLARE rxmessage_cv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"RXMESSAGE"))
 SELECT INTO  $OUTDEV
  msg_created = format(ta.task_create_dt_tm,"MM/DD/YYYY HH:MM;;d"), msg_sender_id = ta.msg_sender_id,
  task_type = uar_get_code_display(ta.task_type_cd),
  patient_id = ta.person_id, encounter_id = ta.encntr_id, order_id = ta.order_id,
  originating_inbox = prsnl.name_full_formatted, pool = pg.prsnl_group_name
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl prsnl,
   prsnl_group pg,
   dummyt d1,
   dummyt d2
  PLAN (ta
   WHERE ta.task_type_cd IN (rxmessage_cv)
    AND ta.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ta.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (taa
   WHERE ta.task_id=taa.task_id)
   JOIN (d1)
   JOIN (prsnl
   WHERE taa.assign_prsnl_id=prsnl.person_id)
   JOIN (d2)
   JOIN (pg
   WHERE pg.prsnl_group_id=taa.assign_prsnl_group_id)
  ORDER BY originating_inbox, msg_created
  WITH outerjoin = d1, outerjoin = d2, nocounter,
   format, separator = " "
 ;end select
END GO
