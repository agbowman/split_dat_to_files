CREATE PROGRAM dba_perf_trend_report
 PAINT
 RECORD request(
   1 base_seq = i4
   1 comp_seq = i4
   1 fname = c30
   1 wc1 = c200
   1 wc2 = c200
   1 tune_stats = c2
 )
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,10,"***  P E R F O R M A N C E   T R E N D    R E P O R T  ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(6,5,"Enter start sequence number : ")
 CALL text(8,5,"Enter end sequence number   : ")
 CALL text(11,5,"Exceptions (Y/N)   : ")
 CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
 SET help =
 SELECT
  l.report_seq";l", l.begin_date, r.instance_name
  FROM ref_instance_id r,
   ref_report_log l,
   ref_report_parms_log p
  WHERE p.report_seq=l.report_seq
   AND p.parm_value=cnvtstring(r.instance_cd)
   AND p.parm_cd=1
   AND l.end_date != null
   AND l.report_cd=3
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  l.report_seq
  FROM ref_report_log l
  WHERE l.end_date != null
   AND l.report_seq=cnvtint(curaccept)
   AND l.report_cd=3
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(6,50,"9999999999;cu")
 SET request->base_seq = cnvtint(curaccept)
 CALL accept(8,50,"9999999999;cu")
 SET request->comp_seq = cnvtint(curaccept)
 SET help = off
 SET validate = off
 CALL clear(23,1)
 CALL accept(11,50,"p;cu","N"
  WHERE curaccept IN ("Y", "N"))
 SET exep = curaccept
 SET request_tune_stats = "N"
 IF (exep="Y")
  CALL video(r)
  CALL clear(1,1)
  CALL box(1,1,18,80)
  CALL box(1,1,4,80)
  CALL clear(2,2,78)
  CALL text(2,10,"***  R E P O R T     P R I N T     O P T I O N S  ***")
  CALL clear(3,2,78)
  CALL video(n)
  CALL text(6,5,"Print only tunable statistics (Y/N) : ")
  CALL accept(6,50,"p;cu","Y"
   WHERE curaccept IN ("Y", "N"))
  SET request->tune_stats = curaccept
 ENDIF
 SET base_seq = request->base_seq
 SET comp_seq = request->comp_seq
 SET request->fname = "perf_trend"
 SET fname = request->fname
 SET line = fillstring(130,"-")
 SET zero = 0
 SET u_notes1 = fillstring(200," ")
 SET u_notes2 = fillstring(200," ")
 SET r1_date = cnvtdatetime(curdate,curtime3)
 SET r2_date = cnvtdatetime(curdate,curtime3)
 SET r1_enddate = cnvtdatetime(curdate,curtime3)
 SET r2_enddate = cnvtdatetime(curdate,curtime3)
 SET inst_name1 = fillstring(30," ")
 SET inst_name2 = fillstring(30," ")
 SELECT INTO "nl:"
  FROM ref_report_log l,
   ref_report_parms_log p,
   ref_instance_id i
  PLAN (l
   WHERE l.report_seq IN (base_seq, comp_seq)
    AND l.report_cd=3)
   JOIN (p
   WHERE l.report_seq=p.report_seq
    AND p.parm_cd=1)
   JOIN (i
   WHERE p.parm_value=cnvtstring(i.instance_cd))
  DETAIL
   IF (l.report_seq=base_seq)
    r1_date = l.begin_date, r1_enddate = l.end_date, u_notes1 = l.user_notes,
    inst_name1 = i.instance_name
   ENDIF
   IF (l.report_seq=comp_seq)
    r2_date = l.begin_date, r2_enddate = l.end_date, u_notes2 = l.user_notes,
    inst_name2 = i.instance_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO trim(fname)
  d.seq
  FROM (dummyt d  WITH seq = value(1))
  HEAD REPORT
   row + 1, col 0, "Trend Report Generated : Date Time - ",
   curdate"dd-mmm-yyyy;;d", row + 2, col 24,
   "Requested By - ", curuser, row + 3,
   col 0, "Start Point : ", row + 2,
   col 24, "Date          : ", r1_date"dd-mmm-yyyy;;d",
   row + 2, col 24, "Instance Name : ",
   inst_name1, row + 1, col 24,
   "Start Time    : ", r1_date"hh:mm:ss;;s", row + 1,
   col 24, "End Time      : ", r1_enddate"hh:mm:ss;;s",
   u1 = substring(1,80,u_notes1), u2 = substring(81,80,u_notes1), row + 2,
   col 24, "User Notes    : ", u1,
   row + 2, col 38, u2,
   row + 2, col 0, "End  Point   : ",
   row + 2, col 24, "Date          : ",
   r2_date"dd-mmm-yyyy;;d", row + 2, col 24,
   "Instance Name : ", inst_name2, row + 1,
   col 24, "Start Time    : ", r2_date"hh:mm:ss;;s",
   row + 1, col 24, "End Time      : ",
   r2_enddate"hh:mm:ss;;s", u1 = substring(1,80,u_notes2), u2 = substring(81,80,u_notes2),
   row + 2, col 24, "User Notes    : ",
   u1, row + 2, col 38,
   u2, BREAK
  WITH nocounter, maxrow = 1, noformfeed
 ;end select
 SELECT INTO trim(fname)
  d.seq
  FROM (dummyt d  WITH seq = value(1))
  HEAD REPORT
   dt = cnvtdatetime(curdate,curtime3), row + 1, row + 1,
   col 2, "Date : ", dt"dd-mmm-yy;3;d",
   row + 1, col 47, "PERFORMANCE  TREND  REPORT",
   row + 1, col 47, "**************************"
  WITH nocounter, noformfeed, maxrow = 1,
   append
 ;end select
 SET wc1 = fillstring(200," ")
 SET wc2 = fillstring(200," ")
 SET wc1 = build(" a.report_seq = ",base_seq)
 SET wc1 = concat(trim(wc1),build(" and b.report_seq(+) = ",comp_seq))
 SET wc2 = build(" where a.report_seq(+) = ",base_seq)
 SET wc2 = concat(trim(wc2),build(" and b.report_seq = ",comp_seq))
 SET request->wc1 = wc1
 SET request->wc2 = wc2
 EXECUTE dba_perf_trend_lib
 EXECUTE dba_perf_trend_stats
 EXECUTE dba_perf_trend_event
 EXECUTE dba_perf_trend_bckevent
 EXECUTE dba_perf_trend_file
 EXECUTE dba_perf_trend_ts
 EXECUTE dba_perf_trend_disk
 EXECUTE dba_perf_trend_latch
 EXECUTE dba_perf_trend_roll
 EXECUTE dba_perf_trend_parameter
 EXECUTE dba_perf_trend_dc
 EXECUTE dba_perf_trend_waitstat
 CALL text(23,1,"Report available in ccluserdir:")
 CALL text(23,32,request->fname)
END GO
