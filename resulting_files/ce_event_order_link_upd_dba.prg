CREATE PROGRAM ce_event_order_link_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_event_order_link t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.order_id = evaluate2(
    IF ((request->lst[d.seq].order_id=- (1))) 0
    ELSE request->lst[d.seq].order_id
    ENDIF
    ), t.order_action_sequence = evaluate2(
    IF ((request->lst[d.seq].order_action_sequence=- (1))) 0
    ELSE request->lst[d.seq].order_action_sequence
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
   t.updt_applctx = request->lst[d.seq].updt_applctx, t.parent_order_ident = evaluate2(
    IF ((request->lst[d.seq].parent_order_ident=- (1))) 0
    ELSE request->lst[d.seq].parent_order_ident
    ENDIF
    ), t.event_end_dt_tm = cnvtdatetimeutc(request->lst[d.seq].event_end_dt_tm),
   t.person_id = evaluate2(
    IF ((request->lst[d.seq].person_id=- (1))) 0
    ELSE request->lst[d.seq].person_id
    ENDIF
    ), t.encntr_id = evaluate2(
    IF ((request->lst[d.seq].encntr_id=- (1))) 0
    ELSE request->lst[d.seq].encntr_id
    ENDIF
    ), t.catalog_type_cd = evaluate2(
    IF ((request->lst[d.seq].catalog_type_cd=- (1))) 0
    ELSE request->lst[d.seq].catalog_type_cd
    ENDIF
    ),
   t.ce_event_order_link_id = request->lst[d.seq].ce_event_order_link_id
  PLAN (d)
   JOIN (t
   WHERE (t.event_id=request->lst[d.seq].event_id)
    AND (t.order_id=request->lst[d.seq].order_id)
    AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
