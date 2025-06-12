CREATE PROGRAM afc_get_interface_file:dba
 IF ("Z"=validate(afc_get_interface_file_vrsn,"Z"))
  DECLARE afc_get_interface_file_vrsn = vc WITH noconstant("CHARGSRV-14179.020"), public
 ENDIF
 SET afc_get_interface_file_vrsn = "CHARGSRV-14179.020"
 RECORD reply(
   1 interface_file_qual = i4
   1 interface_file[*]
     2 interface_file_id = f8
     2 description = vc
     2 file_name = vc
     2 realtime_ind = i2
     2 hl7_ind = i2
     2 cdm_sched_cd = f8
     2 rev_sched_cd = f8
     2 cpt_sched_cd = f8
     2 active_ind = i2
     2 mult_bill_code_sched_cd = f8
     2 contributor_system_cd = f8
     2 doc_nbr_cd = f8
     2 explode_ind = i2
     2 profit_type_cd = f8
     2 fin_nbr_suspend_ind = i2
     2 max_ft1 = vc
     2 perf_phys_cont_ind = i2
     2 round_method_flag = i2
     2 reprocess_ind = i2
     2 reprocess_cpt_ind = i2
     2 interface_type_flag = i2
     2 billing_entity_id = f8
     2 billing_entity_name = vc
     2 order_phys_copy_ind = i2
     2 susp_chrg_process_flag = i2
     2 service_based_ind = i2
     2 cdm_id_suspend_ind = i2
     2 cost_center_suspend_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tmpreply(
   1 interface_file_qual = i4
   1 interface_file[*]
     2 interface_file_id = f8
     2 description = vc
     2 file_name = vc
     2 realtime_ind = i2
     2 hl7_ind = i2
     2 cdm_sched_cd = f8
     2 rev_sched_cd = f8
     2 cpt_sched_cd = f8
     2 active_ind = i2
     2 mult_bill_code_sched_cd = f8
     2 contributor_system_cd = f8
     2 doc_nbr_cd = f8
     2 explode_ind = i2
     2 profit_type_cd = f8
     2 fin_nbr_suspend_ind = i2
     2 max_ft1 = vc
     2 perf_phys_cont_ind = i2
     2 round_method_flag = i2
     2 reprocess_ind = i2
     2 reprocess_cpt_ind = i2
     2 interface_type_flag = i2
     2 billing_entity_id = f8
     2 order_phys_copy_ind = i2
     2 susp_chrg_process_flag = i2
     2 service_based_ind = i2
     2 cdm_id_suspend_ind = i2
     2 cost_center_suspend_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE curlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE mninterfacefilesize = i4 WITH protect, noconstant(0)
 DECLARE mninterfacefileloop = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
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
 IF ( NOT (getlogicaldomain(ld_concept_organization,curlogicaldomainid)))
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  i.*
  FROM interface_file i
  WHERE ((i.interface_file_id+ 0) != 0.0)
   AND i.logical_domain_id=curlogicaldomainid
  ORDER BY i.description
  DETAIL
   count1 += 1, tmpreply->interface_file_qual = count1, stat = alterlist(tmpreply->interface_file,
    count1),
   tmpreply->interface_file[count1].interface_file_id = i.interface_file_id, tmpreply->
   interface_file[count1].description = i.description, tmpreply->interface_file[count1].file_name = i
   .file_name,
   tmpreply->interface_file[count1].realtime_ind = i.realtime_ind, tmpreply->interface_file[count1].
   hl7_ind = i.hl7_ind, tmpreply->interface_file[count1].cdm_sched_cd = i.cdm_sched_cd,
   tmpreply->interface_file[count1].cpt_sched_cd = i.cpt_sched_cd, tmpreply->interface_file[count1].
   rev_sched_cd = i.rev_sched_cd, tmpreply->interface_file[count1].mult_bill_code_sched_cd = i
   .mult_bill_code_sched_cd,
   tmpreply->interface_file[count1].contributor_system_cd = i.contributor_system_cd, tmpreply->
   interface_file[count1].doc_nbr_cd = i.doc_nbr_cd, tmpreply->interface_file[count1].explode_ind = i
   .explode_ind,
   tmpreply->interface_file[count1].active_ind = i.active_ind, tmpreply->interface_file[count1].
   profit_type_cd = i.profit_type_cd, tmpreply->interface_file[count1].fin_nbr_suspend_ind = i
   .fin_nbr_suspend_ind,
   tmpreply->interface_file[count1].max_ft1 = i.max_ft1, tmpreply->interface_file[count1].
   perf_phys_cont_ind = i.perf_phys_cont_ind, tmpreply->interface_file[count1].round_method_flag = i
   .round_method_flag,
   tmpreply->interface_file[count1].reprocess_ind = i.reprocess_ind, tmpreply->interface_file[count1]
   .reprocess_cpt_ind = i.reprocess_cpt_ind, tmpreply->interface_file[count1].interface_type_flag = i
   .interface_type_flag,
   tmpreply->interface_file[count1].billing_entity_id = i.billing_entity_id, tmpreply->
   interface_file[count1].order_phys_copy_ind = i.order_phys_copy_ind, tmpreply->interface_file[
   count1].susp_chrg_process_flag = i.susp_chrg_process_flag,
   tmpreply->interface_file[count1].service_based_ind = i.service_based_ind, tmpreply->
   interface_file[count1].cdm_id_suspend_ind = i.cdm_id_suspend_ind, tmpreply->interface_file[count1]
   .cost_center_suspend_ind = i.cost_center_suspend_ind
  WITH nocounter
 ;end select
 SET mninterfacefilesize = tmpreply->interface_file_qual
 SET stat = alterlist(reply->interface_file,mninterfacefilesize)
 SET reply->interface_file_qual = mninterfacefilesize
 FOR (mninterfacefileloop = 1 TO mninterfacefilesize)
   IF ((validate(reply->interface_file[mninterfacefileloop].interface_file_id,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].interface_file_id = tmpreply->interface_file[
    mninterfacefileloop].interface_file_id
   ENDIF
   IF (validate(reply->interface_file[mninterfacefileloop].description,"Z") != "Z")
    SET reply->interface_file[mninterfacefileloop].description = tmpreply->interface_file[
    mninterfacefileloop].description
   ENDIF
   IF (validate(reply->interface_file[mninterfacefileloop].file_name,"Z") != "Z")
    SET reply->interface_file[mninterfacefileloop].file_name = tmpreply->interface_file[
    mninterfacefileloop].file_name
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].realtime_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].realtime_ind = tmpreply->interface_file[
    mninterfacefileloop].realtime_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].hl7_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].hl7_ind = tmpreply->interface_file[
    mninterfacefileloop].hl7_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].cdm_sched_cd,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].cdm_sched_cd = tmpreply->interface_file[
    mninterfacefileloop].cdm_sched_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].cpt_sched_cd,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].cpt_sched_cd = tmpreply->interface_file[
    mninterfacefileloop].cpt_sched_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].rev_sched_cd,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].rev_sched_cd = tmpreply->interface_file[
    mninterfacefileloop].rev_sched_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].mult_bill_code_sched_cd,- (1.0)) != - (
   1.0)))
    SET reply->interface_file[mninterfacefileloop].mult_bill_code_sched_cd = tmpreply->
    interface_file[mninterfacefileloop].mult_bill_code_sched_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].contributor_system_cd,- (1.0)) != - (1.0)
   ))
    SET reply->interface_file[mninterfacefileloop].contributor_system_cd = tmpreply->interface_file[
    mninterfacefileloop].contributor_system_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].doc_nbr_cd,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].doc_nbr_cd = tmpreply->interface_file[
    mninterfacefileloop].doc_nbr_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].explode_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].explode_ind = tmpreply->interface_file[
    mninterfacefileloop].explode_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].active_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].active_ind = tmpreply->interface_file[
    mninterfacefileloop].active_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].profit_type_cd,- (1.0)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].profit_type_cd = tmpreply->interface_file[
    mninterfacefileloop].profit_type_cd
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].fin_nbr_suspend_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].fin_nbr_suspend_ind = tmpreply->interface_file[
    mninterfacefileloop].fin_nbr_suspend_ind
   ENDIF
   IF (validate(reply->interface_file[mninterfacefileloop].max_ft1,"Z") != "Z")
    SET reply->interface_file[mninterfacefileloop].max_ft1 = tmpreply->interface_file[
    mninterfacefileloop].max_ft1
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].perf_phys_cont_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].perf_phys_cont_ind = tmpreply->interface_file[
    mninterfacefileloop].perf_phys_cont_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].round_method_flag,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].round_method_flag = tmpreply->interface_file[
    mninterfacefileloop].round_method_flag
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].reprocess_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].reprocess_ind = tmpreply->interface_file[
    mninterfacefileloop].reprocess_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].order_phys_copy_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].order_phys_copy_ind = tmpreply->interface_file[
    mninterfacefileloop].order_phys_copy_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].reprocess_cpt_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].reprocess_cpt_ind = tmpreply->interface_file[
    mninterfacefileloop].reprocess_cpt_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].interface_type_flag,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].interface_type_flag = tmpreply->interface_file[
    mninterfacefileloop].interface_type_flag
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].susp_chrg_process_flag,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].susp_chrg_process_flag = tmpreply->interface_file[
    mninterfacefileloop].susp_chrg_process_flag
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].service_based_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].service_based_ind = tmpreply->interface_file[
    mninterfacefileloop].service_based_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].cdm_id_suspend_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].cdm_id_suspend_ind = tmpreply->interface_file[
    mninterfacefileloop].cdm_id_suspend_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].cost_center_suspend_ind,- (1)) != - (1)))
    SET reply->interface_file[mninterfacefileloop].cost_center_suspend_ind = tmpreply->
    interface_file[mninterfacefileloop].cost_center_suspend_ind
   ENDIF
   IF ((validate(reply->interface_file[mninterfacefileloop].billing_entity_id,- (1.00)) != - (1.0)))
    SET reply->interface_file[mninterfacefileloop].billing_entity_id = tmpreply->interface_file[
    mninterfacefileloop].billing_entity_id
    SELECT INTO "nl:"
     FROM billing_entity be
     WHERE (be.billing_entity_id=tmpreply->interface_file[mninterfacefileloop].billing_entity_id)
      AND be.active_ind=true
     DETAIL
      reply->interface_file[mninterfacefileloop].billing_entity_name = trim(be.be_name,3)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#end_program
 FREE RECORD tmpreply
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "INTERFACE_FILE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
