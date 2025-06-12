CREATE PROGRAM dms_get_print_services:dba
 FREE RECORD reply
 RECORD reply(
   1 qual[100]
     2 print_service_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_external_services(x=vc) = null
 DECLARE get_local_services(x=vc) = null
 DECLARE count = i2 WITH noconstant(0)
 DECLARE printer_cd = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(3000,nullterm("PRINTER"),1,printer_cd)
 IF ((request->dms_distribution_mode=1))
  CALL get_local_services("")
 ELSEIF ((request->dms_distribution_mode=2))
  CALL get_external_services("")
 ELSE
  CALL get_local_services("")
  CALL get_external_services("")
 ENDIF
 GO TO exit_script
 SUBROUTINE get_external_services(param)
   SELECT INTO "nl:"
    d.name
    FROM device d
    WHERE d.distribution_flag=1
     AND d.device_type_cd=printer_cd
     AND trim(d.physical_device_name) != null
    DETAIL
     count = (count+ 1)
     IF (mod(count,100)=1
      AND count != 1)
      stat = alter(reply->qual,(count+ 99))
     ENDIF
     reply->qual[count].print_service_name = d.name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_local_services(param)
   SELECT INTO "nl:"
    d.name
    FROM device d,
     dms_service ds
    PLAN (d
     WHERE d.distribution_flag=1
      AND d.device_type_cd=printer_cd
      AND trim(d.physical_device_name)=null)
     JOIN (ds
     WHERE d.dms_service_id=ds.dms_service_id)
    DETAIL
     count = (count+ 1)
     IF (mod(count,100)=1
      AND count != 1)
      stat = alter(reply->qual,(count+ 99))
     ENDIF
     IF (findstring("\",ds.host_name,1,1)=size(trim(ds.host_name)))
      reply->qual[count].print_service_name = build(ds.host_name,d.name)
     ELSE
      reply->qual[count].print_service_name = build(ds.host_name,"\",d.name)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (count != 0)
  SET stat = alter(reply->qual,count)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 FREE SUBROUTINE get_local_services
 FREE SUBROUTINE get_external_services
END GO
