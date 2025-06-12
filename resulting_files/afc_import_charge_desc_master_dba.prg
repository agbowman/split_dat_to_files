CREATE PROGRAM afc_import_charge_desc_master:dba
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 CALL echo("Begin PFT_LOGICAL_DOMAIN_SUBS.INC, version [714452.014 w/o 002,005,007,008,009,010]")
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ( NOT (validate(profitlogicaldomaininfo)))
  RECORD profitlogicaldomaininfo(
    1 hasbeenset = i2
    1 logicaldomainid = f8
    1 logicaldomainsystemuserid = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(ld_concept_batch_trans)))
  DECLARE ld_concept_batch_trans = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_event)))
  DECLARE ld_concept_pft_event = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_ruleset)))
  DECLARE ld_concept_pft_ruleset = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_queue_item_wf_hist)))
  DECLARE ld_concept_pft_queue_item_wf_hist = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_workflow)))
  DECLARE ld_concept_pft_workflow = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_entity_account)))
  DECLARE ld_entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(ld_entity_adjustment)))
  DECLARE ld_entity_adjustment = vc WITH protect, constant("ADJUSTMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_balance)))
  DECLARE ld_entity_balance = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(ld_entity_charge)))
  DECLARE ld_entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(ld_entity_claim)))
  DECLARE ld_entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(ld_entity_encounter)))
  DECLARE ld_entity_encounter = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(ld_entity_invoice)))
  DECLARE ld_entity_invoice = vc WITH protect, constant("INVOICE")
 ENDIF
 IF ( NOT (validate(ld_entity_payment)))
  DECLARE ld_entity_payment = vc WITH protect, constant("PAYMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_person)))
  DECLARE ld_entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(ld_entity_pftencntr)))
  DECLARE ld_entity_pftencntr = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(ld_entity_statement)))
  DECLARE ld_entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(getlogicaldomain)))
  SUBROUTINE (getlogicaldomain(concept=i4,logicaldomainid=f8(ref)) =i2)
    CALL logmessage("getLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     IF (((concept < ld_concept_minvalue) OR (concept > ld_concept_maxvalue)) )
      CALL logmessage("getLogicalDomain",build2("Invalid logical domain concept: ",concept),log_error
       )
      RETURN(false)
     ENDIF
     FREE RECORD acm_get_curr_logical_domain_req
     RECORD acm_get_curr_logical_domain_req(
       1 concept = i4
     )
     FREE RECORD acm_get_curr_logical_domain_rep
     RECORD acm_get_curr_logical_domain_rep(
       1 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     DECLARE currentuserid = f8 WITH protect, constant(reqinfo->updt_id)
     IF ((profitlogicaldomaininfo->hasbeenset=true))
      SET reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
     ENDIF
     SET acm_get_curr_logical_domain_req->concept = concept
     EXECUTE acm_get_curr_logical_domain
     SET reqinfo->updt_id = currentuserid
     IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
      CALL logmessage("getLogicalDomain","Failed to retrieve logical domain...",log_error)
      CALL echorecord(acm_get_curr_logical_domain_rep)
      RETURN(false)
     ENDIF
     SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
     CALL logmessage("getLogicalDomain",build2("Logical domain for concept [",trim(cnvtstring(concept
         )),"]: ",trim(cnvtstring(logicaldomainid))),log_debug)
     FREE RECORD acm_get_curr_logical_domain_req
     FREE RECORD acm_get_curr_logical_domain_rep
    ELSE
     SET logicaldomainid = 0.0
    ENDIF
    CALL logmessage("getLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getlogicaldomainforentitytype(pentityname=vc,prlogicaldomainid=f8(ref)) =i2)
   DECLARE entityconcept = i4 WITH protect, noconstant(0)
   CASE (pentityname)
    OF value(ld_entity_person,ld_entity_encounter,ld_entity_pftencntr):
     SET entityconcept = ld_concept_person
    OF value(ld_entity_claim,ld_entity_invoice,ld_entity_statement,ld_entity_adjustment,
    ld_entity_charge,
    ld_entity_payment,ld_entity_account,ld_entity_balance):
     SET entityconcept = ld_concept_organization
   ENDCASE
   RETURN(getlogicaldomain(entityconcept,prlogicaldomainid))
 END ;Subroutine
 IF ( NOT (validate(setlogicaldomain)))
  SUBROUTINE (setlogicaldomain(logicaldomainid=f8) =i2)
    CALL logmessage("setLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logicaldomainid
      DETAIL
       profitlogicaldomaininfo->logicaldomainsystemuserid = ld.system_user_id
      WITH nocounter
     ;end select
     SET profitlogicaldomaininfo->logicaldomainid = logicaldomainid
     SET profitlogicaldomaininfo->hasbeenset = true
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=reqinfo->updt_id)
      DETAIL
       IF (p.logical_domain_id != logicaldomainid)
        reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
       ENDIF
      WITH nocounter
     ;end select
     IF (validate(debug,0))
      CALL echorecord(profitlogicaldomaininfo)
      CALL echo(build("reqinfo->updt_id:",reqinfo->updt_id))
     ENDIF
    ENDIF
    CALL logmessage("setLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(arelogicaldomainsinuse)))
  DECLARE arelogicaldomainsinuse(null) = i2
  SUBROUTINE arelogicaldomainsinuse(null)
    CALL logmessage("areLogicalDomainsInUse","Entering...",log_debug)
    DECLARE multiplelogicaldomainsdefined = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id > 0.0
      AND ld.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET multiplelogicaldomainsdefined = true
    ENDIF
    CALL logmessage("areLogicalDomainsInUse",build2("Multiple logical domains ",evaluate(
       multiplelogicaldomainsdefined,true,"are","are not")," in use"),log_debug)
    CALL logmessage("areLogicalDomainsInUse","Exiting...",log_debug)
    RETURN(multiplelogicaldomainsdefined)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getparameterentityname(dparmcd=f8) =vc)
   DECLARE parammeaning = vc WITH private, constant(trim(uar_get_code_meaning(dparmcd)))
   DECLARE returnvalue = vc WITH private, noconstant("")
   SET returnvalue = evaluate(parammeaning,"BEID","BILLING_ENTITY","OPTIONALBEID","BILLING_ENTITY",
    "HP ID","HEALTH_PLAN","HP_LIST","HEALTH_PLAN","PRIMARYHP",
    "HEALTH_PLAN","PRIPAYORHPID","HEALTH_PLAN","SECPAYORHPID","HEALTH_PLAN",
    "TERPAYORHPID","HEALTH_PLAN","COLLAGENCY","ORGANIZATION","PAYORORGID",
    "ORGANIZATION","PRECOLAGENCY","ORGANIZATION","PRIPAYORORGI","ORGANIZATION",
    "SECPAYORORGI","ORGANIZATION","TERPAYORORGI","ORGANIZATION","PAYER_LIST",
    "ORGANIZATION","UNKNOWN")
   RETURN(returnvalue)
 END ;Subroutine
 SUBROUTINE (paramsarevalidfordomain(paramstruct=vc(ref),dlogicaldomainid=f8) =i2)
   DECLARE paramidx = i4 WITH private, noconstant(0)
   DECLARE paramentityname = vc WITH private, noconstant("")
   DECLARE paramvalue = f8 WITH protect, noconstant(0.0)
   DECLARE paramerror = i2 WITH protect, noconstant(false)
   FOR (paramidx = 1 TO paramstruct->lparams_qual)
     SET paramentityname = getparameterentityname(paramstruct->aparams[paramidx].dvalue_meaning)
     SET paramvalue = cnvtreal(paramstruct->aparams[paramidx].svalue)
     SET paramerror = true
     IF (paramentityname="BILLING_ENTITY")
      SELECT INTO "nl:"
       FROM billing_entity be,
        organization o
       PLAN (be
        WHERE be.billing_entity_id=paramvalue)
        JOIN (o
        WHERE o.organization_id=be.organization_id
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="HEALTH_PLAN")
      SELECT INTO "nl:"
       FROM health_plan hp
       PLAN (hp
        WHERE hp.health_plan_id=paramvalue
         AND hp.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="ORGANIZATION")
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE o.organization_id=paramvalue
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSE
      SET paramerror = false
     ENDIF
     IF (paramerror)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 IF ( NOT (validate(getlogicaldomainsystemuser)))
  SUBROUTINE (getlogicaldomainsystemuser(logicaldomainid=f8(ref)) =f8)
    DECLARE systempersonnelid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id=logicaldomainid
     DETAIL
      systempersonnelid = ld.system_user_id
     WITH nocounter
    ;end select
    IF (systempersonnelid <= 0.0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.active_ind=true
       AND p.logical_domain_id=logicaldomainid
       AND p.username="SYSTEM"
      DETAIL
       systempersonnelid = p.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (systempersonnelid <= 0.0)
     CALL logmessage("getLogicalDomainSystemUser",
      "Failed to determine the default 'SYSTEM' personnel id",log_error)
     RETURN(0.0)
    ENDIF
    CALL logmessage("getLogicalDomainSystemUser","Exiting",log_debug)
    RETURN(systempersonnelid)
  END ;Subroutine
 ENDIF
 DECLARE afc_import_charge_desc_master = vc WITH constant("CHARGSRV-14134.001")
 IF ( NOT (validate(processcdms)))
  RECORD processcdms(
    1 list[*]
      2 charge_desc_master_id = f8
      2 cdm_code = vc
      2 cdm_description = vc
      2 service_type = i2
      2 service_type_text = vc
      2 errorind = i2
      2 errorreason = vc
  ) WITH protect
 ENDIF
 RECORD afcenscdmreq(
   1 charge_desc_master_qual = i4
   1 charge_desc_master[*]
     2 action_type = c3
     2 cdm_id = f8
     2 cdm_code = vc
     2 description = vc
     2 service_type = i2
     2 logical_domain_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 ) WITH protect
 RECORD afcenscdmrep(
   1 charge_desc_master[*]
     2 cdm_code = vc
     2 description = vc
     2 logical_domain_id = f8
     2 action_type = c3
     2 issue = vc
     2 status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (validate(maxcdmbatchsize,0.0)=0.0)
  DECLARE maxcdmbatchsize = f8 WITH protect, constant(100.0)
 ENDIF
 DECLARE status_success = i2 WITH protect, constant(1)
 DECLARE action_upt = vc WITH protect, constant("UPT")
 DECLARE action_add = vc WITH protect, constant("ADD")
 DECLARE service_type_tech = vc WITH protect, constant("TECHNICAL")
 DECLARE service_type_prof = vc WITH protect, constant("PROFESSIONAL")
 DECLARE tech_flag = i2 WITH protect, constant(1)
 DECLARE prof_flag = i2 WITH protect, constant(2)
 DECLARE max_cdm_code_length = i2 WITH protect, constant(20)
 DECLARE max_cdm_desc_length = i2 WITH protect, constant(60)
 DECLARE error_filename = vc WITH protect, constant("ccluserdir:afc_import_charge_desc_master_")
 DECLARE error_filename_extension = vc WITH protect, constant(".log")
 DECLARE errcdmcoderequired = vc WITH protect, constant("CDM Code is required")
 DECLARE errcdmcodetoolong = vc WITH protect, constant("CDM Code limit is 20 characters")
 DECLARE errservicetyperequired = vc WITH protect, constant("Service Type is required")
 DECLARE errcdmdescriptionrequired = vc WITH protect, constant("CDM Description is required")
 DECLARE errcdmdescriptiontoolong = vc WITH protect, constant(
  "CDM Description limit is 60 characters")
 DECLARE errservicetypeinvalid = vc WITH protect, constant("Service Type is invalid")
 DECLARE errcdmcodeexists = vc WITH protect, constant("CDM Code already exists")
 DECLARE errinvalidupdate = vc WITH protect, constant(
  "Invalid Update: either CDM code was not found, or attempting to change the CDM code")
 DECLARE errservicetypeupdate = vc WITH protect, constant("Service Type cannot be changed")
 DECLARE errcdmcodeduplicate = vc WITH protect, constant("CDM is duplicated in upload")
 DECLARE curlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE validatecdmrequestin(null) = null
 DECLARE processcdmrequest(null) = null
 DECLARE writeerrorlog(null) = null
 IF ( NOT (getlogicaldomain(ld_concept_organization,curlogicaldomainid)))
  CALL logmessage(curprog,"Failed to obtain logical domain",log_warning)
  GO TO exit_script
 ENDIF
 CALL validatecdmrequestin(null)
 CALL processcdmrequest(null)
 CALL writeerrorlog(null)
 SUBROUTINE validatecdmrequestin(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(requestin)
   ENDIF
   IF (size(requestin->list_0,5) <= 0)
    CALL logmessage("validateCDMRequestin","No data in file",log_warning)
    GO TO exit_script
   ENDIF
   IF ((( NOT (validate(requestin->list_0[1].charge_desc_master_id))) OR ((( NOT (validate(requestin
    ->list_0[1].cdm_code))) OR ((( NOT (validate(requestin->list_0[1].service_type))) OR ( NOT (
   validate(requestin->list_0[1].cdm_description)))) )) )) )
    CALL logmessage("validateCDMRequestin","Required columns were not included in file",log_warning)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(processcdms->list,size(requestin->list_0,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(requestin->list_0,5)),
     charge_desc_master cdm
    PLAN (d)
     JOIN (cdm
     WHERE cdm.cdm_code_txt=trim(requestin->list_0[d.seq].cdm_code,3)
      AND cdm.logical_domain_id=curlogicaldomainid
      AND cdm.active_ind=1)
    DETAIL
     processcdms->list[d.seq].charge_desc_master_id = cnvtreal(requestin->list_0[d.seq].
      charge_desc_master_id), processcdms->list[d.seq].cdm_code = trim(requestin->list_0[d.seq].
      cdm_code,3), processcdms->list[d.seq].cdm_description = trim(requestin->list_0[d.seq].
      cdm_description,3),
     processcdms->list[d.seq].service_type_text = trim(requestin->list_0[d.seq].service_type,3)
     IF (textlen(trim(requestin->list_0[d.seq].cdm_code,3))=0)
      CALL populatecdmerror(errcdmcoderequired,d.seq)
     ELSEIF (textlen(trim(requestin->list_0[d.seq].cdm_code,3)) > max_cdm_code_length)
      CALL populatecdmerror(errcdmcodetoolong,d.seq)
     ENDIF
     IF (textlen(trim(requestin->list_0[d.seq].cdm_description,3))=0)
      CALL populatecdmerror(errcdmdescriptionrequired,d.seq)
     ELSEIF (textlen(trim(requestin->list_0[d.seq].cdm_description,3)) > max_cdm_desc_length)
      CALL populatecdmerror(errcdmdescriptiontoolong,d.seq)
     ENDIF
     IF (textlen(trim(requestin->list_0[d.seq].service_type,3))=0)
      CALL populatecdmerror(errservicetyperequired,d.seq)
     ELSE
      CASE (cnvtupper(requestin->list_0[d.seq].service_type))
       OF service_type_tech:
        processcdms->list[d.seq].service_type = tech_flag
       OF service_type_prof:
        processcdms->list[d.seq].service_type = prof_flag
       ELSE
        CALL populatecdmerror(errservicetypeinvalid,d.seq)
      ENDCASE
     ENDIF
     IF ((processcdms->list[d.seq].errorind=0))
      IF ((cdm.charge_desc_master_id != processcdms->list[d.seq].charge_desc_master_id))
       IF (cdm.charge_desc_master_id > 0
        AND (processcdms->list[d.seq].charge_desc_master_id=0))
        CALL populatecdmerror(errcdmcodeexists,d.seq)
       ELSE
        CALL populatecdmerror(errinvalidupdate,d.seq)
       ENDIF
      ELSEIF (cdm.charge_desc_master_id > 0
       AND (processcdms->list[d.seq].service_type != cdm.service_type_flag))
       CALL populatecdmerror(errservicetypeupdate,d.seq)
      ELSE
       pos = locateval(idx,1,(d.seq - 1),requestin->list_0[d.seq].cdm_code,requestin->list_0[idx].
        cdm_code)
       IF (pos > 0)
        CALL populatecdmerror(errcdmcodeduplicate,d.seq)
       ENDIF
       IF ((processcdms->list[d.seq].errorind=0))
        pos = locateval(idx,(d.seq+ 1),size(requestin->list_0,5),requestin->list_0[d.seq].cdm_code,
         requestin->list_0[idx].cdm_code)
        IF (pos > 0)
         CALL populatecdmerror(errcdmcodeduplicate,d.seq)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH outerjoin = d
   ;end select
 END ;Subroutine
 SUBROUTINE processcdmrequest(null)
   DECLARE batchesnotfinished = i2 WITH protect, noconstant(1)
   DECLARE batchnotfull = i2 WITH protect, noconstant(0)
   DECLARE batchcnt = i4 WITH protect, noconstant(0)
   DECLARE processcdmsidx = i4 WITH protect, noconstant(0)
   DECLARE afcenscdmreqidx = i4 WITH protect, noconstant(0)
   DECLARE temperrorstring = vc WITH protect, noconstant("")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   WHILE (batchesnotfinished)
     SET batchcnt += 1
     IF (validate(debug,- (1)) > 0)
      CALL echo(build2("while batchCnt: ",batchcnt))
     ENDIF
     SET stat = initrec(afcenscdmreq)
     SET stat = initrec(afcenscdmrep)
     SET stat = alterlist(afcenscdmreq->charge_desc_master,maxcdmbatchsize)
     SET afcenscdmreq->charge_desc_master_qual = 0
     SET afcenscdmreqidx = 0
     SET batchnotfull = true
     WHILE (batchnotfull)
       SET processcdmsidx += 1
       IF (validate(debug,- (1)) > 0)
        CALL echo(build2("while processCDMsIdx: ",processcdmsidx))
       ENDIF
       IF (processcdmsidx > 0
        AND processcdmsidx <= size(processcdms->list,5))
        IF ((processcdms->list[processcdmsidx].errorind=0))
         SET afcenscdmreqidx = (afcenscdmreq->charge_desc_master_qual+ 1)
         SET afcenscdmreq->charge_desc_master_qual = afcenscdmreqidx
         SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].cdm_id = processcdms->list[
         processcdmsidx].charge_desc_master_id
         IF ((processcdms->list[processcdmsidx].charge_desc_master_id > 0))
          SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].action_type = action_upt
         ELSE
          SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].action_type = action_add
         ENDIF
         SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].cdm_code = processcdms->list[
         processcdmsidx].cdm_code
         SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].description = processcdms->list[
         processcdmsidx].cdm_description
         SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].service_type = processcdms->list[
         processcdmsidx].service_type
         SET afcenscdmreq->charge_desc_master[afcenscdmreqidx].logical_domain_id = curlogicaldomainid
        ENDIF
       ELSE
        SET batchnotfull = false
        SET batchesnotfinished = false
       ENDIF
       IF ((afcenscdmreq->charge_desc_master_qual >= maxcdmbatchsize))
        SET batchnotfull = false
       ENDIF
     ENDWHILE
     SET stat = alterlist(afcenscdmreq->charge_desc_master,afcenscdmreq->charge_desc_master_qual)
     IF (size(afcenscdmreq->charge_desc_master,5) > 0)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(afcenscdmreq)
       CALL echo(build2("Batch:",batchcnt," Calling afc_ens_charge_desc_master"))
      ENDIF
      EXECUTE afc_ens_charge_desc_master  WITH replace("REQUEST",afcenscdmreq), replace("REPLY",
       afcenscdmrep)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(afcenscdmrep)
      ENDIF
      IF (size(afcenscdmrep->charge_desc_master,5) > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = size(afcenscdmrep->charge_desc_master,5))
        PLAN (d
         WHERE (afcenscdmrep->charge_desc_master[d.seq].status_flag != status_success))
        DETAIL
         pos = locateval(idx,1,size(processcdms->list,5),afcenscdmrep->charge_desc_master[d.seq].
          cdm_code,processcdms->list[idx].cdm_code)
         IF (pos > 0)
          CALL populatecdmerror(afcenscdmrep->charge_desc_master[d.seq].issue,pos)
         ELSE
          temperrorstring = build2("CDM code: ",trim(afcenscdmrep->charge_desc_master[d.seq].cdm_code,
            3)," Error: ",trim(afcenscdmrep->charge_desc_master[d.seq].issue,3)),
          CALL logmessage("processCDMRequest",temperrorstring,log_warning)
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (populatecdmerror(errormsg=vc,position=i4) =null)
  IF ((processcdms->list[position].errorind=1))
   SET processcdms->list[position].errorreason = concat(processcdms->list[d.seq].errorreason,"; ",
    errormsg)
  ELSE
   SET processcdms->list[position].errorreason = errormsg
  ENDIF
  SET processcdms->list[position].errorind = 1
 END ;Subroutine
 SUBROUTINE writeerrorlog(null)
   DECLARE cdmerrorfilename = vc WITH protect, noconstant("")
   SET cdmerrorfilename = build2(error_filename,trim(cnvtstring(month(curdate)),3),"_",trim(
     cnvtstring(year(curdate)),3),error_filename_extension)
   CALL logmessage("writeErrorLog",build2("Issues will be logged to: ",cdmerrorfilename),log_info)
   SELECT INTO value(cdmerrorfilename)
    run_date = format(curdate,"dd-mmm-yyyy;;d"), run_time = format(curtime3,"hh:mm:ss;;m"),
    charge_desc_master_id = cnvtstring(processcdms->list[d.seq].charge_desc_master_id),
    cdm_code = substring(1,20,processcdms->list[d.seq].cdm_code), cdm_description = substring(1,60,
     processcdms->list[d.seq].cdm_description), service_type = substring(1,12,processcdms->list[d.seq
     ].service_type_text),
    errorreason = substring(1,120,processcdms->list[d.seq].errorreason)
    FROM (dummyt d  WITH seq = size(processcdms->list,5))
    PLAN (d
     WHERE (processcdms->list[d.seq].errorind=1))
    ORDER BY errorreason, d.seq
    HEAD REPORT
     row + 1, col 1,
     "**************************************** AFC_IMPORT_CHARGE_DESC_MASTER_LOG *****************************************",
     row + 1, col 1, "RUN DATE: ",
     run_date, " ", run_time,
     row + 1
     IF (validate(reqinfo->updt_id,0) > 0)
      col 1, "USER ID: ", reqinfo->updt_id,
      row + 1
     ENDIF
     col 1,
     "********************************************************************************************************************"
    HEAD errorreason
     row + 1, row + 1, col 1,
     "ERROR:", col 8, errorreason,
     row + 1, col 6, "CHARGE_DESC_MASTER_ID",
     col 31, "CDM_CODE", col 53,
     "CDM_DESCRIPTION", col 115, "SERVICE_TYPE",
     row + 1
    DETAIL
     col 6, charge_desc_master_id, col 31,
     cdm_code, col 53, cdm_description,
     col 115, service_type, row + 1
    FOOT REPORT
     row + 1, col 1,
     "--------------------------------------------------------------------------------------------------------------------"
    WITH append, maxrow = 1000
   ;end select
 END ;Subroutine
#exit_script
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(processcdms)
 ENDIF
END GO
