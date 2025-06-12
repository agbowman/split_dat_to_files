CREATE PROGRAM ct_rpt_questionnaire_drv:dba
 PROMPT
  "Pt_Elig_Tracking_Id" = "",
  "OutDev" = ""
  WITH pt_elig_tracking_id, outdev
 FREE RECORD request
 RECORD request(
   1 pt_elig_tracking_id = f8
 )
 RECORD questionnaire(
   1 pt_elig_tracking_id = f8
   1 prot_amendment_id = f8
   1 primary_mnemonic = vc
   1 patient_name = c100
   1 mrn = c200
   1 principal_invest[*]
     2 pi_name = vc
     2 name_len = i2
   1 cra[*]
     2 cra_name = vc
     2 name_len = i2
   1 primary_physician = c100
   1 elig_request_person = c100
   1 elig_review_person = c100
   1 record_dt_tm = dq8
   1 question_cnt = i2
   1 elig_question_cnt = i2
   1 info_question_cnt = i2
   1 elig_status_cd = f8
   1 last_elig_provide_person = c100
   1 elig_questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 question_nbr = i4
     2 desired_value = c1
     2 valid_ans = c255
     2 req_value = i2
     2 req_date = i2
     2 elig_indicator_cd = f8
     2 elig_indicator_disp = c40
     2 elig_indicator_mean = c12
     2 value = c255
     2 value_cd = f8
     2 value_disp = c40
     2 value_mean = c12
     2 specimen_test_dt_tm = dq8
     2 verified_specimen_test_dt_tm = dq8
     2 verified_elig_status_cd = f8
     2 verified_elig_status_disp = c40
     2 verified_elig_status_mean = c12
     2 audited_value = c255
     2 audited_value_cd = f8
     2 audited_value_disp = c40
     2 audited_value_mean = c12
     2 elig_provide_person_id = f8
     2 elig_provide_person = c100
   1 info_questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 question_nbr = i4
     2 desired_value = c1
     2 valid_ans = c255
     2 req_value = i2
     2 req_date = i2
     2 elig_indicator_cd = f8
     2 elig_indicator_disp = c40
     2 elig_indicator_mean = c12
     2 value = c255
     2 value_cd = f8
     2 value_disp = c40
     2 value_mean = c12
     2 specimen_test_dt_tm = dq8
     2 verified_specimen_test_dt_tm = dq8
     2 verified_elig_status_cd = f8
     2 verified_elig_status_disp = c40
     2 verified_elig_status_mean = c12
     2 audited_value = c255
     2 audited_value_cd = f8
     2 audited_value_disp = c40
     2 audited_value_mean = c12
     2 elig_provide_person_id = f8
     2 elig_provide_person = c100
   1 amd_rev_name = vc
   1 amd_irb_appr_dt = dq8
   1 checklist_name = vc
   1 notes[*]
     2 pt_elig_tracking_note_id = f8
     2 note_text = vc
     2 note_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_get_checklist_notes_request(
   1 pt_elig_tracking_id = f8
   1 note_type_cd = f8
 )
 RECORD ct_get_checklist_notes_reply(
   1 notes[*]
     2 pt_elig_tracking_note_id = f8
     2 note_text = vc
     2 note_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE elig_trkng_id = f8 WITH protect, noconstant(0.0)
 DECLARE question_cnt = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE pi_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cra_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pcp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE pi_cnt = i2 WITH protect, noconstant(0)
 DECLARE cra_cnt = i2 WITH protect, noconstant(0)
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE amd_str = vc WITH protect
 DECLARE rev_str = vc WITH protect
 SET questionnaire->status_data.status = "F"
 DECLARE get_prot_info = i2 WITH private, constant(1)
 DECLARE get_questions = i2 WITH private, constant(2)
 DECLARE get_pt_info = i2 WITH private, constant(3)
 DECLARE get_pi_cra_info = i2 WITH private, constant(4)
 DECLARE get_mrn_info = i2 WITH private, constant(5)
 CALL echo("checking prompt value")
 IF (( $PT_ELIG_TRACKING_ID != " "))
  SET elig_trkng_id = cnvtreal( $PT_ELIG_TRACKING_ID)
 ELSE
  SET elig_trkng_id = 0
 ENDIF
 CALL echo(build("elig_trkng_id:",elig_trkng_id))
 IF (elig_trkng_id > 0)
  SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
  SET stat = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
  SET stat = uar_get_meaning_by_codeset(331,"PCP",1,pcp_cd)
  SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
  SET questionnaire->pt_elig_tracking_id = elig_trkng_id
  CALL echo(elig_trkng_id)
  SELECT INTO "nl:"
   FROM pt_elig_tracking pet,
    prot_amendment pa,
    prot_master pm,
    prot_questionnaire pq,
    person p1,
    person p2,
    dummyt d1
   PLAN (pet
    WHERE pet.pt_elig_tracking_id=elig_trkng_id)
    JOIN (pq
    WHERE pq.prot_questionnaire_id=pet.prot_questionnaire_id)
    JOIN (pa
    WHERE pa.prot_amendment_id=pq.prot_amendment_id)
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
    JOIN (p1
    WHERE p1.person_id=pet.elig_request_person_id)
    JOIN (d1)
    JOIN (p2
    WHERE p2.person_id=pet.elig_review_person_id
     AND p2.person_id != 0.0)
   DETAIL
    questionnaire->record_dt_tm = pet.beg_effective_dt_tm, questionnaire->prot_amendment_id = pq
    .prot_amendment_id, questionnaire->elig_request_person = p1.name_full_formatted,
    questionnaire->elig_status_cd = pet.elig_status_cd
    IF (d1.seq > 0)
     questionnaire->elig_review_person = p2.name_full_formatted, bfound = 1
    ENDIF
    IF (pa.amendment_nbr=0)
     amd_str = "Initial Protocol"
    ELSE
     amd_str = build(pa.amendment_nbr), amd_str = concat("Amd ",amd_str)
    ENDIF
    IF (pa.revision_ind=1)
     amd_str = concat(amd_str," - "), rev_str = concat(" Rev ",trim(pa.revision_nbr_txt))
    ENDIF
    questionnaire->amd_rev_name = concat(amd_str,rev_str), questionnaire->primary_mnemonic = concat(
     trim(pm.primary_mnemonic)," - ",trim(questionnaire->amd_rev_name)), questionnaire->
    checklist_name = pq.questionnaire_name
   WITH nocounter, outerjoin = d1
  ;end select
  IF (bfound=0)
   SET questionnaire->elig_review_person = ""
  ENDIF
  IF (curqual=0)
   SET fail_flag = get_prot_info
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   FROM pt_elig_result per,
    prot_elig_quest peq,
    answer_format af,
    category_item ci,
    valid_answer_cat vac,
    long_text_reference ltr,
    person p
   PLAN (per
    WHERE per.pt_elig_tracking_id=elig_trkng_id)
    JOIN (p
    WHERE p.person_id=outerjoin(per.elig_value_provider_person_id))
    JOIN (peq
    WHERE peq.prot_elig_quest_id=per.prot_elig_quest_id
     AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (af
    WHERE af.answer_format_id=peq.answer_format_id)
    JOIN (vac
    WHERE vac.answer_format_id=peq.answer_format_id)
    JOIN (ci
    WHERE ci.category_item_id=vac.category_item_id)
    JOIN (ltr
    WHERE ltr.long_text_id=peq.long_text_id)
   ORDER BY peq.elig_quest_nbr
   HEAD REPORT
    total_cnt = 0, elig_cnt = 0, info_cnt = 0
   DETAIL
    total_cnt = (total_cnt+ 1)
    IF (peq.quest_type_ind=1)
     elig_cnt = (elig_cnt+ 1)
     IF (elig_cnt > size(questionnaire->elig_questions,5))
      stat = alterlist(questionnaire->elig_questions,(elig_cnt+ 10))
     ENDIF
     questionnaire->elig_questions[elig_cnt].prot_elig_quest_id = peq.prot_elig_quest_id,
     questionnaire->elig_questions[elig_cnt].question = ltr.long_text, questionnaire->elig_questions[
     elig_cnt].question_nbr = peq.elig_quest_nbr,
     questionnaire->elig_questions[elig_cnt].desired_value = peq.desired_value, questionnaire->
     elig_questions[elig_cnt].req_value = peq.value_required_flag, questionnaire->elig_questions[
     elig_cnt].req_date = peq.date_required_flag,
     questionnaire->elig_questions[elig_cnt].valid_ans = ci.category_item_text, questionnaire->
     elig_questions[elig_cnt].elig_indicator_cd = per.elig_indicator_cd, questionnaire->
     elig_questions[elig_cnt].value = per.value,
     questionnaire->elig_questions[elig_cnt].value_cd = per.value_cd, questionnaire->elig_questions[
     elig_cnt].specimen_test_dt_tm = per.specimen_test_dt_tm, questionnaire->elig_questions[elig_cnt]
     .verified_specimen_test_dt_tm = per.verified_specimen_test_dt_tm,
     questionnaire->elig_questions[elig_cnt].verified_elig_status_cd = per.verified_elig_status_cd,
     questionnaire->elig_questions[elig_cnt].audited_value = per.audited_value, questionnaire->
     elig_questions[elig_cnt].audited_value_cd = per.audited_value_cd,
     questionnaire->elig_questions[elig_cnt].elig_provide_person_id = per
     .elig_value_provider_person_id, questionnaire->elig_questions[elig_cnt].elig_provide_person = p
     .name_full_formatted, questionnaire->last_elig_provide_person = p.name_full_formatted
    ELSE
     info_cnt = (info_cnt+ 1)
     IF (info_cnt > size(questionnaire->info_questions,5))
      stat = alterlist(questionnaire->info_questions,(info_cnt+ 10))
     ENDIF
     questionnaire->info_questions[info_cnt].prot_elig_quest_id = peq.prot_elig_quest_id,
     questionnaire->info_questions[info_cnt].question = ltr.long_text, questionnaire->info_questions[
     info_cnt].question_nbr = peq.elig_quest_nbr,
     questionnaire->info_questions[info_cnt].desired_value = peq.desired_value, questionnaire->
     info_questions[info_cnt].req_value = peq.value_required_flag, questionnaire->info_questions[
     info_cnt].req_date = peq.date_required_flag,
     questionnaire->info_questions[info_cnt].valid_ans = ci.category_item_text, questionnaire->
     info_questions[info_cnt].elig_indicator_cd = per.elig_indicator_cd, questionnaire->
     info_questions[info_cnt].value = per.value,
     questionnaire->info_questions[info_cnt].value_cd = per.value_cd, questionnaire->info_questions[
     info_cnt].specimen_test_dt_tm = per.specimen_test_dt_tm, questionnaire->info_questions[info_cnt]
     .verified_specimen_test_dt_tm = per.verified_specimen_test_dt_tm,
     questionnaire->info_questions[info_cnt].verified_elig_status_cd = per.verified_elig_status_cd,
     questionnaire->info_questions[info_cnt].audited_value = per.audited_value, questionnaire->
     info_questions[info_cnt].audited_value_cd = per.audited_value_cd,
     questionnaire->info_questions[info_cnt].elig_provide_person_id = per
     .elig_value_provider_person_id, questionnaire->info_questions[info_cnt].elig_provide_person = p
     .name_full_formatted, questionnaire->last_elig_provide_person = p.name_full_formatted
    ENDIF
   FOOT REPORT
    questionnaire->question_cnt = total_cnt, questionnaire->elig_question_cnt = elig_cnt,
    questionnaire->info_question_cnt = info_cnt,
    stat = alterlist(questionnaire->elig_questions,elig_cnt), stat = alterlist(questionnaire->
     info_questions,info_cnt)
   WITH nocounter
  ;end select
  CALL echo(build("curqual in 2nd is: ",curqual))
  IF (curqual=0)
   SET fail_flag = get_questions
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   FROM pt_elig_tracking pet,
    person p,
    person_prsnl_reltn ppr,
    prsnl ps,
    dummyt d2,
    dummyt d3
   PLAN (pet
    WHERE pet.pt_elig_tracking_id=elig_trkng_id)
    JOIN (p
    WHERE p.person_id=pet.person_id)
    JOIN (d2)
    JOIN (ppr
    WHERE ppr.person_id=p.person_id
     AND ppr.person_prsnl_r_cd=pcp_cd)
    JOIN (d3)
    JOIN (ps
    WHERE ps.person_id=ppr.prsnl_person_id)
   DETAIL
    questionnaire->patient_name = p.name_full_formatted, questionnaire->primary_physician = ps
    .name_full_formatted
   WITH nocounter, dontcare = ppr, outerjoin = d3
  ;end select
  IF (curqual=0)
   SET fail_flag = get_pt_info
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   FROM prot_role pr,
    person p
   PLAN (pr
    WHERE (pr.prot_amendment_id=questionnaire->prot_amendment_id)
     AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pr.person_id)
   HEAD REPORT
    pi_cnt = 0, cra_cnt = 0
   DETAIL
    CASE (pr.prot_role_cd)
     OF pi_cd:
      pi_cnt = (pi_cnt+ 1),
      IF (pi_cnt > size(questionnaire->principal_invest,5))
       stat = alterlist(questionnaire->principal_invest,(pi_cnt+ 10))
      ENDIF
      ,questionnaire->principal_invest[pi_cnt].pi_name = p.name_full_formatted,questionnaire->
      principal_invest[pi_cnt].name_len = size(trim(questionnaire->principal_invest[pi_cnt].pi_name),
       1)
     OF cra_cd:
      cra_cnt = (cra_cnt+ 1),
      IF (cra_cnt > size(questionnaire->cra,5))
       stat = alterlist(questionnaire->cra,(cra_cnt+ 10))
      ENDIF
      ,questionnaire->cra[cra_cnt].cra_name = p.name_full_formatted,questionnaire->cra[cra_cnt].
      name_len = size(trim(questionnaire->cra[cra_cnt].cra_name),1)
    ENDCASE
   FOOT REPORT
    stat = alterlist(questionnaire->principal_invest,pi_cnt), stat = alterlist(questionnaire->cra,
     cra_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET fail_flag = get_pi_cra_info
   GO TO check_error
  ENDIF
  SELECT INTO "nl:"
   FROM pt_elig_tracking pet,
    person_alias pa
   PLAN (pet
    WHERE pet.pt_elig_tracking_id=elig_trkng_id)
    JOIN (pa
    WHERE pa.person_id=pet.person_id
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1)
   DETAIL
    questionnaire->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
   WITH nocounter
  ;end select
  SET ct_get_checklist_notes_request->pt_elig_tracking_id = elig_trkng_id
  EXECUTE ct_get_checklist_notes  WITH replace("REQUEST","CT_GET_CHECKLIST_NOTES_REQUEST"), replace(
   "REPLY","CT_GET_CHECKLIST_NOTES_REPLY")
  IF ((ct_get_checklist_notes_reply->status_data.status="S"))
   SET notelistsize = size(ct_get_checklist_notes_reply->notes,5)
   SET stat = alterlist(questionnaire->notes,notelistsize)
   IF (notelistsize > 0)
    FOR (noteidx = 1 TO notelistsize)
      SET questionnaire->notes[noteidx].pt_elig_tracking_note_id = ct_get_checklist_notes_reply->
      notes[noteidx].pt_elig_tracking_note_id
      SET questionnaire->notes[noteidx].note_text = ct_get_checklist_notes_reply->notes[noteidx].
      note_text
      SET questionnaire->notes[noteidx].note_type_cd = ct_get_checklist_notes_reply->notes[noteidx].
      note_type_cd
    ENDFOR
   ENDIF
  ENDIF
  SET irb_cd = uar_get_code_by("MEANING",22209,"IRB")
  SELECT INTO "nl:"
   c.performed_dt_tm
   FROM ct_milestones c,
    committee co
   PLAN (c
    WHERE (c.prot_amendment_id=questionnaire->prot_amendment_id)
     AND c.entity_type_flag=2
     AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (co
    WHERE co.committee_id=c.committee_id
     AND co.committee_type_cd=irb_cd)
   DETAIL
    questionnaire->amd_irb_appr_dt = c.performed_dt_tm
   WITH nocounter
  ;end select
 ENDIF
#check_error
 IF (fail_flag=0)
  SET questionnaire->status_data.status = "S"
  SET questionnaire->status_data.subeventstatus.operationname = ""
  SET questionnaire->status_data.subeventstatus.operationstatus = "S"
  SET questionnaire->status_data.subeventstatus.targetobjectname = ""
  SET questionnaire->status_data.subeventstatus.targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF get_prot_info:
    SET questionnaire->status_data.subeventstatus.operationname = "SELECT"
    SET questionnaire->status_data.subeventstatus.targetobjectname = "TABLE"
    SET questionnaire->status_data.subeventstatus.targetobjectvalue =
    "Searching for checklist specific protocol info."
   OF get_questions:
    SET questionnaire->status_data.subeventstatus.operationname = "SELECT"
    SET questionnaire->status_data.subeventstatus.targetobjectname = "TABLE"
    SET questionnaire->status_data.subeventstatus.targetobjectvalue =
    "Searching for questions on checklist."
   OF get_pt_info:
    SET questionnaire->status_data.subeventstatus.operationname = "SELECT"
    SET questionnaire->status_data.subeventstatus.targetobjectname = "TABLE"
    SET questionnaire->status_data.subeventstatus.targetobjectvalue = "Searching for patient name."
   OF get_pi_cra_info:
    SET questionnaire->status_data.subeventstatus.operationname = "SELECT"
    SET questionnaire->status_data.subeventstatus.targetobjectname = "TABLE"
    SET questionnaire->status_data.subeventstatus.targetobjectvalue =
    "Searching for PI and CRA names."
   OF get_mrn_info:
    SET questionnaire->status_data.subeventstatus.operationname = "SELECT"
    SET questionnaire->status_data.subeventstatus.targetobjectname = "TABLE"
    SET questionnaire->status_data.subeventstatus.targetobjectvalue = "Searching for MRN of patient."
   ELSE
    SET questionnaire->status_data.subeventstatus.operationname = "UNKNOWN"
    SET questionnaire->status_data.subeventstatus.targetobjectname = ""
    SET questionnaire->status_data.subeventstatus.targetobjectvalue = ""
  ENDCASE
  SET questionnaire->status_data.subeventstatus.operationstatus = "F"
 ENDIF
 SET last_mod = "005"
 SET mod_date = "Feb 22, 2018"
END GO
