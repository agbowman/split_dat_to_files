CREATE PROGRAM ce_io_total_result_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 SET error_msg = fillstring(132," ")
 SET error_code = 0
 INSERT  FROM ce_io_total_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.ce_io_total_result_id = request->lst[d.seq].ce_io_total_result_id, t.io_total_definition_id
    = request->lst[d.seq].io_total_definition_id, t.event_id = request->lst[d.seq].event_id,
   t.encntr_id = request->lst[d.seq].encntr_id, t.encntr_focused_ind = request->lst[d.seq].
   encntr_focused_ind, t.person_id = request->lst[d.seq].person_id,
   t.io_total_start_dt_tm = cnvtdatetimeutc(request->lst[d.seq].io_total_start_dt_tm), t
   .io_total_end_dt_tm = cnvtdatetimeutc(request->lst[d.seq].io_total_end_dt_tm), t.io_total_value =
   request->lst[d.seq].io_total_value,
   t.io_total_result_val = request->lst[d.seq].io_total_result_val, t.io_total_unit_cd = request->
   lst[d.seq].io_total_unit_cd, t.suspect_flag = request->lst[d.seq].suspect_flag,
   t.last_io_result_clinsig_dt_tm = cnvtdatetimeutc(request->lst[d.seq].last_io_result_clinsig_dt_tm),
   t.valid_from_dt_tm = cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm), t.valid_until_dt_tm =
   cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm),
   t.updt_id = request->lst[d.seq].updt_id, t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].
    updt_dt_tm), t.updt_task = request->lst[d.seq].updt_task,
   t.updt_applctx = request->lst[d.seq].updt_applctx, t.updt_cnt = request->lst[d.seq].updt_cnt
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
