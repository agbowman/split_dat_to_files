CREATE PROGRAM ct_copy_questionnaires:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 questionnaires[*]
      2 prot_questionnaire_id = f8
      2 status_msg = vc
    1 status_data
      2 status = c1
      2 reason_for_failure = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 RECORD questions_rec(
   1 questions[*]
     2 answer_format_id = f8
     2 question = vc
     2 desired_value = c1
     2 elig_quest_nbr = i4
     2 value_required_flag = i2
     2 date_required_flag = i2
     2 quest_type_ind = i2
 )
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE j = i2 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE existing_questionnaire_id = f8 WITH protect, noconstant(0.0)
 DECLARE existing_questionnaire_name = vc WITH protect, noconstant("")
 DECLARE copy_questionnaire_name = vc WITH protect, noconstant("")
 DECLARE copy_questionnaire_type = f8 WITH protect, noconstant(0.0)
 DECLARE copy_questionnaire_desc = vc WITH protect, noconstant("")
 DECLARE copy_questionnaire_special_instr = vc WITH protect, noconstant("")
 DECLARE special_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE desc_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_desc_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_special_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE peq_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE insert_result = i2 WITH protect
 DECLARE questionnaire_count = i2 WITH protect, noconstant(0)
 SET insert_result = false
 SET reply->status_data.status = "S"
 SET questionnaire_count = size(request->questionnaires,5)
 SET stat = alterlist(reply->questionnaires,questionnaire_count)
 FOR (i = 1 TO questionnaire_count)
   SET peq_id = 0.0
   SET special_instr_id = 0.0
   SET desc_id = 0.0
   SET reply->questionnaires[i].prot_questionnaire_id = nextsequence(0)
   SELECT INTO "nl:"
    FROM prot_questionnaire pq1,
     long_text_reference ltr
    PLAN (pq1
     WHERE (pq1.prot_questionnaire_id=request->questionnaires[i].prot_questionnaire_id))
     JOIN (ltr
     WHERE (ltr.long_text_id= Outerjoin(pq1.desc_long_text_id)) )
    DETAIL
     copy_questionnaire_type = pq1.questionnaire_type_cd, copy_questionnaire_name = pq1
     .questionnaire_name
     IF (pq1.desc_long_text_id > 0)
      copy_questionnaire_desc = ltr.long_text, desc_id = pq1.desc_long_text_id
     ELSE
      copy_questionnaire_desc = "", desc_id = 0.0
     ENDIF
     IF (pq1.special_inst_long_text_id > 0)
      special_instr_id = pq1.special_inst_long_text_id
     ENDIF
     CALL echo(build("copy_questionnaire_type",copy_questionnaire_type)),
     CALL echo(build("copy_questionnaire_name",copy_questionnaire_name)),
     CALL echo(build("copy_questionnaire_desc",copy_questionnaire_desc)),
     CALL echo(build("desc_id",desc_id)),
     CALL echo(build("special_instr_id",special_instr_id))
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("F",build("Cannot create new questionnaire",reply->questionnaires[i].
      prot_questionnaire_id),i)
    GO TO exit_script
   ENDIF
   SET new_special_inst_id = 0.0
   IF (special_instr_id > 0.0)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=special_instr_id
     DETAIL
      copy_questionnaire_special_instr = ltr.long_text,
      CALL echo(build("copy_questionnaire_special_instr",copy_questionnaire_special_instr))
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL report_failure("F",build("Cannot find checklist special instructions - ",reply->
       questionnaires[i].prot_questionnaire_id),i)
     GO TO exit_script
    ENDIF
    SET new_special_inst_id = nextlongtextsequence(0)
    IF (new_special_inst_id=0)
     CALL report_failure("F",build("Cannot get new special instructions id - ",reply->questionnaires[
       i].prot_questionnaire_id),i)
     GO TO exit_script
    ENDIF
    SET insert_result = false
    SET insert_result = insert_long_text_ref(new_special_inst_id,copy_questionnaire_special_instr,
     "PROT_QUESTIONNAIRE",reply->questionnaires[i].prot_questionnaire_id)
    IF (insert_result=false)
     CALL report_failure("F",build(
       "Cannot insert special instructions into long_text_reference table - ",reply->questionnaires[i
       ].prot_questionnaire_id),i)
     GO TO exit_script
    ENDIF
    CALL echo(build("new special inst id",new_special_inst_id))
   ENDIF
   SET new_desc_id = 0.0
   IF (desc_id > 0.0)
    SET new_desc_id = nextlongtextsequence(0)
    IF (new_desc_id=0)
     CALL report_failure("F",build("Cannot get new special instructions id - ",reply->questionnaires[
       i].prot_questionnaire_id),i)
     GO TO exit_script
    ENDIF
    SET insert_result = false
    SET insert_result = insert_long_text_ref(new_desc_id,copy_questionnaire_desc,"PROT_QUESTIONNAIRE",
     reply->questionnaires[i].prot_questionnaire_id)
    IF (insert_result=false)
     CALL report_failure("F",build("Cannot insert description into long_text_reference table - ",
       reply->questionnaires[i].prot_questionnaire_id),i)
     GO TO exit_script
    ENDIF
    CALL echo(build("new special inst id",new_special_inst_id))
   ENDIF
   INSERT  FROM prot_questionnaire pq
    SET pq.prot_questionnaire_id = reply->questionnaires[i].prot_questionnaire_id, pq
     .questionnaire_type_cd = copy_questionnaire_type, pq.questionnaire_name =
     copy_questionnaire_name,
     pq.prot_amendment_id = request->prot_amendment_id, pq.prev_prot_questionnaire_id = reply->
     questionnaires[i].prot_questionnaire_id, pq.beg_effective_dt_tm = cnvtdatetime(sysdate),
     pq.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pq.special_inst_long_text_id =
     IF (new_special_inst_id > 0) new_special_inst_id
     ELSE 0.0
     ENDIF
     , pq.desc_long_text_id =
     IF (new_desc_id > 0) new_desc_id
     ELSE 0.0
     ENDIF
     ,
     pq.updt_dt_tm = cnvtdatetime(sysdate), pq.updt_id = reqinfo->updt_id, pq.updt_task = reqinfo->
     updt_task,
     pq.updt_applctx = reqinfo->updt_applctx, pq.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("F",build("Cannot create new questionnaire - ",reply->questionnaires[i].
      prot_questionnaire_id),i)
    GO TO exit_script
   ENDIF
   SET cnt = 0
   SELECT
    peq1.answer_format_id
    FROM prot_elig_quest peq1,
     long_text_reference ltr
    PLAN (peq1
     WHERE (peq1.prot_questionnaire_id=request->questionnaires[i].prot_questionnaire_id)
      AND peq1.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ltr
     WHERE ltr.long_text_id=peq1.long_text_id)
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1)
      new = (cnt+ 10), stat = alterlist(questions_rec->questions,new)
     ENDIF
     questions_rec->questions[cnt].answer_format_id = peq1.answer_format_id, questions_rec->
     questions[cnt].question = ltr.long_text, questions_rec->questions[cnt].desired_value = peq1
     .desired_value,
     questions_rec->questions[cnt].elig_quest_nbr = peq1.elig_quest_nbr, questions_rec->questions[cnt
     ].value_required_flag = peq1.value_required_flag, questions_rec->questions[cnt].
     date_required_flag = peq1.date_required_flag,
     questions_rec->questions[cnt].quest_type_ind = peq1.quest_type_ind
    WITH nocounter
   ;end select
   SET stat = alterlist(questions_rec->questions,cnt)
   FOR (j = 1 TO cnt)
     SET peq_id = nextsequence(0)
     IF (peq_id=0)
      CALL report_failure("F",build("Cannot get new question id. - ",peq_id,i))
      GO TO exit_script
     ENDIF
     SET insert_result = false
     SET insert_result = insert_long_text_ref(0.0,questions_rec->questions[j].question,
      "PROT_ELIG_QUEST",reply->questionnaires[i].prot_questionnaire_id)
     IF (insert_result=false)
      CALL report_failure("F",build("Cannot insert question into long_text_ref. - ",peq_id,i))
      GO TO exit_script
     ENDIF
     INSERT  FROM prot_elig_quest peq
      SET peq.beg_effective_dt_tm = cnvtdatetime(sysdate), peq.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), peq.answer_format_id = questions_rec->questions[j].answer_format_id,
       peq.long_text_id = seq(long_data_seq,currval), peq.desired_value = questions_rec->questions[j]
       .desired_value, peq.elig_quest_nbr = questions_rec->questions[j].elig_quest_nbr,
       peq.value_required_flag = questions_rec->questions[j].value_required_flag, peq
       .date_required_flag = questions_rec->questions[j].date_required_flag, peq.quest_type_ind =
       questions_rec->questions[j].quest_type_ind,
       peq.prot_elig_quest_id = peq_id, peq.prev_prot_elig_quest_id = peq_id, peq
       .prot_questionnaire_id = reply->questionnaires[i].prot_questionnaire_id,
       peq.updt_dt_tm = cnvtdatetime(sysdate), peq.updt_id = reqinfo->updt_id, peq.updt_task =
       reqinfo->updt_task,
       peq.updt_applctx = reqinfo->updt_applctx, peq.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("F",build(
        "Cannot add questions to new questionnaire - Questionnaire id and name:",reply->
        questionnaires[i].prot_questionnaire_id,peq_id),i)
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE (report_failure(opstatus=c1,statusmsg=vc,index=i2) =null)
  IF (opstatus="F")
   SET failed = 1
  ENDIF
  SET reply->questionnaires[index].status_msg = trim(statusmsg)
 END ;Subroutine
#exit_script
 IF (failed=1)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "006"
 SET mod_date = "Feb 14, 2017"
 CALL echo(build("Status:",reply->status_data.status))
END GO
