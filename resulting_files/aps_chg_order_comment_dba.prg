CREATE PROGRAM aps_chg_order_comment:dba
 RECORD reply(
   1 long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET rt_updt_cnt = 0
 SET error_cnt = 0
 DECLARE current_comments_long_text_id = f8
 IF ((request->long_text_id > 0))
  IF (textlen(trim(request->comments)) > 0)
   CALL updatelongtext(0)
  ELSE
   CALL updatereporttask(0)
   CALL deletelongtextrow(0)
  ENDIF
 ELSE
  CALL createnewid(0)
  CALL updatereporttask(0)
 ENDIF
 SUBROUTINE createnewid(dummyvar)
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     current_comments_long_text_id = seq_nbr
    WITH nocounter
   ;end select
   SET s_active_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
    HEAD REPORT
     s_active_cd = 0.0
    DETAIL
     s_active_cd = cv.code_value
    WITH nocounter
   ;end select
   INSERT  FROM long_text lt
    SET lt.long_text_id = current_comments_long_text_id, lt.updt_cnt = 0, lt.updt_id = reqinfo->
     updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "REPORT_TASK", lt
     .parent_entity_id = request->report_id,
     lt.long_text = request->comments
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deletelongtextrow(dummyvar)
  DELETE  FROM long_text lt
   WHERE (request->long_text_id=lt.long_text_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL handle_errors("DELETE","F","TABLE","LONG_TEXT")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE updatereporttask(dummyvar)
   SELECT INTO "nl:"
    rt.report_task_id
    FROM report_task rt
    WHERE (request->report_id=rt.report_id)
    DETAIL
     rt_updt_cnt = rt.updt_cnt
    WITH forupdate(rt)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
    GO TO exit_script
   ELSE
    SET rt_updt_cnt = (rt_updt_cnt+ 1)
   ENDIF
   UPDATE  FROM report_task rt
    SET rt.comments_long_text_id = current_comments_long_text_id, rt.updt_dt_tm = cnvtdatetime(
      curdate,curtime), rt.updt_id = reqinfo->updt_id,
     rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt =
     rt_updt_cnt
    WHERE (request->report_id=rt.report_id)
     AND (rt.updt_cnt=(rt_updt_cnt - 1))
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UDPATE","F","TABLE","REPORT_TASK")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updatelongtext(dummyvar)
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (request->long_text_id=lt.long_text_id)
     AND (request->lt_updt_cnt=lt.updt_cnt)
     AND lt.parent_entity_name="REPORT_TASK"
    DETAIL
     cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ELSE
    IF ((request->lt_updt_cnt != cur_updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","LONG_TEXT")
     GO TO exit_script
    ELSE
     SET cur_updt_cnt = (cur_updt_cnt+ 1)
    ENDIF
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.long_text = trim(request->comments), lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt
     .updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt =
     cur_updt_cnt
    WHERE (request->long_text_id=lt.long_text_id)
     AND (request->lt_updt_cnt=lt.updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UDPATE","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ENDIF
   SET current_comments_long_text_id = request->long_text_id
 END ;Subroutine
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->long_text_id = current_comments_long_text_id
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
