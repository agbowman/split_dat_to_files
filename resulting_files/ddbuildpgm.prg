CREATE PROGRAM ddbuildpgm
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Last Name - UPPERCASE " = "*"
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_last_key, p.name_first_key, p.birth_dt_tm"MMM-DD-YYYY;;D",
  p.marital_type_cd, marital_type_disp = uar_get_code_display(p.marital_type_cd), p.person_id,
  o.order_id, o.order_mnemonic, o.updt_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D",
  o.order_detail_display_line, e.encntr_id, e.loc_nurse_unit_cd,
  loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), e.encntr_type_cd, encntr_type_disp
   = uar_get_code_display(e.encntr_type_cd),
  e.disch_dt_tm, expr1 = cnvtage(p.birth_dt_tm)
  FROM person p,
   orders o,
   encounter e
  PLAN (p
   WHERE (p.name_last_key= $2)
    AND ((p.birth_dt_tm > cnvtdatetime(cnvtdate(090170),0)) OR (p.person_id IN (100, 850))) )
   JOIN (o
   WHERE o.person_id=p.person_id
    AND o.order_id > 830
    AND o.order_mnemonic="BUN")
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY p.birth_dt_tm, o.updt_dt_tm DESC
  HEAD REPORT
   expr2 = fillstring(85,"**********"), row 2, col 54,
   "PERSON INFORMATION REGARDING", row 3, col 60,
   "ORDERS & ENCOUNTERS", row + 1
  HEAD p.birth_dt_tm
   row + 2, col 4, "PERSON LAST NAME:",
   col 41, "PERSON FIRST NAME:", col 79,
   "BIRTHDAY:", row + 1, name_last_key1 = substring(1,35,p.name_last_key),
   name_first_key1 = substring(1,25,p.name_first_key), col 4, name_last_key1,
   col 41, name_first_key1, col 82,
   p.birth_dt_tm, row + 1, col 4,
   "ENCOUNTER", col 41, "ORDER",
   col 69, "ENCOUNTER TYPE", row + 2,
   line1 = fillstring(36,"_"), col 4, line1,
   row + 1
  DETAIL
   IF (((row+ 2) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 4, e.encntr_id,
   col 35, o.order_id, col 66,
   encntr_type_disp
  FOOT  p.birth_dt_tm
   row + 2, col 10, expr2
  WITH maxrec = 100, maxcol = 250, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
