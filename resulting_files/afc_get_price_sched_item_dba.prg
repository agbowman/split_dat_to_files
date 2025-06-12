CREATE PROGRAM afc_get_price_sched_item:dba
 IF ( NOT (validate(afc_get_price_sched_item_script_vrsn)))
  DECLARE afc_get_price_sched_item_script_vrsn = vc WITH constant("CHARGSRV-15278.015"), private
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
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 CALL beginservice(afc_get_price_sched_item_script_vrsn)
 IF (validate(reply->price_sched_items_qual,999)=999)
  RECORD reply(
    1 price_sched_items_qual = i4
    1 qual[*]
      2 price_sched_id = f8
      2 bill_item_id = f8
      2 price_sched_items_id = f8
      2 price = f8
      2 allowable = f8
      2 copay = f8
      2 deductible = f8
      2 percent_revenue = i4
      2 charge_level_cd = f8
      2 charge_level_disp = c40
      2 charge_level_desc = c60
      2 charge_level_mean = c12
      2 interval_template_cd = f8
      2 detail_charge_ind = f8
      2 price_sched_desc = c200
      2 tax = f8
      2 exclusive_ind = i2
      2 cost_adj_amt = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 updt_cnt = i2
      2 units_ind = i2
      2 stats_only_ind = f8
      2 billing_discount_priority = i4
      2 updt_id = vc
      2 updt_dt_tm = dq8
      2 price_sched_items_hist_id = f8
      2 history_ind = i2
      2 task_action_flag = i2
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD org_list(
   1 org_qual = i2
   1 org[*]
     2 organization_id = f8
 )
 RECORD sched_list(
   1 sched_qual = i2
   1 sched[*]
     2 price_sched_id = f8
 )
 FREE RECORD pricescheditems
 RECORD pricescheditems(
   1 price_sched_items_qual = i4
   1 qual[*]
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price = f8
     2 allowable = f8
     2 copay = f8
     2 deductible = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 charge_level_disp = c40
     2 charge_level_desc = c60
     2 charge_level_mean = c12
     2 interval_template_cd = f8
     2 detail_charge_ind = f8
     2 price_sched_desc = c200
     2 tax = f8
     2 exclusive_ind = i2
     2 cost_adj_amt = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 units_ind = i2
     2 stats_only_ind = f8
     2 billing_discount_priority = i4
     2 updt_id = vc
     2 updt_dt_tm = dq8
     2 price_sched_items_hist_id = f8
     2 history_ind = i2
     2 task_action_flag = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD pricescheditemshistory
 RECORD pricescheditemshistory(
   1 price_sched_items_hist_qual = i2
   1 price_sched_items_hist[*]
     2 price_sched_items_hist_id = f8
     2 price_sched_items_id = f8
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 modification_dt_tm = dq8
     2 updt_id = vc
     2 updt_task = f8
     2 updt_cnt = i2
 )
 IF (validate(getpricescheditemmodhistory,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF ( NOT (validate(price_sched_items_table_name)))
  DECLARE price_sched_items_table_name = vc WITH protect, constant("PRICE_SCHED_ITEMS")
 ENDIF
 IF ( NOT (validate(cs48_inactive_status_cd)))
  DECLARE cs48_inactive_status_cd = f8 WITH protect, constant(getcodevalue(48,nullterm("INACTIVE"),0)
   )
 ENDIF
 IF ((validate(failed,- (1))=- (1)))
  DECLARE failed = i2 WITH noconstant(0)
 ENDIF
 DECLARE iret = i4
 DECLARE null_code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 SET cdf_meaning = "NULL"
 SET code_set = 13020
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,null_code_value)
 DECLARE iret = i4
 DECLARE price_sched_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count = i4
 SET cdf_meaning = "PRICE_SCHED"
 SET code_set = 26078
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,price_sched_cd)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET cntorg = 0
 SET cntsched = 0
 DECLARE user_id = f8
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.username=request->user_name)
  DETAIL
   user_id = p.person_id
  WITH nocounter
 ;end select
 CALL echo(build("user_id: ",cnvtint(user_id)))
 SELECT INTO "nl:"
  FROM prsnl_org_reltn p
  WHERE p.person_id=user_id
   AND p.active_ind=1
   AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   cntorg += 1, stat = alterlist(org_list->org,cntorg), org_list->org[cntorg].organization_id = p
   .organization_id,
   org_list->org_qual = cntorg
  WITH nocounter
 ;end select
 CALL echo(build("cntorg: ",cntorg))
 FOR (i = 1 TO cntorg)
   CALL echo(build("org w/prsnl_id : ",org_list->org[i].organization_id))
 ENDFOR
 CALL echo(build("size of org: ",size(org_list->org,5)))
 CALL echo(build("curqual: ",curqual))
 SELECT INTO "nl:"
  FROM cs_org_reltn cs,
   (dummyt d  WITH seq = value(size(org_list->org,5)))
  PLAN (d)
   JOIN (cs
   WHERE (cs.organization_id=org_list->org[d.seq].organization_id)
    AND cs.cs_org_reltn_type_cd=price_sched_cd
    AND cs.active_ind=1)
  DETAIL
   cntsched += 1, stat = alterlist(sched_list->sched,cntsched), sched_list->sched[cntsched].
   price_sched_id = cs.key1_id,
   sched_list->sched_qual = cntsched
  WITH nocounter
 ;end select
 CALL echo(build("cntsched: ",cntsched))
 FOR (i = 1 TO cntsched)
   CALL echo(build("org w/sched_id: ",sched_list->sched[i].price_sched_id))
 ENDFOR
 CALL echo(build("size of sched: ",size(sched_list->sched,5)))
 IF ((request->sched_ind=1))
  SELECT INTO "nl:"
   p.price_sched_id, p.price_sched_desc
   FROM price_sched p
   WHERE p.active_ind=1
   ORDER BY p.price_sched_desc
   DETAIL
    count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].price_sched_desc = p
    .price_sched_desc,
    reply->qual[count1].price_sched_id = p.price_sched_id
   WITH nocounter
  ;end select
 ELSE
  IF ((request->siteprefs_ind=1))
   CASE (request->item_type)
    OF "P":
     SELECT DISTINCT INTO "nl:"
      p2.price_sched_desc, p.*, pr.name_full_formatted
      FROM price_sched_items p,
       (dummyt d  WITH seq = 1),
       price_sched p2,
       prsnl pr,
       (dummyt d1  WITH seq = value(size(sched_list->sched,5)))
      PLAN (d1)
       JOIN (p2
       WHERE p2.active_ind=1
        AND p2.pharm_ind=0
        AND (p2.price_sched_id=sched_list->sched[d1.seq].price_sched_id))
       JOIN (d
       WHERE d.seq=1)
       JOIN (p
       WHERE (p.bill_item_id=request->bill_item_id)
        AND p.price_sched_id=p2.price_sched_id
        AND p.end_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
        AND p.active_ind=1)
       JOIN (pr
       WHERE (pr.person_id= Outerjoin(p.updt_id)) )
      ORDER BY p2.price_sched_id, cnvtdatetime(p.beg_effective_dt_tm)
      DETAIL
       count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].price_sched_id = p2
       .price_sched_id,
       reply->qual[count1].bill_item_id = request->bill_item_id, reply->qual[count1].
       price_sched_items_id = p.price_sched_items_id, reply->qual[count1].price = p.price,
       reply->qual[count1].percent_revenue = p.percent_revenue, reply->qual[count1].charge_level_cd
        = p.charge_level_cd, reply->qual[count1].interval_template_cd = p.interval_template_cd,
       reply->qual[count1].detail_charge_ind = p.detail_charge_ind, reply->qual[count1].
       stats_only_ind = p.stats_only_ind, reply->qual[count1].tax = p.tax,
       reply->qual[count1].exclusive_ind = p.exclusive_ind, reply->qual[count1].cost_adj_amt = p
       .cost_adj_amt, reply->qual[count1].billing_discount_priority = p.billing_discount_priority_seq,
       reply->qual[count1].price_sched_desc = p2.price_sched_desc, reply->qual[count1].updt_cnt = p
       .updt_cnt, reply->qual[count1].units_ind = p.units_ind,
       reply->qual[count1].updt_id = pr.name_full_formatted, reply->qual[count1].updt_dt_tm = p
       .updt_dt_tm, reply->qual[count1].active_ind = p.active_ind,
       reply->qual[count1].price_sched_items_hist_id = 0, reply->qual[count1].history_ind = false
       IF ((reply->qual[count1].charge_level_cd=0))
        reply->qual[count1].charge_level_cd = null_code_value
       ENDIF
       reply->qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm
       IF (p.end_effective_dt_tm=cnvtdate2("31dec2100","DDMMMYYYY"))
        reply->qual[count1].end_effective_dt_tm = 0
       ELSE
        reply->qual[count1].end_effective_dt_tm = p.end_effective_dt_tm
       ENDIF
      WITH nocounter, outerjoin = d
     ;end select
    OF "C":
     SELECT DISTINCT INTO "nl:"
      p.*, pr.name_full_formatted
      FROM price_sched_items p,
       (dummyt d  WITH seq = 1),
       bill_item b,
       prsnl pr,
       (dummyt d1  WITH seq = value(size(sched_list->sched,5)))
      PLAN (d1)
       JOIN (b
       WHERE (b.ext_parent_reference_id=request->ext_parent_reference_id)
        AND b.ext_child_reference_id != 0
        AND b.active_ind=1)
       JOIN (d
       WHERE d.seq=1)
       JOIN (p
       WHERE p.bill_item_id=b.bill_item_id
        AND (p.price_sched_id=request->price_sched_id)
        AND (p.price_sched_id=sched_list->sched[d1.seq].price_sched_id)
        AND p.active_ind=1
        AND p.end_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm))
       JOIN (pr
       WHERE (pr.person_id= Outerjoin(p.updt_id)) )
      ORDER BY b.bill_item_id, cnvtdatetime(p.beg_effective_dt_tm)
      DETAIL
       count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].price_sched_id =
       request->price_sched_id,
       reply->qual[count1].bill_item_id = b.bill_item_id, reply->qual[count1].price_sched_items_id =
       p.price_sched_items_id, reply->qual[count1].price = p.price,
       reply->qual[count1].percent_revenue = p.percent_revenue, reply->qual[count1].charge_level_cd
        = p.charge_level_cd, reply->qual[count1].detail_charge_ind = p.detail_charge_ind,
       reply->qual[count1].stats_only_ind = p.stats_only_ind, reply->qual[count1].tax = p.tax, reply
       ->qual[count1].exclusive_ind = p.exclusive_ind,
       reply->qual[count1].cost_adj_amt = p.cost_adj_amt, reply->qual[count1].
       billing_discount_priority = p.billing_discount_priority_seq, reply->qual[count1].
       interval_template_cd = p.interval_template_cd,
       reply->qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->qual[count1].
       end_effective_dt_tm = p.end_effective_dt_tm, reply->qual[count1].updt_cnt = p.updt_cnt,
       reply->qual[count1].units_ind = p.units_ind, reply->qual[count1].updt_id = pr
       .name_full_formatted, reply->qual[count1].updt_dt_tm = p.updt_dt_tm,
       reply->qual[count1].active_ind = p.active_ind, reply->qual[count1].price_sched_items_hist_id
        = 0, reply->qual[count1].history_ind = false
       IF ((reply->qual[count1].charge_level_cd=0))
        reply->qual[count1].charge_level_cd = null_code_value
       ENDIF
      WITH nocounter, outerjoin = d
     ;end select
   ENDCASE
  ELSE
   CASE (request->item_type)
    OF "P":
     SELECT INTO "nl:"
      p2.price_sched_desc, p.*, pr.name_full_formatted
      FROM price_sched_items p,
       (dummyt d  WITH seq = 1),
       price_sched p2,
       prsnl pr
      PLAN (p2
       WHERE p2.active_ind=1
        AND p2.pharm_ind=0)
       JOIN (d
       WHERE d.seq=1)
       JOIN (p
       WHERE (p.bill_item_id=request->bill_item_id)
        AND p.price_sched_id=p2.price_sched_id
        AND p.end_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
        AND p.active_ind=1)
       JOIN (pr
       WHERE (pr.person_id= Outerjoin(p.updt_id)) )
      ORDER BY p2.price_sched_id, cnvtdatetime(p.beg_effective_dt_tm)
      DETAIL
       count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].price_sched_id = p2
       .price_sched_id,
       reply->qual[count1].bill_item_id = request->bill_item_id, reply->qual[count1].
       price_sched_items_id = p.price_sched_items_id, reply->qual[count1].price = p.price,
       reply->qual[count1].percent_revenue = p.percent_revenue, reply->qual[count1].charge_level_cd
        = p.charge_level_cd, reply->qual[count1].interval_template_cd = p.interval_template_cd,
       reply->qual[count1].detail_charge_ind = p.detail_charge_ind, reply->qual[count1].
       stats_only_ind = p.stats_only_ind, reply->qual[count1].tax = p.tax,
       reply->qual[count1].exclusive_ind = p.exclusive_ind, reply->qual[count1].cost_adj_amt = p
       .cost_adj_amt, reply->qual[count1].billing_discount_priority = p.billing_discount_priority_seq,
       reply->qual[count1].price_sched_desc = p2.price_sched_desc, reply->qual[count1].updt_cnt = p
       .updt_cnt, reply->qual[count1].units_ind = p.units_ind,
       reply->qual[count1].updt_id = pr.name_full_formatted, reply->qual[count1].updt_dt_tm = p
       .updt_dt_tm, reply->qual[count1].active_ind = p.active_ind,
       reply->qual[count1].price_sched_items_hist_id = 0, reply->qual[count1].history_ind = false
       IF ((reply->qual[count1].charge_level_cd=0))
        reply->qual[count1].charge_level_cd = null_code_value
       ENDIF
       reply->qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm
       IF (p.end_effective_dt_tm=cnvtdate2("31dec2100","DDMMMYYYY"))
        reply->qual[count1].end_effective_dt_tm = 0
       ELSE
        reply->qual[count1].end_effective_dt_tm = p.end_effective_dt_tm
       ENDIF
      WITH nocounter, outerjoin = d
     ;end select
    OF "C":
     SELECT INTO "nl:"
      p.*, pr.name_full_formatted
      FROM price_sched_items p,
       (dummyt d  WITH seq = 1),
       bill_item b,
       prsnl pr
      PLAN (b
       WHERE (b.ext_parent_reference_id=request->ext_parent_reference_id)
        AND b.ext_child_reference_id != 0
        AND b.active_ind=1)
       JOIN (d
       WHERE d.seq=1)
       JOIN (p
       WHERE p.bill_item_id=b.bill_item_id
        AND (p.price_sched_id=request->price_sched_id)
        AND p.active_ind=1
        AND p.end_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm))
       JOIN (pr
       WHERE (pr.person_id= Outerjoin(p.updt_id)) )
      ORDER BY b.bill_item_id, cnvtdatetime(p.beg_effective_dt_tm)
      DETAIL
       count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].price_sched_id =
       request->price_sched_id,
       reply->qual[count1].bill_item_id = b.bill_item_id, reply->qual[count1].price_sched_items_id =
       p.price_sched_items_id, reply->qual[count1].price = p.price,
       reply->qual[count1].percent_revenue = p.percent_revenue, reply->qual[count1].charge_level_cd
        = p.charge_level_cd, reply->qual[count1].detail_charge_ind = p.detail_charge_ind,
       reply->qual[count1].stats_only_ind = p.stats_only_ind, reply->qual[count1].tax = p.tax, reply
       ->qual[count1].exclusive_ind = p.exclusive_ind,
       reply->qual[count1].cost_adj_amt = p.cost_adj_amt, reply->qual[count1].
       billing_discount_priority = p.billing_discount_priority_seq, reply->qual[count1].
       interval_template_cd = p.interval_template_cd,
       reply->qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->qual[count1].
       end_effective_dt_tm = p.end_effective_dt_tm, reply->qual[count1].updt_cnt = p.updt_cnt,
       reply->qual[count1].units_ind = p.units_ind, reply->qual[count1].updt_id = pr
       .name_full_formatted, reply->qual[count1].updt_dt_tm = p.updt_dt_tm,
       reply->qual[count1].active_ind = p.active_ind, reply->qual[count1].price_sched_items_hist_id
        = 0, reply->qual[count1].history_ind = false
       IF ((reply->qual[count1].charge_level_cd=0))
        reply->qual[count1].charge_level_cd = null_code_value
       ENDIF
      WITH nocounter, outerjoin = d
     ;end select
   ENDCASE
  ENDIF
 ENDIF
 SET stat = alterlist(reply->qual,count1)
 SET reply->price_sched_items_qual = count1
 CALL echo(concat("count1: ",cnvtstring(count1)))
 IF (curqual=0)
  SET failed = false
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = price_sched_items_table_name
  SET reply->status_data.status = "Z"
 ELSE
  SET failed = false
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->history_enabled,0)=1)
  CALL getpricescheditemmodhistory(null)
  IF (failed != false)
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL exitservicesuccess(build(" version : ",afc_get_price_sched_item_script_vrsn))
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = price_sched_items_table_name
  SET reqinfo->commit_ind = false
 ENDIF
 SUBROUTINE (getpricescheditemmodhistory(dummyvar=i4) =null)
   IF ( NOT (validate(get_price_sched_items_hist_sub_name)))
    DECLARE get_price_sched_items_hist_sub_name = vc WITH protect, constant(
     "AFC_GET_PRICE_SCHED_ITEM.getPriceSchedItemModHistory")
   ENDIF
   IF ((validate(first_record,- (1))=- (1)))
    DECLARE first_rec = i2 WITH protect, constant(1)
   ENDIF
   IF ((validate(next_rec_move,- (1))=- (1)))
    DECLARE next_rec_move = i2 WITH protect, noconstant(0)
   ENDIF
   IF (size(reply->qual,5) > 0)
    SET reply->price_sched_items_qual = size(reply->qual,5)
   ENDIF
   IF ((validate(select_count,- (1))=- (1)))
    DECLARE select_count = i2 WITH protect, noconstant(0)
   ENDIF
   DECLARE num = i2 WITH protect, noconstant(0)
   SET stat = initrec(pricescheditemshistory)
   SET stat = initrec(pricescheditems)
   SELECT
    IF ( NOT ((request->price_sched_id IN (0, null))))
     WHERE (psi.bill_item_id=request->bill_item_id)
      AND (psi.price_sched_id=request->price_sched_id)
    ELSEIF ((request->siteprefs_ind=1))
     WHERE (psi.bill_item_id=request->bill_item_id)
      AND expand(num,1,size(sched_list->sched,5),psi.price_sched_id,sched_list->sched[num].
      price_sched_id)
    ELSE
     WHERE (psi.bill_item_id=request->bill_item_id)
    ENDIF
    INTO "nl:"
    psi.price_sched_items_id, psi.bill_item_id, psi.price_sched_id
    FROM price_sched_items psi
    DETAIL
     select_count += 1, pricescheditemshistory->price_sched_items_hist_qual = select_count, stat =
     alterlist(pricescheditemshistory->price_sched_items_hist,select_count),
     pricescheditemshistory->price_sched_items_hist[select_count].price_sched_items_id = psi
     .price_sched_items_id, pricescheditemshistory->price_sched_items_hist[select_count].bill_item_id
      = psi.bill_item_id, pricescheditemshistory->price_sched_items_hist[select_count].price_sched_id
      = psi.price_sched_id,
     pricescheditemshistory->price_sched_items_hist[select_count].updt_task = reqinfo->updt_task
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = false
    CALL logmessage(get_price_sched_items_hist_sub_name,
     "No Price Schedule Item modifications existed",log_info)
   ELSE
    SET failed = false
    SET reply->status_data.status = "S"
    CALL logmessage(get_price_sched_items_hist_sub_name,
     "Existing Price Schedule Item modifications fetched successfully!",log_info)
   ENDIF
   IF (size(pricescheditemshistory->price_sched_items_hist,5) > 0)
    EXECUTE afc_get_price_sched_item_hist  WITH replace("REQUEST",pricescheditemshistory), replace(
     "REPLY",pricescheditems)
   ENDIF
   SET next_rec_move = size(reply->qual,5)
   IF (size(pricescheditems->qual,5) > 0)
    SET rec_mov_stat = movereclist(pricescheditems->qual,reply->qual,1,next_rec_move,pricescheditems
     ->price_sched_items_qual,
     true)
    SET reply->price_sched_items_qual = size(reply->qual,5)
   ENDIF
 END ;Subroutine
#exit_script
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
END GO
