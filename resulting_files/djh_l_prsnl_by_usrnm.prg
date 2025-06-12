CREATE PROGRAM djh_l_prsnl_by_usrnm
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
  p.active_ind"##", p.active_status_cd, p_active_status_disp = uar_get_code_display(p
   .active_status_cd),
  p.username, p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd),
  p.beg_effective_dt_tm, p.updt_dt_tm, p.person_id
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind >= 1
    AND ((p.username="dummydjh") OR (((p.username="*64028*") OR (((p.username="*71749*") OR (((p
   .username="*69169*") OR (((p.username="*69997*") OR (((p.username="*98095*") OR (((p.username=
   "*71764*") OR (((p.username="*03181*") OR (((p.username="*70393*") OR (p.username="*99078*")) ))
   )) )) )) )) )) )) )) )
  ORDER BY p.name_full_formatted, p.username
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1,
   CALL print(calcpos(36,(y_pos+ 1))),
   curdate, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(231,(y_pos+ 0))), "Super Users - June 2006", row + 1,
   row + 1, y_val = ((792 - y_pos) - 37), "{PS/newpath 2 setlinewidth   29 ",
   y_val, " moveto  528 ", y_val,
   " lineto stroke 29 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 40)
  DETAIL
   IF (((y_pos+ 70) >= 792))
    y_pos = 0, BREAK
   ENDIF
   p_position_disp1 = substring(1,33,p_position_disp), name_full_formatted1 = substring(1,35,p
    .name_full_formatted), username1 = substring(1,12,p.username),
   CALL print(calcpos(21,(y_pos+ 3))), p.active_ind,
   CALL print(calcpos(56,(y_pos+ 3))),
   username1,
   CALL print(calcpos(123,(y_pos+ 2))), name_full_formatted1,
   CALL print(calcpos(309,(y_pos+ 1))), p_position_disp1, row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(484,(y_pos+ 0))), p.updt_dt_tm,
   y_pos = (y_pos+ 16)
  WITH maxcol = 300, maxrow = 500, dio = 08,
   format, separator = value(_separator), time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
