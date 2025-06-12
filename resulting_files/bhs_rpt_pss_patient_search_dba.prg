CREATE PROGRAM bhs_rpt_pss_patient_search:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, bdate, edate
 SELECT INTO  $OUTDEV
  prsnl_name = substring(1,30,pr.name_full_formatted), patient_name = substring(1,30,p
   .name_full_formatted), fin = substring(1,20,ea.alias),
  beg_dt = format(epr.activity_dt_tm,"MM/DD/YYYY;;D"), beg_tm = cnvtupper(format(epr.activity_dt_tm,
    "HH:MM;;S"))
  FROM prsnl pr,
   encntr_prsnl_reltn epr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (pr
   WHERE pr.username IN ("PN53040", "PN53364", "PN54378", "PN55428", "PN53307",
   "PN53501", "PN55483", "EN04633"))
   JOIN (epr
   WHERE pr.person_id=epr.prsnl_person_id
    AND epr.activity_dt_tm BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),2359))
   JOIN (e
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE epr.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=1077.00)
  ORDER BY p.name_full_formatted, epr.beg_effective_dt_tm
  WITH nocounter, separator = " ", format
 ;end select
END GO
