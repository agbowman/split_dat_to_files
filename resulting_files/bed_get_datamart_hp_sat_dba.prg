CREATE PROGRAM bed_get_datamart_hp_sat:dba
 FREE SET reply
 RECORD reply(
   1 schedules[*]
     2 schedule_id = f8
     2 display = vc
     2 meaning = vc
     2 series[*]
       3 series_id = f8
       3 display = vc
       3 meaning = vc
       3 expectations[*]
         4 expectation_id = f8
         4 display = vc
         4 meaning = vc
         4 satisfiers[*]
           5 satisfier_id = f8
           5 display = vc
           5 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM hm_expect_sched h,
   hm_expect_series s,
   hm_expect e,
   hm_expect_sat es
  PLAN (h
   WHERE h.active_ind=1
    AND h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND h.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (s
   WHERE s.expect_sched_id=h.expect_sched_id
    AND s.active_ind=1
    AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE e.expect_series_id=s.expect_series_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (es
   WHERE es.expect_id=e.expect_id
    AND es.parent_type_flag=2
    AND es.active_ind=1
    AND es.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND es.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY h.expect_sched_id, s.expect_series_id, e.expect_id,
   es.expect_sat_id
  HEAD REPORT
   scnt = 0, stcnt = 0, stat = alterlist(reply->schedules,100)
  HEAD h.expect_sched_id
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 100)
    stat = alterlist(reply->schedules,(stcnt+ 100)), scnt = 1
   ENDIF
   reply->schedules[stcnt].schedule_id = h.expect_sched_id, reply->schedules[stcnt].display = h
   .expect_sched_name, reply->schedules[stcnt].meaning = h.expect_sched_meaning,
   sscnt = 0, sstcnt = 0, stat = alterlist(reply->schedules[stcnt].series,10)
  HEAD s.expect_series_id
   sscnt = (sscnt+ 1), sstcnt = (sstcnt+ 1)
   IF (sscnt > 10)
    stat = alterlist(reply->schedules[stcnt].series,(sstcnt+ 10)), sscnt = 1
   ENDIF
   reply->schedules[stcnt].series[sstcnt].series_id = s.expect_series_id, reply->schedules[stcnt].
   series[sstcnt].display = s.expect_series_name, reply->schedules[stcnt].series[sstcnt].meaning = s
   .series_meaning,
   ecnt = 0, etcnt = 0, stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations,10)
  HEAD e.expect_id
   ecnt = (ecnt+ 1), etcnt = (etcnt+ 1)
   IF (ecnt > 10)
    stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations,(etcnt+ 10)), ecnt = 1
   ENDIF
   reply->schedules[stcnt].series[sstcnt].expectations[etcnt].expectation_id = e.expect_id, reply->
   schedules[stcnt].series[sstcnt].expectations[etcnt].display = e.expect_name, reply->schedules[
   stcnt].series[sstcnt].expectations[etcnt].meaning = e.expect_meaning,
   sacnt = 0, satcnt = 0, stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations[etcnt]
    .satisfiers,10)
  HEAD es.expect_sat_id
   sacnt = (sacnt+ 1), satcnt = (satcnt+ 1)
   IF (sacnt > 10)
    stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations[etcnt].satisfiers,(satcnt+
     10)), sacnt = 1
   ENDIF
   reply->schedules[stcnt].series[sstcnt].expectations[etcnt].satisfiers[satcnt].satisfier_id = es
   .expect_sat_id, reply->schedules[stcnt].series[sstcnt].expectations[etcnt].satisfiers[satcnt].
   display = es.expect_sat_name, reply->schedules[stcnt].series[sstcnt].expectations[etcnt].
   satisfiers[satcnt].meaning = es.satisfier_meaning
  FOOT  e.expect_id
   stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations[etcnt].satisfiers,satcnt)
  FOOT  s.expect_series_id
   stat = alterlist(reply->schedules[stcnt].series[sstcnt].expectations,etcnt)
  FOOT  h.expect_sched_id
   stat = alterlist(reply->schedules[stcnt].series,sstcnt)
  FOOT REPORT
   stat = alterlist(reply->schedules,stcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
