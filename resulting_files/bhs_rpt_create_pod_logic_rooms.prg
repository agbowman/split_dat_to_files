CREATE PROGRAM bhs_rpt_create_pod_logic_rooms
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please enter a facility:" = 0,
  "Nursing Unit" = 0
  WITH outdev, facility, nurse_unit
 SELECT INTO  $OUTDEV
  room_codes = build(uar_get_code_display(l2.parent_loc_cd),uar_get_code_display(l2.child_loc_cd),
   uar_get_code_display(l.parent_loc_cd),uar_get_code_display(l.child_loc_cd),uar_get_code_display(l3
    .child_loc_cd)), unit = uar_get_code_display(l.parent_loc_cd), room = uar_get_code_display(l
   .child_loc_cd),
  bed = uar_get_code_display(l3.child_loc_cd)
  FROM location_group l,
   location_group l1,
   location_group l2,
   location_group l3,
   location lo
  PLAN (l
   WHERE (l.parent_loc_cd= $NURSE_UNIT)
    AND l.root_loc_cd=0
    AND l.active_ind=1)
   JOIN (l1
   WHERE l1.child_loc_cd=l.parent_loc_cd
    AND l1.parent_loc_cd=680158.00
    AND l1.root_loc_cd=0
    AND l1.active_ind=1)
   JOIN (l2
   WHERE l2.child_loc_cd=l1.parent_loc_cd
    AND l2.parent_loc_cd=673936.00
    AND l2.root_loc_cd=0
    AND l2.active_ind=1)
   JOIN (l3
   WHERE l3.parent_loc_cd=l.child_loc_cd
    AND l3.root_loc_cd=0
    AND l3.active_ind=1)
   JOIN (lo
   WHERE lo.location_cd=l3.child_loc_cd
    AND lo.active_ind=1)
  ORDER BY room_codes
  WITH nocounter, separator = " ", format
 ;end select
END GO
