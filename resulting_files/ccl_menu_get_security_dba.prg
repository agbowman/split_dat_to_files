CREATE PROGRAM ccl_menu_get_security:dba
 FREE SET reply
 RECORD reply(
   1 app_groups[*]
     2 app_group_cd = f8
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
 IF ((request->menu_id_f8=0))
  SET request->menu_id_f8 = request->menu_id
 ENDIF
 SELECT DISTINCT INTO "nl:"
  e.app_group_cd
  FROM explorer_menu_security e
  WHERE (e.menu_id=request->menu_id_f8)
  ORDER BY e.app_group_cd
  HEAD REPORT
   stat = alterlist(reply->app_groups,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->app_groups,(cnt+ 10))
   ENDIF
   reply->app_groups[cnt].app_group_cd = e.app_group_cd
  FOOT REPORT
   stat = alterlist(reply->app_groups,cnt), row + 0, cntx = 0
   FOR (cntx = 1 TO cnt)
     CALL echo(reply->app_groups[cntx].app_group_cd)
   ENDFOR
  WITH nocounter
 ;end select
 CALL echo(concat("curqual=",cnvtstring(curqual)))
 SET reply->status_data.status = "S"
 SET failed = "F"
 SET errcode = error(errmsg,1)
 GO TO exit_script
#exit_script
 SET reqinfo->commit_ind = 1
 GO TO endit
#endit
END GO
