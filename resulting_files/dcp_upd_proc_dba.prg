CREATE PROGRAM dcp_upd_proc:dba
 SET modify = predeclare
 RECORD reply(
   1 proc_prsnl_reltn_id = f8
   1 long_text_id = f8
   1 proc_prsnl_reltn_ids[*]
     2 proc_prsnl_reltn_id = f8
   1 procedure_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH protect, noconstant(" ")
 DECLARE freetext_prsnl = i2 WITH protect, noconstant(0)
 DECLARE g_reltns_count = i4 WITH protect, noconstant(0)
 DECLARE g_reltns = i4 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE proc_prsnl_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE comment_ind = i2 WITH noconstant(0)
 DECLARE blank_date = dq8 WITH protect, noconstant(0.0)
 DECLARE msg_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE proc_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM procedure p
  PLAN (p
   WHERE (p.procedure_id=request->procedure_id))
  DETAIL
   request->encntr_id = p.encntr_id
  WITH nocounter
 ;end select
 IF ((request->active_ind=0))
  UPDATE  FROM procedure p
   SET p.active_ind = request->active_ind, p.active_status_cd = reqdata->inactive_status_cd, p
    .end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1)
   WHERE (p.procedure_id=request->procedure_id)
   WITH nocounter
  ;end update
  GO TO exit_script
 ENDIF
 IF ((request->comment_ind=1)
  AND (request->text > " "))
  SET comment_ind = 1
 ELSEIF ((request->comment_ind=- (1))
  AND (request->text=" "))
  SET comment_ind = - (1)
 ELSE
  SET comment_ind = 0
 ENDIF
 SET proc_prsnl_id = 0.0
 IF ((request->proc_prsnl_ft_ind=1)
  AND (request->proc_ft_prsnl > " "))
  SET freetext_prsnl = 1
  SET proc_prsnl_id = 0.0
 ELSEIF ((request->proc_prsnl_ft_ind=- (1))
  AND (request->proc_prsnl_id=- (1.0)))
  SET freetext_prsnl = - (1)
  SET proc_prsnl_id = - (1.0)
 ELSE
  SET freetext_prsnl = 0
  SET proc_prsnl_id = request->proc_prsnl_id
 ENDIF
 UPDATE  FROM procedure p
  SET p.nomenclature_id = evaluate(request->nomenclature_id,- (1.0),p.nomenclature_id,0.0,0.0,
    request->nomenclature_id), p.proc_ftdesc = evaluate(request->proc_ft_nomen," ",p.proc_ftdesc,'""',
    null,
    request->proc_ft_nomen), p.proc_dt_tm = evaluate(request->proc_dt_tm,0.0,p.proc_dt_tm,blank_date,
    null,
    cnvtdatetime(request->proc_dt_tm)),
   p.proc_ft_dt_tm_ind = evaluate(request->proc_ft_dt_tm_ind,- (1),p.proc_ft_dt_tm_ind,0,0,
    request->proc_ft_dt_tm_ind), p.proc_ft_time_frame = evaluate(request->proc_ft_time_frame," ",p
    .proc_ft_time_frame,'""',null,
    request->proc_ft_time_frame), p.proc_loc_cd = evaluate(request->proc_loc_cd,- (1.0),p.proc_loc_cd,
    0.0,0.0,
    request->proc_loc_cd),
   p.proc_loc_ft_ind = evaluate(request->proc_loc_ft_ind,- (1),p.proc_loc_ft_ind,0,0,
    request->proc_loc_ft_ind), p.proc_ft_loc = evaluate(request->proc_ft_loc," ",p.proc_ft_loc,'""',
    null,
    request->proc_ft_loc), p.comment_ind = evaluate(comment_ind,- (1),p.comment_ind,0,0,
    comment_ind),
   p.active_ind = request->active_ind, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
   reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt
   + 1)
  WHERE (p.procedure_id=request->procedure_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "procedure table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to update into table.  Possibly invalid procedure_id."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET g_reltns = size(request->proc_prsnl_reltns,5)
 SET stat = alterlist(reply->proc_prsnl_reltn_ids,g_reltns)
 FOR (x = 1 TO g_reltns)
   IF ((request->proc_prsnl_reltns[x].proc_prsnl_reltn_id > 0.0))
    UPDATE  FROM proc_prsnl_reltn p
     SET p.prsnl_person_id = evaluate(request->proc_prsnl_reltns[x].proc_prsnl_id,- (1.0),0.0,0.0,p
       .prsnl_person_id,
       request->proc_prsnl_reltns[x].proc_prsnl_id), p.proc_prsnl_ft_ind = evaluate(request->
       proc_prsnl_reltns[x].proc_prsnl_ft_ind,- (1),0,0,p.proc_prsnl_ft_ind,
       request->proc_prsnl_reltns[x].proc_prsnl_ft_ind), p.proc_ft_prsnl = evaluate(request->
       proc_prsnl_reltns[x].proc_ft_prsnl," ",p.proc_ft_prsnl,'""',null,
       request->proc_prsnl_reltns[x].proc_ft_prsnl),
      p.proc_prsnl_reltn_cd = evaluate(request->proc_prsnl_reltns[x].proc_prsnl_reltn_cd,- (1.0),0.0,
       0.0,p.proc_prsnl_reltn_cd,
       request->proc_prsnl_reltns[x].proc_prsnl_reltn_cd), p.active_ind = 1, p.active_status_cd =
      reqdata->active_status_cd,
      p.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), p.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), p.updt_id = reqinfo->updt_id,
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
      .updt_cnt+ 1)
     WHERE (p.proc_prsnl_reltn_id=request->proc_prsnl_reltns[x].proc_prsnl_reltn_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET g_reltns_count = (g_reltns_count+ 1)
     SET reply->proc_prsnl_reltn_ids[g_reltns_count].proc_prsnl_reltn_id = request->
     proc_prsnl_reltns[x].proc_prsnl_reltn_id
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectname = "proc_prsnl_reltn table"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to update into proc_prsnl_reltn."
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ELSE
    IF ((((request->proc_prsnl_reltns[x].proc_prsnl_ft_ind=1)
     AND (request->proc_prsnl_reltns[x].proc_ft_prsnl > " ")) OR ((request->proc_prsnl_reltns[x].
    proc_prsnl_id > 0.0))) )
     SELECT INTO "nl:"
      j = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       proc_prsnl_reltn_id = j
      WITH format, nocounter
     ;end select
     INSERT  FROM proc_prsnl_reltn p
      SET p.proc_prsnl_reltn_id = proc_prsnl_reltn_id, p.prsnl_person_id = request->
       proc_prsnl_reltns[x].proc_prsnl_id, p.proc_prsnl_ft_ind = request->proc_prsnl_reltns[x].
       proc_prsnl_ft_ind,
       p.proc_ft_prsnl = request->proc_prsnl_reltns[x].proc_ft_prsnl, p.proc_prsnl_reltn_cd = request
       ->proc_prsnl_reltns[x].proc_prsnl_reltn_cd, p.procedure_id = request->procedure_id,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.active_ind = 1,
       p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
       p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
        "31-Dec-2100"), p.contributor_system_cd = 0.0,
       p.free_text_cd = 0.0, p.ft_prsnl_name = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET g_reltns_count = (g_reltns_count+ 1)
      SET reply->proc_prsnl_reltn_ids[g_reltns_count].proc_prsnl_reltn_id = proc_prsnl_reltn_id
     ELSE
      SET reply->status_data.subeventstatus[1].targetobjectname = "proc_prsnl_reltn table"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into proc_prsnl_reltn."
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->proc_prsnl_reltn_ids,g_reltns_count)
 IF ((freetext_prsnl=- (1))
  AND (proc_prsnl_id=- (1)))
  GO TO comment
 ELSEIF ((request->proc_prsnl_reltn_id > 0.0))
  IF ((((request->proc_prsnl_id > 0)) OR ((request->proc_prsnl_ft_ind=1))) )
   UPDATE  FROM proc_prsnl_reltn p
    SET p.prsnl_person_id = proc_prsnl_id, p.proc_prsnl_ft_ind = evaluate(request->proc_prsnl_ft_ind,
      - (1),p.proc_prsnl_ft_ind,0,0,
      request->proc_prsnl_ft_ind), p.proc_ft_prsnl = evaluate(request->proc_ft_prsnl," ",p
      .proc_ft_prsnl,'""',null,
      request->proc_ft_prsnl),
     p.proc_prsnl_reltn_cd = evaluate(request->proc_prsnl_reltn_cd,- (1.0),p.proc_prsnl_reltn_cd,0.0,
      0.0,
      request->proc_prsnl_reltn_cd), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
     .updt_cnt+ 1)
    WHERE (p.proc_prsnl_reltn_id=request->proc_prsnl_reltn_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM proc_prsnl_reltn p
    SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1)
    WHERE (p.proc_prsnl_reltn_id=request->proc_prsnl_reltn_id)
    WITH nocounter
   ;end update
  ENDIF
 ELSEIF ((((request->proc_prsnl_id > 0)) OR ((request->proc_prsnl_ft_ind=1))) )
  SELECT INTO "nl:"
   j = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    proc_prsnl_reltn_id = j
   WITH format, nocounter
  ;end select
  INSERT  FROM proc_prsnl_reltn p
   SET p.proc_prsnl_reltn_id = proc_prsnl_reltn_id, p.prsnl_person_id = proc_prsnl_id, p
    .proc_prsnl_ft_ind = request->proc_prsnl_ft_ind,
    p.proc_ft_prsnl = request->proc_ft_prsnl, p.proc_prsnl_reltn_cd = request->proc_prsnl_reltn_cd, p
    .procedure_id = request->procedure_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.active_ind = 1,
    p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
    p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100"), p.contributor_system_cd = 0.0,
    p.free_text_cd = 0.0, p.ft_prsnl_name = 0
   WITH nocounter
  ;end insert
 ENDIF
