CREATE PROGRAM ct_add_pt_consent:dba
 RECORD reply(
   1 ptconsentid = f8
   1 constatus = c1
   1 reltnregstatus = c1
   1 reltneligstatus = c1
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
 RECORD audit_events(
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE list_ind = i2 WITH protect, noconstant(0)
 DECLARE conid = f8 WITH protected, noconstant(0.0)
 DECLARE transferwc_ind = i2 WITH protect, noconstant(0)
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE reason_cd = f8 WITH protect, noconstant(0.00)
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE unknown_cd = f8 WITH protect, noconstant(0.0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE protocol_id = f8 WITH protect, noconstant(0.0)
 DECLARE consented_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reply->constatus = "F"
 SET reply->reltnregstatus = "Z"
 SET reply->reltneligstatus = "Z"
 SET add_count = 0
 SET next_code = 0
 SET prev_consent_nbr = 0
 SET conid = 0.0
 SET ptregconsentreltnid = 0.0
 SET pteligconsentreltnid = 0.0
 SET doinsert = 0
 SET conid = 0.0
 SET protocol_id = 0.0
 SET regid = 0.0
 SET unknown_cd = 0.0
 SET newaccessionnbr = fillstring(276," ")
 SET stat = uar_get_meaning_by_codeset(17901,"CONSENTED",1,consented_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SUBROUTINE (enrollconsentpatient(conid=f8(ref)) =null WITH protect)
   SELECT INTO "nl:"
    FROM prot_amendment pa
    WHERE (pa.prot_amendment_id=request->amendment_id)
    DETAIL
     protocol_id = pa.prot_master_id
    WITH format, counter
   ;end select
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
     p_pr_r.pt_prot_reg_id = regid, p_pr_r.reg_id = regid, p_pr_r.person_id = request->person_id,
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
    SET pt_amd_assignment->prot_amendment_id = request->amendment_id
    SET pt_amd_assignment->transfer_checked_amendment_id = request->amendment_id
    SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    SET caaa_status = "F"
    EXECUTE ct_add_a_a_func
    IF (caaa_status != "S")
     SET doinsert = 0
    ENDIF
   ENDIF
   IF (doinsert=1)
    EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
    IF ((pref_reply->pref_value=1))
     IF (consented_cd > 0)
      IF (protocol_id > 0)
       SELECT INTO "NL:"
        FROM pt_prot_prescreen pps
        WHERE (pps.person_id=request->person_id)
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
 END ;Subroutine
 CALL echo("Get a unique key to the pt_consent table")
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   conid = cnvtreal(num), reply->ptconsentid = conid
  WITH format, counter
 ;end select
 CALL echo("calculate what the hightest consent number is")
 SELECT INTO "nl:"
  pc.pt_consent_id
  FROM pt_consent pc,
   pt_reg_consent_reltn rltn
  WHERE (rltn.reg_id=request->regid)
   AND pc.consent_id=rltn.consent_id
  DETAIL
   IF (pc.consent_nbr > prev_consent_nbr)
    prev_consent_nbr = pc.consent_nbr
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("insert into the pt_consent table")
 INSERT  FROM pt_consent pc
  SET pc.pt_consent_id = conid, pc.consent_id = conid, pc.ct_document_version_id =
   IF ((request->ct_document_version_id=0)) 0
   ELSE request->ct_document_version_id
   ENDIF
   ,
   pc.consenting_organization_id =
   IF ((request->consenting_organization_id=0)) 0
   ELSE request->consenting_organization_id
   ENDIF
   , pc.consenting_person_id =
   IF ((request->consenting_person_id=0)) 0
   ELSE request->consenting_person_id
   ENDIF
   , pc.consent_nbr = (prev_consent_nbr+ 1),
   pc.consent_received_dt_tm =
   IF ((request->consent_received_dt_tm=0)) cnvtdatetime("31-Dec-2100 00:00:00.00")
   ELSE cnvtdatetime(request->consent_received_dt_tm)
   ENDIF
   , pc.consent_received_tm_ind = request->conreceived_tm_ind, pc.consent_signed_dt_tm =
   IF ((request->consent_signed_dt_tm=0)) cnvtdatetime("31-Dec-2100 00:00:00.00")
   ELSE cnvtdatetime(request->consent_signed_dt_tm)
   ENDIF
   ,
   pc.consent_signed_tm_ind = request->consigned_tm_ind, pc.consent_released_dt_tm =
   IF ((request->consent_released_dt_tm=0)) cnvtdatetime("31-Dec-2100 00:00:00.00")
   ELSE cnvtdatetime(request->consent_released_dt_tm)
   ENDIF
   , pc.consent_released_tm_ind = request->conissued_tm_ind,
   pc.not_returned_dt_tm =
   IF ((request->not_returned_dt_tm=0)) cnvtdatetime("31-Dec-2100 00:00:00.00")
   ELSE cnvtdatetime(request->not_returned_dt_tm)
   ENDIF
   , pc.not_returned_tm_ind = request->notreturned_tm_ind, pc.reason_for_consent_cd = request->
   reason_for_consent_cd,
   pc.person_id = request->person_id, pc.prot_amendment_id = request->amendment_id, pc
   .not_returned_reason_cd = request->not_returned_reason_cd,
   pc.updt_dt_tm = cnvtdatetime(sysdate), pc.beg_effective_dt_tm = cnvtdatetime(sysdate), pc
   .end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
   updt_applctx,
   pc.updt_cnt = 0
  WITH nocounter
 ;end insert
 SET stat = uar_get_meaning_by_codeset(17349,"TRANSFER",1,reason_cd)
 CALL echo(build("Reason_cd is ",reason_cd))
 IF ((request->reason_for_consent_cd=reason_cd))
  SET transferwc_ind = 1
 ENDIF
 IF ((request->consent_released_dt_tm != 0))
  SET list_ind += 1
  SET stat = alterlist(audit_events->list,list_ind)
  SET audit_events->list[list_ind].eventname = "Consent_Release_Date-Time"
  SET audit_events->list[list_ind].eventtype = "Add"
 ENDIF
 IF ((request->consent_signed_dt_tm != 0))
  SET list_ind += 1
  SET stat = alterlist(audit_events->list,list_ind)
  SET audit_events->list[list_ind].eventname = "Consent_Signed_Date-Time"
  SET audit_events->list[list_ind].eventtype = "Add"
 ENDIF
 IF ((request->consent_received_dt_tm != 0))
  SET list_ind += 1
  SET stat = alterlist(audit_events->list,list_ind)
  SET audit_events->list[list_ind].eventname = "Consent_Returned_Date-Time"
  SET audit_events->list[list_ind].eventtype = "Add"
 ENDIF
 IF ((request->not_returned_dt_tm != 0))
  SET list_ind += 1
  SET stat = alterlist(audit_events->list,list_ind)
  SET audit_events->list[list_ind].eventname = "Con_Not_Returned_Dt-Tm"
  SET audit_events->list[list_ind].eventtype = "Add"
 ENDIF
 IF (curqual=1)
  CALL echo("insert into the pt_consent table : curqual = 1")
  SET reply->constatus = "S"
  SET doinsert = 1
 ELSE
  CALL echo("insert into the pt_consent table : curqual != 1")
  SET doinsert = 0
 ENDIF
 IF (doinsert=1)
  IF ((request->regid != 0))
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
    SET rltn.pt_reg_consent_reltn_id = ptregconsentreltnid, rltn.reg_id = request->regid, rltn
     .consent_id = conid,
     rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
     updt_task,
     rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
     rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
      sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   CALL echo(build("PtRegConsentReltnID = ",ptregconsentreltnid))
   CALL echo(build("Request->RegID = ",request->regid))
   CALL echo(build("ConID = ",conid))
   IF (curqual=1)
    SET reply->reltnregstatus = "S"
    SET doinsert = 1
   ELSE
    SET reply->reltnregstatus = "F"
    SET doinsert = 0
   ENDIF
  ELSEIF ((request->regid=0)
   AND (request->consent_signed_dt_tm != 0))
   CALL enrollconsentpatient(conid)
  ENDIF
 ENDIF
 IF (doinsert=1)
  IF ((request->eligid != 0))
   CALL echo("Get Unique ID for pt_elig_consent_reltn")
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     pteligconsentreltnid = cnvtreal(num)
    WITH format, counter
   ;end select
   CALL echo("BEFORE - Insert pt_elig_consent_reltn")
   INSERT  FROM pt_elig_consent_reltn rltn
    SET rltn.pt_elig_consent_reltn_id = pteligconsentreltnid, rltn.pt_elig_tracking_id = request->
     eligid, rltn.consent_id = conid,
     rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
     updt_task,
     rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
     rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
      sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=1)
    SET doinsert = 1
    SET reply->reltneligstatus = "S"
   ELSE
    SET reply->reltneligstatus = "F"
    SET doinsert = 0
   ENDIF
   CALL echo(build("PtEligConsentReltnID = ",pteligconsentreltnid))
   CALL echo(build("Request->EligID = ",request->eligid))
   CALL echo(build("ConID = ",conid))
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = doinsert
 IF (doinsert=1)
  SET reply->status_data.status = "S"
  IF (transferwc_ind=1)
   EXECUTE cclaudit audit_mode, "Consent_Released", "Add",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, ""
  ENDIF
  FOR (x = 1 TO list_ind)
    EXECUTE cclaudit audit_mode, audit_events->list[x].eventname, audit_events->list[x].eventtype,
    "Person", "Patient", "Patient",
    "Origination", request->person_id, ""
  ENDFOR
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
 CALL echo(build("Status = [",reply->status_data.status,"]"))
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
 SET last_mod = "009"
 SET mod_date = "Jan 31, 2024"
END GO
