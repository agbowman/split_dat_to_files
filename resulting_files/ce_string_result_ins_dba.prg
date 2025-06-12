CREATE PROGRAM ce_string_result_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_string_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.string_result_text = request->lst[d.seq].string_result_text, t.string_result_format_cd =
   evaluate2(
    IF ((request->lst[d.seq].string_result_format_cd=- (1))) 0
    ELSE request->lst[d.seq].string_result_format_cd
    ENDIF
    ),
   t.equation_id = evaluate2(
    IF ((request->lst[d.seq].equation_id=- (1))) 0
    ELSE request->lst[d.seq].equation_id
    ENDIF
    ), t.last_norm_dt_tm = evaluate2(
    IF ((request->lst[d.seq].last_norm_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].last_norm_dt_tm)
    ENDIF
    ), t.unit_of_measure_cd = evaluate2(
    IF ((request->lst[d.seq].unit_of_measure_cd=- (1))) 0
    ELSE request->lst[d.seq].unit_of_measure_cd
    ENDIF
    ),
   t.feasible_ind = evaluate2(
    IF ((request->lst[d.seq].feasible_ind_ind=1)) null
    ELSE request->lst[d.seq].feasible_ind
    ENDIF
    ), t.inaccurate_ind = evaluate2(
    IF ((request->lst[d.seq].inaccurate_ind_ind=1)) null
    ELSE request->lst[d.seq].inaccurate_ind
    ENDIF
    ), t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ),
   t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ), t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm), t.updt_task = request->lst[d
   .seq].updt_task,
   t.updt_id = request->lst[d.seq].updt_id, t.updt_cnt = request->lst[d.seq].updt_cnt, t.updt_applctx
    = request->lst[d.seq].updt_applctx,
   t.calculation_equation = request->lst[d.seq].calculation_equation, t.string_long_text_id = request
   ->lst[d.seq].string_long_text_id
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
