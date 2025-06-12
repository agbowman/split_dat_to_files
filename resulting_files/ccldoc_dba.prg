CREATE PROGRAM ccldoc:dba
 PAINT
 RANGE OF _d IS dr01_1
 RANGE OF _d2 IS dr01_2
 CALL video(r)
 CALL box(1,1,10,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLDOC")
 CALL clear(3,2,78)
 CALL text(03,05,"Report to get documentation for field")
 CALL video(n)
 CALL text(05,05,"MINE/CRT/printer/file")
 CALL text(06,05,"DOC TYPE  (C/E/L/O/P/R/S/T)")
 CALL text(07,05,"DOC DIR   (TEMPLATE/ZSR  nnnn)")
 CALL text(08,05,"DOC FIELD")
 CALL accept(05,40,"X(12);CU","MINE")
 SET p1 = curaccept
 CALL accept(06,40,_d.text_type,"*")
 SET p2 = curaccept
 CALL accept(07,40,_d.directory,"*")
 SET p3 = curaccept
 CALL accept(08,40,_d.file_name,"*")
 SET p4 = curaccept
 SELECT INTO trim(p1)
  type = _d.text_type, dir = _d.directory, field = _d.file_name,
  documentation = _d2.lin
  WHERE _d.text_type=patstring(p2)
   AND _d.directory=patstring(p3)
   AND _d.file_name=patstring(p4)
   AND _d2.lin > " "
  WITH counter
 ;end select
END GO
