CREATE PROGRAM afc_rpt_ct_error_log:dba
 DECLARE afc_rpt_ct_error_log_version = vc WITH private, noconstant("500383.FT.003")
 CALL echo("Begin including PFT_SYSTEM_ACTIVITY_LOG_SUBS.INC version [664227.024]")
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
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE dfinclasstype = f8 WITH public, noconstant(0.0)
 DECLARE today = f8 WITH public, noconstant(0.0)
 DECLARE from_date = f8 WITH public, noconstant(0.0)
 DECLARE script_start_dt_tm = dm12 WITH protect, constant(systimestamp)
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 DECLARE numberofdaysbacktoprocess = i2 WITH public, noconstant(1)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,dfinclasstype)
 SET reply->status_data.status = "F"
 SET numberofdaysbacktoprocess = cnvtint( $1)
 SET today = cnvtdatetime(sysdate)
 SET today = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D")," 00:00:00.00"))
 SET from_date = datetimeadd(today,- (numberofdaysbacktoprocess))
 SET today = cnvtdatetime(sysdate)
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
 ELSE
  SET prtr_name = "MINE"
 ENDIF
 SELECT INTO value(prtr_name)
  d = cnvtdate(e.error_dt_tm)
  FROM cs_cpp_error_log e,
   cs_cpp_rule r,
   encntr_alias a,
   person p
  PLAN (e
   WHERE e.active_ind=1
    AND e.encntr_id != 0
    AND e.person_id != 0
    AND e.error_dt_tm >= cnvtdatetime(from_date)
    AND e.error_dt_tm <= cnvtdatetime(today))
   JOIN (r
   WHERE r.cs_cpp_rule_id=e.cs_cpp_rule_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (a
   WHERE (a.encntr_id= Outerjoin(e.encntr_id))
    AND (a.encntr_alias_type_cd= Outerjoin(dfinclasstype)) )
  ORDER BY cnvtdate(e.error_dt_tm), e.cs_cpp_rule_id, e.error_text,
   e.encntr_id
  HEAD REPORT
   report_name = uar_i18ngetmessage(i18nhandle,"k1","Charge Transformation Error Report"), line132 =
   fillstring(131,"="), firsttime = 1,
   newpage = 0, newdate = 0, prevencntr = 0.0
  HEAD PAGE
   row 0, col 49, report_name,
   row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Page:"), col 122,
   displaystring, col 128, curpage"###",
   row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Report Date:"), col 107,
   displaystring, col 120, curdate"DD-MMM-YYYY;;D",
   row + 1, col 0, line132,
   row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Date"), col 0,
   displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Rule ID"), col 11,
   displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Rule Name"), col 21,
   displaystring, row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reason for Failure"),
   col 3, displaystring, row + 1,
   displaystring = uar_i18ngetmessage(i18nhandle,"k1","Encntr ID"), col 7, displaystring,
   displaystring = uar_i18ngetmessage(i18nhandle,"k1","FIN"), col 25, displaystring,
   displaystring = uar_i18ngetmessage(i18nhandle,"k1","Patient Name"), col 50, displaystring,
   row + 1, col 0, line132,
   row + 1, newpage = 1, prevencntr = 0.0
  HEAD d
   IF (((row+ 5) > maxrow))
    BREAK
   ENDIF
   rule_name = substring(1,100,r.rule_name), col 0, e.error_dt_tm"DD-MMM;;D",
   col 8, e.cs_cpp_rule_id"##########"
   IF (e.cs_cpp_rule_id < 1)
    displaystring = uar_i18ngetmessage(i18nhandle,"k1","(No Rule)"), col 21, displaystring
   ELSE
    col 21, rule_name
   ENDIF
   row + 1, prevencntr = 0.0, newdate = 1
  HEAD e.cs_cpp_rule_id
   IF (newdate != 1)
    IF (((row+ 5) > maxrow))
     BREAK
    ENDIF
    rule_name = substring(1,100,r.rule_name), col 0, e.error_dt_tm"DD-MMM;;D",
    col 8, e.cs_cpp_rule_id"##########"
    IF (e.cs_cpp_rule_id < 1)
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","(No Rule)"), col 21, displaystring
    ELSE
     col 21, rule_name
    ENDIF
    row + 1, prevencntr = 0.0
   ENDIF
   newdate = 0
  HEAD e.error_text
   IF (((row+ 5) > maxrow))
    BREAK
   ENDIF
   IF (newpage=1
    AND firsttime != 1)
    rule_name = substring(1,100,r.rule_name), col 0, e.error_dt_tm"DD-MMM;;D",
    col 8, e.cs_cpp_rule_id"##########"
    IF (e.cs_cpp_rule_id < 1)
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","(No Rule)"), col 21, displaystring
    ELSE
     col 21, rule_name
    ENDIF
    row + 1
   ENDIF
   newpage = 0, error_text = substring(1,127,e.error_text), col 3,
   error_text, row + 2, prevencntr = 0.0
  DETAIL
   IF (((row+ 5) > maxrow))
    BREAK
   ENDIF
   IF (newpage=1
    AND firsttime != 1)
    rule_name = substring(1,100,r.rule_name), error_text = substring(1,127,e.error_text), col 0,
    e.error_dt_tm"DD-MMM;;D", col 8, e.cs_cpp_rule_id"##########"
    IF (e.cs_cpp_rule_id < 1)
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","(No Rule)"), col 21, displaystring
    ELSE
     col 21, rule_name
    ENDIF
    row + 1, col 3, error_text,
    row + 2
   ENDIF
   newpage = 0
   IF (e.encntr_id != prevencntr)
    fin_nbr = substring(1,20,a.alias), full_name = substring(1,80,p.name_full_formatted), col 6,
    e.encntr_id"##########", col 25, fin_nbr,
    col 50, full_name, row + 1
   ENDIF
   prevencntr = e.encntr_id
  FOOT  e.error_text
   row + 1
  FOOT PAGE
   firsttime = 0
  WITH nocounter, compress, nolandscape,
   maxrow = 60, maxcol = 132
 ;end select
 SET qualcount = curqual
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL logsystemactivity(script_start_dt_tm,curprog," ",0.0,reply->status_data.status,
  build2("End calculation of the script execution time - ","Count[",qualcount,"]"),script_level_timer
  )
END GO
