CREATE PROGRAM bhs_rad_dis_pat_order_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14192,"ORDERED"))
 DECLARE in_process_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14192,"INPROCESS"))
 DECLARE discharged_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",261,"DISCHARGED"))
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 SELECT INTO  $OUTDEV
  patient = trim(substring(1,100,p.name_full_formatted)), fin = trim(substring(1,12,ea.alias)),
  order_id = trim(substring(1,12,trim(cnvtstring(o.order_id)))),
  accession = trim(substring(1,100,a.accession)), order_mnemonic = trim(substring(1,100,o
    .order_mnemonic)), order_dt_tm = trim(substring(1,20,format(cnvtdatetime(o.orig_order_dt_tm),
     "MMM-DD-YYYY HH:MM;;Q"))),
  ordering_prsnl = trim(substring(1,100,p2.name_full_formatted))
  FROM order_radiology orr,
   orders o,
   encounter e,
   person p,
   encntr_alias ea,
   accession a,
   person p2
  PLAN (orr
   WHERE orr.exam_status_cd IN (ordered_cd, in_process_cd))
   JOIN (o
   WHERE o.order_id=orr.order_id)
   JOIN (e
   WHERE e.encntr_id=orr.encntr_id
    AND e.encntr_status_cd=discharged_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1)
   JOIN (a
   WHERE a.accession_id=orr.accession_id)
   JOIN (p2
   WHERE p2.person_id=orr.order_physician_id
    AND p2.active_ind=1)
  ORDER BY p.name_full_formatted
  WITH format, variable
 ;end select
END GO
