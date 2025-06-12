CREATE PROGRAM bhs_rpt_pat_relationship
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Username" = "",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, ms_en_number, mf_startdate,
  mf_enddate
 SELECT DISTINCT INTO  $OUTDEV
  p.name_full_formatted, p.birth_dt_tm
  FROM prsnl pl,
   encntr_prsnl_reltn epr,
   encounter e,
   person p
  PLAN (pl
   WHERE pl.username=trim( $MS_EN_NUMBER,3))
   JOIN (epr
   WHERE epr.prsnl_person_id=pl.person_id
    AND epr.beg_effective_dt_tm >= cnvtdatetime(cnvtdate( $MF_STARTDATE),0)
    AND epr.beg_effective_dt_tm <= cnvtdatetime(cnvtdate( $MF_ENDDATE),235959))
   JOIN (e
   WHERE e.encntr_id=epr.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY epr.beg_effective_dt_tm, p.name_last_key
  WITH nocounter, format, separator = "  "
 ;end select
END GO
