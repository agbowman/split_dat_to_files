CREATE PROGRAM ct_chg_pt_enrollments:dba
 RECORD reply(
   1 rowstatus[*]
     2 status = c1
     2 ptprtregstat = c1
     2 prprotregid = f8
     2 accession_nbr = c1
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
 RECORD r(
   1 person_id = f8
   1 currentdatetime = dq8
   1 reg_id = f8
   1 pt_prot_reg_id = f8
   1 prot_master_id = f8
   1 enrolling_organization_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
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
   1 diagnosis_type_cd = f8
   1 best_response_cd = f8
   1 first_pd_dt_tm = dq8
   1 first_cr_dt_tm = dq8
   1 updt_dt_tm = dq8
   1 updt_cnt = i4
   1 removal_reason_cd = f8
   1 removal_reason_desc = vc
   1 off_tx_reason_cd = f8
   1 off_tx_reason_desc = vc
   1 off_tx_removal_org_id = f8
   1 off_tx_removal_person_id = f8
   1 episode_id = f8
   1 on_tx_organization_id = f8
   1 on_tx_assign_prsnl_id = f8
   1 on_tx_comment = vc
   1 status_enum = i4
 )
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 RECORD audit_event(
   1 list[*]
     2 personid = f8
     2 participant_name = vc
     2 events[*]
       3 eventname = vc
       3 eventtype = vc
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
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE j = i2 WITH protect, noconstant(0)
 DECLARE numofupdts = i2 WITH protect, noconstant(0)
 DECLARE dup_found = i2 WITH protect, noconstant(0)
 DECLARE enrolling = f8 WITH protect, noconstant(0.0)
 DECLARE doupdate = i2 WITH protect, noconstant(0)
 DECLARE commitrow = i2 WITH protect, noconstant(0)
 DECLARE petid = f8 WITH protect, noconstant(0.0)
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE updatereg = i2 WITH protect, noconstant(0)
 DECLARE updatecon = i2 WITH protect, noconstant(0)
 DECLARE ccaa_ct_pt_amd_assignment_id = f8 WITH public, noconstant(0.0)
 DECLARE ccaa_status = c1 WITH public, noconstant(fillstring(1," "))
 DECLARE ccaa_updt_cnt = i2 WITH public, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE registration_id = vc WITH protect, noconstant("")
 DECLARE audit_mode = i2 WITH protect, noconstant(0)
 DECLARE lst_updt_dt_tm = vc WITH protect, noconstant("")
 DECLARE list_ind = i2 WITH protect, noconstant(0)
 DECLARE event_ind = i2 WITH protect, noconstant(0)
 DECLARE accessionnbrnext = i2 WITH protect, noconstant(0)
 DECLARE accessionnbrprefix = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE accessionnbrsigdig = i2 WITH protect, noconstant(0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET numofupdts = size(request->es,5)
 SET doupdate = false
 SET commitrow = false
 SET updatereg = false
 SET updatecon = false
 SET stat = alterlist(reply->rowstatus,numofupdts)
 SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling)
 SET stat = alterlist(audit_event->list,0)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 FOR (i = 1 TO numofupdts)
   SET reply->rowstatus[i].ptprtregstat = "F"
   SET reply->rowstatus[i].status = "F"
   SET reply->rowstatus[i].accession_nbr = "F"
   SET doupdate = true
   SET updatereg = false
   SELECT INTO "nl:"
    p_pr_r.*
    FROM pt_prot_reg p_pr_r
    WHERE (p_pr_r.pt_prot_reg_id=request->es[i].ptprotregid)
    DETAIL
     r->currentdatetime = cnvtdatetime(sysdate), r->person_id = p_pr_r.person_id, r->pt_prot_reg_id
      = p_pr_r.pt_prot_reg_id,
     r->reg_id = p_pr_r.reg_id, r->prot_master_id = p_pr_r.prot_master_id, r->beg_effective_dt_tm =
     p_pr_r.beg_effective_dt_tm,
     r->end_effective_dt_tm = p_pr_r.end_effective_dt_tm, r->nomenclature_id = p_pr_r.nomenclature_id,
     r->removal_organization_id = p_pr_r.removal_organization_id,
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
     r->updt_dt_tm = p_pr_r.updt_dt_tm, r->removal_reason_cd = p_pr_r.removal_reason_cd, r->
     removal_reason_desc = p_pr_r.removal_reason_desc,
     r->off_tx_reason_cd = p_pr_r.reason_off_tx_cd, r->off_tx_reason_desc = p_pr_r.reason_off_tx_desc,
     r->off_tx_removal_org_id = p_pr_r.off_tx_removal_organization_id,
     r->off_tx_removal_person_id = p_pr_r.off_tx_removal_person_id, r->episode_id = p_pr_r.episode_id,
     r->on_tx_organization_id = p_pr_r.on_tx_organization_id,
     r->on_tx_assign_prsnl_id = p_pr_r.on_tx_assign_prsnl_id, r->on_tx_comment = p_pr_r.on_tx_comment,
     r->status_enum = p_pr_r.status_enum
    WITH nocounter, forupdate(p_pr_r)
   ;end select
   SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(r->updt_dt_tm,0,
     "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   SET registration_id = build3(3,"REG_ID: ",r->reg_id)
   SET list_ind += 1
   SET stat = alterlist(audit_event->list,list_ind)
   SET audit_event->list[list_ind].participant_name = concat(registration_id," ",lst_updt_dt_tm,
    " (UPDT_DT_TM)")
   SET audit_event->list[list_ind].personid = r->person_id
   SET stat = alterlist(audit_event->list[list_ind].events,0)
   SET event_ind = 0
   IF (curqual=1)
    IF ((r->updt_cnt != request->es[i].regupdtcnt))
     SET reply->rowstatus[i].ptprtregstat = "C"
     SET reply->rowstatus[i].status = "F"
     SET doupdate = false
    ENDIF
    IF (doupdate=true)
     IF ((request->es[i].nomenclatureid != 0))
      IF ((request->es[i].nomenclatureid != r->nomenclature_id))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].nomenclatureid = r->nomenclature_id
     ENDIF
     IF ((request->es[i].removalorgid != r->removal_organization_id))
      SET updatereg = true
      IF ((r->removal_organization_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "OS_Removal_Institute"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
     ENDIF
     IF ((request->es[i].removalperid != r->removal_person_id))
      SET updatereg = true
      IF ((r->removal_person_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "OS_Removal_person"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
     ENDIF
     IF ((request->es[i].dateonstudy != 0))
      IF (datetimecmp(request->es[i].dateonstudy,r->on_study_dt_tm) != 0)
       CALL echo("on study date changed")
       SET updatereg = true
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "On_Study_Modify"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
       SELECT INTO "nl:"
        FROM ct_pt_amd_assignment ctpt
        WHERE (ctpt.reg_id=r->reg_id)
         AND ctpt.end_effective_dt_tm >= cnvtdatetime(sysdate)
        DETAIL
         ccaa_updt_cnt = ctpt.updt_cnt
        WITH nocounter
       ;end select
       SET pt_amd_assignment->reg_id = r->reg_id
       SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime(request->es[i].dateonstudy)
       EXECUTE ct_chg_a_a_func
       CALL echo(build("CCAA_STATUS is ",ccaa_status))
       IF (ccaa_status != "S")
        SET doupdate = false
        SET updatereg = false
       ENDIF
      ENDIF
     ELSE
      SET request->es[i].dateonstudy = r->on_study_dt_tm
     ENDIF
     IF (datetimecmp(request->es[i].dateoffstudy,r->off_study_dt_tm) != 0)
      CALL echo("off study date change")
      SET event_ind += 1
      SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
      IF ((r->off_study_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       IF ((request->es[i].dateoffstudy=cnvtdatetime("31-DEC-2100 00:00:00.00")))
        SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Study_Delete"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Delete"
       ELSE
        SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Study_Modify"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
       ENDIF
      ELSE
       SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Study_Add"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Add"
      ENDIF
      SET ccaa_ct_pt_amd_assignment_id = 0
      SET updatereg = true
      SELECT INTO "nl:"
       FROM ct_pt_amd_assignment ctpt
       WHERE (ctpt.reg_id=r->reg_id)
        AND ctpt.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        ccaa_updt_cnt = ctpt.updt_cnt
       WITH nocounter
      ;end select
      SET pt_amd_assignment->reg_id = r->reg_id
      SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->es[i].dateoffstudy)
      EXECUTE ct_chg_a_a_func
      CALL echo(build("CCAA_STATUS is ",ccaa_status))
      IF (ccaa_status != "S")
       SET doupdate = false
       SET updatereg = false
      ENDIF
     ENDIF
     IF ((request->es[i].dateontherapy != 0))
      IF (datetimecmp(request->es[i].dateontherapy,r->tx_start_dt_tm) != 0)
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       IF ((r->tx_start_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
        IF ((request->es[i].dateontherapy=cnvtdatetime("31-DEC-2100 00:00:00.00")))
         SET audit_event->list[list_ind].events[event_ind].eventname = "On_Treatment_Delete"
         SET audit_event->list[list_ind].events[event_ind].eventtype = "Delete"
        ELSE
         SET audit_event->list[list_ind].events[event_ind].eventname = "On_Treatment_Date_Modify"
         SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
        ENDIF
       ELSE
        SET audit_event->list[list_ind].events[event_ind].eventname = "On_Treatment_Add"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Add"
       ENDIF
       SET updatereg = true
      ENDIF
     ENDIF
     IF ((request->es[i].ontxorgid != r->on_tx_organization_id))
      IF ((request->es[i].ontxorgid != 0)
       AND (r->on_tx_organization_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "On_Treatment_Institute_Modify"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
      SET updatereg = true
     ENDIF
     IF ((request->es[i].ontxperid != r->on_tx_assign_prsnl_id))
      IF ((request->es[i].ontxperid != 0)
       AND (r->on_tx_assign_prsnl_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "On_Treatment_Person_Modify"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
      SET updatereg = true
     ENDIF
     IF ((request->es[i].ontxcomment != r->on_tx_comment))
      SET updatereg = true
     ENDIF
     IF (datetimecmp(request->es[i].dateofftherapy,r->tx_completion_dt_tm) != 0)
      SET event_ind += 1
      SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
      IF ((r->tx_completion_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       IF ((request->es[i].dateofftherapy=cnvtdatetime("31-DEC-2100 00:00:00.00")))
        SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Treatment_Delete"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Delete"
       ELSE
        SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Treatment_Modify"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
       ENDIF
      ELSE
       SET audit_event->list[list_ind].events[event_ind].eventname = "Off_Treatment_Add"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Add"
      ENDIF
      SET updatereg = true
     ENDIF
     IF ((request->es[i].datefirstpdfail != 0))
      IF ((request->es[i].datefirstpdfail != r->first_pd_failure_dt_tm))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].datefirstpdfail = r->first_pd_failure_dt_tm
     ENDIF
     IF ((request->es[i].firstdisrelevent_cd != 0))
      IF ((request->es[i].firstdisrelevent_cd != r->first_dis_rel_event_death_cd))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].firstdisrelevent_cd = r->first_dis_rel_event_death_cd
     ENDIF
     IF ((request->es[i].enrollingorgid != r->enrolling_organization_id))
      SET updatereg = true
      SET event_ind += 1
      SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
      SET audit_event->list[list_ind].events[event_ind].eventname = "Enrolling_Institute"
      SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
     ELSE
      SET request->es[i].enrollingorgid = r->enrolling_organization_id
     ENDIF
     IF ((request->es[i].protarmid != 0))
      IF ((request->es[i].protarmid != r->prot_arm_id))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].protarmid = r->prot_arm_id
     ENDIF
     IF ((request->es[i].diagtype_cd != 0))
      IF ((request->es[i].diagtype_cd != r->diagnosis_type_cd))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].diagtype_cd = r->diagnosis_type_cd
     ENDIF
     IF ((request->es[i].bestresp_cd != 0))
      IF ((request->es[i].bestresp_cd != r->best_response_cd))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].bestresp_cd = r->best_response_cd
     ENDIF
     IF ((request->es[i].datefirstpd != 0))
      IF ((request->es[i].datefirstpd != r->first_pd_dt_tm))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].datefirstpd = r->first_pd_dt_tm
     ENDIF
     IF ((request->es[i].datefirstcr != 0))
      IF ((request->es[i].datefirstcr != r->first_pd_dt_tm))
       SET updatereg = true
      ENDIF
     ELSE
      SET request->es[i].datefirstcr = r->first_pd_dt_tm
     ENDIF
     IF (textlen(request->es[i].protaccessionnbr)=0
      AND (r->status_enum=5))
      SELECT INTO "nl:"
       pr_m.*
       FROM prot_master pr_m
       WHERE (pr_m.prot_master_id=r->prot_master_id)
       DETAIL
        protid = pr_m.prot_master_id, accessionnbrnext = (pr_m.accession_nbr_last+ 1),
        accessionnbrprefix = pr_m.accession_nbr_prefix,
        accessionnbrsigdig = pr_m.accession_nbr_sig_dig
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET reply->rowstatus[i].status = "F"
       SET reply->rowstatus[i].accession_nbr = "U"
       SET doupdate = false
      ENDIF
      IF (doupdate=true)
       SET dup_found = 1
      ENDIF
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
         WHERE (ppr.prot_master_id=r->prot_master_id)
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
      SET request->es[i].protaccessionnbr = newaccessionnbr
     ELSEIF (textlen(request->es[i].protaccessionnbr) > 0)
      IF ((request->es[i].protaccessionnbr != r->prot_accession_nbr))
       SET dup_found = 0
       SELECT INTO "nl:"
        pt.prot_accession_nbr
        FROM pt_prot_reg pt
        WHERE (pt.prot_master_id=r->prot_master_id)
         AND (pt.prot_accession_nbr=request->es[i].protaccessionnbr)
         AND pt.end_effective_dt_tm > cnvtdatetime(sysdate)
        DETAIL
         dup_found = 1
        WITH nocounter
       ;end select
       IF (dup_found=1)
        SET reply->rowstatus[i].status = "F"
        SET reply->rowstatus[i].accession_nbr = "U"
        SET updatereg = false
        SET doupdate = false
       ELSE
        SET updatereg = true
        SET reply->rowstatus[i].status = "S"
        SET reply->rowstatus[i].accession_nbr = "S"
        SET event_ind += 1
        SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
        SET audit_event->list[list_ind].events[event_ind].eventname = "Enrollment_ID_Modify"
        SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
       ENDIF
      ELSE
       SET request->es[i].protaccessionnbr = r->prot_accession_nbr
      ENDIF
     ELSE
      SET request->es[i].protaccessionnbr = r->prot_accession_nbr
     ENDIF
     IF ((request->es[i].removaltxorgid != r->off_tx_removal_org_id))
      SET updatereg = true
      IF ((r->off_tx_removal_org_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "OT_Removal_Institute"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
     ENDIF
     IF ((request->es[i].removaltxperid != r->off_tx_removal_person_id))
      SET updatereg = true
      IF ((r->off_tx_removal_person_id != 0))
       SET event_ind += 1
       SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
       SET audit_event->list[list_ind].events[event_ind].eventname = "OT_Removal_person"
       SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
      ENDIF
     ENDIF
     IF ((request->es[i].removalreasoncd != r->removal_reason_cd))
      SET updatereg = true
      SET event_ind += 1
      SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
      SET audit_event->list[list_ind].events[event_ind].eventname = "OS_Removal_Reason"
      SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
     ENDIF
     IF ((request->es[i].removalreasondesc != r->removal_reason_desc))
      SET updatereg = true
     ENDIF
     IF ((request->es[i].offtxremovalreasoncd != r->off_tx_reason_cd))
      SET updatereg = true
      SET event_ind += 1
      SET stat = alterlist(audit_event->list[list_ind].events,event_ind)
      SET audit_event->list[list_ind].events[event_ind].eventname = "OT_Removal_Reason"
      SET audit_event->list[list_ind].events[event_ind].eventtype = "Modify"
     ENDIF
     IF ((request->es[i].offtxremovalreasondesc != r->off_tx_reason_desc))
      SET updatereg = true
     ENDIF
    ENDIF
   ELSE
    SET reply->rowstatus[i].ptprtregstat = "L"
    SET reply->rowstatus[i].status = "F"
    SET doupdate = false
   ENDIF
   IF (doupdate=true)
    SET commitrow = true
    IF (updatereg=true)
     UPDATE  FROM pt_prot_reg p_pr_r
      SET p_pr_r.end_effective_dt_tm = cnvtdatetime(r->currentdatetime), p_pr_r.updt_cnt = (p_pr_r
       .updt_cnt+ 1), p_pr_r.updt_applctx = reqinfo->updt_applctx,
       p_pr_r.updt_task = reqinfo->updt_task, p_pr_r.updt_id = reqinfo->updt_id, p_pr_r.updt_dt_tm =
       cnvtdatetime(sysdate)
      WHERE (p_pr_r.pt_prot_reg_id=request->es[i].ptprotregid)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET commitrow = false
     ENDIF
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)
      FROM dual
      DETAIL
       regid = num
      WITH format, counter
     ;end select
     SET reply->rowstatus[i].prprotregid = regid
     INSERT  FROM pt_prot_reg p_pr_r
      SET p_pr_r.person_id = r->person_id, p_pr_r.nomenclature_id = request->es[i].nomenclatureid,
       p_pr_r.removal_organization_id = request->es[i].removalorgid,
       p_pr_r.removal_person_id = request->es[i].removalperid, p_pr_r.prot_accession_nbr = request->
       es[i].protaccessionnbr, p_pr_r.off_study_dt_tm = cnvtdatetime(request->es[i].dateoffstudy),
       p_pr_r.tx_start_dt_tm = cnvtdatetime(request->es[i].dateontherapy), p_pr_r.tx_completion_dt_tm
        = cnvtdatetime(request->es[i].dateofftherapy), p_pr_r.first_pd_failure_dt_tm = cnvtdatetime(
        request->es[i].datefirstpdfail),
       p_pr_r.first_dis_rel_event_death_cd = request->es[i].firstdisrelevent_cd, p_pr_r
       .enrolling_organization_id = request->es[i].enrollingorgid, p_pr_r.best_response_cd = request
       ->es[i].bestresp_cd,
       p_pr_r.first_pd_dt_tm = cnvtdatetime(request->es[i].datefirstpd), p_pr_r.first_cr_dt_tm =
       cnvtdatetime(request->es[i].datefirstcr), p_pr_r.on_study_dt_tm = cnvtdatetime(request->es[i].
        dateonstudy),
       p_pr_r.prot_arm_id = request->es[i].protarmid, p_pr_r.diagnosis_type_cd = request->es[i].
       diagtype_cd, p_pr_r.pt_prot_reg_id = regid,
       p_pr_r.reg_id = r->reg_id, p_pr_r.prot_master_id = r->prot_master_id, p_pr_r
       .beg_effective_dt_tm = cnvtdatetime(r->currentdatetime),
       p_pr_r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.updt_cnt = 0,
       p_pr_r.updt_applctx = reqinfo->updt_applctx,
       p_pr_r.updt_task = reqinfo->updt_task, p_pr_r.updt_id = reqinfo->updt_id, p_pr_r.updt_dt_tm =
       cnvtdatetime(sysdate),
       p_pr_r.removal_reason_cd = request->es[i].removalreasoncd, p_pr_r.removal_reason_desc =
       request->es[i].removalreasondesc, p_pr_r.reason_off_tx_cd = request->es[i].
       offtxremovalreasoncd,
       p_pr_r.reason_off_tx_desc = request->es[i].offtxremovalreasondesc, p_pr_r
       .off_tx_removal_organization_id = request->es[i].removaltxorgid, p_pr_r
       .off_tx_removal_person_id = request->es[i].removaltxperid,
       p_pr_r.episode_id = r->episode_id, p_pr_r.on_tx_organization_id = request->es[i].ontxorgid,
       p_pr_r.on_tx_assign_prsnl_id = request->es[i].ontxperid,
       p_pr_r.on_tx_comment = request->es[i].ontxcomment, p_pr_r.status_enum = request->es[i].
       statusenum
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET commitrow = false
     ENDIF
    ENDIF
    IF (doupdate=true)
     EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
     IF ((pref_reply->pref_value=1))
      IF (enrolled_cd > 0)
       IF ((r->prot_master_id > 0))
        SELECT INTO "NL:"
         FROM pt_prot_prescreen pps
         WHERE (pps.person_id=r->person_id)
          AND (pps.prot_master_id=r->prot_master_id)
          AND pps.screening_status_cd != syscancel_cd
          AND pps.screening_status_cd != enrolled_cd
         DETAIL
          status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd
           = enrolled_cd, status_request->status_comment_text = ""
         WITH nocounter
        ;end select
        IF ((status_request->pt_prot_prescreen_id > 0))
         EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
          "STATUS_REPLY")
         IF ((status_reply->status_data.status != "S"))
          SET doupdate = false
         ELSE
          SET reply->rowstatus[i].prescreen_chg_ind = 1
          SET doupdate = doupdate
         ENDIF
        ELSE
         SET doupdate = doupdate
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET commitrow = false
   ENDIF
   SET reqinfo->commit_ind = commitrow
   IF (commitrow=true)
    SET reply->rowstatus[i].ptprtregstat = "S"
    SET reply->rowstatus[i].status = "S"
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 IF ((reply->status_data.status="S"))
  SET audit_mode = 0
  FOR (x = 1 TO list_ind)
    FOR (y = 1 TO event_ind)
      CASE (audit_event->list[x].events[y].eventtype)
       OF "Add":
        EXECUTE cclaudit audit_mode, audit_event->list[x].events[y].eventname, audit_event->list[x].
        events[y].eventtype,
        "Person", "Patient", "Patient",
        "Origination", audit_event->list[x].personid, ""
       OF "Modify":
        EXECUTE cclaudit audit_mode, audit_event->list[x].events[y].eventname, audit_event->list[x].
        events[y].eventtype,
        "Person", "Patient", "Patient",
        "Amendment", audit_event->list[x].personid, audit_event->list[x].participant_name
       OF "Delete":
        EXECUTE cclaudit audit_mode, audit_event->list[x].events[y].eventname, audit_event->list[x].
        events[y].eventtype,
        "Person", "Patient", "Patient",
        "Destruction", audit_event->list[x].personid, audit_event->list[x].participant_name
      ENDCASE
    ENDFOR
  ENDFOR
 ENDIF
 FREE RECORD audit
 FREE RECORD pref_reply
 FREE RECORD status_request
 FREE RECORD status_reply
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
 SET last_mod = "016"
 SET mod_date = "Jan 31, 2024"
END GO
