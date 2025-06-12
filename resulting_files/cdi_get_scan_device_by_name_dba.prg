CREATE PROGRAM cdi_get_scan_device_by_name:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 device[*]
      2 device_cd = f8
      2 device_type_cd = f8
      2 name = vc
      2 description = vc
      2 location_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE device_rows = i4 WITH noconstant(value(size(request->device,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE scannercd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(3000,"SCANNER",1,scannercd)
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM device d
  WHERE expand(num,1,device_rows,d.name,request->device[num].name)
   AND d.device_type_cd=scannercd
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->device,(count+ 9))
   ENDIF
   reply->device[count].device_cd = d.device_cd, reply->device[count].device_type_cd = d
   .device_type_cd, reply->device[count].name = d.name,
   reply->device[count].description = d.description, reply->device[count].location_cd = d.location_cd
  FOOT REPORT
   stat = alterlist(reply->device,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DEVICE"
 ENDIF
END GO
