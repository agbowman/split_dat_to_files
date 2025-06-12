CREATE PROGRAM afc_prod_spec:dba
 PROMPT
  "Last Name of Patient: " = "*",
  "First Name of Patient: " = "*",
  "Order ID: " = 0,
  "Accession Number: " = "*"
 SELECT DISTINCT
  p.name_last_key, p.name_first_key, p.person_id,
  o.order_id, o.catalog_cd, ce.accession,
  c.encntr_id, c.bill_item_id, c.charge_event_id,
  c.process_flg, c.service_dt_tm"MM/DD/YYYY;;D", c.tier_group_cd,
  e.organization_id, ce.ext_m_event_id, ce.ext_p_reference_id,
  cm.active_ind, cm.field6
  FROM charge c,
   charge_event ce,
   charge_mod cm,
   orders o,
   encounter e,
   person p
  PLAN (p
   WHERE p.name_last_key=patstring(cnvtupper( $1))
    AND p.name_first_key=patstring(cnvtupper( $2)))
   JOIN (o
   WHERE o.order_id=outerjoin( $3)
    AND outerjoin(p.person_id)=o.person_id)
   JOIN (c
   WHERE c.person_id=p.person_id)
   JOIN (ce
   WHERE (ce.accession= $4)
    AND outerjoin(p.person_id)=ce.person_id
    AND ce.charge_event_id=c.charge_event_id)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.active_ind=1)
   JOIN (e
   WHERE e.person_id=c.person_id
    AND e.encntr_id=c.encntr_id)
 ;end select
 SET dest = 951060
 SET count_correct = 0
 SET count_requests = 0
 SELECT DISTINCT INTO "nl:"
  rp.*
  FROM request_processing rp
  WHERE rp.destination_step_id=dest
   AND rp.active_ind=1
  DETAIL
   count_correct = (count_correct+ 1)
  WITH counter
 ;end select
 SELECT DISTINCT INTO "nl:"
  rp.request_number, rp.format_script
  FROM request_processing rp
  WHERE rp.destination_step_id=dest
   AND rp.active_ind=1
  DETAIL
   count_requests = (count_requests+ 1)
  WITH counter
 ;end select
 IF (count_correct=0)
  CALL echo(concat("No rows to process"))
 ELSE
  CALL echo(build("Requests to send: ",count_correct))
 ENDIF
 IF (count_requests=0)
  CALL echo("No rows to process")
 ELSE
  CALL echo(build("Number of requests sent: ",count_requests))
 ENDIF
END GO
