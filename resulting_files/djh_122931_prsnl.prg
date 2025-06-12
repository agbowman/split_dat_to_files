CREATE PROGRAM djh_122931_prsnl
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
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.person_id, p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), p.physician_ind, p.position_cd
  FROM prsnl p
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_status_cd=188
    AND p.name_full_formatted="*Abbott*")
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
