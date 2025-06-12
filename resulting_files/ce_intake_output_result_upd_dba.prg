CREATE PROGRAM ce_intake_output_result_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_intake_output_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.ce_io_result_id = request->lst[d.seq].ce_io_result_id, t.io_result_id = request->lst[d.seq].
   io_result_id, t.event_id = request->lst[d.seq].event_id,
   t.person_id = request->lst[d.seq].person_id, t.encntr_id = request->lst[d.seq].encntr_id, t
   .io_start_dt_tm = evaluate2(
    IF ((request->lst[d.seq].io_start_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].io_start_dt_tm)
    ENDIF
    ),
   t.io_end_dt_tm = evaluate2(
    IF ((request->lst[d.seq].io_end_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].io_end_dt_tm)
    ENDIF
    ), t.io_type_flag = request->lst[d.seq].io_type_flag, t.io_volume = request->lst[d.seq].io_volume,
   t.io_status_cd = evaluate2(
    IF ((request->lst[d.seq].io_status_cd=- (1))) 0
    ELSE request->lst[d.seq].io_status_cd
    ENDIF
    ), t.reference_event_id = request->lst[d.seq].reference_event_id, t.reference_event_cd = request
   ->lst[d.seq].reference_event_cd,
   t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ), t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ), t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm),
   t.updt_task = request->lst[d.seq].updt_task, t.updt_id = request->lst[d.seq].updt_id, t.updt_cnt
    = request->lst[d.seq].updt_cnt,
   t.updt_applctx = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.ce_io_result_id=request->lst[d.seq].ce_io_result_id))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
