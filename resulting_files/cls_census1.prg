CREATE PROGRAM cls_census1
 PROMPT
  "Output to File/Printer/MINE" = mine
 SELECT INTO  $1
  o.active_ind, o.organization_id, o.ft_entity_id,
  o.ft_entity_name, o.org_name, l.active_ind,
  l.organization_id, l.location_cd, l.location_type_cd,
  l_location_type_disp = uar_get_code_display(l.location_type_cd), l_location_disp =
  uar_get_code_display(l.location_cd), r_location_disp = uar_get_code_display(r.location_cd),
  r.loc_nurse_unit_cd, r_loc_nurse_unit_disp = uar_get_code_display(r.loc_nurse_unit_cd),
  b_loc_room_disp = uar_get_code_display(b.loc_room_cd),
  b.location_cd, b_location_disp = uar_get_code_display(b.location_cd), e.encntr_id,
  e.person_id, e.loc_building_cd, e_loc_building_disp = uar_get_code_display(e.loc_building_cd),
  e.loc_facility_cd, e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), e
  .loc_nurse_unit_cd,
  e_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), e.loc_room_cd, e_loc_room_disp
   = uar_get_code_display(e.loc_room_cd),
  e.loc_bed_cd, e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd), l.location_type_cd,
  b.loc_room_cd, r.location_cd
  FROM organization o,
   location l,
   room r,
   bed b,
   encntr_domain e
  PLAN (l
   WHERE l.location_type_cd=794)
   JOIN (r
   WHERE r.loc_nurse_unit_cd=l.location_cd)
   JOIN (b
   WHERE b.loc_room_cd=r.location_cd)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (e
   WHERE e.loc_room_cd=r.location_cd
    AND e.loc_bed_cd=b.location_cd)
  ORDER BY o.ft_entity_name, r_loc_nurse_unit_disp, e_loc_room_disp,
   e_loc_bed_disp
 ;end select
END GO
