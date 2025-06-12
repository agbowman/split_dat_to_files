CREATE PROGRAM afc_bill_item_search:dba
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
 SET afc_bill_item_search_version = "643114.FT.018 minus 17"
 SET message = nowindow
 IF (validate(request->test_mode,999)=999)
  SET test_mode = 0
 ELSE
  SET test_mode = 1
 ENDIF
 RECORD tempreply(
   1 match_qual = i4
   1 bill_item_qual = i4
   1 qual[*]
     2 match_ind = i2
     2 item_level = i2
     2 parent_qual_cd = i2
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 ext_owner_disp = c40
     2 ext_owner_desc = c60
     2 ext_owner_mean = c12
     2 bill_item_id = f8
     2 parent_bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_parent_contributor_disp = c40
     2 ext_parent_contributor_desc = c60
     2 ext_parent_contributor_mean = c12
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_child_contributor_disp = c40
     2 ext_child_contributor_desc = c60
     2 ext_child_contributor_mean = c12
     2 ext_description = vc
     2 ext_short_desc = vc
     2 careset_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 stats_only_ind = i2
     2 misc_ind = i2
     2 workload_only_ind = i2
     2 late_chrg_excl_ind = i2
     2 ignore_me_ind = i2
 )
 RECORD reply(
   1 search_field = vc
   1 search_common = vc
   1 match_qual = i4
   1 bill_item_qual = i4
   1 qual[*]
     2 match_ind = i2
     2 item_level = i2
     2 parent_qual_cd = i2
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 ext_owner_disp = c40
     2 ext_owner_desc = c60
     2 ext_owner_mean = c12
     2 bill_item_id = f8
     2 parent_bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_parent_contributor_disp = c40
     2 ext_parent_contributor_desc = c60
     2 ext_parent_contributor_mean = c12
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_child_contributor_disp = c40
     2 ext_child_contributor_desc = c60
     2 ext_child_contributor_mean = c12
     2 ext_description = vc
     2 ext_short_desc = vc
     2 careset_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 stats_only_ind = i2
     2 misc_ind = i2
     2 workload_only_ind = i2
     2 late_chrg_excl_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET srch_careset = 2
 SET srch_caresetcomp = 4
 SET srch_parent = 8
 SET srch_child = 16
 SET srch_default = 32
 SET srch_addon = 64
 SET srch_alpharesp = 128
 DECLARE search_string_beg = vc
 DECLARE search_string_end = vc
 DECLARE search_long = vc
 DECLARE search_short = vc
 DECLARE search_common = vc
 DECLARE ord_cat = f8 WITH public, noconstant(0.0)
 DECLARE alpha_resp = f8 WITH public, noconstant(0.0)
 DECLARE add_on = f8 WITH public, noconstant(0.0)
 DECLARE logicaldomainid = f8 WITH noconstant(0.0), protect
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE searchidx = i4 WITH protect, noconstant(1)
 SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,ord_cat)
 SET stat = uar_get_meaning_by_codeset(13016,"ALPHA RESP",1,alpha_resp)
 SET stat = uar_get_meaning_by_codeset(106,"AFC ADD SPEC",1,add_on)
 DECLARE 26078_bill_item = f8 WITH public, noconstant(0.0)
 DECLARE ibisec = i2 WITH public, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(26078,"BILL_ITEM",1,26078_bill_item)
 CALL echo(build("BILL_ITEM: ",26078_bill_item))
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="BILL ITEM SECURITY"
   AND di.info_char="Y"
   AND di.info_domain_id=logicaldomainid
  DETAIL
   CALL echo("Bill Item Security = 1"), ibisec = 1
  WITH nocounter
 ;end select
 IF ((reqinfo->updt_app=951050))
  SET ibisec = 0
 ENDIF
 DECLARE 26078_bc_sched = f8 WITH public, noconstant(0.0)
 DECLARE ibcsec = i2 WITH public, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(26078,"BC_SCHED",1,26078_bc_sched)
 CALL echo(build("BC_SCHED",cnvtstring(26078_bc_sched,17,2)))
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="BILL CODE SCHED SECURITY"
   AND di.info_char="Y"
   AND di.info_domain_id=logicaldomainid
  DETAIL
   CALL echo("Bill Code Schedule Security = 1"), ibcsec = 1
  WITH nocounter
 ;end select
 IF ((request->bill_code_schedule <= 0)
  AND (request->search_description_type != 3))
  SET position = findstring("'",request->search_string)
  IF (position > 0)
   SET x = movestring("*",1,request->search_string,position,1)
  ENDIF
  SET search_string_beg = trim(request->search_string,3)
  IF ((request->match_case=1))
   IF ((request->match_whole_word=0))
    SET search_long = concat("b.ext_description LIKE '",search_string_beg,"'")
    SET search_short = concat("b.ext_short_desc LIKE '",search_string_beg,"'")
   ELSE
    SET search_long = concat("b.ext_description LIKE '* ",search_string_beg," *'")
    SET search_short = concat("b.ext_short_desc LIKE '* ",search_string_beg," *'")
    SET search_long = concat(search_long," or b.ext_description LIKE '",search_string_beg," *'")
    SET search_short = concat(search_short," or b.ext_short_desc LIKE '",search_string_beg," *'")
    SET search_long = concat(search_long," or b.ext_description LIKE '* ",search_string_beg,"'")
    SET search_short = concat(search_short," or b.ext_short_desc LIKE '* ",search_string_beg,"'")
   ENDIF
  ELSE
   IF ((request->match_whole_word=0))
    SET search_long = concat("cnvtupper(b.ext_description) LIKE '",cnvtupper(search_string_beg),"'")
    SET search_short = concat("cnvtupper(b.ext_short_desc) LIKE '",cnvtupper(search_string_beg),"'")
   ELSE
    SET search_long = concat("cnvtupper(b.ext_description) LIKE '* ",cnvtupper(search_string_beg),
     " *'")
    SET search_short = concat("cnvtupper(b.ext_short_desc) LIKE '* ",cnvtupper(search_string_beg),
     " *'")
    SET search_long = concat(search_long," or cnvtupper(b.ext_description) LIKE '",cnvtupper(
      search_string_beg)," *'")
    SET search_short = concat(search_short," or cnvtupper(b.ext_short_desc) LIKE '",cnvtupper(
      search_string_beg)," *'")
    SET search_long = concat(search_long," or cnvtupper(b.ext_description) LIKE '* ",cnvtupper(
      search_string_beg),"'")
    SET search_short = concat(search_short," or cnvtupper(b.ext_short_desc) LIKE '* ",cnvtupper(
      search_string_beg),"'")
   ENDIF
  ENDIF
  IF ((request->owner_cd > 0))
   SET search_common = concat(" b.ext_owner_cd = ",cnvtstring(request->owner_cd,17,2),
    " and b.active_ind = 1")
  ELSE
   SET search_common = " b.active_ind = 1"
  ENDIF
 ELSEIF ((request->bill_code_schedule > 0)
  AND (request->search_description_type != 3))
  DECLARE code_set = i4
  DECLARE cdf_meaning = c12
  DECLARE cnt = i4
  DECLARE billcd = f8
  SET code_set = 13019
  SET cdf_meaning = "BILL CODE"
  SET cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,billcd)
  SET search_bill_code = concat(" bim.bill_item_type_cd = BillCd and bim.key1_id = ",trim(cnvtstring(
     request->bill_code_schedule,17,2))," and bim.key6 like '",request->bill_code,"'")
  CALL echo(build("search_bill_code = ",search_bill_code))
 ENDIF
 IF ((request->search_description_type=3))
  SET search_long = concat("b.bill_item_id = ",request->search_string)
  SET search_short = concat("b.bill_item_id = ",request->search_string)
  SET search_common = " b.active_ind = 1"
  SET request->search_description_type = 1
 ENDIF
 DECLARE bi_count = i2
 IF ((request->bill_code_schedule <= 0))
  CALL echo(search_long)
  CALL echo(search_short)
  CALL echo(search_common)
  IF (band(request->search_item_level,srch_careset) > 0)
   CALL echo("Searching Caresets")
   SELECT
    IF ((request->search_description_type=1))DISTINCT INTO "NL:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND b.ext_child_reference_id=0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=ord_cat
       AND b1.ext_child_contributor_cd=ord_cat
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )
    ELSEIF ((request->search_description_type=2))DISTINCT INTO "NL:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND b.ext_child_reference_id=0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=ord_cat
       AND b1.ext_child_contributor_cd=ord_cat
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )
    ELSEIF ((request->search_description_type=0))DISTINCT INTO "NL:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND b.ext_child_reference_id=0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=ord_cat
       AND b1.ext_child_contributor_cd=ord_cat
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )
    ELSE
    ENDIF
    DETAIL
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].
     parent_qual_cd = b.parent_qual_cd,
     tempreply->qual[bi_count].item_level = srch_careset, tempreply->qual[bi_count].match_ind = 1,
     tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
     msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b.ext_parent_reference_id,
     tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
     qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
     ext_child_contributor_cd = b.ext_child_contributor_cd,
     tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
     ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 1,
     tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count]
     .end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
     .stats_only_ind,
     tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
     .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind,
     tempreply->qual[bi_count].ignore_me_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF (band(request->search_item_level,srch_caresetcomp) > 0)
   CALL echo("Searching Careset Components")
   DECLARE parent_bill_item_id = f8
   DECLARE process_ind = i2
   SELECT
    IF ((request->search_description_type=1))INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND b.ext_parent_contributor_cd=ord_cat
       AND b.ext_child_contributor_cd=ord_cat
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (((b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0) OR (b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND  NOT ( EXISTS (
      (SELECT
       b.bill_item_id
       FROM bill_item b
       WHERE parser(search_long)
        AND parser(search_common)
        AND b.bill_item_id=b1.bill_item_id)))
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )) )
    ELSEIF ((request->search_description_type=2))INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND b.ext_parent_contributor_cd=ord_cat
       AND b.ext_child_contributor_cd=ord_cat
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (((b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0) OR (b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND  NOT ( EXISTS (
      (SELECT
       b.bill_item_id
       FROM bill_item b
       WHERE parser(search_short)
        AND parser(search_common)
        AND b.bill_item_id=b1.bill_item_id)))
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )) )
    ELSEIF ((request->search_description_type=0))INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND b.ext_parent_contributor_cd=ord_cat
       AND b.ext_child_contributor_cd=ord_cat
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (((b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0) OR (b1.ext_parent_reference_id=b.ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND  NOT ( EXISTS (
      (SELECT
       b.bill_item_id
       FROM bill_item b
       WHERE ((parser(search_long)) OR (parser(search_short)))
        AND parser(search_common)
        AND b.bill_item_id=b1.bill_item_id)))
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )) )
    ELSE
    ENDIF
    ORDER BY b1.ext_parent_reference_id, b1.ext_parent_contributor_cd, b1.ext_child_reference_id,
     b1.ext_child_contributor_cd
    HEAD b1.ext_parent_reference_id
     parent_bill_item_id = b1.bill_item_id, process_ind = 1
    HEAD b1.ext_child_reference_id
     process_ind = 1
    DETAIL
     IF (process_ind=1)
      bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
      IF (b1.ext_child_reference_id=0)
       tempreply->qual[bi_count].careset_ind = 1, tempreply->qual[bi_count].item_level = srch_careset
      ELSE
       tempreply->qual[bi_count].careset_ind = 0, tempreply->qual[bi_count].item_level =
       srch_caresetcomp, tempreply->qual[bi_count].parent_bill_item_id = parent_bill_item_id,
       CALL echo(char(9),0)
      ENDIF
      CALL echo(b1.ext_description,0)
      IF (b1.bill_item_id=b.bill_item_id)
       tempreply->qual[bi_count].match_ind = 1,
       CALL echo(" match")
      ELSE
       CALL echo("")
      ENDIF
      tempreply->qual[bi_count].parent_qual_cd = b1.parent_qual_cd, tempreply->qual[bi_count].
      ext_owner_cd = b1.ext_owner_cd, msstat = assign(validate(tempreply->qual[bi_count].
        ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
      tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
      ext_parent_reference_id = b1.ext_parent_reference_id, tempreply->qual[bi_count].
      ext_parent_contributor_cd = b1.ext_parent_contributor_cd,
      tempreply->qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[
      bi_count].ext_child_contributor_cd = b1.ext_child_contributor_cd, tempreply->qual[bi_count].
      ext_description = b1.ext_description,
      tempreply->qual[bi_count].ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].
      beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count].end_effective_dt_tm =
      b1.end_effective_dt_tm,
      tempreply->qual[bi_count].stats_only_ind = b1.stats_only_ind, tempreply->qual[bi_count].
      misc_ind = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind = b1.workload_only_ind,
      tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind, tempreply->qual[bi_count]
      .ignore_me_ind = 1, process_ind = 0
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (band(request->search_item_level,srch_parent) > 0)
   CALL echo("Searching Parents")
   SELECT
    IF ((request->search_description_type=1))INTO "NL:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
       AND  NOT ( EXISTS (
      (SELECT
       b1.ext_parent_reference_id
       FROM bill_item b1
       WHERE b1.ext_parent_contributor_cd=ord_cat
        AND b1.ext_child_contributor_cd=ord_cat
        AND b1.ext_parent_reference_id=b.ext_parent_reference_id
        AND b1.active_ind=1
        AND ((b1.logical_domain_id=logicaldomainid
        AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )))
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id=0)
    ELSEIF ((request->search_description_type=2))INTO "NL:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
       AND  NOT ( EXISTS (
      (SELECT
       b1.ext_parent_reference_id
       FROM bill_item b1
       WHERE b1.ext_parent_contributor_cd=ord_cat
        AND b1.ext_child_contributor_cd=ord_cat
        AND b1.ext_parent_reference_id=b.ext_parent_reference_id
        AND b1.active_ind=1
        AND ((b1.logical_domain_id=logicaldomainid
        AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )))
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id=0)
    ELSE INTO "NL:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
       AND  NOT ( EXISTS (
      (SELECT
       b1.ext_parent_reference_id
       FROM bill_item b1
       WHERE b1.ext_parent_contributor_cd=ord_cat
        AND b1.ext_child_contributor_cd=ord_cat
        AND b1.ext_parent_reference_id=b.ext_parent_reference_id
        AND b1.active_ind=1
        AND ((b1.logical_domain_id=logicaldomainid
        AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )))
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id=0)
    ENDIF
    DETAIL
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].item_level
      = srch_parent,
     tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b
     .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
     msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b.ext_parent_reference_id,
     tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
     qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
     ext_child_contributor_cd = b.ext_child_contributor_cd,
     tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
     ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
     tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count]
     .end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
     .stats_only_ind,
     tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
     .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind,
     tempreply->qual[bi_count].ignore_me_ind = 1,
     CALL echo(build("Bill Item Description: ",b.ext_description))
    WITH nocounter
   ;end select
  ENDIF
  IF (band(request->search_item_level,srch_child) > 0)
   CALL echo("Searching Children")
   DECLARE parent_bill_item_id = f8
   DECLARE process_ind = i2
   SELECT
    IF ((request->search_description_type=1))INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND b.ext_child_contributor_cd != ord_cat
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd != alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ELSEIF ((request->search_description_type=2))INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND b.ext_child_contributor_cd != ord_cat
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd != alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ELSE INTO "NL:"
     b.bill_item_id, b1.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND b.ext_child_contributor_cd != ord_cat
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd != alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=b
      .ext_parent_reference_id
       AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
       AND b1.ext_child_reference_id=0
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ENDIF
    ORDER BY b1.ext_parent_reference_id, b1.ext_parent_contributor_cd, b1.ext_child_reference_id,
     b1.ext_child_contributor_cd
    HEAD b1.ext_parent_reference_id
     parent_bill_item_id = b1.bill_item_id, process_ind = 1
    HEAD b1.ext_child_reference_id
     process_ind = 1
    DETAIL
     IF (process_ind=1)
      bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
      IF (b1.ext_child_reference_id=0)
       tempreply->qual[bi_count].item_level = srch_parent
      ELSE
       tempreply->qual[bi_count].item_level = srch_child, tempreply->qual[bi_count].
       parent_bill_item_id = parent_bill_item_id,
       CALL echo(char(9),0)
      ENDIF
      CALL echo(b1.ext_description,0)
      IF (b1.bill_item_id=b.bill_item_id)
       tempreply->qual[bi_count].match_ind = 1,
       CALL echo(" match")
      ELSE
       CALL echo("")
      ENDIF
      tempreply->qual[bi_count].parent_qual_cd = b1.parent_qual_cd, tempreply->qual[bi_count].
      ext_owner_cd = b1.ext_owner_cd, msstat = assign(validate(tempreply->qual[bi_count].
        ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
      tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
      ext_parent_reference_id = b1.ext_parent_reference_id, tempreply->qual[bi_count].
      ext_parent_contributor_cd = b1.ext_parent_contributor_cd,
      tempreply->qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[
      bi_count].ext_child_contributor_cd = b1.ext_child_contributor_cd, tempreply->qual[bi_count].
      ext_description = b1.ext_description,
      tempreply->qual[bi_count].ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].
      beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count].end_effective_dt_tm =
      b1.end_effective_dt_tm,
      tempreply->qual[bi_count].stats_only_ind = b1.stats_only_ind, tempreply->qual[bi_count].
      misc_ind = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind = b1.workload_only_ind,
      tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind, tempreply->qual[bi_count]
      .ignore_me_ind = 1, process_ind = 0
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (band(request->search_item_level,srch_default) > 0)
   CALL echo("Searching Defaults")
   SELECT
    IF ((request->search_description_type=1))INTO "nl:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND b.ext_parent_reference_id=0
       AND b.ext_child_reference_id != 0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ELSEIF ((request->search_description_type=2))INTO "nl:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND b.ext_parent_reference_id=0
       AND b.ext_child_reference_id != 0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ELSE INTO "nl:"
     b.*
     FROM bill_item b
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND b.ext_parent_reference_id=0
       AND b.ext_child_reference_id != 0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ENDIF
    DETAIL
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].item_level
      = srch_default,
     tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b
     .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
     msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b.ext_parent_reference_id,
     tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
     qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
     ext_child_contributor_cd = b.ext_child_contributor_cd,
     tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
     ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
     tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count]
     .end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
     .stats_only_ind,
     tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
     .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind,
     tempreply->qual[bi_count].ignore_me_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF (band(request->search_item_level,srch_addon) > 0)
   CALL echo("Searching Add Ons")
  ENDIF
  IF (band(request->search_item_level,srch_alpharesp) > 0)
   CALL echo("Searching Alpha Responses")
   SELECT
    IF ((request->search_description_type=1))INTO "nl:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_long)
       AND parser(search_common)
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd=alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=0.00
       AND b1.ext_child_reference_id=b.ext_parent_reference_id
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ELSEIF ((request->search_description_type=2))INTO "nl:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE parser(search_short)
       AND parser(search_common)
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd=alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=0.00
       AND b1.ext_child_reference_id=b.ext_parent_reference_id
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ELSE INTO "nl:"
     b.*
     FROM bill_item b,
      bill_item b1
     PLAN (b
      WHERE ((parser(search_long)) OR (parser(search_short)))
       AND parser(search_common)
       AND b.ext_parent_reference_id != 0
       AND b.ext_child_reference_id != 0
       AND b.ext_child_contributor_cd=alpha_resp
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (b1
      WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=0.00
       AND b1.ext_child_reference_id=b.ext_parent_reference_id
       AND b1.active_ind=1
       AND ((b1.logical_domain_id=logicaldomainid
       AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
    ENDIF
    ORDER BY b1.ext_child_reference_id, b1.ext_parent_reference_id
    HEAD b1.ext_child_reference_id
     IF (b1.ext_parent_reference_id=0)
      parent_bill_item_id = b1.bill_item_id
     ENDIF
    DETAIL
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
     IF (b1.ext_parent_reference_id=0)
      tempreply->qual[bi_count].item_level = srch_default
     ELSE
      tempreply->qual[bi_count].item_level = srch_alpharesp, tempreply->qual[bi_count].
      parent_bill_item_id = parent_bill_item_id
     ENDIF
     tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b1
     .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b1.ext_owner_cd,
     msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b1.ext_parent_reference_id,
     tempreply->qual[bi_count].ext_parent_contributor_cd = b1.ext_parent_contributor_cd, tempreply->
     qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[bi_count].
     ext_child_contributor_cd = b1.ext_child_contributor_cd,
     tempreply->qual[bi_count].ext_description = b1.ext_description, tempreply->qual[bi_count].
     ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
     tempreply->qual[bi_count].beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count
     ].end_effective_dt_tm = b1.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b1
     .stats_only_ind,
     tempreply->qual[bi_count].misc_ind = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind =
     b1.workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind,
     tempreply->qual[bi_count].ignore_me_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT DISTINCT INTO "NL:"
   FROM bill_item_modifier bim,
    bill_item b,
    bill_item b1
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.ext_child_reference_id=0
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (b1
    WHERE b1.ext_parent_reference_id=b.ext_parent_reference_id
     AND b1.ext_parent_contributor_cd=ord_cat
     AND b1.ext_child_contributor_cd=ord_cat
     AND b1.active_ind=1
     AND ((b1.logical_domain_id=logicaldomainid
     AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )
   DETAIL
    bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].
    parent_qual_cd = b.parent_qual_cd,
    tempreply->qual[bi_count].item_level = srch_careset, tempreply->qual[bi_count].match_ind = 1,
    tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
    msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
    tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
    ext_parent_reference_id = b.ext_parent_reference_id,
    tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
    qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
    ext_child_contributor_cd = b.ext_child_contributor_cd,
    tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
    ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 1,
    tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count].
    end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
    .stats_only_ind,
    tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
    .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind
    IF (ibcsec=0)
     tempreply->qual[bi_count].ignore_me_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM bill_item_modifier bim,
    bill_item b,
    bill_item b1
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.ext_parent_contributor_cd=ord_cat
     AND b.ext_child_contributor_cd=ord_cat
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (b1
    WHERE ((b1.bill_item_id=b.bill_item_id) OR (((b1.ext_parent_reference_id=b
    .ext_parent_reference_id
     AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
     AND b1.ext_child_reference_id=0) OR (b1.ext_parent_reference_id=b.ext_parent_reference_id
     AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
     AND  NOT ( EXISTS (
    (SELECT
     b.bill_item_id
     FROM bill_item b
     WHERE b.active_ind=1
      AND b.bill_item_id=b1.bill_item_id)))
     AND b1.active_ind=1
     AND ((b1.logical_domain_id=logicaldomainid
     AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )) )
   ORDER BY b1.ext_parent_reference_id, b1.ext_parent_contributor_cd, b1.ext_child_reference_id,
    b1.ext_child_contributor_cd
   HEAD b1.ext_parent_reference_id
    parent_bill_item_id = b1.bill_item_id, process_ind = 1
   HEAD b1.ext_child_reference_id
    process_ind = 1
   DETAIL
    IF (process_ind=1)
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
     IF (b1.ext_child_reference_id=0)
      tempreply->qual[bi_count].careset_ind = 1, tempreply->qual[bi_count].item_level = srch_careset
     ELSE
      tempreply->qual[bi_count].careset_ind = 0, tempreply->qual[bi_count].item_level =
      srch_caresetcomp, tempreply->qual[bi_count].parent_bill_item_id = parent_bill_item_id,
      CALL echo(char(9),0)
     ENDIF
     CALL echo(b1.ext_description,0)
     IF (b1.bill_item_id=b.bill_item_id)
      tempreply->qual[bi_count].match_ind = 1,
      CALL echo(" match")
     ELSE
      CALL echo("")
     ENDIF
     tempreply->qual[bi_count].parent_qual_cd = b1.parent_qual_cd, tempreply->qual[bi_count].
     ext_owner_cd = b1.ext_owner_cd, msstat = assign(validate(tempreply->qual[bi_count].
       ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b1.ext_parent_reference_id, tempreply->qual[bi_count].
     ext_parent_contributor_cd = b1.ext_parent_contributor_cd,
     tempreply->qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[
     bi_count].ext_child_contributor_cd = b1.ext_child_contributor_cd, tempreply->qual[bi_count].
     ext_description = b1.ext_description,
     tempreply->qual[bi_count].ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].
     beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count].end_effective_dt_tm = b1
     .end_effective_dt_tm,
     tempreply->qual[bi_count].stats_only_ind = b1.stats_only_ind, tempreply->qual[bi_count].misc_ind
      = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind = b1.workload_only_ind,
     tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind
     IF (ibcsec=0)
      tempreply->qual[bi_count].ignore_me_ind = 1
     ENDIF
     process_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM bill_item_modifier bim,
    bill_item b
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     b1.ext_parent_reference_id
     FROM bill_item b1
     WHERE b1.ext_parent_contributor_cd=ord_cat
      AND b1.ext_child_contributor_cd=ord_cat
      AND b1.ext_parent_reference_id=b.ext_parent_reference_id
      AND b1.active_ind=1)))
     AND b.ext_parent_reference_id != 0
     AND b.ext_child_reference_id=0
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
   DETAIL
    bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].item_level
     = srch_parent,
    tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b
    .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
    msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
    tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
    ext_parent_reference_id = b.ext_parent_reference_id,
    tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
    qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
    ext_child_contributor_cd = b.ext_child_contributor_cd,
    tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
    ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
    tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count].
    end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
    .stats_only_ind,
    tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
    .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind
    IF (ibcsec=0)
     tempreply->qual[bi_count].ignore_me_ind = 1
    ENDIF
    CALL echo(build("Bill Item Description: ",b.ext_description))
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM bill_item_modifier bim,
    bill_item b,
    bill_item b1
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.ext_child_contributor_cd != ord_cat
     AND b.ext_parent_reference_id != 0
     AND b.ext_child_reference_id != 0
     AND b.active_ind=1
     AND b.ext_child_contributor_cd != alpha_resp
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (b1
    WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=b.ext_parent_reference_id
     AND b1.ext_parent_contributor_cd=b.ext_parent_contributor_cd
     AND b1.ext_child_reference_id=0
     AND b1.active_ind=1
     AND ((b1.logical_domain_id=logicaldomainid
     AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
   ORDER BY b1.ext_parent_reference_id, b1.ext_parent_contributor_cd, b1.ext_child_reference_id,
    b1.ext_child_contributor_cd
   HEAD b1.ext_parent_reference_id
    parent_bill_item_id = b1.bill_item_id, process_ind = 1
   HEAD b1.ext_child_reference_id
    process_ind = 1
   DETAIL
    IF (process_ind=1)
     bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
     IF (b1.ext_child_reference_id=0)
      tempreply->qual[bi_count].item_level = srch_parent
     ELSE
      tempreply->qual[bi_count].item_level = srch_child, tempreply->qual[bi_count].
      parent_bill_item_id = parent_bill_item_id,
      CALL echo(char(9),0)
     ENDIF
     CALL echo(b1.ext_description,0)
     IF (b1.bill_item_id=b.bill_item_id)
      tempreply->qual[bi_count].match_ind = 1,
      CALL echo(" match")
     ELSE
      CALL echo("")
     ENDIF
     tempreply->qual[bi_count].parent_qual_cd = b1.parent_qual_cd, tempreply->qual[bi_count].
     ext_owner_cd = b1.ext_owner_cd, msstat = assign(validate(tempreply->qual[bi_count].
       ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
     tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
     ext_parent_reference_id = b1.ext_parent_reference_id, tempreply->qual[bi_count].
     ext_parent_contributor_cd = b1.ext_parent_contributor_cd,
     tempreply->qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[
     bi_count].ext_child_contributor_cd = b1.ext_child_contributor_cd, tempreply->qual[bi_count].
     ext_description = b1.ext_description,
     tempreply->qual[bi_count].ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].
     beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count].end_effective_dt_tm = b1
     .end_effective_dt_tm,
     tempreply->qual[bi_count].stats_only_ind = b1.stats_only_ind, tempreply->qual[bi_count].misc_ind
      = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind = b1.workload_only_ind,
     tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind
     IF (ibcsec=0)
      tempreply->qual[bi_count].ignore_me_ind = 1
     ENDIF
     process_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    bill_item b
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.ext_parent_reference_id=0
     AND b.ext_child_reference_id != 0
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
   DETAIL
    bi_count += 1, stat = alterlist(tempreply->qual,bi_count), tempreply->qual[bi_count].item_level
     = srch_default,
    tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b
    .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b.ext_owner_cd,
    msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b.ext_sub_owner_cd),
    tempreply->qual[bi_count].bill_item_id = b.bill_item_id, tempreply->qual[bi_count].
    ext_parent_reference_id = b.ext_parent_reference_id,
    tempreply->qual[bi_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd, tempreply->
    qual[bi_count].ext_child_reference_id = b.ext_child_reference_id, tempreply->qual[bi_count].
    ext_child_contributor_cd = b.ext_child_contributor_cd,
    tempreply->qual[bi_count].ext_description = b.ext_description, tempreply->qual[bi_count].
    ext_short_desc = b.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
    tempreply->qual[bi_count].beg_effective_dt_tm = b.beg_effective_dt_tm, tempreply->qual[bi_count].
    end_effective_dt_tm = b.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b
    .stats_only_ind,
    tempreply->qual[bi_count].misc_ind = b.misc_ind, tempreply->qual[bi_count].workload_only_ind = b
    .workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b.late_chrg_excl_ind
    IF (ibcsec=0)
     tempreply->qual[bi_count].ignore_me_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    bill_item b,
    bill_item b1
   PLAN (bim
    WHERE parser(search_bill_code)
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND b.ext_parent_reference_id != 0
     AND b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=alpha_resp
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (b1
    WHERE ((b1.bill_item_id=b.bill_item_id) OR (b1.ext_parent_reference_id=0.00
     AND b1.ext_child_reference_id=b.ext_parent_reference_id
     AND b1.active_ind=1
     AND ((b1.logical_domain_id=logicaldomainid
     AND b1.logical_domain_enabled_ind=true) OR (b1.logical_domain_enabled_ind=false)) )) )
   ORDER BY b1.ext_child_reference_id, b1.ext_parent_reference_id
   HEAD b1.ext_child_reference_id
    IF (b1.ext_parent_reference_id=0)
     parent_bill_item_id = b1.bill_item_id
    ENDIF
   DETAIL
    bi_count += 1, stat = alterlist(tempreply->qual,bi_count)
    IF (b1.ext_parent_reference_id=0)
     tempreply->qual[bi_count].item_level = srch_default
    ELSE
     tempreply->qual[bi_count].item_level = srch_alpharesp, tempreply->qual[bi_count].
     parent_bill_item_id = parent_bill_item_id
    ENDIF
    tempreply->qual[bi_count].match_ind = 1, tempreply->qual[bi_count].parent_qual_cd = b1
    .parent_qual_cd, tempreply->qual[bi_count].ext_owner_cd = b1.ext_owner_cd,
    msstat = assign(validate(tempreply->qual[bi_count].ext_sub_owner_cd,0.0),b1.ext_sub_owner_cd),
    tempreply->qual[bi_count].bill_item_id = b1.bill_item_id, tempreply->qual[bi_count].
    ext_parent_reference_id = b1.ext_parent_reference_id,
    tempreply->qual[bi_count].ext_parent_contributor_cd = b1.ext_parent_contributor_cd, tempreply->
    qual[bi_count].ext_child_reference_id = b1.ext_child_reference_id, tempreply->qual[bi_count].
    ext_child_contributor_cd = b1.ext_child_contributor_cd,
    tempreply->qual[bi_count].ext_description = b1.ext_description, tempreply->qual[bi_count].
    ext_short_desc = b1.ext_short_desc, tempreply->qual[bi_count].careset_ind = 0,
    tempreply->qual[bi_count].beg_effective_dt_tm = b1.beg_effective_dt_tm, tempreply->qual[bi_count]
    .end_effective_dt_tm = b1.end_effective_dt_tm, tempreply->qual[bi_count].stats_only_ind = b1
    .stats_only_ind,
    tempreply->qual[bi_count].misc_ind = b1.misc_ind, tempreply->qual[bi_count].workload_only_ind =
    b1.workload_only_ind, tempreply->qual[bi_count].late_chrg_excl_ind = b1.late_chrg_excl_ind
    IF (ibcsec=0)
     tempreply->qual[bi_count].ignore_me_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (ibcsec=1)
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     cs_org_reltn cor,
     bill_item_modifier bim,
     (dummyt d  WITH seq = value(bi_count))
    PLAN (d)
     JOIN (bim
     WHERE (bim.bill_item_id=tempreply->qual[d.seq].bill_item_id)
      AND bim.active_ind=1
      AND bim.bill_item_type_cd=billcd)
     JOIN (cor
     WHERE cor.key1_id=bim.key1_id
      AND cor.cs_org_reltn_type_cd=26078_bc_sched
      AND cor.key1_entity_name="BC_SCHED"
      AND (cor.key1_id=request->bill_code_schedule)
      AND cor.active_ind=1)
     JOIN (por
     WHERE por.organization_id=cor.organization_id
      AND (por.person_id=reqinfo->updt_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     tempreply->qual[d.seq].ignore_me_ind = 1
     IF ((tempreply->qual[d.seq].parent_bill_item_id != 0.0))
      locidx = locateval(searchidx,1,size(tempreply->qual,5),tempreply->qual[d.seq].
       parent_bill_item_id,tempreply->qual[searchidx].bill_item_id,
       0,tempreply->qual[searchidx].ignore_me_ind)
      IF (locidx > 0)
       tempreply->qual[locidx].ignore_me_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM bill_item_modifier bim,
     code_value cv,
     (dummyt d  WITH seq = value(bi_count))
    PLAN (d)
     JOIN (bim
     WHERE (bim.bill_item_id=tempreply->qual[d.seq].bill_item_id)
      AND bim.active_ind=1
      AND bim.bill_item_type_cd=billcd)
     JOIN (cv
     WHERE cv.code_value=bim.key1_id
      AND cv.cdf_meaning="ASA"
      AND cv.active_ind=1)
    DETAIL
     tempreply->qual[d.seq].ignore_me_ind = 1
     IF ((tempreply->qual[d.seq].parent_bill_item_id != 0.0))
      locidx = locateval(searchidx,1,size(tempreply->qual,5),tempreply->qual[d.seq].
       parent_bill_item_id,tempreply->qual[searchidx].bill_item_id,
       0,tempreply->qual[searchidx].ignore_me_ind)
      IF (locidx > 0)
       tempreply->qual[locidx].ignore_me_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET bi_match_count = bi_count
  CALL echo(build("bi_match_count ",bi_match_count))
 ENDIF
 DECLARE bi_count_b = i2
 DECLARE bi_match_count = i2
 DECLARE last_bi_id = f8
 SELECT
  IF (ibisec=0)INTO "nl:"
   bi_id = tempreply->qual[d1.seq].bill_item_id, p_ref = tempreply->qual[d1.seq].
   ext_parent_reference_id, p_cont = tempreply->qual[d1.seq].ext_parent_contributor_cd,
   c_ref = tempreply->qual[d1.seq].ext_child_reference_id, c_cont = tempreply->qual[d1.seq].
   ext_child_contributor_cd, match_ind = tempreply->qual[d1.seq].match_ind
   FROM (dummyt d1  WITH seq = value(bi_count))
   PLAN (d1
    WHERE (tempreply->qual[d1.seq].ignore_me_ind=1))
  ELSE INTO "nl:"
   bi_id = tempreply->qual[d1.seq].bill_item_id, p_ref = tempreply->qual[d1.seq].
   ext_parent_reference_id, p_cont = tempreply->qual[d1.seq].ext_parent_contributor_cd,
   c_ref = tempreply->qual[d1.seq].ext_child_reference_id, c_cont = tempreply->qual[d1.seq].
   ext_child_contributor_cd, match_ind = tempreply->qual[d1.seq].match_ind
   FROM cs_org_reltn cor,
    prsnl_org_reltn por,
    (dummyt d1  WITH seq = value(bi_count))
   PLAN (d1
    WHERE (tempreply->qual[d1.seq].ignore_me_ind=1))
    JOIN (cor
    WHERE (cor.key1_id=tempreply->qual[d1.seq].bill_item_id)
     AND cor.cs_org_reltn_type_cd=26078_bill_item
     AND cor.active_ind=1)
    JOIN (por
    WHERE por.organization_id=cor.organization_id
     AND (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
  ENDIF
  ORDER BY p_ref, p_cont, c_ref,
   c_cont, bi_id, match_ind DESC
  DETAIL
   IF (bi_id != last_bi_id)
    last_bi_id = bi_id, bi_count_b += 1, stat = alterlist(reply->qual,bi_count_b),
    reply->qual[bi_count_b].item_level = tempreply->qual[d1.seq].item_level, reply->qual[bi_count_b].
    parent_bill_item_id = tempreply->qual[d1.seq].parent_bill_item_id, reply->qual[bi_count_b].
    match_ind = tempreply->qual[d1.seq].match_ind,
    reply->qual[bi_count_b].parent_qual_cd = tempreply->qual[d1.seq].parent_qual_cd, reply->qual[
    bi_count_b].ext_owner_cd = tempreply->qual[d1.seq].ext_owner_cd, reply->qual[bi_count_b].
    ext_sub_owner_cd = tempreply->qual[d1.seq].ext_sub_owner_cd,
    reply->qual[bi_count_b].bill_item_id = tempreply->qual[d1.seq].bill_item_id, reply->qual[
    bi_count_b].ext_parent_reference_id = tempreply->qual[d1.seq].ext_parent_reference_id, reply->
    qual[bi_count_b].ext_parent_contributor_cd = tempreply->qual[d1.seq].ext_parent_contributor_cd,
    reply->qual[bi_count_b].ext_child_reference_id = tempreply->qual[d1.seq].ext_child_reference_id,
    reply->qual[bi_count_b].ext_child_contributor_cd = tempreply->qual[d1.seq].
    ext_child_contributor_cd, reply->qual[bi_count_b].ext_description = tempreply->qual[d1.seq].
    ext_description,
    reply->qual[bi_count_b].ext_short_desc = tempreply->qual[d1.seq].ext_short_desc, reply->qual[
    bi_count_b].careset_ind = tempreply->qual[d1.seq].careset_ind, reply->qual[bi_count_b].
    beg_effective_dt_tm = tempreply->qual[d1.seq].beg_effective_dt_tm,
    reply->qual[bi_count_b].end_effective_dt_tm = tempreply->qual[d1.seq].end_effective_dt_tm, reply
    ->qual[bi_count_b].stats_only_ind = tempreply->qual[d1.seq].stats_only_ind, reply->qual[
    bi_count_b].misc_ind = tempreply->qual[d1.seq].misc_ind,
    reply->qual[bi_count_b].workload_only_ind = tempreply->qual[d1.seq].workload_only_ind, reply->
    qual[bi_count_b].late_chrg_excl_ind = tempreply->qual[d1.seq].late_chrg_excl_ind
    IF ((reply->qual[bi_count_b].match_ind=1))
     bi_match_count += 1
    ENDIF
   ELSE
    CALL echo("skip: ",0),
    CALL echo(bi_id),
    CALL echo(tempreply->qual[d1.seq].ext_description)
   ENDIF
  WITH nocounter
 ;end select
 IF (bi_count != 0)
  SET reply->bill_item_qual = bi_count_b
  SET reply->match_qual = bi_match_count
  CALL echo(build("match_qual = ",bi_match_count))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ENDIF
 IF (test_mode=1)
  SELECT
   bi_id = reply->qual[d1.seq].bill_item_id, p_ref = reply->qual[d1.seq].ext_parent_reference_id,
   p_cont = reply->qual[d1.seq].ext_parent_contributor_cd,
   c_ref = reply->qual[d1.seq].ext_child_reference_id, c_cont = reply->qual[d1.seq].
   ext_child_contributor_cd, desc = substring(1,40,reply->qual[d1.seq].ext_description),
   s_desc = substring(1,25,reply->qual[d1.seq].ext_short_desc), match_ind = reply->qual[d1.seq].
   match_ind
   FROM (dummyt d1  WITH seq = value(size(reply->qual,5)))
   PLAN (d1)
   ORDER BY p_ref, p_cont, c_ref,
    c_cont, match_ind DESC
   DETAIL
    col 00, reply->qual[d1.seq].match_ind"#", col 01,
    bi_id"########", col 10, p_ref"########",
    col 20, p_cont"########", col 30,
    c_ref"########", col 40, c_cont"########",
    col 50, desc, col 100,
    s_desc, row + 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
