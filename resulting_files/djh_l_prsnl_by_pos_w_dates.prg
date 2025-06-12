CREATE PROGRAM djh_l_prsnl_by_pos_w_dates
 PROMPT
  "Position Code",
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
  pr.name_full_formatted, pr.username, pr.active_ind,
  pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd), pr.physician_ind,
  pr.beg_effective_dt_tm, pr.end_effective_dt_tm, pr.updt_dt_tm
  FROM prsnl pr
  WHERE pr.active_ind=1
   AND (pr.position_cd= $POSCD)
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , row + 1,
   "{F/0}{CPI/11}",
   CALL print(calcpos(194,(y_pos+ 11))), "List Active Log-In IDs with Dates",
   row + 1, y_pos = (y_pos+ 24)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, y_val = ((792 - y_pos) - 61), "{PS/newpath 2 setlinewidth   38 ",
   y_val, " moveto  523 ", y_val,
   " lineto stroke 38 ", y_val, " moveto/}",
   row + 1,
   CALL print(calcpos(40,(y_pos+ 13))), curdate,
   CALL print(calcpos(48,(y_pos+ 34))), "Log-In ID", row + 1,
   CALL print(calcpos(121,(y_pos+ 21))), "phys",
   CALL print(calcpos(122,(y_pos+ 33))),
   "flg",
   CALL print(calcpos(169,(y_pos+ 33))), "Person Name",
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(200,(y_pos+ 11))),
   pr_position_disp,
   CALL print(calcpos(347,(y_pos+ 35))), "| Begin     End     UpDate |",
   CALL print(calcpos(347,(y_pos+ 24))), "|--------- Dates ----------|", row + 1,
   y_pos = (y_pos+ 41)
  DETAIL
   IF (((y_pos+ 97) >= 792))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,12,pr.username), name_full_formatted1 = substring(1,35,pr
    .name_full_formatted), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(56,(y_pos+ 11))), username1,
   physflg = evaluate(pr.physician_ind,0,"",1,"*",
    2,"2"), row + 1,
   CALL print(calcpos(125,(y_pos+ 11))),
   physflg, row + 1,
   CALL print(calcpos(160,(y_pos+ 11))),
   name_full_formatted1,
   CALL print(calcpos(348,(y_pos+ 11))), pr.beg_effective_dt_tm,
   CALL print(calcpos(398,(y_pos+ 11))), pr.end_effective_dt_tm,
   CALL print(calcpos(447,(y_pos+ 11))),
   pr.updt_dt_tm, y_pos = (y_pos+ 13)
  FOOT PAGE
   y_pos = 726, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(44,(y_pos+ 11))), curprog,
   row + 1,
   CALL print(calcpos(342,(y_pos+ 11))), "Page:",
   row + 1,
   CALL print(calcpos(362,(y_pos+ 11))), curpage
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
