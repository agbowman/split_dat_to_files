CREATE PROGRAM djh_l_all_cer_ids
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
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
  actcd = evaluate(p.active_ind,1," ",2,"*"), statcd = evaluate(p.active_status_cd,194.00,"S",192.00,
   "I",
   188.00,""), p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username, p.name_full_formatted,
  p.position_cd"#########", p_position_disp = uar_get_code_display(p.position_cd), p
  .beg_effective_dt_tm,
  p.end_effective_dt_tm, p.updt_dt_tm"@SHORTDATETIME", newdt = format(p.updt_dt_tm,"yyyy-mm-dd"),
  newenddt = format(p.end_effective_dt_tm,"yyyy-mm-dd"), p.updt_id"#########", p.updt_task,
  p.create_prsnl_id"#########", p1.name_full_formatted, p.active_ind
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE p.username="CER*"
    AND p.username != "CERSUP*"
    AND p.username != "CERNSUP"
    AND p.username != "CERNER")
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY newenddt DESC, p.beg_effective_dt_tm, p.name_full_formatted,
   p_position_disp
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 0))), curdate,
   row + 1,
   CALL print(calcpos(187,(y_pos+ 0))), "List of Suspended / InActivated PN Log-In IDs",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 24))), "In",
   CALL print(calcpos(20,(y_pos+ 33))), "Act", row + 1,
   y_val = ((792 - y_pos) - 59), "{PS/newpath 2 setlinewidth   20 ", y_val,
   " moveto  538 ", y_val, " lineto stroke 20 ",
   y_val, " moveto/}",
   CALL print(calcpos(45,(y_pos+ 24))),
   "Log-In",
   CALL print(calcpos(54,(y_pos+ 35))), "ID",
   CALL print(calcpos(119,(y_pos+ 35))), "User Name",
   CALL print(calcpos(291,(y_pos+ 36))),
   "CIS Position",
   CALL print(calcpos(438,(y_pos+ 27))), "Start",
   CALL print(calcpos(442,(y_pos+ 36))), "Date",
   CALL print(calcpos(482,(y_pos+ 27))),
   "Effective",
   CALL print(calcpos(482,(y_pos+ 35))), "End Date",
   row + 1, y_pos = (y_pos+ 62)
  DETAIL
   IF (((y_pos+ 97) >= 792))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,12,p.username), name_full_formatted1 = substring(1,30,p
    .name_full_formatted), p_position_disp1 = substring(1,32,p_position_disp),
   row + 1, "{F/0}{CPI/14}", row + 1,
   CALL print(calcpos(20,(y_pos+ 0))), actcd, row + 1,
   CALL print(calcpos(25,(y_pos+ 0))), statcd, row + 1,
   CALL print(calcpos(41,(y_pos+ 0))), username1,
   CALL print(calcpos(108,(y_pos+ 0))),
   name_full_formatted1,
   CALL print(calcpos(268,(y_pos+ 0))), p_position_disp1,
   CALL print(calcpos(434,(y_pos+ 0))), p.beg_effective_dt_tm, row + 1,
   CALL print(calcpos(480,(y_pos+ 0))), newenddt, y_pos = (y_pos+ 13)
  FOOT  p.name_full_formatted
   y_pos = (y_pos+ 0)
  FOOT PAGE
   y_pos = 726, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))), "Prgm:", row + 1,
   CALL print(calcpos(47,(y_pos+ 0))), curprog, row + 1,
   CALL print(calcpos(372,(y_pos+ 0))), "Page", cntpg = format(curpage,"###"),
   row + 1,
   CALL print(calcpos(396,(y_pos+ 0))), cntpg
  FOOT REPORT
   IF (((y_pos+ 62) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))),
   "Suspended Count:", x = format(count(p.name_full_formatted),"###"), row + 1,
   CALL print(calcpos(104,(y_pos+ 0))), x, row + 1,
   CALL print(calcpos(271,(y_pos+ 0))), "End of Report"
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
