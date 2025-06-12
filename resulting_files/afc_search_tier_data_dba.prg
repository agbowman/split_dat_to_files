CREATE PROGRAM afc_search_tier_data:dba
 DECLARE afc_search_tier_data_version = vc WITH private, noconstant("483540.FT.004")
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
 FREE SET reply
 RECORD reply(
   1 results_qual = i4
   1 results[*]
     2 result_type = i2
     2 result_string = vc
     2 result_code = f8
     2 result_meaning = vc
     2 result_auth = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE bfound = i2 WITH public, noconstant(0)
 DECLARE lloopcnt = i4 WITH public, noconstant(0)
 DECLARE whereparser = vc WITH public, noconstant("")
 DECLARE dauthcode = f8 WITH public, noconstant(0.0)
 DECLARE dclientcode = f8 WITH public, noconstant(0.0)
 DECLARE dinscode = f8 WITH public, noconstant(0.0)
 DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
 IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
  CALL logmessage("getLogicalDomain","Failed to retrieve logical domain ID...",log_error)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,dauthcode)
 SET stat = uar_get_meaning_by_codeset(278,"CLIENT",1,dclientcode)
 SET stat = uar_get_meaning_by_codeset(278,"INSCO",1,dinscode)
 SET reply->status_data.status = "F"
 IF ((request->search_qual <= 0))
  SET reply->status_data.status = "Z"
  GO TO end_program
 ENDIF
 IF ((request->search_mode=1))
  SET request->search_qual = 1
 ENDIF
 FOR (lloopcnt = 1 TO request->search_qual)
   SET bfound = 0
   IF ((request->search[lloopcnt].flex_search_type=1))
    IF ((request->search_mode=1))
     SET whereparser = concat("o.data_status_cd+0 = ",cnvtstring(dauthcode,17,2))
     SET whereparser = concat(whereparser,' AND o.org_name_key = "')
     SET whereparser = concat(whereparser,trim(cnvtupper(cnvtalphanum(request->search[lloopcnt].
         flex_search_data))),'*"')
    ELSE
     SET whereparser = concat("o.organization_id = ",request->search[lloopcnt].flex_search_data)
    ENDIF
    SELECT INTO "nl:"
     FROM organization o,
      org_type_reltn otr
     PLAN (o
      WHERE parser(whereparser)
       AND ((o.active_ind+ 0)=1)
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND o.logical_domain_id=organizationlogicaldomainid)
      JOIN (otr
      WHERE (otr.organization_id=(o.organization_id+ 0))
       AND ((otr.org_type_cd+ 0)=dclientcode)
       AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY o.org_name
     DETAIL
      reply->results_qual += 1, stat = alterlist(reply->results,reply->results_qual), bfound = 1,
      reply->results[reply->results_qual].result_type = request->search[lloopcnt].flex_search_type,
      reply->results[reply->results_qual].result_code = o.organization_id, reply->results[reply->
      results_qual].result_string = o.org_name,
      reply->results[reply->results_qual].result_auth = o.data_status_cd, reply->results[reply->
      results_qual].active_ind = o.active_ind
     WITH nocounter
    ;end select
   ELSEIF ((request->search[lloopcnt].flex_search_type=4))
    IF ((request->search_mode=1))
     SET whereparser = concat("o.data_status_cd+0 = ",cnvtstring(dauthcode,17,2))
     SET whereparser = concat(whereparser,' AND o.org_name_key = "')
     SET whereparser = concat(whereparser,trim(cnvtupper(cnvtalphanum(request->search[lloopcnt].
         flex_search_data))),'*"')
    ELSE
     SET whereparser = concat("o.organization_id = ",request->search[lloopcnt].flex_search_data)
    ENDIF
    SELECT INTO "nl:"
     FROM organization o,
      org_type_reltn otr
     PLAN (o
      WHERE parser(whereparser)
       AND ((o.active_ind+ 0)=1)
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND o.logical_domain_id=organizationlogicaldomainid)
      JOIN (otr
      WHERE (otr.organization_id=(o.organization_id+ 0))
       AND ((otr.org_type_cd+ 0)=dinscode)
       AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY cnvtupper(cnvtalphanum(o.org_name))
     DETAIL
      reply->results_qual += 1, stat = alterlist(reply->results,reply->results_qual), bfound = 1,
      reply->results[reply->results_qual].result_type = request->search[lloopcnt].flex_search_type,
      reply->results[reply->results_qual].result_code = o.organization_id, reply->results[reply->
      results_qual].result_string = o.org_name,
      reply->results[reply->results_qual].result_auth = o.data_status_cd, reply->results[reply->
      results_qual].active_ind = o.active_ind
     WITH nocounter
    ;end select
   ELSEIF ((request->search[lloopcnt].flex_search_type=2))
    IF ((request->search_mode=1))
     SET whereparser = concat("h.data_status_cd+0 = ",cnvtstring(dauthcode,17,2))
     SET whereparser = concat(whereparser,' AND h.plan_name_key = "')
     SET whereparser = concat(whereparser,trim(cnvtupper(cnvtalphanum(request->search[lloopcnt].
         flex_search_data))),'*"')
    ELSE
     SET whereparser = concat("h.health_plan_id = ",request->search[lloopcnt].flex_search_data)
    ENDIF
    SELECT INTO "nl:"
     FROM health_plan h
     WHERE parser(whereparser)
      AND ((h.active_ind+ 0)=1)
     ORDER BY h.plan_name
     DETAIL
      reply->results_qual += 1, stat = alterlist(reply->results,reply->results_qual), bfound = 1,
      reply->results[reply->results_qual].result_type = request->search[lloopcnt].flex_search_type,
      reply->results[reply->results_qual].result_code = h.health_plan_id, reply->results[reply->
      results_qual].result_string = h.plan_name,
      reply->results[reply->results_qual].result_auth = h.data_status_cd, reply->results[reply->
      results_qual].active_ind = h.active_ind
     WITH nocounter
    ;end select
   ELSEIF ((request->search[lloopcnt].flex_search_type=3))
    SET whereparser = concat("c.code_set = ",cnvtstring(request->search[lloopcnt].flex_code_set))
    IF ((request->search_mode=1))
     SET whereparser = concat(whereparser," AND c.data_status_cd+0 = ",cnvtstring(dauthcode,17,2))
     SET whereparser = concat(whereparser,' AND c.display_key = "')
     SET whereparser = concat(whereparser,trim(cnvtupper(cnvtalphanum(request->search[lloopcnt].
         flex_search_data))),'*"')
     IF (trim(request->search[lloopcnt].flex_cdf_meaning) != "")
      SET whereparser = concat(whereparser," AND trim(c.cdf_meaning) IN (")
      SET whereparser = concat(whereparser,trim(request->search[lloopcnt].flex_cdf_meaning),")")
     ENDIF
    ELSE
     SET whereparser = concat(whereparser," AND c.code_value = ",cnvtstring(request->search[lloopcnt]
       .flex_search_data,17,2))
    ENDIF
    SELECT INTO "nl:"
     FROM code_value c
     WHERE parser(whereparser)
      AND ((c.active_ind+ 0)=1)
     ORDER BY c.display
     DETAIL
      reply->results_qual += 1, stat = alterlist(reply->results,reply->results_qual), bfound = 1,
      reply->results[reply->results_qual].result_type = request->search[lloopcnt].flex_search_type,
      reply->results[reply->results_qual].result_code = c.code_value, reply->results[reply->
      results_qual].result_string = c.display,
      reply->results[reply->results_qual].result_auth = c.data_status_cd, reply->results[reply->
      results_qual].result_meaning = c.cdf_meaning, reply->results[reply->results_qual].active_ind =
      c.active_ind
     WITH nocounter
    ;end select
   ENDIF
   IF (bfound=0
    AND (request->search_mode=2))
    SET reply->results_qual += 1
    SET stat = alterlist(reply->results,reply->results_qual)
    SET reply->results[reply->results_qual].result_type = request->search[lloopcnt].flex_search_type
    SET reply->results[reply->results_qual].result_code = 0.0
    SET reply->results[reply->results_qual].result_string = "NOTbFound"
    SET reply->results[reply->results_qual].result_auth = 0.0
    SET reply->results[reply->results_qual].active_ind = 0
   ENDIF
 ENDFOR
#end_program
 SET reply->status_data.status = "S"
 IF ((reply->results_qual <= 0))
  SET reply->status_data.status = "Z"
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
END GO
