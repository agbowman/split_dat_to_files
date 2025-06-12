CREATE PROGRAM bhs_rpt_msg_errinmsgcntr
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 DECLARE rxmessage_cv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"RXMESSAGE"))
 SELECT INTO  $OUTDEV
  msg_created = format(ta.task_create_dt_tm,"MM/DD/YYYY HH:MM;;d"), org = org.org_name, provider =
  prsnl.name_full_formatted,
  pharmacy_id = ma.pharmacy_identifier, ma_rx_id = ma.rx_identifier, ma_status_cd =
  uar_get_code_display(ma.status_cd),
  ma_error_cd = uar_get_code_display(ma.error_cd), msg_status = uar_get_code_display(ta
   .task_status_cd), msg_event_cd = ta.event_cd,
  patient = p.name_full_formatted, order_mnemonic = o.ordered_as_mnemonic, ord_detail = o
  .clinical_display_line,
  order_date = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"), patient_id = ta.person_id,
  encounter_id = ta.encntr_id,
  order_id = ta.order_id, org_id = org.organization_id, prsnl_id = prsnl.person_id,
  msg_subject = trim(ta.msg_subject)
  FROM messaging_audit ma,
   dummyt d,
   task_activity ta,
   orders o,
   prsnl prsnl,
   organization org,
   person p
  PLAN (ma
   WHERE ma.publish_ind=1
    AND ma.order_id > 0)
   JOIN (d)
   JOIN (ta
   WHERE ta.order_id=ma.order_id
    AND ta.task_type_cd=rxmessage_cv
    AND ta.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ta.updt_dt_tm < cnvtdatetime( $END_DATE)
    AND ta.msg_sender_id=0)
   JOIN (o
   WHERE ta.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (prsnl
   WHERE prsnl.person_id=ma.ordering_phys_id)
   JOIN (org
   WHERE ma.org_id=org.organization_id)
  ORDER BY ta.task_create_dt_tm
  WITH nocounter, format, separator = " "
 ;end select
END GO
