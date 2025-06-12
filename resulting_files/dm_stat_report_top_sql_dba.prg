CREATE PROGRAM dm_stat_report_top_sql:dba
 DECLARE dm_stat_cnt = i4
 SET dm_stat_cnt = 0
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv,
   dm_stat_snaps_values dv2
  PLAN (ds
   WHERE ds.snapshot_type="TOP_SQL_DELTAS"
    AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_reports->begin_dt_tm) AND cnvtdatetime(
    dsr_reports->end_dt_tm))
   JOIN (dv2
   WHERE dv2.dm_stat_snap_id=ds.dm_stat_snap_id
    AND dv2.stat_str_val=patstring(dm_inp_script)
    AND dv2.stat_seq=6)
   JOIN (dv
   WHERE dv.dm_stat_snap_id=dv2.dm_stat_snap_id
    AND dv.stat_name=dv2.stat_name)
  ORDER BY dv.dm_stat_snap_id DESC, dv.stat_name, dv.stat_seq
  DETAIL
   IF (dv.stat_seq=0)
    dm_sql_cnt = 0, dm_stat_cnt = (dm_stat_cnt+ 1), stat = alterlist(temp_report->qual,dm_stat_cnt)
   ENDIF
   IF (dv.stat_seq=0)
    temp_report->qual[dm_stat_cnt].score = dv.stat_number_val
   ELSEIF (dv.stat_seq=2)
    temp_report->qual[dm_stat_cnt].executions = dv.stat_number_val
   ELSEIF (dv.stat_seq=3)
    temp_report->qual[dm_stat_cnt].disk_reads = dv.stat_number_val
   ELSEIF (dv.stat_seq=4)
    temp_report->qual[dm_stat_cnt].buffer_gets = dv.stat_number_val
   ELSEIF (dv.stat_seq=6)
    temp_report->qual[dm_stat_cnt].script_name = dv.stat_str_val
   ELSEIF (dv.stat_seq=7)
    temp_report->qual[dm_stat_cnt].snap_dt_tm_end = format(ds.stat_snap_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;d"), temp_report->qual[dm_stat_cnt].snap_dt_tm_begin = format(datetimeadd
     (ds.stat_snap_dt_tm,- ((dv.stat_number_val/ 1440))),"DD-MMM-YYYY HH:MM:SS;;d")
   ELSEIF (dv.stat_seq > 7)
    dm_sql_cnt = (dm_sql_cnt+ 1), stat = alterlist(temp_report->qual[dm_stat_cnt].qual,dm_sql_cnt),
    temp_report->qual[dm_stat_cnt].qual[dm_sql_cnt].sql_stmt = dv.stat_str_val
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_report->qual,dm_stat_cnt)
  WITH nocounter
 ;end select
 CASE (dm_inp_sort_by)
  OF "S":
   SET temp_sort_name = "temp_report->qual[d.seq].score"
  OF "B":
   SET temp_sort_name = "temp_report->qual[d.seq].buffer_gets"
  OF "E":
   SET temp_sort_name = "temp_report->qual[d.seq].executions"
  OF "D":
   SET temp_sort_name = "temp_report->qual[d.seq].disk_reads"
  ELSE
   SET temp_sort_name = "temp_report->qual[d.seq].score"
 ENDCASE
 IF (dm_stat_cnt > 0)
  SELECT
   *
   FROM (dummyt d  WITH seq = dm_stat_cnt)
   PLAN (d)
   ORDER BY parser(temp_sort_name) DESC
   HEAD REPORT
    col 0, "TOP SQL Statements", row + 1,
    col 0, "Begin Date:  ", dsr_reports->begin_dt_tm,
    row + 1, col 0, "End Date:    ",
    dsr_reports->end_dt_tm, row + 1, row + 1,
    col 0, "Start Date/Time", col 25,
    "End Date/Time", col 50, "Score",
    col 70, "Buffer Gets/Minute", col 90,
    "Executions/Minute", col 110, "Disk Reads/Minute",
    col 130, "Script Name", col 165,
    "SQL Statement", row + 1, dm_rpt_cnt = 0
   DETAIL
    dm_rpt_cnt = (dm_rpt_cnt+ 1)
    IF (dm_rpt_cnt <= dm_inp_num_stmts)
     col 0, temp_report->qual[d.seq].snap_dt_tm_begin, col 25,
     temp_report->qual[d.seq].snap_dt_tm_end, col 50, temp_report->qual[d.seq].score,
     col 70, temp_report->qual[d.seq].buffer_gets, col 90,
     temp_report->qual[d.seq].executions, col 110, temp_report->qual[d.seq].disk_reads,
     col 130, temp_report->qual[d.seq].script_name
     FOR (for_cnt = 1 TO size(temp_report->qual[d.seq].qual,5))
       col 165, temp_report->qual[d.seq].qual[for_cnt].sql_stmt, row + 1
     ENDFOR
     row + 1
    ENDIF
   WITH nocounter, maxcol = 425, formfeed = none,
    maxrow = 1
  ;end select
 ELSE
  SELECT
   *
   FROM dummyt d
   HEAD REPORT
    col 0, "TOP SQL Statements", row + 1,
    col 0, "Begin Date:  ", dsr_reports->begin_dt_tm,
    row + 1, col 0, "End Date:    ",
    dsr_reports->end_dt_tm, row + 1, row + 1,
    col 0, "Start Date/Time", col 25,
    "End Date/Time", col 50, "Score",
    col 70, "Buffer Gets", col 90,
    "Executions", col 110, "Disk Reads",
    col 130, "Script Name", col 165,
    "SQL Statement", row + 1, row + 1,
    col 22, "****NO RECORDS FOUND****"
   WITH nocounter, maxcol = 425
  ;end select
 ENDIF
 IF (error(dsr_reports->stat_error_message,1))
  SET dsr_reports->stat_error_flag = 1
 ENDIF
END GO
