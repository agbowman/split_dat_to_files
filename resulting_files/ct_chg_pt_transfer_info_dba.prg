CREATE PROGRAM ct_chg_pt_transfer_info:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 qual[*]
     2 pt_prot_reg_id = f8
     2 prot_amendment_nbr = i4
     2 off_study_dt_tm = dq8
     2 tx_completion_dt_tm = dq8
     2 amd_assign_dt_tm = dq8
     2 updt_cnt = i4
     2 consent_released_dt_tm = dq8
   1 reason_for_failure = vc
   1 debug_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH private, noconstant(0)
 DECLARE no_transfer = i2 WITH private, constant(0)
 DECLARE no_consent_transfer = i2 WITH private, constant(1)
 DECLARE safety_transfer = i2 WITH private, constant(2)
 DECLARE reconsent_transfer = i2 WITH private, constant(3)
 DECLARE cancel_transfer = i2 WITH private, constant(4)
 DECLARE pt_prot_reg_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstring = c100 WITH private, noconstant(fillstring(100," "))
 RECORD r(
   1 person_id = f8
   1 currentdatetime = dq8
   1 reg_id = f8
   1 pt_prot_reg_id = f8
   1 prot_master_id = f8
   1 prot_amendment_id = f8
   1 enrolling_organization_id = f8
   1 transfer_checked_amendment_id = f8
   1 amendment_assignment_dt_tm = dq8
   1 prot_stratum_id = f8
   1 nomenclature_id = f8
   1 removal_organization_id = f8
   1 removal_person_id = f8
   1 prot_accession_nbr = vc
   1 on_study_dt_tm = dq8
   1 off_study_dt_tm = dq8
   1 tx_start_dt_tm = dq8
   1 tx_completion_dt_tm = dq8
   1 first_pd_failure_dt_tm = dq8
   1 first_dis_rel_event_death_cd = f8
   1 prot_arm_id = f8
   1 checklist_resp_party_org_id = f8
   1 checklist_resp_party_person_id = f8
   1 diagnosis_type_cd = f8
   1 best_response_cd = f8
   1 first_pd_dt_tm = dq8
   1 first_cr_dt_tm = dq8
   1 updt_cnt = i4
   1 episode_id = f8
 )
 RECORD consent(
   1 qual[*]
     2 pt_consent_id = f8
 )
 SET count = size(request->qual,5)
 SET stat = alterlist(reply->qual,count)
 SET tempstring = build("Request->Prot_Amendment_Id=",request->prot_amendment_id)
 SET reply->debug_string = build(reply->debug_string,tempstring)
 SET tempstring = build("Request->Transfer_Type=",request->transfer_type)
 SET reply->debug_string = build(reply->debug_string,tempstring)
 FOR (i = 1 TO count)
   SET tempstring = build("Request->Qual[i]->Pt_Prot_Reg_Id=",request->qual[i].pt_prot_reg_id)
   SET reply->debug_string = build(reply->debug_string,tempstring)
   SET tempstring = build("Request->Qual[i]->Updt_Cnt=",request->qual[i].updt_cnt)
   SET reply->debug_string = build(reply->debug_string,tempstring)
   CALL echo(reply->debug_string)
   SELECT INTO "nl:"
    ppr.pt_prot_reg_id
    FROM pt_prot_reg p_pr_r
    WHERE (p_pr_r.pt_prot_reg_id=request->qual[i].pt_prot_reg_id)
    DETAIL
     r->person_id = p_pr_r.person_id, r->pt_prot_reg_id = p_pr_r.pt_prot_reg_id, r->reg_id = p_pr_r
     .reg_id,
     r->prot_master_id = p_pr_r.prot_master_id, r->prot_amendment_id = p_pr_r.prot_amendment_id, r->
     transfer_checked_amendment_id = p_pr_r.transfer_checked_amendment_id,
     r->amendment_assignment_dt_tm = p_pr_r.amendment_assignment_dt_tm, r->nomenclature_id = p_pr_r
     .nomenclature_id, r->removal_organization_id = p_pr_r.removal_organization_id,
     r->removal_person_id = p_pr_r.removal_person_id, r->prot_accession_nbr = p_pr_r
     .prot_accession_nbr, r->on_study_dt_tm = p_pr_r.on_study_dt_tm,
     r->off_study_dt_tm = p_pr_r.off_study_dt_tm, r->tx_start_dt_tm = p_pr_r.tx_start_dt_tm, r->
     tx_completion_dt_tm = p_pr_r.tx_completion_dt_tm,
     r->first_pd_failure_dt_tm = p_pr_r.first_pd_failure_dt_tm, r->first_dis_rel_event_death_cd =
     p_pr_r.first_dis_rel_event_death_cd, r->enrolling_organization_id = p_pr_r
     .enrolling_organization_id,
     r->prot_arm_id = p_pr_r.prot_arm_id, r->diagnosis_type_cd = p_pr_r.diagnosis_type_cd, r->
     best_response_cd = p_pr_r.best_response_cd,
     r->first_pd_dt_tm = p_pr_r.first_pd_dt_tm, r->first_cr_dt_tm = p_pr_r.first_cr_dt_tm, r->
     updt_cnt = p_pr_r.updt_cnt,
     tempstring = build("Person_Id = ",r->person_id), reply->debug_string = build(reply->debug_string,
      tempstring), tempstring = build("reg_id = ",r->reg_id),
     reply->debug_string = build(reply->debug_string,tempstring), tempstring = build(
      "Amd assign dt tm =",r->amendment_assignment_dt_tm), reply->debug_string = build(reply->
      debug_string,tempstring),
     tempstring = build("Transfer_Type = ",request->transfer_type), reply->debug_string = build(reply
      ->debug_string,tempstring), r->episode_id = p_pr_r.episode_id
    WITH nocounter, forupdate(p_pr_r)
   ;end select
   IF (curqual=1)
    IF ((r->updt_cnt != request->qual[i].updt_cnt))
     SET reply->status_data.status = "F"
     SET reply->reason_for_failure = "Rows have changed since last access"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to lock rows"
    GO TO exit_script
   ENDIF
   UPDATE  FROM pt_prot_reg ppr
    SET ppr.end_effective_dt_tm = cnvtdatetime(sysdate), ppr.updt_cnt = (ppr.updt_cnt+ 1), ppr
     .updt_dt_tm = cnvtdatetime(sysdate),
     ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task, ppr.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ppr.pt_prot_reg_id=request->qual[i].pt_prot_reg_id)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to update"
    GO TO exit_script
   ENDIF
   SET reply->debug_string = build(reply->debug_string,"Success in updating")
   IF ((((request->transfer_type=no_consent_transfer)) OR ((((request->transfer_type=safety_transfer)
   ) OR ((request->transfer_type=reconsent_transfer))) )) )
    SET r->amendment_assignment_dt_tm = cnvtdatetime(cnvtdate2(request->qual[i].
      amendment_assignment_dt,"YYYYMMDD"),0)
   ENDIF
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     pt_prot_reg_id = nextseqnum
    WITH format, nocounter
   ;end select
   INSERT  FROM pt_prot_reg ppr
    SET ppr.pt_prot_reg_id = pt_prot_reg_id, ppr.amendment_assignment_dt_tm = cnvtdatetime(r->
      amendment_assignment_dt_tm), ppr.best_response_cd = r->best_response_cd,
     ppr.diagnosis_type_cd = r->diagnosis_type_cd, ppr.first_cr_dt_tm = cnvtdatetime(r->
      first_cr_dt_tm), ppr.first_dis_rel_event_death_cd = r->first_dis_rel_event_death_cd,
     ppr.first_pd_dt_tm = cnvtdatetime(r->first_pd_dt_tm), ppr.first_pd_failure_dt_tm = cnvtdatetime(
      r->first_pd_failure_dt_tm), ppr.nomenclature_id = r->nomenclature_id,
     ppr.person_id = r->person_id, ppr.prot_accession_nbr = r->prot_accession_nbr, ppr
     .prot_amendment_id =
     IF ((((request->transfer_type=no_consent_transfer)) OR ((((request->transfer_type=
     safety_transfer)) OR ((request->transfer_type=reconsent_transfer))) )) ) request->
      prot_amendment_id
     ELSE r->prot_amendment_id
     ENDIF
     ,
     ppr.prot_arm_id = r->prot_arm_id, ppr.prot_master_id = r->prot_master_id, ppr.reg_id = r->reg_id,
     ppr.removal_organization_id = r->removal_organization_id, ppr.removal_person_id = r->
     removal_person_id, ppr.enrolling_organization_id = r->enrolling_organization_id,
     ppr.on_study_dt_tm = cnvtdatetime(r->on_study_dt_tm), ppr.off_study_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), ppr.tx_start_dt_tm = cnvtdatetime(r->tx_start_dt_tm),
     ppr.tx_completion_dt_tm = cnvtdatetime(r->tx_completion_dt_tm), ppr
     .transfer_checked_amendment_id = request->prot_amendment_id, ppr.beg_effective_dt_tm =
     cnvtdatetime(sysdate),
     ppr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), ppr.updt_cnt = 0, ppr
     .updt_dt_tm = cnvtdatetime(sysdate),
     ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task, ppr.updt_applctx = reqinfo->
     updt_applctx,
     ppr.episode_id = r->episode_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to Insert into Pt_Prot_Reg"
    GO TO exit_script
   ELSE
    SET reply->qual[i].pt_prot_reg_id = pt_prot_reg_id
   ENDIF
   SELECT INTO "nl:"
    ppr.pt_prot_re_id
    FROM pt_prot_reg ppr,
     prot_amendment p_am,
     pt_reg_consent_reltn prcr,
     pt_consent pc,
     dummyt d
    PLAN (ppr
     WHERE ppr.pt_prot_reg_id=pt_prot_reg_id)
     JOIN (p_am
     WHERE p_am.prot_amendment_id=ppr.prot_amendment_id)
     JOIN (d)
     JOIN (prcr
     WHERE prcr.reg_id=ppr.reg_id)
     JOIN (pc
     WHERE pc.consent_id=prcr.consent_id
      AND (pc.prot_amendment_id=request->prot_amendment_id))
    DETAIL
     reply->qual[i].pt_prot_reg_id = pt_prot_reg_id, reply->qual[i].off_study_dt_tm = ppr
     .off_study_dt_tm, reply->qual[i].amd_assign_dt_tm = ppr.amendment_assignment_dt_tm,
     reply->qual[i].updt_cnt = ppr.updt_cnt, reply->qual[i].prot_amendment_nbr = p_am.amendment_nbr,
     reply->qual[i].tx_completion_dt_tm = ppr.tx_completion_dt_tm,
     reply->qual[i].consent_released_dt_tm = pc.consent_released_dt_tm
    WITH outerjoin = d, dontcare = pc, nocounter
   ;end select
   CALL echo(build("reg_id = ",r->reg_id))
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echo(build("Status:",reply->status_data.status))
 IF ((reply->status_data.status="F"))
  CALL echo(build("reason for failure:",reply->reason_for_failure))
 ENDIF
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "002"
 SET mod_date = "May 7, 2008"
END GO
