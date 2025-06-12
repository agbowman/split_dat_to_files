CREATE PROGRAM atr_chg_req_proc:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD status(
   1 qual[*]
     2 status = i2
 )
 SET reply->status_data.status = "F"
 SET number_to_chg = size(request->qual,5)
 SET count_match = 0
 SELECT INTO "nl:"
  r.sequence
  FROM request_processing r,
   (dummyt d  WITH seq = value(number_to_chg))
  PLAN (d)
   JOIN (r
   WHERE (r.request_number=request->request_number)
    AND (r.sequence=request->qual[d.seq].sequence))
  DETAIL
   IF ((r.updt_cnt=request->qual[d.seq].updt_cnt))
    count_match += 1
   ENDIF
  WITH nocounter, forupdate(r)
 ;end select
 IF (count_match != number_to_chg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM request_processing r,
   (dummyt d  WITH seq = value(number_to_chg))
  SET r.format_script = request->qual[d.seq].format_script, r.service = request->qual[d.seq].service,
   r.forward_override_ind = request->qual[d.seq].forward_override_ind,
   r.reprocess_reply_ind = request->qual[d.seq].reprocess_reply_ind, r.active_ind = request->qual[d
   .seq].active_ind, r.destination_step_id = request->qual[d.seq].destination_step_id,
   r.target_request_number = request->qual[d.seq].target_request_number, r.updt_dt_tm = cnvtdatetime(
    sysdate), r.updt_task = reqinfo->updt_task,
   r.updt_cnt = (r.updt_cnt+ 1), r.updt_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (r
   WHERE (r.request_number=request->request_number)
    AND (r.sequence=request->qual[d.seq].sequence))
  WITH nocounter
 ;end update
 IF (curqual=number_to_chg)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
