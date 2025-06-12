CREATE PROGRAM ce_microbiology_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_microbiology t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.micro_seq_nbr = evaluate2(
    IF ((request->lst[d.seq].micro_seq_nbr_ind=1)) null
    ELSE request->lst[d.seq].micro_seq_nbr
    ENDIF
    ), t.organism_cd = evaluate2(
    IF ((request->lst[d.seq].organism_cd=- (1))) 0
    ELSE request->lst[d.seq].organism_cd
    ENDIF
    ),
   t.organism_occurrence_nbr = evaluate2(
    IF ((request->lst[d.seq].organism_occurrence_nbr_ind=1)) null
    ELSE request->lst[d.seq].organism_occurrence_nbr
    ENDIF
    ), t.organism_type_cd = evaluate2(
    IF ((request->lst[d.seq].organism_type_cd=- (1))) 0
    ELSE request->lst[d.seq].organism_type_cd
    ENDIF
    ), t.observation_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].observation_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].observation_prsnl_id
    ENDIF
    ),
   t.biotype = request->lst[d.seq].biotype, t.probability = request->lst[d.seq].probability, t
   .positive_ind = evaluate2(
    IF ((request->lst[d.seq].positive_ind_ind=1)) null
    ELSE request->lst[d.seq].positive_ind
    ENDIF
    ),
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
   WHERE (t.event_id=request->lst[d.seq].event_id)
    AND (t.micro_seq_nbr=request->lst[d.seq].micro_seq_nbr)
    AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
