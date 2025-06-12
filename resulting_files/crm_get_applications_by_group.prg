CREATE PROGRAM crm_get_applications_by_group
 SET app_num = 0
 RECORD reply(
   1 applications[*]
     2 number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  app_access.application_number
  FROM application_access app_access
  PLAN (app_access
   WHERE (app_access.app_group_cd=request->app_group_cd)
    AND app_access.active_ind=1)
  DETAIL
   app_num = (app_num+ 1)
   IF (mod(app_num,10)=1)
    stat = alterlist(reply->applications,(app_num+ 9))
   ENDIF
   reply->applications[app_num].number = app_access.application_number
  FOOT REPORT
   stat = alterlist(reply->applications,app_num)
 ;end select
 SET reply->status_data.status = "S" WITH nocounter
END GO
