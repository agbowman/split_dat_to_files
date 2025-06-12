CREATE PROGRAM crmapp_serverstartup_nordbms:dba
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
   1 tasklist[*]
     2 tasknum = i4
     2 subtaskind = i2
   1 requestlist[*]
     2 requestnum = i4
     2 cpmsendind = i2
     2 requestclass = i2
     2 expertind = i2
     2 cachetime = i2
   1 apptasklist[*]
     2 appnum = i4
     2 tasknum = i4
   1 taskrequestlist[*]
     2 tasknum = i4
     2 requestnum = i4
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo("Loading Application Table...")
 SET appcnt = 0
 SET description = fillstring(50," ")
 SET objname = fillstring(50," ")
 FREE DEFINE rtl2
 DEFINE rtl2 "cer_install:app.csv"
 SELECT INTO "nl:"
  a.line
  FROM rtl2t a
  DETAIL
   appcnt += 1
   IF (appcnt > 1)
    s1 = findstring(",",a.line), s2 = findstring(",",a.line,(s1+ 1)), s3 = findstring(",",a.line,(s2
     + 1)),
    s4 = findstring(",",a.line,(s3+ 1)), s5 = findstring(",",a.line,(s4+ 1)), s6 = findstring(",",a
     .line,(s5+ 1)),
    s7 = findstring(",",a.line,(s6+ 1)), s8 = findstring(",",a.line,(s7+ 1)), s9 = findstring(",",a
     .line,(s8+ 1)),
    s10 = findstring(",",a.line,(s9+ 1)), s11 = findstring(",",a.line,(s10+ 1)), s12 = findstring(",",
     a.line,(s11+ 1)),
    appnum = cnvtint(substring(1,(s1 - 1),a.line)), description = substring((s2+ 1),((s3 - s2) - 1),a
     .line), logaccessind = cnvtint(substring((s5+ 1),((s6 - s5) - 1),a.line)),
    appiniind = cnvtint(substring((s6+ 1),((s7 - s6) - 1),a.line)), objname = substring((s7+ 1),((s8
      - s7) - 1),a.line), loglevel = cnvtint(substring((s9+ 1),((s10 - s9) - 1),a.line)),
    reqloglevel = cnvtint(substring((s10+ 1),((s11 - s10) - 1),a.line)), cacheind = cnvtint(substring
     ((s11+ 1),((s12 - s11) - 1),a.line)), stat = alterlist(reply->applist,appcnt),
    reply->applist[appcnt].appnum = appnum, reply->applist[appcnt].objname = objname, reply->applist[
    appcnt].loglevel = loglevel,
    reply->applist[appcnt].reqloglevel = reqloglevel, reply->applist[appcnt].logaccessind =
    logaccessind, reply->applist[appcnt].appiniind = appiniind,
    reply->applist[appcnt].cacheind = cacheind
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo(build("App Load count:",appcnt))
 FREE DEFINE rtl2
 DEFINE rtl2 "cer_install:task.csv"
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo("Loading Task Table...")
 SET taskcnt = 0
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  DETAIL
   taskcnt += 1
   IF (taskcnt > 1)
    s1 = findstring(",",t.line), tasknum = cnvtint(substring(1,(s1 - 1),t.line)), stat = alterlist(
     reply->tasklist,taskcnt),
    reply->tasklist[taskcnt].tasknum = tasknum
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo(build("Task Load count:",taskcnt))
 FREE DEFINE rtl2
 DEFINE rtl2 "cer_install:req.csv"
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo("Loading Request Table...")
 SET reqcnt = 0
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  DETAIL
   reqcnt += 1
   IF (reqcnt > 1)
    s1 = findstring(",",r.line), reqnum = cnvtint(substring(1,(s1 - 1),r.line)), stat = alterlist(
     reply->requestlist,reqcnt),
    reply->requestlist[reqcnt].requestnum = reqnum
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo(build("Request Load count:",reqcnt))
 FREE DEFINE rtl2
 DEFINE rtl2 "cer_install:rel.csv"
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo("Loading App Task Information...")
 SET cnt = 0
 SELECT INTO "nl:"
  appnum = cnvtint(substring(1,(findstring(",",r.line) - 1),r.line)), tasknum = cnvtint(substring((
    findstring(",",r.line)+ 1),((findstring(",",r.line,(findstring(",",r.line)+ 1)) - findstring(",",
     r.line)) - 1),r.line)), r.line
  FROM rtl2t r
  ORDER BY appnum, tasknum
  HEAD appnum
   col + 0
  HEAD tasknum
   IF (appnum > 0
    AND tasknum > 0)
    cnt += 1, stat = alterlist(reply->apptasklist,cnt), reply->apptasklist[cnt].appnum = appnum,
    reply->apptasklist[cnt].tasknum = tasknum
   ENDIF
  DETAIL
   col + 0
  WITH nocounter
 ;end select
 CALL echo(build("App Task Load count:",cnt))
 CALL echo(build("End time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo(build("time:",format(curtime3,"hh:mm:ss;;m")))
 CALL echo("Loading Task Request Relationship Information...")
 SET taskcnt = 0
 SELECT INTO "nl:"
  appnum = cnvtint(substring(1,(findstring(",",r.line) - 1),r.line)), tasknum = cnvtint(substring((
    findstring(",",r.line)+ 1),((findstring(",",r.line,(findstring(",",r.line)+ 1)) - findstring(",",
     r.line)) - 1),r.line)), reqnum = cnvtint(substring((findstring(",",r.line,(findstring(",",r.line
      )+ 1))+ 1),((findstring(",",r.line,(findstring(",",r.line)+ 1))+ 1) - findstring(",",r.line,(
     findstring(",",r.line,(findstring(",",r.line)+ 1))+ 1))),r.line))
  FROM rtl2t r
  ORDER BY tasknum, reqnum
  HEAD tasknum
   col + 0
  HEAD reqnum
   IF (tasknum > 0
    AND reqnum > 0)
    taskcnt += 1, stat = alterlist(reply->taskrequestlist,taskcnt), reply->taskrequestlist[taskcnt].
    tasknum = tasknum,
    reply->taskrequestlist[taskcnt].requestnum = reqnum, col 0, tasknum,
    " ", reqnum, row + 1
   ENDIF
  DETAIL
   col + 0
  WITH nocounter
 ;end select
 CALL echo(build("TRR Load count:",taskcnt))
 CALL echo(build("End time:",format(curtime3,"hh:mm:ss;;m")))
END GO
