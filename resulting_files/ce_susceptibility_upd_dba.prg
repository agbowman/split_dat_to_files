CREATE PROGRAM ce_susceptibility_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_susceptibility t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.micro_seq_nbr = evaluate2(
    IF ((request->lst[d.seq].micro_seq_nbr_ind=1)) null
    ELSE request->lst[d.seq].micro_seq_nbr
    ENDIF
    ), t.suscep_seq_nbr = evaluate2(
    IF ((request->lst[d.seq].suscep_seq_nbr_ind=1)) null
    ELSE request->lst[d.seq].suscep_seq_nbr
    ENDIF
    ),
   t.susceptibility_test_cd = evaluate2(
    IF ((request->lst[d.seq].susceptibility_test_cd=- (1))) 0
    ELSE request->lst[d.seq].susceptibility_test_cd
    ENDIF
    ), t.detail_susceptibility_cd = evaluate2(
    IF ((request->lst[d.seq].detail_susceptibility_cd=- (1))) 0
    ELSE request->lst[d.seq].detail_susceptibility_cd
    ENDIF
    ), t.panel_antibiotic_cd = evaluate2(
    IF ((request->lst[d.seq].panel_antibiotic_cd=- (1))) 0
    ELSE request->lst[d.seq].panel_antibiotic_cd
    ENDIF
    ),
   t.antibiotic_cd = evaluate2(
    IF ((request->lst[d.seq].antibiotic_cd=- (1))) 0
    ELSE request->lst[d.seq].antibiotic_cd
    ENDIF
    ), t.diluent_volume = evaluate2(
    IF ((request->lst[d.seq].diluent_volume_ind=1)) null
    ELSE request->lst[d.seq].diluent_volume
    ENDIF
    ), t.result_cd = evaluate2(
    IF ((request->lst[d.seq].result_cd=- (1))) 0
    ELSE request->lst[d.seq].result_cd
    ENDIF
    ),
   t.result_text_value = request->lst[d.seq].result_text_value, t.result_numeric_value = evaluate2(
    IF ((request->lst[d.seq].result_numeric_value_ind=1)) null
    ELSE request->lst[d.seq].result_numeric_value
    ENDIF
    ), t.result_unit_cd = evaluate2(
    IF ((request->lst[d.seq].result_unit_cd=- (1))) 0
    ELSE request->lst[d.seq].result_unit_cd
    ENDIF
    ),
   t.result_dt_tm = evaluate2(
    IF ((request->lst[d.seq].result_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].result_dt_tm)
    ENDIF
    ), t.result_tz = request->lst[d.seq].result_tz, t.result_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].result_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].result_prsnl_id
    ENDIF
    ),
   t.susceptibility_status_cd = evaluate2(
    IF ((request->lst[d.seq].susceptibility_status_cd=- (1))) 0
    ELSE request->lst[d.seq].susceptibility_status_cd
    ENDIF
    ), t.abnormal_flag = evaluate2(
    IF ((request->lst[d.seq].abnormal_flag_ind=1)) null
    ELSE request->lst[d.seq].abnormal_flag
    ENDIF
    ), t.chartable_flag = evaluate2(
    IF ((request->lst[d.seq].chartable_flag_ind=1)) null
    ELSE request->lst[d.seq].chartable_flag
    ENDIF
    ),
   t.nomenclature_id = evaluate2(
    IF ((request->lst[d.seq].nomenclature_id=- (1))) 0
    ELSE request->lst[d.seq].nomenclature_id
    ENDIF
    ), t.antibiotic_note = request->lst[d.seq].antibiotic_note, t.valid_from_dt_tm = evaluate2(
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
    = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.event_id=request->lst[d.seq].event_id)
    AND (t.micro_seq_nbr=request->lst[d.seq].micro_seq_nbr)
    AND (t.suscep_seq_nbr=request->lst[d.seq].suscep_seq_nbr)
    AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
