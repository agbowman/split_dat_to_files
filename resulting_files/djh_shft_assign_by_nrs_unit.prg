CREATE PROGRAM djh_shft_assign_by_nrs_unit
 PROMPT
  "Nurse Unit" = "",
  "Output to File/Printer/MINE" = "MINE"
  WITH nrsunit, outdev
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
  p.active_ind, pg.active_ind, p.data_status_prsnl_id,
  p.updt_dt_tm, p.prsnl_group_class_cd, p_prsnl_group_class_disp = uar_get_code_display(p
   .prsnl_group_class_cd),
  p.prsnl_group_desc, p.prsnl_group_id, pg.prsnl_group_id,
  pg.person_id, pr.name_full_formatted, pr.person_id,
  pr.active_ind, pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd),
  pr.username
  FROM prsnl_group p,
   prsnl_group_reltn pg,
   prsnl pr
  PLAN (p
   WHERE p.prsnl_group_class_cd=647082.00
    AND (p.prsnl_group_desc= $NRSUNIT))
   JOIN (pg
   WHERE p.prsnl_group_id=pg.prsnl_group_id
    AND pg.active_ind=1)
   JOIN (pr
   WHERE pg.person_id=pr.person_id
    AND pr.active_ind=1)
  ORDER BY p.prsnl_group_desc, pr.name_full_formatted
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1, "{F/1}{CPI/10}",
   CALL print(calcpos(166,(y_pos+ 0))), "Shift Assignments by Nurse Unit", row + 1,
   row + 1, "{F/0}{CPI/14}", row + 1,
   CALL print(calcpos(287,(y_pos+ 18))), curdate, row + 1,
   y_pos = (y_pos+ 41)
  HEAD p.prsnl_group_desc
   IF (((y_pos+ 86) >= 792))
    y_pos = 0, BREAK
   ENDIF
   prsnl_group_desc1 = substring(1,40,p.prsnl_group_desc), row + 1, y_val = ((792 - y_pos) - 10),
   "{PS/newpath 2 setlinewidth   56 ", y_val, " moveto  523 ",
   y_val, " lineto stroke 56 ", y_val,
   " moveto/}", row + 1, "{CPI/13}",
   row + 1,
   CALL print(calcpos(56,(y_pos+ 9))), prsnl_group_desc1,
   row + 1, y_pos = (y_pos+ 32)
  DETAIL
   IF (((y_pos+ 98) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,35,pr.name_full_formatted), username1 = substring(1,10,pr
    .username),
   CALL print(calcpos(72,(y_pos+ 1))),
   name_full_formatted1,
   CALL print(calcpos(257,(y_pos+ 1))), username1,
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(319,(y_pos+ 0))),
   pr_position_disp, y_pos = (y_pos+ 14)
  FOOT  p.prsnl_group_desc
   IF (((y_pos+ 78) >= 792))
    y_pos = 0, BREAK
   ENDIF
   y_pos = (y_pos+ 12), row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(56,(y_pos+ 0))), "Staff Count:", cntstaff = count(pr.active_ind),
   row + 1,
   CALL print(calcpos(120,(y_pos+ 0))), cntstaff,
   row + 1,
   CALL print(calcpos(360,(y_pos+ 1))), "Page:",
   row + 1,
   CALL print(calcpos(387,(y_pos+ 0))), curpage,
   row + 1,
   CALL print(calcpos(450,(y_pos+ 0))), BREAK,
   y_pos = (y_pos+ 12)
  FOOT PAGE
   y_pos = 726, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(56,(y_pos+ 0))), curprog
  FOOT REPORT
   IF (((y_pos+ 62) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(271,(y_pos+ 0))),
   "End of Report"
  WITH maxcol = 300, maxrow = 500, nolandscape,
   dio = 08, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
