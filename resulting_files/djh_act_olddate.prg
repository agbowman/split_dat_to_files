CREATE PROGRAM djh_act_olddate
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
  p.active_ind, p.end_effective_dt_tm, p.username,
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .active_status_dt_tm,
  p.active_status_prsnl_id, p.beg_effective_dt_tm, p.name_full_formatted,
  p.create_dt_tm, p.create_prsnl_id, p.data_status_cd,
  p_data_status_disp = uar_get_code_display(p.data_status_cd), p.data_status_dt_tm, p
  .data_status_prsnl_id,
  p.person_id, p.physician_ind, p.physician_status_cd,
  p_physician_status_disp = uar_get_code_display(p.physician_status_cd), p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd),
  p.prsnl_type_cd, p_prsnl_type_disp = uar_get_code_display(p.prsnl_type_cd), p.section_cd,
  p_section_disp = uar_get_code_display(p.section_cd), p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id, p.updt_task
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.end_effective_dt_tm < cnvtdatetime(curdate,235959)
   AND p.active_status_cd != 194
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
