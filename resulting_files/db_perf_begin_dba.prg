CREATE PROGRAM db_perf_begin:dba
 SET message = noinformation
 SET trace = nocost
 SET parser_buffer[100] = fillstring(80," ")
 SELECT INTO "nl:"
  y = seq(report_sequence,nextval)
  FROM dual
  DETAIL
   rs = y
  WITH nocounter
 ;end select
 SET parser_buffer[1] = " insert into perf_begin_stats s"
 SET parser_buffer[2] = "(s.report_seq, "
 SET parser_buffer[3] = "s.statistic#,"
 SET parser_buffer[4] = "s.name,"
 SET parser_buffer[5] = "s.class,"
 SET parser_buffer[6] = "s.stat_value) "
 SET parser_buffer[7] = "(select "
 SET parser_buffer[8] = "report_sequence.currval,"
 SET parser_buffer[9] = "v.statistic#,"
 SET parser_buffer[10] = "v.name,"
 SET parser_buffer[11] = "v.class,"
 SET parser_buffer[12] = "v.value"
 SET parser_buffer[13] = concat("from v$sysstat@",dblink," v")
 SET parser_buffer[14] = " ) go"
 FOR (cnt = 1 TO 14)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_begin_latch s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.latch#,"
 SET parser_buffer[4] = "s.level#,"
 SET parser_buffer[5] = "s.name,"
 SET parser_buffer[6] = "s.gets_value,"
 SET parser_buffer[7] = "s.misses_value,"
 SET parser_buffer[8] = "s.sleeps_value,"
 SET parser_buffer[9] = "s.immediate_gets_value,"
 SET parser_buffer[10] = "s.immediate_misses_value,"
 SET parser_buffer[11] = "s.waiters_woken_value,"
 SET parser_buffer[12] = "s.waits_holding_latch_value,"
 SET parser_buffer[13] = "s.spin_gets_value,"
 SET parser_buffer[14] = "s.sleep1,"
 SET parser_buffer[15] = "s.sleep2,"
 SET parser_buffer[16] = "s.sleep3,"
 SET parser_buffer[17] = "s.sleep4,"
 SET parser_buffer[18] = "s.sleep5,"
 SET parser_buffer[19] = "s.sleep6,"
 SET parser_buffer[20] = "s.sleep7,"
 SET parser_buffer[21] = "s.sleep8,"
 SET parser_buffer[22] = "s.sleep9,"
 SET parser_buffer[23] = "s.sleep10,"
 SET parser_buffer[24] = "s.sleep11) "
 SET parser_buffer[25] = "(select "
 SET parser_buffer[26] = "report_sequence.currval,"
 SET parser_buffer[27] = "v.latch#,"
 SET parser_buffer[28] = "v.level#,"
 SET parser_buffer[29] = "v.name,"
 SET parser_buffer[30] = "v.gets ,"
 SET parser_buffer[31] = "v.misses,"
 SET parser_buffer[32] = "v.sleeps,"
 SET parser_buffer[33] = "v.immediate_gets, "
 SET parser_buffer[34] = "v.immediate_misses,"
 SET parser_buffer[35] = "v.waiters_woken,"
 SET parser_buffer[36] = "v.waits_holding_latch,"
 SET parser_buffer[37] = "v.spin_gets,"
 SET parser_buffer[38] = "v.sleep1,"
 SET parser_buffer[39] = "v.sleep2,"
 SET parser_buffer[40] = "v.sleep3,"
 SET parser_buffer[41] = "v.sleep4,"
 SET parser_buffer[42] = "v.sleep5,"
 SET parser_buffer[43] = "v.sleep6,"
 SET parser_buffer[44] = "v.sleep7,"
 SET parser_buffer[45] = "v.sleep8,"
 SET parser_buffer[46] = "v.sleep9,"
 SET parser_buffer[47] = "v.sleep10,"
 SET parser_buffer[48] = "v.sleep11"
 SET parser_buffer[49] = concat("from v$latch@",dblink,"  v)")
 SET parser_buffer[50] = "go"
 FOR (cnt = 1 TO 50)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_begin_roll s"
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
 SET parser_buffer[19] = "report_sequence.currval,"
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
 SET parser_buffer[35] = concat("from v$rollstat@",dblink,"  v)")
 SET parser_buffer[36] = "go"
 FOR (cnt = 1 TO 36)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_begin_lib s"
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
 SET parser_buffer[12] = "report_sequence.currval,"
 SET parser_buffer[13] = "v.namespace,"
 SET parser_buffer[14] = "v.gets,"
 SET parser_buffer[15] = "v.gethits,"
 SET parser_buffer[16] = "v.pins,"
 SET parser_buffer[17] = "v.pinhits,"
 SET parser_buffer[18] = "v.pinhitratio,"
 SET parser_buffer[19] = "v.reloads,"
 SET parser_buffer[20] = "v.invalidations"
 SET parser_buffer[21] = concat("from v$librarycache@",dblink," v)")
 SET parser_buffer[22] = "go"
 FOR (cnt = 1 TO 22)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "  insert into perf_begin_dc s"
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
 SET parser_buffer[14] = "s.scancompletes_value,"
 SET parser_buffer[15] = "s.modifications_value,"
 SET parser_buffer[16] = "s.flushes_value)"
 SET parser_buffer[17] = "(select "
 SET parser_buffer[18] = "report_sequence.currval,"
 SET parser_buffer[19] = "cache#,"
 SET parser_buffer[20] = "nullcheck(subordinate#,-1,nullind(subordinate#)),"
 SET parser_buffer[21] = "type,"
 SET parser_buffer[22] = "parameter,"
 SET parser_buffer[23] = "count,"
 SET parser_buffer[24] = "usage,"
 SET parser_buffer[25] = "fixed,"
 SET parser_buffer[26] = "gets,"
 SET parser_buffer[27] = "getmisses,"
 SET parser_buffer[28] = "scans,"
 SET parser_buffer[29] = "scanmisses,"
 SET parser_buffer[30] = " scancompletes,"
 SET parser_buffer[31] = "modifications,"
 SET parser_buffer[32] = "flushes"
 SET parser_buffer[33] = concat("from v$rowcache@",dblink," )")
 SET parser_buffer[34] = "go"
 FOR (cnt = 1 TO 34)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_begin_event s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.event,"
 SET parser_buffer[4] = "s.total_waits_value,"
 SET parser_buffer[5] = "s.total_timeouts_value,"
 SET parser_buffer[6] = "s.time_waited_value,"
 SET parser_buffer[7] = "s.average_wait_value)"
 SET parser_buffer[8] = "(select "
 SET parser_buffer[9] = "report_sequence.currval,"
 SET parser_buffer[10] = "v.event,"
 SET parser_buffer[11] = "v.total_waits,"
 SET parser_buffer[12] = "v.total_timeouts,"
 SET parser_buffer[13] = "v.time_waited,"
 SET parser_buffer[14] = "v.average_wait"
 SET parser_buffer[15] = concat("from v$system_event@",dblink,"  v)")
 SET parser_buffer[16] = "go"
 FOR (cnt = 1 TO 16)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
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
 INSERT  FROM perf_begin_bckevent s,
   temp e
  SET s.report_seq = rs, s.event = e.event, s.total_waits_value = e.total_waits,
   s.time_waited_value = e.time_waited
  PLAN (e)
   JOIN (s)
  WITH nocounter
 ;end insert
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = " insert into perf_begin_waitstat s"
 SET parser_buffer[2] = "(s.report_seq,"
 SET parser_buffer[3] = "s.class,"
 SET parser_buffer[4] = "s.count,"
 SET parser_buffer[5] = "s.time )"
 SET parser_buffer[6] = "(select "
 SET parser_buffer[7] = "report_sequence.currval,"
 SET parser_buffer[8] = "v.class,"
 SET parser_buffer[9] = "v.count,"
 SET parser_buffer[10] = "v.time"
 SET parser_buffer[11] = concat("from v$waitstat@",dblink,"  v)")
 SET parser_buffer[12] = "go"
 FOR (cnt = 1 TO 12)
   CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[100] = fillstring(80," ")
 SET parser_buffer[1] = "rdb insert into perf_begin_file "
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
 SET parser_buffer[12] = "report_sequence.currval,"
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
 COMMIT
END GO
