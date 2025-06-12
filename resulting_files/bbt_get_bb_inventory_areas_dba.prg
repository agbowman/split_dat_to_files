CREATE PROGRAM bbt_get_bb_inventory_areas:dba
 RECORD reply(
   1 qual[10]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
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
  bia.service_resource_cd
  FROM bb_inventory_area bia,
   code_value cv
  PLAN (bia)
   JOIN (cv
   WHERE cv.code_set=221
    AND cv.code_value=bia.service_resource_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].service_resource_cd = bia.service_resource_cd
  WITH counter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
