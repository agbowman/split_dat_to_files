CREATE PROGRAM atr_get_req_proc:dba
 RECORD reply(
   1 request_number = i4
   1 description = vc
   1 prologue_script = vc
   1 epilogue_script = vc
   1 write_to_queue_ind = i2
   1 updt_cnt = i4
   1 request_module = vc
   1 active_ind = i2
   1 active_dt_tm = dq8
   1 inactive_dt_tm = dq8
   1 text = vc
   1 processclass = i4
   1 qual[*]
     2 sequence = i4
     2 target_request_number = i4
     2 target_request_desc = vc
     2 format_script = vc
     2 service = vc
     2 forward_override_ind = i2
     2 reprocess_reply_ind = i2
     2 active_ind = i2
     2 destination_step_id = f8
     2 updt_cnt = i4
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
  r.request_number
  FROM request r
  WHERE (r.request_number=request->request_number)
  DETAIL
   reply->request_number = r.request_number, reply->description = r.description, reply->
   prologue_script = r.prolog_script,
   reply->epilogue_script = r.epilog_script, reply->write_to_queue_ind = r.write_to_que_ind, reply->
   updt_cnt = r.updt_cnt,
   reply->request_module = r.request_name, reply->active_ind = r.active_ind, reply->active_dt_tm = r
   .active_dt_tm,
   reply->inactive_dt_tm = r.inactive_dt_tm, reply->text = r.text, reply->processclass = r
   .processclass
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  rp.request_number, r.request_number
  FROM request_processing rp,
   (dummyt d  WITH seq = 1),
   request r
  PLAN (rp
   WHERE (rp.request_number=request->request_number))
   JOIN (d)
   JOIN (r
   WHERE r.request_number=rp.target_request_number)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].sequence = rp.sequence, reply->qual[count1].target_request_number = rp
   .target_request_number, reply->qual[count1].target_request_desc = r.description,
   reply->qual[count1].format_script = rp.format_script, reply->qual[count1].service = rp.service,
   reply->qual[count1].forward_override_ind = rp.forward_override_ind,
   reply->qual[count1].reprocess_reply_ind = rp.reprocess_reply_ind, reply->qual[count1].active_ind
    = rp.active_ind, reply->qual[count1].destination_step_id = rp.destination_step_id,
   reply->qual[count1].updt_cnt = rp.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
END GO
