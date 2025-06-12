CREATE PROGRAM ce_specimen_coll_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_specimen_coll t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.specimen_id = evaluate2(
    IF ((request->lst[d.seq].specimen_id=- (1))) 0
    ELSE request->lst[d.seq].specimen_id
    ENDIF
    ), t.container_id = evaluate2(
    IF ((request->lst[d.seq].container_id=- (1))) 0
    ELSE request->lst[d.seq].container_id
    ENDIF
    ),
   t.container_type_cd = evaluate2(
    IF ((request->lst[d.seq].container_type_cd=- (1))) 0
    ELSE request->lst[d.seq].container_type_cd
    ENDIF
    ), t.specimen_status_cd = evaluate2(
    IF ((request->lst[d.seq].specimen_status_cd=- (1))) 0
    ELSE request->lst[d.seq].specimen_status_cd
    ENDIF
    ), t.collect_dt_tm = evaluate2(
    IF ((request->lst[d.seq].collect_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].collect_dt_tm)
    ENDIF
    ),
   t.collect_tz = request->lst[d.seq].collect_tz, t.collect_method_cd = evaluate2(
    IF ((request->lst[d.seq].collect_method_cd=- (1))) 0
    ELSE request->lst[d.seq].collect_method_cd
    ENDIF
    ), t.collect_loc_cd = evaluate2(
    IF ((request->lst[d.seq].collect_loc_cd=- (1))) 0
    ELSE request->lst[d.seq].collect_loc_cd
    ENDIF
    ),
   t.collect_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].collect_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].collect_prsnl_id
    ENDIF
    ), t.collect_volume = evaluate2(
    IF ((request->lst[d.seq].collect_volume_ind=1)) null
    ELSE request->lst[d.seq].collect_volume
    ENDIF
    ), t.collect_unit_cd = evaluate2(
    IF ((request->lst[d.seq].collect_unit_cd=- (1))) 0
    ELSE request->lst[d.seq].collect_unit_cd
    ENDIF
    ),
   t.collect_priority_cd = evaluate2(
    IF ((request->lst[d.seq].collect_priority_cd=- (1))) 0
    ELSE request->lst[d.seq].collect_priority_cd
    ENDIF
    ), t.source_type_cd = evaluate2(
    IF ((request->lst[d.seq].source_type_cd=- (1))) 0
    ELSE request->lst[d.seq].source_type_cd
    ENDIF
    ), t.source_text = request->lst[d.seq].source_text,
   t.body_site_cd = evaluate2(
    IF ((request->lst[d.seq].body_site_cd=- (1))) 0
    ELSE request->lst[d.seq].body_site_cd
    ENDIF
    ), t.danger_cd = evaluate2(
    IF ((request->lst[d.seq].danger_cd=- (1))) 0
    ELSE request->lst[d.seq].danger_cd
    ENDIF
    ), t.positive_ind = evaluate2(
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
   t.updt_applctx = request->lst[d.seq].updt_applctx, t.recvd_dt_tm = evaluate2(
    IF ((request->lst[d.seq].recvd_dt_tm > 0)) cnvtdatetimeutc(request->lst[d.seq].recvd_dt_tm)
    ELSE null
    ENDIF
    ), t.recvd_tz = request->lst[d.seq].recvd_tz
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
