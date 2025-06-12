CREATE PROGRAM cnt_prsnl_by_pos
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
   .position_cd)"#####"
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND p.username > " "
   AND p.username != "DUM*"
   AND p.position_cd > 0
  GROUP BY p.position_cd
  ORDER BY p_position_disp
  WITH compress, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
