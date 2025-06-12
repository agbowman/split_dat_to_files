CREATE PROGRAM crmapp_appstartup:dba
 RECORD reply(
   1 reqinfo
     2 updt_id = f8
     2 updt_applctx = i4
     2 updt_appid = i4
     2 position_cd = f8
     2 location_cd = f8
     2 default_loc_cd = f8
     2 request_log_level = i2
     2 qual[*]
       3 task_number = i4
       3 request_number = i4
       3 cpmsend_ind = i2
   1 clientreqinfo
     2 updt_id = f8
     2 updt_applctx = i4
     2 updt_appid = i4
     2 position_cd = f8
     2 location_cd = f8
     2 default_loc_cd = f8
     2 log_level = i2
     2 device_address = vc
     2 device_location = vc
     2 application_name = vc
     2 username = vc
     2 person_name = vc
     2 physician_ind = i2
     2 email = vc
   1 authorizedtasks
     2 qual[*]
       3 task_number = i4
       3 request_number = i4
       3 expert_ind = i2
   1 apppreferences
     2 qual[*]
       3 section = c32
       3 parameter_data = c2000
       3 person_id = f8
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET reply->status_data.substatus = 0
 SET request->username = cnvtupper(request->username)
 SET count1 = 0
 SET count2 = 0
 SET ap_number_to_insert = size(request->paramlist,5)
 SET log_access_ind = 0
 SET application_ini_ind = 0
 SET user_active_ind = 0
 SET app_active_ind = 0
 SET app_task_ind = 0
 CALL echo(concat("Login processing for user: ",request->username," for application: ",cnvtstring(
    request->application_number)))
 DEFINE rtl "cer_install:rel.csv"
 SET reply->clientreqinfo.updt_applctx = cnvtdatetime(sysdate)
 SET reply->reqinfo.updt_applctx = cnvtdatetime(sysdate)
 SET reply->clientreqinfo.updt_id = request->application_number
 SET reply->reqinfo.updt_id = request->application_number
 SET count = 0
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  WHERE r.line=concat(trim(cnvtstring(request->application_number)),"*")
  DETAIL
   count += 1, s1 = (findstring(",",r.line)+ 1), s2 = (findstring(",",substring(s1,20,r.line))+ s1),
   s3 = ((s2 - s1) - 1), tsknbr = cnvtint(substring(s1,s3,r.line)), s4 = findstring(" ",substring(s2,
     20,r.line)),
   reqnbr = cnvtint(substring(s2,s4,r.line)), stat = alterlist(reply->authorizedtasks.qual,count),
   stat = alterlist(reply->reqinfo.qual,count),
   reply->authorizedtasks.qual[count].task_number = tsknbr, reply->authorizedtasks.qual[count].
   request_number = reqnbr, reply->reqinfo.qual[count].task_number = tsknbr,
   reply->reqinfo.qual[count].request_number = reqnbr
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Authorization Status:",reply->status_data.status))
END GO
