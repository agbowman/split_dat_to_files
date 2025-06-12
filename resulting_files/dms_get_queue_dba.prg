CREATE PROGRAM dms_get_queue:dba
 SET modify = predeclare
 CALL echo("<==================== Entering DMS_GET_QUEUE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 device_cd = f8
      2 name = vc
      2 distribution_flag = i2
      2 service_name = vc
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET printercd
 DECLARE printercd = f8 WITH noconstant(0.0)
 FREE SET stat
 DECLARE stat = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(3000,"PRINTER",1,printercd)
 CALL echo(build("PRINTER Code Value:",printercd))
 IF (size(trim(request->name)) > 0)
  SELECT INTO "nl:"
   d.*, ds.service_name
   FROM device d,
    dms_service ds
   PLAN (d
    WHERE (d.name=request->name)
     AND d.device_type_cd=printercd)
    JOIN (ds
    WHERE ds.dms_service_id=outerjoin(d.dms_service_id))
   DETAIL
    stat = alterlist(reply->qual,1), reply->qual[1].device_cd = d.device_cd, reply->qual[1].name = d
    .name,
    reply->qual[1].distribution_flag = d.distribution_flag, reply->qual[1].service_name = ds
    .service_name, reply->qual[1].description = d.description
   WITH nocounter, maxqual(d,1)
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.status = "Z"
   GO TO end_script
  ENDIF
 ELSE
  DECLARE qualcount = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   d.*, ds.service_name
   FROM device d,
    dms_service ds
   PLAN (d
    WHERE d.device_type_cd=printercd
     AND d.device_cd > 0.0)
    JOIN (ds
    WHERE ds.dms_service_id=outerjoin(d.dms_service_id))
   HEAD REPORT
    qualcount = 0
   HEAD d.device_cd
    qualcount = (qualcount+ 1)
    IF (mod(qualcount,10)=1)
     stat = alterlist(reply->qual,(qualcount+ 9))
    ENDIF
    reply->qual[qualcount].device_cd = d.device_cd, reply->qual[qualcount].name = d.name, reply->
    qual[qualcount].distribution_flag = d.distribution_flag,
    reply->qual[qualcount].service_name = ds.service_name, reply->qual[qualcount].description = d
    .description
   FOOT REPORT
    stat = alterlist(reply->qual,qualcount)
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.status = "Z"
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_QUEUE Script ====================>")
END GO
