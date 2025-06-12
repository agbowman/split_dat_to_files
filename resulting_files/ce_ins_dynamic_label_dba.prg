CREATE PROGRAM ce_ins_dynamic_label:dba
 DECLARE request_size = i4 WITH constant(size(request->request_list,5))
 DECLARE current_time = dq8 WITH constant(cnvtdatetime(sysdate))
 DECLARE cnt = i4 WITH noconstant(0)
 SET stat = alterlist(reply->reply_list,request_size)
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 INSERT  FROM ce_dynamic_label t,
   (dummyt d  WITH seq = value(request_size))
  SET t.ce_dynamic_label_id = request->request_list[d.seq].ce_dynamic_label_id, t
   .prev_dynamic_label_id = request->request_list[d.seq].prev_dynamic_label_id, t.label_template_id
    = request->request_list[d.seq].label_template_id,
   t.label_name = request->request_list[d.seq].label_name, t.label_prsnl_id = request->request_list[d
   .seq].label_prsnl_id, t.label_status_cd = request->request_list[d.seq].label_status_cd,
   t.person_id = request->request_list[d.seq].person_id, t.result_set_id = request->request_list[d
   .seq].result_set_id, t.label_seq_nbr = request->request_list[d.seq].label_seq_nbr,
   t.valid_from_dt_tm = cnvtdatetimeutc(current_time), t.valid_until_dt_tm = cnvtdatetimeutc(
    "31-DEC-2100 00:00:00"), t.updt_dt_tm = cnvtdatetimeutc(current_time),
   t.create_dt_tm = cnvtdatetimeutc(current_time), t.updt_task = reqinfo->updt_task, t.updt_id =
   reqinfo->updt_id,
   t.updt_applctx = reqinfo->updt_applctx, reply->reply_list[d.seq].ce_dynamic_label_id = request->
   request_list[d.seq].ce_dynamic_label_id, reply->reply_list[d.seq].valid_from_dt_tm =
   cnvtdatetimeutc(current_time)
  PLAN (d)
   JOIN (t)
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
