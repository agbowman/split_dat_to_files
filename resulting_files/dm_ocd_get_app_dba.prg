CREATE PROGRAM dm_ocd_get_app:dba
 FREE RECORD reply
 RECORD reply(
   1 app[*]
     2 application_number = i4
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
 SET reply->status_data.status = "S"
#end_program
END GO
