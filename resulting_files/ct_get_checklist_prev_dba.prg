CREATE PROGRAM ct_get_checklist_prev:dba
 IF (validate(reply->status_data.status,"F")="F")
  RECORD reply(
    1 prot_master_id = f8
    1 person_id = f8
    1 prot_amendment_id = f8
    1 prot_questionnaire_id = f8
    1 amendment_status_cd = f8
    1 amendment_status_disp = vc
    1 amendment_status_mean = vc
    1 primary_mnemonic = vc
    1 pt_elig_tracking_id = f8
    1 elig_status_cd = f8
    1 elig_status_disp = vc
    1 elig_status_mean = vc
    1 reason_ineligible_cd = f8
    1 reason_ineligible_disp = vc
    1 reason_ineligible_mean = vc
    1 patient_name = vc
    1 primary_physician = vc
    1 elig_request_person_id = f8
    1 elig_request_person = vc
    1 elig_request_org_id = f8
    1 elig_request_org_name = vc
    1 record_dt_tm = dq8
    1 not_returned_reason_cd = f8
    1 not_returned_reason_disp = vc
    1 checklist_name = vc
    1 special_inst_text = vc
    1 special_inst_long_text_id = f8
    1 amendment_nbr = i4
    1 revision_ind = i2
    1 revision_nbr_txt = c30
    1 pi[*]
      2 pi = vc
    1 cra[*]
      2 cra = vc
    1 mrn_qual[*]
      2 mrn = vc
      2 alias_pool_cd = f8
    1 code_qual[*]
      2 code_set = f8
      2 code_cd = f8
      2 code_disp = vc
      2 code_mean = vc
    1 qual[*]
      2 prot_elig_quest_id = f8
      2 question = vc
      2 question_nbr = i4
      2 desired_value = vc
      2 valid_ans = vc
      2 req_value = i2
      2 req_date = i2
      2 quest_type_ind = i2
      2 elig_indicator_cd = f8
      2 elig_indicator_disp = vc
      2 elig_indicator_mean = vc
      2 value = vc
      2 value_cd = f8
      2 value_disp = vc
      2 value_mean = vc
      2 specimen_test_dt_tm = dq8
      2 elig_provider_person_id = f8
      2 elig_provider_org_id = f8
      2 elig_provider_person = vc
    1 reason_for_failure = vc
    1 amd_irb_appr_dt = dq8
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
 ENDIF
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
 SET reply->status_data.status = "F"
 DECLARE pi_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cra_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pcp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE tempsuspend_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cntpi = i2 WITH protect, noconstant(0)
 DECLARE cntcra = i2 WITH protect, noconstant(0)
 DECLARE notelistsize = i2 WITH protect, noconstant(0)
 DECLARE noteidx = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE irb_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",22209,"IRB"))
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set IN (17284, 17285, 17286, 17429, 17869)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->code_qual,cnt), reply->code_qual[cnt].code_set = c
   .code_set,
   reply->code_qual[cnt].code_cd = c.code_value, reply->code_qual[cnt].code_disp = c.display, reply->
   code_qual[cnt].code_mean = c.cdf_meaning
  WITH nocounter
 ;end select
 SET tmp = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET tmp = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
 SET tmp = uar_get_meaning_by_codeset(331,"PCP",1,pcp_cd)
 SET tmp = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET tmp = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET tmp = uar_get_meaning_by_codeset(17274,"TEMPSUSPEND",1,tempsuspend_cd)
 SELECT INTO "nl:"
  FROM pt_elig_tracking pet,
   person p,
   person_prsnl_reltn ppr,
   prsnl ps,
   dummyt d2,
   dummyt d3
  PLAN (pet
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id))
   JOIN (p
   WHERE p.person_id=pet.person_id)
   JOIN (d2)
   JOIN (ppr
   WHERE ppr.person_id=p.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd)
   JOIN (d3)
   JOIN (ps
   WHERE ps.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.updt_dt_tm
  DETAIL
   reply->person_id = p.person_id, reply->patient_name = p.name_full_formatted, reply->
   primary_physician = ps.name_full_formatted
  WITH nocounter, dontcare = ppr, outerjoin = d3
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Unable to get person info"
  GO TO exit_script
 ENDIF
 CALL echo("After getting person info")
 SELECT INTO "nl:"
  FROM pt_elig_tracking pet,
   prot_amendment pa,
   prot_master pm,
   prot_questionnaire pq,
   person p,
   organization o,
   dummyt d,
   long_text_reference ltr
  PLAN (pet
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id))
   JOIN (p
   WHERE p.person_id=pet.elig_request_person_id)
   JOIN (pq
   WHERE pet.prot_questionnaire_id=pq.prot_questionnaire_id
    AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(pq.special_inst_long_text_id))
   JOIN (pa
   WHERE pa.prot_amendment_id=pq.prot_amendment_id)
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
   JOIN (d)
   JOIN (o
   WHERE o.organization_id=pet.elig_request_org_id)
  DETAIL
   CALL echo("In main script detail"), reply->elig_status_cd = pet.elig_status_cd,
   CALL echo(build("reply->prot_amendment_id = ",reply->prot_amendment_id)),
   reply->reason_ineligible_cd = pet.reason_ineligible_cd, reply->record_dt_tm = pet
   .beg_effective_dt_tm, reply->prot_amendment_id = pq.prot_amendment_id,
   reply->elig_request_person_id = pet.elig_request_person_id, reply->elig_request_org_id = pet
   .elig_request_org_id, reply->elig_request_person = p.name_full_formatted,
   reply->primary_mnemonic = pm.primary_mnemonic, reply->amendment_nbr = pa.amendment_nbr, reply->
   revision_ind = pa.revision_ind,
   reply->revision_nbr_txt = pa.revision_nbr_txt, reply->prot_master_id = pm.prot_master_id, reply->
   elig_request_org_name = o.org_name,
   reply->amendment_status_cd = pa.amendment_status_cd, reply->prot_questionnaire_id = pq
   .prot_questionnaire_id, reply->checklist_name = pq.questionnaire_name
   IF (pq.special_inst_long_text_id > 0)
    reply->special_inst_text = ltr.long_text, reply->special_inst_long_text_id = ltr.long_text_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Unable to get protocol info"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_value IN (reply->amendment_status_cd, reply->elig_status_cd, reply->
  reason_ineligible_cd)
  DETAIL
   IF ((cv.code_value=reply->amendment_status_cd))
    reply->amendment_status_mean = cv.cdf_meaning, reply->amendment_status_disp = cv.display
   ELSEIF ((cv.code_value=reply->elig_status_cd))
    reply->elig_status_mean = trim(cv.cdf_meaning), reply->elig_status_disp = cv.display
   ELSEIF ((cv.code_value=reply->reason_ineligible_cd))
    reply->reason_ineligible_disp = cv.display, reply->reason_ineligible_mean = trim(cv.cdf_meaning)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM prot_role pr,
   person p
  PLAN (pr
   WHERE (pr.prot_amendment_id=reply->prot_amendment_id)
    AND pr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=pr.person_id)
  DETAIL
   IF (pr.prot_role_cd=pi_cd)
    cntpi = (cntpi+ 1), stat = alterlist(reply->pi,cntpi), reply->pi[cntpi].pi = p
    .name_full_formatted
   ELSEIF (pr.prot_role_cd=cra_cd)
    cntcra = (cntcra+ 1), stat = alterlist(reply->cra,cntcra), reply->cra[cntcra].cra = p
    .name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("BEfore main query")
 SELECT INTO "nl:"
  FROM pt_elig_result per,
   prot_elig_quest peq,
   answer_format af,
   category_item ci,
   valid_answer_cat vac,
   long_text_reference ltr,
   person p
  PLAN (per
   WHERE (per.pt_elig_tracking_id=request->pt_elig_tracking_id))
   JOIN (peq
   WHERE peq.prot_elig_quest_id=per.prot_elig_quest_id
    AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (af
   WHERE peq.answer_format_id=af.answer_format_id)
   JOIN (vac
   WHERE vac.answer_format_id=peq.answer_format_id)
   JOIN (ci
   WHERE ci.category_item_id=vac.category_item_id)
   JOIN (ltr
   WHERE ltr.long_text_id=peq.long_text_id)
   JOIN (p
   WHERE p.person_id=per.elig_value_provider_person_id)
  ORDER BY peq.elig_quest_nbr
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->qual[cnt].question = ltr
   .long_text, reply->qual[cnt].question_nbr = peq.elig_quest_nbr,
   reply->qual[cnt].desired_value = peq.desired_value, reply->qual[cnt].req_value = peq
   .value_required_flag, reply->qual[cnt].req_date = peq.date_required_flag,
   reply->qual[cnt].valid_ans = ci.category_item_text, reply->qual[cnt].quest_type_ind = peq
   .quest_type_ind, reply->qual[cnt].elig_indicator_cd = per.elig_indicator_cd,
   reply->qual[cnt].value = per.value, reply->qual[cnt].value_cd = per.value_cd, reply->qual[cnt].
   specimen_test_dt_tm = per.specimen_test_dt_tm,
   reply->qual[cnt].elig_provider_person_id = per.elig_value_provider_person_id, reply->qual[cnt].
   elig_provider_org_id = per.elig_value_provider_org_id, reply->qual[cnt].elig_provider_person = p
   .name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter, dontcare = p
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->reason_for_failure = "Failure to get questions"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM pt_elig_tracking pet,
   person_alias pa
  PLAN (pet
   WHERE (pet.pt_elig_tracking_id=request->pt_elig_tracking_id))
   JOIN (pa
   WHERE pa.person_id=pet.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->mrn_qual,cnt), reply->mrn_qual[cnt].mrn = trim(cnvtalias(
     pa.alias,pa.alias_pool_cd)),
   reply->mrn_qual[cnt].alias_pool_cd = pa.alias_pool_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pt_elig_consent_reltn pecr,
   pt_consent pc
  PLAN (pecr
   WHERE (pecr.pt_elig_tracking_id=request->pt_elig_tracking_id))
   JOIN (pc
   WHERE pc.consent_id=pecr.consent_id
    AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->not_returned_reason_cd = pc.not_returned_reason_cd
  WITH nocounter
 ;end select
 SET ct_get_checklist_notes_request->pt_elig_tracking_id = request->pt_elig_tracking_id
 EXECUTE ct_get_checklist_notes  WITH replace("REQUEST","CT_GET_CHECKLIST_NOTES_REQUEST"), replace(
  "REPLY","CT_GET_CHECKLIST_NOTES_REPLY")
 IF ((ct_get_checklist_notes_reply->status_data.status="S"))
  SET notelistsize = size(ct_get_checklist_notes_reply->notes,5)
  SET stat = alterlist(reply->notes,notelistsize)
  IF (notelistsize > 0)
   FOR (noteidx = 1 TO notelistsize)
     SET reply->notes[noteidx].pt_elig_tracking_note_id = ct_get_checklist_notes_reply->notes[noteidx
     ].pt_elig_tracking_note_id
     SET reply->notes[noteidx].note_text = ct_get_checklist_notes_reply->notes[noteidx].note_text
     SET reply->notes[noteidx].note_type_cd = ct_get_checklist_notes_reply->notes[noteidx].
     note_type_cd
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  c.performed_dt_tm
  FROM ct_milestones c,
   committee co
  PLAN (c
   WHERE (c.prot_amendment_id=reply->prot_amendment_id)
    AND c.entity_type_flag=2
    AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (co
   WHERE co.committee_id=c.committee_id
    AND co.committee_type_cd=irb_cd)
  DETAIL
   reply->amd_irb_appr_dt = c.performed_dt_tm
  WITH nocounter
 ;end select
#exit_script
 CALL echo(build("status= ",reply->status_data.status))
 CALL echo(reply->reason_for_failure)
 SET last_mod = "011"
 SET mod_date = "Feb 22, 2018"
END GO
