CREATE PROGRAM bhs_athn_lastdose_nextdose
 FREE RECORD ip_mar_next_last
 RECORD ip_mar_next_last(
   1 o_id = f8
   1 order_name = vc
   1 last_dose = c20
   1 next_dose = c20
 )
 DECLARE temp_flag = i4
 SET temp_flag = 0
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE mpersonid = f8 WITH protect, constant(request->person[1].person_id)
 SELECT DISTINCT INTO "NL:"
  oid = cnvtint(o.order_id), o.order_mnemonic, next_dose = format(o.current_start_dt_tm,
   "MM/DD/YYYY HH:MM;;D"),
  last_dose = format(c.event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")
  FROM orders o,
   orders o1,
   clinical_event c,
   clinical_event c1
  PLAN (o
   WHERE o.order_id=mpersonid
    AND o.activity_type_cd=705.00)
   JOIN (c
   WHERE c.order_id=outerjoin(o.order_id))
   JOIN (o1
   WHERE o1.template_order_id=outerjoin(o.order_id))
   JOIN (c1
   WHERE c1.order_id=outerjoin(o1.order_id))
  ORDER BY o.order_id, o1.current_start_dt_tm DESC
  HEAD o.order_id
   ip_mar_next_last->o_id = o.order_id, ip_mar_next_last->order_name = o.order_mnemonic
  DETAIL
   ip_mar_next_last->last_dose = last_dose
  FOOT  o.order_id
   ip_mar_next_last->next_dose = next_dose
  WITH time = 60
 ;end select
 SET json = cnvtrectojson(ip_mar_next_last)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, separator = " "
 ;end select
END GO
