CREATE PROGRAM ce_blob_result_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_blob_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.succession_type_cd = evaluate2(
    IF ((request->lst[d.seq].succession_type_cd=- (1))) 0
    ELSE request->lst[d.seq].succession_type_cd
    ENDIF
    ), t.sub_series_ref_nbr = request->lst[d.seq].sub_series_ref_nbr,
   t.storage_cd = evaluate2(
    IF ((request->lst[d.seq].storage_cd=- (1))) 0
    ELSE request->lst[d.seq].storage_cd
    ENDIF
    ), t.format_cd = evaluate2(
    IF ((request->lst[d.seq].format_cd=- (1))) 0
    ELSE request->lst[d.seq].format_cd
    ENDIF
    ), t.device_cd = evaluate2(
    IF ((request->lst[d.seq].device_cd=- (1))) 0
    ELSE request->lst[d.seq].device_cd
    ENDIF
    ),
   t.blob_handle = request->lst[d.seq].blob_handle, t.blob_attributes = request->lst[d.seq].
   blob_attributes, t.max_sequence_nbr = evaluate2(
    IF ((request->lst[d.seq].max_sequence_nbr_ind=1)) null
    ELSE request->lst[d.seq].max_sequence_nbr
    ENDIF
    ),
   t.checksum = evaluate2(
    IF ((request->lst[d.seq].checksum_ind=1)) null
    ELSE request->lst[d.seq].checksum
    ENDIF
    ), t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ), t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ),
   t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm), t.updt_task = request->lst[d.seq].
   updt_task, t.updt_id = request->lst[d.seq].updt_id,
   t.updt_cnt = request->lst[d.seq].updt_cnt, t.updt_applctx = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.event_id=request->lst[d.seq].event_id)
    AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
