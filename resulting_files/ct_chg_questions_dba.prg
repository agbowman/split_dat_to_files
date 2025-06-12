CREATE PROGRAM ct_chg_questions:dba
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
 RECORD ins_prot_elig_quest(
   1 questions[*]
     2 prot_amendment_id = f8
     2 prot_questionnaire_id = f8
     2 answer_format_id = f8
     2 date_required_flag = i2
     2 desired_value = c1
     2 elig_quest_nbr = i4
     2 long_text_id = f8
     2 prev_prot_elig_quest_id = f8
     2 question = vc
     2 quest_type_ind = i2
     2 value_required_flag = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 ) WITH protect
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE insert_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE end_date = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_questionnaire_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 IF (size(request->questions,5) > 0)
  SET cnt = 0
  SELECT INTO "nl:"
   peq.prot_elig_quest_id
   FROM prot_elig_quest peq,
    (dummyt d  WITH seq = value(size(request->questions,5)))
   PLAN (d)
    JOIN (peq
    WHERE (peq.prot_elig_quest_id=request->questions[d.seq].prot_elig_quest_id))
   HEAD peq.prot_questionnaire_id
    prot_questionnaire_id = peq.prot_questionnaire_id
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(ins_prot_elig_quest->questions,(cnt+ 9))
    ENDIF
    ins_prot_elig_quest->questions[cnt].prot_amendment_id = peq.prot_amendment_id,
    ins_prot_elig_quest->questions[cnt].prot_questionnaire_id = peq.prot_questionnaire_id,
    ins_prot_elig_quest->questions[cnt].answer_format_id = peq.answer_format_id,
    ins_prot_elig_quest->questions[cnt].date_required_flag = peq.date_required_flag,
    ins_prot_elig_quest->questions[cnt].desired_value = peq.desired_value, ins_prot_elig_quest->
    questions[cnt].elig_quest_nbr = peq.elig_quest_nbr,
    ins_prot_elig_quest->questions[cnt].long_text_id = peq.long_text_id, ins_prot_elig_quest->
    questions[cnt].prev_prot_elig_quest_id = peq.prev_prot_elig_quest_id, ins_prot_elig_quest->
    questions[cnt].question = peq.question,
    ins_prot_elig_quest->questions[cnt].quest_type_ind = peq.quest_type_ind, ins_prot_elig_quest->
    questions[cnt].value_required_flag = peq.value_required_flag, ins_prot_elig_quest->questions[cnt]
    .beg_effective_dt_tm = peq.beg_effective_dt_tm,
    ins_prot_elig_quest->questions[cnt].end_effective_dt_tm = cnvtdatetime(script_date),
    ins_prot_elig_quest->questions[cnt].updt_applctx = peq.updt_applctx, ins_prot_elig_quest->
    questions[cnt].updt_cnt = peq.updt_cnt,
    ins_prot_elig_quest->questions[cnt].updt_dt_tm = peq.updt_dt_tm, ins_prot_elig_quest->questions[
    cnt].updt_id = peq.updt_id, ins_prot_elig_quest->questions[cnt].updt_task = peq.updt_task
   WITH nocounter, forupdate(peq)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error locking prot_elig_quest table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  SET stat = alterlist(ins_prot_elig_quest->questions,cnt)
  CALL echo(build("Going to insert this many new questions: ",cnt))
  CALL echorecord(ins_prot_elig_quest)
  FOR (idx = 1 TO size(request->questions,5))
   IF ((request->questions[idx].delete_ind=1))
    SET end_date = cnvtdatetime(script_date)
    UPDATE  FROM prot_elig_quest peq
     SET peq.beg_effective_dt_tm = cnvtdatetime(script_date), peq.end_effective_dt_tm = cnvtdatetime(
       end_date), peq.updt_id = reqinfo->updt_id,
      peq.updt_applctx = reqinfo->updt_applctx, peq.updt_cnt = (peq.updt_cnt+ 1), peq.updt_id =
      reqinfo->updt_id,
      peq.updt_task = reqinfo->updt_task, peq.updt_dt_tm = cnvtdatetime(script_date)
     WHERE (peq.prot_elig_quest_id=request->questions[idx].prot_elig_quest_id)
     WITH nocounter
    ;end update
   ELSE
    SELECT INTO "nl:"
     temp_seq = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = temp_seq
     WITH nocounter
    ;end select
    INSERT  FROM long_text_reference ltr
     SET ltr.long_text_id = long_text_id, ltr.long_text = request->questions[idx].question, ltr
      .parent_entity_name = "PROT_ELIG_QUEST",
      ltr.parent_entity_id = prot_questionnaire_id, ltr.updt_dt_tm = cnvtdatetime(script_date), ltr
      .updt_id = reqinfo->updt_id,
      ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
      ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm
       = cnvtdatetime(script_date),
      ltr.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    UPDATE  FROM prot_elig_quest peq
     SET peq.desired_value = request->questions[idx].desired_value, peq.answer_format_id = request->
      questions[idx].answer_format_id, peq.elig_quest_nbr = request->questions[idx].elig_quest_nbr,
      peq.value_required_flag = request->questions[idx].value_required_flag, peq.date_required_flag
       = request->questions[idx].date_required_flag, peq.long_text_id = long_text_id,
      peq.beg_effective_dt_tm = cnvtdatetime(script_date), peq.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), peq.updt_id = reqinfo->updt_id,
      peq.updt_applctx = reqinfo->updt_applctx, peq.updt_cnt = (peq.updt_cnt+ 1), peq.updt_id =
      reqinfo->updt_id,
      peq.updt_task = reqinfo->updt_task, peq.updt_dt_tm = cnvtdatetime(script_date)
     WHERE (peq.prot_elig_quest_id=request->questions[idx].prot_elig_quest_id)
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating pt_prot_reg table."
    SET fail_flag = update_error
    GO TO check_error
   ENDIF
  ENDFOR
  INSERT  FROM prot_elig_quest peq,
    (dummyt d  WITH seq = value(size(ins_prot_elig_quest->questions,5)))
   SET peq.prot_elig_quest_id = cnvtreal(seq(protocol_def_seq,nextval)), peq.prot_questionnaire_id =
    ins_prot_elig_quest->questions[d.seq].prot_questionnaire_id, peq.prot_amendment_id =
    ins_prot_elig_quest->questions[d.seq].prot_amendment_id,
    peq.beg_effective_dt_tm = cnvtdatetime(ins_prot_elig_quest->questions[d.seq].beg_effective_dt_tm),
    peq.end_effective_dt_tm = cnvtdatetime(ins_prot_elig_quest->questions[d.seq].end_effective_dt_tm),
    peq.answer_format_id = ins_prot_elig_quest->questions[d.seq].answer_format_id,
    peq.date_required_flag = ins_prot_elig_quest->questions[d.seq].date_required_flag, peq
    .desired_value = ins_prot_elig_quest->questions[d.seq].desired_value, peq.elig_quest_nbr =
    ins_prot_elig_quest->questions[d.seq].elig_quest_nbr,
    peq.long_text_id = ins_prot_elig_quest->questions[d.seq].long_text_id, peq
    .prev_prot_elig_quest_id = ins_prot_elig_quest->questions[d.seq].prev_prot_elig_quest_id, peq
    .question = ins_prot_elig_quest->questions[d.seq].question,
    peq.quest_type_ind = ins_prot_elig_quest->questions[d.seq].quest_type_ind, peq
    .value_required_flag = ins_prot_elig_quest->questions[d.seq].value_required_flag, peq
    .updt_applctx = ins_prot_elig_quest->questions[d.seq].updt_applctx,
    peq.updt_cnt = ins_prot_elig_quest->questions[d.seq].updt_cnt, peq.updt_dt_tm = cnvtdatetime(
     ins_prot_elig_quest->questions[d.seq].updt_dt_tm), peq.updt_id = ins_prot_elig_quest->questions[
    d.seq].updt_id,
    peq.updt_task = ins_prot_elig_quest->questions[d.seq].updt_task
   PLAN (d)
    JOIN (peq)
   WITH nocounter
  ;end insert
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
 FREE RECORD ins_prot_elig_quest
 SET last_mod = "000"
 SET mod_date = "August 13, 2007"
END GO
