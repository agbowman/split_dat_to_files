CREATE PROGRAM cpm_scriptcache_startup:dba
 RECORD reply(
   1 list[*]
     2 reqid = i4
     2 grace = i4
     2 stale = i4
     2 trimpolicy = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT INTO "nl:"
  r.request_number, r.cachegrace, r.cachestale,
  r.cachetrim
  FROM request r
  WHERE r.request_number > 0
   AND ((r.cachegrace > 0) OR (trim(r.cachetrim) > ""))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->list,cnt), reply->list[cnt].reqid = r.request_number,
   reply->list[cnt].grace = r.cachegrace, reply->list[cnt].stale = r.cachestale, reply->list[cnt].
   trimpolicy = trim(r.cachetrim)
  WITH nocounter
 ;end select
 CALL echo(build("requests found:",cnt))
 SET trace = recpersist
 RECORD reqevent(
   1 last_queried_dt_tm = dq8
   1 last_purged_dt_tm = dq8
 )
 SET trace = norecpersist
 SET reqevent->last_queried_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reqevent->last_purged_dt_tm = cnvtdatetime(curdate,curtime3)
 CALL echo(build("Last Queried and purged at:",concat(format(reqevent->last_queried_dt_tm,
     "mm/dd/yy;;d"),format(reqevent->last_queried_dt_tm,"hh:mm;;m"))))
END GO
