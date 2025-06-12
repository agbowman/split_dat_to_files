CREATE PROGRAM dba_perf_trend_waitstat
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.class = b.class(+) union ")
 SET wc = build(wc," ( select b.*,a.* from perf_waitstat a, perf_waitstat b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.class(+) = b.class)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bclass = a.class, bcount = a.count,
  btime = a.time, cseq = b.report_seq, cclass = b.class,
  ccount = b.count, ctime = b.time
  FROM perf_waitstat a,
   perf_waitstat b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, class =
  IF (cclass=" ") p.bclass
  ELSE p.cclass
  ENDIF
  FROM perf_temp p
  ORDER BY class
  HEAD REPORT
   line = fillstring(131,"-"), mcount = 0.0, mtime = 0.0,
   row + 1, row + 1, row + 1,
   col 0, "Rem: Trended waitstatisitcs."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Class ", col 30, "Count",
   col 50, "Time", row + 1,
   col 0, line, row + 1
  DETAIL
   mcount = (p.ccount - p.bcount), mtime = (p.ctime - p.btime), col 1,
   class, col 30, mcount";l",
   col 50, mtime";l", row + 1
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
