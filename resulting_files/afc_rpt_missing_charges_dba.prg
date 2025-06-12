CREATE PROGRAM afc_rpt_missing_charges:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Charge Event Type" = 0.000000
  WITH outdev, dtfromdate, dtenddate,
  dcetypecd
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
 CALL beginservice("312138.001")
 RECORD my_request(
   1 from_date = dq8
   1 to_date = dq8
 )
 RECORD chargeevent(
   1 charge_event_qual = i4
   1 charge_event[*]
     2 charge_event_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_reference_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 name_full_formatted = vc
     2 encntr_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 accession = vc
     2 bill_item_desc = vc
     2 service_dt_tm = dq8
     2 dx_reason = vc
     2 activity_dt_tm = dq8
     2 build_exists = i2
 )
 FREE RECORD authorizedorganizations
 RECORD authorizedorganizations(
   1 organizations[*]
     2 organizationid = f8
     2 confidentialitylevel = i4
 )
 DECLARE iret = i2 WITH noconstant(0)
 DECLARE firsttime = i2 WITH noconstant(1)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE codeset = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE 13019_chargepoint = f8 WITH noconstant(0.0)
 DECLARE 13019_srv_diag = f8 WITH noconstant(0.0)
 DECLARE 13020_null = f8 WITH noconstant(0.0)
 DECLARE 13029_clear = f8 WITH noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH noconstant("")
 DECLARE l_date = vc WITH noconstant("")
 DECLARE l_page = vc WITH noconstant("")
 DECLARE l_begin_date = vc WITH noconstant("")
 DECLARE l_end_date = vc WITH noconstant("")
 DECLARE l_patient_name = vc WITH noconstant("")
 DECLARE l_encntr_id = vc WITH noconstant("")
 DECLARE l_organization = vc WITH noconstant("")
 DECLARE l_activity_date = vc WITH noconstant("")
 DECLARE l_service_date = vc WITH noconstant("")
 DECLARE l_accession = vc WITH noconstant("")
 DECLARE l_orderable = vc WITH noconstant("")
 DECLARE l_reason = vc WITH noconstant("")
 DECLARE l_report_type = vc WITH noconstant("")
 DECLARE sacttype = vc WITH noconstant("")
 DECLARE soutputdest = vc WITH noconstant("")
 DECLARE servicedttm = dq8
 DECLARE activitydttm = dq8
 DECLARE iindex = i4
 SET iret = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET my_request->from_date = curdate
 SET my_request->to_date = curdate
 SET my_request->to_date = cnvtdatetime(concat(format(curdate,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET codeset = 13019
 SET cdf_meaning = "CHARGE POINT"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13019_chargepoint)
 SET codeset = 13019
 SET cdf_meaning = "SRV DIAG"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13019_srv_diag)
 SET codeset = 13020
 SET cdf_meaning = "NULL"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13020_null)
 SET codeset = 13029
 SET cdf_meaning = "CLEAR"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13029_clear)
 SET l_date = uar_i18ngetmessage(i18nhandle,"k1","Date: ")
 SET l_pate = uar_i18ngetmessage(i18nhandle,"k1","Page:  1 ")
 SET l_begin_date = uar_i18ngetmessage(i18nhandle,"k1","Begin Date: ")
 SET l_end_date = uar_i18ngetmessage(i18nhandle,"k1","End Date: ")
 SET l_page = uar_i18ngetmessage(i18nhandle,"k1","Page:")
 SET l_patient_name = uar_i18ngetmessage(i18nhandle,"k1","PATIENT NAME")
 SET l_encntr_id = uar_i18ngetmessage(i18nhandle,"k1","ENCNTR ID")
 SET l_organization = uar_i18ngetmessage(i18nhandle,"k1","ORGANIZATION")
 SET l_activity_date = uar_i18ngetmessage(i18nhandle,"k1","ACTIVITY DATE")
 SET l_service_date = uar_i18ngetmessage(i18nhandle,"k1","SERVICE DATE")
 SET l_accession = uar_i18ngetmessage(i18nhandle,"k1","ACCESSION")
 SET l_orderable = uar_i18ngetmessage(i18nhandle,"k1","ORDERABLE")
 SET l_reason = uar_i18ngetmessage(i18nhandle,"k1","REASON")
 SET l_report_type = uar_i18ngetmessage(i18nhandle,"k1","Event Type:")
 SET soutputdest =  $OUTDEV
 SET my_request->from_date = cnvtdatetime( $DTFROMDATE)
 SET my_request->to_date = cnvtdatetime( $DTENDDATE)
 SET code_value =  $DCETYPECD
 SET sacttype = uar_get_code_display(code_value)
 IF ( NOT (getauthorizedorganizations(authorizedorganizations)))
  CALL exitservicefailure("Unable to retrieve Authorized Organizations",true)
 ENDIF
 SELECT INTO "nl:"
  FROM charge_event_act cea,
   charge_event ce,
   encounter e,
   person p,
   organization o
  PLAN (cea
   WHERE cea.updt_dt_tm BETWEEN cnvtdatetime(my_request->from_date) AND cnvtdatetime(my_request->
    to_date)
    AND cea.cea_type_cd=code_value
    AND cea.active_ind=1)
   JOIN (ce
   WHERE ce.charge_event_id=cea.charge_event_id
    AND ce.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    c.charge_item_id
    FROM charge c
    WHERE c.charge_event_id=ce.charge_event_id))))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND expand(iindex,1,size(authorizedorganizations->organizations,5),o.organization_id,
    authorizedorganizations->organizations[iindex].organizationid))
  ORDER BY ce.charge_event_id
  HEAD REPORT
   stat = alterlist(chargeevent->charge_event,10)
  HEAD ce.charge_event_id
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(chargeevent->charge_event,(count1+ 10))
   ENDIF
   chargeevent->charge_event[count1].activity_dt_tm = cea.updt_dt_tm, chargeevent->charge_event[
   count1].charge_event_id = ce.charge_event_id, chargeevent->charge_event[count1].
   ext_parent_reference_id = ce.ext_p_reference_id,
   chargeevent->charge_event[count1].ext_parent_reference_cont_cd = ce.ext_p_reference_cont_cd,
   chargeevent->charge_event[count1].ext_item_reference_id = ce.ext_i_reference_id, chargeevent->
   charge_event[count1].ext_item_reference_cont_cd = ce.ext_i_reference_cont_cd,
   chargeevent->charge_event[count1].encntr_id = ce.encntr_id, chargeevent->charge_event[count1].
   accession = ce.accession, chargeevent->charge_event[count1].service_dt_tm = cea.service_dt_tm,
   chargeevent->charge_event[count1].name_full_formatted = p.name_full_formatted, chargeevent->
   charge_event[count1].organization_id = e.organization_id, chargeevent->charge_event[count1].
   org_name = o.org_name
  DETAIL
   null
  FOOT REPORT
   chargeevent->charge_event_qual = count1, stat = alterlist(chargeevent->charge_event,count1)
  WITH nocounter, expand = 1
 ;end select
 IF ((chargeevent->charge_event_qual > 0))
  SELECT INTO "nl:"
   FROM bill_item b,
    bill_item_modifier bim,
    (dummyt d  WITH seq = value(chargeevent->charge_event_qual))
   PLAN (d
    WHERE (chargeevent->charge_event[d.seq].ext_parent_reference_id=0.0))
    JOIN (b
    WHERE (b.ext_parent_reference_id=chargeevent->charge_event[d.seq].ext_item_reference_id)
     AND (b.ext_parent_contributor_cd=chargeevent->charge_event[d.seq].ext_item_reference_cont_cd)
     AND b.ext_child_reference_id=0
     AND b.ext_child_contributor_cd=0)
    JOIN (bim
    WHERE bim.bill_item_id=b.bill_item_id
     AND bim.bill_item_type_cd=13019_chargepoint
     AND bim.key2_id != 13029_clear
     AND bim.key4_id != 13020_null
     AND bim.active_ind=1)
   DETAIL
    chargeevent->charge_event[d.seq].bill_item_desc = b.ext_description, chargeevent->charge_event[d
    .seq].build_exists = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bill_item b,
    bill_item_modifier bim,
    (dummyt d  WITH seq = value(chargeevent->charge_event_qual))
   PLAN (d
    WHERE (chargeevent->charge_event[d.seq].ext_parent_reference_id > 0.0))
    JOIN (b
    WHERE (b.ext_parent_reference_id=chargeevent->charge_event[d.seq].ext_parent_reference_id)
     AND (b.ext_parent_contributor_cd=chargeevent->charge_event[d.seq].ext_parent_reference_cont_cd)
     AND (b.ext_child_reference_id=chargeevent->charge_event[d.seq].ext_item_reference_id)
     AND (b.ext_child_contributor_cd=chargeevent->charge_event[d.seq].ext_item_reference_cont_cd))
    JOIN (bim
    WHERE bim.bill_item_id=b.bill_item_id
     AND bim.bill_item_type_cd=13019_chargepoint
     AND bim.key2_id != 13029_clear
     AND bim.key4_id != 13020_null
     AND bim.active_ind=1)
   DETAIL
    chargeevent->charge_event[d.seq].bill_item_desc = b.ext_description, chargeevent->charge_event[d
    .seq].build_exists = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_mod cem,
    (dummyt d1  WITH seq = value(chargeevent->charge_event_qual))
   PLAN (d1
    WHERE (chargeevent->charge_event[d1.seq].build_exists=1))
    JOIN (cem
    WHERE (cem.charge_event_id=chargeevent->charge_event[d1.seq].charge_event_id)
     AND cem.charge_event_mod_type_cd=13019_srv_diag
     AND cem.active_ind=1)
   DETAIL
    chargeevent->charge_event[d1.seq].dx_reason = cem.field6
   WITH nocounter
  ;end select
  SELECT INTO value(soutputdest)
   activitydttm = format(chargeevent->charge_event[d1.seq].activity_dt_tm,"DD-MMM-YYYY hh:mm;;D"),
   servicedttm = format(chargeevent->charge_event[d1.seq].service_dt_tm,"DD-MMM-YYYY hh:mm;;D")
   FROM (dummyt d1  WITH seq = value(chargeevent->charge_event_qual))
   PLAN (d1
    WHERE (chargeevent->charge_event[d1.seq].build_exists=1))
   ORDER BY chargeevent->charge_event[d1.seq].activity_dt_tm
   HEAD REPORT
    mainheading = uar_i18ngetmessage(i18nhandle,"k1","M I S S I N G  C H A R G E S  A U D I T"),
    todaysdate = concat(format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D")), underline =
    fillstring(125,"-"),
    col 0, l_date, col 6,
    todaysdate, col 44, mainheading,
    col 116, l_page, col 124,
    curpage"#", row + 2, col 0,
    l_begin_date, col 12, my_request->from_date"dd-mmm-yyyy hh:mm;;d",
    row + 1, col 0, l_end_date,
    col 10, my_request->to_date"dd-mmm-yyyy hh:mm;;d", row + 1,
    col 0, l_report_type, col 12,
    sacttype, row + 2
   HEAD PAGE
    IF (firsttime=0)
     col 116, l_page, col 124,
     curpage"###", row + 2
    ENDIF
    firsttime = 0, col 0, l_patient_name,
    col 22, l_encntr_id, col 39,
    l_organization, col 70, l_activity_date,
    row + 1, col 10, l_service_date,
    col 30, l_accession, col 50,
    l_orderable, col 80, l_reason,
    row + 1, col 0, underline,
    row + 1
   DETAIL
    row + 1, col 0, chargeevent->charge_event[d1.seq].name_full_formatted"####################",
    col 19, chargeevent->charge_event[d1.seq].encntr_id"##########", col 39,
    chargeevent->charge_event[d1.seq].org_name"#########################", col 70, activitydttm,
    row + 1, col 10, servicedttm,
    col 30, chargeevent->charge_event[d1.seq].accession"##################", col 50,
    chargeevent->charge_event[d1.seq].bill_item_desc"#########################", col 80, chargeevent
    ->charge_event[d1.seq].dx_reason"########################################",
    row + 1
   WITH nocounter
  ;end select
 ENDIF
#end_program
END GO
