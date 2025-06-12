CREATE PROGRAM bbt_get_refrigerators:dba
 RECORD reply(
   1 qual[*]
     2 device_id = f8
     2 description = c40
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_mean = c12
     2 inventory_area_cd = f8
     2 inventory_area_disp = c40
     2 inventory_area_mean = c12
     2 device_type_cd = f8
     2 device_type_disp = c40
     2 device_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET stat = 0
 SELECT INTO "nl:"
  d.seq
  FROM bb_device d
  WHERE d.device_id > 0
   AND d.active_ind=1
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].device_id = d
   .device_id,
   reply->qual[count1].description = d.description, reply->qual[count1].location_cd = d.location_cd,
   reply->qual[count1].service_resource_cd = d.service_resource_cd,
   reply->qual[count1].inventory_area_cd = d.inventory_area_cd, reply->qual[count1].device_type_cd =
   d.device_type_cd
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
