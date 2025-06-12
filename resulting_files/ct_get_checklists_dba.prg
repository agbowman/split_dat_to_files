CREATE PROGRAM ct_get_checklists:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 qual[*]
      2 pt_elig_tracking_id = f8
      2 bgotdata = i2
      2 prot_amendment_id = f8
      2 primary_mnemonic = vc
      2 patient_name = vc
      2 mrn = vc
      2 pi = vc
      2 cra = vc
      2 primary_physician = vc
      2 elig_request_person = vc
      2 elig_review_person = vc
      2 record_dt_tm = dq8
      2 quest[*]
        3 prot_elig_quest_id = f8
        3 question = vc
        3 question_nbr = i4
        3 desired_value = vc
        3 valid_ans = vc
        3 req_value = i2
        3 req_date = i2
        3 quest_type_ind = i2
        3 elig_indicator_cd = f8
        3 elig_indicator_disp = vc
        3 elig_indicator_mean = vc
        3 value = vc
        3 value_cd = f8
        3 value_disp = vc
        3 value_mean = vc
        3 specimen_test_dt_tm = dq8
        3 verified_specimen_test_dt_tm = dq8
        3 verified_elig_status_cd = f8
        3 verified_elig_status_disp = vc
        3 verified_elig_status_mean = vc
        3 audited_value = vc
        3 audited_value_cd = f8
        3 audited_value_disp = vc
        3 audited_value_mean = vc
        3 elig_provide_person = vc
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
 SET reply->status_data.status = "F"
 SET pi_cd = 0.0
 SET cra_cd = 0.0
 SET mrn_cd = 0.0
 SET pcp_cd = 0.0
 SET qual_cnt = size(request->qual,5)
 SET bstat = alterlist(reply->qual,qual_cnt)
 SET bstat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET bstat = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
 SET bstat = uar_get_meaning_by_codeset(331,"PCP",1,pcp_cd)
 SET bstat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 IF (qual_cnt > 0)
  SELECT INTO "nl:"
   FROM pt_elig_tracking pet,
    prot_amendment am,
    prot_master pm,
    person p,
    person_alias pa,
    person_prsnl_reltn ppr,
    prsnl ps,
    (dummyt d  WITH seq = value(qual_cnt)),
    dummyt d1,
    dummyt d2,
    dummyt d3,
    dummyt d4
   PLAN (d)
    JOIN (pet
    WHERE (pet.pt_elig_tracking_id=request->qual[d.seq].pt_elig_tracking_id))
    JOIN (p
    WHERE ((p.person_id=pet.elig_request_person_id) OR (((p.person_id=pet.elig_review_person_id) OR (
    p.person_id=pet.person_id)) )) )
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=mrn_cd)
    JOIN (d2)
    JOIN (ppr
    WHERE ppr.person_id=pa.person_id
     AND ppr.person_prsnl_r_cd=pcp_cd)
    JOIN (d3)
    JOIN (ps
    WHERE ps.person_id=ppr.person_id)
    JOIN (d4)
    JOIN (am
    WHERE am.prot_amendment_id=pet.prot_amendment_id)
    JOIN (pm
    WHERE pm.prot_master_id=am.prot_master_id)
   ORDER BY ppr.updt_dt_tm
   HEAD d.seq
    reply->qual[d.seq].prot_amendment_id = pet.prot_amendment_id, reply->qual[d.seq].record_dt_tm =
    pet.beg_effective_dt_tm, reply->qual[d.seq].primary_mnemonic = pm.primary_mnemonic,
    reply->qual[d.seq].mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd)), reply->qual[d.seq].
    primary_physician = ps.name_full_formatted, reply->qual[d.seq].bgotdata = 1
   DETAIL
    IF (p.person_id=pet.person_id)
     reply->qual[d.seq].patient_name = p.name_full_formatted
    ENDIF
    IF (p.person_id=pet.elig_request_person_id)
     reply->qual[d.seq].elig_request_person = p.name_full_formatted
    ENDIF
    IF (p.person_id=pet.elig_review_person_id)
     reply->qual[d.seq].elig_review_person = p.name_full_formatted
    ENDIF
   WITH nocounter, dontcare = pa, dontcare = ppr,
    dontcare = ps
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SELECT INTO "nl:"
   FROM pt_elig_result per,
    prot_elig_quest peq,
    answer_format af,
    category_item ci,
    valid_answer_cat vac,
    (dummyt d  WITH seq = value(qual_cnt)),
    long_text_reference ltr
   PLAN (d)
    JOIN (per
    WHERE (per.pt_elig_tracking_id=request->qual[d.seq].pt_elig_tracking_id))
    JOIN (peq
    WHERE peq.prot_amendment_id=per.prot_amendment_id
     AND peq.prot_elig_quest_id=per.prot_elig_quest_id)
    JOIN (af
    WHERE peq.answer_format_id=af.answer_format_id)
    JOIN (vac
    WHERE vac.answer_format_id=peq.answer_format_id)
    JOIN (ci
    WHERE ci.category_item_id=vac.category_item_id)
    JOIN (ltr
    WHERE ltr.long_text_id=peq.long_text_id)
   ORDER BY d.seq, peq.elig_quest_nbr
   HEAD d.seq
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > size(reply->qual[d.seq].quest,5))
     stat = alterlist(reply->qual[d.seq].quest,(cnt+ 10))
    ENDIF
    reply->qual[d.seq].quest[cnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->qual[d.seq].
    quest[cnt].question = ltr.long_text, reply->qual[d.seq].quest[cnt].question_nbr = peq
    .elig_quest_nbr,
    reply->qual[d.seq].quest[cnt].desired_value = peq.desired_value, reply->qual[d.seq].quest[cnt].
    req_value = peq.value_required_flag, reply->qual[d.seq].quest[cnt].req_date = peq
    .date_required_flag,
    reply->qual[d.seq].quest[cnt].valid_ans = ci.category_item_text, reply->qual[d.seq].quest[cnt].
    quest_type_ind = peq.quest_type_ind, reply->qual[d.seq].quest[cnt].elig_indicator_cd = per
    .elig_indicator_cd,
    reply->qual[d.seq].quest[cnt].value = per.value, reply->qual[d.seq].quest[cnt].value_cd = per
    .value_cd, reply->qual[d.seq].quest[cnt].specimen_test_dt_tm = per.specimen_test_dt_tm,
    reply->qual[d.seq].quest[cnt].verified_specimen_test_dt_tm = per.verified_specimen_test_dt_tm,
    reply->qual[d.seq].quest[cnt].verified_elig_status_cd = per.verified_elig_status_cd, reply->qual[
    d.seq].quest[cnt].audited_value = per.audited_value,
    reply->qual[d.seq].quest[cnt].audited_value_cd = per.audited_value_cd
   FOOT  d.seq
    stat = alterlist(reply->qual[d.seq].quest,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prot_role pr,
    person p,
    (dummyt d  WITH seq = value(qual_cnt))
   PLAN (d)
    JOIN (pr
    WHERE (pr.prot_amendment_id=reply->qual[d.seq].prot_amendment_id))
    JOIN (p
    WHERE p.person_id=pr.person_id)
   HEAD d.seq
    cnt = 0
   DETAIL
    IF (pr.prot_role_cd=pi_cd)
     reply->qual[d.seq].pi = p.name_full_formatted
    ENDIF
    IF (pr.prot_role_cd=cra_cd)
     reply->qual[d.seq].cra = p.name_full_formatted
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_program
 SET last_mod = "003"
 SET mod_date = "Feb 22, 2018"
END GO
