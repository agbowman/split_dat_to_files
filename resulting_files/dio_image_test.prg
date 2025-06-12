CREATE PROGRAM dio_image_test
 PROMPT
  "ENTER result desination             (DIO): " = "DIO",
  "ENTER table name                (REQUEST): " = "REQUEST",
  "ENTER dio device#                    (08): " = 08,
  "ENTER dio margin#                     (0): " = 0,
  "ENTER dio duplex Simple,Tumble,Edge   (S): " = "S"
 SELECT INTO  $1
  t.table_name, l.attr_name, l.len,
  t.file_name, t.access_code
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE (t.table_name= $2)
   AND t.table_name=a.table_name
  HEAD REPORT
   IF (( $3=08))
    "{PS/ ~C$LMAR .5 c$in def /}"
   ENDIF
   CALL parser("%I ccluserdir:dio_image.xps"), "{CPI/5}{LPI/3}", row + 1,
   col 10, "{COLOR/11}{CENTER/CERNER REPORT #00001/}{COLOR/0}", row + 3,
   "{LPI/7}{CPI/16/6}", "{BOX/125/50}"
  HEAD PAGE
   row + 1, "{B}", "TIME: ",
   curtime"hh:mm;;mtime", "  DATE: ", curdate,
   "  PAGE: ", curpage, row + 1
  HEAD t.table_name
   IF (((row+ 30) > maxrow))
    BREAK
   ELSE
    row + 2
   ENDIF
   col 0, "{B} ---TABLE NAME---", col + 10,
   "----- FIELD NAME------", row + 1, col 1,
   t.table_name, row + 1, col 1,
   t.file_name, row + 1, col 1,
   t.access_code, row- (2), col 35
  DETAIL
   IF (((col+ 35) > maxcol))
    row + 1, col 35, l.attr_name,
    col + 1, l.len, col + 1
   ELSE
    l.attr_name, col + 1, l.len,
    col + 1
   ENDIF
  FOOT  t.table_name
   row + 1, " --------------------------------", row + 1,
   " {COLOR/11}Number of fields for table: {COLOR/0}", col 40, count(l.attr_name),
   col + 1, sum(l.len), col + 1,
   avg(l.len), row + 1
  FOOT REPORT
   " --------------------------------", row + 1, " {COLOR/11}    Total number of fields: {COLOR/0}",
   col 40, count(l.attr_name)"######.##;$;f", col + 1,
   sum(l.len), col + 1, avg(l.len)
  WITH dio =  $3
 ;end select
END GO
