CREATE PROGRAM djh_l_encntr_domain
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  e.active_ind, e.active_status_cd, e_active_status_disp = uar_get_code_display(e.active_status_cd),
  e.active_status_dt_tm, e.active_status_prsnl_id, e.beg_effective_dt_tm,
  e.encntr_domain_id, e.encntr_domain_type_cd, e_encntr_domain_type_disp = uar_get_code_display(e
   .encntr_domain_type_cd),
  e.encntr_id, e.end_effective_dt_tm, e.loc_bed_cd,
  e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd), e.loc_building_cd, e_loc_building_disp =
  uar_get_code_display(e.loc_building_cd),
  e.loc_facility_cd, e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), e
  .loc_nurse_unit_cd,
  e_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), e.loc_room_cd, e_loc_room_disp
   = uar_get_code_display(e.loc_room_cd),
  e.med_service_cd, e_med_service_disp = uar_get_code_display(e.med_service_cd), e.person_id,
  e.rowid, e.updt_applctx, e.updt_cnt,
  e.updt_dt_tm, e.updt_id, e.updt_task
  FROM encntr_domain e
  WHERE e.encntr_domain_id=147249597
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
