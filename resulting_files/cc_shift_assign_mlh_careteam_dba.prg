CREATE PROGRAM cc_shift_assign_mlh_careteam:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  sa.prsnl_id, ctp.prsnl_id, p.name_full_formatted,
  careteam = ct.name, assigment_location = uar_get_code_display(sa.assignment_group_cd),
  assigned_facility = uar_get_code_display(sa.loc_facility_cd),
  assigned_building = uar_get_code_display(sa.loc_building_cd), assigned_unit = uar_get_code_display(
   sa.loc_unit_cd), assigned_room = uar_get_code_display(sa.loc_room_cd),
  assigned_bed = uar_get_code_display(sa.loc_bed_cd), sa.person_id, sa.encntr_id,
  sa.beg_effective_dt_tm";;Q", sa.end_effective_dt_tm";;Q", active_ind = sa.active_ind,
  updt_cnt = sa.updt_cnt, sa.updt_dt_tm";;Q", sa.updt_id,
  p1.name_full_formatted, position_of_person_making_assignment = uar_get_code_display(sa
   .assignment_pos_cd), sa.purge_ind,
  assignment_type = uar_get_code_display(sa.assign_type_cd)
  FROM dcp_shift_assignment sa,
   dcp_care_team_prsnl ctp,
   dcp_care_team ct,
   person p,
   person p1,
   dummyt d,
   dummyt d1
  PLAN (sa
   WHERE sa.loc_facility_cd IN (673938))
   JOIN (ctp
   WHERE sa.careteam_id=ctp.careteam_id)
   JOIN (ct
   WHERE sa.careteam_id=ct.careteam_id)
   JOIN (d)
   JOIN (p
   WHERE p.active_ind=1
    AND ((p.person_id=sa.prsnl_id) OR (p.person_id=ctp.prsnl_id)) )
   JOIN (d1)
   JOIN (p1
   WHERE p.active_ind=1
    AND p1.person_id=sa.updt_id)
  ORDER BY sa.active_ind DESC, sa.beg_effective_dt_tm, sa.end_effective_dt_tm
  WITH outerjoin = d, outerjoin = d1, format,
   variable
 ;end select
END GO
