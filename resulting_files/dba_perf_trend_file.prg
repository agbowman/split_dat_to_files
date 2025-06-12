CREATE PROGRAM dba_perf_trend_file
 SET fname = request->fname
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET wc1 = request->wc1
 SET wc2 = request->wc2
 SET wc = fillstring(300," ")
 SET wc = build(wc1," and a.file_name = b.file_name(+) ")
 SET wc = build(wc," union ( select b.*,a.* ")
 SET wc = build(wc," from perf_files a, perf_files b ")
 SET wc = build(wc,wc2)
 SET wc = build(wc," and a.file_name(+) = b.file_name)")
 SELECT INTO TABLE perf_temp
  bseq = a.report_seq, bfname = a.file_name, btname = a.table_space,
  bpyr = a.phy_reads_value, bpbr = a.phy_blks_rd_value, bpbw = a.phy_blks_wr_value,
  bpyw = a.phy_writes_value, bprt = a.phy_rd_time_value, bpwt = a.phy_wrt_time_value,
  bdname = a.disk_name, cseq = b.report_seq, cfname = b.file_name,
  ctname = b.table_space, cpyr = b.phy_reads_value, cpbr = b.phy_blks_rd_value,
  cpbw = b.phy_blks_wr_value, cpyw = b.phy_writes_value, cprt = b.phy_rd_time_value,
  cpwt = b.phy_wrt_time_value, cdname = b.disk_name
  FROM perf_files a,
   perf_files b
  WHERE sqlpassthru(wc)
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  p.*, file_name =
  IF (p.bfname=" ") p.cfname
  ELSE p.bfname
  ENDIF
  , tname =
  IF (p.btname=" ") p.ctname
  ELSE p.btname
  ENDIF
  FROM perf_temp p
  ORDER BY file_name
  HEAD REPORT
   line = fillstring(131,"-"), mpr = 0.0, mpw = 0.0,
   mpbr = 0.0, mpbw = 0.0, mprt = 0.0,
   mpwt = 0.0, row + 1, row + 1,
   row + 1, col 0, "Rem : File I/O is unique to the file name not including path.",
   col 7, "So if a file is moved, it will retain its statistics. "
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Table_Space", col 30, "File Name",
   row + 1, col 1, "Phy_Reads",
   col 15, "Phy_Blks_Rd", col 35,
   "Phy_Rd_Time", col 50, "Phy_Writes",
   col 65, "Phy_Blks_Wr", col 80,
   "Phy_Wrt_Time", row + 1, col 0,
   line
  DETAIL
   mpr = (p.cpyr - p.bpyr), mpbr = (p.cpbr - p.bpbr), mpw = (p.cpyw - p.bpyw),
   mpbw = (p.cpbw - p.bpbw), mprt = (p.cprt - p.bprt), mpwt = (p.cpwt - p.bpwt),
   row + 1, fs = findstring("]",file_name,1), name = substring((fs+ 1),80,file_name),
   fname = substring(1,40,name), col 1, tname,
   col 30, fname, row + 1
   IF (mpr=0)
    col 1, "0"
   ELSE
    col 1, mpr";l"
   ENDIF
   IF (mpbr=0)
    col 15, "0"
   ELSE
    col 15, mpbr";l"
   ENDIF
   IF (mprt=0)
    col 35, "0"
   ELSE
    col 35, mprt";l"
   ENDIF
   IF (mpw=0)
    col 50, "0"
   ELSE
    col 50, mpw";l"
   ENDIF
   IF (mpbw=0)
    col 65, "0"
   ELSE
    col 65, mpbw";l"
   ENDIF
   IF (mpwt=0)
    col 80, "0"
   ELSE
    col 80, mpwt";l"
   ENDIF
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
