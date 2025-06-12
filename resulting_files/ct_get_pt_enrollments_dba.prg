CREATE PROGRAM ct_get_pt_enrollments:dba
 RECORD reply(
   1 curdate = dq8
   1 tara = i4
   1 groupwidetara = i4
   1 prot_status_cd = f8
   1 prot_status_disp = vc
   1 prot_status_desc = vc
   1 prot_status_mean = c12
   1 as[*]
     2 amendstatus_cd = f8
     2 amendstatus_disp = vc
     2 amendstatus_desc = vc
     2 amendstatus_mean = c12
     2 datebegactive = dq8
     2 dateendactive = dq8
     2 datebegsusp = dq8
     2 nbr = i4
     2 id = f8
     2 revisionnbrtxt = c30
     2 revisionind = i2
   1 activeamendid = f8
   1 activeamendnbr = f8
   1 activedttm = dq8
   1 activerevisionind = i2
   1 activerevisionnbrtxt = c30
   1 highestamendid = f8
   1 highestamendnbr = f8
   1 registry_only_ind = i2
   1 enrolls[*]
     2 prot_master_id = f8
     2 prot_status_cd = f8
     2 prot_status_disp = vc
     2 prot_status_desc = vc
     2 prot_status_mean = c12
     2 prot_type_cd = f8
     2 prot_type_disp = vc
     2 prot_type_desc = vc
     2 prot_type_mean = c12
     2 cur_dateamendassignstart = dq8
     2 cur_dateamendassignend = dq8
     2 cur_protamendid = f8
     2 cur_amendmentnbr = i4
     2 cur_revisionnbrtxt = c30
     2 cur_revisionind = i2
     2 first_dateamendassignstart = dq8
     2 first_dateamendassignend = dq8
     2 first_protamendid = f8
     2 elig_protamendid = f8
     2 ptprotregid = f8
     2 regid = f8
     2 eligid = f8
     2 protalias = vc
     2 nomenclatureid = f8
     2 removalorgid = f8
     2 removalorgname = vc
     2 removalperid = f8
     2 removalpername = vc
     2 protaccessionnbr = vc
     2 dateonstudy = dq8
     2 dateoffstudy = dq8
     2 dateontherapy = dq8
     2 dateofftherapy = dq8
     2 datefirstpdfail = dq8
     2 firstdisrelevent_cd = f8
     2 firstdisrelevent_disp = vc
     2 firstdisrelevent_desc = vc
     2 firstdisrelevent_mean = c12
     2 enrollingorgid = f8
     2 enrollingorgname = vc
     2 protarmid = f8
     2 diagtype_cd = f8
     2 diagtype_disp = vc
     2 diagtype_desc = vc
     2 diagtype_mean = c12
     2 bestresp_cd = f8
     2 bestresp_disp = vc
     2 bestresp_desc = vc
     2 bestresp_mean = c12
     2 datefirstpd = dq8
     2 datefirstcr = dq8
     2 regupdtcnt = i4
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 namefullformatted = vc
     2 stratumlabel = vc
     2 stratumid = f8
     2 follow_up_status_cd = f8
     2 follow_up_status_disp = vc
     2 txremovalorgid = f8
     2 txremovalorgname = vc
     2 txremovalperid = f8
     2 txremovalpername = vc
     2 txremovalreason_cd = f8
     2 txremovalreason_disp = vc
     2 txremovalreason_desc = vc
     2 txremovalreason_mean = c12
     2 txremovalreason = c255
     2 removalreason_cd = f8
     2 removalreason_disp = vc
     2 removalreason_desc = vc
     2 removalreason_mean = c12
     2 removalreason = c255
     2 episode_id = f8
     2 cohort_label = c30
     2 cohort_id = f8
     2 txorgid = f8
     2 txorgname = vc
     2 txperid = f8
     2 txpername = vc
     2 txcomment = vc
     2 statusenum = i4
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
 DECLARE cnte = i2 WITH protect, noconstant(0)
 DECLARE cnta = i2 WITH protect, noconstant(0)
 DECLARE cnts = i2 WITH protect, noconstant(0)
 DECLARE cntm = i2 WITH protect, noconstant(0)
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE nnumprotocols = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE userorgstr = vc WITH protect
 DECLARE whrdate = vc WITH protect
 DECLARE whrpt = vc WITH protect
 DECLARE whrprot = vc WITH protect
 DECLARE mrn = f8 WITH public, noconstant(0.0)
 DECLARE primary = f8 WITH public, noconstant(0.0)
 DECLARE enrolling = f8 WITH public, noconstant(0.0)
 DECLARE cfg_registry_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"REGISTRY"))
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE cntp = i2 WITH protect, noconstant(0)
 IF ((request->ptqualifier=1))
  SET whrdate =
