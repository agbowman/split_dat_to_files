CREATE PROGRAM djh_l_prsnl_term_id_chk
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
  p.active_ind"##", p_active_status_disp = uar_get_code_display(p.active_status_cd), p.username,
  p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm,
  p.updt_dt_tm, p.person_id, p.position_cd,
  p.end_effective_dt_tm, p.updt_id, p1.name_full_formatted,
  p.physician_ind
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE p.active_ind >= 1
    AND p.active_status_cd=188
    AND p.username != "DUM*"
    AND p.physician_ind != 1
    AND ((p.username="*11778*") OR (((p.username="*11857*") OR (((p.username="*11640*") OR (((p
   .username="*06440*") OR (((p.username="*47317*") OR (((p.username="*11245*") OR (((p.username=
   "*01520*") OR (((p.username="*11017*") OR (((p.username="*11227*") OR (((p.username="*10748*") OR
   (((p.username="*10371*") OR (((p.username="*40526*") OR (((p.username="*45464*") OR (((p.username=
   "*40952*") OR (((p.username="*01623*") OR (((p.username="*11995*") OR (((p.username="*23445*") OR
   (((p.username="*48885*") OR (((p.username="*01599*") OR (((p.username="*47153*") OR (((p.username=
   "*03459*") OR (((p.username="*06987*") OR (((p.username="*47143*") OR (((p.username="*24963*") OR
   (((p.username="*49106*") OR (((p.username="*11799*") OR (((p.username="*47040*") OR (((p.username=
   "*47353*") OR (((p.username="*49334*") OR (((p.username="*48339*") OR (((p.username="*49415*") OR
   (((p.username="*11723*") OR (((p.username="*46414*") OR (((p.username="*49387*") OR (((p.username=
   "*48743*") OR (((p.username="*11893*") OR (((p.username="*10356*") OR (((p.username="*48883*") OR
   (((p.username="*11533*") OR (((p.username="*11732*") OR (((p.username="*11704*") OR (((p.username=
   "*44740*") OR (((p.username="*12038*") OR (((p.username="*08474*") OR (((p.username="*44300*") OR
   (((p.username="*00170*") OR (((p.username="*11526*") OR (((p.username="*47709*") OR (((p.username=
   "*05960*") OR (p.username="*46918*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY p.username, p.name_full_formatted
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
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
