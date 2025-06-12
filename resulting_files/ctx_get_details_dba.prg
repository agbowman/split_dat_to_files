CREATE PROGRAM ctx_get_details:dba
 RECORD reply(
   1 app_ctx_id = f8
   1 application_number = i4
   1 person_id = f8
   1 name = vc
   1 username = vc
   1 position_cd = f8
   1 position_disp = c40
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 application_image = c32
   1 application_dir = vc
   1 application_status = i4
   1 parms_flag = i2
   1 device_location = vc
   1 device_address = vc
   1 authorization_ind = i2
   1 application_version = vc
   1 default_location = vc
   1 client_start_dt_tm = dq8
   1 client_node_name = vc
   1 tcpip_address = vc
   1 logdirectory = vc
   1 client_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  a.app_ctx_id
  FROM application_context a
  WHERE (a.app_ctx_id=request->appctxid)
  DETAIL
   count1 += 1, reply->app_ctx_id = a.app_ctx_id, reply->application_number = a.application_number,
   reply->person_id = a.person_id, reply->name = a.name, reply->username = a.username,
   reply->position_cd = a.position_cd, reply->start_dt_tm = cnvtdatetime(a.start_dt_tm), reply->
   end_dt_tm = cnvtdatetime(a.end_dt_tm),
   reply->application_image = a.application_image, reply->application_dir = a.application_dir, reply
   ->application_status = a.application_status,
   reply->parms_flag = a.parms_flag, reply->device_location = a.device_location, reply->
   device_address = a.device_address,
   reply->authorization_ind = a.authorization_ind, reply->application_version = a.application_version,
   reply->default_location = a.default_location,
   reply->client_start_dt_tm = cnvtdatetime(a.client_start_dt_tm), reply->client_node_name = a
   .client_node_name, reply->tcpip_address = a.tcpip_address,
   reply->logdirectory = a.logdirectory, reply->client_tz = a.client_tz
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
