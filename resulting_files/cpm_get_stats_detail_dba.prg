CREATE PROGRAM cpm_get_stats_detail:dba
 DECLARE node_name = c16
 DECLARE output = c32
 DECLARE data_idx = i4
 DECLARE x = i4
 SET node_name = fillstring(16," ")
 SET x = 0
 CALL uar_get_nodename(node_name,x)
 SET output = concat("cached_",trim(node_name),"_",format(curdate,"mmmdd;;d"),".csv")
 CALL echo(output)
 SET data_idx = value(size(request->requestdata,5))
 CALL echo(build("size of request list:",data_idx))
 CALL echo(build("Check for valid request numbers:",request->requestdata[1].request_number))
 SELECT INTO value(output)
  FROM (dummyt d  WITH seq = value(data_idx))
  HEAD REPORT
   col 0, "request_num,", "script,",
   "cache_hits_grace,", "cache_hits_stale,", "cache_misses,",
   "script_execute_cnt,", "average_size,", "crc_key",
   row + 3
  DETAIL
   dline = concat(trim(cnvtstring(request->requestdata[d.seq].request_number)),",",trim(request->
     requestdata[d.seq].script_name),",",trim(cnvtstring(request->requestdata[d.seq].cache_hits_grace
      )),
    ",",trim(cnvtstring(request->requestdata[d.seq].cache_hits_stale)),",",trim(cnvtstring(request->
      requestdata[d.seq].cache_misses)),",",
    trim(cnvtstring(request->requestdata[d.seq].refreshcnt)),",",trim(cnvtstring(request->
      requestdata[d.seq].average_size)),",",trim(cnvtstring(request->requestdata[d.seq].crc_key))),
   col 0, dline,
   row + 1
  WITH nocounter, maxrow = 1, noformat,
   noformfeed
 ;end select
END GO
