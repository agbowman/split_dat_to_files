CREATE PROGRAM db_perf_generate_rpt:dba
 SET message = noinformation
 SET trace = nocost
 SET charwidth = 12
 SET numwidth = 10
 SET fname = build("perfmon_",rs)
 SET line = fillstring(130,"-")
 CALL text(15,15,"Print 'A'll or only 'T'unable statistics (A/T) : ")
 CALL accept(15,64,"p;cu","A"
  WHERE curaccept IN ("A", "T"))
 SET tune_opt = curaccept
 CALL text(17,15,"Print statistics definition (Y/N) : ")
 CALL accept(17,64,"p;cu","N"
  WHERE curaccept IN ("Y", "N"))
 SET defn_opt = curaccept
 SET start_time = cnvtdatetime(curdate,curtime3)
 SET end_time = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM ref_report_log l
  WHERE l.report_seq=rs
  DETAIL
   start_time = l.begin_date, end_time = l.end_date
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  d.seq
  FROM (dummyt d  WITH seq = value(1))
  HEAD REPORT
   dt = cnvtdatetime(curdate,curtime3), row + 1, row + 1,
   col 2, "Date       : ", dt"dd-mmm-yy;3;d",
   row + 1, col 2, "Start Time : ",
   start_time"hh:mm:ss;;s", row + 1, col 2,
   "End Time   : ", end_time"hh:mm:ss;;s", row + 1,
   col 47, "PERFORMANCE  SUMMARY  REPORT", row + 1,
   col 47, "****************************"
  WITH nocounter, noformfeed, maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  s.namespace, s.gets_value";l", s.gethits_value";l",
  s.pins_value";l", s.pinhits_value";l", s.reloads_value";l",
  s.invalidations";l"
  FROM perf_lib s
  PLAN (s
   WHERE s.report_seq=rs)
  HEAD REPORT
   ge = 0.0, gh = 0.0, gr = 0.0,
   pi = 0.0, ph = 0.0, pr = 0.0,
   row + 1, row + 1, row + 1,
   row + 1, col 1, "REM : Selects Library cache statistics. The pin hit rate should be.",
   row + 1, col 5, " high.",
   row + 1
  HEAD PAGE
   row + 1, col 1, "Library",
   col 20, "Gets", col 35,
   "Get Hitratio", col 50, "Pins",
   col 65, "Pin Hitratio", col 80,
   "Reloads", col 95, "Invalidations",
   row + 1, col 1, line,
   row + 1
  DETAIL
   IF (s.gets_value=0)
    ge = 1
   ELSE
    ge = s.gets_value
   ENDIF
   IF (s.gethits_value=0)
    gh = 1
   ELSE
    gh = s.gethits_value
   ENDIF
   IF (s.pins_value=0)
    pi = 1
   ELSE
    pi = s.pins_value
   ENDIF
   IF (s.pinhits_value=0)
    ph = 1
   ELSE
    ph = s.pinhits_value
   ENDIF
   pr = round((ph/ pi),3), gr = round((gh/ ge),3), name = substring(1,20,s.namespace),
   col 1, name
   IF (s.gets_value=0)
    col 20, "0"
   ELSE
    col 20, s.gets_value
   ENDIF
   IF (gr=0)
    col 35, "0"
   ELSE
    col 35, gr"###.###;l"
   ENDIF
   IF (s.pins_value=0)
    col 50, "0"
   ELSE
    col 50, s.pins_value
   ENDIF
   IF (pr=0)
    col 65, "0"
   ELSE
    col 65, pr"###.###;l"
   ENDIF
   IF (s.reloads_value=0)
    col 80, "0"
   ELSE
    col 80, s.reloads_value
   ENDIF
   col 95, s.invalidations, row + 1
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
 SELECT
  IF (tune_opt="T")
   FROM perf_stats n1,
    perf_stats trans,
    perf_stats logs,
    perf_stats_defn d
   PLAN (n1
    WHERE n1.change_value != 0
     AND n1.report_seq=rs)
    JOIN (trans
    WHERE trans.name="user commits"
     AND trans.report_seq=rs)
    JOIN (logs
    WHERE logs.name="logons cumulative"
     AND logs.report_seq=rs)
    JOIN (d
    WHERE trim(d.statistic)=trim(n1.name)
     AND d.tunable_flag="T")
  ELSE
   FROM perf_stats n1,
    perf_stats trans,
    perf_stats logs
   PLAN (n1
    WHERE n1.change_value != 0
     AND n1.report_seq=rs)
    JOIN (trans
    WHERE trans.name="user commits"
     AND trans.report_seq=rs)
    JOIN (logs
    WHERE logs.name="logons cumulative"
     AND logs.report_seq=rs)
  ENDIF
  INTO trim(fname)
  n1.name, n1.change_value, trans_change = round((n1.change_value/ trans.change_value),2),
  logs_change = round((n1.change_value/ logs.change_value),2)
  ORDER BY n1.name
  HEAD REPORT
   pt = 0.0, pl = 0.0, row + 1,
   row + 1, row + 1, col 1,
   "REM: The total is the total value of the statistic between the time ", row + 1, col 1,
   " bperf was run and the time eperf was run. Note that the eperf", row + 1, col 1,
   " script logs on as 'internal' so the per_logon statistics will", row + 1, col 1,
   " always be based on atleast one logon.", row + 1
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Statistic", col 60, "Total",
   col 80, "Per Transaction", col 100,
   "Per Logon", row + 1, col 1,
   line, row + 1
  DETAIL
   pt = round((n1.change_value/ trans.change_value),2), pl = round((n1.change_value/ logs
    .change_value),2), col 1,
   n1.name, col 60, n1.change_value";l"
   IF (trans_change=0)
    col 80, "0"
   ELSE
    col 80, trans_change"##########.##;l"
   ENDIF
   IF (logs_change=0)
    col 100, "0"
   ELSE
    col 100, logs_change"##########.##;l"
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  n1.event, n1.event_count_value";l", n1.time_waited_value";l",
  avetim = (n1.time_waited_value/ n1.event_count_value)";l"
  FROM perf_event n1
  PLAN (n1
   WHERE n1.event_count_value > 0
    AND n1.report_seq=rs)
  ORDER BY n1.time_waited_value DESC
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: System wide wait events.", row + 1
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Event Name", col 60, "Count",
   col 80, "Total Time", col 100,
   "Average Time", row + 1, col 1,
   line, row + 1
  DETAIL
   event = substring(1,60,n1.event), col 1, event,
   col 60, n1.event_count_value
   IF (n1.time_waited_value=0)
    col 80, "0"
   ELSE
    col 80, n1.time_waited_value
   ENDIF
   IF (avetim=0)
    col 100, "0"
   ELSE
    col 100, avetim
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  n1.event, n1.event_count_value";l", n1.time_waited_value";l",
  avetim = (n1.time_waited_value/ n1.event_count_value)";l"
  FROM perf_bckevent n1
  PLAN (n1
   WHERE n1.event_count_value > 0
    AND n1.report_seq=rs)
  ORDER BY n1.time_waited_value DESC
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: System wide wait events for background processes ", row + 1,
   col 1, "(PMON,SMON,etc).", row + 1
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Event Name", col 60, "Count",
   col 80, "Total Time", col 100,
   "Average Time", row + 1, col 1,
   line, row + 1
  DETAIL
   event = substring(1,60,n1.event), col 1, event,
   col 60, n1.event_count_value
   IF (n1.time_waited_value=0)
    col 80, "0"
   ELSE
    col 80, n1.time_waited_value
   ENDIF
   IF (avetim=0)
    col 100, "0"
   ELSE
    col 100, avetim
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  awql = (queue.change_value/ writes.change_value)
  FROM perf_stats queue,
   perf_stats writes
  PLAN (queue
   WHERE queue.name="summed dirty queue length"
    AND queue.report_seq=rs)
   JOIN (writes
   WHERE writes.name="write requests"
    AND writes.report_seq=rs)
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: Average length of the dirty buffer write queue. If this is ", row + 1,
   col 1, "larger than the value of the db_block_write_batch init.ora parameter,", row + 1,
   col 1, "then consider increasing the value of db_block_write_batch and ", row + 1,
   col 1, "check for disks that are doing many more IOs than other disks.", row + 1
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Average Write Queue Length", row + 1, col 1,
   line, row + 1
  DETAIL
   col 1, awql";l", row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.table_space, s.file_name, s.phy_reads_value,
  s.phy_blks_rd_value, s.phy_rd_time_value, s.phy_writes_value,
  s.phy_blks_wr_value, s.phy_wrt_time_value
  FROM perf_files s
  PLAN (s
   WHERE s.report_seq=rs)
  ORDER BY s.table_space, s.file_name
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: I/O should be spread evenly across drives. A big difference ", row + 1,
   col 1, "between phy_reads and phy_blks_rd implies table scans are going on."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Table_space", col 30, "File Name",
   row + 1, col 1, "Phy_Reads",
   col 15, "Phy_Blks_Rd", col 35,
   "Phy_Rd_Time", col 50, "Phy_Writes",
   col 65, "Phy_Blks_Wrt", col 80,
   "Phy_Wrt_Time", row + 1, col 1,
   line, row + 1
  DETAIL
   ts = substring(1,30,s.table_space), fn = substring(1,60,s.file_name), col 1,
   ts, col 30, fn,
   row + 1, col 1, s.phy_reads_value";l",
   col 15, s.phy_blks_rd_value";l", col 35,
   s.phy_rd_time_value";l", col 50, s.phy_writes_value";l",
   col 65, s.phy_blks_wr_value";l", col 80,
   s.phy_wrt_time_value";l", row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.table_space, pyr = sum(s.phy_reads_value), pbr = sum(s.phy_blks_rd_value),
  prt = sum(s.phy_rd_time_value), pyw = sum(s.phy_writes_value), pbw = sum(s.phy_blks_wr_value),
  pwt = sum(s.phy_wrt_time_value)
  FROM perf_files s
  PLAN (s
   WHERE s.report_seq=rs)
  GROUP BY s.table_space
  ORDER BY s.table_space
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: Sum over tablespaces.", row + 1
  HEAD PAGE
   row + 1, col 1, "Table Space",
   col 25, "Phy_Reads", col 40,
   "Phy_Blks_Rd", col 55, "Phy_Rd_Time",
   col 70, "Phy_Writes", col 85,
   "Phy_Blks_Wr", col 100, "Phy_Wrt_Time",
   row + 1, col 1, line,
   row + 1
  DETAIL
   col 1, s.table_space, col 25,
   pyr";l", col 40, pbr";l",
   col 55, prt";l", col 70,
   pyw";l", col 85, pbw";l",
   col 100, pwt";l", row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.disk_name, pyr = sum(s.phy_reads_value), pbr = sum(s.phy_blks_rd_value),
  prt = sum(s.phy_rd_time_value), pyw = sum(s.phy_writes_value), pbw = sum(s.phy_blks_wr_value),
  pwt = sum(s.phy_wrt_time_value)
  FROM perf_files s
  PLAN (s
   WHERE s.report_seq=rs)
  GROUP BY s.disk_name
  ORDER BY s.disk_name
  HEAD REPORT
   row_count = 0
  HEAD PAGE
   IF (row_count > 0)
    row + 1, col 1, "Disk_name ",
    col 25, "Phy_Reads", col 40,
    "Phy_Blks_Rd", col 55, "Phy_Rd_Time",
    col 70, "Phy_Writes", col 85,
    "Phy_Blks_Wr", col 100, "Phy_Wrt_Time",
    row + 1, col 1, line,
    row + 1
   ENDIF
  DETAIL
   IF (row_count=0
    AND s.disk_name != " ")
    row + 1, row + 1, row + 1,
    col 1, "REM: Sum over disk.", row + 1,
    col 1, "Disk_name ", col 25,
    "Phy_Reads", col 40, "Phy_Blks_Rd",
    col 55, "Phy_Rd_Time", col 70,
    "Phy_Writes", col 85, "Phy_Blks_Wr",
    col 100, "Phy_Wrt_Time", row + 1,
    col 1, line, row + 1
   ENDIF
   IF (s.disk_name != " ")
    col 1, s.disk_name, col 25,
    pyr";l", col 40, pbr";l",
    col 55, prt";l", col 70,
    pyw";l", col 85, pbw";l",
    col 100, pwt";l", row + 1
   ENDIF
   row_count = (row_count+ 1)
  WITH size = 132, append, noformfeed,
   maxrow = 1, noer
 ;end select
 SELECT INTO trim(fname)
  s.name, s.gets_value, s.misses_value,
  s.sleeps_value
  FROM perf_latches s
  PLAN (s
   WHERE s.gets_value != 0
    AND s.report_seq=rs)
  ORDER BY s.name
  HEAD REPORT
   ge = 0.0, mi = 0.0, gm = 0.0,
   hr = 0.0, sm = 0.0, row + 1,
   row + 1, row + 1, col 1,
   "REM: Sleeps should be low. The hit ratio should be high.", row + 1
  HEAD PAGE
   row + 1, col 1, "Latch Name",
   col 30, "Gets", col 45,
   "Misses", col 60, "Hit Ratio",
   col 75, "Sleeps", col 90,
   "Sleeps/Misses", row + 1, col 1,
   line, row + 1
  DETAIL
   IF (s.gets_value=0)
    ge = 1
   ELSE
    ge = s.gets_value
   ENDIF
   IF (s.misses_value=0)
    mi = 1
   ELSE
    mi = s.misses_value
   ENDIF
   IF (((s.gets_value - s.misses_value)=0))
    gm = 1
   ELSE
    gm = (s.gets_value - s.misses_value)
   ENDIF
   hr = round((gm/ ge),3), sm = round((s.sleeps_value/ mi),3), col 1,
   s.name, col 30, s.gets_value";l",
   col 45, s.misses_value";l"
   IF (hr=0)
    col 60, "0"
   ELSE
    col 60, hr"###.###;l"
   ENDIF
   col 75, s.sleeps_value";l"
   IF (sm=0)
    col 90, "0"
   ELSE
    col 90, sm"###.###;l"
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.name, s.immediate_gets_value, s.immediate_misses_value
  FROM perf_latches s
  PLAN (s
   WHERE s.immediate_gets_value != 0
    AND s.report_seq=rs)
  ORDER BY s.name
  HEAD REPORT
   ge = 0.0, gm = 0.0, hr = 0.0,
   row + 1, row + 1, row + 1,
   col 1, "REM: Statistics on no_wait gets of latches. A no_wait get does ", row + 1,
   col 1, "not wait for the latch to become free, it immediately times out."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "latch Name", col 30, "Nowait_Gets",
   col 50, "Nowait_Misses", col 70,
   "Nowait_Hitratio", row + 1, col 1,
   line, row + 1
  DETAIL
   IF (s.immediate_gets_value=0)
    ge = 1
   ELSE
    ge = s.immediate_gets_value
   ENDIF
   IF (((s.immediate_gets_value - s.immediate_misses_value)=0))
    gm = 1
   ELSE
    gm = (s.immediate_gets_value - s.immediate_misses_value)
   ENDIF
   hr = round((gm/ ge),3), col 1, s.name
   IF (s.immediate_gets_value=0)
    col 30, "0"
   ELSE
    col 30, s.immediate_gets_value";l"
   ENDIF
   IF (s.immediate_misses_value=0)
    col 50, "0"
   ELSE
    col 50, s.immediate_misses_value";l"
   ENDIF
   IF (hr=0)
    col 70, "0"
   ELSE
    col 70, hr"###.###;l"
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.undo_segment";l", s.trans_tbl_gets_value";l", s.trans_tbl_waits";l",
  s.undo_bytes_written_value";l", s.segment_size_bytes_value";l", s.xacts";l",
  s.shrinks";l", s.wraps";l"
  FROM perf_roll s
  PLAN (s
   WHERE s.report_seq=rs)
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: Waits_for_trans_tbl high implies you should add rollback segments."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Undo segment", col 15, "Trans_tbl_gets",
   col 33, "Trans_tbl_waits", col 50,
   "Undo_bytes_written", col 70, "Segment_size_bytes",
   col 90, "Xacts", col 105,
   "Shrinks", col 120, "Wraps",
   row + 1, col 1, line,
   row + 1
  DETAIL
   col 1, s.undo_segment
   IF (s.trans_tbl_gets_value=0)
    col 15, "0"
   ELSE
    col 15, s.trans_tbl_gets_value
   ENDIF
   col 33, s.trans_tbl_waits
   IF (s.undo_bytes_written_value=0)
    col 50, "0"
   ELSE
    col 50, s.undo_bytes_written_value
   ENDIF
   IF (s.segment_size_bytes_value=0)
    col 70, "0"
   ELSE
    col 70, s.segment_size_bytes_value
   ENDIF
   col 90, s.xacts, col 105,
   s.shrinks, col 120, s.wraps,
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.class, s.count, s.time
  FROM perf_waitstat s
  PLAN (s
   WHERE s.report_seq=rs
    AND s.count != 0)
  ORDER BY s.count DESC
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: Buffer busy wait statistics. If the value for 'buffer busy", row + 1,
   col 1, "wait' in the wait event statistics is high, then this table will", row + 1,
   col 1, "identify which class of blocks is having high contention. If th-", row + 1,
   col 1, "ere are high 'undo header' waits then add more rollback segments.", row + 1,
   col 1, "If there are high 'segment header' waits then adding freelists  ", row + 1,
   col 1, "might help. Check v$session_wait to get the addresses of the act-", row + 1,
   col 1, "ual blocks having contention.", row + 1
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Class", col 30, "Count",
   col 50, "Time", row + 1,
   col 1, line, row + 1
  DETAIL
   col 1, s.class, col 30,
   s.count, col 50, s.time,
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.name, s.value
  FROM perf_parameter s
  PLAN (s
   WHERE s.report_seq=rs)
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: The instance parameters currenly in effect."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Name", col 50, "Value",
   row + 1, col 1, line,
   row + 1
  DETAIL
   value = substring(1,50,s.value), name = substring(1,50,s.name), col 1,
   name, col 50, value,
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 SELECT INTO trim(fname)
  s.name, s.get_reqs_value";l", s.get_miss_value";l",
  s.scan_reqs_value";l", s.scan_miss_value";l", s.mod_reqs_value";l",
  s.count_value";l", s.cur_usage_value";l"
  FROM perf_dc s
  PLAN (s
   WHERE s.report_seq=rs
    AND s.get_reqs_value != 0
    AND ((s.scan_reqs_value != 0) OR (s.mod_reqs_value != 0)) )
  HEAD REPORT
   row + 1, row + 1, row + 1,
   col 1, "REM: Get_miss and scan_miss should be very low compared to the ", row + 1,
   col 1, "requests. cur_usage is the number of entries in the cache that", row + 1,
   col 1, " are being used."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Name", col 25, "Get_Reqs",
   col 40, "Get_Miss", col 55,
   "Scan_Reqs", col 70, "Scan_Miss",
   col 85, "Mod_Reqs", col 100,
   "Count", col 115, "Cur_usage",
   row + 1, col 1, line,
   row + 1
  DETAIL
   col 1, s.name
   IF (s.get_reqs_value=0)
    col 25, "0"
   ELSE
    col 25, s.get_reqs_value
   ENDIF
   IF (s.get_miss_value=0)
    col 40, "0"
   ELSE
    col 40, s.get_miss_value
   ENDIF
   IF (s.scan_reqs_value=0)
    col 55, "0"
   ELSE
    col 55, s.scan_reqs_value
   ENDIF
   IF (s.scan_miss_value=0)
    col 70, "0"
   ELSE
    col 70, s.scan_miss_value
   ENDIF
   IF (s.mod_reqs_value=0)
    col 85, "0"
   ELSE
    col 85, s.mod_reqs_value
   ENDIF
   IF (s.count_value=0)
    col 100, "0"
   ELSE
    col 100, s.count_value
   ENDIF
   IF (s.cur_usage_value=0)
    col 115, "0"
   ELSE
    col 115, s.cur_usage_value
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 IF (defn_opt="Y")
  SELECT INTO trim(fname)
   s.*
   FROM perf_stats_defn s
   ORDER BY s.statistic
   HEAD REPORT
    col 0, "REM: Document for all statistics with their definition. All the", row + 1,
    col 0, " statistics with a definition 'For internal use' are not tunable.", row + 1,
    row + 1
   HEAD PAGE
    col 0, "Statistic", col 54,
    "Definition", row + 1, col 0,
    line, row + 1
   DETAIL
    stat = substring(1,50,s.statistic), def1 = substring(1,77,s.definition), def2 = substring(78,77,s
     .definition),
    def3 = substring(155,77,s.definition), def4 = substring(232,77,s.definition), def5 = substring(
     309,77,s.definition),
    col 0, stat, col 54,
    def1
    IF (def2 != " ")
     row + 1, col 54, def2
    ENDIF
    IF (def3 != " ")
     row + 1, col 54, def3
    ENDIF
    IF (def4 != " ")
     row + 1, col 54, def4
    ENDIF
    IF (def5 != " ")
     row + 1, col 54, def5
    ENDIF
    row + 1
   WITH size = 132, append, noformfeed,
    maxrow = 1, nocounter
  ;end select
 ENDIF
 SET message = information
 SET trace = cost
 CALL text(23,1,"Report generated and is available in ccluserdir: ")
 CALL text(23,50,concat(trim(fname),".dat"))
 CALL accept(23,70,"p;c"," ")
 EXECUTE db_rpt_perf
END GO
