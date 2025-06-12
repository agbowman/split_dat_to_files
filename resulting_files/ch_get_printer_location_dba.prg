CREATE PROGRAM ch_get_printer_location:dba
 RECORD reply(
   1 qual[10]
     2 description = vc
     2 device_cd = f8
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
 SELECT DISTINCT INTO "nl:"
  d.device_cd
  FROM device d
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 != 1
    AND mod(count1,10)=1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].description = d.description,
   CALL echo(build("Printer:",reply->qual[count1].description)), reply->qual[count1].device_cd = d
   .device_cd
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
