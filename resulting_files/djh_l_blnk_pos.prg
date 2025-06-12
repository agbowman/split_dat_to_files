CREATE PROGRAM djh_l_blnk_pos
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
  p.name_full_formatted, p.username, p_position_disp = uar_get_code_display(p.position_cd),
  p.position_cd, p.active_ind, physflg = evaluate(p.physician_ind,1,"*",0,""),
  p.beg_effective_dt_tm, p.physician_ind, p.updt_dt_tm
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.position_cd=0
  ORDER BY p.username, p_position_disp, p.name_full_formatted,
   p.position_cd
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, y_pos = (y_pos+ 12), row + 1,
   "{F/0}{CPI/14}", row + 1,
   CALL print(calcpos(22,(y_pos+ 0))),
   curdate, row + 1, "{F/1}{CPI/11}",
   row + 1,
   CALL print(calcpos(219,(y_pos+ 0))), "List of all Active DBAs",
   row + 1, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(28,(y_pos+ 18))), "Log-In",
   CALL print(calcpos(79,(y_pos+ 18))),
   "PHYS", row + 1,
   CALL print(calcpos(36,(y_pos+ 36))),
   "ID",
   CALL print(calcpos(81,(y_pos+ 36))), "FLG",
   CALL print(calcpos(111,(y_pos+ 36))), "User's Name",
   CALL print(calcpos(276,(y_pos+ 36))),
   "CIS Position",
   CALL print(calcpos(443,(y_pos+ 36))), "Last UPDT",
   row + 1, y_pos = (y_pos+ 59)
  DETAIL
   row + 1, y_val = ((792 - y_pos) - 11), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  574 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, username1 = substring(1,12,p.username), name_full_formatted1 = substring(1,35,p
    .name_full_formatted),
   p_position_disp1 = substring(1,10,p_position_disp), row + 1,
   CALL print(calcpos(20,(y_pos+ 17))),
   username1, row + 1,
   CALL print(calcpos(84,(y_pos+ 17))),
   physflg,
   CALL print(calcpos(97,(y_pos+ 17))), name_full_formatted1,
   CALL print(calcpos(284,(y_pos+ 17))), p_position_disp1,
   CALL print(calcpos(442,(y_pos+ 17))),
   p.updt_dt_tm, y_pos = (y_pos+ 31)
  FOOT PAGE
   y_pos = 726, y_pos = (y_pos+ 12), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(276,(y_pos+ 0))), "Page:",
   row + 1,
   CALL print(calcpos(306,(y_pos+ 0))), curpage
  FOOT REPORT
   IF (((y_pos+ 66) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   y_pos = (y_pos+ 12), row + 1, "{F/1}{CPI/10}",
   CALL print(calcpos(246,(y_pos+ 0))), "End of Report"
  WITH maxcol = 300, maxrow = 500, dio = 08,
   format, separator = value(_separator), time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
