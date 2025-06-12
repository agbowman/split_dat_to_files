CREATE PROGRAM djh_l_ticket_72360
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
  p.physician_ind, p.username, p.name_full_formatted,
  p.position_cd, p_position_disp = uar_get_code_display(p.position_cd), p.updt_id,
  p1.person_id, p1.name_full_formatted, p1.create_dt_tm,
  p1.updt_dt_tm
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.position_cd > 0
    AND p.username != null
    AND p.username > " "
    AND p.username != "DUM*")
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY p_position_disp
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
