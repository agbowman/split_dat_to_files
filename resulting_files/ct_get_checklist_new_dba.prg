CREATE PROGRAM ct_get_checklist_new:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_amendment_id = f8
    1 amendment_nbr = i4
    1 amendment_status_cd = f8
    1 amendment_status_disp = vc
    1 amendment_status_mean = vc
    1 primary_mnemonic = vc
    1 patient_name = vc
    1 primary_physician = vc
    1 no_active_amendment = i2
    1 elig_request_person_id = f8
    1 elig_request_person = vc
    1 checklist_name = vc
    1 special_inst_text = vc
    1 special_inst_long_text_id = f8
    1 pi[*]
      2 pi = vc
    1 cra[*]
      2 cra = vc
    1 mrn_qual[*]
      2 mrn = vc
      2 alias_pool_cd = f8
    1 qual[*]
      2 prot_elig_quest_id = f8
      2 question = vc
      2 question_nbr = i4
      2 desired_value = vc
      2 valid_ans = vc
      2 req_value = i2
      2 req_date = i2
      2 quest_type_ind = i2
    1 code_qual[*]
      2 code_set = f8
      2 code_cd = f8
      2 code_disp = vc
      2 code_mean = vc
    1 revision_ind = i2
    1 revision_nbr_txt = c30
    1 amd_irb_appr_dt = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE irb_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",22209,"IRB"))
 SET reply->status_data.status = "F"
 SET last_attempt_cd = 0.0
 SET pi_cd = 0.0
 SET cra_cd = 0.0
 SET pcp_cd = 0.0
 SET mrn_cd = 0.0
 SET activated_cd = 0.0
 SET tempsuspend_cd = 0.0
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
 SET tmp = uar_get_meaning_by_codeset(17283,"YES",1,last_attempt_cd)
 SET tmp = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET tmp = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
 SET tmp = uar_get_meaning_by_codeset(331,"PCP",1,pcp_cd)
 SET tmp = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET tmp = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET tmp = uar_get_meaning_by_codeset(17274,"TEMPSUSPEND",1,tempsuspend_cd)
 IF ((request->prot_amendment_id=0))
  SET reply->prot_amendment_id = 0
  SELECT INTO "nl:"
   FROM prot_amendment pa
   WHERE (pa.prot_master_id=request->prot_master_id)
    AND pa.amendment_status_cd=activated_cd
   DETAIL
    reply->prot_amendment_id = pa.prot_amendment_id, reply->amendment_nbr = pa.amendment_nbr, reply->
    revision_ind = pa.revision_ind,
    reply->revision_nbr_txt = pa.revision_nbr_txt
   WITH nocounter
  ;end select
  IF ((reply->prot_amendment_id=0))
   SELECT INTO "nl:"
    FROM prot_amendment pa
    WHERE (pa.prot_master_id=request->prot_master_id)
     AND pa.amendment_status_cd=tempsuspend_cd
    DETAIL
     reply->prot_amendment_id = pa.prot_amendment_id, reply->amendment_nbr = pa.amendment_nbr, reply
     ->revision_ind = pa.revision_ind,
     reply->revision_nbr_txt = pa.revision_nbr_txt
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->no_active_amendment = 1
    SET reply->status_data.status = "Z"
    CALL echo("here 1")
    GO TO exit_program
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM prot_amendment pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id)
   DETAIL
    reply->prot_amendment_id = pa.prot_amendment_id, reply->amendment_nbr = pa.amendment_nbr, reply->
    revision_ind = pa.revision_ind,
    reply->revision_nbr_txt = pa.revision_nbr_txt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM person p,
   person_prsnl_reltn ppr,
   prsnl ps,
   dummyt d2,
   dummyt d3
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (d2)
   JOIN (ppr
   WHERE ppr.person_id=p.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd)
   JOIN (d3)
   JOIN (ps
   WHERE ps.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.updt_dt_tm
  DETAIL
   reply->patient_name = p.name_full_formatted, reply->primary_physician = ps.name_full_formatted
  WITH nocounter, dontcare = ppr, outerjoin = d3
 ;end select
 SELECT INTO "nl:"
  FROM prot_questionnaire pq,
   long_text_reference ltr
  PLAN (pq
   WHERE (pq.prot_questionnaire_id=request->prot_questionnaire_id)
    AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(pq.special_inst_long_text_id))
  DETAIL
   reply->checklist_name = pq.questionnaire_name
   IF (pq.special_inst_long_text_id > 0)
    reply->special_inst_text = ltr.long_text, reply->special_inst_long_text_id = ltr.long_text_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SET cntpi = 0
 SET cntcra = 0
 SELECT INTO "nl:"
  pm.primary_mnemonic, p.name_full_formatted, pr.prot_role_cd
  FROM prot_amendment pa,
   prot_master pm,
   prot_role pr,
   person p,
   dummyt d1
  PLAN (pa
   WHERE (pa.prot_amendment_id=reply->prot_amendment_id))
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
   JOIN (d1)
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND pr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=pr.person_id)
  ORDER BY pa.prot_amendment_id
  HEAD pa.prot_amendment_id
   reply->primary_mnemonic = pm.primary_mnemonic, reply->amendment_status_cd = pa.amendment_status_cd
  DETAIL
   IF (pr.prot_role_cd=pi_cd
    AND d1.seq > 0)
    cntpi = (cntpi+ 1), stat = alterlist(reply->pi,cntpi), reply->pi[cntpi].pi = p
    .name_full_formatted
   ELSEIF (pr.prot_role_cd=cra_cd
    AND d1.seq > 0)
    cntcra = (cntcra+ 1), stat = alterlist(reply->cra,cntcra), reply->cra[cntcra].cra = p
    .name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  ppr.person_prsnl_reltn_id
  FROM person_prsnl_reltn ppr,
   person p
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND (ppr.person_prsnl_r_cd=request->req_person_cd))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  DETAIL
   reply->elig_request_person_id = p.person_id, reply->elig_request_person = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  peq.elig_quest_nbr
  FROM prot_elig_quest peq,
   answer_format af,
   category_item ci,
   valid_answer_cat vac,
   long_text_reference ltr
  PLAN (peq
   WHERE (peq.prot_questionnaire_id=request->prot_questionnaire_id)
    AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (af
   WHERE peq.answer_format_id=af.answer_format_id)
   JOIN (vac
   WHERE vac.answer_format_id=peq.answer_format_id)
   JOIN (ci
   WHERE ci.category_item_id=vac.category_item_id)
   JOIN (ltr
   WHERE ltr.long_text_id=peq.long_text_id)
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
   .quest_type_ind
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE (pa.person_id=request->person_id)
   AND pa.person_alias_type_cd=mrn_cd
   AND pa.active_ind=1
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->mrn_qual,cnt), reply->mrn_qual[cnt].mrn = trim(cnvtalias(
     pa.alias,pa.alias_pool_cd)),
   reply->mrn_qual[cnt].alias_pool_cd = pa.alias_pool_cd
  WITH nocounter
 ;end select
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
#exit_program
 SET last_mod = "010"
 SET mod_date = "Feb 22, 2018"
END GO
