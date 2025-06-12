CREATE PROGRAM ccljoin
 PAINT
  video(n), clear(1,1), box(2,2,20,78),
  line(6,2,77,xhor), text(4,35,"TABLE LINKS"), text(8,5,"OUTPUT DEVICE (MINE,PRINTER,FILE): "),
  accept(8,45,"P(30);CU","MINE"), text(10,5,"ENTER FIRST TABLE: "), accept(10,25,"P(30);CU","X"),
  text(12,5,"ENTER SECOND TABLE: "), accept(12,25,"P(30);CU","Y"), text(24,5,
   "RUN AGAIN AFTER DISPLAYING DATA ?: "),
  accept(24,45,"P;CU","Y"), video(rb), clear(24,1),
  text(24,1,"PROCESSING ..."), video(n)
 SELECT INTO  $1
  t.*, expr1 = build(t.table1,".",t.column1,"=",t.table2,
   ".",t.column2)
  FROM ccljoin t
  WHERE ((t.table1=patstring(cnvtupper( $2))
   AND t.table2=patstring(cnvtupper( $3))) OR (t.table2=patstring(cnvtupper( $2))
   AND t.table1=patstring(cnvtupper( $3))))
  HEAD REPORT
   col 3, "No Data"
  DETAIL
   expr2 = substring(1,120,expr1), col 3, "FROM:  ",
   col 10, t.table2, row + 1,
   col 10, t.table1, row + 1,
   col 3, "WHERE:", col 10,
   expr2, row + 1, col 10,
   t.comment, row + 2
  WITH nocounter, nullreport
 ;end select
 IF (curaccept="Y")
  EXECUTE ccljoin
 ENDIF
END GO
