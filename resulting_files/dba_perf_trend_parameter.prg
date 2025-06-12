CREATE PROGRAM dba_perf_trend_parameter
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.name = b.name(+) union ")
 SET wc = build(wc,"(select b.*,a.* from perf_parameter a, perf_parameter b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.name(+) = b.name )")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bname = a.name, bvalue = a.value,
  cseq = b.report_seq, cname = b.name, cvalue = b.value
  FROM perf_parameter a,
   perf_parameter b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*
  FROM perf_temp p
  WHERE ((p.bname != p.cname
   AND p.bvalue != p.cvalue) OR (p.bname=p.cname
   AND p.bvalue != p.cvalue))
  ORDER BY p.bname, p.cname
  HEAD REPORT
   line = fillstring(131,"-"), row + 1, row + 1,
   row + 1, col 0, "Rem: Modified Instance Parameters"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Rep_seq", col 10, "Name",
   col 60, "Value", row + 1,
   col 0, line
  DETAIL
   bname = substring(1,50,p.bname), cname = substring(1,50,p.cname), bvalue = substring(1,70,p.bvalue
    ),
   cvalue = substring(1,70,p.cvalue)
   IF (p.bname != " ")
    row + 1, col 1, p.bseq";l",
    col 10, bname, col 60,
    bvalue";l"
   ENDIF
   IF (p.cname != " ")
    row + 1, col 1, p.cseq";l",
    col 10, cname, col 60,
    cvalue";l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
