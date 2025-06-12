CREATE PROGRAM cpe_get_proc_errors:dba
 RECORD reply(
   1 qual[*]
     2 request_number = i4
     2 error_id = f8
     2 que_id = f8
     2 destination_step_id = f8
     2 service = vc
     2 target_request_number = i4
     2 error_code = i4
     2 srvexec_status = i4
     2 original_error_code = i4
     2 format_script = c30
     2 que_seq = i4
     2 recover_seq = i4
     2 retry_attempts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->request_number > 0)
   AND (request->destination_step_id > 0.0))
   WHERE (c.request_number=request->request_number)
    AND (c.destination_step_id=request->destination_step_id)
    AND error_code > 0
  ELSEIF ((request->request_number > 0)
   AND (request->destination_step_id=0.0))
   WHERE (c.request_number=request->request_number)
    AND error_code > 0
  ELSEIF ((request->request_number=0)
   AND (request->destination_step_id > 0.0))
   WHERE (c.destination_step_id=request->destination_step_id)
    AND error_code > 0
  ELSEIF ((request->request_number=0)
   AND (request->destination_step_id=0.0))
   WHERE 0=0
    AND error_code > 0
  ELSE
  ENDIF
  INTO "nl:"
  c.request_number, c.error_id, c.que_id,
  c.destination_step_id, c.service, c.target_request_number,
  c.error_code, c.srvexec_status, c.original_error_code,
  c.format_script, c.que_seq, c.recover_seq,
  c.retry_attempts
  FROM cpmprocess_error c
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].request_number = c
   .request_number,
   reply->qual[count1].error_id = c.error_id, reply->qual[count1].que_id = c.que_id, reply->qual[
   count1].destination_step_id = c.destination_step_id,
   reply->qual[count1].service = c.service, reply->qual[count1].target_request_number = c
   .target_request_number, reply->qual[count1].error_code = c.error_code,
   reply->qual[count1].srvexec_status = c.srvexec_status, reply->qual[count1].original_error_code = c
   .original_error_code, reply->qual[count1].format_script = c.format_script,
   reply->qual[count1].que_seq = c.que_seq, reply->qual[count1].recover_seq = c.recover_seq, reply->
   qual[count1].retry_attempts = c.retry_attempts
  WITH nocounter
 ;end select
 CALL echo(build("count1 = ",count1))
 IF (count1=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "application"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("statuschar = ",reply->status_data.status))
 CALL echo(size(reply->qual,5))
END GO
