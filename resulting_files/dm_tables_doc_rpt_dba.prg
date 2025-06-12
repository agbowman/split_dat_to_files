CREATE PROGRAM dm_tables_doc_rpt:dba
 SET table_cnt = 0
 SELECT
  td.*, dms.owner_name
  FROM dm_data_model_section dms,
   dm_tables_doc td,
   dm_tables t
  WHERE t.schema_date=cnvtdatetime("01-SEP-1997")
   AND t.table_name=patstring(cnvtupper( $1))
   AND td.table_name=t.table_name
   AND dms.data_model_section=td.data_model_section
  ORDER BY td.table_name
  HEAD REPORT
   line = fillstring(131,"="), line1 = fillstring(131,"-"), page_nbr = 0
  HEAD PAGE
   col 0, "Page: ", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 55, "Cerner HNA Millennium",
   col 114, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1, col 49, "Data Dictionary Tables 01-SEP-1997",
   row + 1, col 0, "TABLE NAME",
   col 35, "DESCRIPTION / DEFINITION", row + 1,
   col 0, line, row + 1
  DETAIL
   col 0, td.table_name, table_cnt = (table_cnt+ 1),
   col 35, desc = substring(1,80,td.description), desc,
   row + 1, x = fillstring(75," "), x1 = fillstring(75," "),
   x2 = fillstring(75," "), x3 = fillstring(75," "), beg = 1,
   len = 75, max = 75, x = substring(beg,len,td.definition)
   IF (x > " ")
    col 35, x, row + 1,
    beg = (beg+ len), x1 = substring(beg,len,td.definition)
    IF (x1 > " ")
     col 35, x1, row + 1,
     beg = (beg+ len), x2 = substring(beg,len,td.definition)
     IF (x2 > " ")
      col 35, x2, row + 1,
      beg = (beg+ len), len = 30, x3 = substring(beg,len,td.definition)
      IF (x3 > " ")
       col 35, x3, row + 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   row + 1
  FOOT REPORT
   col 0, line1, row + 1,
   col 0, "*** Total Tables: ", table_cnt
  WITH counter
 ;end select
END GO
