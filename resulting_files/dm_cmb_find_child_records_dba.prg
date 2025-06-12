CREATE PROGRAM dm_cmb_find_child_records:dba
 FREE SET parent_table
 FREE SET parent_id
 SET parent_table = cnvtupper( $1)
 SET parent_id =  $2
 RECORD rchild(
   1 qual[*]
     2 table_name = c30
     2 fk_col_name = c30
     2 row_num = f8
 )
 SET child_cnt = 0
 SET p[6] = fillstring(100," ")
 SELECT INTO "nl:"
  a.table_name, b.column_name
  FROM user_constraints a,
   user_cons_columns b
  WHERE a.owner=currdbuser
   AND a.r_constraint_name=concat("XPK",parent_table)
   AND a.owner=b.owner
   AND a.table_name=b.table_name
   AND a.constraint_name=b.constraint_name
  ORDER BY a.table_name, b.column_name
  DETAIL
   child_cnt += 1, stat = alterlist(rchild->qual,child_cnt), rchild->qual[child_cnt].table_name = a
   .table_name,
   rchild->qual[child_cnt].fk_col_name = b.column_name
  WITH nocounter
 ;end select
 FOR (dm_cnt = 1 TO child_cnt)
   SET cnt = 0
   SET p[1] = "select into 'nl:' rowid"
   SET p[2] = concat("from   ",rchild->qual[dm_cnt].table_name)
   SET p[3] = concat("where  ",rchild->qual[dm_cnt].fk_col_name,"= parent_id")
   SET p[4] = "detail "
   SET p[5] = "       cnt = cnt + 1"
   SET p[6] = "with   nocounter go"
   FOR (p_cnt = 1 TO 6)
     CALL parser(p[p_cnt])
   ENDFOR
   SET rchild->qual[dm_cnt].row_num = cnt
 ENDFOR
 SELECT INTO mine
  d.seq
  FROM (dummyt d  WITH seq = value(child_cnt))
  HEAD REPORT
   col 0, "PARENT_TABLE = ", parent_table,
   row + 1, col 0, parent_table,
   " ID = ", parent_id"#########;l", row + 2,
   col 0, "TABLE_NAME", col 32,
   "COLUMN_NAME", col 64, "NUMBER OF ROWS",
   row + 1, col 0, "----------",
   col 32, "-----------", col 64,
   "--------------", row + 1
  DETAIL
   IF ((rchild->qual[d.seq].row_num != 0))
    col 0, rchild->qual[d.seq].table_name, col 32,
    rchild->qual[d.seq].fk_col_name, col 64, rchild->qual[d.seq].row_num"######;l",
    row + 1
   ENDIF
  WITH nocounter
 ;end select
END GO
