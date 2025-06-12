CREATE PROGRAM crmapp_monitor:dba
 PAINT
 SET accept = time(30)
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Active Users: ")
 CALL text(2,40,"auto refresh set to 30 seconds")
 CALL video(n)
 FREE DEFINE users
 RECORD users(
   1 list[*]
     2 uname = vc
     2 name = vc
     2 appnbr = i4
     2 appname = vc
     2 pc = vc
     2 start_dt_tm = dq8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  a.application_number, app.description
  FROM application_context a,
   application app
  WHERE a.start_dt_tm >= cnvtdatetime(curdate,0)
   AND a.end_dt_tm=null
   AND a.application_number=app.application_number
  ORDER BY a.start_dt_tm DESC
  DETAIL
   cnt += 1, stat = alterlist(users->list,cnt), users->list[cnt].uname = a.username,
   users->list[cnt].name = substring(1,15,a.name), users->list[cnt].appnbr = a.application_number,
   users->list[cnt].appname = app.description,
   users->list[cnt].start_dt_tm = a.start_dt_tm
  WITH nocounter
 ;end select
 CALL text(2,25,cnvtstring(cnt))
 IF (cnt < 18)
  SET cnt1 = cnt
 ELSE
  SET cnt1 = 18
 ENDIF
 FOR (x = 1 TO cnt1)
   SET ctime = format(users->list[x].start_dt_tm,"hh:mm:ss;;m")
   CALL text((x+ 3),5,users->list[x].uname)
   CALL text((x+ 3),15,ctime)
   CALL text((x+ 3),25,users->list[x].appname)
 ENDFOR
 CALL text(24,3,"return to refresh, 1 for details, 2 reset appctx, 9 to exit")
 CALL accept(24,1,"9",0)
 IF (curaccept=9)
  GO TO endscript
 ENDIF
 IF (curaccept=1)
  EXECUTE crmapp_report
 ENDIF
 IF (curaccept=2)
  CALL update_appctx(0)
 ENDIF
 GO TO start
#endscript
 SET accept = time(0)
 SUBROUTINE update_appctx(idx)
   CALL clear(24,1)
   CALL text(24,3,"Are you sure you want to update all appctx information (Y/N)?")
   CALL accept(24,1,"P;CU","N")
   IF (curaccept="Y")
    UPDATE  FROM application_context a
     SET a.end_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE a.start_dt_tm >= cnvtdatetime(curdate,0)
      AND a.end_dt_tm=null
     WITH nocounter
    ;end update
   ENDIF
   CALL clear(24,1)
   CALL text(24,3,"Commit changes (Y/N)?")
   CALL accept(24,1,"P;CU","N")
   IF (curaccept="Y")
    COMMIT
   ENDIF
 END ;Subroutine
END GO
