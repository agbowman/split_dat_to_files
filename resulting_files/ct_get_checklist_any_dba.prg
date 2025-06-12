CREATE PROGRAM ct_get_checklist_any:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_amendment_id = f8
    1 amendment_status_cd = f8
    1 amendment_status_disp = vc
    1 amendment_status_mean = vc
    1 primary_mnemonic = vc
    1 pt_elig_tracking_id = f8
    1 elig_status_cd = f8
    1 elig_status_disp = vc
    1 patient_name = vc
    1 pi = vc
    1 cra = vc
    1 primary_physician = vc
    1 elig_request_person_id = f8
    1 elig_request_person = vc
    1 elig_request_org_id = f8
    1 elig_request_org_name = vc
    1 record_dt_tm = dq8
    1 reason_ineligible_cd = f8
    1 reason_ineligible_disp = vc
    1 mrn_qual[*]
      2 mrn = vc
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
    1 code_qual[*]
      2 code_set = f8
      2 code_cd = f8
      2 code_disp = vc
      2 code_mean = vc
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
 DECLARE qual_cnt = i2 WITH protect, noconstant(0)
 DECLARE last_attempt_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pi_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cra_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pcp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
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
 SET stat = uar_get_meaning_by_codeset(17283,"YES",1,last_attempt_cd)
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET stat = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
 SET stat = uar_get_meaning_by_codeset(331,"PCP",1,pcp_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
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
 IF ((request->prot_amendment_id=0))
  SELECT INTO "nl:"
   FROM prot_amendment pa
   WHERE (pa.prot_master_id=request->prot_master_id)
   HEAD REPORT
    max = - (2)
   DETAIL
    IF (pa.amendment_nbr > max)
     max = pa.amendment_nbr, request->prot_amendment_id = pa.prot_amendment_id
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM prot_amendment pa,
   prot_master pm
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
  DETAIL
   reply->primary_mnemonic = pm.primary_mnemonic, reply->amendment_status_cd = pa.amendment_status_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prot_role pr,
   person p
  PLAN (pr
   WHERE (pr.prot_amendment_id=request->prot_amendment_id))
   JOIN (p
   WHERE p.person_id=pr.person_id)
  DETAIL
   IF (pr.prot_role_cd=pi_cd)
    reply->pi = p.name_full_formatted
   ENDIF
   IF (pr.prot_role_cd=cra_cd)
    reply->cra = p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  peq.elig_quest_nbr, per.value
  FROM prot_elig_quest peq,
   prot_questionnaire pq,
   answer_format af,
   category_item ci,
   valid_answer_cat vac
  PLAN (pq
   WHERE (pq.prot_amendment_id=request->prot_amendment_id))
   JOIN (peq
   WHERE peq.prot_questionnaire_id=pq.prot_questionnaire_id
    AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (af
   WHERE peq.answer_format_id=af.answer_format_id)
   JOIN (vac
   WHERE vac.answer_format_id=peq.answer_format_id)
   JOIN (ci
   WHERE ci.category_item_id=vac.category_item_id)
  ORDER BY peq.elig_quest_nbr
  HEAD REPORT
   cnt = 0, reply->prot_amendment_id = request->prot_amendment_id
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].prot_elig_quest_id = peq
   .prot_elig_quest_id,
   reply->qual[cnt].question = peq.question, reply->qual[cnt].question_nbr = peq.elig_quest_nbr,
   reply->qual[cnt].desired_value = peq.desired_value,
   reply->qual[cnt].req_value = peq.value_required_flag, reply->qual[cnt].req_date = peq
   .date_required_flag, reply->qual[cnt].valid_ans = ci.category_item_text,
   reply->qual[cnt].quest_type_ind = peq.quest_type_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM pt_elig_tracking pet,
   prot_questionnaire pq,
   person p,
   organization o,
   dummyt d1,
   dummyt d2
  PLAN (pq
   WHERE (pq.prot_amendment_id=request->prot_amendment_id)
    AND pq.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pet
   WHERE pet.prot_questionnaire_id=pq.prot_questionnaire_id
    AND (pet.person_id=request->person_id)
    AND pet.last_attempt_indicator_cd=last_attempt_cd)
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=pet.elig_request_person_id)
   JOIN (d2)
   JOIN (o
   WHERE o.organization_id=pet.elig_request_org_id)
  HEAD REPORT
   reply->pt_elig_tracking_id = 0, reply->elig_status_cd = 0
  DETAIL
   reply->pt_elig_tracking_id = pet.pt_elig_tracking_id, reply->elig_status_cd = pet.elig_status_cd,
   reply->record_dt_tm = pet.beg_effective_dt_tm,
   reply->reason_ineligible_cd = pet.reason_ineligible_cd, reply->elig_request_person_id = pet
   .elig_request_person_id, reply->elig_request_person = p.name_full_formatted,
   reply->elig_request_org_id = pet.elig_request_org_id, reply->elig_request_org_name = o.org_name
  WITH nocounter, outerjoin = d1
 ;end select
 IF ((reply->pt_elig_tracking_id > 0))
  SET qual_cnt = size(reply->qual,5)
  IF (qual_cnt > 0)
   SELECT INTO "nl:"
    FROM pt_elig_result per,
     (dummyt d  WITH seq = value(qual_cnt))
    PLAN (d)
     JOIN (per
     WHERE (per.pt_elig_tracking_id=reply->pt_elig_tracking_id)
      AND (per.prot_elig_quest_id=reply->qual[d.seq].prot_elig_quest_id))
    DETAIL
     reply->qual[d.seq].elig_indicator_cd = per.elig_indicator_cd, reply->qual[d.seq].value = per
     .value, reply->qual[d.seq].value_cd = per.value_cd,
     reply->qual[d.seq].specimen_test_dt_tm = per.specimen_test_dt_tm, reply->qual[d.seq].
     elig_provider_person_id = per.elig_value_provider_person_id, reply->qual[d.seq].
     elig_provider_org_id = per.elig_value_provider_org_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE (pa.person_id=request->person_id)
   AND pa.person_alias_type_cd=mrn_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->mrn_qual,cnt), reply->mrn_qual[cnt].mrn = trim(cnvtalias(
     pa.alias,pa.alias_pool_cd))
  WITH nocounter
 ;end select
#exit_program
 SET last_mod = "004"
 SET mod_date = "Feb 22, 2018"
END GO
