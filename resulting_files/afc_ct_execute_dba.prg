CREATE PROGRAM afc_ct_execute:dba
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
 DECLARE pft_event_subs_vrsn = vc WITH noconstant("603428.027")
 IF ("Z"=validate(pft_common_vrsn,"Z"))
  DECLARE pft_common_vrsn = vc WITH noconstant(""), public
 ENDIF
 SET pft_common_vrsn = "500383.087"
 IF ((validate(pft_neither,- (1))=- (1)))
  DECLARE pft_neither = i2 WITH constant(0)
 ENDIF
 IF ((validate(pft_debit,- (1))=- (1)))
  DECLARE pft_debit = i2 WITH constant(1)
 ENDIF
 IF ((validate(pft_credit,- (1))=- (1)))
  DECLARE pft_credit = i2 WITH constant(2)
 ENDIF
 IF (validate(null_f8,0.0)=0.0)
  DECLARE null_f8 = f8 WITH constant(- (0.00001))
 ENDIF
 IF (validate(null_i2,0)=0)
  DECLARE null_i2 = i2 WITH constant(- (1))
 ENDIF
 IF (validate(null_i4,0)=0)
  DECLARE null_i4 = i4 WITH constant(- (1))
 ENDIF
 IF ((validate(null_dt,- (1.0))=- (1.0)))
  DECLARE null_dt = q8 WITH constant(0.0)
 ENDIF
 IF (validate(null_vc,"Z")="Z")
  DECLARE null_vc = vc WITH constant("")
 ENDIF
 IF ((validate(upt_force,- (1))=- (1)))
  DECLARE upt_force = i4 WITH constant(- (99999))
 ENDIF
 IF ((validate(log_error,- (1))=- (1)))
  DECLARE log_error = i4 WITH constant(0)
 ENDIF
 IF ((validate(log_warning,- (1))=- (1)))
  DECLARE log_warning = i4 WITH constant(1)
 ENDIF
 IF ((validate(log_audit,- (1))=- (1)))
  DECLARE log_audit = i4 WITH constant(2)
 ENDIF
 IF ((validate(log_info,- (1))=- (1)))
  DECLARE log_info = i4 WITH constant(3)
 ENDIF
 IF ((validate(log_debug,- (1))=- (1)))
  DECLARE log_debug = i4 WITH constant(4)
 ENDIF
 IF (validate(ein_pft_charge,0)=0)
  DECLARE ein_pft_charge = i4 WITH constant(1)
 ENDIF
 IF (validate(ein_charge_item,0)=0)
  DECLARE ein_charge_item = i4 WITH constant(2)
 ENDIF
 IF (validate(ein_bill_header,0)=0)
  DECLARE ein_bill_header = i4 WITH constant(3)
 ENDIF
 IF (validate(ein_pft_encntr,0)=0)
  DECLARE ein_pft_encntr = i4 WITH constant(4)
 ENDIF
 IF (validate(ein_benefit_order,0)=0)
  DECLARE ein_benefit_order = i4 WITH constant(5)
 ENDIF
 IF (validate(ein_guarantor,0)=0)
  DECLARE ein_guarantor = i4 WITH constant(6)
 ENDIF
 IF (validate(ein_encounter,0)=0)
  DECLARE ein_encounter = i4 WITH constant(7)
 ENDIF
 IF (validate(ein_account,0)=0)
  DECLARE ein_account = i4 WITH constant(8)
 ENDIF
 IF (validate(ein_remittance,0)=0)
  DECLARE ein_remittance = i4 WITH constant(9)
 ENDIF
 IF (validate(ein_eob,0)=0)
  DECLARE ein_eob = i4 WITH constant(10)
 ENDIF
 IF (validate(ein_billing_entity,0)=0)
  DECLARE ein_billing_entity = i4 WITH constant(11)
 ENDIF
 IF (validate(ein_person,0)=0)
  DECLARE ein_person = i4 WITH constant(12)
 ENDIF
 IF (validate(ein_activity,0)=0)
  DECLARE ein_activity = i4 WITH constant(13)
 ENDIF
 IF (validate(ein_fin_nbr,0)=0)
  DECLARE ein_fin_nbr = i4 WITH constant(14)
 ENDIF
 IF (validate(ein_bo_hp_reltn,0)=0)
  DECLARE ein_bo_hp_reltn = i4 WITH constant(15)
 ENDIF
 IF (validate(ein_denial,0)=0)
  DECLARE ein_denial = i4 WITH constant(16)
 ENDIF
 IF (validate(ein_client_account,0)=0)
  DECLARE ein_client_account = i4 WITH constant(17)
 ENDIF
 IF (validate(ein_encntr_clln_reltn,0)=0)
  DECLARE ein_encntr_clln_reltn = i4 WITH constant(18)
 ENDIF
 IF (validate(ein_bill_nbr,0)=0)
  DECLARE ein_bill_nbr = i4 WITH constant(19)
 ENDIF
 IF (validate(ein_trans_alias,0)=0)
  DECLARE ein_trans_alias = i4 WITH constant(20)
 ENDIF
 IF (validate(ein_trans_alias_elements,0)=0)
  DECLARE ein_trans_alias_elements = i4 WITH constant(21)
 ENDIF
 IF (validate(ein_hold,0)=0)
  DECLARE ein_hold = i4 WITH constant(22)
 ENDIF
 IF (validate(ein_hold_prompt,0)=0)
  DECLARE ein_hold_prompt = i4 WITH constant(23)
 ENDIF
 IF (validate(ein_person_at,0)=0)
  DECLARE ein_person_at = i4 WITH constant(24)
 ENDIF
 IF (validate(ein_reversal,0)=0)
  DECLARE ein_reversal = i4 WITH constant(25)
 ENDIF
 IF (validate(ein_ext_acct_id_txt,0)=0)
  DECLARE ein_ext_acct_id_txt = i4 WITH constant(26)
 ENDIF
 IF (validate(ein_organization,0)=0)
  DECLARE ein_organization = i4 WITH constant(27)
 ENDIF
 IF (validate(ein_fifo,0)=0)
  DECLARE ein_fifo = i4 WITH constant(28)
 ENDIF
 IF (validate(ein_nopost,0)=0)
  DECLARE ein_nopost = i4 WITH constant(29)
 ENDIF
 IF (validate(ein_date_time,0)=0)
  DECLARE ein_date_time = i4 WITH constant(30)
 ENDIF
 IF (validate(ein_encntr_package,0)=0)
  DECLARE ein_encntr_package = i4 WITH constant(31)
 ENDIF
 IF (validate(ein_pay_plan_hist,0)=0)
  DECLARE ein_pay_plan_hist = i4 WITH constant(32)
 ENDIF
 IF (validate(ein_report_date,0)=0)
  DECLARE ein_report_date = i4 WITH constant(33)
 ENDIF
 IF (validate(ein_parent_entity,0)=0)
  DECLARE ein_parent_entity = i4 WITH constant(34)
 ENDIF
 IF (validate(ein_pay_plan_suggest,0)=0)
  DECLARE ein_pay_plan_suggest = i4 WITH constant(35)
 ENDIF
 IF (validate(ein_report_instance,0)=0)
  DECLARE ein_report_instance = i4 WITH constant(36)
 ENDIF
 IF (validate(ein_pft_fiscal_daily_id,0)=0)
  DECLARE ein_pft_fiscal_daily_id = i4 WITH constant(37)
 ENDIF
 IF (validate(ein_pft_encntr_fact_active,0)=0)
  DECLARE ein_pft_encntr_fact_active = i4 WITH constant(38)
 ENDIF
 IF (validate(ein_pft_encntr_fact_history,0)=0)
  DECLARE ein_pft_encntr_fact_history = i4 WITH constant(39)
 ENDIF
 IF (validate(ein_invoice,0)=0)
  DECLARE ein_invoice = i4 WITH constant(40)
 ENDIF
 IF (validate(ein_pending_batch,0)=0)
  DECLARE ein_pending_batch = i4 WITH constant(41)
 ENDIF
 IF (validate(ein_application,0)=0)
  DECLARE ein_application = i4 WITH constant(42)
 ENDIF
 IF (validate(ein_view,0)=0)
  DECLARE ein_view = i4 WITH constant(43)
 ENDIF
 IF (validate(ein_test,0)=0)
  DECLARE ein_test = i4 WITH constant(44)
 ENDIF
 IF (validate(ein_trans_alias_best_guess_wo_reason,0)=0)
  DECLARE ein_trans_alias_best_guess_wo_reason = i4 WITH constant(45)
 ENDIF
 IF (validate(ein_submitted_batch,0)=0)
  DECLARE ein_submitted_batch = i4 WITH constant(46)
 ENDIF
 IF (validate(ein_dequeue_wf_batch,0)=0)
  DECLARE ein_dequeue_wf_batch = i4 WITH constant(47)
 ENDIF
 IF (validate(ein_account_date,0)=0)
  DECLARE ein_account_date = i4 WITH constant(48)
 ENDIF
 IF (validate(ein_entity,0)=0)
  DECLARE ein_entity = i4 WITH constant(49)
 ENDIF
 IF (validate(ein_pft_line_item,0)=0)
  DECLARE ein_pft_line_item = i4 WITH constant(50)
 ENDIF
 IF (validate(ein_transfer,0)=0)
  DECLARE ein_transfer = i4 WITH constant(51)
 ENDIF
 IF (validate(ein_suppress,0)=0)
  DECLARE ein_suppress = i4 WITH constant(52)
 ENDIF
 IF (validate(ein_related_trans,0)=0)
  DECLARE ein_related_trans = i4 WITH constant(53)
 ENDIF
 IF (validate(ein_wf_entity_status,0)=0)
  DECLARE ein_wf_entity_status = i4 WITH constant(54)
 ENDIF
 IF (validate(ein_health_plan,0)=0)
  DECLARE ein_health_plan = i4 WITH constant(55)
 ENDIF
 IF (validate(ein_global_preference,0)=0)
  DECLARE ein_global_preference = i4 WITH constant(56)
 ENDIF
 IF (validate(ein_balance,0)=0)
  DECLARE ein_balance = i4 WITH constant(57)
 ENDIF
 IF (validate(ein_user_name,0)=0)
  DECLARE ein_user_name = i4 WITH constant(58)
 ENDIF
 IF (validate(ein_ready_to_bill,0)=0)
  DECLARE ein_ready_to_bill = i4 WITH constant(59)
 ENDIF
 IF (validate(ein_ready_to_bill_claim,0)=0)
  DECLARE ein_ready_to_bill_claim = i4 WITH constant(60)
 ENDIF
 IF (validate(ein_umdap_del,0)=0)
  DECLARE ein_umdap_del = i4 WITH constant(61)
 ENDIF
 IF (validate(ein_umdap_quest,0)=0)
  DECLARE ein_umdap_quest = i4 WITH constant(62)
 ENDIF
 IF (validate(ein_umdap_hist,0)=0)
  DECLARE ein_umdap_hist = i4 WITH constant(63)
 ENDIF
 IF (validate(ein_new_entity,0)=0)
  DECLARE ein_new_entity = i4 WITH constant(64)
 ENDIF
 IF (validate(ein_account_selfpay_bal,0)=0)
  DECLARE ein_account_selfpay_bal = i4 WITH constant(65)
 ENDIF
 IF (validate(ein_guarantor_selfpay_bal,0)=0)
  DECLARE ein_guarantor_selfpay_bal = i4 WITH constant(66)
 ENDIF
 IF (validate(ein_queue,0)=0)
  DECLARE ein_queue = i4 WITH constant(67)
 ENDIF
 IF (validate(ein_supervisor,0)=0)
  DECLARE ein_supervisor = i4 WITH constant(68)
 ENDIF
 IF (validate(ein_ar_management,0)=0)
  DECLARE ein_ar_management = i4 WITH constant(69)
 ENDIF
 IF (validate(ein_status,0)=0)
  DECLARE ein_status = i4 WITH constant(70)
 ENDIF
 IF (validate(ein_status_type_event,0)=0)
  DECLARE ein_status_type_event = i4 WITH constant(71)
 ENDIF
 IF (validate(ein_pftencntr_selfpay_bal,0)=0)
  DECLARE ein_pftencntr_selfpay_bal = i4 WITH constant(72)
 ENDIF
 IF (validate(ein_batch_event,0)=0)
  DECLARE ein_batch_event = i4 WITH constant(73)
 ENDIF
 IF (validate(ein_ready_to_bill_all_sp,0)=0)
  DECLARE ein_ready_to_bill_all_sp = i4 WITH constant(74)
 ENDIF
 IF (validate(ein_account_stmt,0)=0)
  DECLARE ein_account_stmt = i4 WITH constant(75)
 ENDIF
 IF (validate(ein_pft_encntr_stmt,0)=0)
  DECLARE ein_pft_encntr_stmt = i4 WITH constant(76)
 ENDIF
 IF (validate(ein_guarantor_stmt,0)=0)
  DECLARE ein_guarantor_stmt = i4 WITH constant(77)
 ENDIF
 IF (validate(ein_pft_encntr_claim,0)=0)
  DECLARE ein_pft_encntr_claim = i4 WITH constant(78)
 ENDIF
 IF (validate(ein_pftencntr_combine,0)=0)
  DECLARE ein_pftencntr_combine = i4 WITH constant(79)
 ENDIF
 IF (validate(ein_current_eob,0)=0)
  DECLARE ein_current_eob = i4 WITH constant(80)
 ENDIF
 IF (validate(ein_prior_eobs,0)=0)
  DECLARE ein_prior_eobs = i4 WITH constant(81)
 ENDIF
 IF (validate(ein_last,0)=0)
  DECLARE ein_last = i4 WITH constant(82)
 ENDIF
 IF (validate(ein_cob,0)=0)
  DECLARE ein_cob = i4 WITH constant(83)
 ENDIF
 IF (validate(ein_encounter_active,0)=0)
  DECLARE ein_encounter_active = i4 WITH constant(84)
 ENDIF
 IF (validate(ein_remittance_all,0)=0)
  DECLARE ein_remittance_all = i4 WITH constant(85)
 ENDIF
 IF (validate(ein_pay_plan,0)=0)
  DECLARE ein_pay_plan = i4 WITH constant(86)
 ENDIF
 IF (validate(ein_guar_acct,0)=0)
  DECLARE ein_guar_acct = i4 WITH constant(87)
 ENDIF
 IF (validate(ein_report,0)=0)
  DECLARE ein_report = i4 WITH constant(88)
 ENDIF
 IF (validate(ein_ime_benefit_order,0)=0)
  DECLARE ein_ime_benefit_order = i4 WITH constant(89)
 ENDIF
 IF (validate(ein_formal_payment_plan,0)=0)
  DECLARE ein_formal_payment_plan = i4 WITH constant(90)
 ENDIF
 IF (validate(ein_guarantor_account,0)=0)
  DECLARE ein_guarantor_account = i4 WITH constant(91)
 ENDIF
 IF ((validate(gnstat,- (1))=- (1)))
  DECLARE gnstat = i4 WITH noconstant(0)
 ENDIF
 IF (validate(none_action,0)=0
  AND validate(none_action,1)=1)
  DECLARE none_action = i4 WITH public, constant(0)
 ENDIF
 IF (validate(add_action,0)=0
  AND validate(add_action,1)=1)
  DECLARE add_action = i4 WITH public, constant(1)
 ENDIF
 IF (validate(chg_action,0)=0
  AND validate(chg_action,1)=1)
  DECLARE chg_action = i4 WITH public, constant(2)
 ENDIF
 IF (validate(del_action,0)=0
  AND validate(del_action,1)=1)
  DECLARE del_action = i4 WITH public, constant(3)
 ENDIF
 IF (validate(pft_publish_event_flag,null_i2)=null_i2)
  DECLARE pft_publish_event_flag = i2 WITH public, noconstant(0)
 ENDIF
 DECLARE __hpsys = i4 WITH protect, noconstant(0)
 DECLARE __lpsysstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(threads)))
  FREE RECORD threads
  RECORD threads(
    1 objarray[*]
      2 request_handle = i4
      2 start_time = dq8
  )
 ENDIF
 IF ( NOT (validate(codevalueslist)))
  RECORD codevalueslist(
    1 codevalues[*]
      2 codevalue = f8
  ) WITH protect
 ENDIF
 IF (validate(logmsg,char(128))=char(128))
  SUBROUTINE (logmsg(sname=vc,smsg=vc,llevel=i4) =null)
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo(concat(sname,": ",smsg))
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __hpsys = 0
    SET __lpsysstat = 0
    CALL uar_syscreatehandle(__hpsys,__lpsysstat)
    IF (__hpsys > 0)
     CALL uar_sysevent(__hpsys,llevel,nullterm(sname),nullterm(smsg))
     CALL uar_sysdestroyhandle(__hpsys)
    ENDIF
    IF (llevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(smsg))
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
 IF (validate(setreply,char(128))=char(128))
  SUBROUTINE (setreply(sstatus=vc,sname=vc,svalue=vc) =null)
    IF (validate(reply,char(128)) != char(128))
     SET reply->status_data.status = nullterm(sstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(sstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(sname)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(svalue)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplyblock,char(128))=char(128))
  SUBROUTINE (setreplyblock(sstatus=c1,soperstatus=c1,sname=vc,svalue=vc) =null)
   CALL logmsg(sname,svalue,log_debug)
   IF (validate(reply,char(128)) != char(128))
    SET reply->status_data.status = nullterm(sstatus)
    SET reply->status_data.subeventstatus[1].operationstatus = nullterm(soperstatus)
    SET reply->status_data.subeventstatus[1].operationname = nullterm(sname)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(svalue)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(beginscript,char(128))=char(128))
  SUBROUTINE (beginscript(sname=vc) =null)
   CALL logmsg(sname,"Begin Script",log_debug)
   CALL setreply("F",sname,"Begin Script")
  END ;Subroutine
 ENDIF
 IF (validate(exitscript,char(128))=char(128))
  SUBROUTINE (exitscript(sname=vc) =null)
   CALL logmsg(sname,"Exit Script",log_debug)
   CALL setreply("S",sname,"Exit Script")
  END ;Subroutine
 ENDIF
 IF (validate(abortscript,char(128))=char(128))
  SUBROUTINE (abortscript(sname=vc,smsg=vc) =null)
   CALL logmsg(sname,smsg,log_warning)
   CALL setreply("F",sname,smsg)
  END ;Subroutine
 ENDIF
 IF (validate(setfieldheader,char(128))=char(128))
  SUBROUTINE (setfieldheader(sfield=vc,stype=vc,sdisplay=vc) =null)
   DECLARE nheadersize = i2 WITH noconstant(0)
   IF (validate(objreply->headers)=1)
    SET nheadersize = (size(objreply->headers,5)+ 1)
    SET stat = alterlist(objreply->headers,nheadersize)
    SET objreply->headers[nheadersize].field_name = sfield
    SET objreply->headers[nheadersize].field_type = stype
    SET objreply->headers[nheadersize].header_display = sdisplay
   ELSEIF (validate(reply->headers)=1)
    SET nheadersize = (size(reply->headers,5)+ 1)
    SET stat = alterlist(reply->headers,nheadersize)
    SET reply->headers[nheadersize].field_name = sfield
    SET reply->headers[nheadersize].field_type = stype
    SET reply->headers[nheadersize].header_display = sdisplay
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setfieldheaderattr,char(128))=char(128))
  SUBROUTINE (setfieldheaderattr(sfield=vc,stype=vc,sdisplay=vc,sgroupprefix=vc,sgrpaggrprefix=vc,
   sgrpaggrfnctn=vc,stotalprefix=vc,stotalfunction=vc) =null)
   DECLARE nheadersize = i2 WITH noconstant(0)
   IF (validate(objreply->headers,char(128)) != char(128))
    SET nheadersize = (size(objreply->headers,5)+ 1)
    SET stat = alterlist(objreply->headers,nheadersize)
    SET objreply->headers[nheadersize].field_name = sfield
    SET objreply->headers[nheadersize].field_type = stype
    SET objreply->headers[nheadersize].header_display = sdisplay
    SET objreply->headers[nheadersize].group_prefix = sgroupprefix
    SET objreply->headers[nheadersize].group_aggr_prefix = sgrpaggrprefix
    SET objreply->headers[nheadersize].group_aggr_func = sgrpaggrfnctn
    SET objreply->headers[nheadersize].total_prefix = stotalprefix
    SET objreply->headers[nheadersize].total_func = stotalfunction
   ELSEIF (validate(reply->headers,char(128)) != char(128))
    SET nheadersize = (size(reply->headers,5)+ 1)
    SET stat = alterlist(reply->headers,nheadersize)
    SET reply->headers[nheadersize].field_name = sfield
    SET reply->headers[nheadersize].field_type = stype
    SET reply->headers[nheadersize].header_display = sdisplay
    SET reply->headers[nheadersize].group_prefix = sgroupprefix
    SET reply->headers[nheadersize].group_aggr_prefix = sgrpaggrprefix
    SET reply->headers[nheadersize].group_aggr_func = sgrpaggrfnctn
    SET reply->headers[nheadersize].total_prefix = stotalprefix
    SET reply->headers[nheadersize].total_func = stotalfunction
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(formatcurrency,char(128))=char(128))
  SUBROUTINE (formatcurrency(damt=f8) =vc)
    DECLARE sformattedamt = vc WITH noconstant("")
    SET sformattedamt = format(damt,"#########.##;I$,;F")
    IF (damt <= 0)
     SET sformattedamt = trim(sformattedamt,3)
     SET sformattedamt = substring(2,textlen(sformattedamt),sformattedamt)
     SET sformattedamt = concat("(",trim(sformattedamt,3),")")
    ENDIF
    SET sformattedamt = trim(sformattedamt,3)
    RETURN(sformattedamt)
  END ;Subroutine
 ENDIF
 IF (validate(setsrvdouble,char(128))=char(128))
  SUBROUTINE (setsrvdouble(hhandle=i4,sfield=vc,dvalue=f8) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetdouble(hhandle,nullterm(sfield),dvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvstring,char(128))=char(128))
  SUBROUTINE (setsrvstring(hhandle=i4,sfield=vc,svalue=vc) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetstring(hhandle,nullterm(sfield),nullterm(svalue))
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvlong,char(128))=char(128))
  SUBROUTINE (setsrvlong(hhandle=i4,sfield=vc,lvalue=i4) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetlong(hhandle,nullterm(sfield),lvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvshort,char(128))=char(128))
  SUBROUTINE (setsrvshort(hhandle=i4,sfield=vc,nvalue=i4) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetshort(hhandle,nullterm(sfield),nvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvdate,char(128))=char(128))
  SUBROUTINE (setsrvdate(hhandle=i4,sfield=vc,dtvalue=q8) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetdate(hhandle,nullterm(sfield),dtvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(publishevent,char(128))=char(128))
  SUBROUTINE (publishevent(dummyvar=i4) =null)
    CALL logmsg(curprog,"IN PublishEvent",log_debug)
    DECLARE nappid = i4 WITH protect, constant(4080000)
    DECLARE ntaskid = i4 WITH protect, constant(4080000)
    DECLARE nreqid = i4 WITH protect, constant(4080140)
    DECLARE sreq = vc WITH protect, constant("pft_manage_event_completion")
    DECLARE happ = i4 WITH protect, noconstant(0)
    DECLARE htask = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrequest = i4 WITH protect, noconstant(0)
    DECLARE hitem = i4 WITH protect, noconstant(0)
    DECLARE hreply = i4 WITH protect, noconstant(0)
    DECLARE hstatus = i4 WITH protect, noconstant(0)
    DECLARE ncnt = i4 WITH protect, noconstant(0)
    DECLARE npidx = i4 WITH protect, noconstant(0)
    DECLARE ipublisheventflg = i2 WITH constant(validate(pft_publish_event_flag,0))
    IF (validate(pft_publish_event_flag))
     CALL logmsg(curprog,concat("pft_publish_event_flag exist. value:: ",cnvtstring(
        pft_publish_event_flag,5)),4)
    ELSE
     CALL logmsg(curprog,"pft_publish_event_flag doesn't exist",4)
    ENDIF
    IF (validate(reply->objarray,char(128))=char(128))
     CALL logmsg(curprog,"No objArray found in reply",log_debug)
     RETURN
    ENDIF
    IF (validate(reply->status_data.status,"F") != "S")
     CALL logmsg(curprog,concat("Reply status as (",validate(reply->status_data.status,"F"),
       "). Not publishing events."),log_debug)
     RETURN
    ENDIF
    CASE (ipublisheventflg)
     OF 0:
      SET curalias eventrec reply->objarray[npidx]
      SET ncnt = size(reply->objarray,5)
     OF 1:
      CALL queueitemstoeventrec(0)
      RETURN
     OF 2:
      SET curalias eventrec pft_event_rec->objarray[npidx]
      SET ncnt = size(pft_event_rec->objarray,5)
    ENDCASE
    IF (ncnt > 0)
     SET npidx = 1
     IF (validate(eventrec->published_ind,null_i2)=null_i2)
      CALL logmsg(curprog,"Field published_ind not found in objArray",log_debug)
      RETURN
     ENDIF
     SET gnstat = uar_crmbeginapp(nappid,happ)
     IF (gnstat != 0)
      CALL logmsg(curprog,"Unable to create application instance (4080000)",log_error)
      RETURN
     ENDIF
     SET gnstat = uar_crmbegintask(happ,ntaskid,htask)
     IF (gnstat != 0)
      CALL logmsg(curprog,"Unable to create task instance (4080000)",log_error)
      IF (happ > 0)
       CALL uar_crmendapp(happ)
      ENDIF
      RETURN
     ENDIF
     FOR (npidx = 1 TO ncnt)
       IF ((eventrec->published_ind=false))
        SET gnstat = uar_crmbeginreq(htask,nullterm(sreq),nreqid,hreq)
        IF (gnstat != 0)
         CALL logmsg(curprog,"Unable to create request instance (4080140)",log_error)
        ELSE
         SET hrequest = uar_crmgetrequest(hreq)
         IF (hrequest=0)
          CALL logmsg(curprog,"Unable to retrieve request handle for (4080140)",log_error)
         ELSE
          SET hitem = uar_srvadditem(hrequest,"objArray")
          IF (hitem=0)
           CALL logmsg(curprog,"Unable to add item to request (4080140)",log_error)
          ELSE
           IF (validate(eventrec->event_key,char(128)) != char(128))
            CALL setsrvstring(hitem,"event_key",eventrec->event_key)
           ELSE
            CALL logmsg(curprog,"Field event_key not found in objArray",log_debug)
           ENDIF
           IF (validate(eventrec->category_key,char(128)) != char(128))
            CALL setsrvstring(hitem,"category_key",eventrec->category_key)
           ELSE
            CALL logmsg(curprog,"Field category_key not found in objArray",log_debug)
           ENDIF
           IF (validate(eventrec->acct_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"acct_id",eventrec->acct_id)
           ENDIF
           IF (validate(eventrec->pft_encntr_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_encntr_id",eventrec->pft_encntr_id)
           ENDIF
           IF (validate(eventrec->encntr_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"encntr_id",eventrec->encntr_id)
           ENDIF
           IF (validate(eventrec->bo_hp_reltn_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"bo_hp_reltn_id",eventrec->bo_hp_reltn_id)
           ENDIF
           IF (validate(eventrec->corsp_activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"corsp_activity_id",eventrec->corsp_activity_id)
           ENDIF
           IF (validate(eventrec->activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"activity_id",eventrec->activity_id)
           ENDIF
           IF (validate(eventrec->pft_charge_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_charge_id",eventrec->pft_charge_id)
           ENDIF
           IF (validate(eventrec->service_cd,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"entity_service_cd",eventrec->service_cd)
           ENDIF
           IF (validate(eventrec->batch_trans_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"batch_trans_id",eventrec->batch_trans_id)
           ENDIF
           IF (validate(eventrec->pft_bill_activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_bill_activity_id",eventrec->pft_bill_activity_id)
           ENDIF
           IF (validate(eventrec->bill_vrsn_nbr,null_i4) != null_i4)
            CALL setsrvlong(hitem,"bill_vrsn_nbr",eventrec->bill_vrsn_nbr)
           ENDIF
           IF (validate(eventrec->pe_status_reason_cd,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pe_status_reason_cd",eventrec->pe_status_reason_cd)
           ENDIF
           CALL logmsg("PFT_COMMON",build("pft_publish_event_binding::",validate(
              pft_publish_event_binding,"N/A")),log_debug)
           IF (validate(pft_publish_event_binding,"") != "")
            SET gnstat = uar_crmperformas(hreq,nullterm(pft_publish_event_binding))
           ELSE
            SET gnstat = uar_crmperform(hreq)
           ENDIF
           IF (gnstat != 0)
            CALL logmsg(curprog,concat("Failed to execute server step (",cnvtstring(nreqid,11),")"),
             log_error)
           ELSE
            SET hreply = uar_crmgetreply(hreq)
            IF (hreply=0)
             CALL logmsg(curprog,"Failed to retrieve reply structure",log_error)
            ELSE
             SET hstatus = uar_srvgetstruct(hreply,"status_data")
             IF (hstatus=0)
              CALL logmsg(curprog,"Failed to retrieve status_block",log_error)
             ELSE
              IF (uar_srvgetstringptr(hstatus,"status")="S")
               SET eventrec->published_ind = true
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF (hreq > 0)
         CALL uar_crmendreq(hreq)
        ENDIF
       ENDIF
     ENDFOR
     IF (htask > 0)
      CALL uar_crmendtask(htask)
     ENDIF
     IF (happ > 0)
      CALL uar_crmendapp(happ)
     ENDIF
    ELSE
     CALL logmsg(curprog,"Not objects in objArray",log_debug)
    ENDIF
    SET curalias eventrec off
  END ;Subroutine
 ENDIF
 IF (validate(queueitemstoeventrec,char(128))=char(128))
  SUBROUTINE (queueitemstoeventrec(dummyvar=i4) =null)
    DECLARE ncnt = i4 WITH protect, noconstant(0)
    DECLARE npeventidx = i4 WITH protect, noconstant(0)
    DECLARE npidx = i4 WITH protect, noconstant(0)
    IF (validate(pft_event_rec,char(128))=char(128))
     CALL logmsg(curprog,"pft_event_rec must be declared by call InitEvents",4)
    ENDIF
    SET curalias event_rec pft_event_rec->objarray[npeventidx]
    SET curalias reply_rec reply->objarray[npidx]
    SET ncnt = size(reply->objarray,5)
    FOR (npidx = 1 TO ncnt)
      IF (validate(reply_rec->published_ind,true)=false)
       SET npeventidx = (size(pft_event_rec->objarray,5)+ 1)
       SET stat = alterlist(pft_event_rec->objarray,npeventidx)
       SET event_rec->published_ind = false
       SET event_rec->event_key = validate(reply_rec->event_key,"")
       SET event_rec->category_key = validate(reply_rec->category_key,"")
       SET event_rec->acct_id = validate(reply_rec->acct_id,0.0)
       SET event_rec->pft_encntr_id = validate(reply_rec->pft_encntr_id,0.0)
       SET event_rec->encntr_id = validate(reply_rec->encntr_id,0.0)
       SET event_rec->bo_hp_reltn_id = validate(reply_rec->bo_hp_reltn_id,0.0)
       SET event_rec->corsp_activity_id = validate(reply_rec->corsp_activity_id,0.0)
       SET event_rec->activity_id = validate(reply_rec->activity_id,0.0)
       SET event_rec->pft_charge_id = validate(reply_rec->pft_charge_id,0.0)
       SET event_rec->service_cd = validate(reply_rec->service_cd,0.0)
       SET event_rec->batch_trans_id = validate(reply_rec->batch_trans_id,0.0)
       SET event_rec->pft_bill_activity_id = validate(reply_rec->pft_bill_activity_id,0.0)
       SET event_rec->bill_vrsn_nbr = validate(reply_rec->bill_vrsn_nbr,0)
       SET event_rec->pe_status_reason_cd = validate(reply_rec->pe_status_reason_cd,0.0)
       SET reply_rec->published_ind = true
      ENDIF
    ENDFOR
    SET curalias event_rec off
    SET curalias reply_rec off
  END ;Subroutine
 ENDIF
 IF (validate(initevents,char(128))=char(128))
  SUBROUTINE (initevents(publishflag=i2) =null)
    SET pft_publish_event_flag = publishflag
    FREE RECORD pft_event_rec
    RECORD pft_event_rec(
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
    ) WITH persistscript
  END ;Subroutine
 ENDIF
 IF (validate(processevents,char(128))=char(128))
  SUBROUTINE (processevents(dummyvar=i4) =null)
    DECLARE itmppublishflag = i2 WITH private, noconstant(pft_publish_event_flag)
    SET pft_publish_event_flag = 2
    CALL publishevent(0)
    SET pft_publish_event_flag = itmppublishflag
  END ;Subroutine
 ENDIF
 IF (validate(stamptime,char(128))=char(128))
  SUBROUTINE (stamptime(dummyvar=i4) =null)
    CALL echo("-----------------TIME STAMP----------------")
    CALL echo(build("-----------",curprog,"-----------"))
    CALL echo(format(curtime3,"hh:mm:ss:cc;3;M"))
    CALL echo("-----------------TIME STAMP----------------")
  END ;Subroutine
 ENDIF
 IF (validate(isequal,char(128))=char(128))
  SUBROUTINE isequal(damt1,damt2)
   DECLARE tmpdiff = f8 WITH private, noconstant(abs((abs(damt1) - abs(damt2))))
   IF (tmpdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(nextavailablethread,char(128))=char(128))
  DECLARE nextavailablethread(null) = i4
  SUBROUTINE nextavailablethread(null)
    DECLARE thread_cnt = i4 WITH noconstant(size(threads->objarray,5))
    DECLARE i = i4 WITH noconstant(thread_cnt)
    DECLARE looping = i2 WITH noconstant(true)
    WHILE (thread_cnt > 0
     AND looping)
     IF ((threads->objarray[i].request_handle > 0))
      IF ((threads->objarray[i].start_time=null))
       SET threads->objarray[i].start_time = cnvtdatetime(sysdate)
      ENDIF
      IF (uar_crmperformpeek(threads->objarray[i].request_handle) IN (0, 1, 4, 5))
       SET stat = uar_crmsynch(threads->objarray[i].request_handle)
       CALL uar_crmendreq(threads->objarray[i].request_handle)
       SET threads->objarray[i].request_handle = 0
       SET threads->objarray[i].start_time = null
       SET looping = false
      ENDIF
     ELSE
      SET looping = false
     ENDIF
     IF (looping)
      SET i = evaluate(i,1,thread_cnt,(i - 1))
     ENDIF
    ENDWHILE
    RETURN(i)
  END ;Subroutine
 ENDIF
 IF (validate(waituntilthreadscomplete,char(128))=char(128))
  DECLARE waituntilthreadscomplete(null) = i4
  SUBROUTINE waituntilthreadscomplete(null)
    DECLARE thread_cnt = i4 WITH noconstant(size(threads->objarray,5))
    DECLARE i = i4 WITH noconstant(thread_cnt)
    FOR (i = 1 TO thread_cnt)
      IF ((threads->objarray[i].request_handle > 0))
       IF ((threads->objarray[i].start_time=null))
        SET threads->objarray[i].start_time = cnvtdatetime(sysdate)
       ENDIF
       SET stat = uar_crmsynch(threads->objarray[i].request_handle)
       CALL uar_crmendreq(threads->objarray[i].request_handle)
       SET threads->objarray[i].request_handle = 0
       SET threads->objarray[i].start_time = null
      ENDIF
    ENDFOR
    RETURN
  END ;Subroutine
 ENDIF
 IF (validate(waitforthreadtocomplete,char(128))=char(128))
  SUBROUTINE (waitforthreadtocomplete(thread=i4) =i4)
    IF ( NOT (validate(threads)))
     RETURN(0)
    ENDIF
    IF ( NOT (size(threads->objarray,5) > 0))
     RETURN(0)
    ENDIF
    IF ((threads->objarray[thread].request_handle > 0))
     IF ((threads->objarray[thread].start_time=null))
      SET threads->objarray[thread].start_time = cnvtdatetime(sysdate)
     ENDIF
     SET stat = uar_crmsynch(threads->objarray[thread].request_handle)
     CALL uar_crmendreq(threads->objarray[thread].request_handle)
     SET threads->objarray[thread].request_handle = 0
     SET threads->objarray[thread].start_time = null
    ENDIF
    RETURN(thread)
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalueindex,char(128))=char(128))
  SUBROUTINE (getcodevalueindex(pcodevalue=f8,prcodevalueslist=vc(ref)) =i4)
    IF (((pcodevalue <= 0.0) OR (size(prcodevalueslist->codevalues,5)=0)) )
     RETURN(0)
    ENDIF
    DECLARE num = i4 WITH protect, noconstant(0)
    RETURN(locateval(num,1,size(prcodevalueslist->codevalues,5),pcodevalue,prcodevalueslist->
     codevalues[num].codevalue))
  END ;Subroutine
 ENDIF
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 RECORD t_parse_param(
   1 qual_cnt = i4
   1 qual[*]
     2 name = vc
     2 value = vc
 )
 SUBROUTINE (s_init_parse(s_source=vc,s_beg_marker=vc,s_end_marker=vc,s_delimiter=vc,s_delimiter2=vc,
  s_error_flag=i2) =i4)
   SET t_parse_param->qual_cnt = 0
   DECLARE t_beg = i4 WITH private, noconstant(0)
   DECLARE t_end = i4 WITH private, noconstant(0)
   DECLARE t_size = i4 WITH private, noconstant(0)
   DECLARE t_string = vc WITH protect, noconstant(trim(s_source,3))
   DECLARE t_param = vc WITH protect, noconstant(" ")
   IF (t_string <= " ")
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("ERROR-->s_init_parse (Input source string is empty."," CURPROG [",
       curprog,"]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_init_parse (Input source string is empty."," CURPROG [",curprog,"]")
       )
    ENDCASE
    RETURN(t_parse_param->qual_cnt)
   ENDIF
   SET t_beg = findstring(s_beg_marker,t_string,1,0)
   SET t_end = findstring(s_end_marker,t_string,1,1)
   IF (((t_beg=0) OR (((t_end=0) OR (((t_end - t_beg) < 2))) )) )
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("ERROR-->s_init_parse (Invalid marker for input string: ",s_source,
       " CURPROG [",curprog,"]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_init_parse (Invalid marker for input string: ",s_source," CURPROG [",
        curprog,"]"))
    ENDCASE
    RETURN(t_parse_param->qual_cnt)
   ENDIF
   SET t_string = concat(substring((t_beg+ 1),((t_end - t_beg) - 1),t_string),s_delimiter)
   SET t_beg = 1
   SET t_size = size(t_string)
   WHILE (t_beg <= t_size)
     SET t_end = findstring(s_delimiter,t_string,t_beg,0)
     SET t_param = substring(t_beg,(t_end - t_beg),t_string)
     CALL s_parse_param(t_param,s_delimiter2)
     SET t_beg = (t_end+ 1)
   ENDWHILE
   SET stat = alterlist(t_parse_param->qual,t_parse_param->qual_cnt)
   RETURN(t_parse_param->qual_cnt)
 END ;Subroutine
 SUBROUTINE (s_parse_param(s_param=vc,s_delimiter3=vc) =i4)
   DECLARE t_pos = i4 WITH private, noconstant(findstring(s_delimiter3,s_param,1,0))
   SET t_parse_param->qual_cnt += 1
   IF (mod(t_parse_param->qual_cnt,10)=1)
    SET stat = alterlist(t_parse_param->qual,(t_parse_param->qual_cnt+ 9))
   ENDIF
   IF (t_pos > 0)
    SET t_parse_param->qual[t_parse_param->qual_cnt].name = trim(substring(1,(t_pos - 1),s_param),3)
    SET t_parse_param->qual[t_parse_param->qual_cnt].value = trim(substring((t_pos+ 1),(size(s_param)
       - t_pos),s_param),3)
   ELSE
    SET t_parse_param->qual[t_parse_param->qual_cnt].value = trim(s_param,3)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_get_value_by_name(s_input_name=vc,s_error_flag=i2) =vc)
   DECLARE t_retvalue = vc WITH protect, noconstant(" ")
   DECLARE t_found = i2 WITH protect, noconstant(0)
   FOR (index = 1 TO t_parse_param->qual_cnt)
     IF ((t_parse_param->qual[index].name=s_input_name))
      SET t_retvalue = t_parse_param->qual[index].value
      SET index = (t_parse_param->qual_cnt+ 1)
      SET t_found = 1
     ENDIF
   ENDFOR
   IF (t_found=0)
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("WARNING-->s_get_value_by_name (No value found for a param name: ",
       s_input_name," CURPROG [",curprog,"]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("WARNING-->s_get_value_by_name (No value found for a param name: ",s_input_name,
        " CURPROG [",curprog,"]"))
    ENDCASE
   ENDIF
   RETURN(t_retvalue)
 END ;Subroutine
 SUBROUTINE (s_get_value_by_index(s_input_index=i4,s_error_flag=i2) =vc)
   IF ((s_input_index <= t_parse_param->qual_cnt)
    AND s_input_index > 0)
    RETURN(t_parse_param->qual[s_input_index].value)
   ENDIF
   CASE (s_error_flag)
    OF 0:
     SET table_name = build("ERROR-->s_get_value_by_index (Out of bound index: ",s_input_index,
      " CURPROG [",curprog,"]")
     CALL echo(table_name)
     SET failed = attribute_error
     GO TO exit_script
    OF 1:
     CALL echo(build("ERROR-->s_get_value_by_index (Out of bound index: ",s_input_index," CURPROG [",
       curprog,"]"))
   ENDCASE
   RETURN("")
 END ;Subroutine
 SUBROUTINE (s_get_param_count(s_null=i2) =i4)
   RETURN(t_parse_param->qual_cnt)
 END ;Subroutine
 DECLARE pft_event_params_vrsn = vc WITH noconstant("433520.003")
 IF ( NOT (validate(echotimingmsg)))
  SUBROUTINE (echotimingmsg(pmessage=vc(val),pstarttime=f8(ref)) =null)
    DECLARE timing = f8 WITH private, noconstant(0.0)
    DECLARE sfiller = vc WITH private, noconstant(fillstring(90," "))
    SET timing = datetimediff(cnvtdatetime(sysdate),pstarttime,5)
    CALL echo(build2("[",trim(cnvtstring(curmem),3),"]:",substring(1,90,concat(curprog," : ",pmessage,
        sfiller))," [",
      substring(1,12,trim(format(timing,"#######.##########"),3)),"]"))
    SET pstarttime = cnvtdatetime(sysdate)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getelapsedtime(pstarttime=f8(ref)) =vc)
   DECLARE timing = f8 WITH noconstant(datetimediff(cnvtdatetime(sysdate),pstarttime,8))
   SET pstarttime = cnvtdatetime(sysdate)
   RETURN(substring(6,13,format(timing,"####.##:##:##")))
 END ;Subroutine
 SUBROUTINE (eventparamexists(paramname=vc) =i2)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   IF ( NOT (validate(pft_event_rep)))
    RETURN(false)
   ENDIF
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,paramname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventparamasinteger(parmname=vc) =i4)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,parmname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    RETURN(cnvtint(pft_event_rep->aparams[idx].svalue))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventparamascodevalue(parmname=vc) =f8)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,parmname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    RETURN(pft_event_rep->aparams[idx].dvalue_meaning)
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventparamaslist(sparamname=vc,sparamtype=vc,slistname=vc,slistitemname=vc) =i4)
   DECLARE icheck = i2 WITH protect, noconstant(0)
   IF ( NOT (cnvtupper(sparamtype) IN ("INTEGER", "REAL", "STRING")))
    RETURN(0)
   ENDIF
   DECLARE lmatchcount = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO pft_event_rep->lparams_qual)
     IF ((pft_event_rep->aparams[i].svalue_meaning=sparamname))
      SET lmatchcount += 1
     ENDIF
   ENDFOR
   IF (lmatchcount=0)
    RETURN(0)
   ENDIF
   CALL parser(build2("set iCheck = validate(",slistname,") go"),1)
   IF ( NOT (icheck))
    RETURN(0)
   ENDIF
   CALL parser(build2("set stat = alterlist(",slistname,",0) go"),1)
   CALL parser(build2("set stat = alterlist(",slistname,",",trim(cnvtstring(lmatchcount)),") go"),1)
   CALL parser(build2("set iCheck = validate(",slistname,"[1]->",slistitemname,") go"),1)
   IF ( NOT (icheck))
    RETURN(0)
   ENDIF
   DECLARE litemidx = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO pft_event_rep->lparams_qual)
     IF ((pft_event_rep->aparams[i].svalue_meaning=sparamname))
      SET litemidx += 1
      CASE (cnvtupper(sparamtype))
       OF "INTEGER":
        CALL parser(build2("set ",slistname,"[",litemidx,"]->",
          slistitemname,"=",cnvtint(pft_event_rep->aparams[i].svalue)," go"),1)
       OF "REAL":
        CALL parser(build2("set ",slistname,"[",litemidx,"]->",
          slistitemname,"=",cnvtreal(pft_event_rep->aparams[i].svalue)," go"),1)
       OF "STRING":
        CALL parser(build2("set ",slistname,"[",litemidx,"]->",
          slistitemname,"='",trim(pft_event_rep->aparams[i].svalue),"' go"),1)
      ENDCASE
     ENDIF
   ENDFOR
   RETURN(lmatchcount)
 END ;Subroutine
 SUBROUTINE (geteventparamasreal(parmname=vc) =f8)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,parmname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    RETURN(cnvtreal(pft_event_rep->aparams[idx].svalue))
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventparamasstring(parmname=vc) =vc)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,parmname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    IF (substring(1,7,parmname)="PFTOPS_")
     RETURN(nullterm(cnvtupper(trim(pft_event_rep->aparams[idx].svalue))))
    ELSE
     RETURN(nullterm(trim(pft_event_rep->aparams[idx].svalue)))
    ENDIF
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 DECLARE geteventparamcount(null) = i4
 SUBROUTINE geteventparamcount(null)
   RETURN(pft_event_rep->lparams_qual)
 END ;Subroutine
 SUBROUTINE (geteventparamindexbyname(parmname=vc) =i4)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,parmname,pft_event_rep->aparams[num].
    svalue_meaning)
   RETURN(idx)
 END ;Subroutine
 SUBROUTINE (geteventparamnamebyindex(lindex=i4) =vc)
   RETURN(trim(pft_event_rep->aparams[lindex].svalue_meaning))
 END ;Subroutine
 IF ( NOT (validate(quiet)))
  SUBROUTINE (quiet(mode=vc) =i2)
    IF ( NOT (validate(verbose,- (1)) > 0))
     IF (trim(cnvtupper(mode))="ON")
      SET trace = nocallecho
      SET trace = nowarning
      SET message = noinformation
     ENDIF
     IF (trim(cnvtupper(mode))="OFF")
      SET trace = callecho
      SET trace = warning
      SET message = information
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF ("Z"=validate(pft_declare_bus_svc_req_sub_vrsn,"Z"))
  DECLARE pft_declare_bus_svc_req_sub_vrsn = vc WITH noconstant("623278.007")
 ENDIF
 IF ( NOT (validate(custom_job_req_defs)))
  RECORD custom_job_req_defs(
    1 field_cnt = i4
    1 field_def[*]
      2 data_type = vc
      2 source_cdf = vc
      2 cnt_item = vc
      2 list_item = vc
      2 data_item = vc
  ) WITH persistscript
  SET custom_job_req_defs->field_cnt = 0
 ENDIF
 IF (validate(dbsr_verbose_mode,- (1)) < 0)
  DECLARE dbsr_verbose_mode = i2 WITH noconstant(false)
 ENDIF
 SUBROUTINE (createbusinessservicerequest(sstructname=vc,sparententityname=vc,dparententityid=f8) =i2
  )
   IF (dbsr_verbose_mode)
    CALL echo(fillstring(79,"="))
    CALL echo(build2("Constructing a business service request named ",sstructname,
      " for parent_entity_name ",sparententityname," and parent_entity_id ",
      trim(cnvtstring(dparententityid),3)))
    CALL echo(fillstring(79,"="))
   ENDIF
   DECLARE sdoublevalue = vc WITH protect, noconstant("")
   SET sdoublevalue = format(dparententityid,"#####################.##########;L")
   CALL parser(build2("free record ",sstructname," go"),1)
   CALL parser(build2("record ",sstructname," ("),1)
   CALL parser("1 objArray[*]",1)
   CASE (cnvtupper(sparententityname))
    OF "CONS_BO_SCHED":
     CALL parser("  2 cons_bo_sched_id   = f8",1)
    OF "ACCOUNT":
     CALL parser("  2 acct_id            = f8",1)
    OF "PFT_ENCNTR":
     CALL parser("  2 pft_encntr_id      = f8",1)
    OF "ENCOUNTER":
     CALL parser("  2 encntr_id          = f8",1)
    OF "BILL_REC":
     CALL parser("  2 corsp_activity_id  = f8",1)
     CALL parser("  2 bill_vrsn_nbr      = i4",1)
    OF "BO_HP_RELTN":
     CALL parser("  2 bo_hp_reltn_id     = f8",1)
    OF "ACTIVITY_LOG":
     CALL parser("  2 activity_id        = f8",1)
    OF "PFT_CHARGE":
     CALL parser("  2 pft_charge_id      = f8",1)
    OF "CHARGE":
     CALL parser("  2 charge_item_id     = f8",1)
    OF "PFT_ARWB_DATA_EXT":
     CALL parser("  2 pft_arwb_data_ext_id     = f8",1)
    ELSE
     CALL parser("  2 parent_entity_name = vc",1)
     CALL parser("  2 parent_entity_id   = f8",1)
   ENDCASE
   DECLARE fldidx = i4 WITH protect, noconstant(0)
   IF ((custom_job_req_defs->field_cnt > 0))
    FOR (fldidx = 1 TO custom_job_req_defs->field_cnt)
      IF ((custom_job_req_defs->field_def[fldidx].cnt_item != "")
       AND (custom_job_req_defs->field_def[fldidx].list_item != ""))
       CALL parser(build2("1 ",custom_job_req_defs->field_def[fldidx].cnt_item," = i4"),1)
       CALL parser(build2("1 ",custom_job_req_defs->field_def[fldidx].list_item,"[*]"),1)
       CALL parser(build2("  2 ",custom_job_req_defs->field_def[fldidx].data_item," = ",
         custom_job_req_defs->field_def[fldidx].data_type),1)
      ELSE
       CALL parser(build2("1 ",custom_job_req_defs->field_def[fldidx].data_item," = ",
         custom_job_req_defs->field_def[fldidx].data_type),1)
      ENDIF
    ENDFOR
   ENDIF
   CALL parser(") with persistscript go",1)
   CALL parser(build2("set stat = alterlist(",sstructname,"->objArray,1) go"),1)
   CASE (cnvtupper(sparententityname))
    OF "CONS_BO_SCHED":
     CALL parser(build2("set ",sstructname,"->objArray[1]->cons_bo_sched_id = ",sdoublevalue," go"),1
      )
    OF "ACCOUNT":
     CALL parser(build2("set ",sstructname,"->objArray[1]->acct_id = ",sdoublevalue," go"),1)
    OF "PFT_ENCNTR":
     CALL parser(build2("set ",sstructname,"->objArray[1]->pft_encntr_id = ",sdoublevalue," go"),1)
    OF "ENCOUNTER":
     CALL parser(build2("set ",sstructname,"->objArray[1]->encntr_id = ",sdoublevalue," go"),1)
    OF "BILL_REC":
     CALL parser(build2("set ",sstructname,"->objArray[1]->corsp_activity_id = ",sdoublevalue," go"),
      1)
     CALL parser(build2("set ",sstructname,"->objArray[1]->bill_vrsn_nbr = 0 go"),1)
    OF "BO_HP_RELTN":
     CALL parser(build2("set ",sstructname,"->objArray[1]->bo_hp_reltn_id = ",sdoublevalue," go"),1)
    OF "ACTIVITY_LOG":
     CALL parser(build2("set ",sstructname,"->objArray[1]->activity_id = ",sdoublevalue," go"),1)
    OF "PFT_CHARGE":
     CALL parser(build2("set ",sstructname,"->objArray[1]->pft_charge_id = ",sdoublevalue," go"),1)
    OF "CHARGE":
     CALL parser(build2("set ",sstructname,"->objArray[1]->charge_item_id = ",sdoublevalue," go"),1)
    OF "PFT_ARWB_DATA_EXT":
     CALL parser(build2("set ",sstructname,"->objArray[1]->PFT_ARWB_DATA_EXT_ID = ",sdoublevalue,
       " go"),1)
    ELSE
     CALL parser(build2("set ",sstructname,"->objArray[1]->parent_entity_name = '",sparententityname,
       "' go"),1)
     CALL parser(build2("set ",sstructname,"->objArray[1]->parent_entity_id = ",sdoublevalue," go"),1
      )
   ENDCASE
   DECLARE valcnt = i4 WITH protect, noconstant(0)
   DECLARE sparamtype = vc WITH protect, noconstant("")
   DECLARE slistname = vc WITH protect, noconstant("")
   DECLARE sdataitemname = vc WITH protect, noconstant("")
   DECLARE ltempinteger = i4 WITH protect, noconstant(0)
   DECLARE dtempreal = f8 WITH protect, noconstant(0.0)
   DECLARE stempstring = vc WITH protect, noconstant("")
   IF ((custom_job_req_defs->field_cnt > 0))
    FOR (fldidx = 1 TO custom_job_req_defs->field_cnt)
      IF ((custom_job_req_defs->field_def[fldidx].cnt_item != "")
       AND (custom_job_req_defs->field_def[fldidx].list_item != ""))
       CASE (cnvtupper(custom_job_req_defs->field_def[fldidx].data_type))
        OF "I4":
         SET sparamtype = "INTEGER"
        OF "F8":
         SET sparamtype = "REAL"
        OF "VC":
         SET sparamtype = "STRING"
       ENDCASE
       SET slistname = custom_job_req_defs->field_def[fldidx].list_item
       SET sdataitemname = custom_job_req_defs->field_def[fldidx].data_item
       SET valcnt = geteventparamaslist(custom_job_req_defs->field_def[fldidx].source_cdf,sparamtype,
        build(sstructname,"->",slistname),sdataitemname)
       CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].cnt_item,
         " = ",
         valcnt," go"),1)
      ELSE
       CASE (substring(1,1,custom_job_req_defs->field_def[fldidx].source_cdf))
        OF ">":
         SET stempstring = substring(2,(size(custom_job_req_defs->field_def[fldidx].source_cdf) - 1),
          custom_job_req_defs->field_def[fldidx].source_cdf)
         IF (cnvtupper(custom_job_req_defs->field_def[fldidx].data_type) IN ("I1", "I2", "I4", "I8"))
          SET ltempinteger = cnvtint(stempstring)
          CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].data_item,
            " = ",
            ltempinteger," go"),1)
         ELSEIF (cnvtupper(custom_job_req_defs->field_def[fldidx].data_type) IN ("F4", "F8"))
          SET dtempreal = cnvtreal(stempstring)
          CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].data_item,
            " = ",
            dtempreal," go"),1)
         ELSEIF (cnvtupper(custom_job_req_defs->field_def[fldidx].data_type)="DQ8")
          CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].data_item,
            " = cnvtdatetime('",
            stempstring,"') go"),1)
         ELSE
          CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].data_item,
            " = '",
            stempstring,"' go"),1)
         ENDIF
        ELSE
         CASE (cnvtupper(custom_job_req_defs->field_def[fldidx].data_type))
          OF "I4":
           SET ltempinteger = geteventparamasinteger(cnvtupper(custom_job_req_defs->field_def[fldidx]
             .source_cdf))
           CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].
             data_item," = ",
             ltempinteger," go"),1)
          OF "F8":
           SET dtempreal = geteventparamasreal(cnvtupper(custom_job_req_defs->field_def[fldidx].
             source_cdf))
           CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].
             data_item," = ",
             dtempreal," go"),1)
          OF "VC":
           SET stempstring = geteventparamasstring(cnvtupper(custom_job_req_defs->field_def[fldidx].
             source_cdf))
           CALL parser(build2("set ",sstructname,"->",custom_job_req_defs->field_def[fldidx].
             data_item," = '",
             stempstring,"' go"),1)
         ENDCASE
       ENDCASE
      ENDIF
    ENDFOR
   ENDIF
   IF (dbsr_verbose_mode)
    CALL parser(build2("call echorecord(",sstructname,") go"))
    CALL echo("")
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includedatevalueitem(qdate=q8,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(build(">",format(qdate,
      "DD-MMM-YYYY HH:MM:SS.CC;;d")))
   SET custom_job_req_defs->field_def[fldcnt].data_type = "dq8"
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includeintegeritem(scdf=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "i4"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includeintegerlist(scdf=vc,scnt=vc,slist=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "i4"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].cnt_item = nullterm(scnt)
   SET custom_job_req_defs->field_def[fldcnt].list_item = nullterm(slist)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includeliteralvalueitem(sliteralvalue=vc,sitemtype=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(build(">",sliteralvalue))
   SET custom_job_req_defs->field_def[fldcnt].data_type = nullterm(sitemtype)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includerealitem(scdf=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "f8"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includereallist(scdf=vc,scnt=vc,slist=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "f8"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].cnt_item = nullterm(scnt)
   SET custom_job_req_defs->field_def[fldcnt].list_item = nullterm(slist)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includestringitem(scdf=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "vc"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (includestringlist(scdf=vc,scnt=vc,slist=vc,sitem=vc) =i2)
   DECLARE fldcnt = i4 WITH protect, noconstant(0)
   SET fldcnt = (custom_job_req_defs->field_cnt+ 1)
   SET custom_job_req_defs->field_cnt = fldcnt
   SET stat = alterlist(custom_job_req_defs->field_def,fldcnt)
   SET custom_job_req_defs->field_def[fldcnt].data_type = "vc"
   SET custom_job_req_defs->field_def[fldcnt].source_cdf = nullterm(scdf)
   SET custom_job_req_defs->field_def[fldcnt].cnt_item = nullterm(scnt)
   SET custom_job_req_defs->field_def[fldcnt].list_item = nullterm(slist)
   SET custom_job_req_defs->field_def[fldcnt].data_item = nullterm(sitem)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (setdbsrverbosemode(iboolean=i2) =i2)
  SET dbsr_verbose_mode = iboolean
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (additemtoservicerequest(sstructname=vc(ref),sparententityname=vc,dparententityid=f8) =i2
  )
   DECLARE recsize = i4 WITH noconstant(0), private
   IF ( NOT (validate(sstructname->objarray)))
    RETURN(false)
   ELSE
    SET recsize = (size(sstructname->objarray,5)+ 1)
    SET stat = alterlist(sstructname->objarray,recsize)
    CASE (cnvtupper(sparententityname))
     OF "CONS_BO_SCHED":
      SET sstructname->objarray[recsize].cons_bo_sched_id = dparententityid
     OF "ACCOUNT":
      SET sstructname->objarray[recsize].acct_id = dparententityid
     OF "PFT_ENCNTR":
      SET sstructname->objarray[recsize].pft_encntr_id = dparententityid
     OF "ENCOUNTER":
      SET sstructname->objarray[recsize].encntr_id = dparententityid
     OF "BILL_REC":
      SET sstructname->objarray[recsize].corsp_activity_id = dparententityid
     OF "BO_HP_RELTN":
      SET sstructname->objarray[recsize].bo_hp_reltn_id = dparententityid
     OF "ACTIVITY_LOG":
      SET sstructname->objarray[recsize].activity_id = dparententityid
     OF "PFT_CHARGE":
      SET sstructname->objarray[recsize].pft_charge_id = dparententityid
     OF "CHARGE":
      SET sstructname->objarray[recsize].charge_item_id = dparententityid
     OF "PFT_ARWB_DATA_EXT":
      SET sstructname->objarray[recsize].pft_arwb_data_ext_id = dparententityid
     ELSE
      SET sstructname->objarray[recsize].parent_entity_name = sparententityname
      SET sstructname->objarray[recsize].parent_entity_id = dparententityid
    ENDCASE
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE job_entity_name = vc WITH noconstant("")
 DECLARE job_cd = f8 WITH noconstant(0.0)
 DECLARE requested_cd = f8 WITH noconstant(0.0)
 DECLARE completed_cd = f8 WITH noconstant(0.0)
 DECLARE error_cd = f8 WITH noconstant(0.0)
 DECLARE retry_cd = f8 WITH noconstant(0.0)
 DECLARE clmgenedi_cd = f8 WITH noconstant(0.0)
 DECLARE clmgenpaper_cd = f8 WITH noconstant(0.0)
 DECLARE holdrelease_cd = f8 WITH noconstant(0.0)
 DECLARE state_gen_cd = f8 WITH noconstant(0.0)
 SET iret = uar_get_meaning_by_codeset(23060,nullterm("PFTOPS"),1,job_cd)
 SET iret = uar_get_meaning_by_codeset(23061,nullterm("REQUESTED"),1,requested_cd)
 SET iret = uar_get_meaning_by_codeset(23061,nullterm("COMPLETED"),1,completed_cd)
 SET iret = uar_get_meaning_by_codeset(23061,nullterm("ERROR"),1,error_cd)
 SET iret = uar_get_meaning_by_codeset(23061,nullterm("RETRY"),1,retry_cd)
 SET iret = uar_get_meaning_by_codeset(23370,nullterm("CLMGENEDI"),1,clmgenedi_cd)
 SET iret = uar_get_meaning_by_codeset(23370,nullterm("CLMGENPAPER"),1,clmgenpaper_cd)
 SET iret = uar_get_meaning_by_codeset(23370,nullterm("HOLDRELEASE"),1,holdrelease_cd)
 SET iret = uar_get_meaning_by_codeset(23370,nullterm("STATE GEN"),1,state_gen_cd)
 DECLARE unique_job_tag = vc WITH protect, constant(format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;D")
  )
 DECLARE job_tag_fe_ld = vc WITH protect, noconstant("")
 DECLARE trap_job_ccl_errors = vc WITH noconstant("N")
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE errcode = i4 WITH noconstant(0)
 FREE SET job_error_log_filename
 DECLARE job_error_log_filename = vc WITH noconstant("")
 FREE SET use_standard_commit_logic
 DECLARE use_standard_commit_logic = i2 WITH noconstant(true)
 FREE SET event_fails_on_any_job_error
 DECLARE event_fails_on_any_job_error = i2 WITH noconstant(true)
 CALL seteventerrorflag(false,"")
 DECLARE persist_called = i2
 SET persist_called = false
 DECLARE no_event = i2 WITH constant(98)
 DECLARE logical_domain_not_set = i2 WITH constant(99)
 DECLARE retry_delay_cap = i2 WITH constant(600)
 DECLARE subevent_job_class = vc WITH protect, noconstant("")
 FREE SET event_warning_cnt
 DECLARE event_warning_cnt = i4 WITH noconstant(0)
 FREE SET event_error_cnt
 DECLARE event_error_cnt = i4 WITH noconstant(0)
 DECLARE batchrouteuptd = vc WITH protect, noconstant("")
 FREE RECORD pft_event_req
 RECORD pft_event_req(
   1 devent_id = f8
 )
 FREE RECORD pft_event_rep
 RECORD pft_event_rep(
   1 devent_type_cd = f8
   1 devent_sub_type_cd = f8
   1 lcurrent_occurrence = i4
   1 levent_updt_cnt = i4
   1 devent_occur_log_id = f8
   1 devent_status_cd = f8
   1 devent_reason_cd = f8
   1 loccur_updt_cnt = i4
   1 lparams_qual = i4
   1 aparams[*]
     2 devent_params_id = f8
     2 dvalue_meaning = f8
     2 svalue_meaning = vc
     2 svalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pft_event_rep->status_data.status = "F"
 FREE RECORD event_joblist
 RECORD event_joblist(
   1 job_cnt = i4
   1 parent_entity_name = vc
   1 job_qual[*]
     2 parent_entity_id = f8
     2 returned_status = vc
 )
 SET event_joblist->job_cnt = 0
 FREE RECORD event_subevent_results
 RECORD event_subevent_results(
   1 subevent_cnt = i4
   1 subevent_results[*]
     2 subevent_status_message = vc
     2 subevent_total_jobs = i4
     2 subevent_jobs_completed = i4
     2 subevent_jobs_error = i4
     2 subevent_jobs_requested = i4
 )
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL echo(build2(trim(curprog),
    "::pft_event_subs.inc (Initialization) - Unable to get the logical domain"))
 ENDIF
 DECLARE addeventoccurlog(null) = i2
 SUBROUTINE addeventoccurlog(null)
   DECLARE new_nbr_test = f8 WITH noconstant(0.0)
   CALL quiet("ON")
   SELECT INTO "nl:"
    newseq = seq(pft_ref_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr_test = cnvtreal(newseq)
    WITH format, nocounter
   ;end select
   CALL quiet("OFF")
   IF (((curqual=0) OR (new_nbr_test=0)) )
    CALL echo(build2("curqual=",curqual))
    CALL echo(build2("new_nbr_test=",new_nbr_test))
    CALL echo("gen # failed")
    CALL seteventerrorflag(gen_nbr_error,"pft_ref_seq")
    RETURN(false)
   ELSE
    SET pft_event_rep->devent_occur_log_id = new_nbr_test
    SET pft_event_rep->devent_reason_cd = 0.0
    CALL seteventstatuscodebymeaning("WORKING")
    SET pft_event_rep->loccur_updt_cnt = 0
   ENDIF
   CALL quiet("ON")
   INSERT  FROM pft_event_occur_log po
    SET po.pft_event_occur_log_id = new_nbr_test, po.pft_event_id = pft_event_req->devent_id, po
     .pft_event_status_cd = pft_event_rep->devent_status_cd,
     po.log_file_produced_ind = 0, po.start_dt_tm = cnvtdatetime(sysdate), po.active_ind = 1,
     po.active_status_cd = active_status, po.beg_effective_dt_tm = cnvtdatetime(sysdate), po
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     po.active_status_prsnl_id = reqinfo->updt_id, po.active_status_dt_tm = cnvtdatetime(sysdate), po
     .updt_cnt = 0,
     po.updt_dt_tm = cnvtdatetime(sysdate), po.updt_id = reqinfo->updt_id, po.updt_applctx = reqinfo
     ->updt_applctx,
     po.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL quiet("OFF")
   IF (curqual=0)
    CALL seteventerrorflag(insert_error,"pft_event_occur_log")
    RETURN(false)
   ENDIF
   IF (commitlogicenabled(null))
    COMMIT
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (addeventparamvalue(paramname=vc,paramvalue=vc) =i2)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE cval = f8 WITH noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(24454,nullterm(paramname),1,cval)
   IF (iret != 0)
    CALL echo(build2(curprog,"::AddEventParamValue - Attempted to set unknown parameter [",paramname,
      "]"))
    RETURN(false)
   ENDIF
   SET idx = (pft_event_rep->lparams_qual+ 1)
   SET pft_event_rep->lparams_qual = idx
   SET stat = alterlist(pft_event_rep->aparams,idx)
   SET pft_event_rep->aparams[idx].dvalue_meaning = cval
   SET pft_event_rep->aparams[idx].svalue_meaning = trim(paramname)
   SET pft_event_rep->aparams[idx].svalue = trim(paramvalue)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (addjobtolist(dparententityid=f8,icheckdups=i2) =i2)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   IF (icheckdups)
    SET idx = locateval(num,start,event_joblist->job_cnt,dparententityid,event_joblist->job_qual[num]
     .parent_entity_id)
   ENDIF
   IF (idx > 0)
    RETURN(false)
   ELSE
    SET event_joblist->job_cnt += 1
    SET stat = alterlist(event_joblist->job_qual,event_joblist->job_cnt)
    SET event_joblist->parent_entity_name = job_entity_name
    SET event_joblist->job_qual[event_joblist->job_cnt].parent_entity_id = dparententityid
    IF (mod(event_joblist->job_cnt,100)=0)
     CALL echo(build2(event_joblist->job_cnt," entries added to job list so far..."))
    ENDIF
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (alljobsmustsucceed(iboolean=i2) =i2)
  SET event_fails_on_any_job_error = iboolean
  RETURN(true)
 END ;Subroutine
 DECLARE anyjoberrorfailsevent(null) = i2
 SUBROUTINE anyjoberrorfailsevent(null)
   RETURN(event_fails_on_any_job_error)
 END ;Subroutine
 DECLARE commitlogicenabled(null) = i2
 SUBROUTINE commitlogicenabled(null)
   RETURN(use_standard_commit_logic)
 END ;Subroutine
 DECLARE echoeventparams(null) = i2
 SUBROUTINE echoeventparams(null)
   DECLARE idx = i4
   DECLARE lbal = vc
   IF (eventparamexists("PFTOPS_LBAL"))
    SET lbal = geteventparamasstring("PFTOPS_LBAL")
   ELSE
    SET lbal = "N"
   ENDIF
   CALL echo(fillstring(79,"="))
   IF (scriptexecutingasfinevent(null))
    CALL echo(build2("Parameters for event ",trim(cnvtstring(pft_event_req->devent_id))," - ",trim(
       uar_get_code_description(pft_event_rep->devent_sub_type_cd)),":"))
    CALL echo(build2("(This event ",evaluate(lbal,"Y","supports","N","does not support"),
      " load balancing)"))
   ELSE
    CALL echo("Script is not executing as a fin calendar event")
    CALL echo(build2("(This execution ",evaluate(lbal,"Y","supports","N","does not support"),
      " load balancing)"))
   ENDIF
   CALL echo(fillstring(79,"="))
   FOR (idx = 1 TO pft_event_rep->lparams_qual)
     CALL echo(build2(trim(uar_get_code_description(pft_event_rep->aparams[idx].dvalue_meaning))," [",
       pft_event_rep->aparams[idx].svalue_meaning,"] = ",trim(pft_event_rep->aparams[idx].svalue)))
   ENDFOR
   CALL echo(fillstring(79,"="))
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (enablecommitlogic(ienablecommits=i2) =i2)
  SET use_standard_commit_logic = ienablecommits
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (enableerrortrap(ienableerrortrap=i2) =i2)
  IF (ienableerrortrap)
   SET trap_job_ccl_errors = "Y"
  ELSE
   SET trap_job_ccl_errors = "N"
  ENDIF
  RETURN(true)
 END ;Subroutine
 DECLARE endeventoccur(null) = i2
 SUBROUTINE endeventoccur(null)
   DECLARE ix = i4 WITH private, noconstant(0)
   IF (scriptexecutingasfinevent(null))
    DECLARE lcount = i4
    IF ((pft_event_rep->devent_status_cd=null))
     CALL seteventstatuscode(0.0)
    ENDIF
    IF ((pft_event_rep->devent_reason_cd=null))
     CALL seteventstatusreasoncode(0.0)
    ENDIF
    CALL quiet("ON")
    SELECT INTO "nl:"
     FROM pft_event_occur_log peo
     WHERE (peo.pft_event_occur_log_id=pft_event_rep->devent_occur_log_id)
      AND peo.active_ind=1
     DETAIL
      IF (peo.pft_event_occur_log_id > 0)
       lcount += 1
      ENDIF
     WITH forupdate(peo), nocounter
    ;end select
    CALL quiet("OFF")
    IF (lcount=1)
     CALL updateeventoccurlogend(null)
     IF (failed != false)
      CALL seteventstatuscodebymeaning("FAILED")
      RETURN(false)
     ENDIF
    ELSE
     CALL seteventerrorflag(lock_error,"pft_event_occur_log")
     CALL seteventstatuscodebymeaning("FAILED")
     RETURN(false)
    ENDIF
   ENDIF
   CALL echorecord(reply)
   CALL echo(fillstring(79,"="))
   FOR (ix = 1 TO event_subevent_results->subevent_cnt)
     CALL echo(event_subevent_results->subevent_results[ix].subevent_status_message)
   ENDFOR
   CALL echo(fillstring(79,"="))
   IF (failed=false)
    SET pft_event_rep->status_data.status = "S"
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventcounterbytype(scounttype=vc) =i4)
   CASE (scounttype)
    OF "ERROR":
     RETURN(event_error_cnt)
    OF "WARNING":
     RETURN(event_warning_cnt)
    ELSE
     RETURN(0)
   ENDCASE
 END ;Subroutine
 DECLARE geteventjobcount(null) = i4
 SUBROUTINE geteventjobcount(null)
   RETURN(event_joblist->job_cnt)
 END ;Subroutine
 DECLARE geteventoccurparams(null) = i2
 SUBROUTINE geteventoccurparams(null)
   SET pft_event_rep->lparams_qual = 0
   CALL quiet("ON")
   SELECT INTO "nl:"
    parm_meaning = trim(uar_get_code_meaning(p.value_specifier_cd))
    FROM pft_event_params p,
     long_text lt
    PLAN (p
     WHERE (p.pft_event_occur_log_id=pft_event_rep->devent_occur_log_id)
      AND p.active_ind=1)
     JOIN (lt
     WHERE (lt.parent_entity_id= Outerjoin(p.pft_event_params_id))
      AND (lt.parent_entity_name= Outerjoin("PFTEVENTPARAMS"))
      AND (lt.active_ind= Outerjoin(1)) )
    DETAIL
     IF (textlen(parm_meaning) > 0)
      pft_event_rep->lparams_qual += 1
      IF ((pft_event_rep->lparams_qual > size(pft_event_rep->aparams,5)))
       stat = alterlist(pft_event_rep->aparams,pft_event_rep->lparams_qual)
      ENDIF
      pft_event_rep->aparams[pft_event_rep->lparams_qual].devent_params_id = p.pft_event_params_id,
      pft_event_rep->aparams[pft_event_rep->lparams_qual].dvalue_meaning = p.value_specifier_cd,
      pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue_meaning = parm_meaning
      IF (p.params_value_long_text_id > 0.0)
       pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue = lt.long_text
      ELSE
       IF (parm_meaning="BATCHROUTE"
        AND validate(isbatchforunbilledar,false)=true)
        batchrouteuptd = p.value, pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue = concat
        (batchrouteuptd,"_UNBILLEDAR"), batchrouteuptd = ""
       ELSE
        pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue = p.value
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL quiet("OFF")
   IF ((pft_event_rep->lparams_qual=0))
    CALL quiet("ON")
    SELECT INTO "nl:"
     parm_meaning = trim(uar_get_code_meaning(p.value_specifier_cd))
     FROM pft_event_params p,
      long_text lt
     PLAN (p
      WHERE (p.pft_event_id=pft_event_req->devent_id)
       AND p.pft_event_occur_log_id IN (0, null)
       AND p.active_ind=1)
      JOIN (lt
      WHERE (lt.parent_entity_id= Outerjoin(p.pft_event_params_id))
       AND (lt.parent_entity_name= Outerjoin("PFTEVENTPARAMS"))
       AND (lt.active_ind= Outerjoin(1)) )
     DETAIL
      IF (textlen(parm_meaning) > 0)
       pft_event_rep->lparams_qual += 1
       IF ((pft_event_rep->lparams_qual > size(pft_event_rep->aparams,5)))
        stat = alterlist(pft_event_rep->aparams,pft_event_rep->lparams_qual)
       ENDIF
       pft_event_rep->aparams[pft_event_rep->lparams_qual].devent_params_id = p.pft_event_params_id,
       pft_event_rep->aparams[pft_event_rep->lparams_qual].dvalue_meaning = p.value_specifier_cd,
       pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue_meaning = parm_meaning
       IF (p.params_value_long_text_id > 0.0)
        pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue = lt.long_text
       ELSE
        IF (parm_meaning="BATCHROUTE"
         AND validate(isbatchforunbilledar,false)=true)
         batchrouteuptd = p.value, pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue =
         concat(batchrouteuptd,"_UNBILLEDAR"), batchrouteuptd = ""
        ELSE
         pft_event_rep->aparams[pft_event_rep->lparams_qual].svalue = p.value
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    CALL quiet("OFF")
   ENDIF
   CALL setloadbalancingparams(null)
   RETURN(true)
 END ;Subroutine
 DECLARE geteventstatuscode(null) = f8
 SUBROUTINE geteventstatuscode(null)
   RETURN(pft_event_rep->devent_status_cd)
 END ;Subroutine
 DECLARE geteventstatusreasoncode(null) = f8
 SUBROUTINE geteventstatusreasoncode(null)
   RETURN(pft_event_rep->devent_reason_cd)
 END ;Subroutine
 DECLARE getfinaleventstatus(null) = i2
 SUBROUTINE getfinaleventstatus(null)
   IF (all_jobs_processed)
    IF (anyjoberrorfailsevent(null)
     AND geteventcounterbytype("ERROR") > 0)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (handleeventerror(failed=i2) =i2)
   CASE (failed)
    OF attribute_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
    OF delete_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "DELETE"
    OF execute_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "EXECUTE"
    OF gen_nbr_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "GEN_NBR"
    OF insert_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "INSERT"
    OF lock_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "LOCK"
    OF no_event:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "NO_EVENT"
    OF remove_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "REMOVE"
    OF replace_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "REPLACE"
    OF undelete_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "UNDELETE"
    OF update_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "UPDATE"
    OF update_cnt_error:
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "UPT_CNT"
    ELSE
     SET pft_event_rep->status_data.subeventstatus[1].operationname = "UNKNOWN"
   ENDCASE
   CALL echo(build2(trim(curprog),"::HandleEventError - ",trim(pft_event_rep->status_data.
      subeventstatus[1].operationname)," error occurred (",trim(cnvtstring(failed)),
     ")"))
   SET pft_event_rep->status_data.subeventstatus[1].operationstatus = "F"
   SET pft_event_rep->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET pft_event_rep->status_data.subeventstatus[1].targetobjectvalue = table_name
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (incrementeventcounterbytype(scounttype=vc) =i2)
   CASE (scounttype)
    OF "ERROR":
     SET event_error_cnt += 1
     RETURN(true)
    OF "WARNING":
     SET event_warning_cnt += 1
     RETURN(true)
    ELSE
     RETURN(false)
   ENDCASE
 END ;Subroutine
 DECLARE loadbalancingenabled(null) = i2
 SUBROUTINE loadbalancingenabled(null)
   IF (eventparamexists("PFTOPS_LBAL"))
    IF (geteventparamasstring("PFTOPS_LBAL")="Y")
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (logsubeventcompletion(smessage=vc) =i2)
   SET event_subevent_results->subevent_cnt += 1
   SET stat = alterlist(event_subevent_results->subevent_results,event_subevent_results->subevent_cnt
    )
   SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
   subevent_status_message = build2(curprog,"/",cnvtupper(trim(geteventparamasstring("PFTOPS_SCR"))),
    " [Subevent ",trim(cnvtstring(event_subevent_results->subevent_cnt)),
    "]: ",smessage)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (persistjoblist(prschjoblockrowid=f8(ref)) =i2)
   DECLARE subtime = f8 WITH protect, noconstant(0.0)
   CALL echotimingmsg("Entering PersistJobList ...",subtime)
   IF (persist_called)
    CALL echotimingmsg("Exiting PersistJobList ...",subtime)
    RETURN(true)
   ENDIF
   SET persist_called = true
   IF ( NOT (loadbalancingenabled(null)))
    CALL echo(fillstring(79,"="))
    CALL echo("Load balancing is disabled: All jobs will be processed internally")
    CALL echo(build2("Job count:",event_joblist->job_cnt))
    CALL echo(fillstring(79,"="))
    CALL echotimingmsg("Exiting PersistJobList ...",subtime)
    RETURN(true)
   ENDIF
   DECLARE unique_job_class = vc WITH protect, noconstant("")
   SET unique_job_class = build(geteventparamasstring("PFTOPS_SCR"),"|",unique_job_tag,job_tag_fe_ld,
    "|",
    geteventparamasstring("PFTOPS_BLK"),trap_job_ccl_errors)
   CALL echo(build2("Unique job class for this event: ",unique_job_class))
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE k = i4 WITH noconstant(0), private
   DECLARE req_dt_tm = q8 WITH noconstant(0.0), private
   DECLARE beg_dt_tm = q8 WITH noconstant(0.0), private
   DECLARE end_dt_tm = q8 WITH noconstant(0.0), private
   DECLARE slice = i4 WITH noconstant(1000), private
   DECLARE iterations = i4 WITH noconstant(0), private
   DECLARE start = i4 WITH noconstant(0), private
   DECLARE stop = i4 WITH noconstant(0), private
   SET req_dt_tm = cnvtdatetime(sysdate)
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,235959)
   SET iterations = (event_joblist->job_cnt/ slice)
   IF (mod(event_joblist->job_cnt,slice) != 0)
    SET iterations += 1
   ENDIF
   CALL echo(fillstring(79,"="))
   CALL echo("Creating the job list in the sch_job table:")
   CALL echo(build2("Job count:",event_joblist->job_cnt))
   CALL echo(build2("Maximum number added between commits:",slice))
   CALL echo(build2("Number of iterations required:",iterations))
   CALL echo(fillstring(79,"="))
   FOR (i = 1 TO iterations)
     FREE RECORD chgw_job_request
     RECORD chgw_job_request(
       1 call_echo_ind = i2
       1 allow_partial_ind = i2
       1 duplicate_check_ind = i2
       1 qual_cnt = i4
       1 qual[*]
         2 sch_job_id = f8
         2 job_type_cd = f8
         2 parent_entity_name = c32
         2 parent_entity_id = f8
         2 key_entity_name = c32
         2 key_entity_id = f8
         2 job_state_cd = f8
         2 job_status_cd = f8
         2 display = vc
         2 job_key = vc
         2 job_class = vc
         2 sch_conversation_id = f8
         2 active_ind = i2
         2 active_status_cd = f8
         2 request_dt_tm = dq8
         2 last_dt_tm = dq8
         2 complete_dt_tm = dq8
         2 lock_dt_tm = dq8
         2 attempt_cnt = i4
         2 updt_cnt = i4
         2 action = i2
         2 force_updt_ind = i2
         2 version_ind = i2
         2 detail_partial_ind = i2
         2 detail_qual_cnt = i4
         2 detail_qual[*]
           3 oe_field_id = f8
           3 seq_nbr = i4
           3 version_dt_tm = dq8
           3 oe_field_display_value = vc
           3 oe_field_dt_tm_value = dq8
           3 oe_field_meaning = c25
           3 oe_field_value = f8
           3 oe_field_meaning_id = f8
           3 candidate_id = f8
           3 active_ind = i2
           3 active_status_cd = f8
           3 updt_cnt = i4
           3 label_text = vc
           3 action = i2
           3 force_updt_ind = i2
           3 version_ind = i2
         2 action_partial_ind = i2
         2 action_qual[*]
           3 sch_action_id = f8
           3 version_dt_tm = dq8
           3 sch_action_cd = f8
           3 action_meaning = c12
           3 action_prsnl_id = f8
           3 action_dt_tm = dq8
           3 perform_dt_tm = dq8
           3 candidate_id = f8
           3 active_ind = i2
           3 active_status_cd = f8
           3 updt_cnt = i4
           3 reason_meaning = c12
           3 sch_reason_cd = f8
           3 action = i2
           3 force_updt_ind = i2
           3 version_ind = i2
           3 comment_partial_ind = i2
           3 comment_qual[*]
             4 text_type_cd = f8
             4 sub_text_cd = f8
             4 text_id = f8
             4 text_type_meaning = c12
             4 sub_text_meaning = c12
             4 candidate_id = f8
             4 active_ind = i2
             4 active_status_cd = f8
             4 updt_cnt = i4
             4 action = i2
             4 force_updt_ind = i2
             4 version_ind = i2
             4 text_partial_ind = i2
             4 text_updt_cnt = i4
             4 text_active_ind = i2
             4 text_active_status_cd = f8
             4 long_text = vc
             4 text_action = i2
             4 text_force_updt_ind = i2
             4 text_version_ind = i2
     )
     FREE RECORD chgw_job_reply
     RECORD chgw_job_reply(
       1 qual_cnt = i4
       1 qual[*]
         2 sch_job_id = f8
         2 status = i2
         2 detail_qual_cnt = i4
         2 detail_qual[*]
           3 candidate_id = f8
           3 status = i2
         2 action_qual_cnt = i4
         2 action_qual[*]
           3 sch_action_id = f8
           3 candidate_id = f8
           3 status = i2
           3 comment_qual_cnt = i4
           3 comment_qual[*]
             4 candidate_id = f8
             4 status = i2
             4 text_status = i2
             4 text_id = f8
     )
     SET start = (((i - 1) * slice)+ 1)
     SET stop = minval(((start+ slice) - 1),event_joblist->job_cnt)
     CALL echo(build2("Processing Iteration ",trim(cnvtstring(i))," (Jobs ",trim(cnvtstring(start)),
       " to ",
       trim(cnvtstring(stop)),")"))
     SET chgw_job_reply->qual_cnt = ((stop - start)+ 1)
     SET stat = alterlist(chgw_job_request->qual,0)
     SET stat = alterlist(chgw_job_request->qual,chgw_job_reply->qual_cnt)
     SET chgw_job_request->duplicate_check_ind = 0
     SET k = 0
     FOR (j = start TO stop)
       SET k += 1
       SET chgw_job_request->qual[k].job_type_cd = job_cd
       SET chgw_job_request->qual[k].parent_entity_name = event_joblist->parent_entity_name
       SET chgw_job_request->qual[k].parent_entity_id = event_joblist->job_qual[j].parent_entity_id
       SET chgw_job_request->qual[k].job_key = build(format(curdate,"dd/mmm/yyyy;;d"),"^",curprog,"^",
        event_joblist->job_qual[j].parent_entity_id)
       SET chgw_job_request->qual[k].job_state_cd = requested_cd
       SET chgw_job_request->qual[k].display = concat(format(beg_dt_tm,"dd/mmm/yyyy;;d")," - ",format
        (end_dt_tm,"dd/mmm/yyyy;;d"))
       SET chgw_job_request->qual[k].job_class = unique_job_class
       SET chgw_job_request->qual[k].action = action_add
       SET chgw_job_request->qual[k].request_dt_tm = req_dt_tm
       SET chgw_job_request->qual[k].active_ind = 1
     ENDFOR
     EXECUTE pft_chgw_job
     IF ((reply->status_data.status="F"))
      CALL echo("*_*_* PersistJobList->pft_chgw_job ROLLBACK *_*_*")
      ROLLBACK
      CALL seteventparamvalue("PFTOPS_LBAL","N")
      CALL echotimingmsg("Exiting PersistJobList ...",subtime)
      RETURN(false)
     ENDIF
     COMMIT
     SET reply->status_data.status = "F"
   ENDFOR
   IF ((validate(prschjoblockrowid,- (999)) != - (999))
    AND iterations > 0)
    FREE RECORD chgw_job_request
    RECORD chgw_job_request(
      1 call_echo_ind = i2
      1 allow_partial_ind = i2
      1 duplicate_check_ind = i2
      1 qual_cnt = i4
      1 qual[*]
        2 sch_job_id = f8
        2 job_type_cd = f8
        2 parent_entity_name = c32
        2 parent_entity_id = f8
        2 key_entity_name = c32
        2 key_entity_id = f8
        2 job_state_cd = f8
        2 job_status_cd = f8
        2 display = vc
        2 job_key = vc
        2 job_class = vc
        2 sch_conversation_id = f8
        2 active_ind = i2
        2 active_status_cd = f8
        2 request_dt_tm = dq8
        2 last_dt_tm = dq8
        2 complete_dt_tm = dq8
        2 lock_dt_tm = dq8
        2 attempt_cnt = i4
        2 updt_cnt = i4
        2 action = i2
        2 force_updt_ind = i2
        2 version_ind = i2
        2 detail_partial_ind = i2
        2 detail_qual_cnt = i4
        2 detail_qual[*]
          3 oe_field_id = f8
          3 seq_nbr = i4
          3 version_dt_tm = dq8
          3 oe_field_display_value = vc
          3 oe_field_dt_tm_value = dq8
          3 oe_field_meaning = c25
          3 oe_field_value = f8
          3 oe_field_meaning_id = f8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 updt_cnt = i4
          3 label_text = vc
          3 action = i2
          3 force_updt_ind = i2
          3 version_ind = i2
        2 action_partial_ind = i2
        2 action_qual[*]
          3 sch_action_id = f8
          3 version_dt_tm = dq8
          3 sch_action_cd = f8
          3 action_meaning = c12
          3 action_prsnl_id = f8
          3 action_dt_tm = dq8
          3 perform_dt_tm = dq8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 updt_cnt = i4
          3 reason_meaning = c12
          3 sch_reason_cd = f8
          3 action = i2
          3 force_updt_ind = i2
          3 version_ind = i2
          3 comment_partial_ind = i2
          3 comment_qual[*]
            4 text_type_cd = f8
            4 sub_text_cd = f8
            4 text_id = f8
            4 text_type_meaning = c12
            4 sub_text_meaning = c12
            4 candidate_id = f8
            4 active_ind = i2
            4 active_status_cd = f8
            4 updt_cnt = i4
            4 action = i2
            4 force_updt_ind = i2
            4 version_ind = i2
            4 text_partial_ind = i2
            4 text_updt_cnt = i4
            4 text_active_ind = i2
            4 text_active_status_cd = f8
            4 long_text = vc
            4 text_action = i2
            4 text_force_updt_ind = i2
            4 text_version_ind = i2
    )
    FREE RECORD chgw_job_reply
    RECORD chgw_job_reply(
      1 qual_cnt = i4
      1 qual[*]
        2 sch_job_id = f8
        2 status = i2
        2 detail_qual_cnt = i4
        2 detail_qual[*]
          3 candidate_id = f8
          3 status = i2
        2 action_qual_cnt = i4
        2 action_qual[*]
          3 sch_action_id = f8
          3 candidate_id = f8
          3 status = i2
          3 comment_qual_cnt = i4
          3 comment_qual[*]
            4 candidate_id = f8
            4 status = i2
            4 text_status = i2
            4 text_id = f8
    )
    SET stat = alterlist(chgw_job_request->qual,1)
    SET chgw_job_request->qual[1].job_type_cd = job_cd
    SET chgw_job_request->qual[1].parent_entity_name = event_joblist->parent_entity_name
    SET chgw_job_request->qual[1].parent_entity_id = event_joblist->job_qual[(j - 1)].
    parent_entity_id
    SET chgw_job_request->qual[1].job_key = build(format(curdate,"dd/mmm/yyyy;;d"),"^",curprog,"^",
     event_joblist->job_qual[(j - 1)].parent_entity_id)
    SET chgw_job_request->qual[1].job_state_cd = requested_cd
    SET chgw_job_request->qual[1].display = concat(format(beg_dt_tm,"dd/mmm/yyyy;;d")," - ",format(
      end_dt_tm,"dd/mmm/yyyy;;d"))
    SET chgw_job_request->qual[1].job_class = unique_job_class
    SET chgw_job_request->qual[1].action = action_add
    SET chgw_job_request->qual[1].request_dt_tm = req_dt_tm
    SET chgw_job_request->qual[1].active_ind = 0
    EXECUTE pft_chgw_job
    IF ((reply->status_data.status="F"))
     CALL echo("*_*_* PersistJobList->pft_chgw_job ROLLBACK *_*_*")
     ROLLBACK
     CALL seteventparamvalue("PFTOPS_LBAL","N")
     CALL echotimingmsg("Exiting PersistJobList ...",subtime)
     RETURN(false)
    ENDIF
    COMMIT
    SET reply->status_data.status = "F"
    SET prschjoblockrowid = chgw_job_request->qual[1].sch_job_id
   ENDIF
   FREE RECORD chgw_job_request
   FREE RECORD chgw_job_reply
   CALL echotimingmsg("Exiting PersistJobList ...",subtime)
   RETURN(true)
 END ;Subroutine
 DECLARE processjoblist(null) = i2
 SUBROUTINE processjoblist(null)
   DECLARE subtime = f8 WITH protect, noconstant(0.0)
   DECLARE schjoblockrowid = f8 WITH protect, noconstant(0.0)
   CALL echotimingmsg("Entering ProcessJobList ...",subtime)
   IF (validate(dbsr_verbose_mode,- (1)) < 0)
    DECLARE dbsr_verbose_mode = i2 WITH noconstant(false)
   ENDIF
   SET event_error_cnt = 0
   SET event_warning_cnt = 0
   IF (eventparamexists("PFTOPS_FAIL"))
    IF (geteventparamasstring("PFTOPS_FAIL")="N")
     CALL alljobsmustsucceed(false)
    ELSE
     CALL alljobsmustsucceed(true)
    ENDIF
   ELSE
    CALL alljobsmustsucceed(true)
   ENDIF
   IF (loadbalancingenabled(null))
    CALL setloadbalancingparams(null)
   ENDIF
   CALL echoeventparams(null)
   IF ( NOT (persist_called))
    CALL persistjoblist(schjoblockrowid)
   ENDIF
   DECLARE jobhandler = vc WITH protect, noconstant("")
   SET jobhandler = geteventparamasstring("PFTOPS_SCR")
   DECLARE idx = i4 WITH privateprotect, noconstant(0)
   DECLARE bestidx = i4 WITH protect, noconstant(1)
   DECLARE worstidx = i4 WITH protect, noconstant(1)
   DECLARE executiontime = f8 WITH protect, noconstant(0.0)
   DECLARE bestexecutiontime = f8 WITH protect, noconstant(0.0)
   DECLARE worstexecutiontime = f8 WITH protect, noconstant(0.0)
   DECLARE averagetime = f8 WITH protect, noconstant(0.0)
   DECLARE retrydelayseconds = i2 WITH protect, noconstant(0)
   DECLARE retryjobcnt = i4 WITH protect, noconstant(0)
   FREE RECORD event_job_reply
   RECORD event_job_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
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
   )
   DECLARE all_jobs_processed = i2 WITH protect, noconstant(0)
   DECLARE default_sleep = i4 WITH protect, constant(15)
   DECLARE sleep_seconds = i4 WITH protect, noconstant(0)
   DECLARE elapsed_seconds = i4 WITH protect, noconstant(0)
   DECLARE job_average_secs = f8 WITH protect, noconstant(0.0)
   DECLARE max_retries = i4 WITH protect, noconstant(0)
   DECLARE last_job_count = i4 WITH protect, noconstant(0)
   DECLARE this_job_count = i4 WITH protect, noconstant(0)
   DECLARE no_change_count = i4 WITH protect, noconstant(0)
   DECLARE job_class = vc WITH protect, noconstant("")
   DECLARE end_jobs_requested = i4 WITH protect, noconstant(0)
   DECLARE end_jobs_completed = i4 WITH protect, noconstant(0)
   DECLARE end_jobs_error = i4 WITH protect, noconstant(0)
   DECLARE end_jobs_retry = i4 WITH protect, noconstant(0)
   DECLARE end_total_jobs = i4 WITH protect, noconstant(0)
   FREE RECORD pft_call_ops_request
   RECORD pft_call_ops_request(
     1 batch_selection = vc
     1 output_dist = vc
     1 ops_date = dq8
   )
   FREE RECORD pft_call_ops_reply
   RECORD pft_call_ops_reply(
     1 ops_event = c100
     1 status = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF ((event_joblist->job_cnt=0))
    SET event_subevent_results->subevent_cnt += 1
    SET stat = alterlist(event_subevent_results->subevent_results,event_subevent_results->
     subevent_cnt)
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_total_jobs = 0
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_completed = 0
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_error = 0
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_requested = 0
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_status_message = build2(curprog,"/",cnvtupper(trim(geteventparamasstring("PFTOPS_SCR"))),
     " [Subevent ",trim(cnvtstring(event_subevent_results->subevent_cnt)),
     "]: Submitted ",trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job; "," jobs; "),
     trim(cnvtstring(end_jobs_completed))," successful, ",
     trim(cnvtstring(end_jobs_error))," with errors, ",trim(cnvtstring(end_jobs_requested)),
     " unprocessed.")
    CALL echo(fillstring(79,"="))
    CALL echo(build2("No jobs to process for subevent ",trim(cnvtstring(event_subevent_results->
        subevent_cnt))))
    CALL echo(fillstring(79,"="))
    CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
    RETURN(true)
   ENDIF
   IF ( NOT (loadbalancingenabled(null)))
    SET job_error_log_filename = build2("job_",unique_job_tag,job_tag_fe_ld,"_errors")
    FREE RECORD pft_call_ops_request
    FREE RECORD pft_call_ops_reply
    FOR (idx = 1 TO event_joblist->job_cnt)
      SET stat = initrec(event_job_reply)
      IF (validate(debug,0)=1)
       CALL echo(fillstring(79,"="))
       CALL echo(build2("Beginning processing of job request ",trim(cnvtstring(idx))," of ",trim(
          cnvtstring(event_joblist->job_cnt))," [",
         trim(job_entity_name)," id ",format(event_joblist->job_qual[idx].parent_entity_id,
          "#####################.##########];L")))
       CALL echo(fillstring(79,"="))
      ENDIF
      FREE RECORD ppsj_request
      RECORD ppsj_request(
        1 sjobhandler = vc
        1 sparententityname = vc
        1 dparententityid = f8
      )
      SET ppsj_request->sjobhandler = cnvtupper(trim(jobhandler))
      SET ppsj_request->sparententityname = job_entity_name
      SET ppsj_request->dparententityid = event_joblist->job_qual[idx].parent_entity_id
      SET executiontime = abs((curtime3/ 100.0))
      SET errcode = error(errmsg,1)
      SET trace = errorclear
      EXECUTE pft_process_single_job  WITH replace("REQUEST",ppsj_request), replace("REPLY",
       event_job_reply)
      SET errcode = error(errmsg,0)
      IF (errcode != 0)
       CALL echo(fillstring(79,"="))
       CALL echo(build2("The following CCL errors occurred while processing ID ",event_joblist->
         job_qual[idx].parent_entity_id,":"))
       CALL echo(fillstring(79,"="))
       IF (trap_job_ccl_errors="Y")
        SET event_job_reply->status_data.status = "F"
       ENDIF
      ENDIF
      WHILE (errcode != 0)
        CALL echo(build("errCode=",errcode))
        CALL echo(build("errMsg=",trim(errmsg)))
        CALL echo("----------")
        SET errcode = error(errmsg,0)
      ENDWHILE
      SET event_joblist->job_qual[idx].returned_status = event_job_reply->status_data.status
      IF ((event_job_reply->status_data.status != "S"))
       IF (commitlogicenabled(null))
        CALL echo("*_*_* ProcessJobList ROLLBACK *_*_*")
        ROLLBACK
       ENDIF
       CALL echo(build2(" Status :",event_job_reply->status_data.status))
       IF ((event_job_reply->status_data.status="Z"))
        SET event_joblist->job_qual[idx].returned_status = "S"
        CALL echo("*_*_* ProcessJobList SET SUCCESS *_*_*")
       ELSE
        CALL incrementeventcounterbytype("ERROR")
       ENDIF
      ELSE
       IF (commitlogicenabled(null))
        COMMIT
        CALL echo("*_*_* ProcessJobList COMMIT *_*_*")
       ENDIF
      ENDIF
      SET executiontime = (abs((curtime3/ 100.0)) - executiontime)
      IF (bestexecutiontime > executiontime)
       SET bestidx = idx
       SET bestexecutiontime = executiontime
      ENDIF
      IF (worstexecutiontime < executiontime)
       SET worstidx = idx
       SET worstexecutiontime = executiontime
      ENDIF
      SET averagetime += executiontime
    ENDFOR
    SET averagetime /= event_joblist->job_cnt
    CALL echo(fillstring(79,"="))
    CALL echo("Finished processing all jobs for this event (internally)")
    CALL echo(fillstring(79,"="))
    CALL echo(build2("Average Time: ",format(averagetime,"###.######")))
    CALL echo(build2("Best Time:    ",format(bestexecutiontime,"###.######")," scored by ",cnvtlower(
       event_joblist->parent_entity_name)," ",
      event_joblist->job_qual[bestidx].parent_entity_id))
    CALL echo(build2("Worst Time:   ",format(worstexecutiontime,"###.######")," scored by ",cnvtlower
      (event_joblist->parent_entity_name)," ",
      event_joblist->job_qual[worstidx].parent_entity_id))
    CALL echo(fillstring(79,"="))
    SET end_total_jobs = event_joblist->job_cnt
    SET end_jobs_error = geteventcounterbytype("ERROR")
    SET end_jobs_completed = (end_total_jobs - end_jobs_error)
    SET end_jobs_requested = 0
    SET all_jobs_processed = true
    CALL echo("####################################")
    CALL echo("####################################")
    CALL echo(build2(" SUB RETURN :",getfinaleventstatus(null)))
    CALL echo("####################################")
    CALL echo("####################################")
    CALL setreply(evaluate(getfinaleventstatus(null),true,"S",false,"F"),curprog,build2("Submitted ",
      trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job; "," jobs; "),trim(cnvtstring(
        end_jobs_completed))," successful, ",
      trim(cnvtstring(end_jobs_error))," with errors, ",trim(cnvtstring(end_jobs_requested)),
      " unprocessed."))
    SET event_subevent_results->subevent_cnt += 1
    SET stat = alterlist(event_subevent_results->subevent_results,event_subevent_results->
     subevent_cnt)
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_total_jobs = end_total_jobs
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_completed = end_jobs_completed
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_error = end_jobs_error
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_requested = end_jobs_requested
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_status_message = build2(curprog,"/",cnvtupper(trim(geteventparamasstring("PFTOPS_SCR"))),
     " [Subevent ",trim(cnvtstring(event_subevent_results->subevent_cnt)),
     "]: Submitted ",trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job; "," jobs; "),
     trim(cnvtstring(end_jobs_completed))," successful, ",
     trim(cnvtstring(end_jobs_error))," with errors, ",trim(cnvtstring(end_jobs_requested)),
     " unprocessed.")
    CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
    RETURN(getfinaleventstatus(null))
   ELSE
    SET job_error_log_filename = build2("job_",unique_job_tag,job_tag_fe_ld,"_errors")
    SET pft_call_ops_request->batch_selection = build2("PFT_OPS_JOB_THREAD_START","[CLS=",build(
      geteventparamasstring("PFTOPS_SCR"),"|",unique_job_tag,job_tag_fe_ld,"|",
      geteventparamasstring("PFTOPS_BLK"),trap_job_ccl_errors),",TYPE=PFTOPS",",THR=",
     geteventparamasstring("PFTOPS_THR"),",SLC=",geteventparamasstring("PFTOPS_SLC"),",ITR=",
     geteventparamasstring("PFTOPS_ITR"),
     ",SUB=",geteventparamasstring("PFTOPS_SUB"),",KILL=",geteventparamasstring("PFTOPS_KILL"),
     ",LOCK=",
     geteventparamasstring("PFTOPS_LOCK"),build(",LOCK_ROW=",schjoblockrowid),"]")
    SET pft_call_ops_request->ops_date = cnvtdatetime(sysdate)
    CALL echo(fillstring(79,"="))
    CALL echo("Calling pft_call_ops with the following batch_selection string")
    CALL echo(pft_call_ops_request->batch_selection)
    CALL echo(fillstring(79,"="))
    EXECUTE pft_call_ops  WITH replace("REQUEST",pft_call_ops_request), replace("REPLY",
     pft_call_ops_reply)
    IF ((pft_call_ops_reply->status_data.status != "S"))
     CALL setreply("F",curprog,"An error occurred while attempting to start threaded processing")
     CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
     RETURN(false)
    ENDIF
    IF ( NOT (geteventparamasstring("PFTOPS_BLK")="Y"))
     CALL setreply("S",curprog,build2(trim(cnvtstring(event_joblist->job_cnt)),evaluate(event_joblist
        ->job_cnt,1," job "," jobs "),"submitted for threaded processing"))
     CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
     RETURN(true)
    ENDIF
    CALL echo("Monitoring status of job requests")
    SET sleep_seconds = default_sleep
    SET elapsed_seconds = 0
    SET max_retries = ((geteventparamasinteger("PFTOPS_LOCK") * 60)/ sleep_seconds)
    SET this_job_count = event_joblist->job_cnt
    CALL echo(build2("Number of job requests=",trim(cnvtstring(this_job_count))))
    SET job_class = build(geteventparamasstring("PFTOPS_SCR"),"|",unique_job_tag,job_tag_fe_ld,"|",
     geteventparamasstring("PFTOPS_BLK"),trap_job_ccl_errors)
    SET all_jobs_processed = false
    CALL quiet("ON")
    SELECT INTO "nl:"
     acount = count(*)
     FROM sch_job sj
     WHERE sj.job_type_cd=job_cd
      AND sj.job_class=job_class
      AND sj.job_state_cd IN (requested_cd, retry_cd)
      AND sj.active_ind=true
     GROUP BY sj.job_type_cd, sj.job_class, sj.job_state_cd
     FOOT REPORT
      this_job_count = acount
     WITH nocounter
    ;end select
    CALL quiet("OFF")
    IF (curqual=0)
     SET this_job_count = 0
     SET all_jobs_processed = true
     CALL echo("No jobs remain to process ...")
    ELSE
     CALL echo(build2(trim(cnvtstring(this_job_count)),evaluate(this_job_count,1," job "," jobs "),
       "remaining to process - will check again in ",trim(cnvtstring(sleep_seconds)),evaluate(
        sleep_seconds,1," second ..."," seconds ...")))
    ENDIF
    WHILE (this_job_count > 0)
      CALL sleepseconds(sleep_seconds)
      SET elapsed_seconds += sleep_seconds
      CALL quiet("ON")
      SELECT INTO "nl:"
       acount = count(*)
       FROM sch_job sj
       WHERE sj.job_type_cd=job_cd
        AND sj.job_class=job_class
        AND sj.job_state_cd=requested_cd
        AND sj.active_ind=true
       GROUP BY sj.job_type_cd, sj.job_class, sj.job_state_cd
       FOOT REPORT
        this_job_count = acount
       WITH nocounter
      ;end select
      CALL quiet("OFF")
      IF (curqual=0)
       SET this_job_count = 0
      ENDIF
      IF ((((cnvtreal((event_joblist->job_cnt - this_job_count))/ cnvtreal(elapsed_seconds)) *
      sleep_seconds) > this_job_count))
       SET max_retries *= sleep_seconds
       SET sleep_seconds = 1
      ENDIF
      IF (this_job_count > 0)
       CALL echo(build2(trim(cnvtstring(this_job_count)),evaluate(this_job_count,1," job "," jobs "),
         "remaining to process - will check again in ",trim(cnvtstring(sleep_seconds)),evaluate(
          sleep_seconds,1," second ..."," seconds ...")))
      ENDIF
      IF (this_job_count=last_job_count)
       SET no_change_count += 1
      ELSE
       SET no_change_count = 0
      ENDIF
      SET last_job_count = this_job_count
      IF (this_job_count=0)
       FREE RECORD chgw_job_request
       RECORD chgw_job_request(
         1 call_echo_ind = i2
         1 allow_partial_ind = i2
         1 duplicate_check_ind = i2
         1 qual_cnt = i4
         1 qual[*]
           2 sch_job_id = f8
           2 job_type_cd = f8
           2 parent_entity_name = c32
           2 parent_entity_id = f8
           2 key_entity_name = c32
           2 key_entity_id = f8
           2 job_state_cd = f8
           2 job_status_cd = f8
           2 display = vc
           2 job_key = vc
           2 job_class = vc
           2 sch_conversation_id = f8
           2 active_ind = i2
           2 active_status_cd = f8
           2 request_dt_tm = dq8
           2 last_dt_tm = dq8
           2 complete_dt_tm = dq8
           2 lock_dt_tm = dq8
           2 attempt_cnt = i4
           2 updt_cnt = i4
           2 action = i2
           2 force_updt_ind = i2
           2 version_ind = i2
           2 detail_partial_ind = i2
           2 detail_qual_cnt = i4
           2 detail_qual[*]
             3 oe_field_id = f8
             3 seq_nbr = i4
             3 version_dt_tm = dq8
             3 oe_field_display_value = vc
             3 oe_field_dt_tm_value = dq8
             3 oe_field_meaning = c25
             3 oe_field_value = f8
             3 oe_field_meaning_id = f8
             3 candidate_id = f8
             3 active_ind = i2
             3 active_status_cd = f8
             3 updt_cnt = i4
             3 label_text = vc
             3 action = i2
             3 force_updt_ind = i2
             3 version_ind = i2
           2 action_partial_ind = i2
           2 action_qual[*]
             3 sch_action_id = f8
             3 version_dt_tm = dq8
             3 sch_action_cd = f8
             3 action_meaning = c12
             3 action_prsnl_id = f8
             3 action_dt_tm = dq8
             3 perform_dt_tm = dq8
             3 candidate_id = f8
             3 active_ind = i2
             3 active_status_cd = f8
             3 updt_cnt = i4
             3 reason_meaning = c12
             3 sch_reason_cd = f8
             3 action = i2
             3 force_updt_ind = i2
             3 version_ind = i2
             3 comment_partial_ind = i2
             3 comment_qual[*]
               4 text_type_cd = f8
               4 sub_text_cd = f8
               4 text_id = f8
               4 text_type_meaning = c12
               4 sub_text_meaning = c12
               4 candidate_id = f8
               4 active_ind = i2
               4 active_status_cd = f8
               4 updt_cnt = i4
               4 action = i2
               4 force_updt_ind = i2
               4 version_ind = i2
               4 text_partial_ind = i2
               4 text_updt_cnt = i4
               4 text_active_ind = i2
               4 text_active_status_cd = f8
               4 long_text = vc
               4 text_action = i2
               4 text_force_updt_ind = i2
               4 text_version_ind = i2
       )
       FREE RECORD chgw_job_reply
       RECORD chgw_job_reply(
         1 qual_cnt = i4
         1 qual[*]
           2 sch_job_id = f8
           2 status = i2
           2 detail_qual_cnt = i4
           2 detail_qual[*]
             3 candidate_id = f8
             3 status = i2
           2 action_qual_cnt = i4
           2 action_qual[*]
             3 sch_action_id = f8
             3 candidate_id = f8
             3 status = i2
             3 comment_qual_cnt = i4
             3 comment_qual[*]
               4 candidate_id = f8
               4 status = i2
               4 text_status = i2
               4 text_id = f8
       )
       CALL quiet("ON")
       SELECT INTO "nl:"
        FROM sch_job sj
        WHERE sj.job_type_cd=job_cd
         AND sj.job_class=job_class
         AND sj.job_state_cd=retry_cd
         AND sj.active_ind=true
        ORDER BY sj.sch_job_id
        HEAD REPORT
         retryjobcnt = 0, stat = initrec(chgw_job_request)
        HEAD sj.sch_job_id
         retryjobcnt += 1
         IF (mod(retryjobcnt,10)=1)
          stat = alterlist(chgw_job_request->qual,(retryjobcnt+ 9))
         ENDIF
         chgw_job_request->qual[retryjobcnt].sch_job_id = sj.sch_job_id, chgw_job_request->qual[
         retryjobcnt].action = action_chg, chgw_job_request->qual[retryjobcnt].job_state_cd =
         requested_cd,
         chgw_job_request->qual[retryjobcnt].lock_dt_tm = null_dt, chgw_job_request->qual[retryjobcnt
         ].complete_dt_tm = null_dt, chgw_job_request->qual[retryjobcnt].last_dt_tm = null_dt,
         chgw_job_request->qual[retryjobcnt].parent_entity_name = sj.parent_entity_name,
         chgw_job_request->qual[retryjobcnt].parent_entity_id = sj.parent_entity_id, chgw_job_request
         ->qual[retryjobcnt].key_entity_name = sj.key_entity_name,
         chgw_job_request->qual[retryjobcnt].key_entity_id = sj.key_entity_id, chgw_job_request->
         qual[retryjobcnt].job_type_cd = sj.job_type_cd, chgw_job_request->qual[retryjobcnt].
         job_status_cd = sj.job_status_cd,
         chgw_job_request->qual[retryjobcnt].display = sj.display, chgw_job_request->qual[retryjobcnt
         ].job_key = sj.job_key, chgw_job_request->qual[retryjobcnt].job_class = sj.job_class,
         chgw_job_request->qual[retryjobcnt].sch_conversation_id = sj.sch_conversation_id,
         chgw_job_request->qual[retryjobcnt].request_dt_tm = cnvtdatetime(sj.request_dt_tm),
         chgw_job_request->qual[retryjobcnt].attempt_cnt = sj.attempt_cnt,
         chgw_job_request->qual[retryjobcnt].updt_cnt = sj.updt_cnt, chgw_job_request->qual[
         retryjobcnt].active_ind = sj.active_ind, chgw_job_request->qual[retryjobcnt].
         active_status_cd = sj.active_status_cd
        FOOT REPORT
         stat = alterlist(chgw_job_request->qual,retryjobcnt), end_jobs_retry = retryjobcnt
        WITH nocounter
       ;end select
       CALL quiet("OFF")
       IF (curqual=0)
        SET end_jobs_retry = 0
       ENDIF
       IF (end_jobs_retry > 0)
        EXECUTE pft_chgw_job
        IF ((reply->status_data.status="F"))
         CALL echo("*_*_* ProcessJobList->pft_chgw_job ROLLBACK *_*_*")
         ROLLBACK
        ELSE
         COMMIT
         IF (eventparamexists("PFTOPS_DELAY"))
          SET retrydelayseconds = geteventparamasinteger("PFTOPS_DELAY")
          SET retrydelayseconds = least(retrydelayseconds,retry_delay_cap)
         ENDIF
         CALL sleepseconds(retrydelayseconds)
         EXECUTE pft_call_ops  WITH replace("REQUEST",pft_call_ops_request), replace("REPLY",
          pft_call_ops_reply)
         IF ((pft_call_ops_reply->status_data.status != "S"))
          CALL setreply("F",curprog,"An error occurred while attempting to start threaded processing"
           )
          CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
          RETURN(false)
         ENDIF
         SET last_job_count = end_jobs_retry
         SET this_job_count = end_jobs_retry
        ENDIF
       ELSE
        SET sleep_seconds = default_sleep
        CALL echo(build2("All jobs have been processed..."))
        SET all_jobs_processed = true
       ENDIF
       FREE RECORD chgw_job_request
       FREE RECORD chgw_job_reply
      ELSEIF (no_change_count > max_retries)
       CALL echo(build2("All job processing threads seem to have stopped..."))
       CALL echo(build2("Halting event processing..."))
       SET this_job_count = 0
      ENDIF
    ENDWHILE
    CALL quiet("ON")
    SELECT INTO "nl:"
     acount = count(*)
     FROM sch_job sj
     WHERE sj.job_type_cd=job_cd
      AND sj.job_class=job_class
      AND sj.job_state_cd=requested_cd
      AND sj.active_ind=true
     GROUP BY sj.job_type_cd, sj.job_class, sj.job_state_cd
     FOOT REPORT
      end_jobs_requested = acount
     WITH nocounter
    ;end select
    CALL quiet("OFF")
    SET end_total_jobs += end_jobs_requested
    CALL echo(build2(trim(cnvtstring(end_jobs_requested))," requested ",evaluate(end_jobs_requested,1,
       "job","jobs")," remaining..."))
    CALL quiet("ON")
    SELECT INTO "nl:"
     acount = count(*)
     FROM sch_job sj
     WHERE sj.job_type_cd=job_cd
      AND sj.job_class=job_class
      AND sj.job_state_cd=completed_cd
      AND sj.active_ind=true
     GROUP BY sj.job_type_cd, sj.job_class, sj.job_state_cd
     FOOT REPORT
      end_jobs_completed = acount
     WITH nocounter
    ;end select
    CALL quiet("OFF")
    SET end_total_jobs += end_jobs_completed
    CALL echo(build2(trim(cnvtstring(end_jobs_completed))," completed ",evaluate(end_jobs_completed,1,
       "job...","jobs...")))
    CALL quiet("ON")
    SELECT INTO "nl:"
     acount = count(*)
     FROM sch_job sj
     WHERE sj.job_type_cd=job_cd
      AND sj.job_class=job_class
      AND sj.job_state_cd=error_cd
      AND sj.active_ind=true
     GROUP BY sj.job_type_cd, sj.job_class, sj.job_state_cd
     FOOT REPORT
      end_jobs_error = acount
     WITH nocounter
    ;end select
    CALL quiet("OFF")
    SET end_total_jobs += end_jobs_error
    CALL echo(build2(trim(cnvtstring(end_jobs_error)),evaluate(end_jobs_error,1," job"," jobs"),
      " with errors..."))
    SET job_average_secs = (cnvtreal(elapsed_seconds)/ cnvtreal((end_total_jobs - end_jobs_requested)
     ))
    CALL echo("")
    CALL echo(fillstring(79,"="))
    CALL echo("Load Balancing Statistics From This Run:")
    CALL echo(fillstring(79,"="))
    CALL echo(build2(trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job was",
       " jobs were")," submitted for processing..."))
    CALL echo(build2(trim(cnvtstring((end_jobs_completed+ end_jobs_error))),evaluate((
       end_jobs_completed+ end_jobs_error),1," job was"," jobs were")," processed..."))
    CALL echo(build2(trim(cnvtstring(elapsed_seconds)),evaluate(elapsed_seconds,1," second",
       " seconds")," elapsed while jobs were processing..."))
    CALL echo(build2("Average processing time per job was ",trim(cnvtstring(job_average_secs,11,3)),
      " seconds  ..."))
    CALL echo(build2("Average number of jobs processed every ",trim(cnvtstring(sleep_seconds)),
      " seconds was ",trim(cnvtstring((cnvtreal(sleep_seconds)/ cnvtreal(job_average_secs)),11,3)),
      " ..."))
    CALL echo(fillstring(79,"="))
    CALL seteventcounterbytype("ERROR",end_jobs_error)
    CALL seteventcounterbytype("WARNING",end_jobs_requested)
    CALL setreply(evaluate(getfinaleventstatus(null),true,"S",false,"F"),curprog,build2("Submitted ",
      trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job; "," jobs; "),trim(cnvtstring(
        end_jobs_completed))," successful, ",
      trim(cnvtstring(end_jobs_error))," with errors, ",trim(cnvtstring(end_jobs_requested)),
      " unprocessed."))
    SET event_subevent_results->subevent_cnt += 1
    SET stat = alterlist(event_subevent_results->subevent_results,event_subevent_results->
     subevent_cnt)
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_total_jobs = end_total_jobs
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_completed = end_jobs_completed
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_error = end_jobs_error
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_jobs_requested = end_jobs_requested
    SET event_subevent_results->subevent_results[event_subevent_results->subevent_cnt].
    subevent_status_message = build2(curprog,"/",cnvtupper(trim(geteventparamasstring("PFTOPS_SCR"))),
     " [Subevent ",trim(cnvtstring(event_subevent_results->subevent_cnt)),
     "]: Submitted ",trim(cnvtstring(end_total_jobs)),evaluate(end_total_jobs,1," job; "," jobs; "),
     trim(cnvtstring(end_jobs_completed))," successful, ",
     trim(cnvtstring(end_jobs_error))," with errors, ",trim(cnvtstring(end_jobs_requested)),
     " unprocessed.")
    CALL echotimingmsg("Exiting ProcessJobList ...",subtime)
    RETURN(getfinaleventstatus(null))
   ENDIF
 END ;Subroutine
 DECLARE purgejoblistentries(null) = i2
 SUBROUTINE purgejoblistentries(null)
   DECLARE subtime = f8 WITH protect, noconstant(0.0)
   CALL echotimingmsg("Entering PurgeJobListEntries ...",subtime)
   FREE SET dbsr_verbose_mode
   SET persist_called = false
   IF ( NOT (loadbalancingenabled(null)))
    IF (geteventcounterbytype("ERROR") > 0)
     CALL echo(fillstring(79,"!"))
     CALL echo(build2("Logging jobs with errors to ",job_error_log_filename,".dat"))
     CALL echo(fillstring(79,"!"))
     DECLARE jobhandler = vc WITH protect, noconstant("")
     SET jobhandler = geteventparamasstring("PFTOPS_SCR")
     CALL quiet("ON")
     SELECT INTO value(job_error_log_filename)
      event_handler = substring(1,32,concat(curprog,fillstring(32," "))), job_handler = substring(1,
       32,concat(jobhandler,fillstring(32," "))), parent_entity_name = substring(1,32,concat(
        event_joblist->parent_entity_name,fillstring(32," "))),
      parent_entity_id = format(event_joblist->job_qual[d.seq].parent_entity_id,"##############.#")
      FROM (dummyt d  WITH seq = event_joblist->job_cnt)
      WHERE (event_joblist->job_qual[d.seq].returned_status="F")
      WITH format = pcformat, format = variable, nocounter,
       append
     ;end select
     CALL quiet("OFF")
    ENDIF
    SET stat = initrec(event_joblist)
    CALL echotimingmsg("Exiting PurgeJobListEntries ...",subtime)
    RETURN(true)
   ENDIF
   IF (geteventparamasstring("PFTOPS_BLK")="N")
    CALL echotimingmsg("Exiting PurgeJobListEntries ...",subtime)
    RETURN(true)
   ENDIF
   DECLARE del_job_class = vc WITH protect, noconstant("")
   SET del_job_class = build(geteventparamasstring("PFTOPS_SCR"),"|",unique_job_tag,job_tag_fe_ld,"|",
    geteventparamasstring("PFTOPS_BLK"),trap_job_ccl_errors)
   IF (geteventcounterbytype("ERROR") > 0)
    CALL echo(fillstring(79,"!"))
    CALL echo(build2("Logging jobs with errors to ",job_error_log_filename,".dat"))
    CALL echo(fillstring(79,"!"))
    CALL quiet("ON")
    SELECT INTO value(job_error_log_filename)
     event_handler = substring(1,32,concat(curprog,fillstring(32," "))), job_class = substring(1,32,
      concat(del_job_class,fillstring(32," "))), parent_entity_name = substring(1,32,concat(sj
       .parent_entity_name,fillstring(32," "))),
     parent_entity_id = format(sj.parent_entity_id,"##############.#")
     FROM sch_job sj
     WHERE sj.job_type_cd=job_cd
      AND sj.job_class=del_job_class
      AND sj.job_state_cd=error_cd
     WITH format = pcformat, format = variable, nocounter,
      append
    ;end select
    CALL quiet("OFF")
   ENDIF
   SET stat = initrec(event_joblist)
   CALL quiet("ON")
   DELETE  FROM sch_job sj
    WHERE sj.job_type_cd=job_cd
     AND sj.job_class=del_job_class
    WITH nocounter
   ;end delete
   CALL quiet("OFF")
   COMMIT
   CALL echotimingmsg("Exiting PurgeJobListEntries ...",subtime)
   RETURN(true)
 END ;Subroutine
 DECLARE scriptexecutingasfinevent(null) = i2
 SUBROUTINE scriptexecutingasfinevent(null)
   IF (validate(request->batch_selection,"") != "")
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (seteventcounterbytype(scounttype=vc,lcount=i4) =i2)
  CASE (scounttype)
   OF "ERROR":
    SET event_error_cnt = lcount
   OF "WARNING":
    SET event_warning_cnt = lcount
   ELSE
    RETURN(false)
  ENDCASE
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (seteventerrorflag(errflag=i2,tablename=vc) =i2)
   SET failed = errflag
   IF (errflag=false)
    SET table_name = " "
   ELSE
    SET table_name = cnvtupper(trim(tablename))
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (seteventparamvalue(paramname=vc,paramvalue=vc) =i2)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE cval = f8 WITH noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(24454,nullterm(paramname),1,cval)
   IF (iret != 0)
    CALL echo(build2(curprog,"::SetEventParamValue - Attempted to set unknown parameter [",paramname,
      "]"))
    RETURN(false)
   ENDIF
   SET idx = locateval(num,start,pft_event_rep->lparams_qual,paramname,pft_event_rep->aparams[num].
    svalue_meaning)
   IF (idx > 0)
    SET pft_event_rep->aparams[idx].svalue = trim(paramvalue)
    RETURN(true)
   ELSE
    SET idx = (pft_event_rep->lparams_qual+ 1)
    SET pft_event_rep->lparams_qual = idx
    SET stat = alterlist(pft_event_rep->aparams,idx)
    SET pft_event_rep->aparams[idx].dvalue_meaning = cval
    SET pft_event_rep->aparams[idx].svalue_meaning = trim(paramname)
    SET pft_event_rep->aparams[idx].svalue = trim(paramvalue)
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (seteventparententityname(sparententityname=vc) =i2)
  SET job_entity_name = sparententityname
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (seteventstatuscode(dstatus=f8) =i2)
  SET pft_event_rep->devent_status_cd = dstatus
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (seteventstatuscodebymeaning(smeaning=vc) =i2)
   DECLARE dcodevalue = f8 WITH noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(23372,nullterm(smeaning),1,dcodevalue)
   SET pft_event_rep->devent_status_cd = dcodevalue
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (seteventstatusreasoncode(dreason=f8) =i2)
  SET pft_event_rep->devent_reason_cd = dreason
  RETURN(true)
 END ;Subroutine
 DECLARE setloadbalancingparams(null) = i2
 SUBROUTINE setloadbalancingparams(null)
   DECLARE event_sub_type = vc
   SET event_sub_type = trim(uar_get_code_meaning(pft_event_rep->devent_sub_type_cd))
   CALL echo(build2("Event subtype = ",event_sub_type))
   IF (loadbalancingenabled(null))
    IF ( NOT (eventparamexists("PFTOPS_THR")))
     CALL seteventparamvalue("PFTOPS_THR","2")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_SLC")))
     CALL seteventparamvalue("PFTOPS_SLC","10")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_ITR")))
     CALL seteventparamvalue("PFTOPS_ITR","5")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_SUB")))
     CALL seteventparamvalue("PFTOPS_SUB","999999")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_KILL")))
     CALL seteventparamvalue("PFTOPS_KILL","1440")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_LOCK")))
     CALL seteventparamvalue("PFTOPS_LOCK","1")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_BLK")))
     CALL seteventparamvalue("PFTOPS_BLK","Y")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_FAIL")))
     CALL seteventparamvalue("PFTOPS_FAIL","Y")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_A_SLC")))
     CALL seteventparamvalue("PFTOPS_A_SLC","N")
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_RETRY")))
     IF ((pft_event_rep->devent_sub_type_cd IN (clmgenedi_cd, clmgenpaper_cd, state_gen_cd,
     holdrelease_cd)))
      CALL seteventparamvalue("PFTOPS_RETRY","1")
     ELSE
      CALL seteventparamvalue("PFTOPS_RETRY","0")
     ENDIF
    ENDIF
    IF ( NOT (eventparamexists("PFTOPS_DELAY")))
     IF ((pft_event_rep->devent_sub_type_cd IN (clmgenedi_cd, clmgenpaper_cd, state_gen_cd,
     holdrelease_cd)))
      CALL seteventparamvalue("PFTOPS_DELAY","120")
     ELSE
      CALL seteventparamvalue("PFTOPS_DELAY","0")
     ENDIF
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (sleepseconds(iseconds=i2) =i2)
   DECLARE idx = i2 WITH protect, noconstant(0)
   IF (iseconds > 0)
    FOR (idx = 1 TO iseconds)
      CALL pause(1)
    ENDFOR
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE standardeventerrorchecks(null) = i2
 SUBROUTINE standardeventerrorchecks(null)
   IF (failed=false)
    IF (geteventcounterbytype("ERROR") > 0)
     CALL seteventstatuscodebymeaning("COMP W ERR")
    ELSEIF (geteventcounterbytype("WARNING") > 0)
     CALL seteventstatuscodebymeaning("COMP W WARN")
    ELSE
     CALL seteventstatuscodebymeaning("COMP WO ERR")
    ENDIF
   ELSE
    CALL setreply("F",curprog,"Failed")
    CALL handleeventerror(failed)
    CALL seteventstatuscodebymeaning("FAILED")
   ENDIF
   IF (commitlogicenabled(null)
    AND ((failed) OR ((reply->status_data.status="F"))) )
    CALL echo("*_*_* StandardEventErrorChecks ROLLBACK *_*_*")
    ROLLBACK
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (starteventoccur(sparententityname=vc) =i2)
   SET job_entity_name = sparententityname
   IF ( NOT (scriptexecutingasfinevent(null)))
    SET job_tag_fe_ld = build2("ld",cnvtstring(logicaldomainid))
    RETURN(true)
   ENDIF
   DECLARE lcount = i4 WITH noconstant(0)
   DECLARE active_status = f8 WITH noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(48,nullterm("ACTIVE"),1,active_status)
   SET pft_event_req->devent_id = cnvtreal(trim(request->batch_selection))
   CALL quiet("ON")
   SELECT INTO "nl:"
    FROM pft_event p
    WHERE (p.pft_event_id=pft_event_req->devent_id)
     AND p.start_dt_tm <= cnvtdatetime(curdate,2359)
     AND p.end_dt_tm >= cnvtdatetime(curdate,0)
     AND p.active_ind=1
    DETAIL
     IF (p.pft_event_id > 0)
      lcount += 1, pft_event_rep->devent_type_cd = p.pft_event_type_cd, pft_event_rep->
      devent_sub_type_cd = p.pft_event_sub_type_cd,
      pft_event_rep->lcurrent_occurrence = p.current_occurrance, pft_event_rep->levent_updt_cnt = p
      .updt_cnt, logicaldomainid = p.logical_domain_id
     ENDIF
    WITH nocounter
   ;end select
   CALL quiet("OFF")
   SET job_tag_fe_ld = build2("fe",trim(cnvtstring(pft_event_req->devent_id),3),"ld",trim(cnvtstring(
      logicaldomainid),3))
   IF (lcount=0)
    CALL echo(build2(trim(curprog),"::StartEventOccur - Event ",trim(cnvtstring(pft_event_req->
        devent_id))," is not active for the current date"))
    CALL echo(build2(trim(curprog),"::StartEventOccur - Setting failed = NO_EVENT (",trim(cnvtstring(
        no_event)),")"))
    CALL seteventerrorflag(no_event,"pft_event")
    CALL seteventstatuscodebymeaning("FAILED")
    RETURN(false)
   ENDIF
   IF ( NOT (setlogicaldomain(logicaldomainid)))
    CALL echo(build2(trim(curprog),
      "::StartEventOccur - Unable to set the logical domain for the current process"))
    CALL seteventerrorflag(logical_domain_not_set,"pft_event")
    CALL seteventstatuscodebymeaning("FAILED")
    RETURN(false)
   ENDIF
   SET lcount = 0
   CALL quiet("ON")
   SELECT INTO "nl:"
    FROM pft_event_occur_log peo
    WHERE (peo.pft_event_id=pft_event_req->devent_id)
     AND datetimecmp(peo.start_dt_tm,cnvtdatetime(sysdate))=0
     AND peo.active_ind=1
    DETAIL
     IF (peo.pft_event_occur_log_id > 0.0)
      pft_event_rep->devent_occur_log_id = peo.pft_event_occur_log_id, pft_event_rep->
      devent_reason_cd = peo.pft_event_reason_cd, pft_event_rep->loccur_updt_cnt = peo.updt_cnt,
      lcount += 1
     ENDIF
    WITH forupdate(peo), nocounter
   ;end select
   CALL quiet("OFF")
   CALL seteventstatuscodebymeaning("WORKING")
   IF (lcount=1)
    IF ( NOT (updateeventoccurlogbegin(null)))
     CALL seteventstatuscodebymeaning("FAILED")
     RETURN(false)
    ENDIF
   ELSEIF (lcount=0)
    IF ( NOT (addeventoccurlog(null)))
     CALL seteventstatuscodebymeaning("FAILED")
     RETURN(false)
    ENDIF
   ELSE
    CALL seteventerrorflag(lock_error,"pft_event_occur_log")
    CALL seteventstatuscodebymeaning("FAILED")
    RETURN(false)
   ENDIF
   CALL geteventoccurparams(null)
   IF ( NOT (paramsarevalidfordomain(pft_event_rep,logicaldomainid)))
    CALL seteventerrorflag(attribute_error,"pft_event_params")
    CALL seteventstatuscodebymeaning("FAILED")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (subeventcompleted(lsubeventidx=i4) =i2)
   IF (lsubeventidx=0)
    RETURN(false)
   ENDIF
   IF ( NOT (validate(event_subevent_results)))
    RETURN(false)
   ENDIF
   IF (lsubeventidx > size(event_subevent_results->subevent_results,5))
    RETURN(false)
   ENDIF
   IF ((event_subevent_results->subevent_results[lsubeventidx].subevent_jobs_requested > 0))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (subeventsucceeded(lsubeventidx=i4) =i2)
   IF (lsubeventidx=0)
    RETURN(false)
   ENDIF
   IF ( NOT (validate(event_subevent_results)))
    RETURN(false)
   ENDIF
   IF (lsubeventidx > size(event_subevent_results->subevent_results,5))
    RETURN(false)
   ENDIF
   IF ((((event_subevent_results->subevent_results[lsubeventidx].subevent_jobs_requested > 0)) OR ((
   event_subevent_results->subevent_results[lsubeventidx].subevent_jobs_error > 0))) )
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE updateeventoccurlogbegin(null) = i2
 SUBROUTINE updateeventoccurlogbegin(null)
   CALL quiet("ON")
   UPDATE  FROM pft_event_occur_log po
    SET po.pft_event_status_cd = pft_event_rep->devent_status_cd, po.log_file_produced_ind = 0, po
     .start_dt_tm = cnvtdatetime(sysdate),
     po.active_status_prsnl_id = reqinfo->updt_id, po.active_status_dt_tm = cnvtdatetime(sysdate), po
     .updt_cnt = (po.updt_cnt+ 1),
     po.updt_dt_tm = cnvtdatetime(sysdate), po.updt_id = reqinfo->updt_id, po.updt_applctx = reqinfo
     ->updt_applctx,
     po.updt_task = reqinfo->updt_task
    WHERE (po.pft_event_occur_log_id=pft_event_rep->devent_occur_log_id)
     AND po.active_ind=1
    WITH nocounter
   ;end update
   CALL quiet("OFF")
   IF (curqual=0)
    CALL seteventerrorflag(update_error,"pft_event_occur_log")
    RETURN(false)
   ENDIF
   IF (commitlogicenabled(null))
    COMMIT
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE updateeventoccurlogend(null) = i2
 SUBROUTINE updateeventoccurlogend(null)
   CALL quiet("ON")
   UPDATE  FROM pft_event_occur_log po
    SET po.pft_event_status_cd = pft_event_rep->devent_status_cd, po.pft_event_reason_cd =
     pft_event_rep->devent_reason_cd, po.log_file_produced_ind = 1,
     po.end_dt_tm = cnvtdatetime(sysdate), po.active_status_prsnl_id = reqinfo->updt_id, po
     .active_status_dt_tm = cnvtdatetime(sysdate),
     po.updt_cnt = (po.updt_cnt+ 1), po.updt_dt_tm = cnvtdatetime(sysdate), po.updt_id = reqinfo->
     updt_id,
     po.updt_applctx = reqinfo->updt_applctx, po.updt_task = reqinfo->updt_task
    WHERE (po.pft_event_occur_log_id=pft_event_rep->devent_occur_log_id)
     AND po.active_ind=1
    WITH nocounter
   ;end update
   CALL quiet("OFF")
   IF (curqual=0)
    CALL seteventerrorflag(update_error,"pft_event_occur_log")
    RETURN(false)
   ENDIF
   IF (commitlogicenabled(null))
    COMMIT
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (validatejobhandler(shandler=vc) =i2)
  IF (eventparamexists("PFTOPS_SCR"))
   IF (checkprg(cnvtupper(geteventparamasstring("PFTOPS_SCR"))))
    RETURN(true)
   ENDIF
  ENDIF
  IF (checkprg(cnvtupper(shandler)))
   CALL seteventparamvalue("PFTOPS_SCR",shandler)
   RETURN(true)
  ELSE
   CALL seteventerrorflag(attribute_error,build2("Job handler script ",shandler,
     " does not exist in CCL dictionary"))
   CALL echo("The job handler script does not exist in the CCL dictionary")
   RETURN(false)
  ENDIF
 END ;Subroutine
 RECORD csfacilitytimezone(
   1 timezonelist[*]
     2 organization_id = f8
     2 timezoneindex = i4
     2 from_date = dq8
     2 today = dq8
     2 organization[*]
       3 org_id = f8
 ) WITH protect
 FREE RECORD rulesetdata
 RECORD rulesetdata(
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
 ) WITH protect
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
  )
 ENDIF
 RECORD joblistrec(
   1 objarray[*]
     2 encntr_id = f8
 )
 RECORD loadbalbatchselection(
   1 params[*]
     2 param = vc
 )
 RECORD charge_trans_request(
   1 batch_selection = vc
   1 output_dist = vc
   1 ops_date = dq8
   1 encntr_id = f8
   1 load_balance_flag = i2
 )
 IF ( NOT (validate(siteprefs)))
  RECORD siteprefs(
    1 site_pref_qual = i2
    1 site_pref[*]
      2 info_name = vc
      2 info_date = dq8
      2 info_char = vc
      2 info_number = f8
      2 info_long_id = f8
      2 updt_applctx = f8
      2 updt_task = f8
      2 info_domain_id = f8
  )
 ENDIF
 DECLARE len = i2 WITH protect, noconstant(0)
 DECLARE lennext = i2 WITH protect, noconstant(0)
 DECLARE logicaldomainsinuse = i2 WITH protect, noconstant(0)
 DECLARE today = q8 WITH public
 DECLARE from_date = q8 WITH public
 DECLARE tempbatchselection = vc WITH protect, noconstant("")
 DECLARE cntrule = i4 WITH public, noconstant(0)
 DECLARE cntrs = i4 WITH public, noconstant(0)
 DECLARE hpidx = i4 WITH protect, noconstant(0)
 DECLARE orgidx = i4 WITH protect, noconstant(0)
 DECLARE insidx = i4 WITH protect, noconstant(0)
 DECLARE encntrtypeidx = i4 WITH protect, noconstant(0)
 DECLARE encntrclassidx = i4 WITH protect, noconstant(0)
 DECLARE finidx = i4 WITH protect, noconstant(0)
 DECLARE loopcnt = i4 WITH public, noconstant(0)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE script_start_dt_tm = dm12 WITH protect, constant(systimestamp)
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 DECLARE jobindex = i4 WITH protect, noconstant(0)
 DECLARE pftops_thr = i2 WITH protect, noconstant(0)
 DECLARE pftops_slc = i2 WITH protect, noconstant(0)
 DECLARE batchselectionidx = i2 WITH protect, noconstant(0)
 DECLARE numberofdaysbacktoprocess = i2 WITH public, noconstant(1)
 DECLARE ialreadyrunning = i2 WITH public, noconstant(0)
 CALL beginscript(curprog)
 SET logicaldomainsinuse = arelogicaldomainsinuse(null)
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echo(build2("IslogicalDomainInUse: ",logicaldomainsinuse))
 ENDIF
 IF (validate(request->batch_selection)=1)
  SET tempbatchselection = request->batch_selection
  SET len = findstring("|",trim(request->batch_selection),1)
  SET lennext = findstring("|",trim(request->batch_selection),(len+ 1))
  IF (len=1)
   SET numberofdaysbacktoprocess = 1
  ELSEIF (len=0)
   SET numberofdaysbacktoprocess = cnvtint(trim(request->batch_selection))
  ELSE
   SET stat = arraysplit(loadbalbatchselection->params[batchselectionidx].param,batchselectionidx,
    trim(request->batch_selection),"|")
   SET numberofdaysbacktoprocess = cnvtint(loadbalbatchselection->params[1].param)
   IF (size(loadbalbatchselection->params,5)=1)
    IF (logicaldomainsinuse=true)
     CALL echo("Single Param not suported for logical domain in use")
     GO TO end_program
    ENDIF
   ELSEIF (size(loadbalbatchselection->params,5)=3)
    IF (logicaldomainsinuse=true)
     CALL echo("Three Param not suported for logical domain in use")
     GO TO end_program
    ENDIF
    SET pftops_thr = cnvtint(loadbalbatchselection->params[2].param)
    SET pftops_slc = cnvtint(loadbalbatchselection->params[3].param)
   ELSEIF (size(loadbalbatchselection->params,5) > 3)
    SET logicaldomainid = cnvtint(loadbalbatchselection->params[2].param)
    SET pftops_thr = cnvtint(loadbalbatchselection->params[3].param)
    SET pftops_slc = cnvtint(loadbalbatchselection->params[4].param)
    SET request->batch_selection = build(numberofdaysbacktoprocess,"|",logicaldomainid,"|")
   ENDIF
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
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("pftops_thr: ",pftops_thr," pftops_slc: ",pftops_slc))
  ENDIF
 ELSE
  SET numberofdaysbacktoprocess = cnvtint( $1)
  SET request->batch_selection = cnvtstring(numberofdaysbacktoprocess)
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo(build("The number of days to process is: ",numberofdaysbacktoprocess))
 ENDIF
 IF (numberofdaysbacktoprocess=0)
  SET numberofdaysbacktoprocess = 1
  SET request->batch_selection = cnvtstring(numberofdaysbacktoprocess)
 ENDIF
 CALL checkdminfo(0)
 IF (ialreadyrunning=1)
  IF (validate(debug,- (1)) > 0)
   CALL echo("AFC_CT_EXECUTE Process already running exit Script")
  ENDIF
  GO TO end_program
 ELSE
  IF (validate(debug,- (1)) > 0)
   CALL echo("AFC_CT_EXECUTE Process Started")
  ENDIF
  CALL uptsitepref(1)
 ENDIF
 IF (pftops_thr > 0
  AND pftops_slc > 0)
  SET today = cnvtdatetime(sysdate)
  SET today = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D"),"00:00:00.00"))
  SET from_date = datetimeadd(today,- (numberofdaysbacktoprocess))
  IF (validate(debug,- (1)) > 0)
   CALL echo(build("Today:",today))
   CALL echo(build("From:",from_date))
  ENDIF
  CALL getcsfacilitytimezonedetails(0)
  IF (validate(debug,- (1)) > 0)
   CALL echorecord(csfacilitytimezone)
  ENDIF
  CALL enableerrortrap(true)
  SET request->batch_selection = ""
  IF ( NOT (starteventoccur("ENCOUNTER")))
   CALL logmsg(curprog,"Unable to process the event",log_error)
   CALL standardeventerrorchecks(null)
   GO TO end_program
  ENDIF
  SET request->batch_selection = tempbatchselection
  CALL enableloadbalance(null)
  IF (validate(debug,- (1)) > 0)
   CALL showeventparams(null)
  ENDIF
  IF ( NOT (validatejobhandler("afc_ct_execute_handler")))
   CALL echo(build2("Unable to verify job handler: ","afc_ct_execute_handler"))
   GO TO exit_script
  ENDIF
  CALL includeliteralvalueitem(request->batch_selection,"vc","batch_selection")
  CALL includeliteralvalueitem(nullterm(cnvtstring("")),"dq8","ops_date")
  CALL includeliteralvalueitem(nullterm(cnvtstring("TRUE")),"i2","load_balance_flag")
  CALL getrulesetdata(0)
  IF (validate(debug,- (1)) > 0)
   CALL echorecord(rulesetdata)
  ENDIF
  DECLARE loop_start_dt_tm = dm12 WITH protect, noconstant(systimestamp)
  DECLARE job_start_dt_tm = dm12 WITH protect, noconstant(systimestamp)
  FOR (loopcnt = 1 TO cntrs)
    SET job_start_dt_tm = systimestamp
    SET custom_job_req_defs->field_cnt = 2
    CALL includeliteralvalueitem(nullterm(cnvtstring(rulesetdata->rulesets[loopcnt].ruleset_id)),"f8",
     "ruleset_id")
    IF (validate(request->encntr_id)=1
     AND (request->encntr_id > 0))
     SET stat = alterlist(joblistrec->objarray,1)
     SET joblistrec->objarray[1].encntr_id = request->encntr_id
    ELSE
     CALL getqualifiedencntrs(0)
    ENDIF
    FOR (jobindex = 1 TO size(joblistrec->objarray,5))
      IF ( NOT (addjobtolist(joblistrec->objarray[jobindex].encntr_id,true)))
       CALL echo(build2("Error adding ID ",trim(cnvtstring(c.encntr_id))))
      ENDIF
    ENDFOR
    CALL processjoblist(null)
    CALL logsystemactivity(job_start_dt_tm,"afc_ct_execute"," ",0.0,"Z",
     build2("Job List count[",loopcnt,"]"),script_and_detail_level_timer)
    CALL purgejoblistentries(null)
  ENDFOR
  CALL logsystemactivity(loop_start_dt_tm,"afc_ct_execute"," ",0.0,"Z",
   build2("CT load balanced program"),script_and_detail_level_timer)
 ELSE
  IF (validate(debug,- (1)) > 0)
   CALL echo("No Load Balance program execution.")
  ENDIF
  IF (validate(request->batch_selection))
   SET charge_trans_request->batch_selection = request->batch_selection
  ENDIF
  IF (validate(request->ops_date))
   SET charge_trans_request->ops_date = request->ops_date
  ENDIF
  IF (validate(request->output_dist))
   SET charge_trans_request->output_dist = request->output_dist
  ENDIF
  IF (validate(request->encntr_id))
   SET charge_trans_request->encntr_id = request->encntr_id
  ENDIF
  SET charge_trans_request->load_balance_flag = false
  EXECUTE afc_ct_execute_handler  WITH replace("REQUEST",charge_trans_request)
 ENDIF
 IF (ialreadyrunning=1)
  IF (validate(debug,- (1)) > 0)
   CALL echo("AFC_CT_EXECUTE Process Completed")
  ENDIF
  CALL uptsitepref(0)
 ENDIF
 GO TO end_program
