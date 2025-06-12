CREATE PROGRAM cls_badroom
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 SELECT INTO  $OUTDEV
  e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp =
  uar_get_code_display(e.loc_nurse_unit_cd), e_loc_room_disp = uar_get_code_display(e.loc_room_cd),
  e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd), e.person_id, e.encntr_id,
  cv1.code_value, cv1.cdf_meaning, p.person_id,
  p.name_full_formatted
  FROM encntr_domain e,
   code_value cv1,
   person p
  PLAN (e
   WHERE e.loc_room_cd=0
    AND e.loc_bed_cd=0)
   JOIN (cv1
   WHERE e.loc_nurse_unit_cd=cv1.code_value
    AND cv1.cdf_meaning="NURSEUNI*")
   JOIN (p
   WHERE e.person_id=p.person_id)
  ORDER BY e_loc_facility_disp, e_loc_nurse_unit_disp, e.encntr_id
  WITH maxrec = 1500
 ;end select
END GO
