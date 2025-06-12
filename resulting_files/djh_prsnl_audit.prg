CREATE PROGRAM djh_prsnl_audit
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
  p.updt_cnt, p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), p.position_cd, p.active_status_dt_tm,
  p.active_status_prsnl_id, p.beg_effective_dt_tm, p.create_dt_tm,
  p.create_prsnl_id, p.end_effective_dt_tm, p.person_id,
  p.physician_ind, p.physician_status_cd, p_physician_status_disp = uar_get_code_display(p
   .physician_status_cd),
  p.updt_applctx, p.updt_dt_tm, p.updt_id,
  p.updt_task
  FROM prsnl p
  WHERE p.updt_cnt > 10
   AND p.updt_cnt < 100
  ORDER BY p.updt_cnt DESC
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
