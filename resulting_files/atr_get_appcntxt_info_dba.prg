CREATE PROGRAM atr_get_appcntxt_info:dba
 RECORD reply(
   1 qual[1]
     2 app_ctx_id = f8
     2 application_number = i4
     2 person_id = f8
     2 name = vc
     2 username = vc
     2 position_cd = f8
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 application_image = c32
     2 application_dir = vc
     2 application_status = i4
     2 parms_flag = i2
     2 device_location = vc
     2 device_address = vc
     2 authorization_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  a.app_ctx_id, a.application_number, a.person_id,
  a.name, a.username, a.position_cd,
  a.start_dt_tm, a.end_dt_tm, a.application_image,
  a.application_dir, a.application_status, a.parms_flag,
  a.device_location, a.device_address, a.authorization_ind
  FROM application_context a
  WHERE (a.application_number=request->application_number)
   AND a.start_dt_tm >= cnvtdatetime(request->start_dt_tm)
   AND a.start_dt_tm <= cnvtdatetime(request->end_dt_tm)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].app_ctx_id = a.app_ctx_id, reply->qual[count1].application_number = a
   .application_number, reply->qual[count1].person_id = a.person_id,
   reply->qual[count1].name = a.name, reply->qual[count1].username = a.username, reply->qual[count1].
   start_dt_tm =
   IF (nullind(a.start_dt_tm)=0) cnvtdatetime(a.start_dt_tm)
   ENDIF
   ,
   reply->qual[count1].end_dt_tm =
   IF (nullind(a.end_dt_tm)=0) cnvtdatetime(a.end_dt_tm)
   ENDIF
   , reply->qual[count1].application_image = a.application_image, reply->qual[count1].application_dir
    = a.application_dir,
   reply->qual[count1].application_status = a.application_status, reply->qual[count1].parms_flag = a
   .parms_flag, reply->qual[count1].device_location = a.device_location,
   reply->qual[count1].device_address = a.device_address, reply->qual[count1].authorization_ind = a
   .authorization_ind
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
