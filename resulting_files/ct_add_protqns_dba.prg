CREATE PROGRAM ct_add_protqns:dba
 RECORD reply(
   1 prot_questionnaire_id = f8
   1 special_inst_long_text_id = f8
   1 desc_long_text_id = f8
   1 qual[*]
     2 prot_elig_quest_id = f8
     2 quest_type_ind = i2
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
 RECORD chg_questions_req(
   1 questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 desired_value = c1
     2 answer_format_id = f8
     2 elig_quest_nbr = i4
     2 value_required_flag = i2
     2 date_required_flag = i2
     2 long_text_id = f8
     2 delete_ind = i2
 ) WITH protect
 RECORD chg_questions_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD chg_checklist_req(
   1 prot_amendment_id = f8
   1 prot_questionnaire_id = f8
   1 questionnaire_type_cd = f8
   1 questionnaire_name = vc
   1 special_inst_text = vc
   1 desc_text = vc
   1 delete_ind = i2
 ) WITH protect
 RECORD chg_checklist_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE add_count = i2 WITH protect, noconstant(0)
 DECLARE del_count = i2 WITH protect, noconstant(0)
 DECLARE chg_count = i2 WITH protect, noconstant(0)
 DECLARE quest_cnt = i2 WITH protect, noconstant(0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE desc_id = f8 WITH protect, noconstant(0.0)
 DECLARE special_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE insert_result = i2 WITH protect, noconstant(false)
 DECLARE quest_text_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((request->prot_questionnaire_id < 0))
  SET request->prot_questionnaire_id = nextsequence(0)
  IF (size(request->desc_text,1) > 0)
   SET desc_id = nextlongtextsequence(0)
   SET reply->desc_long_text_id = desc_id
   SET insert_result = insert_long_text_ref(desc_id,request->desc_text,"PROT_QUESTIONNAIRE",request->
    prot_questionnaire_id)
   IF (insert_result=false)
    SET failed = true
    SET reply->status_data.reason_for_failure =
    "Cannot insert checklist description into long_text_reference."
    GO TO exit_script
   ENDIF
  ENDIF
  IF (size(request->special_inst_text,1) > 0)
   SET special_inst_id = nextlongtextsequence(0)
   SET reply->special_inst_long_text_id = special_inst_id
   SET insert_result = insert_long_text_ref(special_inst_id,request->special_inst_text,
    "PROT_QUESTIONNAIRE",request->prot_questionnaire_id)
   IF (insert_result=false)
    SET failed = true
    SET reply->status_data.reason_for_failure =
    "Cannot insert checklist special instruction into long_text_reference."
    GO TO exit_script
   ENDIF
  ENDIF
  INSERT  FROM prot_questionnaire pq
   SET pq.prot_questionnaire_id = request->prot_questionnaire_id, pq.questionnaire_type_cd = request
    ->questionnaire_type_cd, pq.prot_amendment_id = request->prot_amendment_id,
    pq.questionnaire_name = request->questionnaire_name, pq.prev_prot_questionnaire_id = request->
    prot_questionnaire_id, pq.beg_effective_dt_tm = cnvtdatetime(script_date),
    pq.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pq.updt_dt_tm = cnvtdatetime(
     script_date), pq.updt_id = reqinfo->updt_id,
    pq.updt_task = reqinfo->updt_task, pq.updt_applctx = reqinfo->updt_applctx, pq.updt_cnt = 0,
    pq.desc_long_text_id = desc_id, pq.special_inst_long_text_id = special_inst_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = true
   SET reply->status_data.reason_for_failure = "Cannot create new questionnaire"
   GO TO exit_script
  ELSE
   SET reply->prot_questionnaire_id = request->prot_questionnaire_id
  ENDIF
 ELSE
  SET del_count = size(request->del,5)
  CALL echo(build("del_count = ",del_count))
  SET stat = alterlist(chg_questions_req->questions,del_count)
  FOR (i = 1 TO del_count)
    SET quest_cnt += 1
    SET chg_questions_req->questions[quest_cnt].delete_ind = 1
    SET chg_questions_req->questions[quest_cnt].prot_elig_quest_id = request->del[i].
    prot_elig_quest_id
  ENDFOR
  SET chg_count = size(request->chg,5)
  CALL echo(build("chg_count = ",chg_count))
  SET stat = alterlist(chg_questions_req->questions,(chg_count+ size(chg_questions_req->questions,5))
   )
  CALL echo(build("New alterlist size:",(chg_count+ size(chg_questions_req->questions,5))))
  IF (chg_count > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->chg,5)))
    DETAIL
     quest_cnt += 1,
     CALL echo(build("quest_cnt = ",quest_cnt)),
     CALL echo(build("d.seq = ",d.seq)),
     chg_questions_req->questions[quest_cnt].delete_ind = 0, chg_questions_req->questions[quest_cnt].
     prot_elig_quest_id = request->chg[d.seq].prot_elig_quest_id, chg_questions_req->questions[
     quest_cnt].question = request->chg[d.seq].question,
     chg_questions_req->questions[quest_cnt].desired_value = request->chg[d.seq].desired_value,
     chg_questions_req->questions[quest_cnt].answer_format_id = request->chg[d.seq].answer_format_id,
     chg_questions_req->questions[quest_cnt].elig_quest_nbr = request->chg[d.seq].prot_elig_quest_nbr,
     chg_questions_req->questions[quest_cnt].value_required_flag = request->chg[d.seq].val_reqd_flag,
     chg_questions_req->questions[quest_cnt].date_required_flag = request->chg[d.seq].dt_reqd_flag,
     chg_questions_req->questions[quest_cnt].long_text_id = request->chg[d.seq].long_text_id
    WITH nocounter
   ;end select
  ENDIF
  EXECUTE ct_chg_questions  WITH replace("REQUEST","CHG_QUESTIONS_REQ"), replace("REPLY",
   "CHG_QUESTIONS_REP")
  IF ((chg_questions_rep->status_data.status != "S"))
   SET reply->status_data.reason_for_failure = "Error logically deleting questions."
   SET failed = true
   GO TO exit_script
  ENDIF
  IF (trim(request->questionnaire_name) != "")
   SET chg_checklist_req->prot_amendment_id = request->prot_amendment_id
   SET chg_checklist_req->prot_questionnaire_id = request->prot_questionnaire_id
   SET chg_checklist_req->questionnaire_name = request->questionnaire_name
   SET chg_checklist_req->questionnaire_type_cd = request->questionnaire_type_cd
   SET chg_checklist_req->special_inst_text = request->special_inst_text
   SET chg_checklist_req->desc_text = request->desc_text
   SET chg_checklist_req->delete_ind = 0
   EXECUTE ct_chg_checklist  WITH replace("REQUEST","CHG_CHECKLIST_REQ"), replace("REPLY",
    "CHG_CHECKLIST_REP")
   IF ((chg_checklist_rep->status_data.status != "S"))
    SET failed = true
    SET chg_checklist_rep->status_data.reason_for_failure = reply->status_data.subeventstatus[1].
    targetobjectvalue
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET add_count = size(request->add,5)
 SET stat = alterlist(reply->qual,add_count)
 FOR (i = 1 TO add_count)
   SET quest_text_id = 0
   SET insert_result = false
   SET quest_text_id = nextlongtextsequence(0)
   SET insert_result = insert_long_text_ref(quest_text_id,request->add[i].question,"PROT_ELIG_QUEST",
    request->prot_questionnaire_id)
   IF (insert_result=false)
    SET failed = true
    SET reply->status_data.reason_for_failure = "Cannot insert question into long_text_reference."
    GO TO exit_script
   ENDIF
   SET reply->qual[i].prot_elig_quest_id = nextsequence(0)
   IF ((reply->qual[i].prot_elig_quest_id=0))
    SET failed = true
    SET reply->status_data.reason_for_failure = "Cannot get new id."
    GO TO exit_script
   ENDIF
   INSERT  FROM prot_elig_quest peq
    SET peq.prot_elig_quest_id = reply->qual[i].prot_elig_quest_id, peq.answer_format_id = request->
     add[i].answer_format_id, peq.desired_value = request->add[i].desired_value,
     peq.prot_questionnaire_id = request->prot_questionnaire_id, peq.elig_quest_nbr = request->add[i]
     .prot_elig_quest_nbr, peq.value_required_flag = request->add[i].val_reqd_flag,
     peq.date_required_flag = request->add[i].dt_reqd_flag, peq.quest_type_ind = request->add[i].
     quest_type_ind, peq.prev_prot_elig_quest_id = reply->qual[i].prot_elig_quest_id,
     peq.beg_effective_dt_tm = cnvtdatetime(script_date), peq.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), peq.updt_dt_tm = cnvtdatetime(sysdate),
     peq.updt_id = reqinfo->updt_id, peq.updt_task = reqinfo->updt_task, peq.updt_applctx = reqinfo->
     updt_applctx,
     peq.updt_cnt = 0, peq.long_text_id = quest_text_id
    WITH nocounter
   ;end insert
   SET reply->qual[i].quest_type_ind = request->add[i].quest_type_ind
   IF (curqual=0)
    SET failed = true
    SET reply->status_data.reason_for_failure = "Cannot insert question"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (curqual=0)
  SET failed = true
 ENDIF
#exit_script
 IF (failed=true)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "005"
 SET mod_date = "July 21, 2009"
END GO
