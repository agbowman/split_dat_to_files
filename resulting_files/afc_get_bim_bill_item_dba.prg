CREATE PROGRAM afc_get_bim_bill_item:dba
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
 CALL beginservice("688081.030")
 DECLARE afc_get_bim_bill_item_vrsn = vc WITH constant("FT.688081.030")
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
     2 bill_item_mod_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 ext_owner_cd = f8
     2 key1_id = f8
     2 misc_ind = i2
     2 priv_ind = i2
     2 bill_item_mod_qual = i4
     2 bill_item_mods[*]
       3 bill_item_mod_id = f8
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 bim_ind = i2
       3 bim1_int = f8
   1 none_found_flg = i2
   1 ref_cont_cd = f8
   1 batch_charge_entry_seq = f8
   1 ref_cont_cd_inquiry = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD cdm(
   1 arr[*]
     2 code_value = f8
 )
 RECORD cpt(
   1 arr[*]
     2 code_value = f8
 )
 RECORD hcpcs(
   1 arr[*]
     2 code_value = f8
 )
 RECORD dcp_request(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 RECORD dcp_reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userhasprivs(dactivitytypecd) = i2
 DECLARE userhasprivsreturnvalue = i2
 DECLARE meaningforvalue = c12
 DECLARE inexceptionlist = i2
 DECLARE logicaldomainid = f8 WITH noconstant(0), protect
 DECLARE i = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE iret = i4
 DECLARE ibcschedsec = i2
 SET ibcschedsec = 0
 DECLARE 26078_bc_sched = f8
 DECLARE checkbischedsec(dbillitemid,dschedulecd) = i2
 DECLARE ibisec = i2
 SET ibcsec = 0
 DECLARE 26078_bill_item = f8
 DECLARE ord_cat = f8
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ord_cat)
 CALL echo(build("ORD_CAT: ",cnvtstring(ord_cat,17,2)))
 DECLARE bill_code = f8
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,bill_code)
 CALL echo(build("BILL_CODE: ",cnvtstring(bill_code,17,2)))
 DECLARE charge_point = f8
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,charge_point)
 CALL echo(build("CHARGE_POINT: ",cnvtstring(charge_point,17,2)))
 DECLARE group = f8
 SET code_set = 13020
 SET cdf_meaning = "GROUP"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,group)
 CALL echo(build("GROUP: ",cnvtstring(group,17,2)))
 DECLARE both = f8
 SET code_set = 13020
 SET cdf_meaning = "BOTH"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,both)
 CALL echo(build("BOTH: ",cnvtstring(both,17,2)))
 DECLARE detail_now = f8
 SET codeset = 1020
 SET cdf_meaning = "DETAIL_NOW"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,detail_now)
 CALL echo(build("DETAIL NOW: ",cnvtstring(detail_now,17,2)))
 SET stat = uar_get_meaning_by_codeset(26078,"BC_SCHED",1,26078_bc_sched)
 CALL echo(build("BC_SCHED",cnvtstring(26078_bc_sched,17,2)))
 SET stat = uar_get_meaning_by_codeset(26078,"BILL_ITEM",1,26078_bill_item)
 CALL echo(build("26078_BILL_ITEM ",cnvtstring(26078_bill_item,17,2)))
 DECLARE cpt_sched_value = f8
 SET cdf_meaning = "CPT4"
 SET code_set = 14002
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),count1,cpt_sched_value)
 IF (iret=0)
  IF (count1 > 0)
   SET stat = alterlist(cpt->arr,count1)
   SET cpt->arr[1].code_value = cpt_sched_value
  ENDIF
 ELSE
  CALL echo("Falure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),i,cpt_sched_value)
    IF (iret=0)
     SET cpt->arr[count2].code_value = cpt_sched_value
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE hcpcs_sched_value = f8
 SET cdf_meaning = "HCPCS"
 SET code_set = 14002
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),count1,hcpcs_sched_value)
 IF (iret=0)
  IF (count1 > 0)
   SET stat = alterlist(hcpcs->arr,count1)
   SET hcpcs->arr[1].code_value = hcpcs_sched_value
  ENDIF
 ELSE
  CALL echo("Falure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),i,hcpcs_sched_value)
    IF (iret=0)
     SET hcpcs->arr[count2].code_value = hcpcs_sched_value
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE 6016_chargeentry_cd = f8
 SET code_set = 6016
 SET cdf_meaning = "CHARGEENTRY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,6016_chargeentry_cd)
 CALL echo(build("6016_CHARGEENTRY_CD: ",6016_chargeentry_cd))
 DECLARE 6016_chargevient_cd = f8
 SET code_set = 6016
 SET cdf_meaning = "CHARGEVI&ENT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,6016_chargevient_cd)
 CALL echo(build("6016_CHARGEVIENT_CD: ",6016_chargevient_cd))
 DECLARE 13019_bar_code = f8
 SET code_set = 13019
 SET cdf_meaning = "BARCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13019_bar_code)
 CALL echo(build("13019_BAR_CODE: ",13019_bar_code))
 DECLARE prompt_cd = f8
 SET codeset = 13019
 SET cdf_meaning = "PROMPT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(13019,"PROMPT",1,prompt_cd)
 CALL echo(build("PROMPT_CD: ",cnvtstring(prompt_cd,17,2)))
 SET lastbillitemid = 0
 DECLARE bim_count = i4
 DECLARE codeset = i4 WITH protect, noconstant(0)
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
 SET stat = alterlist(reply->bill_item,count1)
 SET codeset = 14002
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="BILL CODE SCHED SECURITY"
   AND di.info_char="Y"
   AND di.info_domain_id=logicaldomainid
  DETAIL
   ibcsec = 1
  WITH nocounter
 ;end select
 IF ((((request->bill_code_ind=0)) OR ((((request->bill_code_ind=4)) OR ((request->bill_code_ind=8)
 )) )) )
  IF (ibcsec=1
   AND validate(request->organization_id,0) != 0)
   SELECT DISTINCT INTO "nl:"
    bim.bill_item_id
    FROM bill_item_modifier bim,
     bill_item b,
     bill_item_modifier bim2,
     cs_org_reltn cor,
     code_value cv
    PLAN (cor
     WHERE (cor.organization_id=request->organization_id)
      AND cor.cs_org_reltn_type_cd=26078_bc_sched
      AND cor.key1_entity_name="BC_SCHED"
      AND cor.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=cor.key1_id
      AND cv.code_set=codeset
      AND cv.cdf_meaning="CDM_SCHED"
      AND cv.active_ind=true)
     JOIN (bim
     WHERE bim.key1_id=cv.code_value
      AND bim.bill_item_type_cd=bill_code
      AND trim(bim.key6) != ""
      AND (bim.key6=request->cdm_code)
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=true
      AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=ord_cat))
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
     JOIN (bim2
     WHERE bim2.bill_item_id=bim.bill_item_id
      AND bim2.bill_item_type_cd=charge_point
      AND bim2.key4_id IN (group, both, detail_now)
      AND bim2.active_ind=true)
    ORDER BY bim.bill_item_id
    DETAIL
     IF (bim.bill_item_id != lastbillitemid)
      count1 += 1, stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
      bill_item_mod_id = bim.bill_item_mod_id,
      reply->bill_item[count1].bill_item_id = bim.bill_item_id
      IF ((request->bill_code_ind=0))
       reply->bill_item[count1].ext_description = bim.key7
      ELSEIF ((request->bill_code_ind=4))
       reply->bill_item[count1].ext_description = b.ext_description
      ELSEIF ((request->bill_code_ind=8))
       reply->bill_item[count1].ext_description = b.ext_short_desc
      ENDIF
      reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
      count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
      ext_child_reference_id = b.ext_child_reference_id,
      reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
      bill_item[count1].ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b
      .ext_owner_cd,
      reply->bill_item[count1].misc_ind = b.misc_ind, reply->bill_item[count1].key1_id = bim.key1_id,
      CALL echo(concat("Bill item: ",cnvtstring(b.bill_item_id,17,2)," ",bim.key7)),
      CALL echo(build("    owner cd: ",b.ext_owner_cd)), lastbillitemid = bim.bill_item_id
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->bill_item,count1)
   SET reply->bill_item_qual = count1
   CALL echo(concat("count1: ",cnvtstring(count1)))
  ELSE
   SELECT DISTINCT INTO "nl:"
    bim.bill_item_id
    FROM bill_item_modifier bim,
     bill_item b,
     bill_item_modifier bim2
    PLAN (bim
     WHERE bim.bill_item_type_cd=bill_code
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=bim.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.active_ind=1))
      AND trim(bim.key6) != ""
      AND (bim.key6=request->cdm_code)
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1
      AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=ord_cat))
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
     JOIN (bim2
     WHERE bim2.bill_item_id=bim.bill_item_id
      AND bim2.bill_item_type_cd=charge_point
      AND bim2.key4_id IN (group, both, detail_now)
      AND bim2.active_ind=1)
    ORDER BY bim.bill_item_id
    DETAIL
     IF (bim.bill_item_id != lastbillitemid)
      count1 += 1, stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
      bill_item_mod_id = bim.bill_item_mod_id,
      reply->bill_item[count1].bill_item_id = bim.bill_item_id
      IF ((request->bill_code_ind=0))
       reply->bill_item[count1].ext_description = bim.key7
      ELSEIF ((request->bill_code_ind=4))
       reply->bill_item[count1].ext_description = b.ext_description
      ELSEIF ((request->bill_code_ind=8))
       reply->bill_item[count1].ext_description = b.ext_short_desc
      ENDIF
      reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
      count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
      ext_child_reference_id = b.ext_child_reference_id,
      reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
      bill_item[count1].ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b
      .ext_owner_cd,
      reply->bill_item[count1].misc_ind = b.misc_ind, reply->bill_item[count1].key1_id = bim.key1_id,
      CALL echo(concat("Bill item: ",cnvtstring(b.bill_item_id,17,2)," ",bim.key7)),
      CALL echo(build("    owner cd: ",b.ext_owner_cd)), lastbillitemid = bim.bill_item_id
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->bill_item,count1)
   SET reply->bill_item_qual = count1
   CALL echo(concat("count1: ",cnvtstring(count1)))
  ENDIF
 ELSEIF ((((request->bill_code_ind=1)) OR ((((request->bill_code_ind=5)) OR ((request->bill_code_ind=
 9))) )) )
  SELECT DISTINCT INTO "nl:"
   bim.bill_item_id, b.bill_item_id
   FROM bill_item_modifier bim,
    bill_item b,
    (dummyt d1  WITH seq = value(size(cpt->arr,5))),
    bill_item_modifier bim2
   PLAN (d1)
    JOIN (bim
    WHERE bim.bill_item_type_cd=bill_code
     AND (bim.key1_id=cpt->arr[d1.seq].code_value)
     AND trim(bim.key6) != ""
     AND (bim.key6=request->cpt_code)
     AND ((bim.bim1_int=1) OR (bim.key2_id=1))
     AND bim.active_ind=1
     AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=ord_cat))
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (bim2
    WHERE bim2.bill_item_id=bim.bill_item_id
     AND bim2.bill_item_type_cd=charge_point
     AND bim2.key4_id IN (group, both, detail_now)
     AND bim2.active_ind=1)
   ORDER BY bim.bill_item_id
   DETAIL
    IF (lastbillitemid != bim.bill_item_id)
     count1 += 1, stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
     bill_item_mod_id = bim.bill_item_mod_id,
     reply->bill_item[count1].bill_item_id = bim.bill_item_id
     IF ((request->bill_code_ind=1))
      reply->bill_item[count1].ext_description = bim.key7
     ELSEIF ((request->bill_code_ind=5))
      reply->bill_item[count1].ext_description = b.ext_description
     ELSEIF ((request->bill_code_ind=9))
      reply->bill_item[count1].ext_description = b.ext_short_desc
     ENDIF
     reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
     count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
     ext_child_reference_id = b.ext_child_reference_id,
     reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
     bill_item[count1].ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b
     .ext_owner_cd,
     reply->bill_item[count1].misc_ind = b.misc_ind, reply->bill_item[count1].key1_id = bim.key1_id,
     CALL echo(concat("Bill item: ",cnvtstring(b.bill_item_id,17,2)," ",bim.key7)),
     lastbillitemid = bim.bill_item_id
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bill_item,count1)
  SET reply->bill_item_qual = count1
  CALL echo(concat("count1: ",cnvtstring(count1)))
 ELSEIF ((((request->bill_code_ind=2)) OR ((((request->bill_code_ind=6)) OR ((request->bill_code_ind=
 10))) )) )
  SELECT DISTINCT INTO "nl:"
   bim.bill_item_id, b.bill_item_id
   FROM bill_item_modifier bim,
    bill_item b,
    (dummyt d1  WITH seq = value(size(hcpcs->arr,5))),
    bill_item_modifier bim2
   PLAN (d1)
    JOIN (bim
    WHERE bim.bill_item_type_cd=bill_code
     AND (bim.key1_id=hcpcs->arr[d1.seq].code_value)
     AND trim(bim.key6) != ""
     AND (bim.key6=request->hcpcs_code)
     AND ((bim.bim1_int=1) OR (bim.key2_id=1))
     AND bim.active_ind=1
     AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=ord_cat))
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (bim2
    WHERE bim2.bill_item_id=bim.bill_item_id
     AND bim2.bill_item_type_cd=charge_point
     AND bim2.key4_id IN (group, both, detail_now)
     AND bim2.active_ind=1)
   ORDER BY bim.bill_item_id
   DETAIL
    IF (lastbillitemid != bim.bill_item_id)
     count1 += 1, stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
     bill_item_mod_id = bim.bill_item_mod_id,
     reply->bill_item[count1].bill_item_id = bim.bill_item_id
     IF ((request->bill_code_ind=2))
      reply->bill_item[count1].ext_description = bim.key7
     ELSEIF ((request->bill_code_ind=6))
      reply->bill_item[count1].ext_description = b.ext_description
     ELSEIF ((request->bill_code_ind=10))
      reply->bill_item[count1].ext_description = b.ext_short_desc
     ENDIF
     reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
     count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
     ext_child_reference_id = b.ext_child_reference_id,
     reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
     bill_item[count1].ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b
     .ext_owner_cd,
     reply->bill_item[count1].misc_ind = b.misc_ind, reply->bill_item[count1].key1_id = bim.key1_id,
     CALL echo(concat("Bill item: ",cnvtstring(b.bill_item_id,17,2)," ",bim.key7)),
     lastbillitemid = bim.bill_item_id
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bill_item,count1)
  SET reply->bill_item_qual = count1
  CALL echo(concat("count1: ",cnvtstring(count1)))
 ELSEIF ((((request->bill_code_ind=3)) OR ((((request->bill_code_ind=7)) OR ((request->bill_code_ind=
 11))) )) )
  SELECT INTO "nl:"
   bim.bill_item_id, b.bill_item_id
   FROM bill_item_modifier bim,
    bill_item b,
    bill_item_modifier bim2
   PLAN (bim
    WHERE bim.bill_item_type_cd=13019_bar_code
     AND trim(bim.key6) != ""
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=ord_cat))
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    JOIN (bim2
    WHERE bim2.bill_item_id=bim.bill_item_id
     AND bim2.bill_item_type_cd=charge_point
     AND bim2.key4_id IN (group, both, detail_now)
     AND bim2.active_ind=1)
   ORDER BY bim.bill_item_id
   DETAIL
    IF (lastbillitemid != bim.bill_item_id)
     CALL echo(build("bill_item_mod_id: ",bim.bill_item_mod_id))
     IF (cnvtalphanum(cnvtupper(request->bar_code))=cnvtalphanum(cnvtupper(bim.key6)))
      CALL echo("FOUND MATCH"), count1 += 1, stat = alterlist(reply->bill_item,count1),
      reply->bill_item[count1].bill_item_mod_id = bim.bill_item_mod_id, reply->bill_item[count1].
      bill_item_id = bim.bill_item_id
      IF ((request->bill_code_ind=3))
       reply->bill_item[count1].ext_description = bim.key7
      ELSEIF ((request->bill_code_ind=7))
       reply->bill_item[count1].ext_description = b.ext_description
      ELSEIF ((request->bill_code_ind=11))
       reply->bill_item[count1].ext_description = b.ext_short_desc
      ENDIF
      reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
      count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
      ext_child_reference_id = b.ext_child_reference_id,
      reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
      bill_item[count1].ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b
      .ext_owner_cd,
      reply->bill_item[count1].misc_ind = b.misc_ind, reply->bill_item[count1].key1_id = bim.key1_id,
      CALL echo(concat("Bill item: ",cnvtstring(b.bill_item_id,17,2)," ",bim.key7)),
      lastbillitemid = bim.bill_item_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bill_item,count1)
  SET reply->bill_item_qual = count1
  CALL echo(concat("count1: ",cnvtstring(count1)))
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM_MODIFIER"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->bill_item_qual > 0))
  SET bim_count = 0
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    (dummyt d1  WITH seq = value(size(reply->bill_item,5)))
   PLAN (d1)
    JOIN (bim
    WHERE (bim.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
     AND bim.bill_item_type_cd=prompt_cd
     AND bim.active_ind=1)
   ORDER BY bim.bill_item_id
   HEAD bim.bill_item_id
    bim_count = 0
   DETAIL
    bim_count += 1, stat = alterlist(reply->bill_item[d1.seq].bill_item_mods,bim_count), reply->
    bill_item[d1.seq].bill_item_mods[bim_count].bill_item_mod_id = bim.bill_item_mod_id,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].bill_item_type_cd = bim.bill_item_type_cd,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].key1_id = bim.key1_id, reply->bill_item[d1.seq
    ].bill_item_mods[bim_count].bim_ind = bim.bim_ind,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].bim1_int = bim.bim1_int, reply->bill_item[d1
    .seq].bill_item_mod_qual = bim_count
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET billitemcounter = 0
  IF ((request->bill_code_ind=0))
   SELECT DISTINCT INTO "nl:"
    FROM bill_item_modifier bim,
     bill_item b
    PLAN (bim
     WHERE bim.bill_item_type_cd=bill_code
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=bim.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.active_ind=1))
      AND trim(bim.key6) != ""
      AND (bim.key6=request->cdm_code)
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1
      AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=ord_cat))
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    DETAIL
     reply->none_found_flg = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->bill_code_ind=1))
   SELECT DISTINCT INTO "nl:"
    FROM bill_item_modifier bim,
     bill_item b,
     (dummyt d1  WITH seq = value(size(cpt->arr,5)))
    PLAN (d1)
     JOIN (bim
     WHERE bim.bill_item_type_cd=bill_code
      AND (bim.key1_id=cpt->arr[d1.seq].code_value)
      AND trim(bim.key6) != ""
      AND (bim.key6=request->cpt_code)
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1
      AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=ord_cat))
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    DETAIL
     reply->none_found_flg = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->bill_code_ind=2))
   SELECT DISTINCT INTO "nl:"
    FROM bill_item_modifier bim,
     bill_item b,
     (dummyt d1  WITH seq = value(size(hcpcs->arr,5)))
    PLAN (d1)
     JOIN (bim
     WHERE bim.bill_item_type_cd=bill_code
      AND (bim.key1_id=hcpcs->arr[d1.seq].code_value)
      AND trim(bim.key6) != ""
      AND (bim.key6=request->hcpcs_code)
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1
      AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=ord_cat))
      AND b.active_ind=1
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    DETAIL
     reply->none_found_flg = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->bill_code_ind=3))
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    bill_item b
   PLAN (bim
    WHERE bim.bill_item_type_cd=13019_bar_code
     AND trim(bim.key6) != ""
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=ord_cat))
     AND b.active_ind=1
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
   DETAIL
    IF (cnvtalphanum(cnvtupper(request->bar_code))=cnvtalphanum(cnvtupper(bim.key6)))
     reply->none_found_flg = 1,
     CALL echo("none_found_flg = 1")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("Getting CHARGE_ENTRY code_value...")
 DECLARE charge_entry = f8
 SET code_set = 13016
 SET cdf_meaning = "CHARGE ENTRY"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),1,charge_entry)
 CALL echo(build("CHARGE_ENTRY: ",cnvtstring(charge_entry,17,2)))
 SET reply->ref_cont_cd = charge_entry
 CALL echo(concat("REF_CONT_CD: ",cnvtstring(reply->ref_cont_cd,17,2)))
 SELECT INTO "nl:"
  y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->batch_charge_entry_seq = cnvtreal(y)
  WITH format, counter
 ;end select
 CALL echo("Getting INQUIRY code_value...")
 DECLARE inquiry = f8
 SET code_set = 13016
 SET cdf_meaning = "INQUIRY"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),1,inquiry)
 CALL echo(build("INQUIRY: ",cnvtstring(inquiry,17,2)))
 SET reply->ref_cont_cd_inquiry = inquiry
 CALL echo(concat("REF_CONT_CD_INQUIRY: ",cnvtstring(reply->ref_cont_cd_inquiry,17,2)))
 CALL echo(build("bill item qual: ",reply->bill_item_qual))
 FOR (nbicount = 1 TO reply->bill_item_qual)
   CALL echo(build("checking bill item: ",reply->bill_item[nbicount].bill_item_id))
   CALL echo(build("    with activity type: ",reply->bill_item[nbicount].ext_owner_cd))
   SET inexceptionlist = 0
   SET userhasprivsreturnvalue = 0
   IF (userhasprivs(reply->bill_item[nbicount].ext_owner_cd)=1)
    SET reply->bill_item[nbicount].priv_ind = 1
    CALL echo(build("priv_ind: ",reply->bill_item[nbicount].priv_ind))
   ENDIF
   CALL echo(build("result is: ",reply->bill_item[nbicount].priv_ind))
 ENDFOR
 SET ibcsec = 0
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
 SET ibisec = 0
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
 IF (((ibcsec=1) OR (ibisec=1)) )
  CALL echo("Checking Bill Code Schedule/BILL ITEM Security")
  CALL echo(build("bill item qual: ",reply->bill_item_qual))
  SET nbicount = 0
  FOR (nbicount = 1 TO reply->bill_item_qual)
    CALL echo(build("checking bill item: ",reply->bill_item[nbicount].bill_item_id))
    IF ((reply->bill_item[nbicount].priv_ind=0))
     SET checkbischedsecreturnvalue = 0
     IF (checkbischedsec(reply->bill_item[nbicount].bill_item_id,reply->bill_item[nbicount].key1_id)=
     1)
      SET reply->bill_item[nbicount].priv_ind = 1
      CALL echo(build("priv_ind: ",reply->bill_item[nbicount].priv_ind))
     ENDIF
    ENDIF
    CALL echo(build("result is: ",reply->bill_item[nbicount].priv_ind))
  ENDFOR
 ENDIF
 SUBROUTINE userhasprivs(dactivitytypecd)
   CALL echo(build("executing UserHasPrivs for activity type: ",dactivitytypecd))
   CALL echo(build("and position: ",reqinfo->position_cd))
   SET stat = alterlist(dcp_reply->qual,0)
   SET dcp_request->chk_psn_ind = 1
   SET stat = alterlist(dcp_request->plist,1)
   SET dcp_request->plist[1].privilege_mean = "CHARGEENTRY"
   SET dcp_request->plist[1].privilege_cd = 6016_chargeentry_cd
   EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
   IF (size(dcp_reply->qual,5)=0)
    CALL echo("Did not find anything for CHARGEENTRY, trying CHARGEVIE&ENT")
    SET dcp_request->plist[1].privilege_meaning = "CHARGEVI&ENT"
    SET dcp_request->plist[1].privilege_cd = 6016_chargevient_cd
    EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
   ENDIF
   IF (size(dcp_reply->qual,5)=1)
    CALL echo(build("priv_value_cd: ",dcp_reply->qual[1].priv_value_cd))
    IF ((dcp_reply->qual[1].priv_value_cd=0))
     CALL echo("PRIV NOT DEFINED.  Trying CHARGEVIE&ENT")
     SET dcp_request->plist[1].privilege_mean = "CHARGEVI&ENT"
     SET dcp_request->plist[1].privilege_cd = 6016_chargevient_cd
     EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
    ENDIF
   ENDIF
   CALL echo(build("Back from call to dcp size is: ",size(dcp_reply->qual,5)))
   IF (size(dcp_reply->qual,5) > 0)
    FOR (nrepcount = 1 TO size(dcp_reply->qual,5))
      SET meaningforvalue = uar_get_code_meaning(dcp_reply->qual[nrepcount].priv_value_cd)
      CALL echo(build("MeaningForValue: ",meaningforvalue))
      IF (meaningforvalue="YES")
       SET userhasprivsreturnvalue = 0
      ELSEIF (meaningforvalue="NO")
       SET userhasprivsreturnvalue = 1
      ELSEIF (meaningforvalue="EXCLUDE")
       CALL echo("In 'Yes, except for'")
       FOR (nexceptionloop = 1 TO dcp_reply->qual[nrepcount].except_cnt)
         IF ((dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name=
         "ACTIVITY TYPE"))
          IF ((dactivitytypecd=dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
           SET inexceptionlist = 1
           CALL echo(build("User allowed except for: ",dactivitytypecd))
          ENDIF
         ENDIF
       ENDFOR
       IF (inexceptionlist=1)
        SET userhasprivsreturnvalue = 1
       ENDIF
      ELSEIF (meaningforvalue="INCLUDE")
       FOR (nexceptionloop = 1 TO dcp_reply->qual[nrepcount].except_cnt)
         IF ((dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name=
         "ACTIVITY TYPE"))
          CALL echo("exception_entity_name is ACTIVITY TYPE")
          CALL echo(build("exception_cd: ",dcp_reply->qual[nrepcount].excepts[nexceptionloop].
            exception_id))
          CALL echo(build("comparing against: ",dactivitytypecd))
          IF ((dactivitytypecd=dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
           SET inexceptionlist = 1
          ENDIF
         ENDIF
       ENDFOR
       IF (inexceptionlist=0)
        SET userhasprivsreturnvalue = 1
       ENDIF
      ELSE
       CALL echo("Nothing built for this activity type/user")
      ENDIF
    ENDFOR
   ELSE
    CALL echo("Didn't find anything.  Nothing built in PrivTool")
   ENDIF
   RETURN(userhasprivsreturnvalue)
 END ;Subroutine
 SUBROUTINE checkbischedsec(dbillitemid,dschedulecd)
   DECLARE bcschedulecdfmeaning = vc
   CALL echo(build("executing CheckBISchedSec for Bill Item: ",dbillitemid))
   CALL echo(build("                          and Schedule:  ",dschedulecd))
   CALL echo(build("and user_id is: ",reqinfo->updt_id))
   IF (ibcsec=1)
    SET found_one = 0
    IF (((trim(request->cdm_code) != "") OR (((trim(request->cpt_code) != "") OR (trim(request->
     hcpcs_code) != "")) )) )
     SET bcschedulecdfmeaning = uar_get_code_meaning(dschedulecd)
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       cs_org_reltn cor,
       code_value cv,
       bill_item_modifier bim
      PLAN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND por.active_ind=1)
       JOIN (cor
       WHERE cor.organization_id=por.organization_id
        AND cor.cs_org_reltn_type_cd=26078_bc_sched
        AND cor.key1_entity_name="BC_SCHED"
        AND cor.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=cor.key1_id
        AND cv.active_ind=true
        AND cv.cdf_meaning=bcschedulecdfmeaning)
       JOIN (bim
       WHERE bim.key1_id=cv.code_value
        AND bim.bill_item_id=dbillitemid
        AND bim.bill_item_type_cd=bill_code
        AND bim.key6=evaluate2(
        IF (trim(request->cdm_code) != "") trim(request->cdm_code)
        ELSEIF (trim(request->cpt_code) != "") trim(request->cpt_code)
        ELSEIF (trim(request->hcpcs_code) != "") trim(request->hcpcs_code)
        ENDIF
        )
        AND bim.active_ind=1
        AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
      DETAIL
       found_one = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       cs_org_reltn cor,
       bill_item_modifier bim
      PLAN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND por.active_ind=1)
       JOIN (cor
       WHERE cor.organization_id=por.organization_id
        AND cor.cs_org_reltn_type_cd=26078_bc_sched
        AND cor.key1_entity_name="BC_SCHED"
        AND cor.key1_id=dschedulecd
        AND cor.active_ind=1)
       JOIN (bim
       WHERE bim.key1_id=cor.key1_id
        AND bim.bill_item_id=dbillitemid
        AND bim.bill_item_type_cd=bill_code
        AND bim.active_ind=1)
      DETAIL
       found_one = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (found_one=0)
     SET checkbischedsecreturnvalue = 1
    ENDIF
   ELSE
    CALL echo("Bill Code Schedule security option is off")
   ENDIF
   IF (ibisec=1
    AND checkbischedsecreturnvalue=0)
    CALL echo("BILL ITEM security option is on and we did not fail for bc sched security")
    SET found_one = 0
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por,
      cs_org_reltn cor
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=26078_bill_item
       AND cor.key1_entity_name="BILL_ITEM"
       AND cor.key1_id=dbillitemid
       AND cor.active_ind=1)
     DETAIL
      found_one = 1
     WITH nocounter
    ;end select
    IF (found_one=0)
     CALL echo("The user does not have privs to see the bill item")
     SET checkbischedsecreturnvalue = 1
    ENDIF
   ENDIF
   RETURN(checkbischedsecreturnvalue)
 END ;Subroutine
#exit_script
END GO
