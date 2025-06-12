CREATE PROGRAM ct_get_pt_cnsnt_nt_rtrn:dba
 RECORD reply(
   1 transfercd = f8
   1 transfersafcd = f8
   1 consents[*]
     2 protocolid = f8
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 stratumlabel = vc
     2 namefullformatted = vc
     2 protalias = vc
     2 dateconissued = dq8
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
     2 regid = f8
     2 amendment_nbr = i4
     2 revision_nbr_txt = vc
     2 isenrolled = i2
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
 SET reply->status_data.status = "F"
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE y = i2 WITH protect, noconstant(0)
 DECLARE cntc = i2 WITH protect, noconstant(0)
 DECLARE cntm = i2 WITH protect, noconstant(0)
 DECLARE mrn = f8 WITH public, noconstant(0.0)
 DECLARE eligible = f8 WITH public, noconstant(0.0)
 DECLARE enrolling = f8 WITH public, noconstant(0.0)
 DECLARE numofprotocols = i2 WITH protect, noconstant(0)
 SET numofprotocols = size(request->protocols,5)
 SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling)
 SET stat = uar_get_meaning_by_codeset(17349,"TRANSFER",1,reply->transfercd)
 SET stat = uar_get_meaning_by_codeset(17349,"TRANSFERSAF",1,reply->transfersafcd)
 IF ((request->enrollingconsentsonly=false))
  SET swhr = "1=1"
 ELSE
  SET swhr = build("pt_c.reason_for_consent_cd = ",enrolling)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGIBLE",1,eligible)
 IF ((request->orgsecurity=1))
  SET userorgstr = builduserorglist("pt_c.consenting_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 SET cntc = 0
 SET stat = alterlist(reply->consents,cntc)
 IF (numofprotocols > 0)
  SELECT INTO "NL:"
   pt_c.*, p.name_first, p.name_last,
   p.name_full_formatted, p.person_id, poolid_d = decode(p_a.seq,p_a.alias_pool_cd,- (9.0)),
   pr_am.prot_amendment_id, pr_am.prot_master_id, pr_m.primary_mnemonic,
   regid_d = decode(prcr.seq,prcr.reg_id,- (9.0))
   FROM (dummyt d1  WITH seq = value(numofprotocols)),
    prot_master pr_m,
    prot_amendment pr_am,
    person p,
    dummyt d4,
    dummyt d6,
    person_alias p_a,
    pt_consent pt_c,
    pt_reg_consent_reltn prcr
   PLAN (d1)
    JOIN (pr_m
    WHERE (pr_m.prot_master_id=request->protocols[d1.seq].protocolid))
    JOIN (pr_am
    WHERE pr_am.prot_master_id=pr_m.prot_master_id)
    JOIN (pt_c
    WHERE pt_c.prot_amendment_id=pr_am.prot_amendment_id
     AND pt_c.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND pt_c.consent_signed_dt_tm >= cnvtdatetime(sysdate)
     AND pt_c.not_returned_dt_tm >= cnvtdatetime(sysdate)
     AND parser(swhr)
     AND parser(userorgstr))
    JOIN (p
    WHERE pt_c.person_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d4)
    JOIN (p_a
    WHERE p_a.person_id=p.person_id
     AND p_a.person_alias_type_cd=mrn
     AND p_a.active_ind=1
     AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d6)
    JOIN (prcr
    WHERE (prcr.consent_id= Outerjoin(pt_c.consent_id)) )
   ORDER BY pt_c.pt_consent_id
   HEAD pt_c.pt_consent_id
    CALL echo(build("pt_c.pt_consent_id = ",pt_c.pt_consent_id)), cntc += 1
    IF (mod(cntc,50)=1)
     new = (cntc+ 50), stat = alterlist(reply->consents,new)
    ENDIF
    reply->consents[cntc].personid = p.person_id, reply->consents[cntc].lastname = p.name_last, reply
    ->consents[cntc].firstname = p.name_first,
    reply->consents[cntc].namefullformatted = p.name_full_formatted, reply->consents[cntc].protalias
     = pr_m.primary_mnemonic, reply->consents[cntc].protocolid = pr_am.prot_master_id,
    reply->consents[cntc].dateconissued = pt_c.consent_released_dt_tm, reply->consents[cntc].
    reasonforcon_cd = pt_c.reason_for_consent_cd, reply->consents[cntc].conprotamendmentid = pt_c
    .prot_amendment_id,
    reply->consents[cntc].amendment_nbr = pr_am.amendment_nbr, reply->consents[cntc].revision_nbr_txt
     = pr_am.revision_nbr_txt, reply->consents[cntc].conid = pt_c.consent_id,
    reply->consents[cntc].ptconid = pt_c.pt_consent_id, reply->consents[cntc].eligprotamendmentid =
    0.0, reply->consents[cntc].pteligtrackingid = 0.0,
    reply->consents[cntc].regid = regid_d, reply->consents[cntc].protquestionnaireid = 0.0, cntm = 0
   DETAIL
    IF ((poolid_d != - (9.0)))
     cntm += 1
     IF (mod(cntm,10)=1)
      new = (cntm+ 10), stat = alterlist(reply->consents[cntc].mrns,new)
     ENDIF
     reply->consents[cntc].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->
     consents[cntc].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
    ENDIF
   FOOT  pt_c.pt_consent_id
    stat = alterlist(reply->consents[cntc].mrns,cntm)
   WITH dontcare = p_a, outerjoin = d6, dontcare = d4,
    nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->consents,cntc)
 CALL echo(build("cntC: ",cntc))
 IF (cntc > 0)
  SELECT INTO "nl:"
   FROM pt_elig_consent_reltn pecr,
    pt_elig_tracking pet,
    (dummyt d1  WITH seq = value(cntc))
   PLAN (d1)
    JOIN (pecr
    WHERE (pecr.consent_id=reply->consents[d1.seq].conid))
    JOIN (pet
    WHERE (pet.pt_elig_tracking_id= Outerjoin(pecr.pt_elig_tracking_id)) )
   DETAIL
    reply->consents[d1.seq].pteligtrackingid = pecr.pt_elig_tracking_id, reply->consents[d1.seq].
    protquestionnaireid = pet.prot_questionnaire_id, reply->consents[d1.seq].eligprotamendmentid =
    pet.prot_amendment_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM assign_elig_reltn aer,
    prot_cohort pc,
    prot_stratum ps,
    (dummyt d1  WITH seq = value(cntc))
   PLAN (d1)
    JOIN (aer
    WHERE (aer.pt_elig_tracking_id=reply->consents[d1.seq].pteligtrackingid)
     AND aer.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pc
    WHERE aer.cohort_id=pc.cohort_id
     AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (ps
    WHERE pc.stratum_id=ps.stratum_id
     AND ps.end_effective_dt_tm >= cnvtdatetime(sysdate))
   HEAD aer.assign_elig_reltn_id
    reply->consents[d1.seq].stratumlabel = ps.stratum_label
    IF (uar_get_code_meaning(ps.stratum_cohort_type_cd)="DEFAULT")
     reply->consents[d1.seq].cohort_label = ""
    ELSE
     reply->consents[d1.seq].cohort_label = pc.cohort_label
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pt_prot_reg pt,
    (dummyt d1  WITH seq = value(cntc))
   PLAN (d1)
    JOIN (pt
    WHERE (pt.person_id=reply->consents[d1.seq].personid)
     AND (pt.prot_master_id=reply->consents[d1.seq].protocolid)
     AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    reply->consents[d1.seq].isenrolled = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 GO TO noecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo("",1)
 CALL echo("These are the consents",1)
 SET numofc = size(reply->consents,5)
 CALL echo("--------------------------------------------------------------")
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO numofc)
   CALL echo(build("R->C[",x,"]->PersonID = ",reply->consents[x].personid))
   CALL echo(build("R->C[",x,"]->ProtocolID = ",reply->consents[x].protocolid))
   CALL echo(build("R->C[",x,"]->ConProtAmendmentID = ",reply->consents[x].conprotamendmentid))
   CALL echo(build("R->C[",x,"]->ConID = ",reply->consents[x].conid))
   CALL echo(build("R->C[",x,"]->EligProtAmendmentID = ",reply->consents[x].eligprotamendmentid))
   CALL echo(build("R->C[",x,"]->RegID = ",reply->consents[x].regid))
   CALL echo(build("R->C[",x,"]->LastName = ",reply->consents[x].lastname))
   CALL echo(build("R->C[",x,"]->FirstName = ",reply->consents[x].firstname))
   CALL echo(build("R->C[",x,"]->NameFullFormatted = ",reply->consents[x].namefullformatted))
   CALL echo(build("R->C[",x,"]->ProtAlias = ",reply->consents[x].protalias))
   CALL echo(build("R->C[",x,"]->DateConIssued = ",reply->consents[x].dateconissued))
   CALL echo(build("R->C[",x,"]->PtEligTrackingID = ",reply->consents[x].pteligtrackingid))
   CALL echo(build("R->C[",x,"]->ReasonForCon_cd = ",reply->consents[x].reasonforcon_cd))
   SET numofmrn = size(reply->consents[x].mrns,5)
   FOR (y = 1 TO numofmrn)
     CALL echo("    ------------------------------------------------------")
     CALL echo(build("    R->C[",x,"]->MRNs[",y,"]->MRN = ",
       reply->consents[x].mrns[y].mrn))
     CALL echo(build("    R->C[",x,"]->MRNs[",y,"]->alias_pool_cd = ",
       reply->consents[x].mrns[y].alias_pool_cd))
   ENDFOR
   CALL echo("    ------------------------------------------------------")
   CALL echo("--------------------------------------------------------------")
 ENDFOR
 CALL echo("--------------------------------------------------------------")
 CALL echo(build("MRN =",mrn))
#noecho
 SET last_mod = "011"
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
