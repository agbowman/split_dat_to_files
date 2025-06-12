CREATE PROGRAM ct_add_pt_enrollments:dba
 RECORD reply(
   1 rowstatus[*]
     2 status = c1
     2 ptprtreg = c1
     2 protmaster = c1
     2 pteligtrackingrltn = c1
     2 ptprtregid = f8
     2 conid = f8
     2 newaccessionnbr = vc
     2 prescreen_chg_ind = i2
     2 accession_nbr = c1
     2 episode_id = f8
     2 person_id = f8
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
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 RECORD acc_tgt_request(
   1 prot_amendment_id = f8
   1 prot_master_id = f8
   1 requiredaccrualcd = f8
   1 person_id = f8
   1 person_list[*]
     2 person_id = f8
   1 participation_type_cd = f8
   1 application_nbr = i4
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
 )
 RECORD acc_tgt_reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 accrual_estimate_only_ind = i2
   1 track_tw_accrual = i2
   1 excluded_person_cnt = i4
   1 over_accrual_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (batchlistremoveperson(prot_master_id=f8,person_id=f8) =i2)
   CALL echo(build("BatchListRemovePerson::prot_master_id = ",prot_master_id))
   CALL echo(build("BatchListRemovePerson::person_id = ",person_id))
   DELETE  FROM ct_pt_prot_batch_list bl
    WHERE bl.person_id=person_id
     AND bl.prot_master_id=prot_master_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE numofinserts = i2 WITH protect, noconstant(0)
 DECLARE curregupdtcnt = f8 WITH protect, noconstant(0.0)
 DECLARE accessionnbrnext = i2 WITH protect, noconstant(0)
 DECLARE accessionnbrprefix = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE accessionnbrsigdig = i2 WITH protect, noconstant(0)
 DECLARE cval = f8 WITH protect, noconstant(0.0)
 DECLARE cmean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE doinsert = i2 WITH protect, noconstant(0)
 DECLARE commitrow = i2 WITH protect, noconstant(0)
 DECLARE conid = f8 WITH protect, noconstant(0.0)
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE reltnid = f8 WITH protect, noconstant(0.0)
 DECLARE protid = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE unknown_cd = f8 WITH protect, noconstant(0.0)
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE dup_found = i2 WITH protect, noconstant(0)
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 RECORD status_request(
   1 pt_prot_prescreen_id = f8
   1 status_cd = f8
   1 status_comment_text = vc
 )
 RECORD status_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD episoderequest(
   1 person_id = f8
   1 options = vc
   1 episode[*]
     2 episode_id = f8
     2 delete_ind = i2
     2 display = vc
     2 episode_type_cd = f8
     2 options = vc
     2 encounter[*]
       3 encntr_id = f8
       3 delete_ind = i2
       3 options = vc
     2 end_effective_dt_tm = dq8
 )
 RECORD episodereply(
   1 episode[*]
     2 episode_id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET numofinserts = size(request->es,5)
 SET accessionnbrprefix = fillstring(255," ")
 SET newaccessionnbr = fillstring(276," ")
 SET cmean = fillstring(12," ")
 SET commitrow = false
 SET stat = alterlist(reply->rowstatus,numofinserts)
 SET stat = uar_get_meaning_by_codeset(17270,"UNKNOWN",1,unknown_cd)
 SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 CALL echo(build("NumOfInserts = ",numofinserts))
 FOR (i = 1 TO numofinserts)
   SET reply->rowstatus[i].status = "F"
   SET reply->rowstatus[i].ptprtreg = "F"
   SET reply->rowstatus[i].protmaster = "F"
   SET reply->rowstatus[i].pteligtrackingrltn = "Z"
   SET reply->rowstatus[i].accession_nbr = "F"
   SET doinsert = true
   IF ((request->batch_enroll_ind=1))
    IF (doinsert=true)
     SET acc_tgt_request->prot_master_id = request->es[i].protmasterid
     SET acc_tgt_request->prot_amendment_id = request->es[i].protamendmentid
     SET acc_tgt_request->person_id = request->es[i].personid
     EXECUTE ct_get_validate_target_accrual  WITH replace("REQUEST","ACC_TGT_REQUEST"), replace(
      "REPLY","ACC_TGT_REPLY")
     IF ((acc_tgt_reply->status_data.status != "S"))
      SET reply->rowstatus[i].status = "F"
      SET doinsert = false
     ELSE
      IF ((acc_tgt_reply->accrual_estimate_only_ind=0))
       IF ((acc_tgt_reply->over_accrual_ind=1))
        SET doinsert = false
        SET reply->rowstatus[i].status = "T"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (size(trim(request->es[i].protaccessionnbr),1)=0)
    IF (doinsert=true)
     SELECT INTO "nl:"
      pr_m.*
      FROM prot_master pr_m,
       prot_amendment pr_am
      WHERE (pr_am.prot_amendment_id=request->es[i].protamendmentid)
       AND pr_m.prot_master_id=pr_am.prot_master_id
      DETAIL
       protid = pr_m.prot_master_id, accessionnbrnext = (pr_m.accession_nbr_last+ 1),
       accessionnbrprefix = pr_m.accession_nbr_prefix,
       accessionnbrsigdig = pr_m.accession_nbr_sig_dig
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET reply->rowstatus[i].status = "F"
      SET reply->rowstatus[i].protmaster = "L"
      SET doinsert = false
     ENDIF
    ENDIF
    IF (doinsert=true)
     SET dup_found = 1
     WHILE (dup_found=1)
       SET newaccessionnbr = build(accessionnbrnext)
       SET len = size(build(newaccessionnbr),1)
       CALL echo(build("len = ",len))
       CALL echo(build("AccessionNbrSigDig - len = ",(accessionnbrsigdig - len)))
       FOR (k = 1 TO (accessionnbrsigdig - len))
         SET newaccessionnbr = build("0",build(newaccessionnbr))
       ENDFOR
       SET newaccessionnbr = build(accessionnbrprefix,newaccessionnbr)
       SET dup_found = 0
       SELECT INTO "nl:"
        ppr.prot_master_id, ppr.person_id, ppr.end_effective_dt_tm,
        ppr.prot_accession_nbr, ppr.*
        FROM pt_prot_reg ppr
        WHERE (ppr.prot_master_id=request->es[i].protmasterid)
        ORDER BY ppr.person_id, ppr.end_effective_dt_tm DESC
        HEAD ppr.person_id
         IF (ppr.prot_accession_nbr=newaccessionnbr)
          dup_found = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (dup_found=1)
        SET accessionnbrnext += 1
       ENDIF
     ENDWHILE
     UPDATE  FROM prot_master pr_m
      SET pr_m.accession_nbr_last = accessionnbrnext
      WHERE pr_m.prot_master_id=protid
      WITH nocounter
     ;end update
     IF (curqual=1)
      SET reply->rowstatus[i].protmaster = "S"
     ELSE
      SET doinsert = false
     ENDIF
    ENDIF
   ELSE
    SET dup_found = 0
    SELECT INTO "nl:"
     pt.prot_accession_nbr
     FROM pt_prot_reg pt
     WHERE (pt.prot_master_id=request->es[i].protmasterid)
      AND (pt.prot_accession_nbr=request->es[i].protaccessionnbr)
      AND pt.end_effective_dt_tm >= cnvtdatetime(sysdate)
     DETAIL
      dup_found = 1
     WITH nocounter
    ;end select
    IF (dup_found=1)
     SET reply->rowstatus[i].status = "F"
     SET reply->rowstatus[i].accession_nbr = "U"
     SET doinsert = false
    ELSE
     SET newaccessionnbr = request->es[i].protaccessionnbr
    ENDIF
   ENDIF
   IF (doinsert=true)
    SET reply->rowstatus[i].episode_id = 0.0
    IF ((request->es[i].episode_type_cd > 0))
     SET episoderequest->person_id = request->es[i].personid
     SET stat = alterlist(episoderequest->episode,1)
     SET episoderequest->episode[1].episode_type_cd = request->es[i].episode_type_cd
     SELECT INTO "nl:"
      pm.primary_mnemonic
      FROM prot_master pm
      WHERE (pm.prot_master_id=request->es[i].protmasterid)
       AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
      DETAIL
       episoderequest->episode[1].display = pm.primary_mnemonic
      WITH nocounter
     ;end select
     SET tmp = i
     CALL echorecord(episoderequest)
     EXECUTE pm_epi_upt_episodes  WITH replace("REQUEST","EPISODEREQUEST"), replace("REPLY",
      "EPISODEREPLY")
     SET i = tmp
     CALL echorecord(episodereply)
     IF ((episodereply->status_data.status="S"))
      IF (size(episodereply->episode,5) > 0)
       SET reply->rowstatus[i].episode_id = episodereply->episode[1].episode_id
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      regid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("Insert pt_prot_reg")
    CALL echo(build("regid = ",regid))
    INSERT  FROM pt_prot_reg p_pr_r
     SET p_pr_r.off_study_dt_tm =
      IF ((request->es[i].dateoffstudy != 0)) cnvtdatetime(request->es[i].dateoffstudy)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      , p_pr_r.tx_start_dt_tm =
      IF ((request->es[i].dateontherapy != 0)) cnvtdatetime(request->es[i].dateontherapy)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      , p_pr_r.tx_completion_dt_tm =
      IF ((request->es[i].dateofftherapy != 0)) cnvtdatetime(request->es[i].dateofftherapy)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      ,
      p_pr_r.first_pd_failure_dt_tm =
      IF ((request->es[i].datefirstpdfail != 0)) cnvtdatetime(request->es[i].datefirstpdfail)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      , p_pr_r.first_pd_dt_tm =
      IF ((request->es[i].datefirstpd != 0)) cnvtdatetime(request->es[i].datefirstpd)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      , p_pr_r.first_cr_dt_tm =
      IF ((request->es[i].datefirstcr != 0)) cnvtdatetime(request->es[i].datefirstcr)
      ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
      ENDIF
      ,
      p_pr_r.nomenclature_id =
      IF ((request->es[i].nomenclatureid != 0)) request->es[i].nomenclatureid
      ELSE 0.0
      ENDIF
      , p_pr_r.removal_organization_id =
      IF ((request->es[i].removalorgid != 0)) request->es[i].removalorgid
      ELSE 0.0
      ENDIF
      , p_pr_r.removal_person_id =
      IF ((request->es[i].removalperid != 0)) request->es[i].removalperid
      ELSE 0.0
      ENDIF
      ,
      p_pr_r.enrolling_organization_id =
      IF ((request->es[i].enrollingorgid != 0)) request->es[i].enrollingorgid
      ELSE 0.0
      ENDIF
      , p_pr_r.best_response_cd =
      IF ((request->es[i].bestresp_cd != 0)) request->es[i].bestresp_cd
      ELSE 0.0
      ENDIF
      , p_pr_r.first_dis_rel_event_death_cd =
      IF ((request->es[i].firstdisrelevent_cd != 0)) request->es[i].firstdisrelevent_cd
      ELSE 0.0
      ENDIF
      ,
      p_pr_r.diagnosis_type_cd =
      IF ((request->es[i].diagtype_cd != 0)) request->es[i].diagtype_cd
      ELSE unknown_cd
      ENDIF
      , p_pr_r.on_tx_organization_id =
      IF ((request->es[i].ontxorgid != 0)) request->es[i].ontxorgid
      ELSE 0.0
      ENDIF
      , p_pr_r.on_tx_assign_prsnl_id =
      IF ((request->es[i].ontxperid != 0)) request->es[i].ontxperid
      ELSE 0.0
      ENDIF
      ,
      p_pr_r.on_tx_comment = request->es[i].ontxcomment, p_pr_r.status_enum = request->es[i].
      statusenum, p_pr_r.prot_arm_id = request->es[i].protarmid,
      p_pr_r.prot_master_id = request->es[i].protmasterid, p_pr_r.beg_effective_dt_tm = cnvtdatetime(
       sysdate), p_pr_r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      p_pr_r.pt_prot_reg_id = regid, p_pr_r.reg_id = regid, p_pr_r.person_id = request->es[i].
      personid,
      p_pr_r.prot_accession_nbr = newaccessionnbr, p_pr_r.on_study_dt_tm = cnvtdatetime(request->es[i
       ].dateonstudy), p_pr_r.updt_cnt = 0,
      p_pr_r.updt_applctx = reqinfo->updt_applctx, p_pr_r.updt_task = reqinfo->updt_task, p_pr_r
      .updt_id = reqinfo->updt_id,
      p_pr_r.updt_dt_tm = cnvtdatetime(sysdate), p_pr_r.removal_reason_cd = request->es[i].
      removalreasoncd, p_pr_r.removal_reason_desc = request->es[i].removalreasondesc,
      p_pr_r.reason_off_tx_cd = request->es[i].offtxremovalreasoncd, p_pr_r.reason_off_tx_desc =
      request->es[i].offtxremovalreasondesc, p_pr_r.off_tx_removal_organization_id = request->es[i].
      removaltxorgid,
      p_pr_r.off_tx_removal_person_id = request->es[i].removaltxperid, p_pr_r.episode_id = reply->
      rowstatus[i].episode_id
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET doinsert = true
     SET reply->rowstatus[i].ptprtreg = "S"
    ELSE
     SET doinsert = false
    ENDIF
   ENDIF
   IF (doinsert=true)
    SET pt_amd_assignment->reg_id = regid
    SET pt_amd_assignment->prot_amendment_id = request->es[i].protamendmentid
    SET pt_amd_assignment->transfer_checked_amendment_id = request->es[i].
    transfer_checked_amendment_id
    IF ((request->es[i].dateamendmentassigned=0))
     SET pt_amd_assignment->assign_start_dt_tm = request->es[i].dateonstudy
    ELSE
     SET pt_amd_assignment->assign_start_dt_tm = request->es[i].dateamendmentassigned
    ENDIF
    IF ((request->es[i].dateoffstudy > 0))
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->es[i].dateoffstudy)
    ELSE
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    SET caaa_status = "F"
    EXECUTE ct_add_a_a_func
    IF (caaa_status != "S")
     SET doinsert = false
    ENDIF
   ENDIF
   IF (doinsert=true)
    IF ((request->es[i].pteligtrackingid != 0))
     SET doinsert = false
     CALL echo("Get Unique ID for Reltn")
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)
      FROM dual
      DETAIL
       reltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     CALL echo("BEFORE - Insert pt_reg_elig_reltn")
     INSERT  FROM pt_reg_elig_reltn rltn
      SET rltn.pt_reg_elig_reltn_id = reltnid, rltn.reg_id = regid, rltn.pt_elig_tracking_id =
       request->es[i].pteligtrackingid,
       rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
       updt_task,
       rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
       rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
        sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     ;end insert
     IF (curqual=1)
      SET doinsert = true
      SET reply->rowstatus[i].pteligtrackingrltn = "S"
     ELSE
      SET doinsert = false
     ENDIF
     CALL echo(build("ReltnID = ",reltnid))
     CALL echo(build("RegID = ",regid))
     CALL echo(build("Request->Es[i]->PtEligTrackingID = ",request->es[i].pteligtrackingid))
     CALL echo("AFTER - Insert pt_reg_elig_reltn")
    ENDIF
   ELSE
    SET doinsert = false
   ENDIF
   IF (doinsert=true)
    EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
    IF ((pref_reply->pref_value=1))
     IF (enrolled_cd > 0)
      IF ((request->es[i].protmasterid > 0))
       SELECT INTO "NL:"
        FROM pt_prot_prescreen pps
        WHERE (pps.person_id=request->es[i].personid)
         AND (pps.prot_master_id=request->es[i].protmasterid)
         AND pps.screening_status_cd != syscancel_cd
        DETAIL
         status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd
          = enrolled_cd, status_request->status_comment_text = ""
        WITH nocounter
       ;end select
       IF ((status_request->pt_prot_prescreen_id > 0))
        EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
         "STATUS_REPLY")
        IF ((status_reply->status_data.status != "S"))
         SET doinsert = false
        ELSE
         SET reply->rowstatus[i].prescreen_chg_ind = 1
         SET doinsert = doinsert
        ENDIF
       ELSE
        SET doinsert = doinsert
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (doinsert=true)
    IF (enrolled_cd > 0)
     IF ((request->es[i].protmasterid > 0))
      SELECT INTO "nl:"
       FROM ct_pt_prot_batch_list bl
       WHERE (bl.person_id=request->es[i].personid)
        AND (bl.prot_master_id=request->es[i].protmasterid)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       CALL batchlistremoveperson(request->es[i].protmasterid,request->es[i].personid)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET reqinfo->commit_ind = doinsert
   IF (doinsert=true)
    SET reply->rowstatus[i].status = "S"
    SET reply->rowstatus[i].ptprtregid = regid
    SET reply->rowstatus[i].conid = conid
    SET reply->rowstatus[i].newaccessionnbr = newaccessionnbr
    SET reply->rowstatus[i].person_id = request->es[i].personid
    IF ((request->es[i].personid > 0))
     EXECUTE cclaudit audit_mode, "Enrolled_Patient", "Add",
     "Person", "Patient", "Patient",
     "Origination", request->es[i].personid, ""
    ENDIF
    CALL echo("COMMIT")
    COMMIT
   ELSE
    CALL echo("ROLLBACK")
    ROLLBACK
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 GO TO noecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo(build("NewAccessionNbr = ",newaccessionnbr))
 CALL echo(build("AccessionNbrSigDig = ",accessionnbrsigdig))
 CALL echo(build("ReltnID = ",reltnid))
 CALL echo(build("RegID = ",regid))
 CALL echo(build("Request->Es[1]->PtEligTrackingID = ",request->es[1].pteligtrackingid))
 CALL echo("CommitRow = ",0)
 CALL echo(commitrow,1)
 CALL echo("-------------------------------------------------------------")
 FOR (i = 1 TO numofinserts)
   CALL echo(build("Reply->RowStatus[i]->ProtMaster = ",reply->rowstatus[i].protmaster))
   CALL echo("Reply->RowStatus[i]->PtPrtReg = ",0)
   CALL echo(reply->rowstatus[i].ptprtreg,1)
   CALL echo(build("Reply->RowStatus[i]->PtEligTrackingRltn = ",reply->rowstatus[i].
     pteligtrackingrltn))
   CALL echo("Reply->RowStatus[i]->Status = ",0)
   CALL echo(reply->rowstatus[i].status,1)
   CALL echo("-------------------------------------------------------------")
 ENDFOR
#noecho
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
 FREE RECORD status_request
 FREE RECORD status_reply
 FREE RECORD pref_reply
 CALL echorecord(reply)
 SET last_mod = "014"
 SET mod_date = "DEC 08, 2022"
END GO
