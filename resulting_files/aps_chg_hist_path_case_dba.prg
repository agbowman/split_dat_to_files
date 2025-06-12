CREATE PROGRAM aps_chg_hist_path_case:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 pc_updt_cnt = i4
   1 cr_updt_cnt = i4
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET pc_cur_updt_cnt = request->pc_updt_cnt
 SET cr_cur_updt_cnt = request->cr_updt_cnt
 SET person_id = 0.0
 IF ((((request->flag_ind=1)) OR ((request->flag_ind=3))) )
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (request->case_id=pc.case_id)
   DETAIL
    person_id = pc.person_id, pc_cur_updt_cnt = pc.updt_cnt
   WITH nocounter, forupdate(pc)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   GO TO exit_script
  ENDIF
  IF ((request->pc_updt_cnt != pc_cur_updt_cnt))
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   GO TO exit_script
  ENDIF
  SET pc_cur_updt_cnt = (pc_cur_updt_cnt+ 1)
  SET new_comments_long_text_id = 0.00
  SET s_active_cd = 0.00
  IF (textlen(trim(request->case_comment)) > 0
   AND (request->case_comment_long_text_id=0))
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
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_comments_long_text_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "DUAL"
    GO TO exit_script
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
     .parent_entity_id = request->case_id,
     lt.long_text = request->case_comment
    WITH nocounter
   ;end insert
  ELSEIF ((request->case_comment_long_text_id > 0))
   SET cur_updt_cnt = 0
   SET new_comments_long_text_id = request->case_comment_long_text_id
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt
    WHERE (request->case_comment_long_text_id=lt.long_text_id)
    DETAIL
     cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    GO TO exit_script
   ENDIF
   IF ((request->case_lt_updt_cnt != cur_updt_cnt))
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    GO TO exit_script
   ENDIF
   SET cur_updt_cnt = (cur_updt_cnt+ 1)
   UPDATE  FROM long_text lt
    SET lt.long_text = trim(request->case_comment), lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt
     .updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt =
     cur_updt_cnt
    WHERE (request->case_comment_long_text_id=lt.long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    GO TO exit_script
   ENDIF
  ENDIF
  UPDATE  FROM pathology_case pc
   SET pc.requesting_physician_id = request->requesting_physician_id, pc.case_collect_dt_tm =
    IF ((request->collected_dt_tm > 0)) cnvtdatetime(request->collected_dt_tm)
    ELSE null
    ENDIF
    , pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
    updt_applctx,
    pc.updt_cnt = pc_cur_updt_cnt, pc.comments_long_text_id = new_comments_long_text_id
   WHERE (pc.case_id=request->case_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->flag_ind=2))
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (request->case_id=pc.case_id)
   DETAIL
    person_id = pc.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((((request->flag_ind=2)) OR ((request->flag_ind=3))) )
  DELETE  FROM ap_qa_info aq
   WHERE (aq.case_id=request->case_id)
   WITH nocounter
  ;end delete
  INSERT  FROM ap_qa_info aq
   SET aq.qa_flag_id = seq(pathnet_seq,nextval), aq.case_id = request->case_id, aq.flag_type_cd =
    request->flag_type_cd,
    aq.activated_id = reqinfo->updt_id, aq.activated_dt_tm = cnvtdatetime(curdate,curtime3), aq
    .person_id = person_id,
    aq.active_ind = 1, aq.updt_dt_tm = cnvtdatetime(curdate,curtime3), aq.updt_id = reqinfo->updt_id,
    aq.updt_task = reqinfo->updt_task, aq.updt_applctx = reqinfo->updt_applctx, aq.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_QA_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->report_id > 0.0))
  SELECT INTO "nl:"
   cr.report_id
   FROM case_report cr
   WHERE (request->report_id=cr.report_id)
   DETAIL
    cr_cur_updt_cnt = cr.updt_cnt
   WITH nocounter, forupdate(cr)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
   GO TO exit_script
  ENDIF
  IF ((request->cr_updt_cnt != cr_cur_updt_cnt))
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
   GO TO exit_script
  ENDIF
  SET cr_cur_updt_cnt = (cr_cur_updt_cnt+ 1)
  UPDATE  FROM case_report cr
   SET cr.status_prsnl_id = request->status_prsnl_id, cr.status_dt_tm =
    IF ((request->status_dt_tm > 0)) cnvtdatetime(request->status_dt_tm)
    ELSE null
    ENDIF
    , cr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
    updt_applctx,
    cr.updt_cnt = cr_cur_updt_cnt
   WHERE (cr.report_id=request->report_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->pc_updt_cnt = pc_cur_updt_cnt
  SET reply->cr_updt_cnt = cr_cur_updt_cnt
 ENDIF
END GO
