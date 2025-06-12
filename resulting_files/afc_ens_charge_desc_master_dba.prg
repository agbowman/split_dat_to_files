CREATE PROGRAM afc_ens_charge_desc_master:dba
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
 CALL beginservice("CHARGSRV-14226.006")
 IF ( NOT (validate(reply->status_data.status)))
  RECORD reply(
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
 ENDIF
 RECORD addcdmrequest(
   1 charge_desc_master_qual = i4
   1 charge_desc_master[*]
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
 RECORD addcdmreply(
   1 charge_desc_master_qual = i4
   1 charge_desc_master[*]
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD updatecdmrequest(
   1 charge_desc_master[*]
     2 cdm_id = f8
     2 cdm_code = vc
     2 description = vc
     2 updt_cnt = i4
 ) WITH protect
 RECORD updatecdmreply(
   1 charge_desc_master[*]
     2 cdm_id = f8
     2 cdm_code = vc
     2 issue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD synccdmrequest(
   1 charge_desc_master_qual = i4
   1 charge_desc_master[*]
     2 cdm_id = vc
     2 cdm_code = vc
     2 description = vc
     2 service_type = i2
     2 logical_domain_id = f8
   1 asynctoggle = i2
 ) WITH protect
 RECORD synccdmreply(
   1 charge_desc_master_qual = i4
   1 charge_desc_master[*]
     2 cdm_id = vc
     2 cdm_code = vc
     2 description = vc
     2 service_type = i2
     2 status_code = i2
     2 issue = vc
     2 logical_domain_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE updatereplywitherroredstatus(null) = null
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE isrevelateenabled = i2 WITH protect, noconstant(false)
 DECLARE isserviceitemmasterfilesyncenabled = i2 WITH protect, noconstant(false)
 DECLARE asyncind = i2 WITH protect, noconstant(false)
 DECLARE no_service_type = i2 WITH protect, constant(0)
 DECLARE technical_service_type = i2 WITH protect, constant(1)
 DECLARE professional_service_type = i2 WITH protect, constant(2)
 DECLARE statuscode_ok = i2 WITH protect, constant(200)
 DECLARE success_status_flag = i2 WITH protect, constant(1)
 DECLARE pending_status_flag = i2 WITH protect, constant(2)
 DECLARE duplicate_status_flag = i2 WITH protect, constant(3)
 DECLARE invalid_cdm_code_status_flag = i2 WITH protect, constant(4)
 DECLARE invalid_cdm_desc_status_flag = i2 WITH protect, constant(5)
 DECLARE invalid_cdm_serv_type_status_flag = i2 WITH protect, constant(6)
 DECLARE error_status_flag = i2 WITH protect, constant(7)
 DECLARE afc_sync_non_200_status_flag = i2 WITH protect, constant(8)
 DECLARE add_action_type = vc WITH protect, constant("ADD")
 DECLARE update_action_type = vc WITH protect, constant("UPT")
 DECLARE invalid_cdm_code_status = vc WITH protect, constant("INVALID CDM CODE")
 DECLARE invalid_cdm_description_status = vc WITH protect, constant("INVALID CDM DESCRIPTION")
 DECLARE invalid_cdm_service_type_status = vc WITH protect, constant("INVALID CDM SERVICE TYPE")
 DECLARE duplicate_cdm_status = vc WITH protect, constant("DUPLICATE")
 DECLARE pending_cdm_status = vc WITH protect, constant("PENDING")
 DECLARE success_cdm_status = vc WITH protect, constant("SUCCESS")
 DECLARE error_cdm_status = vc WITH protect, constant("ERROR")
 DECLARE revelate_system_identifier = vc WITH protect, constant("urn:cerner:revelate")
 DECLARE revelate_enabled_toggle_name = vc WITH protect, constant("urn:cerner:revelate:enable")
 DECLARE service_item_master_file_sync_toggle_name = vc WITH protect, constant(
  "urn:cerner:revelate:service-item-master-file")
 IF (size(request->charge_desc_master,5)=0)
  CALL exitservicefailure("Request contains no CDM's to be persisted",go_to_exit_script)
 ENDIF
 IF ( NOT (getlogicaldomain(ld_concept_person,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID",go_to_exit_script)
 ENDIF
 IF ( NOT (initializereplycdmlist(logicaldomainid)))
  CALL exitservicefailure("CDM list contains an invalid action_type",go_to_exit_script)
 ENDIF
 IF ( NOT (checkfeaturetoggle(revelate_enabled_toggle_name,revelate_system_identifier,
  isrevelateenabled)))
  CALL logmessage("checkFeatureToggle",build("Failed to get Feature Toggle details : ",
    revelate_enabled_toggle_name),log_debug)
 ENDIF
 IF ( NOT (checkfeaturetoggle(service_item_master_file_sync_toggle_name,revelate_system_identifier,
  isserviceitemmasterfilesyncenabled)))
  CALL logmessage("checkFeatureToggle",build("Failed to get Feature Toggle details : ",
    service_item_master_file_sync_toggle_name),log_debug)
 ENDIF
 IF ( NOT (validaterequest(logicaldomainid,isrevelateenabled,isserviceitemmasterfilesyncenabled)))
  CALL exitservicefailure("Request validation failed",go_to_exit_script)
 ENDIF
 IF ( NOT (addchargedescmaster(logicaldomainid)))
  CALL exitservicefailure("Failed to persist CDM's",go_to_exit_script)
 ENDIF
 IF ( NOT (updatechargedescmaster(logicaldomainid)))
  CALL exitservicefailure("Failed to update CDM's",go_to_exit_script)
 ENDIF
 IF (isrevelateenabled
  AND isserviceitemmasterfilesyncenabled)
  IF ( NOT (syncchargedescmastertosf(asyncind)))
   CALL exitservicefailure("Failed to sync CDM's to SF",go_to_exit_script)
  ENDIF
 ENDIF
 CALL exitservicesuccess("")
 SUBROUTINE (validaterequest(plogicaldomainid=f8,pisrevelateenabled=i2,
  pisserviceitemmasterfilesyncenabled=i2) =i2)
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE cdmcode = vc WITH protect, noconstant("")
   DECLARE description = vc WITH protect, noconstant("")
   DECLARE action = c3 WITH protect, noconstant("")
   DECLARE servicetype = i2 WITH protect, noconstant(0)
   DECLARE failedind = i2 WITH protect, noconstant(false)
   DECLARE violationfound = i2 WITH protect, noconstant(false)
   FOR (cdmindex = 1 TO size(request->charge_desc_master,5))
     SET cdmcode = validate(request->charge_desc_master[cdmindex].cdm_code,"")
     SET description = validate(request->charge_desc_master[cdmindex].description,"")
     SET servicetype = validate(request->charge_desc_master[cdmindex].service_type,no_service_type)
     SET action = request->charge_desc_master[cdmindex].action_type
     SET violationfound = false
     IF (trim(cdmcode,3)="")
      CALL updatecdmissueinreply(cdmcode,invalid_cdm_code_status,invalid_cdm_code_status_flag)
      SET failedind = true
      SET violationfound = true
     ENDIF
     IF ( NOT (violationfound)
      AND trim(description,3)="")
      CALL updatecdmissueinreply(cdmcode,invalid_cdm_description_status,invalid_cdm_desc_status_flag)
      SET failedind = true
      SET violationfound = true
     ENDIF
     IF ( NOT (violationfound)
      AND pisrevelateenabled
      AND pisserviceitemmasterfilesyncenabled
      AND  NOT (servicetype IN (technical_service_type, professional_service_type)))
      CALL updatecdmissueinreply(cdmcode,invalid_cdm_service_type_status,
       invalid_cdm_serv_type_status_flag)
      SET failedind = true
     ELSEIF ( NOT (violationfound)
      AND (( NOT (pisrevelateenabled)) OR ( NOT (pisserviceitemmasterfilesyncenabled)))
      AND  NOT (servicetype IN (no_service_type, technical_service_type, professional_service_type)))
      CALL updatecdmissueinreply(cdmcode,invalid_cdm_service_type_status,
       invalid_cdm_serv_type_status_flag)
      SET failedind = true
     ENDIF
   ENDFOR
   IF (failedind)
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(request->charge_desc_master,5)),
     charge_desc_master cdm
    PLAN (d1
     WHERE (request->charge_desc_master[d1.seq].cdm_code != "")
      AND (request->charge_desc_master[d1.seq].action_type=add_action_type))
     JOIN (cdm
     WHERE (cdm.cdm_code_txt=request->charge_desc_master[d1.seq].cdm_code)
      AND cdm.logical_domain_id=plogicaldomainid
      AND cdm.active_ind=true)
    DETAIL
     IF (cdm.charge_desc_master_id > 0.0)
      CALL updatecdmissueinreply(request->charge_desc_master[d1.seq].cdm_code,duplicate_cdm_status,
      duplicate_status_flag), failedind = true
     ENDIF
    WITH nocounter
   ;end select
   IF (failedind)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (checkfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc,prisfeatureenabled=i2(ref)
  ) =i2)
   RECORD featuretogglerequest(
     1 togglename = vc
     1 username = vc
     1 positioncd = f8
     1 systemidentifier = vc
     1 solutionname = vc
   ) WITH protect
   RECORD featuretogglereply(
     1 togglename = vc
     1 isenabled = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET featuretogglerequest->togglename = pfeaturetogglekey
   SET featuretogglerequest->systemidentifier = psystemidentifier
   EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
    featuretogglereply)
   IF ((featuretogglereply->status_data.status="S"))
    SET prisfeatureenabled = featuretogglereply->isenabled
    CALL logmessage("checkFeatureToggle",build("Feature Toggle of ",pfeaturetogglekey," : ",
      prisfeatureenabled),log_debug)
   ELSE
    CALL logmessage("checkFeatureToggle","Call to sys_check_feature_toggle failed",log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updatecdmissueinreply(pcdmcode=vc,pissue=vc,pstatusflag=i4) =null)
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE cdmlocation = i4 WITH protect, noconstant(0)
   SET cdmlocation = locateval(cdmindex,1,size(reply->charge_desc_master,5),pcdmcode,reply->
    charge_desc_master[cdmindex].cdm_code)
   IF (cdmlocation > 0)
    SET reply->charge_desc_master[cdmlocation].issue = pissue
    SET reply->charge_desc_master[cdmlocation].status_flag = pstatusflag
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializereplycdmlist(plogicaldomainid=f8) =i2)
   DECLARE cdm_count = i4 WITH protect, constant(size(request->charge_desc_master,5))
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->charge_desc_master,cdm_count)
   FOR (cdmindex = 1 TO cdm_count)
     IF ( NOT (validate(request->charge_desc_master[cdmindex].action_type,"") IN (add_action_type,
     update_action_type)))
      RETURN(false)
     ENDIF
     SET reply->charge_desc_master[cdmindex].cdm_code = validate(request->charge_desc_master[cdmindex
      ].cdm_code,"")
     SET reply->charge_desc_master[cdmindex].description = validate(request->charge_desc_master[
      cdmindex].description,"")
     SET reply->charge_desc_master[cdmindex].logical_domain_id = plogicaldomainid
     SET reply->charge_desc_master[cdmindex].action_type = request->charge_desc_master[cdmindex].
     action_type
     SET reply->charge_desc_master[cdmindex].issue = pending_cdm_status
     SET reply->charge_desc_master[cdmindex].status_flag = pending_status_flag
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE updatereplywitherroredstatus(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(reply->charge_desc_master,5))
    WHERE (reply->charge_desc_master[d1.seq].action_type IN (add_action_type, update_action_type))
     AND (reply->charge_desc_master[d1.seq].issue IN (pending_cdm_status, success_cdm_status))
     AND (reply->charge_desc_master[d1.seq].status_flag IN (pending_status_flag, success_status_flag)
    )
    DETAIL
     reply->charge_desc_master[d1.seq].issue = "", reply->charge_desc_master[d1.seq].status_flag =
     error_status_flag
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (addchargedescmaster(plogicaldomainid=f8) =i2)
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE addcount = i4 WITH protect, noconstant(0)
   FOR (cdmindex = 1 TO size(request->charge_desc_master,5))
     IF ((request->charge_desc_master[cdmindex].action_type=add_action_type))
      SET addcount = (size(addcdmrequest->charge_desc_master,5)+ 1)
      SET stat = alterlist(addcdmrequest->charge_desc_master,addcount)
      SET addcdmrequest->charge_desc_master[addcount].cdm_code = trim(request->charge_desc_master[
       cdmindex].cdm_code,3)
      SET addcdmrequest->charge_desc_master[addcount].description = trim(request->charge_desc_master[
       cdmindex].description,3)
      SET addcdmrequest->charge_desc_master[addcount].service_type = request->charge_desc_master[
      cdmindex].service_type
      SET addcdmrequest->charge_desc_master[addcount].logical_domain_id = plogicaldomainid
     ENDIF
   ENDFOR
   IF (size(addcdmrequest->charge_desc_master,5) > 0)
    EXECUTE afc_add_charge_desc_master  WITH replace("REQUEST",addcdmrequest), replace("REPLY",
     addcdmreply)
    IF ( NOT (verifyreplyfromadd(addcdmrequest,addcdmreply)))
     CALL logmessage("addChargeDescMaster","afc_add_charge_desc_master returned failure",log_error)
     RETURN(false)
    ENDIF
    CALL addcdmstosyncrequest(addcdmreply)
    FOR (cdmindex = 1 TO size(addcdmreply->charge_desc_master,5))
      CALL updatecdmissueinreply(addcdmreply->charge_desc_master[cdmindex].cdm_code,
       success_cdm_status,success_status_flag)
    ENDFOR
    RETURN(true)
   ENDIF
   CALL logmessage("addChargeDescMaster","No CDM's need to be added",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updatechargedescmaster(plogicaldomainid=f8) =i2)
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE uptcount = i4 WITH protect, noconstant(0)
   DECLARE synccount = i4 WITH protect, noconstant(0)
   DECLARE failedind = i2 WITH protect, noconstant(0)
   FOR (cdmindex = 1 TO size(request->charge_desc_master,5))
     IF ((request->charge_desc_master[cdmindex].action_type=update_action_type))
      SELECT INTO "nl:"
       FROM charge_desc_master cdm
       WHERE (cdm.charge_desc_master_id=request->charge_desc_master[cdmindex].cdm_id)
        AND cdm.cdm_code_txt=trim(request->charge_desc_master[cdmindex].cdm_code,3)
        AND cdm.logical_domain_id=plogicaldomainid
        AND cdm.active_ind=true
       DETAIL
        IF (cdm.description != trim(request->charge_desc_master[cdmindex].description,3))
         uptcount = (size(updatecdmrequest->charge_desc_master,5)+ 1), stat = alterlist(
          updatecdmrequest->charge_desc_master,uptcount), updatecdmrequest->charge_desc_master[
         uptcount].cdm_id = request->charge_desc_master[cdmindex].cdm_id,
         updatecdmrequest->charge_desc_master[uptcount].cdm_code = trim(request->charge_desc_master[
          cdmindex].cdm_code,3), updatecdmrequest->charge_desc_master[uptcount].description = trim(
          request->charge_desc_master[cdmindex].description,3), updatecdmrequest->charge_desc_master[
         uptcount].updt_cnt = cdm.updt_cnt
        ENDIF
        synccount = (size(synccdmrequest->charge_desc_master,5)+ 1), stat = alterlist(synccdmrequest
         ->charge_desc_master,synccount), synccdmrequest->charge_desc_master[synccount].cdm_id =
        cnvtstring(request->charge_desc_master[cdmindex].cdm_id),
        synccdmrequest->charge_desc_master[synccount].cdm_code = trim(request->charge_desc_master[
         cdmindex].cdm_code,3), synccdmrequest->charge_desc_master[synccount].description = trim(
         request->charge_desc_master[cdmindex].description,3), synccdmrequest->charge_desc_master[
        synccount].service_type = request->charge_desc_master[cdmindex].service_type,
        synccdmrequest->charge_desc_master[synccount].logical_domain_id = request->
        charge_desc_master[cdmindex].logical_domain_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL updatecdmissueinreply(request->charge_desc_master[cdmindex].cdm_code,"Invalid Update",
        error_status_flag)
       SET failedind = true
      ENDIF
     ENDIF
   ENDFOR
   IF (failedind)
    CALL logmessage("updateChargeDescMaster","Invalid updates found",log_error)
    CALL updatereplywitherroredstatus(null)
    RETURN(false)
   ENDIF
   IF (size(updatecdmrequest->charge_desc_master,5) > 0)
    EXECUTE afc_upt_charge_desc_master  WITH replace("REQUEST",updatecdmrequest), replace("REPLY",
     updatecdmreply)
    IF ( NOT (verifyreplyfromupdate(updatecdmreply)))
     CALL logmessage("updateChargeDescMaster","afc_upt_charge_desc_master returned failure",log_error
      )
     CALL updatereplywitherroredstatus(null)
     RETURN(false)
    ENDIF
    FOR (cdmindex = 1 TO size(updatecdmreply->charge_desc_master,5))
      CALL updatecdmissueinreply(updatecdmreply->charge_desc_master[cdmindex].cdm_code,
       success_cdm_status,success_status_flag)
    ENDFOR
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (verifyreplyfromadd(praddcdmrequest=vc(ref),praddcdmreply=vc(ref)) =i2)
   DECLARE add_reply_size = i4 WITH protect, constant(size(praddcdmreply->charge_desc_master,5))
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE issuestring = vc WITH protect, noconstant("")
   IF ((praddcdmreply->status_data.status="F"))
    IF (validate(debug,false))
     CALL echorecord(praddcdmrequest)
     CALL echorecord(praddcdmreply)
    ENDIF
    FOR (cdmindex = 1 TO size(praddcdmrequest->charge_desc_master,5))
      CALL updatecdmissueinreply(praddcdmrequest->charge_desc_master[cdmindex].cdm_code,issuestring,
       error_status_flag)
    ENDFOR
    CASE (praddcdmreply->status_data.subeventstatus[1].operationname)
     OF "GEN_NBR":
      SET issuestring = "Primary Key Generation Error"
     OF "INSERT":
      SET issuestring = "Insert Error"
     ELSE
      SET issuestring = ""
    ENDCASE
    IF (add_reply_size=0)
     CALL updatecdmissueinreply(praddcdmrequest->charge_desc_master[1].cdm_code,issuestring,
      error_status_flag)
    ENDIF
    IF (size(praddcdmrequest->charge_desc_master,5) != add_reply_size)
     CALL updatecdmissueinreply(praddcdmrequest->charge_desc_master[(add_reply_size+ 1)].cdm_code,
      issuestring,error_status_flag)
    ENDIF
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (verifyreplyfromupdate(prupdatecdmreply=vc(ref)) =i2)
   DECLARE upt_reply_size = i4 WITH protect, constant(size(prupdatecdmreply->charge_desc_master,5))
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE issuestring = vc WITH protect, noconstant("")
   IF ((prupdatecdmreply->status_data.status="F"))
    IF (validate(debug,false))
     CALL echorecord(prupdatecdmreply)
    ENDIF
    FOR (cdmindex = 1 TO upt_reply_size)
     CASE (prupdatecdmreply->charge_desc_master[cdmindex].issue)
      OF "UPDATE":
       SET issuestring = "Update Error"
      OF "ATTRIBUTE":
       SET issuestring = "Attribute Error"
      OF "LOCK":
       SET issuestring = "Lock Error"
      ELSE
       SET issuestring = ""
     ENDCASE
     CALL updatecdmissueinreply(prupdatecdmreply->charge_desc_master[cdmindex].cdm_code,issuestring,
      error_status_flag)
    ENDFOR
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (addcdmstosyncrequest(prcdmstobesynced=vc(ref)) =null)
   DECLARE cdm_count = i4 WITH protect, constant(size(prcdmstobesynced->charge_desc_master,5))
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE synccount = i4 WITH protect, noconstant(0)
   FOR (cdmindex = 1 TO cdm_count)
     SET synccount = (size(synccdmrequest->charge_desc_master,5)+ 1)
     SET stat = alterlist(synccdmrequest->charge_desc_master,synccount)
     SET synccdmrequest->charge_desc_master[synccount].cdm_id = cnvtstring(prcdmstobesynced->
      charge_desc_master[cdmindex].cdm_id)
     SET synccdmrequest->charge_desc_master[synccount].cdm_code = trim(prcdmstobesynced->
      charge_desc_master[cdmindex].cdm_code,3)
     SET synccdmrequest->charge_desc_master[synccount].description = trim(prcdmstobesynced->
      charge_desc_master[cdmindex].description,3)
     SET synccdmrequest->charge_desc_master[synccount].service_type = prcdmstobesynced->
     charge_desc_master[cdmindex].service_type
     SET synccdmrequest->charge_desc_master[synccount].logical_domain_id = prcdmstobesynced->
     charge_desc_master[cdmindex].logical_dom
   ENDFOR
 END ;Subroutine
 SUBROUTINE (verifyreplyfromsync(prsynccdmreply=vc(ref)) =i2)
   DECLARE sync_cdm_reply_size = i4 WITH protect, constant(size(prsynccdmreply->charge_desc_master,5)
    )
   DECLARE cdmindex = i4 WITH protect, noconstant(0)
   DECLARE failedind = i2 WITH protect, noconstant(false)
   IF (validate(debug,false))
    CALL echorecord(prsynccdmreply)
   ENDIF
   IF ((prsynccdmreply->status_data.status="F"))
    SET failedind = true
    FOR (cdmindex = 1 TO sync_cdm_reply_size)
      IF ((prsynccdmreply->charge_desc_master[cdmindex].status_code >= 400)
       AND (prsynccdmreply->charge_desc_master[cdmindex].status_code < 600))
       CALL updatecdmissueinreply(prsynccdmreply->charge_desc_master[cdmindex].cdm_code,trim(
         prsynccdmreply->charge_desc_master[cdmindex].issue,3),prsynccdmreply->charge_desc_master[
        cdmindex].status_code)
      ELSE
       CALL updatecdmissueinreply(prsynccdmreply->charge_desc_master[cdmindex].cdm_code,
        error_cdm_status,error_status_flag)
      ENDIF
    ENDFOR
   ELSE
    FOR (cdmindex = 1 TO sync_cdm_reply_size)
      IF ((prsynccdmreply->charge_desc_master[cdmindex].status_code=statuscode_ok))
       CALL updatecdmissueinreply(prsynccdmreply->charge_desc_master[cdmindex].cdm_code,
        success_cdm_status,success_status_flag)
      ELSEIF ((prsynccdmreply->charge_desc_master[cdmindex].status_code >= 400)
       AND (prsynccdmreply->charge_desc_master[cdmindex].status_code < 600))
       CALL updatecdmissueinreply(prsynccdmreply->charge_desc_master[cdmindex].cdm_code,trim(
         prsynccdmreply->charge_desc_master[cdmindex].issue,3),prsynccdmreply->charge_desc_master[
        cdmindex].status_code)
      ELSE
       SET failedind = true
       CALL updatecdmissueinreply(prsynccdmreply->charge_desc_master[cdmindex].cdm_code,trim(
         prsynccdmreply->charge_desc_master[cdmindex].issue,3),afc_sync_non_200_status_flag)
      ENDIF
    ENDFOR
   ENDIF
   IF (failedind)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (syncchargedescmastertosf(pisasync=i2) =i2)
   DECLARE cdm_count = i4 WITH protect, constant(size(synccdmrequest->charge_desc_master,5))
   IF (cdm_count=0)
    RETURN(true)
   ENDIF
   SET synccdmrequest->charge_desc_master_qual = cdm_count
   SET synccdmrequest->asynctoggle = pisasync
   EXECUTE afc_sync_cdm  WITH replace("REQUEST",synccdmrequest), replace("REPLY",synccdmreply)
   IF ( NOT (verifyreplyfromsync(synccdmreply)))
    CALL logmessage("syncChargeDescMasterToSF","Failed to sync CDM's to SF",log_error)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
#end_program
END GO
