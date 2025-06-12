CREATE PROGRAM dmd_qual_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 5
 ENDIF
 SELECT INTO  $1
  p.name_last_key, p.name_first_key, p.birth_dt_tm,
  p.last_encntr_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", p.person_id, sex_disp = uar_get_code_display(p
   .sex_cd),
  c.encntr_id, event_disp = uar_get_code_display(c.event_cd), o.order_id,
  o.order_mnemonic, expr1 = concat(trim(p.name_first_key)," ",p.name_last_key), expr2 = cnvtage(p
   .birth_dt_tm)
  FROM person p,
   clinical_event c,
   orders o
  PLAN (p
   WHERE p.birth_dt_tm >= cnvtdatetime("31-DEC-1989 00:00:00.00"))
   JOIN (c
   WHERE c.person_id=p.person_id)
   JOIN (o
   WHERE o.order_id=c.order_id
    AND o.order_id != null)
  ORDER BY concat(trim(p.name_first_key)," ",p.name_last_key) DESC
  WITH format, maxcol = 500, time = value(maxsecs)
 ;end select
END GO
