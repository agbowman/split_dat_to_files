CREATE PROGRAM crm_get_app_group:dba
 RECORD reply(
   1 qual[*]
     2 app_group_cd = f8
     2 app_group_disp = c40
     2 app_qual[*]
       3 application_desc = vc
       3 object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET appcnt = 0
 SET groupcnt = 0
 SELECT INTO "nl:"
  a.*
  FROM appbar_security a
  WHERE (a.position_cd=reqinfo->position_cd)
  ORDER BY a.app_group_cd
  HEAD a.app_group_cd
   groupcnt = (groupcnt+ 1)
   IF (mod(groupcnt,20)=1)
    stat = alterlist(reply->qual,(groupcnt+ 19))
   ENDIF
   reply->qual[groupcnt].app_group_cd = a.app_group_cd, appcnt = 0
  DETAIL
   appcnt = (appcnt+ 1)
   IF (mod(appcnt,20)=1)
    stat = alterlist(reply->qual[groupcnt].app_qual,(appcnt+ 19))
   ENDIF
   reply->qual[groupcnt].app_qual[appcnt].application_desc = a.application_name, reply->qual[groupcnt
   ].app_qual[appcnt].object_name = a.object_name
  FOOT  a.app_group_cd
   stat = alterlist(reply->qual[groupcnt].app_qual,appcnt)
  FOOT REPORT
   stat = alterlist(reply->qual,groupcnt)
  WITH nocounter
 ;end select
END GO
