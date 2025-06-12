CREATE PROGRAM atr_add_req_proc:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 INSERT  FROM request_processing r,
   (dummyt d  WITH seq = value(number_to_add))
  SET r.request_number = request->request_number, r.target_request_number = request->qual[d.seq].
   target_request_number, r.sequence = request->qual[d.seq].sequence,
   r.format_script = request->qual[d.seq].format_script, r.destination_step_id = request->qual[d.seq]
   .destination_step_id, r.service = request->qual[d.seq].service,
   r.active_ind = request->qual[d.seq].active_ind, r.forward_override_ind = request->qual[d.seq].
   forward_override_ind, r.reprocess_reply_ind = request->qual[d.seq].reprocess_reply_ind,
   r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->
   updt_id,
   r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (r)
  WITH nocounter
 ;end insert
 IF (curqual=number_to_add)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
