CREATE PROGRAM aps_chg_hold_reports:dba
 RECORD reply(
   1 long_text_id = f8
   1 hold_cd = f8
   1 hold_disp = vc
   1 updt_cnt = i4
   1 lt_updt_cnt = i4
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
 SET error_cnt = 0
 DECLARE s_active_cd = f8
 DECLARE current_hold_comment_long_text_id = f8
 IF ((request->hold_comment_long_text_id > 0))
  IF (textlen(trim(request->hold_comment)) > 0)
   CALL updatelongtexttable(0)
  ELSE
   CALL updatereporttasktable(0)
   CALL deletelongtextrow(0)
   CALL scriptsuccess(0)
   GO TO end_of_reports
  ENDIF
 ELSE
  IF (textlen(trim(request->hold_comment)) > 0)
   CALL generatenewlongtextid(0)
   CALL insertnewrowtolongtexttable(0)
  ENDIF
 ENDIF
 CALL updatereporttasktable(0)
 CALL scriptsuccess(0)
 SUBROUTINE generatenewlongtextid(dummyvar)
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     current_hold_comment_long_text_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL handle_errors("GETSEQUENCE","F","TABLE","LONG_DATA_SEQ")
    GO TO end_of_reports
   ENDIF
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
 END ;Subroutine
 SUBROUTINE insertnewrowtolongtexttable(dummyvar)
  INSERT  FROM long_text lt
   SET lt.long_text_id = current_hold_comment_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "REPORT_TASK", lt
    .parent_entity_id = request->report_id,
    lt.long_text = request->hold_comment
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","LONG_TEXT")
   GO TO end_of_reports
  ENDIF
 END ;Subroutine
 SUBROUTINE updatelongtexttable(dummyvar)
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (request->hold_comment_long_text_id=lt.long_text_id)
    DETAIL
     cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF ((request->lt_updt_cnt != cur_updt_cnt))
    CALL handle_errors("LOCK","F","TABLE","LONG_TEXT")
    GO TO end_of_reports
   ENDIF
   SET cur_updt_cnt = (cur_updt_cnt+ 1)
   UPDATE  FROM long_text lt
    SET lt.long_text = trim(request->hold_comment), lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt
     .updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt =
     cur_updt_cnt
    WHERE (request->hold_comment_long_text_id=lt.long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","LONG_TEXT")
    GO TO end_of_reports
   ENDIF
   SET current_hold_comment_long_text_id = request->hold_comment_long_text_id
 END ;Subroutine
 SUBROUTINE deletelongtextrow(dummyvar)
   DELETE  FROM long_text lt
    WHERE (request->hold_comment_long_text_id=lt.long_text_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL handle_errors("DELETE","F","TABLE","LONG_TEXT")
    GO TO end_of_reports
   ENDIF
   SET current_hold_comment_long_text_id = 0.0
 END ;Subroutine
 SUBROUTINE updatereporttasktable(dummyvar)
  SELECT INTO "nl:"
   rt.report_task_id
   FROM report_task rt
   WHERE (request->report_id=rt.report_id)
   DETAIL
    cur_updt_cnt = rt.updt_cnt
   WITH forupdate(rt)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
   GO TO end_of_reports
  ELSE
   IF ((request->updt_cnt != cur_updt_cnt))
    CALL handle_errors("LOCK","F","TABLE","REPORT_TASK")
    GO TO end_of_reports
   ELSE
    SET cur_updt_cnt = (cur_updt_cnt+ 1)
    UPDATE  FROM report_task rt
     SET rt.hold_cd = request->hold_cd, rt.hold_comment_long_text_id =
      current_hold_comment_long_text_id, rt.hold_dt_tm = cnvtdatetime(curdate,curtime),
      rt.hold_prsnl_id = reqinfo->updt_id, rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id
       = reqinfo->updt_id,
      rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt =
      cur_updt_cnt
     WHERE (request->report_id=rt.report_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","REPORT_TASK")
     GO TO end_of_reports
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE scriptsuccess(dummyvar)
   SET reply->long_text_id = current_hold_comment_long_text_id
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
 END ;Subroutine
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET reqinfo->commit_ind = 0
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_reports
 SELECT INTO "nl:"
  FROM report_task rt,
   long_text lt
  PLAN (rt
   WHERE (rt.report_id=request->report_id))
   JOIN (lt
   WHERE lt.long_text_id=rt.hold_comment_long_text_id)
  DETAIL
   reply->hold_cd = rt.hold_cd, reply->updt_cnt = rt.updt_cnt
   IF (lt.long_text_id > 0.0)
    reply->lt_updt_cnt = lt.updt_cnt
   ENDIF
  WITH nocounter
 ;end select
END GO
