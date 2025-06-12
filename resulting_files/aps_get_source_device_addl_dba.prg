CREATE PROGRAM aps_get_source_device_addl:dba
 RECORD reply(
   1 source_device_params[*]
     2 ap_source_device_addl_id = f8
     2 source_device_cd = f8
     2 source_device_disp = vc
     2 network_share_path = vc
     2 source_device_url = vc
     2 device_username = vc
     2 device_password = vc
     2 image_server_url = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE source_device_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM ap_source_device_addl asda
  WHERE asda.ap_source_device_addl_id > 0.0
  DETAIL
   source_device_cnt = (source_device_cnt+ 1)
   IF (mod(source_device_cnt,10)=1)
    stat = alterlist(reply->source_device_params,(source_device_cnt+ 9))
   ENDIF
   reply->source_device_params[source_device_cnt].ap_source_device_addl_id = asda
   .ap_source_device_addl_id, reply->source_device_params[source_device_cnt].source_device_cd = asda
   .source_device_cd, reply->source_device_params[source_device_cnt].network_share_path = asda
   .network_share_path,
   reply->source_device_params[source_device_cnt].source_device_url = asda.source_device_url, reply->
   source_device_params[source_device_cnt].device_username = asda.device_username, reply->
   source_device_params[source_device_cnt].device_password = asda.device_password,
   reply->source_device_params[source_device_cnt].image_server_url = asda.image_server_url
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->source_device_params,source_device_cnt)
 IF (size(reply->source_device_params,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
