CREATE PROGRAM djh_l_medstud
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
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.updt_dt_tm
  FROM prsnl p
  WHERE ((p.position_cd=777650
   AND p.active_status_cd=188) OR (p.position_cd=777650
   AND p.end_effective_dt_tm >= cnvtdatetime((curdate - 45),000)))
   AND p.username != "MEDICALSTUDENT"
   AND p.username != "VT*"
  ORDER BY p.name_full_formatted, p.beg_effective_dt_tm DESC, p.username
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
