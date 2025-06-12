CREATE PROGRAM ct_get_pt_pndng_vrfctn:dba
 RECORD reply(
   1 enrolls[*]
     2 cur_dateamendassignstart = dq8
     2 cur_dateamendassignend = dq8
     2 cur_protamendid = f8
     2 first_dateamendassignstart = dq8
     2 first_dateamendassignend = dq8
     2 first_protamendid = f8
     2 elig_protamendid = f8
     2 enrollingorgid = f8
     2 regid = f8
     2 personid = f8
     2 protocolid = f8
     2 registry_ind = i2
     2 protaccessionnbr = vc
     2 lastname = vc
     2 firstname = vc
     2 namefullformatted = vc
     2 stratumlabel = vc
     2 protalias = vc
     2 dateonstudy = dq8
     2 pteligtrackingid = f8
     2 cur_amendmentnbr = i4
     2 cur_revisionnbrtxt = c30
     2 cohort_label = c30
     2 dateconsent = dq8
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
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 DECLARE cntp = i4 WITH protect, noconstant(0)
 DECLARE cntm = i4 WITH protect, noconstant(0)
 DECLARE new = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE mrn = f8 WITH protect, noconstant(0.0)
 DECLARE eligible = f8 WITH protect, noconstant(0.0)
 DECLARE numofprotocols = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE aliaspoolcount = i4 WITH protected, noconstant(0)
 DECLARE aliaspoollist = vc
 DECLARE registry_cd = f8 WITH constant(uar_get_code_by("MEANING",17906,"REGISTRY"))
 SET numofprotocols = size(request->protocols,5)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGIBLE",1,eligible)
 CALL echo(build("ELIGIBLE is ",eligible))
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn)
 CALL echo(build2("MRN is ",mrn))
 SET aliaspoollist = "p_a.alias_pool_cd NOT IN ("
 SELECT INTO "NL:"
  oap.alias_pool_cd
  FROM org_alias_pool_reltn oap,
   ct_excluded_clients ec,
   organization o
  PLAN (ec
   WHERE ec.active_ind=1)
   JOIN (o
   WHERE o.organization_id=ec.organization_id
    AND (o.logical_domain_id=domain_reply->logical_domain_id))
   JOIN (oap
   WHERE oap.organization_id=o.organization_id)
  DETAIL
   aliaspoolcount += 1
   IF (aliaspoolcount=1)
    aliaspoollist = build(aliaspoollist,oap.alias_pool_cd)
   ELSE
    aliaspoollist = build(aliaspoollist,", ",oap.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (aliaspoolcount=0)
  SET aliaspoollist = "p_a.alias_pool_cd NOT IN (-1)"
 ELSE
  SET aliaspoollist = build(aliaspoollist,")")
 ENDIF
 CALL echo(build("AliasPoolList is: ",aliaspoollist))
 IF ((request->orgsecurity=1))
  SET userorgstr = builduserorglist("p_pr_r.enrolling_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 IF ((request->verifiedviewstate=0))
  CALL echo(build("Select # 1"))
  IF (numofprotocols > 0)
   SELECT INTO "NL:"
    p.name_first, p.name_last, p.name_full_formatted,
    p.person_id, pr_m.primary_mnemonic, p_pr_r.on_study_dt_tm,
    p_a.alias, poolid_d = decode(p_a.seq,p_a.alias_pool_cd,- (9.0)), pr_am.prot_master_id,
    pr_am.prot_amendment_id, p_e_t.pt_elig_tracking_id, p_q.prot_amendment_id,
    p_pr_r.reg_id, p_pr_r.prot_accession_nbr, p_c.consent_signed_dt_tm
    FROM (dummyt d1  WITH seq = value(numofprotocols)),
     prot_master pr_m,
     prot_amendment pr_am,
     pt_elig_tracking p_e_t,
     person p,
     person_alias p_a,
     dummyt d2,
     pt_reg_elig_reltn rltn,
     pt_prot_reg p_pr_r,
     prot_questionnaire p_q,
     pt_reg_consent_reltn p_r_c_r,
     pt_consent p_c
    PLAN (d1)
     JOIN (pr_m
     WHERE (pr_m.prot_master_id=request->protocols[d1.seq].protocolid))
     JOIN (pr_am
     WHERE pr_am.prot_master_id=pr_m.prot_master_id)
     JOIN (p_q
     WHERE p_q.prot_amendment_id=pr_am.prot_amendment_id)
     JOIN (p_e_t
     WHERE p_e_t.prot_questionnaire_id=p_q.prot_questionnaire_id
      AND p_e_t.elig_status_cd=eligible)
     JOIN (p
     WHERE p.person_id=p_e_t.person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (rltn
     WHERE rltn.pt_elig_tracking_id=p_e_t.pt_elig_tracking_id)
     JOIN (p_pr_r
     WHERE p_pr_r.reg_id=rltn.reg_id
      AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND parser(userorgstr))
     JOIN (p_r_c_r
     WHERE p_pr_r.reg_id=p_r_c_r.reg_id
      AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (p_c
     WHERE p_c.consent_id=p_r_c_r.consent_id
      AND p_c.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (d2)
     JOIN (p_a
     WHERE p_a.person_id=p.person_id
      AND p_a.person_alias_type_cd=mrn
      AND p_a.active_ind=1
      AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND parser(aliaspoollist))
    ORDER BY p_e_t.pt_elig_tracking_id
    HEAD p_e_t.pt_elig_tracking_id
     cntp += 1
     IF (mod(cntp,50)=1)
      new = (cntp+ 50), stat = alterlist(reply->enrolls,new)
     ENDIF
     reply->enrolls[cntp].elig_protamendid = p_q.prot_amendment_id, reply->enrolls[cntp].dateonstudy
      = p_pr_r.on_study_dt_tm, reply->enrolls[cntp].personid = p.person_id,
     reply->enrolls[cntp].protocolid = pr_am.prot_master_id, reply->enrolls[cntp].lastname = p
     .name_last, reply->enrolls[cntp].firstname = p.name_first,
     reply->enrolls[cntp].namefullformatted = p.name_full_formatted, reply->enrolls[cntp].protalias
      = pr_m.primary_mnemonic, reply->enrolls[cntp].regid = p_pr_r.reg_id,
     reply->enrolls[cntp].enrollingorgid = p_pr_r.enrolling_organization_id, reply->enrolls[cntp].
     pteligtrackingid = p_e_t.pt_elig_tracking_id, reply->enrolls[cntp].protaccessionnbr = p_pr_r
     .prot_accession_nbr,
     reply->enrolls[cntp].dateconsent = p_c.consent_signed_dt_tm, cntm = 0
    DETAIL
     IF ((poolid_d != - (9.0)))
      cntm += 1
      IF (mod(cntm,10)=1)
       new = (cntm+ 10), stat = alterlist(reply->enrolls[cntp].mrns,new)
      ENDIF
      reply->enrolls[cntp].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->
      enrolls[cntp].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
     ENDIF
    FOOT  p_e_t.pt_elig_tracking_id
     stat = alterlist(reply->enrolls[cntp].mrns,cntm)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->enrolls,cntp)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->verifiedviewstate=1))
  CALL echo(build("Select # 2"))
  IF (numofprotocols > 0)
   SELECT INTO "NL:"
    p.name_first, p.name_last, p.name_full_formatted,
    p.person_id, pr_m.primary_mnemonic, p_pr_r.on_study_dt_tm,
    p_a.alias, poolid_d = decode(p_a.seq,p_a.alias_pool_cd,- (9.0)), enrollingorgid_d = decode(p_pr_r
     .seq,p_pr_r.enrolling_organization_id,- (9.0)),
    regid_d = decode(p_pr_r.seq,p_pr_r.reg_id,- (9.0)), onstudy_d = decode(p_pr_r.seq,p_pr_r
     .on_study_dt_tm,cnvtdatetime("31-DEC-2100 00:00:00.00")), pr_am.prot_master_id,
    pr_am.prot_amendment_id, p_e_t.pt_elig_tracking_id, p_q.prot_amendment_id,
    p_pr_r.reg_id, p_pr_r.prot_accession_nbr, p_c.consent_signed_dt_tm
    FROM (dummyt d1  WITH seq = value(numofprotocols)),
     prot_master pr_m,
     prot_amendment pr_am,
     prot_questionnaire p_q,
     pt_elig_tracking p_e_t,
     person p,
     person_alias p_a,
     dummyt d2,
     dummyt d3,
     pt_reg_elig_reltn rltn,
     pt_prot_reg p_pr_r,
     pt_reg_consent_reltn p_r_c_r,
     pt_consent p_c
    PLAN (d1)
     JOIN (pr_m
     WHERE (pr_m.prot_master_id=request->protocols[d1.seq].protocolid))
     JOIN (pr_am
     WHERE pr_am.prot_master_id=pr_m.prot_master_id)
     JOIN (p_q
     WHERE p_q.prot_amendment_id=pr_am.prot_amendment_id)
     JOIN (p_e_t
     WHERE p_e_t.prot_questionnaire_id=p_q.prot_questionnaire_id
      AND p_e_t.elig_status_cd=eligible)
     JOIN (p
     WHERE p.person_id=p_e_t.person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (d2)
     JOIN (p_a
     WHERE p_a.person_id=p.person_id
      AND p_a.person_alias_type_cd=mrn
      AND p_a.active_ind=1
      AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND parser(aliaspoollist))
     JOIN (d3)
     JOIN (rltn
     WHERE rltn.pt_elig_tracking_id=p_e_t.pt_elig_tracking_id)
     JOIN (p_pr_r
     WHERE p_pr_r.reg_id=rltn.reg_id
      AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (p_r_c_r
     WHERE p_pr_r.reg_id=p_r_c_r.reg_id
      AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (p_c
     WHERE p_c.consent_id=p_r_c_r.consent_id
      AND p_c.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ORDER BY p_e_t.pt_elig_tracking_id
    HEAD p_e_t.pt_elig_tracking_id
     cntp += 1
     IF (mod(cntp,50)=1)
      new = (cntp+ 50), stat = alterlist(reply->enrolls,new)
     ENDIF
     reply->enrolls[cntp].elig_protamendid = p_q.prot_amendment_id, reply->enrolls[cntp].dateonstudy
      = onstudy_d, reply->enrolls[cntp].personid = p.person_id,
     reply->enrolls[cntp].protocolid = pr_am.prot_master_id, reply->enrolls[cntp].lastname = p
     .name_last, reply->enrolls[cntp].firstname = p.name_first,
     reply->enrolls[cntp].namefullformatted = p.name_full_formatted, reply->enrolls[cntp].protalias
      = pr_m.primary_mnemonic, reply->enrolls[cntp].regid = regid_d,
     reply->enrolls[cntp].enrollingorgid = enrollingorgid_d, reply->enrolls[cntp].pteligtrackingid =
     p_e_t.pt_elig_tracking_id, reply->enrolls[cntp].protaccessionnbr = p_pr_r.prot_accession_nbr,
     reply->enrolls[cntp].dateconsent = p_c.consent_signed_dt_tm, cntm = 0
    DETAIL
     IF ((poolid_d != - (9.0)))
      cntm += 1
      IF (mod(cntm,10)=1)
       new = (cntm+ 10), stat = alterlist(reply->enrolls[cntp].mrns,new)
      ENDIF
      reply->enrolls[cntp].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->
      enrolls[cntp].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
     ENDIF
    FOOT  p_e_t.pt_elig_tracking_id
     stat = alterlist(reply->enrolls[cntp].mrns,cntm)
    WITH outerjoin = d3
   ;end select
   SET stat = alterlist(reply->enrolls,cntp)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (cntp > 0)
  SELECT INTO "NL:"
   cpaa.prot_amendment_id, cpaa.beg_effective_dt_tm
   FROM ct_pt_amd_assignment cpaa,
    prot_amendment pa,
    ct_prot_type_config cfg,
    (dummyt d1  WITH seq = value(cntp))
   PLAN (d1)
    JOIN (cpaa
    WHERE (cpaa.reg_id=reply->enrolls[d1.seq].regid)
     AND cpaa.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pa
    WHERE pa.prot_amendment_id=cpaa.prot_amendment_id)
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND cfg.item_cd=registry_cd
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   ORDER BY cpaa.beg_effective_dt_tm
   HEAD REPORT
    reply->enrolls[d1.seq].first_protamendid = cpaa.prot_amendment_id, reply->enrolls[d1.seq].
    first_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[d1.seq].
    first_dateamendassignend = cpaa.assign_end_dt_tm
   DETAIL
    reply->enrolls[d1.seq].cur_protamendid = cpaa.prot_amendment_id, reply->enrolls[d1.seq].
    cur_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[d1.seq].cur_dateamendassignend
     = cpaa.assign_end_dt_tm,
    reply->enrolls[d1.seq].cur_amendmentnbr = pa.amendment_nbr, reply->enrolls[d1.seq].
    cur_revisionnbrtxt = pa.revision_nbr_txt
    IF (uar_get_code_meaning(cfg.config_value_cd)="YES")
     reply->enrolls[d1.seq].registry_ind = 1
    ELSE
     reply->enrolls[d1.seq].registry_ind = 0
    ENDIF
    IF ((reply->enrolls[d1.seq].first_protamendid=0))
     reply->enrolls[d1.seq].first_protamendid = cpaa.prot_amendment_id, reply->enrolls[d1.seq].
     first_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[d1.seq].
     first_dateamendassignend = cpaa.assign_end_dt_tm
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM assign_reg_reltn arr,
    prot_cohort pc,
    prot_stratum ps,
    (dummyt d1  WITH seq = value(cntp))
   PLAN (d1)
    JOIN (arr
    WHERE (arr.reg_id=reply->enrolls[d1.seq].regid)
     AND arr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc
    WHERE arr.cohort_id=pc.cohort_id
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (ps
    WHERE pc.stratum_id=ps.stratum_id
     AND ps.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY arr.assign_reg_reltn_id
   HEAD arr.assign_reg_reltn_id
    reply->enrolls[d1.seq].stratumlabel = ps.stratum_label
    IF (uar_get_code_meaning(ps.stratum_cohort_type_cd)="DEFAULT")
     reply->enrolls[d1.seq].cohort_label = ""
    ELSE
     reply->enrolls[d1.seq].cohort_label = pc.cohort_label
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 GO TO noecho
 CALL echo(build("ELIGIBLE =",eligible))
 CALL echo(build("MRN =",mrn))
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 SET numofp = size(reply->enrolls,5)
 FOR (x = 1 TO numofp)
   CALL echo(build("Reply->Enrolls[",x,"]->RegID = ",reply->enrolls[x].regid))
   CALL echo(build("Reply->Enrolls[",x,"]->Cur_ProtAmendID = ",reply->enrolls[x].cur_protamendid))
   CALL echo(build("Reply->Enrolls[",x,"]->First_ProtAmendID = ",reply->enrolls[x].first_protamendid)
    )
   CALL echo(build("Reply->Enrolls[",x,"]->Elig_ProtAmendID = ",reply->enrolls[x].elig_protamendid))
   CALL echo(build("Reply->Enrolls[",x,"]->ProtocolID = ",reply->enrolls[x].protocolid))
   CALL echo(build("Reply->Enrolls[",x,"]->PersonID = ",reply->enrolls[x].personid))
   CALL echo(build("Reply->Enrolls[",x,"]->LastName = ",reply->enrolls[x].lastname))
   CALL echo(build("Reply->Enrolls[",x,"]->FirstName = ",reply->enrolls[x].firstname))
   CALL echo(build("Reply->Enrolls[",x,"]->NameFullFormatted = ",reply->enrolls[x].namefullformatted)
    )
   CALL echo(build("Reply->Enrolls[",x,"]->ProtAlias = ",reply->enrolls[x].protalias))
   CALL echo(build("Reply->Enrolls[",x,"]->DateOnStudy = ",reply->enrolls[x].dateonstudy))
   CALL echo(build("Reply->Enrolls[",x,"]->EnrollingOrgID  = ",reply->enrolls[x].enrollingorgid))
   CALL echo(build("Reply->Enrolls[",x,"]->ProtAccessionNbr  = ",reply->enrolls[x].protaccessionnbr))
   CALL echo(build("Reply->Enrolls[",x,"]->DateConsent = ",reply->enrolls[x].dateconsent))
   CALL echo("        ------------------------------------------------------")
   SET numofmrn = size(reply->enrolls[x].mrns,5)
   FOR (y = 1 TO numofmrn)
    CALL echo(build("        Reply->Enrolls[",x,"]->MRNs[",y,"]->MRN = ",
      reply->enrolls[x].mrns[y].mrn))
    CALL echo(build("        Reply->Enrolls[",x,"]->MRNs[",y,"]->alias_pool_cd = ",
      reply->enrolls[x].mrns[y].alias_pool_cd))
   ENDFOR
   CALL echo("        ------------------------------------------------------")
   CALL echo("--------------------------------------------------------------")
 ENDFOR
 CALL echo("")
 CALL echo(build("Request->VerifiedViewState  =",request->verifiedviewstate))
#noecho
 SET last_mod = "016"
 SET mod_date = "May 27, 2024"
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
