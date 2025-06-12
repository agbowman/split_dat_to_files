CREATE PROGRAM djh_l_all_pns
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
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username, physflg = evaluate(p
   .physician_ind,1,"*",""),
  p.name_full_formatted, p.person_id, p_position_disp = uar_get_code_display(p.position_cd),
  p.position_cd, p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.updt_dt_tm, p.updt_id
  FROM prsnl p
  PLAN (p
   WHERE p.username="PN*")
  ORDER BY p.username
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , row + 1,
   "{F/1}{CPI/10}",
   CALL print(calcpos(162,(y_pos+ 11))), "List Active PN prefix log in IDs",
   row + 1, y_pos = (y_pos+ 27)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(29,(y_pos+ 11))),
   "Log-In",
   CALL print(calcpos(87,(y_pos+ 11))), "User Name",
   CALL print(calcpos(270,(y_pos+ 11))), "CIS Position",
   CALL print(calcpos(407,(y_pos+ 12))),
   "| Start  -  End  |", row + 1, row + 1,
   y_val = ((792 - y_pos) - 41), "{PS/newpath 2 setlinewidth   20 ", y_val,
   " moveto  503 ", y_val, " lineto stroke 20 ",
   y_val, " moveto/}", row + 1,
   y_pos = (y_pos+ 33)
  DETAIL
   IF (((y_pos+ 100) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,35,p.name_full_formatted), username1 = substring(1,10,p
    .username), p_position_disp1 = substring(1,32,p_position_disp),
   CALL print(calcpos(20,(y_pos+ 12))), username1, row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(72,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(248,(y_pos+ 12))), p_position_disp1,
   CALL print(calcpos(411,(y_pos+ 11))),
   p.beg_effective_dt_tm,
   CALL print(calcpos(456,(y_pos+ 11))), p.end_effective_dt_tm,
   y_pos = (y_pos+ 14)
  FOOT PAGE
   y_pos = 724, row + 1,
   CALL print(calcpos(36,(y_pos+ 13))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(398,(y_pos+ 11))), "Page:", row + 1,
   CALL print(calcpos(423,(y_pos+ 11))), curpage
  FOOT REPORT
   IF (((y_pos+ 62) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))),
   "Contractot/Consultant count:", cntid = format(count(p.username),"####"), row + 1,
   CALL print(calcpos(168,(y_pos+ 11))), cntid
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
