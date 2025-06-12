CREATE PROGRAM bhs_rpt_epr_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "User Name (EN or PN Number)" = "",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, prompt1, prompt2,
  prompt3
 SELECT INTO  $1
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
   WHERE pr.username=trim( $2,3))
   JOIN (epr
   WHERE pr.person_id=epr.prsnl_person_id
    AND epr.activity_dt_tm BETWEEN cnvtdatetime(cnvtdate( $3),0) AND cnvtdatetime(cnvtdate( $4),
    235959))
   JOIN (e
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE epr.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=1077.00)
  ORDER BY p.name_full_formatted, epr.beg_effective_dt_tm
  WITH nocounter, format, separator = " "
 ;end select
END GO
