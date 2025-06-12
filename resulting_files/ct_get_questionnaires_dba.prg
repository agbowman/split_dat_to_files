CREATE PROGRAM ct_get_questionnaires:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 questionnaires[*]
      2 prot_questionnaire_id = f8
      2 questionnaire_name = vc
      2 questionnaire_type_cd = f8
      2 questionnaire_type_disp = vc
      2 questionnaire_type_desc = vc
      2 questionnaire_type_mean = vc
      2 special_inst_text = vc
      2 special_inst_long_text_id = f8
      2 desc_text = vc
      2 desc_long_text_id = f8
    1 amendment_nbr = i4
    1 amendment_id = f8
    1 prot_status_disp = c30
    1 prot_status_mean = c30
    1 prot_mnemonic = vc
    1 prot_master_id = f8
    1 participation_type_cd = f8
    1 participation_type_disp = c50
    1 participation_type_desc = c50
    1 participation_type_mean = c12
    1 revision_nbr_text = c30
    1 revision_ind = i2
    1 revision_seq = i4
    1 parent_amendment_id = f8
    1 enrolling_questionnaire_id = f8
    1 enrolling_questionnaire_name = vc
    1 eligqns[*]
      2 prot_elig_quest_id = f8
      2 question = vc
      2 elig_quest_nbr = i4
      2 desired_value = c1
      2 format_label = c30
      2 domain_label = c30
      2 answer_format_id = f8
      2 dt_reqd_flag = i2
      2 val_reqd_flag = i2
    1 infqns[*]
      2 prot_elig_quest_id = f8
      2 question = vc
      2 elig_quest_nbr = i4
      2 desired_value = c1
      2 format_label = c30
      2 domain_label = c30
      2 answer_format_id = f8
      2 dt_reqd_flag = i2
      2 val_reqd_flag = i2
    1 enrollment_attempted = i2
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
 SET modify = predeclare
 DECLARE eligqncnt = i2 WITH protect, noconstant(0)
 DECLARE infqncnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE eligibility_qn = i2 WITH protect, noconstant(1)
 DECLARE questionnairecnt = i2 WITH protect, noconstant(0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE checklist_count = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_questionnaire_cnt = i2 WITH protect, noconstant(0)
 DECLARE bfoundspecialinst = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "S"
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SELECT INTO "nl:"
  p_am.prot_amendment_id
  FROM prot_amendment p_am,
   prot_master pm
  PLAN (p_am
   WHERE (p_am.prot_amendment_id=request->prot_amendment_id)
    AND p_am.prot_amendment_id != 0)
   JOIN (pm
   WHERE pm.prot_master_id=p_am.prot_master_id)
  DETAIL
   IF (p_am.revision_ind=1)
    reply->revision_nbr_text = p_am.revision_nbr_txt, reply->revision_ind = p_am.revision_ind, reply
    ->revision_seq = p_am.revision_seq,
    reply->parent_amendment_id = p_am.parent_amendment_id
   ENDIF
   reply->amendment_nbr = p_am.amendment_nbr, reply->amendment_id = p_am.prot_amendment_id, reply->
   prot_master_id = p_am.prot_master_id,
   reply->prot_status_disp = uar_get_code_display(p_am.amendment_status_cd), reply->prot_status_mean
    = trim(uar_get_code_meaning(p_am.amendment_status_cd)), reply->prot_mnemonic = pm
   .primary_mnemonic,
   reply->participation_type_cd = p_am.participation_type_cd
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET bfoundspecialinst = 0
 SET reply->enrolling_questionnaire_id = 0
 SELECT INTO "nl:"
  pq.prot_questionnaire_id
  FROM prot_questionnaire pq,
   long_text_reference ltr
  PLAN (pq
   WHERE (pq.prot_amendment_id=request->prot_amendment_id)
    AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(pq.desc_long_text_id))
  DETAIL
   questionnairecnt = (questionnairecnt+ 1)
   IF (mod(questionnairecnt,10)=1)
    stat = alterlist(reply->questionnaires,(questionnairecnt+ 9))
   ENDIF
   reply->questionnaires[questionnairecnt].prot_questionnaire_id = pq.prot_questionnaire_id, reply->
   questionnaires[questionnairecnt].questionnaire_type_cd = pq.questionnaire_type_cd, reply->
   questionnaires[questionnairecnt].questionnaire_name = pq.questionnaire_name
   IF (pq.questionnaire_type_cd=enrolling_cd)
    reply->enrolling_questionnaire_id = pq.prot_questionnaire_id, reply->enrolling_questionnaire_name
     = pq.questionnaire_name
   ENDIF
   IF (pq.desc_long_text_id > 0)
    reply->questionnaires[questionnairecnt].desc_text = ltr.long_text, reply->questionnaires[
    questionnairecnt].desc_long_text_id = pq.desc_long_text_id
   ENDIF
   IF (pq.special_inst_long_text_id > 0)
    reply->questionnaires[questionnairecnt].special_inst_long_text_id = pq.special_inst_long_text_id,
    bfoundspecialinst = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->questionnaires,questionnairecnt)
 CALL echo(build("curqual for quests are ",curqual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (bfoundspecialinst=1)
  SET loop_cnt = ceil((cnvtreal(questionnairecnt)/ batch_size))
  SET new_questionnaire_cnt = (batch_size * loop_cnt)
  SET stat = alterlist(reply->questionnaires,new_questionnaire_cnt)
  FOR (i = (questionnairecnt+ 1) TO new_questionnaire_cnt)
    SET reply->questionnaires[i].special_inst_long_text_id = reply->questionnaires[questionnairecnt].
    special_inst_long_text_id
  ENDFOR
  SELECT INTO "nl:"
   FROM long_text_reference ltr,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ltr
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),ltr.long_text_id,reply->questionnaires[num].
     special_inst_long_text_id))
   DETAIL
    index = locateval(num,1,questionnairecnt,ltr.long_text_id,reply->questionnaires[num].
     special_inst_long_text_id)
    IF (ltr.long_text_id > 0)
     reply->questionnaires[index].special_inst_text = ltr.long_text
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->questionnaires,questionnairecnt)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->getquestions_ind != 1))
  IF ((reply->enrolling_questionnaire_id > 0))
   SELECT INTO "nl:"
    peq.prot_elig_quest_id
    FROM prot_elig_quest peq,
     answer_format af,
     answer_domain ad,
     long_text_reference ltr
    PLAN (peq
     WHERE (peq.prot_questionnaire_id=reply->enrolling_questionnaire_id)
      AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (af
     WHERE af.answer_format_id=peq.answer_format_id)
     JOIN (ad
     WHERE ad.answer_domain_id=af.answer_domain_id)
     JOIN (ltr
     WHERE ltr.long_text_id=peq.long_text_id)
    ORDER BY peq.elig_quest_nbr
    DETAIL
     IF (peq.quest_type_ind=eligibility_qn)
      eligqncnt = (eligqncnt+ 1)
      IF (eligqncnt > size(reply->eligqns,5))
       stat = alterlist(reply->eligqns,(eligqncnt+ 10))
      ENDIF
      reply->eligqns[eligqncnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->eligqns[eligqncnt
      ].question = ltr.long_text, reply->eligqns[eligqncnt].elig_quest_nbr = peq.elig_quest_nbr,
      reply->eligqns[eligqncnt].desired_value = peq.desired_value, reply->eligqns[eligqncnt].
      format_label = af.format_label, reply->eligqns[eligqncnt].domain_label = ad.answer_domain_label,
      reply->eligqns[eligqncnt].answer_format_id = peq.answer_format_id, reply->eligqns[eligqncnt].
      val_reqd_flag = peq.value_required_flag, reply->eligqns[eligqncnt].dt_reqd_flag = peq
      .date_required_flag
     ELSE
      infqncnt = (infqncnt+ 1)
      IF (infqncnt > size(reply->infqns,5))
       stat = alterlist(reply->infqns,(infqncnt+ 10))
      ENDIF
      reply->infqns[infqncnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->infqns[infqncnt].
      question = ltr.long_text, reply->infqns[infqncnt].elig_quest_nbr = peq.elig_quest_nbr,
      reply->infqns[infqncnt].desired_value = peq.desired_value, reply->infqns[infqncnt].format_label
       = af.format_label, reply->infqns[infqncnt].domain_label = ad.answer_domain_label,
      reply->infqns[infqncnt].answer_format_id = peq.answer_format_id, reply->infqns[infqncnt].
      val_reqd_flag = peq.value_required_flag, reply->infqns[infqncnt].dt_reqd_flag = peq
      .date_required_flag
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->eligqns,eligqncnt)
   SET stat = alterlist(reply->infqns,infqncnt)
  ENDIF
  CALL echo("before checking status")
  CALL echo(build("curqual for questions are ",curqual))
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSEIF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("After checking status")
 SELECT INTO "nl:"
  FROM pt_elig_result per
  WHERE (per.prot_amendment_id=request->prot_amendment_id)
   AND per.active_ind > 0
 ;end select
 IF (curqual > 0)
  SET reply->enrollment_attempted = 1
  CALL echo(" eligibility attempted")
 ELSE
  SET reply->enrollment_attempted = 0
  CALL echo(" eligibility not attempted")
 ENDIF
#exit_script
 SET last_mod = "007"
 SET mod_date = "May 15, 2012"
END GO
