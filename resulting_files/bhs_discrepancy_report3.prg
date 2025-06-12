CREATE PROGRAM bhs_discrepancy_report3
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
  r_activity_disp = uar_get_code_display(r.activity_cd), r.rad_init_read_id, r.read_text,
  r.updt_cnt, r.updt_dt_tm, r.updt_id,
  p.person_id, p.name_full_formatted, i.patient_name,
  i.study_description
  FROM rad_init_read r,
   prsnl p,
   im_acquired_study i
  PLAN (p)
   JOIN (r
   WHERE p.person_id=r.updt_id)
   JOIN (i
   WHERE i.im_acquired_study_id=r.consultation_cd
    AND r.rad_init_read_id != 0)
  HEAD REPORT
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   ,
   row + 1, "{F/9}{CPI/9}",
   CALL print(calcpos(314,(y_pos+ 11))),
   "Discrepancy Readings", row + 1, y_pos = (y_pos+ 29)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/9}{CPI/10}",
   CALL print(calcpos(20,(y_pos+ 11))), "{U}Physician{ENDU}",
   CALL print(calcpos(288,(y_pos+ 11))),
   "{U}Patient ID{ENDU}",
   CALL print(calcpos(504,(y_pos+ 11))), "{U}Response and Comments with Date{ENDU}",
   row + 1, y_pos = (y_pos+ 27)
  DETAIL
   IF (((y_pos+ 89) >= 612))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,30,p.name_full_formatted), r_activity_disp1 = substring(1,15,
    r_activity_disp), read_text1 = substring(1,20,r.read_text),
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))),
   name_full_formatted1,
   CALL print(calcpos(270,(y_pos+ 11))), p.person_id,
   CALL print(calcpos(504,(y_pos+ 11))), r_activity_disp1,
   CALL print(calcpos(594,(y_pos+ 11))),
   read_text1, row + 1, row + 1,
   y_val = ((792 - y_pos) - 52), "{PS/newpath 2 setlinewidth   18 ", y_val,
   " moveto  771 ", y_val, " lineto stroke 18 ",
   y_val, " moveto/}",
   CALL print(calcpos(594,(y_pos+ 29))),
   r.updt_dt_tm, y_pos = (y_pos+ 35)
  WITH maxrec = 9999, maxcol = 300, maxrow = 500,
   landscape, dio = 08, format,
   separator = value(_separator), time = value(maxsecs), skipreport = 1
 ;end select
END GO
