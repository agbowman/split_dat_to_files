CREATE PROGRAM cp_load_discern_reports:dba
 IF (validate(request) != 1)
  FREE RECORD request
  RECORD request(
    1 requesting_system
    1 custom_data_element_flag
  )
 ENDIF
 RECORD reply(
   1 qual[*]
     2 chart_discern_request_id = f8
     2 request_number = i4
     2 process_flag = i2
     2 display = vc
     2 scope_bit_map = i4
     2 active_ind = i2
     2 process_system_flag = i2
     2 script_name = c30
     2 qualification_date_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 DECLARE win32 = i2 WITH constant(0), protect
 DECLARE xr = i2 WITH constant(1), protect
 DECLARE win32_and_xr = i2 WITH constant(2), protect
 DECLARE xr_custom_dataelements = i2 WITH constant(3), protect
 SELECT DISTINCT INTO "nl:"
  cdr.chart_discern_request_id, cdr.request_number, cdr.process_flag,
  cdr.display_text, cdr.scope_bit_map, cdr.active_ind
  FROM chart_discern_request cdr
  WHERE cdr.chart_discern_request_id != 0.0
   AND cdr.active_ind=1
  ORDER BY cnvtupper(cdr.display_text) DESC
  HEAD REPORT
   count = 0
  DETAIL
   IF (((cdr.process_system_flag=xr_custom_dataelements
    AND (request->requesting_system=xr)
    AND (request->custom_data_element_flag=1)) OR ((((request->requesting_system=win32)
    AND ((cdr.process_system_flag=win32) OR (cdr.process_system_flag=win32_and_xr)) ) OR ((request->
   requesting_system=xr)
    AND ((cdr.process_system_flag=xr) OR (cdr.process_system_flag=win32_and_xr))
    AND (request->custom_data_element_flag=0))) )) )
    count += 1
    IF (mod(count,10)=1)
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].chart_discern_request_id = cdr.chart_discern_request_id, reply->qual[count].
    request_number = cdr.request_number, reply->qual[count].process_flag = cdr.process_flag,
    reply->qual[count].display = cdr.display_text, reply->qual[count].scope_bit_map = cdr
    .scope_bit_map, reply->qual[count].active_ind = cdr.active_ind,
    reply->qual[count].process_system_flag = cdr.process_system_flag, reply->qual[count].script_name
     = cdr.script_name, reply->qual[count].qualification_date_flag = validate(cdr
     .qualification_date_flag,0)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
