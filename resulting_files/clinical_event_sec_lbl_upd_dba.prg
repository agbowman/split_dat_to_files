CREATE PROGRAM clinical_event_sec_lbl_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM clinical_event_sec_lbl t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.clinical_event_sec_lbl_id = request->lst[d.seq].clinical_event_sec_lbl_id, t.event_id =
   request->lst[d.seq].event_id, t.sensitivity_reason_cd = request->lst[d.seq].sensitivity_reason_cd,
   t.created_by_prsnl_id = request->lst[d.seq].created_by_prsnl_id, t.beg_effective_dt_tm = evaluate2
   (
    IF ((request->lst[d.seq].beg_effective_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].beg_effective_dt_tm)
    ENDIF
    ), t.end_effective_dt_tm = evaluate2(
    IF ((request->lst[d.seq].end_effective_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].end_effective_dt_tm)
    ENDIF
    ),
   t.active_ind = request->lst[d.seq].active_ind, t.action_prsnl_id = request->lst[d.seq].
   action_prsnl_id, t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm),
   t.updt_id = request->lst[d.seq].updt_id, t.updt_task = request->lst[d.seq].updt_task, t.updt_cnt
    = request->lst[d.seq].updt_cnt,
   t.updt_applctx = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.clinical_event_sec_lbl_id=request->lst[d.seq].clinical_event_sec_lbl_id))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
