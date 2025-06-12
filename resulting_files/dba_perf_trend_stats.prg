CREATE PROGRAM dba_perf_trend_stats
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET fname = request->fname
 SET line = fillstring(131,"-")
 SET par_buf[80] = fillstring(100," ")
 SET par_buf[1] = "insert into perf_trend_begin_stats s(s.name,s.change_value,"
 SET par_buf[2] = "s.trans_value,s.logs_value)"
 SET par_buf[3] = "(select a.name,a.change_value,"
 SET par_buf[4] = "a.change_value/t.change_value,"
 SET par_buf[5] = "a.change_value/l.change_value"
 SET par_buf[6] = " from perf_stats a,perf_stats t,perf_stats l"
 SET par_buf[7] = " where a.change_value != 0 and t.name = 'user commits'"
 SET par_buf[8] = " and l.name = 'logons cumulative' and "
 SET par_buf[9] = build("a.report_seq = ",base_seq)
 SET par_buf[10] = build("and t.report_seq = ",base_seq)
 SET par_buf[11] = build("and l.report_seq = ",base_seq)
 SET par_buf[12] = ") go"
 FOR (i = 1 TO 12)
   CALL parser(par_buf[i],1)
 ENDFOR
 SET par_buf[80] = fillstring(100," ")
 SET par_buf[1] = "insert into perf_trend_end_stats s(s.name,s.change_value,"
 SET par_buf[2] = "s.trans_value,s.logs_value)"
 SET par_buf[3] = "(select a.name,a.change_value,"
 SET par_buf[4] = "a.change_value/t.change_value,"
 SET par_buf[5] = "a.change_value/l.change_value"
 SET par_buf[6] = " from perf_stats a,perf_stats t,perf_stats l"
 SET par_buf[7] = " where a.change_value != 0 and t.name = 'user commits'"
 SET par_buf[8] = " and l.name = 'logons cumulative' and "
 SET par_buf[9] = build("a.report_seq = ",comp_seq)
 SET par_buf[10] = build("and t.report_seq = ",comp_seq)
 SET par_buf[11] = build("and l.report_seq = ",comp_seq)
 SET par_buf[12] = ") go"
 FOR (i = 1 TO 12)
   CALL parser(par_buf[i],1)
 ENDFOR
 SET wc = fillstring(300," ")
 SET wc = " a.name = b.name(+) "
 SET wc = build(wc," union ( select b.*,a.* from perf_trend_begin_stats a,")
 SET wc = build(wc,"  perf_trend_end_stats b ")
 SET wc = build(wc," where a.name(+) = b.name)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bname = a.name, bchange_value = a.change_value, btrans_value = a.trans_value,
  blogs_value = a.logs_value, cname = b.name, cchange_value = b.change_value,
  ctrans_value = b.trans_value, clogs_value = b.logs_value
  FROM perf_trend_begin_stats a,
   perf_trend_end_stats b
  WHERE sqlpassthru(wc)
 ;end select
 SELECT
  IF ((request->tune_stats="Y"))
   FROM perf_temp p,
    perf_stats_defn d
   PLAN (p)
    JOIN (d
    WHERE ((trim(d.statistic)=trim(p.bname)) OR (trim(d.statistic)=trim(p.cname)))
     AND d.tunable_flag="T")
  ELSE
   FROM perf_temp p
  ENDIF
  INTO trim(fname)
  p.*, name =
  IF (p.bname=" ") p.cname
  ELSE p.bname
  ENDIF
  FROM perf_temp p
  ORDER BY name
  HEAD REPORT
   zero = 0, mchange = 0.0, trans_change = 0.0,
   logs_change = 0.0, row + 1, row + 1,
   row + 1, col 0, "Rem : System statistics"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Statisitc", col 58, "Total",
   col 70, "Per Transaction", col 95,
   "Per Logon", row + 1, col 0,
   line, row + 1
  DETAIL
   mchange = (p.cchange_value - p.bchange_value), trans_change = (p.ctrans_value - p.btrans_value),
   logs_change = (p.clogs_value - p.blogs_value),
   col 1, name
   IF (mchange=0)
    col 50, zero
   ELSE
    col 50, mchange
   ENDIF
   IF (trans_change=0)
    col 70, zero
   ELSE
    col 70, trans_change
   ENDIF
   IF (logs_change=0)
    col 90, zero
   ELSE
    col 90, logs_change
   ENDIF
   row + 1
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
 SET bawql = 0.0
 SELECT INTO "nl:"
  awql = (queue.change_value/ writes.change_value)
  FROM perf_stats queue,
   perf_stats writes
  PLAN (queue
   WHERE queue.name="summed dirty queue length"
    AND queue.report_seq=base_seq)
   JOIN (writes
   WHERE writes.name="write requests"
    AND writes.report_seq=queue.report_seq)
  DETAIL
   bawql = 0.0, bawql = awql
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  awql = (queue.change_value/ writes.change_value)
  FROM perf_stats queue,
   perf_stats writes
  PLAN (queue
   WHERE queue.name="summed dirty queue length"
    AND queue.report_seq=comp_seq)
   JOIN (writes
   WHERE writes.name="write requests"
    AND writes.report_seq=comp_seq)
  HEAD REPORT
   row + 1, row + 1, row + 1,
   ave_wrt_que_len = 0.0, row + 1, row + 1,
   row + 1, col 0, "Average length of the dirty buffer write queue"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Average Write Queue Length", row + 1, col 0,
   line, row + 1
  DETAIL
   ave_wrt_que_len = (awql - bawql)
   IF (ave_wrt_que_len=0)
    col 1, "0"
   ELSE
    col 1, ave_wrt_que_len";l"
   ENDIF
   row + 1
  WITH size = 132, append, noformfeed,
   maxrow = 1, nocounter
 ;end select
 ROLLBACK
END GO
