CREATE PROGRAM dmd_outerjoin2_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, p.person_id, e.person_id,
  encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e.encntr_id, o.encntr_id,
  o.order_mnemonic, o.order_id
  FROM person p,
   encounter e,
   orders o,
   dummyt d1
  PLAN (p
   WHERE p.person_id > 0)
   JOIN (e
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (o
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY p.name_full_formatted
  WITH format, maxrec = 100, maxcol = 500,
   time = value(maxsecs), outerjoin = d1
 ;end select
END GO
