CREATE PROGRAM dba_perf_trend_roll
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.undo_segment = b.undo_segment(+) ")
 SET wc = build(wc," union ( select b.*,a.* from perf_roll a, perf_roll b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.undo_segment(+) = b.undo_segment) ")
 FREE SELECT perf_temp
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, busn = a.undo_segment, bgets = a.trans_tbl_gets_value,
  bwaits = a.trans_tbl_waits, bbytes = a.undo_bytes_written_value, bsize = a.segment_size_bytes_value,
  bxacts = a.xacts, bshrinks = a.shrinks, bwraps = a.wraps,
  cseq = b.report_seq, cusn = b.undo_segment, cgets = b.trans_tbl_gets_value,
  cwaits = b.trans_tbl_waits, cbytes = b.undo_bytes_written_value, csize = b.segment_size_bytes_value,
  cxacts = b.xacts, cshrinks = b.shrinks, cwraps = b.wraps
  FROM perf_roll a,
   perf_roll b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, undo_segment =
  IF (p.busn=null) p.cusn
  ELSE p.busn
  ENDIF
  FROM perf_temp p
  ORDER BY undo_segment
  HEAD REPORT
   line = fillstring(131,"-"), mgets = 0.0, mwaits = 0.0,
   mubw = 0.0, mseg_sb = 0.0, mxacts = 0.0,
   mshrinks = 0.0, mwraps = 0.0, row + 1,
   row + 1, row + 1, col 1,
   "Rem: Rollback segment statistics"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Undo Segment ", col 15, "Trans_tbl_Gets",
   col 33, "Trans_tbl_Waits", col 50,
   "Undo_Bytes_Written", col 70, "Segment_Size_Bytes",
   col 90, "Xacts", col 103,
   "Shrinks", col 115, "Wraps",
   row + 1, col 0, line,
   row + 1
  DETAIL
   mgets = (p.cgets - p.bgets), mwaits = (p.cwaits - p.bwaits), mubw = (p.cbytes - p.bbytes),
   mseg_sb = (p.csize - p.bsize), mxacts = (p.cxacts - p.bxacts), mshrinks = (p.cshrinks - p.bshrinks
   ),
   mwraps = (p.cwraps - p.bwraps), row + 1, col 1,
   undo_segment";l"
   IF (mgets=0)
    col 15, "0"
   ELSE
    col 15, mgets";l"
   ENDIF
   IF (mwaits=0)
    col 33, "0"
   ELSE
    col 33, mwaits";l"
   ENDIF
   IF (mubw=0)
    col 50, "0"
   ELSE
    col 50, mubw";l"
   ENDIF
   IF (mseg_sb=0)
    col 70, "0"
   ELSE
    col 70, mseg_sb";l"
   ENDIF
   IF (mxacts=0)
    col 90, "0"
   ELSE
    col 90, mxacts";l"
   ENDIF
   IF (mshrinks=0)
    col 103, "0"
   ELSE
    col 103, mshrinks";l"
   ENDIF
   IF (mwraps=0)
    col 115, "0"
   ELSE
    col 115, mwraps";l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
