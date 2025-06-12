CREATE PROGRAM djh_90_no_login_rpt
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
  p.updt_dt_tm, oa.start_day, oa.application_number,
  oa.frequency, oa.log_ins, oa.minutes,
  oa.person_id, d1.user
  FROM prsnl p,
   omf_app_ctx_day_st oa,
   dummyt d1
  PLAN (p
   WHERE p.active_ind=1
    AND p.username > " "
    AND p.updt_dt_tm < cnvtdatetime((curdate - 90),0)
    AND p.position_cd > 0
    AND p.position_cd != 966300
    AND p.position_cd != 719476
    AND p.position_cd != 925837
    AND p.position_cd != 925824
    AND p.position_cd != 925825
    AND p.position_cd != 925828
    AND p.position_cd != 925830
    AND p.position_cd != 925831
    AND p.position_cd != 925832
    AND p.position_cd != 925833
    AND p.position_cd != 925834
    AND p.position_cd != 925836
    AND p.position_cd != 925844
    AND p.position_cd != 925847
    AND p.position_cd != 925852
    AND p.position_cd != 925843
    AND p.position_cd != 441
    AND p.position_cd != 686743
    AND p.position_cd != 786870
    AND p.position_cd != 20377776
    AND p.position_cd != 966301
    AND p.position_cd != 925826
    AND p.position_cd != 925845
    AND p.position_cd != 925848
    AND p.position_cd != 925841)
   JOIN (d1)
   JOIN (oa
   WHERE p.person_id=oa.person_id
    AND oa.start_day < cnvtdatetime((curdate - 90),0))
  ORDER BY p.username
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
   format, separator = value(_separator), time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