'(p_pr_r.off_study_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00") or p_pr_r.off_study_dt_tm >= cnvtdatetime(		Request->UT\
CMaxDate))\
'
 ELSEIF ((request->ptqualifier=2))
  SET whrdate =
'(p_pr_r.tx_completion_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00") or p_pr_r.tx_completion_dt_tm >= 		cnvtdatetime(Req\
uest->UTCMaxDate))\
'
 ELSE
  SET whrdate = "1=1"
 ENDIF
 IF ((request->patientid > 0))
  SET whrpt = "p_pr_r.person_id = Request->PatientID"
 ELSE
  SET whrpt = "1=1"
 ENDIF
 SET nnumprotocols = size(request->protocols,5)
 IF (nnumprotocols > 0)
  SET whrprot =
  "EXPAND(num, 1, nNumProtocols, pr_m.prot_master_id, request->Protocols[num]->ProtocolId)"
 ELSEIF ((request->protocolid > 0))
  SET whrprot = "pr_m.prot_master_id = Request->ProtocolID"
 ELSE
  SET whrprot =
  "pr_m.logical_domain_id = domain_reply->logical_domain_id AND     		pr_m.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)"
 ENDIF
 IF ((request->orgsecurity=1))
  SET userorgstr = builduserorglist("p_pr_r.enrolling_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 SET reply->curdate = cnvtdatetime(sysdate)
 IF ((request->protocolid > 0))
  SELECT INTO "NL:"
   pr_s.beg_effective_dt_tm, pr_s.prot_suspension_id, pr_am.*,
   pr_m.prot_status_cd
   FROM prot_master pr_m,
    prot_amendment pr_am,
    prot_suspension pr_s
   PLAN (pr_m
    WHERE parser(whrprot))
    JOIN (pr_am
    WHERE pr_m.prot_master_id=pr_am.prot_master_id)
    JOIN (pr_s
    WHERE (pr_s.prot_amendment_id= Outerjoin(pr_am.prot_amendment_id))
     AND (pr_s.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   ORDER BY pr_am.amendment_nbr, pr_am.revision_seq, pr_s.prot_suspension_id
   HEAD REPORT
    reply->prot_status_cd = pr_m.prot_status_cd
   HEAD pr_am.prot_amendment_id
    cnta += 1, stat = alterlist(reply->as,cnta), reply->as[cnta].amendstatus_cd = pr_am
    .amendment_status_cd,
    reply->as[cnta].nbr = pr_am.amendment_nbr, reply->as[cnta].id = pr_am.prot_amendment_id, reply->
    as[cnta].revisionind = pr_am.revision_ind,
    reply->as[cnta].revisionnbrtxt = pr_am.revision_nbr_txt, reply->as[cnta].datebegactive =
    cnvtdatetime(pr_am.amendment_dt_tm)
    IF (cnta > 1)
     reply->as[(cnta - 1)].dateendactive = cnvtdatetime(pr_am.amendment_dt_tm)
    ENDIF
   HEAD pr_s.prot_suspension_id
    IF (pr_s.prot_suspension_id != 0)
     reply->as[cnta].datebegsusp = cnvtdatetime(pr_s.beg_effective_dt_tm)
    ENDIF
   FOOT REPORT
    reply->as[cnta].dateendactive = cnvtdatetime("31-DEC-2100 00:00:00.00")
   WITH nocounter
  ;end select
  SET highestamdnbr = 0
  SET highestamdid = 0
  SET highestrevisionind = 0
  SET highestrevisionnbrtxt = ""
  SET pmid = request->protocolid
  CALL echo("before")
  EXECUTE ct_get_highest_a_nbr
  CALL echo(build("after ",highestamdid))
  SET reply->highestamendid = highestamdid
  SET reply->highestamendnbr = highestamdnbr
  SELECT INTO "NL:"
   pr_am.targeted_accrual, pr_am.groupwide_targeted_accrual
   FROM prot_amendment pr_am
   WHERE (pr_am.prot_amendment_id=reply->highestamendid)
   DETAIL
    reply->tara = pr_am.targeted_accrual, reply->groupwidetara = pr_am.groupwide_targeted_accrual
   WITH nocounter
  ;end select
  SET activeamdnbr = 0
  SET activeamdid = 0
  SET activedttm = cnvtdatetime(sysdate)
  SET activerevisionind = 0
  SET activerevisionnbrtxt = ""
  SET pmid = request->protocolid
  EXECUTE ct_get_active_a_nbr
  SET reply->activeamendid = activeamdid
  SET reply->activeamendnbr = activeamdnbr
  SET reply->activedttm = activedttm
  SET reply->activerevisionind = activerevisionind
  SET reply->activerevisionnbrtxt = activerevisionnbrtxt
 ENDIF
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn)
 CALL echo(build("Request->ProtocolID = ",request->protocolid))
 RECORD condate(
   1 list[*]
     2 consenteddate = dq8
     2 reg_id = f8
 )
 SELECT INTO "NL:"
  FROM pt_consent pc,
   pt_prot_reg p_pr_r,
   person p,
   prot_master pr_m,
   pt_reg_consent_reltn p_r_c_r
  PLAN (pr_m
   WHERE parser(whrprot))
   JOIN (p_pr_r
   WHERE p_pr_r.prot_master_id=pr_m.prot_master_id
    AND parser(whrdate)
    AND parser(whrpt)
    AND p_pr_r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND parser(userorgstr))
   JOIN (p
   WHERE p.person_id=p_pr_r.person_id
    AND ((p.active_ind+ 0)=1)
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p_r_c_r
   WHERE p_pr_r.reg_id=p_r_c_r.reg_id
    AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pc
   WHERE pc.consent_id=p_r_c_r.consent_id
    AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY p_pr_r.pt_prot_reg_id
  HEAD p_pr_r.pt_prot_reg_id
   cntp += 1
   IF (mod(cntp,10)=1)
    stat = alterlist(condate->list,(cntp+ 10))
   ENDIF
   condate->list[cntp].consenteddate = pc.consent_signed_dt_tm, condate->list[cntp].reg_id = p_pr_r
   .reg_id
 ;end select
 SET stat = alterlist(condate->list,cntp)
 SELECT INTO "NL:"
  poolid_d = decode(p_a.seq,p_a.alias_pool_cd,- (9.0)), followupstat_d = decode(p_c.seq,p_c
   .follow_up_status_cd,0.0), followupdisp = uar_get_code_display(p_c.follow_up_status_cd)
  FROM prot_master pr_m,
   pt_prot_reg p_pr_r,
   person p,
   person_alias p_a,
   pt_control p_c
  PLAN (pr_m
   WHERE parser(whrprot))
   JOIN (p_pr_r
   WHERE p_pr_r.prot_master_id=pr_m.prot_master_id
    AND parser(whrdate)
    AND parser(whrpt)
    AND p_pr_r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND parser(userorgstr))
   JOIN (p
   WHERE p.person_id=p_pr_r.person_id
    AND ((p.active_ind+ 0)=1)
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p_a
   WHERE (p_a.person_id= Outerjoin(p.person_id))
    AND (p_a.person_alias_type_cd= Outerjoin(mrn))
    AND ((p_a.active_ind+ 0)= Outerjoin(1))
    AND (p_a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p_a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (p_c
   WHERE (p_c.person_id= Outerjoin(p.person_id))
    AND (p_c.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
  ORDER BY p_pr_r.pt_prot_reg_id
  HEAD p_pr_r.pt_prot_reg_id
   cnte += 1
   IF (mod(cnte,10)=1)
    stat = alterlist(reply->enrolls,(cnte+ 10))
   ENDIF
   reply->enrolls[cnte].prot_master_id = pr_m.prot_master_id, reply->enrolls[cnte].prot_type_cd =
   pr_m.prot_type_cd, reply->enrolls[cnte].prot_status_cd = pr_m.prot_status_cd,
   reply->enrolls[cnte].lastname = p.name_last, reply->enrolls[cnte].firstname = p.name_first, reply
   ->enrolls[cnte].namefullformatted = p.name_full_formatted,
   reply->enrolls[cnte].personid = p_pr_r.person_id, reply->enrolls[cnte].ptprotregid = p_pr_r
   .pt_prot_reg_id, reply->enrolls[cnte].regid = p_pr_r.reg_id,
   reply->enrolls[cnte].eligid = 0.0, reply->enrolls[cnte].elig_protamendid = - (9.0), reply->
   enrolls[cnte].protalias = pr_m.primary_mnemonic,
   reply->enrolls[cnte].nomenclatureid = p_pr_r.nomenclature_id, reply->enrolls[cnte].removalorgid =
   p_pr_r.removal_organization_id, reply->enrolls[cnte].removalperid = p_pr_r.removal_person_id,
   reply->enrolls[cnte].protaccessionnbr = p_pr_r.prot_accession_nbr, reply->enrolls[cnte].
   dateonstudy = p_pr_r.on_study_dt_tm, reply->enrolls[cnte].dateoffstudy = p_pr_r.off_study_dt_tm,
   reply->enrolls[cnte].dateontherapy = p_pr_r.tx_start_dt_tm, reply->enrolls[cnte].dateofftherapy =
   p_pr_r.tx_completion_dt_tm, reply->enrolls[cnte].datefirstpdfail = p_pr_r.first_pd_failure_dt_tm,
   reply->enrolls[cnte].firstdisrelevent_cd = p_pr_r.first_dis_rel_event_death_cd, reply->enrolls[
   cnte].enrollingorgid = p_pr_r.enrolling_organization_id, reply->enrolls[cnte].protarmid = p_pr_r
   .prot_arm_id,
   reply->enrolls[cnte].diagtype_cd = p_pr_r.diagnosis_type_cd, reply->enrolls[cnte].bestresp_cd =
   p_pr_r.best_response_cd, reply->enrolls[cnte].datefirstpd = p_pr_r.first_pd_dt_tm,
   reply->enrolls[cnte].datefirstcr = p_pr_r.first_cr_dt_tm, reply->enrolls[cnte].regupdtcnt = p_pr_r
   .updt_cnt, reply->enrolls[cnte].follow_up_status_cd = followupstat_d,
   reply->enrolls[cnte].follow_up_status_disp = followupdisp, reply->enrolls[cnte].txremovalorgid =
   p_pr_r.off_tx_removal_organization_id, reply->enrolls[cnte].txremovalperid = p_pr_r
   .off_tx_removal_person_id,
   reply->enrolls[cnte].txremovalreason_cd = p_pr_r.reason_off_tx_cd, reply->enrolls[cnte].
   txremovalreason = p_pr_r.reason_off_tx_desc, reply->enrolls[cnte].removalreason_cd = p_pr_r
   .removal_reason_cd,
   reply->enrolls[cnte].removalreason = p_pr_r.removal_reason_desc, reply->enrolls[cnte].episode_id
    = p_pr_r.episode_id, reply->enrolls[cnte].txorgid = p_pr_r.on_tx_organization_id,
   reply->enrolls[cnte].txperid = p_pr_r.on_tx_assign_prsnl_id, reply->enrolls[cnte].txcomment =
   p_pr_r.on_tx_comment, reply->enrolls[cnte].statusenum = p_pr_r.status_enum,
   reply->enrolls[cnte].dateconsent = cnvtdatetime("31-DEC-2100 00:00:00.00"), cntm = 0
  DETAIL
   IF (size(trim(p_a.alias),1) > 0)
    cntm += 1
    IF (mod(cntm,10)=1)
     stat = alterlist(reply->enrolls[cnte].mrns,(cntm+ 10))
    ENDIF
    reply->enrolls[cnte].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->
    enrolls[cnte].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
   ENDIF
  FOOT  p_pr_r.pt_prot_reg_id
   stat = alterlist(reply->enrolls[cnte].mrns,cntm)
   FOR (index = 1 TO cntp)
     IF ((reply->enrolls[cnte].regid=condate->list[index].reg_id))
      reply->enrolls[cnte].dateconsent = condate->list[index].consenteddate, BREAK
     ENDIF
   ENDFOR
  WITH dontcare = p_c, nocounter
 ;end select
 SET stat = alterlist(reply->enrolls,cnte)
 FREE RECORD condate
 CALL echorecord(reply->enrolls)
 CALL echo(build2("cntE is ",cnte))
 IF (cnte > 0)
  SET cur_list_size = size(reply->enrolls,5)
  SET batch_size = 100
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->enrolls,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->enrolls[idx].regid = reply->enrolls[cur_list_size].regid
    SET reply->enrolls[idx].removalorgid = reply->enrolls[cur_list_size].removalorgid
    SET reply->enrolls[idx].removalperid = reply->enrolls[cur_list_size].removalperid
    SET reply->enrolls[idx].txremovalorgid = reply->enrolls[cur_list_size].txremovalorgid
    SET reply->enrolls[idx].txremovalperid = reply->enrolls[cur_list_size].txremovalperid
    SET reply->enrolls[idx].txorgid = reply->enrolls[cur_list_size].txorgid
    SET reply->enrolls[idx].txperid = reply->enrolls[cur_list_size].txperid
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    pt_elig_tracking pet,
    pt_reg_elig_reltn rerltn
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (rerltn
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rerltn.reg_id,reply->enrolls[num].regid))
    JOIN (pet
    WHERE (pet.pt_elig_tracking_id= Outerjoin(rerltn.pt_elig_tracking_id)) )
   HEAD REPORT
    cur_idx = 0
   DETAIL
    cur_idx = locateval(num,1,cur_list_size,rerltn.reg_id,reply->enrolls[num].regid),
    CALL echo(build("cur_idx is:",cur_idx))
    IF (cur_idx > 0)
     reply->enrolls[cur_idx].eligid = pet.pt_elig_tracking_id, reply->enrolls[cur_idx].
     elig_protamendid = pet.prot_amendment_id
    ENDIF
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM organization org,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (org
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),org.organization_id,reply->enrolls[num].
     enrollingorgid)
     AND ((org.active_ind+ 0)=1)
     AND org.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND org.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    CALL echo(build("nstart =",nstart)), cur_idx = locateval(idx,1,cur_list_size,org.organization_id,
     reply->enrolls[idx].enrollingorgid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].enrollingorgname = org.org_name,cur_idx = locateval(idx,(cur_idx+ 1),
      cur_list_size,org.organization_id,reply->enrolls[idx].enrollingorgid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM organization org,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (org
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),org.organization_id,reply->enrolls[num].
     removalorgid)
     AND ((org.active_ind+ 0)=1)
     AND org.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND org.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,org.organization_id,reply->enrolls[idx].removalorgid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].removalorgname = org.org_name,cur_idx = locateval(idx,(cur_idx+ 1),
      cur_list_size,org.organization_id,reply->enrolls[idx].removalorgid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->enrolls[num].removalperid))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,p.person_id,reply->enrolls[idx].removalperid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].removalpername = p.name_full_formatted,cur_idx = locateval(idx,(cur_idx
      + 1),cur_list_size,p.person_id,reply->enrolls[idx].removalperid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM organization org,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (org
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),org.organization_id,reply->enrolls[num].
     txremovalorgid))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,org.organization_id,reply->enrolls[idx].txremovalorgid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].txremovalorgname = org.org_name,cur_idx = locateval(idx,(cur_idx+ 1),
      cur_list_size,org.organization_id,reply->enrolls[idx].txremovalorgid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->enrolls[num].txremovalperid
     ))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,p.person_id,reply->enrolls[idx].txremovalperid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].txremovalpername = p.name_full_formatted,cur_idx = locateval(idx,(
      cur_idx+ 1),cur_list_size,p.person_id,reply->enrolls[idx].txremovalperid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM organization org,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (org
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),org.organization_id,reply->enrolls[num].
     txorgid))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,org.organization_id,reply->enrolls[idx].txorgid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].txorgname = org.org_name,cur_idx = locateval(idx,(cur_idx+ 1),
      cur_list_size,org.organization_id,reply->enrolls[idx].txorgid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->enrolls[num].txperid))
   DETAIL
    cur_idx = locateval(idx,1,cur_list_size,p.person_id,reply->enrolls[idx].txperid)
    WHILE (cur_idx > 0)
     reply->enrolls[cur_idx].txpername = p.name_full_formatted,cur_idx = locateval(idx,(cur_idx+ 1),
      cur_list_size,p.person_id,reply->enrolls[idx].txperid)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  IF ((request->patientid > 0))
   SET reply->registry_only_ind = 0
  ELSE
   SET reply->registry_only_ind = - (1)
  ENDIF
  SELECT INTO "NL:"
   cpaa.prot_amendment_id, cpaa.beg_effective_dt_tm
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    ct_pt_amd_assignment cpaa,
    prot_amendment pa,
    ct_prot_type_config cfg
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cpaa
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),cpaa.reg_id,reply->enrolls[num].regid)
     AND cpaa.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pa
    WHERE pa.prot_amendment_id=cpaa.prot_amendment_id)
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND cfg.item_cd=cfg_registry_cd
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   ORDER BY cpaa.assign_end_dt_tm
   HEAD cpaa.reg_id
    cur_idx = locateval(idx,1,cur_list_size,cpaa.reg_id,reply->enrolls[idx].regid)
    IF (cur_idx > 0)
     reply->enrolls[cur_idx].first_protamendid = cpaa.prot_amendment_id, reply->enrolls[cur_idx].
     first_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[cur_idx].
     first_dateamendassignend = cpaa.assign_end_dt_tm
    ENDIF
   DETAIL
    IF (cur_idx > 0)
     reply->enrolls[cur_idx].cur_protamendid = cpaa.prot_amendment_id, reply->enrolls[cur_idx].
     cur_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[cur_idx].
     cur_dateamendassignend = cpaa.assign_end_dt_tm,
     reply->enrolls[cur_idx].cur_amendmentnbr = pa.amendment_nbr, reply->enrolls[cur_idx].
     cur_revisionnbrtxt = pa.revision_nbr_txt, reply->enrolls[cur_idx].cur_revisionind = pa
     .revision_ind
     IF ((reply->enrolls[cur_idx].first_protamendid=0))
      reply->enrolls[cur_idx].first_protamendid = cpaa.prot_amendment_id, reply->enrolls[cur_idx].
      first_dateamendassignstart = cpaa.assign_start_dt_tm, reply->enrolls[cur_idx].
      first_dateamendassignend = cpaa.assign_end_dt_tm
     ENDIF
    ENDIF
    IF ((request->patientid > 0))
     IF (uar_get_code_meaning(cfg.config_value_cd)="YES")
      reply->registry_only_ind = 2
     ENDIF
    ELSE
     IF ((reply->registry_only_ind=- (1)))
      IF (uar_get_code_meaning(cfg.config_value_cd)="YES")
       reply->registry_only_ind = 1
      ELSE
       reply->registry_only_ind = 0
      ENDIF
     ELSEIF ((reply->registry_only_ind=1))
      IF (uar_get_code_meaning(cfg.config_value_cd) != "YES")
       reply->registry_only_ind = 0
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    assign_reg_reltn arr,
    prot_cohort pc,
    prot_stratum ps
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (arr
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),arr.reg_id,reply->enrolls[num].regid)
     AND arr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc
    WHERE pc.cohort_id=arr.cohort_id
     AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (ps
    WHERE ps.stratum_id=pc.stratum_id
     AND ps.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   HEAD arr.assign_reg_reltn_id
    cur_idx = locateval(idx,1,cur_list_size,arr.reg_id,reply->enrolls[idx].regid)
    IF (cur_idx > 0)
     reply->enrolls[cur_idx].stratumlabel = ps.stratum_label, reply->enrolls[cur_idx].stratumid = ps
     .stratum_id
     IF (uar_get_code_meaning(ps.stratum_cohort_type_cd)="DEFAULT")
      reply->enrolls[cur_idx].cohort_label = "", reply->enrolls[cur_idx].cohort_id = 0
     ELSE
      reply->enrolls[cur_idx].cohort_label = pc.cohort_label, reply->enrolls[cur_idx].cohort_id = pc
      .cohort_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->enrolls,cur_list_size)
 ENDIF
 SET reply->status_data.status = "S"
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
 SET last_mod = "023"
 SET mod_date = "Sep 25, 2023"
END GO
