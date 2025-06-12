CREATE PROGRAM afc_export_bill_items:dba
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
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 CALL beginservice("323720.003")
 FREE SET bi_info
 RECORD bi_info(
   1 bill_items[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_owner_cd = vc
     2 price_qual = i4
     2 prices[*]
       3 psi_id = f8
       3 price_sched = vc
       3 price = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 bill_code_qual = i4
     2 bill_codes[*]
       3 bim_id = f8
       3 bill_code_sched = vc
       3 bill_code = vc
       3 bill_code_desc = vc
       3 priority = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 SET file_name =  $1
 SET owner_cd =  $2
 SET user_option =  $3
 SET file_name2 = fillstring(40," ")
 SET file_name2 = file_name
 CALL echo(build("the option is: ",user_option))
 CALL echo(build("the filename is: ",file_name))
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_code_cd = f8
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,bill_code_cd)
 CALL echo(build("the bill code code value is: ",bill_code_cd))
 SET finished = 0
 SET first_time = 1
 SET bi_counter = 0
 SET file_count = 0
 SET max_bi_id = 0.0
 SET num_bi = 0
 DECLARE logicaldomainid = f8 WITH noconstant(0.0), protect
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
 SELECT INTO "nl:"
  max_id = max(b.bill_item_id)
  FROM bill_item b
  DETAIL
   max_bi_id = max_id
  WITH nocounter
 ;end select
 SET beg_range = 0
 SET end_range = 0
 WHILE (finished=0)
   SET counter = 0
   SET stat = alterlist(bi_info->bill_items,counter)
   SET beg_range = (end_range+ 1)
   IF (beg_range > 1)
    SET end_range += 2000
   ELSE
    SET end_range = 2000
   ENDIF
   IF ((end_range > (max_bi_id+ 1000)))
    SET finished = 1
   ENDIF
   IF (owner_cd=0)
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE b.bill_item_id BETWEEN beg_range AND end_range
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
     DETAIL
      counter += 1, stat = alterlist(bi_info->bill_items,counter), bi_info->bill_items[counter].
      bill_item_id = b.bill_item_id,
      bi_info->bill_items[counter].ext_description = b.ext_description, bi_info->bill_items[counter].
      ext_parent_reference_id = b.ext_parent_reference_id, bi_info->bill_items[counter].
      ext_child_reference_id = b.ext_child_reference_id,
      bi_info->bill_items[counter].ext_owner_cd = uar_get_code_display(b.ext_owner_cd)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE b.bill_item_id BETWEEN beg_range AND end_range
      AND b.ext_owner_cd=owner_cd
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
     DETAIL
      counter += 1, stat = alterlist(bi_info->bill_items,counter), bi_info->bill_items[counter].
      bill_item_id = b.bill_item_id,
      bi_info->bill_items[counter].ext_description = b.ext_description, bi_info->bill_items[counter].
      ext_parent_reference_id = b.ext_parent_reference_id, bi_info->bill_items[counter].
      ext_child_reference_id = b.ext_child_reference_id,
      bi_info->bill_items[counter].ext_owner_cd = uar_get_code_display(b.ext_owner_cd)
     WITH nocounter
    ;end select
   ENDIF
   SET size = value(size(bi_info->bill_items,5))
   IF (size > 0)
    IF (choice=1)
     SET counter = 0
     SELECT INTO "nl:"
      FROM price_sched_items psi,
       price_sched ps,
       (dummyt d  WITH seq = value(size(bi_info->bill_items,5)))
      PLAN (d)
       JOIN (psi
       WHERE (psi.bill_item_id=bi_info->bill_items[d.seq].bill_item_id)
        AND psi.active_ind=1
        AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
        AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
       JOIN (ps
       WHERE ps.price_sched_id=psi.price_sched_id)
      HEAD psi.bill_item_id
       counter = 0
      DETAIL
       counter += 1, stat = alterlist(bi_info->bill_items[d.seq].prices,counter), bi_info->
       bill_items[d.seq].prices[counter].psi_id = psi.price_sched_items_id,
       bi_info->bill_items[d.seq].prices[counter].price_sched = ps.price_sched_desc, bi_info->
       bill_items[d.seq].prices[counter].price = psi.price, bi_info->bill_items[d.seq].price_qual =
       counter,
       bi_info->bill_items[d.seq].prices[counter].beg_effective_dt_tm = psi.beg_effective_dt_tm,
       bi_info->bill_items[d.seq].prices[counter].end_effective_dt_tm = psi.end_effective_dt_tm
      WITH nocounter
     ;end select
     SET counter = 0
     SELECT INTO "nl:"
      FROM bill_item_modifier bim,
       (dummyt d  WITH seq = value(size(bi_info->bill_items,5)))
      PLAN (d)
       JOIN (bim
       WHERE (bim.bill_item_id=bi_info->bill_items[d.seq].bill_item_id)
        AND bim.bill_item_type_cd=bill_code_cd
        AND bim.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
        AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
      HEAD bim.bill_item_id
       counter = 0
      DETAIL
       counter += 1, stat = alterlist(bi_info->bill_items[d.seq].bill_codes,counter), bi_info->
       bill_items[d.seq].bill_codes[counter].bim_id = bim.bill_item_mod_id,
       bi_info->bill_items[d.seq].bill_codes[counter].bill_code_sched = uar_get_code_display(bim
        .key1_id), bi_info->bill_items[d.seq].bill_codes[counter].bill_code = bim.key6, bi_info->
       bill_items[d.seq].bill_codes[counter].priority = bim.bim1_int,
       bi_info->bill_items[d.seq].bill_codes[counter].bill_code_desc = bim.key7, bi_info->bill_items[
       d.seq].bill_code_qual = counter, bi_info->bill_items[d.seq].bill_codes[counter].
       beg_effective_dt_tm = bim.beg_effective_dt_tm,
       bi_info->bill_items[d.seq].bill_codes[counter].end_effective_dt_tm = bim.end_effective_dt_tm
      WITH nocounter
     ;end select
    ENDIF
    FOR (i = 1 TO value(size(bi_info->bill_items,5)))
      SET price_count = 0
      SET bill_ocde_count = 0
      SET price_count = bi_info->bill_items[i].price_qual
      SET bill_code_count = bi_info->bill_items[i].bill_code_qual
      IF (price_count > bill_code_count)
       SET bi_counter += price_count
      ELSEIF (bill_code_count > 0)
       SET bi_counter += bill_code_count
      ELSE
       SET bi_counter += 1
      ENDIF
    ENDFOR
    IF (bi_counter > 15000)
     SET file_count += 1
     SET file_name2 = build(file_name,cnvtstring(file_count))
     CALL echo(build("the new file name is : ",file_name2))
     SET bi_counter = 0
    ENDIF
    SET activity_type = fillstring(50," ")
    SET bill_item_id = fillstring(50," ")
    SET p_ref_id = fillstring(50," ")
    SET c_ref_id = fillstring(50," ")
    SET desc = fillstring(205," ")
    SET first_time_in_detail = 1
    IF (choice=1)
     SET psi_id = fillstring(50," ")
     SET price_sched = fillstring(205," ")
     SET price = fillstring(50," ")
     SET price_beg_dt_tm = fillstring(30," ")
     SET price_end_dt_tm = fillstring(30," ")
     SET bim_id = fillstring(50," ")
     SET bill_code_sched = fillstring(45," ")
     SET bill_code = fillstring(205," ")
     SET bill_code_desc = fillstring(205," ")
     SET pri = fillstring(10," ")
     SET bill_code_beg_dt_tm = fillstring(30," ")
     SET bill_code_end_dt_tm = fillstring(30," ")
     SET price_count = 0
     SET bill_ocde_count = 0
     SELECT INTO value(file_name2)
      FROM (dummyt d1  WITH seq = value(size(bi_info->bill_items,5)))
      HEAD REPORT
       IF (first_time=1)
        col 0, "Activity_Type", ",",
        "Bill_Item_Id", ",", "Parent_Ref_Id",
        ",", "Child_Ref_id", ",",
        "Description", ",", "Price_Sched_Items_Id",
        ",", "Price_Sched", ",",
        "Price", ",", "Price_Beg_Effective_Dt_Tm",
        ",", "Price_End_Effective_Dt_Tm", ",",
        "Bill_Item_Mod_Id", ",", "Bill_Code_Sched",
        ",", "Bill_Code", ",",
        "Bill_Code_Desc", ",", "Priority",
        ",", "Bill_Code_Beg_Effective_Dt_Tm", ",",
        "Bill_Code_End_Effective_Dt_Tm"
       ENDIF
      DETAIL
       price_count = bi_info->bill_items[d1.seq].price_qual, bill_code_count = bi_info->bill_items[d1
       .seq].bill_code_qual, line = fillstring(800," ")
       IF (price_count=0
        AND bill_code_count=0)
        activity_type = build('"',trim(bi_info->bill_items[d1.seq].ext_owner_cd),'"',","),
        bill_item_id = build(bi_info->bill_items[d1.seq].bill_item_id,","), p_ref_id = build(bi_info
         ->bill_items[d1.seq].ext_parent_reference_id,","),
        c_ref_id = build(bi_info->bill_items[d1.seq].ext_child_reference_id,","), desc = build('"',
         trim(bi_info->bill_items[d1.seq].ext_description),'"',","), psi_id = ",",
        price_sched = ",", price = ",", price_beg_dt_tm = ",",
        price_end_dt_tm = ",", bim_id = ",", bill_code_sched = ",",
        bill_code = ",", bill_code_desc = ",", pri = ",",
        bill_code_beg_dt_tm = ",", bill_code_end_dt_tm = ",", line = concat(trim(activity_type),trim(
          bill_item_id),trim(p_ref_id)),
        line = concat(trim(line),trim(c_ref_id),trim(desc),trim(psi_id)), line = concat(trim(line),
         trim(price_sched),trim(price)), line = concat(trim(line),trim(price_beg_dt_tm),trim(
          price_end_dt_tm),trim(bim_id)),
        line = concat(trim(line),trim(bill_code_sched),trim(bill_code)), line = concat(trim(line),
         trim(bill_code_desc),trim(pri)), line = concat(trim(line),trim(bill_code_beg_dt_tm),trim(
          bill_code_end_dt_tm))
        IF (first_time=0
         AND first_time_in_detail=1)
         line
        ELSE
         row + 1, line
        ENDIF
        first_time_in_detail = 0
       ELSEIF (price_count > bill_code_count)
        FOR (i = 1 TO price_count)
          line = fillstring(800," "), activity_type = build('"',trim(bi_info->bill_items[d1.seq].
            ext_owner_cd),'"',","), bill_item_id = build(bi_info->bill_items[d1.seq].bill_item_id,","
           ),
          p_ref_id = build(bi_info->bill_items[d1.seq].ext_parent_reference_id,","), c_ref_id = build
          (bi_info->bill_items[d1.seq].ext_child_reference_id,","), desc = build('"',trim(bi_info->
            bill_items[d1.seq].ext_description),'"',","),
          psi_id = build(bi_info->bill_items[d1.seq].prices[i].psi_id,","), price_sched = build('"',
           trim(bi_info->bill_items[d1.seq].prices[i].price_sched),'"',","), price = build(bi_info->
           bill_items[d1.seq].prices[i].price,","),
          price_beg_dt_tm = build(format(bi_info->bill_items[d1.seq].prices[i].beg_effective_dt_tm,
            "MM/DD/YYYY HH:MM:SS;;D"),","), price_end_dt_tm = build(format(bi_info->bill_items[d1.seq
            ].prices[i].end_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),",")
          IF (i <= bill_code_count)
           bim_id = build(bi_info->bill_items[d1.seq].bill_codes[i].bim_id,","), bill_code_sched =
           build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code_sched),'"',","),
           bill_code = build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code),'"',","),
           bill_code_desc = build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code_desc),
            '"',","), pri = build(bi_info->bill_items[d1.seq].bill_codes[i].priority,",")
          ELSE
           bim_id = ",", bill_code_sched = ",", bill_code = ",",
           bill_code_desc = ",", pri = ","
          ENDIF
          line = concat(trim(activity_type),trim(bill_item_id),trim(p_ref_id)), line = concat(trim(
            line),trim(c_ref_id),trim(desc),trim(psi_id)), line = concat(trim(line),trim(price_sched),
           trim(price)),
          line = concat(trim(line),trim(price_beg_dt_tm),trim(price_end_dt_tm),trim(bim_id)), line =
          concat(trim(line),trim(bill_code_sched),trim(bill_code)), line = concat(trim(line),trim(
            bill_code_desc),trim(pri)),
          line = concat(trim(line),trim(bill_code_beg_dt_tm),trim(bill_code_end_dt_tm))
          IF (first_time=0
           AND first_time_in_detail=1)
           line
          ELSE
           row + 1, line
          ENDIF
          first_time_in_detail = 0
        ENDFOR
       ELSE
        FOR (i = 1 TO bill_code_count)
          line = fillstring(800," "), activity_type = build('"',trim(bi_info->bill_items[d1.seq].
            ext_owner_cd),'"',","), bill_item_id = build(bi_info->bill_items[d1.seq].bill_item_id,","
           ),
          p_ref_id = build(bi_info->bill_items[d1.seq].ext_parent_reference_id,","), c_ref_id = build
          (bi_info->bill_items[d1.seq].ext_child_reference_id,","), desc = build('"',trim(bi_info->
            bill_items[d1.seq].ext_description),'"',","),
          bim_id = build(bi_info->bill_items[d1.seq].bill_codes[i].bim_id,","), bill_code_sched =
          build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code_sched),'"',","),
          bill_code = build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code),'"',","),
          bill_code_desc = build('"',trim(bi_info->bill_items[d1.seq].bill_codes[i].bill_code_desc),
           '"',","), pri = build(bi_info->bill_items[d1.seq].bill_codes[i].priority,","),
          bill_code_beg_dt_tm = build(format(bi_info->bill_items[d1.seq].bill_codes[i].
            beg_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),","),
          bill_code_end_dt_tm = build(format(bi_info->bill_items[d1.seq].bill_codes[i].
            end_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),",")
          IF (i <= price_count)
           psi_id = build(bi_info->bill_items[d1.seq].prices[i].psi_id,","), price_sched = build('"',
            trim(bi_info->bill_items[d1.seq].prices[i].price_sched),'"',","), price = build(bi_info->
            bill_items[d1.seq].prices[i].price,","),
           price_beg_dt_tm = build(format(bi_info->bill_items[d1.seq].prices[i].beg_effective_dt_tm,
             "MM/DD/YYYY HH:MM:SS;;D"),","), price_end_dt_tm = build(format(bi_info->bill_items[d1
             .seq].prices[i].end_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),",")
          ELSE
           psi_id = ",", price_sched = ",", price = ","
          ENDIF
          line = concat(trim(activity_type),trim(bill_item_id),trim(p_ref_id)), line = concat(trim(
            line),trim(c_ref_id),trim(desc),trim(psi_id)), line = concat(trim(line),trim(price_sched),
           trim(price)),
          line = concat(trim(line),trim(price_beg_dt_tm),trim(price_end_dt_tm),trim(bim_id)), line =
          concat(trim(line),trim(bill_code_sched),trim(bill_code)), line = concat(trim(line),trim(
            bill_code_desc),trim(pri)),
          line = concat(trim(line),trim(bill_code_beg_dt_tm),trim(bill_code_end_dt_tm))
          IF (first_time=0
           AND first_time_in_detail=1)
           line
          ELSE
           row + 1, line
          ENDIF
          first_time_in_detail = 0
        ENDFOR
       ENDIF
      WITH maxcol = 1000, append, maxrow = 15000
     ;end select
     SET first_time = 0
    ELSE
     SELECT INTO value(file_name2)
      FROM (dummyt d1  WITH seq = value(size(bi_info->bill_items,5)))
      HEAD REPORT
       IF (first_time=1)
        col 0, "Activity_Type", ",",
        "Bill_Item_Id", ",", "Parent_Ref_Id",
        ",", "Child_Ref_id", ",",
        "Description", ",", "Price_Sched_Items_Id",
        ",", "Price_Sched", ",",
        "Price", ",", "Price_Beg_Effective_Dt_Tm",
        ",", "Price_End_Effective_Dt_Tm", ",",
        "Bill_Item_Mod_Id", ",", "Bill_Code_Sched",
        ",", "Bill_Code", ",",
        "Bill_Code_Desc", ",", "Priority",
        ",", "Bill_Code_Beg_Effective_Dt_Tm", ",",
        "Bill_Code_End_Effective_Dt_Tm"
       ENDIF
      DETAIL
       line = fillstring(800," "), activity_type = build('"',trim(bi_info->bill_items[d1.seq].
         ext_owner_cd),'"',","), bill_item_id = build(bi_info->bill_items[d1.seq].bill_item_id,","),
       p_ref_id = build(bi_info->bill_items[d1.seq].ext_parent_reference_id,","), c_ref_id = build(
        bi_info->bill_items[d1.seq].ext_child_reference_id,","), desc = build('"',trim(bi_info->
         bill_items[d1.seq].ext_description),'"',","),
       psi_id = ",", price_sched = ",", price = ",",
       price_beg_dt_tm = ",", price_end_dt_tm = ",", bim_id = ",",
       bill_code_sched = ",", bill_code = ",", bill_code_desc = ",",
       pri = ",", bill_code_beg_dt_tm = ",", bill_code_end_dt_tm = ",",
       line = concat(trim(activity_type),trim(bill_item_id),trim(p_ref_id)), line = concat(trim(line),
        trim(c_ref_id),trim(desc),trim(psi_id)), line = concat(trim(line),trim(price_sched),trim(
         price),trim(bim_id)),
       line = concat(trim(line),trim(bill_code_sched),trim(bill_code)), line = concat(trim(line),trim
        (bill_code_desc),trim(pri)), line = concat(trim(line),trim(price_beg_dt_tm),trim(
         price_end_dt_tm)),
       line = concat(trim(line),trim(bill_code_beg_dt_tm),trim(bill_code_end_dt_tm))
       IF (first_time=0
        AND first_time_in_detail=1)
        line
       ELSE
        row + 1, line
       ENDIF
       first_time_in_detail = 0
      WITH maxcol = 1000, append, maxrow = 15000
     ;end select
     SET first_time = 0
    ENDIF
   ENDIF
 ENDWHILE
#exit_script
END GO
