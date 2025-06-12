CREATE PROGRAM cpm_get_stats_summary:dba
 DECLARE node_name = c16
 DECLARE output = c32
 DECLARE data_idx = i4
 DECLARE x = i4
 DECLARE tcache_stale = i4
 DECLARE tcache_grace = i4
 DECLARE tscript_exec = i4
 DECLARE tentries = i4
 SET data_idx = value(size(request->requestdata,5))
 SET node_name = fillstring(16," ")
 SET x = 0
 CALL uar_get_nodename(node_name,x)
 SET output = concat("caches_",trim(node_name),"_",format(curdate,"mmmdd;;d"),".csv")
 CALL echo(output)
 SELECT INTO value(output)
  request_nbr = request->requestdata[d.seq].request_number, avg_size = request->requestdata[d.seq].
  average_size, refresh_cnt = request->requestdata[d.seq].refreshcnt
  FROM (dummyt d  WITH seq = value(data_idx))
  ORDER BY request_nbr
  HEAD REPORT
   col 0, "request_num,", "script,",
   "cache_hits_grace,", "cache_hits_stale,", "cache_misses,",
   "script_execute_cnt,", "average_size,", "nbr_of_entries,",
   "max_size,", "min_size", row + 1
  HEAD request_nbr
   new_req = 0
  DETAIL
   new_req = (new_req+ 1)
  FOOT  request_nbr
   size_sum = sum(avg_size), average_size = (size_sum/ new_req), max_avg = max(avg_size),
   min_avg = min(avg_size), refresh_sum = sum(refresh_cnt), cache_stale = sum(request->requestdata[d
    .seq].cache_hits_stale),
   cache_grace = sum(request->requestdata[d.seq].cache_hits_grace), cache_misses = sum(request->
    requestdata[d.seq].cache_misses), cache_hits = (cache_stale+ cache_grace),
   dline = concat(trim(cnvtstring(request->requestdata[d.seq].request_number)),",",trim(request->
     requestdata[d.seq].script_name),",",trim(cnvtstring(cache_grace)),
    ",",trim(cnvtstring(cache_stale)),",",trim(cnvtstring(cache_misses)),",",
    trim(cnvtstring(refresh_sum)),",",trim(cnvtstring(average_size)),",",trim(cnvtstring(new_req)),
    ",",trim(cnvtstring(max_avg)),",",trim(cnvtstring(min_avg))), col 0, dline,
   row + 1, tcache_stale = (tcache_stale+ cache_stale), tcache_grace = (tcache_grace+ cache_grace),
   tscript_exec = (tscript_exec+ refresh_sum), tentries = (tentries+ new_req)
  WITH nocounter, maxrow = 1, noformat,
   noformfeed, maxcol = 200
 ;end select
 SET output = concat("cachet_",trim(node_name),"_",format(curdate,"mmmdd;;d"),".csv")
 SELECT INTO value(output)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   col 0, "total_hits,cache_grace_hits,cache_stale_hits,script_executes,cache_entries", row + 1,
   cache = (tcache_stale+ tcache_grace), col 0, cache,
   ",", tcache_grace, ",",
   tcache_stale, ",", tscript_exec,
   ",", tentries, row + 1
  WITH nocounter, maxrow = 3, noformat,
   noformfeed
 ;end select
END GO
