CREATE PROGRAM ct_get_pnt_trans_func:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cntmoved = i2 WITH protect, noconstant(0)
 DECLARE cntcnstrlsd = i2 WITH protect, noconstant(0)
 DECLARE cnttouched = i2 WITH protect, noconstant(0)
 DECLARE cntuntouched = i2 WITH protect, noconstant(0)
 DECLARE prev_amd_pnt = i2 WITH protect, constant(0)
 DECLARE no_trans_pnt = i2 WITH protect, constant(1)
 DECLARE cur_amd_pnt = i2 WITH protect, constant(2)
 DECLARE reconsent_pnt = i2 WITH protect, constant(3)
 DECLARE mrn_count = i2 WITH protect, noconstant(0)
 DECLARE alias_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cntp = i2 WITH protect, noconstant(0)
 SET last_mod = "010"
 SET mod_date = "May 14, 2007"
 SET i = 0
 SET count = 0
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,alias_cd)
 RECORD condate(
   1 list[*]
     2 consenteddate = dq8
     2 reg_id = f8
     2 amendid = f8
 )
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   pt_consent pc,
   pt_reg_consent_reltn prcr
  PLAN (ppr
   WHERE (ppr.prot_master_id=request->prot_master_id)
    AND ppr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (prcr
   WHERE ppr.reg_id=prcr.reg_id)
   JOIN (pc
   WHERE pc.consent_id=prcr.consent_id
    AND pc.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc.consent_signed_dt_tm < cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc.not_returned_reason_cd=0.0)
  ORDER BY ppr.pt_prot_reg_id
  HEAD ppr.pt_prot_reg_id
   cntp += 1
   IF (mod(cntp,10)=1)
    stat = alterlist(condate->list,(cntp+ 10))
   ENDIF
   condate->list[cntp].consenteddate = pc.consent_signed_dt_tm, condate->list[cntp].reg_id = ppr
   .reg_id, condate->list[cntp].amendid = pc.prot_amendment_id
 ;end select
 SET stat = alterlist(condate->list,cntp)
 SELECT INTO "nl:"
  pc1check = decode(prcr1.seq,"PC1","none"), pc2check = decode(pc2.seq,"PC2","none"), cpaa
  .prot_amendment_id
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment cpaa,
   person p1,
   pt_consent pc1,
   pt_consent pc2,
   prot_master pm,
   pt_reg_consent_reltn prcr1,
   pt_reg_consent_reltn prcr2,
   prot_amendment p_am,
   dummyt d1,
   dummyt d2
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id))
   JOIN (ppr
   WHERE ppr.prot_master_id=pm.prot_master_id
    AND ppr.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (cpaa
   WHERE cpaa.reg_id=ppr.reg_id
    AND cpaa.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND format(cpaa.assign_end_dt_tm,"MMDDYYY")=format(ppr.off_study_dt_tm,"MMDDYYY")
    AND  NOT ( EXISTS (
   (SELECT INTO "NL:"
    cpaa2.ct_pt_amd_assignment_id
    FROM ct_pt_amd_assignment cpaa2,
     prot_amendment pa2
    WHERE cpaa2.reg_id=cpaa.reg_id
     AND pa2.prot_amendment_id=cpaa2.prot_amendment_id
     AND ((pa2.amendment_nbr > cgpt_amendment_nbr) OR (pa2.amendment_nbr=cgpt_amendment_nbr
     AND pa2.revision_seq > cgpt_revision_seq))
     AND cpaa2.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")))))
   JOIN (p_am
   WHERE p_am.prot_amendment_id=cpaa.prot_amendment_id
    AND p_am.amendment_nbr <= cgpt_amendment_nbr)
   JOIN (p1
   WHERE p1.person_id=ppr.person_id
    AND p1.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (d1)
   JOIN (prcr1
   WHERE ppr.reg_id=prcr1.reg_id)
   JOIN (pc1
   WHERE pc1.consent_id=prcr1.consent_id
    AND pc1.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc1.not_returned_reason_cd=0.0
    AND pc1.prot_amendment_id=cgpt_amendment_id)
   JOIN (d2)
   JOIN (prcr2
   WHERE ppr.reg_id=prcr2.reg_id)
   JOIN (pc2
   WHERE pc2.consent_id=prcr2.consent_id
    AND pc2.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc2.consent_signed_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc2.not_returned_reason_cd=0.0
    AND pc2.prot_amendment_id != cgpt_amendment_id)
  ORDER BY ppr.person_id, ppr.pt_prot_reg_id DESC, cpaa.reg_id DESC,
   p_am.amendment_nbr DESC
  HEAD REPORT
   reply->protocol_name = pm.primary_mnemonic
  HEAD ppr.person_id
   count += 1, stat = alterlist(reply->pt_reg_info,count), reply->pt_reg_info[count].patient_name =
   p1.name_full_formatted,
   reply->pt_reg_info[count].patient_id = ppr.person_id, reply->pt_reg_info[count].reg_id = ppr
   .reg_id, reply->pt_reg_info[count].enrolling_org_id = ppr.enrolling_organization_id,
   reply->pt_reg_info[count].assign_start_dt_tm = cpaa.assign_start_dt_tm, reply->pt_reg_info[count].
   on_study_dt_tm = ppr.on_study_dt_tm, reply->pt_reg_info[count].off_study_dt_tm =
   IF (ppr.off_study_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")) null
   ELSE ppr.off_study_dt_tm
   ENDIF
   ,
   reply->pt_reg_info[count].tx_completion_dt_tm =
   IF (ppr.tx_completion_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")) null
   ELSE ppr.tx_completion_dt_tm
   ENDIF
   , reply->pt_reg_info[count].consent_released_dt_tm =
   IF (pc1check="PC1") pc1.consent_released_dt_tm
   ELSE null
   ENDIF
   , reply->pt_reg_info[count].consent_signed_dt_tm =
   IF (pc1check="PC1") pc1.consent_signed_dt_tm
   ELSE null
   ENDIF
   ,
   reply->pt_reg_info[count].updt_cnt = ppr.updt_cnt, reply->pt_reg_info[count].prot_amendment_nbr =
   p_am.amendment_nbr, reply->pt_reg_info[count].prot_amendment_id = cpaa.prot_amendment_id,
   reply->pt_reg_info[count].revision_ind = p_am.revision_ind, reply->pt_reg_info[count].
   revision_nbr_txt = p_am.revision_nbr_txt, reply->pt_reg_info[count].deceased_dt_tm =
   IF (p1.deceased_dt_tm=null) null
   ELSE p1.deceased_dt_tm
   ENDIF
   ,
   reply->pt_reg_info[count].has_pending_consent = false
   IF (cpaa.prot_amendment_id=cgpt_amendment_id)
    cntmoved += 1, reply->pt_reg_info[count].patient_type = cur_amd_pnt
    IF (pc1check="PC1"
     AND uar_get_code_meaning(pc1.reason_for_consent_cd)="ENROLLING")
     reply->pt_reg_info[count].enrolled_on_cur_amd = true
    ELSE
     reply->pt_reg_info[count].enrolled_on_cur_amd = false
    ENDIF
   ELSEIF (pc1check="PC1"
    AND pc1.consent_received_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00")
    AND uar_get_code_meaning(pc1.reason_for_consent_cd) IN ("RECONSENT", "RECONSENTSAF", "TRANSFER")
    AND pc1.prot_amendment_id=cgpt_amendment_id)
    cntcnstrlsd += 1, reply->pt_reg_info[count].patient_type = reconsent_pnt, reply->pt_reg_info[
    count].enrolled_on_cur_amd = false,
    reply->pt_reg_info[count].has_pending_consent = true
   ELSEIF (cpaa.transfer_checked_amendment_id=cgpt_amendment_id)
    cnttouched += 1, reply->pt_reg_info[count].patient_type = no_trans_pnt, reply->pt_reg_info[count]
    .enrolled_on_cur_amd = false
   ELSE
    cntuntouched += 1, reply->pt_reg_info[count].patient_type = prev_amd_pnt, reply->pt_reg_info[
    count].enrolled_on_cur_amd = false
   ENDIF
   IF (pc2check="PC2")
    reply->pt_reg_info[count].has_pending_consent = true
   ENDIF
   mrn_count = 0
  DETAIL
   mrn_count += 1
  FOOT  ppr.pt_prot_reg_id
   FOR (index = 1 TO cntp)
     IF ((condate->list[index].amendid != cgpt_amendment_id)
      AND (reply->pt_reg_info[count].reg_id=condate->list[index].reg_id)
      AND (reply->pt_reg_info[count].prot_amendment_id=condate->list[index].amendid))
      reply->pt_reg_info[count].consent_signed_dt_tm = condate->list[index].consenteddate, BREAK
     ENDIF
   ENDFOR
  WITH dontcare = prcr1, outerjoin = d2, nocounter
 ;end select
 IF (curqual=0)
  SET cgpt_status = "Z"
 ELSEIF (curqual > 0)
  SET cgpt_status = "S"
 ENDIF
 IF (count > 0)
  SELECT INTO "nl:"
   p_al.person_alias_id, alias_pool = uar_get_code_display(p_al.alias_pool_cd), p_al.alias_pool_cd
   FROM person_alias p_al,
    (dummyt d1  WITH seq = value(count))
   PLAN (d1)
    JOIN (p_al
    WHERE (p_al.person_id=reply->pt_reg_info[d1.seq].patient_id)
     AND p_al.person_alias_type_cd=alias_cd
     AND p_al.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   ORDER BY p_al.person_id
   HEAD p_al.person_id
    mrn_count = 0
   DETAIL
    mrn_count += 1, stat = alterlist(reply->pt_reg_info[d1.seq].mrns,mrn_count), reply->pt_reg_info[
    d1.seq].mrns[mrn_count].mrn = concat(trim(cnvtalias(p_al.alias,p_al.alias_pool_cd))," - ",
     alias_pool),
    reply->pt_reg_info[d1.seq].mrns[mrn_count].alias_pool_cd = p_al.alias_pool_cd
   WITH nocounter
  ;end select
 ENDIF
 GO TO exit_script
#echo_reply
 CALL echo(build("mrn_count is: ",mrn_count))
 CALL echo("After Script")
 CALL echo(build("cnttouched = ",cnttouched))
 CALL echo(build("cntuntouched = ",cntuntouched))
 CALL echo(build("cntcnstrlsd = ",cntcnstrlsd))
 CALL echo(build("cntmoved = ",cntmoved))
 SET i = 0
 CALL echo("Printing")
 CALL echo(build("Current Amend Id =",reply->current_amendment_id))
 CALL echo(" ")
 FOR (i = 1 TO count)
   CALL echo(build("i= ",i))
   CALL echo(build("pt name = ",reply->pt_reg_info[i].patient_name))
   CALL echo(build("pt id = ",reply->pt_reg_info[i].patient_id))
   CALL echo(build("reg_id = ",reply->pt_reg_info[i].reg_id))
   CALL echo(build("enrolled on cur amd = ",reply->pt_reg_info[i].enrolled_on_cur_amd))
   CALL echo(build("has_pending_consent = ",reply->pt_reg_info[i].has_pending_consent))
   CALL echo(build("enrolling_org_id =",reply->pt_reg_info[i].enrolling_org_id))
   SET mrn_count = size(reply->pt_reg_info[i].mrns,5)
   CALL echo(build("mrn_count =",mrn_count))
   FOR (j = 1 TO mrn_count)
     CALL echo(build("mrn = ",reply->pt_reg_info[i].mrns[j].mrn))
   ENDFOR
   CALL echo(build(" amd nbr= ",reply->pt_reg_info[i].prot_amendment_nbr))
   CALL echo(build(" consent rlsd dt tm= ",reply->pt_reg_info[i].consent_released_dt_tm))
   CALL echo(build(" consent signed dt tm= ",reply->pt_reg_info[i].consent_signed_dt_tm))
   CALL echo(build("on study dt = ",reply->pt_reg_info[i].on_study_dt_tm))
   CALL echo(build("off study dt = ",reply->pt_reg_info[i].off_study_dt_tm))
   CALL echo(build("deceased dt = ",reply->pt_reg_info[i].deceased_dt_tm))
   CALL echo(build("comple dt= ",reply->pt_reg_info[i].tx_completion_dt_tm))
   CALL echo(build("amd assign dt = ",reply->pt_reg_info[i].assign_start_dt_tm))
   CALL echo(build("updtcnt = ",reply->pt_reg_info[i].updt_cnt))
 ENDFOR
#exit_script
 SET last_mod = "014"
 SET mod_date = "May 27, 2024"
END GO
