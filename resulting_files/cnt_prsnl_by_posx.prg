CREATE PROGRAM cnt_prsnl_by_posx
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
  p_position_disp = uar_get_code_display(p.position_cd), p.position_cd"###########", cntr = count(p
   .position_cd)
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.username > " "
   AND p.position_cd > 0
  ORDER BY p_position_disp
  HEAD REPORT
   row 1, col 51, "Count PRSNL by Active CIS Position",
   row + 2
  DETAIL
   p_position_disp1 = substring(1,32,p_position_disp), col 6, p_position_disp1,
   col 42, p.position_cd, row + 1
  WITH compress, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
