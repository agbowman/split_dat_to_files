CREATE PROGRAM aps_chg_report_queue:dba
 RECORD reply(
   1 code_value = f8
   1 exception_data[1]
     2 report_queue_cd = f8
     2 report_queue_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET chg_updt_cnt[500] = 0
 SET error_cnt = 0
 SET count1 = 0
 IF ((request->qual[1].action="A"))
  SELECT INTO "nl:"
   next_seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->qual[1].report_queue_cd = cnvtreal(next_seq_nbr), reply->code_value = request->qual[1].
    report_queue_cd
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
   GO TO exit_script
  ENDIF
  INSERT  FROM code_value c
   SET c.code_value =
    IF ((request->qual[1].report_queue_cd=0)) null
    ELSE request->qual[1].report_queue_cd
    ENDIF
    , c.code_set = 1319, c.cdf_meaning = null,
    c.display = request->qual[1].report_queue_name, c.display_key = cnvtupper(cnvtalphanum(request->
      qual[1].report_queue_name)), c.description = request->qual[1].report_queue_name,
    c.data_status_cd = reqdata->data_status_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime),
    c.data_status_prsnl_id = reqinfo->updt_id,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
    ->updt_task,
    c.updt_applctx = reqinfo->updt_applctx, c.active_ind = 1, c.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","CODE_VALUE, 1319")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->qual[1].action="C"))
  SELECT INTO "nl:"
   c.*
   FROM code_value c
   WHERE c.code_set=1319
    AND (c.code_value=request->qual[1].report_queue_cd)
   DETAIL
    cur_updt_cnt = c.updt_cnt
   WITH forupdate(c)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CODE_VALUE, 1319")
   GO TO exit_script
  ENDIF
  IF ((request->qual[1].updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","CODE_VALUE, 1319")
   GO TO exit_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM code_value c
   SET c.display = request->qual[1].report_queue_name, c.display_key = cnvtupper(cnvtalphanum(request
      ->qual[1].report_queue_name)), c.description = request->qual[1].report_queue_name,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_cnt = cur_updt_cnt, c.updt_id = reqinfo->
    updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
   WHERE c.code_set=1319
    AND (c.code_value=request->qual[1].report_queue_cd)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE, 1319")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->qual[1].del_cnt > 0))
  DELETE  FROM report_queue_r rptq_r,
    (dummyt d  WITH seq = value(request->qual[1].del_cnt))
   SET rptq_r.seq = 1
   PLAN (d)
    JOIN (rptq_r
    WHERE (request->qual[1].report_queue_cd=rptq_r.report_queue_cd)
     AND (request->qual[1].del_qual[d.seq].report_id=rptq_r.report_id))
   WITH nocounter
  ;end delete
  IF ((curqual != request->qual[1].del_cnt))
   CALL handle_errors("DELETE","F","TABLE","REPORT_QUEUE_R")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->qual[1].add_cnt > 0))
  INSERT  FROM report_queue_r rptq_r,
    (dummyt d  WITH seq = value(request->qual[1].add_cnt))
   SET rptq_r.report_queue_cd = request->qual[1].report_queue_cd, rptq_r.report_id = request->qual[1]
    .add_qual[d.seq].report_id, rptq_r.sequence = request->qual[1].add_qual[d.seq].report_sequence,
    rptq_r.updt_dt_tm = cnvtdatetime(curdate,curtime), rptq_r.updt_id = reqinfo->updt_id, rptq_r
    .updt_task = reqinfo->updt_task,
    rptq_r.updt_applctx = reqinfo->updt_applctx, rptq_r.updt_cnt = 0
   PLAN (d)
    JOIN (rptq_r)
   WITH nocounter
  ;end insert
  IF ((curqual != request->qual[1].add_cnt))
   CALL handle_errors("ADD","F","TABLE","REPORT_QUEUE_R")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->qual[1].chg_cnt > 0))
  SELECT INTO "nl:"
   rptq_r.*
   FROM report_queue_r rptq_r,
    (dummyt d  WITH seq = value(request->qual[1].chg_cnt))
   PLAN (d)
    JOIN (rptq_r
    WHERE (request->qual[1].report_queue_cd=rptq_r.report_queue_cd)
     AND (request->qual[1].chg_qual[d.seq].report_id=rptq_r.report_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), chg_updt_cnt[count1] = rptq_r.updt_cnt
   WITH nocounter, forupdate(rptq_r)
  ;end select
  IF ((count1 != request->qual[1].chg_cnt))
   CALL handle_errors("LOCK","F","TABLE","REPORT_QUEUE_R")
   GO TO exit_script
  ENDIF
  FOR (count1 = 1 TO request->qual[1].chg_cnt)
    IF ((request->qual[1].chg_qual[count1].updt_cnt != chg_updt_cnt[count1]))
     CALL handle_errors("CHANGE","F","TABLE","REPORT_QUEUE_R")
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM report_queue_r rptq_r,
    (dummyt d  WITH seq = value(request->qual[1].chg_cnt))
   SET rptq_r.report_queue_cd = request->qual[1].report_queue_cd, rptq_r.report_id = request->qual[1]
    .chg_qual[d.seq].report_id, rptq_r.sequence = request->qual[1].chg_qual[d.seq].report_sequence,
    rptq_r.updt_dt_tm = cnvtdatetime(curdate,curtime), rptq_r.updt_id = reqinfo->updt_id, rptq_r
    .updt_task = reqinfo->updt_task,
    rptq_r.updt_applctx = reqinfo->updt_applctx, rptq_r.updt_cnt = (rptq_r.updt_cnt+ 1)
   PLAN (d)
    JOIN (rptq_r
    WHERE (request->qual[1].report_queue_cd=rptq_r.report_queue_cd)
     AND (request->qual[1].chg_qual[d.seq].report_id=rptq_r.report_id))
   WITH nocounter
  ;end update
  IF ((curqual != request->qual[1].chg_cnt))
   CALL handle_errors("CHANGE","F","TABLE","REPORT_QUEUE_R")
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   IF ((request->qual[1].action="A"))
    SET reply->exception_data[error_cnt].report_queue_name = request->qual[1].report_queue_name
   ELSE
    SET reply->exception_data[error_cnt].report_queue_cd = request->qual[1].report_queue_cd
   ENDIF
 END ;Subroutine
END GO
