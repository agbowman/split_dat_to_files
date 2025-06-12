CREATE PROGRAM dba_perf_trend_bckevent
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.event = b.event(+) union ")
 SET wc = build(wc," ( select b.*,a.* from perf_bckevent a, perf_bckevent b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.event(+) = b.event)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bevent = a.event, btime_waited = a.time_waited_value,
  bevent_count = a.event_count_value, cseq = b.report_seq, cevent = b.event,
  ctime_waited = b.time_waited_value, cevent_count = b.event_count_value
  FROM perf_bckevent a,
   perf_bckevent b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, temp_event =
  IF (p.cevent=" ") p.bevent
  ELSE p.cevent
  ENDIF
  FROM perf_temp p
  ORDER BY temp_event
  HEAD REPORT
   line = fillstring(131,"-"), mecount = 0.0, mtwaited = 0.0,
   row + 1, row + 1, row + 1,
   col 0, "Rem: Trended background events."
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Event ", col 50, "Count",
   col 70, "Total Time", row + 1,
   col 0, line, row + 1
  DETAIL
   mecount = (p.cevent_count - p.bevent_count), mtwaited = (p.ctime_waited - p.btime_waited), event
    = substring(1,50,temp_event),
   col 1, event
   IF (mecount=0)
    col 50, "0"
   ELSE
    col 50, mecount";l"
   ENDIF
   IF (mtwaited=0)
    col 70, "0"
   ELSE
    col 70, mtwaited";l"
   ENDIF
   row + 1
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
