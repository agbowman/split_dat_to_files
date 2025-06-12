CREATE PROGRAM dm_ocd_get_atr:dba
 FREE RECORD reply
 RECORD reply(
   1 app[*]
     2 application_number = i4
     2 feature_number = i4
   1 task[*]
     2 task_number = i4
     2 feature_number = i4
   1 req[*]
     2 request_number = i4
     2 feature_number = i4
   1 app_task[*]
     2 application_number = i4
     2 task_number = i4
     2 feature_number = i4
   1 task_req[*]
     2 task_number = i4
     2 request_number = i4
     2 feature_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->app,0)
 SET stat = alterlist(reply->task,0)
 SET stat = alterlist(reply->req,0)
 SET stat = alterlist(reply->app_task,0)
 SET stat = alterlist(reply->task_req,0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_ocd_application dm
  WHERE (dm.alpha_feature_nbr=request->ocd_number)
  ORDER BY dm.application_number
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->app,count), reply->app[count].application_number = dm
   .application_number,
   reply->app[count].feature_number = dm.feature_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_ocd_task dm
  WHERE (dm.alpha_feature_nbr=request->ocd_number)
  ORDER BY dm.task_number
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->task,count), reply->task[count].task_number = dm
   .task_number,
   reply->task[count].feature_number = dm.feature_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_ocd_request dm
  WHERE (dm.alpha_feature_nbr=request->ocd_number)
  ORDER BY dm.request_number
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->req,count), reply->req[count].request_number = dm
   .request_number,
   reply->req[count].feature_number = dm.feature_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_ocd_app_task_r dm
  WHERE (dm.alpha_feature_nbr=request->ocd_number)
  ORDER BY dm.application_number, dm.task_number
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->app_task,count), reply->app_task[count].
   application_number = dm.application_number,
   reply->app_task[count].task_number = dm.task_number, reply->app_task[count].feature_number = dm
   .feature_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_ocd_task_req_r dm
  WHERE (dm.alpha_feature_nbr=request->ocd_number)
  ORDER BY dm.task_number, dm.request_number
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->task_req,count), reply->task_req[count].task_number =
   dm.task_number,
   reply->task_req[count].request_number = dm.request_number, reply->task_req[count].feature_number
    = dm.feature_number
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#end_program
END GO
