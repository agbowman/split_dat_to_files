CREATE PROGRAM djh_l_prsnl_by_slct_pos
 PROMPT
  "Position:",
  "Output to File/Printer/MINE" = "MINE"
  WITH poscd, outdev
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
  p.active_ind, p.name_full_formatted, p.person_id,
  p_position_disp = uar_get_code_display(p.position_cd), p.position_cd, p.username,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id, p1.name_full_formatted
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE (p.position_cd= $POSCD)
    AND p.active_ind=1)
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY p_position_disp, p.name_full_formatted
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(36,(y_pos+ 0))), curdate,
   row + 1,
   CALL print(calcpos(216,(y_pos+ 1))), p_position_disp,
   row + 1, row + 1, y_val = ((792 - y_pos) - 36),
   "{PS/newpath 2 setlinewidth   29 ", y_val, " moveto  528 ",
   y_val, " lineto stroke 29 ", y_val,
   " moveto/}", row + 1, y_pos = (y_pos+ 39)
  DETAIL
   IF (((y_pos+ 68) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,35,p.name_full_formatted), username1 = substring(1,12,p
    .username), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(34,(y_pos+ 0))), name_full_formatted1,
   CALL print(calcpos(209,(y_pos+ 1))), username1,
   CALL print(calcpos(274,(y_pos+ 1))),
   p.beg_effective_dt_tm,
   CALL print(calcpos(329,(y_pos+ 1))), p.updt_dt_tm,
   y_pos = (y_pos+ 14)
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
