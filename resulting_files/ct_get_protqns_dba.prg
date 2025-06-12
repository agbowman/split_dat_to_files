CREATE PROGRAM ct_get_protqns:dba
 RECORD reply(
   1 amendment_nbr = i4
   1 amendment_id = f8
   1 prot_status_disp = c30
   1 prot_status_mean = c30
   1 prot_mnemonic = vc
   1 prot_master_id = f8
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
   1 enroll_attempted_ind = i2
   1 associated_with_consent_ind = i2
   1 only_checklist_associated_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE eligqncnt = i4 WITH protect, noconstant(0)
 DECLARE infqncnt = i4 WITH protect, noconstant(0)
 DECLARE failed = i4 WITH private, noconstant(0)
 DECLARE eligibility_qn = i4 WITH protect, noconstant(1)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nstat = i2 WITH public, noconstant(0)
 SET nstat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p_am.prot_amendment_id
  FROM prot_questionnaire q,
   prot_amendment p_am,
   prot_master pm,
   questionnaire_doc_reltn qdr
  PLAN (q
   WHERE (q.prot_questionnaire_id=request->prot_questionnaire_id))
   JOIN (p_am
   WHERE p_am.prot_amendment_id=q.prot_amendment_id
    AND p_am.prot_amendment_id != 0)
   JOIN (pm
   WHERE pm.prot_master_id=p_am.prot_master_id)
   JOIN (qdr
   WHERE qdr.prot_questionnaire_id=outerjoin(q.prot_questionnaire_id))
  DETAIL
   reply->amendment_nbr = p_am.amendment_nbr, reply->amendment_id = p_am.prot_amendment_id, reply->
   prot_master_id = p_am.prot_master_id,
   reply->prot_status_disp = uar_get_code_display(p_am.amendment_status_cd), reply->prot_status_mean
    = trim(uar_get_code_meaning(p_am.amendment_status_cd)), reply->prot_mnemonic = pm
   .primary_mnemonic,
   CALL echo(build("QDR.questionnaire_doc_id = ",qdr.questionnaire_doc_id))
   IF (qdr.questionnaire_doc_id > 0)
    reply->associated_with_consent_ind = 1
   ELSE
    reply->associated_with_consent_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  peq.prot_elig_quest_id
  FROM prot_elig_quest peq,
   answer_format af,
   answer_domain ad,
   long_text_reference ltr
  PLAN (peq
   WHERE (peq.prot_questionnaire_id=request->prot_questionnaire_id)
    AND peq.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
    reply->eligqns[eligqncnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->eligqns[eligqncnt].
    question = ltr.long_text, reply->eligqns[eligqncnt].elig_quest_nbr = peq.elig_quest_nbr,
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
 SET stat = alterlist(reply->infqns,infqncnt)
 SET stat = alterlist(reply->eligqns,eligqncnt)
 CALL echo("before checking status")
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 CALL echo("After checking status")
 SET reply->enroll_attempted_ind = 0
 SELECT INTO "nl:"
  FROM pt_elig_result per,
   prot_elig_quest peq
  PLAN (per
   WHERE (per.prot_amendment_id=reply->amendment_id)
    AND per.active_ind > 0)
   JOIN (peq
   WHERE peq.prot_elig_quest_id=per.prot_elig_quest_id)
  DETAIL
   IF ((peq.prot_questionnaire_id=request->prot_questionnaire_id))
    reply->enroll_attempted_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->enrollment_attempted = 1
  CALL echo(" eligibility attempted")
 ELSE
  SET reply->enrollment_attempted = 0
  CALL echo(" eligibility not attempted")
 ENDIF
 IF ((reply->associated_with_consent_ind=1))
  SELECT
   pq.prot_questionnaire_id
   FROM prot_questionnaire pq,
    questionnaire_doc_reltn qdr
   PLAN (pq
    WHERE (pq.prot_amendment_id=reply->amendment_id)
     AND pq.questionnaire_type_cd=enrolling_cd
     AND (pq.prot_questionnaire_id != request->prot_questionnaire_id))
    JOIN (qdr
    WHERE qdr.prot_questionnaire_id=pq.prot_questionnaire_id)
   WITH nocounter
  ;end select
  IF (curqual > 1)
   SET reply->only_checklist_associated_ind = 0
  ELSE
   SET reply->only_checklist_associated_ind = 1
  ENDIF
 ENDIF
#exit_script
 SET last_mod = "006"
 SET mod_date = "May 17, 2012"
 CALL echo(build("Status:",reply->status_data.status))
END GO
