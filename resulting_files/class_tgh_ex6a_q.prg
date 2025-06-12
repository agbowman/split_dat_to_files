CREATE PROGRAM class_tgh_ex6a_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.person_id, p.name_full_formatted, e.person_id,
  e.encntr_id, e.loc_facility_cd, e.loc_nurse_unit_cd,
  e.loc_room_cd, e.loc_bed_cd
  FROM encounter e,
   person p
  WHERE p.person_id=e.person_id
  ORDER BY p.person_id, e.encntr_id
  WITH format, maxrec = 50, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
