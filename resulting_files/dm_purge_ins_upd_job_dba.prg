CREATE PROGRAM dm_purge_ins_upd_job:dba
 FREE SET reply
 RECORD reply(
   1 job_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET history
 RECORD history(
   1 data[*]
     2 change_type = vc
     2 old_value = f8
     2 new_value = f8
     2 token_name = vc
 )
 DECLARE token_cnt = i4
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 DECLARE v_job_id = f8
 IF ((request->job_id=0))
  SELECT INTO "nl:"
   new_job = seq(dm_clinical_seq,nextval)
   FROM dual
   DETAIL
    v_job_id = new_job
   WITH nocounter
  ;end select
 ELSE
  SET v_job_id = request->job_id
  SELECT INTO "nl:"
   d.active_flag, d.purge_flag, d.max_rows
   FROM dm_purge_job d
   WHERE d.job_id=v_job_id
   HEAD REPORT
    cnt = 0
   DETAIL
    IF ( NOT ((d.active_flag=request->active_flag)))
     cnt = (cnt+ 1), stat = alterlist(history->data,cnt), history->data[cnt].change_type =
     "ACTIVE_FLAG",
     history->data[cnt].old_value = d.active_flag, history->data[cnt].new_value = request->
     active_flag
    ENDIF
    IF ( NOT ((d.purge_flag=request->purge_flag)))
     cnt = (cnt+ 1), stat = alterlist(history->data,cnt), history->data[cnt].change_type =
     "PURGE_FLAG",
     history->data[cnt].old_value = d.purge_flag, history->data[cnt].new_value = request->purge_flag
    ENDIF
    IF ( NOT ((d.max_rows=request->max_rows)))
     cnt = (cnt+ 1), stat = alterlist(history->data,cnt), history->data[cnt].change_type = "MAX_ROWS",
     history->data[cnt].old_value = d.max_rows, history->data[cnt].new_value = request->max_rows
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.token_str, d.value
   FROM dm_purge_job_token d
   WHERE d.job_id=v_job_id
   HEAD REPORT
    cnt = size(history->data,5)
   DETAIL
    token_cnt = locateval(token_cnt,1,size(request->tokens,5),d.token_str,request->tokens[token_cnt].
     token_str)
    IF (token_cnt > 0
     AND  NOT ((d.value=request->tokens[token_cnt].value)))
     cnt = (cnt+ 1), stat = alterlist(history->data,cnt), history->data[cnt].change_type = "TOKEN",
     history->data[cnt].old_value = cnvtreal(d.value), history->data[cnt].new_value = cnvtreal(
      request->tokens[token_cnt].value), history->data[cnt].token_name = request->tokens[token_cnt].
     token_str
    ENDIF
   WITH nocounter
  ;end select
  DELETE  FROM dm_purge_job_token pjt
   WHERE (pjt.job_id=request->job_id)
  ;end delete
 ENDIF
 SET reply->job_id = v_job_id
 IF ((request->job_id > 0))
  UPDATE  FROM dm_purge_job pj
   SET pj.template_nbr = request->template_nbr, pj.max_rows = request->max_rows, pj.purge_flag =
    request->purge_flag,
    pj.active_flag = request->active_flag, pj.updt_task = reqinfo->updt_task, pj.updt_id = reqinfo->
    updt_id,
    pj.updt_applctx = reqinfo->updt_applctx, pj.updt_dt_tm = cnvtdatetime(curdate,curtime3), pj
    .updt_cnt = (pj.updt_cnt+ 1)
   WHERE pj.job_id=v_job_id
   WITH nocounter
  ;end update
 ENDIF
 IF (((curqual=0) OR ((request->job_id=0))) )
  INSERT  FROM dm_purge_job pj
   SET pj.job_id = v_job_id, pj.template_nbr = request->template_nbr, pj.max_rows = request->max_rows,
    pj.purge_flag = request->purge_flag, pj.active_flag = request->active_flag, pj.updt_task =
    reqinfo->updt_task,
    pj.updt_id = reqinfo->updt_id, pj.updt_applctx = reqinfo->updt_applctx, pj.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pj.updt_cnt = 0
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   GO TO exit_program
  ENDIF
 ENDIF
 IF (size(request->tokens,5) > 0)
  INSERT  FROM dm_purge_job_token pjt,
    (dummyt d1  WITH seq = value(size(request->tokens,5)))
   SET pjt.job_id = v_job_id, pjt.token_str = request->tokens[d1.seq].token_str, pjt.value = request
    ->tokens[d1.seq].value,
    pjt.updt_task = reqinfo->updt_task, pjt.updt_id = reqinfo->updt_id, pjt.updt_applctx = reqinfo->
    updt_applctx,
    pjt.updt_dt_tm = cnvtdatetime(curdate,curtime3), pjt.updt_cnt = 0
   PLAN (d1)
    JOIN (pjt)
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   GO TO exit_program
  ENDIF
 ENDIF
 IF (size(history->data,5) > 0)
  INSERT  FROM dm_purge_history dph,
    (dummyt d  WITH seq = size(history->data,5))
   SET dph.dm_purge_history_id = seq(dm_clinical_seq,nextval), dph.job_id = v_job_id, dph.change_type
     = history->data[d.seq].change_type,
    dph.token_str = history->data[d.seq].token_name, dph.old_value = history->data[d.seq].old_value,
    dph.new_value = history->data[d.seq].new_value,
    dph.updt_task = reqinfo->updt_task, dph.updt_id = reqinfo->updt_id, dph.updt_applctx = reqinfo->
    updt_applctx,
    dph.updt_dt_tm = cnvtdatetime(curdate,curtime3), dph.updt_cnt = 0
   PLAN (d)
    JOIN (dph)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   GO TO exit_program
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
#exit_program
END GO
