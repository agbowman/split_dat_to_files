CREATE PROGRAM dm_disp_fs_table_files:dba
 SET table_file = fillstring(30," ")
 IF ((fs_proc->ocd_number > 0))
  SET table_file = build("dm_ocd_tables_",fs_proc->ocd_number,".txt")
 ELSE
  SET table_file = build(cnvtlower(fs_proc->file_prefix),"_tables.txt")
 ENDIF
 SELECT INTO value(table_file)
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
    "The 'DDL Filename' is the file that contains the DDL to make", row + 1,
    "schema changes. The 'COM Filename' is the file that can be",
    row + 1, "submitted as a batch job to execute the DDL file.", row + 1
   ENDIF
   row + 1, row + 1, col 0,
   "Table Name", col 35, "Uptime/Downtime"
   IF (( $1=1))
    col 55, "DDL Filename", col 90,
    "COM Filename"
   ENDIF
   row + 1, col 0, "----------",
   col 35, "---------------"
   IF (( $1=1))
    col 55, "------------", col 90,
    "------------"
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
      ddl_file, col 90, com_file
      IF ((tgtdb->tbl[t.seq].downtime_ind=1))
       row + 1, ddl_file = rfiles->qual[fi].file2d, com_file = rfiles->qual[fi].file1dcom,
       col 55, ddl_file, col 90,
       com_file
      ENDIF
     ELSEIF ((tgtdb->tbl[t.seq].downtime_ind=1))
      ddl_file = rfiles->qual[fi].file2d, com_file = rfiles->qual[fi].file1dcom, col 55,
      ddl_file, col 90, com_file
     ENDIF
    ELSE
     col 55, "??", col 90,
     "??"
    ENDIF
   ENDIF
   row + 1
  FOOT REPORT
   row + 1, "Number of tables that require uptime schema changes only        :", ucnt,
   row + 1, "Number of tables that require downtime schema changes only      :", dcnt,
   row + 1, "Number of tables that require uptime and downtime schema changes:", udcnt,
   row + 1, tcnt = ((ucnt+ dcnt)+ udcnt),
   "Total number of tables with schema differences that can be fixed:",
   tcnt
  WITH nocounter, format = variable, formfeed = none,
   maxrow = 1
 ;end select
 FREE DEFINE rtl
 FREE SET file_loc
 SET logical file_loc value(table_file)
 DEFINE rtl "file_loc"
 SELECT
  r.line
  FROM rtlt r
  WITH nocounter
 ;end select
#end_program
END GO
