CREATE PROGRAM dmd_outerjoin2
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, p.person_id, e.person_id,
  encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e.encntr_id, o.encntr_id,
  o.order_mnemonic, o.order_id
  FROM person p,
   encounter e,
   orders o,
   dummyt d1
  PLAN (p)
   JOIN (e
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (o
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   expr1 = fillstring(95,"="), expr2 = format(curdate,"MMM DD, YYYY;;D"),
   "%!PS-Adobe-2.0  %EndProlog  gsave",
   row + 1, "/VTEX{/txt exch def /y exch def /x exch def /size exch def findfont",
   " size scalefont setfont x y moveto txt show stroke x y moveto} def  ",
   row + 1, "/VLIN{/lw exch def /y2 exch def /x2 exch def /y1 exch def /x1 exch def newpath",
   " lw setlinewidth x1 y1 moveto x2 y2 lineto stroke x1 y1 moveto} def  ",
   row + 1, "/VBOX{/lw exch def /h exch def /w exch def /y exch def /x exch def newpath",
   " lw setlinewidth x y moveto w 0 rlineto 0 h neg rlineto w neg 0 rlineto closepath stroke x y moveto} def  ",
   row + 1,
   "/VEL1{/lw exch def /f1 exch def /ry exch def /rx exch def /y exch def /x exch def gsave newpath",
   " lw setlinewidth 1 ry rx div scale x y rx ry div mul rx 0 360 arc stroke x y moveto grestore} def   ",
   row + 1, dio_mode = 8, page_height = 792,
   y_pos = 18, row + 1, "152",
   CALL print((page_height - (y_pos+ 32))), " 222 29 2 VBOX  ", "/(Courier-Bold) 12 162 ",
   CALL print((page_height - (y_pos+ 53))), " (", "PERSONS ENCOUNTERS AND ORDERS",
   ")  VTEX ", row + 1, y_pos = (y_pos+ 54)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 36
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "/(Courier) 9 18 ",
   CALL print((page_height - (y_pos+ 11))),
   " (", expr2, ")  VTEX ",
   "/(Courier) 9 377 ",
   CALL print((page_height - (y_pos+ 9))), " (",
   "Page:", ")  VTEX ", "/(Courier) 9 406 ",
   CALL print((page_height - (y_pos+ 9))), " (", curpage,
   ")  VTEX ", row + 1, y_pos = (y_pos+ 38),
   row + 1
  HEAD p.name_full_formatted
   row + 1, "/(Courier) 9 18 ",
   CALL print((page_height - (y_pos+ 10))),
   " (", expr1, ")  VTEX ",
   row + 1, name_full_formatted1 = substring(1,60,p.name_full_formatted), "/(Courier-Bold) 11 18 ",
   CALL print((page_height - (y_pos+ 35))), " (", "NAME:",
   ")  VTEX ", "/(Courier-Bold) 11 47 ",
   CALL print((page_height - (y_pos+ 35))),
   " (", name_full_formatted1, ")  VTEX ",
   "/(Courier-Bold) 11 348 ",
   CALL print((page_height - (y_pos+ 35))), " (",
   "ID:", ")  VTEX ", "/(Courier-Bold) 11 363 ",
   CALL print((page_height - (y_pos+ 35))), " (", p.person_id,
   ")  VTEX ", row + 1, "/(Courier) 9 18 ",
   CALL print((page_height - (y_pos+ 69))), " (", expr1,
   ")  VTEX ", row + 1, "/(Courier) 9 133 ",
   CALL print((page_height - (y_pos+ 87))), " (", "Encounter Type",
   ")  VTEX ", "/(Courier) 9 348 ",
   CALL print((page_height - (y_pos+ 87))),
   " (", "Order Mnemonic", ")  VTEX ",
   row + 1, "133",
   CALL print((page_height - (y_pos+ 93))),
   " 223",
   CALL print((page_height - (y_pos+ 93))), " 2 VLIN  ",
   "348",
   CALL print((page_height - (y_pos+ 93))), " 429",
   CALL print((page_height - (y_pos+ 93))), " 2 VLIN  ", row + 1,
   y_pos = (y_pos+ 117)
  DETAIL
   IF (((y_pos+ 86) >= 792))
    y_pos = 0, BREAK
   ENDIF
   row + 1, order_mnemonic1 = substring(1,30,o.order_mnemonic), "/(Courier) 9 18 ",
   CALL print((page_height - (y_pos+ 28))), " (", o.encntr_id,
   ")  VTEX ", "/(Courier) 9 118 ",
   CALL print((page_height - (y_pos+ 28))),
   " (", encntr_type_disp, ")  VTEX ",
   "/(Courier) 9 334 ",
   CALL print((page_height - (y_pos+ 28))), " (",
   order_mnemonic1, ")  VTEX ", y_pos = (y_pos+ 15),
   row + 1
  FOOT PAGE
   row + 1, "showpage", y_pos = 0
  FOOT REPORT
   row + 1, "grestore"
  WITH maxrec = 100, maxcol = 500, maxrow = 1,
   time = value(maxsecs), outerjoin = d1, noheading,
   format = variable
 ;end select
END GO
