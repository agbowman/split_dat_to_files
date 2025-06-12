CREATE PROGRAM db_perf_end:dba
 SET message = noinformation
 SET trace = nocost
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "insert into perf_end_stats s"
 SET parser_buffer[2] = "(s.report_seq, "
 SET parser_buffer[3] = "s.statistic#,"
 SET parser_buffer[4] = "s.name,"
 SET parser_buffer[5] = "s.class,"
 SET parser_buffer[6] = "s.stat_value) "
 SET parser_buffer[7] = "( select  "
 SET parser_buffer[8] = "  rs,"
 SET parser_buffer[9] = "v.statistic#,"
 SET parser_buffer[10] = "v.name,"
 SET parser_buffer[11] = "v.class,"
 SET parser_buffer[12] = "v.value"
 SET parser_buffer[13] = concat(" from v$sysstat@",dblink," v) ")
 SET parser_buffer[14] = "go"
 FOR (cnt = 1 TO 14)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "insert into perf_end_roll s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.usn,"
 SET parser_buffer[4] = "s.extents,"
 SET parser_buffer[5] = "s.rssize_value,"
 SET parser_buffer[6] = "s.writes_value,"
 SET parser_buffer[7] = "s.xacts,"
 SET parser_buffer[8] = "s.gets_value,"
 SET parser_buffer[9] = "s.waits,"
 SET parser_buffer[10] = "s.optsize_value,"
 SET parser_buffer[11] = "s.hwmsize_value,"
 SET parser_buffer[12] = "s.shrinks,"
 SET parser_buffer[13] = "s.wraps,"
 SET parser_buffer[14] = "s.extends,"
 SET parser_buffer[15] = "s.aveshrink_value,"
 SET parser_buffer[16] = "s.aveactive_value,"
 SET parser_buffer[17] = "s.status)"
 SET parser_buffer[18] = "(select "
 SET parser_buffer[19] = " rs, "
 SET parser_buffer[20] = "v.usn,"
 SET parser_buffer[21] = "v.extents,"
 SET parser_buffer[22] = "v.rssize,"
 SET parser_buffer[23] = "v.writes,"
 SET parser_buffer[24] = "v.xacts,"
 SET parser_buffer[25] = "v.gets,"
 SET parser_buffer[26] = "v.waits,"
 SET parser_buffer[27] = "v.optsize,"
 SET parser_buffer[28] = "v.hwmsize,"
 SET parser_buffer[29] = "v.shrinks,"
 SET parser_buffer[30] = "v.wraps,"
 SET parser_buffer[31] = "v.extends,"
 SET parser_buffer[32] = "v.aveshrink,"
 SET parser_buffer[33] = "v.aveactive,"
 SET parser_buffer[34] = "v.status"
 SET parser_buffer[35] = concat("from v$rollstat@",dblink," v )")
 SET parser_buffer[36] = "go"
 FOR (cnt = 1 TO 36)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("end_roll")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_end_lib s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.namespace,"
 SET parser_buffer[4] = "s.gets_value,"
 SET parser_buffer[5] = "s.gethits_value,"
 SET parser_buffer[6] = "s.pins_value,"
 SET parser_buffer[7] = "s.pinhits_value,"
 SET parser_buffer[8] = "s.pinhitratio,"
 SET parser_buffer[9] = "s.reloads_value,"
 SET parser_buffer[10] = "s.invalidations)"
 SET parser_buffer[11] = "(select "
 SET parser_buffer[12] = " rs, "
 SET parser_buffer[13] = "v.namespace,"
 SET parser_buffer[14] = " v.gets,"
 SET parser_buffer[15] = "v.gethits,"
 SET parser_buffer[16] = "v.pins,"
 SET parser_buffer[17] = "v.pinhits,"
 SET parser_buffer[18] = "v.pinhitratio,"
 SET parser_buffer[19] = "v.reloads,"
 SET parser_buffer[20] = "v.invalidations"
 SET parser_buffer[21] = concat("from v$librarycache@",dblink,"  v)")
 SET parser_buffer[22] = "go"
 FOR (cnt = 1 TO 22)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("end_lib")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_end_dc s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.cache#,"
 SET parser_buffer[4] = "s.subordinate#,"
 SET parser_buffer[5] = "s.type,"
 SET parser_buffer[6] = "s.parameter,"
 SET parser_buffer[7] = "s.count_value,"
 SET parser_buffer[8] = "s.usage_value,"
 SET parser_buffer[9] = "s.fixed_value,"
 SET parser_buffer[10] = "s.gets_value,"
 SET parser_buffer[11] = "s.getmisses_value,"
 SET parser_buffer[12] = "s.scans_value,"
 SET parser_buffer[13] = "s.scanmisses_value,"
 SET parser_buffer[14] = "s.modifications_value,"
 SET parser_buffer[15] = "s.flushes_value)"
 SET parser_buffer[16] = "(select "
 SET parser_buffer[17] = " rs, "
 SET parser_buffer[18] = "v.cache#,"
 SET parser_buffer[19] = "nullcheck(v.subordinate#,-1,nullind(v.subordinate#)),"
 SET parser_buffer[20] = "v.type,"
 SET parser_buffer[21] = "v.parameter,"
 SET parser_buffer[22] = "v.count,"
 SET parser_buffer[23] = "v.usage,"
 SET parser_buffer[24] = "v.fixed,"
 SET parser_buffer[25] = "v.gets,"
 SET parser_buffer[26] = "v.getmisses,"
 SET parser_buffer[27] = "v.scans,"
 SET parser_buffer[28] = "v.scanmisses,"
 SET parser_buffer[29] = "v.modifications,"
 SET parser_buffer[30] = "v.flushes"
 SET parser_buffer[31] = concat("from v$rowcache@",dblink,"  v)")
 SET parser_buffer[32] = "go"
 FOR (cnt = 1 TO 32)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_end_event s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.event,"
 SET parser_buffer[4] = "s.total_waits_value,"
 SET parser_buffer[5] = "s.total_timeouts_value,"
 SET parser_buffer[6] = "s.time_waited_value,"
 SET parser_buffer[7] = "s.average_wait_value)"
 SET parser_buffer[8] = "(select "
 SET parser_buffer[9] = " rs ,"
 SET parser_buffer[10] = "v.event,"
 SET parser_buffer[11] = "v.total_waits,"
 SET parser_buffer[12] = "v.total_timeouts,"
 SET parser_buffer[13] = "v.time_waited,"
 SET parser_buffer[14] = "v.average_wait"
 SET parser_buffer[15] = concat("from v$system_event@",dblink," v )")
 SET parser_buffer[16] = "go"
 FOR (cnt = 1 TO 16)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_end_waitstat s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.class,"
 SET parser_buffer[4] = "s.count,"
 SET parser_buffer[5] = "s.time )"
 SET parser_buffer[6] = "(select "
 SET parser_buffer[7] = "rs,"
 SET parser_buffer[8] = "v.class,"
 SET parser_buffer[9] = "v.count,"
 SET parser_buffer[10] = "v.time"
 SET parser_buffer[11] = concat("from v$waitstat@",dblink,"  v)")
 SET parser_buffer[12] = "go"
 FOR (cnt = 1 TO 12)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "rdb insert into perf_end_file "
 SET parser_buffer[2] = "(report_seq, "
 SET parser_buffer[3] = "ts,"
 SET parser_buffer[4] = "name,"
 SET parser_buffer[5] = "pyr_value,"
 SET parser_buffer[6] = "pyw_value,"
 SET parser_buffer[7] = "prt_value,"
 SET parser_buffer[8] = "pwt_value,"
 SET parser_buffer[9] = "pbr_value, "
 SET parser_buffer[10] = "pbw_value) "
 SET parser_buffer[11] = "(select "
 SET parser_buffer[12] = concat(cnvtstring(rs),", ")
 SET parser_buffer[13] = "ts.name,"
 SET parser_buffer[14] = "i.name,"
 SET parser_buffer[15] = "x.phyrds,"
 SET parser_buffer[16] = "x.phywrts,"
 SET parser_buffer[17] = "x.readtim,"
 SET parser_buffer[18] = "x.writetim,"
 SET parser_buffer[19] = "x.phyblkrd,"
 SET parser_buffer[20] = "x.phyblkwrt"
 SET parser_buffer[21] = concat("from v$filestat@",dblink," x,")
 SET parser_buffer[22] = concat("v$datafile@",dblink," i,")
 SET parser_buffer[23] = concat("sys.ts$@",dblink," ts,")
 SET parser_buffer[24] = concat("sys.file$@",dblink," f ")
 SET parser_buffer[25] = "where i.file# = f.file# and ts.ts# = f.ts#"
 SET parser_buffer[26] = "and x.file# = f.file#) go"
 FOR (cnt = 1 TO 26)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("end_file")
 SET select_stat = fillstring(400," ")
 SET select_stat = "select into table temp e.event,"
 SET select_stat = build(select_stat,"total_waits = sum(e.total_waits),")
 SET select_stat = build(select_stat,"time_waited = sum(e.time_waited) from v$session@")
 SET select_stat = build(select_stat,dblink)
 SET select_stat = build(select_stat," v,v$session_event@")
 SET select_stat = build(select_stat,dblink)
 SET select_stat = build(select_stat," e")
 SET select_stat = build(select_stat,
  " where v.type = 'BACKGROUND' and e.sid = v.sid group by e.event go ")
 CALL parser(select_stat)
 INSERT  FROM perf_end_bckevent s,
   temp e
  SET s.report_seq = rs, s.event = e.event, s.total_waits_value = e.total_waits,
   s.time_waited_value = e.time_waited
  PLAN (e)
   JOIN (s)
  WITH nocounter
 ;end insert
 SET parser_buffer[100] = fillstring(80," ")
 CALL echo("stats")
 SET parser_buffer[1] = "insert into perf_stats s"
 SET parser_buffer[2] = "(s.report_seq, "
 SET parser_buffer[3] = "s.statistic#,"
 SET parser_buffer[4] = "s.name,"
 SET parser_buffer[5] = "s.change_value) "
 SET parser_buffer[6] = "( select  "
 SET parser_buffer[7] = "  rs,"
 SET parser_buffer[8] = "n.statistic#,"
 SET parser_buffer[9] = "n.name,"
 SET parser_buffer[10] = "e.stat_value - b.stat_value"
 SET parser_buffer[11] = " from perf_begin_stats b, "
 SET parser_buffer[12] = " perf_end_stats e,"
 SET parser_buffer[13] = concat(" v$statname@",dblink," n ")
 SET parser_buffer[14] = "where n.statistic# = b.statistic#"
 SET parser_buffer[15] = "and n.statistic# = e.statistic# "
 SET parser_buffer[16] = "and b.report_seq = rs "
 SET parser_buffer[17] = "and e.report_seq = rs )"
 SET parser_buffer[18] = "go"
 FOR (cnt = 1 TO 18)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("stats")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_latches s"
 SET parser_buffer[2] = " (s.report_seq,"
 SET parser_buffer[3] = " s.latch#,"
 SET parser_buffer[4] = " s.name,"
 SET parser_buffer[5] = " s.gets_value,"
 SET parser_buffer[6] = " s.misses_value,"
 SET parser_buffer[7] = " s.sleeps_value,"
 SET parser_buffer[8] = " s.immediate_gets_value, "
 SET parser_buffer[9] = " s.immediate_misses_value ) "
 SET parser_buffer[10] = " (select "
 SET parser_buffer[11] = " e.report_seq, "
 SET parser_buffer[12] = " e.latch#, "
 SET parser_buffer[13] = " n.name,"
 SET parser_buffer[14] = " e.gets_value - b.gets_value ,"
 SET parser_buffer[15] = " e.misses_value - b.misses_value,"
 SET parser_buffer[16] = " e.sleeps_value - b.sleeps_value,"
 SET parser_buffer[17] = " e.immediate_gets_value - b.immediate_gets_value, "
 SET parser_buffer[18] = " e.immediate_misses_value - b.immediate_misses_value "
 SET parser_buffer[19] = concat(" from v$latchname@",dblink,"  n, ")
 SET parser_buffer[20] = " perf_begin_latch b, perf_end_latch e "
 SET parser_buffer[21] = " where n.latch# = b.latch# and "
 SET parser_buffer[22] = " n.latch# = e.latch# and e.report_seq = rs "
 SET parser_buffer[23] = "and  b.report_seq = rs) "
 SET parser_buffer[24] = " go"
 FOR (cnt = 1 TO 24)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("latches")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "insert into perf_roll s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.undo_segment,"
 SET parser_buffer[4] = "s.trans_tbl_gets_value,"
 SET parser_buffer[5] = "s.trans_tbl_waits,"
 SET parser_buffer[6] = "s.undo_bytes_written_value,"
 SET parser_buffer[7] = "s.segment_size_bytes_value,"
 SET parser_buffer[8] = "s.xacts,"
 SET parser_buffer[9] = "s.shrinks,"
 SET parser_buffer[10] = "s.wraps ) "
 SET parser_buffer[11] = "(select "
 SET parser_buffer[12] = "e.report_seq, "
 SET parser_buffer[13] = "e.usn,"
 SET parser_buffer[14] = "e.gets_value - b.gets_value,"
 SET parser_buffer[15] = "e.waits - b.waits, "
 SET parser_buffer[16] = "e.writes_value - b.writes_value,"
 SET parser_buffer[17] = "e.rssize_value,"
 SET parser_buffer[18] = "e.xacts - b.xacts,"
 SET parser_buffer[19] = "e.shrinks - b.shrinks,"
 SET parser_buffer[20] = "e.wraps - b.wraps "
 SET parser_buffer[21] = "from perf_begin_roll b, perf_end_roll e "
 SET parser_buffer[22] = "where e.report_seq = rs "
 SET parser_buffer[23] = "and b.report_seq = rs and "
 SET parser_buffer[24] = "e.usn = b.usn  ) "
 SET parser_buffer[25] = "go"
 FOR (cnt = 1 TO 25)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("roll")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_lib s"
 SET parser_buffer[2] = "(s.report_seq ,"
 SET parser_buffer[3] = "s.namespace, "
 SET parser_buffer[4] = "s.gets_value,"
 SET parser_buffer[5] = "s.gethits_value, "
 SET parser_buffer[6] = "s.pins_value, "
 SET parser_buffer[7] = "s.pinhits_value, "
 SET parser_buffer[8] = "s.reloads_value, "
 SET parser_buffer[9] = "s.invalidations )"
 SET parser_buffer[10] = "(select "
 SET parser_buffer[11] = " e.report_seq, "
 SET parser_buffer[12] = "e.namespace,"
 SET parser_buffer[13] = "e.gets_value - b.gets_value,"
 SET parser_buffer[14] = "e.gethits_value - b.gethits_value,"
 SET parser_buffer[15] = "e.pins_value - b.pins_value,"
 SET parser_buffer[16] = "e.pinhits_value - b.pinhits_value,"
 SET parser_buffer[17] = "e.reloads_value - b.reloads_value,"
 SET parser_buffer[18] = "e.invalidations - b.invalidations "
 SET parser_buffer[19] = " from perf_begin_lib b, perf_end_lib e "
 SET parser_buffer[20] = " where e.report_seq = rs and "
 SET parser_buffer[21] = " b.report_seq = rs and "
 SET parser_buffer[22] = " e.namespace =  b.namespace )"
 SET parser_buffer[23] = "go"
 FOR (cnt = 1 TO 23)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("lib")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "rdb insert into perf_dc "
 SET parser_buffer[2] = "(report_seq,"
 SET parser_buffer[3] = "cache#,"
 SET parser_buffer[4] = "subordinate#,"
 SET parser_buffer[5] = "name,"
 SET parser_buffer[6] = "get_reqs_value,"
 SET parser_buffer[7] = "get_miss_value,"
 SET parser_buffer[8] = "scan_reqs_value,"
 SET parser_buffer[9] = "scan_miss_value,"
 SET parser_buffer[10] = "mod_reqs_value,"
 SET parser_buffer[11] = "count_value,"
 SET parser_buffer[12] = "cur_usage_value)"
 SET parser_buffer[13] = "(select "
 SET parser_buffer[14] = "e.report_seq, "
 SET parser_buffer[15] = "e.cache#,"
 SET parser_buffer[16] = "e.subordinate#,"
 SET parser_buffer[17] = "e.parameter,"
 SET parser_buffer[18] = "e.gets_value - b.gets_value,"
 SET parser_buffer[19] = "e.getmisses_value - b.getmisses_value,"
 SET parser_buffer[20] = "e.scans_value - b.scans_value,"
 SET parser_buffer[21] = "e.scanmisses_value - b.scanmisses_value,"
 SET parser_buffer[22] = "e.modifications_value - b.modifications_value,"
 SET parser_buffer[23] = "e.count_value, "
 SET parser_buffer[24] = "e.usage_value "
 SET parser_buffer[25] = "from perf_begin_dc b, perf_end_dc e "
 SET parser_buffer[26] = " where b.cache# = e.cache# and "
 SET parser_buffer[27] = "nvl(b.subordinate#, -1 ) ="
 SET parser_buffer[28] = "nvl(e.subordinate#, -1) and "
 SET parser_buffer[29] = " b.report_seq = e.report_seq and  e.report_seq = "
 SET parser_buffer[30] = concat(cnvtstring(rs))
 SET parser_buffer[31] = ") go"
 FOR (cnt = 1 TO 31)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echo("dc")
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "insert into perf_files s"
 SET parser_buffer[2] = "(s.report_seq, "
 SET parser_buffer[3] = "s.table_space,"
 SET parser_buffer[4] = "s.file_name,"
 SET parser_buffer[5] = "s.phy_reads_value,"
 SET parser_buffer[6] = "s.phy_writes_value,"
 SET parser_buffer[7] = "s.phy_rd_time_value,"
 SET parser_buffer[8] = "s.phy_wrt_time_value,"
 SET parser_buffer[9] = "s.phy_blks_rd_value, "
 SET parser_buffer[10] = "s.phy_blks_wr_value) "
 SET parser_buffer[11] = "(select "
 SET parser_buffer[12] = "e.report_seq, "
 SET parser_buffer[13] = "b.ts,"
 SET parser_buffer[14] = "b.name,"
 SET parser_buffer[15] = "e.pyr_value - b.pyr_value,"
 SET parser_buffer[16] = "e.pyw_value - b.pyw_value,"
 SET parser_buffer[17] = "e.prt_value - b.prt_value,"
 SET parser_buffer[18] = "e.pwt_value - b.pwt_value,"
 SET parser_buffer[19] = "e.pbr_value - b.pbr_value,"
 SET parser_buffer[20] = "e.pbw_value - b.pbw_value"
 SET parser_buffer[21] = "from perf_begin_file b, perf_end_file e"
 SET parser_buffer[22] = " where e.report_seq = rs and "
 SET parser_buffer[23] = "  b.report_seq = rs and "
 SET parser_buffer[24] = " b.name = e.name ) go"
 FOR (cnt = 1 TO 24)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET fs = 0
 RECORD store(
   1 file_cnt = i4
   1 qual[*]
     2 mfile_name = vc
     2 mdisk_name = vc
 )
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_waitstat s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.class,"
 SET parser_buffer[4] = "s.count,"
 SET parser_buffer[5] = "s.time )"
 SET parser_buffer[6] = "(select "
 SET parser_buffer[7] = "e.report_seq,"
 SET parser_buffer[8] = "e.class,"
 SET parser_buffer[9] = "e.count - b.count,"
 SET parser_buffer[10] = "e.time - b.time "
 SET parser_buffer[11] = "from perf_begin_waitstat b,perf_end_waitstat e"
 SET parser_buffer[12] = " where b.report_seq = e.report_seq and "
 SET parser_buffer[13] = " b.class = e.class )"
 SET parser_buffer[14] = "go"
 FOR (cnt = 1 TO 14)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET store->file_cnt = 0
 SELECT INTO "nl:"
  FROM perf_files s
  WHERE s.report_seq=rs
  DETAIL
   store->file_cnt = (store->file_cnt+ 1), stat = alterlist(store->qual,store->file_cnt), fs =
   findstring(":",s.file_name,1),
   store->qual[store->file_cnt].mfile_name = s.file_name, store->qual[store->file_cnt].mdisk_name =
   substring(1,(fs - 1),s.file_name)
  WITH nocounter
 ;end select
 UPDATE  FROM perf_files s,
   (dummyt d  WITH seq = value(store->file_cnt))
  SET s.disk_name = store->qual[d.seq].mdisk_name
  PLAN (d)
   JOIN (s
   WHERE s.report_seq=rs
    AND (s.file_name=store->qual[d.seq].mfile_name))
  WITH nocounter
 ;end update
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_event s"
 SET parser_buffer[2] = "( s.report_seq,"
 SET parser_buffer[3] = " s.event,"
 SET parser_buffer[4] = " s.event_count_value,"
 SET parser_buffer[5] = " s.time_waited_value)"
 SET parser_buffer[6] = " (select "
 SET parser_buffer[7] = " e.report_seq,"
 SET parser_buffer[8] = " e.event,"
 SET parser_buffer[9] = " e.total_waits_value,"
 SET parser_buffer[10] = " e.time_waited_value "
 SET parser_buffer[11] = " from perf_events_view e "
 SET parser_buffer[12] = " where e.report_seq = rs) go "
 FOR (cnt = 1 TO 12)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_bckevent s"
 SET parser_buffer[2] = "( s.report_seq,"
 SET parser_buffer[3] = " s.event,"
 SET parser_buffer[4] = " s.event_count_value,"
 SET parser_buffer[5] = " s.time_waited_value)"
 SET parser_buffer[6] = " (select "
 SET parser_buffer[7] = " e.report_seq,"
 SET parser_buffer[8] = " e.event,"
 SET parser_buffer[9] = " e.total_waits_value,"
 SET parser_buffer[10] = " e.time_waited_value "
 SET parser_buffer[11] = " from perf_bckevents_view e "
 SET parser_buffer[12] = " where e.report_seq = rs) go "
 FOR (cnt = 1 TO 12)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_parameter s"
 SET parser_buffer[2] = "( s.report_seq,"
 SET parser_buffer[3] = " s.name,"
 SET parser_buffer[4] = " s.value )"
 SET parser_buffer[5] = " (select "
 SET parser_buffer[6] = " rs,"
 SET parser_buffer[7] = " v.name,"
 SET parser_buffer[8] = " v.value"
 SET parser_buffer[9] = concat(" from v$parameter@",dblink," v)")
 SET parser_buffer[10] = " go "
 FOR (cnt = 1 TO 10)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 UPDATE  FROM ref_report_log r
  SET r.end_date = cnvtdatetime(curdate,curtime3)
  WHERE r.report_seq=rs
   AND r.report_cd=3
  WITH nocounter
 ;end update
 DELETE  FROM perf_begin_stats
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_stats
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_latch
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_latch
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_lib
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_lib
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_roll
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_roll
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_dc
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_dc
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_event
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_event
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_file
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_file
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_waitstat
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_waitstat
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_begin_bckevent
  WHERE report_seq=rs
 ;end delete
 DELETE  FROM perf_end_bckevent
  WHERE report_seq=rs
 ;end delete
 COMMIT
 EXECUTE db_perf_generate_rpt rs
END GO
