CREATE PROGRAM ce_suscep_footnote_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_suscep_footnote t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.ce_suscep_footnote_id = evaluate2(
    IF ((request->lst[d.seq].ce_suscep_footnote_id=- (1))) 0
    ELSE request->lst[d.seq].ce_suscep_footnote_id
    ENDIF
    ), t.suscep_footnote_id = evaluate2(
    IF ((request->lst[d.seq].suscep_footnote_id=- (1))) 0
    ELSE request->lst[d.seq].suscep_footnote_id
    ENDIF
    ),
   t.checksum = evaluate2(
    IF ((request->lst[d.seq].checksum_ind=1)) null
    ELSE request->lst[d.seq].checksum
    ENDIF
    ), t.compression_cd = evaluate2(
    IF ((request->lst[d.seq].compression_cd=- (1))) 0
    ELSE request->lst[d.seq].compression_cd
    ENDIF
    ), t.format_cd = evaluate2(
    IF ((request->lst[d.seq].format_cd=- (1))) 0
    ELSE request->lst[d.seq].format_cd
    ENDIF
    ),
   t.contributor_system_cd = evaluate2(
    IF ((request->lst[d.seq].contributor_system_cd=- (1))) 0
    ELSE request->lst[d.seq].contributor_system_cd
    ENDIF
    ), t.blob_length = evaluate2(
    IF ((request->lst[d.seq].blob_length_ind=1)) null
    ELSE request->lst[d.seq].blob_length
    ENDIF
    ), t.reference_nbr = request->lst[d.seq].reference_nbr,
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
   WHERE (t.ce_suscep_footnote_id=request->lst[d.seq].ce_suscep_footnote_id)
    AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
