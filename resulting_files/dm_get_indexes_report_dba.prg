CREATE PROGRAM dm_get_indexes_report:dba
 SELECT INTO "index.dat"
  brk1 = concat(a.table_name,a.index_name), a.table_name, a.table_owner,
  a.tablespace_name, a.index_name, a.uniqueness,
  colname = c.column_name, colpos = c.column_position, collen = c.column_length
  FROM (sys.all_indexes a),
   (sys.all_ind_columns c)
  WHERE (a.table_name=request->table_name)
   AND a.table_owner="V500"
   AND a.index_name=c.index_name
   AND a.table_name=c.table_name
   AND a.table_owner=c.table_owner
  ORDER BY a.table_name, a.index_name, c.column_position
  HEAD REPORT
   line = fillstring(130,"_")
  HEAD PAGE
   "Table_name/Owner/Space", col 40, "Index Name",
   col 70, "Unique", col 80,
   "Index Col", col 110, "Col Pos",
   col 120, "Col len", row + 1,
   line, row + 1
  HEAD brk1
   a.table_name, row + 1, a.table_owner,
   row + 1, a.tablespace_name, row- (2),
   col 40, a.index_name, col 70,
   a.uniqueness, cnt = 0
  DETAIL
   col 80, colname, col 110,
   colpos"######", col 120, collen"######",
   row + 1, cnt = (cnt+ 1)
  FOOT  a.table_name
   IF (((row+ 5) > maxrow))
    BREAK
   ELSEIF (cnt > 3)
    row + 1
   ELSE
    cnt = (4 - cnt), row + cnt
   ENDIF
  WITH counter
 ;end select
END GO
