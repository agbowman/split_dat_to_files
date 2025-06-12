CREATE PROGRAM dm_set_archive_dt_tm:dba
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_request->enc_cnt))
  PLAN (d)
  DETAIL
   dm_request->enc[d.seq].archive_dt_tm = datetimeadd(dm_request->enc[d.seq].encntr_complete_dt_tm,
    dm_request->aenccomplete_days)
  WITH nocounter
 ;end select
 UPDATE  FROM encounter e,
   (dummyt d  WITH seq = value(dm_request->enc_cnt))
  SET e.archive_dt_tm_est = cnvtdatetime(dm_request->enc[d.seq].archive_dt_tm), e
   .parent_ret_criteria_id = dm_request->parent_criteria_id, e.pa_current_status_cd = dm_pa_codes->
   action[1].set_arch_dt_tm_cd,
   e.pa_current_status_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id, e
   .updt_task = reqinfo->updt_task,
   e.updt_applctx = reqinfo->updt_applctx, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(
    curdate,curtime3)
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=dm_request->enc[d.seq].encntr_id))
  WITH nocounter
 ;end update
 IF ((curqual != dm_request->enc_cnt))
  SET reply->status_data.status = "F"
  SET dm_ecode = error(dm_cemsg,1)
  SET dm_emsg = "Could not update encounter table with purge/archive information"
  GO TO end_dm_set_archive_dt_tm
 ENDIF
#end_dm_set_archive_dt_tm
 IF ((reply->status_data.status="F"))
  ROLLBACK
  INSERT  FROM dm_archive_log a,
    (dummyt d  WITH seq = value(dm_request->enc_cnt))
   SET a.archive_log_id = seq(dm_archive_log_seq,nextval), a.encntr_id = dm_request->enc[d.seq].
    encntr_id, a.action_dt_tm = cnvtdatetime(curdate,curtime3),
    a.action_type_cd = dm_pa_codes->action[1].failed_set_arch_dt_tm_cd, a.active_ind = 1, a
    .parent_ret_criteria_id = dm_request->parent_criteria_id,
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.process_type = dm_request->
    process_type,
    a.error_msg = trim(dm_emsg), a.ccl_error_msg = trim(dm_cemsg)
   PLAN (d)
    JOIN (a
    WHERE (a.encntr_id=dm_request->enc[d.seq].encntr_id))
   WITH nocounter
  ;end insert
  COMMIT
  IF ((curqual != dm_request->enc_cnt))
   SET reply->status_data.status = "F"
   SET dm_ecode = error(dm_cemsg,1)
   SET dm_emsg = "Could not insert rows into dm_archive_log table"
  ENDIF
 ELSEIF ((reply->status_data.status="S"))
  INSERT  FROM dm_archive_log a,
    (dummyt d  WITH seq = value(dm_request->enc_cnt))
   SET a.archive_log_id = seq(dm_archive_log_seq,nextval), a.encntr_id = dm_request->enc[d.seq].
    encntr_id, a.action_dt_tm = cnvtdatetime(curdate,curtime3),
    a.action_type_cd = dm_pa_codes->action[1].set_arch_dt_tm_cd, a.next_action_dt_tm = cnvtdatetime(
     dm_request->enc[d.seq].archive_dt_tm), a.next_action_type_cd = dm_pa_codes->action[1].
    next_action_cd,
    a.active_ind = 1, a.parent_ret_criteria_id = dm_request->parent_criteria_id, a.updt_id = reqinfo
    ->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.process_type = dm_request->process_type
   PLAN (d)
    JOIN (a
    WHERE (a.encntr_id=dm_request->enc[d.seq].encntr_id))
   WITH nocounter
  ;end insert
  COMMIT
  IF ((curqual != dm_request->enc_cnt))
   SET reply->status_data.status = "F"
   SET dm_ecode = error(dm_cemsg,1)
   SET dm_emsg = "Could not insert rows into dm_archive_log table"
  ENDIF
 ENDIF
END GO
