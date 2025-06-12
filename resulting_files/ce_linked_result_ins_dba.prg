CREATE PROGRAM ce_linked_result_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_linked_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.linked_event_id = evaluate2(
    IF ((request->lst[d.seq].linked_event_id=- (1))) 0
    ELSE request->lst[d.seq].linked_event_id
    ENDIF
    ), t.order_id = evaluate2(
    IF ((request->lst[d.seq].order_id=- (1))) 0
    ELSE request->lst[d.seq].order_id
    ENDIF
    ),
   t.encntr_id = evaluate2(
    IF ((request->lst[d.seq].encntr_id=- (1))) 0
    ELSE request->lst[d.seq].encntr_id
    ENDIF
    ), t.accession_nbr = request->lst[d.seq].accession_nbr, t.contributor_system_cd = evaluate2(
    IF ((request->lst[d.seq].contributor_system_cd=- (1))) 0
    ELSE request->lst[d.seq].contributor_system_cd
    ENDIF
    ),
   t.reference_nbr = request->lst[d.seq].reference_nbr, t.event_class_cd = evaluate2(
    IF ((request->lst[d.seq].event_class_cd=- (1))) 0
    ELSE request->lst[d.seq].event_class_cd
    ENDIF
    ), t.series_ref_nbr = request->lst[d.seq].series_ref_nbr,
   t.sub_series_ref_nbr = request->lst[d.seq].sub_series_ref_nbr, t.succession_type_cd = evaluate2(
    IF ((request->lst[d.seq].succession_type_cd=- (1))) 0
    ELSE request->lst[d.seq].succession_type_cd
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
    = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
