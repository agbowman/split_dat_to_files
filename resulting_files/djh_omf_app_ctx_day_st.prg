CREATE PROGRAM djh_omf_app_ctx_day_st
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
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  oa.application_number, oa.frequency, oa.log_ins,
  oa.minutes, oa.person_id, oa.rowid,
  oa.start_day
  FROM omf_app_ctx_day_st oa
  WHERE (oa.person_id= $CISID)
  ORDER BY oa.start_day DESC
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
