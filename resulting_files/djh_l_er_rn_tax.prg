CREATE PROGRAM djh_l_er_rn_tax
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
  p.physician_ind, p.person_id, p.name_full_formatted,
  p.username, p.position_cd, p_position_disp = uar_get_code_display(p.position_cd)
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND ((p.position_cd=36409588) OR (((p.position_cd=36572393) OR (((p.position_cd=1465246) OR (p
  .position_cd=1465245)) )) ))
  ORDER BY p_position_disp, p.username
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
