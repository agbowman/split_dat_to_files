CREATE PROGRAM drug_utilization
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Please enter the Patient's Last Name " = "*",
  "Enter Drug: " = "*",
  "Enter Date: " = "*"
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SET y_pos = 0
 SELECT INTO  $1
  p1.name_full_formatted, pa.alias, loc_nurse_unit_cdf = uar_get_code_meaning(e.loc_nurse_unit_cd),
  loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), loc_room_cdf =
  uar_get_code_meaning(e.loc_room_cd), loc_room_disp = uar_get_code_display(e.loc_room_cd),
  loc_bed_cdf = uar_get_code_meaning(e.loc_bed_cd), loc_bed_disp = uar_get_code_display(e.loc_bed_cd),
  o.dept_misc_line,
  o.current_start_dt_tm, o.projected_stop_dt_tm, p.person_id,
  p1.person_id, e.person_id, oa.order_provider_id,
  o.order_id, oa.order_id, e.loc_nurse_unit_cd,
  e.loc_room_cd, e.loc_bed_cd, pa.person_id,
  o.order_mnemonic, name = p.name_full_formatted
  FROM orders o,
   order_action oa,
   person p,
   person p1,
   encounter e,
   person_alias pa
  PLAN (p)
   JOIN (oa
   WHERE p.person_id=oa.order_provider_id)
   JOIN (o
   WHERE oa.order_id=o.order_id)
   JOIN (p1
   WHERE o.person_id=p1.person_id)
   JOIN (pa
   WHERE p1.person_id=pa.person_id)
   JOIN (e
   WHERE e.person_id=p1.person_id
    AND p1.name_last_key=patstring(cnvtupper(concat( $2,"*")))
    AND cnvtupper(o.order_mnemonic)=patstring(cnvtupper(concat( $3,"*"))))
  ORDER BY loc_nurse_unit_disp
  HEAD REPORT
   expr1 = format(curdate,"mm/dd/yy;;d"), expr2 = curpage, expr3 = curpage,
   "%!PS-Adobe-2.0  %EndProlog  gsave", row + 1,
   "/VTEX{/txt exch def /y exch def /x exch def /size exch def findfont",
   " size scalefont setfont x y moveto txt show stroke x y moveto} def  ", row + 1,
   "/VLIN{/lw exch def /y2 exch def /x2 exch def /y1 exch def /x1 exch def newpath",
   " lw setlinewidth x1 y1 moveto x2 y2 lineto stroke x1 y1 moveto} def  ", row + 1,
   "/VBOX{/lw exch def /h exch def /w exch def /y exch def /x exch def newpath",
   " lw setlinewidth x y moveto w 0 rlineto 0 h neg rlineto w neg 0 rlineto closepath stroke x y moveto} def  ",
   row + 1,
   "/VEL1{/lw exch def /f1 exch def /ry exch def /rx exch def /y exch def /x exch def gsave newpath",
   " lw setlinewidth 1 ry rx div scale x y rx ry div mul rx 0 360 arc stroke x y moveto grestore} def   ",
   row + 1, dio_mode = 8,
   page_height = 792, row + 1, "/(Times-Roman) 12 20 ",
   CALL print((page_height - (y_pos+ 34))), " (", expr1,
   ")  VTEX ", "/(Garamond) 14 201 ",
   CALL print((page_height - (y_pos+ 35))),
   " (", "Our Lady of the Lake Regional Medical Center", ")  VTEX ",
   row + 1, "/(Garamond) 29 173 ",
   CALL print((page_height - (y_pos+ 73))),
   " (", "Drug Utilization Evaluation", ")  VTEX ",
   row + 1, y_pos = (y_pos+ 77)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 36
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, curpage, order_mnemonic1 = substring(1,30,o.order_mnemonic),
   "/(Courier) 9 16 ",
   CALL print((page_height - (y_pos+ 10))), " (",
   "Page:", ")  VTEX ", "/(Courier) 9 40 ",
   CALL print((page_height - (y_pos+ 10))), " (", expr2,
   ")  VTEX ", "/(Times-BoldItalic) 12 225 ",
   CALL print((page_height - (y_pos+ 13))),
   " (", "Drug Description:", ")  VTEX ",
   "/(Courier) 9 308 ",
   CALL print((page_height - (y_pos+ 11))), " (",
   order_mnemonic1, ")  VTEX ", row + 1,
   y_pos = (y_pos+ 38), row + 1
  HEAD loc_nurse_unit_disp
   row + 1, loc_nurse_unit_disp1 = substring(1,5,loc_nurse_unit_disp), "/(Times-BoldItalic) 10 16 ",
   CALL print((page_height - (y_pos+ 16))), " (", "Nursing Unit:",
   ")  VTEX ", "/(Courier) 9 83 ",
   CALL print((page_height - (y_pos+ 15))),
   " (", loc_nurse_unit_disp1, ")  VTEX ",
   row + 1, "/(Times-Bold) 10 16 ",
   CALL print((page_height - (y_pos+ 51))),
   " (", "Patient Name:", ")  VTEX ",
   "/(Times-Bold) 10 137 ",
   CALL print((page_height - (y_pos+ 65))), " (",
   "Ordering Physician:", ")  VTEX ", "/(Times-Bold) 10 254 ",
   CALL print((page_height - (y_pos+ 68))), " (", "Order:",
   ")  VTEX ", "/(Times-Bold) 10 487 ",
   CALL print((page_height - (y_pos+ 68))),
   " (", "Start Date:", ")  VTEX ",
   "/(Times-Bold) 10 551 ",
   CALL print((page_height - (y_pos+ 68))), " (",
   "End Date:", ")  VTEX ", row + 1,
   "/(Times-Bold) 10 16 ",
   CALL print((page_height - (y_pos+ 69))), " (",
   "MRN #:", ")  VTEX ", row + 1,
   y_pos = (y_pos+ 85)
  DETAIL
   IF (((y_pos+ 86) >= 792))
    y_pos = 0, BREAK
   ENDIF
   row + 1, name_full_formatted1 = substring(1,20,p1.name_full_formatted), dept_misc_line1 =
   substring(1,30,o.dept_misc_line),
   alias1 = substring(1,100,pa.alias), "/(Times-Roman) 8 16 ",
   CALL print((page_height - (y_pos+ 5))),
   " (", name_full_formatted1, ")  VTEX ",
   "/(Times-Roman) 8 139 ",
   CALL print((page_height - (y_pos+ 7))), " (",
   name, ")  VTEX ", "/(Courier) 9 191 ",
   CALL print((page_height - (y_pos+ 20))), " (", alias1,
   ")  VTEX ", "/(Times-Bold) 8 247 ",
   CALL print((page_height - (y_pos+ 6))),
   " (", dept_misc_line1, ")  VTEX ",
   "/(Times-Roman) 8 487 ",
   CALL print((page_height - (y_pos+ 8))), " (",
   o.current_start_dt_tm, ")  VTEX ", "/(Times-Roman) 8 551 ",
   CALL print((page_height - (y_pos+ 9))), " (", o.projected_stop_dt_tm,
   ")  VTEX ", row + 1, alias2 = substring(1,15,pa.alias),
   alias3 = substring(1,100,pa.alias), "/(Courier) 9 17 ",
   CALL print((page_height - (y_pos+ 23))),
   " (", alias2, ")  VTEX ",
   "/(Courier) 9 132 ",
   CALL print((page_height - (y_pos+ 33))), " (",
   alias3, ")  VTEX ", row + 1,
   row- (2), "/(Courier) 9 516 ",
   CALL print((page_height - (y_pos+ 49))),
   " (", p.person_id, ")  VTEX ",
   y_pos = (y_pos+ 66), row + 1
  FOOT  loc_nurse_unit_disp
   row + 1, "/(Times-Bold) 10 16 ",
   CALL print((page_height - (y_pos+ 9))),
   " (", "Patient Subtotal:", ")  VTEX ",
   "/(Courier) 9 91 ",
   CALL print((page_height - (y_pos+ 7))), " (",
   count(p1.name_full_formatted), ")  VTEX ", y_pos = (y_pos+ 36)
  FOOT PAGE
   row + 1, "showpage", y_pos = 0
  FOOT REPORT
   row + 1, "grestore"
  WITH maxrec = 10, maxcol = 1000, maxrow = 1,
   time = value(maxsecs), noheading, format = variable
 ;end select
END GO