#comment
 IF ((comment_ind=- (1)))
  GO TO exit_script
 ELSEIF ((request->long_text_id > 0))
  IF (comment_ind=1)
   UPDATE  FROM long_text l
    SET l.long_text = request->text, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id =
     reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
     .updt_cnt+ 1)
    WHERE (l.long_text_id=request->long_text_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM long_text l
    SET l.active_ind = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
     .updt_cnt+ 1)
    WHERE (l.long_text_id=request->long_text_id)
    WITH nocounter
   ;end update
   UPDATE  FROM procedure p
    SET p.long_text_id = 0.0, p.comment_ind = 0
    WHERE (p.procedure_id=request->procedure_id)
    WITH nocounter
   ;end update
  ENDIF
 ELSE
  IF (comment_ind=1)
   SET msg_text_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     msg_text_id = nextseqnum, long_text_id = msg_text_id
    WITH format
   ;end select
   INSERT  FROM long_text lt
    SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "PROCEDURE", lt.parent_entity_id =
     request->procedure_id,
     lt.long_text = request->text, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
     updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   UPDATE  FROM procedure p
    SET p.long_text_id = msg_text_id
    WHERE (p.procedure_id=request->procedure_id)
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->proc_prsnl_reltn_id = proc_prsnl_reltn_id
  SET reply->long_text_id = long_text_id
  SET reply->procedure_id = request->procedure_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET script_version = "012 12/23/11 PS022943"
 SET modify = nopredeclare
END GO
