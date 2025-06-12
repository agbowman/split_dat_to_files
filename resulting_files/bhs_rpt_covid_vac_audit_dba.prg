CREATE PROGRAM bhs_rpt_covid_vac_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "",
  "End Date:" = ""
  WITH outdev, rpt_start_dt, rpt_end_dt
 SELECT DISTINCT INTO  $OUTDEV
  e.encntr_id, name = p.name_full_formatted, fin = ea.alias,
  appt_type = uar_get_code_display(se.appt_type_cd), appt_date = format(sa.beg_dt_tm,
   "mm/dd/yy HH:mm;;D"), encounter_type = uar_get_code_display(e.encntr_type_cd),
  location = uar_get_code_display(e.loc_nurse_unit_cd), sch_state = uar_get_code_display(sa
   .sch_state_cd), vaccine_order = o.ordered_as_mnemonic,
  o.orig_order_dt_tm"mm/dd/yy HH:mm", vaccine_order_status = uar_get_code_display(o.order_status_cd),
  vaccine_med_admin = format(ce.event_end_dt_tm,"mm/dd/yy HH:mm;;D"),
  vaccine_charge_order = o2.ordered_as_mnemonic, vaccine_charge_date = od2.oe_field_display_value
  FROM sch_appt sa,
   sch_event se,
   encounter e,
   encntr_alias ea,
   person p,
   dummyt d1,
   orders o,
   dummyt d2,
   clinical_event ce,
   dummyt d3,
   orders o2,
   order_detail od2
  PLAN (sa
   WHERE sa.beg_dt_tm >= cnvtdatetime("10-FEB-2021 00:00:00")
    AND sa.beg_dt_tm < cnvtdatetime("11-FEB-2021 00:00:00"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.appt_type_cd > 0.00
    AND se.appt_type_cd IN (1118569173.00, 1118569373.00, 1118569533.00, 1118569713.00))
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id
    AND e.encntr_type_cd != 335953107.00)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE p.person_id=sa.person_id
    AND  NOT (p.name_last_key IN ("ZZZZ")))
   JOIN (d1)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.synonym_id IN (1090700927.00, 1090701259.00))
   JOIN (d2)
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.order_id=o.order_id)
   JOIN (d3)
   JOIN (o2
   WHERE o2.encntr_id=e.encntr_id
    AND o2.synonym_id IN (1120275719.00, 1120276179.00, 1120273941.00, 1120274841.00))
   JOIN (od2
   WHERE od2.order_id=o2.order_id
    AND od2.oe_field_meaning="REQSTARTDTTM"
    AND od2.action_sequence IN (
   (SELECT
    max(od20.action_sequence)
    FROM order_detail od20
    WHERE od20.order_id=od2.order_id
     AND od20.oe_field_id=od2.oe_field_id)))
  ORDER BY sa.beg_dt_tm, p.name_full_formatted, o.orig_order_dt_tm,
   ce.event_end_dt_tm, od2.oe_field_dt_tm_value
  WITH outerjoin = d1, dontcare = o, outerjoin = d2,
   dontcare = ce, outerjoin = d3, time = 600,
   format, separator = " ", nocounter
 ;end select
END GO
