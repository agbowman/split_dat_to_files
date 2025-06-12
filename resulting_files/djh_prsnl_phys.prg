CREATE PROGRAM djh_prsnl_phys
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
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username,
  p.name_full_formatted, p.position_cd, p_position_disp = uar_get_code_display(p.position_cd),
  p.beg_effective_dt_tm, p.physician_ind, p.active_ind
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.active_status_cd=188
    AND p.physician_ind=1
    AND p.position_cd > 0
    AND p.position_cd != 441)
  ORDER BY p.name_full_formatted
  WITH maxrec = 10000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
