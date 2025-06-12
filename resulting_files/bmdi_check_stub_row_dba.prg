CREATE PROGRAM bmdi_check_stub_row:dba
 RECORD request(
   1 service_resource_cd = f8
 )
 RECORD reply(
   1 qual[*]
     2 device_alias = vc
     2 monitored_device_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE rcount = i2
 DECLARE i = i2
 DECLARE temp = i2
 SET rcount = 0
 SET i = 0
 SET reply->status_data.status = "F"
 SET temp = 0
 SELECT INTO "nl:"
  FROM bmdi_monitored_device bmd
  WHERE (bmd.device_cd=request->service_resource_cd)
  DETAIL
   rcount += 1, stat = alterlist(reply->qual,rcount), reply->qual[rcount].device_alias = bmd
   .device_alias,
   reply->qual[rcount].monitored_device_id = bmd.monitored_device_id
  WITH nocounter
 ;end select
 CALL echo(build("Total Devices in Gateway is  = ",rcount))
 FOR (i = 1 TO rcount)
  SELECT INTO "nl:"
   FROM bmdi_acquired_data_track badt
   WHERE (badt.monitored_device_id=reply->qual[i].monitored_device_id)
    AND badt.active_ind=0
    AND badt.dis_association_dt_tm=null
    AND badt.person_id=0.00
    AND badt.parent_entity_id=0.00
   DETAIL
    temp += 1
    IF (temp > 0)
     CALL echo("The stub row/assoc row exists"), temp = 0
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Association exists or Stub row is missing. ")
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.monitored_device_id=reply->qual[i].monitored_device_id)
     AND badt.active_ind=1
     AND badt.dis_association_dt_tm=null
     AND ((badt.person_id > 0.00) OR (badt.parent_entity_id > 0.00))
    DETAIL
     temp += 1
     IF (temp > 0)
      CALL echo("The DEVICE is in USE. "), temp = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("The Stub is really missing. ")
    SET reply->qual[i].monitored_device_id = 0.00
   ENDIF
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
