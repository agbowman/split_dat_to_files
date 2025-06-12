CREATE PROGRAM ct_upt_quest_doc_reltn:dba
 RECORD reply(
   1 qual[*]
     2 questionnaire_doc_id = f8
     2 updt_cnt = i4
     2 action_ind = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_flag = i2 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE curupdtcnt = i4 WITH protect, noconstant(0)
 DECLARE numbercount = i4 WITH protect, noconstant(0)
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 SET qualcount = cnvtint(size(request->reltns,5))
 DECLARE find_flag = i2 WITH protect, noconstant(0)
 DECLARE gen_nbr_error = i2 WITH private, noconstant(1)
 DECLARE insert_error = i2 WITH private, noconstant(2)
 DECLARE update_error = i2 WITH private, noconstant(3)
 DECLARE lock_error = i2 WITH private, noconstant(4)
 SET bstat = alterlist(reply->qual,qualcount)
 CALL echo(build("QualCount is: ",qualcount))
 IF (qualcount > 0)
  SELECT INTO "nl:"
   qd.*
   FROM questionnaire_doc_reltn qd,
    (dummyt d  WITH seq = value(qualcount))
   PLAN (d)
    JOIN (qd
    WHERE (qd.prot_questionnaire_id=request->reltns[d.seq].prot_questionnaire_id)
     AND (qd.ct_document_id=request->reltns[d.seq].ct_document_id)
     AND (request->reltns[d.seq].action_ind=1))
   DETAIL
    request->reltns[d.seq].action_ind = 0, request->reltns[d.seq].questionnaire_doc_id = qd
    .questionnaire_doc_id, request->reltns[d.seq].active_ind = 1,
    request->reltns[d.seq].updt_cnt = qd.updt_cnt,
    CALL echo(build("Update Count is ",request->reltns[d.seq].updt_cnt))
   WITH counter
  ;end select
  CALL echo(build("Curqual is ",curqual))
 ENDIF
 CALL echo(build("QualCount is: ",qualcount))
 FOR (i = 1 TO qualcount)
   CALL echo(build("Action is :",request->reltns[i].action_ind))
   SELECT INTO "nl:"
    new_id = seq(protocol_def_seq,nextval)"########################;rpO"
    FROM dual
    WHERE (request->reltns[i].action_ind=1)
    DETAIL
     numbercount = (numbercount+ 1), find_flag = 1,
     CALL echo(new_id),
     reply->qual[i].questionnaire_doc_id = new_id, reply->qual[i].action_ind = request->reltns[i].
     action_ind, reply->qual[i].active_ind = request->reltns[i].active_ind,
     reply->qual[i].updt_cnt = request->reltns[i].updt_cnt,
     CALL echo(reply->qual[i].questionnaire_doc_id)
    WITH counter
   ;end select
   CALL echo(build("Numbercount is ",numbercount))
   CALL echo(build("Curqual is ",curqual))
   CALL echo(build("find_flag is ",find_flag))
   IF (numbercount > 0)
    IF (find_flag=1)
     IF (curqual=0)
      SET fail_flag = gen_nbr_error
      GO TO check_error
     ENDIF
    ENDIF
   ENDIF
   SET find_flag = 0
 ENDFOR
 IF (numbercount > 0
  AND qualcount > 0)
  INSERT  FROM questionnaire_doc_reltn qd,
    (dummyt d  WITH seq = value(qualcount))
   SET qd.questionnaire_doc_id = reply->qual[d.seq].questionnaire_doc_id, qd.prot_questionnaire_id =
    request->reltns[d.seq].prot_questionnaire_id, qd.ct_document_id = request->reltns[d.seq].
    ct_document_id,
    qd.active_ind = request->reltns[d.seq].active_ind, qd.updt_cnt = 0, qd.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    qd.updt_id = reqinfo->updt_id, qd.updt_applctx = reqinfo->updt_applctx, qd.updt_task = reqinfo->
    updt_task,
    qd.active_status_cd =
    IF ((request->reltns[d.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , qd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), qd.active_status_prsnl_id = reqinfo->
    updt_id
   PLAN (d
    WHERE (request->reltns[d.seq].action_ind=1))
    JOIN (qd)
   WITH counter
  ;end insert
  CALL echo("Actual Inserted")
  CALL echo(curqual)
  IF (curqual=0)
   SET fail_flag = insert_error
   GO TO check_error
  ENDIF
  CALL echo("After inserting into Questionnaire_doc_reltn table")
 ENDIF
 CALL echo(build("qdocid = ",request->reltns[1].questionnaire_doc_id))
 IF (qualcount > 0)
  SELECT INTO "nl:"
   qdv.*
   FROM questionnaire_doc_reltn qdv,
    (dummyt d  WITH seq = value(qualcount))
   PLAN (d)
    JOIN (qdv
    WHERE (qdv.questionnaire_doc_id=request->reltns[d.seq].questionnaire_doc_id)
     AND qdv.questionnaire_doc_id != 0.0)
   DETAIL
    curupdtcnt = (curupdtcnt+ 1), reply->qual[d.seq].questionnaire_doc_id = qdv.questionnaire_doc_id,
    reply->qual[d.seq].action_ind = request->reltns[d.seq].action_ind,
    reply->qual[d.seq].active_ind = request->reltns[d.seq].active_ind, reply->qual[d.seq].updt_cnt =
    request->reltns[d.seq].updt_cnt,
    CALL echo(build("Update count is ",request->reltns[d.seq].updt_cnt))
   WITH counter, forupdate(qdv)
  ;end select
  CALL echo(build("rows found:",curupdtcnt))
  CALL echo("curqual-chg script")
  CALL echo(build("Curqual after lock is",curqual))
  CALL echo("chg curqual")
  IF (curupdtcnt > 0)
   IF (curqual=0)
    SET fail_flag = lock_error
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
 CALL echo("after lock")
 IF (curupdtcnt > 0
  AND qualcount > 0)
  UPDATE  FROM questionnaire_doc_reltn qdv,
    (dummyt d1  WITH seq = value(qualcount))
   SET qdv.prot_questionnaire_id = request->reltns[d1.seq].prot_questionnaire_id, qdv.ct_document_id
     = request->reltns[d1.seq].ct_document_id, qdv.active_ind = request->reltns[d1.seq].active_ind,
    qdv.updt_dt_tm = cnvtdatetime(curdate,curtime3), qdv.updt_cnt = (qdv.updt_cnt+ 1), qdv.updt_task
     = reqinfo->updt_task,
    qdv.updt_id = reqinfo->updt_id, qdv.updt_applctx = reqinfo->updt_applctx, qdv.active_status_cd =
    IF ((request->reltns[d1.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    ,
    qdv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), qdv.active_status_prsnl_id = reqinfo->
    updt_id
   PLAN (d1)
    JOIN (qdv
    WHERE (request->reltns[d1.seq].action_ind=0)
     AND (qdv.questionnaire_doc_id=request->reltns[d1.seq].questionnaire_doc_id)
     AND (qdv.updt_cnt=request->reltns[d1.seq].updt_cnt))
   WITH counter
  ;end update
  CALL echo(build("Curqual for update is: ",curqual))
  IF (curqual=0)
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
  CALL echo("after update")
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
