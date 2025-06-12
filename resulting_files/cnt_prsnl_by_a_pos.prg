CREATE PROGRAM cnt_prsnl_by_a_pos
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
  p_position_disp = uar_get_code_display(p.position_cd), p.position_cd"###########", cntr = count(p
   .position_cd)"#####",
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND p.username > " "
   AND p.username != "EN*"
   AND p.username != "TN*"
   AND p.username != "PN*"
   AND p.username != "CR*"
   AND p.username != "CN*"
   AND p.username != "SN*"
   AND p.username != "TERM*"
   AND p.username != "DUM*"
   AND p.username != "SI*"
   AND p.position_cd > 0
  GROUP BY p.position_cd, p.active_status_cd, p.username
  ORDER BY p.username, p.position_cd, p_position_disp,
   p_active_status_disp
  WITH compress, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
