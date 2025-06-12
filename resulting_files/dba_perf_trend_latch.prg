CREATE PROGRAM dba_perf_trend_latch
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(500," ")
 SET wc = build(wc1," and a.latch# = b.latch#(+) ")
 SET wc = build(wc," union ( select b.report_seq,b.gets_value,b.misses_value,")
 SET wc = build(wc,"b.sleeps_value,b.name,a.report_seq,a.gets_value,")
 SET wc = build(wc," a.misses_value,a.sleeps_value,a.name ")
 SET wc = build(wc,"  from perf_latches a, perf_latches b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.latch#(+) = b.latch#)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bgets = a.gets_value, bmisses = a.misses_value,
  bsleeps = a.sleeps_value, bname = a.name, cseq = b.report_seq,
  cgets = b.gets_value, cmisses = b.misses_value, csleeps = b.sleeps_value,
  cname = b.name
  FROM perf_latches a,
   perf_latches b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, name =
  IF (p.bname=" ") p.cname
  ELSE p.bname
  ENDIF
  FROM perf_temp p
  ORDER BY name
  HEAD REPORT
   line = fillstring(131," "), ge = 0.0, mi = 0.0,
   gm = 0.0, hr = 0.0, sm = 0.0,
   sleeps = 0.0, row + 1, row + 1,
   row + 1, col 0, "Rem : Latch statistics"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Latch Name", col 40, "Gets",
   col 55, "Missses", col 70,
   "Hit Ratio", col 85, "Sleeps",
   col 100, "Sleeps/Misses", row + 1,
   col 0, line, row + 1
  DETAIL
   ge = (p.cgets - p.bgets), mi = (p.cmisses - p.bmisses), sleeps = (p.csleeps - p.bsleeps),
   gm = ((p.cgets - p.cmisses) - (p.bgets - p.bmisses))
   IF (ge=0)
    ge = 1
   ENDIF
   IF (mi=0)
    mi = 1
   ENDIF
   IF (gm=0)
    gm = 1
   ENDIF
   hr = round((gm/ ge),3), sm = round((sleeps/ mi),3), row + 1,
   col 1, name
   IF (ge=0)
    col 40, "0"
   ELSE
    col 40, ge";l"
   ENDIF
   IF (mi=0)
    col 55, "0"
   ELSE
    col 55, mi";l"
   ENDIF
   IF (hr=0)
    col 70, "0"
   ELSE
    col 70, hr"###.###;l"
   ENDIF
   IF (sleeps=0)
    col 85, "0"
   ELSE
    col 85, sleeps";l"
   ENDIF
   IF (sm=0)
    col 100, "0"
   ELSE
    col 100, sm"###.###;l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
 SET wc = fillstring(500," ")
 SET wc = build(wc1," and a.latch# = b.latch#(+) ")
 SET wc = build(wc," union ( select b.report_seq,b.immediate_gets_value,")
 SET wc = build(wc,"b.immediate_misses_value,b.name,a.report_seq,")
 SET wc = build(wc," a.immediate_gets_value,a.immediate_misses_value,a.name ")
 SET wc = build(wc,"  from perf_latches a, perf_latches b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.latch#(+) = b.latch#)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bgets = a.immediate_gets_value, bmisses = a.immediate_misses_value,
  bname = a.name, cseq = b.report_seq, cgets = b.immediate_gets_value,
  cmisses = b.immediate_misses_value, cname = b.name
  FROM perf_latches a,
   perf_latches b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, name =
  IF (p.bname=" ") p.cname
  ELSE p.bname
  ENDIF
  FROM perf_temp p
  ORDER BY name
  HEAD REPORT
   line = fillstring(131,"-"), ge = 0.0, gm = 0.0,
   hr = 0.0, mi = 0.0, row + 1,
   row + 1, row + 1, col 1,
   "Rem: Statistics on no_wait gets of latches"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Latch Name", col 40, "Nowait_Gets",
   col 60, "Nowait_Missses", col 80,
   "Nowait_Hitratio", row + 1, col 0,
   line, row + 1
  DETAIL
   ge = (p.cgets - p.bgets), mi = (p.cmisses - p.bmisses), gm = ((p.cgets - p.cmisses) - (p.bgets - p
   .bmisses))
   IF (ge=0)
    ge = 1
   ENDIF
   IF (mi=0)
    mi = 0
   ENDIF
   IF (gm=0)
    gm = 1
   ENDIF
   hr = round((gm/ ge),3), row + 1, col 1,
   name, col 40, ge";l",
   col 60, mi";l"
   IF (hr=0)
    col 80, "0"
   ELSE
    col 80, hr"###.###;l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