#exit_script
#end_program
 IF (ialreadyrunning=1)
  SET reply->status_data.status = "Z"
  IF (validate(debug,- (1)) > 0)
   CALL echo("Aborted: Engine already running...")
  ENDIF
 ELSEIF ((request->ops_date > 0.0)
  AND logicaldomainsinuse=true
  AND ((lennext=0) OR ((lennext=(len+ 1)))) )
  SET reply->status_data.status = "F"
  IF (validate(debug,- (1)) > 0)
   CALL echo("Enter valid input format for batch selection")
  ENDIF
 ENDIF
 CALL echo(build2("Program execution complete."))
 SUBROUTINE (getqualifiedencntrs(dummy=i2) =i2)
   DECLARE count = i4 WITH noconstant(0)
   DECLARE start_dt_tm = dm12 WITH protect, constant(systimestamp)
   DECLARE icount = i4 WITH noconstant(0)
   DECLARE itimezonecount = i4 WITH noconstant(0)
   DECLARE soprparser = vc WITH protect
   DECLARE sencntrclassparser = vc WITH protect
   DECLARE shpparser = vc WITH protect
   DECLARE sfinparser = vc WITH protect
   DECLARE sorgparser = vc WITH protect
   DECLARE sencntrtypeparser = vc WITH protect
   DECLARE in_clause_ind = i2 WITH private, noconstant(false)
   DECLARE 370_carrier_cd = f8 WITH noconstant(0.0)
   DECLARE cs71_encntr = i4 WITH constant(71)
   SET stat = uar_get_meaning_by_codeset(370,"CARRIER",1,370_carrier_cd)
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.health_plan,5) > 0)
    IF ((rulesetdata->rulesets[loopcnt].tier_row.health_plan_excl_ind=1))
     SET shpparser = build(shpparser," c.health_plan_id+0 not in (")
    ELSE
     SET shpparser = build(shpparser," c.health_plan_id+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.health_plan,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       shpparser = build(shpparser,rulesetdata->rulesets[loopcnt].tier_row.health_plan[d.seq].
        health_plan_id), in_clause_ind = true
      ELSE
       shpparser = build(shpparser,", ",rulesetdata->rulesets[loopcnt].tier_row.health_plan[d.seq].
        health_plan_id)
      ENDIF
     FOOT REPORT
      shpparser = build(shpparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET shpparser = "1=1"
   ENDIF
   CALL echo(build2("RRR sHPParser",shpparser))
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.organization,5) > 0)
    IF ((rulesetdata->rulesets[loopcnt].tier_row.org_excl_ind=1))
     SET sorgparser = build(sorgparser," c.payor_id+0 not in (")
    ELSE
     SET sorgparser = build(sorgparser," c.payor_id+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.organization,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sorgparser = build(sorgparser,rulesetdata->rulesets[loopcnt].tier_row.organization[d.seq].
        org_id), in_clause_ind = true
      ELSE
       sorgparser = build(sorgparser,", ",rulesetdata->rulesets[loopcnt].tier_row.organization[d.seq]
        .org_id)
      ENDIF
     FOOT REPORT
      sorgparser = build(sorgparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sorgparser = "1=1"
   ENDIF
   CALL echo(build2("RRR sOrgParser",sorgparser))
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.encntr_type,5) > 0)
    IF ((rulesetdata->rulesets[loopcnt].tier_row.encntr_type_excl_ind=1))
     SET sencntrtypeparser = build(sencntrtypeparser," c.admit_type_cd+0 not in (")
    ELSE
     SET sencntrtypeparser = build(sencntrtypeparser," c.admit_type_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.encntr_type,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sencntrtypeparser = build(sencntrtypeparser,rulesetdata->rulesets[loopcnt].tier_row.
        encntr_type[d.seq].encntr_type_cd), in_clause_ind = true
      ELSE
       sencntrtypeparser = build(sencntrtypeparser,", ",rulesetdata->rulesets[loopcnt].tier_row.
        encntr_type[d.seq].encntr_type_cd)
      ENDIF
     FOOT REPORT
      sencntrtypeparser = build(sencntrtypeparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sencntrtypeparser = "1=1"
   ENDIF
   CALL echo(build2("RRR sEncntrTypeParser",sencntrtypeparser))
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.encntr_type_class,5) > 0)
    IF ((rulesetdata->rulesets[loopcnt].tier_row.encntr_class_excl_ind=1))
     SET sencntrclassparser = build(sencntrclassparser," c.admit_type_cd+0 not in (")
    ELSE
     SET sencntrclassparser = build(sencntrclassparser," c.admit_type_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.encntr_type_class,
        5))),
      code_value_group cvg
     PLAN (d)
      JOIN (cvg
      WHERE cvg.code_set=cs71_encntr
       AND (cvg.parent_code_value=rulesetdata->rulesets[loopcnt].tier_row.encntr_type_class[d.seq].
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
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.fin_class,5) > 0)
    IF ((rulesetdata->rulesets[loopcnt].tier_row.fin_class_excl_ind=1))
     SET sfinparser = build(sfinparser," c.fin_class_cd+0 not in (")
    ELSE
     SET sfinparser = build(sfinparser," c.fin_class_cd+0 in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.fin_class,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       sfinparser = build(sfinparser,rulesetdata->rulesets[loopcnt].tier_row.fin_class[d.seq].
        fin_class_cd), in_clause_ind = true
      ELSE
       sfinparser = build(sfinparser,", ",rulesetdata->rulesets[loopcnt].tier_row.fin_class[d.seq].
        fin_class_cd)
      ENDIF
     FOOT REPORT
      sfinparser = build(sfinparser,")")
     WITH nocounter
    ;end select
   ELSE
    SET sfinparser = "1=1"
   ENDIF
   IF (size(rulesetdata->rulesets[loopcnt].tier_row.insurance_org,5) > 0)
    SET soprparser = "o.health_plan_id = c.health_plan_id"
    IF ((rulesetdata->rulesets[loopcnt].tier_row.ins_org_excl_ind=1))
     SET soprparser = build(soprparser," and ((c.health_plan_id = 0.0) or (o.active_ind = 1")
     SET soprparser = build(soprparser," and o.org_plan_reltn_cd =",370_carrier_cd)
     SET soprparser = build(soprparser," and o.organization_id not in (")
    ELSE
     SET soprparser = build(soprparser," and o.active_ind = 1")
     SET soprparser = build(soprparser," and o.org_plan_reltn_cd =",370_carrier_cd)
     SET soprparser = build(soprparser," and o.organization_id in (")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rulesetdata->rulesets[loopcnt].tier_row.insurance_org,5)))
     PLAN (d)
     HEAD REPORT
      in_clause_ind = false
     DETAIL
      IF (in_clause_ind=false)
       soprparser = build(soprparser,rulesetdata->rulesets[loopcnt].tier_row.insurance_org[d.seq].
        ins_org_id), in_clause_ind = true
      ELSE
       soprparser = build(soprparser,", ",rulesetdata->rulesets[loopcnt].tier_row.insurance_org[d.seq
        ].ins_org_id)
      ENDIF
     FOOT REPORT
      soprparser = build(soprparser,")")
      IF ((rulesetdata->rulesets[loopcnt].tier_row.ins_org_excl_ind=1))
       soprparser = build(soprparser,"))")
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SET soprparser = "o.org_plan_reltn_id = 0.0"
   ENDIF
   CALL echo(build2("RRR sOPRParser",soprparser))
   FOR (itimezonecount = 1 TO size(csfacilitytimezone->timezonelist,5))
    SELECT
     IF (logicaldomainsinuse)
      PLAN (c
       WHERE parser(shpparser)
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
        AND org.logical_domain_id=logicaldomainid
        AND org.active_ind=1)
       JOIN (b
       WHERE (b.bill_item_id=(c.bill_item_id+ 0)))
       JOIN (o
       WHERE parser(soprparser))
     ELSE
     ENDIF
     INTO "nl:"
     FROM organization org,
      encounter e,
      charge c,
      org_plan_reltn o,
      bill_item b
     PLAN (c
      WHERE parser(shpparser)
       AND parser(sorgparser)
       AND parser(sfinparser)
       AND parser(sencntrtypeparser)
       AND parser(sencntrclassparser)
       AND ((c.offset_charge_item_id+ 0)=0)
       AND ((c.process_flg+ 0) IN (0, 1, 2, 3, 4,
      100, 999))
       AND ((c.active_ind+ 0)=1)
       AND c.service_dt_tm >= cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].from_date
       )
       AND c.service_dt_tm < cnvtdatetime(csfacilitytimezone->timezonelist[itimezonecount].today)
       AND ((c.charge_item_id+ 0) != 0))
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND e.active_ind=1
       AND expand(icount,1,size(csfacilitytimezone->timezonelist[itimezonecount].organization,5),e
       .organization_id,csfacilitytimezone->timezonelist[itimezonecount].organization[icount].org_id)
      )
      JOIN (org
      WHERE org.organization_id=e.organization_id
       AND org.active_ind=1)
      JOIN (b
      WHERE (b.bill_item_id=(c.bill_item_id+ 0)))
      JOIN (o
      WHERE parser(soprparser))
     ORDER BY c.encntr_id
     HEAD c.encntr_id
      count += 1, stat = alterlist(joblistrec->objarray,count), joblistrec->objarray[count].encntr_id
       = c.encntr_id
     WITH expand = 1, nocounter
    ;end select
    SET qualcount += curqual
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(joblistrec)
    CALL echo(build2("Total number of qualified encntrs: ",qualcount))
   ENDIF
   CALL logsystemactivity(start_dt_tm,"afc_ct_execute"," ",0.0,"Z",
    build2("getQualifiedEncntrs for RuleSet_Id[",rulesetdata->rulesets[loopcnt].ruleset_id,"]",
     " For Count[",itimezonecount,
     "]"),script_and_detail_level_timer)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getrulesetdata(dummy=i2) =null)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub getRuleSetData")
    CALL echo("----------------------------------")
   ENDIF
   DECLARE health_plan = vc WITH protect, constant("HEALTH_PLAN")
   DECLARE organization = vc WITH protect, constant("ORGANIZATION")
   DECLARE insurance_org = vc WITH protect, constant("INSURANCE_ORG")
   DECLARE encntr_type = vc WITH protect, constant("ENCNTR_TYPE")
   DECLARE encntr_type_class = vc WITH protect, constant("ENCNTR_TYPE_CLASS")
   DECLARE fin_class = vc WITH protect, constant("FIN_CLASS")
   DECLARE ct_codevalue = vc WITH protect, constant("CODE_VALUE")
   DECLARE hpidx = i4 WITH protect, noconstant(0)
   DECLARE orgidx = i4 WITH protect, noconstant(0)
   DECLARE insidx = i4 WITH protect, noconstant(0)
   DECLARE encntrtypeidx = i4 WITH protect, noconstant(0)
   DECLARE encntrclassidx = i4 WITH protect, noconstant(0)
   DECLARE finidx = i4 WITH protect, noconstant(0)
   DECLARE start_dt_tm = dm12 WITH protect, constant(systimestamp)
   SELECT INTO "nl:"
    FROM cs_cpp_ruleset rs,
     cs_cpp_tier t,
     cs_cpp_rule r,
     long_text_reference l,
     cs_cpp_tier_detail td
    PLAN (rs
     WHERE rs.cs_cpp_ruleset_id > 0.0
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
     stat = alterlist(rulesetdata->rulesets,10)
    HEAD t.priority_nbr
     cntrule = 0, cntrs += 1
     IF (mod(cntrs,10)=1
      AND cntrs != 1)
      stat = alterlist(rulesetdata->rulesets,(cntrs+ 10))
     ENDIF
     rulesetdata->rulesets[cntrs].ruleset_id = rs.cs_cpp_ruleset_id, rulesetdata->rulesets[cntrs].
     tier_row.tier_id = t.cs_cpp_tier_id, rulesetdata->rulesets[cntrs].tier_row.health_plan_excl_ind
      = t.health_plan_excld_ind,
     rulesetdata->rulesets[cntrs].tier_row.org_excl_ind = t.organization_excld_ind, rulesetdata->
     rulesets[cntrs].tier_row.ins_org_excl_ind = t.ins_org_excld_ind, rulesetdata->rulesets[cntrs].
     tier_row.encntr_type_excl_ind = t.encntr_type_excld_ind,
     rulesetdata->rulesets[cntrs].tier_row.fin_class_excl_ind = t.fin_class_excld_ind, rulesetdata->
     rulesets[cntrs].tier_row.encntr_class_excl_ind = t.encntr_type_class_excld_ind, hpidx = 0,
     orgidx = 0, insidx = 0, encntrtypeidx = 0,
     encntrclassidx = 0, finidx = 0
    HEAD td.cs_cpp_tier_detail_id
     IF (td.cs_cpp_tier_detail_entity_name=health_plan)
      hpidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.health_plan,hpidx),
      rulesetdata->rulesets[cntrs].tier_row.health_plan[hpidx].health_plan_id = td
      .cs_cpp_tier_detail_entity_id
     ELSEIF (td.cs_cpp_tier_detail_entity_name=organization)
      orgidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.organization,orgidx),
      rulesetdata->rulesets[cntrs].tier_row.organization[orgidx].org_id = td
      .cs_cpp_tier_detail_entity_id
     ELSEIF (td.cs_cpp_tier_detail_entity_name=ct_codevalue)
      IF (td.cs_cpp_tier_detail_subtype=insurance_org)
       insidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.insurance_org,insidx),
       rulesetdata->rulesets[cntrs].tier_row.insurance_org[insidx].ins_org_id = td
       .cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=encntr_type)
       encntrtypeidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.encntr_type,
        encntrtypeidx), rulesetdata->rulesets[cntrs].tier_row.encntr_type[encntrtypeidx].
       encntr_type_cd = td.cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=encntr_type_class)
       encntrclassidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.encntr_type_class,
        encntrclassidx), rulesetdata->rulesets[cntrs].tier_row.encntr_type_class[encntrclassidx].
       encntr_type_class_cd = td.cs_cpp_tier_detail_entity_id
      ELSEIF (td.cs_cpp_tier_detail_subtype=fin_class)
       finidx += 1, stat = alterlist(rulesetdata->rulesets[cntrs].tier_row.fin_class,finidx),
       rulesetdata->rulesets[cntrs].tier_row.fin_class[finidx].fin_class_cd = td
       .cs_cpp_tier_detail_entity_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(rulesetdata->rulesets,cntrs)
    WITH nocounter
   ;end select
   IF (validate(debug,- (1)) > 1)
    CALL echorecord(rulesetdata)
   ENDIF
   CALL logsystemactivity(start_dt_tm,"afc_ct_execute"," ",0.0,"Z",
    build2("getRuleSetData"),script_and_detail_level_timer)
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
 SUBROUTINE (enableloadbalance(dummy=i2) =null)
   CALL seteventparamvalue("PFTOPS_LBAL","Y")
   CALL seteventparamvalue("PFTOPS_SLC",cnvtstring(pftops_slc))
   CALL seteventparamvalue("PFTOPS_A_SLC","Y")
   CALL seteventparamvalue("PFTOPS_THR",cnvtstring(pftops_thr))
   CALL seteventparamvalue("PFTOPS_LOCK","20")
   CALL setloadbalancingparams(null)
   IF (validate(debug,- (1)) > 0)
    CALL echoeventparams(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (showeventparams(dummy=i2) =null)
   CALL echo(build2("PFTOPS_THR: ",geteventparamasstring("PFTOPS_THR")))
   CALL echo(build2("PFTOPS_SLC: ",geteventparamasstring("PFTOPS_SLC")))
   CALL echo(build2("PFTOPS_ITR: ",geteventparamasstring("PFTOPS_ITR")))
   CALL echo(build2("PFTOPS_SUB: ",geteventparamasstring("PFTOPS_SUB")))
   CALL echo(build2("PFTOPS_KILL: ",geteventparamasstring("PFTOPS_KILL")))
   CALL echo(build2("PFTOPS_LOCK: ",geteventparamasstring("PFTOPS_LOCK")))
   CALL echo(build2("PFTOPS_BLK: ",geteventparamasstring("PFTOPS_BLK")))
   CALL echo(build2("PFTOPS_FAIL: ",geteventparamasstring("PFTOPS_FAIL")))
   CALL echo(build2("PFTOPS_A_SLC: ",geteventparamasstring("PFTOPS_A_SLC")))
   CALL echo(build2("PFTOPS_RETRY: ",geteventparamasstring("PFTOPS_RETRY")))
   CALL echo(build2("PFTOPS_RETRY: ",geteventparamasstring("PFTOPS_RETRY")))
   CALL echo(build2("PFTOPS_DELAY: ",geteventparamasstring("PFTOPS_DELAY")))
 END ;Subroutine
 SUBROUTINE (uptsitepref(infonumber=i2) =null)
   SET stat = initrec(siteprefs)
   SET siteprefs->site_pref_qual = 1
   SET stat = alterlist(siteprefs->site_pref,1)
   SET siteprefs->site_pref[1].info_name = "CT RUNNING"
   SET siteprefs->site_pref[1].info_number = infonumber
   SET siteprefs->site_pref[1].info_date = cnvtdatetime(sysdate)
   IF (logicaldomainsinuse)
    SET siteprefs->site_pref[1].info_domain_id = logicaldomainid
   ENDIF
   EXECUTE afc_add_upt_site_prefs  WITH replace("REQUEST",siteprefs)
   COMMIT
   SET ialreadyrunning = infonumber
   IF (validate(debug,- (1)) > 0)
    CALL echo(concat("Memory start: ",trim(cnvtstring(curmem))))
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkdminfo(dummy=i2) =null)
   SELECT
    IF (logicaldomainsinuse)
     PLAN (d
      WHERE d.info_domain_id=logicaldomainid
       AND d.info_domain="CHARGE SERVICES"
       AND d.info_name="CT RUNNING")
    ELSE
    ENDIF
    INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="CHARGE SERVICES"
     AND d.info_name="CT RUNNING"
    DETAIL
     IF (datetimediff(cnvtdatetime(sysdate),d.info_date,3) >= 24)
      ialreadyrunning = 0
     ELSE
      ialreadyrunning = cnvtint(d.info_number)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL logsystemactivity(script_start_dt_tm,"afc_ct_execute"," ",0.0,"Z",
  build2("Total encounters qualified - ","Count[",qualcount,"]"),script_level_timer)
 CALL logsystemactivity(script_start_dt_tm,curprog," ",0.0,reply->status_data.status,
  build2("End calculation of the script execution time - ","Count[",qualcount,"]"),script_level_timer
  )
END GO
