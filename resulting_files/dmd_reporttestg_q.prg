CREATE PROGRAM dmd_reporttestg_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.birth_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", p.name_first_key, p.name_last_key,
  p.person_id, p.sex_cd, sex_disp = uar_get_code_display(p.sex_cd),
  c.clinical_event_id, c.event_reltn_cd, event_reltn_disp = uar_get_code_display(c.event_reltn_cd),
  c.result_status_cd, result_status_disp = uar_get_code_display(c.result_status_cd), c
  .performed_dt_tm,
  c.verified_dt_tm, expr2 = concat(trim(p.name_last_key),",  ",p.name_first_key), expr3 = cnvtage(p
   .birth_dt_tm)
  FROM person p,
   clinical_event c
  PLAN (p
   WHERE p.person_id != null
    AND p.birth_dt_tm >= cnvtdatetime(cnvtdate(123196),0))
   JOIN (c
   WHERE c.person_id=p.person_id)
  ORDER BY p.name_last_key
  WITH format, maxrec = 50, maxcol = 500,
   time = value(maxsecs), landscape
 ;end select
END GO
