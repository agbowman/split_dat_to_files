CREATE PROGRAM dm_rpt_tables:dba
 SELECT
  IF (cnvtupper( $1)="ALL")
   WHERE d.table_name="*"
    AND t.table_name=d.table_name
    AND tc.table_name=d.table_name
    AND tc.constraint_name=d.constraint
    AND pc.constraint_name=tc.r_constraint_name
  ELSE
   WHERE d.table_name=patstring(cnvtupper( $1))
    AND t.table_name=d.table_name
    AND tc.table_name=d.table_name
    AND tc.constraint_name=d.constraint
    AND pc.constraint_name=tc.r_constraint_name
  ENDIF
  d.table_name, t.data_model_section, d.constraint,
  tc.column_name, pc.table_name, pc.column_name
  FROM dm_for_key_except d,
   dm_tables_doc t,
   temp_constraints tc,
   temp_constraints pc
  ORDER BY d.table_name, d.constraint, tc.column_name
  HEAD REPORT
   line = fillstring(127,"="), page_nbr = 0, cnt = 0
  HEAD PAGE
   col 0, "Page:", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 80, "Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 4,
   "TABLE NAME", col 22, "DATA MOD SECN",
   col 44, "CONSTRAINT NAME", col 70,
   "COLUMN NAME", col 90, "PARENT TBL NAME",
   col 108, "PARENT COL NAME", row + 1,
   col 0, line, row + 1
  HEAD d.table_name
   col 0, d.table_name, col 26,
   t.data_model_section, u = substring(1,19,pc.table_name), col 91,
   u, cnt = 0
  HEAD d.constraint
   col 40, d.constraint, w = substring(1,17,pc.column_name),
   col 111, w
  HEAD tc.column_name
   x = substring(1,20,tc.column_name), col 70, x,
   row + 1, cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  d.constraint
   y = concat(" ",trim(cnvtstring(cnt))," "), z = concat(" ",trim(d.table_name)," "), col 8,
   CALL print(build(d.constraint," on ",z," has ",y,
    " orphan row(s)")), row + 2
  WITH counter, maxcol = 130
 ;end select
END GO
