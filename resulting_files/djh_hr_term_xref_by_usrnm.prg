CREATE PROGRAM djh_hr_term_xref_by_usrnm
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
   .active_status_cd)"#",
  p.username, p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd),
  p.beg_effective_dt_tm, p.updt_dt_tm, p.person_id,
  p.physician_ind
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind >= 0
    AND p.active_status_cd != 194
    AND p.active_status_cd != 189
    AND ((p.username="dummydjh") OR (((p.username="*10948*") OR (((p.username="*03017*") OR (((p
   .username="*12145*") OR (((p.username="*48791*") OR (((p.username="*11441*") OR (((p.username=
   "*12052*") OR (((p.username="*44218*") OR (((p.username="*48966*") OR (((p.username="*04866*") OR
   (((p.username="*00944*") OR (((p.username="*45215*") OR (((p.username="*43577*") OR (((p.username=
   "*10259*") OR (((p.username="*10967*") OR (((p.username="*44413*") OR (((p.username="*47413*") OR
   (((p.username="*03182*") OR (((p.username="*48881*") OR (((p.username="*41232*") OR (((p.username=
   "*48478*") OR (((p.username="*48308*") OR (((p.username="*12478*") OR (((p.username="*11092*") OR
   (((p.username="*47966*") OR (((p.username="*49055*") OR (((p.username="*11138*") OR (((p.username=
   "*46147*") OR (((p.username="*02481*") OR (((p.username="*46744*") OR (((p.username="*47182*") OR
   (((p.username="*08628*") OR (((p.username="*12177*") OR (((p.username="*10650*") OR (((p.username=
   "*45406*") OR (((p.username="*12022*") OR (((p.username="*45398*") OR (((p.username="*48181*") OR
   (((p.username="*00766*") OR (((p.username="*12224*") OR (((p.username="*26384*") OR (((p.username=
   "*11910*") OR (((p.username="*00291*") OR (((p.username="*12018*") OR (((p.username="*05639*") OR
   (((p.username="*45426*") OR (((p.username="*49418*") OR (((p.username="*47175*") OR (((p.username=
   "*10324*") OR (((p.username="*44734*") OR (((p.username="*00947*") OR (((p.username="*46501*") OR
   (p.username="*11351*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
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
   CALL print(calcpos(231,(y_pos+ 0))), "HR Term xRef List by UserName", row + 1,
   row + 1, y_val = ((792 - y_pos) - 36), "{PS/newpath 2 setlinewidth   21 ",
   y_val, " moveto  573 ", y_val,
   " lineto stroke 21 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 39)
  DETAIL
   IF (((y_pos+ 69) >= 792))
    y_pos = 0, BREAK
   ENDIF
   p_position_disp1 = substring(1,33,p_position_disp), name_full_formatted1 = substring(1,35,p
    .name_full_formatted), p_active_status_disp1 = substring(1,1,p_active_status_disp),
   username1 = substring(1,12,p.username),
   CALL print(calcpos(21,(y_pos+ 2))), p.active_ind,
   CALL print(calcpos(44,(y_pos+ 2))), p_active_status_disp1,
   CALL print(calcpos(56,(y_pos+ 2))),
   username1,
   CALL print(calcpos(125,(y_pos+ 1))), name_full_formatted1,
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(313,(y_pos+ 0))),
   p_position_disp1,
   CALL print(calcpos(496,(y_pos+ 0))), p.updt_dt_tm,
   y_pos = (y_pos+ 15)
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
