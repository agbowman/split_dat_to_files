CREATE PROGRAM afc_get_bill_item_modifier:dba
 IF ( NOT (validate(afc_get_bill_item_modifier_script_vrsn)))
  DECLARE afc_get_bill_item_modifier_script_vrsn = vc WITH constant("464331.000"), private
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
 CALL beginservice(afc_get_bill_item_modifier_script_vrsn)
 IF (validate(reply->bill_item_modifier_qual,999)=999)
  RECORD reply(
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[*]
      2 bill_item_mod_id = f8
      2 bill_item_id = f8
      2 bill_item_type_cd = f8
      2 bill_item_type_disp = c40
      2 bill_item_type_desc = c60
      2 bill_item_type_mean = c12
      2 key1_id = f8
      2 key2_id = f8
      2 key3_id = f8
      2 key4_id = f8
      2 key5_id = f8
      2 key6 = vc
      2 key7 = vc
      2 key8 = vc
      2 key9 = vc
      2 key10 = vc
      2 key11 = vc
      2 key12 = vc
      2 key13 = vc
      2 key14 = vc
      2 key15 = vc
      2 bim1_int = f8
      2 bim2_int = f8
      2 bim_ind = i2
      2 bim1_ind = i2
      2 bim1_nbr = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 updt_cnt = i2
      2 updt_id = vc
      2 updt_dt_tm = dq8
      2 task_action_flag = i2
      2 bill_item_mod_hist_id = f8
      2 history_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD billitemmodifier
 RECORD billitemmodifier(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 bill_item_type_disp = c40
     2 bill_item_type_desc = c60
     2 bill_item_type_mean = c12
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 updt_id = vc
     2 updt_dt_tm = dq8
     2 task_action_flag = i2
     2 bill_item_mod_hist_id = f8
     2 history_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD billitemmodifierhistory
 RECORD billitemmodifierhistory(
   1 bill_item_modifier_hist_qual = i2
   1 bill_item_modifier_hist[*]
     2 bill_item_mod_hist_id = f8
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
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
 IF (validate(getcorrespondingbillitemmodhistory,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF ( NOT (validate(c13019_addon_cd)))
  DECLARE c13019_addon_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"ADD ON"))
  CALL echo(build("C13019_ADDON_CD:",c13019_addon_cd))
 ENDIF
 IF ( NOT (validate(cs48_inactive_status_cd)))
  DECLARE cs48_inactive_status_cd = f8 WITH protect, constant(getcodevalue(48,nullterm("INACTIVE"),0)
   )
 ENDIF
 IF ( NOT (validate(bill_item_modifier_table_name)))
  DECLARE bill_item_modifier_table_name = vc WITH protect, constant("BILL_ITEM_MODIFIER")
 ENDIF
 IF ((validate(failed,- (1))=- (1)))
  DECLARE failed = i2 WITH noconstant(0)
 ENDIF
 DECLARE seffective = vc WITH noconstant("")
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 IF (arelogicaldomainsinuse(null))
  IF ( NOT (getlogicaldomain(ld_concept_prsnl,logicaldomainid)))
   CALL exitservicefailure("Failed to retrieve logical domain ID.",true)
  ENDIF
 ENDIF
 IF (validate(request->beg_effective_dt_tm)=1)
  IF (trim(format(request->beg_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS.CC;;d")) != "")
   SET seffective = "bim.end_effective_dt_tm >= cnvtdatetime('"
   SET seffective = concat(seffective,format(request->beg_effective_dt_tm,
     "DD-MMM-YYYY HH:MM:SS.CC;;d"),"')")
  ELSE
   SET seffective = "1=1"
  ENDIF
 ELSE
  SET seffective = "1=1"
 ENDIF
 SELECT
  IF ((request->bill_item_type_cd != 0)
   AND (request->inactive_ind IN (0, null)))
   WHERE (bim.bill_item_id=request->bill_item_id)
    AND (bim.bill_item_type_cd=request->bill_item_type_cd)
    AND bim.active_ind=1
    AND parser(seffective)
    AND (pr.person_id= Outerjoin(bim.updt_id))
  ELSEIF ((request->bill_item_type_cd != 0)
   AND (request->inactive_ind=1))
   WHERE (bim.bill_item_id=request->bill_item_id)
    AND (bim.bill_item_type_cd=request->bill_item_type_cd)
    AND bim.active_ind=0
    AND parser(seffective)
    AND (pr.person_id= Outerjoin(bim.updt_id))
  ELSEIF ((request->bill_item_type_cd IN (0, null))
   AND (request->inactive_ind=1))
   WHERE (bim.bill_item_id=request->bill_item_id)
    AND bim.active_ind=0
    AND parser(seffective)
    AND (pr.person_id= Outerjoin(bim.updt_id))
  ELSE
   WHERE (bim.bill_item_id=request->bill_item_id)
    AND bim.active_ind=1
    AND parser(seffective)
    AND (pr.person_id= Outerjoin(bim.updt_id))
  ENDIF
  INTO "nl:"
  bim.*, pr.*
  FROM bill_item_modifier bim,
   prsnl pr
  DETAIL
   IF (bim.bill_item_type_cd=c13019_addon_cd)
    IF (bim.key3_id=logicaldomainid)
     count1 += 1, stat = alterlist(reply->bill_item_modifier,count1), reply->bill_item_modifier[
     count1].bill_item_mod_id = bim.bill_item_mod_id,
     reply->bill_item_modifier[count1].bill_item_id = bim.bill_item_id, reply->bill_item_modifier[
     count1].bill_item_type_cd = bim.bill_item_type_cd, reply->bill_item_modifier[count1].key1_id =
     bim.key1_id,
     reply->bill_item_modifier[count1].key2_id = bim.key2_id, reply->bill_item_modifier[count1].
     key3_id = bim.key3_id, reply->bill_item_modifier[count1].key4_id = bim.key4_id,
     reply->bill_item_modifier[count1].key5_id = bim.key5_id, reply->bill_item_modifier[count1].key6
      = bim.key6, reply->bill_item_modifier[count1].key7 = bim.key7,
     reply->bill_item_modifier[count1].key8 = bim.key8, reply->bill_item_modifier[count1].key9 = bim
     .key9, reply->bill_item_modifier[count1].key10 = bim.key10,
     reply->bill_item_modifier[count1].bim1_int = bim.bim1_int, reply->bill_item_modifier[count1].
     bim2_int = bim.bim2_int, reply->bill_item_modifier[count1].bim_ind = bim.bim_ind,
     reply->bill_item_modifier[count1].bim1_ind = bim.bim1_ind, reply->bill_item_modifier[count1].
     bim1_nbr = bim.bim1_nbr, reply->bill_item_modifier[count1].active_ind = bim.active_ind,
     reply->bill_item_modifier[count1].active_status_cd = bim.active_status_cd, reply->
     bill_item_modifier[count1].active_status_dt_tm = bim.active_status_dt_tm, reply->
     bill_item_modifier[count1].active_status_prsnl_id = bim.active_status_prsnl_id,
     reply->bill_item_modifier[count1].beg_effective_dt_tm = bim.beg_effective_dt_tm, reply->
     bill_item_modifier[count1].end_effective_dt_tm = bim.end_effective_dt_tm, reply->
     bill_item_modifier[count1].updt_cnt = bim.updt_cnt,
     reply->bill_item_modifier[count1].updt_id = pr.name_full_formatted, reply->bill_item_modifier[
     count1].updt_dt_tm = bim.updt_dt_tm, reply->bill_item_modifier[count1].task_action_flag = 0,
     reply->bill_item_modifier[count1].bill_item_mod_hist_id = 0.0, reply->bill_item_modifier[count1]
     .history_ind = 0
    ENDIF
   ELSE
    count1 += 1, stat = alterlist(reply->bill_item_modifier,count1), reply->bill_item_modifier[count1
    ].bill_item_mod_id = bim.bill_item_mod_id,
    reply->bill_item_modifier[count1].bill_item_id = bim.bill_item_id, reply->bill_item_modifier[
    count1].bill_item_type_cd = bim.bill_item_type_cd, reply->bill_item_modifier[count1].key1_id =
    bim.key1_id,
    reply->bill_item_modifier[count1].key2_id = bim.key2_id, reply->bill_item_modifier[count1].
    key3_id = bim.key3_id, reply->bill_item_modifier[count1].key4_id = bim.key4_id,
    reply->bill_item_modifier[count1].key5_id = bim.key5_id, reply->bill_item_modifier[count1].key6
     = bim.key6, reply->bill_item_modifier[count1].key7 = bim.key7,
    reply->bill_item_modifier[count1].key8 = bim.key8, reply->bill_item_modifier[count1].key9 = bim
    .key9, reply->bill_item_modifier[count1].key10 = bim.key10,
    reply->bill_item_modifier[count1].bim1_int = bim.bim1_int, reply->bill_item_modifier[count1].
    bim2_int = bim.bim2_int, reply->bill_item_modifier[count1].bim_ind = bim.bim_ind,
    reply->bill_item_modifier[count1].bim1_ind = bim.bim1_ind, reply->bill_item_modifier[count1].
    bim1_nbr = bim.bim1_nbr, reply->bill_item_modifier[count1].active_ind = bim.active_ind,
    reply->bill_item_modifier[count1].active_status_cd = bim.active_status_cd, reply->
    bill_item_modifier[count1].active_status_dt_tm = bim.active_status_dt_tm, reply->
    bill_item_modifier[count1].active_status_prsnl_id = bim.active_status_prsnl_id,
    reply->bill_item_modifier[count1].beg_effective_dt_tm = bim.beg_effective_dt_tm, reply->
    bill_item_modifier[count1].end_effective_dt_tm = bim.end_effective_dt_tm, reply->
    bill_item_modifier[count1].updt_cnt = bim.updt_cnt,
    reply->bill_item_modifier[count1].updt_id = pr.name_full_formatted, reply->bill_item_modifier[
    count1].updt_dt_tm = bim.updt_dt_tm, reply->bill_item_modifier[count1].task_action_flag = 0,
    reply->bill_item_modifier[count1].bill_item_mod_hist_id = 0.0, reply->bill_item_modifier[count1].
    history_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET reply->bill_item_modifier_qual = count1
 IF (curqual=0)
  SET failed = false
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM_MODIFIER"
  SET reply->status_data.status = "Z"
 ELSE
  SET failed = false
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->history_enabled,0)=1)
  CALL getcorrespondingbillitemmodhistory(null)
  IF (failed != false)
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL exitservicesuccess(build(" version : ",afc_get_bill_item_modifier_script_vrsn))
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
  SET reply->status_data.subeventstatus[1].targetobjectvalue = bill_item_modifier_table_name
  SET reqinfo->commit_ind = false
 ENDIF
 SUBROUTINE (getcorrespondingbillitemmodhistory(dummyvar=i4) =null)
   IF ( NOT (validate(get_bill_item_mod_his_sub_name)))
    DECLARE get_bill_item_mod_his_sub_name = vc WITH protect, constant(
     "AFC_GET_BILL_ITEM_MODIFIER_HIS.getBillItemModHistory")
   ENDIF
   IF ((validate(first_record,- (1))=- (1)))
    DECLARE first_rec = i2 WITH protect, constant(1)
   ENDIF
   IF ((validate(next_rec_move,- (1))=- (1)))
    DECLARE next_rec_move = i2 WITH protect, noconstant(0)
   ENDIF
   IF (size(reply->bill_item_modifier,5) > 0)
    SET stat = copyrec(reply,temporaryreply,1)
    SET sel_begin = 1
    SET sel_end = temporaryreply->bill_item_modifier_qual
    IF (initrec(reply)=1)
     FOR (index = sel_begin TO sel_end)
       SET billitemmodifierhistory->bill_item_modifier_hist_qual = first_rec
       SET stat = alterlist(billitemmodifierhistory->bill_item_modifier_hist,first_rec)
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].bill_item_mod_id =
       temporaryreply->bill_item_modifier[index].bill_item_mod_id
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].bill_item_id = temporaryreply
       ->bill_item_modifier[index].bill_item_id
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].bill_item_type_cd =
       temporaryreply->bill_item_modifier[index].bill_item_type_cd
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].active_ind = temporaryreply->
       bill_item_modifier[index].active_ind
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].active_status_cd =
       temporaryreply->bill_item_modifier[index].active_status_cd
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].active_status_prsnl_id =
       temporaryreply->bill_item_modifier[index].active_status_prsnl_id
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].beg_effective_dt_tm =
       temporaryreply->bill_item_modifier[index].beg_effective_dt_tm
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].end_effective_dt_tm =
       temporaryreply->bill_item_modifier[index].end_effective_dt_tm
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].updt_id = temporaryreply->
       bill_item_modifier[index].updt_id
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].updt_cnt = temporaryreply->
       bill_item_modifier[index].updt_cnt
       SET billitemmodifierhistory->bill_item_modifier_hist[first_rec].updt_task = reqinfo->updt_task
       EXECUTE afc_get_bill_item_modifier_his  WITH replace("REQUEST",billitemmodifierhistory),
       replace("REPLY",billitemmodifier)
       SET parent_rec_mov_stat = movereclist(temporaryreply->bill_item_modifier,reply->
        bill_item_modifier,index,next_rec_move,1,
        true)
       SET next_rec_move += 1
       IF (size(billitemmodifier->bill_item_modifier,5) > 0)
        SET rec_mov_stat = movereclist(billitemmodifier->bill_item_modifier,reply->bill_item_modifier,
         1,next_rec_move,billitemmodifier->bill_item_modifier_qual,
         true)
        SET next_rec_move += billitemmodifier->bill_item_modifier_qual
       ENDIF
       SET stat = initrec(billitemmodifier)
     ENDFOR
     SET reply->bill_item_modifier_qual = size(reply->bill_item_modifier,5)
    ENDIF
   ENDIF
   IF (validate(request->bill_item_id,0.0) > 0.0)
    IF ((validate(select_count,- (1))=- (1)))
     DECLARE select_count = i2 WITH protect, noconstant(0)
    ENDIF
    SET stat = initrec(billitemmodifierhistory)
    SET stat = initrec(billitemmodifier)
    SELECT
     IF ((request->bill_item_type_cd != 0))
      WHERE bim.active_ind=0
       AND (bim.bill_item_id=request->bill_item_id)
       AND bim.active_status_cd=cs48_inactive_status_cd
       AND (bim.bill_item_type_cd=request->bill_item_type_cd)
     ELSE
      WHERE bim.active_ind=0
       AND (bim.bill_item_id=request->bill_item_id)
       AND bim.active_status_cd=cs48_inactive_status_cd
     ENDIF
     INTO "nl:"
     bim.bill_item_mod_id, bim.bill_item_id, bim.bill_item_type_cd
     FROM bill_item_modifier bim
     DETAIL
      select_count += 1, billitemmodifierhistory->bill_item_modifier_hist_qual = select_count, stat
       = alterlist(billitemmodifierhistory->bill_item_modifier_hist,select_count),
      billitemmodifierhistory->bill_item_modifier_hist[select_count].bill_item_mod_id = bim
      .bill_item_mod_id, billitemmodifierhistory->bill_item_modifier_hist[select_count].bill_item_id
       = bim.bill_item_id, billitemmodifierhistory->bill_item_modifier_hist[select_count].
      bill_item_type_cd = bim.bill_item_type_cd,
      billitemmodifierhistory->bill_item_modifier_hist[select_count].updt_task = reqinfo->updt_task
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = false
     CALL logmessage(get_bill_item_mod_his_sub_name,"No Bill Item modifications existed",log_info)
    ELSE
     SET failed = false
     SET reply->status_data.status = "S"
     CALL logmessage(get_bill_item_mod_his_sub_name,
      "Existing Deleted Bill Item modifications fetched successfully!",log_info)
    ENDIF
    IF (size(billitemmodifierhistory->bill_item_modifier_hist,5) > 0)
     EXECUTE afc_get_bill_item_modifier_his  WITH replace("REQUEST",billitemmodifierhistory), replace
     ("REPLY",billitemmodifier)
    ENDIF
    SET next_rec_move = size(reply->bill_item_modifier,5)
    IF (size(billitemmodifier->bill_item_modifier,5) > 0)
     SET rec_mov_stat = movereclist(billitemmodifier->bill_item_modifier,reply->bill_item_modifier,1,
      next_rec_move,billitemmodifier->bill_item_modifier_qual,
      true)
     SET reply->bill_item_modifier_qual = size(reply->bill_item_modifier,5)
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
END GO
