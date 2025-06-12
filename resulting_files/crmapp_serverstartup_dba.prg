CREATE PROGRAM crmapp_serverstartup:dba
 CALL echo(concat("CRMAPP_SERVERSTARTUP ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;M")))
 RECORD reply(
   1 applist[*]
     2 appnum = i4
     2 appname = vc
     2 objname = vc
     2 loglevel = i2
     2 reqloglevel = i2
     2 logaccessind = i2
     2 appiniind = i2
     2 cacheind = i2
     2 commonind = i2
   1 tasklist[*]
     2 tasknum = i4
     2 subtaskind = i2
   1 requestlist[*]
     2 requestnum = i4
     2 requestclass = i2
     2 expertind = i2
     2 cachetime = i2
     2 processclass = i4
     2 requestbinding = vc
   1 reqproclist[*]
     2 requestnum = i4
   1 apptasklist[*]
     2 appnum = i4
     2 tasklist[*]
       3 tasknum = i4
   1 taskrequestlist[*]
     2 tasknum = i4
     2 requestlist[*]
       3 requestnum = i4
   1 appgrouplist[*]
     2 appgroupcd = f8
     2 positionlist[*]
       3 positioncd = f8
   1 appaccesslist[*]
     2 appnum = i4
     2 appgrouplist[*]
       3 appgroupcd = f8
   1 taskaccesslist[*]
     2 tasknum = i4
     2 appgrouplist[*]
       3 appgroupcd = f8
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 IF ((request->loadmode=2))
  CALL echo("Check for new ATR data.")
  CALL echo(concat("Last refresh: ",format(request->lastupdt_dt_tm,"MMM DD, YYYY - HH:MM:SS;;D")))
  SELECT INTO "nl:"
   d.info_name, d.updt_dt_tm
   FROM dm_info d
   WHERE d.info_domain="ATR"
    AND d.updt_dt_tm >= cnvtdatetimeutc(request->lastupdt_dt_tm,2)
   DETAIL
    CALL echo(concat("dm_info date: ",format(cnvtdatetimeutc(d.updt_dt_tm,3),
      "MMM DD, YYYY - HH:MM:SS;;D")))
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("No new ATR data to refresh")
   SET reply->status_data.status = "Z"
   GO TO end_script
  ENDIF
 ENDIF
 DECLARE appcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  a.application_number, a.description, a.object_name,
  a.log_level, a.request_log_level, a.log_access_ind,
  a.application_ini_ind, a.disable_cache_ind, a.common_application_ind,
  a.active_ind
  FROM application a
  WHERE a.application_number > 0
   AND a.active_ind=1
  HEAD REPORT
   appcnt = 0
  DETAIL
   IF (mod(appcnt,100)=0)
    stat = alterlist(reply->applist,(appcnt+ 100))
   ENDIF
   appcnt += 1, reply->applist[appcnt].appnum = a.application_number, reply->applist[appcnt].appname
    = a.description,
   reply->applist[appcnt].objname = a.object_name, reply->applist[appcnt].loglevel = a.log_level,
   reply->applist[appcnt].reqloglevel = a.request_log_level,
   reply->applist[appcnt].logaccessind = a.log_access_ind, reply->applist[appcnt].appiniind = a
   .application_ini_ind, reply->applist[appcnt].cacheind = a.disable_cache_ind,
   reply->applist[appcnt].commonind = a.common_application_ind
  FOOT REPORT
   stat = alterlist(reply->applist,appcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Application:",appcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE taskcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  t.task_number, t.subordinate_task_ind, t.active_ind
  FROM application_task t
  WHERE t.task_number > 0
   AND t.active_ind=1
  HEAD REPORT
   taskcnt = 0
  DETAIL
   IF (mod(taskcnt,100)=0)
    stat = alterlist(reply->tasklist,(taskcnt+ 100))
   ENDIF
   taskcnt += 1, reply->tasklist[taskcnt].tasknum = t.task_number, reply->tasklist[taskcnt].
   subtaskind = t.subordinate_task_ind
  FOOT REPORT
   stat = alterlist(reply->tasklist,taskcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Application_task:",taskcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE reqcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  r.request_number, r.requestclass, r.cachetime,
  r.processclass, r.binding_override, r.active_ind
  FROM request r
  WHERE r.request_number > 0
   AND r.active_ind=1
  HEAD REPORT
   reqcnt = 0
  DETAIL
   IF (mod(reqcnt,100)=0)
    stat = alterlist(reply->requestlist,(reqcnt+ 100))
   ENDIF
   reqcnt += 1, reply->requestlist[reqcnt].requestnum = r.request_number, reply->requestlist[reqcnt].
   requestclass = r.requestclass,
   reply->requestlist[reqcnt].cachetime = r.cachetime, reply->requestlist[reqcnt].processclass = r
   .processclass, reply->requestlist[reqcnt].requestbinding = trim(r.binding_override)
  FOOT REPORT
   stat = alterlist(reply->requestlist,reqcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Request:",reqcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE reqproccnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  r.request_number, r.active_ind
  FROM request_processing r
  WHERE r.request_number > 0
   AND r.active_ind=1
  ORDER BY r.request_number
  HEAD REPORT
   reqproccnt = 0
  DETAIL
   IF (mod(reqproccnt,100)=0)
    stat = alterlist(reply->reqproclist,(reqproccnt+ 100))
   ENDIF
   reqproccnt += 1, reply->reqproclist[reqproccnt].requestnum = r.request_number
  FOOT REPORT
   stat = alterlist(reply->reqproclist,reqproccnt)
  WITH nocounter
 ;end select
 CALL echo(build("Request_processing:",reqproccnt))
 DECLARE apptaskcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  a.application_number, a.task_number
  FROM application_task_r a
  WHERE a.application_number > 0
  ORDER BY a.application_number
  HEAD REPORT
   apptaskcnt = 0
  HEAD a.application_number
   IF (mod(apptaskcnt,100)=0)
    stat = alterlist(reply->apptasklist,(apptaskcnt+ 100))
   ENDIF
   apptaskcnt += 1, reply->apptasklist[apptaskcnt].appnum = a.application_number, taskcnt = 0
  DETAIL
   IF (mod(taskcnt,100)=0)
    stat = alterlist(reply->apptasklist[apptaskcnt].tasklist,(taskcnt+ 100))
   ENDIF
   taskcnt += 1, reply->apptasklist[apptaskcnt].tasklist[taskcnt].tasknum = a.task_number
  FOOT  a.application_number
   stat = alterlist(reply->apptasklist[apptaskcnt].tasklist,taskcnt)
  FOOT REPORT
   stat = alterlist(reply->apptasklist,apptaskcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Application_task_r:",apptaskcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE taskreqcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  t.task_number, t.request_number
  FROM task_request_r t
  WHERE t.task_number > 0
  ORDER BY t.task_number
  HEAD REPORT
   taskreqcnt = 0
  HEAD t.task_number
   IF (mod(taskreqcnt,100)=0)
    stat = alterlist(reply->taskrequestlist,(taskreqcnt+ 100))
   ENDIF
   taskreqcnt += 1, reply->taskrequestlist[taskreqcnt].tasknum = t.task_number, reqcnt = 0
  DETAIL
   IF (mod(reqcnt,100)=0)
    stat = alterlist(reply->taskrequestlist[taskreqcnt].requestlist,(reqcnt+ 100))
   ENDIF
   reqcnt += 1, reply->taskrequestlist[taskreqcnt].requestlist[reqcnt].requestnum = t.request_number
  FOOT  t.task_number
   stat = alterlist(reply->taskrequestlist[taskreqcnt].requestlist,reqcnt)
  FOOT REPORT
   stat = alterlist(reply->taskrequestlist,taskreqcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Task_request_r:",taskreqcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE appgrpcnt = i4 WITH noconstant(0)
 DECLARE poscnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  a.app_group_cd, a.position_cd, c.code_value,
  c.begin_effective_dt_tm, c.end_effective_dt_tm, c.active_ind
  FROM application_group a,
   code_value c
  WHERE ((a.app_group_cd+ 0) > 0)
   AND c.code_value=a.app_group_cd
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
   AND c.active_ind=1
  ORDER BY a.app_group_cd
  HEAD REPORT
   appgrpcnt = 0
  HEAD a.app_group_cd
   IF (mod(appgrpcnt,100)=0)
    stat = alterlist(reply->appgrouplist,(appgrpcnt+ 100))
   ENDIF
   appgrpcnt += 1, reply->appgrouplist[appgrpcnt].appgroupcd = a.app_group_cd, poscnt = 0
  DETAIL
   IF (mod(poscnt,100)=0)
    stat = alterlist(reply->appgrouplist[appgrpcnt].positionlist,(poscnt+ 100))
   ENDIF
   poscnt += 1, reply->appgrouplist[appgrpcnt].positionlist[poscnt].positioncd = a.position_cd
  FOOT  a.app_group_cd
   stat = alterlist(reply->appgrouplist[appgrpcnt].positionlist,poscnt)
  FOOT REPORT
   stat = alterlist(reply->appgrouplist,appgrpcnt)
  WITH nocounter
 ;end select
 CALL echo(build("Application_group:",appgrpcnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE appacccnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  a.application_number, a.app_group_cd, a.active_ind
  FROM application_access a
  WHERE ((a.application_number+ 0) > 0)
   AND ((a.active_ind+ 0)=1)
  ORDER BY a.application_number
  HEAD REPORT
   appacccnt = 0
  HEAD a.application_number
   IF (mod(appacccnt,100)=0)
    stat = alterlist(reply->appaccesslist,(appacccnt+ 100))
   ENDIF
   appacccnt += 1, reply->appaccesslist[appacccnt].appnum = a.application_number, appgrpcnt = 0
  DETAIL
   IF (mod(appgrpcnt,100)=0)
    stat = alterlist(reply->appaccesslist[appacccnt].appgrouplist,(appgrpcnt+ 100))
   ENDIF
   appgrpcnt += 1, reply->appaccesslist[appacccnt].appgrouplist[appgrpcnt].appgroupcd = a
   .app_group_cd
  FOOT  a.application_number
   stat = alterlist(reply->appaccesslist[appacccnt].appgrouplist,appgrpcnt)
  FOOT REPORT
   stat = alterlist(reply->appaccesslist,appacccnt)
  WITH nocounter
 ;end select
 CALL echo(build("Application_access:",appacccnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 DECLARE taskacccnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  t.task_number, t.app_group_cd
  FROM task_access t
  WHERE t.task_number > 0
  ORDER BY t.task_number
  HEAD REPORT
   taskacccnt = 0
  HEAD t.task_number
   IF (mod(taskacccnt,100)=0)
    stat = alterlist(reply->taskaccesslist,(taskacccnt+ 100))
   ENDIF
   taskacccnt += 1, reply->taskaccesslist[taskacccnt].tasknum = t.task_number, appgrpcnt = 0
  DETAIL
   IF (mod(appgrpcnt,100)=0)
    stat = alterlist(reply->taskaccesslist[taskacccnt].appgrouplist,(appgrpcnt+ 100))
   ENDIF
   appgrpcnt += 1, reply->taskaccesslist[taskacccnt].appgrouplist[appgrpcnt].appgroupcd = t
   .app_group_cd
  FOOT  t.task_number
   stat = alterlist(reply->taskaccesslist[taskacccnt].appgrouplist,appgrpcnt)
  FOOT REPORT
   stat = alterlist(reply->taskaccesslist,taskacccnt)
  WITH nocounter
 ;end select
 CALL echo(build("Task_access:",taskacccnt))
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 SET errmsg = fillstring(132," ")
 SET errcode = 1
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
 CALL echo(concat("reply->status_data.status: ",reply->status_data.status))
END GO
