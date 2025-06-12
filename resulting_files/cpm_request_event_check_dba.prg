CREATE PROGRAM cpm_request_event_check:dba
 RECORD reply(
   1 list[*]
     2 request_number = i4
     2 event_type = i4
     2 event_data = vc
 )
 DECLARE reqcnt = i4
 SET reqcnt = 0
 SELECT INTO "nl:"
  FROM request_event re
  WHERE re.event_dt_tm > cnvtdatetime(reqevent->last_queried_dt_tm)
  ORDER BY re.request_number
  DETAIL
   reqcnt = (reqcnt+ 1), stat = alterlist(reply->list,reqcnt), reply->list[reqcnt].request_number =
   re.request_number,
   reply->list[reqcnt].event_type = re.event_type, reply->list[reqcnt].event_data = re.event_data,
   CALL echo(build("event_type:",re.event_type," ",re.event_data))
  WITH nocounter
 ;end select
 SET reqevent->last_queried_dt_tm = cnvtdatetime(curdate,curtime3)
 CALL echo(build("requests found in request_event table:",reqcnt))
 CALL echo(build("Last Queried at:",concat(format(reqevent->last_queried_dt_tm,"mm/dd/yy;;d"),format(
     reqevent->last_queried_dt_tm,"hh:mm;;m"))))
 DECLARE diff = i4
 SET diff = datetimediff(reqevent->last_queried_dt_tm,reqevent->last_purged_dt_tm,1)
 CALL echo(build("Number of days since the last purge was done: ",diff))
 IF (diff > 0)
  DELETE  FROM request_event re
   WHERE re.event_dt_tm < cnvtdatetime(curdate,0)
  ;end delete
  COMMIT
  SET reqevent->last_purged_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(build("delete performed"))
 ENDIF
END GO
