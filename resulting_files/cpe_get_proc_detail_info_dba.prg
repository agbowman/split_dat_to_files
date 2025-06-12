CREATE PROGRAM cpe_get_proc_detail_info:dba
 RECORD reply(
   1 request_number = i4
   1 description = vc
   1 error_id = f8
   1 que_id = f8
   1 destination_step_id = f8
   1 service = vc
   1 target_request_number = i4
   1 error_code = i4
   1 srvexec_status = i4
   1 original_error_code = i4
   1 format_script = vc
   1 que_seq = i4
   1 recover_seq = i4
   1 retry_attempts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.request_number, r.description, c.error_id,
  c.que_id, c.destination_step_id, c.service,
  c.target_request_number, c.error_code, c.srvexec_status,
  c.original_error_code, c.format_script, c.que_seq,
  c.recover_seq, c.retry_attempts
  FROM request r,
   cpmprocess_error c
  WHERE c.request_number=r.request_number
   AND (c.request_number=request->request_number)
   AND (c.error_id=request->error_id)
  DETAIL
   reply->request_number = c.request_number, reply->description = r.description, reply->error_id = c
   .error_id,
   reply->que_id = c.que_id, reply->destination_step_id = c.destination_step_id, reply->service = c
   .service,
   reply->target_request_number = c.target_request_number, reply->error_code = c.error_code, reply->
   srvexec_status = c.srvexec_status,
   reply->original_error_code = c.original_error_code, reply->format_script = c.format_script, reply
   ->que_seq = c.que_seq,
   reply->recover_seq = c.recover_seq, reply->retry_attempts = c.retry_attempts
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
