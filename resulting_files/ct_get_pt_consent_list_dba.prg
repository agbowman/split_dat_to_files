CREATE PROGRAM ct_get_pt_consent_list:dba
 RECORD reply(
   1 consents[*]
     2 protocolid = f8
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 stratumlabel = vc
     2 namefullformatted = vc
     2 protalias = vc
     2 amendment_nbr = i4
     2 revision_nbr_txt = vc
     2 dateconissued = dq8
     2 dateconsigned = dq8
     2 dateconreturned = dq8
     2 dateconnotreturned = dq8
     2 reasonnotreturned_cd = f8
     2 reasonnotreturned_disp = vc
     2 reasonforcon_cd = f8
     2 reasonforcon_disp = vc
     2 reasonforcon_desc = vc
     2 reasonforcon_mean = vc
     2 conprotamendmentid = f8
     2 eligprotamendmentid = f8
     2 pteligtrackingid = f8
     2 protquestionnaireid = f8
     2 conid = f8
     2 ptconid = f8
     2 ctdocumentid = f8
     2 consentdocname = vc
     2 regid = f8
     2 protaccessionnbr = vc
     2 cohort_label = c30
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
 DECLARE mrn = f8 WITH protect, noconstant(0.0)
 DECLARE cntc = i2 WITH protect, noconstant(0)
 DECLARE cntm = i2 WITH protect, noconstant(0)
 DECLARE numofprotocols = i2 WITH protect, noconstant(0)
 DECLARE numoftypes = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE personidstr = vc WITH protect
 SET reply->status_data.status = "F"
 SET numofprotocols = size(request->protocols,5)
 SET numoftypes = size(request->consenttypes,5)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn)
 IF ((request->orgsecurity=1))
  SET userorgstr = builduserorglist("pt_c.consenting_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 IF ((request->personid > 0))
  SET personidstr = build("pt_c.person_id = ",request->personid)
 ELSE
  SET personidstr = "1=1"
 ENDIF
 CALL echo(build("personIdStr: ",personidstr))
 SET cntc = 0
 SET stat = alterlist(reply->consents,cntc)
 IF (numofprotocols > 0)
  SELECT INTO "NL:"
   pt_c.*, p.name_first, p.name_last,
   p.name_full_formatted, p.person_id, poolid_d = decode(p_a.seq,p_a.alias_pool_cd,- (9.0)),
   pr_am.prot_amendment_id, pr_am.prot_master_id, eligid_d = decode(pet.seq,pet.pt_elig_tracking_id,
    - (9.0)),
   amendid_d = decode(pet.seq,pet.prot_amendment_id,- (9.0)), pr_m.primary_mnemonic, regid_d = decode
   (prcr.seq,prcr.reg_id,- (9.0)),
   pet.prot_questionnaire_id, p_pr_r.prot_accession_nbr
   FROM (dummyt d1  WITH seq = value(numofprotocols)),
    prot_master pr_m,
    prot_amendment pr_am,
    person p,
    dummyt d3,
    dummyt d4,
    dummyt d6,
    person_alias p_a,
    pt_consent pt_c,
    pt_elig_consent_reltn pecr,
    pt_elig_tracking pet,
    pt_reg_consent_reltn prcr,
    (dummyt d2  WITH seq = value(numoftypes)),
    pt_prot_reg p_pr_r
   PLAN (d1)
    JOIN (pr_m
    WHERE (pr_m.prot_master_id=request->protocols[d1.seq].protocolid))
    JOIN (pr_am
    WHERE pr_am.prot_master_id=pr_m.prot_master_id
     AND pr_m.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (d2)
    JOIN (pt_c
    WHERE pt_c.prot_amendment_id=pr_am.prot_amendment_id
     AND parser(personidstr)
     AND pt_c.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pt_c.consent_signed_dt_tm <=
    IF ((request->returned=1)) cnvtdatetime(sysdate)
    ELSE pt_c.consent_signed_dt_tm
    ENDIF
    )
     AND (pt_c.not_returned_dt_tm <=
    IF ((request->notreturned=1)) cnvtdatetime(sysdate)
    ELSE pt_c.not_returned_dt_tm
    ENDIF
    )
     AND ((numoftypes > 0
     AND (pt_c.reason_for_consent_cd=request->consenttypes[d2.seq].consenttypecd)) OR (numoftypes=0
     AND pt_c.reason_for_consent_cd > 0))
     AND parser(userorgstr))
    JOIN (p
    WHERE pt_c.person_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d3)
    JOIN (p_a
    WHERE p.person_id=p_a.person_id
     AND p_a.person_alias_type_cd=mrn
     AND p_a.active_ind=1
     AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d4)
    JOIN (pecr
    WHERE pecr.consent_id=pt_c.consent_id)
    JOIN (pet
    WHERE pecr.pt_elig_tracking_id=pet.pt_elig_tracking_id)
    JOIN (d6)
    JOIN (prcr
    WHERE prcr.consent_id=pt_c.consent_id)
    JOIN (p_pr_r
    WHERE p_pr_r.reg_id=prcr.reg_id)
   ORDER BY pt_c.pt_consent_id, p_pr_r.pt_prot_reg_id DESC
   HEAD pt_c.pt_consent_id
    cntc += 1
    IF (mod(cntc,50)=1)
     stat = alterlist(reply->consents,(cntc+ 50))
    ENDIF
    reply->consents[cntc].personid = p.person_id, reply->consents[cntc].lastname = p.name_last, reply
    ->consents[cntc].firstname = p.name_first,
    reply->consents[cntc].namefullformatted = p.name_full_formatted, reply->consents[cntc].protalias
     = pr_m.primary_mnemonic, reply->consents[cntc].protocolid = pr_am.prot_master_id,
    reply->consents[cntc].dateconissued = pt_c.consent_released_dt_tm, reply->consents[cntc].
    dateconsigned = pt_c.consent_signed_dt_tm, reply->consents[cntc].dateconreturned = pt_c
    .consent_received_dt_tm,
    reply->consents[cntc].dateconnotreturned = pt_c.not_returned_dt_tm, reply->consents[cntc].
    reasonnotreturned_cd = pt_c.not_returned_reason_cd, reply->consents[cntc].reasonforcon_cd = pt_c
    .reason_for_consent_cd,
    reply->consents[cntc].conprotamendmentid = pt_c.prot_amendment_id, reply->consents[cntc].conid =
    pt_c.consent_id, reply->consents[cntc].ptconid = pt_c.pt_consent_id,
    reply->consents[cntc].eligprotamendmentid = amendid_d, reply->consents[cntc].pteligtrackingid =
    eligid_d, reply->consents[cntc].regid = regid_d,
    reply->consents[cntc].protquestionnaireid = pet.prot_questionnaire_id, reply->consents[cntc].
    amendment_nbr = pr_am.amendment_nbr, reply->consents[cntc].revision_nbr_txt = pr_am
    .revision_nbr_txt,
    reply->consents[cntc].protaccessionnbr = p_pr_r.prot_accession_nbr, reply->consents[cntc].
    ctdocumentid = pt_c.ct_document_version_id, cntm = 0
   DETAIL
    IF ((poolid_d != - (9.0)))
     cntm += 1
     IF (mod(cntm,10)=1)
      stat = alterlist(reply->consents[cntc].mrns,(cntm+ 10))
     ENDIF
     reply->consents[cntc].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->
     consents[cntc].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
    ENDIF
   FOOT  pt_c.pt_consent_id
    stat = alterlist(reply->consents[cntc].mrns,cntm)
   WITH dontcare = pecr, dontcare = p_a, outerjoin = d6,
    nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->consents,cntc)
 CALL echo(build("cntC: ",cntc))
 IF (cntc > 0)
  SELECT INTO "nl:"
   FROM assign_elig_reltn aer,
    prot_cohort pc,
    prot_stratum ps,
    (dummyt d1  WITH seq = value(cntc))
   PLAN (d1)
    JOIN (aer
    WHERE (aer.pt_elig_tracking_id=reply->consents[d1.seq].pteligtrackingid)
     AND aer.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc
    WHERE aer.cohort_id=pc.cohort_id
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (ps
    WHERE pc.stratum_id=ps.stratum_id
     AND ps.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   HEAD aer.assign_elig_reltn_id
    reply->consents[d1.seq].stratumlabel = ps.stratum_label
    IF (uar_get_code_meaning(ps.stratum_cohort_type_cd)="DEFAULT")
     reply->consents[d1.seq].cohort_label = ""
    ELSE
     reply->consents[d1.seq].cohort_label = pc.cohort_label
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->personid > 0)
   AND (request->consentdetailind=1))
   SELECT INTO "nl:"
    FROM ct_document cd,
     ct_document_version cdv,
     (dummyt d1  WITH seq = value(cntc))
    PLAN (d1)
     JOIN (cdv
     WHERE (cdv.ct_document_version_id= Outerjoin(reply->consents[d1.seq].ctdocumentid)) )
     JOIN (cd
     WHERE (cd.ct_document_id= Outerjoin(cdv.ct_document_id)) )
    DETAIL
     reply->consents[d1.seq].consentdocname = cd.title
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET last_mod = "007"
 SET mod_date = "Feb 22, 2018"
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
