CREATE PROGRAM ce_implant_result_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_implant_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.item_id = evaluate2(
    IF ((request->lst[d.seq].item_id=- (1))) 0
    ELSE request->lst[d.seq].item_id
    ENDIF
    ), t.item_size = request->lst[d.seq].item_size,
   t.harvest_site = request->lst[d.seq].harvest_site, t.culture_ind = evaluate2(
    IF ((request->lst[d.seq].culture_ind_ind=1)) null
    ELSE request->lst[d.seq].culture_ind
    ENDIF
    ), t.tissue_graft_type_cd = evaluate2(
    IF ((request->lst[d.seq].tissue_graft_type_cd=- (1))) 0
    ELSE request->lst[d.seq].tissue_graft_type_cd
    ENDIF
    ),
   t.explant_reason_cd = evaluate2(
    IF ((request->lst[d.seq].explant_reason_cd=- (1))) 0
    ELSE request->lst[d.seq].explant_reason_cd
    ENDIF
    ), t.explant_disposition_cd = evaluate2(
    IF ((request->lst[d.seq].explant_disposition_cd=- (1))) 0
    ELSE request->lst[d.seq].explant_disposition_cd
    ENDIF
    ), t.reference_entity_id = evaluate2(
    IF ((request->lst[d.seq].reference_entity_id=- (1))) 0
    ELSE request->lst[d.seq].reference_entity_id
    ENDIF
    ),
   t.reference_entity_name = request->lst[d.seq].reference_entity_name, t.manufacturer_cd = evaluate2
   (
    IF ((request->lst[d.seq].manufacturer_cd=- (1))) 0
    ELSE request->lst[d.seq].manufacturer_cd
    ENDIF
    ), t.manufacturer_ft = request->lst[d.seq].manufacturer_ft,
   t.model_nbr = request->lst[d.seq].model_nbr, t.lot_nbr = request->lst[d.seq].lot_nbr, t
   .other_identifier = request->lst[d.seq].other_identifier,
   t.expiration_dt_tm = evaluate2(
    IF ((request->lst[d.seq].expiration_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].expiration_dt_tm)
    ENDIF
    ), t.ecri_code = request->lst[d.seq].ecri_code, t.batch_nbr = request->lst[d.seq].batch_nbr,
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
