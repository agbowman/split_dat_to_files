CREATE PROGRAM ce_product_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_product t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.product_id = evaluate2(
    IF ((request->lst[d.seq].product_id=- (1))) 0
    ELSE request->lst[d.seq].product_id
    ENDIF
    ), t.product_nbr = request->lst[d.seq].product_nbr,
   t.product_cd = evaluate2(
    IF ((request->lst[d.seq].product_cd=- (1))) 0
    ELSE request->lst[d.seq].product_cd
    ENDIF
    ), t.abo_cd = evaluate2(
    IF ((request->lst[d.seq].abo_cd=- (1))) 0
    ELSE request->lst[d.seq].abo_cd
    ENDIF
    ), t.rh_cd = evaluate2(
    IF ((request->lst[d.seq].rh_cd=- (1))) 0
    ELSE request->lst[d.seq].rh_cd
    ENDIF
    ),
   t.product_status_cd = evaluate2(
    IF ((request->lst[d.seq].product_status_cd=- (1))) 0
    ELSE request->lst[d.seq].product_status_cd
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
   t.updt_cnt = request->lst[d.seq].updt_cnt, t.updt_applctx = request->lst[d.seq].updt_applctx, t
   .product_volume = request->lst[d.seq].product_volume,
   t.product_volume_unit_cd = request->lst[d.seq].product_volume_unit_cd, t.product_quantity =
   request->lst[d.seq].product_quantity, t.product_quantity_unit_cd = request->lst[d.seq].
   product_quantity_unit_cd,
   t.product_strength = request->lst[d.seq].product_strength, t.product_strength_unit_cd = request->
   lst[d.seq].product_strength_unit_cd
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
