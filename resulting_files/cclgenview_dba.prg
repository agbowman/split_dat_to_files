CREATE PROGRAM cclgenview:dba
 PAINT
 SET accept = nopatcheck
 CALL box(1,1,12,80)
 CALL text(2,5,"CCLGENVIEW PROGRAM")
 CALL line(3,1,80,xhor)
 CALL text(5,5,"Table Name")
 CALL text(7,5,"View Name                     .view")
 CALL text(9,5,"Result Name")
 CALL accept(5,20,"p(30);cu","PR05_1")
 SET p_table = curaccept
 CALL accept(7,20,"p(30);cu","1VPR05_1")
 SET p_view = curaccept
 CALL accept(9,20,"p(30);cu","1VPR05_1")
 SET p_result = concat(trim(curaccept),".view")
 SELECT INTO value(p_result)
  t.file_name, table_name = a.table_name, l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name=a.table_name
   AND  NOT (l.structtype IN ("G", "K"))
   AND btest(l.stat,11)=0
   AND t.table_name=patstring(substring(1,12,p_table))
   AND t.table_name=p_table
  HEAD table_name
   first = 1, "DROP VIEW ", p_view,
   " GO", row + 1, "CREATE VIEW ",
   p_view, row + 1
  DETAIL
   col 5
   IF (first=1)
    " ", first = 0
   ELSE
    ","
   ENDIF
   l.attr_name, " = ",
   CALL print(build(table_name,".",l.attr_name)),
   row + 1
  FOOT  table_name
   col 5, "FROM ", table_name,
   row + 1, "GO", row + 1
  WITH noformfeed, maxrow = 1, maxcol = 100,
   format = variable
 ;end select
END GO
