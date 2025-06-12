CREATE PROGRAM dba_perf_trend_disk
 SET fname = request->fname
 SELECT INTO trim(fname)
  p.bdname, p.cdname, name =
  IF (p.bdname=" ") p.cdname
  ELSE p.bdname
  ENDIF
  FROM perf_temp p
  ORDER BY name
  HEAD REPORT
   line = fillstring(131,"-"), row + 1, row + 1,
   row + 1, col 0, "Rem : Disk I/O"
  HEAD PAGE
   row + 1, row + 1, col 1,
   "Disk_Name", col 40, "Phy_Reads",
   col 55, "Phy_Blks_Rd", col 70,
   "Phy_Rd_Time", col 85, "Phy_Writes",
   col 100, "Phy_Blks_Wr", col 115,
   "Phy_Wrt_Time", row + 1, col 0,
   line, row + 1
  HEAD name
   col 1, name, breads = 0,
   creads = 0, bwrites = 0, cwrites = 0,
   bpwt = 0, cpwt = 0, bpbw = 0,
   cpbw = 0, bprt = 0, cprt = 0,
   bpbr = 0, cpbr = 0
  DETAIL
   breads = (breads+ p.bpyr), creads = (creads+ p.cpyr), bwrites = (bwrites+ p.bpyw),
   cwrites = (cwrites+ p.cpyw), bprt = (bprt+ p.bprt), cprt = (cprt+ p.cprt),
   bpwt = (bpwt+ p.bpwt), cpwt = (cpwt+ p.cpwt), bpbr = (bpbr+ p.bpbr),
   cpbr = (cpbr+ p.cpbr), bpbw = (bpbw+ p.bpbw), cpwt = (cpbw+ p.cpbw)
  FOOT  name
   reads = (creads - breads), writes = (cwrites - bwrites), read_time = (cprt - bprt),
   write_time = (cpwt - bpwt), blk_reads = (cpbr - bpbr), blk_writes = (cpbw - bpbw),
   col 40, reads, col 55,
   blk_reads, col 70, read_time,
   col 85, writes, col 100,
   blk_writes, col 115, write_time,
   row + 1
  WITH size = 132, noformfeed, maxrow = 1,
   nocounter, append
 ;end select
END GO
