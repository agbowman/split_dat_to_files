CREATE PROGRAM bhs_athn_get_mar_dose
 FREE RECORD ip_mar_next_last
 RECORD ip_mar_next_last(
   1 o_id = vc
   1 order_name = vc
   1 last_dose = vc
   1 next_dose = vc
 )
 DECLARE orderid = f8 WITH protect, constant( $2)
 DECLARE pharmacy = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",106,"PHARMACY"))
 SELECT DISTINCT INTO "NL:"
  oid = cnvtstring(o.order_id), o.order_mnemonic, next_dose = datetimezoneformat(o
   .current_start_dt_tm,o.current_start_tz,"MM/dd/yyyy HH:mm",curtimezonedef),
  last_dose = datetimezoneformat(c.event_end_dt_tm,c.event_end_tz,"MM/dd/yyyy HH:mm",curtimezonedef)
  FROM orders o,
   orders o1,
   clinical_event c,
   clinical_event c1
  PLAN (o
   WHERE o.order_id=orderid
    AND o.activity_type_cd=pharmacy)
   JOIN (c
   WHERE c.order_id=outerjoin(o.order_id))
   JOIN (o1
   WHERE o1.template_order_id=outerjoin(o.order_id))
   JOIN (c1
   WHERE c1.order_id=outerjoin(o1.order_id))
  ORDER BY o.order_id, o1.current_start_dt_tm DESC
  HEAD o.order_id
   ip_mar_next_last->o_id = oid, ip_mar_next_last->order_name = trim(o.order_mnemonic,3)
  DETAIL
   ip_mar_next_last->last_dose = trim(last_dose,3)
  FOOT  o.order_id
   ip_mar_next_last->next_dose = trim(next_dose,3)
  WITH time = 60
 ;end select
 CALL echojson(ip_mar_next_last, $1)
END GO
