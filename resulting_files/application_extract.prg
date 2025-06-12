CREATE PROGRAM application_extract
 PAINT
 RECORD atr(
   1 application_number = i4
   1 task_qual[*]
     2 task_number = i4
     2 req_cnt = i4
     2 req_qual[*]
       3 request_number = i4
 )
 RECORD app(
   1 app_qual[*]
     2 application_number = i4
 )
#start
 DECLARE appno = i4
 DECLARE tempappstring = c10
 DECLARE appno2 = i4
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,17,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"ATR Application Extract")
 CALL video(n)
 CALL text(6,5,"Application Number ")
 CALL text(6,35,"To")
 CALL accept(6,25,"XXXXXXXXX")
 SET appno = curaccept
 IF (appno=0)
  GO TO start
 ENDIF
 CALL accept(6,38,"XXXXXXXXX",appno)
 SET appno2 = curaccept
 CALL text(8,5,"Type a unique name for your files? ")
 CALL accept(8,40,"XXXXXXXXXX;CU")
 SET grpname = curaccept
 CALL text(10,5,"Your files will be named")
 CALL text(10,30,build(grpname,"App.csv"))
 CALL text(11,30,build(grpname,"Rel.csv"))
 CALL text(12,30,build(grpname,"Task.csv"))
 CALL text(13,30,build(grpname,"Req.csv"))
 CALL text(14,5,"and are located in the CER_INSTALL directory")
 SET appfname = build("cer_install:",grpname,"App.csv")
 SET relfname = build("cer_install:",grpname,"Rel.csv")
 SET taskfname = build("cer_install:",grpname,"Task.csv")
 SET reqfname = build("cer_install:",grpname,"Req.csv")
 SET appcnt = 0
 SELECT INTO "nl:"
  a.application_number
  FROM application a
  WHERE a.application_number >= appno
   AND a.application_number <= appno2
  ORDER BY a.application_number
  DETAIL
   appcnt = (appcnt+ 1), stat = alterlist(app->app_qual,appcnt), app->app_qual[appcnt].
   application_number = a.application_number,
   col 0, app->app_qual[appcnt].application_number, row + 1
  WITH nocounter
 ;end select
 SET first_time = "T"
 SET first_req = "T"
 FOR (num = 1 TO appcnt)
   SELECT INTO "nl:"
    atr.task_number, atreq.request_number
    FROM application_task_r atr,
     task_request_r atreq
    PLAN (atr
     WHERE (atr.application_number=app->app_qual[num].application_number))
     JOIN (atreq
     WHERE atr.task_number=atreq.task_number)
    ORDER BY atr.task_number, atreq.request_number
    HEAD REPORT
     cnt = 0, atr->application_number = app->app_qual[num].application_number, col 5,
     app->app_qual[num].application_number
    HEAD atr.task_number
     reqcnt = 0, cnt = (cnt+ 1), stat = alterlist(atr->task_qual,cnt),
     atr->task_qual[cnt].req_cnt = 0, atr->task_qual[cnt].task_number = atr.task_number, row + 1,
     col 10, atr.task_number
    HEAD atreq.request_number
     reqcnt = (reqcnt+ 1), stat = alterlist(atr->task_qual[cnt].req_qual,reqcnt), atr->task_qual[cnt]
     .req_cnt = (atr->task_qual[cnt].req_cnt+ 1),
     atr->task_qual[cnt].req_qual[reqcnt].request_number = atreq.request_number, row + 1, col 15,
     atreq.request_number
    WITH append
   ;end select
   SELECT
    IF (first_time="T")
     WITH maxcol = 1000, noformfeed, maxrow = 1
    ELSE
     WITH maxcol = 1000, noformfeed, maxrow = 1,
      append
    ENDIF
    INTO value(appfname)
    a.*
    FROM application a
    WHERE (a.application_number=app->app_qual[num].application_number)
    ORDER BY a.application_number
    HEAD REPORT
     IF (first_time="T")
      y = build("application_number, ","owner, ","app_description, ","app_active_ind, ","app_text, ",
       "log_access_ind, ","application_ini_ind, ","object_name, ","direct_access_ind, ","log_level, ",
       "request_log_level, ","min_version_required"), col 0, y,
      row + 1
     ENDIF
    DETAIL
     x = check(build(a.application_number,",",'"',a.owner,'"',
       ",",'"',a.description,'"',",",
       a.active_ind,",",'"',a.text,'"',
       ",",a.log_access_ind,",",a.application_ini_ind,",",
       a.object_name,",",a.direct_access_ind,",",a.log_level,
       ",",a.request_log_level,",",a.min_version_required)), col 0, x
   ;end select
   SELECT
    IF (first_time="T")
     WITH maxcol = 70, noformfeed, maxrow = 1
    ELSE
     WITH maxcol = 70, noformfeed, maxrow = 1,
      append
    ENDIF
    INTO value(relfname)
    x = build(atr.application_number,",",trr.task_number,",",trr.request_number)
    FROM application_task_r atr,
     task_request_r trr
    PLAN (atr
     WHERE (atr.application_number=app->app_qual[num].application_number))
     JOIN (trr
     WHERE atr.task_number=trr.task_number)
    ORDER BY atr.application_number, trr.task_number
    HEAD REPORT
     IF (first_time="T")
      y = build("application_number, ","task_number, ","request_number"), col 0, y,
      row + 1
     ENDIF
    DETAIL
     row + 1, col 0, x
   ;end select
   SET first_task = "T"
   SET cnt = size(atr->task_qual,5)
   SELECT
    IF (first_time="T")
     WITH maxcol = 900, noformfeed, maxrow = 1
    ELSE
     WITH maxcol = 900, noformfeed, maxrow = 1,
      append
    ENDIF
    INTO value(taskfname)
    t.*
    FROM application_task t,
     (dummyt d  WITH seq = value(cnt))
    PLAN (d)
     JOIN (t
     WHERE (t.task_number=atr->task_qual[d.seq].task_number))
    ORDER BY t.task_number
    HEAD REPORT
     IF (first_time="T")
      y = build("task_number, ","tsk_description, ","tsk_active_ind, ","tsk_text, ",
       "subordinate_task_ind"), col 0, y,
      row + 1
     ENDIF
    DETAIL
     x = check(build(t.task_number,",",'"',t.description,'"',
       ",",t.active_ind,",",'"',t.text,
       '"',",",t.subordinate_task_ind)), col 0, x,
     row + 1
   ;end select
   SET cnt = size(atr->task_qual,5)
   FOR (a = 1 TO cnt)
    SELECT
     IF (first_req="T")
      WITH maxcol = 1000, noformfeed, maxrow = 1
     ELSE
      WITH maxcol = 1000, noformfeed, maxrow = 1,
       append
     ENDIF
     INTO value(reqfname)
     r.*
     FROM request r,
      (dummyt d2  WITH seq = value(atr->task_qual[a].req_cnt))
     PLAN (d2)
      JOIN (r
      WHERE (r.request_number=atr->task_qual[a].req_qual[d2.seq].request_number))
     HEAD REPORT
      IF (first_req="T")
       y = build("request_number, ","req_description, ","request_name, ","req_text, ",
        "req_active_ind, ",
        "prolog_script, ","epilog_script, "), col 0, y,
       row + 1
      ENDIF
     DETAIL
      x = check(build(r.request_number,",",'"',r.description,'"',
        ",",'"',r.request_name,'"',",",
        '"',r.text,'"',",",r.active_ind,
        ",",r.prolog_script,",",r.epilog_script)), row + 1, col 0,
      x
    ;end select
    SET first_req = "F"
   ENDFOR
   SET first_time = "F"
 ENDFOR
END GO
