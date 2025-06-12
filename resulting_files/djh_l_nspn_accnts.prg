CREATE PROGRAM djh_l_nspn_accnts
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
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.active_status_dt_tm, p.active_status_prsnl_id, p.beg_effective_dt_tm,
  p.contributor_system_cd, p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd),
  p.create_dt_tm,
  p.create_prsnl_id, p.data_status_cd, p_data_status_disp = uar_get_code_display(p.data_status_cd),
  p.data_status_dt_tm, p.data_status_prsnl_id, p.department_cd,
  p_department_disp = uar_get_code_display(p.department_cd), p.email, p.end_effective_dt_tm,
  p.free_text_ind, p.ft_entity_id, p.ft_entity_name,
  p.log_access_ind, p.log_level, p.name_first,
  p.name_first_key, p.name_first_key_nls, p.name_full_formatted,
  p.name_last, p.name_last_key, p.name_last_key_nls,
  p.password, p.person_id, p.physician_ind,
  p.physician_status_cd, p_physician_status_disp = uar_get_code_display(p.physician_status_cd), p
  .position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.prim_assign_loc_cd, p_prim_assign_loc_disp
   = uar_get_code_display(p.prim_assign_loc_cd),
  p.prsnl_type_cd, p_prsnl_type_disp = uar_get_code_display(p.prsnl_type_cd), p.rowid,
  p.section_cd, p_section_disp = uar_get_code_display(p.section_cd), p.updt_applctx,
  p.updt_cnt, p.updt_dt_tm, p.updt_id,
  p.updt_task, p.username
  FROM prsnl p
  WHERE username="NSPN*"
   AND p.active_ind=1
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
