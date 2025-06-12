CREATE PROGRAM djh_l_nspn_accnts_v2
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
 SELECT DISTINCT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.physician_ind, p.username, p.person_id,
  p.name_full_formatted, p.position_cd, p_position_disp = uar_get_code_display(p.position_cd),
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id
  FROM prsnl p
  PLAN (p
   WHERE p.username="NS*"
    AND p.active_ind=1
    AND p.physician_ind=1)
  ORDER BY p.username
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
