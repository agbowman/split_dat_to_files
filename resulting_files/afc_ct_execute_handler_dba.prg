CREATE PROGRAM afc_ct_execute_handler:dba
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
 IF ( NOT (validate(csfacilitylist->facilities)))
  RECORD csfacilitylist(
    1 facilities[*]
      2 organizationid = f8
      2 timezoneindex = i4
      2 logicaldomainid = f8
  )
  SET stat = initializecsfacilitytimezone(null)
 ENDIF
 IF (validate(initializecsfacilitytimezone,char(128))=char(128))
  DECLARE initializecsfacilitytimezone(null) = null
  SUBROUTINE initializecsfacilitytimezone(null)
    CALL logmessage("initializeCsFacilityTimeZone","Entering...",log_debug)
    DECLARE cs222_facility_cd = f8 WITH noconstant(uar_get_code_by("MEANING",222,"FACILITY")),
    protect
    DECLARE facilitycount = i4 WITH noconstant(0), protect
    SELECT INTO "nl:"
     FROM organization o,
      location l,
      time_zone_r tzr
     PLAN (o
      WHERE o.organization_id > 0.0
       AND o.active_ind=1)
      JOIN (l
      WHERE l.organization_id=o.organization_id
       AND l.location_type_cd=cs222_facility_cd
       AND l.active_ind=1
       AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (tzr
      WHERE (tzr.parent_entity_id= Outerjoin(l.location_cd))
       AND (tzr.parent_entity_name= Outerjoin("LOCATION")) )
     ORDER BY o.organization_id
     HEAD o.organization_id
      facilitycount += 1, stat = alterlist(csfacilitylist->facilities,facilitycount), csfacilitylist
      ->facilities[facilitycount].organizationid = o.organization_id
      IF (tzr.parent_entity_id != 0.0)
       csfacilitylist->facilities[facilitycount].timezoneindex = datetimezonebyname(tzr.time_zone)
      ELSE
       csfacilitylist->facilities[facilitycount].timezoneindex = curtimezoneapp
      ENDIF
      csfacilitylist->facilities[facilitycount].logicaldomainid = o.logical_domain_id
     WITH nocounter
    ;end select
    CALL logmessage("initializeCsFacilityTimeZone","Exiting...",log_debug)
    IF (validate(debug))
     CALL echorecord(csfacilitylist)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getcsfacilitytimezoneidx,char(128))=char(128))
  SUBROUTINE (getcsfacilitytimezoneidx(porganizationid=f8) =i4)
    CALL logmessage("getCsFacilityTimeZoneIdx","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, noconstant(0)
    DECLARE facilitypos = i4 WITH protect, noconstant(0)
    DECLARE facilitylidx = i4 WITH protect, noconstant(0)
    IF (porganizationid <= 0.0)
     SET timezoneindex = curtimezoneapp
    ELSE
     SET facilitypos = locatevalsort(facilitylidx,1,size(csfacilitylist->facilities,5),
      porganizationid,csfacilitylist->facilities[facilitylidx].organizationid)
     IF (facilitypos > 0)
      SET timezoneindex = csfacilitylist->facilities[facilitypos].timezoneindex
     ELSE
      SET timezoneindex = curtimezoneapp
     ENDIF
    ENDIF
    CALL logmessage("getCsFacilityTimeZoneIdx","Exiting...",log_debug)
    RETURN(timezoneindex)
  END ;Subroutine
 ENDIF
 IF (validate(getcsfacilitybeginningofday,char(128))=char(128))
  SUBROUTINE (getcsfacilitybeginningofday(porganizationid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCsFacilityBeginningOfDay","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcsfacilitytimezoneidx(porganizationid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    IF (calcfacilitydate != chargeservicedate)
     SET calcfacilitydate = chargeservicedate
    ENDIF
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(calcfacilitydate),0),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCsFacilityBeginningOfDay","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcsfacilityendofday,char(128))=char(128))
  SUBROUTINE (getcsfacilityendofday(porganizationid=f8,pdatetimeutc=dq8) =dq8)
    CALL logmessage("getCsFacilityEndOfDay","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcsfacilitytimezoneidx(porganizationid))
    DECLARE intdate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect
    SET facilitydate = cnvtdatetimeutc(pdatetimeutc,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET intdate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate),"##;P0"
       ),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(intdate),235959),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCsFacilityEndOfDay","Exiting...",log_debug)
    RETURN(facilitydate)
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
 CALL echo("Begin including PFT_SYSTEM_ACTIVITY_LOG_SUBS.INC version [664227.024]")
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
 IF ( NOT (validate(cs23372_comp_wo_err_cd)))
  DECLARE cs23372_comp_wo_err_cd = f8 WITH protect, constant(getcodevalue(23372,"COMP WO ERR",2))
 ENDIF
 IF ( NOT (validate(cs23372_failed_cd)))
  DECLARE cs23372_failed_cd = f8 WITH protect, constant(getcodevalue(23372,"FAILED",2))
 ENDIF
 IF ( NOT (validate(claim_sys_log)))
  DECLARE claim_sys_log = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(statement_sys_log)))
  DECLARE statement_sys_log = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(entity_balance_sys_log)))
  DECLARE entity_balance_sys_log = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(entity_insurance_sys_log)))
  DECLARE entity_insurance_sys_log = vc WITH protect, constant("INSURANCE")
 ENDIF
 IF ( NOT (validate(entity_selfpay_sys_log)))
  DECLARE entity_selfpay_sys_log = vc WITH protect, constant("SELFPAY")
 ENDIF
 IF ( NOT (validate(pftencntr_sys_log)))
  DECLARE pftencntr_sys_log = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(encounter_sys_log)))
  DECLARE encounter_sys_log = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(bill_rec_sys_log)))
  DECLARE bill_rec_sys_log = vc WITH protect, constant("BILL_REC")
 ENDIF
 IF ( NOT (validate(bo_hp_reltn_sys_log)))
  DECLARE bo_hp_reltn_sys_log = vc WITH protect, constant("BO_HP_RELTN")
 ENDIF
 IF ( NOT (validate(pft_encntr_sys_log)))
  DECLARE pft_encntr_sys_log = vc WITH protect, constant("PFT_ENCNTR")
 ENDIF
 IF ( NOT (validate(charge_sys_log)))
  DECLARE charge_sys_log = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(pft_trans_sys_log)))
  DECLARE pft_trans_sys_log = vc WITH protect, constant("PFT_TRANS_LOG")
 ENDIF
 IF ( NOT (validate(batch_trans_sys_log)))
  DECLARE batch_trans_sys_log = vc WITH protect, constant("BATCH_TRANS")
 ENDIF
 IF ( NOT (validate(entity_trans_sys_log)))
  DECLARE entity_trans_sys_log = vc WITH protect, constant("TRANS_LOG")
 ENDIF
 IF ( NOT (validate(entity_account_sys_log)))
  DECLARE entity_account_sys_log = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_person_sys_log)))
  DECLARE entity_person_sys_log = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(entity_sch_event_sys_log)))
  DECLARE entity_sch_event_sys_log = vc WITH protect, constant("SCH_EVENT")
 ENDIF
 IF ( NOT (validate(entity_billing_entity_sys_log)))
  DECLARE entity_billing_entity_sys_log = vc WITH protect, constant("BILLING_ENTITY")
 ENDIF
 IF ( NOT (validate(batch_trans_file_sys_log)))
  DECLARE batch_trans_file_sys_log = vc WITH protect, constant("BATCH_TRANS_FILE")
 ENDIF
 IF ( NOT (validate(workflow_task_queue_hist_sys_log)))
  DECLARE workflow_task_queue_hist_sys_log = vc WITH protect, constant("WORKFLOW_TASK_QUEUE_HIST")
 ENDIF
 IF ( NOT (validate(pft_charge_sys_log)))
  DECLARE pft_charge_sys_log = vc WITH protect, constant("PFT_CHARGE")
 ENDIF
 IF ( NOT (validate(entity_sch_entry_sys_log)))
  DECLARE entity_sch_entry_sys_log = vc WITH protect, constant("SCH_ENTRY")
 ENDIF
 IF ( NOT (validate(pft_system_activity_log_subs)))
  DECLARE pft_system_activity_log_subs = vc WITH protect, constant("PFT_SYSTEM_ACTIVITY_LOG_SUBS")
 ENDIF
 IF ( NOT (validate(dm_info_domain_file_log)))
  DECLARE dm_info_domain_file_log = vc WITH protect, constant("PATIENT_ACCOUNTING_FILE_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_char_file_log)))
  DECLARE dm_info_char_file_log = vc WITH protect, constant("OPT_IN_FILE_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_domain_msgview_log)))
  DECLARE dm_info_domain_msgview_log = vc WITH protect, constant("PATIENT_ACCOUNTING_MSGVIEW_LOGGING"
   )
 ENDIF
 IF ( NOT (validate(dm_info_char_msgview_log)))
  DECLARE dm_info_char_msgview_log = vc WITH protect, constant("OPT_IN_MSGVIEW_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_domain_table_log)))
  DECLARE dm_info_domain_table_log = vc WITH protect, constant("PATIENT_ACCOUNTING_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_char_table_log)))
  DECLARE dm_info_char_table_log = vc WITH protect, constant(
   "OPT_IN_LOGGING_FRAMEWORK_FOR_PATIENT_ACCOUNTING")
 ENDIF
 IF ( NOT (validate(log_system_activity_sub)))
  DECLARE log_system_activity_sub = vc WITH protect, constant("LogSystemActivity")
 ENDIF
 IF ( NOT (validate(base_log_file_name)))
  DECLARE base_log_file_name = vc WITH protect, constant(concat("SysAct_",trim(curprcname,3),"_"))
 ENDIF
 IF ( NOT (validate(max_file_size_in_bytes)))
  DECLARE max_file_size_in_bytes = f8 WITH protect, constant(100000000.0)
 ENDIF
 IF ( NOT (validate(max_msgview_file_name_size)))
  DECLARE max_msgview_file_name_size = f8 WITH protect, constant(31.0)
 ENDIF
 IF ( NOT (validate(script_level_timer)))
  DECLARE script_level_timer = f8 WITH protect, constant(1.0)
 ENDIF
 IF ( NOT (validate(script_and_detail_level_timer)))
  DECLARE script_and_detail_level_timer = f8 WITH protect, constant(2.0)
 ENDIF
 IF ( NOT (validate(main_select_timer_string)))
  DECLARE main_select_timer_string = vc WITH protect, constant("MAIN_SELECT_TIMER_STRING")
 ENDIF
 IF ( NOT (validate(tens_of_millisecs)))
  DECLARE tens_of_millisecs = i2 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(sysactlog)))
  RECORD sysactlog(
    1 finalstatuscd = f8
    1 entityname = vc
    1 entityid = f8
    1 taskname = vc
    1 completionmsg = vc
    1 logicaldomainid = f8
    1 locfacilitycd = f8
    1 organizationid = f8
    1 startdttm = dm12
    1 enddttm = dm12
    1 encntrid = f8
    1 personid = f8
    1 pfteventoccurlogid = f8
    1 currentnodename = vc
    1 servername = vc
    1 executiondurationsecs = f8
    1 timeridentifier = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(cachedtasks)))
  RECORD cachedtasks(
    1 task[*]
      2 taskname = vc
      2 tableloglevel = f8
      2 fileloglevel = f8
      2 msgviewloglevel = f8
      2 logicaldomainid = f8
  ) WITH protect
 ENDIF
 DECLARE sysactlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE sysactlogicaldomainind = i2 WITH protect, noconstant(false)
 IF (validate(getfilesize,char(128))=char(128))
  SUBROUTINE (getfilesize(pfilename=vc) =f8)
    DECLARE filesize = f8 WITH protect, noconstant(0.0)
    RECORD frec(
      1 file_desc = i4
      1 file_offset = i4
      1 file_dir = i4
      1 file_name = vc
      1 file_buf = vc
    ) WITH protect
    SET frec->file_name = pfilename
    SET frec->file_buf = "r"
    SET stat = cclio("OPEN",frec)
    SET frec->file_dir = 2
    SET frec->file_offset = 0
    SET stat = cclio("SEEK",frec)
    SET filesize = cclio("TELL",frec)
    RETURN(filesize)
  END ;Subroutine
 ENDIF
 IF (validate(transcribetofile,char(128))=char(128))
  SUBROUTINE (transcribetofile(pfilename=vc,pcontent=gvc,pmode=vc) =i2)
    RECORD frec(
      1 file_desc = i4
      1 file_offset = i4
      1 file_dir = i4
      1 file_name = vc
      1 file_buf = vc
    ) WITH protect
    SET frec->file_name = pfilename
    SET frec->file_buf = pmode
    SET stat = cclio("OPEN",frec)
    SET frec->file_buf = pcontent
    SET stat = cclio("WRITE",frec)
    SET stat = cclio("CLOSE",frec)
    RETURN(stat)
  END ;Subroutine
 ENDIF
 IF (validate(logsystemactivity,char(128))=char(128))
  SUBROUTINE (logsystemactivity(pstarttime=dm12,ptaskname=vc,pentityname=vc,pentityid=f8,pstatus=c1,
   pmessage=vc,plogtimer=f8(value,script_level_timer),ptimerident=vc(value,"")) =null)
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    DECLARE cacheidx = i4 WITH protect, noconstant(0)
    DECLARE cachecnt = i4 WITH protect, noconstant(0)
    DECLARE cachefound = i4 WITH protect, noconstant(0)
    DECLARE queriedind = i2 WITH protect, noconstant(true)
    DECLARE logfilemsg = vc WITH protect, noconstant("")
    DECLARE logfilename = vc WITH protect, noconstant("")
    DECLARE logfilenum = i4 WITH protect, noconstant(0)
    DECLARE logfilesize = f8 WITH protect, noconstant(max_file_size_in_bytes)
    DECLARE loggedmsgind = i2 WITH protect, noconstant(false)
    DECLARE logactivitytofile = i2 WITH protect, noconstant(false)
    DECLARE logactivitytotable = i2 WITH protect, noconstant(false)
    DECLARE logactivitytomsgview = i2 WITH protect, noconstant(false)
    DECLARE msgloglevel = i4 WITH protect, noconstant(0)
    DECLARE msghandle = i4 WITH protect, noconstant(0)
    DECLARE msglogevent = vc WITH protect, noconstant("")
    DECLARE msgfilename = vc WITH protect, noconstant("")
    SET stat = initrec(sysactlog)
    SET ptaskname = cnvtupper(ptaskname)
    SET cachecnt = size(cachedtasks->task,5)
    SET sysactlog->startdttm = pstarttime
    SET sysactlog->enddttm = systimestamp
    SET sysactlog->executiondurationsecs = timestampdiff(sysactlog->enddttm,sysactlog->startdttm)
    SET sysactlog->taskname = ptaskname
    SET sysactlog->entityid = pentityid
    SET sysactlog->completionmsg = pmessage
    SET sysactlog->currentnodename = curnode
    SET sysactlog->servername = build(curserver)
    SET sysactlog->timeridentifier = trim(ptimerident,3)
    IF ( NOT (sysactlogicaldomainind))
     CALL getlogicaldomain(ld_concept_person,sysactlogicaldomainid)
     SET sysactlogicaldomainind = true
    ENDIF
    SET cachefound = locateval(cacheidx,1,cachecnt,ptaskname,cachedtasks->task[cacheidx].taskname,
     sysactlogicaldomainid,cachedtasks->task[cacheidx].logicaldomainid)
    IF (cachefound=0)
     SET cachecnt += 1
     SET cachefound = cachecnt
     SET stat = alterlist(cachedtasks->task,cachecnt)
     SET cachedtasks->task[cachecnt].taskname = ptaskname
     SET cachedtasks->task[cachecnt].logicaldomainid = sysactlogicaldomainid
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name=ptaskname
       AND di.info_domain_id=sysactlogicaldomainid
       AND ((di.info_domain=dm_info_domain_table_log
       AND di.info_char=dm_info_char_table_log) OR (((di.info_domain=dm_info_domain_file_log
       AND di.info_char=dm_info_char_file_log) OR (di.info_domain=dm_info_domain_msgview_log
       AND di.info_char=dm_info_char_msgview_log)) ))
      DETAIL
       IF (di.info_domain=dm_info_domain_table_log)
        cachedtasks->task[cachecnt].tableloglevel = di.info_number
       ELSEIF (di.info_domain=dm_info_domain_file_log)
        cachedtasks->task[cachecnt].fileloglevel = di.info_number
       ELSEIF (di.info_domain=dm_info_domain_msgview_log)
        cachedtasks->task[cachecnt].msgviewloglevel = di.info_number
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF ((cachedtasks->task[cachefound].tableloglevel >= plogtimer))
     SET logactivitytotable = true
    ENDIF
    IF ((cachedtasks->task[cachefound].fileloglevel >= plogtimer))
     SET logactivitytofile = true
    ENDIF
    IF ((cachedtasks->task[cachefound].msgviewloglevel >= plogtimer))
     SET logactivitytomsgview = true
    ENDIF
    IF (((logactivitytotable) OR (((logactivitytofile) OR (logactivitytomsgview)) )) )
     CASE (pstatus)
      OF "S":
       SET sysactlog->finalstatuscd = cs23372_comp_wo_err_cd
       SET msgloglevel = log_info
       SET msglogevent = "Script success"
      OF "F":
       SET sysactlog->finalstatuscd = cs23372_failed_cd
       SET msgloglevel = log_error
       SET msglogevent = "Script failure"
      ELSE
       SET sysactlog->finalstatuscd = 0.0
       SET msgloglevel = log_warning
       SET msglogevent = "No data"
     ENDCASE
     CASE (pentityname)
      OF claim_sys_log:
      OF statement_sys_log:
      OF bill_rec_sys_log:
       SET sysactlog->entityname = bill_rec_sys_log
      OF entity_balance_sys_log:
      OF entity_insurance_sys_log:
      OF entity_selfpay_sys_log:
      OF bo_hp_reltn_sys_log:
       SET sysactlog->entityname = bo_hp_reltn_sys_log
      OF pftencntr_sys_log:
      OF pft_encntr_sys_log:
       SET sysactlog->entityname = pft_encntr_sys_log
      OF encounter_sys_log:
       IF (pentityid > 0.0)
        SET sysactlog->entityname = encounter_sys_log
       ELSE
        SET sysactlog->entityname = pft_encntr_sys_log
       ENDIF
      OF charge_sys_log:
       SET sysactlog->entityname = charge_sys_log
      OF batch_trans_sys_log:
       SET sysactlog->entityname = batch_trans_sys_log
      OF entity_trans_sys_log:
       SET sysactlog->entityname = entity_trans_sys_log
      OF entity_account_sys_log:
       SET sysactlog->entityname = entity_account_sys_log
      OF entity_person_sys_log:
       SET sysactlog->entityname = entity_person_sys_log
      OF entity_sch_event_sys_log:
       SET sysactlog->entityname = entity_sch_event_sys_log
      OF entity_sch_entry_sys_log:
       SET sysactlog->entityname = entity_sch_entry_sys_log
      OF entity_billing_entity_sys_log:
       SET sysactlog->entityname = entity_billing_entity_sys_log
      OF batch_trans_file_sys_log:
       SET sysactlog->entityname = batch_trans_file_sys_log
      OF workflow_task_queue_hist_sys_log:
       SET sysactlog->entityname = workflow_task_queue_hist_sys_log
      OF pft_charge_sys_log:
       SET sysactlog->entityname = pft_charge_sys_log
      ELSE
       SET sysactlog->entityname = ""
     ENDCASE
     IF (pentityid > 0.0)
      CASE (sysactlog->entityname)
       OF bill_rec_sys_log:
        SELECT INTO "nl:"
         FROM bill_rec br,
          bill_reltn brn,
          bo_hp_reltn bhr,
          benefit_order bo,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (br
          WHERE br.corsp_activity_id=pentityid
           AND br.active_ind=true)
          JOIN (brn
          WHERE brn.corsp_activity_id=br.corsp_activity_id
           AND brn.parent_entity_name=bo_hp_reltn_sys_log
           AND brn.active_ind=true)
          JOIN (bhr
          WHERE bhr.bo_hp_reltn_id=brn.parent_entity_id
           AND bhr.active_ind=true)
          JOIN (bo
          WHERE bo.benefit_order_id=bhr.benefit_order_id
           AND bo.active_ind=true)
          JOIN (pe
          WHERE pe.pft_encntr_id=bo.pft_encntr_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY br.corsp_activity_id
         HEAD br.corsp_activity_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
        IF (curqual=0)
         SELECT INTO "nl:"
          FROM pft_pending_bill ppb,
           pft_encntr pe,
           encounter e,
           person p
          PLAN (ppb
           WHERE ppb.corsp_activity_id=pentityid)
           JOIN (pe
           WHERE pe.pft_encntr_id=ppb.pft_encntr_id
            AND pe.active_ind=true)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id
            AND e.active_ind=true)
           JOIN (p
           WHERE p.person_id=e.person_id
            AND p.active_ind=true)
          ORDER BY ppb.corsp_activity_id
          HEAD ppb.corsp_activity_id
           sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
           sysactlog->encntrid = e.encntr_id,
           sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e
           .organization_id
          WITH nocounter
         ;end select
        ENDIF
       OF bo_hp_reltn_sys_log:
        SELECT INTO "nl:"
         FROM bo_hp_reltn bhr,
          benefit_order bo,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (bhr
          WHERE bhr.bo_hp_reltn_id=pentityid)
          JOIN (bo
          WHERE bo.benefit_order_id=bhr.benefit_order_id
           AND bo.active_ind=true)
          JOIN (pe
          WHERE pe.pft_encntr_id=bo.pft_encntr_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY bhr.bo_hp_reltn_id
         HEAD bhr.bo_hp_reltn_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF pft_encntr_sys_log:
        SELECT INTO "nl:"
         FROM pft_encntr pe,
          encounter e,
          person p
         PLAN (pe
          WHERE pe.pft_encntr_id=pentityid
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY pe.encntr_id
         HEAD pe.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF encounter_sys_log:
        SET sysactlog->entityname = pft_encntr_sys_log
        SET sysactlog->entityid = 0.0
        SET sysactlog->encntrid = pentityid
        SELECT INTO "nl:"
         FROM encounter e,
          person p,
          pft_encntr pe
         PLAN (e
          WHERE e.encntr_id=pentityid
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
          JOIN (pe
          WHERE (pe.encntr_id= Outerjoin(e.encntr_id))
           AND (pe.active_ind= Outerjoin(true)) )
         ORDER BY pe.pft_encntr_id, e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->locfacilitycd = e.loc_facility_cd,
          sysactlog->organizationid = e.organization_id, sysactlog->entityid = pe.pft_encntr_id
         WITH nocounter
        ;end select
       OF charge_sys_log:
        SELECT INTO "nl:"
         FROM charge c,
          encounter e,
          person p
         PLAN (c
          WHERE c.charge_item_id=pentityid
           AND c.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=c.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF pft_charge_sys_log:
        SELECT INTO "nl:"
         FROM pft_charge pc,
          charge c,
          encounter e,
          person p
         PLAN (pc
          WHERE pc.pft_charge_id=pentityid
           AND pc.active_ind=true)
          JOIN (c
          WHERE c.charge_item_id=pc.charge_item_id
           AND c.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=c.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF batch_trans_sys_log:
        SELECT INTO "nl:"
         FROM batch_trans bt
         WHERE bt.batch_trans_id=pentityid
         ORDER BY bt.batch_trans_id
         HEAD bt.batch_trans_id
          sysactlog->entityid = bt.batch_trans_id, sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF batch_trans_file_sys_log:
        SELECT INTO "nl:"
         FROM batch_trans_file btf,
          batch_trans bt
         PLAN (btf
          WHERE btf.batch_trans_file_id=pentityid
           AND btf.active_ind=true)
          JOIN (bt
          WHERE bt.batch_trans_id=btf.batch_trans_id
           AND bt.active_ind=true)
         ORDER BY btf.batch_trans_file_id
         HEAD btf.batch_trans_file_id
          sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_trans_sys_log:
        SELECT INTO "nl:"
         FROM trans_log t,
          batch_trans_reltn btr,
          batch_trans bt
         PLAN (t
          WHERE t.activity_id=pentityid
           AND t.active_ind=true)
          JOIN (btr
          WHERE btr.activity_id=t.activity_id
           AND btr.active_ind=true)
          JOIN (bt
          WHERE bt.batch_trans_id=btr.batch_trans_id
           AND bt.active_ind=true)
         ORDER BY t.activity_id
         HEAD t.activity_id
          sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_account_sys_log:
        SELECT INTO "nl:"
         FROM account a,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (a
          WHERE a.acct_id=pentityid
           AND a.active_ind=true)
          JOIN (pe
          WHERE pe.acct_id=a.acct_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY a.acct_id
         HEAD a.acct_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF entity_person_sys_log:
        SELECT INTO "nl:"
         FROM person p
         WHERE p.person_id=pentityid
          AND p.active_ind=true
         ORDER BY p.person_id
         HEAD p.person_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_billing_entity_sys_log:
        SELECT INTO "nl:"
         FROM billing_entity be,
          organization o
         PLAN (be
          WHERE be.billing_entity_id=pentityid
           AND be.active_ind=true)
          JOIN (o
          WHERE o.organization_id=be.organization_id
           AND o.active_ind=true)
         ORDER BY be.billing_entity_id
         HEAD be.billing_entity_id
          sysactlog->logicaldomainid = o.logical_domain_id, sysactlog->organizationid = o
          .organization_id
         WITH nocounter
        ;end select
       OF entity_sch_event_sys_log:
        SELECT INTO "nl:"
         FROM sch_event se,
          sch_appt sa,
          person p
         PLAN (se
          WHERE se.sch_event_id=pentityid
           AND se.active_ind=true)
          JOIN (sa
          WHERE sa.sch_event_id=se.sch_event_id
           AND sa.active_ind=true)
          JOIN (p
          WHERE p.person_id=sa.person_id
           AND p.active_ind=true)
         ORDER BY se.sch_event_id
         HEAD se.sch_event_id
          sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_sch_entry_sys_log:
        SELECT INTO "nl:"
         FROM sch_entry se,
          person p
         PLAN (se
          WHERE se.sch_entry_id=pentityid
           AND se.active_ind=true)
          JOIN (p
          WHERE p.person_id=se.person_id
           AND p.active_ind=true)
         ORDER BY se.sch_entry_id
         HEAD se.sch_entry_id
          sysactlog->logicaldomainid = p.logical_domain_id, sysactlog->entityid = se.sch_entry_id
         WITH nocounter
        ;end select
       OF workflow_task_queue_hist_sys_log:
        SELECT INTO "nl:"
         FROM workflow_task_queue_hist wtqh,
          person p
         PLAN (wtqh
          WHERE wtqh.workflow_task_queue_hist_id=pentityid)
          JOIN (p
          WHERE p.person_id=wtqh.updt_id
           AND p.active_ind=true)
         DETAIL
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       ELSE
        CALL logmessage(log_system_activity_sub,build2("Invalid entity [",pentityname,"]"),
         log_warning)
        SET queriedind = false
      ENDCASE
      IF (queriedind)
       IF (curqual=0)
        CALL logmessage(log_system_activity_sub,build2("No results returned for entity id [",
          pentityid,"]"),log_warning)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (logactivitytotable)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",sysactlog->finalstatuscd)
     SET stat = uar_srvsetstring(hobjarray,"entity_name",nullterm(sysactlog->entityname))
     SET stat = uar_srvsetdouble(hobjarray,"entity_id",sysactlog->entityid)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(sysactlog->taskname))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(sysactlog->completionmsg))
     SET stat = uar_srvsetdouble(hobjarray,"logical_domain_id",sysactlog->logicaldomainid)
     SET stat = uar_srvsetdouble(hobjarray,"loc_facility_cd",sysactlog->locfacilitycd)
     SET stat = uar_srvsetdouble(hobjarray,"organization_id",sysactlog->organizationid)
     SET stat = uar_srvsetdate(hobjarray,"start_dt_tm",cnvtdatetime(sysactlog->startdttm))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysactlog->enddttm))
     SET stat = uar_srvsetdouble(hobjarray,"encntr_id",sysactlog->encntrid)
     SET stat = uar_srvsetdouble(hobjarray,"person_id",sysactlog->personid)
     SET stat = uar_srvsetdouble(hobjarray,"pft_event_occur_log_id",sysactlog->pfteventoccurlogid)
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(sysactlog->currentnodename))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(sysactlog->servername))
     SET stat = uar_srvsetstring(hobjarray,"current_process_name",nullterm(trim(curprcname,3)))
     SET stat = uar_srvsetdouble(hobjarray,"execution_duration_secs",sysactlog->executiondurationsecs
      )
     SET stat = uar_srvsetstring(hobjarray,"timer_ident",nullterm(sysactlog->timeridentifier))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     IF (validate(debug))
      CALL echorecord(sysactlog)
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
    IF (((logactivitytofile) OR (logactivitytomsgview)) )
     SET logfilemsg = build(sysactlog->entityname,"|",cnvtstring(sysactlog->entityid,17,2),"|",
      sysactlog->taskname,
      "|",cnvtstring(sysactlog->finalstatuscd,17,2),"|",sysactlog->completionmsg,"|",
      cnvtstring(sysactlog->personid,17,2),"|",cnvtstring(sysactlog->encntrid,17,2),"|",cnvtstring(
       sysactlog->organizationid,17,2),
      "|",cnvtstring(sysactlog->locfacilitycd,17,2),"|",cnvtstring(sysactlog->logicaldomainid,17,2),
      "|",
      cnvtstring(sysactlog->pfteventoccurlogid,17,2),"|",sysactlog->currentnodename,"|",sysactlog->
      servername,
      "|",trim(curprcname,3),"|",cnvtstring(sysactlog->executiondurationsecs,17,2),"|",
      sysactlog->timeridentifier,"|",format(sysactlog->startdttm,";;Q"),"|",format(sysactlog->enddttm,
       ";;Q"),
      char(13),char(10))
     WHILE (logfilesize >= max_file_size_in_bytes)
       SET logfilenum += 1
       SET msgfilename = concat(base_log_file_name,cnvtstring(logfilenum,11))
       SET logfilename = concat(msgfilename,".txt")
       SET logfilesize = getfilesize(logfilename)
     ENDWHILE
    ENDIF
    IF (logactivitytofile)
     IF (logfilesize=0)
      DECLARE logfileheader = vc WITH protect, noconstant("")
      SET logfileheader = build(
       "ENTITY_NAME|ENTITY_ID|TASK_NAME|FINAL_STATUS_CD|COMPLETION_MSG|PERSON_ID|ENCNTR_ID|",
       "ORGANIZATION_ID|LOC_FACILITY_CD|LOGICAL_DOMAIN_ID|PFT_EVENT_OCCUR_LOG_ID|",
       "CURRENT_NODE_NAME|SERVER_NAME|CURRENT_PROCESS_NAME|EXECUTION_DURATION_SECS|TIMER_IDENT|",
       "START_DT_TM|END_DT_TM",char(13),
       char(10))
      SET loggedmsgind = transcribetofile(logfilename,logfileheader,"a")
     ENDIF
     SET loggedmsgind = transcribetofile(logfilename,logfilemsg,"a")
     IF ( NOT (loggedmsgind))
      CALL logmessage(log_system_activity_sub,concat("Failed to write to file:",logfilename),
       log_warning)
     ENDIF
    ENDIF
    IF (logactivitytomsgview)
     IF (size(msgfilename,1) <= max_msgview_file_name_size)
      EXECUTE msgrtl
      SET msghandle = uar_msgopen(nullterm(msgfilename))
      IF (msghandle != 0)
       CALL uar_msgsetlevel(msghandle,msgloglevel)
       CALL uar_msgwrite(msghandle,0,nullterm(msglogevent),msgloglevel,nullterm(logfilemsg))
       CALL uar_msgclose(msghandle)
      ELSE
       CALL logmessage(log_system_activity_sub,"Failed to write to MsgView. No file handle obtained",
        log_warning)
      ENDIF
     ELSE
      CALL logmessage(log_system_activity_sub,concat("File name ",msgfilename,
        " exceeds 31 character limit"),log_warning)
     ENDIF
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
 IF (validate(getcgfacilitytimezoneidx,char(128))=char(128))
  SUBROUTINE (getcgfacilitytimezoneidx(pbillingentityid=f8) =i4)
    CALL logmessage("getCGFacilityTimeZoneIdx","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, noconstant(curtimezonesys)
    DECLARE cs222_facility_cd = f8 WITH protect, constant(getcodevalue(222,"FACILITY",0))
    SELECT INTO "nl:"
     FROM billing_entity be,
      organization o,
      location l,
      time_zone_r tzr
     PLAN (be
      WHERE be.billing_entity_id=pbillingentityid
       AND be.active_ind=true)
      JOIN (o
      WHERE o.organization_id=be.organization_id
       AND o.active_ind=true)
      JOIN (l
      WHERE l.organization_id=o.organization_id
       AND l.location_type_cd=cs222_facility_cd
       AND l.active_ind=true
       AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (tzr
      WHERE (tzr.parent_entity_id= Outerjoin(l.location_cd))
       AND (tzr.parent_entity_name= Outerjoin("LOCATION")) )
     DETAIL
      IF (tzr.parent_entity_id != 0.0)
       timezoneindex = datetimezonebyname(tzr.time_zone)
      ENDIF
     WITH nocounter
    ;end select
    CALL logmessage("getCGFacilityTimeZoneIdx","Exiting...",log_debug)
    RETURN(timezoneindex)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilitybeginningofday,char(128))=char(128))
  SUBROUTINE (getcgfacilitybeginningofday(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityBeginningOfDay","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(calcfacilitydate),0),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityBeginningOfDay","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilityendofday,char(128))=char(128))
  SUBROUTINE (getcgfacilityendofday(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityEndOfDay","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(calcfacilitydate),235959),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityEndOfDay","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilitybeginningofweek,char(128))=char(128))
  SUBROUTINE (getcgfacilitybeginningofweek(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityBeginningOfWeek","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE serviceweekday = i4 WITH protect, noconstant(0)
    DECLARE servicemonth = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET serviceweekday = weekday(facilitydate)
    SET servicemonth = month(facilitydate)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(cnvtlookbehind(concat(trim(cnvtstring(
           serviceweekday),3),",D"),cnvtdatetime(cnvtdate(calcfacilitydate),0))),0),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    IF (month(facilitydate) != servicemonth)
     SET facilitydate = getcgfacilitybeginningofmonth(pbillingentityid,pdatetime)
    ENDIF
    CALL logmessage("getCGFacilityBeginningOfWeek","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilityendofweek,char(128))=char(128))
  SUBROUTINE (getcgfacilityendofweek(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityEndOfWeek","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE serviceweekday = i4 WITH protect, noconstant(0)
    DECLARE servicemonth = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET serviceweekday = weekday(facilitydate)
    SET servicemonth = month(facilitydate)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(cnvtlookahead(concat(trim(cnvtstring((6
            - serviceweekday)),3),",D"),cnvtdatetime(cnvtdate(calcfacilitydate),0))),235959),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    IF (month(facilitydate) != servicemonth)
     SET facilitydate = getcgfacilityendofmonth(pbillingentityid,pdatetime)
    ENDIF
    CALL logmessage("getCGFacilityEndOfWeek","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilitybeginningofmonth,char(128))=char(128))
  SUBROUTINE (getcgfacilitybeginningofmonth(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityBeginningOfMonth","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE servicemonth = i4 WITH protect, noconstant(0)
    DECLARE serviceyear = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET servicemonth = month(facilitydate)
    SET serviceyear = year(facilitydate)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat(format(servicemonth,"##;P0"),
        format(01,"##;P0"),format(serviceyear,"####;P0")),"MMDDYYYY"),0),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityBeginningOfMonth","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilityendofmonth,char(128))=char(128))
  SUBROUTINE (getcgfacilityendofmonth(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityEndOfMonth","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE servicemonth = i4 WITH protect, noconstant(0)
    DECLARE serviceyear = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET servicemonth = month(facilitydate)
    SET serviceyear = year(facilitydate)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetime(cnvtdate2(concat(format(servicemonth,"##;P0"),format(01,"##;P0"),
       format(serviceyear,"####;P0")),"MMDDYYYY"),0)
    SET facilitydate = cnvtdatetimeutc(cnvtlookbehind("1,S",cnvtlookahead("1,M",facilitydate)),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityEndOfMonth","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilitytzadmitdatetime,char(128))=char(128))
  SUBROUTINE (getcgfacilitytzadmitdatetime(pbillingentityid=f8,pdatetime=dq8,pgroupbypreadmitchrgdays
   =i4) =dq8)
    CALL logmessage("getCGFacilityTZAdmitDateTime","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE admittime = vc WITH protect, noconstant("")
    SET admittime = cnvtalphanum(datetimezoneformat(pdatetime,timezoneindex,"HH:mm:ss"),1)
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    IF (pgroupbypreadmitchrgdays != 0)
     SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(cnvtlookbehind(concat(trim(cnvtstring(
            pgroupbypreadmitchrgdays),3),",D"),cnvtdatetime(cnvtdate(calcfacilitydate),0))),0),2)
    ELSEIF (pgroupbypreadmitchrgdays=0)
     SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(calcfacilitydate),cnvttime2(admittime,
        "HHMMSS")),2)
    ENDIF
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityTZAdmitDateTime","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilityeopdate,char(128))=char(128))
  SUBROUTINE (getcgfacilityeopdate(pbillingentityid=f8,pdatetime=dq8,peopmonth=i4,peopday=i4) =dq8)
    CALL logmessage("getCGFacilityEOPDate","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE serviceday = i4 WITH protect, noconstant(0)
    DECLARE servicemonth = i4 WITH protect, noconstant(0)
    DECLARE serviceyear = i4 WITH protect, noconstant(0)
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET serviceday = day(facilitydate)
    SET servicemonth = month(facilitydate)
    SET serviceyear = year(facilitydate)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    IF (((servicemonth > peopmonth) OR (servicemonth=peopmonth
     AND serviceday > peopday)) )
     SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat(format(peopmonth,"##;P0"),
         format(peopday,"##;P0"),format((serviceyear+ 1),"####;P0")),"MMDDYYYY"),235959),2)
    ELSE
     SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat(format(peopmonth,"##;P0"),
         format(peopday,"##;P0"),format(serviceyear,"####;P0")),"MMDDYYYY"),235959),2)
    ENDIF
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityEOPDate","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcgfacilityservicedatetime,char(128))=char(128))
  SUBROUTINE (getcgfacilityservicedatetime(pbillingentityid=f8,pdatetime=dq8) =dq8)
    CALL logmessage("getCGFacilityServiceDateTime","Entering...",log_debug)
    DECLARE timezoneindex = i4 WITH protect, constant(getcgfacilitytimezoneidx(pbillingentityid))
    DECLARE calcfacilitydate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    DECLARE chargeservicedate = i4 WITH protect, noconstant(0)
    DECLARE chargeservicetime = vc WITH protect, noconstant("")
    SET chargeservicedate = cnvtint(build2(format(month(pdatetime),"##;P0"),format(day(pdatetime),
       "##;P0"),year(pdatetime)))
    SET chargeservicetime = cnvtalphanum(datetimezoneformat(pdatetime,timezoneindex,"HH:mm:ss"),1)
    SET facilitydate = cnvtdatetimeutc(pdatetime,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET calcfacilitydate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate
        ),"##;P0"),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(calcfacilitydate),cnvttime2(
       chargeservicetime,"HHMMSS")),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    CALL logmessage("getCGFacilityServiceDateTime","Exiting...",log_debug)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getfacilitytimezonedatetime,char(128))=char(128))
  SUBROUTINE (getfacilitytimezonedatetime(pdatetime=dq8,pfactimezoneindex=i4) =dq8)
    CALL logmessage("getFacilityTimeZoneDateTime","Entering...",log_debug)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0)
    SET facilitydate = cnvtdatetimeutc(pdatetime,1)
    SET facilitydate = cnvtdatetimeutc(facilitydate,2,pfactimezoneindex)
    CALL logmessage("getFacilityTimeZoneDateTime","Exiting...",log_debug)
    RETURN(facilitydate)
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
 CALL echo("Begin PFT_RCA_CONTEXT_CONSTANTS.INC, version [700704.011]")
 DECLARE entity_type_patient_account = i4 WITH protect, constant(1)
 DECLARE entity_type_encounter = i4 WITH protect, constant(2)
 DECLARE entity_type_financial_encounter = i4 WITH protect, constant(3)
 DECLARE entity_type_insurance_balance = i4 WITH protect, constant(5)
 DECLARE entity_type_self_pay_balance = i4 WITH protect, constant(6)
 DECLARE entity_type_statement = i4 WITH protect, constant(7)
 DECLARE entity_type_consolidated_statement = i4 WITH protect, constant(8)
 DECLARE entity_type_claim = i4 WITH protect, constant(9)
 DECLARE entity_type_charge = i4 WITH protect, constant(10)
 DECLARE entity_type_itrans_balance = i4 WITH protect, constant(11)
 DECLARE entity_type_itrans_claim = i4 WITH protect, constant(12)
 DECLARE entity_type_itrans_charge = i4 WITH protect, constant(13)
 DECLARE entity_type_sptrans_statement = i4 WITH protect, constant(14)
 DECLARE entity_type_sptrans_charge = i4 WITH protect, constant(15)
 DECLARE entity_type_sptrans_balance = i4 WITH protect, constant(16)
 DECLARE entity_type_denial_claim = i4 WITH protect, constant(17)
 DECLARE entity_type_denial_charge = i4 WITH protect, constant(18)
 DECLARE entity_type_personnel = i4 WITH protect, constant(19)
 DECLARE entity_type_guarantor = i4 WITH protect, constant(20)
 DECLARE entity_type_charge_batch = i4 WITH protect, constant(21)
 DECLARE entity_type_client_account = i4 WITH protect, constant(22)
 DECLARE entity_type_client_invoice = i4 WITH protect, constant(23)
 DECLARE entity_type_transaction_batch = i4 WITH protect, constant(24)
 DECLARE entity_type_general_ar = i4 WITH protect, constant(25)
 DECLARE entity_type_prsnl_workflow_entity = i4 WITH protect, constant(26)
 DECLARE entity_type_patient = i4 WITH protect, constant(27)
 DECLARE entity_type_visit = i4 WITH protect, constant(28)
 DECLARE entity_type_remittance = i4 WITH protect, constant(29)
 DECLARE entity_type_general_account = i4 WITH protect, constant(31)
 DECLARE entity_type_ime_claim = i4 WITH protect, constant(32)
 DECLARE entity_type_eob = i4 WITH protect, constant(33)
 DECLARE entity_type_pending_transaction = i4 WITH protect, constant(34)
 DECLARE entity_type_modify_eob_detail = i4 WITH protect, constant(35)
 DECLARE entity_type_person = i4 WITH protect, constant(36)
 DECLARE entity_type_multi_acct_encounter = i4 WITH protect, constant(37)
 DECLARE entity_type_insurance_pending_transaction = i4 WITH protect, constant(39)
 DECLARE entity_type_invoice_transaction = i4 WITH protect, constant(40)
 DECLARE entity_type_claim_line_item = i4 WITH protect, constant(41)
 DECLARE entity_type_research_account = i4 WITH protect, constant(42)
 DECLARE entity_type_invoice = i4 WITH protect, constant(43)
 DECLARE entity_type_guarantor_account = i4 WITH protect, constant(44)
 DECLARE entity_type_billing_hold = i4 WITH protect, constant(45)
 CALL echo("End PFT_RCA_CONTEXT_CONSTANTS.INC")
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
 IF ( NOT (validate(cs354_selfpay_cd)))
  DECLARE cs354_selfpay_cd = f8 WITH protect, constant(getcodevalue(354,"SELFPAY",0))
 ENDIF
 IF (validate(getbillingentitybyencounter,char(128))=char(128))
  SUBROUTINE (getbillingentitybyencounter(pencntrid=f8,prbillingentityid=f8(ref)) =i2)
    DECLARE facilitycd = f8 WITH protect, noconstant(0.0)
    SET prbillingentityid = 0.0
    SELECT INTO "nl:"
     FROM encounter e
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
     DETAIL
      facilitycd = e.loc_facility_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM encntr_pending e
      PLAN (e
       WHERE e.encntr_id=pencntrid
        AND e.active_ind=true)
      DETAIL
       facilitycd = e.pend_facility_cd
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     FROM location l,
      be_org_reltn bor,
      billing_entity be
     PLAN (l
      WHERE l.location_cd=facilitycd
       AND l.active_ind=true
       AND l.location_cd > 0.0)
      JOIN (bor
      WHERE bor.organization_id=l.organization_id
       AND bor.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=bor.billing_entity_id
       AND be.active_ind=true)
     DETAIL
      prbillingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getaccountbillingentityforfinancialencounter,char(128))=char(128))
  SUBROUTINE (getaccountbillingentityforfinancialencounter(ppftencntrid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      account a,
      billing_entity be
     PLAN (pe
      WHERE pe.pft_encntr_id=ppftencntrid
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getaccountbillingentityforencounter,char(128))=char(128))
  SUBROUTINE (getaccountbillingentityforencounter(pencntrid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentitiesforencounterwithmultipleaccounts,char(128))=char(128))
  SUBROUTINE (getbillingentitiesforencounterwithmultipleaccounts(pencntrid=f8,prbes=vc(ref)) =i2)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      becnt += 1, stat = alterlist(prbes->billingentities,becnt), prbes->billingentities[becnt].
      billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentityforaccount,char(128))=char(128))
  SUBROUTINE (getbillingentityforaccount(pacctid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM account a,
      billing_entity be
     PLAN (a
      WHERE a.acct_id=pacctid
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentitiesforperson,char(128))=char(128))
  SUBROUTINE (getbillingentitiesforperson(ppersonid=f8,prbes=vc(ref)) =i2)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM person p,
      encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (p
      WHERE p.person_id=ppersonid
       AND p.active_ind=true)
      JOIN (e
      WHERE e.person_id=p.person_id
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      becnt += 1, stat = alterlist(prbes->billingentities,becnt), prbes->billingentities[becnt].
      billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getviewablebillingentitiesforentity,char(128))=char(128))
  SUBROUTINE (getviewablebillingentitiesforentity(pentityid=f8,pentitytype=i4,prbes=vc(ref)) =i2)
    RECORD entitybes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    RECORD authorizedbes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    DECLARE beid = f8 WITH protect, noconstant(0.0)
    DECLARE beidx = i4 WITH protect, noconstant(0)
    DECLARE authbeidx = i4 WITH protect, noconstant(0)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    IF ( NOT (getuserauthorizedbillingentities(authorizedbes)))
     CALL exitservicefailure("Unable to retrieve authorized biling entity ids",true)
    ENDIF
    CASE (pentitytype)
     OF entity_type_person:
      SET stat = getbillingentitiesforperson(pentityid,entitybes)
     OF entity_type_patient_account:
      SET stat = getbillingentityforaccount(pentityid,beid)
     OF entity_type_multi_acct_encounter:
      SET stat = getbillingentitiesforencounterwithmultipleaccounts(pentityid,entitybes)
     OF entity_type_encounter:
      SET stat = getaccountbillingentityforencounter(pentityid,beid)
     OF entity_type_financial_encounter:
      SET stat = getaccountbillingentityforfinancialencounter(pentityid,beid)
     ELSE
      RETURN(false)
    ENDCASE
    IF (beid > 0.0)
     SET stat = alterlist(entitybes->billingentities,1)
     SET entitybes->billingentities[1].billingentityid = beid
    ENDIF
    FOR (beidx = 1 TO size(entitybes->billingentities,5))
     SET bepos = locateval(authbeidx,1,size(authorizedbes->billingentities,5),entitybes->
      billingentities[beidx].billingentityid,authorizedbes->billingentities[authbeidx].
      billingentityid)
     IF (bepos > 0)
      SET becnt += 1
      SET stat = alterlist(prbes->billingentities,becnt)
      SET prbes->billingentities[becnt].billingentityid = entitybes->billingentities[beidx].
      billingentityid
     ENDIF
    ENDFOR
    RETURN(true)
  END ;Subroutine
 ENDIF
 DECLARE afc_ct_execute_handler_version = vc WITH private, noconstant("CHARGSRV-15934.FT.039")
 SET modify = subvarlistfree
 EXECUTE crmrtl
 EXECUTE srvrtl
 IF (validate(debug,- (1)) > 0)
  CALL echoxml(request,"afc_ct_execute_handler_request")
 ENDIF
 EXECUTE cclseclogin
 SET message = nowindow
 IF (validate(request->ops_date,999)=999)
  IF ((xxcclseclogin->loggedin != 1))
   CALL echo("******************************************")
   CALL echo("*** User Not Signed In.                ***")
   CALL echo("*** Type 'CCLSECLOGIN GO'              ***")
   CALL echo("*** and sign in to continue.           ***")
   CALL echo("******************************************")
   GO TO end_program
  ENDIF
 ENDIF
 FREE RECORD charges
 RECORD charges(
   1 dateofservice[*]
     2 dateofservice = dq8
     2 skipdate = i2
     2 physicians[*]
       3 ordpysicianid = f8
       3 perfphysicianid = f8
       3 verifyphysicianid = f8
       3 skipcharges = i2
       3 charges[*]
         4 chg = i4
         4 xpcharge = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD builddata
 RECORD builddata(
   1 rulesets[*]
     2 ruleset_id = f8
     2 ruleset_name = vc
     2 priority_nbr = i4
     2 tier_row
       3 tier_id = f8
       3 health_plan_excl_ind = i2
       3 org_excl_ind = i2
       3 ins_org_excl_ind = i2
       3 encntr_type_excl_ind = i2
       3 fin_class_excl_ind = i2
       3 encntr_class_excl_ind = i2
       3 health_plan[*]
         4 health_plan_id = f8
       3 organization[*]
         4 org_id = f8
       3 insurance_org[*]
         4 ins_org_id = f8
       3 encntr_type[*]
         4 encntr_type_cd = f8
       3 fin_class[*]
         4 fin_class_cd = f8
       3 encntr_type_class[*]
         4 encntr_type_class_cd = f8
       3 charge_status_ind = i2
     2 rules[*]
       3 rule_id = f8
       3 rule_name = vc
       3 long_text = vc
       3 priority_nbr = i4
       3 rule_beg_dt_tm = dq8
       3 rule_end_dt_tm = dq8
       3 charge_status_ind = i2
 )
 FREE RECORD workdata
 RECORD workdata(
   1 encntrs[*]
     2 encntr_id = f8
     2 person_id = f8
     2 exclude_ind = i2
     2 dts[*]
       3 service_dt_tm = dq8
       3 tier[*]
         4 tier_group_cd = f8
         4 charges[*]
           5 charge_used = i2
           5 charge_item_id = f8
           5 charge_event_id = f8
           5 bill_item_id = f8
           5 encntr_id = f8
           5 person_id = f8
           5 item_quantity = f8
           5 item_price = f8
           5 service_dt_tm = dq8
           5 next_cpt_mod_seq = i4
           5 cs_cpp_undo_id = f8
           5 ord_phys_id = f8
           5 perf_phys_id = f8
           5 verify_phys_id = f8
           5 abn_status_cd = f8
           5 provider_specialty_cd = f8
           5 charge_mods[*]
             6 field1_id = f8
             6 nomen_id = f8
             6 field6 = vc
             6 field3_id = f8
 )
 FREE RECORD ruledata
 RECORD ruledata(
   1 rules[*]
     2 rule_id = f8
     2 rule_name = vc
     2 rulecomplete = i2
     2 person_id = f8
     2 encntr_id = f8
     2 service_res_cd = f8
     2 conditions_met = i2
     2 conditions[*]
       3 text = vc
       3 condition_true = i2
       3 quantity = f8
       3 charges[*]
         4 charge_item_id = f8
         4 workdata_index = i4
         4 replace_used = i2
         4 firstchargeind = i2
     2 actions[*]
       3 text = vc
     2 charge_status_ind = i2
 )
 FREE RECORD tempreplace
 RECORD tempreplace(
   1 replace_valid = i2
   1 source[*]
     2 match_string = vc
     2 charge_item_id = f8
   1 dest[*]
     2 bill_item_id = f8
     2 quantity = i4
 )
 FREE RECORD addcreditreq
 RECORD addcreditreq(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 )
 FREE RECORD addcreditreply
 RECORD addcreditreply(
   1 charge_qual = i2
   1 dequeued_ind = i2
   1 charge[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 ord_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
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
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 price_sched_id = f8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 username = vc
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 bundle_id = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 inst_fin_nbr = c50
     2 cost_center_cd = f8
     2 cost_center_disp = c40
     2 cost_center_desc = c60
     2 cost_center_mean = c12
     2 abn_status_cd = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 payor_type_cd = f8
     2 item_reimbursement = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 list_price_sched_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
   1 original_charge_qual = i2
   1 original_charge[*]
     2 charge_item_id = f8
     2 process_flg = f8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD ct_request
 RECORD ct_request(
   1 ref_id = f8
   1 ref_cont_cd = f8
   1 person_id = f8
   1 encntr_id = f8
   1 quantity = i4
   1 order_id = f8
   1 ord_phys_id = f8
   1 perf_phys_id = f8
   1 verify_phys_id = f8
   1 ref_phys_id = f8
   1 service_dt_tm = dq8
   1 service_res_cd = f8
 )
 FREE RECORD ct_reply
 RECORD ct_reply(
   1 charges[*]
     2 charge_item_id = f8
     2 process_flg = i4
 )
 FREE RECORD finalcharges
 RECORD finalcharges(
   1 charges[*]
     2 charge_item_id = f8
     2 interface_file_id = f8
 )
 FREE RECORD afcinterfacecharge_request
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 FREE RECORD afcinterfacecharge_reply
 RECORD afcinterfacecharge_reply(
   1 interface_charge[*]
     2 abn_status_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_type_cd = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 admit_type_cd = f8
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 batch_num = i4
     2 bed_cd = f8
     2 beg_effective_dt_tm = dq8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 building_cd = f8
     2 charge_description = c200
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 code_revenue_cd = f8
     2 code_revenue_more_ind = i2
     2 cost_center_cd = f8
     2 department_cd = f8
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 discount_amount = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 facility_cd = f8
     2 fin_nbr = c50
     2 fin_nbr_type_flg = i4
     2 gross_price = f8
     2 icd9_proc_more_ind = i2
     2 institution_cd = f8
     2 interface_charge_id = f8
     2 interface_file_id = f8
     2 level5_cd = f8
     2 manual_ind = i2
     2 med_nbr = c50
     2 med_service_cd = f8
     2 net_ext_price = f8
     2 nurse_unit_cd = f8
     2 order_dept = i4
     2 order_nbr = c200
     2 ord_doc_nbr = c20
     2 ord_phys_id = f8
     2 organization_id = f8
     2 override_desc = c200
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 person_id = f8
     2 person_name = c100
     2 posted_dt_tm = dq8
     2 price = f8
     2 prim_cdm = c50
     2 prim_cdm_desc = c200
     2 prim_cpt = c50
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 quantity = f8
     2 referring_phys_id = f8
     2 room_cd = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 user_def_ind = i2
     2 ndc_ident = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD afcprofit_request
 RECORD afcprofit_request(
   1 remove_commit_ind = i2
   1 follow_combined_parent_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD afcprofit_reply
 RECORD afcprofit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 objarray[*]
     2 service_cd = f8
     2 updt_id = f8
     2 event_key = vc
     2 category_key = vc
     2 published_ind = i2
     2 pe_status_reason_cd = f8
     2 acct_id = f8
     2 activity_id = f8
     2 batch_denial_file_r_id = f8
     2 batch_trans_ext_id = f8
     2 batch_trans_file_id = f8
     2 batch_trans_id = f8
     2 benefit_order_id = f8
     2 bill_item_id = f8
     2 bill_templ_id = f8
     2 bill_vrsn_nbr = i4
     2 billing_entity_id = f8
     2 bo_hp_reltn_id = f8
     2 charge_item_id = f8
     2 chrg_activity_id = f8
     2 claim_status_id = f8
     2 client_org_id = f8
     2 corsp_activity_id = f8
     2 corsp_log_reltn_id = f8
     2 denial_id = f8
     2 dirty_flag = i4
     2 encntr_id = f8
     2 guar_acct_id = f8
     2 guarantor_id = f8
     2 health_plan_id = f8
     2 long_text_id = f8
     2 organization_id = f8
     2 payor_org_id = f8
     2 pe_status_reason_id = f8
     2 person_id = f8
     2 pft_balance_id = f8
     2 pft_bill_activity_id = f8
     2 pft_charge_id = f8
     2 pft_encntr_fact_id = f8
     2 pft_encntr_id = f8
     2 pft_line_item_id = f8
     2 trans_alias_id = f8
     2 pft_payment_plan_id = f8
     2 daily_encntr_bal_id = f8
     2 daily_acct_bal_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = f8
     2 benefit_status_cd = f8
     2 financial_class_cd = f8
     2 payment_plan_flag = i2
     2 payment_location_id = f8
     2 encntr_plan_cob_id = f8
     2 guarantor_account_id = f8
     2 guarantor_id1 = f8
     2 guarantor_id2 = f8
     2 cbos_pe_reltn_id = f8
     2 post_dt_tm = dq8
     2 posting_category_type_flag = i2
 )
 FREE RECORD addcmrequest
 RECORD addcmrequest(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c200
     2 field4 = c200
     2 field5 = c200
     2 field6 = c200
     2 field7 = c200
     2 field8 = c200
     2 field9 = c200
     2 field10 = c200
     2 activity_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 cm1_nbr = f8
     2 nomen_entity_reltn_id = f8
 )
 FREE RECORD addcmreply
 RECORD addcmreply(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
     2 nomen_id = f8
     2 action_type = c3
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD adjustrequest
 RECORD adjustrequest(
   1 charge_item_id = f8
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = i4
 )
 FREE RECORD adjustreply
 RECORD adjustreply(
   1 new_charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cptlist
 RECORD cptlist(
   1 cptlist[*]
     2 cpt = f8
 )
 FREE RECORD code_val
 RECORD code_val(
   1 370_carrier = f8
   1 13019_billcode = f8
   1 13019_suspense = f8
   1 13029_complete = f8
   1 13028_charge_now = f8
   1 13030_noauth = f8
   1 14002_modifier = f8
   1 17769_mod59 = f8
   1 17769_mod76 = f8
   1 17769_mod91 = f8
   1 17769_modl1 = f8
   1 17769_modxu = f8
   1 17769_modxs = f8
   1 17769_modxp = f8
   1 13030_modreview = f8
 )
 RECORD csfacilitytimezone(
   1 timezonelist[*]
     2 organization_id = f8
     2 timezoneindex = i4
     2 from_date = dq8
     2 today = dq8
     2 organization[*]
       3 org_id = f8
 ) WITH protect
 RECORD cemrequest(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cemreply(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE script_start_dt_tm = dm12 WITH protect, constant(systimestamp)
 DECLARE loop_start_dt_tm = dm12 WITH protect, noconstant(0)
 DECLARE factimezoneindex = i4 WITH protect, noconstant(0)
 DECLARE pencntrid = f8 WITH protect, noconstant(0.0)
 DECLARE cntfinal = i4 WITH public, noconstant(0)
 DECLARE cntfinal2 = i4 WITH public, noconstant(0)
 DECLARE cntrs = i4 WITH public, noconstant(0)
 DECLARE cntrule = i4 WITH public, noconstant(0)
 DECLARE cntenc = i4 WITH public, noconstant(0)
 DECLARE cntdt = i4 WITH public, noconstant(0)
 DECLARE cnttier = i4 WITH public, noconstant(0)
 DECLARE cntchg = i4 WITH public, noconstant(0)
 DECLARE cntcm = i4 WITH public, noconstant(0)
 DECLARE loopcnt = i4 WITH public, noconstant(0)
 DECLARE loopcnt2 = i4 WITH public, noconstant(0)
 DECLARE cntr = i4 WITH public, noconstant(0)
 DECLARE cntcon = i4 WITH public, noconstant(0)
 DECLARE cntact = i4 WITH public, noconstant(0)
 DECLARE istartpos = i4 WITH public, noconstant(0)
 DECLARE ifindpos = i4 WITH public, noconstant(0)
 DECLARE idoneprocessing = i2 WITH public, noconstant(0)
 DECLARE sprocessstring = vc WITH public
 DECLARE stempcondition = vc WITH public
 DECLARE stempaction = vc WITH public
 DECLARE stempaction2 = vc WITH public
 DECLARE scptlist = vc WITH public
 DECLARE scptmodlist = vc WITH public
 DECLARE ssubquantity = vc WITH public
 DECLARE ordphysicianid = f8 WITH public
 DECLARE dateofservice = dq8 WITH public
 DECLARE chargecount = i4 WITH public
 DECLARE reviewcharges = i2 WITH public
 DECLARE validcharges = i2 WITH public
 DECLARE includefirstchg = i2 WITH public
 DECLARE validencounter = i2 WITH public
 DECLARE iexisttype = i2 WITH public, noconstant(0)
 DECLARE loopenc = i4 WITH public, noconstant(0)
 DECLARE loopdt = i4 WITH public, noconstant(0)
 DECLARE looptier = i4 WITH public, noconstant(0)
 DECLARE loopchg = i4 WITH public, noconstant(0)
 DECLARE loopchg2 = i4 WITH public, noconstant(0)
 DECLARE loopcm = i4 WITH public, noconstant(0)
 DECLARE looprule = i4 WITH public, noconstant(0)
 DECLARE loopcon = i4 WITH public, noconstant(0)
 DECLARE loopact = i4 WITH public, noconstant(0)
 DECLARE loopphys = i4 WITH public, noconstant(0)
 DECLARE loopdate = i4 WITH public, noconstant(0)
 DECLARE dtempid = f8 WITH public, noconstant(0.0)
 DECLARE imodcnt = i4 WITH public, noconstant(0)
 DECLARE range1 = i4 WITH public, noconstant(0)
 DECLARE range2 = i4 WITH public, noconstant(0)
 DECLARE icheckgood = i2 WITH public, noconstant(0)
 DECLARE iskipforaddmod = i2 WITH public, noconstant(0)
 DECLARE dundoid = f8 WITH public, noconstant(0.0)
 DECLARE iaddcmcnt = i4 WITH public, noconstant(0)
 DECLARE imodifierrange = i2 WITH public, noconstant(0)
 DECLARE imodifierphyssame = i2 WITH public, noconstant(0)
 DECLARE imodifierphysdiff = i2 WITH public, noconstant(0)
 DECLARE total_remaining = i4 WITH public, noconstant(0)
 DECLARE cpt_sched_value = f8 WITH public, noconstant(0.0)
 DECLARE ncpt4cnt1 = i4 WITH public, noconstant(1)
 DECLARE ncpt4cnt2 = i4 WITH public, noconstant(2)
 DECLARE today = q8 WITH public
 DECLARE from_date = q8 WITH public
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE imodifierabn = i2 WITH public, noconstant(0)
 DECLARE numberofdaysbacktoprocess = i2 WITH public, noconstant(1)
 DECLARE encntr_type = vc WITH protect, constant("ENCNTR_TYPE")
 DECLARE organization = vc WITH protect, constant("ORGANIZATION")
 DECLARE insurance_org = vc WITH protect, constant("INSURANCE_ORG")
 DECLARE health_plan = vc WITH protect, constant("HEALTH_PLAN")
 DECLARE fin_class = vc WITH protect, constant("FIN_CLASS")
 DECLARE encntr_type_class = vc WITH protect, constant("ENCNTR_TYPE_CLASS")
 DECLARE ct_codevalue = vc WITH protect, constant("CODE_VALUE")
 DECLARE exist_nomen = vc WITH protect, constant("EXIST NOMEN")
 DECLARE exist_rev = vc WITH protect, constant("EXIST REV")
 DECLARE exist_cdm = vc WITH protect, constant("EXIST CDM")
 DECLARE cdm_sched = vc WITH protect, constant("CDM_SCHED")
 DECLARE l1_collector_id = vc WITH protect, constant("2014.2.00431.1")
 DECLARE xmod_collector_id = vc WITH protect, constant("2014.2.00431.2")
 DECLARE abn_collector_id = vc WITH protect, constant("2015.1.00134.1")
 DECLARE exist_abn = c10 WITH protect, constant("EXIST ABN")
 DECLARE hpidx = i4 WITH protect, noconstant(0)
 DECLARE orgidx = i4 WITH protect, noconstant(0)
 DECLARE insidx = i4 WITH protect, noconstant(0)
 DECLARE encntrtypeidx = i4 WITH protect, noconstant(0)
 DECLARE encntrclassidx = i4 WITH protect, noconstant(0)
 DECLARE finidx = i4 WITH protect, noconstant(0)
 DECLARE chrgmodfindidx = i4 WITH noconstant(0)
 DECLARE modindxcnt = i4 WITH noconstant(0)
 DECLARE dmodifiercvalue = f8 WITH noconstant(0.0)
 DECLARE in_clause_ind = i2 WITH private, noconstant(false)
 DECLARE sconditiontype = vc WITH public, noconstant("")
 DECLARE scdmtext = vc WITH public, noconstant("")
 DECLARE sbillcodetypemeaning = vc WITH public, noconstant("")
 DECLARE cs71_encntr = i4
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 DECLARE table_name = vc WITH public, noconstant("")
 SET cs71_encntr = 71
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sprocessstring = fillstring(32000," ")
 SET stempcondition = fillstring(32000," ")
 SET stempaction = fillstring(32000," ")
 SET stempaction2 = fillstring(32000," ")
 SET scptlist = fillstring(32000," ")
 SET scptmodlist = fillstring(32000," ")
 SET sprocessstring = ""
 SET stempcondition = ""
 SET stempaction = ""
 SET stempaction2 = ""
 SET scptlist = ""
 SET scptmodlist = ""
 SET ssubquantity = ""
 SET rulename = fillstring(32000," ")
 SET stat = uar_get_meaning_by_codeset(370,"CARRIER",1,code_val->370_carrier)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,code_val->13019_billcode)
 SET stat = uar_get_meaning_by_codeset(13019,"SUSPENSE",1,code_val->13019_suspense)
 SET stat = uar_get_meaning_by_codeset(13028,"CHARGE NOW",1,code_val->13028_charge_now)
 SET stat = uar_get_meaning_by_codeset(13029,"COMPLETE",1,code_val->13029_complete)
 SET stat = uar_get_meaning_by_codeset(13030,"NOAUTH",1,code_val->13030_noauth)
 SET stat = uar_get_meaning_by_codeset(13030,"MODREVIEW",1,code_val->13030_modreview)
 SET stat = uar_get_code_list_by_dispkey(17769,"59",1,1,total_remaining,
  code_val->17769_mod59)
 SET stat = uar_get_code_list_by_dispkey(17769,"76",1,1,total_remaining,
  code_val->17769_mod76)
 SET stat = uar_get_code_list_by_dispkey(17769,"91",1,1,total_remaining,
  code_val->17769_mod91)
 SET stat = uar_get_code_list_by_dispkey(17769,"L1",1,1,total_remaining,
  code_val->17769_modl1)
 SET stat = uar_get_code_list_by_dispkey(17769,"XU",1,1,total_remaining,
  code_val->17769_modxu)
 SET stat = uar_get_code_list_by_dispkey(17769,"XS",1,1,total_remaining,
  code_val->17769_modxs)
 SET stat = uar_get_code_list_by_dispkey(17769,"XP",1,1,total_remaining,
  code_val->17769_modxp)
 SET stat = alterlist(finalcharges->charges,10)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE logicaldomainsinuse = i2 WITH protect, noconstant(0)
 DECLARE len = i2 WITH protect, noconstant(0)
 DECLARE lennext = i2 WITH protect, noconstant(0)
 DECLARE lockind = i2 WITH protect, noconstant(0)
 SET logicaldomainsinuse = arelogicaldomainsinuse(null)
 SET iret = uar_get_meaning_by_codeset(14002,"CPT4",ncpt4cnt1,cpt_sched_value)
 IF (iret=0)
  IF (ncpt4cnt1 > 0)
   SET scptlist = concat(scptlist,",",cnvtstring(cpt_sched_value,17,2),",")
  ENDIF
 ELSE
  GO TO end_program
 ENDIF
 IF (ncpt4cnt1 > 1)
  FOR (ncpt4cnt2 = 2 TO ncpt4cnt1)
    SET i = ncpt4cnt2
    SET iret = uar_get_meaning_by_codeset(14002,"CPT4",i,cpt_sched_value)
    IF (iret=0)
     SET scptlist = concat(scptlist,",",cnvtstring(cpt_sched_value,17,2),",")
    ELSE
     GO TO end_program
    ENDIF
  ENDFOR
 ENDIF
 SET ncpt4cnt1 = 1
 SET ncpt4cnt2 = 2
 SET iret = uar_get_meaning_by_codeset(14002,"MODIFIER",ncpt4cnt1,cpt_sched_value)
 IF (iret=0)
  IF (ncpt4cnt1 > 0)
   SET scptmodlist = concat(scptmodlist,",",cnvtstring(cpt_sched_value,17,2),",")
   SET code_val->14002_modifier = cpt_sched_value
  ENDIF
 ELSE
  GO TO end_program
 ENDIF
 IF (ncpt4cnt1 > 1)
  FOR (ncpt4cnt2 = 2 TO ncpt4cnt1)
    SET i = ncpt4cnt2
    SET iret = uar_get_meaning_by_codeset(14002,"MODIFIER",i,cpt_sched_value)
    IF (iret=0)
     SET scptmodlist = concat(scptmodlist,",",cnvtstring(cpt_sched_value,17,2),",")
     IF ((cpt_sched_value < code_val->14002_modifier))
      SET code_val->14002_modifier = cpt_sched_value
     ENDIF
    ELSE
     GO TO end_program
    ENDIF
  ENDFOR
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo(build("Start date/time: ",format(cnvtdatetime(sysdate),"DD-MMM-YYYY;;D")))
 ENDIF
 IF (validate(request->batch_selection)=1)
  SET len = findstring("|",trim(request->batch_selection),1)
  SET lennext = findstring("|",trim(request->batch_selection),(len+ 1))
  IF (len=1)
   SET numberofdaysbacktoprocess = 1
  ELSEIF (len=0)
   SET numberofdaysbacktoprocess = cnvtint(trim(request->batch_selection))
  ELSE
   SET numberofdaysbacktoprocess = cnvtint(substring(1,(len - 1),trim(request->batch_selection)))
  ENDIF
  IF ((request->ops_date > 0.0)
   AND lennext > 0
   AND (lennext != (len+ 1)))
   SET logicaldomainid = cnvtreal(substring((len+ 1),(lennext - (len+ 1)),trim(request->
      batch_selection)))
  ELSEIF ((request->ops_date > 0.0)
   AND logicaldomainsinuse=true
   AND ((lennext=0) OR ((lennext=(len+ 1)))) )
   GO TO end_program
  ELSE
   IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
    CALL exitservicefailure("Failed to get Logical Domain ID",true)
   ENDIF
  ENDIF
 ELSE
  SET numberofdaysbacktoprocess = cnvtint( $1)
  IF (validate(debug,- (1)) > 0)
   CALL echo(build("The number of days to process is: ",numberofdaysbacktoprocess))
  ENDIF
 ENDIF
 IF (numberofdaysbacktoprocess=0)
  SET numberofdaysbacktoprocess = 1
 ENDIF
 SET today = cnvtdatetime(sysdate)
 SET today = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D")," 00:00:00.00"))
 SET from_date = datetimeadd(today,- (numberofdaysbacktoprocess))
 IF (validate(debug,- (1)) > 0)
  CALL echo(build("Today:",today))
  CALL echo(build("From:",from_date))
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo(concat("Memory start: ",trim(cnvtstring(curmem))))
 ENDIF
 CALL getbuilddata(0)
 CALL getcsfacilitytimezonedetails(0)
 SET loop_start_dt_tm = systimestamp
 FOR (loopcnt = 1 TO cntrs)
   CALL getqualifiedcharges(0)
   CALL parseruledata(0)
   SET loopenc = 0
   SET loopdt = 0
   SET loopchg = 0
   SET loopchg2 = 0
   SET loopcm = 0
   SET looprule = 0
   SET loopcon = 0
   SET loopact = 0
   SET looptier = 0
   SET dtempid = 0.0
   SET range1 = 0.0
   SET range2 = 0.0
   SET icheckgood = 0
   SET stempcondition = ""
   SET stempaction = ""
   SET sprocessstring = ""
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin main loop through encounters")
    CALL echo(concat("Memory: ",trim(cnvtstring(curmem))))
    CALL echo("----------------------------------------------------------")
   ENDIF
   FOR (loopenc = 1 TO size(workdata->encntrs,5))
     SET lockind = false
     IF (getencounterlock(workdata->encntrs[loopenc].encntr_id))
      CALL echo(getencounterlock(workdata->encntrs[loopenc].encntr_id))
      FOR (loopdt = 1 TO size(workdata->encntrs[loopenc].dts,5))
        FOR (looptier = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier,5))
          FOR (looprule = 1 TO size(ruledata->rules,5))
            IF ((((builddata->rulesets[loopcnt].tier_row.charge_status_ind=1)) OR ((((ruledata->
            rules[looprule].charge_status_ind=1)) OR ((workdata->encntrs[loopenc].exclude_ind=0)))
            )) )
             SET imodifierrange = 0
             SET imodifierphyssame = 0
             SET imodifierphysdiff = 0
             SET imodifierabn = 0
             IF ((ruledata->rules[looprule].rulecomplete=1))
              IF (validate(debug,- (1)) > 0)
               CALL echo(concat("Rule Name: ",ruledata->rules[looprule].rule_name))
               CALL echo("----------------------------------")
              ENDIF
              SET ruledata->rules[looprule].person_id = 0.0
              SET ruledata->rules[looprule].encntr_id = 0.0
              SET ruledata->rules[looprule].service_res_cd = 0.0
              IF (validate(debug,- (1)) > 0)
               CALL echo("Processing Conditions...")
               CALL echo("----------------------------------")
              ENDIF
              FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
                SET stat = alterlist(ruledata->rules[looprule].conditions[loopcon].charges,0)
                SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
                SET ruledata->rules[looprule].conditions[loopcon].quantity = 0
                SET cnttemp = 0
                SET stat = alterlist(ruledata->rules[looprule].conditions[loopcon].charges,10)
                IF (((substring(1,11,ruledata->rules[looprule].conditions[loopcon].text)=
                "EXIST NOMEN") OR (((substring(1,8,ruledata->rules[looprule].conditions[loopcon].text
                 )="EXIST BI") OR (((substring(1,9,ruledata->rules[looprule].conditions[loopcon].text
                 )="EXIST REV") OR (substring(1,9,ruledata->rules[looprule].conditions[loopcon].text)
                ="EXIST CDM")) )) )) )
                 CALL conditionexist(0)
                ELSEIF (substring(1,15,ruledata->rules[looprule].conditions[loopcon].text)=
                "EXIST ADD NOMEN")
                 CALL conditionaddnomen(0)
                 SET imodifierrange = 1
                ELSEIF (substring(1,15,ruledata->rules[looprule].conditions[loopcon].text)=
                "EXIST SAME PHYS")
                 CALL conditionaddl1nomen(0)
                 SET imodifierrange = 1
                 SET imodifierphyssame = 1
                ELSEIF (substring(1,15,ruledata->rules[looprule].conditions[loopcon].text)=
                "EXIST DIFF PHYS")
                 CALL conditionaddxpnomen(0)
                 SET imodifierrange = 1
                 SET imodifierphysdiff = 1
                ELSEIF (substring(1,9,ruledata->rules[looprule].conditions[loopcon].text)="EXIST ABN"
                )
                 CALL conditionexist(0)
                 SET imodifierabn = 1
                ELSE
                 CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt rule EXIST clause"),0)
                ENDIF
                SET stat = alterlist(ruledata->rules[looprule].conditions[loopcon].charges,cnttemp)
                IF (size(ruledata->rules[looprule].conditions[loopcon].charges,5) > 0)
                 SELECT INTO "nl:"
                  FROM charge c,
                   (dummyt d1  WITH seq = value(size(ruledata->rules[looprule].conditions[loopcon].
                     charges,5)))
                  PLAN (d1)
                   JOIN (c
                   WHERE (c.charge_item_id=ruledata->rules[looprule].conditions[loopcon].charges[d1
                   .seq].charge_item_id)
                    AND c.offset_charge_item_id=0.0
                    AND c.active_ind=1
                    AND c.process_flg IN (0, 1, 2, 3, 4,
                   100, 999))
                  WITH forupdate(c), nocounter
                 ;end select
                 IF (curqual=0)
                  SET loopcon = size(ruledata->rules[looprule].conditions,5)
                  SET looprule = size(ruledata->rules,5)
                  SET loopdt = size(workdata->encntrs[loopenc].dts,5)
                  SET looptier = size(workdata->encntrs[loopenc].dts[loopdt].tier,5)
                  SET lockind = true
                 ENDIF
                ENDIF
              ENDFOR
              IF ( NOT (lockind))
               SET ruledata->rules[looprule].conditions_met = 1
               FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
                 IF ((ruledata->rules[looprule].conditions[loopcon].condition_true != 1))
                  SET ruledata->rules[looprule].conditions_met = 0
                 ENDIF
               ENDFOR
               IF (validate(debug,- (1)) > 0)
                CALL echo("Processing Actions...")
                CALL echo("----------------------------------")
                IF (validate(debug,- (1)) > 1)
                 CALL echorecord(ruledata)
                 CALL echo("Condition flags")
                 CALL echo(imodifierrange)
                 CALL echo(imodifierphyssame)
                 CALL echo(imodifierphysdiff)
                 CALL echo(ruledata->rules[looprule].conditions_met)
                 CALL echo(imodifierabn)
                ENDIF
               ENDIF
               SET dundoid = 0.0
               FOR (loopact = 1 TO size(ruledata->rules[looprule].actions,5))
                 IF ((ruledata->rules[looprule].conditions_met=1))
                  SET stat = initrec(addcreditreq)
                  SET stat = initrec(addcreditreply)
                  SET stat = initrec(adjustrequest)
                  SET stat = initrec(adjustreply)
                  SET stat = initrec(ct_request)
                  SET stat = initrec(ct_reply)
                  IF (substring(1,6,ruledata->rules[looprule].actions[loopact].text)="MODIFY")
                   CALL actionmodify(0)
                  ELSEIF (substring(1,6,ruledata->rules[looprule].actions[loopact].text)="CREDIT")
                   CALL actioncredit(0)
                  ELSEIF (substring(1,7,ruledata->rules[looprule].actions[loopact].text)="REPLACE")
                   CALL actionreplace(0)
                  ELSEIF (substring(1,6,ruledata->rules[looprule].actions[loopact].text)="CREATE")
                   CALL actioncreate(0)
                  ELSEIF (substring(1,12,ruledata->rules[looprule].actions[loopact].text)=
                  "ADD MODIFIER")
                   IF (imodifierrange=1
                    AND imodifierphyssame=1
                    AND imodifierphysdiff=0)
                    CALL actionaddl1modifiertorange(0)
                   ELSEIF (imodifierrange=1
                    AND imodifierphyssame=0
                    AND imodifierphysdiff=1)
                    CALL actionaddxpmodifiertorange(0)
                   ELSEIF (imodifierrange=1
                    AND imodifierphyssame=0
                    AND imodifierphysdiff=0)
                    CALL actionaddmodifiertorange(0)
                   ELSEIF (imodifierabn=1)
                    CALL actionaddmodifiertoabn(0)
                   ELSE
                    CALL actionaddmodifiertonomen(0)
                   ENDIF
                  ELSE
                   IF (validate(debug,- (1)) > 0)
                    CALL echo(ruledata->rules[looprule].actions[loopact].text)
                   ENDIF
                   CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt rule action clause"),0
                    )
                  ENDIF
                 ENDIF
               ENDFOR
              ENDIF
             ENDIF
            ELSE
             CALL logcterror("",1)
            ENDIF
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
     COMMIT
   ENDFOR
 ENDFOR
 CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
  "Exit loop for rulesets",script_and_detail_level_timer)
 CALL processinterfaces(1)
 COMMIT
 GO TO end_program
 SUBROUTINE (logcterror(smessage=vc,iskip=i4) =null)
   DECLARE dtempruleid = f8
   SET dtempruleid = 0.0
   IF (looprule < size(ruledata->rules,5))
    SET dtempruleid = ruledata->rules[looprule].rule_id
   ENDIF
   IF (iskip > 0)
    SET smessage = uar_i18ngetmessage(i18nhandle,"k1",
     "Encounter excluded due to suspended/held/manual/review charges")
   ENDIF
   INSERT  FROM cs_cpp_error_log e
    SET e.cs_cpp_error_log_id = seq(pft_activity_seq,nextval), e.error_text = smessage, e.error_dt_tm
      = cnvtdatetime(sysdate),
     e.cs_cpp_ruleset_id = builddata->rulesets[loopcnt].ruleset_id, e.cs_cpp_rule_id =
     IF (iskip > 0) 0.0
     ELSE dtempruleid
     ENDIF
     , e.encntr_id = workdata->encntrs[loopenc].encntr_id,
     e.person_id = workdata->encntrs[loopenc].person_id, e.active_ind = 1, e.updt_dt_tm =
     cnvtdatetime(sysdate),
     e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (validate(debug,- (1)) > 0)
    CALL echo(concat("LogCTError: ",trim(smessage)),0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (afteractionprocess(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub AfterActionProcess")
    CALL echo("----------------------------------")
    CALL echo(concat("Current UndoID: ",trim(cnvtstring(dundoid,17,2))))
   ENDIF
   IF (dundoid < 1)
    SELECT INTO "nl:"
     next_seq = seq(pft_activity_seq,nextval)"###############;rp0"
     FROM dual
     DETAIL
      dundoid = next_seq
     WITH nocounter
    ;end select
    INSERT  FROM cs_cpp_undo u
     SET u.cs_cpp_undo_id = dundoid, u.cs_cpp_rule_id = ruledata->rules[looprule].rule_id, u
      .encntr_id = ruledata->rules[looprule].encntr_id,
      u.person_id = ruledata->rules[looprule].person_id, u.active_ind = 1
     WITH nocounter
    ;end insert
   ENDIF
   IF ((adjustrequest->charge_item_id != 0))
    IF (validate(debug,- (1)) > 1)
     CALL echorecord(adjustrequest)
    ENDIF
    EXECUTE afc_ct_adjust_charge  WITH replace("REQUEST",adjustrequest), replace("REPLY",adjustreply)
    IF ((adjustreply->new_charge_item_id != 0))
     UPDATE  FROM charge c
      SET c.cs_cpp_undo_id = dundoid
      WHERE (c.charge_item_id=adjustreply->new_charge_item_id)
      WITH nocounter
     ;end update
     INSERT  FROM cs_cpp_undo_detail c
      SET c.cs_cpp_undo_detail_id = seq(pft_activity_seq,nextval), c.cs_cpp_undo_id = dundoid, c
       .charge_item_id = adjustreply->new_charge_item_id,
       c.original_ind = 0, c.active_ind = 1
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   IF ((ct_request->encntr_id != 0))
    IF (validate(debug,- (1)) > 1)
     CALL echorecord(ct_request)
    ENDIF
    EXECUTE ct_create_result_charge
    UPDATE  FROM charge c,
      (dummyt d  WITH seq = value(size(ct_reply->charges,5)))
     SET c.cs_cpp_undo_id = dundoid
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=ct_reply->charges[d.seq].charge_item_id))
     WITH nocounter
    ;end update
    INSERT  FROM cs_cpp_undo_detail c,
      (dummyt d  WITH seq = value(size(ct_reply->charges,5)))
     SET c.cs_cpp_undo_detail_id = seq(pft_activity_seq,nextval), c.cs_cpp_undo_id = dundoid, c
      .charge_item_id = ct_reply->charges[d.seq].charge_item_id,
      c.original_ind = 0, c.active_ind = 1
     PLAN (d)
      JOIN (c)
     WITH nocounter
    ;end insert
   ENDIF
   UPDATE  FROM charge c,
     (dummyt d1  WITH seq = value(size(ruledata->rules[looprule].conditions,5))),
     (dummyt d2  WITH seq = 1)
    SET c.cs_cpp_undo_qual_id = dundoid
    PLAN (d1
     WHERE maxrec(d2,size(ruledata->rules[looprule].conditions[d1.seq].charges,5)))
     JOIN (d2)
     JOIN (c
     WHERE (c.charge_item_id=ruledata->rules[looprule].conditions[d1.seq].charges[d2.seq].
     charge_item_id))
    WITH nocounter
   ;end update
   IF (size(addcreditreq->charge,5) != 0)
    IF (validate(debug,- (1)) > 1)
     CALL echorecord(addcreditreq)
    ENDIF
    EXECUTE afc_add_credit  WITH replace("REQUEST",addcreditreq), replace("REPLY",addcreditreply)
    UPDATE  FROM charge c,
      (dummyt d  WITH seq = value(size(addcreditreply->original_charge,5)))
     SET c.cs_cpp_undo_id = dundoid
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=addcreditreply->original_charge[d.seq].charge_item_id))
     WITH nocounter
    ;end update
    INSERT  FROM cs_cpp_undo_detail c,
      (dummyt d  WITH seq = value(size(addcreditreply->original_charge,5)))
     SET c.cs_cpp_undo_detail_id = seq(pft_activity_seq,nextval), c.cs_cpp_undo_id = dundoid, c
      .charge_item_id = addcreditreply->original_charge[d.seq].charge_item_id,
      c.original_ind = 1, c.active_ind = 1
     PLAN (d)
      JOIN (c)
     WITH nocounter
    ;end insert
    UPDATE  FROM charge c,
      (dummyt d  WITH seq = value(size(addcreditreply->charge,5)))
     SET c.cs_cpp_undo_id = dundoid
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=addcreditreply->charge[d.seq].charge_item_id))
     WITH nocounter
    ;end update
    INSERT  FROM cs_cpp_undo_detail c,
      (dummyt d  WITH seq = value(size(addcreditreply->charge,5)))
     SET c.cs_cpp_undo_detail_id = seq(pft_activity_seq,nextval), c.cs_cpp_undo_id = dundoid, c
      .charge_item_id = addcreditreply->charge[d.seq].charge_item_id,
      c.original_ind = 0, c.active_ind = 1
     PLAN (d)
      JOIN (c)
     WITH nocounter
    ;end insert
   ENDIF
   IF ((adjustreply->new_charge_item_id != 0)
    AND iskipforaddmod=0)
    SET cntfinal += 1
    IF (mod(cntfinal,10)=1
     AND cntfinal != 1)
     SET stat = alterlist(finalcharges->charges,(cntfinal+ 10))
    ENDIF
    SET finalcharges->charges[cntfinal].charge_item_id = adjustreply->new_charge_item_id
   ENDIF
   SET iskipforaddmod = 0
   IF (size(ct_reply->charges,5) >= 1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(ct_reply->charges,5)))
     PLAN (d)
     DETAIL
      cntfinal += 1
      IF (mod(cntfinal,10)=1
       AND cntfinal != 1)
       stat = alterlist(finalcharges->charges,(cntfinal+ 10))
      ENDIF
      finalcharges->charges[cntfinal].charge_item_id = ct_reply->charges[d.seq].charge_item_id
     WITH nocounter
    ;end select
   ENDIF
   IF (size(addcreditreply->charge,5) >= 1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(addcreditreply->charge,5)))
     PLAN (d)
     DETAIL
      cntfinal += 1
      IF (mod(cntfinal,10)=1
       AND cntfinal != 1)
       stat = alterlist(finalcharges->charges,(cntfinal+ 10))
      ENDIF
      finalcharges->charges[cntfinal].charge_item_id = addcreditreply->charge[d.seq].charge_item_id,
      finalcharges->charges[cntfinal].interface_file_id = addcreditreply->charge[d.seq].
      interface_file_id
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (processinterfaces(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ProcessInterfaces")
    CALL echo("----------------------------------")
   ENDIF
   SET stat = alterlist(finalcharges->charges,cntfinal)
   IF (size(finalcharges->charges,5) >= 1)
    SELECT INTO "nl:"
     FROM charge c,
      (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=finalcharges->charges[d.seq].charge_item_id))
     DETAIL
      finalcharges->charges[d.seq].interface_file_id = c.interface_file_id
     WITH nocounter
    ;end select
    SET cntfinal = 0
    SET cntfinal2 = 0
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,10)
    SET stat = alterlist(afcprofit_request->charges,10)
    SELECT INTO "nl:"
     FROM interface_file i,
      (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
     PLAN (d)
      JOIN (i
      WHERE (i.interface_file_id=finalcharges->charges[d.seq].interface_file_id))
     DETAIL
      IF (i.realtime_ind=1)
       cntfinal += 1
       IF (mod(cntfinal,10)=1
        AND cntfinal != 1)
        stat = alterlist(afcinterfacecharge_request->interface_charge,(cntfinal+ 10))
       ENDIF
       afcinterfacecharge_request->interface_charge[cntfinal].charge_item_id = finalcharges->charges[
       d.seq].charge_item_id
      ELSEIF (i.profit_type_cd > 0)
       cntfinal2 += 1
       IF (mod(cntfinal2,10)=1
        AND cntfinal2 != 1)
        stat = alterlist(afcprofit_request->charges,(cntfinal2+ 10))
       ENDIF
       afcprofit_request->charges[cntfinal2].charge_item_id = finalcharges->charges[d.seq].
       charge_item_id
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,cntfinal)
    SET stat = alterlist(afcprofit_request->charges,cntfinal2)
    IF (size(afcprofit_request->charges,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcprofit_request)
     ENDIF
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
      afcprofit_reply)
    ENDIF
    IF (size(afcinterfacecharge_request->interface_charge,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_request)
     ENDIF
     EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
      "REPLY",afcinterfacecharge_reply)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_reply)
     ENDIF
     IF ((afcinterfacecharge_reply->status_data.status="f"))
      CALL echo("afc_srv_interface_charge failed")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (roundprice(sroundmethod=vc,dprice=f8) =f8)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub RoundPrice")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE stempdir = vc WITH private
   DECLARE stempprec = vc WITH private
   DECLARE dtempprice = f8 WITH private, noconstant(0.0)
   DECLARE dholdamount = f8 WITH private, noconstant(0.0)
   SET stempdir = substring(1,2,sroundmethod)
   SET stempprec = substring(3,4,sroundmethod)
   IF (stempdir="RN")
    SET stempprec = "0.01"
   ENDIF
   SET dholdamount = (dprice * (1/ cnvtreal(stempprec)))
   IF (stempdir="RU")
    SET dholdamount = ceil(dholdamount)
   ELSEIF (stempdir="RD")
    SET dholdamount = floor(dholdamount)
   ELSEIF (stempdir="RS")
    SET dholdamount = round((dholdamount+ 0.000001),0)
   ELSEIF (stempdir="RN")
    SET dholdamount = cnvtint(dholdamount)
   ENDIF
   SET dtempprice = (dholdamount/ (1/ cnvtreal(stempprec)))
   RETURN(dtempprice)
 END ;Subroutine
 SUBROUTINE (conditionaddxpnomen(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ConditionAddXPNomen")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE numofphysicians = i4
   DECLARE numofcharges = i4
   DECLARE chgadded = i2
   DECLARE count = i4
   DECLARE numofdates = i4
   DECLARE ignorechgs = i2
   DECLARE physid = f8
   SET stat = initrec(charges)
   SET numofcharges = 0
   SET numofphysicians = 0
   SET numofdates = 0
   SET physid = 0
   SET dateofservice = 0
   SET chargecount = 0
   SET reviewcharges = 0
   SET count = 0
   SET stat = alterlist(charges->dateofservice,1)
   SET stat = alterlist(charges->dateofservice[1].physicians,1)
   FOR (loopact = 1 TO size(ruledata->rules[looprule].actions,5))
     IF (substring(1,12,ruledata->rules[looprule].actions[loopact].text)="ADD MODIFIER")
      SET sprocessstring = trim(substring(14,32000,ruledata->rules[looprule].actions[loopact].text),3
       )
      SET sprocessstring = substring(1,(findstring(" ",sprocessstring) - 1),sprocessstring)
     ENDIF
   ENDFOR
   IF (findstring(" ",ruledata->rules[looprule].conditions[loopcon].text,14) != 0)
    SET stempcondition = substring(17,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSE
    SET stempcondition = "80000-89999"
   ENDIF
   SET range1 = cnvtint(substring(1,(findstring("-",stempcondition) - 1),stempcondition))
   SET range2 = cnvtint(substring((findstring("-",stempcondition)+ 1),32000,stempcondition))
   SET loop_start_dt_tm = systimestamp
   FOR (loopchg = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
     IF (loopchg=1)
      SET charges->dateofservice[1].dateofservice = workdata->encntrs[loopenc].dts[loopdt].tier[
      looptier].charges[loopchg].service_dt_tm
      IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].perf_phys_id != 0))
       SET charges->dateofservice[1].physicians[1].perfphysicianid = workdata->encntrs[loopenc].dts[
       loopdt].tier[looptier].charges[loopchg].perf_phys_id
      ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].verify_phys_id
       != 0))
       SET charges->dateofservice[1].physicians[1].verifyphysicianid = workdata->encntrs[loopenc].
       dts[loopdt].tier[looptier].charges[loopchg].verify_phys_id
      ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].ord_phys_id !=
      0))
       SET charges->dateofservice[1].physicians[1].ordpysicianid = workdata->encntrs[loopenc].dts[
       loopdt].tier[looptier].charges[loopchg].ord_phys_id
      ENDIF
      SET numofphysicians += 1
      SET numofdates += 1
     ENDIF
     IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].perf_phys_id != 0))
      SET physid = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
      perf_phys_id
     ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].verify_phys_id
      != 0))
      SET physid = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
      verify_phys_id
     ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].ord_phys_id != 0
     ))
      SET physid = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].ord_phys_id
     ENDIF
     SET dateofservice = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
     service_dt_tm
     FOR (loopdate = 1 TO size(charges->dateofservice,5))
       FOR (loopphys = 1 TO size(charges->dateofservice[loopdate].physicians,5))
        IF (validate(debug,- (1)) > 1)
         CALL echo("for loopPhys count")
         CALL echo(loopphys)
         CALL echo(size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
         CALL echo(size(charges->dateofservice,5))
         CALL echo(size(charges->dateofservice[loopdate].physicians,5))
         CALL echo(charges->dateofservice[loopdate].dateofservice)
        ENDIF
        IF ((charges->dateofservice[loopdate].dateofservice=dateofservice)
         AND (((charges->dateofservice[loopdate].physicians[loopphys].perfphysicianid=physid)) OR ((
        charges->dateofservice[loopdate].physicians[loopphys].verifyphysicianid=physid))) )
         SET numofcharges = (size(charges->dateofservice[loopdate].physicians[loopphys].charges,5)+ 1
         )
         SET stat = alterlist(charges->dateofservice[loopdate].physicians[loopphys].charges,
          numofcharges)
         SET charges->dateofservice[loopdate].physicians[loopphys].charges[numofcharges].chg =
         loopchg
        ELSEIF (loopphys=size(charges->dateofservice[loopdate].physicians,5)
         AND (((charges->dateofservice[loopdate].physicians[loopphys].perfphysicianid != physid)) OR
        ((charges->dateofservice[loopdate].physicians[loopphys].verifyphysicianid=physid)))
         AND (charges->dateofservice[loopdate].dateofservice=dateofservice))
         SET numofphysicians = (size(charges->dateofservice[loopdate].physicians,5)+ 1)
         SET stat = alterlist(charges->dateofservice[loopdate].physicians,numofphysicians)
         SET stat = alterlist(charges->dateofservice[loopdate].physicians[numofphysicians].charges,1)
         IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].perf_phys_id !=
         0))
          SET charges->dateofservice[loopdate].physicians[numofphysicians].perfphysicianid = physid
         ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
         verify_phys_id != 0))
          SET charges->dateofservice[loopdate].physicians[numofphysicians].verifyphysicianid = physid
         ENDIF
         SET charges->dateofservice[loopdate].physicians[numofphysicians].charges[1].chg = loopchg
        ELSEIF (loopdate=size(charges->dateofservice)
         AND (charges->dateofservice[loopdate].dateofservice != dateofservice))
         SET numofdates += 1
         SET stat = alterlist(charges->dateofservice,(size(charges->dateofservice,5)+ 1))
         SET stat = alterlist(charges->dateofservice[size(charges->dateofservice)].physicians,1)
         SET stat = alterlist(charges->dateofservice[size(charges->dateofservice)].physicians[1].
          charges,1)
         SET charges->dateofservice[size(charges->dateofservice)].dateofservice = dateofservice
         IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].perf_phys_id !=
         0))
          SET charges->dateofservice[size(charges->dateofservice)].physicians[1].perfphysicianid =
          physid
         ELSEIF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
         verify_phys_id != 0))
          SET charges->dateofservice[size(charges->dateofservice)].physicians[1].verifyphysicianid =
          physid
         ENDIF
         SET charges->dateofservice[size(charges->dateofservice)].physicians[1].charges[1].chg =
         loopchg
        ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for sorting charges",script_and_detail_level_timer)
   SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
   SET loop_start_dt_tm = systimestamp
   FOR (loopdate = 1 TO size(charges->dateofservice,5))
     FOR (loopphys = 1 TO (size(charges->dateofservice[loopdate].physicians,5) - 1))
       FOR (loopchg = 1 TO size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
         SET ruledata->rules[looprule].person_id = workdata->encntrs[loopenc].dts[loopdt].tier[
         looptier].charges[charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg
         ].person_id
         SET ruledata->rules[looprule].encntr_id = workdata->encntrs[loopenc].dts[loopdt].tier[
         looptier].charges[charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg
         ].encntr_id
         FOR (loopcm = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
          charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].charge_mods,5))
           IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[
           loopdate].physicians[loopphys].charges[loopchg].chg].charge_used=0)
            AND findstring(concat(",",cnvtstring(workdata->encntrs[loopenc].dts[loopdt].tier[looptier
              ].charges[charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].
              charge_mods[loopcm].field1_id,17,2),","),scptlist))
            SET dtempid = cnvtreal(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
             charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].charge_mods[
             loopcm].field6)
            IF (dtempid >= range1
             AND dtempid <= range2)
             FOR (loopphys2 = (loopphys+ 1) TO size(charges->dateofservice[loopdate].physicians,5))
               FOR (loopchg2 = 1 TO size(charges->dateofservice[loopdate].physicians[loopphys2].
                charges,5))
                 FOR (loopcm2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
                  charges[charges->dateofservice[loopdate].physicians[loopphys2].charges[loopchg2].
                  chg].charge_mods,5))
                   IF (cnvtreal(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges
                    ->dateofservice[loopdate].physicians[loopphys2].charges[loopchg2].chg].
                    charge_mods[loopcm2].field6)=dtempid)
                    SET charges->dateofservice[loopdate].physicians[loopphys2].charges[loopchg2].
                    xpcharge = 1
                   ENDIF
                 ENDFOR
               ENDFOR
             ENDFOR
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for cpt check among charges",script_and_detail_level_timer)
 END ;Subroutine
 SUBROUTINE (conditionaddnomen(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ConditionAddNomen")
    CALL echo("----------------------------------")
   ENDIF
   FOR (loopact = 1 TO size(ruledata->rules[looprule].actions,5))
     IF (substring(1,12,ruledata->rules[looprule].actions[loopact].text)="ADD MODIFIER")
      SET sprocessstring = trim(substring(14,32000,ruledata->rules[looprule].actions[loopact].text),3
       )
      SET sprocessstring = substring(1,(findstring(" ",sprocessstring) - 1),sprocessstring)
     ENDIF
   ENDFOR
   IF (findstring(" ",ruledata->rules[looprule].conditions[loopcon].text,14) != 0)
    SET stempcondition = substring(17,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSE
    SET stempcondition = "80000-89999"
   ENDIF
   SET range1 = cnvtint(substring(1,(findstring("-",stempcondition) - 1),stempcondition))
   SET range2 = cnvtint(substring((findstring("-",stempcondition)+ 1),32000,stempcondition))
   SET stat = initrec(cptlist)
   SET loop_start_dt_tm = systimestamp
   FOR (loopchg = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
     SET ruledata->rules[looprule].person_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
     charges[loopchg].person_id
     SET ruledata->rules[looprule].encntr_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
     charges[loopchg].encntr_id
     SET icheckgood = 0
     IF (validate(debug,- (1)) > 0)
      CALL echo(concat("  Person_id: ",trim(cnvtstring(ruledata->rules[looprule].person_id,17,2))))
      CALL echo(concat("  Encntr_id: ",trim(cnvtstring(ruledata->rules[looprule].encntr_id,17,2))))
      CALL echo(concat("  Memory: ",trim(cnvtstring(curmem))))
      CALL echo(concat("  Charge_Item_ID = ",trim(cnvtstring(workdata->encntrs[loopenc].dts[loopdt].
          tier[looptier].charges[loopchg].charge_item_id,17,2))))
      CALL echo("  iCheckGood = 0")
     ENDIF
     FOR (loopcm = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
      charge_mods,5))
       IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_used=0)
        AND findstring(concat(",",cnvtstring(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
          charges[loopchg].charge_mods[loopcm].field1_id,17,2),","),scptlist))
        SET dtempid = cnvtreal(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg]
         .charge_mods[loopcm].field6)
        IF (dtempid >= range1
         AND dtempid <= range2
         AND icheckgood=0)
         SET icheckgood = 1
        ENDIF
        IF (icheckgood=1)
         SET icptfound = 0
         FOR (loopcptcheck = 1 TO size(cptlist->cptlist,5))
           IF ((cptlist->cptlist[loopcptcheck].cpt=dtempid))
            SET icptfound = 1
            SET loopcptcheck = size(cptlist->cptlist,5)
           ENDIF
         ENDFOR
         IF (icptfound=0)
          SET newsize = (size(cptlist->cptlist,5)+ 1)
          SET stat = alterlist(cptlist->cptlist,newsize)
          SET cptlist->cptlist[newsize].cpt = dtempid
          SET icheckgood = 0
         ENDIF
        ENDIF
        IF (validate(debug,- (1)) > 0)
         CALL echo(concat("     dTempID = ",trim(cnvtstring(dtempid,17,2))))
         CALL echo(concat("     iCheckGood = ",trim(cnvtstring(icheckgood))))
        ENDIF
       ENDIF
     ENDFOR
     IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].cs_cpp_undo_id != 0)
     )
      SET icheckgood = 0
     ELSE
      SET cnttemp += 1
      IF (mod(cnttemp,10)=1
       AND cnttemp != 1)
       SET stat = alterlist(ruledata->rules[looprule].conditions[loopcon].charges,(cnttemp+ 10))
      ENDIF
      SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].charge_item_id = workdata->
      encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_item_id
      SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].workdata_index = loopchg
      SET ruledata->rules[looprule].conditions[loopcon].quantity += workdata->encntrs[loopenc].dts[
      loopdt].tier[looptier].charges[loopchg].item_quantity
      SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
      IF (icheckgood=1)
       SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].firstchargeind = false
      ELSE
       SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].firstchargeind = true
      ENDIF
     ENDIF
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for adding modifiers to charges",script_and_detail_level_timer)
 END ;Subroutine
 SUBROUTINE (conditionaddl1nomen(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ConditionAddL1Nomen")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE numofphysicians = i4
   DECLARE numofcharges = i4
   DECLARE chgadded = i2
   DECLARE count = i4
   DECLARE numofdates = i4
   DECLARE ignorechgs = i2
   FOR (loopact = 1 TO size(ruledata->rules[looprule].actions,5))
     IF (substring(1,12,ruledata->rules[looprule].actions[loopact].text)="ADD MODIFIER")
      SET sprocessstring = trim(substring(14,32000,ruledata->rules[looprule].actions[loopact].text),3
       )
      SET sprocessstring = substring(1,(findstring(" ",sprocessstring) - 1),sprocessstring)
     ENDIF
   ENDFOR
   SET stempcondition = substring(17,32000,ruledata->rules[looprule].conditions[loopcon].text)
   SET range1 = cnvtint(substring(1,(findstring("-",stempcondition) - 1),stempcondition))
   SET range2 = cnvtint(substring((findstring("-",stempcondition)+ 1),32000,stempcondition))
   IF (validate(debug,- (1)) > 0)
    CALL echo(stempcondition)
    CALL echo(sprocessstring)
    CALL echo(range1)
    CALL echo(range2)
   ENDIF
   SET stat = initrec(charges)
   SET numofcharges = 0
   SET numofphysicians = 0
   SET numofdates = 0
   SET ordphysicianid = 0
   SET dateofservice = 0
   SET chargecount = 0
   SET reviewcharges = 0
   SET count = 0
   SET stat = alterlist(charges->dateofservice,1)
   SET stat = alterlist(charges->dateofservice[1].physicians,1)
   FOR (loopchg = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
     IF (loopchg=1)
      SET charges->dateofservice[1].dateofservice = workdata->encntrs[loopenc].dts[loopdt].tier[
      looptier].charges[loopchg].service_dt_tm
      SET charges->dateofservice[1].physicians[1].ordpysicianid = workdata->encntrs[loopenc].dts[
      loopdt].tier[looptier].charges[loopchg].ord_phys_id
      SET numofphysicians += 1
      SET numofdates += 1
     ENDIF
     SET ordphysicianid = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
     ord_phys_id
     SET dateofservice = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
     service_dt_tm
     FOR (loopdate = 1 TO size(charges->dateofservice,5))
       FOR (loopphys = 1 TO size(charges->dateofservice[loopdate].physicians,5))
        IF (validate(debug,- (1)) > 1)
         CALL echo("for loopPhys count")
         CALL echo(loopphys)
         CALL echo(size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
         CALL echo(size(charges->dateofservice,5))
         CALL echo(size(charges->dateofservice[loopdate].physicians,5))
         CALL echo(charges->dateofservice[loopdate].dateofservice)
        ENDIF
        IF ((charges->dateofservice[loopdate].dateofservice=dateofservice)
         AND (charges->dateofservice[loopdate].physicians[loopphys].ordpysicianid=ordphysicianid))
         SET numofcharges = (size(charges->dateofservice[loopdate].physicians[loopphys].charges,5)+ 1
         )
         SET stat = alterlist(charges->dateofservice[loopdate].physicians[loopphys].charges,
          numofcharges)
         SET charges->dateofservice[loopdate].physicians[loopphys].charges[numofcharges].chg =
         loopchg
        ELSEIF (loopphys=size(charges->dateofservice[loopdate].physicians,5)
         AND (charges->dateofservice[loopdate].physicians[loopphys].ordpysicianid != ordphysicianid)
         AND (charges->dateofservice[loopdate].dateofservice=dateofservice))
         SET numofphysicians = (size(charges->dateofservice[loopdate].physicians,5)+ 1)
         SET stat = alterlist(charges->dateofservice[loopdate].physicians,numofphysicians)
         SET stat = alterlist(charges->dateofservice[loopdate].physicians[numofphysicians].charges,1)
         SET charges->dateofservice[loopdate].physicians[numofphysicians].ordpysicianid =
         ordphysicianid
         SET charges->dateofservice[loopdate].physicians[numofphysicians].charges[1].chg = loopchg
        ELSEIF (loopdate=size(charges->dateofservice)
         AND (charges->dateofservice[loopdate].dateofservice != dateofservice))
         SET numofdates += 1
         SET stat = alterlist(charges->dateofservice,(size(charges->dateofservice,5)+ 1))
         SET stat = alterlist(charges->dateofservice[size(charges->dateofservice)].physicians,1)
         SET stat = alterlist(charges->dateofservice[size(charges->dateofservice)].physicians[1].
          charges,1)
         SET charges->dateofservice[size(charges->dateofservice)].dateofservice = dateofservice
         SET charges->dateofservice[size(charges->dateofservice)].physicians[1].ordpysicianid =
         ordphysicianid
         SET charges->dateofservice[size(charges->dateofservice)].physicians[1].charges[1].chg =
         loopchg
        ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   FOR (loopdate = 1 TO size(charges->dateofservice,5))
     FOR (loopphys = 1 TO size(charges->dateofservice[loopdate].physicians,5))
       SET charges->dateofservice[loopdate].physicians[loopphys].skipcharges = 0
       SET icheckgood = 1
       FOR (loopchg2 = 1 TO size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
         FOR (loopcm = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
          charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg2].chg].charge_mods,5)
          )
          SET dtempid = cnvtreal(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
           charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg2].chg].charge_mods[
           loopcm].field6)
          IF (dtempid >= range1
           AND dtempid <= range2)
           SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->
            dateofservice[loopdate].physicians[loopphys].charges[loopchg2].chg].charge_mods,5)
          ELSEIF (loopcm=size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->
           dateofservice[loopdate].physicians[loopphys].charges[loopchg2].chg].charge_mods,5))
           SET icheckgood = 0
          ENDIF
         ENDFOR
       ENDFOR
       IF (icheckgood != 1)
        SET charges->dateofservice[loopdate].physicians[loopphys].skipcharges = 1
       ENDIF
     ENDFOR
   ENDFOR
   SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
 END ;Subroutine
 SUBROUTINE (conditionexist(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ConditionExist")
    CALL echo("----------------------------------")
   ENDIF
   SET scdmtext = ""
   SET dtempid = 0.0
   SET sconditiontype = ""
   SET iexisttype = 1
   IF (substring(1,11,ruledata->rules[looprule].conditions[loopcon].text)="EXIST NOMEN")
    SET sconditiontype = exist_nomen
    SET stempcondition = substring(13,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSEIF (substring(1,9,ruledata->rules[looprule].conditions[loopcon].text)="EXIST REV")
    SET sconditiontype = exist_rev
    SET stempcondition = substring(11,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSEIF (substring(1,9,ruledata->rules[looprule].conditions[loopcon].text)="EXIST CDM")
    SET sconditiontype = exist_cdm
    SET stempcondition = substring(11,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSEIF (substring(1,9,ruledata->rules[looprule].conditions[loopcon].text)="EXIST ABN")
    SET sconditiontype = exist_abn
    SET stempcondition = substring(11,32000,ruledata->rules[looprule].conditions[loopcon].text)
   ELSE
    SET stempcondition = substring(10,32000,ruledata->rules[looprule].conditions[loopcon].text)
    SET iexisttype = 2
   ENDIF
   IF (findstring("WITH",stempcondition) != 0)
    IF (sconditiontype=exist_cdm)
     SET scdmtext = trim(substring(1,(findstring("WITH",stempcondition) - 2),stempcondition),3)
    ELSE
     SET dtempid = cnvtreal(substring(1,(findstring("WITH",stempcondition) - 2),stempcondition))
    ENDIF
    SET stempcondition = substring((findstring("WITH",stempcondition)+ 5),32000,stempcondition)
   ELSE
    IF (sconditiontype=exist_cdm)
     SET scdmtext = trim(stempcondition)
    ELSE
     SET dtempid = cnvtreal(stempcondition)
    ENDIF
    SET stempcondition = ""
   ENDIF
   IF (sconditiontype=exist_nomen)
    SET dtempid = getactivenomenid(dtempid)
   ENDIF
   FOR (loopchg = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
     IF (validate(debug,- (1)) > 0)
      CALL echo(concat("  Memory: ",trim(cnvtstring(curmem))))
     ENDIF
     SET icheckgood = 0
     IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_used=0))
      IF (iexisttype=1)
       FOR (loopcm = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg]
        .charge_mods,5))
         SET sbillcodetypemeaning = uar_get_code_meaning(workdata->encntrs[loopenc].dts[loopdt].tier[
          looptier].charges[loopchg].charge_mods[loopcm].field1_id)
         SET sbillcodetypemeaning = trim(sbillcodetypemeaning,3)
         CASE (sconditiontype)
          OF exist_nomen:
           IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_mods[
           loopcm].nomen_id=dtempid))
            SET icheckgood = 1
            SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
             charge_mods,5)
           ENDIF
          OF exist_rev:
           IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_mods[
           loopcm].field3_id=dtempid))
            SET icheckgood = 1
            SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
             charge_mods,5)
           ENDIF
          OF exist_abn:
           IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].abn_status_cd=
           dtempid))
            SET icheckgood = 1
            SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
             charge_mods,5)
           ENDIF
          OF exist_cdm:
           IF (sbillcodetypemeaning=cdm_sched
            AND cnvtupper(trim(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg]
             .charge_mods[loopcm].field6,3))=cnvtupper(scdmtext))
            SET icheckgood = 1
            SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].
             charge_mods,5)
           ENDIF
         ENDCASE
       ENDFOR
      ELSEIF (iexisttype=2
       AND (workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].bill_item_id=
      dtempid))
       SET icheckgood = 1
      ENDIF
     ENDIF
     IF (icheckgood=1)
      SET ruledata->rules[looprule].person_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
      .charges[loopchg].person_id
      SET ruledata->rules[looprule].encntr_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
      .charges[loopchg].encntr_id
      IF ((ruledata->rules[looprule].service_res_cd < 1))
       SELECT INTO "nl:"
        FROM charge c,
         charge_event_act cea
        PLAN (c
         WHERE (c.charge_item_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
         loopchg].charge_item_id))
         JOIN (cea
         WHERE cea.charge_event_act_id=c.charge_event_act_id)
        DETAIL
         ruledata->rules[looprule].service_res_cd = cea.service_resource_cd
        WITH nocounter
       ;end select
      ENDIF
      SET cnttemp += 1
      IF (mod(cnttemp,10)=1
       AND cnttemp != 1)
       SET stat = alterlist(ruledata->rules[looprule].conditions[loopcon].charges,(cnttemp+ 10))
      ENDIF
      SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].charge_item_id = workdata->
      encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_item_id
      SET ruledata->rules[looprule].conditions[loopcon].charges[cnttemp].workdata_index = loopchg
      SET ruledata->rules[looprule].conditions[loopcon].quantity += workdata->encntrs[loopenc].dts[
      loopdt].tier[looptier].charges[loopchg].item_quantity
      IF (validate(debug,- (1)) > 0)
       CALL echo(concat("  Person_id: ",trim(cnvtstring(ruledata->rules[looprule].person_id,17,2))))
       CALL echo(concat("  Encntr_id: ",trim(cnvtstring(ruledata->rules[looprule].encntr_id,17,2))))
       CALL echo(concat("  Charge_item_id: ",trim(cnvtstring(workdata->encntrs[loopenc].dts[loopdt].
           tier[looptier].charges[loopchg].charge_item_id,17,2))))
       CALL echo(concat("  Current Total Quantity: ",trim(cnvtstring(ruledata->rules[looprule].
           conditions[loopcon].quantity))))
       CALL echo(concat("  Item Quantity: ",trim(cnvtstring(workdata->encntrs[loopenc].dts[loopdt].
           tier[looptier].charges[loopchg].item_quantity))))
      ENDIF
      IF (stempcondition="")
       SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
      ELSE
       IF (findstring("QUANTITY",stempcondition) != 0)
        IF (findstring("BETWEEN",stempcondition) != 0)
         IF (findstring(",",stempcondition) != 0)
          SET istartpos = findstring(" ",stempcondition)
          SET ssubquantity = substring(istartpos,((size(stempcondition,1) - istartpos)+ 1),
           stempcondition)
          SET ifindpos = findstring(",",ssubquantity)
          SET range1 = cnvtint(substring(istartpos,(ifindpos - istartpos),ssubquantity))
          SET range2 = cnvtint(substring((ifindpos+ 1),(size(ssubquantity,1) - ifindpos),ssubquantity
            ))
          IF (validate(debug,- (1)) > 0)
           CALL echo(concat("     Range1: ",trim(cnvtstring(range1))))
           CALL echo(concat("     Range2: ",trim(cnvtstring(range2))))
          ENDIF
          IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) >= range1
           AND cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) <= range2)
           SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
          ELSE
           SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
          ENDIF
         ELSE
          CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt BETWEEN clause"),0)
         ENDIF
        ELSEIF (findstring(">=",stempcondition) != 0)
         SET range1 = cnvtint(trim(substring((findstring(">=",stempcondition)+ 2),100,stempcondition),
           3))
         IF (validate(debug,- (1)) > 0)
          CALL echo(concat("     >= Range1: ",trim(cnvtstring(range1))))
         ENDIF
         IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) >= range1)
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
         ELSE
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
         ENDIF
        ELSEIF (findstring("<=",stempcondition) != 0)
         SET range1 = cnvtint(trim(substring((findstring("<=",stempcondition)+ 2),100,stempcondition),
           3))
         IF (validate(debug,- (1)) > 0)
          CALL echo(concat("     <= Range1: ",trim(cnvtstring(range1))))
         ENDIF
         IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) <= range1)
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
         ELSE
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
         ENDIF
        ELSEIF (findstring("=",stempcondition) != 0)
         SET range1 = cnvtint(trim(substring((findstring("=",stempcondition)+ 1),100,stempcondition),
           3))
         IF (validate(debug,- (1)) > 0)
          CALL echo(concat("     = Range1: ",trim(cnvtstring(range1))))
         ENDIF
         IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity)=range1)
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
         ELSE
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
         ENDIF
        ELSEIF (findstring(">",stempcondition) != 0)
         SET range1 = cnvtint(trim(substring((findstring(">",stempcondition)+ 1),100,stempcondition),
           3))
         IF (validate(debug,- (1)) > 0)
          CALL echo(concat("     > Range1: ",trim(cnvtstring(range1))))
         ENDIF
         IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) > range1)
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
         ELSE
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
         ENDIF
        ELSEIF (findstring("<",stempcondition) != 0)
         SET range1 = cnvtint(trim(substring((findstring("<",stempcondition)+ 1),100,stempcondition),
           3))
         IF (validate(debug,- (1)) > 0)
          CALL echo(concat("     < Range1: ",trim(cnvtstring(range1))))
         ENDIF
         IF (cnvtint(ruledata->rules[looprule].conditions[loopcon].quantity) < range1)
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 1
         ELSE
          SET ruledata->rules[looprule].conditions[loopcon].condition_true = 0
         ENDIF
        ELSE
         CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown condition comparison operator"),
          0)
        ENDIF
       ELSE
        CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt condition WITH clause"),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (actionreplace(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionReplace")
    CALL echo("----------------------------------")
   ENDIF
   SET ifindpos = findstring(" WITH ",ruledata->rules[looprule].actions[loopact].text)
   IF (ifindpos != 0)
    SET stat = initrec(tempreplace)
    SET tempreplace->replace_valid = 1
    SET stempaction = substring(1,(ifindpos - 1),ruledata->rules[looprule].actions[loopact].text)
    SET stempaction = substring(9,32000,stempaction)
    SET stempaction2 = substring((ifindpos+ 6),32000,ruledata->rules[looprule].actions[loopact].text)
    IF (findstring("2ND",ruledata->rules[looprule].actions[loopact].text) != 0)
     SET istartpos = 2
     SET stempaction = substring(4,32000,stempaction)
    ELSE
     SET istartpos = 1
    ENDIF
    SET stempaction = replace(stempaction," AND ",",",0)
    SET stempaction2 = replace(stempaction2," AND ",",",0)
    SET ifindpos = 0
    WHILE ((ifindpos != - (1)))
      SET ifindpos += 1
      SET sprocessstring = piece(stempaction,",",ifindpos,"<none>")
      IF (sprocessstring="<none>")
       IF (ifindpos=1)
        SET stat = alterlist(tempreplace->source,ifindpos)
        SET tempreplace->source[ifindpos].match_string = trim(stempaction,3)
       ENDIF
       SET ifindpos = - (1)
      ELSE
       SET stat = alterlist(tempreplace->source,ifindpos)
       SET tempreplace->source[ifindpos].match_string = trim(sprocessstring,3)
      ENDIF
    ENDWHILE
    SET ifindpos = 0
    WHILE ((ifindpos != - (1)))
      SET ifindpos += 1
      SET sprocessstring = piece(stempaction2,",",ifindpos,"<none>")
      IF (sprocessstring="<none>")
       IF (ifindpos=1)
        SET stat = alterlist(tempreplace->dest,ifindpos)
        SET tempreplace->dest[ifindpos].bill_item_id = cnvtreal(substring(1,(findstring(
           " SET QUANTITY",stempaction2) - 1),stempaction2))
        SET tempreplace->dest[ifindpos].quantity = cnvtreal(substring((findstring(" ",stempaction2,1,
           1)+ 1),32000,stempaction2))
       ENDIF
       SET ifindpos = - (1)
      ELSE
       SET stat = alterlist(tempreplace->dest,ifindpos)
       SET tempreplace->dest[ifindpos].bill_item_id = cnvtreal(substring(1,(findstring(
          " SET QUANTITY",sprocessstring) - 1),sprocessstring))
       SET tempreplace->dest[ifindpos].quantity = cnvtreal(substring((findstring(" ",sprocessstring,1,
          1)+ 1),32000,sprocessstring))
      ENDIF
    ENDWHILE
    IF (validate(debug,- (1)) > 1)
     CALL echorecord(tempreplace)
    ENDIF
    SET tempreplace->replace_valid = 1
    WHILE ((tempreplace->replace_valid=1))
      SET tempreplace->replace_valid = 1
      FOR (loopcnt2 = 1 TO size(tempreplace->source,5))
        SET tempreplace->source[loopcnt2].charge_item_id = 0.0
        FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
          IF (findstring(tempreplace->source[loopcnt2].match_string,ruledata->rules[looprule].
           conditions[loopcon].text) != 0)
           FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
             IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].replace_used=0))
              SET ruledata->rules[looprule].conditions[loopcon].charges[loopchg].replace_used = 1
              SET tempreplace->source[loopcnt2].charge_item_id = ruledata->rules[looprule].
              conditions[loopcon].charges[loopchg].charge_item_id
              SET loopchg = size(ruledata->rules[looprule].conditions[loopcon].charges,5)
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
        IF ((tempreplace->source[loopcnt2].charge_item_id < 1))
         SET tempreplace->replace_valid = 0
        ENDIF
      ENDFOR
      IF (validate(debug,- (1)) > 1)
       CALL echorecord(tempreplace)
      ENDIF
      IF ((tempreplace->replace_valid=1))
       SET stat = initrec(addcreditreq)
       SET stat = initrec(addcreditreply)
       SET stat = initrec(ct_request)
       SET stat = initrec(ct_reply)
       IF (istartpos=2)
        SET istartpos = 1
       ELSE
        FOR (loopcnt2 = 1 TO size(tempreplace->source,5))
          SET addcreditreq->charge_qual = 0
          SET stat = initrec(addcreditreq)
          FOR (loopchg = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
            IF ((tempreplace->source[loopcnt2].charge_item_id=workdata->encntrs[loopenc].dts[loopdt].
            tier[looptier].charges[loopchg].charge_item_id))
             SET addcreditreq->charge_qual += 1
             SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
             SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
             loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_item_id
             SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
             SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg].charge_used
              = 1
             CALL afteractionprocess(1)
             SET loopchg = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
            ENDIF
          ENDFOR
        ENDFOR
        SET stat = initrec(addcreditreq)
        SET stat = initrec(addcreditreply)
        FOR (loopcnt2 = 1 TO size(tempreplace->dest,5))
          SET stat = initrec(ct_request)
          SET stat = initrec(ct_reply)
          SELECT INTO "nl:"
           FROM bill_item b
           WHERE (b.bill_item_id=tempreplace->dest[loopcnt2].bill_item_id)
           DETAIL
            ct_request->ref_id = b.ext_parent_reference_id, ct_request->ref_cont_cd = b
            .ext_parent_contributor_cd
           WITH nocounter
          ;end select
          SET ct_request->person_id = ruledata->rules[looprule].person_id
          SET ct_request->encntr_id = ruledata->rules[looprule].encntr_id
          SET ct_request->service_res_cd = ruledata->rules[looprule].service_res_cd
          SET ct_request->quantity = tempreplace->dest[loopcnt2].quantity
          SET ct_request->service_dt_tm = workdata->encntrs[loopenc].dts[loopdt].service_dt_tm
          CALL afteractionprocess(1)
        ENDFOR
       ENDIF
      ENDIF
    ENDWHILE
   ELSE
    CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt replace action, missing WITH"),0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (actionaddxpmodifiertorange(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionAddXPModifierToRange")
    CALL echo("----------------------------------")
   ENDIF
   SET stat = initrec(addcmrequest)
   SET stat = initrec(addcmreply)
   SET validencounter = 0
   SET dmodifiercvalue = 0.0
   SET loop_start_dt_tm = systimestamp
   FOR (loopdate = 1 TO size(charges->dateofservice,5))
     FOR (loopphys = 1 TO size(charges->dateofservice[loopdate].physicians,5))
       FOR (loopchg = 1 TO size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
         IF ((charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].xpcharge=1))
          IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[
          loopdate].physicians[loopphys].charges[loopchg].chg].charge_used != 1))
           SET stat = initrec(addcreditreq)
           SET stat = initrec(addcreditreply)
           SET stat = initrec(adjustrequest)
           SET stat = initrec(adjustreply)
           SET addcreditreq->charge_qual = 0
           DECLARE cemcount = i4 WITH noconstant(0)
           SET stat = alterlist(cemrequest->objarray,cemcount)
           SELECT INTO "nl:"
            FROM charge_event_mod c
            WHERE (c.charge_event_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
            charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].
            charge_event_id)
             AND (c.charge_event_mod_type_cd=code_val->13019_billcode)
             AND c.field10="afc_ct_execute"
            DETAIL
             cemcount += 1, stat = alterlist(cemrequest->objarray,cemcount), cemrequest->objarray[
             cemcount].action_type = "DEL",
             cemrequest->objarray[cemcount].charge_event_mod_id = c.charge_event_mod_id, cemrequest->
             objarray[cemcount].charge_event_id = c.charge_event_id, cemrequest->objarray[cemcount].
             updt_cnt = c.updt_cnt
            WITH nocounter
           ;end select
           IF (cemcount > 0)
            EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
             cemreply)
            IF ((cemreply->status_data.status != "S"))
             CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
             IF (validate(debug,- (1)) > 0)
              CALL echorecord(cemrequest)
              CALL echorecord(cemreply)
             ENDIF
            ENDIF
           ELSE
            CALL logmessage(curprog,"No existing charge_event_mods found",log_debug)
           ENDIF
           SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
           charges[charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].
           charge_item_id
           SET iskipforaddmod = 1
           SET addcreditreq->charge_qual += 1
           SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
           SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
           loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[loopdate].physicians[
           loopphys].charges[loopchg].chg].charge_item_id
           SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
           SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[
           loopdate].physicians[loopphys].charges[loopchg].chg].charge_used = 1
           CALL afteractionprocess(1)
           SET addcmrequest->charge_mod_qual += 2
           SET iaddcmcnt = addcmrequest->charge_mod_qual
           SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
           SET addcmrequest->charge_mod[(iaddcmcnt - 1)].action_type = "ADD"
           SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_item_id = adjustreply->
           new_charge_item_id
           SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_mod_type_cd = code_val->
           13019_suspense
           SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field1_id = code_val->13030_noauth
           SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field6 =
           "Release authorization needed for added CPT Modifier"
           SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
           SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->new_charge_item_id
           SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = 0.0
           SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->14002_modifier
           SET addcmrequest->charge_mod[iaddcmcnt].field2_id = (workdata->encntrs[loopenc].dts[loopdt
           ].tier[looptier].charges[charges->dateofservice[loopdate].physicians[loopphys].charges[
           loopchg].chg].next_cpt_mod_seq+ 1)
           IF (sprocessstring="XP")
            SET addcmrequest->charge_mod[iaddcmcnt].field6 = "XP"
            SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
             17769_modxp)
            SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
            SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modxp
            SET dmodifiercvalue = code_val->17769_modxp
           ELSEIF (sprocessstring="59")
            SET addcmrequest->charge_mod[iaddcmcnt].field6 = "59"
            SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
             17769_mod59)
            SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
            SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_mod59
            SET dmodifiercvalue = code_val->17769_mod59
           ELSE
            CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown modifier to add"),0)
           ENDIF
           SET validencounter = 1
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for adding xp modifier",script_and_detail_level_timer)
   IF (validencounter=1)
    CALL logmodcapability(workdata->encntrs[loopenc].encntr_id,xmod_collector_id)
   ENDIF
   IF (validate(addcmrequest->charge_mod)=1)
    IF (size(addcmrequest->charge_mod,5) > 0)
     SET addcmrequest->charge_mod_qual = size(addcmrequest->charge_mod,5)
     SET stat = initrec(adjustrequest)
     SET stat = initrec(adjustreply)
     SET stat = initrec(addcreditreq)
     SET stat = initrec(addcreditreply)
     IF (validate(debug,- (1)) > 0)
      CALL echo("call afc_add_charge_mod")
     ENDIF
     EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addcmrequest), replace("REPLY",addcmreply)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(addcmreply)
     ENDIF
     CALL inactivatedupchargeeventmod(code_val->14002_modifier,dmodifiercvalue)
     IF ((addcmreply->status_data.status="S"))
      UPDATE  FROM charge c,
        (dummyt d  WITH seq = value(size(addcmrequest->charge_mod,5)))
       SET c.process_flg = 2
       PLAN (d)
        JOIN (c
        WHERE (c.charge_item_id=addcmrequest->charge_mod[d.seq].charge_item_id))
       WITH nocounter
      ;end update
      CALL afteractionprocess(1)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (actionaddl1modifiertorange(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionAddL1ModifierToRange")
    CALL echo("----------------------------------")
   ENDIF
   SET stat = initrec(addcmrequest)
   SET stat = initrec(addcmreply)
   SET validencounter = 0
   SET loop_start_dt_tm = systimestamp
   FOR (loopdate = 1 TO size(charges->dateofservice,5))
     IF ((charges->dateofservice[loopdate].skipdate != 1))
      FOR (loopphys = 1 TO size(charges->dateofservice[loopdate].physicians,5))
        IF ((charges->dateofservice[loopdate].physicians[loopphys].skipcharges != 1))
         FOR (loopchg = 1 TO size(charges->dateofservice[loopdate].physicians[loopphys].charges,5))
           IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[
           loopdate].physicians[loopphys].charges[loopchg].chg].charge_used != 1))
            IF (validate(debug,- (1)) > 1)
             CALL echo("Charge index to recieve mod")
             CALL echo(loopchg)
             CALL echo(charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg)
             CALL echo(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->
              dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].charge_used)
            ENDIF
            SET stat = initrec(addcreditreq)
            SET stat = initrec(addcreditreply)
            SET stat = initrec(adjustrequest)
            SET stat = initrec(adjustreply)
            SET addcreditreq->charge_qual = 0
            DECLARE cemcount = i4 WITH noconstant(0)
            SET stat = alterlist(cemrequest->objarray,cemcount)
            SELECT INTO "nl:"
             FROM charge_event_mod c
             WHERE (c.charge_event_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
             charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].
             charge_event_id)
              AND (c.charge_event_mod_type_cd=code_val->13019_billcode)
              AND c.field10="afc_ct_execute"
             DETAIL
              cemcount += 1, stat = alterlist(cemrequest->objarray,cemcount), cemrequest->objarray[
              cemcount].action_type = "DEL",
              cemrequest->objarray[cemcount].charge_event_mod_id = c.charge_event_mod_id, cemrequest
              ->objarray[cemcount].charge_event_id = c.charge_event_id, cemrequest->objarray[cemcount
              ].updt_cnt = c.updt_cnt
             WITH nocounter
            ;end select
            IF (cemcount > 0)
             EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
              cemreply)
             IF ((cemreply->status_data.status != "S"))
              CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
              IF (validate(debug,- (1)) > 0)
               CALL echorecord(cemrequest)
               CALL echorecord(cemreply)
              ENDIF
             ENDIF
            ELSE
             CALL logmessage(curprog,"No existing charge_event_mods found",log_debug)
            ENDIF
            SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
            .charges[charges->dateofservice[loopdate].physicians[loopphys].charges[loopchg].chg].
            charge_item_id
            SET iskipforaddmod = 1
            SET addcreditreq->charge_qual += 1
            SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
            SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
            loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[loopdate].physicians[
            loopphys].charges[loopchg].chg].charge_item_id
            SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
            SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[charges->dateofservice[
            loopdate].physicians[loopphys].charges[loopchg].chg].charge_used = 1
            CALL afteractionprocess(1)
            SET addcmrequest->charge_mod_qual += 2
            SET iaddcmcnt = addcmrequest->charge_mod_qual
            SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].action_type = "ADD"
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_item_id = adjustreply->
            new_charge_item_id
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_mod_type_cd = code_val->
            13019_suspense
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field1_id = code_val->13030_noauth
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field6 =
            "Release authorization needed for added CPT Modifier"
            SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
            SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->new_charge_item_id
            SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = 0.0
            SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->14002_modifier
            SET addcmrequest->charge_mod[iaddcmcnt].field2_id = (workdata->encntrs[loopenc].dts[
            loopdt].tier[looptier].charges[charges->dateofservice[loopdate].physicians[loopphys].
            charges[loopchg].chg].next_cpt_mod_seq+ 1)
            IF (sprocessstring="L1")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "L1"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_modl1)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modl1
            ELSE
             CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown modifier to add"),0)
            ENDIF
            SET validencounter = 1
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for adding L1 modifier",script_and_detail_level_timer)
   IF (validencounter=1)
    CALL logmodcapability(workdata->encntrs[loopenc].encntr_id,l1_collector_id)
   ENDIF
   IF (validate(addcmrequest->charge_mod)=1)
    IF (size(addcmrequest->charge_mod,5) > 0)
     SET addcmrequest->charge_mod_qual = size(addcmrequest->charge_mod,5)
     SET stat = initrec(adjustrequest)
     SET stat = initrec(adjustreply)
     SET stat = initrec(addcreditreq)
     SET stat = initrec(addcreditreply)
     IF (validate(debug,- (1)) > 0)
      CALL echo("call afc_add_charge_mod")
     ENDIF
     EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addcmrequest), replace("REPLY",addcmreply)
     CALL inactivatedupchargeeventmod(code_val->14002_modifier,code_val->17769_modl1)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(addcmreply)
     ENDIF
     CALL afteractionprocess(1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (actionaddmodifiertorange(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionAddModifierToRange")
    CALL echo("----------------------------------")
   ENDIF
   SET validencounter = 0
   SET sprocessstring = trim(substring(14,32000,ruledata->rules[looprule].actions[loopact].text),3)
   IF (findstring(" ",sprocessstring) != 0)
    SET sprocessstring = substring(1,(findstring(" ",sprocessstring) - 1),sprocessstring)
   ENDIF
   SET dmodifiercvalue = 0.0
   SET loop_start_dt_tm = systimestamp
   FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
     IF (findstring("EXIST ADD NOMEN",ruledata->rules[looprule].conditions[loopcon].text) != 0)
      SET stat = initrec(addcmrequest)
      SET stat = initrec(addcmreply)
      IF (size(ruledata->rules[looprule].conditions[loopcon].charges,5) > 0)
       FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
         FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
           IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
           loopchg2)
            AND (ruledata->rules[looprule].conditions[loopcon].charges[loopchg].firstchargeind=false)
           )
            SET stat = initrec(addcreditreq)
            SET stat = initrec(addcreditreply)
            SET stat = initrec(adjustrequest)
            SET stat = initrec(adjustreply)
            SET addcreditreq->charge_qual = 0
            DECLARE cemcount = i4 WITH noconstant(0)
            SET stat = alterlist(cemrequest->objarray,cemcount)
            SELECT INTO "nl:"
             FROM charge_event_mod c
             WHERE (c.charge_event_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
             loopchg2].charge_event_id)
              AND (c.charge_event_mod_type_cd=code_val->13019_billcode)
              AND c.field10="afc_ct_execute"
             DETAIL
              cemcount += 1, stat = alterlist(cemrequest->objarray,cemcount), cemrequest->objarray[
              cemcount].action_type = "DEL",
              cemrequest->objarray[cemcount].charge_event_mod_id = c.charge_event_mod_id, cemrequest
              ->objarray[cemcount].charge_event_id = c.charge_event_id, cemrequest->objarray[cemcount
              ].updt_cnt = c.updt_cnt
             WITH nocounter
            ;end select
            IF (cemcount > 0)
             EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
              cemreply)
             IF ((cemreply->status_data.status != "S"))
              CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
              IF (validate(debug,- (1)) > 0)
               CALL echorecord(cemrequest)
               CALL echorecord(cemreply)
              ENDIF
             ENDIF
            ELSE
             CALL logmessage(curprog,"No existing charge_event_mods found",log_debug)
            ENDIF
            SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
            .charges[loopchg2].charge_item_id
            SET iskipforaddmod = 1
            SET addcreditreq->charge_qual += 1
            SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
            SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
            loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
            SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
            SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
             = 1
            CALL afteractionprocess(1)
            SET addcmrequest->charge_mod_qual += 2
            SET iaddcmcnt = addcmrequest->charge_mod_qual
            SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].action_type = "ADD"
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_item_id = adjustreply->
            new_charge_item_id
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_mod_type_cd = code_val->
            13019_suspense
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field1_id = code_val->13030_noauth
            SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field6 =
            "Release authorization needed for added CPT Modifier"
            SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
            SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->new_charge_item_id
            SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = 0.0
            SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->14002_modifier
            SET addcmrequest->charge_mod[iaddcmcnt].field2_id = (workdata->encntrs[loopenc].dts[
            loopdt].tier[looptier].charges[loopchg2].next_cpt_mod_seq+ 1)
            IF (sprocessstring="59")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "59"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_mod59)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_mod59
             SET dmodifiercvalue = code_val->17769_mod59
            ELSEIF (sprocessstring="76")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "76"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_mod76)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_mod76
             SET dmodifiercvalue = code_val->17769_mod76
            ELSEIF (sprocessstring="91")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "91"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_mod91)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_mod91
             SET dmodifiercvalue = code_val->17769_mod91
            ELSEIF (sprocessstring="XS")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "XS"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_modxs)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modxs
             SET dmodifiercvalue = code_val->17769_modxs
            ELSEIF (sprocessstring="XU")
             SET addcmrequest->charge_mod[iaddcmcnt].field6 = "XU"
             SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
              17769_modxu)
             SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
             SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modxu
             SET dmodifiercvalue = code_val->17769_modxu
            ELSE
             CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown modifier to add"),0)
            ENDIF
            SET validencounter = 1
            SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
           ENDIF
         ENDFOR
       ENDFOR
       IF (((sprocessstring="XU") OR (sprocessstring="XS")) )
        IF (validencounter=1)
         CALL logmodcapability(workdata->encntrs[loopenc].encntr_id,xmod_collector_id)
        ENDIF
       ENDIF
       IF (validate(addcmrequest->charge_mod)=1)
        IF (size(addcmrequest->charge_mod,5) > 0)
         SET addcmrequest->charge_mod_qual = size(addcmrequest->charge_mod,5)
         SET stat = initrec(adjustrequest)
         SET stat = initrec(adjustreply)
         SET stat = initrec(addcreditreq)
         SET stat = initrec(addcreditreply)
         IF (validate(debug,- (1)) > 0)
          CALL echo("call afc_add_charge_mod")
         ENDIF
         EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addcmrequest), replace("REPLY",addcmreply
          )
         IF (validate(debug,- (1)) > 1)
          CALL echorecord(addcmreply)
         ENDIF
         CALL inactivatedupchargeeventmod(code_val->14002_modifier,dmodifiercvalue)
         IF ((addcmreply->status_data.status="S"))
          UPDATE  FROM charge c,
            (dummyt d  WITH seq = value(size(addcmrequest->charge_mod,5)))
           SET c.process_flg = 2
           PLAN (d)
            JOIN (c
            WHERE (c.charge_item_id=addcmrequest->charge_mod[d.seq].charge_item_id))
           WITH nocounter
          ;end update
          CALL afteractionprocess(1)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for adding modifier",script_and_detail_level_timer)
 END ;Subroutine
 SUBROUTINE (actioncreate(dummy=i2) =null)
  IF (validate(debug,- (1)) > 0)
   CALL echo("Begin Sub ActionCreate")
   CALL echo("----------------------------------")
  ENDIF
  IF (findstring("SET",ruledata->rules[looprule].actions[loopact].text) != 0)
   SET sprocessstring = ruledata->rules[looprule].actions[loopact].text
   SET sprocessstring = substring(8,(findstring(" ",sprocessstring,8) - 8),sprocessstring)
   IF (findstring("QUANTITY",ruledata->rules[looprule].actions[loopact].text) != 0)
    IF (findstring("=",ruledata->rules[looprule].actions[loopact].text) != 0)
     SET stempaction = trim(substring((findstring("=",ruledata->rules[looprule].actions[loopact].text
        )+ 2),32000,ruledata->rules[looprule].actions[loopact].text),3)
     SET stat = initrec(addcreditreq)
     SET stat = initrec(addcreditreply)
     SET stat = initrec(ct_request)
     SET stat = initrec(ct_reply)
     SELECT INTO "nl:"
      FROM bill_item b
      WHERE b.bill_item_id=cnvtreal(sprocessstring)
      DETAIL
       ct_request->ref_id = b.ext_parent_reference_id, ct_request->ref_cont_cd = b
       .ext_parent_contributor_cd
      WITH nocounter
     ;end select
     SET ct_request->person_id = ruledata->rules[looprule].person_id
     SET ct_request->encntr_id = ruledata->rules[looprule].encntr_id
     SET ct_request->service_res_cd = ruledata->rules[looprule].service_res_cd
     SET ct_request->quantity = cnvtint(stempaction)
     SET ct_request->service_dt_tm = workdata->encntrs[loopenc].dts[loopdt].service_dt_tm
     CALL afteractionprocess(1)
    ELSE
     CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown quantity operator for create action"
       ),0)
    ENDIF
   ELSE
    CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Create action missing QUANTITY specification"
      ),0)
   ENDIF
  ELSE
   CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Create action missing SET clause"),0)
  ENDIF
 END ;Subroutine
 SUBROUTINE (actioncredit(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionCredit")
    CALL echo("----------------------------------")
   ENDIF
   SET sprocessstring = ruledata->rules[looprule].actions[loopact].text
   SET sprocessstring = substring(8,32000,sprocessstring)
   SET loop_start_dt_tm = systimestamp
   FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
     SET stat = initrec(addcreditreq)
     SET stat = initrec(addcreditreply)
     SET stat = initrec(ct_request)
     SET stat = initrec(ct_reply)
     SET addcreditreq->charge_qual = 0
     IF (findstring(sprocessstring,ruledata->rules[looprule].conditions[loopcon].text) != 0)
      FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
        FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
          IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=loopchg2
          ))
           SET addcreditreq->charge_qual += 1
           SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
           SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
           loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
           SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
           SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used =
           1
           SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
          ENDIF
        ENDFOR
      ENDFOR
      CALL afteractionprocess(1)
     ENDIF
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for action credit",script_and_detail_level_timer)
 END ;Subroutine
 SUBROUTINE (actionaddmodifiertonomen(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionAddModifierToNomen")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE modifier = vc
   IF (findstring("TO",ruledata->rules[looprule].actions[loopact].text) != 0)
    SET stat = initrec(addcmrequest)
    SET stat = initrec(addcmreply)
    SET sprocessstring = trim(substring(14,32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET sprocessstring = substring(1,(findstring(" ",sprocessstring) - 1),sprocessstring)
    SET stempaction = trim(substring((findstring("TO",ruledata->rules[looprule].actions[loopact].text
       )+ 3),32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET icheckgood = 1
    SET loop_start_dt_tm = systimestamp
    FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
     FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
      FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
       IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=loopchg2))
        FOR (loopcm = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
         loopchg2].charge_mods,5))
          IF ((workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used=0)
           AND findstring(concat(",",cnvtstring(workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
             .charges[loopchg2].charge_mods[loopcm].field1_id,17,2),","),scptlist))
           SET dtempid = cnvtreal(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[
            loopchg2].charge_mods[loopcm].field6)
           IF (((dtempid < 80000) OR (dtempid > 89999)) )
            SET icheckgood = 0
           ENDIF
          ENDIF
        ENDFOR
        IF (icheckgood=0)
         SET loopcm = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].
          charge_mods,5)
        ENDIF
       ENDIF
       IF (icheckgood=0)
        SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
       ENDIF
      ENDFOR
      IF (icheckgood=0)
       SET loopchg = size(ruledata->rules[looprule].conditions[loopcon].charges,5)
      ENDIF
     ENDFOR
     IF (icheckgood=0)
      SET loopcon = size(ruledata->rules[looprule].conditions,5)
     ENDIF
    ENDFOR
    CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
     "Exit loop for nomenclature check",script_and_detail_level_timer)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build("iCheckGood =",icheckgood))
    ENDIF
    SET dmodifiercvalue = 0.0
    IF (icheckgood=1)
     SET modifier = cnvtupper(trim(cnvtalphanum(substring((findstring("TO",ruledata->rules[looprule].
          actions[loopact].text) - 3),2,ruledata->rules[looprule].actions[loopact].text))))
     SET stat = uar_get_code_list_by_dispkey(17769,modifier,1,1,total_remaining,
      dmodifiercvalue)
     SET loop_start_dt_tm = systimestamp
     FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
       IF (findstring(stempaction,ruledata->rules[looprule].conditions[loopcon].text) != 0)
        FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
          FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
            SET chrgmodfindidx = 0
            SET modindxcnt = 0
            IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
            loopchg2))
             SET chrgmodfindidx = locateval(modindxcnt,1,size(workdata->encntrs[loopenc].dts[loopdt].
               tier[looptier].charges[loopchg2].charge_mods,5),dmodifiercvalue,workdata->encntrs[
              loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_mods[modindxcnt].field3_id
              )
             IF (chrgmodfindidx=0)
              SET stat = initrec(addcreditreq)
              SET stat = initrec(addcreditreply)
              SET stat = initrec(adjustrequest)
              SET stat = initrec(adjustreply)
              SET addcreditreq->charge_qual = 0
              DECLARE cemcount = i4 WITH noconstant(0)
              SET stat = alterlist(cemrequest->objarray,cemcount)
              SELECT INTO "nl:"
               FROM charge_event_mod c
               WHERE (c.charge_event_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
               charges[loopchg2].charge_event_id)
                AND (c.charge_event_mod_type_cd=code_val->13019_billcode)
                AND c.field10="afc_ct_execute"
               DETAIL
                cemcount += 1, stat = alterlist(cemrequest->objarray,cemcount), cemrequest->objarray[
                cemcount].action_type = "DEL",
                cemrequest->objarray[cemcount].charge_event_mod_id = c.charge_event_mod_id,
                cemrequest->objarray[cemcount].charge_event_id = c.charge_event_id, cemrequest->
                objarray[cemcount].updt_cnt = c.updt_cnt
               WITH nocounter
              ;end select
              IF (cemcount > 0)
               EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
                cemreply)
               IF ((cemreply->status_data.status != "S"))
                CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
                IF (validate(debug,- (1)) > 0)
                 CALL echorecord(cemrequest)
                 CALL echorecord(cemreply)
                ENDIF
               ENDIF
              ELSE
               CALL logmessage(curprog,"No existing charge_event_mods found",log_debug)
              ENDIF
              SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[
              looptier].charges[loopchg2].charge_item_id
              SET iskipforaddmod = 1
              SET addcreditreq->charge_qual += 1
              SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
              SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
              loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
              SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
              SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
               = 1
              CALL afteractionprocess(1)
              SET addcmrequest->charge_mod_qual += 2
              SET iaddcmcnt = addcmrequest->charge_mod_qual
              SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
              SET addcmrequest->charge_mod[(iaddcmcnt - 1)].action_type = "ADD"
              SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_item_id = adjustreply->
              new_charge_item_id
              SET addcmrequest->charge_mod[(iaddcmcnt - 1)].charge_mod_type_cd = code_val->
              13019_suspense
              SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field1_id = code_val->13030_noauth
              SET addcmrequest->charge_mod[(iaddcmcnt - 1)].field6 =
              "Release authorization needed for added CPT Modifier"
              SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
              SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->
              new_charge_item_id
              SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = 0.0
              SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->14002_modifier
              SET addcmrequest->charge_mod[iaddcmcnt].field2_id = (workdata->encntrs[loopenc].dts[
              loopdt].tier[looptier].charges[loopchg2].next_cpt_mod_seq+ 1)
              IF (sprocessstring="59")
               SET addcmrequest->charge_mod[iaddcmcnt].field6 = "59"
               SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
                17769_mod59)
               SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
               SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_mod59
              ELSEIF (sprocessstring="XS")
               SET addcmrequest->charge_mod[iaddcmcnt].field6 = "XS"
               SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
                17769_modxs)
               SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
               SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modxs
              ELSEIF (sprocessstring="XU")
               SET addcmrequest->charge_mod[iaddcmcnt].field6 = "XU"
               SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(code_val->
                17769_modxu)
               SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
               SET addcmrequest->charge_mod[iaddcmcnt].field3_id = code_val->17769_modxu
              ELSE
               CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unsupported modifier to add"),0)
              ENDIF
              SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
             ELSE
              CALL echo(build(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2]
                .charge_item_id," already associated to a ",uar_get_code_display(dmodifiercvalue),
                " modifier"))
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
     CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
      "Exit loop for processing",script_and_detail_level_timer)
     IF (validate(addcmrequest->charge_mod)=1)
      IF (size(addcmrequest->charge_mod,5) > 0)
       SET addcmrequest->charge_mod_qual = size(addcmrequest->charge_mod,5)
       SET stat = initrec(adjustrequest)
       SET stat = initrec(adjustreply)
       SET stat = initrec(addcreditreq)
       SET stat = initrec(addcreditreply)
       IF (validate(debug,- (1)) > 0)
        CALL echo("call afc_add_charge_mod")
       ENDIF
       EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addcmrequest), replace("REPLY",addcmreply)
       IF (validate(debug,- (1)) > 1)
        CALL echorecord(addcmreply)
       ENDIF
       CALL inactivatedupchargeeventmod(code_val->14002_modifier,dmodifiercvalue)
       IF ((addcmreply->status_data.status="S"))
        UPDATE  FROM charge c,
          (dummyt d  WITH seq = value(size(addcmrequest->charge_mod,5)))
         SET c.process_flg = 2
         PLAN (d)
          JOIN (c
          WHERE (c.charge_item_id=addcmrequest->charge_mod[d.seq].charge_item_id))
         WITH nocounter
        ;end update
        CALL afteractionprocess(1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt Add Modifier TO clause"),0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (actionmodify(dummy=i2) =null)
  IF (validate(debug,- (1)) > 0)
   CALL echo("Begin Sub ActionModify")
   CALL echo("----------------------------------")
  ENDIF
  IF (findstring("SET",ruledata->rules[looprule].actions[loopact].text) != 0)
   SET sprocessstring = ruledata->rules[looprule].actions[loopact].text
   SET sprocessstring = substring(8,(findstring(" ",sprocessstring,8) - 8),sprocessstring)
   IF (findstring("TOTQUANTITY",ruledata->rules[looprule].actions[loopact].text) != 0)
    SET stempaction = trim(substring((findstring("=",ruledata->rules[looprule].actions[loopact].text)
      + 2),32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET loop_start_dt_tm = systimestamp
    FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
      SET stat = initrec(addcreditreq)
      SET stat = initrec(addcreditreply)
      SET stat = initrec(adjustrequest)
      SET stat = initrec(adjustreply)
      SET addcreditreq->charge_qual = 0
      IF (findstring(sprocessstring,ruledata->rules[looprule].conditions[loopcon].text) != 0)
       FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
         FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
           IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
           loopchg2))
            SET addcreditreq->charge_qual += 1
            SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
            SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
            loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
            SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
            IF ((adjustrequest->charge_item_id=0))
             SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier
             ].charges[loopchg2].charge_item_id
             SET adjustrequest->item_quantity = cnvtint(stempaction)
            ENDIF
            SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
             = 1
            SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
           ENDIF
         ENDFOR
       ENDFOR
       CALL afteractionprocess(1)
      ENDIF
    ENDFOR
    CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
     "Exit loop for total quantity not zero",script_and_detail_level_timer)
   ELSEIF (findstring("PRICE",ruledata->rules[looprule].actions[loopact].text) != 0)
    SET stempaction = trim(substring((findstring("=",ruledata->rules[looprule].actions[loopact].text)
      + 2),32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET loop_start_dt_tm = systimestamp
    FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
      IF (findstring(sprocessstring,ruledata->rules[looprule].conditions[loopcon].text) != 0)
       FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
         FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
           IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
           loopchg2))
            SET stat = initrec(addcreditreq)
            SET stat = initrec(addcreditreply)
            SET stat = initrec(adjustrequest)
            SET stat = initrec(adjustreply)
            SET addcreditreq->charge_qual = 0
            SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
            .charges[loopchg2].charge_item_id
            SET adjustrequest->item_price = workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
            charges[loopchg2].item_price
            IF (substring(1,1,stempaction)="+")
             IF (findstring("%",stempaction) != 0)
              IF (findstring(" ",stempaction)=0)
               SET stempaction = concat(stempaction," RN0.01")
              ENDIF
              SET dtempid = cnvtreal(substring(2,(findstring(" ",stempaction) - 3),stempaction))
              SET stempaction = substring((findstring(" ",stempaction)+ 1),32000,stempaction)
              SET dtempid = (1+ (dtempid/ 100))
              SET adjustrequest->item_price = roundprice(stempaction,(adjustrequest->item_price *
               dtempid))
             ELSE
              SET dtempid = cnvtreal(substring(2,32000,stempaction))
              SET adjustrequest->item_price += dtempid
             ENDIF
            ELSEIF (substring(1,1,stempaction)="-")
             IF (findstring("%",stempaction) != 0)
              IF (findstring(" ",stempaction)=0)
               SET stempaction = concat(stempaction," RN0.01")
              ENDIF
              SET dtempid = cnvtreal(substring(2,(findstring(" ",stempaction) - 3),stempaction))
              SET stempaction = substring((findstring(" ",stempaction)+ 1),32000,stempaction)
              SET dtempid = (1 - (dtempid/ 100))
              SET adjustrequest->item_price = roundprice(stempaction,(adjustrequest->item_price *
               dtempid))
             ELSE
              SET dtempid = cnvtreal(substring(2,32000,stempaction))
              SET adjustrequest->item_price -= dtempid
             ENDIF
            ELSE
             SET dtempid = cnvtreal(stempaction)
             SET adjustrequest->item_price = dtempid
            ENDIF
            IF ((adjustrequest->item_price <= 0))
             CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1",
               "Price attempted to be modified to 0 or less"),0)
            ELSE
             SET addcreditreq->charge_qual += 1
             SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
             SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
             loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
             SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
             SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
              = 1
             CALL afteractionprocess(1)
            ENDIF
            SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
    CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
     "Begin loop for price not zero",script_and_detail_level_timer)
   ELSEIF (findstring("QUANTITY",ruledata->rules[looprule].actions[loopact].text) != 0)
    SET stempaction = trim(substring((findstring("=",ruledata->rules[looprule].actions[loopact].text)
      + 2),32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET loop_start_dt_tm = systimestamp
    FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
      IF (findstring(sprocessstring,ruledata->rules[looprule].conditions[loopcon].text) != 0)
       FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
         FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
           IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
           loopchg2))
            SET stat = initrec(addcreditreq)
            SET stat = initrec(addcreditreply)
            SET stat = initrec(adjustrequest)
            SET stat = initrec(adjustreply)
            SET addcreditreq->charge_qual = 0
            SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[looptier]
            .charges[loopchg2].charge_item_id
            SET adjustrequest->item_quantity = cnvtreal(stempaction)
            IF ((adjustrequest->item_quantity <= 0))
             CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1",
               "Quantity attempted to be modified to 0 or less"),0)
            ELSE
             SET addcreditreq->charge_qual += 1
             SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
             SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
             loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
             SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
             SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
              = 1
             CALL afteractionprocess(1)
            ENDIF
            SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
    CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
     "Begin loop for quantity not zero",script_and_detail_level_timer)
   ELSE
    CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt MODIFY SET clause"),0)
   ENDIF
  ELSE
   CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt MODIFY clause"),0)
  ENDIF
 END ;Subroutine
 SUBROUTINE (getbuilddata(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub GetBuildData")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE rulesetparser = vc WITH protect
   SET rulesetparser = "1=1"
   IF (validate(request->ruleset_id)=1)
    IF ((request->ruleset_id > 0))
     SET rulesetparser = build("rs.cs_cpp_ruleset_id = ",request->ruleset_id)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM cs_cpp_ruleset rs,
     cs_cpp_tier t,
     cs_cpp_rule r,
     long_text_reference l,
     cs_cpp_tier_detail td
    PLAN (rs
     WHERE rs.cs_cpp_ruleset_id > 0.0
      AND parser(rulesetparser)
      AND ((rs.active_ind+ 0)=1)
      AND ((rs.process_ind+ 0)=1))
     JOIN (t
     WHERE t.cs_cpp_ruleset_id=rs.cs_cpp_ruleset_id
      AND ((t.active_ind+ 0)=1))
     JOIN (r
     WHERE r.cs_cpp_ruleset_id=rs.cs_cpp_ruleset_id
      AND ((r.active_ind+ 0)=1)
      AND ((r.process_ind+ 0)=1)
      AND r.long_text_id != 0
      AND cnvtdatetime(sysdate) BETWEEN r.rule_beg_dt_tm AND r.rule_end_dt_tm)
     JOIN (l
     WHERE l.long_text_id=r.long_text_id)
     JOIN (td
     WHERE (td.cs_cpp_tier_id= Outerjoin(t.cs_cpp_tier_id))
      AND (td.active_ind= Outerjoin(1)) )
    ORDER BY t.priority_nbr, td.cs_cpp_tier_detail_id, r.priority_nbr,
     r.cs_cpp_rule_id
    HEAD REPORT
     stat = alterlist(builddata->rulesets,10)
    HEAD t.priority_nbr
     cntrule = 0, cntrs += 1
     IF (mod(cntrs,10)=1
      AND cntrs != 1)
      stat = alterlist(builddata->rulesets,(cntrs+ 10))
     ENDIF
     stat = alterlist(builddata->rulesets[cntrs].rules,10), builddata->rulesets[cntrs].ruleset_id =
     rs.cs_cpp_ruleset_id, builddata->rulesets[cntrs].ruleset_name = rs.ruleset_name,
     builddata->rulesets[cntrs].priority_nbr = t.priority_nbr, builddata->rulesets[cntrs].tier_row.
     tier_id = t.cs_cpp_tier_id, builddata->rulesets[cntrs].tier_row.health_plan_excl_ind = t
     .health_plan_excld_ind,
     builddata->rulesets[cntrs].tier_row.org_excl_ind = t.organization_excld_ind, builddata->
     rulesets[cntrs].tier_row.ins_org_excl_ind = t.ins_org_excld_ind, builddata->rulesets[cntrs].
     tier_row.encntr_type_excl_ind = t.encntr_type_excld_ind,
     builddata->rulesets[cntrs].tier_row.fin_class_excl_ind = t.fin_class_excld_ind, builddata->
     rulesets[cntrs].tier_row.encntr_class_excl_ind = t.encntr_type_class_excld_ind, builddata->
     rulesets[cntrs].tier_row.charge_status_ind = t.charge_status_ind,
     hpidx = 0, orgidx = 0, insidx = 0,
     encntrtypeidx = 0, encntrclassidx = 0, finidx = 0
    HEAD td.cs_cpp_tier_detail_id
     IF (td.cs_cpp_tier_detail_entity_name=health_plan)
      hpidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.health_plan,hpidx), builddata
      ->rulesets[cntrs].tier_row.health_plan[hpidx].health_plan_id = td.cs_cpp_tier_detail_entity_id
     ELSEIF (td.cs_cpp_tier_detail_entity_name=organization)
      orgidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.organization,orgidx),
      builddata->rulesets[cntrs].tier_row.organization[orgidx].org_id = td
      .cs_cpp_tier_detail_entity_id
     ELSEIF (td.cs_cpp_tier_detail_entity_name=ct_codevalue)
      IF (td.cs_cpp_tier_detail_subtype=insurance_org)
       insidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.insurance_org,insidx),
       builddata->rulesets[cntrs].tier_row.insurance_org[insidx].ins_org_id = td
       .cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=encntr_type)
       encntrtypeidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.encntr_type,
        encntrtypeidx), builddata->rulesets[cntrs].tier_row.encntr_type[encntrtypeidx].encntr_type_cd
        = td.cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=encntr_type_class)
       encntrclassidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.encntr_type_class,
        encntrclassidx), builddata->rulesets[cntrs].tier_row.encntr_type_class[encntrclassidx].
       encntr_type_class_cd = td.cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=fin_class)
       finidx += 1, stat = alterlist(builddata->rulesets[cntrs].tier_row.fin_class,finidx), builddata
       ->rulesets[cntrs].tier_row.fin_class[finidx].fin_class_cd = td.cs_cpp_tier_detail_entity_id
      ENDIF
     ENDIF
    HEAD r.cs_cpp_rule_id
     iindex = 0, igl_idx = 0, igl_idx = locateval(iindex,1,size(builddata->rulesets[cntrs].rules,5),r
      .cs_cpp_rule_id,builddata->rulesets[cntrs].rules[iindex].rule_id)
     IF (igl_idx=0)
      cntrule += 1
      IF (mod(cntrule,10)=1
       AND cntrule != 1)
       stat = alterlist(builddata->rulesets[cntrs].rules,(cntrule+ 10))
      ENDIF
      builddata->rulesets[cntrs].rules[cntrule].rule_id = r.cs_cpp_rule_id, builddata->rulesets[cntrs
      ].rules[cntrule].rule_name = r.rule_name, builddata->rulesets[cntrs].rules[cntrule].long_text
       = cnvtupper(l.long_text),
      builddata->rulesets[cntrs].rules[cntrule].priority_nbr = r.priority_nbr, builddata->rulesets[
      cntrs].rules[cntrule].rule_beg_dt_tm = r.rule_beg_dt_tm, builddata->rulesets[cntrs].rules[
      cntrule].rule_end_dt_tm = r.rule_end_dt_tm,
      builddata->rulesets[cntrs].rules[cntrule].charge_status_ind = r.charge_status_ind
     ENDIF
    FOOT  t.priority_nbr
     stat = alterlist(builddata->rulesets[cntrs].rules,cntrule)
    FOOT REPORT
     stat = alterlist(builddata->rulesets,cntrs)
    WITH nocounter
   ;end select
   IF (validate(debug,- (1)) > 1)
    CALL echorecord(builddata)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getqualifiedcharges(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub GetQualifiedCharges")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE sparser = vc WITH protect
   DECLARE soprparser = vc WITH protect
   DECLARE sencntrclassparser = vc WITH protect
   DECLARE shpparser = vc WITH protect
   DECLARE sfinparser = vc WITH protect
   DECLARE sorgparser = vc WITH protect
   DECLARE sencntrtypeparser = vc WITH protect
   DECLARE icount = i4 WITH protect
   DECLARE itimezonecount = i4 WITH protect
   DECLARE index = i4 WITH protect
   SET sparser = "-"
   IF (validate(request->encntr_id)=1)
    IF ((request->encntr_id > 0))
     SET sparser = build(sparser," and c.encntr_id =",request->encntr_id)
    ENDIF
   ENDIF
   IF (size(builddata->rulesets[loopcnt].tier_row.health_plan,5) > 0)
    IF ((builddata->rulesets[loopcnt].tier_row.health_plan_excl_ind=1))
     SET shpparser = build(shpparser," c.health_plan_id+0 not in (")
    ELSE
     SET shpparser = build(shpparser," c.health_plan_id+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.health_plan,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       shpparser = build(shpparser,builddata->rulesets[loopcnt].tier_row.health_plan[d.seq].
        health_plan_id), in_clause_ind = true
      ELSE
       shpparser = build(shpparser,", ",builddata->rulesets[loopcnt].tier_row.health_plan[d.seq].
        health_plan_id)
      ENDIF
     FOOT REPORT
      shpparser = build(shpparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET shpparser = "1=1"
   ENDIF
   IF (size(builddata->rulesets[loopcnt].tier_row.organization,5) > 0)
    IF ((builddata->rulesets[loopcnt].tier_row.org_excl_ind=1))
     SET sorgparser = build(sorgparser," c.payor_id+0 not in (")
    ELSE
     SET sorgparser = build(sorgparser," c.payor_id+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.organization,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sorgparser = build(sorgparser,builddata->rulesets[loopcnt].tier_row.organization[d.seq].org_id
        ), in_clause_ind = true
      ELSE
       sorgparser = build(sorgparser,", ",builddata->rulesets[loopcnt].tier_row.organization[d.seq].
        org_id)
      ENDIF
     FOOT REPORT
      sorgparser = build(sorgparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sorgparser = "1=1"
   ENDIF
   IF (size(builddata->rulesets[loopcnt].tier_row.encntr_type,5) > 0)
    IF ((builddata->rulesets[loopcnt].tier_row.encntr_type_excl_ind=1))
     SET sencntrtypeparser = build(sencntrtypeparser," c.admit_type_cd+0 not in (")
    ELSE
     SET sencntrtypeparser = build(sencntrtypeparser," c.admit_type_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.encntr_type,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sencntrtypeparser = build(sencntrtypeparser,builddata->rulesets[loopcnt].tier_row.encntr_type[
        d.seq].encntr_type_cd), in_clause_ind = true
      ELSE
       sencntrtypeparser = build(sencntrtypeparser,", ",builddata->rulesets[loopcnt].tier_row.
        encntr_type[d.seq].encntr_type_cd)
      ENDIF
     FOOT REPORT
      sencntrtypeparser = build(sencntrtypeparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sencntrtypeparser = "1=1"
   ENDIF
   IF (size(builddata->rulesets[loopcnt].tier_row.encntr_type_class,5) > 0)
    IF ((builddata->rulesets[loopcnt].tier_row.encntr_class_excl_ind=1))
     SET sencntrclassparser = build(sencntrclassparser," c.admit_type_cd+0 not in (")
    ELSE
     SET sencntrclassparser = build(sencntrclassparser," c.admit_type_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.encntr_type_class,5)
       )),
      code_value_group cvg
     PLAN (d)
      JOIN (cvg
      WHERE cvg.code_set=cs71_encntr
       AND (cvg.parent_code_value=builddata->rulesets[loopcnt].tier_row.encntr_type_class[d.seq].
      encntr_type_class_cd))
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sencntrclassparser = build(sencntrclassparser,cvg.child_code_value), in_clause_ind = true
      ELSE
       sencntrclassparser = build(sencntrclassparser,", ",cvg.child_code_value)
      ENDIF
     FOOT REPORT
      sencntrclassparser = build(sencntrclassparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sencntrclassparser = "1=1"
   ENDIF
   IF (curqual=0)
    SET sencntrclassparser = "1=1"
   ENDIF
   CALL echo(build("EncntrClass:",sencntrclassparser))
   IF (size(builddata->rulesets[loopcnt].tier_row.fin_class,5) > 0)
    IF ((builddata->rulesets[loopcnt].tier_row.fin_class_excl_ind=1))
     SET sfinparser = build(sfinparser," c.fin_class_cd+0 not in (")
    ELSE
     SET sfinparser = build(sfinparser," c.fin_class_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.fin_class,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sfinparser = build(sfinparser,builddata->rulesets[loopcnt].tier_row.fin_class[d.seq].
        fin_class_cd), in_clause_ind = true
      ELSE
       sfinparser = build(sfinparser,", ",builddata->rulesets[loopcnt].tier_row.fin_class[d.seq].
        fin_class_cd)
      ENDIF
     FOOT REPORT
      sfinparser = build(sfinparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sfinparser = "1=1"
   ENDIF
   IF (sparser="-")
    SET sparser = "1=1"
   ELSE
    SET sparser = substring(7,32000,sparser)
   ENDIF
   IF (size(builddata->rulesets[loopcnt].tier_row.insurance_org,5) > 0)
    SET soprparser = "o.health_plan_id = c.health_plan_id"
    IF ((builddata->rulesets[loopcnt].tier_row.ins_org_excl_ind=1))
     SET soprparser = build(soprparser," and ((c.health_plan_id = 0.0) or (o.active_ind = 1")
     SET soprparser = build(soprparser," and o.org_plan_reltn_cd =",code_val->370_carrier)
     SET soprparser = build(soprparser," and o.organization_id not in (")
    ELSE
     SET soprparser = build(soprparser," and o.active_ind = 1")
     SET soprparser = build(soprparser," and o.org_plan_reltn_cd =",code_val->370_carrier)
     SET soprparser = build(soprparser," and o.organization_id in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(builddata->rulesets[loopcnt].tier_row.insurance_org,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       soprparser = build(soprparser,builddata->rulesets[loopcnt].tier_row.insurance_org[d.seq].
        ins_org_id), in_clause_ind = true
      ELSE
       soprparser = build(soprparser,", ",builddata->rulesets[loopcnt].tier_row.insurance_org[d.seq].
        ins_org_id)
      ENDIF
     FOOT REPORT
      soprparser = build(soprparser,")")
      IF ((builddata->rulesets[loopcnt].tier_row.ins_org_excl_ind=1))
       soprparser = build(soprparser,"))")
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SET soprparser = "o.org_plan_reltn_id = 0.0"
   ENDIF
   IF (validate(request->objarray)=1)
    IF (size(request->objarray,5) > 0)
     SET sparser = "1=1"
     SET stat = copyrec(request,lbrequest,1)
     SET sparser = build("expand(index, 1, size(lbrequest->objArray, 5)",
      ",c.encntr_id,lbrequest->objArray[index]->encntr_id)")
    ENDIF
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Charge Select")
    CALL echo("----------------------------------")
   ENDIF
   SET stat = initrec(workdata)
   SET cntenc = 0
   SET loop_start_dt_tm = systimestamp
   FOR (itimezonecount = 1 TO size(csfacilitytimezone->timezonelist,5))
     SET factimezoneindex = csfacilitytimezone->timezonelist[itimezonecount].timezoneindex
     SELECT
      IF (logicaldomainsinuse)
       PLAN (c
        WHERE parser(sparser)
         AND parser(shpparser)
         AND parser(sorgparser)
         AND parser(sfinparser)
         AND parser(sencntrtypeparser)
         AND parser(sencntrclassparser)
         AND ((c.offset_charge_item_id+ 0)=0)
         AND ((c.process_flg+ 0) IN (0, 1, 2, 3, 4,
        100, 999))
         AND ((c.active_ind+ 0)=1)
         AND c.service_dt_tm >= cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].
         from_date)
         AND c.service_dt_tm < cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].today)
         AND ((c.charge_item_id+ 0) != 0))
        JOIN (e
        WHERE e.encntr_id=c.encntr_id
         AND e.active_ind=1
         AND expand(icount,1,size(csfacilitytimezone->timezonelist[itimezonecount].organization,5),e
         .organization_id,csfacilitytimezone->timezonelist[itimezonecount].organization[icount].
         org_id))
        JOIN (org
        WHERE org.organization_id=e.organization_id
         AND org.logical_domain_id=logicaldomainid
         AND org.active_ind=1)
        JOIN (b
        WHERE (b.bill_item_id=(c.bill_item_id+ 0)))
        JOIN (o
        WHERE parser(soprparser))
        JOIN (cm
        WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
         AND ((cm.active_ind+ 0)= Outerjoin(1)) )
      ELSE
      ENDIF
      INTO "nl:"
      facilityservicedttm = cnvtdatetime(cnvtdate2(datetimezoneformat(c.service_dt_tm,
         factimezoneindex,"MMDDYYYY"),"MMDDYYYY"),cnvttime2(datetimezoneformat(c.service_dt_tm,
         factimezoneindex,"HH:MM:SS"),"HH:MM:SS")), facilitydate = cnvtdate2(datetimezoneformat(c
        .service_dt_tm,factimezoneindex,"MMDDYYYY"),"MMDDYYYY")
      FROM organization org,
       encounter e,
       charge c,
       org_plan_reltn o,
       charge_mod cm,
       bill_item b
      PLAN (c
       WHERE parser(sparser)
        AND parser(shpparser)
        AND parser(sorgparser)
        AND parser(sfinparser)
        AND parser(sencntrtypeparser)
        AND parser(sencntrclassparser)
        AND ((c.offset_charge_item_id+ 0)=0)
        AND ((c.process_flg+ 0) IN (0, 1, 2, 3, 4,
       100, 999))
        AND ((c.active_ind+ 0)=1)
        AND c.service_dt_tm >= cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].
        from_date)
        AND c.service_dt_tm < cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].today)
        AND ((c.charge_item_id+ 0) != 0))
       JOIN (e
       WHERE e.encntr_id=c.encntr_id
        AND e.active_ind=1
        AND expand(icount,1,size(csfacilitytimezone->timezonelist[itimezonecount].organization,5),e
        .organization_id,csfacilitytimezone->timezonelist[itimezonecount].organization[icount].org_id
        ))
       JOIN (org
       WHERE org.organization_id=e.organization_id
        AND org.active_ind=1)
       JOIN (b
       WHERE (b.bill_item_id=(c.bill_item_id+ 0)))
       JOIN (o
       WHERE parser(soprparser))
       JOIN (cm
       WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
        AND ((cm.active_ind+ 0)= Outerjoin(1)) )
      ORDER BY c.encntr_id, facilitydate, c.tier_group_cd,
       c.service_dt_tm, c.activity_dt_tm, c.charge_item_id,
       cm.field2_id
      HEAD REPORT
       IF (size(workdata->encntrs,5)=0)
        stat = alterlist(workdata->encntrs,100)
       ENDIF
      HEAD c.encntr_id
       cntenc += 1, cntchg = 0, cntcm = 0,
       cntdt = 0, cnttier = 0
       IF (mod(cntenc,100)=1
        AND cntenc != 1)
        stat = alterlist(workdata->encntrs,(cntenc+ 100))
       ENDIF
       workdata->encntrs[cntenc].encntr_id = c.encntr_id, workdata->encntrs[cntenc].person_id = c
       .person_id, workdata->encntrs[cntenc].exclude_ind = 0
      HEAD facilitydate
       cntdt += 1, cnttier = 0, cntchg = 0,
       cntcm = 0, stat = alterlist(workdata->encntrs[cntenc].dts,cntdt), workdata->encntrs[cntenc].
       dts[cntdt].service_dt_tm = cnvtdatetime(getcsfacilityendofday(csfacilitytimezone->
         timezonelist[itimezonecount].organization_id,c.service_dt_tm))
      HEAD c.tier_group_cd
       cnttier += 1, cntchg = 0, cntcm = 0,
       stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier,cnttier), stat = alterlist(workdata
        ->encntrs[cntenc].dts[cntdt].tier[cnttier].charges,50), workdata->encntrs[cntenc].dts[cntdt].
       tier[cnttier].tier_group_cd = c.tier_group_cd
      HEAD c.charge_item_id
       IF (c.process_flg IN (1, 2, 3, 4))
        workdata->encntrs[cntenc].exclude_ind = 1
       ELSE
        cntchg += 1, cntcm = 0
        IF (mod(cntchg,50)=1
         AND cntchg != 1)
         stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges,(cntchg+ 50))
        ENDIF
        stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
         charge_mods,5), workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
        charge_item_id = c.charge_item_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].
        charges[cntchg].charge_event_id = c.charge_event_id,
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].bill_item_id = c
        .bill_item_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].encntr_id
         = c.encntr_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].person_id
         = c.person_id,
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].item_quantity = c
        .item_quantity, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].item_price
         = c.item_price, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
        service_dt_tm = facilityservicedttm,
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].cs_cpp_undo_id = c
        .cs_cpp_undo_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
        ord_phys_id = c.ord_phys_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[
        cntchg].perf_phys_id = c.perf_phys_id,
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].verify_phys_id = c
        .verify_phys_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
        abn_status_cd = c.abn_status_cd
       ENDIF
      DETAIL
       IF (c.process_flg IN (0, 100, 999))
        cntcm += 1
        IF (mod(cntcm,5)=1
         AND cntcm != 1)
         stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
          charge_mods,(cntcm+ 5))
        ENDIF
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].charge_mods[cntcm].field6
         = cm.field6, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].charge_mods[
        cntcm].field1_id = cm.field1_id, workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[
        cntchg].charge_mods[cntcm].nomen_id = cm.nomen_id,
        workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].charge_mods[cntcm].
        field3_id = cm.field3_id
        IF ((cm.charge_mod_type_cd=code_val->13019_billcode))
         IF (findstring(concat(",",cnvtstring(cm.field1_id,17,2),","),scptmodlist) != 0)
          workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].next_cpt_mod_seq += 1
         ENDIF
        ENDIF
       ENDIF
      FOOT  c.charge_item_id
       stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges[cntchg].
        charge_mods,cntcm)
      FOOT  c.tier_group_cd
       stat = alterlist(workdata->encntrs[cntenc].dts[cntdt].tier[cnttier].charges,cntchg)
      WITH forupdate(c), expand = 2, orahintcbo("OPT_PARAM('_B_TREE_BITMAP_PLANS','FALSE')"),
       nocounter
     ;end select
     SET qualcount = size(workdata->encntrs,5)
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for charges in logicaldomains",script_and_detail_level_timer)
   SET stat = alterlist(workdata->encntrs,cntenc)
   IF (validate(debug,- (1)) > 1)
    CALL echorecord(workdata)
   ENDIF
 END ;Subroutine
 SUBROUTINE (parseruledata(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ParseRuleData")
    CALL echo("----------------------------------")
   ENDIF
   SET cntr = 0
   SET istartpos = 0
   SET ifindpos = 0
   SET idoneprocessing = 0
   SET stat = initrec(ruledata)
   SET stat = alterlist(ruledata->rules,size(builddata->rulesets[loopcnt].rules,5))
   SET loop_start_dt_tm = systimestamp
   FOR (loopcnt2 = 1 TO size(builddata->rulesets[loopcnt].rules,5))
     SET idoneprocessing = 0
     SET cntrule = 0
     SET sprocessstring = builddata->rulesets[loopcnt].rules[loopcnt2].long_text
     WHILE (((idoneprocessing != 1) OR (cntrule > 500)) )
       SET cntrule += 1
       SET cntcon = 0
       SET cntact = 0
       IF (substring(1,3,sprocessstring)="IF(")
        SET cntr += 1
        IF (cntr > size(ruledata->rules,5))
         SET stat = alterlist(ruledata->rules,(cntr+ 10))
        ENDIF
        SET ruledata->rules[cntr].rule_id = builddata->rulesets[loopcnt].rules[loopcnt2].rule_id
        SET ruledata->rules[cntr].rule_name = builddata->rulesets[loopcnt].rules[loopcnt2].rule_name
        SET ruledata->rules[cntr].charge_status_ind = builddata->rulesets[loopcnt].rules[loopcnt2].
        charge_status_ind
        SET stempcondition = substring(4,(findstring(")THEN(",sprocessstring) - 4),sprocessstring)
        SET istartpos = 1
        SET ifindpos = findstring(" AND ",stempcondition)
        WHILE (ifindpos != 0)
          SET cntcon += 1
          SET stat = alterlist(ruledata->rules[cntr].conditions,cntcon)
          SET ruledata->rules[cntr].conditions[cntcon].text = substring(istartpos,(ifindpos -
           istartpos),stempcondition)
          SET istartpos = (ifindpos+ 5)
          SET ifindpos = findstring(" AND ",stempcondition,istartpos)
        ENDWHILE
        SET cntcon += 1
        SET stat = alterlist(ruledata->rules[cntr].conditions,cntcon)
        SET ruledata->rules[cntr].conditions[cntcon].text = substring(istartpos,32000,stempcondition)
        CALL echo(sprocessstring)
        IF (findstring(")ELSEIF(",sprocessstring) != 0)
         SET stempaction = substring((findstring(")THEN(",sprocessstring)+ 6),32000,sprocessstring)
         SET stempaction = substring(1,(findstring(")ELSEIF(",stempaction) - 1),stempaction)
         SET sprocessstring = substring((findstring(")ELSEIF(",sprocessstring)+ 5),32000,
          sprocessstring)
        ELSE
         SET stempaction = substring((findstring(")THEN(",sprocessstring)+ 6),32000,sprocessstring)
         SET idoneprocessing = 1
        ENDIF
        SET istartpos = 1
        SET ifindpos = findstring(")AND(",stempaction)
        WHILE (ifindpos != 0)
          SET cntact += 1
          SET stat = alterlist(ruledata->rules[cntr].actions,cntact)
          SET ruledata->rules[cntr].actions[cntact].text = substring(istartpos,(ifindpos - istartpos),
           stempaction)
          SET istartpos = (ifindpos+ 5)
          SET ifindpos = findstring(")AND(",stempaction,istartpos)
        ENDWHILE
        SET cntact += 1
        SET stat = alterlist(ruledata->rules[cntr].actions,cntact)
        SET stempaction = substring(istartpos,32000,stempaction)
        SET ifindpos = findstring(")",stempaction)
        IF (ifindpos != 0)
         SET stempaction = substring(1,(ifindpos - 1),stempaction)
        ENDIF
        SET ruledata->rules[cntr].actions[cntact].text = stempaction
        IF (cntcon > 0
         AND cntact > 0)
         SET ruledata->rules[cntr].rulecomplete = 1
        ENDIF
       ELSE
        SET idoneprocessing = 1
       ENDIF
     ENDWHILE
     IF (cntrule > 500)
      CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Rule is either too large, or corrupt"),0)
     ELSE
      IF (validate(debug,- (1)) > 0)
       CALL echo(concat("Rule has ",trim(cnvtstring(cntrule))," part(s)"))
      ENDIF
     ENDIF
   ENDFOR
   CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
    "Exit loop for parsing rules",script_and_detail_level_timer)
   SET stat = alterlist(ruledata->rules,cntr)
 END ;Subroutine
 SUBROUTINE (getencounterlock(pencntrid=f8) =i2)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE e.encntr_id=pencntrid
     AND e.active_ind=1
    WITH forupdate(e), nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (getactivenomenid(nomenid=f8) =f8)
   DECLARE newnomenid = f8
   SET newnomenid = nomenid
   SELECT INTO "nl:"
    FROM nomenclature n,
     nomenclature n1
    PLAN (n
     WHERE n.nomenclature_id=nomenid)
     JOIN (n1
     WHERE n1.source_identifier=n.source_identifier
      AND n1.source_vocabulary_cd=n.source_vocabulary_cd
      AND n1.active_ind=1
      AND n1.beg_effective_dt_tm <= cnvtdatetime(from_date)
      AND n1.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY n1.nomenclature_id DESC
    HEAD n1.nomenclature_id
     newnomenid = n1.nomenclature_id
    WITH nocounter
   ;end select
   RETURN(newnomenid)
 END ;Subroutine
 SUBROUTINE (getcsfacilitytimezonedetails(dummy=i2) =null)
   DECLARE ifacilitycount = i4 WITH private, noconstant(0)
   DECLARE itimezonecount = i4 WITH private, noconstant(0)
   DECLARE icount = i4 WITH private, noconstant(0)
   DECLARE ipos = i4 WITH private, noconstant(0)
   DECLARE iorgcount = i4 WITH private, noconstant(0)
   FOR (ifacilitycount = 1 TO size(csfacilitylist->facilities,5))
    IF (ifacilitycount > 1)
     SET ipos = locateval(icount,1,size(csfacilitytimezone->timezonelist,5),csfacilitylist->
      facilities[ifacilitycount].timezoneindex,csfacilitytimezone->timezonelist[icount].timezoneindex
      )
    ENDIF
    IF (ipos=0)
     SET itimezonecount += 1
     SET stat = alterlist(csfacilitytimezone->timezonelist,itimezonecount)
     SET csfacilitytimezone->timezonelist[itimezonecount].organization_id = csfacilitylist->
     facilities[ifacilitycount].organizationid
     SET csfacilitytimezone->timezonelist[itimezonecount].timezoneindex = csfacilitylist->facilities[
     ifacilitycount].timezoneindex
     SET csfacilitytimezone->timezonelist[itimezonecount].from_date = cnvtdatetime(
      getcsfacilitybeginningofday(csfacilitylist->facilities[ifacilitycount].organizationid,from_date
       ))
     SET csfacilitytimezone->timezonelist[itimezonecount].today = cnvtdatetime(
      getcsfacilitybeginningofday(csfacilitylist->facilities[ifacilitycount].organizationid,today))
     SET stat = alterlist(csfacilitytimezone->timezonelist[itimezonecount].organization,1)
     SET csfacilitytimezone->timezonelist[itimezonecount].organization[1].org_id = csfacilitylist->
     facilities[ifacilitycount].organizationid
    ELSE
     SET iorgcount = (size(csfacilitytimezone->timezonelist[ipos].organization,5)+ 1)
     SET stat = alterlist(csfacilitytimezone->timezonelist[ipos].organization,iorgcount)
     SET csfacilitytimezone->timezonelist[ipos].organization[iorgcount].org_id = csfacilitylist->
     facilities[ifacilitycount].organizationid
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (logmodcapability(encounterid=f8,loncollectorid=vc) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub logModCapability")
    CALL echo("----------------------------------")
    CALL echo(encounterid)
    CALL echo(loncollectorid)
   ENDIF
   RECORD capabilitylogrequest(
     1 capability_ident = vc
     1 teamname = vc
     1 entities[*]
       2 entity_id = f8
       2 entity_name = vc
   ) WITH protect
   RECORD capabilitylogreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET capabilitylogrequest->capability_ident = loncollectorid
   SET capabilitylogrequest->teamname = "PATIENT_ACCOUNTING"
   SET stat = alterlist(capabilitylogrequest->entities,1)
   SET capabilitylogrequest->entities[1].entity_id = encounterid
   SET capabilitylogrequest->entities[1].entity_name = "FINANCIAL_ENCOUNTER"
   CALL echorecord(capabilitylogrequest)
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace("REPLY",
    capabilitylogreply)
   IF ((capabilitylogreply->status_data.status != "S"))
    CALL logmessage(curprog,"logCapabilityInfo: pft_log_solution_capability failed.",log_error)
   ENDIF
 END ;Subroutine
 SUBROUTINE (actionaddmodifiertoabn(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ActionAddModifierToABN")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE isetreview = i2 WITH noconstant(0)
   DECLARE gmodifier = vc
   SET stat = initrec(addcmrequest)
   SET stat = initrec(addcmreply)
   SET addcmrequest->charge_mod_qual = 0
   SET dmodifiercvalue = 0.0
   IF (findstring("TO",ruledata->rules[looprule].actions[loopact].text) != 0)
    SET stempaction = trim(substring((findstring("TO",ruledata->rules[looprule].actions[loopact].text
       )+ 3),32000,ruledata->rules[looprule].actions[loopact].text),3)
    SET gmodifier = cnvtupper(trim(cnvtalphanum(substring((findstring("TO",ruledata->rules[looprule].
         actions[loopact].text) - 3),2,ruledata->rules[looprule].actions[loopact].text))))
    SET stat = uar_get_code_list_by_dispkey(17769,gmodifier,1,1,total_remaining,
     dmodifiercvalue)
    IF (dmodifiercvalue != 0.0)
     SET iskipforaddmod = 1
     SET isetreview = 1
     IF (gmodifier="GA")
      SET iskipforaddmod = 0
      SET isetreview = 0
     ENDIF
     SET loop_start_dt_tm = systimestamp
     FOR (loopcon = 1 TO size(ruledata->rules[looprule].conditions,5))
       IF (findstring(stempaction,ruledata->rules[looprule].conditions[loopcon].text) != 0)
        FOR (loopchg = 1 TO size(ruledata->rules[looprule].conditions[loopcon].charges,5))
          FOR (loopchg2 = 1 TO size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5))
            SET chrgmodfindidx = 0
            SET modindxcnt = 0
            IF ((ruledata->rules[looprule].conditions[loopcon].charges[loopchg].workdata_index=
            loopchg2)
             AND (workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[ruledata->rules[
            looprule].conditions[loopcon].charges[loopchg].workdata_index].charge_used=0))
             SET chrgmodfindidx = locateval(modindxcnt,1,size(workdata->encntrs[loopenc].dts[loopdt].
               tier[looptier].charges[loopchg2].charge_mods,5),dmodifiercvalue,workdata->encntrs[
              loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_mods[modindxcnt].field3_id
              )
             IF (chrgmodfindidx=0)
              SET stat = initrec(addcreditreq)
              SET stat = initrec(addcreditreply)
              SET stat = initrec(adjustrequest)
              SET stat = initrec(adjustreply)
              SET addcreditreq->charge_qual = 0
              DECLARE cemcount = i4 WITH noconstant(0)
              SET stat = alterlist(cemrequest->objarray,cemcount)
              SELECT INTO "nl:"
               FROM charge_event_mod c
               WHERE (c.charge_event_id=workdata->encntrs[loopenc].dts[loopdt].tier[looptier].
               charges[loopchg2].charge_event_id)
                AND (c.charge_event_mod_type_cd=code_val->13019_billcode)
                AND c.field10="afc_ct_execute"
               DETAIL
                cemcount += 1, stat = alterlist(cemrequest->objarray,cemcount), cemrequest->objarray[
                cemcount].action_type = "DEL",
                cemrequest->objarray[cemcount].charge_event_mod_id = c.charge_event_mod_id,
                cemrequest->objarray[cemcount].charge_event_id = c.charge_event_id, cemrequest->
                objarray[cemcount].updt_cnt = c.updt_cnt
               WITH nocounter
              ;end select
              IF (cemcount > 0)
               EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
                cemreply)
               IF ((cemreply->status_data.status != "S"))
                CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
                IF (validate(debug,- (1)) > 0)
                 CALL echorecord(cemrequest)
                 CALL echorecord(cemreply)
                ENDIF
               ENDIF
              ELSE
               CALL logmessage(curprog,"No existing charge_event_mods found",log_debug)
              ENDIF
              SET adjustrequest->charge_item_id = workdata->encntrs[loopenc].dts[loopdt].tier[
              looptier].charges[loopchg2].charge_item_id
              SET addcreditreq->charge_qual += 1
              SET stat = alterlist(addcreditreq->charge,addcreditreq->charge_qual)
              SET addcreditreq->charge[addcreditreq->charge_qual].charge_item_id = workdata->encntrs[
              loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_item_id
              SET addcreditreq->charge[addcreditreq->charge_qual].reason_comment = "afc_ct_execute"
              SET workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2].charge_used
               = 1
              CALL afteractionprocess(1)
              IF (isetreview)
               SET addcmrequest->charge_mod_qual += 1
               SET iaddcmcnt = addcmrequest->charge_mod_qual
               SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
               SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
               SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->
               new_charge_item_id
               SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = code_val->13019_suspense
               SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->13030_modreview
               SET addcmrequest->charge_mod[iaddcmcnt].field6 = "Review Added Modifier"
              ENDIF
              SET addcmrequest->charge_mod_qual += 1
              SET iaddcmcnt = addcmrequest->charge_mod_qual
              SET stat = alterlist(addcmrequest->charge_mod,iaddcmcnt)
              SET addcmrequest->charge_mod[iaddcmcnt].action_type = "ADD"
              SET addcmrequest->charge_mod[iaddcmcnt].charge_item_id = adjustreply->
              new_charge_item_id
              SET addcmrequest->charge_mod[iaddcmcnt].charge_mod_type_cd = 0.0
              SET addcmrequest->charge_mod[iaddcmcnt].field1_id = code_val->14002_modifier
              SET addcmrequest->charge_mod[iaddcmcnt].field2_id = (workdata->encntrs[loopenc].dts[
              loopdt].tier[looptier].charges[loopchg2].next_cpt_mod_seq+ 1)
              SET addcmrequest->charge_mod[iaddcmcnt].field6 = uar_get_code_display(dmodifiercvalue)
              SET addcmrequest->charge_mod[iaddcmcnt].field7 = uar_get_code_description(
               dmodifiercvalue)
              SET addcmrequest->charge_mod[iaddcmcnt].field10 = "afc_ct_execute"
              SET addcmrequest->charge_mod[iaddcmcnt].field3_id = dmodifiercvalue
              SET validencounter = 1
              SET loopchg2 = size(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges,5)
             ELSE
              CALL echo(build(workdata->encntrs[loopenc].dts[loopdt].tier[looptier].charges[loopchg2]
                .charge_item_id," already associated to a ",uar_get_code_display(dmodifiercvalue),
                " modifier"))
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
     CALL logsystemactivity(loop_start_dt_tm,curprog," ",0.0,"Z",
      "Exit loop for processing ABN modifiers",script_and_detail_level_timer)
     IF (validencounter=1)
      CALL logmodcapability(workdata->encntrs[loopenc].encntr_id,abn_collector_id)
     ENDIF
     IF (validate(addcmrequest->charge_mod)=1)
      IF (size(addcmrequest->charge_mod,5) > 0)
       SET addcmrequest->charge_mod_qual = size(addcmrequest->charge_mod,5)
       SET stat = initrec(adjustrequest)
       SET stat = initrec(adjustreply)
       SET stat = initrec(addcreditreq)
       SET stat = initrec(addcreditreply)
       IF (validate(debug,- (1)) > 0)
        CALL echo("call afc_add_charge_mod")
       ENDIF
       EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addcmrequest), replace("REPLY",addcmreply)
       IF (validate(debug,- (1)) > 1)
        CALL echorecord(addcmreply)
       ENDIF
       IF ((addcmreply->status_data.status != "S"))
        CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Falied to update the charge mod."),0)
       ENDIF
       CALL inactivatedupchargeeventmod(code_val->14002_modifier,dmodifiercvalue)
       IF ((addcmreply->status_data.status="S")
        AND isetreview)
        UPDATE  FROM charge c,
          (dummyt d  WITH seq = value(size(addcmrequest->charge_mod,5)))
         SET c.process_flg = 2
         PLAN (d)
          JOIN (c
          WHERE (c.charge_item_id=addcmrequest->charge_mod[d.seq].charge_item_id))
         WITH nocounter
        ;end update
       ENDIF
       CALL afteractionprocess(1)
      ENDIF
     ENDIF
    ELSE
     CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Unknown modifier to add"),0)
    ENDIF
   ELSE
    CALL logcterror(uar_i18ngetmessage(i18nhandle,"k1","Corrupt Add G Modifier TO clause"),0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivatedupchargeeventmod(entitytype=f8,entityvalue=f8) =null)
   DECLARE nfirstentity = i4 WITH noconstant(0)
   DECLARE nentitycnt = i4 WITH noconstant(0)
   SET stat = alterlist(cemrequest->objarray,nentitycnt)
   SELECT INTO "nl:"
    FROM charge_event_mod cem,
     charge c,
     (dummyt d  WITH seq = value(size(addcmrequest->charge_mod,5)))
    PLAN (d)
     JOIN (c
     WHERE (c.charge_item_id=addcmrequest->charge_mod[d.seq].charge_item_id))
     JOIN (cem
     WHERE cem.charge_event_id=c.charge_event_id
      AND cem.field3_id=entityvalue
      AND cem.field1_id=entitytype
      AND cem.field10="afc_ct_execute"
      AND cem.active_ind=1)
    ORDER BY cem.charge_event_id, cem.charge_event_mod_id
    HEAD REPORT
     nentitycnt = 0
    HEAD cem.charge_event_id
     nfirstentity = 1
    HEAD cem.charge_event_mod_id
     IF (nfirstentity=0)
      nentitycnt += 1, stat = alterlist(cemrequest->objarray,nentitycnt), cemrequest->objarray[
      nentitycnt].action_type = "DEL",
      cemrequest->objarray[nentitycnt].charge_event_mod_id = cem.charge_event_mod_id, cemrequest->
      objarray[nentitycnt].charge_event_id = cem.charge_event_id, cemrequest->objarray[nentitycnt].
      updt_cnt = cem.updt_cnt
     ENDIF
     nfirstentity = 0
    WITH nocounter
   ;end select
   IF (size(cemrequest->objarray,5) > 0)
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",cemreply)
    IF ((cemreply->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cemrequest)
      CALL echorecord(cemreply)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#end_program
 IF ((request->ops_date > 0.0)
  AND logicaldomainsinuse=true
  AND ((lennext=0) OR ((lennext=(len+ 1)))) )
  SET reply->status_data.status = "F"
  IF (validate(debug,- (1)) > 0)
   CALL echo("Enter valid input format for batch selection")
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  IF (validate(debug,- (1)) > 0)
   CALL echo("Rules engine completed successfully!")
  ENDIF
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(builddata)
  CALL echorecord(workdata)
  CALL echorecord(request)
  CALL echorecord(charges)
 ENDIF
 FREE RECORD builddata
 FREE RECORD workdata
 FREE RECORD ruledata
 FREE RECORD tempreplace
 FREE RECORD addcreditreq
 FREE RECORD addcreditreply
 FREE RECORD ct_request
 FREE RECORD ct_reply
 FREE RECORD finalcharges
 FREE RECORD afcinterfacecharge_request
 FREE RECORD afcinterfacecharge_reply
 FREE RECORD afcprofit_request
 FREE RECORD afcprofit_reply
 FREE RECORD addcmrequest
 FREE RECORD addcmreply
 FREE RECORD adjustrequest
 FREE RECORD adjustreply
 FREE RECORD code_val
 FREE RECORD request
 FREE RECORD charges
 CALL logsystemactivity(script_start_dt_tm,curprog," ",0.0,reply->status_data.status,
  build2("End calculation of the script execution time - ","Count[",qualcount,"]"),script_level_timer
  )
END GO
