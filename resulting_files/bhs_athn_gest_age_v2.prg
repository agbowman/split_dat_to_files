CREATE PROGRAM bhs_athn_gest_age_v2
 DECLARE person_id = f8 WITH protect, constant( $2)
 SELECT INTO  $1
  p.gest_age_at_birth, p.person_id, active_dt = format(p.active_status_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"
   )
  FROM person_patient p
  WHERE p.person_id=person_id
   AND p.beg_effective_dt_tm < sysdate
   AND p.end_effective_dt_tm > sysdate
   AND p.active_ind=1
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col 1, "<GestationalDetails>",
   row + 1, p_id = build("<PersonID>",cnvtint(p.person_id),"</PersonID>"), col + 1,
   p_id, row + 1
  DETAIL
   gab = build("<GestAgeAtBirth>",p.gest_age_at_birth,"</GestAgeAtBirth>"), col + 1, gab,
   row + 1, asd = build("<ActiveStatusDate>",active_dt,"</ActiveStatusDate>"), col + 1,
   asd, row + 1
  FOOT REPORT
   col 1, "</GestationalDetails>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
