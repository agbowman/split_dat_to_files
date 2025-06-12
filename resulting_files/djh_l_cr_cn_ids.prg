CREATE PROGRAM djh_l_cr_cn_ids
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
  p.active_ind, p.username, md = evaluate(p.physician_ind,1,"MD",0,"  "),
  p.physician_ind, p.name_full_formatted, p.person_id,
  p_position_disp = uar_get_code_display(p.position_cd), p.position_cd, p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.updt_dt_tm, p.updt_id,
  p1.name_full_formatted
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE ((p.username="CN*") OR (p.username="CR*"))
    AND p.active_ind=1
    AND p.position_cd > 0)
   JOIN (p1
   WHERE p1.person_id=p.updt_id)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   ,
   row + 1, "{F/0}{CPI/10}",
   CALL print(calcpos(255,(y_pos+ 11))),
   "Active CR and CN Prefix Log-In IDs", row + 1, y_pos = (y_pos+ 27)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(458,(y_pos+ 11))), "Date", row + 1,
   row + 1, "{CPI/15}",
   CALL print(calcpos(20,(y_pos+ 29))),
   "Log-In ID", row + 1, "{CPI/14}",
   CALL print(calcpos(108,(y_pos+ 29))), "User Name",
   CALL print(calcpos(288,(y_pos+ 29))),
   "CIS Position",
   CALL print(calcpos(429,(y_pos+ 29))), "| Start -  Chng |",
   CALL print(calcpos(527,(y_pos+ 29))), "Created / Changed by", row + 1,
   row + 1, y_val = ((792 - y_pos) - 57), "{PS/newpath 1 setlinewidth   20 ",
   y_val, " moveto  718 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 48)
  DETAIL
   IF (((y_pos+ 97) >= 612))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,10,p.username), name_full_formatted1 = substring(1,30,p
    .name_full_formatted), p_position_disp1 = substring(1,32,p_position_disp),
   name_full_formatted2 = substring(1,30,p1.name_full_formatted), row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))), username1,
   CALL print(calcpos(79,(y_pos+ 11))),
   name_full_formatted1, row + 1,
   CALL print(calcpos(239,(y_pos+ 11))),
   md, row + 1,
   CALL print(calcpos(259,(y_pos+ 11))),
   p_position_disp1,
   CALL print(calcpos(431,(y_pos+ 11))), p.beg_effective_dt_tm,
   CALL print(calcpos(477,(y_pos+ 11))), p.updt_dt_tm,
   CALL print(calcpos(526,(y_pos+ 11))),
   name_full_formatted2, y_pos = (y_pos+ 13)
  FOOT PAGE
   y_pos = 546, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(370,(y_pos+ 11))), "Page:", row + 1,
   CALL print(calcpos(396,(y_pos+ 11))), curpage
  FOOT REPORT
   IF (((y_pos+ 66) >= 612))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))),
   "Record Count:", cntrec = format(count(p.username),"####"), row + 1,
   CALL print(calcpos(92,(y_pos+ 12))), cntrec, row + 1,
   CALL print(calcpos(361,(y_pos+ 13))), "End of Report", row + 1,
   CALL print(calcpos(478,(y_pos+ 14))), curprog
  WITH maxcol = 300, maxrow = 500, landscape,
   dio = 08, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
