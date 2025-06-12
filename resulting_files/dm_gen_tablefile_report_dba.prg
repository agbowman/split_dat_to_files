CREATE PROGRAM dm_gen_tablefile_report:dba
 SELECT INTO value(fs_proc->table_filename)
  FROM (dummyt t  WITH seq = value(tgtdb->tbl_cnt))
  PLAN (t
   WHERE (((tgtdb->tbl[t.seq].diff_ind=1)) OR ((tgtdb->tbl[t.seq].new_ind=1))) )
  ORDER BY tgtdb->tbl[t.seq].tbl_name
  HEAD REPORT
   ddl_file = fillstring(30," "), com_file = fillstring(30," "), ucnt = 0,
   dcnt = 0, udcnt = 0, tcnt = 0,
   fi = 0, "The following tables have schema differences that can be fixed.", row + 1,
   "The 'Uptime/Downtime' column indicates whether a table needs", row + 1,
   "uptime schema changes, downtime schema changes or both.",
   row + 1
   IF (( $1=1))
    "The 'DDL Filename' is the file that contains the DDL to make", row + 1, "schema changes.",
    row + 1
   ENDIF
   row + 1, row + 1, col 0,
   "Table Name", col 35, "Uptime/Downtime"
   IF (( $1=1))
    col 55, "DDL Filename"
   ENDIF
   row + 1, col 0, "----------",
   col 35, "---------------"
   IF (( $1=1))
    col 55, "------------"
   ENDIF
   row + 1
  DETAIL
   col 0, tgtdb->tbl[t.seq].tbl_name
   IF ((tgtdb->tbl[t.seq].uptime_ind=1)
    AND (tgtdb->tbl[t.seq].downtime_ind=1))
    col 35, "Uptime/Downtime", udcnt = (udcnt+ 1)
   ELSEIF ((tgtdb->tbl[t.seq].uptime_ind=1))
    col 35, "Uptime only", ucnt = (ucnt+ 1)
   ELSEIF ((tgtdb->tbl[t.seq].downtime_ind=1))
    col 35, "Downtime only", dcnt = (dcnt+ 1)
   ELSE
    col 35, "??"
   ENDIF
   IF (( $1=1))
    IF ((rfiles->fcnt > 0)
     AND (tgtdb->tbl[t.seq].file_idx > 0))
     fi = tgtdb->tbl[t.seq].file_idx
     IF ((tgtdb->tbl[t.seq].uptime_ind=1))
      ddl_file = rfiles->qual[fi].file2, com_file = rfiles->qual[fi].file1com, col 55,
      ddl_file, row + 1
      IF ((tgtdb->tbl[t.seq].downtime_ind=1))
       ddl_file = rfiles->qual[fi].file2d, com_file = rfiles->qual[fi].file1dcom, col 55,
       ddl_file, row + 1
      ENDIF
     ELSEIF ((tgtdb->tbl[t.seq].downtime_ind=1))
      ddl_file = rfiles->qual[fi].file2d, com_file = rfiles->qual[fi].file1dcom, col 55,
      ddl_file, row + 1
     ENDIF
    ELSE
     col 55, "??", row + 1
    ENDIF
   ELSE
    row + 1
   ENDIF
  FOOT REPORT
   row + 1, "Number of tables that require uptime schema changes only        :", ucnt,
   row + 1, "Number of tables that require downtime schema changes only      :", dcnt,
   row + 1, "Number of tables that require uptime and downtime schema changes:", udcnt,
   row + 1, tcnt = ((ucnt+ dcnt)+ udcnt),
   "Total number of tables with schema differences that can be fixed:",
   tcnt
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 131, maxrow = 1, nullreport
 ;end select
#end_program
END GO
