CREATE PROGRAM dba_perf_trend_lib
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.namespace = b.namespace(+) ")
 SET wc = build(wc," union ( select b.*,a.* from perf_lib a, perf_lib b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.namespace(+) = b.namespace)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bnamespace = a.namespace, bgets_value = a.gets_value,
  bgethits_value = a.gethits_value, bpins_value = a.pins_value, bpinhits_value = a.pinhits_value,
  breloads_value = a.reloads_value, binvalidations = a.invalidations, cseq = b.report_seq,
  cnamespace = b.namespace, cgets_value = b.gets_value, cgethits_value = b.gethits_value,
  cpins_value = b.pins_value, cpinhits_value = b.pinhits_value, creloads_value = b.reloads_value,
  cinvalidations = b.invalidations
  FROM perf_lib a,
   perf_lib b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, namespace =
  IF (p.cnamespace=" ") p.bnamespace
  ELSE p.cnamespace
  ENDIF
  FROM perf_temp p
  ORDER BY namespace
  HEAD REPORT
   line = fillstring(131,"-"), mgets = 0.0, mghits = 0.0,
   mpins = 0.0, mpinhits = 0.0, mreloads = 0.0,
   minvalidations = 0.0, gr = 0.0, pr = 0.0,
   bgr = 0.0, cgr = 0.0, bpr = 0.0,
   cpr = 0.0, bge = 0.0, cge = 0.0,
   bghits = 0.0, cghits = 0.0, bpins = 0.0,
   cpins = 0.0, bphits = 0.0, cphits = 0.0,
   row + 1, row + 1, row + 1,
   col 0, "Rem : Selects Library cache statistics"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Library", col 25, "Gets",
   col 37, "Get Hitratio", col 64,
   "Pins", col 75, "Pin Hitratio",
   col 97, "Reloads", col 110,
   "Invalidations", row + 1, col 0,
   line
  DETAIL
   mgets = (p.cgets_value - p.bgets_value), mghits = (p.cgethits_value - p.bgethits_value), mpins = (
   p.cpins_value - p.bpins_value),
   mpinhits = (p.cpinhits_value - p.bpinhits_value), mreloads = (p.creloads_value - p.breloads_value),
   minvalidations = (p.cinvalidations - p.binvalidations)
   IF (p.bgets_value=0)
    bge = 1
   ELSE
    bge = p.bgets_value
   ENDIF
   IF (p.bgethits_value=0)
    bghits = 1
   ELSE
    bghits = p.bgethits_value
   ENDIF
   IF (p.bpins_value=0)
    bpins = 1
   ELSE
    bpins = p.bpins_value
   ENDIF
   IF (p.bpinhits_value=0)
    bphits = 1
   ELSE
    bphits = p.bpinhits_value
   ENDIF
   bpr = round((bphits/ bpins),4), bgr = round((bghits/ bge),4)
   IF (p.cgets_value=0)
    cge = 1
   ELSE
    cge = p.cgets_value
   ENDIF
   IF (p.cgethits_value=0)
    cghits = 1
   ELSE
    cghits = p.cgethits_value
   ENDIF
   IF (p.cpins_value=0)
    cpins = 1
   ELSE
    cpins = p.cpins_value
   ENDIF
   IF (p.cpinhits_value=0)
    cphits = 1
   ELSE
    cphits = p.cpinhits_value
   ENDIF
   cpr = round((cphits/ cpins),4), cgr = round((cghits/ cge),4), gr = (cgr - bgr),
   pr = (cpr - bpr), zero = 0, name = substring(1,20,namespace),
   row + 1, col 1, name
   IF (mgets=0)
    col 20, zero
   ELSE
    col 20, mgets
   ENDIF
   IF (gr=0)
    col 35, zero
   ELSE
    col 42, gr"##.###"
   ENDIF
   IF (mpins=0)
    col 57, zero
   ELSE
    col 57, mpins
   ENDIF
   IF (pr=0)
    col 72, zero
   ELSE
    col 79, pr"##.###"
   ENDIF
   IF (mreloads=0)
    col 92, zero
   ELSE
    col 92, mreloads
   ENDIF
   IF (minvalidations=0)
    col 107, zero
   ELSE
    col 107, minvalidations
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
