CREATE PROGRAM ct_import_questionnaires:dba
 RECORD reply(
   1 questionnaires[*]
     2 prot_questionnaire_id = f8
     2 status_msg = vc
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
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
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE existing_questionnaire_name = c255 WITH private, noconstant(fillstring(255," "))
 DECLARE existing_questionnaire_id = f8 WITH protect, noconstant(0.0)
 DECLARE peq_id = f8 WITH protect, noconstant(0.0)
 DECLARE temp_seq = f8 WITH protect, noconstant(0.0)
 DECLARE questionnaire_count = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE failed = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "S"
 SET questionnaire_count = size(request->questionnaires,5)
 SET stat = alterlist(reply->questionnaires,questionnaire_count)
 FOR (i = 1 TO questionnaire_count)
   SET peq_id = 0.0
   SELECT INTO "nl:"
    pq1.prot_questionnaire_id
    FROM prot_questionnaire pq1,
     prot_questionnaire pq2
    PLAN (pq1
     WHERE (pq1.prot_questionnaire_id=request->questionnaires[i].prot_questionnaire_id))
     JOIN (pq2
     WHERE (pq2.prot_amendment_id=request->prot_amendment_id)
      AND pq2.questionnaire_type_cd=pq1.questionnaire_type_cd
      AND pq1.questionnaire_name=pq2.questionnaire_name)
    DETAIL
     existing_questionnaire_id = pq2.prot_questionnaire_id, existing_questionnaire_name = pq2
     .questionnaire_name
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = 1
    SET reply->status_data.reason_for_failure = "questionnaire already exists"
    SET reply->questionnaires[i].status_msg = build(
     "Questionnaire already exists - Questionnaire id AND name:",existing_questionnaire_id)
    SET reply->questionnaires[i].status_msg = build(reply->questionnaires[i].status_msg,
     existing_questionnaire_name)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    temp_seq = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     reply->questionnaires[i].prot_questionnaire_id = temp_seq
    WITH format, counter
   ;end select
   INSERT  FROM prot_questionnaire pq
    (pq.prot_questionnaire_id, pq.questionnaire_type_cd, pq.questionnaire_name,
    pq.prot_amendment_id, pq.prev_prot_questionnaire_id, pq.beg_effective_dt_tm,
    pq.end_effective_dt_tm, updt_dt_tm, updt_id,
    updt_task, updt_applctx, updt_cnt)(SELECT
     reply->questionnaires[i].prot_questionnaire_id, pq1.questionnaire_type_cd, pq1
     .questionnaire_name,
     request->prot_amendment_id, reply->questionnaires[i].prot_questionnaire_id, 1,
     cnvtdatetime(script_date), cnvtdatetime("31-DEC-2100 00:00:00.00"), cnvtdatetime(curdate,
      curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM prot_questionnaire pq1
     WHERE (pq1.prot_questionnaire_id=request->questionnaires[i].prot_questionnaire_id))
   ;end insert
   IF (curqual=0)
    SET failed = 1
    SET reply->status_data.reason_for_failure = "Cannot create new questionnaire"
    SET reply->questionnaires[i].status_msg = build("Cannot create new questionnaire",reply->
     questionnaires[i].prot_questionnaire_id)
    GO TO exit_script
   ENDIF
   SET cnt = 0
   SELECT
    peq1.answer_format_id
    FROM prot_elig_quest peq1
    WHERE (peq1.prot_questionnaire_id=request->questionnaires[i].prot_questionnaire_id)
     AND peq1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(questions_rec->questions,(cnt+ 10))
     ENDIF
     questions_rec->questions[cnt].answer_format_id = peq1.answer_format_id, questions_rec->
     questions[cnt].question = peq1.question, questions_rec->questions[cnt].desired_value = peq1
     .desired_value,
     questions_rec->questions[cnt].elig_quest_nbr = peq1.elig_quest_nbr, questions_rec->questions[cnt
     ].value_required_flag = peq1.value_required_flag, questions_rec->questions[cnt].
     date_required_flag = peq1.date_required_flag,
     questions_rec->questions[cnt].quest_type_ind = peq1.quest_type_ind
    WITH nocounter
   ;end select
   SET stat = alterlist(questions_rec->questions,cnt)
   FOR (j = 1 TO cnt)
     SELECT INTO "nl:"
      temp_seq = seq(protocol_def_seq,nextval)
      FROM dual
      DETAIL
       peq_id = temp_seq
      WITH format, counter
     ;end select
     INSERT  FROM prot_elig_quest peq
      SET peq.answer_format_id = questions_rec->questions[j].answer_format_id, peq.question =
       questions_rec->questions[j].question, peq.desired_value = questions_rec->questions[j].
       desired_value,
       peq.elig_quest_nbr = questions_rec->questions[j].elig_quest_nbr, peq.value_required_flag =
       questions_rec->questions[j].value_required_flag, peq.date_required_flag = questions_rec->
       questions[j].date_required_flag,
       peq.quest_type_ind = questions_rec->questions[j].quest_type_ind, peq.prot_elig_quest_id =
       peq_id, peq.prot_questionnaire_id = reply->questionnaires[i].prot_questionnaire_id,
       peq.prev_prot_elig_quest_id = peq_id, peq.beg_effective_dt_tm = cnvtdatetime(script_date), peq
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
       peq.updt_dt_tm = cnvtdatetime(curdate,curtime3), peq.updt_id = reqinfo->updt_id, peq.updt_task
        = reqinfo->updt_task,
       peq.updt_applctx = reqinfo->updt_applctx, peq.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = 1
      SET reply->status_data.reason_for_failure = "Cannot add questions to new questionnaire "
      SET reply->questionnaires[i].status_msg = build(
       "Cannot add questions to new questionnaire - Questionnaire id AND name:",reply->
       questionnaires[i].prot_questionnaire_id)
      SET reply->questionnaires[i].status_msg = build(reply->questionnaires[i].status_msg,peq_id)
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
 GO TO exit_script
#exit_script
 IF (failed=1)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "001"
 SET mod_date = "August 13, 2007"
END GO
