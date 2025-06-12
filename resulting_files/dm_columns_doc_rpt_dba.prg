CREATE PROGRAM dm_columns_doc_rpt:dba
 SET save_table_name = fillstring(30," ")
 SET temp_table_name = fillstring(45," ")
 SET dtype1 = fillstring(17," ")
 SET table_cnt = 0
 SET col_cnt = 0
 SELECT
  td.description, dms.owner_name, cd.*,
  c.*
  FROM dm_columns_doc cd,
   dm_columns c,
   dm_data_model_section dms,
   dm_tables_doc td,
   dm_tables t
  WHERE t.schema_date=cnvtdatetime("01-SEP-1997")
   AND t.table_name=patstring(cnvtupper( $1))
   AND td.table_name=t.table_name
   AND dms.data_model_section=td.data_model_section
   AND c.schema_date=cnvtdatetime("01-SEP-1997")
   AND c.table_name=td.table_name
   AND cd.table_name=c.table_name
   AND cd.column_name=c.column_name
  ORDER BY cd.table_name, cd.column_name
  HEAD REPORT
   line = fillstring(131,"="), line1 = fillstring(131,"-"), page_nbr = 0
  HEAD PAGE
   col 0, "Page: ", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 55, "Cerner HNA Millennium",
   col 114, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1, col 45, "Data Dictionary Table Columns 01-SEP-1997",
   row + 1, col 0, "TABLE NAME / COLUMN NAME",
   col 35, "COLUMN DESCRIPTION / DEFINITION", row + 1,
   col 0, line, row + 1
  DETAIL
   IF (row > 57)
    BREAK
   ENDIF
   IF (((cd.table_name != save_table_name) OR (row=4)) )
    IF (cd.table_name != save_table_name
     AND row != 4)
     line1, row + 1
    ENDIF
    col 0
    IF (cd.table_name=save_table_name)
     temp_table_name = build(c.table_name," Table (continued)")
    ELSE
     temp_table_name = build(c.table_name," Table"), table_cnt = (table_cnt+ 1)
    ENDIF
    temp_table_name, save_table_name = cd.table_name, row + 1
   ENDIF
   col 5, cd.column_name, col_cnt = (col_cnt+ 1),
   col 35, desc = substring(1,80,cd.description), desc,
   row + 1
   IF (cd.code_set IS NOT null
    AND cd.code_set > 0)
    col 7, "Code Set: ", cd.code_set"########"
   ENDIF
   col 35, "RDBMS Data Type: "
   IF (((c.data_type="VARCHAR") OR (((c.data_type="VARCHAR2") OR (c.data_type="CHAR")) )) )
    dtype1 = build(c.data_type,"(",c.data_length,")")
   ELSE
    dtype1 = c.data_type
   ENDIF
   dtype1, col + 1
   IF (c.nullable="Y")
    "NULL", col + 6
   ELSE
    "NOT NULL", col + 2
   ENDIF
   IF (c.data_default IS NOT null
    AND  NOT (c.data_default < "0"))
    "Default: ", default1 = substring(1,40,c.data_default), default1
   ENDIF
   row + 1
   IF (cd.sequence_name IS NOT null
    AND cd.sequence_name > " ")
    col 7, "Seq: ", cd.sequence_name
   ENDIF
   x = fillstring(90," "), x1 = fillstring(90," "), x2 = fillstring(75," "),
   beg = 1, len = 90, max = 90,
   x = substring(beg,len,cd.definition)
   IF (x > " ")
    col 35, x, row + 1,
    beg = (beg+ len), x1 = substring(beg,len,cd.definition)
    IF (x1 > " ")
     col 35, x1, row + 1,
     beg = (beg+ 75), x2 = substring(beg,len,cd.definition)
     IF (x2 > " ")
      col 35, x2, row + 1
     ENDIF
    ENDIF
   ENDIF
   row + 1
  FOOT REPORT
   col 0, line, row + 1,
   col 0, "**** Total Tables:  ", table_cnt,
   row + 1, col 0, "**** Total Columns: ",
   col_cnt
  WITH maxrow = 64
 ;end select
END GO
