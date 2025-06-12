CREATE PROGRAM cps_get_appl_ini:dba
 RECORD reply(
   1 person_id = f8
   1 appl_qual = i4
   1 appl[*]
     2 application_number = i4
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 device_location = vc
     2 device_address = vc
     2 tcpip_address = vc
     2 sect_qual = i4
     2 sect[*]
       3 section = vc
       3 parameter_data = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->appl,5)
 SET reply->appl_qual = 0
 SET stat = alterlist(reply->appl[1].sect,5)
 SET reply->appl[1].sect_qual = 0
 SET count1 = 0
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE idx1 = i4 WITH noconstant(0), public
 SELECT INTO "NL:"
  a.application_number
  FROM application_ini a
  PLAN (a
   WHERE expand(idx,1,size(request->appl,5),a.application_number,request->appl[idx].
    application_number)
    AND (request->person_id=a.person_id)
    AND a.application_number > 0)
  ORDER BY a.application_number
  HEAD REPORT
   count1 = 0, reply->person_id = request->person_id
  HEAD a.application_number
   count1 += 1
   IF (size(reply->appl,5) <= count1)
    stat = alterlist(reply->appl,(count1+ 9))
   ENDIF
   reply->appl[count1].application_number = a.application_number, count2 = 0
  DETAIL
   count2 += 1
   IF (size(reply->appl[count1].sect,5) <= count2)
    stat = alterlist(reply->appl[count1].sect,(count2+ 9))
   ENDIF
   reply->appl[count1].sect[count2].section = a.section, reply->appl[count1].sect[count2].
   parameter_data = a.parameter_data
  FOOT  a.application_number
   stat = alterlist(reply->appl[count1].sect,count2), reply->appl[count1].sect_qual = count2
  FOOT REPORT
   stat = alterlist(reply->appl,count1), reply->appl_qual = count1
  WITH noformat, nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((reply->status_data.status="S"))
  SET appl_size = size(reply->appl,5)
  SET knt = 0
  SELECT INTO "nl:"
   ac.application_number
   FROM application_context ac
   PLAN (ac
    WHERE expand(idx1,1,appl_size,ac.application_number,reply->appl[idx1].application_number)
     AND (ac.person_id=reply->person_id))
   ORDER BY cnvtdatetime(ac.start_dt_tm) DESC
   HEAD REPORT
    knt += 1, reply->appl[knt].start_dt_tm = ac.start_dt_tm, reply->appl[knt].end_dt_tm = ac
    .end_dt_tm,
    reply->appl[knt].device_location = ac.device_location, reply->appl[knt].device_address = ac
    .device_address, reply->appl[knt].tcpip_address = ac.tcpip_address
   DETAIL
    x = 0
   WITH nocounter, check
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ENDIF
 SET script_version = "002 01/14/05 AW9942"
END GO
