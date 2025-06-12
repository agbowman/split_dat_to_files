CREATE PROGRAM dm_invalid_codes_rpt:dba
 SELECT
  IF (cnvtupper( $1)="ALL")
   WHERE d.table_name="*"
    AND t.table_name=d.table_name
    AND cd.table_name=d.table_name
    AND cd.column_name=d.column_name
  ELSE
   WHERE d.table_name=patstring(cnvtupper( $1))
    AND t.table_name=d.table_name
    AND cd.table_name=d.table_name
    AND cd.column_name=d.column_name
  ENDIF
  d.table_name, t.data_model_section, d.column_name,
  d.row_id, ni = nullind(d.invalid_value)
  FROM dm_invalid_table_value d,
   dm_tables_doc t,
   dm_columns_doc cd
  ORDER BY d.table_name, d.column_name
  HEAD REPORT
   line = fillstring(127,"="), page_nbr = 0, cnt = 0
  HEAD PAGE
   col 0, "Page:", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 50, "INALID CODE VALUE REPORT",
   col 100, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1, col 00, "TABLE NAME",
   col 22, "DATA MOD SECN", col 50,
   "COLUMN NAME", col 70, "INVALID VALUE",
   col 98, "ROW ID", row + 1,
   col 0, line, row + 1
  HEAD d.table_name
   col 0, d.table_name, col 26,
   t.data_model_section, cnt = 0, row + 1
  HEAD d.column_name
   x = substring(1,25,d.column_name), z = cnvtstring(cd.code_set), col 50,
   x, col 75, "Probable Code Set : ",
   z, row + 1, cnt = 0
  DETAIL
   cnt = (cnt+ 1), y = cnvtstring(d.invalid_value)
   IF (ni=1)
    col 60, "xxxx"
   ELSE
    col 60, "NULL"
   ENDIF
   col 70, y, col 98,
   d.row_id, row + 1
  FOOT  d.column_name
   row + 1
  WITH nocounter
 ;end select
END GO
