CREATE PROGRAM ccloraindex:dba
 PAINT
 CALL video(r)
 CALL box(1,1,14,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLORAINDEX")
 CALL clear(3,2,78)
 CALL text(03,05,"Report to view index for ORACLE table.")
 CALL video(n)
 CALL text(06,05,"ORACLE SYSTEM TABLES (Y/N)")
 CALL text(08,05,"DATABASE NAME")
 CALL text(11,05,"TABLE NAME")
 CALL text(012,05,"OWNER NAME")
 CALL accept(06,40,"A;CU","N"
  WHERE curaccept IN ("N", "Y"))
 SET p1 = curaccept
 IF (p1="Y")
  CALL accept(08,40,"P(31);cu","ORACLESYSTEM")
 ELSE
  CALL accept(08,40,"P(31);cu","V500")
 ENDIF
 SET p2 = curaccept
 SET accept = nopatcheck
 CALL accept(11,40,"P(31);CU",char(42))
 SET p3 = curaccept
 CALL accept(12,40,"P(31);CU","V500")
 SET p_owner = curaccept
 CALL clear(1,1)
 SET pos = findstring(char(42),p3)
 IF (textlen(trim(p3)) < 3)
  SELECT
   FROM dummyt
   DETAIL
    col 0, "Failed to read indexes. Table name must be minimum of three characters with wildcard."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 SELECT
  IF (currdb="DB2UDB")
   brk1 = concat(doc.table_name,substring(1,30,a.index_name)), doc.table_name, owner = a.table_owner,
   a.tablespace_name, index_name = substring(1,30,a.index_name), a.uniqueness,
   colname = substring(1,30,c.column_name), colpos = c.column_position, collen = c.column_length
   FROM dm_tables_doc doc,
    dba_indexes a,
    dba_ind_columns c
   PLAN (doc
    WHERE doc.table_name=patstring(p3))
    JOIN (a
    WHERE a.table_owner=patstring(p_owner)
     AND a.table_name=doc.suffixed_table_name)
    JOIN (c
    WHERE a.index_name=c.index_name
     AND a.table_name=c.table_name
     AND a.table_owner=c.index_owner)
  ELSE
   brk1 = concat(a.table_name,substring(1,30,a.index_name)), a.table_name, owner = a.table_owner,
   a.tablespace_name, index_name = substring(1,30,a.index_name), a.uniqueness,
   colname = substring(1,30,c.column_name), colpos = c.column_position, collen = c.column_length
   FROM dba_indexes a,
    dba_ind_columns c
   PLAN (a
    WHERE a.table_name=patstring(p3)
     AND a.table_owner=patstring(p_owner))
    JOIN (c
    WHERE a.index_name=c.index_name
     AND a.table_name=c.table_name
     AND a.table_owner=c.table_owner)
  ENDIF
  INTO "MINE"
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
   a.table_name, row + 1, owner,
   row + 1, a.tablespace_name, row- (2),
   col 40, index_name, col 70,
   a.uniqueness, cnt = 0
  DETAIL
   col 80, colname, col 110,
   colpos"######", col 120, collen"######",
   row + 1, cnt += 1
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
#end_program
END GO
