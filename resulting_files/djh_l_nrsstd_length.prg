CREATE PROGRAM djh_l_nrsstd_length
 PROMPT
  "Number of Days Back" = 0,
  "Output to File/Printer/MINE" = "MINE"
  WITH dybk, outdev
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
  actcd = evaluate(p.active_ind,1," ",2,"*"), p.username, idlen = textlen(p.username),
  p.name_full_formatted, p.position_cd"#########", p_position_disp = uar_get_code_display(p
   .position_cd),
  p.beg_effective_dt_tm, p.updt_dt_tm"@SHORTDATETIME", newdt = format(p.updt_dt_tm,"yyyy-mm-dd"),
  p.updt_id"#########", p.updt_task, p.create_prsnl_id"#########",
  newdays = format( $DYBK,"##"), expr1 = curprog
  FROM prsnl p
  WHERE p.updt_dt_tm >= cnvtdatetime((curdate - 10),0)
   AND p.updt_dt_tm <= cnvtdatetime(curdate,235959)
   AND p.position_cd=457
   AND p.updt_id != 99999999
  ORDER BY newdt, p.name_full_formatted
  HEAD REPORT
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 0))), curdate,
   row + 1,
   CALL print(calcpos(90,(y_pos+ 0))), "Back",
   row + 1,
   CALL print(calcpos(109,(y_pos+ 0))), newdays,
   row + 1,
   CALL print(calcpos(123,(y_pos+ 0))), "days",
   CALL print(calcpos(351,(y_pos+ 0))), "Nurse Student IDs", row + 1,
   CALL print(calcpos(20,(y_pos+ 24))), "In",
   CALL print(calcpos(20,(y_pos+ 33))),
   "Act", row + 1, y_val = ((792 - y_pos) - 58),
   "{PS/newpath 2 setlinewidth   19 ", y_val, " moveto  729 ",
   y_val, " lineto stroke 19 ", y_val,
   " moveto/}",
   CALL print(calcpos(45,(y_pos+ 24))), "Log-In",
   CALL print(calcpos(54,(y_pos+ 35))), "ID",
   CALL print(calcpos(119,(y_pos+ 35))),
   "User Name",
   CALL print(calcpos(291,(y_pos+ 36))), "CIS Position",
   CALL print(calcpos(434,(y_pos+ 27))), "Start", row + 1,
   CALL print(calcpos(437,(y_pos+ 36))), "Date",
   CALL print(calcpos(473,(y_pos+ 35))),
   "|  Date / Time  |",
   CALL print(calcpos(499,(y_pos+ 27))), "Change",
   CALL print(calcpos(571,(y_pos+ 34))), "Created / Changed by", row + 1,
   y_pos = (y_pos+ 60)
  DETAIL
   IF (((y_pos+ 97) >= 612))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,9,p.username), name_full_formatted1 = substring(1,30,p.name_full_formatted
    ), p_position_disp1 = substring(1,32,p_position_disp),
   name_full_formatted2 = substring(1,30,p1.name_full_formatted), row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(22,(y_pos+ 0))), actcd,
   row + 1,
   CALL print(calcpos(41,(y_pos+ 0))), username1,
   CALL print(calcpos(95,(y_pos+ 0))), name_full_formatted1,
   CALL print(calcpos(255,(y_pos+ 0))),
   p_position_disp1,
   CALL print(calcpos(425,(y_pos+ 0))), p.beg_effective_dt_tm,
   CALL print(calcpos(473,(y_pos+ 0))), p.updt_dt_tm,
   CALL print(calcpos(571,(y_pos+ 0))),
   name_full_formatted2, y_pos = (y_pos+ 13)
  FOOT PAGE
   y_pos = 546, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))), "Prgm:", row + 1,
   CALL print(calcpos(47,(y_pos+ 0))), curprog, row + 1,
   CALL print(calcpos(504,(y_pos+ 0))), "Page", cntpg = format(curpage,"###"),
   row + 1,
   CALL print(calcpos(527,(y_pos+ 0))), cntpg
  FOOT REPORT
   IF (((y_pos+ 62) >= 612))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))),
   "Recs Added/Changed:", x = format(count(p.name_full_formatted),"###"), row + 1,
   CALL print(calcpos(121,(y_pos+ 0))), x, row + 1,
   CALL print(calcpos(361,(y_pos+ 0))), "End of Report"
  WITH maxcol = 300, maxrow = 500, dio = 08,
   landscape, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
