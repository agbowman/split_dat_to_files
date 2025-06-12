CREATE PROGRAM class_tgh_ex7_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e.encntr_type_cd,
  encntr_prsnl_r_disp = uar_get_code_display(ep.encntr_prsnl_r_cd), ep.encntr_prsnl_r_cd, pr
  .name_full_formatted,
  e.person_id, p.person_id, pr.person_id,
  ep.encntr_id, e.encntr_id, ep.prsnl_person_id
  FROM encntr_prsnl_reltn ep,
   encounter e,
   person p,
   prsnl pr
  PLAN (p)
   JOIN (e
   WHERE p.person_id=e.person_id)
   JOIN (ep
   WHERE e.encntr_id=ep.encntr_id)
   JOIN (pr
   WHERE ep.prsnl_person_id=pr.person_id)
  ORDER BY p.person_id, e.encntr_id
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
