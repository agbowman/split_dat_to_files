CREATE PROGRAM aps_chg_case_comment:dba
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
 SET pc_updt_cnt = 0
 SET error_cnt = 0
 DECLARE current_comments_long_text_id = f8
 IF ((request->application="CSMREQUESTVIEWER"))
  SELECT INTO "n1:"
   FROM long_text lt
   WHERE (lt.parent_entity_id=request->case_id)
    AND lt.parent_entity_name="PATHOLOGY_CASE"
   DETAIL
    request->comments = concat(trim(lt.long_text),char(10),request->comments), request->lt_updt_cnt
     = lt.updt_cnt, request->long_text_id = lt.long_text_id
  ;end select
 ENDIF
 IF ((request->long_text_id > 0))
  IF (textlen(trim(request->comments)) > 0)
   CALL updatelongtext(0)
  ELSE
   CALL updatepathologycase(0)
   CALL deletelongtextrow(0)
  ENDIF
 ELSE
  CALL createnewid(0)
  CALL updatepathologycase(0)
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
     lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
     .parent_entity_id = request->case_id,
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
 SUBROUTINE updatepathologycase(dummyvar)
   SELECT INTO "nl:"
    pc.case_id
    FROM pathology_case pc
    WHERE (request->case_id=pc.case_id)
    DETAIL
     pc_updt_cnt = pc.updt_cnt
    WITH forupdate(pc)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ELSE
    SET pc_updt_cnt = (pc_updt_cnt+ 1)
   ENDIF
   UPDATE  FROM pathology_case pc
    SET pc.comments_long_text_id = current_comments_long_text_id, pc.updt_dt_tm = cnvtdatetime(
      curdate,curtime), pc.updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt =
     pc_updt_cnt
    WHERE (request->case_id=pc.case_id)
     AND (pc.updt_cnt=(pc_updt_cnt - 1))
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UDPATE","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updatelongtext(dummyvar)
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (request->long_text_id=lt.long_text_id)
     AND (request->lt_updt_cnt=lt.updt_cnt)
     AND lt.parent_entity_name="PATHOLOGY_CASE"
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
