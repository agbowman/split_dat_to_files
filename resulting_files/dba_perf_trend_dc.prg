CREATE PROGRAM dba_perf_trend_dc
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.cache# = b.cache#(+) and a.subordinate# = b.subordinate#(+)")
 SET wc = build(wc," union ( select b.*,a.* from perf_dc a, perf_dc b ")
 SET wc = concat(trim(wc),wc2)
 SET wc = build(wc," and a.cache#(+) = b.cache# and a.subordinate#(+) = b.subordinate#)")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bcache = a.cache#, bsub = a.subordinate#,
  bget_reqs = a.get_reqs_value, bget_miss = a.get_miss_value, bscan_reqs = a.scan_reqs_value,
  bscan_miss = a.scan_miss_value, bmod_reqs = a.mod_reqs_value, bcount = a.count_value,
  bcur_usage = a.cur_usage_value, bname = a.name, cseq = b.report_seq,
  ccache = b.cache#, csub = b.subordinate#, cget_reqs = b.get_reqs_value,
  cget_miss = b.get_miss_value, cscan_reqs = b.scan_reqs_value, cscan_miss = b.scan_miss_value,
  cmod_reqs = b.mod_reqs_value, ccount = b.count_value, ccur_usage = b.cur_usage_value,
  cname = b.name
  FROM perf_dc a,
   perf_dc b
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
   line = fillstring(131,"-"), mget_reqs = 0.0, mget_misses = 0.0,
   mscan_reqs = 0.0, mscan_miss = 0.0, mmod_reqs = 0.0,
   mcount = 0.0, mcur_usage = 0.0, row + 1,
   row + 1, row + 1, col 0,
   "Rem: DC Cache"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Name", col 25, "Get_Reqs",
   col 40, "Get_Misss", col 55,
   "Scan_Reqs", col 70, "Scan_Miss",
   col 85, "Mod_Reqs", col 100,
   "Count", col 115, "Cur_Usage",
   row + 1, col 0, line,
   row + 1
  DETAIL
   mget_reqs = (p.cget_reqs - p.bget_reqs), mget_miss = (p.cget_miss - p.bget_miss), mscan_reqs = (p
   .cscan_reqs - p.bscan_reqs),
   mscan_miss = (p.cscan_miss - p.bscan_miss), mmod_reqs = (p.cmod_reqs - p.bmod_reqs), mcount = (p
   .ccount - p.bcount),
   mcur_usage = (p.ccur_usage - p.bcur_usage), row + 1, col 1,
   name
   IF (mget_reqs=0)
    col 25, "0"
   ELSE
    col 25, mget_reqs";l"
   ENDIF
   IF (mget_miss=0)
    col 40, "0"
   ELSE
    col 40, mget_miss";l"
   ENDIF
   IF (mscan_reqs=0)
    col 55, "0"
   ELSE
    col 55, mscan_reqs";l"
   ENDIF
   IF (mscan_miss=0)
    col 70, "0"
   ELSE
    col 70, mscan_miss";l"
   ENDIF
   IF (mmod_reqs=0)
    col 85, "0"
   ELSE
    col 85, mmod_reqs";l"
   ENDIF
   IF (mcount=0)
    col 100, "0"
   ELSE
    col 100, mcount";l"
   ENDIF
   IF (mcur_usage=0)
    col 115, "0"
   ELSE
    col 115, mcur_usage";l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
