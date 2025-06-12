CREATE PROGRAM ce_event_note_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_event_note t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.ce_event_note_id = evaluate2(
    IF ((request->lst[d.seq].ce_event_note_id=- (1))) 0
    ELSE request->lst[d.seq].ce_event_note_id
    ENDIF
    ), t.event_note_id = evaluate2(
    IF ((request->lst[d.seq].event_note_id=- (1))) 0
    ELSE request->lst[d.seq].event_note_id
    ENDIF
    ), t.long_text_id = evaluate2(
    IF ((request->lst[d.seq].long_text_id=- (1))) 0
    ELSE request->lst[d.seq].long_text_id
    ENDIF
    ),
   t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.note_type_cd = evaluate2(
    IF ((request->lst[d.seq].note_type_cd=- (1))) 0
    ELSE request->lst[d.seq].note_type_cd
    ENDIF
    ), t.note_format_cd = evaluate2(
    IF ((request->lst[d.seq].note_format_cd=- (1))) 0
    ELSE request->lst[d.seq].note_format_cd
    ENDIF
    ),
   t.entry_method_cd = evaluate2(
    IF ((request->lst[d.seq].entry_method_cd=- (1))) 0
    ELSE request->lst[d.seq].entry_method_cd
    ENDIF
    ), t.note_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].note_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].note_prsnl_id
    ENDIF
    ), t.note_dt_tm = evaluate2(
    IF ((request->lst[d.seq].note_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].note_dt_tm)
    ENDIF
    ),
   t.note_tz = request->lst[d.seq].note_tz, t.record_status_cd = evaluate2(
    IF ((request->lst[d.seq].record_status_cd=- (1))) 0
    ELSE request->lst[d.seq].record_status_cd
    ENDIF
    ), t.compression_cd = evaluate2(
    IF ((request->lst[d.seq].compression_cd=- (1))) 0
    ELSE request->lst[d.seq].compression_cd
    ENDIF
    ),
   t.checksum = evaluate2(
    IF ((request->lst[d.seq].checksum_ind=1)) null
    ELSE request->lst[d.seq].checksum
    ENDIF
    ), t.non_chartable_flag = request->lst[d.seq].non_chartable_flag, t.importance_flag = request->
   lst[d.seq].importance_flag,
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
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
