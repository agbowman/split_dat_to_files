CREATE PROGRAM dms_get_device_by_servicename:dba
 RECORD reply(
   1 description = c110
   1 device_cd = f8
   1 device_function_cd = f8
   1 device_type_cd = f8
   1 distribution_flag = i2
   1 dms_service_id = f8
   1 local_address = c20
   1 location_cd = f8
   1 name = c50
   1 physical_device_name = c50
   1 status = c1
 )
 SET reply->status = "F"
 SELECT INTO "nl:"
  FROM device d,
   dms_service dms
  PLAN (dms
   WHERE (dms.service_name=request->service_name))
   JOIN (d
   WHERE d.dms_service_id=dms.dms_service_id)
  DETAIL
   reply->description = d.description, reply->device_cd = d.device_cd, reply->device_function_cd = d
   .device_function_cd,
   reply->device_type_cd = d.device_type_cd, reply->distribution_flag = d.distribution_flag, reply->
   dms_service_id = d.dms_service_id,
   reply->local_address = d.local_address, reply->location_cd = d.location_cd, reply->name = d.name,
   reply->physical_device_name = d.physical_device_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status = "Z"
 ELSE
  SET reply->status = "S"
 ENDIF
END GO
