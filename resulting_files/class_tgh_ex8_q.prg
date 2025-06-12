CREATE PROGRAM class_tgh_ex8_q
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter verrified date in MMDDYYYY " = "12011997"
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  c.accession_nbr, event_cdf = uar_get_code_meaning(c.event_cd), c.event_cd,
  c.event_tag, c.verified_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D"
  FROM clinical_event c
  WHERE c.verified_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $2),235959)
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
