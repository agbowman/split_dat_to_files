CREATE PROGRAM afc_post_interface_charge:dba
 EXECUTE srvrtl
 EXECUTE crmrtl
 DECLARE afc_post_interf_charge_version = vc
 SET afc_post_interf_charge_version = "RCBCMR-10884.062"
 DECLARE curlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE logicaldomainsinuse = i2 WITH protect, noconstant(0)
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
 SUBROUTINE (removeregroupinghold(encntrid=f8) =i2)
   CALL logmessage("removeRegroupingHold","Entering",log_debug)
   IF ( NOT (validate(removeregroupids)))
    RECORD removeregroupids(
      1 objarray[*]
        2 pe_status_reason_id = f8
        2 active_ind = i2
        2 updt_cnt = i4
    ) WITH protect
   ENDIF
   IF ( NOT (validate(removeregroupreply)))
    RECORD removeregroupreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   DECLARE regroupcnt = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(cs24450_regroupenc)))
    DECLARE cs24450_regroupenc = f8 WITH protect, constant(uar_get_code_by("MEANING",24450,
      "REGROUPENC"))
   ENDIF
   IF ( NOT (validate(cs24450_regroupchgev)))
    DECLARE cs24450_regroupchgev = f8 WITH protect, constant(uar_get_code_by("MEANING",24450,
      "REGROUPCHGEV"))
   ENDIF
   IF ( NOT (cs24450_regroupenc > 0.0
    AND cs24450_regroupchgev > 0.0))
    CALL logmessage("removeRegroupingHold",
     "Code values (CS24450_REGROUPENC, CS24450_REGROUPCHGEV) not set up.",log_debug)
    RETURN(true)
   ENDIF
   IF (encntrid=0.0)
    CALL logmessage("removeRegroupingHold","Received a 0.0 id.",log_debug)
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM pft_encntr pe,
     pe_status_reason psr
    PLAN (pe
     WHERE pe.encntr_id=encntrid
      AND pe.active_ind=true)
     JOIN (psr
     WHERE psr.pft_encntr_id=pe.pft_encntr_id
      AND psr.pe_status_reason_cd IN (cs24450_regroupenc, cs24450_regroupchgev)
      AND psr.active_ind=true)
    DETAIL
     regroupcnt += 1, stat = alterlist(removeregroupids->objarray,regroupcnt), removeregroupids->
     objarray[regroupcnt].pe_status_reason_id = psr.pe_status_reason_id,
     removeregroupids->objarray[regroupcnt].active_ind = false, removeregroupids->objarray[regroupcnt
     ].updt_cnt = psr.updt_cnt
    WITH nocounter
   ;end select
   IF (size(removeregroupids->objarray,5) > 0)
    EXECUTE pft_da_upt_pe_status_reason  WITH replace("REQUEST",removeregroupids), replace("REPLY",
     removeregroupreply)
    IF ((removeregroupreply->status_data.status != "S"))
     CALL logmessage("removeRegroupingHold","pft_da_upt_pe_status_reason failed",log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   CALL logmessage("removeRegroupingHold","Exiting",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (publishcodingcompleteevent(encntrid=f8) =i2)
   CALL logmessage("publishCodingCompleteEvent","Entering",log_debug)
   IF (encntrid=0.0)
    CALL logmessage("publishCodingCompleteEvent","Received a 0.0 id.",log_debug)
    RETURN(false)
   ENDIF
   IF ( NOT (validate(cs23369_wfevent)))
    DECLARE cs23369_wfevent = f8 WITH protect, constant(uar_get_code_by("MEANING",23369,"WFEVENT"))
   ENDIF
   IF ( NOT (validate(cs29322_codingcomplt)))
    DECLARE cs29322_codingcomplt = f8 WITH protect, constant(uar_get_code_by("MEANING",29322,
      "CODINGCOMPLT"))
   ENDIF
   IF ( NOT (cs23369_wfevent > 0.0
    AND cs29322_codingcomplt > 0.0))
    CALL logmessage("publishCodingCompleteEvent",
     "Code values (CS23369_WFEVENT, CS29322_CODINGCOMPLT) not set up.",log_debug)
    RETURN(true)
   ENDIF
   IF ( NOT (validate(publisheventrequest)))
    RECORD publisheventrequest(
      1 eventlist[*]
        2 entitytypekey = vc
        2 entityid = f8
        2 eventtypecd = f8
        2 eventcd = f8
        2 params[*]
          3 paramcd = f8
          3 paramvalue = f8
    ) WITH protect
   ENDIF
   IF ( NOT (validate(publisheventreply)))
    RECORD publisheventreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
   ENDIF
   SET stat = alterlist(publisheventrequest->eventlist,1)
   SET publisheventrequest->eventlist[1].entitytypekey = "ENCOUNTER"
   SET publisheventrequest->eventlist[1].entityid = encntrid
   SET publisheventrequest->eventlist[1].eventcd = cs29322_codingcomplt
   SET publisheventrequest->eventlist[1].eventtypecd = cs23369_wfevent
   EXECUTE pft_publish_event  WITH replace("REQUEST",publisheventrequest), replace("REPLY",
    publisheventreply)
   IF ((publisheventreply->status_data.status != "S"))
    CALL logmessage("publishCodingCompleteEvent","Call to pft_publish_event failed",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage("publishCodingCompleteEvent","Exiting",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (publishpftchargeevent(req=vc(ref)) =i2)
   DECLARE chgevidx = i4 WITH protect, noconstant(0)
   DECLARE loopidx = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(cs13028_debit_cd)))
    DECLARE cs13028_debit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"DR"))
   ENDIF
   IF ( NOT (cs13028_debit_cd > 0.0))
    CALL logmessage("publishPftChargeEvent","Code value CS13028_DEBIT_CD not set up.",log_debug)
    RETURN(true)
   ENDIF
   IF ( NOT (validate(chargeeventreq)))
    RECORD chargeeventreq(
      1 charges[*]
        2 chargeitemid = f8
      1 revelatechargeind = i2
    ) WITH protect
   ENDIF
   IF ( NOT (validate(chargeeventreply)))
    RECORD chargeeventreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
   ENDIF
   IF (validate(req->charges))
    IF (size(req->charges,5) > 0)
     SET stat = alterlist(chargeeventreq->charges,size(req->charges,5))
     FOR (chgevidx = 1 TO size(req->charges,5))
       SET chargeeventreq->charges[chgevidx].chargeitemid = req->charges[chgevidx].charge_item_id
     ENDFOR
    ENDIF
   ELSEIF (validate(req->charge))
    IF (size(req->charge,5) > 0)
     SET stat = alterlist(chargeeventreq->charges,size(req->charge,5))
     FOR (loopidx = 1 TO size(req->charge,5))
       IF ((req->charge[loopidx].charge_type_cd IN (cs13028_debit_cd, 0.0))
        AND (req->charge[loopidx].process_flg != 1))
        SET chgevidx += 1
        SET chargeeventreq->charges[chgevidx].chargeitemid = req->charge[loopidx].charge_item_id
       ENDIF
     ENDFOR
     SET stat = alterlist(chargeeventreq->charges,chgevidx)
    ENDIF
   ENDIF
   IF (validate(req->revelatechargeind))
    SET chargeeventreq->revelatechargeind = req->revelatechargeind
   ENDIF
   IF (size(chargeeventreq->charges,5) > 0)
    EXECUTE pft_process_charge_event  WITH replace("REQUEST",chargeeventreq), replace("REPLY",
     chargeeventreply)
    IF ((chargeeventreply->status_data.status != "S"))
     CALL logmessage("publishPftChargeEvent","Call to pft_process_charge_event failed",log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   FREE RECORD chargeeventreq
   RETURN(true)
 END ;Subroutine
 RECORD interface_files(
   1 file_qual = i2
   1 files[*]
     2 cdm_sched_cd = f8
     2 cpt_sched_cd = f8
     2 rev_sched_cd = f8
     2 description = c100
     2 doc_nbr_cd = f8
     2 explode_ind = i2
     2 file_name = c32
     2 fin_nbr_suspend_ind = i2
     2 hl7_ind = i2
     2 interface_file_id = f8
     2 mult_bill_code_sched_cd = f8
     2 realtime_ind = i2
 )
 FREE SET post_request
 RECORD post_request(
   1 charge_qual = i2
   1 charge[*]
     2 abn_status_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_type_cd = f8
     2 admit_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 charge_description = c200
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 cost_center_cd = f8
     2 department_cd = f8
     2 discount_amount = f8
     2 encntr_id = f8
     2 end_effective_dt_tm = dq8
     2 gross_price = f8
     2 institution_cd = f8
     2 inst_fin_nbr = c50
     2 interface_file_id = f8
     2 item_extended_price = f8
     2 item_price = f8
     2 item_quantity = f8
     2 level5_cd = f8
     2 manual_ind = i2
     2 med_service_cd = f8
     2 order_id = f8
     2 ord_phys_id = f8
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 person_id = f8
     2 posted_dt_tm = dq8
     2 research_acct_id = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 updt_id = f8
     2 verify_phys_id = f8
     2 perf_phys_cont_ind = i2
     2 pharm_nocharge_ind = i2
     2 susp_for_missing_fin_ind = i2
     2 dont_susp_for_fin_ind = i2
     2 susp_for_missing_cdm_ind = i2
     2 susp_for_missing_cpt_ind = i2
     2 susp_for_missing_rev_ind = i2
     2 susp_for_missing_if_ind = i2
     2 missing_cpt_cd = f8
     2 missing_cdm_cd = f8
     2 missing_rev_cd = f8
     2 explode_ind = i2
     2 doc_nbr_cd = f8
     2 mult_bill_code_sched_cd = f8
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 batch_num = f8
     2 bed_cd = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 building_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 code_revenue_cd = f8
     2 code_revenue_more_ind = i2
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 encntr_type_cd = f8
     2 facility_cd = f8
     2 fin_nbr = c50
     2 fin_nbr_type_flg = i4
     2 icd9_proc_more_ind = i2
     2 interface_charge_id = f8
     2 med_nbr = c50
     2 net_ext_price = f8
     2 nurse_unit_cd = f8
     2 order_dept = i4
     2 order_nbr = c200
     2 ord_doc_nbr = c20
     2 organization_id = f8
     2 override_desc = c200
     2 person_name = c100
     2 price = f8
     2 prim_cdm = c50
     2 prim_cdm_desc = c200
     2 prim_cpt = c50
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 referring_phys_id = f8
     2 room_cd = f8
     2 user_def_ind = i2
     2 location_found = i2
     2 found_fin_nbr = i2
     2 qty_conv_factor = f8
     2 ext_bill_qty = i4
     2 mrn_check = i2
     2 found_one = i2
     2 ndc_ident = c40
     2 charge_event_id = f8
     2 service_based_ind = i2
 )
 FREE SET susp
 RECORD susp(
   1 charge_qual = i2
   1 charges[*]
     2 charge_item_id = f8
     2 susp_for_missing_fin_ind = i2
     2 dont_susp_for_fin_ind = i2
     2 susp_for_missing_cdm_ind = i2
     2 susp_for_missing_cpt_ind = i2
     2 susp_for_missing_if_ind = i2
     2 susp_for_missing_rev_ind = i2
 )
 RECORD cmreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cmrep(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE SET csops_request2
 RECORD csops_request2(
   1 csops_summ_id = f8
   1 job_name_cd = f8
   1 batch_num = f8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 job_status = c1
   1 seq = i4
   1 charge_qual = i2
   1 charges[*]
     2 interface_file_id = f8
     2 charge_type_cd = f8
     2 raw_count = i4
     2 total_amount = f8
     2 total_quantity = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET csops_cnt = 0
 SET logicaldomainsinuse = arelogicaldomainsinuse(null)
 IF (logicaldomainsinuse)
  IF (validate(request->batch_selection," ") != " ")
   IF (trim(request->batch_selection)="")
    GO TO end_program
   ELSE
    SET curlogicaldomainid = cnvtreal(trim(request->batch_selection))
   ENDIF
  ELSE
   IF ( NOT (getlogicaldomain(ld_concept_organization,curlogicaldomainid)))
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
   SET csops_request2->start_dt_tm = rn_dt
  ELSE
   SET rn_dt = cnvtdatetime(curdate,curtime)
   SET csops_request2->start_dt_tm = rn_dt
  ENDIF
 ELSE
  SET rn_dt = cnvtdatetime(curdate,curtime)
  SET csops_request2->start_dt_tm = rn_dt
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 SET run_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 CALL echo(build("the run date is: ",format(run_dt,"DD-MMM-YYYY HH:MM;;d")))
 DECLARE max_rows = i2
 DECLARE finished = i2
 DECLARE no_cdm_cd = f8
 DECLARE no_cpt_cd = f8
 DECLARE no_rev_cd = f8
 DECLARE no_fin_cd = f8
 DECLARE inactive_file_cd = f8
 DECLARE nocharge_cd = f8
 DECLARE pharm_cd = f8
 DECLARE all_cd = f8
 DECLARE docupin_cd = f8
 DECLARE docnbr_cd = f8
 DECLARE bill_code_cd = f8
 DECLARE fin_num_cd = f8
 DECLARE eff_cd = f8
 DECLARE del_cd = f8
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE admit_dr_cd = f8
 DECLARE attend_dr_cd = f8
 DECLARE refer_dr_cd = f8
 DECLARE med_rec_num_cd = f8
 DECLARE user_def_cd = f8
 DECLARE susp_cd = f8
 DECLARE object_name_cd = f8
 DECLARE credit_cd = f8
 DECLARE debit_cd = f8
 DECLARE total_qty_debit = f8
 DECLARE total_amt_debit = f8
 DECLARE total_cnt_debit = i4
 DECLARE total_qty_credit = f8
 DECLARE total_amt_credit = f8
 DECLARE total_cnt_credit = i4
 DECLARE new_batch_num = f8
 DECLARE new_nbr = f8
 DECLARE new_charge_mod_id = f8
 DECLARE 13019_billcode_cd = f8
 DECLARE 14002_icd9_cd = f8
 DECLARE 14002_proccode_cd = f8
 DECLARE diagcnt = i4 WITH noconstant(0)
 IF ( NOT (validate(interfaced_through_service)))
  DECLARE interfaced_through_service = i4 WITH protect, constant(1)
 ENDIF
 SET from_server = 0
 SET no_cdm_desc = fillstring(60," ")
 SET no_cpt_desc = fillstring(60," ")
 SET no_fin_desc = fillstring(60," ")
 SET inactive_file_desc = fillstring(60," ")
 SET reply_count = 0
 SET susp_charge_count = 0
 SET counter = 0
 SET charge_count = 0
 SET num_charges = 0
 SET num_files = 0
 SET ifiles = 0
 SET new_batch_num = 0.0
 SET got_fin_nbr = 0
 SET max_rows = 500
 SET codeset = 13030
 SET cdf_meaning = "NOCDM"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,no_cdm_cd)
 CALL echo(build("the no cdm code value is: ",no_cdm_cd))
 IF (no_cdm_cd IN (0.0, null))
  CALL echo("no_cdm_cd IS NULL")
  GO TO end_program
 ENDIF
 SET no_cdm_desc = uar_get_code_description(no_cdm_cd)
 CALL echo(build("the no cdm desc is: ",no_cdm_desc))
 SET codeset = 13030
 SET cdf_meaning = "NOCPT4"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,no_cpt_cd)
 CALL echo(build("the no cpt code value is: ",no_cpt_cd))
 IF (no_cpt_cd IN (0.0, null))
  CALL echo("no_cpt_cd IS NULL")
  GO TO end_program
 ENDIF
 SET no_cpt_desc = uar_get_code_description(no_cpt_cd)
 CALL echo(build("the no cpt desc is: ",no_cpt_desc))
 SET codeset = 13030
 SET cdf_meaning = "NOREV"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,no_rev_cd)
 CALL echo(build("the no rev code value is: ",no_rev_cd))
 IF (no_rev_cd IN (0.0, null))
  CALL echo("no_rev_cd IS NULL")
  GO TO end_program
 ENDIF
 SET no_rev_desc = uar_get_code_description(no_rev_cd)
 CALL echo(build("the no rev desc is: ",no_rev_desc))
 SET codeset = 13030
 SET cdf_meaning = "NOFIN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,no_fin_cd)
 CALL echo(build("the no fin code value is: ",no_fin_cd))
 IF (no_fin_cd IN (0.0, null))
  CALL echo("no_fin_cd IS NULL")
  GO TO end_program
 ENDIF
 SET no_fin_desc = uar_get_code_description(no_fin_cd)
 CALL echo(build("the no fin desc is: ",no_fin_desc))
 SET codeset = 13030
 SET cdf_meaning = "NOINTERFACE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,inactive_file_cd)
 CALL echo(build("the inactive interface file code value is: ",inactive_file_cd))
 IF (inactive_file_cd IN (0.0, null))
  CALL echo("inactive_file_cd IS NULL")
  GO TO end_program
 ENDIF
 SET inactive_file_desc = uar_get_code_description(inactive_file_cd)
 CALL echo(build("the inactive interface file desc is: ",inactive_file_desc))
 SET codeset = 13028
 SET cdf_meaning = "NO CHARGE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,nocharge_cd)
 CALL echo(build("the no charge code value is: ",nocharge_cd))
 IF (nocharge_cd IN (0.0, null))
  CALL echo("nocharge_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 106
 SET cdf_meaning = "PHARMACY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,pharm_cd)
 CALL echo(build("the pharmacy code value is: ",pharm_cd))
 IF (pharm_cd IN (0.0, null))
  CALL echo("pharm_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 14002
 SET cdf_meaning = "ALL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,all_cd)
 CALL echo(build("the all code value is: ",all_cd))
 IF (all_cd IN (0.0, null))
  CALL echo("all_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 25632
 SET cdf_meaning = "AFC_POST_INT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,object_name_cd)
 CALL echo(build("the AFC_POST_INT code value is: ",object_name_cd))
 SET csops_request2->job_name_cd = object_name_cd
 IF (object_name_cd IN (0.0, null))
  CALL echo("object_name_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,credit_cd)
 CALL echo(build("the credit_cd code value is: ",credit_cd))
 IF (credit_cd IN (0.0, null))
  CALL echo("credit_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,debit_cd)
 CALL echo(build("the debit_cd code value is: ",debit_cd))
 IF (debit_cd IN (0.0, null))
  CALL echo("debit_cd IS NULL")
  GO TO end_program
 ENDIF
 DECLARE bill_code = f8
 SET cnt = 1
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,bill_code)
 CALL echo(build("BILL_CODE: ",bill_code))
 IF (bill_code IN (0.0, null))
  CALL echo("bill_cd IS NULL")
  GO TO end_program
 ENDIF
 DECLARE 13019_mrn_nbr_alias = f8
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("MRNALIAS"),1,13019_mrn_nbr_alias)
 CALL echo(build("the mrn_nbr_alias_cd is : ",13019_mrn_nbr_alias))
 IF (13019_mrn_nbr_alias IN (0.0, null))
  CALL echo("13019_MRN_NBR_ALIAS IS NULL")
  GO TO end_program
 ENDIF
 DECLARE 14002_combine = f8
 SET stat = uar_get_meaning_by_codeset(14002,nullterm("COMBINE"),1,14002_combine)
 CALL echo(build("the combine_cd is : ",14002_combine))
 IF (14002_combine IN (0.0, null))
  CALL echo("14002_COMBINE IS NULL")
  GO TO end_program
 ENDIF
 DECLARE 13019_fin_nbr_alias = f8
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("FINNBRALIAS"),1,13019_fin_nbr_alias)
 CALL echo(build("the 13019_FIN_NBR_ALIAS_CD is : ",13019_fin_nbr_alias))
 IF (13019_fin_nbr_alias IN (0.0, null))
  CALL echo("13019_FIN_NBR_ALIAS IS NULL")
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs23369_wfevent)))
  DECLARE cs23369_wfevent = f8 WITH protect, constant(uar_get_code_by("MEANING",23369,"WFEVENT"))
 ENDIF
 IF ( NOT (validate(cs24454_chrgitemid)))
  DECLARE cs24454_chrgitemid = f8 WITH protect, constant(uar_get_code_by("MEANING",24454,"CHRGITEMID"
    ))
 ENDIF
 IF ( NOT (validate(cs24454_svcbasedind)))
  DECLARE cs24454_svcbasedind = f8 WITH protect, constant(uar_get_code_by("MEANING",24454,
    "SVCBASEDIND"))
 ENDIF
 IF ( NOT (validate(cs29322_chargecreated_event)))
  DECLARE cs29322_chargecreated_event = f8 WITH protect, constant(uar_get_code_by("MEANING",29322,
    "CHRGCREATED"))
 ENDIF
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,13019_billcode_cd)
 SET codeset = 14002
 SET cdf_meaning = "ICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,14002_icd9_cd)
 SET codeset = 14002
 SET cdf_meaning = "PROCCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,14002_proccode_cd)
 FREE SET cdm_codes
 RECORD cdm_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 DECLARE lcvcount = i4
 DECLARE codevalue = f8
 DECLARE total_remaining = i4
 DECLARE start_index = i4
 DECLARE occurances = i4
 DECLARE meaningval = c12
 SET meaningval = "CDM_SCHED"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(cdm_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET cdm_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(cdm_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET cpt_codes
 RECORD cpt_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "CPT4"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(cpt_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET cpt_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(cpt_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET rev_codes
 RECORD rev_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "REVENUE"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(rev_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET rev_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(rev_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET icd9_codes
 RECORD icd9_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "PROCCODE"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(icd9_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET icd9_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(icd9_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET icd9diag_codes
 RECORD icd9diag_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "ICD9"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(icd9diag_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET icd9diag_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(icd9diag_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET mod_codes
 RECORD mod_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "MODIFIER"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(mod_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET mod_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(mod_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 FREE SET hcpcs_codes
 RECORD hcpcs_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET meaningval = "HCPCS"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(hcpcs_codes->code_vals,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET hcpcs_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(hcpcs_codes)
 ELSE
  CALL echo("Failure.")
 ENDIF
 SET codeset = 320
 SET cdf_meaning = "DOCUPIN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,docupin_cd)
 CALL echo(build("the code value is: ",docupin_cd))
 IF (docupin_cd IN (0.0, null))
  CALL echo("docupin_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 320
 SET cdf_meaning = "DOCNBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,docnbr_cd)
 CALL echo(build("the code value is: ",docnbr_cd))
 IF (docnbr_cd IN (0.0, null))
  CALL echo("docnbr_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,bill_code_cd)
 CALL echo(build("the code value is: ",bill_code_cd))
 IF (bill_code_cd IN (0.0, null))
  CALL echo("bill_code_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,fin_num_cd)
 CALL echo(build("the code value is: ",fin_num_cd))
 IF (fin_num_cd IN (0.0, null))
  CALL echo("fin_num_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 327
 SET cdf_meaning = "EFF"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,eff_cd)
 CALL echo(build("the EFF code is : ",eff_cd))
 IF (eff_cd IN (0.0, null))
  CALL echo("eff_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 327
 SET cdf_meaning = "DEL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,del_cd)
 CALL echo(build("the DEL code is : ",del_cd))
 IF (del_cd IN (0.0, null))
  CALL echo("del_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 333
 SET cdf_meaning = "ADMITDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,admit_dr_cd)
 CALL echo(build("the code value is: ",admit_dr_cd))
 IF (admit_dr_cd IN (0.0, null))
  CALL echo("admit_dr_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 333
 SET cdf_meaning = "ATTENDDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,attend_dr_cd)
 CALL echo(build("the code value is: ",attend_dr_cd))
 IF (attend_dr_cd IN (0.0, null))
  CALL echo("attend_dr_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 333
 SET cdf_meaning = "REFERDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,refer_dr_cd)
 CALL echo(build("the code value is: ",refer_dr_cd))
 IF (refer_dr_cd IN (0.0, null))
  CALL echo("refer_dr_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 319
 SET cdf_meaning = "MRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,med_rec_num_cd)
 CALL echo(build("the code value is: ",med_rec_num_cd))
 IF (med_rec_num_cd IN (0.0, null))
  CALL echo("med_rec_num_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 13019
 SET cdf_meaning = "USER DEF"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,user_def_cd)
 CALL echo(build("the user def code is : ",user_def_cd))
 IF (user_def_cd IN (0.0, null))
  CALL echo("user_def_cd IS NULL")
  GO TO end_program
 ENDIF
 SET codeset = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,susp_cd)
 CALL echo(build("the code value is: ",susp_cd))
 IF (susp_cd IN (0.0, null))
  CALL echo("susp_cd IS NULL")
  GO TO end_program
 ENDIF
 IF ((validate(request->interface_charge[1].charge_item_id,- (999)) != - (999)))
  SET from_server = 1
  CALL echo("From Server!!!")
 ENDIF
 SET new_batch_num = 0.0
 SELECT INTO "nl:"
  batch_seq_num = seq(batch_num_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_batch_num = cnvtreal(batch_seq_num)
  WITH format, counter
 ;end select
 CALL echo(build("New Batch num: ",new_batch_num))
 SET csops_request2->batch_num = new_batch_num
 IF (from_server=1)
  CALL echo("defining realtime reply")
  IF ( NOT (validate(reply->workflow_task_name)))
   FREE RECORD reply
   RECORD reply(
     1 interface_charge[*]
       2 abn_status_cd = f8
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 activity_type_cd = f8
       2 additional_encntr_phys1_id = f8
       2 additional_encntr_phys2_id = f8
       2 additional_encntr_phys3_id = f8
       2 admit_type_cd = f8
       2 adm_phys_id = f8
       2 attending_phys_id = f8
       2 batch_num = f8
       2 bed_cd = f8
       2 beg_effective_dt_tm = dq8
       2 bill_code1 = c50
       2 bill_code1_desc = c200
       2 bill_code2 = c50
       2 bill_code2_desc = c200
       2 bill_code3 = c50
       2 bill_code3_desc = c200
       2 bill_code_more_ind = i2
       2 bill_code_type_cdf = c12
       2 building_cd = f8
       2 charge_description = c200
       2 charge_item_id = f8
       2 charge_type_cd = f8
       2 code_modifier1_cd = f8
       2 code_modifier2_cd = f8
       2 code_modifier3_cd = f8
       2 code_modifier_more_ind = i2
       2 code_revenue_cd = f8
       2 code_revenue_more_ind = i2
       2 cost_center_cd = f8
       2 department_cd = f8
       2 diag_code1 = c50
       2 diag_code2 = c50
       2 diag_code3 = c50
       2 diag_desc1 = c200
       2 diag_desc2 = c200
       2 diag_desc3 = c200
       2 diag_more_ind = i2
       2 discount_amount = f8
       2 encntr_id = f8
       2 encntr_type_cd = f8
       2 end_effective_dt_tm = dq8
       2 facility_cd = f8
       2 fin_nbr = c50
       2 fin_nbr_type_flg = i4
       2 gross_price = f8
       2 icd9_proc_more_ind = i2
       2 institution_cd = f8
       2 interface_charge_id = f8
       2 interface_file_id = f8
       2 level5_cd = f8
       2 manual_ind = i2
       2 med_nbr = c50
       2 med_service_cd = f8
       2 net_ext_price = f8
       2 nurse_unit_cd = f8
       2 order_dept = i4
       2 order_nbr = c200
       2 ord_doc_nbr = c20
       2 ord_phys_id = f8
       2 organization_id = f8
       2 override_desc = c200
       2 payor_id = f8
       2 perf_loc_cd = f8
       2 perf_phys_id = f8
       2 person_id = f8
       2 person_name = c100
       2 posted_dt_tm = dq8
       2 price = f8
       2 prim_cdm = c50
       2 prim_cdm_desc = c200
       2 prim_cpt = c50
       2 prim_cpt_desc = c200
       2 prim_icd9_proc = c50
       2 prim_icd9_proc_desc = c200
       2 process_flg = i4
       2 quantity = f8
       2 referring_phys_id = f8
       2 room_cd = f8
       2 section_cd = f8
       2 service_dt_tm = dq8
       2 subsection_cd = f8
       2 updt_applctx = i4
       2 updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_task = i4
       2 user_def_ind = i2
       2 ndc_ident = c40
       2 prim_icd9_proc_nomen_id = f8
       2 bill_code1_nomen_id = f8
       2 bill_code2_nomen_id = f8
       2 bill_code3_nomen_id = f8
       2 icd_diag_info[*]
         3 nomen_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
  ENDIF
  SET reply->status_data.status = "Z"
  CALL get_realtime_charge_info(0)
  CALL check_suspense(0)
  CALL add_extra_charge_info(0)
  CALL get_qcf(0)
  CALL dump_request(0)
  CALL write_charges(0)
  CALL write_suspense_mods(0)
  CALL update_charges(0)
  CALL echo("committing realtime charges")
  COMMIT
  CALL fill_out_reply(0)
  CALL dump_reply(0)
  CALL publishpftchargeevent(post_request)
  CALL publishchargecreatedevent(post_request)
  CALL updateserviceinterfaceflag(post_request)
  IF (size(reply->interface_charge,5) > 0)
   EXECUTE afc_hl7_realtime_interface  WITH replace("REPLY",reply)
  ENDIF
 ELSE
  CALL echo("defining reply to ops")
  CALL echo("*********************************************************")
  FREE SET reply
  RECORD reply(
    1 t01_qual = i2
    1 t01_recs[*]
      2 t01_id = f8
      2 t01_charge_item_id = f8
      2 t01_interfaced = c1
    1 page_count = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET reply->status_data.status = "Z"
  CALL get_interface_files(0)
  CALL get_charge_info(0)
 ENDIF
 SUBROUTINE get_realtime_charge_info(aa)
   CALL echo("getting realtime charge info...")
   SET num_reals = 0
   SELECT INTO "nl:"
    FROM charge c,
     (dummyt d1  WITH seq = value(size(request->interface_charge,5)))
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_item_id=request->interface_charge[d1.seq].charge_item_id)
      AND ((c.active_ind+ 0)=true)
      AND c.process_flg=0
      AND  NOT ( EXISTS (
     (SELECT
      i.charge_item_id
      FROM interface_charge i
      WHERE i.charge_item_id=c.charge_item_id
       AND i.active_ind=1))))
    DETAIL
     num_reals += 1, stat = alterlist(post_request->charge,num_reals), post_request->charge[num_reals
     ].abn_status_cd = c.abn_status_cd,
     post_request->charge[num_reals].active_ind = c.active_ind, post_request->charge[num_reals].
     active_status_cd = c.active_status_cd, post_request->charge[num_reals].active_status_dt_tm = c
     .active_status_dt_tm,
     post_request->charge[num_reals].active_status_prsnl_id = c.active_status_prsnl_id, post_request
     ->charge[num_reals].activity_type_cd = c.activity_type_cd, post_request->charge[num_reals].
     admit_type_cd = c.admit_type_cd,
     post_request->charge[num_reals].beg_effective_dt_tm = c.beg_effective_dt_tm, post_request->
     charge[num_reals].charge_description = c.charge_description, post_request->charge[num_reals].
     charge_item_id = c.charge_item_id,
     post_request->charge[num_reals].charge_event_id = c.charge_event_id, post_request->charge[
     num_reals].charge_type_cd = c.charge_type_cd, post_request->charge[num_reals].cost_center_cd = c
     .cost_center_cd,
     post_request->charge[num_reals].department_cd = c.department_cd, post_request->charge[num_reals]
     .discount_amount = c.discount_amount, post_request->charge[num_reals].encntr_id = c.encntr_id,
     post_request->charge[num_reals].encntr_type_cd = c.admit_type_cd, post_request->charge[num_reals
     ].end_effective_dt_tm = c.end_effective_dt_tm, post_request->charge[num_reals].gross_price = c
     .gross_price,
     post_request->charge[num_reals].institution_cd = c.institution_cd, post_request->charge[
     num_reals].inst_fin_nbr = c.inst_fin_nbr, post_request->charge[num_reals].interface_file_id = c
     .interface_file_id,
     post_request->charge[num_reals].item_extended_price = c.item_extended_price, post_request->
     charge[num_reals].item_price = c.item_price, post_request->charge[num_reals].item_quantity = c
     .item_quantity,
     post_request->charge[num_reals].level5_cd = c.level5_cd, post_request->charge[num_reals].
     manual_ind = c.manual_ind, post_request->charge[num_reals].med_service_cd = c.med_service_cd,
     post_request->charge[num_reals].order_id = c.order_id, post_request->charge[num_reals].
     ord_phys_id = c.ord_phys_id, post_request->charge[num_reals].payor_id = c.payor_id,
     post_request->charge[num_reals].perf_loc_cd = c.perf_loc_cd, post_request->charge[num_reals].
     perf_phys_id = c.perf_phys_id, post_request->charge[num_reals].person_id = c.person_id,
     post_request->charge[num_reals].posted_dt_tm = c.posted_dt_tm, post_request->charge[num_reals].
     research_acct_id = c.research_acct_id, post_request->charge[num_reals].section_cd = c.section_cd,
     post_request->charge[num_reals].service_dt_tm = c.service_dt_tm, post_request->charge[num_reals]
     .subsection_cd = c.subsection_cd, post_request->charge[num_reals].updt_id = c.updt_id,
     post_request->charge[num_reals].verify_phys_id = c.verify_phys_id, post_request->charge[
     num_reals].pharm_nocharge_ind = 0, post_request->charge[num_reals].perf_phys_cont_ind = 0
     IF ((post_request->charge[num_reals].charge_type_cd=nocharge_cd)
      AND (post_request->charge[num_reals].activity_type_cd=pharm_cd))
      post_request->charge[num_reals].pharm_nocharge_ind = 1
     ENDIF
     post_request->charge[num_reals].susp_for_missing_fin_ind = 0, post_request->charge[num_reals].
     dont_susp_for_fin_ind = 0, post_request->charge[num_reals].susp_for_missing_cdm_ind = 0,
     post_request->charge[num_reals].susp_for_missing_cpt_ind = 0, post_request->charge[num_reals].
     susp_for_missing_if_ind = 0, post_request->charge[num_reals].missing_cpt_cd = 0,
     post_request->charge[num_reals].missing_cdm_cd = 0, post_request->charge[num_reals].
     missing_rev_cd = 0, post_request->charge[num_reals].explode_ind = 0,
     post_request->charge[num_reals].doc_nbr_cd = 0, post_request->charge[num_reals].
     mult_bill_code_sched_cd = 0, post_request->charge[num_reals].additional_encntr_phys1_id = 0,
     post_request->charge[num_reals].additional_encntr_phys2_id = 0, post_request->charge[num_reals].
     additional_encntr_phys3_id = 0, post_request->charge[num_reals].adm_phys_id = 0,
     post_request->charge[num_reals].attending_phys_id = 0, post_request->charge[num_reals].batch_num
      = new_batch_num, post_request->charge[num_reals].bed_cd = 0,
     post_request->charge[num_reals].bill_code1 = fillstring(50," "), post_request->charge[num_reals]
     .bill_code1_desc = fillstring(200," "), post_request->charge[num_reals].bill_code2 = fillstring(
      50," "),
     post_request->charge[num_reals].bill_code2_desc = fillstring(200," "), post_request->charge[
     num_reals].bill_code3 = fillstring(50," "), post_request->charge[num_reals].bill_code3_desc =
     fillstring(200," "),
     post_request->charge[num_reals].bill_code_more_ind = 0, post_request->charge[num_reals].
     bill_code_type_cdf = fillstring(12," "), post_request->charge[num_reals].building_cd = 0,
     post_request->charge[num_reals].code_modifier1_cd = 0, post_request->charge[num_reals].
     code_modifier2_cd = 0, post_request->charge[num_reals].code_modifier3_cd = 0,
     post_request->charge[num_reals].code_modifier_more_ind = 0, post_request->charge[num_reals].
     code_revenue_cd = 0, post_request->charge[num_reals].code_revenue_more_ind = 0,
     post_request->charge[num_reals].diag_code1 = fillstring(50," "), post_request->charge[num_reals]
     .diag_desc1 = fillstring(200," "), post_request->charge[num_reals].diag_code2 = fillstring(50,
      " "),
     post_request->charge[num_reals].diag_desc2 = fillstring(200," "), post_request->charge[num_reals
     ].diag_code3 = fillstring(50," "), post_request->charge[num_reals].diag_desc3 = fillstring(200,
      " "),
     post_request->charge[num_reals].diag_more_ind = 0, post_request->charge[num_reals].facility_cd
      = 0, post_request->charge[num_reals].fin_nbr = fillstring(50," "),
     post_request->charge[num_reals].fin_nbr_type_flg = 0, post_request->charge[num_reals].
     icd9_proc_more_ind = 0, post_request->charge[num_reals].interface_charge_id = 0,
     post_request->charge[num_reals].med_nbr = fillstring(50," "), post_request->charge[num_reals].
     net_ext_price = 0, post_request->charge[num_reals].nurse_unit_cd = 0,
     post_request->charge[num_reals].order_dept = 0, post_request->charge[num_reals].order_nbr =
     fillstring(200," "), post_request->charge[num_reals].ord_doc_nbr = fillstring(20," "),
     post_request->charge[num_reals].organization_id = 0, post_request->charge[num_reals].
     override_desc = fillstring(200," "), post_request->charge[num_reals].person_name = fillstring(
      100," "),
     post_request->charge[num_reals].price = 0, post_request->charge[num_reals].prim_cdm = fillstring
     (50," "), post_request->charge[num_reals].prim_cdm_desc = fillstring(200," "),
     post_request->charge[num_reals].prim_cpt = fillstring(50," "), post_request->charge[num_reals].
     prim_cpt_desc = fillstring(200," "), post_request->charge[num_reals].prim_icd9_proc = fillstring
     (50," "),
     post_request->charge[num_reals].prim_icd9_proc_desc = fillstring(200," "), post_request->charge[
     num_reals].process_flg = 0, post_request->charge[num_reals].referring_phys_id = 0,
     post_request->charge[num_reals].room_cd = 0, post_request->charge[num_reals].user_def_ind = 0,
     post_request->charge[num_reals].location_found = 0,
     post_request->charge[num_reals].found_fin_nbr = 0, post_request->charge_qual = num_reals,
     post_request->charge[num_reals].service_based_ind = 0
    WITH nocounter, forupdate(c)
   ;end select
   CALL echo(build("found:"," ",post_request->charge_qual," realtime charges"))
   CALL echorecord(post_request)
   IF (num_reals > 0)
    CALL update_pharm_nocharge_charges(0)
    SELECT INTO "nl:"
     FROM interface_file i,
      (dummyt d1  WITH seq = value(size(post_request->charge,5)))
     PLAN (d1)
      JOIN (i
      WHERE (i.interface_file_id=post_request->charge[d1.seq].interface_file_id))
     DETAIL
      IF (i.active_ind=0)
       post_request->charge[d1.seq].susp_for_missing_if_ind = 1
      ELSE
       IF (validate(i.service_based_ind,0)=1)
        post_request->charge[d1.seq].service_based_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET reply->status_data.status = "S"
   ELSE
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE get_interface_files(jj)
   CALL echo("getting active interface files")
   SET num_files = 0
   SELECT INTO "nl"
    FROM interface_file i
    WHERE i.file_name != "CLIENTBILL"
     AND i.interface_file_id > 0
     AND i.active_ind=1
     AND i.profit_type_cd=0
     AND i.logical_domain_id=curlogicaldomainid
    DETAIL
     num_files += 1, stat = alterlist(interface_files->files,num_files), interface_files->files[
     num_files].interface_file_id = i.interface_file_id,
     interface_files->file_qual = num_files, interface_files->files[num_files].realtime_ind = i
     .realtime_ind
    WITH nocounter
   ;end select
   CALL echo(build(num_files," interface files found"))
 END ;Subroutine
 SUBROUTINE get_charge_info(bb)
   CALL echo("Retrieving pending charges")
   FOR (ifiles = 1 TO interface_files->file_qual)
     CALL echo(build("processing: ",interface_files->files[ifiles].interface_file_id))
     SET finished = 0
     SET total_qty_credit = 0.0
     SET total_amt_credit = 0.0
     SET total_cnt_credit = 0
     SET total_qty_debit = 0.0
     SET total_amt_debit = 0.0
     SET total_cnt_debit = 0
     WHILE (finished=0)
       CALL echo("inside while")
       SET num_charges = 0
       SELECT INTO "nl"
        FROM charge c
        PLAN (c
         WHERE c.process_flg=0
          AND c.active_ind=1
          AND (((c.interface_file_id=interface_files->files[ifiles].interface_file_id)
          AND (interface_files->files[ifiles].realtime_ind=0)) OR ((c.interface_file_id=
         interface_files->files[ifiles].interface_file_id)
          AND (interface_files->files[ifiles].realtime_ind=1)
          AND c.combine_ind=1))
          AND c.beg_effective_dt_tm < cnvtdatetime(run_dt)
          AND  NOT ( EXISTS (
         (SELECT
          i.charge_item_id
          FROM interface_charge i
          WHERE i.charge_item_id=c.charge_item_id
           AND i.active_ind=1))))
        DETAIL
         num_charges += 1, stat = alterlist(post_request->charge,num_charges), post_request->charge[
         num_charges].abn_status_cd = c.abn_status_cd,
         post_request->charge[num_charges].active_ind = c.active_ind, post_request->charge[
         num_charges].active_status_cd = c.active_status_cd, post_request->charge[num_charges].
         active_status_dt_tm = c.active_status_dt_tm,
         post_request->charge[num_charges].active_status_prsnl_id = c.active_status_prsnl_id,
         post_request->charge[num_charges].activity_type_cd = c.activity_type_cd, post_request->
         charge[num_charges].admit_type_cd = c.admit_type_cd,
         post_request->charge[num_charges].beg_effective_dt_tm = c.beg_effective_dt_tm, post_request
         ->charge[num_charges].charge_description = c.charge_description, post_request->charge[
         num_charges].charge_item_id = c.charge_item_id,
         post_request->charge[num_charges].charge_event_id = c.charge_event_id, post_request->charge[
         num_charges].charge_type_cd = c.charge_type_cd, post_request->charge[num_charges].
         cost_center_cd = c.cost_center_cd,
         post_request->charge[num_charges].department_cd = c.department_cd, post_request->charge[
         num_charges].discount_amount = c.discount_amount, post_request->charge[num_charges].
         encntr_id = c.encntr_id,
         post_request->charge[num_charges].encntr_type_cd = c.admit_type_cd, post_request->charge[
         num_charges].end_effective_dt_tm = c.end_effective_dt_tm, post_request->charge[num_charges].
         gross_price = c.gross_price,
         post_request->charge[num_charges].institution_cd = c.institution_cd, post_request->charge[
         num_charges].inst_fin_nbr = c.inst_fin_nbr, post_request->charge[num_charges].
         interface_file_id = c.interface_file_id,
         post_request->charge[num_charges].item_extended_price = c.item_extended_price, post_request
         ->charge[num_charges].item_price = c.item_price, post_request->charge[num_charges].
         item_quantity = c.item_quantity,
         post_request->charge[num_charges].level5_cd = c.level5_cd, post_request->charge[num_charges]
         .manual_ind = c.manual_ind, post_request->charge[num_charges].med_service_cd = c
         .med_service_cd,
         post_request->charge[num_charges].order_id = c.order_id, post_request->charge[num_charges].
         ord_phys_id = c.ord_phys_id, post_request->charge[num_charges].payor_id = c.payor_id,
         post_request->charge[num_charges].perf_loc_cd = c.perf_loc_cd, post_request->charge[
         num_charges].perf_phys_id = c.perf_phys_id, post_request->charge[num_charges].person_id = c
         .person_id,
         post_request->charge[num_charges].posted_dt_tm = c.posted_dt_tm, post_request->charge[
         num_charges].research_acct_id = c.research_acct_id, post_request->charge[num_charges].
         section_cd = c.section_cd,
         post_request->charge[num_charges].service_dt_tm = c.service_dt_tm, post_request->charge[
         num_charges].subsection_cd = c.subsection_cd, post_request->charge[num_charges].updt_id = c
         .updt_id,
         post_request->charge[num_charges].verify_phys_id = c.verify_phys_id, post_request->charge[
         num_charges].pharm_nocharge_ind = 0, post_request->charge[num_charges].perf_phys_cont_ind =
         0,
         post_request->charge[num_charges].susp_for_missing_fin_ind = 0, post_request->charge[
         num_charges].dont_susp_for_fin_ind = 0, post_request->charge[num_charges].
         susp_for_missing_cdm_ind = 0,
         post_request->charge[num_charges].susp_for_missing_cpt_ind = 0, post_request->charge[
         num_charges].susp_for_missing_if_ind = 0, post_request->charge[num_charges].missing_cpt_cd
          = 0,
         post_request->charge[num_charges].missing_cdm_cd = 0, post_request->charge[num_charges].
         missing_rev_cd = 0, post_request->charge[num_charges].explode_ind = 0,
         post_request->charge[num_charges].doc_nbr_cd = 0, post_request->charge[num_charges].
         mult_bill_code_sched_cd = 0, post_request->charge[num_charges].additional_encntr_phys1_id =
         0,
         post_request->charge[num_charges].additional_encntr_phys2_id = 0, post_request->charge[
         num_charges].additional_encntr_phys3_id = 0, post_request->charge[num_charges].adm_phys_id
          = 0,
         post_request->charge[num_charges].attending_phys_id = 0, post_request->charge[num_charges].
         batch_num = new_batch_num, post_request->charge[num_charges].bed_cd = 0,
         post_request->charge[num_charges].bill_code1 = fillstring(50," "), post_request->charge[
         num_charges].bill_code1_desc = fillstring(200," "), post_request->charge[num_charges].
         bill_code2 = fillstring(50," "),
         post_request->charge[num_charges].bill_code2_desc = fillstring(200," "), post_request->
         charge[num_charges].bill_code3 = fillstring(50," "), post_request->charge[num_charges].
         bill_code3_desc = fillstring(200," "),
         post_request->charge[num_charges].bill_code_more_ind = 0, post_request->charge[num_charges].
         bill_code_type_cdf = fillstring(12," "), post_request->charge[num_charges].building_cd = 0,
         post_request->charge[num_charges].code_modifier1_cd = 0, post_request->charge[num_charges].
         code_modifier2_cd = 0, post_request->charge[num_charges].code_modifier3_cd = 0,
         post_request->charge[num_charges].code_modifier_more_ind = 0, post_request->charge[
         num_charges].code_revenue_cd = 0, post_request->charge[num_charges].code_revenue_more_ind =
         0,
         post_request->charge[num_charges].diag_code1 = fillstring(50," "), post_request->charge[
         num_charges].diag_desc1 = fillstring(200," "), post_request->charge[num_charges].diag_code2
          = fillstring(50," "),
         post_request->charge[num_charges].diag_desc2 = fillstring(200," "), post_request->charge[
         num_charges].diag_code3 = fillstring(50," "), post_request->charge[num_charges].diag_desc3
          = fillstring(200," "),
         post_request->charge[num_charges].diag_more_ind = 0, post_request->charge[num_charges].
         facility_cd = 0, post_request->charge[num_charges].fin_nbr = fillstring(50," "),
         post_request->charge[num_charges].fin_nbr_type_flg = 0, post_request->charge[num_charges].
         icd9_proc_more_ind = 0, post_request->charge[num_charges].interface_charge_id = 0,
         post_request->charge[num_charges].med_nbr = fillstring(50," "), post_request->charge[
         num_charges].net_ext_price = 0, post_request->charge[num_charges].nurse_unit_cd = 0,
         post_request->charge[num_charges].order_dept = 0, post_request->charge[num_charges].
         order_nbr = fillstring(200," "), post_request->charge[num_charges].ord_doc_nbr = fillstring(
          20," "),
         post_request->charge[num_charges].organization_id = 0, post_request->charge[num_charges].
         override_desc = fillstring(200," "), post_request->charge[num_charges].person_name =
         fillstring(100," "),
         post_request->charge[num_charges].price = 0, post_request->charge[num_charges].prim_cdm =
         fillstring(50," "), post_request->charge[num_charges].prim_cdm_desc = fillstring(200," "),
         post_request->charge[num_charges].prim_cpt = fillstring(50," "), post_request->charge[
         num_charges].prim_cpt_desc = fillstring(200," "), post_request->charge[num_charges].
         prim_icd9_proc = fillstring(50," "),
         post_request->charge[num_charges].prim_icd9_proc_desc = fillstring(200," "), post_request->
         charge[num_charges].process_flg = 0, post_request->charge[num_charges].referring_phys_id = 0,
         post_request->charge[num_charges].room_cd = 0, post_request->charge[num_charges].
         user_def_ind = 0
         IF ((post_request->charge[num_charges].charge_type_cd=nocharge_cd)
          AND (post_request->charge[num_charges].activity_type_cd=pharm_cd))
          post_request->charge[num_charges].pharm_nocharge_ind = 1
         ENDIF
         post_request->charge[num_charges].location_found = 0, post_request->charge[num_charges].
         found_fin_nbr = 0, post_request->charge[num_charges].ndc_ident = fillstring(40," "),
         post_request->charge_qual = num_charges
        WITH nocounter, maxqual(c,value(max_rows)), forupdatewait(c)
       ;end select
       CALL echo("outside detail")
       IF (num_charges < max_rows)
        CALL echo("********* Last Time ***********")
        SET finished = 1
       ENDIF
       IF (num_charges > 0)
        CALL update_pharm_nocharge_charges(0)
        CALL check_suspense(0)
        CALL add_extra_charge_info(0)
        CALL dump_request(0)
        CALL get_qcf(0)
        CALL write_charges(0)
        CALL write_suspense_mods(0)
        CALL update_charges(0)
        SET reply->status_data.status = "S"
       ENDIF
     ENDWHILE
   ENDFOR
   CALL dump_reply(0)
 END ;Subroutine
 SUBROUTINE update_pharm_nocharge_charges(cc)
  CALL echo("updating pharmacy no charge charges")
  UPDATE  FROM charge c,
    (dummyt d1  WITH seq = value(size(post_request->charge,5)))
   SET c.process_flg = 998, c.updt_dt_tm = cnvtdatetime(sysdate)
   PLAN (d1
    WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=1))
    JOIN (c
    WHERE (c.charge_item_id=post_request->charge[d1.seq].charge_item_id))
  ;end update
 END ;Subroutine
 SUBROUTINE check_suspense(ll)
   CALL echo("checking suspense")
   SELECT INTO "nl:"
    FROM interface_file i,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (i
     WHERE (i.interface_file_id=post_request->charge[d1.seq].interface_file_id))
    DETAIL
     IF (i.fin_nbr_suspend_ind=1)
      post_request->charge[d1.seq].susp_for_missing_fin_ind = 1
     ELSE
      post_request->charge[d1.seq].dont_susp_for_fin_ind = 1
     ENDIF
     IF (i.cdm_sched_cd=all_cd)
      post_request->charge[d1.seq].susp_for_missing_cdm_ind = 2
     ELSEIF (i.cdm_sched_cd > 0)
      post_request->charge[d1.seq].susp_for_missing_cdm_ind = 1, post_request->charge[d1.seq].
      missing_cdm_cd = i.cdm_sched_cd
     ELSE
      post_request->charge[d1.seq].susp_for_missing_cdm_ind = 0
     ENDIF
     IF (i.cpt_sched_cd=all_cd)
      post_request->charge[d1.seq].susp_for_missing_cpt_ind = 2
     ELSEIF (i.cpt_sched_cd > 0)
      post_request->charge[d1.seq].susp_for_missing_cpt_ind = 1, post_request->charge[d1.seq].
      missing_cpt_cd = i.cpt_sched_cd
     ELSE
      post_request->charge[d1.seq].susp_for_missing_cpt_ind = 0
     ENDIF
     IF (i.rev_sched_cd=all_cd)
      post_request->charge[d1.seq].susp_for_missing_rev_ind = 2
     ELSEIF (i.rev_sched_cd > 0)
      post_request->charge[d1.seq].susp_for_missing_rev_ind = 1, post_request->charge[d1.seq].
      missing_rev_cd = i.rev_sched_cd
     ELSE
      post_request->charge[d1.seq].susp_for_missing_rev_ind = 0
     ENDIF
     IF (i.explode_ind=1)
      post_request->charge[d1.seq].explode_ind = 1
     ENDIF
     post_request->charge[d1.seq].mult_bill_code_sched_cd = i.mult_bill_code_sched_cd
     IF (i.doc_nbr_cd=docupin_cd)
      post_request->charge[d1.seq].doc_nbr_cd = docupin_cd
     ELSE
      post_request->charge[d1.seq].doc_nbr_cd = docnbr_cd
     ENDIF
     post_request->charge[d1.seq].perf_phys_cont_ind = i.perf_phys_cont_ind
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6, cm.field7
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(cdm_codes->code_vals,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.active_ind=1
      AND cm.charge_mod_type_cd=bill_code_cd)
     JOIN (d2
     WHERE (cdm_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF ((post_request->charge[d1.seq].susp_for_missing_cdm_ind=2))
      IF (cm.field2_id=1
       AND cm.field1_id > 0
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cdm = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cdm_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cdm_ind = 0
      ENDIF
     ELSEIF ((post_request->charge[d1.seq].susp_for_missing_cdm_ind=1))
      IF (cm.field2_id=1
       AND (cm.field1_id=post_request->charge[d1.seq].missing_cdm_cd)
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cdm = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cdm_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cdm_ind = 0
      ENDIF
     ELSE
      IF (cm.field2_id=1
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cdm = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cdm_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cdm_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6, cm.field7
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(cpt_codes->code_vals,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.active_ind=1
      AND cm.charge_mod_type_cd=bill_code_cd)
     JOIN (d2
     WHERE (cpt_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF ((post_request->charge[d1.seq].susp_for_missing_cpt_ind=2))
      IF (cm.field2_id=1
       AND cm.field1_id > 0
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cpt = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cpt_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cpt_ind = 0
      ENDIF
     ELSEIF ((post_request->charge[d1.seq].susp_for_missing_cpt_ind=1))
      IF (cm.field2_id=1
       AND (cm.field1_id=post_request->charge[d1.seq].missing_cpt_cd)
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cpt = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cpt_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cpt_ind = 0
      ENDIF
     ELSE
      IF (cm.field2_id=1
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].prim_cpt = trim(cm.field6,3), post_request->charge[d1.seq].
       prim_cpt_desc = trim(cm.field7,3), post_request->charge[d1.seq].susp_for_missing_cpt_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field3_id
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(rev_codes->code_vals,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=bill_code_cd
      AND cm.active_ind=1)
     JOIN (d2
     WHERE (rev_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF ((post_request->charge[d1.seq].susp_for_missing_rev_ind=2))
      IF (cm.field2_id=1
       AND cm.field1_id > 0
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].code_revenue_cd = cm.field3_id, post_request->charge[d1.seq].
       susp_for_missing_rev_ind = 0
      ENDIF
     ELSEIF ((post_request->charge[d1.seq].susp_for_missing_rev_ind=1))
      IF (cm.field2_id=1
       AND (cm.field1_id=post_request->charge[d1.seq].missing_rev_cd)
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].code_revenue_cd = cm.field3_id, post_request->charge[d1.seq].
       susp_for_missing_rev_ind = 0
      ENDIF
     ELSE
      IF (cm.field2_id=1
       AND trim(cm.field6) != "")
       post_request->charge[d1.seq].code_revenue_cd = cm.field3_id, post_request->charge[d1.seq].
       susp_for_missing_rev_ind = 0
      ENDIF
     ENDIF
     IF (cm.field2_id > 1
      AND cm.field1_id > 0)
      post_request->charge[d1.seq].code_revenue_cd = cm.field3_id, post_request->charge[d1.seq].
      code_revenue_more_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cem.field6, cem.field7
    FROM charge_event_mod cem,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(cdm_codes->code_vals,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0)
      AND uar_get_code_meaning(post_request->charge[d1.seq].activity_type_cd)="PHARMACY")
     JOIN (cem
     WHERE (cem.charge_event_id=post_request->charge[d1.seq].charge_event_id)
      AND cem.active_ind=1
      AND cem.charge_event_mod_type_cd=bill_code_cd)
     JOIN (d2
     WHERE (cdm_codes->code_vals[d2.seq].code_val=cem.field1_id))
    DETAIL
     post_request->charge[d1.seq].ndc_ident = trim(cem.field7,3)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cem.field6, cem.field7
    FROM charge_event_mod cem,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(cdm_codes->code_vals,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0)
      AND uar_get_code_meaning(post_request->charge[d1.seq].activity_type_cd)="PHARMACY"
      AND (post_request->charge[d1.seq].charge_type_cd=credit_cd)
      AND trim(post_request->charge[d1.seq].ndc_ident,3)="")
     JOIN (cem
     WHERE (cem.charge_event_id=post_request->charge[d1.seq].charge_event_id)
      AND cem.active_ind=0
      AND cem.charge_event_mod_type_cd=bill_code_cd)
     JOIN (d2
     WHERE (cdm_codes->code_vals[d2.seq].code_val=cem.field1_id))
    ORDER BY cem.charge_event_mod_id
    HEAD cem.charge_event_mod_id
     post_request->charge[d1.seq].ndc_ident = trim(cem.field7,3)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    r.account_nbr
    FROM research_account r,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (r
     WHERE (r.research_account_id=post_request->charge[d1.seq].research_acct_id)
      AND r.active_ind=1
      AND r.research_account_id != 0)
    DETAIL
     IF (r.account_nbr > " ")
      post_request->charge[d1.seq].fin_nbr = r.account_nbr, post_request->charge[d1.seq].
      fin_nbr_type_flg = 3, post_request->charge[d1.seq].susp_for_missing_fin_ind = 0,
      post_request->charge[d1.seq].found_fin_nbr = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=1)) OR ((post_request->charge[d1
    .seq].dont_susp_for_fin_ind=1)
     AND (post_request->charge[d1.seq].found_fin_nbr=0)))
     AND (post_request->charge[d1.seq].inst_fin_nbr > " ")
     AND (post_request->charge[d1.seq].pharm_nocharge_ind=0)
    DETAIL
     post_request->charge[d1.seq].fin_nbr = post_request->charge[d1.seq].inst_fin_nbr, post_request->
     charge[d1.seq].fin_nbr_type_flg = 2, post_request->charge[d1.seq].susp_for_missing_fin_ind = 0,
     post_request->charge[d1.seq].found_fin_nbr = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ea.alias
    FROM encntr_alias ea,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=1)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)
      AND (post_request->charge[d1.seq].found_fin_nbr=0)))
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (ea
     WHERE (ea.encntr_id=post_request->charge[d1.seq].encntr_id)
      AND ea.encntr_alias_type_cd=fin_num_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     post_request->charge[d1.seq].fin_nbr = ea.alias, post_request->charge[d1.seq].fin_nbr_type_flg
      = 1, post_request->charge[d1.seq].susp_for_missing_fin_ind = 0,
     post_request->charge[d1.seq].found_fin_nbr = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=1)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)
      AND (post_request->charge[d1.seq].found_fin_nbr=0)))
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=14002_combine
      AND cm.field1_id=13019_fin_nbr_alias)
    DETAIL
     post_request->charge[d1.seq].fin_nbr = cm.field6, post_request->charge[d1.seq].fin_nbr_type_flg
      = 1, post_request->charge[d1.seq].susp_for_missing_fin_ind = 0,
     post_request->charge[d1.seq].found_fin_nbr = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE add_extra_charge_info(ee)
   CALL echo("adding extra charge info...")
   SELECT INTO "nl:"
    epr.prsnl_person_id
    FROM (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     encounter e,
     encntr_prsnl_reltn epr
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (e
     WHERE (e.encntr_id=post_request->charge[d1.seq].encntr_id))
     JOIN (epr
     WHERE epr.encntr_prsnl_r_cd IN (admit_dr_cd, attend_dr_cd, refer_dr_cd)
      AND epr.encntr_id=e.encntr_id
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm < cnvtdatetime(post_request->charge[d1.seq].service_dt_tm)
      AND epr.end_effective_dt_tm > cnvtdatetime(post_request->charge[d1.seq].service_dt_tm))
    DETAIL
     IF (epr.encntr_prsnl_r_cd=admit_dr_cd)
      post_request->charge[d1.seq].adm_phys_id = epr.prsnl_person_id
     ELSEIF (epr.encntr_prsnl_r_cd=attend_dr_cd)
      post_request->charge[d1.seq].attending_phys_id = epr.prsnl_person_id
     ELSE
      post_request->charge[d1.seq].referring_phys_id = epr.prsnl_person_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
    e.loc_room_cd, e.loc_bed_cd
    FROM encntr_loc_hist e,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (e
     WHERE (e.encntr_id=post_request->charge[d1.seq].encntr_id)
      AND e.active_ind=1
      AND e.beg_effective_dt_tm < cnvtdatetime(post_request->charge[d1.seq].service_dt_tm)
      AND e.end_effective_dt_tm > cnvtdatetime(post_request->charge[d1.seq].service_dt_tm))
    DETAIL
     post_request->charge[d1.seq].facility_cd = e.loc_facility_cd, post_request->charge[d1.seq].
     building_cd = e.loc_building_cd, post_request->charge[d1.seq].nurse_unit_cd = e
     .loc_nurse_unit_cd,
     post_request->charge[d1.seq].room_cd = e.loc_room_cd, post_request->charge[d1.seq].bed_cd = e
     .loc_bed_cd, post_request->charge[d1.seq].location_found = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
    e.loc_room_cd, e.loc_bed_cd
    FROM encounter e,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0)
      AND (post_request->charge[d1.seq].location_found=0))
     JOIN (e
     WHERE (e.encntr_id=post_request->charge[d1.seq].encntr_id))
    DETAIL
     post_request->charge[d1.seq].facility_cd = e.loc_facility_cd, post_request->charge[d1.seq].
     building_cd = e.loc_building_cd, post_request->charge[d1.seq].nurse_unit_cd = e
     .loc_nurse_unit_cd,
     post_request->charge[d1.seq].room_cd = e.loc_room_cd, post_request->charge[d1.seq].bed_cd = e
     .loc_bed_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6, cm.field7
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(icd9_codes->code_vals,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.active_ind=1
      AND cm.charge_mod_type_cd=bill_code_cd)
     JOIN (d2
     WHERE (icd9_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF (cm.field2_id=1)
      post_request->charge[d1.seq].prim_icd9_proc = trim(cm.field6,3), post_request->charge[d1.seq].
      prim_icd9_proc_desc = trim(cm.field7,3)
     ELSEIF (cm.field2_id > 1)
      post_request->charge[d1.seq].icd9_proc_more_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6, cm.field7
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     code_value cv
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=bill_code_cd
      AND cm.active_ind=1
      AND (cm.field1_id=post_request->charge[d1.seq].mult_bill_code_sched_cd))
     JOIN (cv
     WHERE cv.code_value=cm.field1_id
      AND cv.active_ind=1
      AND cv.code_set=14002)
    DETAIL
     post_request->charge[d1.seq].bill_code_type_cdf = cv.cdf_meaning
     IF (cm.field2_id=2)
      post_request->charge[d1.seq].bill_code1 = trim(cm.field6,3), post_request->charge[d1.seq].
      bill_code1_desc = trim(cm.field7,3)
     ELSEIF (cm.field2_id=3)
      post_request->charge[d1.seq].bill_code2 = trim(cm.field6,3), post_request->charge[d1.seq].
      bill_code2_desc = trim(cm.field7,3)
     ELSEIF (cm.field2_id=4)
      post_request->charge[d1.seq].bill_code3 = trim(cm.field6,3), post_request->charge[d1.seq].
      bill_code3_desc = trim(cm.field7,3)
     ELSEIF (cm.field2_id > 4)
      post_request->charge[d1.seq].bill_code_more_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6, cm.field7
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(icd9diag_codes->code_vals,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=bill_code_cd
      AND cm.active_ind=1)
     JOIN (d2
     WHERE (icd9diag_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF (cm.field2_id=1)
      post_request->charge[d1.seq].diag_code1 = trim(cm.field6,3), post_request->charge[d1.seq].
      diag_desc1 = trim(cm.field7,3)
     ELSEIF (cm.field2_id=2)
      post_request->charge[d1.seq].diag_code2 = trim(cm.field6,3), post_request->charge[d1.seq].
      diag_desc2 = trim(cm.field7,3)
     ELSEIF (cm.field2_id=3)
      post_request->charge[d1.seq].diag_code3 = trim(cm.field6,3), post_request->charge[d1.seq].
      diag_desc3 = trim(cm.field7,3)
     ELSEIF (cm.field2_id > 3)
      post_request->charge[d1.seq].diag_more_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field3_id
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     (dummyt d2  WITH seq = value(size(mod_codes->code_vals,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=bill_code_cd
      AND cm.active_ind=1)
     JOIN (d2
     WHERE (mod_codes->code_vals[d2.seq].code_val=cm.field1_id))
    DETAIL
     IF (cm.field2_id=1)
      post_request->charge[d1.seq].code_modifier1_cd = cm.field3_id
     ELSEIF (cm.field2_id=2)
      post_request->charge[d1.seq].code_modifier2_cd = cm.field3_id
     ELSEIF (cm.field2_id=3)
      post_request->charge[d1.seq].code_modifier3_cd = cm.field3_id
     ELSEIF (cm.field2_id > 3)
      post_request->charge[d1.seq].code_modifier_more_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cm.field6
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=14002_combine
      AND cm.field1_id=13019_mrn_nbr_alias)
    DETAIL
     post_request->charge[d1.seq].med_nbr = cm.field6, post_request->charge[d1.seq].found_one = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ea.alias
    FROM encntr_alias ea,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0)
      AND (post_request->charge[d1.seq].found_one != 1))
     JOIN (ea
     WHERE (ea.encntr_id=post_request->charge[d1.seq].encntr_id)
      AND ea.encntr_alias_type_cd=med_rec_num_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     post_request->charge[d1.seq].med_nbr = ea.alias
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    oa.alias
    FROM order_alias oa,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (oa
     WHERE (oa.order_id=post_request->charge[d1.seq].order_id)
      AND oa.bill_ord_nbr_ind=1
      AND oa.active_ind=1)
    DETAIL
     post_request->charge[d1.seq].order_nbr = oa.alias
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pa.alias
    FROM prsnl_alias pa,
     org_alias_pool_reltn oapr,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (oapr
     WHERE (oapr.organization_id=post_request->charge[d1.seq].payor_id)
      AND oapr.alias_entity_name="PRSNL_ALIAS"
      AND (oapr.alias_entity_alias_type_cd=post_request->charge[d1.seq].doc_nbr_cd)
      AND oapr.active_ind=1)
     JOIN (pa
     WHERE (pa.person_id=post_request->charge[d1.seq].ord_phys_id)
      AND pa.alias_pool_cd=oapr.alias_pool_cd
      AND (pa.prsnl_alias_type_cd=post_request->charge[d1.seq].doc_nbr_cd)
      AND pa.active_ind=1)
    DETAIL
     post_request->charge[d1.seq].ord_doc_nbr = pa.alias
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM person p,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (p
     WHERE (p.person_id=post_request->charge[d1.seq].person_id))
    DETAIL
     post_request->charge[d1.seq].person_name = p.name_full_formatted
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM charge_mod cm,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    PLAN (d1
     WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
     JOIN (cm
     WHERE (cm.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND cm.active_ind=1
      AND cm.charge_mod_type_cd=user_def_cd)
    DETAIL
     post_request->charge[d1.seq].user_def_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dump_request(ff)
  CALL echo("dumping request...")
  CALL echorecord(post_request,"CCLUSERDIR:afc_post_request.dat")
 END ;Subroutine
 SUBROUTINE write_charges(gg)
   CALL echo("writing charges...")
   FOR (charge_count = 1 TO post_request->charge_qual)
     IF ((((post_request->charge[charge_count].susp_for_missing_fin_ind=0)) OR ((post_request->
     charge[charge_count].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[charge_count].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[charge_count].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[charge_count].susp_for_missing_rev_ind=0)
      AND (post_request->charge[charge_count].susp_for_missing_if_ind=0)
      AND (post_request->charge[charge_count].pharm_nocharge_ind=0))
      IF ((post_request->charge[charge_count].explode_ind=1))
       CALL echo("exploding...")
       FOR (explode_count = 1 TO cnvtint(post_request->charge[charge_count].item_quantity))
         SET new_nbr = 0.0
         SELECT INTO "nl:"
          ce_seq_num = seq(charge_event_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_nbr = cnvtreal(ce_seq_num)
          WITH nocounter
         ;end select
         SET post_request->charge[charge_count].interface_charge_id = new_nbr
         INSERT  FROM interface_charge i
          SET i.abn_status_cd = post_request->charge[charge_count].abn_status_cd, i.active_ind =
           post_request->charge[charge_count].active_ind, i.active_status_cd = post_request->charge[
           charge_count].active_status_cd,
           i.active_status_dt_tm = cnvtdatetime(post_request->charge[charge_count].
            active_status_dt_tm), i.active_status_prsnl_id = post_request->charge[charge_count].
           active_status_prsnl_id, i.activity_type_cd = post_request->charge[charge_count].
           activity_type_cd,
           i.additional_encntr_phys1_id = post_request->charge[charge_count].
           additional_encntr_phys1_id, i.additional_encntr_phys2_id = post_request->charge[
           charge_count].additional_encntr_phys2_id, i.additional_encntr_phys3_id = post_request->
           charge[charge_count].additional_encntr_phys3_id,
           i.admit_type_cd = post_request->charge[charge_count].admit_type_cd, i.adm_phys_id =
           post_request->charge[charge_count].adm_phys_id, i.attending_phys_id = post_request->
           charge[charge_count].attending_phys_id,
           i.batch_num = post_request->charge[charge_count].batch_num, i.bed_cd = post_request->
           charge[charge_count].bed_cd, i.beg_effective_dt_tm = cnvtdatetime(sysdate),
           i.bill_code1 = post_request->charge[charge_count].bill_code1, i.bill_code1_desc =
           post_request->charge[charge_count].bill_code1_desc, i.bill_code2 = post_request->charge[
           charge_count].bill_code2,
           i.bill_code2_desc = post_request->charge[charge_count].bill_code2_desc, i.bill_code3 =
           post_request->charge[charge_count].bill_code3, i.bill_code3_desc = post_request->charge[
           charge_count].bill_code3_desc,
           i.bill_code_more_ind = post_request->charge[charge_count].bill_code_more_ind, i
           .bill_code_type_cdf = post_request->charge[charge_count].bill_code_type_cdf, i.building_cd
            = post_request->charge[charge_count].building_cd,
           i.charge_description = post_request->charge[charge_count].charge_description, i
           .charge_item_id = post_request->charge[charge_count].charge_item_id, i.charge_type_cd =
           post_request->charge[charge_count].charge_type_cd,
           i.code_modifier1_cd = post_request->charge[charge_count].code_modifier1_cd, i
           .code_modifier2_cd = post_request->charge[charge_count].code_modifier2_cd, i
           .code_modifier3_cd = post_request->charge[charge_count].code_modifier3_cd,
           i.code_modifier_more_ind = post_request->charge[charge_count].code_modifier_more_ind, i
           .code_revenue_cd = post_request->charge[charge_count].code_revenue_cd, i
           .code_revenue_more_ind = post_request->charge[charge_count].code_revenue_more_ind,
           i.cost_center_cd = post_request->charge[charge_count].cost_center_cd, i.department_cd =
           post_request->charge[charge_count].department_cd, i.diag_code1 = post_request->charge[
           charge_count].diag_code1,
           i.diag_code2 = post_request->charge[charge_count].diag_code2, i.diag_code3 = post_request
           ->charge[charge_count].diag_code3, i.diag_desc1 = post_request->charge[charge_count].
           diag_desc1,
           i.diag_desc2 = post_request->charge[charge_count].diag_desc2, i.diag_desc3 = post_request
           ->charge[charge_count].diag_desc3, i.diag_more_ind = post_request->charge[charge_count].
           diag_more_ind,
           i.discount_amount = post_request->charge[charge_count].discount_amount, i.encntr_id =
           post_request->charge[charge_count].encntr_id, i.encntr_type_cd = post_request->charge[
           charge_count].encntr_type_cd,
           i.end_effective_dt_tm = cnvtdatetime(post_request->charge[charge_count].
            end_effective_dt_tm), i.facility_cd = post_request->charge[charge_count].facility_cd, i
           .fin_nbr = post_request->charge[charge_count].fin_nbr,
           i.fin_nbr_type_flg = post_request->charge[charge_count].fin_nbr_type_flg, i.gross_price =
           post_request->charge[charge_count].gross_price, i.icd9_proc_more_ind = post_request->
           charge[charge_count].icd9_proc_more_ind,
           i.institution_cd = post_request->charge[charge_count].institution_cd, i
           .interface_charge_id = new_nbr, i.interface_file_id = post_request->charge[charge_count].
           interface_file_id,
           i.level5_cd = post_request->charge[charge_count].level5_cd, i.manual_ind = post_request->
           charge[charge_count].manual_ind, i.med_nbr = post_request->charge[charge_count].med_nbr,
           i.med_service_cd = post_request->charge[charge_count].med_service_cd, i.net_ext_price =
           post_request->charge[charge_count].item_price, i.nurse_unit_cd = post_request->charge[
           charge_count].nurse_unit_cd,
           i.order_dept = post_request->charge[charge_count].order_dept, i.order_nbr = post_request->
           charge[charge_count].order_nbr, i.ord_doc_nbr = post_request->charge[charge_count].
           ord_doc_nbr,
           i.ord_phys_id = post_request->charge[charge_count].ord_phys_id, i.organization_id =
           post_request->charge[charge_count].payor_id, i.override_desc =
           IF ((post_request->charge[charge_count].manual_ind=1)) post_request->charge[charge_count].
            charge_description
           ELSE null
           ENDIF
           ,
           i.payor_id = post_request->charge[charge_count].payor_id, i.perf_loc_cd = post_request->
           charge[charge_count].perf_loc_cd, i.perf_phys_id =
           IF ((post_request->charge[charge_count].perf_phys_cont_ind=1)) post_request->charge[
            charge_count].perf_phys_id
           ELSE post_request->charge[charge_count].verify_phys_id
           ENDIF
           ,
           i.person_id = post_request->charge[charge_count].person_id, i.person_name = post_request->
           charge[charge_count].person_name, i.posted_dt_tm = cnvtdatetime(run_dt),
           i.price = post_request->charge[charge_count].item_price, i.prim_cdm = post_request->
           charge[charge_count].prim_cdm, i.prim_cdm_desc = post_request->charge[charge_count].
           prim_cdm_desc,
           i.prim_cpt = post_request->charge[charge_count].prim_cpt, i.prim_cpt_desc = post_request->
           charge[charge_count].prim_cpt_desc, i.prim_icd9_proc = post_request->charge[charge_count].
           prim_icd9_proc,
           i.prim_icd9_proc_desc = post_request->charge[charge_count].prim_icd9_proc_desc, i
           .process_flg = 0, i.quantity = 1,
           i.referring_phys_id = post_request->charge[charge_count].referring_phys_id, i.room_cd =
           post_request->charge[charge_count].room_cd, i.section_cd = post_request->charge[
           charge_count].section_cd,
           i.service_dt_tm = cnvtdatetime(post_request->charge[charge_count].service_dt_tm), i
           .subsection_cd = post_request->charge[charge_count].subsection_cd, i.updt_applctx =
           reqinfo->updt_applctx,
           i.updt_cnt = 0, i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_id = post_request->charge[
           charge_count].updt_id,
           i.updt_task = reqinfo->updt_task, i.user_def_ind = post_request->charge[charge_count].
           user_def_ind, i.verify_phys_id = post_request->charge[charge_count].verify_phys_id,
           i.qty_conv_factor = post_request->charge[charge_count].qty_conv_factor, i.ext_bill_qty =
           post_request->charge[charge_count].ext_bill_qty, i.ndc_ident = post_request->charge[
           charge_count].ndc_ident
         ;end insert
       ENDFOR
       IF ((post_request->charge[charge_count].charge_type_cd=credit_cd))
        SET total_qty_credit += post_request->charge[charge_count].item_quantity
        SET total_amt_credit += post_request->charge[charge_count].item_price
        SET total_cnt_credit += cnvtint(post_request->charge[charge_count].item_quantity)
       ELSEIF ((post_request->charge[charge_count].charge_type_cd=debit_cd))
        SET total_qty_debit += post_request->charge[charge_count].item_quantity
        SET total_amt_debit += post_request->charge[charge_count].item_price
        SET total_cnt_debit += cnvtint(post_request->charge[charge_count].item_quantity)
       ENDIF
      ELSE
       CALL echo("not exploding...")
       SET new_nbr = 0.0
       SELECT INTO "nl:"
        ce_seq_num = seq(charge_event_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(ce_seq_num)
        WITH nocounter
       ;end select
       SET post_request->charge[charge_count].interface_charge_id = new_nbr
       INSERT  FROM interface_charge i
        SET i.abn_status_cd = post_request->charge[charge_count].abn_status_cd, i.active_ind =
         post_request->charge[charge_count].active_ind, i.active_status_cd = post_request->charge[
         charge_count].active_status_cd,
         i.active_status_dt_tm = cnvtdatetime(post_request->charge[charge_count].active_status_dt_tm),
         i.active_status_prsnl_id = post_request->charge[charge_count].active_status_prsnl_id, i
         .activity_type_cd = post_request->charge[charge_count].activity_type_cd,
         i.additional_encntr_phys1_id = post_request->charge[charge_count].additional_encntr_phys1_id,
         i.additional_encntr_phys2_id = post_request->charge[charge_count].additional_encntr_phys2_id,
         i.additional_encntr_phys3_id = post_request->charge[charge_count].additional_encntr_phys3_id,
         i.admit_type_cd = post_request->charge[charge_count].admit_type_cd, i.adm_phys_id =
         post_request->charge[charge_count].adm_phys_id, i.attending_phys_id = post_request->charge[
         charge_count].attending_phys_id,
         i.batch_num = post_request->charge[charge_count].batch_num, i.bed_cd = post_request->charge[
         charge_count].bed_cd, i.beg_effective_dt_tm = cnvtdatetime(sysdate),
         i.bill_code1 = post_request->charge[charge_count].bill_code1, i.bill_code1_desc =
         post_request->charge[charge_count].bill_code1_desc, i.bill_code2 = post_request->charge[
         charge_count].bill_code2,
         i.bill_code2_desc = post_request->charge[charge_count].bill_code2_desc, i.bill_code3 =
         post_request->charge[charge_count].bill_code3, i.bill_code3_desc = post_request->charge[
         charge_count].bill_code3_desc,
         i.bill_code_more_ind = post_request->charge[charge_count].bill_code_more_ind, i
         .bill_code_type_cdf = post_request->charge[charge_count].bill_code_type_cdf, i.building_cd
          = post_request->charge[charge_count].building_cd,
         i.charge_description = post_request->charge[charge_count].charge_description, i
         .charge_item_id = post_request->charge[charge_count].charge_item_id, i.charge_type_cd =
         post_request->charge[charge_count].charge_type_cd,
         i.code_modifier1_cd = post_request->charge[charge_count].code_modifier1_cd, i
         .code_modifier2_cd = post_request->charge[charge_count].code_modifier2_cd, i
         .code_modifier3_cd = post_request->charge[charge_count].code_modifier3_cd,
         i.code_modifier_more_ind = post_request->charge[charge_count].code_modifier_more_ind, i
         .code_revenue_cd = post_request->charge[charge_count].code_revenue_cd, i
         .code_revenue_more_ind = post_request->charge[charge_count].code_revenue_more_ind,
         i.cost_center_cd = post_request->charge[charge_count].cost_center_cd, i.department_cd =
         post_request->charge[charge_count].department_cd, i.diag_code1 = post_request->charge[
         charge_count].diag_code1,
         i.diag_code2 = post_request->charge[charge_count].diag_code2, i.diag_code3 = post_request->
         charge[charge_count].diag_code3, i.diag_desc1 = post_request->charge[charge_count].
         diag_desc1,
         i.diag_desc2 = post_request->charge[charge_count].diag_desc2, i.diag_desc3 = post_request->
         charge[charge_count].diag_desc3, i.diag_more_ind = post_request->charge[charge_count].
         diag_more_ind,
         i.discount_amount = post_request->charge[charge_count].discount_amount, i.encntr_id =
         post_request->charge[charge_count].encntr_id, i.encntr_type_cd = post_request->charge[
         charge_count].encntr_type_cd,
         i.end_effective_dt_tm = cnvtdatetime(post_request->charge[charge_count].end_effective_dt_tm),
         i.facility_cd = post_request->charge[charge_count].facility_cd, i.fin_nbr = post_request->
         charge[charge_count].fin_nbr,
         i.fin_nbr_type_flg = post_request->charge[charge_count].fin_nbr_type_flg, i.gross_price =
         post_request->charge[charge_count].gross_price, i.icd9_proc_more_ind = post_request->charge[
         charge_count].icd9_proc_more_ind,
         i.institution_cd = post_request->charge[charge_count].institution_cd, i.interface_charge_id
          = new_nbr, i.interface_file_id = post_request->charge[charge_count].interface_file_id,
         i.level5_cd = post_request->charge[charge_count].level5_cd, i.manual_ind = post_request->
         charge[charge_count].manual_ind, i.med_nbr = post_request->charge[charge_count].med_nbr,
         i.med_service_cd = post_request->charge[charge_count].med_service_cd, i.net_ext_price =
         post_request->charge[charge_count].item_extended_price, i.nurse_unit_cd = post_request->
         charge[charge_count].nurse_unit_cd,
         i.order_dept = post_request->charge[charge_count].order_dept, i.order_nbr = post_request->
         charge[charge_count].order_nbr, i.ord_doc_nbr = post_request->charge[charge_count].
         ord_doc_nbr,
         i.ord_phys_id = post_request->charge[charge_count].ord_phys_id, i.organization_id =
         post_request->charge[charge_count].payor_id, i.override_desc =
         IF ((post_request->charge[charge_count].manual_ind=1)) post_request->charge[charge_count].
          charge_description
         ELSE null
         ENDIF
         ,
         i.payor_id = post_request->charge[charge_count].payor_id, i.perf_loc_cd = post_request->
         charge[charge_count].perf_loc_cd, i.perf_phys_id =
         IF ((post_request->charge[charge_count].perf_phys_cont_ind=1)) post_request->charge[
          charge_count].perf_phys_id
         ELSE post_request->charge[charge_count].verify_phys_id
         ENDIF
         ,
         i.person_id = post_request->charge[charge_count].person_id, i.person_name = post_request->
         charge[charge_count].person_name, i.posted_dt_tm = cnvtdatetime(run_dt),
         i.price = post_request->charge[charge_count].item_price, i.prim_cdm = post_request->charge[
         charge_count].prim_cdm, i.prim_cdm_desc = post_request->charge[charge_count].prim_cdm_desc,
         i.prim_cpt = post_request->charge[charge_count].prim_cpt, i.prim_cpt_desc = post_request->
         charge[charge_count].prim_cpt_desc, i.prim_icd9_proc = post_request->charge[charge_count].
         prim_icd9_proc,
         i.prim_icd9_proc_desc = post_request->charge[charge_count].prim_icd9_proc_desc, i
         .process_flg = 0, i.quantity = post_request->charge[charge_count].item_quantity,
         i.referring_phys_id = post_request->charge[charge_count].referring_phys_id, i.room_cd =
         post_request->charge[charge_count].room_cd, i.section_cd = post_request->charge[charge_count
         ].section_cd,
         i.service_dt_tm = cnvtdatetime(post_request->charge[charge_count].service_dt_tm), i
         .subsection_cd = post_request->charge[charge_count].subsection_cd, i.updt_applctx = reqinfo
         ->updt_applctx,
         i.updt_cnt = 0, i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_id = post_request->charge[
         charge_count].updt_id,
         i.updt_task = reqinfo->updt_task, i.user_def_ind = post_request->charge[charge_count].
         user_def_ind, i.verify_phys_id = post_request->charge[charge_count].verify_phys_id,
         i.qty_conv_factor = post_request->charge[charge_count].qty_conv_factor, i.ext_bill_qty =
         post_request->charge[charge_count].ext_bill_qty, i.ndc_ident = post_request->charge[
         charge_count].ndc_ident
       ;end insert
       IF ((post_request->charge[charge_count].charge_type_cd=credit_cd))
        SET total_qty_credit += post_request->charge[charge_count].item_quantity
        SET total_amt_credit += post_request->charge[charge_count].item_price
        SET total_cnt_credit += 1
       ELSEIF ((post_request->charge[charge_count].charge_type_cd=debit_cd))
        SET total_qty_debit += post_request->charge[charge_count].item_quantity
        SET total_amt_debit += post_request->charge[charge_count].item_price
        SET total_cnt_debit += 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET csops_cnt += 1
   SET stat = alterlist(csops_request2->charges,csops_cnt)
   SET csops_request2->charges[csops_cnt].interface_file_id = interface_files->files[ifiles].
   interface_file_id
   SET csops_request2->charges[csops_cnt].charge_type_cd = credit_cd
   CALL echo(build("charge_type_cd1: ",credit_cd))
   SET csops_request2->charges[csops_cnt].total_quantity = total_qty_credit
   CALL echo(build("total_qty_credit: ",total_qty_credit))
   SET csops_request2->charges[csops_cnt].total_amount = total_amt_credit
   CALL echo(build("total_amt_credit: ",total_amt_credit))
   SET csops_request2->charges[csops_cnt].raw_count = total_cnt_credit
   CALL echo(build("total_cnt_credit: ",total_cnt_credit))
   SET csops_cnt += 1
   SET stat = alterlist(csops_request2->charges,csops_cnt)
   SET csops_request2->charges[csops_cnt].interface_file_id = interface_files->files[ifiles].
   interface_file_id
   CALL echo(build("interface_file_id: ",csops_request2->charges[csops_cnt].interface_file_id))
   SET csops_request2->charges[csops_cnt].charge_type_cd = debit_cd
   CALL echo(build("charge_type_cd: ",debit_cd))
   SET csops_request2->charges[csops_cnt].total_quantity = total_qty_debit
   CALL echo(build("total_qty_debit: ",total_qty_debit))
   SET csops_request2->charges[csops_cnt].total_amount = total_amt_debit
   CALL echo(build("total_amt_debit: ",total_amt_debit))
   SET csops_request2->charges[csops_cnt].raw_count = total_cnt_debit
   CALL echo(build("total_cnt_debit: ",total_cnt_debit))
 END ;Subroutine
 SUBROUTINE write_suspense_mods(pp)
   DECLARE billcodecnt = i4 WITH protect, noconstant(0)
   CALL echo("writing suspense mods...")
   SET stat = alterlist(susp->charges,0)
   SET stat = alterlist(cmreq->objarray,0)
   SET susp_charge_count = 0
   SET susp->charge_qual = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    WHERE (((post_request->charge[d1.seq].susp_for_missing_fin_ind=1)
     AND (post_request->charge[d1.seq].dont_susp_for_fin_ind=0)) OR ((((post_request->charge[d1.seq].
    susp_for_missing_cdm_ind > 0)) OR ((((post_request->charge[d1.seq].susp_for_missing_cpt_ind > 0))
     OR ((((post_request->charge[d1.seq].susp_for_missing_rev_ind > 0)) OR ((post_request->charge[d1
    .seq].susp_for_missing_if_ind=1)
     AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))) )) )) ))
    DETAIL
     post_request->charge[d1.seq].process_flg = 1, susp_charge_count += 1, stat = alterlist(susp->
      charges,susp_charge_count),
     susp->charges[susp_charge_count].charge_item_id = post_request->charge[d1.seq].charge_item_id,
     susp->charges[susp_charge_count].susp_for_missing_fin_ind = post_request->charge[d1.seq].
     susp_for_missing_fin_ind, susp->charges[susp_charge_count].dont_susp_for_fin_ind = post_request
     ->charge[d1.seq].dont_susp_for_fin_ind,
     susp->charges[susp_charge_count].susp_for_missing_cdm_ind = post_request->charge[d1.seq].
     susp_for_missing_cdm_ind, susp->charges[susp_charge_count].susp_for_missing_cpt_ind =
     post_request->charge[d1.seq].susp_for_missing_cpt_ind, susp->charges[susp_charge_count].
     susp_for_missing_rev_ind = post_request->charge[d1.seq].susp_for_missing_rev_ind,
     susp->charges[susp_charge_count].susp_for_missing_if_ind = post_request->charge[d1.seq].
     susp_for_missing_if_ind, susp->charge_qual = susp_charge_count
    WITH nocounter
   ;end select
   CALL echo(build("# suspended charges found:"," ",susp->charge_qual))
   IF ((susp->charge_qual > 0))
    FOR (counter = 1 TO susp->charge_qual)
      IF ((susp->charges[counter].susp_for_missing_fin_ind=1)
       AND (susp->charges[counter].dont_susp_for_fin_ind=0))
       SET billcodecnt += 1
       CALL insert_susp_mod(susp->charges[counter].charge_item_id,no_fin_cd,no_fin_desc,billcodecnt)
       CALL echo("inserting fin suspend mod")
      ENDIF
      IF ((susp->charges[counter].susp_for_missing_cdm_ind > 0))
       SET billcodecnt += 1
       CALL insert_susp_mod(susp->charges[counter].charge_item_id,no_cdm_cd,no_cdm_desc,billcodecnt)
       CALL echo("inserting cdm suspend mod")
      ENDIF
      IF ((susp->charges[counter].susp_for_missing_cpt_ind > 0))
       SET billcodecnt += 1
       CALL insert_susp_mod(susp->charges[counter].charge_item_id,no_cpt_cd,no_cpt_desc,billcodecnt)
       CALL echo("inserting cpt suspend mod")
      ENDIF
      IF ((susp->charges[counter].susp_for_missing_rev_ind > 0))
       SET billcodecnt += 1
       CALL insert_susp_mod(susp->charges[counter].charge_item_id,no_rev_cd,no_rev_desc,billcodecnt)
       CALL echo("inserting rev suspend mod")
      ENDIF
      IF ((susp->charges[counter].susp_for_missing_if_ind=1))
       SET billcodecnt += 1
       CALL insert_susp_mod(susp->charges[counter].charge_item_id,inactive_file_cd,inactive_file_desc,
        billcodecnt)
       CALL echo("inserting if suspend mod")
      ENDIF
    ENDFOR
   ENDIF
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to add")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_susp_mod(charge,code,desc,billcodecnt)
   CALL echo("inserting suspense mod...")
   SET new_charge_mod_id = 0.0
   SELECT INTO "nl:"
    ce_seq_num = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_charge_mod_id = cnvtreal(ce_seq_num)
    WITH format, counter
   ;end select
   SET stat = alterlist(cmreq->objarray,billcodecnt)
   SET cmreq->objarray[billcodecnt].action_type = "ADD"
   SET cmreq->objarray[billcodecnt].charge_mod_id = new_charge_mod_id
   SET cmreq->objarray[billcodecnt].charge_item_id = charge
   SET cmreq->objarray[billcodecnt].charge_mod_type_cd = susp_cd
   SET cmreq->objarray[billcodecnt].field1 = cnvtstring(code,17,2)
   SET cmreq->objarray[billcodecnt].field6 = trim(desc)
   SET cmreq->objarray[billcodecnt].field1_id = code
   SET cmreq->objarray[billcodecnt].active_ind = 1
   SET cmreq->objarray[billcodecnt].active_status_cd = reqdata->active_status_cd
   SET cmreq->objarray[billcodecnt].active_status_prsnl_id = reqinfo->updt_id
   SET cmreq->objarray[billcodecnt].active_status_dt_tm = cnvtdatetime(sysdate)
   SET cmreq->objarray[billcodecnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
   SET cmreq->objarray[billcodecnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   SET cmreq->objarray[billcodecnt].updt_cnt = 0
 END ;Subroutine
 SUBROUTINE update_charges(hh)
   CALL echo("Updating charges...")
   UPDATE  FROM charge c,
     (dummyt d1  WITH seq = value(size(post_request->charge,5)))
    SET c.process_flg =
     IF ((((post_request->charge[d1.seq].susp_for_missing_cdm_ind > 0)) OR ((((post_request->charge[
     d1.seq].susp_for_missing_cpt_ind > 0)) OR ((((post_request->charge[d1.seq].
     susp_for_missing_rev_ind > 0)) OR ((((post_request->charge[d1.seq].susp_for_missing_if_ind=1))
      OR ((post_request->charge[d1.seq].susp_for_missing_fin_ind=1)
      AND (post_request->charge[d1.seq].dont_susp_for_fin_ind=0))) )) )) )) ) 1
     ELSE 999
     ENDIF
     , c.beg_effective_dt_tm = cnvtdatetime(rn_dt), c.updt_dt_tm = cnvtdatetime(sysdate),
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
     updt_task
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_item_id=post_request->charge[d1.seq].charge_item_id)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0))
   ;end update
   CALL echo("committing realtime charges")
   COMMIT
 END ;Subroutine
 SUBROUTINE fill_out_reply(jj)
   CALL echo("filling out realtime reply...")
   SET reply_count = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(post_request->charge,5))),
     interface_charge i
    PLAN (d1
     WHERE (post_request->charge[d1.seq].batch_num=new_batch_num)
      AND (((post_request->charge[d1.seq].susp_for_missing_fin_ind=0)) OR ((post_request->charge[d1
     .seq].dont_susp_for_fin_ind=1)))
      AND (post_request->charge[d1.seq].susp_for_missing_cdm_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_cpt_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_rev_ind=0)
      AND (post_request->charge[d1.seq].susp_for_missing_if_ind=0)
      AND (post_request->charge[d1.seq].pharm_nocharge_ind=0)
      AND (post_request->charge[d1.seq].service_based_ind != 1))
     JOIN (i
     WHERE (i.batch_num=post_request->charge[d1.seq].batch_num)
      AND (i.charge_item_id=post_request->charge[d1.seq].charge_item_id))
    ORDER BY post_request->charge[d1.seq].encntr_id, post_request->charge[d1.seq].fin_nbr
    DETAIL
     reply_count += 1, stat = alterlist(reply->interface_charge,reply_count), reply->
     interface_charge[reply_count].abn_status_cd = i.abn_status_cd,
     reply->interface_charge[reply_count].active_ind = i.active_ind, reply->interface_charge[
     reply_count].active_status_cd = i.active_status_cd, reply->interface_charge[reply_count].
     active_status_dt_tm = i.active_status_dt_tm,
     reply->interface_charge[reply_count].active_status_prsnl_id = i.active_status_prsnl_id, reply->
     interface_charge[reply_count].activity_type_cd = i.activity_type_cd, reply->interface_charge[
     reply_count].additional_encntr_phys1_id = i.additional_encntr_phys1_id,
     reply->interface_charge[reply_count].additional_encntr_phys2_id = i.additional_encntr_phys2_id,
     reply->interface_charge[reply_count].additional_encntr_phys3_id = i.additional_encntr_phys3_id,
     reply->interface_charge[reply_count].admit_type_cd = i.admit_type_cd,
     reply->interface_charge[reply_count].adm_phys_id = i.adm_phys_id, reply->interface_charge[
     reply_count].attending_phys_id = i.attending_phys_id, reply->interface_charge[reply_count].
     batch_num = i.batch_num,
     reply->interface_charge[reply_count].bed_cd = i.bed_cd, reply->interface_charge[reply_count].
     beg_effective_dt_tm = i.beg_effective_dt_tm, reply->interface_charge[reply_count].bill_code1 = i
     .bill_code1,
     reply->interface_charge[reply_count].bill_code1_desc = i.bill_code1_desc, reply->
     interface_charge[reply_count].bill_code2 = i.bill_code2, reply->interface_charge[reply_count].
     bill_code2_desc = i.bill_code2_desc,
     reply->interface_charge[reply_count].bill_code3 = i.bill_code3, reply->interface_charge[
     reply_count].bill_code3_desc = i.bill_code3_desc, reply->interface_charge[reply_count].
     bill_code_more_ind = i.bill_code_more_ind,
     reply->interface_charge[reply_count].bill_code_type_cdf = i.bill_code_type_cdf, reply->
     interface_charge[reply_count].building_cd = i.building_cd, reply->interface_charge[reply_count].
     charge_description = i.charge_description,
     reply->interface_charge[reply_count].charge_item_id = i.charge_item_id, reply->interface_charge[
     reply_count].charge_type_cd = i.charge_type_cd, reply->interface_charge[reply_count].
     code_modifier1_cd = i.code_modifier1_cd,
     reply->interface_charge[reply_count].code_modifier2_cd = i.code_modifier2_cd, reply->
     interface_charge[reply_count].code_modifier3_cd = i.code_modifier3_cd, reply->interface_charge[
     reply_count].code_modifier_more_ind = i.code_modifier_more_ind,
     reply->interface_charge[reply_count].code_revenue_cd = i.code_revenue_cd, reply->
     interface_charge[reply_count].code_revenue_more_ind = i.code_revenue_more_ind, reply->
     interface_charge[reply_count].cost_center_cd = i.cost_center_cd,
     reply->interface_charge[reply_count].department_cd = i.department_cd, reply->interface_charge[
     reply_count].diag_code1 = i.diag_code1, reply->interface_charge[reply_count].diag_code2 = i
     .diag_code2,
     reply->interface_charge[reply_count].diag_code3 = i.diag_code3, reply->interface_charge[
     reply_count].diag_desc1 = i.diag_desc1, reply->interface_charge[reply_count].diag_desc2 = i
     .diag_desc2,
     reply->interface_charge[reply_count].diag_desc3 = i.diag_desc3, reply->interface_charge[
     reply_count].diag_more_ind = i.diag_more_ind, reply->interface_charge[reply_count].
     discount_amount = i.discount_amount,
     reply->interface_charge[reply_count].encntr_id = i.encntr_id, reply->interface_charge[
     reply_count].encntr_type_cd = i.encntr_type_cd, reply->interface_charge[reply_count].
     end_effective_dt_tm = i.end_effective_dt_tm,
     reply->interface_charge[reply_count].facility_cd = i.facility_cd, reply->interface_charge[
     reply_count].fin_nbr = i.fin_nbr, reply->interface_charge[reply_count].fin_nbr_type_flg = i
     .fin_nbr_type_flg,
     reply->interface_charge[reply_count].gross_price = i.gross_price, reply->interface_charge[
     reply_count].icd9_proc_more_ind = i.icd9_proc_more_ind, reply->interface_charge[reply_count].
     institution_cd = i.institution_cd,
     reply->interface_charge[reply_count].interface_charge_id = i.interface_charge_id, reply->
     interface_charge[reply_count].interface_file_id = i.interface_file_id, reply->interface_charge[
     reply_count].level5_cd = i.level5_cd,
     reply->interface_charge[reply_count].manual_ind = i.manual_ind, reply->interface_charge[
     reply_count].med_nbr = i.med_nbr, reply->interface_charge[reply_count].med_service_cd = i
     .med_service_cd,
     reply->interface_charge[reply_count].net_ext_price = i.net_ext_price, reply->interface_charge[
     reply_count].nurse_unit_cd = i.nurse_unit_cd, reply->interface_charge[reply_count].order_dept =
     i.order_dept,
     reply->interface_charge[reply_count].order_nbr = i.order_nbr, reply->interface_charge[
     reply_count].ord_doc_nbr = i.ord_doc_nbr, reply->interface_charge[reply_count].ord_phys_id = i
     .ord_phys_id,
     reply->interface_charge[reply_count].organization_id = i.organization_id, reply->
     interface_charge[reply_count].override_desc = i.override_desc, reply->interface_charge[
     reply_count].payor_id = i.payor_id,
     reply->interface_charge[reply_count].perf_loc_cd = i.perf_loc_cd, reply->interface_charge[
     reply_count].perf_phys_id = i.perf_phys_id, reply->interface_charge[reply_count].person_id = i
     .person_id,
     reply->interface_charge[reply_count].person_name = i.person_name, reply->interface_charge[
     reply_count].posted_dt_tm = i.posted_dt_tm, reply->interface_charge[reply_count].price = i.price,
     reply->interface_charge[reply_count].prim_cdm = i.prim_cdm, reply->interface_charge[reply_count]
     .prim_cdm_desc = i.prim_cdm_desc, reply->interface_charge[reply_count].prim_cpt = i.prim_cpt,
     reply->interface_charge[reply_count].prim_cpt_desc = i.prim_cpt_desc, reply->interface_charge[
     reply_count].prim_icd9_proc = i.prim_icd9_proc, reply->interface_charge[reply_count].
     prim_icd9_proc_desc = i.prim_icd9_proc_desc,
     reply->interface_charge[reply_count].process_flg = i.process_flg, reply->interface_charge[
     reply_count].quantity = i.quantity, reply->interface_charge[reply_count].referring_phys_id = i
     .referring_phys_id,
     reply->interface_charge[reply_count].room_cd = i.room_cd, reply->interface_charge[reply_count].
     section_cd = i.section_cd, reply->interface_charge[reply_count].service_dt_tm = i.service_dt_tm,
     reply->interface_charge[reply_count].subsection_cd = i.subsection_cd, reply->interface_charge[
     reply_count].updt_applctx = i.updt_applctx, reply->interface_charge[reply_count].updt_cnt = i
     .updt_cnt,
     reply->interface_charge[reply_count].updt_dt_tm = i.updt_dt_tm, reply->interface_charge[
     reply_count].updt_id = i.updt_id, reply->interface_charge[reply_count].updt_task = i.updt_task,
     reply->interface_charge[reply_count].user_def_ind = i.user_def_ind, reply->interface_charge[
     reply_count].ndc_ident = i.ndc_ident
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->interface_charge,5))),
     charge_mod cm
    PLAN (d1)
     JOIN (cm
     WHERE (cm.charge_item_id=reply->interface_charge[d1.seq].charge_item_id)
      AND cm.charge_mod_type_cd=13019_billcode_cd
      AND cm.nomen_id > 0.0
      AND ((cm.active_ind+ 0)=true))
    ORDER BY cm.charge_item_id, cm.field1_id, cm.field2_id
    HEAD cm.charge_item_id
     diagcnt = 0
    DETAIL
     IF (uar_get_code_meaning(cm.field1_id)="PROCCODE")
      IF (cm.field2_id=1)
       reply->interface_charge[d1.seq].prim_icd9_proc_nomen_id = cm.nomen_id
      ENDIF
      IF (trim(reply->interface_charge[d1.seq].bill_code1) != "")
       CASE (cm.field2_id)
        OF 2:
         reply->interface_charge[d1.seq].bill_code1_nomen_id = cm.nomen_id
        OF 3:
         reply->interface_charge[d1.seq].bill_code2_nomen_id = cm.nomen_id
        OF 4:
         reply->interface_charge[d1.seq].bill_code3_nomen_id = cm.nomen_id
       ENDCASE
      ENDIF
     ELSEIF (uar_get_code_meaning(cm.field1_id)="ICD9")
      diagcnt += 1, stat = alterlist(reply->interface_charge[d1.seq].icd_diag_info,diagcnt), reply->
      interface_charge[d1.seq].icd_diag_info[diagcnt].nomen_id = cm.nomen_id
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("reply count: ",reply_count))
   CALL echorecord(reply)
 END ;Subroutine
 SUBROUTINE dump_reply(xx)
  CALL echo("dumping reply...")
  CALL echorecord(reply,"CCLUSERDIR:afc_post_reply.dat")
 END ;Subroutine
 SUBROUTINE get_qcf(cc)
   CALL echo("getting QCF value...")
   DECLARE qcf = f8
   DECLARE roundingflag = i2
   DECLARE itemquantity = f8
   DECLARE result = f8
   FOR (nchargeloop = 1 TO post_request->charge_qual)
     CALL echo(build("charge_item_id: ",post_request->charge[nchargeloop].charge_item_id))
     CALL echo(build("The size of HCPCS_codes->code_vals is: ",size(hcpcs_codes->code_vals,5)))
     CALL echo(build("HCPCS: ",hcpcs_codes->code_vals[1].code_val))
     CALL echo(build("BILL_CODE: ",bill_code))
     SET qcf = 0.0
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(hcpcs_codes->code_vals,5))),
       charge_mod cm
      PLAN (cm
       WHERE cm.charge_mod_type_cd=bill_code
        AND (cm.charge_item_id=post_request->charge[nchargeloop].charge_item_id)
        AND cm.field2_id=1
        AND cm.active_ind=1)
       JOIN (d1
       WHERE (hcpcs_codes->code_vals[d1.seq].code_val=cm.field1_id))
      DETAIL
       qcf = cm.cm1_nbr,
       CALL echo("DETAIL")
      WITH nocounter
     ;end select
     CALL echo(build("QCF IS: ",qcf))
     IF (qcf IN (0.0, null))
      SET qcf = 1
     ENDIF
     CALL echo(build("QCF IS: ",qcf))
     CALL echo("returning QCF: ")
     SET post_request->charge[nchargeloop].qty_conv_factor = qcf
     SELECT INTO "nl:"
      FROM interface_file i
      WHERE (i.interface_file_id=post_request->charge[nchargeloop].interface_file_id)
      DETAIL
       roundingflag = i.round_method_flag
      WITH nocounter
     ;end select
     CALL echo(build("RoundingFlag: ",roundingflag))
     SET result = (cnvtreal(format(post_request->charge[nchargeloop].item_quantity,"########.####;;F"
       )) * cnvtreal(format(post_request->charge[nchargeloop].qty_conv_factor,"########.####;;F")))
     CALL echo(build("Result of calculation: ",result))
     CASE (roundingflag)
      OF 0:
       SET result = round(result,0)
      OF 1:
       SET result = ceil(cnvtreal(format(result,"########.####;;F")))
      OF 2:
       SET result = floor(result)
     ENDCASE
     IF (result < 1)
      SET result = 1
     ENDIF
     CALL echo(build("The result after rounding: ",result))
     SET post_request->charge[nchargeloop].ext_bill_qty = result
     CALL echo(build("The result of ext_bill_qty after rounding: ",post_request->charge[nchargeloop].
       ext_bill_qty))
   ENDFOR
 END ;Subroutine
 SUBROUTINE (publishchargecreatedevent(prpostrequest=vc(ref)) =i2)
   DECLARE chargeidx = i4 WITH protect, noconstant(0)
   DECLARE chargecount = i4 WITH protect, noconstant(0)
   DECLARE encntridx = i4 WITH protect, noconstant(0)
   DECLARE echargeidx = i4 WITH protect, noconstant(0)
   DECLARE paramsidx = i4 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE locatepos = i4 WITH protect, noconstant(0)
   IF ( NOT (cs23369_wfevent > 0.0
    AND cs29322_chargecreated_event > 0.0
    AND cs24454_chrgitemid > 0.0
    AND cs24454_svcbasedind > 0.0))
    CALL logmessage(cursub,
     "Code values (CS23369_WFEVENT, CS29322_CHARGECREATED_EVENT, CS24454_CHRGITEMID, CS24454_SVCBASEDIND) are not set up.",
     log_debug)
    RETURN(true)
   ENDIF
   SET chargecount = size(prpostrequest->charge,5)
   IF (chargecount=0.0)
    RETURN(true)
   ENDIF
   RECORD encntrchargesrec(
     1 encntrlist[*]
       2 encntrid = f8
       2 servicebasedind = i2
       2 chargelist[*]
         3 chargeitemid = f8
   ) WITH protect
   FOR (chargeidx = 1 TO chargecount)
     IF ((prpostrequest->charge[chargeidx].encntr_id > 0.0)
      AND (prpostrequest->charge[chargeidx].charge_item_id > 0.0)
      AND (((prpostrequest->charge[chargeidx].susp_for_missing_fin_ind=0)) OR ((prpostrequest->
     charge[chargeidx].dont_susp_for_fin_ind=1)))
      AND (prpostrequest->charge[chargeidx].susp_for_missing_cdm_ind=0)
      AND (prpostrequest->charge[chargeidx].susp_for_missing_cpt_ind=0)
      AND (prpostrequest->charge[chargeidx].susp_for_missing_rev_ind=0)
      AND (prpostrequest->charge[chargeidx].susp_for_missing_if_ind=0)
      AND (prpostrequest->charge[chargeidx].pharm_nocharge_ind=0))
      SET encntrpos = 0
      SET encntrpos = locateval(encntridx,1,size(encntrchargesrec->encntrlist,5),prpostrequest->
       charge[chargeidx].encntr_id,encntrchargesrec->encntrlist[encntridx].encntrid)
      IF (encntrpos=0)
       SET encntridx = (size(encntrchargesrec->encntrlist,5)+ 1)
       SET stat = alterlist(encntrchargesrec->encntrlist,encntridx)
       SET encntrchargesrec->encntrlist[encntridx].encntrid = prpostrequest->charge[chargeidx].
       encntr_id
       SET stat = alterlist(encntrchargesrec->encntrlist[encntridx].chargelist,1)
       SET encntrchargesrec->encntrlist[encntridx].chargelist[1].chargeitemid = prpostrequest->
       charge[chargeidx].charge_item_id
       IF ((encntrchargesrec->encntrlist[encntridx].servicebasedind=0)
        AND validate(prpostrequest->charge[chargeidx].service_based_ind,0)=1)
        SET encntrchargesrec->encntrlist[encntridx].servicebasedind = 1
       ENDIF
      ELSE
       SET echargeidx = (size(encntrchargesrec->encntrlist[encntrpos].chargelist,5)+ 1)
       SET stat = alterlist(encntrchargesrec->encntrlist[encntrpos].chargelist,echargeidx)
       SET encntrchargesrec->encntrlist[encntrpos].chargelist[echargeidx].chargeitemid =
       prpostrequest->charge[chargeidx].charge_item_id
       IF ((encntrchargesrec->encntrlist[encntridx].servicebasedind=0)
        AND validate(prpostrequest->charge[chargeidx].service_based_ind,0)=1)
        SET encntrchargesrec->encntrlist[encntridx].servicebasedind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(encntrchargesrec)
   ENDIF
   RECORD chargecreatedeventreq(
     1 eventlist[*]
       2 entitytypekey = vc
       2 entityid = f8
       2 eventcd = f8
       2 eventtypecd = f8
       2 params[*]
         3 paramcd = f8
         3 paramvalue = f8
         3 newparamind = i2
         3 doublevalue = f8
         3 stringvalue = vc
         3 datevalue = dq8
         3 parententityname = vc
         3 parententityid = f8
   ) WITH protect
   RECORD chargecreatedeventrep(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET encntrcount = size(encntrchargesrec->encntrlist,5)
   IF (encntrcount=0.0)
    RETURN(true)
   ENDIF
   SET stat = alterlist(chargecreatedeventreq->eventlist,encntrcount)
   FOR (encntridx = 1 TO encntrcount)
     SET chargecreatedeventreq->eventlist[encntridx].entitytypekey = "ENCOUNTER"
     SET chargecreatedeventreq->eventlist[encntridx].entityid = encntrchargesrec->encntrlist[
     encntridx].encntrid
     SET chargecreatedeventreq->eventlist[encntridx].eventcd = cs29322_chargecreated_event
     SET chargecreatedeventreq->eventlist[encntridx].eventtypecd = cs23369_wfevent
     SET stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,1)
     SET chargecreatedeventreq->eventlist[encntridx].params[1].paramcd = cs24454_svcbasedind
     SET chargecreatedeventreq->eventlist[encntridx].params[1].newparamind = true
     IF (validate(encntrchargesrec->encntrlist[encntridx].servicebasedind,0)=1)
      SET chargecreatedeventreq->eventlist[encntridx].params[1].stringvalue = "TRUE"
     ELSE
      SET chargecreatedeventreq->eventlist[encntridx].params[1].stringvalue = "FALSE"
     ENDIF
     SET chargecount = size(encntrchargesrec->encntrlist[encntridx].chargelist,5)
     SET stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,(chargecount+ 1))
     FOR (echargeidx = 1 TO chargecount)
       SET paramsidx = (echargeidx+ 1)
       SET chargecreatedeventreq->eventlist[encntridx].params[paramsidx].paramcd = cs24454_chrgitemid
       SET chargecreatedeventreq->eventlist[encntridx].params[paramsidx].newparamind = true
       SET chargecreatedeventreq->eventlist[encntridx].params[paramsidx].doublevalue =
       encntrchargesrec->encntrlist[encntridx].chargelist[echargeidx].chargeitemid
     ENDFOR
   ENDFOR
   EXECUTE pft_publish_event  WITH replace("REQUEST",chargecreatedeventreq), replace("REPLY",
    chargecreatedeventrep)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(chargecreatedeventreq)
    CALL echorecord(chargecreatedeventrep)
   ENDIF
   IF ((chargecreatedeventrep->status_data.status != "S"))
    CALL logmessage(cursub,"Call to pft_publish_event failed",log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updateserviceinterfaceflag(prpostrequest=vc(ref)) =i2)
  UPDATE  FROM charge c,
    (dummyt d1  WITH seq = value(size(prpostrequest->charge,5)))
   SET c.service_interface_flag = interfaced_through_service, c.updt_dt_tm = cnvtdatetime(sysdate), c
    .updt_cnt = (c.updt_cnt+ 1),
    c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=prpostrequest->charge[d1.seq].charge_item_id)
     AND (prpostrequest->charge[d1.seq].service_based_ind=1))
  ;end update
  RETURN(true)
 END ;Subroutine
#end_program
 SET csops_request2->job_status = reply->status_data.status
 CALL echo(build("status: ",csops_request2->job_status))
 SET csops_request2->end_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt = cnvtdatetime(concat(format(csops_request2->end_dt_tm,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 CALL echo(build("the end date is: ",format(end_dt,"DD-MMM-YYYY HH:MM;;d")))
 CALL echo("executing afc_add_csops_summ")
 EXECUTE afc_add_csops_summ
 FREE SET cpt_codes
 FREE SET cdm_codes
 FREE SET rev_codes
 FREE SET icd9_codes
 FREE SET icd9diag_codes
 FREE SET mod_codes
 FREE SET hcpcs_codes
END GO
