CREATE PROGRAM ce_ins_index_blob_list:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM srch_index_queue t,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET t.event_id = request->request_list[d.seq].event_id, t.parent_event_id = request->request_list[d
   .seq].parent_event_id, t.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm)
  PLAN (d)
   JOIN (t)
  WITH counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
