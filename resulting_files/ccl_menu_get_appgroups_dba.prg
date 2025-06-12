CREATE PROGRAM ccl_menu_get_appgroups:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 app_group_cd = f8
     2 desc = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 SET errmsg = fillstring(255," ")
 SELECT DISTINCT INTO "nl:"
  a.app_group_cd, group_display = uar_get_code_display(a.app_group_cd)
  FROM application_group a
  WHERE a.application_group_id > 0
   AND a.app_group_cd > 0
  ORDER BY a.app_group_cd
  HEAD REPORT
   stat = alterlist(reply->qual,10), testout = 0, app_grp_txt = fillstring(12," ")
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].app_group_cd = a.app_group_cd
   IF (group_display=" ")
    app_grp_txt = format(cnvtstring(a.app_group_cd),"############"), reply->qual[cnt].desc = build(
     "Application Group Code","-",app_grp_txt)
   ELSE
    reply->qual[cnt].desc = group_display
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
   FOR (testout = 1 TO cnt)
     CALL echo(concat(cnvtstring(reply->qual[testout].app_group_cd),"  ",reply->qual[testout].desc))
   ENDFOR
  WITH nocounter
 ;end select
 CALL echo(concat("curqual=",cnvtstring(curqual)))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_menu_get_appgroups"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
END GO
