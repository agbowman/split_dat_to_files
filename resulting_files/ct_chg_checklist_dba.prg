CREATE PROGRAM ct_chg_checklist:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE (nextlongtextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SUBROUTINE (insert_long_text_ref(long_text_id=f8,text=vc,parent_name=vc,parent_id=f8) =i2)
  INSERT  FROM long_text_reference ltr
   SET ltr.long_text_id =
    IF (long_text_id > 0) long_text_id
    ELSE seq(long_data_seq,nextval)
    ENDIF
    , ltr.long_text = text, ltr.parent_entity_name = parent_name,
    ltr.parent_entity_id = parent_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->
    updt_id,
    ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
    ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
    cnvtdatetime(sysdate),
    ltr.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   RETURN(false)
  ELSE
   RETURN(true)
  ENDIF
 END ;Subroutine
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE desc_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE special_inst_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE orig_desc_text = vc WITH protect
 DECLARE orig_special_inst_text = vc WITH protect
 DECLARE insert_result = i2 WITH protect, noconstant(false)
 DECLARE delete_desc_ind = i2 WITH proctect, noconstant(0)
 DECLARE delete_inst_ind = i2 WITH proctect, noconstant(0)
 SET reply->status_data.status = "F"
 SET fail_flag = 0
 IF ((request->prot_questionnaire_id > 0))
  SET new_id = nextsequence(0)
  INSERT  FROM prot_questionnaire pq
   (pq.prot_questionnaire_id, pq.questionnaire_type_cd, pq.questionnaire_name,
   pq.prot_amendment_id, pq.prev_prot_questionnaire_id, pq.beg_effective_dt_tm,
   pq.end_effective_dt_tm, pq.special_inst_long_text_id, pq.desc_long_text_id,
   pq.updt_dt_tm, pq.updt_id, pq.updt_task,
   pq.updt_applctx, pq.updt_cnt)(SELECT
    new_id, pq1.questionnaire_type_cd, pq1.questionnaire_name,
    pq1.prot_amendment_id, pq1.prev_prot_questionnaire_id, pq1.beg_effective_dt_tm,
    cnvtdatetime(script_date), pq1.special_inst_long_text_id, pq1.desc_long_text_id,
    pq1.updt_dt_tm, pq1.updt_id, pq1.updt_task,
    pq1.updt_applctx, pq1.updt_cnt
    FROM prot_questionnaire pq1
    WHERE (pq1.prot_questionnaire_id=request->prot_questionnaire_id))
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting into ct_reason_deleted table."
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   pq.prot_questionnaire_id
   FROM prot_questionnaire pq
   WHERE (pq.prot_questionnaire_id=request->prot_questionnaire_id)
   DETAIL
    desc_long_text_id = pq.desc_long_text_id, special_inst_long_text_id = pq
    .special_inst_long_text_id
    IF (size(request->desc_text,1)=0
     AND desc_long_text_id > 0)
     delete_desc_ind = 1
    ENDIF
    CALL echo(build("size of special_inst_text is:",size(request->special_inst_text,1)))
    IF (size(request->special_inst_text,1)=0
     AND special_inst_long_text_id > 0)
     delete_inst_ind = 1
    ENDIF
   WITH nocounter, forupdate(pq)
  ;end select
  IF ((request->delete_ind=1)
   AND curqual > 0)
   UPDATE  FROM prot_questionnaire pq
    SET pq.beg_effective_dt_tm = cnvtdatetime(script_date), pq.end_effective_dt_tm = cnvtdatetime(
      script_date), pq.updt_dt_tm = cnvtdatetime(sysdate),
     pq.updt_id = reqinfo->updt_id, pq.updt_task = reqinfo->updt_task, pq.updt_applctx = reqinfo->
     updt_applctx,
     pq.updt_cnt = (pq.updt_cnt+ 1), pq.updt_dt_tm = cnvtdatetime(script_date)
    WHERE (pq.prot_questionnaire_id=request->prot_questionnaire_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET fail_flag = update_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating into prot_questionnaire. (delete_ind = 0)"
    GO TO check_error
   ENDIF
   SELECT INTO "nl:"
    qdr.prot_questionnaire_id
    FROM questionnaire_doc_reltn qdr
    WHERE (qdr.prot_questionnaire_id=request->prot_questionnaire_id)
    WITH nocounter, forupdate(qdr)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM questionnaire_doc_reltn qdr
     SET qdr.active_ind = 0, qdr.updt_id = reqinfo->updt_id, qdr.updt_task = reqinfo->updt_task,
      qdr.updt_applctx = reqinfo->updt_applctx, qdr.updt_cnt = (qdr.updt_cnt+ 1), qdr.updt_dt_tm =
      cnvtdatetime(script_date)
     WHERE (qdr.prot_questionnaire_id=request->prot_questionnaire_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET fail_flag = update_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error updating into questionnaire_doc_reltn."
    ENDIF
   ENDIF
   IF (desc_long_text_id > 0)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=desc_long_text_id
     WITH nocounter, forupdate(ltr)
    ;end select
    IF (curqual > 0)
     UPDATE  FROM long_text_reference ltr
      SET ltr.active_ind = 0, ltr.active_status_cd = reqdata->inactive_status_cd, ltr
       .active_status_dt_tm = cnvtdatetime(sysdate),
       ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
       .updt_id = reqinfo->updt_id,
       ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt = (
       ltr.updt_cnt+ 1)
      WHERE ltr.long_text_id=desc_long_text_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error updating description in long_text_reference."
     ENDIF
    ENDIF
   ENDIF
   IF (special_inst_long_text_id > 0)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=special_inst_long_text_id
     WITH nocounter, forupdate(ltr)
    ;end select
    IF (curqual > 0)
     UPDATE  FROM long_text_reference ltr
      SET ltr.active_ind = 0, ltr.active_status_cd = reqdata->inactive_status_cd, ltr
       .active_status_dt_tm = cnvtdatetime(sysdate),
       ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
       .updt_id = reqinfo->updt_id,
       ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt = (
       ltr.updt_cnt+ 1)
      WHERE ltr.long_text_id=special_inst_long_text_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET fail_flag = update_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error updating special instruction in long_text_reference."
     ENDIF
    ENDIF
   ENDIF
  ELSEIF (curqual > 0)
   IF (desc_long_text_id > 0)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=desc_long_text_id
     DETAIL
      orig_desc_text = ltr.long_text
     WITH nocounter, forupdate(ltr)
    ;end select
    IF ((request->desc_text != orig_desc_text))
     IF (delete_desc_ind=1)
      UPDATE  FROM long_text_reference ltr
       SET ltr.active_ind = 0, ltr.active_status_cd = reqdata->inactive_status_cd, ltr
        .active_status_dt_tm = cnvtdatetime(sysdate),
        ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
        .updt_id = reqinfo->updt_id,
        ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt =
        (ltr.updt_cnt+ 1)
       WHERE ltr.long_text_id=desc_long_text_id
       WITH nocounter
      ;end update
      SET desc_long_text_id = 0.0
      IF (curqual=0)
       SET fail_flag = update_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error deleting desc from long_text_reference."
       GO TO check_error
      ENDIF
     ELSE
      UPDATE  FROM long_text_reference ltr
       SET ltr.long_text = request->desc_text, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id =
        reqinfo->updt_id,
        ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt =
        (ltr.updt_cnt+ 1)
       WHERE ltr.long_text_id=desc_long_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET fail_flag = update_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error updating checklist desc text."
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (size(request->desc_text,1) > 0)
     SET desc_long_text_id = nextlongtextsequence(0)
     SET insert_result = insert_long_text_ref(desc_long_text_id,request->desc_text,
      "PROT_QUESTIONNAIRE",request->prot_questionnaire_id)
     IF (insert_result=false)
      SET fail_flag = insert_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Cannot insert checklist description into long_text_reference."
      GO TO check_error
     ENDIF
    ENDIF
   ENDIF
   IF (special_inst_long_text_id > 0)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=special_inst_long_text_id
     DETAIL
      orig_special_inst_text = ltr.long_text
     WITH nocounter, forupdate(ltr)
    ;end select
    IF ((request->special_inst_text != orig_special_inst_text))
     IF (delete_inst_ind=1)
      UPDATE  FROM long_text_reference ltr
       SET ltr.active_ind = 0, ltr.active_status_cd = reqdata->inactive_status_cd, ltr
        .active_status_dt_tm = cnvtdatetime(sysdate),
        ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
        .updt_id = reqinfo->updt_id,
        ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt =
        (ltr.updt_cnt+ 1)
       WHERE ltr.long_text_id=special_inst_long_text_id
       WITH nocounter
      ;end update
      SET special_inst_long_text_id = 0.0
      IF (curqual=0)
       SET fail_flag = update_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error deleting special inst from long_text_reference."
       GO TO check_error
      ENDIF
     ELSE
      UPDATE  FROM long_text_reference ltr
       SET ltr.long_text = request->special_inst_text, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr
        .updt_id = reqinfo->updt_id,
        ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_cnt =
        (ltr.updt_cnt+ 1)
       WHERE ltr.long_text_id=special_inst_long_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET fail_flag = update_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error updating checklist special inst text."
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (size(request->special_inst_text,1) > 0)
     SET special_inst_long_text_id = nextlongtextsequence(0)
     SET insert_result = insert_long_text_ref(special_inst_long_text_id,request->special_inst_text,
      "PROT_QUESTIONNAIRE",request->prot_questionnaire_id)
     IF (insert_result=false)
      SET fail_flag = insert_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Cannot insert checklist special instructions into long_text_reference."
      GO TO check_error
     ENDIF
    ENDIF
   ENDIF
   UPDATE  FROM prot_questionnaire pq
    SET pq.questionnaire_name = request->questionnaire_name, pq.desc_long_text_id = desc_long_text_id,
     pq.special_inst_long_text_id = special_inst_long_text_id,
     pq.beg_effective_dt_tm = cnvtdatetime(script_date), pq.updt_dt_tm = cnvtdatetime(sysdate), pq
     .updt_id = reqinfo->updt_id,
     pq.updt_task = reqinfo->updt_task, pq.updt_applctx = reqinfo->updt_applctx, pq.updt_cnt = (pq
     .updt_cnt+ 1)
    WHERE (pq.prot_questionnaire_id=request->prot_questionnaire_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET fail_flag = update_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating into prot_questionnaire (delete_ind = 0)."
   ENDIF
  ENDIF
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
  CALL echo("fail_flag != 0")
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "001"
 SET mod_date = "Jan 21, 2008"
END GO
