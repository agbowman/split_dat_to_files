CREATE PROGRAM barb_0615_q
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT
  p.name_full_formatted, p.person_id, sex_disp = uar_get_code_display(p.sex_cd),
  p.birth_dt_tm
  FROM person p
  WITH format, maxrec = 100, maxcol = 500,
   time = value(maxsecs)
 ;end select
END GO
