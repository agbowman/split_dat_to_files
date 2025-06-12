CREATE PROGRAM dmd_person_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.active_ind, p.birth_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", p.name_first_key,
  p.name_last_key, p.person_id, sex_disp = uar_get_code_display(p.sex_cd),
  p.sex_cd, expr1 = format(p.person_id,"######;R")
  FROM person p
  WITH format, maxrec = 100, maxcol = 500,
   time = value(maxsecs)
 ;end select
END GO
