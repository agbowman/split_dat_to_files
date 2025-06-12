CREATE PROGRAM cpm_audit_load_atr:dba
 DECLARE appcnt = i4
 SET appcnt = 0
 SELECT INTO "nl:"
  a.application_number, a.description
  FROM application a
  WHERE a.application_number > 0
  DETAIL
   appcnt += 1, stat = alterlist(reply->applist,appcnt), reply->applist[appcnt].number = a
   .application_number,
   reply->applist[appcnt].desc = a.description
  WITH nocounter
 ;end select
 DECLARE taskcnt = i4
 SET taskcnt = 0
 SELECT INTO "nl:"
  t.task_number, t.description
  FROM application_task t
  WHERE t.task_number > 0
  DETAIL
   taskcnt += 1, stat = alterlist(reply->tasklist,taskcnt), reply->tasklist[taskcnt].number = t
   .task_number,
   reply->tasklist[taskcnt].desc = t.description
  WITH nocounter
 ;end select
 DECLARE reqcnt = i4
 SET reqcnt = 0
 SELECT INTO "nl:"
  r.request_number, r.description
  FROM request r
  WHERE r.request_number > 0
  DETAIL
   reqcnt += 1, stat = alterlist(reply->reqlist,reqcnt), reply->reqlist[reqcnt].number = r
   .request_number,
   reply->reqlist[reqcnt].desc = r.description
  WITH nocounter
 ;end select
 CALL echo(build("appCnt:",appcnt))
 CALL echo(build("taskCnt:",taskcnt))
 CALL echo(build("reqCnt:",reqcnt))
END GO
