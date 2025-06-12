CREATE PROGRAM bed_get_report_history:dba
 FREE SET reply
 RECORD reply(
   1 history[*]
     2 br_report_history_id = f8
     2 run_dt_tm = dq8
     2 prsnl_id = f8
     2 username = vc
     2 status_flag = i2
     2 statistics[*]
       3 statistic_meaning = vc
       3 status_flag = i2
       3 qualifying_items = i4
       3 total_items = i4
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET hcnt = 0
 IF ((request->history_ind=0))
  SET max_cnt = 1
 ELSE
  SET max_cnt = 10
 ENDIF
 SELECT INTO "nl:"
  FROM br_report_history h
  PLAN (h
   WHERE (h.br_report_id=request->br_report_id))
  ORDER BY h.updt_dt_tm DESC
  HEAD h.br_report_history_id
   hcnt = (hcnt+ 1), stat = alterlist(reply->history,hcnt), reply->history[hcnt].br_report_history_id
    = h.br_report_history_id,
   reply->history[hcnt].run_dt_tm = h.run_dt_tm, reply->history[hcnt].prsnl_id = h.run_prsnl_id,
   reply->history[hcnt].status_flag = h.run_status_flag
  WITH nocounter, maxqual(h,value(max_cnt))
 ;end select
 IF (hcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(hcnt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=reply->history[d.seq].prsnl_id))
  ORDER BY d.seq
  HEAD d.seq
   reply->history[d.seq].username = p.username, reply->history[d.seq].name_full_formatted = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(hcnt)),
   br_report_statistics s
  PLAN (d)
   JOIN (s
   WHERE (s.br_report_history_id=reply->history[d.seq].br_report_history_id))
  ORDER BY d.seq
  HEAD d.seq
   scnt = 0
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->history[d.seq].statistics,scnt), reply->history[d.seq].
   statistics[scnt].statistic_meaning = s.statistic_meaning,
   reply->history[d.seq].statistics[scnt].status_flag = s.status_flag, reply->history[d.seq].
   statistics[scnt].qualifying_items = s.qualifying_items, reply->history[d.seq].statistics[scnt].
   total_items = s.total_items
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
