CREATE PROGRAM djh_omf_app_ctx_day_st_v2
 PROMPT
  "CIS ID:" = 0,
  "Output to File/Printer/MINE" = "MINE"
  WITH cisid, outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 60
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  oa.person_id, p.person_id, oa.frequency,
  p.username, oa.log_ins, p.name_full_formatted,
  oa.minutes, newstday = format(oa.start_day,"yyyy-mm-dd;;d"), oa.start_day,
  p.physician_ind, p.active_ind
  FROM omf_app_ctx_day_st oa,
   prsnl p
  PLAN (oa
   WHERE oa.person_id != 1
    AND oa.person_id != 2
    AND oa.person_id != 3
    AND oa.start_day > cnvtdatetime(cnvtdate(010106),0))
   JOIN (p
   WHERE oa.person_id=p.person_id
    AND p.active_ind=1)
  ORDER BY p.person_id, newstday DESC
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(250,(y_pos+ 11))), "With valid Log-In IDs",
   row + 1, y_pos = (y_pos+ 23)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, "{F/0}{CPI/13}",
   CALL print(calcpos(36,(y_pos+ 11))),
   "Log In",
   CALL print(calcpos(42,(y_pos+ 26))), "ID",
   CALL print(calcpos(126,(y_pos+ 26))), "Name", row + 1,
   row + 1, y_val = ((792 - y_pos) - 56), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  449 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 48)
  FOOT PAGE
   y_pos = 725, row + 1,
   CALL print(calcpos(20,(y_pos+ 12))),
   "PROG:", row + 1,
   CALL print(calcpos(51,(y_pos+ 12))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(367,(y_pos+ 10))), "Page:", row + 1,
   CALL print(calcpos(383,(y_pos+ 10))), curpage
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
