CREATE PROGRAM db_backup_stats_rep:dba
 SET message = noinformation
 SET trace = nocost
 SET charwidth = 12
 SET numwidth = 10
 SET fname = "backup_stats.rep"
 SET line = fillstring(120,"-")
 SET dline = fillstring(109,"=")
 SET pg = 0
 SET start_dt_tm = cnvtdatetime(curdate,curtime3)
 SET end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET cur_dt = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  d1.begin_date
  FROM dba_bkup_stats d1
  WHERE (d1.begin_date=
  (SELECT
   min(d2.begin_date)
   FROM dba_bkup_stats d2))
  FOOT REPORT
   start_dt_tm = min(d1.begin_date)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.end_date
  FROM dba_bkup_stats d1
  WHERE (d1.end_date=
  (SELECT
   max(d2.end_date)
   FROM dba_bkup_stats d2))
  FOOT REPORT
   end_dt_tm = max(d1.end_date)
  WITH nocounter
 ;end select
 RECORD stats(
   1 qual[*]
     2 ts = c30
     2 fn = c257
     2 min_bd = dq8
     2 min_ed = dq8
     2 min_pr = f8
     2 min_pw = f8
     2 max_bd = dq8
     2 max_ed = dq8
     2 max_pr = f8
     2 max_pw = f8
 )
 SET count = 0
 SET ret = 0
 SELECT INTO "nl:"
  d1.tablespace_name, d1.file_name, d1.begin_date,
  d1.end_date, d1.phys_reads, d1.phys_writes
  FROM dba_bkup_stats d1
  WHERE (d1.end_date=
  (SELECT
   min(d2.end_date)
   FROM dba_bkup_stats d2
   WHERE d1.tablespace_name=d2.tablespace_name
    AND d1.file_name=d2.file_name
    AND ((d2.phys_reads+ d2.phys_writes)=
   (SELECT
    min((d3.phys_reads+ d3.phys_writes))
    FROM dba_bkup_stats d3
    WHERE d1.tablespace_name=d3.tablespace_name
     AND d1.file_name=d3.file_name))))
  ORDER BY d1.tablespace_name, d1.file_name
  HEAD REPORT
   ret = alterlist(stats->qual,500)
  DETAIL
   count = (count+ 1), stats->qual[count].ts = d1.tablespace_name, stats->qual[count].fn = d1
   .file_name,
   stats->qual[count].min_bd = d1.begin_date, stats->qual[count].min_ed = d1.end_date, stats->qual[
   count].min_pr = d1.phys_reads,
   stats->qual[count].min_pw = d1.phys_writes
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.tablespace_name, d1.file_name, d1.begin_date,
  d1.end_date, d1.phys_reads, d1.phys_writes
  FROM dba_bkup_stats d1
  WHERE (d1.end_date=
  (SELECT
   min(d2.end_date)
   FROM dba_bkup_stats d2
   WHERE d1.tablespace_name=d2.tablespace_name
    AND d1.file_name=d2.file_name
    AND ((d2.phys_reads+ d2.phys_writes)=
   (SELECT
    max((d3.phys_reads+ d3.phys_writes))
    FROM dba_bkup_stats d3
    WHERE d1.tablespace_name=d3.tablespace_name
     AND d1.file_name=d3.file_name))))
  ORDER BY d1.tablespace_name, d1.file_name
  DETAIL
   FOR (loop = 1 TO count)
     IF ((stats->qual[loop].ts=d1.tablespace_name)
      AND (stats->qual[loop].fn=d1.file_name))
      stats->qual[loop].max_bd = d1.begin_date, stats->qual[loop].max_ed = d1.end_date, stats->qual[
      loop].max_pr = d1.phys_reads,
      stats->qual[loop].max_pw = d1.phys_writes
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 DELETE  FROM dba_bkup_stats_sum
  WHERE 1=1
 ;end delete
 COMMIT
 FOR (loop = 1 TO count)
  INSERT  FROM dba_bkup_stats_sum d
   SET d.tablespace_name = stats->qual[loop].ts, d.file_name = stats->qual[loop].fn, d.min_begin_date
     = cnvtdatetime(stats->qual[loop].min_bd),
    d.min_end_date = cnvtdatetime(stats->qual[loop].min_ed), d.min_phys_reads = stats->qual[loop].
    min_pr, d.min_phys_writes = stats->qual[loop].min_pw,
    d.max_begin_date = cnvtdatetime(stats->qual[loop].max_bd), d.max_end_date = cnvtdatetime(stats->
     qual[loop].max_ed), d.max_phys_reads = stats->qual[loop].max_pr,
    d.max_phys_writes = stats->qual[loop].max_pw
  ;end insert
  COMMIT
 ENDFOR
 SELECT INTO trim(fname)
  *
  FROM dba_bkup_stats_sum d1
  ORDER BY d1.tablespace_name, d1.file_name
  HEAD REPORT
   col 1, "Begin Date : ", col 14,
   start_dt_tm"www mm/dd/yyyy;;d", col 29, start_dt_tm"hh:mm;;m",
   col 40, "I/O STATISTICS REPORT BY TABLESPACE", col 79,
   "End Date : ", col 90, end_dt_tm"www mm/dd/yyyy;;d",
   col 105, end_dt_tm"hh:mm;;m", row + 1,
   col 1, dline, row + 2
  HEAD PAGE
   pg = (pg+ 1), col 1, "Cur Date : ",
   col 12, cur_dt"mm/dd/yyyy;;d", col 103,
   "Page ", pg_txt = substring(1,4,cnvtstring(pg)), col 109,
   pg_txt";l", row + 2, col 1,
   "Tablespace Name", row + 1, col 3,
   "File Name", col 57, "Min Date",
   col 73, "Min I/O", col 86,
   "Max Date", col 103, "max I/O",
   row + 1, col 1, dline,
   row + 2
  HEAD d1.tablespace_name
   col 1, d1.tablespace_name, row + 1
  DETAIL
   min_io = (d1.min_phys_reads+ d1.min_phys_writes), max_io = (d1.max_phys_reads+ d1.max_phys_writes),
   fn = substring(1,50,d1.file_name),
   col 3, fn, col 54,
   d1.min_end_date"www mm/dd;;d", col 64, d1.min_end_date"hh:mm;;m",
   col 69, min_io, col 83,
   d1.max_end_date"www mm/dd;;d", col 93, d1.max_end_date"hh:mm;;m",
   col 99, max_io, row + 1
  WITH nocounter
 ;end select
END GO
