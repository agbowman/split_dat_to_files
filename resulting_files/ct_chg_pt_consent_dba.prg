CREATE PROGRAM ct_chg_pt_consent:dba
 RECORD reply(
   1 statuscon = c1
   1 statusrltn = c1
   1 ptconsentid = f8
   1 scs_funcstatus = c1
   1 statusfunc = c1
   1 a_c_results[*]
     2 a_key = vc
     2 stratumstatus = c1
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 suspsummary = c1
     2 cohortsummary = c1
     2 susps[*]
       3 a_key = vc
       3 suspstatus = c1
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
     2 cohorts[*]
       3 a_key = vc
       3 cohortstatus = c1
       3 prot_cohort_id = f8
       3 cohort_id = f8
   1 probdesc[*]
     2 str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD c(
   1 currentdatetime = dq8
   1 prot_amendment_id = f8
   1 consent_id = f8
   1 pt_consent_id = f8
   1 consenting_person_id = f8
   1 consenting_organization_id = f8
   1 consent_released_dt_tm = dq8
   1 consent_signed_dt_tm = dq8
   1 consent_received_dt_tm = dq8
   1 consent_nbr = i4
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 not_returned_dt_tm = dq8
   1 not_returned_reason_cd = f8
   1 reason_for_consent_cd = f8
   1 ct_document_version_id = f8
   1 person_id = f8
   1 conissued_tm_ind = i2
   1 consigned_tm_ind = i2
   1 conreceived_tm_ind = i2
   1 notreturned_tm_ind = i2
 )
 RECORD audits(
   1 list[*]
     2 eventname = vc
     2 eventtype = vc
 )
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
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
 SET reply->status_data.status = "F"
 SET reply->statuscon = "F"
 SET reply->statusrltn = "Z"
 DECLARE prev_consent_nbr = i2 WITH protect, noconstant(0)
 DECLARE bfalse = i2 WITH protect, constant(0)
 DECLARE btrue = i2 WITH protect, constant(1)
 DECLARE continue = i2 WITH protect, noconstant(0)
 DECLARE updatecon = i2 WITH protect, noconstant(bfalse)
 DECLARE createrltn = i2 WITH protect, noconstant(bfalse)
 DECLARE reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE participantname = vc WITH public, noconstant("")
 DECLARE con_id = vc WITH public, noconstant("")
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm = vc WITH public, noconstant("")
 DECLARE transferwc_ind = i2 WITH protect, noconstant(0)
 DECLARE signeddate_ind = i2 WITH protect, noconstant(0)
 DECLARE reason_cd = f8 WITH protect, noconstant(0.00)
 DECLARE list_ind = i2 WITH protect, noconstant(0)
 DECLARE con_info_ind = i2 WITH protect, noconstant(0)
 DECLARE connotret_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elig_id = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE consent_id = f8 WITH protect, noconstant(0.0)
 DECLARE consented_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 DECLARE eligstatus_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elignoverif_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notenrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notsigned_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5,"008"))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30,"April 4, 2019"))
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE unknown_cd = f8 WITH protect, noconstant(0.0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE protocol_id = f8 WITH protect, noconstant(0.0)
 DECLARE ptregconsentreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE pteligtrackingid = f8 WITH protect, noconstant(0.0)
 DECLARE reltnid = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17901,"CONSENTED",1,consented_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SET ptregconsentreltnid = 0.0
 SET pteligconsentreltnid = 0.0
 SET doinsert = 0
 SET conid = 0.0
 SET protocol_id = 0.0
 SET regid = 0.0
 SET unknown_cd = 0.0
 SET newaccessionnbr = fillstring(276," ")
 SUBROUTINE (enrollconsentpatient(conid=f8(ref)) =null WITH protect)
   SELECT INTO "nl:"
    FROM prot_amendment pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id)
    DETAIL
     protocol_id = pa.prot_master_id
    WITH format, counter
   ;end select
   SELECT INTO "nl:"
    reg.*
    FROM pt_prot_reg reg
    WHERE reg.prot_master_id=protocol_id
     AND reg.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND reg.off_study_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (reg.person_id=c->person_id)
    WITH nocounter
   ;end select
   SET dup = false
   CALL echo(build("post check for open enrollment curqual = ",curqual))
   IF (dup=false)
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
     SET p_pr_r.off_study_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.tx_start_dt_tm =
      cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.tx_completion_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"),
      p_pr_r.first_pd_failure_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_pd_dt_tm
       = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_cr_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"),
      p_pr_r.nomenclature_id = 0.0, p_pr_r.removal_organization_id = 0.0, p_pr_r.removal_person_id =
      0.0,
      p_pr_r.enrolling_organization_id = 0.0, p_pr_r.best_response_cd = 0.0, p_pr_r
      .first_dis_rel_event_death_cd = 0.0,
      p_pr_r.diagnosis_type_cd = unknown_cd, p_pr_r.on_tx_organization_id = 0.0, p_pr_r
      .on_tx_assign_prsnl_id = 0.0,
      p_pr_r.on_tx_comment = "", p_pr_r.status_enum = 5, p_pr_r.prot_arm_id = 0.0,
      p_pr_r.prot_master_id = protocol_id, p_pr_r.beg_effective_dt_tm = cnvtdatetime(sysdate), p_pr_r
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      p_pr_r.pt_prot_reg_id = regid, p_pr_r.reg_id = regid, p_pr_r.person_id = c->person_id,
      p_pr_r.prot_accession_nbr = newaccessionnbr, p_pr_r.on_study_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), p_pr_r.updt_cnt = 0,
      p_pr_r.updt_applctx = reqinfo->updt_applctx, p_pr_r.updt_task = reqinfo->updt_task, p_pr_r
      .updt_id = reqinfo->updt_id,
      p_pr_r.updt_dt_tm = cnvtdatetime(sysdate), p_pr_r.removal_reason_cd = 0.0, p_pr_r
      .removal_reason_desc = "",
      p_pr_r.reason_off_tx_cd = 0.0, p_pr_r.reason_off_tx_desc = "", p_pr_r
      .off_tx_removal_organization_id = 0.0,
      p_pr_r.off_tx_removal_person_id = 0.0, p_pr_r.episode_id = 0.0
     WITH nocounter
    ;end insert
    IF (curqual=1)
     CALL echo("insert into the pt_prot_reg table : curqual = 1")
     SET doinsert = 1
    ELSE
     CALL echo("insert into the pt_prot_reg table : curqual != 1")
     SET doinsert = 0
    ENDIF
    IF (doinsert=1)
     SET pt_amd_assignment->reg_id = regid
     SET pt_amd_assignment->prot_amendment_id = request->prot_amendment_id
     SET pt_amd_assignment->transfer_checked_amendment_id = request->prot_amendment_id
     SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     SET caaa_status = "F"
     EXECUTE ct_add_a_a_func
     IF (caaa_status != "S")
      SET doinsert = 0
     ENDIF
    ENDIF
    CALL echo(build("ConID = ",conid))
    CALL echo("Get Unique ID for pt_reg_consent_reltn")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      ptregconsentreltnid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("BEFORE - Insert pt_reg_consent_reltn")
    INSERT  FROM pt_reg_consent_reltn rltn
     SET rltn.pt_reg_consent_reltn_id = ptregconsentreltnid, rltn.reg_id = regid, rltn.consent_id =
      conid,
      rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
      updt_task,
      rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
      rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
       sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    CALL echo(build("PtRegConsentReltnID = ",ptregconsentreltnid))
    CALL echo(build("RegID = ",regid))
    CALL echo(build("ConID = ",conid))
    IF (curqual=1)
     CALL echo("insert into the pt_reg_consent_reltn table : curqual = 1")
     SET doinsert = 1
    ELSE
     CALL echo("insert into the pt_reg_consent_reltn table : curqual != 1")
     SET doinsert = 0
    ENDIF
    SELECT INTO "nl:"
     FROM pt_elig_consent_reltn ecrltn
     WHERE ecrltn.consent_id=conid
     DETAIL
      pteligtrackingid = ecrltn.pt_elig_tracking_id
     WITH format, counter
    ;end select
    CALL echo("Get Unique ID for Reltn")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      reltnid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("BEFORE - Insert pt_reg_elig_reltn")
    INSERT  FROM pt_reg_elig_reltn erltn
     SET erltn.pt_reg_elig_reltn_id = reltnid, erltn.reg_id = regid, erltn.pt_elig_tracking_id =
      pteligtrackingid,
      erltn.updt_cnt = 0, erltn.updt_applctx = reqinfo->updt_applctx, erltn.updt_task = reqinfo->
      updt_task,
      erltn.updt_id = reqinfo->updt_id, erltn.updt_dt_tm = cnvtdatetime(sysdate), erltn.active_ind =
      1,
      erltn.active_status_cd = reqdata->active_status_cd, erltn.active_status_dt_tm = cnvtdatetime(
       sysdate), erltn.active_status_prsnl_id = reqinfo->updt_id
    ;end insert
    IF (curqual=1)
     SET doinsert = 1
    ELSE
     SET doinsert = 0
    ENDIF
    CALL echo(build("ReltnID = ",reltnid))
    CALL echo("AFTER - Insert pt_reg_elig_reltn")
    IF (doinsert=1)
     EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
     IF ((pref_reply->pref_value=1))
      IF (consented_cd > 0)
       IF (protocol_id > 0)
        SELECT INTO "NL:"
         FROM pt_prot_prescreen pps
         WHERE (pps.person_id=c->person_id)
          AND pps.prot_master_id=protocol_id
          AND pps.screening_status_cd != syscancel_cd
          AND pps.screening_status_cd != enrolled_cd
         DETAIL
          status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd
           = consented_cd, status_request->status_comment_text = ""
         WITH nocounter
        ;end select
        IF ((status_request->pt_prot_prescreen_id > 0))
         EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
          "STATUS_REPLY")
         IF ((status_reply->status_data.status != "S"))
          SET doinsert = 0
         ELSE
          SET doinsert = doinsert
         ENDIF
        ELSE
         SET doinsert = doinsert
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 CALL echo(build("ECHO   lock  rows to update"))
 SELECT INTO "nl:"
  p_cn.*
  FROM pt_consent p_cn
  WHERE (p_cn.pt_consent_id=request->ptconsentid)
  DETAIL
   c->currentdatetime = cnvtdatetime(sysdate), c->pt_consent_id = p_cn.pt_consent_id, c->consent_id
    = p_cn.consent_id,
   c->consenting_person_id = p_cn.consenting_person_id, c->consenting_organization_id = p_cn
   .consenting_organization_id, c->consent_released_dt_tm = p_cn.consent_released_dt_tm,
   c->consent_signed_dt_tm = p_cn.consent_signed_dt_tm, c->consent_received_dt_tm = p_cn
   .consent_received_dt_tm, c->consent_nbr = p_cn.consent_nbr,
   c->updt_cnt = p_cn.updt_cnt, c->beg_effective_dt_tm = p_cn.beg_effective_dt_tm, c->
   end_effective_dt_tm = p_cn.end_effective_dt_tm,
   c->not_returned_dt_tm = p_cn.not_returned_dt_tm, c->not_returned_reason_cd = p_cn
   .not_returned_reason_cd, c->reason_for_consent_cd = p_cn.reason_for_consent_cd,
   c->ct_document_version_id = p_cn.ct_document_version_id, c->person_id = p_cn.person_id, c->
   updt_dt_tm = p_cn.updt_dt_tm,
   c->conissued_tm_ind = p_cn.consent_released_tm_ind, c->consigned_tm_ind = p_cn
   .consent_signed_tm_ind, c->conreceived_tm_ind = p_cn.consent_received_tm_ind,
   c->notreturned_tm_ind = p_cn.not_returned_tm_ind
  WITH nocounter, forupdate(p_cn)
 ;end select
 SET stat = uar_get_meaning_by_codeset(17349,"TRANSFER",1,reason_cd)
 CALL echo(build("Reason_cd is ",reason_cd))
 IF ((c->reason_for_consent_cd=reason_cd))
  SET transferwc_ind = 1
 ENDIF
 SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(c->updt_dt_tm,0,
   "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
 IF (curqual=1)
  IF ((c->updt_cnt != request->updtcnt))
   CALL echo(build("C->updt_cnt  = ",c->updt_cnt))
   CALL echo(build("Request->UpdtCnt  = ",request->updtcnt))
   SET reply->status_data.status = "C"
   SET reply->statuscon = "C"
   SET continue = bfalse
  ELSE
   SET continue = btrue
  ENDIF
  CALL echo(build("ECHO   checking if data passed in is NULL or different"))
  IF (continue=btrue)
   SET stat = alterlist(audits->list,0)
   IF ((request->ct_document_version_id != 0))
    IF ((request->ct_document_version_id != c->ct_document_version_id))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->ct_document_version_id = c->ct_document_version_id
   ENDIF
   IF ((request->reasonforconcd != 0))
    IF ((request->reasonforconcd != c->reason_for_consent_cd))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->reasonforconcd = c->reason_for_consent_cd
   ENDIF
   IF ((request->consentingperid != 0))
    IF ((request->consentingperid != c->consenting_person_id))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->consentingperid = c->consenting_person_id
   ENDIF
   IF ((request->consentingorgid != 0))
    IF ((request->consentingorgid != c->consenting_organization_id))
     CALL echo(build("UpdateCon = ",updatecon))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->consentingorgid = c->consenting_organization_id
   ENDIF
   IF ((request->dateconissued != 0))
    IF ((((request->dateconissued != c->consent_released_dt_tm)) OR ((request->conissued_tm_ind != c
    ->conissued_tm_ind))) )
     SET updatecon = btrue
     SET list_ind += 1
     SET stat = alterlist(audits->list,list_ind)
     IF ((c->consent_released_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
      SET audits->list[list_ind].eventname = "Con_Release_Dt-Tm_Mod"
      SET audits->list[list_ind].eventtype = "Modify"
     ELSE
      SET audits->list[list_ind].eventname = "Consent_Release_Date-Time"
      SET audits->list[list_ind].eventtype = "Add"
     ENDIF
    ENDIF
   ELSE
    SET request->dateconissued = c->consent_released_dt_tm
   ENDIF
   IF ((request->dateconsigned != 0))
    IF ((((request->dateconsigned != c->consent_signed_dt_tm)) OR ((request->consigned_tm_ind != c->
    consigned_tm_ind))) )
     SET updatecon = btrue
     SET signeddate_ind = 1
     SET list_ind += 1
     SET stat = alterlist(audits->list,list_ind)
     IF ((c->consent_signed_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
      SET audits->list[list_ind].eventname = "Con_Signed_Dt-Tm_Mod"
      SET audits->list[list_ind].eventtype = "Modify"
     ELSE
      SET audits->list[list_ind].eventname = "Consent_Signed_Date-Time"
      SET audits->list[list_ind].eventtype = "Add"
     ENDIF
    ENDIF
   ELSE
    SET request->dateconsigned = c->consent_signed_dt_tm
   ENDIF
   IF ((request->dateconreceived != 0))
    IF ((((request->dateconreceived != c->consent_received_dt_tm)) OR ((request->conreceived_tm_ind
     != c->conreceived_tm_ind))) )
     SET updatecon = btrue
     SET list_ind += 1
     SET stat = alterlist(audits->list,list_ind)
     IF ((c->consent_received_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
      SET audits->list[list_ind].eventname = "Con_Returned_Dt-Tm_Mod"
      SET audits->list[list_ind].eventtype = "Modify"
     ELSE
      SET audits->list[list_ind].eventname = "Consent_Returned_Date-Time"
      SET audits->list[list_ind].eventtype = "Add"
     ENDIF
    ENDIF
   ELSE
    SET request->dateconreceived = c->consent_received_dt_tm
   ENDIF
   IF ((request->not_returned_dt_tm != 0))
    IF ((((request->not_returned_dt_tm != c->not_returned_dt_tm)) OR ((request->notreturned_tm_ind
     != c->notreturned_tm_ind))) )
     SET updatecon = btrue
     SET list_ind += 1
     SET stat = alterlist(audits->list,list_ind)
     IF ((c->not_returned_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
      SET audits->list[list_ind].eventname = "C_Not_Returned_Dt-Tm_Mod"
      SET audits->list[list_ind].eventtype = "Modify"
     ELSE
      SET audits->list[list_ind].eventname = "Con_Not_Returned_Dt-Tm"
      SET audits->list[list_ind].eventtype = "Add"
     ENDIF
    ENDIF
   ELSE
    SET request->not_returned_dt_tm = c->not_returned_dt_tm
   ENDIF
   IF ((request->not_returned_reason_cd != 0))
    IF ((request->not_returned_reason_cd != c->not_returned_reason_cd))
     SET updatecon = btrue
     IF ((c->not_returned_reason_cd != 0))
      SET list_ind += 1
      SET stat = alterlist(audits->list,list_ind)
      SET audits->list[list_ind].eventname = "Con_Not_Returned_Reason"
      SET audits->list[list_ind].eventtype = "Modify"
     ENDIF
    ENDIF
   ELSE
    SET request->not_returned_reason_cd = c->not_returned_reason_cd
   ENDIF
  ENDIF
 ELSE
  SET continue = bfalse
  SET reply->status_data.status = "L"
  SET reply->statuscon = "L"
 ENDIF
 CALL echo(build("ECHO   CONTINUE = ",continue))
 CALL echo(build("ECHO   UpdateCon = ",updatecon))
 IF (continue=btrue)
  IF (updatecon=btrue)
   CALL echo("ECHO   UpdateCon = bTRUE")
   UPDATE  FROM pt_consent p_cn
    SET p_cn.end_effective_dt_tm = cnvtdatetime(c->currentdatetime), p_cn.updt_cnt = (request->
     updtcnt+ 1), p_cn.updt_applctx = reqinfo->updt_applctx,
     p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (p_cn.pt_consent_id=request->ptconsentid)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET reply->statuscon = "F"
    SET continue = bfalse
   ENDIF
   CALL echo(build("after update  con table : curqual = ",curqual))
   IF (continue=btrue)
    CALL echo("ECHO   Get Unique ID for Consent")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)"########################;rpO"
     FROM dual
     DETAIL
      consent_id = cnvtreal(num)
     WITH format, counter
    ;end select
    SET reply->ptconsentid = consent_id
    INSERT  FROM pt_consent p_cn
     SET p_cn.prot_amendment_id = request->prot_amendment_id, p_cn.consenting_person_id = request->
      consentingperid, p_cn.consenting_organization_id = request->consentingorgid,
      p_cn.consent_released_dt_tm = cnvtdatetime(request->dateconissued), p_cn
      .consent_released_tm_ind = request->conissued_tm_ind, p_cn.consent_signed_dt_tm = cnvtdatetime(
       request->dateconsigned),
      p_cn.consent_signed_tm_ind = request->consigned_tm_ind, p_cn.consent_received_dt_tm =
      cnvtdatetime(request->dateconreceived), p_cn.consent_received_tm_ind = request->
      conreceived_tm_ind,
      p_cn.consent_nbr = c->consent_nbr, p_cn.not_returned_dt_tm = cnvtdatetime(request->
       not_returned_dt_tm), p_cn.not_returned_tm_ind = request->notreturned_tm_ind,
      p_cn.not_returned_reason_cd = request->not_returned_reason_cd, p_cn.beg_effective_dt_tm =
      cnvtdatetime(c->currentdatetime), p_cn.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"),
      p_cn.pt_consent_id = reply->ptconsentid, p_cn.consent_id = c->consent_id, p_cn
      .reason_for_consent_cd = request->reasonforconcd,
      p_cn.ct_document_version_id = request->ct_document_version_id, p_cn.person_id = c->person_id,
      p_cn.updt_cnt = 0,
      p_cn.updt_applctx = reqinfo->updt_applctx, p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id =
      reqinfo->updt_id,
      p_cn.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     CALL echo(build("ECHO    change of pt_consent - succeeded"))
     SET reply->status_data.status = "S"
     SET reply->statuscon = "S"
    ELSE
     CALL echo(build("ECHO    change of pt_consent  - failed"))
     SET reply->statuscon = "F"
     SET reply->status_data.status = "F"
     SET continue = bfalse
    ENDIF
    CALL echo(build("after insert  con table : curqual = ",curqual))
    IF (continue=btrue)
     IF ((request->not_returned_reason_cd != 0))
      CALL echo("Request->not_returned_reason_cd != 0")
      CALL echo(build("Locking pt_elig_tracking row to update"))
      SELECT INTO "nl:"
       FROM pt_elig_consent_reltn cerltn,
        pt_consent p_cn
       PLAN (p_cn
        WHERE (p_cn.pt_consent_id=request->ptconsentid))
        JOIN (cerltn
        WHERE cerltn.consent_id=p_cn.consent_id)
       DETAIL
        elig_id = cerltn.pt_elig_tracking_id
       WITH nocounter
      ;end select
      IF (curqual != 0)
       SELECT INTO "nl:"
        FROM pt_elig_tracking pet
        PLAN (pet
         WHERE pet.pt_elig_tracking_id=elig_id)
        DETAIL
         elig_id = pet.pt_elig_tracking_id
        WITH nocounter, forupdate(pet)
       ;end select
       IF (curqual != 0)
        SET stat = uar_get_meaning_by_codeset(17285,"NOTENROLLED",1,notenrolled_cd)
        SET stat = uar_get_meaning_by_codeset(17285,"NOTRETURNED",1,notsigned_cd)
        SET stat = uar_get_meaning_by_codeset(17285,"ELIGNOVER",1,elignoverif_cd)
        SET stat = uar_get_meaning_by_codeset(17284,"CONNORET",1,connotret_cd)
        SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling_cd)
        IF ((request->reasonforconcd=enrolling_cd))
         SET eligstatus_cd = notenrolled_cd
        ELSE
         SET eligstatus_cd = notsigned_cd
        ENDIF
        IF (eligstatus_cd != 0.0)
         UPDATE  FROM pt_elig_tracking pet
          SET pet.elig_status_cd = eligstatus_cd, pet.reason_ineligible_cd = connotret_cd, pet
           .updt_cnt = (pet.updt_cnt+ 1),
           pet.updt_applctx = reqinfo->updt_applctx, pet.updt_task = reqinfo->updt_task, pet.updt_id
            = reqinfo->updt_id,
           pet.updt_dt_tm = cnvtdatetime(sysdate)
          WHERE pet.pt_elig_tracking_id=elig_id
          WITH nocounter
         ;end update
         CALL echo(build("ECHO   elig_id = ",elig_id))
         CALL echo(build("ECHO   UPDATING ELIG ROWS  (pre curqual check) curqual = ",curqual))
         IF (curqual=0)
          SET reply->status_data.status = "F"
          SET continue = bfalse
         ENDIF
         IF (continue=btrue)
          IF ((request->reasonforconcd=enrolling_cd))
           IF ((request->not_returned_dt_tm != 0))
            CALL echo(build("ECHO   lock assign_elig_reltn row to update"))
            SELECT INTO "NL:"
             FROM assign_elig_reltn a_e,
              prot_cohort coh
             PLAN (a_e
              WHERE a_e.pt_elig_tracking_id=elig_id
               AND a_e.end_effective_dt_tm >= cnvtdatetime(sysdate))
              JOIN (coh
              WHERE coh.cohort_id=a_e.cohort_id)
             DETAIL
              request->stratum_id = coh.stratum_id, request->cohort_id = a_e.cohort_id
             WITH nocounter
            ;end select
            IF (curqual != 0)
             UPDATE  FROM assign_elig_reltn a_e
              SET a_e.end_effective_dt_tm = cnvtdatetime(sysdate), a_e.updt_cnt = (a_e.updt_cnt+ 1),
               a_e.updt_applctx = reqinfo->updt_applctx,
               a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
               cnvtdatetime(sysdate)
              WHERE a_e.pt_elig_tracking_id=elig_id
               AND a_e.end_effective_dt_tm >= cnvtdatetime(sysdate)
              WITH nocounter
             ;end update
             CALL echo(build("elig_id = ",elig_id))
             CALL echo(build("UPDATING ASSIGN_ELIG ROWS (pre curqual check) curqual = ",curqual))
             IF (curqual=0)
              SET reply->status_data.status = "F"
              SET continue = bfalse
             ELSE
              EXECUTE strat_coh_status_update_func
              CALL echo(build("Reply->SCS_FuncStatus = ",reply->scs_funcstatus))
              IF ((reply->scs_funcstatus != "F"))
               SET reply->status_data.status = "S"
               SET reqinfo->commit_ind = true
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (continue=btrue)
  IF ((request->regid != 0))
   SELECT INTO "nl:"
    FROM pt_reg_consent_reltn rltn
    PLAN (rltn
     WHERE (rltn.consent_id=c->consent_id))
   ;end select
   IF (curqual=0)
    SET createrltn = btrue
   ELSE
    SET createrltn = bfalse
   ENDIF
   IF (createrltn=btrue)
    CALL echo("ECHO   Get Unique ID for Consent")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)"########################;rpO"
     FROM dual
     DETAIL
      reltn_id = cnvtreal(num)
     WITH format, counter
    ;end select
    INSERT  FROM pt_reg_consent_reltn rltn
     SET rltn.pt_reg_consent_reltn_id = reltn_id, rltn.reg_id = request->regid, rltn.consent_id = c->
      consent_id,
      rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
      updt_task,
      rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
      rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
       sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->statusrltn = "F"
    ELSE
     SET reply->status_data.status = "S"
     SET reply->statusrltn = "S"
    ENDIF
   ENDIF
  ELSEIF ((request->regid=0)
   AND (request->dateconsigned != 0)
   AND (request->dateconsigned != cnvtdatetime("31-DEC-2100 00:00:00.00")))
   CALL enrollconsentpatient(c->consent_id)
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  IF (transferwc_ind=1
   AND signeddate_ind=1)
   EXECUTE cclaudit audit_mode, "PT_with_consent", "Add",
   "Person", "Patient", "Patient",
   "Origination", c->person_id, ""
  ENDIF
  IF (con_info_ind=1)
   SET list_ind += 1
   SET stat = alterlist(audits->list,list_ind)
   SET audits->list[list_ind].eventname = "Consent_info_Update"
   SET audits->list[list_ind].eventtype = "Modify"
  ENDIF
  FOR (x = 1 TO list_ind)
    CASE (audits->list[x].eventtype)
     OF "Add":
      EXECUTE cclaudit audit_mode, audits->list[x].eventname, audits->list[x].eventtype,
      "Person", "Patient", "Patient",
      "Origination", c->person_id, ""
     OF "Modify":
      SET con_id = build3(3,"CONSENT_ID: ",c->consent_id)
      SET participantname = concat(con_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
      EXECUTE cclaudit audit_mode, audits->list[x].eventname, audits->list[x].eventtype,
      "Person", "Patient", "Patient",
      "Amendment", c->person_id, participantname
    ENDCASE
  ENDFOR
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build("Status->PtConsent = ",reply->statuscon))
 CALL echo(build("Status = ",reply->status_data.status))
 FREE RECORD pref_reply
 FREE RECORD status_request
 FREE RECORD status_reply
 SET last_mod = "012"
 SET mod_date = "May 27, 2024"
END GO
