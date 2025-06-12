CREATE PROGRAM afc_get_billitem_for_bcsched:dba
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
 CALL beginservice("644734.008 minus 007")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 activityqual[*]
      2 activitycd = f8
      2 activitydisplay = c40
      2 billitemqual[*]
        3 ext_owner_cd = f8
        3 ext_sub_owner_cd = f8
        3 ext_sub_owner_disp = vc
        3 ext_owner_disp = vc
        3 bill_item_id = f8
        3 ext_parent_reference_id = f8
        3 ext_parent_contributor_cd = f8
        3 ext_parent_contributor_disp = c40
        3 ext_child_reference_id = f8
        3 ext_child_contributor_cd = f8
        3 ext_child_contributor_disp = c40
        3 ext_description = vc
        3 ext_short_desc = vc
        3 misc_ind = i2
        3 stats_only_ind = i2
        3 workload_only_ind = i2
        3 late_chrg_excl_ind = i2
        3 isparentfororphan = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempbillitems(
   1 billitemqual[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
 )
 FREE RECORD billcodeschedules
 RECORD billcodeschedules(
   1 schedulelist[*]
     2 schedulevalue = f8
 )
 DECLARE getparentfororphanchild(dummy) = i2
 DECLARE fillreply(dummy) = null
 IF ( NOT (validate(cs26078_bc_sched_cd)))
  DECLARE cs26078_bc_sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",26078,"BC_SCHED")
   )
 ENDIF
 IF ( NOT (validate(cs26078_bill_item_cd)))
  DECLARE cs26078_bill_item_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",26078,
    "BILL_ITEM"))
 ENDIF
 IF ( NOT (validate(cs13019_bill_code_cd)))
  DECLARE cs13019_bill_code_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,
    "BILL CODE"))
 ENDIF
 IF ( NOT (validate(cs14002_asa_code_cd)))
  DECLARE cs14002_asa_code_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14002,"ASA"))
 ENDIF
 DECLARE isbillitemsecurityon = i2 WITH protect, noconstant(0)
 DECLARE isbillcodesecurityon = i2 WITH protect, noconstant(0)
 DECLARE logicaldomainid = f8 WITH noconstant(0.0), protect
 CALL logcapabilityauditevent(0)
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",true)
 ENDIF
 IF ( NOT (initsecuritypreference(isbillitemsecurityon,isbillcodesecurityon)))
  CALL exitservicenodata("Failed to initialize Security Preference",true)
 ENDIF
 IF ( NOT (initbillcodeschedlist(isbillcodesecurityon,billcodeschedules,request->billcodeschedule)))
  CALL exitservicenodata("Failed to initialize Bill Code Schedules",true)
 ENDIF
 IF ( NOT (getbillitemsforbillcodetype(isbillitemsecurityon,billcodeschedules)))
  CALL exitservicenodata("Failed to find Bill items for the BillCode schedule searchText",true)
 ENDIF
 IF ( NOT (getparentfororphanchild(null)))
  CALL exitservicenodata("Failed to find Parent Bill items for the Orphan BillItems",true)
 ENDIF
 IF (size(tempbillitems->billitemqual,5) > 0)
  CALL fillreply(null)
 ENDIF
 CALL exitservicesuccess("")
 GO TO exit_script
 SUBROUTINE (initsecuritypreference(billitemsecurity=i2(ref),billcodesecurity=i2(ref)) =i2)
   DECLARE nrepcount = i4
   DECLARE iflag = i2 WITH protect, noconstant(true)
   FREE RECORD afc_dm_request
   RECORD afc_dm_request(
     1 info_name_qual = i2
     1 info[*]
       2 info_name = vc
     1 info_name = vc
   )
   FREE RECORD afc_dm_reply
   RECORD afc_dm_reply(
     1 dm_info_qual = i2
     1 dm_info[*]
       2 info_name = vc
       2 info_date = dq8
       2 info_char = vc
       2 info_number = f8
       2 info_long_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET afc_dm_request->info_name_qual = 2
   SET stat = alterlist(afc_dm_request->info,2)
   SET afc_dm_request->info[1].info_name = "BILL ITEM SECURITY"
   SET afc_dm_request->info[2].info_name = "BILL CODE SCHED SECURITY"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    FOR (nrepcount = 1 TO size(afc_dm_reply->dm_info,5))
     IF ((afc_dm_reply->dm_info[nrepcount].info_name="BILL ITEM SECURITY")
      AND (afc_dm_reply->dm_info[nrepcount].info_char="Y"))
      SET billitemsecurity = true
     ENDIF
     IF ((afc_dm_reply->dm_info[nrepcount].info_name="BILL CODE SCHED SECURITY")
      AND (afc_dm_reply->dm_info[nrepcount].info_char="Y"))
      SET billcodesecurity = true
     ENDIF
    ENDFOR
   ELSEIF ((afc_dm_reply->status_data.status="F"))
    SET iflag = false
   ENDIF
   RETURN(iflag)
 END ;Subroutine
 SUBROUTINE (initbillcodeschedlist(securitypref=i2,billcodeschedulearray=vc(ref),billcodeschedule=f8
  ) =i2)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE ischedcnt = i4 WITH protect, noconstant(0)
   DECLARE billcodecfmeaning = vc WITH protect, noconstant("")
   IF (billcodeschedule=0.0)
    SELECT
     IF (securitypref)
      FROM prsnl_org_reltn por,
       cs_org_reltn cor,
       code_value cv
      PLAN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND por.active_ind=1)
       JOIN (cor
       WHERE cor.organization_id=por.organization_id
        AND cor.cs_org_reltn_type_cd=cs26078_bc_sched_cd
        AND cor.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=cor.key1_id
        AND cv.active_ind=true
        AND cv.cdf_meaning=trim(request->billcodetypefilter,3))
     ELSE
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=14002
        AND cv.active_ind=true
        AND cv.cdf_meaning=trim(request->billcodetypefilter))
     ENDIF
     INTO "nl:"
     ORDER BY cv.code_value
     HEAD cv.code_value
      icnt += 1, stat = alterlist(billcodeschedulearray->schedulelist,icnt), billcodeschedulearray->
      schedulelist[icnt].schedulevalue = cv.code_value
     WITH nocounter
    ;end select
    IF (trim(request->billcodetypefilter)="ASA")
     SET icnt += 1
     SET stat = alterlist(billcodeschedulearray->schedulelist,icnt)
     SET billcodeschedulearray->schedulelist[icnt].schedulevalue = cs14002_asa_code_cd
    ENDIF
    IF (curqual=0
     AND icnt=0)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   ELSEIF (billcodeschedule > 0.0)
    SET icnt += 1
    SET stat = alterlist(billcodeschedulearray->schedulelist,icnt)
    SET billcodeschedulearray->schedulelist[icnt].schedulevalue = billcodeschedule
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getbillitemsforbillcodetype(securitypref=i2,billcodeschedulearray=vc(ref)) =i2)
   DECLARE jcnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT
    IF (securitypref)
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      bill_item b,
      bill_item_modifier bim
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND por.active_ind=true)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=cs26078_bill_item_cd
       AND cor.active_ind=true)
      JOIN (bim
      WHERE expand(idx,1,size(billcodeschedulearray->schedulelist,5),bim.key1_id,
       billcodeschedulearray->schedulelist[idx].schedulevalue)
       AND bim.bill_item_id=cor.key1_id
       AND bim.bill_item_type_cd=cs13019_bill_code_cd
       AND cnvtupper(bim.key6)=patstring(cnvtupper(trim(request->billcodefiltertext,3)))
       AND bim.active_ind=true
       AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (b
      WHERE b.bill_item_id=bim.bill_item_id
       AND b.active_ind=true
       AND b.ext_owner_cd > 0.0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ELSE
     FROM bill_item b,
      bill_item_modifier bim
     PLAN (bim
      WHERE expand(idx,1,size(billcodeschedulearray->schedulelist,5),bim.key1_id,
       billcodeschedulearray->schedulelist[idx].schedulevalue)
       AND bim.bill_item_type_cd=cs13019_bill_code_cd
       AND cnvtupper(bim.key6)=patstring(cnvtupper(trim(request->billcodefiltertext,3)))
       AND bim.active_ind=true
       AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (b
      WHERE b.bill_item_id=bim.bill_item_id
       AND b.bill_item_id > 0.0
       AND b.active_ind=true
       AND b.ext_owner_cd > 0.0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ENDIF
    INTO "nl:"
    ORDER BY b.ext_owner_cd, b.ext_parent_reference_id, b.bill_item_id,
     b.ext_child_reference_id
    HEAD b.bill_item_id
     jcnt += 1, stat = alterlist(tempbillitems->billitemqual,jcnt), tempbillitems->billitemqual[jcnt]
     .bill_item_id = b.bill_item_id,
     tempbillitems->billitemqual[jcnt].ext_parent_reference_id = b.ext_parent_reference_id,
     tempbillitems->billitemqual[jcnt].ext_child_reference_id = b.ext_child_reference_id
    WITH nocounter
   ;end select
   IF (trim(request->billcodetypefilter)="ASA"
    AND securitypref)
    SELECT INTO "nl:"
     FROM bill_item b,
      bill_item_modifier bim
     PLAN (bim
      WHERE expand(idx,1,size(billcodeschedulearray->schedulelist,5),bim.key1_id,
       billcodeschedulearray->schedulelist[idx].schedulevalue)
       AND bim.bill_item_type_cd=cs13019_bill_code_cd
       AND cnvtupper(bim.key6)=patstring(cnvtupper(trim(request->billcodefiltertext,3)))
       AND bim.active_ind=true
       AND bim.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (b
      WHERE b.bill_item_id=bim.bill_item_id
       AND b.bill_item_id > 0.0
       AND b.active_ind=true
       AND b.ext_owner_cd > 0.0
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
     ORDER BY b.ext_owner_cd, b.ext_parent_reference_id, b.bill_item_id,
      b.ext_child_reference_id
     HEAD b.bill_item_id
      jcnt += 1, stat = alterlist(tempbillitems->billitemqual,jcnt), tempbillitems->billitemqual[jcnt
      ].bill_item_id = b.bill_item_id,
      tempbillitems->billitemqual[jcnt].ext_parent_reference_id = b.ext_parent_reference_id,
      tempbillitems->billitemqual[jcnt].ext_child_reference_id = b.ext_child_reference_id
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0
    AND jcnt=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getparentfororphanchild(dummy)
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SET acnt = size(tempbillitems->billitemqual,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(tempbillitems->billitemqual,5)),
     bill_item bi
    PLAN (d
     WHERE (tempbillitems->billitemqual[d.seq].ext_child_reference_id != 0.0)
      AND (tempbillitems->billitemqual[d.seq].ext_parent_reference_id != 0.0))
     JOIN (bi
     WHERE (bi.ext_parent_reference_id=tempbillitems->billitemqual[d.seq].ext_parent_reference_id)
      AND bi.ext_child_reference_id=0.0
      AND bi.active_ind=1)
    DETAIL
     ipos = locateval(num,1,size(tempbillitems->billitemqual,5),bi.bill_item_id,tempbillitems->
      billitemqual[num].bill_item_id)
     IF (ipos < 1)
      acnt += 1, stat = alterlist(tempbillitems->billitemqual,acnt), tempbillitems->billitemqual[acnt
      ].bill_item_id = bi.bill_item_id,
      tempbillitems->billitemqual[acnt].ext_parent_reference_id = 0.0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE fillreply(dummy)
   DECLARE icnt = i4
   DECLARE jcnt = i4
   SELECT INTO "nl:"
    FROM bill_item b,
     (dummyt d  WITH seq = size(tempbillitems->billitemqual,5))
    PLAN (d)
     JOIN (b
     WHERE (b.bill_item_id=tempbillitems->billitemqual[d.seq].bill_item_id))
    ORDER BY b.ext_owner_cd, b.ext_parent_reference_id, b.bill_item_id,
     b.ext_child_reference_id
    HEAD b.ext_owner_cd
     icnt += 1, stat = alterlist(reply->activityqual,icnt), reply->activityqual[icnt].activitycd = b
     .ext_owner_cd,
     reply->activityqual[icnt].activitydisplay = uar_get_code_display(b.ext_owner_cd), jcnt = 0
    HEAD b.bill_item_id
     jcnt += 1, stat = alterlist(reply->activityqual[icnt].billitemqual,jcnt)
     IF ((tempbillitems->billitemqual[d.seq].ext_parent_reference_id=0.0))
      reply->activityqual[icnt].billitemqual[jcnt].isparentfororphan = true
     ELSE
      reply->activityqual[icnt].billitemqual[jcnt].isparentfororphan = false
     ENDIF
     reply->activityqual[icnt].billitemqual[jcnt].bill_item_id = b.bill_item_id, reply->activityqual[
     icnt].billitemqual[jcnt].ext_owner_cd = b.ext_owner_cd, reply->activityqual[icnt].billitemqual[
     jcnt].ext_owner_disp = uar_get_code_display(b.ext_owner_cd),
     msstat = assign(validate(reply->activityqual[icnt].billitemqual[jcnt].ext_sub_owner_cd,0.0),b
      .ext_sub_owner_cd), reply->activityqual[icnt].billitemqual[jcnt].ext_sub_owner_disp =
     uar_get_code_display(b.ext_sub_owner_cd), reply->activityqual[icnt].billitemqual[jcnt].
     ext_parent_reference_id = b.ext_parent_reference_id,
     reply->activityqual[icnt].billitemqual[jcnt].ext_parent_contributor_cd = b
     .ext_parent_contributor_cd, reply->activityqual[icnt].billitemqual[jcnt].
     ext_parent_contributor_disp = uar_get_code_display(b.ext_parent_contributor_cd), reply->
     activityqual[icnt].billitemqual[jcnt].ext_child_reference_id = b.ext_child_reference_id,
     reply->activityqual[icnt].billitemqual[jcnt].ext_child_contributor_cd = b
     .ext_child_contributor_cd, reply->activityqual[icnt].billitemqual[jcnt].
     ext_child_contributor_disp = uar_get_code_display(b.ext_child_contributor_cd)
     IF (trim(b.ext_description)=" ")
      reply->activityqual[icnt].billitemqual[jcnt].ext_description = "BLANK"
     ELSE
      reply->activityqual[icnt].billitemqual[jcnt].ext_description = trim(b.ext_description)
     ENDIF
     reply->activityqual[icnt].billitemqual[jcnt].ext_short_desc = trim(b.ext_short_desc), reply->
     activityqual[icnt].billitemqual[jcnt].misc_ind = b.misc_ind, reply->activityqual[icnt].
     billitemqual[jcnt].stats_only_ind = b.stats_only_ind,
     reply->activityqual[icnt].billitemqual[jcnt].workload_only_ind = b.workload_only_ind, reply->
     activityqual[icnt].billitemqual[jcnt].late_chrg_excl_ind = b.late_chrg_excl_ind
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (logcapabilityauditevent(d=i2) =null)
   CALL logmessage("logCapabilityAuditEvent","Entering",log_debug)
   IF ( NOT (validate(entity_type_bill_code_schedule)))
    DECLARE entity_type_bill_code_schedule = vc WITH constant("BILL_CODE_SCHEDULE")
   ENDIF
   FREE RECORD capabilityauditrequest
   RECORD capabilityauditrequest(
     1 capability_ident = vc
     1 entities[*]
       2 entity_id = f8
       2 entity_name = vc
   )
   FREE RECORD capabilityauditreply
   RECORD capabilityauditreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET capabilityauditrequest->capability_ident = "2010.2.00200.1"
   SET stat = alterlist(capabilityauditrequest->entities,1)
   SET capabilityauditrequest->entities[1].entity_id = request->billcodeschedule
   SET capabilityauditrequest->entities[1].entity_name = entity_type_bill_code_schedule
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilityauditrequest), replace(
    "REPLY",capabilityauditreply)
   CALL logmessage("logCapabilityAuditEvent","Exiting",log_debug)
   RETURN
 END ;Subroutine
#exit_script
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(billcodeschedules)
  CALL echorecord(reply)
 ENDIF
END GO
