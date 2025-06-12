CREATE PROGRAM dba_perf_trend_event
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.event = b.event(+) and a.event_count_value > 0")
 SET wc = build(wc," union ( select b.*,a.* from perf_event a, perf_event b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.event(+) = b.event and b.event_count_value > 0 )")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bevent = a.event, btime_waited = a.time_waited_value,
  bevent_count = a.event_count_value, cseq = b.report_seq, cevent = b.event,
  ctime_waited = b.time_waited_value, cevent_count = b.event_count_value
  FROM perf_event a,
   perf_event b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, bavetime = (p.btime_waited/ p.bevent_count), cavetime = (p.ctime_waited/ p.cevent_count),
  temp_event =
  IF (p.cevent=" ") p.bevent
  ELSE p.cevent
  ENDIF
  FROM perf_temp p
  ORDER BY temp_event
  HEAD REPORT
   line = fillstring(131,"-"), zero = 0, mtime_waited = 0.0,
   mevent_count = 0.0, mavetim = 0.0, row + 1,
   row + 1, row + 1, col 0,
   "Rem : System wide wait events"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Event Name", col 48, "Count",
   col 65, "Total Time ", col 85,
   "Average Time", row + 1, col 0,
   line, row + 1
  DETAIL
   mevent_count = (p.cevent_count - p.bevent_count), mtime_waited = (p.ctime_waited - p.btime_waited),
   mavetim = (cavetime - bavetime),
   mavetim = round(mavetim,4), row + 1, col 1,
   temp_event
   IF (mevent_count=0)
    col 40, zero
   ELSE
    col 40, mevent_count
   ENDIF
   IF (mtime_waited=0)
    col 60, zero
   ELSE
    col 60, mtime_waited
   ENDIF
   IF (mavetim=0)
    col 80, zero
   ELSE
    col 80, mavetim"#########.####"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
