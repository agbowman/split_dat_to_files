CREATE PROGRAM afc_get_charges:dba
 DECLARE versionnbr = vc
 SET versionnbr = "CHARGSRV-16054.102"
 CALL echo(build("AFC_GET_CHARGES Version: ",versionnbr))
 SET message = nowindow
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
 CALL echo("Begin PFT_GET_ORGANIZATION_SUBS.INC, version [565928.008]")
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
 IF ( NOT (validate(cs278_facility_cd)))
  DECLARE cs278_facility_cd = f8 WITH protect, constant(getcodevalue(278,"FACILITY",1))
 ENDIF
 IF ( NOT (validate(cs20849_client_cd)))
  DECLARE cs20849_client_cd = f8 WITH protect, constant(getcodevalue(20849,"CLIENT",1))
 ENDIF
 IF ( NOT (validate(getauthorizedorganizations)))
  SUBROUTINE (getauthorizedorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedOrganizations","Failed to retrieve logical domain ID...",log_error
      )
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       code_value cv,
       organization o
      PLAN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
       JOIN (o
       WHERE o.organization_id=por.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY por.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM organization o,
       org_type_reltn otr
      PLAN (o
       WHERE o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (otr
       WHERE otr.organization_id=o.organization_id
        AND otr.org_type_cd=cs278_facility_cd
        AND otr.active_ind=true)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedprofitorganizations)))
  SUBROUTINE (getauthorizedprofitorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedProFitOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedProFitOrganizations","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       be_org_reltn bor,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM billing_entity be,
       be_org_reltn bor,
       organization o
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedProFitOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedclientorganizations)))
  SUBROUTINE (getauthorizedclientorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedClientOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedClientOrganizations","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       account a,
       pft_acct_reltn par,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (a
       WHERE a.billing_entity_id=be.billing_entity_id
        AND a.active_ind=true
        AND a.acct_sub_type_cd=cs20849_client_cd)
       JOIN (par
       WHERE par.acct_id=a.acct_id
        AND par.active_ind=true
        AND par.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=par.parent_entity_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY o.organization_id
      HEAD o.organization_id
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM billing_entity be,
       account a,
       pft_acct_reltn par,
       organization o
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (a
       WHERE a.billing_entity_id=be.billing_entity_id
        AND a.active_ind=true
        AND a.acct_sub_type_cd=cs20849_client_cd)
       JOIN (par
       WHERE par.acct_id=a.acct_id
        AND par.active_ind=true
        AND par.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=par.parent_entity_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY o.organization_id
      HEAD o.organization_id
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedClientOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedprofitandclientorganizations)))
  SUBROUTINE (getauthorizedprofitandclientorganizations(authorizedclientorganizations=vc(ref),
   authorizedprofitorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedProFitAndClientOrganizations","Entering...",log_debug)
    FREE RECORD combinedorganizations
    RECORD combinedorganizations(
      1 organizations[*]
        2 organizationid = f8
        2 confidentialitylevel = i4
    )
    DECLARE num = i4 WITH protect, noconstant(0)
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    DECLARE startidx = i4 WITH protect, noconstant(0)
    DECLARE combinedorgcnt = i4 WITH protect, noconstant(0)
    DECLARE clientorgcnt = i4 WITH protect, noconstant(size(authorizedclientorganizations->
      organizations,5))
    DECLARE profitorgcnt = i4 WITH protect, noconstant(size(authorizedprofitorganizations->
      organizations,5))
    IF (profitorgcnt=0)
     CALL logmessage("getAuthorizedProFitAndClientOrganizations","No ProFit org to merge, exiting...",
      log_debug)
     RETURN(true)
    ELSEIF (clientorgcnt=0)
     SET stat = initrec(authorizedclientorganizations)
     SET stat = moverec(authorizedprofitorganizations,authorizedclientorganizations)
     CALL logmessage("getAuthorizedProFitAndClientOrganizations","No Client org to merge, exiting...",
      log_debug)
     RETURN(true)
    ENDIF
    SET stat = moverec(authorizedclientorganizations,combinedorganizations)
    FOR (loopidx = 1 TO profitorgcnt)
      IF (locateval(num,1,clientorgcnt,authorizedprofitorganizations->organizations[loopidx].
       organizationid,authorizedclientorganizations->organizations[num].organizationid)=0)
       SET combinedorgcnt = (size(combinedorganizations->organizations,5)+ 1)
       SET stat = alterlist(combinedorganizations->organizations,combinedorgcnt)
       SET combinedorganizations->organizations[combinedorgcnt].organizationid =
       authorizedprofitorganizations->organizations[loopidx].organizationid
       SET combinedorganizations->organizations[combinedorgcnt].confidentialitylevel =
       authorizedprofitorganizations->organizations[loopidx].confidentialitylevel
      ENDIF
    ENDFOR
    SET stat = initrec(authorizedclientorganizations)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(combinedorganizations->organizations,5)))
     PLAN (d1
      WHERE (combinedorganizations->organizations[d1.seq].organizationid > 0.0))
     ORDER BY combinedorganizations->organizations[d1.seq].organizationid
     DETAIL
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedclientorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedclientorganizations->organizations[organizationcount].organizationid =
      combinedorganizations->organizations[d1.seq].organizationid, authorizedclientorganizations->
      organizations[organizationcount].confidentialitylevel = combinedorganizations->organizations[d1
      .seq].confidentialitylevel
     FOOT REPORT
      stat = alterlist(authorizedclientorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
    FREE RECORD combinedorganizations
    CALL logmessage("getAuthorizedProFitAndClientOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getbillingentities)))
  SUBROUTINE (getbillingentities(billingentities=vc(ref)) =i2)
    CALL logmessage("getBillingEntities","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getBillingEntities","Failed to retrieve logical domain ID...",log_error)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM billing_entity be,
      organization o
     PLAN (be
      WHERE be.active_ind=true)
      JOIN (o
      WHERE o.organization_id=be.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
     ORDER BY be.billing_entity_id
     HEAD REPORT
      billingentitycount = 0
     DETAIL
      billingentitycount += 1, stat = alterlist(billingentities->billingentities,billingentitycount),
      billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedbillingentities)))
  SUBROUTINE (getauthorizedbillingentities(billingentities=vc(ref)) =i2)
    CALL logmessage("getAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE billingentitycount = i4 WITH protect, noconstant(0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echorecord(billingentities)
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (o
       WHERE o.organization_id=be.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY be.billing_entity_id
      HEAD be.billing_entity_id
       billingentitycount += 1
       IF (mod(billingentitycount,20)=1)
        stat = alterlist(billingentities->billingentities,(billingentitycount+ 19))
       ENDIF
       billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
      FOOT REPORT
       stat = alterlist(billingentities->billingentities,billingentitycount)
      WITH nocounter
     ;end select
    ELSE
     IF ( NOT (getbillingentities(billingentities)))
      CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve Billing Entity ID's...",
       log_error)
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedbillingentitiesbyuserid)))
  SUBROUTINE (getauthorizedbillingentitiesbyuserid(billingentities=vc(ref)) =i2)
    CALL logmessage("getAuthorizedBillingEntitiesByUserId","Entering...",log_debug)
    DECLARE billingentitycount = i4 WITH protect, noconstant(0)
    DECLARE isbillingentitysecurityon = i2 WITH protect, constant(isbillingentitysecurityon(0))
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedBillingEntitiesByUserId","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    IF (isbillingentitysecurityon)
     SELECT DISTINCT
      be.billing_entity_id
      FROM billing_entity be,
       be_org_reltn bor,
       organization o,
       be_prsnl_group_r bg,
       pft_prsnl_group_r pg
      PLAN (pg
       WHERE (pg.prsnl_id=reqinfo->updt_id)
        AND pg.active_ind=true)
       JOIN (bg
       WHERE bg.pft_prsnl_group_id=pg.pft_prsnl_group_id
        AND bg.active_ind=true)
       JOIN (be
       WHERE be.billing_entity_id=bg.billing_entity_id
        AND be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY be.billing_entity_id
      DETAIL
       billingentitycount += 1
       IF (mod(billingentitycount,20)=1)
        stat = alterlist(billingentities->billingentities,(billingentitycount+ 19))
       ENDIF
       billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
      FOOT REPORT
       stat = alterlist(billingentities->billingentities,billingentitycount)
      WITH nocounter
     ;end select
    ELSE
     IF ( NOT (getbillingentities(billingentities)))
      CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve Billing Entity ID's...",
       log_error)
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getAuthorizedBillingEntitiesByUserId","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isorganizationsecurityon)))
  DECLARE isorganizationsecurityon(null) = i2
  SUBROUTINE isorganizationsecurityon(null)
    CALL logmessage("isOrganizationSecurityOn","Entering...",log_debug)
    DECLARE isorgsecurityon = i2 WITH protect, noconstant(false)
    IF (validate(ccldminfo->mode,0))
     IF ((ccldminfo->sec_org_reltn > 0))
      SET isorgsecurityon = true
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name="SEC_ORG_RELTN"
       AND di.info_domain="SECURITY"
       AND di.info_number > 0.0
      DETAIL
       isorgsecurityon = true
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("isOrganizationSecurityOn",build2("Organization security is ",evaluate(
       isorgsecurityon,true,"on","off")),log_debug)
    CALL logmessage("isOrganizationSecurityOn","Exiting...",log_debug)
    RETURN(isorgsecurityon)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isbillingentitysecurityon)))
  DECLARE isbillingentitysecurityon(null) = i2
  SUBROUTINE isbillingentitysecurityon(null)
    CALL logmessage("isBillingEntitySecurityOn","Entering...",log_debug)
    DECLARE isbillingentitysecurityon = i2 WITH protect, noconstant(false)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("isBillingEntitySecurityOn","Failed to retrieve logical domain ID...",log_error)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_BE_RELTN"
      AND di.info_domain="SECURITY"
      AND di.info_domain_id=organizationlogicaldomainid
      AND di.info_number > 0.0
     DETAIL
      isbillingentitysecurityon = true
     WITH nocounter
    ;end select
    CALL logmessage("isBillingEntitySecurityOn",build2("Billing Entity security is ",evaluate(
       isbillingentitysecurityon,true,"on","off")),log_debug)
    CALL logmessage("isBillingEntitynSecurityOn","Exiting...",log_debug)
    RETURN(isbillingentitysecurityon)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isconfidentialitysecurityon)))
  DECLARE isconfidentialitysecurityon(null) = i2
  SUBROUTINE isconfidentialitysecurityon(null)
    CALL logmessage("isConfidentialitySecurityOn","Entering...",log_debug)
    DECLARE isconfidsecurityon = i2 WITH protect, noconstant(false)
    IF (validate(ccldminfo->mode,0))
     IF ((ccldminfo->sec_confid > 0))
      SET isconfidsecurityon = true
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name="SEC_CONFID"
       AND di.info_domain="SECURITY"
       AND di.info_number > 0.0
      DETAIL
       isconfidsecurityon = true
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("isConfidentialitySecurityOn",build2("Confidentiality level security is ",
      evaluate(isconfidsecurityon,true,"on","off")),log_debug)
    CALL logmessage("isConfidentialitySecurityOn","Exiting...",log_debug)
    RETURN(isconfidsecurityon)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getauthorizedprofitorgsforbe(billingentityids=vc,authorizedorganizations=vc(ref)) =i2)
   CALL logmessage("getAuthorizedProFitOrgsForBe","Entering...",log_debug)
   DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
   DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
   DECLARE organizationcount = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
    CALL logmessage("getAuthorizedProFitOrgsForBe","Failed to retrieve logical domain ID...",
     log_error)
    RETURN(false)
   ENDIF
   IF (isorgsecurityon)
    SELECT INTO "nl:"
     FROM billing_entity be,
      be_org_reltn bor,
      organization o,
      prsnl_org_reltn por,
      code_value cv
     PLAN (be
      WHERE expand(iidx,1,size(billingentityids->billingentities,5),be.billing_entity_id,
       billingentityids->billingentities[iidx].billingentityid)
       AND be.active_ind=true)
      JOIN (bor
      WHERE bor.billing_entity_id=be.billing_entity_id
       AND bor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=bor.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
      JOIN (por
      WHERE por.organization_id=o.organization_id
       AND (por.person_id=reqinfo->updt_id)
       AND por.active_ind=true
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (cv
      WHERE cv.code_value=por.confid_level_cd)
     ORDER BY o.organization_id
     HEAD o.organization_id
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
      authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
      .collation_seq
     FOOT REPORT
      stat = alterlist(authorizedorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM billing_entity be,
      be_org_reltn bor,
      organization o
     PLAN (be
      WHERE expand(iidx,1,size(billingentityids->billingentities,5),be.billing_entity_id,
       billingentityids->billingentities[iidx].billingentityid)
       AND be.active_ind=true)
      JOIN (bor
      WHERE bor.billing_entity_id=be.billing_entity_id
       AND bor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=bor.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
     ORDER BY o.organization_id
     HEAD o.organization_id
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
      authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
     FOOT REPORT
      stat = alterlist(authorizedorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
   CALL logmessage("getAuthorizedProFitOrgsForBe","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 CALL beginservice("565928.005")
 IF (validate(getprofitauthorizedbillingentities,char(128))=char(128))
  SUBROUTINE (getprofitauthorizedbillingentities(authorizedgrpbillingenitities=vc(ref)) =i2)
    CALL logmessage("getProfitAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE becount = i4 WITH protect, noconstant(0)
    SELECT DISTINCT INTO "nl:"
     FROM be_prsnl_group_r bpg,
      billing_entity be,
      pft_prsnl_group_r pgr
     PLAN (pgr
      WHERE (pgr.prsnl_id=reqinfo->updt_id)
       AND pgr.active_ind=true)
      JOIN (bpg
      WHERE bpg.pft_prsnl_group_id=pgr.pft_prsnl_group_id
       AND bpg.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=bpg.billing_entity_id
       AND be.active_ind=true)
     DETAIL
      becount += 1, stat = alterlist(authorizedgrpbillingenitities->billingentities,becount),
      authorizedgrpbillingenitities->billingentities[becount].billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    CALL logmessage("getProfitAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getuserauthorizedbillingentities,char(128))=char(128))
  SUBROUTINE (getuserauthorizedbillingentities(authorizedbillingentities=vc(ref)) =i2)
    CALL logmessage("getUserAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE bcnt = i4 WITH protect, noconstant(0)
    DECLARE rcnt = i4 WITH protect, noconstant(0)
    DECLARE lidx = i4 WITH protect, noconstant(0)
    DECLARE bposition = i4 WITH protect, noconstant(0)
    RECORD userauthorizedbillingentities(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    RECORD profitauthorizedbillingentities(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    IF ( NOT (getauthorizedbillingentities(userauthorizedbillingentities)))
     CALL exitservicefailure("Unable to retrieve Authorized Biling Entity ID's",true)
    ENDIF
    IF ( NOT (getprofitauthorizedbillingentities(profitauthorizedbillingentities)))
     CALL exitservicefailure("Unable to retrieve Logical Biling Entity ID's",true)
    ENDIF
    FOR (bcnt = 1 TO size(profitauthorizedbillingentities->billingentities,5))
     SET bposition = locateval(lidx,1,size(userauthorizedbillingentities->billingentities,5),
      profitauthorizedbillingentities->billingentities[bcnt].billingentityid,
      userauthorizedbillingentities->billingentities[lidx].billingentityid)
     IF (bposition > 0)
      SET rcnt += 1
      SET stat = alterlist(authorizedbillingentities->billingentities,rcnt)
      SET authorizedbillingentities->billingentities[rcnt].billingentityid =
      profitauthorizedbillingentities->billingentities[bcnt].billingentityid
     ENDIF
    ENDFOR
    CALL logmessage("getUserAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(validatemultiaccountencountersexist,char(128))=char(128))
  SUBROUTINE (validatemultiaccountencountersexist(pencounterid=f8) =i2)
    CALL logmessage("validateMultiAccountEncountersExist","Enter",log_debug)
    DECLARE cs20849_acct_sub_type_cd_patient = f8 WITH protect, constant(getcodevalue(20849,"PATIENT",
      0))
    DECLARE multiaccountcount = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      account a
     PLAN (pe
      WHERE pe.encntr_id=pencounterid
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.acct_sub_type_cd=cs20849_acct_sub_type_cd_patient
       AND a.active_ind=true)
     ORDER BY pe.acct_id
     HEAD pe.acct_id
      multiaccountcount += 1
     WITH nocounter
    ;end select
    CALL logmessage("validateMultiAccountEncountersExist","Exit",log_debug)
    IF (multiaccountcount > 1)
     RETURN(true)
    ENDIF
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(isbedifferentforencandfinancialenc,char(128))=char(128))
  SUBROUTINE (isbedifferentforencandfinancialenc(pencounterid=f8) =i2)
    CALL logmessage("isBEDifferentForEncAndFinancialEnc","Enter",log_debug)
    DECLARE isbillingentitydiff = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      be_org_reltn bor
     PLAN (e
      WHERE e.encntr_id=pencounterid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (bor
      WHERE bor.organization_id=e.organization_id
       AND bor.active_ind=true)
     DETAIL
      IF (pe.billing_entity_id != bor.billing_entity_id)
       isbillingentitydiff = true
      ENDIF
     WITH nocounter
    ;end select
    CALL logmessage("isBEDifferentForEncAndFinancialEnc","Exit",log_debug)
    RETURN(isbillingentitydiff)
  END ;Subroutine
 ENDIF
 RECORD reply(
   1 charge_qual = i2
   1 report_file_name = vc
   1 hasmoreind = i2
   1 qual[*]
     2 suspense_in_list = i2
     2 review_in_list = i2
     2 master_ind = i2
     2 place_holder = i2
     2 bump_up = i2
     2 charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 payor_id = f8
     2 ord_loc_cd = f8
     2 ord_loc_disp = c40
     2 ord_loc_desc = c60
     2 ord_loc_mean = c12
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 parent_charge_item_id = f8
     2 charge_type_cd = f8
     2 charge_type_disp = c40
     2 charge_type_desc = c60
     2 charge_type_mean = c12
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 suspense_rsn_disp = c40
     2 suspense_rsn_desc = c60
     2 suspense_rsn_mean = c12
     2 reason_comment = vc
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 interface_file_id = f8
     2 profit_ind = i2
     2 building_cd = f8
     2 building_disp = c40
     2 building_desc = c60
     2 building_mean = c12
     2 verify_phys_id = f8
     2 def_bill_item_id = f8
     2 department_cd = f8
     2 department_disp = c40
     2 department_desc = c60
     2 department_mean = c12
     2 section_cd = f8
     2 section_disp = c40
     2 section_desc = c60
     2 section_mean = c12
     2 dept = f8
     2 section = f8
     2 posted_cd = f8
     2 posted_desc = c60
     2 posted_mean = c12
     2 posted_disp = c40
     2 provider_specialty_cd = f8
     2 provider_specialty_disp = c40
     2 provider_specialty_desc = c60
     2 provider_specialty_mean = c12
     2 posted_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = c40
     2 active_status_desc = c60
     2 active_status_mean = c12
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 person_name = vc
     2 person_dob = dq8
     2 person_sex_cd = f8
     2 person_sex_disp = c40
     2 person_sex_desc = c60
     2 person_sex_mean = c12
     2 process_flg = i4
     2 manual_ind = i2
     2 combine_ind = i2
     2 bundle_id = f8
     2 institution_cd = f8
     2 institution_disp = c40
     2 institution_desc = c60
     2 institution_mean = c12
     2 subsection_cd = f8
     2 subsection_disp = c40
     2 subsection_desc = c60
     2 subsection_mean = c12
     2 level5_cd = f8
     2 level5_disp = c40
     2 level5_desc = c60
     2 level5_mean = c12
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 inst_fin_nbr = vc
     2 cost_center_cd = f8
     2 cost_center_disp = c40
     2 cost_center_desc = c60
     2 cost_center_mean = c12
     2 gross_price = f8
     2 discount_amount = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 fin_class_disp = c40
     2 fin_class_desc = c60
     2 fin_class_mean = c12
     2 payor_type_cd = f8
     2 payor_type_disp = c40
     2 payor_type_desc = c60
     2 payor_type_mean = c12
     2 item_reimbursement = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 list_price_sched_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 late_chrg_flag = i4
     2 offset_charge_item_id = f8
     2 cs_cpp_undo_id = f8
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 ext_parent_event_id = f8
     2 ext_parent_event_cont_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_reference_cont_cd = f8
     2 ext_item_event_id = f8
     2 ext_item_event_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 ext_owner_cd = f8
     2 accession_nbr = vc
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 abn_status_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 parent_qual_cd = f8
     2 charge_point_cd = f8
     2 physician_name = vc
     2 perf_physician_name = vc
     2 verify_physician_name = vc
     2 org_name = vc
     2 physician_id = f8
     2 username = vc
     2 fin_nbr = vc
     2 mrn_nbr = vc
     2 encntr_type_cd = f8
     2 loc_facility_cd = f8
     2 financial_class_cd = f8
     2 reason_for_visit = vc
     2 requested_start_dt_tm = dq8
     2 careset_ind = i2
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 interfaced_dt_tm = dq8
     2 cea_qty = f8
     2 interval_template_cd = f8
     2 bill_code_qual = i2
     2 bill_code[*]
       3 bill_code_type = vc
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field6 = vc
       3 field7 = vc
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 nomen_id = f8
       3 nomen_entity_reltn_id = f8
       3 cm1_nbr = f8
       3 charge_event_mod_id = f8
       3 username = c50
       3 activity_dt_tm = dq8
       3 field8 = vc
     2 interval_qual[*]
       3 item_interval_id = f8
       3 price = f8
       3 interval_template_cd = f8
       3 parent_entity_id = f8
       3 interval_id = f8
       3 beg_value = f8
       3 end_value = f8
       3 unit_type_cd = f8
       3 calc_type_cd = f8
       3 bc_qual[*]
         4 bill_item_mod_id = f8
         4 bill_item_type_cd = f8
         4 key1_id = f8
         4 key2_id = f8
         4 key3_id = f8
         4 key6 = vc
         4 key7 = vc
     2 corsp_activity_id = f8
     2 bill_type_cdf = c12
     2 bill_nbr_disp = vc
     2 bill_class_cdf = c12
     2 has_bill_access = i2
     2 order_status_cd = f8
     2 profit_type_cd = f8
     2 discharge_dt_tm = dq8
     2 postedbyid = f8
     2 postedby = c50
     2 changelog = i2
     2 admitting_physician_name = vc
     2 loc_room_disp = vc
     2 ssn_nbr = vc
     2 original_org_id = f8
     2 original_org_name = vc
     2 service_interface_flag = i4
     2 ext_billed_ind = i2
     2 access_to_billing_entity = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD secbillingentities
 RECORD secbillingentities(
   1 be_qual[*]
     2 billingentityid = f8
 )
 RECORD billcodestring(
   1 bill_code_string = vc
 )
 RECORD activitytypestring(
   1 activity_type_string = vc
 )
 FREE RECORD deptcdstr
 RECORD deptcdstr(
   1 sdeptcdstr = vc
 )
 FREE RECORD serviceresourcestrings
 RECORD serviceresourcestrings(
   1 institution_string = vc
   1 department_string = vc
   1 section_string = vc
   1 subsection_string = vc
   1 level5_string = vc
 )
 FREE RECORD namefilter
 RECORD namefilter(
   1 slastnamefilter = vc
 )
 RECORD changelogchargeeventids(
   1 charge_events[*]
     2 charge_event_id = f8
 ) WITH protect
 DECLARE cap = f8 WITH protect
 DECLARE defaultcap = f8 WITH protect, constant(65533.0)
 DECLARE curlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE checkbillingentitysecurity = i2 WITH protect, noconstant(false)
 IF ( NOT (getlogicaldomain(ld_concept_organization,curlogicaldomainid)))
  GO TO end_program
 ENDIF
 IF (validate(request->maxlistsize,- (1)) > 0)
  SET cap = request->maxlistsize
 ELSE
  SELECT INTO "nl:"
   FROM dm_info dm
   WHERE dm.info_domain="CHARGE SERVICES"
    AND dm.info_name="CAP FOR CHARGE VIEWER"
    AND dm.info_domain_id=curlogicaldomainid
   DETAIL
    cap = dm.info_number
   WITH nocounter
  ;end select
  IF (((curqual=0) OR (((cap=0) OR (cap > defaultcap)) )) )
   SET cap = defaultcap
  ENDIF
 ENDIF
 DECLARE cap_plus_1 = i4 WITH protect, constant((cap+ 1))
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="CHARGE SERVICES"
   AND dm.info_name="BILLING ENTITY SECURITY FOR CHARGE VIEWER"
   AND dm.info_domain_id=curlogicaldomainid
  DETAIL
   IF (dm.info_char="Y")
    checkbillingentitysecurity = true
   ENDIF
  WITH nocounter
 ;end select
 DECLARE iorglevelsecurity = i4
 DECLARE determineorgsecurity(null) = null
 DECLARE builddeptcdstr(null) = null
 DECLARE buildserviceresource(null) = null
 DECLARE buildnamefilter(null) = null
 DECLARE lookuporderinfo() = null
 DECLARE retrieveretailpharmacyind(null) = null
 DECLARE updatereplybasedonbillingentityaccess(null) = null
 DECLARE lbecnt = i4 WITH public, noconstant(0)
 DECLARE igl_idx = i4 WITH public, noconstant(0)
 DECLARE iidx = i4 WITH public, noconstant(0)
 DECLARE eventcounter = i4 WITH public, noconstant(0)
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE finnbr = f8
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,finnbr)
 DECLARE d13019_interval_cd = f8
 SET code_set = 13019
 SET cdf_meaning = "INTERVALCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,d13019_interval_cd)
 DECLARE mrn = f8
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,mrn)
 DECLARE userdef = f8
 SET code_set = 13019
 SET cdf_meaning = "USER DEF"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,userdef)
 DECLARE ord_cat = f8
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ord_cat)
 DECLARE suspended = f8
 SET code_set = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,suspended)
 DECLARE pftptacct = f8
 SET code_set = 22449
 SET cdf_meaning = "PFTPTACCT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,pftptacct)
 DECLARE pftcltbill = f8
 SET code_set = 22449
 SET cdf_meaning = "PFTCLTBILL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,pftcltbill)
 DECLARE pftcltacct = f8
 SET code_set = 22449
 SET cdf_meaning = "PFTCLTACCT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,pftcltacct)
 DECLARE dmissingicd9 = f8
 SET code_set = 13030
 SET cdf_meaning = "NOICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dmissingicd9)
 DECLARE dmissingrenphys = f8
 SET code_set = 13030
 SET cdf_meaning = "NORENDPHYS"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dmissingrenphys)
 DECLARE dmissingpatresp = f8
 SET code_set = 13030
 SET cdf_meaning = "NOPATRESP"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dmissingpatresp)
 DECLARE dmissingmodauth = f8
 SET code_set = 13030
 SET cdf_meaning = "NOAUTH"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dmissingmodauth)
 DECLARE dprompt = f8
 SET code_set = 13019
 SET cdf_meaning = "PROMPT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dprompt)
 DECLARE dradreviewsuspense = f8 WITH protect, noconstant(0.0)
 SET code_set = 13030
 SET cdf_meaning = "RADREVIEW"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,dradreviewsuspense)
 SET codeset = 13028
 DECLARE cs13028_debit = f8
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,cs13028_debit)
 DECLARE cs13019_changelog_cd = f8 WITH protect, constant(getcodevalue(13019,"CHANGELOG",0))
 DECLARE cs333_admitdoc = f8 WITH protect, constant(getcodevalue(333,"ADMITDOC",0))
 DECLARE cs4_ssn = f8 WITH protect, constant(getcodevalue(4,"SSN",0))
 DECLARE maxlistcount = i4
 SET maxlistcount = 250
 SET mycount = 0
 IF ((request->detail_ind=0))
  SET flag_count = 0
  SET process_flags = fillstring(200," ")
  CALL buildprocessflags("dummy")
  IF (size(request->suspense_reasons,5) > 0)
   DECLARE suspensereasons = vc
   CALL buildsuspensereasons("dummy")
  ENDIF
  IF ((request->activity_type_count > 0))
   CALL buildactivitytypes("dummy")
  ENDIF
  CALL builddeptcdstr(null)
  CALL buildserviceresource(null)
  CALL buildnamefilter(null)
 ENDIF
 SET reply->status_data.status = "F"
 SET i = 0
 SET count1 = 0
 SET master = 0
 SET count2 = 0
 SET firstmaster = false
 SET stat = alterlist(reply->qual,(count1+ 10))
 CALL determineorgsecurity(null)
 IF ((request->detail_ind=0))
  IF (iorglevelsecurity=1
   AND (request->encntr_id=0.0))
   EXECUTE afc_get_charges_secured parser(
    IF ((request->person_id > 0)) "c.person_id = request->person_id"
    ELSE "0 = 0"
    ENDIF
    ), parser("0 = 0"), parser(
    IF ((request->service_dt_tm_f > 0))
     "c.service_dt_tm between cnvtdatetime(request->service_dt_tm_f) and cnvtdatetime(request->service_dt_tm_t)"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->ord_phys_id > 0)) "c.ord_phys_id = request->ord_phys_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->charge_type_cd > 0)) "c.charge_type_cd = request->charge_type_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->department > 0)) "c.department_cd = request->department"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->bill_item_id > 0)) "c.bill_item_id = request->bill_item_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF (flag_count > 0) process_flags
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->accession_nbr != "")) "ce.accession = request->accession_nbr"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF (mycount > 0) billcodestring->bill_code_string
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->tier_group_cd > 0)) "c.tier_group_cd = request->tier_group_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->admit_type > 0)) "e.encntr_type_cd = request->admit_type"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->payor_id > 0)) "c.payor_id+0 = request->payor_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->building_cd > 0)) "e.loc_building_cd = request->building_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->interface_file_id > 0)) "c.interface_file_id = request->interface_file_id"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->verify_phys_id > 0)) "c.verify_phys_id = request->verify_phys_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->manual_ind > 0)) "c.manual_ind = request->manual_ind"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->cost_center_cd > 0)) "c.cost_center_cd = request->cost_center_cd"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->perf_loc_cd > 0)) "c.perf_loc_cd = request->perf_loc_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->activity_type_cd > 0)) "c.activity_type_cd = request->activity_type_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->charge_item_id > 0)) "c.charge_item_id = request->charge_item_id"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->activity_type_count > 0)) activitytypestring->activity_type_string
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->interfaced_dt_tm_f > 0)) "true"
    ELSE "false"
    ENDIF
    ), parser(
    IF ((request->interfaced_dt_tm_f > 0))
     "ic.posted_dt_tm between cnvtdatetime(request->interfaced_dt_tm_f) and cnvtdatetime(request->interfaced_dt_tm_t)"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(deptcdstr->sdeptcdstr), parser(serviceresourcestrings->institution_string), parser(
    serviceresourcestrings->department_string),
   parser(serviceresourcestrings->section_string), parser(serviceresourcestrings->subsection_string),
   parser(serviceresourcestrings->level5_string),
   parser(namefilter->slastnamefilter), parser(
    IF (validate(request->financial_class_cd,- (0.00001)) > 0)
     "e.financial_class_cd = validate(request->financial_class_cd,-0.00001)"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF (validate(request->abn_status_cd,- (0.00001)) > 0)
     "c.abn_status_cd = validate(request->abn_status_cd,-0.00001)"
    ELSE "0 = 0"
    ENDIF
    )
  ELSE
   EXECUTE afc_get_charges2 parser(
    IF ((request->person_id > 0)) "c.person_id = request->person_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->encntr_id > 0)) "c.encntr_id = request->encntr_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->service_dt_tm_f > 0))
     "c.service_dt_tm between cnvtdatetime(request->service_dt_tm_f) and cnvtdatetime(request->service_dt_tm_t)"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->ord_phys_id > 0)) "c.ord_phys_id = request->ord_phys_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->charge_type_cd > 0)) "c.charge_type_cd = request->charge_type_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->department > 0)) "c.department_cd = request->department"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->bill_item_id > 0)) "c.bill_item_id = request->bill_item_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF (flag_count > 0) process_flags
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->accession_nbr != "")) "ce.accession = request->accession_nbr"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF (mycount > 0) billcodestring->bill_code_string
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->tier_group_cd > 0)) "c.tier_group_cd = request->tier_group_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->admit_type > 0)) "e.encntr_type_cd = request->admit_type"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->payor_id > 0)) "c.payor_id+0 = request->payor_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->building_cd > 0)) "e.loc_building_cd = request->building_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->interface_file_id > 0)) "c.interface_file_id = request->interface_file_id"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->verify_phys_id > 0)) "c.verify_phys_id = request->verify_phys_id"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->manual_ind > 0)) "c.manual_ind = request->manual_ind"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->cost_center_cd > 0)) "c.cost_center_cd = request->cost_center_cd"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->perf_loc_cd > 0)) "c.perf_loc_cd = request->perf_loc_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->activity_type_cd > 0)) "c.activity_type_cd = request->activity_type_cd"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->charge_item_id > 0)) "c.charge_item_id = request->charge_item_id"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(
    IF ((request->activity_type_count > 0)) activitytypestring->activity_type_string
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->interfaced_dt_tm_f > 0)) "true"
    ELSE "false"
    ENDIF
    ), parser(
    IF ((request->interfaced_dt_tm_f > 0))
     "ic.posted_dt_tm between cnvtdatetime(request->interfaced_dt_tm_f) and cnvtdatetime(request->interfaced_dt_tm_t)"
    ELSE "0 = 0"
    ENDIF
    ),
   parser(deptcdstr->sdeptcdstr), parser(serviceresourcestrings->institution_string), parser(
    serviceresourcestrings->department_string),
   parser(serviceresourcestrings->section_string), parser(serviceresourcestrings->subsection_string),
   parser(serviceresourcestrings->level5_string),
   parser(namefilter->slastnamefilter), parser(
    IF (validate(request->financial_class_cd,- (0.00001)) > 0)
     "e.financial_class_cd = validate(request->financial_class_cd,-0.00001)"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF (validate(request->abn_status_cd,- (0.00001)) > 0)
     "c.abn_status_cd = validate(request->abn_status_cd,-0.00001)"
    ELSE "0 = 0"
    ENDIF
    )
  ENDIF
 ELSE
  EXECUTE afc_get_charges2
 ENDIF
 IF (size(reply->qual,5) > 0)
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn ea,
    prsnl pr,
    (dummyt d1  WITH seq = value(size(reply->qual,5)))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
     AND ea.encntr_prsnl_r_cd=cs333_admitdoc
     AND ((ea.active_ind+ 0)=true)
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    JOIN (pr
    WHERE pr.person_id=ea.prsnl_person_id
     AND pr.active_ind=1)
   DETAIL
    reply->qual[d1.seq].admitting_physician_name = pr.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(reply->qual,5)))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=reply->qual[d1.seq].encntr_id))
   DETAIL
    reply->qual[d1.seq].location_disp = uar_get_code_display(e.loc_nurse_unit_cd), reply->qual[d1.seq
    ].fin_class_disp = uar_get_code_display(e.financial_class_cd), reply->qual[d1.seq].loc_room_disp
     = uar_get_code_display(e.loc_room_cd),
    reply->qual[d1.seq].building_disp = uar_get_code_display(e.loc_building_cd)
   WITH nocounter
  ;end select
  CALL retrieveretailpharmacyind(null)
  IF (checkbillingentitysecurity=true
   AND validate(reply->qual[1].access_to_billing_entity) > 0
   AND validate(reply->qual[1].ext_parent_event_id) > 0
   AND validate(reply->qual[1].ext_child_reference_id) > 0)
   CALL updatereplybasedonbillingentityaccess(null)
  ELSEIF (checkbillingentitysecurity=true)
   IF (validate(debug,- (1)) > 0)
    CALL echo(
     "Reply record structure definition is missing a required member variable for security checks.")
   ENDIF
  ENDIF
 ENDIF
 FREE RECORD deptcdstr
 FREE RECORD namefilter
 FREE RECORD serviceresourcestrings
 SUBROUTINE getbillcodestring(dummyvar)
   DECLARE lcvcount = i4
   DECLARE codevalue = f8
   DECLARE total_remaining = i4
   DECLARE start_index = i4
   DECLARE occurances = i4
   DECLARE meaning = c12
   SET code_set = 14002
   SET cdf_meaning = "CPT4"
   DECLARE maxcount = i4
   SET maxcount = 0
   SET billcodestring->bill_code_string = "cm.field1_id in ("
   SET start_index = 1
   SET occurances = 1
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "CDM_SCHED"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "MODIFIER"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "ICD9"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "PROCCODE"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "REVENUE"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",")
   FREE SET code_list
   SET start_index = 1
   SET occurances = 1
   SET cdf_meaning = "HCPCS"
   SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),occurances,codevalue)
   DECLARE code_list[value(occurances)] = f8
   CALL uar_get_code_list_by_meaning(14002,nullterm(cdf_meaning),start_index,occurances,
    total_remaining,
    code_list)
   FOR (lcvcount = 1 TO size(code_list,5))
     SET maxcount += 1
     IF (maxcount > maxlistcount)
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,
       ") or cm.field1_id in (")
      SET maxcount = 0
     ENDIF
     IF (((lcvcount=1) OR (maxcount=0)) )
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,cnvtstring(
        code_list[lcvcount],17,2))
     ELSE
      SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,",",cnvtstring(
        code_list[lcvcount],17,2))
     ENDIF
   ENDFOR
   FREE SET code_list
   SET mycount = 1
   SET billcodestring->bill_code_string = build(billcodestring->bill_code_string,")")
   SET billcodestring->bill_code_string = trim(billcodestring->bill_code_string)
   CALL echo(concat("BillCodeString: ",billcodestring->bill_code_string))
 END ;Subroutine
 SUBROUTINE buildprocessflags(dummy)
   SET process_flags = "c.process_flg + 0 in ("
   IF ((request->pending > 0))
    SET process_flags = build(process_flags,"0")
    SET flag_count += 1
   ENDIF
   IF ((request->suspended > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",1")
   ELSEIF ((request->suspended > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"1")
    SET flag_count += 1
   ENDIF
   IF ((request->interfaced > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",999")
   ELSEIF ((request->interfaced > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"999")
    SET flag_count += 1
   ENDIF
   IF ((request->held > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",3")
   ELSEIF ((request->held > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"3")
    SET flag_count += 1
   ENDIF
   IF ((request->reviewed > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",2")
   ELSEIF ((request->reviewed > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"2")
    SET flag_count += 1
   ENDIF
   IF ((request->manual > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",4")
   ELSEIF ((request->manual > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"4")
    SET flag_count += 1
   ENDIF
   IF ((request->skipped > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",5")
   ELSEIF ((request->skipped > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"5")
    SET flag_count += 1
   ENDIF
   IF ((request->combined > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",6")
   ELSEIF ((request->combined > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"6")
    SET flag_count += 1
   ENDIF
   IF ((request->absorbed > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",7")
   ELSEIF ((request->absorbed > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"7")
    SET flag_count += 1
   ENDIF
   IF ((request->offset > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",10")
   ELSEIF ((request->offset > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"10")
    SET flag_count += 1
   ENDIF
   IF ((request->adjusted > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",11")
   ELSEIF ((request->adjusted > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"11")
    SET flag_count += 1
   ENDIF
   IF ((request->abn > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",8")
   ELSEIF ((request->abn > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"8")
    SET flag_count += 1
   ENDIF
   IF ((request->bundled > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",777")
   ELSEIF ((request->bundled > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"777")
    SET flag_count += 1
   ENDIF
   IF ((request->stats_only > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",997")
   ELSEIF ((request->stats_only > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"997")
    SET flag_count += 1
   ENDIF
   IF ((request->omf_stats_only > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",996")
   ELSEIF ((request->omf_stats_only > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"996")
    SET flag_count += 1
   ENDIF
   IF ((request->posted > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",100")
   ELSEIF ((request->posted > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"100")
    SET flag_count += 1
   ENDIF
   IF ((request->bundled_profit > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",177")
   ELSEIF ((request->bundled_profit > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"177")
    SET flag_count += 1
   ENDIF
   IF ((request->bundled_interfaced > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",977")
   ELSEIF ((request->bundled_interfaced > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"977")
    SET flag_count += 1
   ENDIF
   IF ((request->unreconciled_credit > 0)
    AND flag_count > 0)
    SET process_flags = build(process_flags,",13")
   ELSEIF ((request->unreconciled_credit > 0)
    AND flag_count=0)
    SET process_flags = build(process_flags,"13")
    SET flag_count += 1
   ENDIF
   SET process_flags = build(process_flags,")")
   SET process_flags = trim(process_flags)
 END ;Subroutine
 SUBROUTINE buildsuspensereasons(dummy)
   FOR (x = 1 TO size(request->suspense_reasons,5))
     IF (x=1)
      SET suspensereasons = build("reply->qual[x1]->bill_code[x2]->field1_id in (",cnvtstring(request
        ->suspense_reasons[x].suspense_rsn_cd,17,2))
     ELSE
      SET suspensereasons = build(suspensereasons,",",cnvtstring(request->suspense_reasons[x].
        suspense_rsn_cd,17,2))
     ENDIF
   ENDFOR
   SET suspensereasons = build(suspensereasons,")")
   SET suspensereasons = trim(suspensereasons)
 END ;Subroutine
 SUBROUTINE buildactivitytypes(dummy)
   FOR (x = 1 TO request->activity_type_count)
     IF (x=1)
      SET activitytypestring->activity_type_string = build("c.activity_type_cd in (",cnvtstring(
        request->activity_types[x].activity_type_cd,17,2))
     ELSE
      SET activitytypestring->activity_type_string = build(activitytypestring->activity_type_string,
       ",",cnvtstring(request->activity_types[x].activity_type_cd,17,2))
     ENDIF
   ENDFOR
   SET activitytypestring->activity_type_string = build(activitytypestring->activity_type_string,")")
   SET activitytypestring->activity_type_string = trim(activitytypestring->activity_type_string)
   CALL echo(build("ActivityTypes: ",activitytypestring->activity_type_string))
 END ;Subroutine
 SUBROUTINE builddeptcdstr(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(request->departments,5))
     IF (i != 1)
      SET deptcdstr->sdeptcdstr = build(deptcdstr->sdeptcdstr,",",cnvtstring(request->departments[i].
        department_cd,17,2))
     ELSE
      SET deptcdstr->sdeptcdstr = build("c.department_cd in (",cnvtstring(request->departments[i].
        department_cd,17,2))
     ENDIF
   ENDFOR
   IF (textlen(deptcdstr->sdeptcdstr) != 0)
    SET deptcdstr->sdeptcdstr = trim(build(deptcdstr->sdeptcdstr,")"))
   ELSE
    SET deptcdstr->sdeptcdstr = "0 = 0"
   ENDIF
   CALL echo(build2("Department Code String: ",deptcdstr->sdeptcdstr))
 END ;Subroutine
 SUBROUTINE buildserviceresource(null)
   DECLARE ninstitution = i2 WITH protect, constant(1)
   DECLARE ndepartment = i2 WITH protect, constant(2)
   DECLARE nsection = i2 WITH protect, constant(3)
   DECLARE nsubsection = i2 WITH protect, constant(4)
   DECLARE nlevel5 = i2 WITH protect, constant(5)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(request->service_resource,5))
     CASE (request->service_resource[i].level_flag)
      OF ninstitution:
       IF (textlen(serviceresourcestrings->institution_string) != 0)
        SET serviceresourcestrings->institution_string = build(serviceresourcestrings->
         institution_string,",",cnvtstring(request->service_resource[i].service_resource_cd,17,2))
       ELSE
        SET serviceresourcestrings->institution_string = build("c.institution_cd in (",cnvtstring(
          request->service_resource[i].service_resource_cd,17,2))
       ENDIF
      OF ndepartment:
       IF (textlen(serviceresourcestrings->department_string) != 0)
        SET serviceresourcestrings->department_string = build(serviceresourcestrings->
         department_string,",",cnvtstring(request->service_resource[i].service_resource_cd,17,2))
       ELSE
        SET serviceresourcestrings->department_string = build("c.department_cd in (",cnvtstring(
          request->service_resource[i].service_resource_cd,17,2))
       ENDIF
      OF nsection:
       IF (textlen(serviceresourcestrings->section_string) != 0)
        SET serviceresourcestrings->section_string = build(serviceresourcestrings->section_string,",",
         cnvtstring(request->service_resource[i].service_resource_cd,17,2))
       ELSE
        SET serviceresourcestrings->section_string = build("c.section_cd in (",cnvtstring(request->
          service_resource[i].service_resource_cd,17,2))
       ENDIF
      OF nsubsection:
       IF (textlen(serviceresourcestrings->subsection_string) != 0)
        SET serviceresourcestrings->subsection_string = build(serviceresourcestrings->
         subsection_string,",",cnvtstring(request->service_resource[i].service_resource_cd,17,2))
       ELSE
        SET serviceresourcestrings->subsection_string = build("c.subsection_cd in (",cnvtstring(
          request->service_resource[i].service_resource_cd,17,2))
       ENDIF
      OF nlevel5:
       IF (textlen(serviceresourcestrings->level5_string) != 0)
        SET serviceresourcestrings->level5_string = build(serviceresourcestrings->level5_string,",",
         cnvtstring(request->service_resource[i].service_resource_cd,17,2))
       ELSE
        SET serviceresourcestrings->level5_string = build("c.level5_cd in (",cnvtstring(request->
          service_resource[i].service_resource_cd,17,2))
       ENDIF
     ENDCASE
   ENDFOR
   IF (textlen(serviceresourcestrings->institution_string) != 0)
    SET serviceresourcestrings->institution_string = trim(build(serviceresourcestrings->
      institution_string,")"))
   ELSE
    SET serviceresourcestrings->institution_string = "0 = 0"
   ENDIF
   CALL echo(build2("institution_string: ",serviceresourcestrings->institution_string))
   IF (textlen(serviceresourcestrings->department_string) != 0)
    SET serviceresourcestrings->department_string = trim(build(serviceresourcestrings->
      department_string,")"))
   ELSE
    SET serviceresourcestrings->department_string = "0 = 0"
   ENDIF
   CALL echo(build2("department_string: ",serviceresourcestrings->department_string))
   IF (textlen(serviceresourcestrings->section_string) != 0)
    SET serviceresourcestrings->section_string = trim(build(serviceresourcestrings->section_string,
      ")"))
   ELSE
    SET serviceresourcestrings->section_string = "0 = 0"
   ENDIF
   CALL echo(build2("section_string: ",serviceresourcestrings->section_string))
   IF (textlen(serviceresourcestrings->subsection_string) != 0)
    SET serviceresourcestrings->subsection_string = trim(build(serviceresourcestrings->
      subsection_string,")"))
   ELSE
    SET serviceresourcestrings->subsection_string = "0 = 0"
   ENDIF
   CALL echo(build2("subsection_string: ",serviceresourcestrings->subsection_string))
   IF (textlen(serviceresourcestrings->level5_string) != 0)
    SET serviceresourcestrings->level5_string = trim(build(serviceresourcestrings->level5_string,")")
     )
   ELSE
    SET serviceresourcestrings->level5_string = "0 = 0"
   ENDIF
   CALL echo(build2("level5_string: ",serviceresourcestrings->level5_string))
 END ;Subroutine
 SUBROUTINE buildnamefilter(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(request->name_filter,5))
     IF (i != 1)
      SET namefilter->slastnamefilter = build(namefilter->slastnamefilter,
       ' or trim(p.name_last_key) like "',cnvtupper(request->name_filter[i].last_name_filter),'*"')
     ELSE
      SET namefilter->slastnamefilter = build('(trim(p.name_last_key) like "',cnvtupper(request->
        name_filter[i].last_name_filter),'*"')
     ENDIF
   ENDFOR
   IF (textlen(namefilter->slastnamefilter) != 0)
    SET namefilter->slastnamefilter = trim(build(namefilter->slastnamefilter,")"))
   ELSE
    SET namefilter->slastnamefilter = "0 = 0"
   ENDIF
   CALL echo(build2("Last Name String: ",namefilter->slastnamefilter))
 END ;Subroutine
 SUBROUTINE determineorgsecurity(null)
   IF (validate(ccldminfo,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET iorglevelsecurity = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     i.info_number
     FROM dm_info i
     WHERE i.info_name="SEC_ORG_RELTN"
      AND i.info_domain="SECURITY"
      AND ((i.info_number+ 0) > 0.0)
     DETAIL
      iorglevelsecurity = 1
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE fillchargeinfo(void)
  SET count1 += 1
  IF (count1 <= cap)
   IF (mod(count1,10)=1
    AND count1 != 1)
    SET stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   IF (firstmaster=true
    AND ce.ext_p_event_id <= 0
    AND b.ext_child_reference_id <= 0)
    SET reply->qual[count1].master_ind = 1
    SET reply->qual[count1].place_holder = 0
    SET reply->qual[count1].bump_up = 0
    SET reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id
    SET reply->qual[count1].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd
    SET reply->qual[count1].ext_master_event_id = ce.ext_m_event_id
    SET reply->qual[count1].charge_event_act_id = c.charge_event_act_id
    SET reply->qual[count1].accession_nbr = ce.accession
    SET reply->qual[count1].charge_item_id = c.charge_item_id
    SET reply->qual[count1].charge_event_id = c.charge_event_id
    SET reply->qual[count1].tier_group_cd = c.tier_group_cd
    SET reply->qual[count1].encntr_id = c.encntr_id
    SET reply->qual[count1].person_id = c.person_id
    SET reply->qual[count1].perf_loc_cd = c.perf_loc_cd
    SET reply->qual[count1].payor_id = c.payor_id
    SET reply->qual[count1].ord_phys_id = c.ord_phys_id
    SET reply->qual[count1].verify_phys_id = c.verify_phys_id
    SET reply->qual[count1].charge_description = c.charge_description
    SET reply->qual[count1].item_quantity = c.item_quantity
    SET reply->qual[count1].item_price = c.item_price
    SET reply->qual[count1].item_extended_price = c.item_extended_price
    SET reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id
    SET reply->qual[count1].charge_type_cd = c.charge_type_cd
    SET reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd
    SET reply->qual[count1].reason_comment = c.reason_comment
    SET reply->qual[count1].interface_file_id = c.interface_file_id
    SET reply->qual[count1].process_flg = c.process_flg
    SET reply->qual[count1].manual_ind = c.manual_ind
    SET reply->qual[count1].bundle_id = c.bundle_id
    SET reply->qual[count1].cost_center_cd = c.cost_center_cd
    SET reply->qual[count1].section_cd = c.section_cd
    SET reply->qual[count1].activity_type_cd = c.activity_type_cd
    SET reply->qual[count1].credited_dt_tm = c.credited_dt_tm
    SET reply->qual[count1].adjusted_dt_tm = c.adjusted_dt_tm
    SET reply->qual[count1].service_dt_tm = c.service_dt_tm
    SET reply->qual[count1].research_acct_id = c.research_acct_id
    SET reply->qual[count1].person_name = p.name_full_formatted
    SET reply->qual[count1].person_dob = p.birth_dt_tm
    SET reply->qual[count1].person_sex_cd = p.sex_cd
    SET reply->qual[count1].department_cd = c.department_cd
    SET reply->qual[count1].reason_for_visit = e.reason_for_visit
    SET reply->qual[count1].updt_id = c.updt_id
    SET reply->qual[count1].order_id = c.order_id
    SET reply->qual[count1].abn_status_cd = c.abn_status_cd
    SET reply->qual[count1].updt_dt_tm = c.updt_dt_tm
    SET reply->qual[count1].encntr_type_cd = e.encntr_type_cd
    SET reply->qual[count1].loc_facility_cd = e.loc_facility_cd
    SET reply->qual[count1].financial_class_cd = e.financial_class_cd
    SET reply->qual[count1].building_cd = e.loc_building_cd
    SET reply->qual[count1].discharge_dt_tm = e.disch_dt_tm
    SET reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd
    SET reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id
    SET reply->qual[count1].ext_child_contributor_cd = b.ext_child_contributor_cd
    SET reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id
    SET reply->qual[count1].item_copay = c.item_copay
    SET reply->qual[count1].item_deductible_amt = c.item_deductible_amt
    SET reply->qual[count1].patient_responsibility_flag = c.patient_responsibility_flag
    SET reply->qual[count1].ext_owner_cd = b.ext_owner_cd
    SET reply->qual[count1].offset_charge_item_id = c.offset_charge_item_id
    SET reply->qual[count1].item_interval_id = c.item_interval_id
    SET reply->qual[count1].bill_item_id = c.bill_item_id
    SET reply->qual[count1].price_sched_id = c.price_sched_id
    SET reply->qual[count1].cs_cpp_undo_id = c.cs_cpp_undo_id
    SET reply->qual[count1].provider_specialty_cd = c.provider_specialty_cd
    SET reply->qual[count1].updt_cnt = c.updt_cnt
    SET reply->qual[count1].original_org_id = c.original_org_id
    IF (validate(reply->qual[count1].service_interface_flag) > 0)
     SET reply->qual[count1].service_interface_flag = c.service_interface_flag
    ENDIF
    IF (validate(reply->qual[count1].access_to_billing_entity) > 0)
     SET reply->qual[count1].access_to_billing_entity = true
    ENDIF
    IF (validate(reply->qual[count1].ext_parent_event_id) > 0)
     SET reply->qual[count1].ext_parent_event_id = ce.ext_p_event_id
    ENDIF
    SET firstmaster = false
   ELSEIF (((firstmaster=true
    AND ce.ext_p_event_id > 0) OR (firstmaster=true
    AND ce.ext_p_event_id <= 0
    AND b.ext_child_reference_id > 0)) )
    SET reply->qual[count1].master_ind = 1
    SET reply->qual[count1].place_holder = 1
    SET reply->qual[count1].bump_up = 1
    SET reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id
    SET reply->qual[count1].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd
    SET reply->qual[count1].ext_master_event_id = ce.ext_m_event_id
    SET reply->qual[count1].charge_item_id = c.charge_item_id
    SET reply->qual[count1].charge_event_id = c.charge_event_id
    SET reply->qual[count1].charge_description = c.charge_description
    SET reply->qual[count1].item_quantity = c.item_quantity
    SET reply->qual[count1].payor_id = c.payor_id
    SET reply->qual[count1].perf_loc_cd = c.perf_loc_cd
    SET reply->qual[count1].tier_group_cd = c.tier_group_cd
    SET reply->qual[count1].charge_type_cd = c.charge_type_cd
    SET reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd
    SET reply->qual[count1].reason_comment = c.reason_comment
    SET reply->qual[count1].interface_file_id = c.interface_file_id
    SET reply->qual[count1].process_flg = c.process_flg
    SET reply->qual[count1].manual_ind = c.manual_ind
    SET reply->qual[count1].service_dt_tm = c.service_dt_tm
    SET reply->qual[count1].research_acct_id = c.research_acct_id
    SET reply->qual[count1].activity_type_cd = c.activity_type_cd
    SET reply->qual[count1].encntr_id = c.encntr_id
    SET reply->qual[count1].person_id = p.person_id
    SET reply->qual[count1].person_name = p.name_full_formatted
    SET reply->qual[count1].person_dob = p.birth_dt_tm
    SET reply->qual[count1].person_sex_cd = p.sex_cd
    SET reply->qual[count1].department_cd = c.department_cd
    SET reply->qual[count1].ord_phys_id = c.ord_phys_id
    SET reply->qual[count1].verify_phys_id = c.verify_phys_id
    SET reply->qual[count1].activity_type_cd = c.activity_type_cd
    SET reply->qual[count1].bundle_id = c.bundle_id
    SET reply->qual[count1].cost_center_cd = c.cost_center_cd
    SET reply->qual[count1].updt_id = c.updt_id
    SET reply->qual[count1].order_id = c.order_id
    SET reply->qual[count1].abn_status_cd = c.abn_status_cd
    SET reply->qual[count1].updt_dt_tm = c.updt_dt_tm
    SET reply->qual[count1].encntr_type_cd = e.encntr_type_cd
    SET reply->qual[count1].loc_facility_cd = e.loc_facility_cd
    SET reply->qual[count1].financial_class_cd = e.financial_class_cd
    SET reply->qual[count1].building_cd = e.loc_building_cd
    SET reply->qual[count1].discharge_dt_tm = e.disch_dt_tm
    SET reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd
    SET reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id
    SET reply->qual[count1].ext_child_contributor_cd = b.ext_child_contributor_cd
    SET reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id
    SET reply->qual[count1].item_copay = c.item_copay
    SET reply->qual[count1].item_deductible_amt = c.item_deductible_amt
    SET reply->qual[count1].patient_responsibility_flag = c.patient_responsibility_flag
    SET reply->qual[count1].ext_owner_cd = b.ext_owner_cd
    SET reply->qual[count1].offset_charge_item_id = c.offset_charge_item_id
    SET reply->qual[count1].item_interval_id = c.item_interval_id
    SET reply->qual[count1].bill_item_id = c.bill_item_id
    SET reply->qual[count1].price_sched_id = c.price_sched_id
    SET reply->qual[count1].cs_cpp_undo_id = c.cs_cpp_undo_id
    SET reply->qual[count1].provider_specialty_cd = c.provider_specialty_cd
    SET reply->qual[count1].updt_cnt = c.updt_cnt
    SET reply->qual[count1].original_org_id = c.original_org_id
    IF (validate(reply->qual[count1].service_interface_flag) > 0)
     SET reply->qual[count1].service_interface_flag = c.service_interface_flag
    ENDIF
    IF (validate(reply->qual[count1].access_to_billing_entity) > 0)
     SET reply->qual[count1].access_to_billing_entity = true
    ENDIF
    IF (validate(reply->qual[count1].ext_parent_event_id) > 0)
     SET reply->qual[count1].ext_parent_event_id = ce.ext_p_event_id
    ENDIF
    SET count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     SET stat = alterlist(reply->qual,(count1+ 10))
    ENDIF
    SET reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id
    SET reply->qual[count1].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd
    SET reply->qual[count1].ext_master_event_id = ce.ext_m_event_id
    SET reply->qual[count1].accession_nbr = ce.accession
    SET reply->qual[count1].charge_item_id = c.charge_item_id
    SET reply->qual[count1].charge_event_id = c.charge_event_id
    SET reply->qual[count1].tier_group_cd = c.tier_group_cd
    SET reply->qual[count1].encntr_id = c.encntr_id
    SET reply->qual[count1].person_id = c.person_id
    SET reply->qual[count1].payor_id = c.payor_id
    SET reply->qual[count1].perf_loc_cd = c.perf_loc_cd
    SET reply->qual[count1].ord_phys_id = c.ord_phys_id
    SET reply->qual[count1].verify_phys_id = c.verify_phys_id
    SET reply->qual[count1].charge_description = c.charge_description
    SET reply->qual[count1].item_quantity = c.item_quantity
    SET reply->qual[count1].item_price = c.item_price
    SET reply->qual[count1].item_extended_price = c.item_extended_price
    SET reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id
    SET reply->qual[count1].charge_type_cd = c.charge_type_cd
    SET reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd
    SET reply->qual[count1].reason_comment = c.reason_comment
    SET reply->qual[count1].interface_file_id = c.interface_file_id
    SET reply->qual[count1].process_flg = c.process_flg
    SET reply->qual[count1].manual_ind = c.manual_ind
    SET reply->qual[count1].bundle_id = c.bundle_id
    SET reply->qual[count1].cost_center_cd = c.cost_center_cd
    SET reply->qual[count1].credited_dt_tm = c.credited_dt_tm
    SET reply->qual[count1].adjusted_dt_tm = c.adjusted_dt_tm
    SET reply->qual[count1].service_dt_tm = c.service_dt_tm
    SET reply->qual[count1].research_acct_id = c.research_acct_id
    SET reply->qual[count1].activity_type_cd = c.activity_type_cd
    SET reply->qual[count1].person_name = p.name_full_formatted
    SET reply->qual[count1].person_dob = p.birth_dt_tm
    SET reply->qual[count1].person_sex_cd = p.sex_cd
    SET reply->qual[count1].department_cd = c.department_cd
    SET reply->qual[count1].reason_for_visit = e.reason_for_visit
    SET reply->qual[count1].updt_id = c.updt_id
    SET reply->qual[count1].order_id = c.order_id
    SET reply->qual[count1].abn_status_cd = c.abn_status_cd
    SET reply->qual[count1].updt_dt_tm = c.updt_dt_tm
    SET reply->qual[count1].encntr_type_cd = e.encntr_type_cd
    SET reply->qual[count1].loc_facility_cd = e.loc_facility_cd
    SET reply->qual[count1].financial_class_cd = e.financial_class_cd
    SET reply->qual[count1].building_cd = e.loc_building_cd
    SET reply->qual[count1].discharge_dt_tm = e.disch_dt_tm
    SET reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd
    SET reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id
    SET reply->qual[count1].ext_child_contributor_cd = b.ext_child_contributor_cd
    SET reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id
    SET reply->qual[count1].item_copay = c.item_copay
    SET reply->qual[count1].item_deductible_amt = c.item_deductible_amt
    SET reply->qual[count1].patient_responsibility_flag = c.patient_responsibility_flag
    SET reply->qual[count1].ext_owner_cd = b.ext_owner_cd
    SET reply->qual[count1].offset_charge_item_id = c.offset_charge_item_id
    SET reply->qual[count1].item_interval_id = c.item_interval_id
    SET reply->qual[count1].bill_item_id = c.bill_item_id
    SET reply->qual[count1].price_sched_id = c.price_sched_id
    SET reply->qual[count1].cs_cpp_undo_id = c.cs_cpp_undo_id
    SET reply->qual[count1].provider_specialty_cd = c.provider_specialty_cd
    SET reply->qual[count1].updt_cnt = c.updt_cnt
    SET reply->qual[count1].original_org_id = c.original_org_id
    IF (validate(reply->qual[count1].service_interface_flag) > 0)
     SET reply->qual[count1].service_interface_flag = c.service_interface_flag
    ENDIF
    IF (validate(reply->qual[count1].access_to_billing_entity) > 0)
     SET reply->qual[count1].access_to_billing_entity = true
    ENDIF
    IF (validate(reply->qual[count1].ext_parent_event_id) > 0)
     SET reply->qual[count1].ext_parent_event_id = ce.ext_p_event_id
    ENDIF
    SET firstmaster = false
   ELSE
    SET reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id
    SET reply->qual[count1].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd
    SET reply->qual[count1].ext_master_event_id = ce.ext_m_event_id
    SET reply->qual[count1].accession_nbr = ce.accession
    SET reply->qual[count1].master_ind = 0
    SET reply->qual[count1].place_holder = 0
    SET reply->qual[count1].bump_up = 0
    SET reply->qual[count1].charge_item_id = c.charge_item_id
    SET reply->qual[count1].charge_event_id = c.charge_event_id
    SET reply->qual[count1].charge_event_act_id = c.charge_event_act_id
    SET reply->qual[count1].tier_group_cd = c.tier_group_cd
    SET reply->qual[count1].encntr_id = c.encntr_id
    SET reply->qual[count1].person_id = c.person_id
    SET reply->qual[count1].payor_id = c.payor_id
    SET reply->qual[count1].perf_loc_cd = c.perf_loc_cd
    SET reply->qual[count1].ord_phys_id = c.ord_phys_id
    SET reply->qual[count1].verify_phys_id = c.verify_phys_id
    SET reply->qual[count1].charge_description = c.charge_description
    SET reply->qual[count1].item_quantity = c.item_quantity
    SET reply->qual[count1].item_price = c.item_price
    SET reply->qual[count1].item_extended_price = c.item_extended_price
    SET reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id
    SET reply->qual[count1].charge_type_cd = c.charge_type_cd
    SET reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd
    SET reply->qual[count1].reason_comment = c.reason_comment
    SET reply->qual[count1].interface_file_id = c.interface_file_id
    SET reply->qual[count1].process_flg = c.process_flg
    SET reply->qual[count1].manual_ind = c.manual_ind
    SET reply->qual[count1].bundle_id = c.bundle_id
    SET reply->qual[count1].cost_center_cd = c.cost_center_cd
    SET reply->qual[count1].credited_dt_tm = c.credited_dt_tm
    SET reply->qual[count1].adjusted_dt_tm = c.adjusted_dt_tm
    SET reply->qual[count1].service_dt_tm = c.service_dt_tm
    SET reply->qual[count1].research_acct_id = c.research_acct_id
    SET reply->qual[count1].activity_type_cd = c.activity_type_cd
    SET reply->qual[count1].updt_dt_tm = c.updt_dt_tm
    SET reply->qual[count1].person_name = p.name_full_formatted
    SET reply->qual[count1].person_dob = p.birth_dt_tm
    SET reply->qual[count1].person_sex_cd = p.sex_cd
    SET reply->qual[count1].department_cd = c.department_cd
    SET reply->qual[count1].section_cd = c.section_cd
    SET reply->qual[count1].reason_for_visit = e.reason_for_visit
    SET reply->qual[count1].updt_id = c.updt_id
    SET reply->qual[count1].order_id = c.order_id
    SET reply->qual[count1].abn_status_cd = c.abn_status_cd
    SET reply->qual[count1].encntr_type_cd = e.encntr_type_cd
    SET reply->qual[count1].discharge_dt_tm = e.disch_dt_tm
    SET reply->qual[count1].loc_facility_cd = e.loc_facility_cd
    SET reply->qual[count1].financial_class_cd = e.financial_class_cd
    SET reply->qual[count1].building_cd = e.loc_building_cd
    SET reply->qual[count1].discharge_dt_tm = e.disch_dt_tm
    SET reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd
    SET reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id
    SET reply->qual[count1].ext_child_contributor_cd = b.ext_child_contributor_cd
    SET reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id
    SET reply->qual[count1].item_copay = c.item_copay
    SET reply->qual[count1].item_deductible_amt = c.item_deductible_amt
    SET reply->qual[count1].patient_responsibility_flag = c.patient_responsibility_flag
    SET reply->qual[count1].ext_owner_cd = b.ext_owner_cd
    SET reply->qual[count1].offset_charge_item_id = c.offset_charge_item_id
    SET reply->qual[count1].item_interval_id = c.item_interval_id
    SET reply->qual[count1].bill_item_id = c.bill_item_id
    SET reply->qual[count1].price_sched_id = c.price_sched_id
    SET reply->qual[count1].cs_cpp_undo_id = c.cs_cpp_undo_id
    SET reply->qual[count1].provider_specialty_cd = c.provider_specialty_cd
    SET reply->qual[count1].updt_cnt = c.updt_cnt
    SET reply->qual[count1].original_org_id = c.original_org_id
    IF (validate(reply->qual[count1].service_interface_flag) > 0)
     SET reply->qual[count1].service_interface_flag = c.service_interface_flag
    ENDIF
    IF (validate(reply->qual[count1].access_to_billing_entity) > 0)
     SET reply->qual[count1].access_to_billing_entity = true
    ENDIF
    IF (validate(reply->qual[count1].ext_parent_event_id) > 0)
     SET reply->qual[count1].ext_parent_event_id = ce.ext_p_event_id
    ENDIF
   ENDIF
   IF (c.posted_id > 0.0)
    SET reply->qual[count1].postedbyid = c.posted_id
   ELSE
    SET reply->qual[count1].postedbyid = c.updt_id
   ENDIF
   SET reply->qual[count1].updt_id = c.updt_id
   SET reply->qual[count1].location_disp = uar_get_code_display(e.loc_nurse_unit_cd)
   SET reply->qual[count1].fin_class_disp = uar_get_code_display(e.financial_class_cd)
   SET reply->qual[count1].loc_room_disp = uar_get_code_display(e.loc_room_cd)
   SET reply->qual[count1].building_disp = uar_get_code_display(e.loc_building_cd)
  ELSE
   SET reply->hasmoreind = true
  ENDIF
 END ;Subroutine
 SUBROUTINE lookuporderinfo(null)
   DECLARE nbatch_size = i2 WITH protect, constant(60)
   DECLARE lloopcnt = i4 WITH protect, noconstant(0)
   DECLARE ltempsize = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE lndx = i4 WITH protect, noconstant(0)
   DECLARE llastndx = i4 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE lstartndx = i4 WITH protect, noconstant(1)
   FREE RECORD order_index
   RECORD order_index(
     1 orders[*]
       2 dorderid = f8
       2 replyindexes[*]
         3 lindex = i4
       2 lreplyindexessize = i4
   )
   SET lstat = alterlist(order_index->orders,reply->charge_qual)
   FOR (i = 1 TO reply->charge_qual)
     IF ((reply->qual[i].order_id != 0.0))
      IF (llastndx != 0)
       SET lndx = locateval(j,1,llastndx,reply->qual[i].order_id,order_index->orders[j].dorderid)
      ELSE
       SET lndx = 0
      ENDIF
      IF (lndx=0)
       SET llastndx += 1
       SET lndx = llastndx
       SET order_index->orders[lndx].dorderid = reply->qual[i].order_id
      ENDIF
      SET order_index->orders[lndx].lreplyindexessize += 1
      SET lstat = alterlist(order_index->orders[lndx].replyindexes,order_index->orders[lndx].
       lreplyindexessize)
      SET order_index->orders[lndx].replyindexes[order_index->orders[lndx].lreplyindexessize].lindex
       = i
     ENDIF
   ENDFOR
   SET lloopcnt = ceil((cnvtreal(llastndx)/ nbatch_size))
   SET ltempsize = (lloopcnt * nbatch_size)
   SET lstat = alterlist(order_index->orders,ltempsize)
   FOR (i = (llastndx+ 1) TO ltempsize)
     SET order_index->orders[i].dorderid = order_index->orders[llastndx].dorderid
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = lloopcnt),
     orders o
    PLAN (d
     WHERE initarray(lstartndx,evaluate(d.seq,1,1,(lstartndx+ nbatch_size))))
     JOIN (o
     WHERE expand(i,lstartndx,((lstartndx+ nbatch_size) - 1),o.order_id,order_index->orders[i].
      dorderid))
    DETAIL
     lndx = locateval(j,lstartndx,((lstartndx+ nbatch_size) - 1),o.order_id,order_index->orders[j].
      dorderid)
     FOR (j = 1 TO order_index->orders[lndx].lreplyindexessize)
       reply->qual[order_index->orders[lndx].replyindexes[j].lindex].order_status_cd = o
       .order_status_cd
     ENDFOR
    WITH nocounter
   ;end select
   FREE RECORD order_index
 END ;Subroutine
 SUBROUTINE retrieveretailpharmacyind(null)
   CALL logmessage("retrieveRetailPharmacyInd","Begin - retrieveRetailPharmacyInd",log_debug)
   SELECT INTO "nl:"
    FROM pft_charge pc,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1)
     JOIN (pc
     WHERE (pc.charge_item_id=reply->qual[d1.seq].charge_item_id)
      AND pc.active_ind=true)
    DETAIL
     reply->qual[d1.seq].ext_billed_ind = pc.ext_billed_ind
    WITH nocounter
   ;end select
   CALL logmessage("retrieveRetailPharmacyInd","End - retrieveRetailPharmacyInd",log_debug)
 END ;Subroutine
 SUBROUTINE updatereplybasedonbillingentityaccess(null)
   CALL logmessage("updateReplyBasedOnBillingEntityAccess",
    "Begin - updateReplyBasedOnBillingEntityAccess",log_debug)
   DECLARE chargeidx = i4 WITH noconstant(0)
   DECLARE billingentityidx = i4 WITH noconstant(0)
   DECLARE numcharges = i4 WITH noconstant(0)
   DECLARE replyimpacted = i2 WITH noconstant(false)
   DECLARE notdone = i2 WITH noconstant(true)
   DECLARE chargeidx = i4 WITH noconstant(0)
   DECLARE charge2idx = i4 WITH noconstant(0)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE searchstart = i4 WITH noconstant(1)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Reply contents before updating")
    CALL echorecord(reply)
   ENDIF
   RECORD authorizedbillingentities(
     1 billingentities[*]
       2 billingentityid = f8
   ) WITH protect
   IF ( NOT (getuserauthorizedbillingentities(authorizedbillingentities)))
    CALL echo("getUserAuthorizedBillingEntities returned failure")
    SET stat = initrec(reply)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to retrieve authorized billing entities"
    GO TO exit_script
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echo("User's authorized billing entities")
    CALL echorecord(authorizedbillingentities)
   ENDIF
   SELECT INTO "nl:"
    FROM charge c,
     interface_file i,
     encounter e,
     location l,
     be_org_reltn b
    PLAN (c
     WHERE expand(chargeidx,1,size(reply->qual,5),c.charge_item_id,reply->qual[chargeidx].
      charge_item_id))
     JOIN (e
     WHERE e.encntr_id=c.encntr_id)
     JOIN (l
     WHERE l.location_cd=e.loc_facility_cd)
     JOIN (b
     WHERE b.organization_id=l.organization_id
      AND b.active_ind=1
      AND b.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND b.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (i
     WHERE i.interface_file_id=c.interface_file_id
      AND i.profit_type_cd > 0.0
      AND i.billing_entity_id=0.0
      AND  NOT (expand(billingentityidx,1,size(authorizedbillingentities->billingentities,5),b
      .billing_entity_id,authorizedbillingentities->billingentities[billingentityidx].billingentityid
      )))
    ORDER BY c.charge_item_id
    HEAD c.charge_item_id
     notdone = true, charge2idx = 0, idx = 0,
     searchstart = 1
     WHILE (notdone=true)
      charge2idx = locateval(idx,searchstart,size(reply->qual,5),c.charge_item_id,reply->qual[idx].
       charge_item_id),
      IF (charge2idx > 0)
       reply->qual[charge2idx].access_to_billing_entity = false, searchstart = (charge2idx+ 1),
       replyimpacted = true
       IF (searchstart > size(reply->qual,5))
        notdone = false
       ENDIF
      ELSE
       notdone = false
      ENDIF
     ENDWHILE
    WITH nocounter, expand = 2
   ;end select
   SELECT INTO "nl:"
    FROM charge c,
     interface_file i
    PLAN (c
     WHERE expand(chargeidx,1,size(reply->qual,5),c.charge_item_id,reply->qual[chargeidx].
      charge_item_id))
     JOIN (i
     WHERE i.interface_file_id=c.interface_file_id
      AND i.profit_type_cd > 0.0
      AND i.billing_entity_id > 0.0
      AND  NOT (expand(billingentityidx,1,size(authorizedbillingentities->billingentities,5),i
      .billing_entity_id,authorizedbillingentities->billingentities[billingentityidx].billingentityid
      )))
    ORDER BY c.charge_item_id
    HEAD c.charge_item_id
     notdone = true, charge2idx = 0, idx = 0,
     searchstart = 1
     WHILE (notdone=true)
      charge2idx = locateval(idx,searchstart,size(reply->qual,5),c.charge_item_id,reply->qual[idx].
       charge_item_id),
      IF (charge2idx > 0)
       reply->qual[charge2idx].access_to_billing_entity = false, searchstart = (charge2idx+ 1),
       replyimpacted = true
       IF (searchstart > size(reply->qual,5))
        notdone = false
       ENDIF
      ELSE
       notdone = false
      ENDIF
     ENDWHILE
    WITH nocounter, expand = 2
   ;end select
   IF (validate(debug,- (1)) > 0)
    CALL echo("Reply after initial update")
    CALL echorecord(reply)
   ENDIF
   IF (replyimpacted)
    IF (validate(debug,- (1)) > 0)
     CALL echo("The Reply has at least one charge the user shouldn't see. Execute remaining logic.")
    ENDIF
    SET stat = copyrec(reply,temprec,0)
    SET stat = alterlist(temprec->qual,size(reply->qual,5))
    FOR (chargeidx = 1 TO size(reply->qual,5))
      IF ((reply->qual[chargeidx].master_ind=1)
       AND (reply->qual[chargeidx].bump_up=1)
       AND (reply->qual[chargeidx].access_to_billing_entity=false))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "Copy Logic: Master_Ind = 1 and bump_up = 1 access = FALSE, Looking for new dummy charge.")
        CALL echo(build2("  Current Dummy charge_item_id: ",reply->qual[chargeidx].charge_item_id))
       ENDIF
       DECLARE foundnewparent = i2 WITH noconstant(false)
       DECLARE currentidx = i4 WITH noconstant(0)
       SET currentidx = (chargeidx+ 2)
       WHILE (currentidx <= size(reply->qual,5)
        AND (reply->qual[currentidx].master_ind=0)
        AND foundnewparent=false)
         IF (validate(debug,- (1)) > 0)
          CALL echo(build2("  potential new dummy charge_item_id: ",reply->qual[currentidx].
            charge_item_id))
         ENDIF
         IF ((reply->qual[currentidx].access_to_billing_entity=true)
          AND (reply->qual[currentidx].master_ind=0)
          AND (reply->qual[currentidx].bump_up=0))
          IF (validate(debug,- (1)) > 0)
           CALL echo("  Found new dummy charge, copying current child.")
           CALL echo(build2("  Current Index: ",currentidx," New dummy charge_item_id: ",reply->qual[
             currentidx].charge_item_id))
          ENDIF
          SET numcharges += 1
          SET stat = movereclist(reply->qual[currentidx],temprec->qual[numcharges],currentidx,
           numcharges,1,
           0)
          SET temprec->qual[numcharges].master_ind = 1
          SET temprec->qual[numcharges].place_holder = 1
          SET temprec->qual[numcharges].bump_up = 1
          IF ((temprec->qual[numcharges].order_id <= 0))
           SET temprec->qual[numcharges].accession_nbr = ""
          ENDIF
          SET temprec->qual[numcharges].item_price = 0.0
          SET temprec->qual[numcharges].item_extended_price = 0.0
          SET temprec->qual[numcharges].parent_charge_item_id = 0.0
          SET temprec->qual[numcharges].reason_for_visit = ""
          SET temprec->qual[numcharges].postedbyid = 0.0
          SET temprec->qual[numcharges].postedby = ""
          SET stat = alterlist(temprec->qual[numcharges].bill_code,0)
          SET temprec->qual[numcharges].bill_code_qual = 0
          SET stat = alterlist(temprec->qual[numcharges].interval_qual,0)
          SET temprec->qual[numcharges].interval_template_cd = 0.0
          SET temprec->qual[numcharges].item_interval_id = 0.0
          SET chargeidx = (currentidx - 1)
          SET foundnewparent = true
          IF (validate(debug,- (1)) > 0)
           CALL echo(build2("  Setting chargeIdx To: ",chargeidx))
          ENDIF
         ENDIF
         SET currentidx += 1
       ENDWHILE
       IF (foundnewparent=false
        AND validate(debug,- (1)) > 0)
        CALL echo("  No new dummy charge found for this master event")
       ENDIF
      ELSEIF ((reply->qual[chargeidx].master_ind=1)
       AND (reply->qual[chargeidx].bump_up=1)
       AND (reply->qual[chargeidx].access_to_billing_entity=true))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "Copy Logic: Master_Ind = 1 and bump_up = 1 access = TRUE, Copy the current dummy charge")
        CALL echo(build2("  Current Dummy charge_item_id: ",reply->qual[chargeidx].charge_item_id))
       ENDIF
       SET numcharges += 1
       SET stat = movereclist(reply->qual[chargeidx],temprec->qual[numcharges],chargeidx,numcharges,1,
        0)
      ELSEIF ((reply->qual[chargeidx].master_ind=1)
       AND (reply->qual[chargeidx].bump_up=0)
       AND (reply->qual[chargeidx].access_to_billing_entity=false))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "Copy Logic: master_ind = 1 bump_up = 0, need to identify a new master for this event.")
        CALL echo(build2("  Current Master charge_item_id: ",reply->qual[chargeidx].charge_item_id))
       ENDIF
       DECLARE foundnewmaster = i2 WITH noconstant(false)
       DECLARE currentidx = i4 WITH noconstant(0)
       SET currentidx = (chargeidx+ 1)
       WHILE (currentidx <= size(reply->qual,5)
        AND (reply->qual[currentidx].master_ind=0)
        AND foundnewmaster=false)
         IF (validate(debug,- (1)) > 0)
          CALL echo(build2("  Potential new master charge_item_id: ",reply->qual[currentidx].
            charge_item_id))
         ENDIF
         IF ((reply->qual[currentidx].access_to_billing_entity=true))
          IF ((((reply->qual[currentidx].ext_parent_event_id > 0)) OR ((reply->qual[currentidx].
          ext_parent_event_id <= 0)
           AND (reply->qual[currentidx].ext_child_reference_id > 0))) )
           IF (validate(debug,- (1)) > 0)
            CALL echo(
             "  New master found, new master should also a dummy charge, copying current charge and making the dummy"
             )
            CALL echo(build2("  Current Index: ",currentidx," New Master/Dummy charge_item_id: ",
              reply->qual[currentidx].charge_item_id))
           ENDIF
           SET numcharges += 1
           SET stat = movereclist(reply->qual[currentidx],temprec->qual[numcharges],currentidx,
            numcharges,1,
            0)
           SET temprec->qual[numcharges].master_ind = 1
           SET temprec->qual[numcharges].place_holder = 1
           SET temprec->qual[numcharges].bump_up = 1
           IF ((temprec->qual[numcharges].order_id <= 0))
            SET temprec->qual[numcharges].accession_nbr = ""
           ENDIF
           SET temprec->qual[numcharges].item_price = 0.0
           SET temprec->qual[numcharges].item_extended_price = 0.0
           SET temprec->qual[numcharges].parent_charge_item_id = 0.0
           SET temprec->qual[numcharges].reason_for_visit = ""
           SET temprec->qual[numcharges].postedbyid = 0.0
           SET temprec->qual[numcharges].postedby = ""
           SET stat = alterlist(temprec->qual[numcharges].bill_code,0)
           SET temprec->qual[numcharges].bill_code_qual = 0
           SET stat = alterlist(temprec->qual[numcharges].interval_qual,0)
           SET temprec->qual[numcharges].interval_template_cd = 0.0
           SET temprec->qual[numcharges].item_interval_id = 0.0
           SET numcharges += 1
           SET stat = movereclist(reply->qual[currentidx],temprec->qual[numcharges],currentidx,
            numcharges,1,
            0)
           SET foundnewmaster = true
           SET chargeidx = currentidx
           IF (validate(debug,- (1)) > 0)
            CALL echo(build2("  Setting chargeIdx To: ",chargeidx))
           ENDIF
          ELSE
           IF (validate(debug,- (1)) > 0)
            CALL echo("  New master found, copying and updating current charge to be the new master."
             )
            CALL echo(build2("  Current Index: ",currentidx," New Master charge_item_id: ",reply->
              qual[currentidx].charge_item_id))
           ENDIF
           SET numcharges += 1
           SET stat = movereclist(reply->qual[currentidx],temprec->qual[numcharges],currentidx,
            numcharges,1,
            0)
           SET temprec->qual[numcharges].master_ind = 1
           SET temprec->qual[numcharges].bump_up = 0
           SET temprec->qual[numcharges].place_holder = 0
           SET foundnewmaster = true
           SET chargeidx = currentidx
           IF (validate(debug,- (1)) > 0)
            CALL echo(build2("  Setting chargeIdx To: ",chargeidx))
           ENDIF
          ENDIF
         ENDIF
         SET currentidx += 1
       ENDWHILE
       IF (foundnewmaster=false
        AND validate(debug,- (1)) > 0)
        CALL echo("  No new master charge found for this master event")
       ENDIF
      ELSEIF ((reply->qual[chargeidx].bump_up=0)
       AND (reply->qual[chargeidx].access_to_billing_entity=true))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
"Copy Logic: bump_up = 0, we have access to this charge and can copy,                                                      \
                     it's either a master or a child\
")
        CALL echo(build2("  Current Child/Master charge_item_id: ",reply->qual[chargeidx].
          charge_item_id))
       ENDIF
       SET numcharges += 1
       SET stat = movereclist(reply->qual[chargeidx],temprec->qual[numcharges],chargeidx,numcharges,1,
        0)
      ELSE
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "Copy Logic: We have determined that this charge shouldn't be viewed by the user, don't copy"
         )
        CALL echo(build2("  Current charge_item_id: ",reply->qual[chargeidx].charge_item_id))
       ENDIF
      ENDIF
    ENDFOR
    IF (validate(debug,- (1)) > 0)
     CALL echo("Temprec contents")
     CALL echorecord(temprec)
     CALL echo(build2("Number of Charges: ",numcharges))
    ENDIF
    SET stat = alterlist(temprec->qual,numcharges)
    SET stat = alterlist(reply->qual,numcharges)
    SET stat = movereclist(temprec->qual,reply->qual,1,1,size(temprec->qual,5),
     0)
    SET reply->charge_qual = numcharges
    IF (validate(debug,- (1)) > 0)
     CALL echo("Reply contents after removing charges")
     CALL echorecord(reply)
    ENDIF
    IF (size(reply->qual,5) <= 0
     AND (reply->status_data.status="S"))
     SET reply->status_data.status = "Z"
     SET reply->status_data.subeventstatus[1].operationname = "Select"
     SET reply->status_data.subeventstatus[1].operationstatus = "s"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARGE"
    ENDIF
   ELSE
    IF (validate(debug,- (1)) > 0)
     CALL echo("The user can view all charges in the reply. Bypassed reply looping logic.")
    ENDIF
   ENDIF
   CALL logmessage("updateReplyBasedOnBillingEntityAccess",
    "End - updateReplyBasedOnBillingEntityAccess",log_debug)
 END ;Subroutine
#exit_script
#end_program
END GO
