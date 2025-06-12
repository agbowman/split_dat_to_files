CREATE PROGRAM djh_l_all_mds_for_ag
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
  p.active_ind, p.physician_ind, p.name_full_formatted,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.updt_dt_tm,
  p.position_cd, p_position_disp = uar_get_code_display(p.position_cd), p.username,
  cv1.code_value, cv1.description, pa.alias_pool_cd,
  pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd), pa.alias, pa.person_id,
  p.person_id, p.updt_id, p1.name_full_formatted
  FROM prsnl p,
   code_value cv1,
   prsnl_alias pa,
   prsnl p1
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.position_cd > 0
    AND p.username > " ")
   JOIN (cv1
   WHERE p.position_cd=cv1.code_value)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.alias_pool_cd=719676)
   JOIN (p1
   WHERE p1.person_id=p.updt_id)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , row + 1,
   "{F/0}{CPI/13}",
   CALL print(calcpos(234,(y_pos+ 11))), "List All Current Physicians",
   row + 1, row + 1, "{CPI/14}",
   CALL print(calcpos(250,(y_pos+ 29))), "With valid Log-In IDs", row + 1,
   y_pos = (y_pos+ 41)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, y_val = ((792 - y_pos) - 44), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  539 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, "{F/0}{CPI/13}",
   CALL print(calcpos(36,(y_pos+ 11))),
   "Log In", row + 1, "{CPI/13}",
   CALL print(calcpos(42,(y_pos+ 21))), "ID", row + 1,
   "{CPI/13}",
   CALL print(calcpos(126,(y_pos+ 22))), "Name",
   row + 1, "{CPI/14}",
   CALL print(calcpos(292,(y_pos+ 21))),
   "CIS Position", row + 1, "{CPI/14}",
   CALL print(calcpos(447,(y_pos+ 12))), "Create/Change", row + 1,
   "{CPI/14}",
   CALL print(calcpos(468,(y_pos+ 22))), "Date",
   row + 1, y_pos = (y_pos+ 37)
  DETAIL
   IF (((y_pos+ 99) >= 792))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,9,p.username), name_full_formatted1 = substring(1,35,p.name_full_formatted
    ), p_position_disp1 = substring(1,32,p_position_disp),
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(37,(y_pos+ 11))),
   username1,
   CALL print(calcpos(89,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(278,(y_pos+ 12))), p_position_disp1,
   CALL print(calcpos(452,(y_pos+ 12))),
   p.updt_dt_tm, y_pos = (y_pos+ 14)
  FOOT PAGE
   y_pos = 725, row + 1,
   CALL print(calcpos(20,(y_pos+ 12))),
   "PROG:", row + 1,
   CALL print(calcpos(51,(y_pos+ 12))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(367,(y_pos+ 10))), "Page:", row + 1,
   CALL print(calcpos(383,(y_pos+ 10))), curpage
  FOOT REPORT
   IF (((y_pos+ 76) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))),
   "Physician Count:", cntmd = format(count(p.name_full_formatted),"####"), row + 1,
   CALL print(calcpos(107,(y_pos+ 12))), cntmd, row + 1,
   CALL print(calcpos(271,(y_pos+ 25))), "End of Report"
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
