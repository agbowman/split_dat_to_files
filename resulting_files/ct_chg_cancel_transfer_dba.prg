CREATE PROGRAM ct_chg_cancel_transfer:dba
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
     2 revision_ind = i2
     2 revision_nbr_txt = c30
     2 off_study_dt_tm = dq8
     2 tx_completion_dt_tm = dq8
     2 amd_assign_dt_tm = dq8
     2 updt_cnt = i4
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
 SET cancel_transfer = 4
 DECLARE count = i2 WITH private, noconstant(0)
 DECLARE cnt = i2 WITH private, noconstant(0)
 DECLARE tempstring = c100 WITH private, noconstant(fillstring(100," "))
 DECLARE pt_prot_reg_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
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
   1 end_effective_dt_tm = f8
 )
 SET count = size(request->qual,5)
 SET stat = alterlist(reply->qual,count)
 SET tempstring = build("Request->Prot_Amendment_Id=",request->prot_amendment_id)
 SET reply->debug_string = build(reply->debug_string,tempstring)
 SET updt_cnt = 0
 FOR (i = 1 TO count)
   SELECT INTO "nl:"
    ppr.pt_prot_reg_id
    FROM pt_prot_reg ppr
    WHERE (ppr.pt_prot_reg_id=request->qual[i].pt_prot_reg_id)
     AND (ppr.reg_id=request->qual[i].reg_id)
    DETAIL
     updt_cnt = ppr.updt_cnt
    WITH nocounter, forupdate(ppr)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Cannot lock rows for update"
    GO TO exit_script
   ENDIF
   IF ((updt_cnt != request->qual[i].updt_cnt))
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Rows have changed since last access"
    GO TO exit_script
   ENDIF
   UPDATE  FROM pt_prot_reg ppr
    SET ppr.end_effective_dt_tm = cnvtdatetime(sysdate), ppr.updt_cnt = (ppr.updt_cnt+ 1), ppr
     .updt_dt_tm = cnvtdatetime(sysdate),
     ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task, ppr.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ppr.pt_prot_reg_id=request->qual[i].pt_prot_reg_id)
     AND (ppr.reg_id=request->qual[i].reg_id)
    WITH nocounter
   ;end update
   CALL echo(build("Pt_Prot_Reg_Id =",request->qual[i].pt_prot_reg_id))
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to update Pt_Prot_Reg taable"
    GO TO exit_script
   ENDIF
   CALL echo("Success in updating")
   SELECT INTO "nl:"
    ppr.pt_prot_reg_id
    FROM pt_prot_reg p_pr_r
    WHERE (p_pr_r.prot_amendment_id != request->prot_amendment_id)
     AND (p_pr_r.reg_id=request->qual[i].reg_id)
    DETAIL
     cnt += 1
     IF (cnt=1)
      r->end_effective_dt_tm = cnvtdatetime(p_pr_r.end_effective_dt_tm)
     ENDIF
     IF ((((p_pr_r.end_effective_dt_tm > r->end_effective_dt_tm)) OR (cnt=1)) )
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
      tempstring = build("Person_Id = ",r->person_id), reply->debug_string = build(reply->
       debug_string,tempstring), tempstring = build("reg_id = ",r->reg_id),
      reply->debug_string = build(reply->debug_string,tempstring), tempstring = build(
       "Amd assign dt tm =",r->amendment_assignment_dt_tm), reply->debug_string = build(reply->
       debug_string,tempstring),
      CALL echo(build("Person_Id = ",r->person_id)),
      CALL echo(build("reg_id = ",r->reg_id)),
      CALL echo(build("pt_prot_reg_id = ",r->pt_prot_reg_id)),
      CALL echo(build("prot_Amendment_Id = ",r->prot_amendment_id)),
      CALL echo(build("enrolling Org = ",r->enrolling_organization_id)),
      CALL echo(build("trans_Checked_Amendment =",r->transfer_checked_amendment_id)),
      CALL echo(build("Amd assign dt tm =",r->amendment_assignment_dt_tm))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to get the previous amendment registrations"
    GO TO exit_script
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
     .prot_amendment_id = r->prot_amendment_id,
     ppr.prot_arm_id = r->prot_arm_id, ppr.prot_master_id = r->prot_master_id, ppr.reg_id = request->
     qual[i].reg_id,
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
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->reason_for_failure = "Failure to Insert into Pt_Prot_Reg"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    ppr.pt_prot_re_id
    FROM pt_prot_reg ppr,
     prot_amendment p_am
    PLAN (ppr
     WHERE ppr.pt_prot_reg_id=pt_prot_reg_id)
     JOIN (p_am
     WHERE p_am.prot_amendment_id=ppr.prot_amendment_id)
    DETAIL
     reply->qual[i].pt_prot_reg_id = pt_prot_reg_id, reply->qual[i].off_study_dt_tm =
     IF (ppr.off_study_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")) null
     ELSE ppr.off_study_dt_tm
     ENDIF
     , reply->qual[i].amd_assign_dt_tm = ppr.amendment_assignment_dt_tm,
     reply->qual[i].updt_cnt = ppr.updt_cnt, reply->qual[i].prot_amendment_nbr = p_am.amendment_nbr,
     reply->qual[i].revision_ind = p_am.revision_ind,
     reply->qual[i].revision_nbr_txt = p_am.revision_nbr_txt, reply->qual[i].tx_completion_dt_tm =
     IF (ppr.tx_completion_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")) null
     ELSE ppr.tx_completion_dt_tm
     ENDIF
     ,
     CALL echo(build("Pt_Prot_Reg_Id = ",pt_prot_reg_id))
    WITH nocounter
   ;end select
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
 SET last_mod = "001"
 SET mod_date = "Aug 27, 2007"
END GO
