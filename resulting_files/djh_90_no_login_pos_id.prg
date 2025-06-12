CREATE PROGRAM djh_90_no_login_pos_id
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
  SET maxsecs = 300
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  p.active_ind, p.username, p.person_id,
  p.name_full_formatted, p.position_cd, p_position_disp = uar_get_code_display(p.position_cd),
  p.updt_dt_tm, oa.start_day, oa.person_id,
  d1.user
  FROM prsnl p,
   omf_app_ctx_day_st oa,
   dummyt d1
  PLAN (p
   WHERE p.active_ind=1
    AND p.username > " "
    AND p.updt_dt_tm < cnvtdatetime((curdate - 90),0)
    AND p.position_cd=634812)
   JOIN (d1)
   JOIN (oa
   WHERE oa.person_id=p.person_id
    AND ((oa.start_day < cnvtdatetime((curdate - 90),0)) OR (oa.start_day=null)) )
  ORDER BY p.name_full_formatted
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   ,
   CALL print(calcpos(51,(y_pos+ 12))),
   "Today:", row + 1,
   CALL print(calcpos(92,(y_pos+ 12))),
   curdate, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(260,(y_pos+ 11))), "90 Day No Activity", row + 1,
   y_pos = (y_pos+ 24)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, y_val = ((792 - y_pos) - 48), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  556 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   CALL print(calcpos(46,(y_pos+ 23))), "Name", row + 1,
   "{F/0}{CPI/13}",
   CALL print(calcpos(193,(y_pos+ 10))), "Log In",
   CALL print(calcpos(200,(y_pos+ 22))), "ID", row + 1,
   y_pos = (y_pos+ 40)
  DETAIL
   IF (((y_pos+ 100) >= 792))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,13,p.username), name_full_formatted1 = substring(1,30,p
    .name_full_formatted), p_position_disp1 = substring(1,33,p_position_disp),
   CALL print(calcpos(20,(y_pos+ 11))), name_full_formatted1, row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(182,(y_pos+ 10))), username1,
   CALL print(calcpos(254,(y_pos+ 12))), p_position_disp1,
   CALL print(calcpos(432,(y_pos+ 13))),
   p.updt_dt_tm, y_pos = (y_pos+ 15)
  FOOT PAGE
   y_pos = 725, row + 1,
   CALL print(calcpos(20,(y_pos+ 12))),
   "PROG:", row + 1,
   CALL print(calcpos(51,(y_pos+ 12))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(367,(y_pos+ 10))), "Page:", row + 1,
   CALL print(calcpos(383,(y_pos+ 10))), curpage
  WITH maxcol = 300, maxrow = 500, dio = 08,
   format, separator = value(_separator), time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
