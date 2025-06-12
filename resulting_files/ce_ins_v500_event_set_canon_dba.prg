CREATE PROGRAM ce_ins_v500_event_set_canon:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 num_inserted = i4
    1 error_code = f8
    1 error_msg = vc
  )
 ENDIF
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE insertintocanonsnp(null) = null
 DECLARE insertintocanon(null) = null
 IF ((request->use_snapshot_tables_ind=1))
  CALL insertintocanonsnp(null)
 ELSE
  CALL insertintocanon(null)
 ENDIF
 SUBROUTINE insertintocanonsnp(null)
   INSERT  FROM kia_event_set_canon_snp t,
     (dummyt d  WITH seq = value(size(request->request_list,5)))
    SET t.event_set_cd =
     IF ((request->request_list[d.seq].event_set_cd=- (1))) 0
     ELSE request->request_list[d.seq].event_set_cd
     ENDIF
     , t.parent_event_set_cd =
     IF ((request->request_list[d.seq].parent_event_set_cd=- (1))) 0
     ELSE request->request_list[d.seq].parent_event_set_cd
     ENDIF
     , t.event_set_status_cd =
     IF ((request->request_list[d.seq].event_set_status_cd=- (1))) 0
     ELSE request->request_list[d.seq].event_set_status_cd
     ENDIF
     ,
     t.updt_id = request->request_list[d.seq].updt_id, t.updt_dt_tm = cnvtdatetimeutc(request->
      request_list[d.seq].updt_dt_tm), t.event_set_collating_seq = request->request_list[d.seq].
     event_set_collating_seq,
     t.updt_task = request->request_list[d.seq].updt_task, t.updt_cnt = request->request_list[d.seq].
     updt_cnt, t.updt_applctx = request->request_list[d.seq].updt_applctx,
     t.event_set_explode_ind = request->request_list[d.seq].event_set_explode_ind
    PLAN (d)
     JOIN (t)
    WITH counter
   ;end insert
 END ;Subroutine
 SUBROUTINE insertintocanon(null)
   INSERT  FROM v500_event_set_canon t,
     (dummyt d  WITH seq = value(size(request->request_list,5)))
    SET t.event_set_cd =
     IF ((request->request_list[d.seq].event_set_cd=- (1))) 0
     ELSE request->request_list[d.seq].event_set_cd
     ENDIF
     , t.parent_event_set_cd =
     IF ((request->request_list[d.seq].parent_event_set_cd=- (1))) 0
     ELSE request->request_list[d.seq].parent_event_set_cd
     ENDIF
     , t.event_set_status_cd =
     IF ((request->request_list[d.seq].event_set_status_cd=- (1))) 0
     ELSE request->request_list[d.seq].event_set_status_cd
     ENDIF
     ,
     t.updt_id = request->request_list[d.seq].updt_id, t.updt_dt_tm = cnvtdatetimeutc(request->
      request_list[d.seq].updt_dt_tm), t.event_set_collating_seq = request->request_list[d.seq].
     event_set_collating_seq,
     t.updt_task = request->request_list[d.seq].updt_task, t.updt_cnt = request->request_list[d.seq].
     updt_cnt, t.updt_applctx = request->request_list[d.seq].updt_applctx,
     t.event_set_explode_ind = request->request_list[d.seq].event_set_explode_ind
    PLAN (d)
     JOIN (t)
    WITH counter
   ;end insert
 END ;Subroutine
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = assign(validate(reqinfo->commit_ind),1)
END GO
