CREATE PROGRAM afc_run_price_inquiry:dba
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
 DECLARE afc_run_price_inquiry_vrsn = vc WITH constant("720849.FT.018")
 EXECUTE crmrtl
 EXECUTE srvrtl
 RECORD reply(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 mods[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = c200
       3 field2 = c200
       3 field3 = c350
       3 field4 = c200
       3 field5 = c200
       3 field6 = c200
       3 field7 = c200
       3 field8 = c200
       3 field9 = c200
       3 field10 = c200
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 charge_mod_source_cd = f8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
   1 srv_diag[*]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 srv_diag_cd = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag_tier = f8
     2 srv_diag_reason = c200
 )
 RECORD impactedchargeindexlist(
   1 indexes[*]
     2 charge_index = i4
 ) WITH protect
 RECORD priorities(
   1 qual[*]
     2 modpriority = f8
 ) WITH protect
 RECORD modifiers(
   1 qual[*]
     2 field1_id = f8
     2 field6 = c200
     2 field2_id = f8
     2 field_value = i2
     2 field3_id = f8
     2 charge_mod_source_cd = f8
 ) WITH protect
 DECLARE hreq = i4
 DECLARE hlist = i4
 DECLARE hlist2 = i4
 DECLARE hlist3 = i4
 DECLARE hreply = i4
 DECLARE litemcount = i4
 DECLARE lloopcount = i4
 DECLARE lmodcount = i4
 DECLARE lmodloopcount = i4
 DECLARE lchrgcount = i4
 DECLARE releaseappid = i4
 DECLARE releasetaskid = i4
 DECLARE releasereqid = i4
 DECLARE happrelease = i4
 DECLARE htaskrelease = i4
 DECLARE hsteprelease = i4
 DECLARE iret = i4
 DECLARE dchargeeventid = f8
 DECLARE dinquiry = f8
 DECLARE dchargetypecd = f8
 DECLARE dceatypecd = f8
 DECLARE dextmastereventid = f8
 DECLARE dextitemeventid = f8
 DECLARE dextmastereventcontcd = f8
 DECLARE dextitemeventcontcd = f8
 DECLARE dencntrid = f8
 DECLARE nidx = i4
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE requesthaschargeitemid = i2 WITH protect, noconstant(0)
 DECLARE srvstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(cs13019_billcode_cd)))
  DECLARE cs13019_billcode_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs4518006_manually_added_cd)))
  DECLARE cs4518006_manually_added_cd = f8 WITH protect, constant(getcodevalue(4518006,"MANUALLY_ADD",
    0))
 ENDIF
 IF ( NOT (validate(cs4518006_copyfromcem_cd)))
  DECLARE cs4518006_copyfromcem_cd = f8 WITH protect, constant(getcodevalue(4518006,"COPYFROMCEM",0))
 ENDIF
 IF ( NOT (validate(cs4518006_ref_data_cd)))
  DECLARE cs4518006_ref_data_cd = f8 WITH protect, constant(getcodevalue(4518006,"REF_DATA",0))
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
 DECLARE null_vc_d = vc WITH constant("NULL_VC_D")
 FREE RECORD temprequest
 RECORD temprequest(
   1 objarray[*]
     2 chargeeventactid = f8
 )
 DECLARE chrgidx = i4 WITH protect, noconstant(0)
 DECLARE batchsize = i4 WITH protect, noconstant(0)
 DECLARE curlistsize = i4 WITH protect, noconstant(0)
 DECLARE loopcount = i4 WITH protect, noconstant(0)
 DECLARE newlistsize = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE modifierpos = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 IF (validate(debug,- (1)) > 0)
  CALL echo("Request Contents")
  CALL echorecord(request)
 ENDIF
 SET stat = alterlist(temprequest->objarray,size(request->objarray,5))
 FOR (idx = 1 TO size(request->objarray,5))
  SET temprequest->objarray[idx].chargeeventactid = request->objarray[idx].charge_event_act_id
  IF (validate(request->objarray[idx].charge_item_id,0) > 0)
   SET requesthaschargeitemid = true
  ENDIF
 ENDFOR
 IF (arelogicaldomainsinuse(0))
  IF ( NOT (getlogicaldomain(ld_concept_prsnl,logicaldomainid)))
   CALL exitservicefailure("Failed to retrieve logical domain ID...",true)
  ENDIF
 ENDIF
 SET batchsize = 50
 SET curlistsize = size(temprequest->objarray,5)
 SET loopcount = ceil((cnvtreal(curlistsize)/ batchsize))
 SET newlistsize = (loopcount * batchsize)
 SET nstart = 1
 SET stat = alterlist(temprequest->objarray,newlistsize)
 FOR (idx = (curlistsize+ 1) TO newlistsize)
   SET temprequest->objarray[idx].chargeeventactid = temprequest->objarray[curlistsize].
   chargeeventactid
 ENDFOR
 SET releaseappid = 951900
 SET releasetaskid = 951901
 SET releasereqid = 951361
 SET stat = uar_get_meaning_by_codeset(13016,"INQUIRY",1,dinquiry)
 SET stat = uar_get_meaning_by_codeset(13028,"CHARGE NOW",1,dchargetypecd)
 SET stat = uar_get_meaning_by_codeset(13029,"COMPLETE",1,dceatypecd)
 SET stat = alterlist(reply->charges,0)
 IF (validate(request->objarray[1].charge_event_act_id,0) <= 0)
  SELECT INTO "nl:"
   y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    dextmastereventid = cnvtreal(y), dextitemeventid = cnvtreal(y), dextmastereventcontcd = dinquiry,
    dextmasteritemeventcontcd = dinquiry
   WITH format, counter
  ;end select
 ENDIF
 SET iret = uar_crmbeginapp(releaseappid,happrelease)
 IF (iret=0)
  CALL echo("Successfull begin app")
  SET iret = uar_crmbegintask(happrelease,releasetaskid,htaskrelease)
  IF (iret=0)
   CALL echo("Successfull begin task")
   SET iret = uar_crmbeginreq(htaskrelease,"",releasereqid,hsteprelease)
   IF (iret=0)
    CALL echo("Successfull begin req")
    SET hreq = uar_crmgetrequest(hsteprelease)
    IF (validate(request->objarray[1].charge_event_act_id,0) <= 0)
     FOR (lchrgcount = 1 TO size(request->objarray,5))
       CALL echo(build("Chrg Count Price Inquiry: ",lchrgcount))
       SET hlist = uar_srvadditem(hreq,"charge_event")
       SET srvstat = uar_srvsetdouble(hlist,"logical_domain_id",logicaldomainid)
       SET srvstat = uar_srvsetdouble(hlist,"ext_master_event_id",dextmastereventid)
       SET srvstat = uar_srvsetdouble(hlist,"ext_master_event_cont_cd",dextmastereventcontcd)
       SET srvstat = uar_srvsetdouble(hlist,"ext_master_reference_id",request->objarray[lchrgcount].
        ext_parent_reference_id)
       SET srvstat = uar_srvsetdouble(hlist,"ext_master_reference_id",request->objarray[lchrgcount].
        ext_parent_reference_id)
       SET srvstat = uar_srvsetdouble(hlist,"ext_master_reference_cont_cd",request->objarray[
        lchrgcount].ext_parent_contributor_cd)
       SET srvstat = uar_srvsetdouble(hlist,"ext_item_event_id",dextitemeventid)
       SET srvstat = uar_srvsetdouble(hlist,"ext_item_event_cont_cd",dextitemeventcontcd)
       SET srvstat = uar_srvsetdouble(hlist,"ext_item_reference_id",request->objarray[lchrgcount].
        ext_parent_reference_id)
       SET srvstat = uar_srvsetdouble(hlist,"ext_item_reference_cont_cd",request->objarray[lchrgcount
        ].ext_parent_contributor_cd)
       SET srvstat = uar_srvsetdouble(hlist,"person_id",request->objarray[lchrgcount].person_id)
       IF (validate(request->objarray[lchrgcount].encntr_bill_type_cd)=1)
        SET srvstat = uar_srvsetdouble(hlist,"encntr_bill_type_cd",request->objarray[lchrgcount].
         encntr_bill_type_cd)
       ENDIF
       SET srvstat = uar_srvsetdouble(hlist,"encntr_id",request->objarray[lchrgcount].encntr_id)
       SET srvstat = uar_srvsetdouble(hlist,"encntr_org_id",request->objarray[lchrgcount].
        encntr_org_id)
       SET srvstat = uar_srvsetdouble(hlist,"loc_nurse_unit_cd",request->objarray[lchrgcount].
        loc_nurse_unit_cd)
       SET srvstat = uar_srvsetdouble(hlist,"fin_class_cd",request->objarray[lchrgcount].fin_class_cd
        )
       SET srvstat = uar_srvsetdouble(hlist,"health_plan_id",request->objarray[lchrgcount].
        health_plan_id)
       SET srvstat = uar_srvsetdouble(hlist,"encntr_type_cd",request->objarray[lchrgcount].
        encntr_type_cd)
       SET srvstat = uar_srvsetdouble(hlist,"ord_loc_cd",request->objarray[lchrgcount].ord_loc_cd)
       SET srvstat = uar_srvsetdouble(hlist,"perf_loc_cd",request->objarray[lchrgcount].perf_loc_cd)
       IF (validate(request->objarray[lchrgcount].orderingphysid,0) > 0)
        SET srvstat = uar_srvsetdouble(hlist,"ord_phys_id",request->objarray[lchrgcount].
         orderingphysid)
       ENDIF
       IF (validate(request->objarray[lchrgcount].renderingphysid,0) > 0)
        SET srvstat = uar_srvsetdouble(hlist,"verify_phys_id",request->objarray[lchrgcount].
         renderingphysid)
       ENDIF
       IF (validate(request->objarray[lchrgcount].charge_event_id)=1)
        SET srvstat = uar_srvsetdouble(hlist,"charge_event_id",request->objarray[lchrgcount].
         charge_event_id)
       ENDIF
       SET hlist2 = uar_srvadditem(hlist,"charge_event_act")
       SET srvstat = uar_srvsetdouble(hlist2,"charge_type_cd",dchargetypecd)
       SET srvstat = uar_srvsetdouble(hlist2,"cea_type_cd",dceatypecd)
       IF (validate(request->objarray[lchrgcount].serviceresourcecd,0) > 0)
        SET srvstat = uar_srvsetdouble(hlist2,"service_resource_cd",request->objarray[lchrgcount].
         serviceresourcecd)
       ENDIF
       SET srvstat = uar_srvsetdate(hlist2,"service_dt_tm",cnvtdatetime(request->objarray[lchrgcount]
         .service_dt_tm))
       SET srvstat = uar_srvsetlong(hlist2,"quantity",request->objarray[lchrgcount].item_quantity)
       IF (size(request->objarray[lchrgcount].charge_mod,5) > 0)
        FOR (lmodloopcount = 1 TO size(request->objarray[lchrgcount].charge_mod,5))
          SET hlist2 = uar_srvgetstruct(hlist,"mods")
          CALL echo(build("   Charge Mod Price Inquiry",lmodloopcount))
          SET hlist3 = uar_srvadditem(hlist2,"charge_mods")
          SET srvstat = uar_srvsetdouble(hlist3,"charge_mod_type_cd",request->objarray[lchrgcount].
           charge_mod[lmodloopcount].charge_mod_type_cd)
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field1 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field1",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field1)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field2 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field2",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field2)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field3 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field3",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field3)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field4 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field4",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field4)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field5 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field5",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field5)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field6 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field6",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field6)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field7 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field7",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field7)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field8 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field8",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field8)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field9 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field9",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field9)
          ENDIF
          IF ((request->objarray[lchrgcount].charge_mod[lmodloopcount].field10 != null))
           SET srvstat = uar_srvsetstring(hlist3,"field10",request->objarray[lchrgcount].charge_mod[
            lmodloopcount].field10)
          ENDIF
          SET srvstat = uar_srvsetdouble(hlist3,"code1_cd",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].code1_cd)
          SET srvstat = uar_srvsetdouble(hlist3,"nomen_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].nomen_id)
          SET srvstat = uar_srvsetdouble(hlist3,"field1_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].field1_id)
          SET srvstat = uar_srvsetdouble(hlist3,"field2_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].field2_id)
          SET srvstat = uar_srvsetdouble(hlist3,"field3_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].field3_id)
          SET srvstat = uar_srvsetdouble(hlist3,"field4_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].field4_id)
          SET srvstat = uar_srvsetdouble(hlist3,"field5_id",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].field5_id)
          SET srvstat = uar_srvsetdouble(hlist3,"cm1_nbr",request->objarray[lchrgcount].charge_mod[
           lmodloopcount].cm1_nbr)
        ENDFOR
       ENDIF
     ENDFOR
    ELSE
     SET srvstat = uar_srvsetstring(hreq,"action_type","GCE")
     SET hlist = uar_srvadditem(hreq,"charge_event")
     SELECT INTO "nl:"
      FROM charge_event_act cea,
       charge_event ce,
       (dummyt d1  WITH seq = value(loopcount))
      PLAN (d1
       WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batchsize))))
       JOIN (cea
       WHERE expand(idx,nstart,(nstart+ (batchsize - 1)),cea.charge_event_act_id,temprequest->
        objarray[idx].chargeeventactid))
       JOIN (ce
       WHERE ce.charge_event_id=cea.charge_event_id)
      ORDER BY ce.charge_event_id, cea.charge_event_act_id
      HEAD ce.charge_event_id
       hlist = uar_srvadditem(hreq,"charge_event"), srvstat = uar_srvsetdouble(hlist,
        "ext_master_event_id",ce.ext_m_event_id), srvstat = uar_srvsetdouble(hlist,
        "ext_master_event_cont_cd",ce.ext_m_event_cont_cd),
       srvstat = uar_srvsetdouble(hlist,"ext_master_reference_id",ce.ext_m_reference_id), srvstat =
       uar_srvsetdouble(hlist,"ext_master_reference_cont_cd",ce.ext_m_reference_cont_cd), srvstat =
       uar_srvsetdouble(hlist,"ext_parent_event_id",ce.ext_p_event_id),
       srvstat = uar_srvsetdouble(hlist,"ext_parent_event_cont_cd",ce.ext_p_event_cont_cd), srvstat
        = uar_srvsetdouble(hlist,"ext_parent_reference_id",ce.ext_p_reference_id), srvstat =
       uar_srvsetdouble(hlist,"ext_parent_reference_cont_cd",ce.ext_p_reference_cont_cd),
       srvstat = uar_srvsetdouble(hlist,"ext_item_event_id",ce.ext_i_event_id), srvstat =
       uar_srvsetdouble(hlist,"ext_item_event_cont_cd",ce.ext_i_event_cont_cd), srvstat =
       uar_srvsetdouble(hlist,"ext_item_reference_id",ce.ext_i_reference_id),
       srvstat = uar_srvsetdouble(hlist,"ext_item_reference_cont_cd",ce.ext_i_reference_cont_cd),
       srvstat = uar_srvsetdouble(hlist,"person_id",ce.person_id), srvstat = uar_srvsetdouble(hlist,
        "encntr_id",ce.encntr_id),
       srvstat = uar_srvsetdouble(hlist,"order_id",ce.order_id), srvstat = uar_srvsetdouble(hlist,
        "research_acct_id",ce.research_account_id), srvstat = uar_srvsetdouble(hlist,
        "collection_priority_cd",ce.collection_priority_cd),
       srvstat = uar_srvsetdouble(hlist,"report_priority_cd",ce.report_priority_cd), srvstat =
       uar_srvsetdouble(hlist,"perf_loc_cd",ce.perf_loc_cd), srvstat = uar_srvsetdouble(hlist,
        "bill_item_id",ce.bill_item_id),
       srvstat = uar_srvsetdouble(hlist,"charge_event_id",ce.charge_event_id), dencntrid = ce
       .encntr_id
      HEAD cea.charge_event_act_id
       hlist2 = uar_srvadditem(hlist,"charge_event_act"), srvstat = uar_srvsetdouble(hlist2,
        "charge_event_act_id",cea.charge_event_act_id), srvstat = uar_srvsetdouble(hlist2,
        "cea_type_cd",cea.cea_type_cd),
       srvstat = uar_srvsetdate(hlist2,"ceact_dt_tm",cea.service_dt_tm), srvstat = uar_srvsetdate(
        hlist2,"service_dt_tm",cea.service_dt_tm), srvstat = uar_srvsetdouble(hlist2,"service_loc_cd",
        cea.service_loc_cd),
       srvstat = uar_srvsetlong(hlist2,"quantity",cnvtint(cea.quantity)), srvstat = uar_srvsetdouble(
        hlist2,"charge_type_cd",cea.charge_type_cd), srvstat = uar_srvsetdouble(hlist2,"priority_cd",
        cea.priority_cd),
       srvstat = uar_srvsetdouble(hlist,"abn_status_cd",ce.abn_status_cd), srvstat = uar_srvsetshort(
        hlist2,"misc_ind",cea.misc_ind), srvstat = uar_srvsetdouble(hlist2,"cea_misc4_id",cea
        .cea_misc4_id),
       srvstat = uar_srvsetstring(hlist2,"cea_misc3",cea.cea_misc3), srvstat = uar_srvsetdouble(
        hlist2,"cea_misc2_id",cea.cea_misc2_id), srvstat = uar_srvsetdouble(hlist2,"cea_misc5_id",cea
        .cea_misc5_id),
       srvstat = uar_srvsetdouble(hlist2,"cea_misc6_id",cea.cea_misc6_id), srvstat = uar_srvsetdouble
       (hlist2,"cea_misc7_id",cea.cea_misc7_id), srvstat = uar_srvsetdouble(hlist2,"cea_prsnl_id",cea
        .cea_prsnl_id),
       srvstat = uar_srvsetstring(hlist2,"cea_misc1",cea.cea_misc1)
       IF (cea.service_resource_cd > 0)
        srvstat = uar_srvsetdouble(hlist2,"service_resource_cd",cea.service_resource_cd)
       ENDIF
      DETAIL
       chrgidx = locateval(idx,1,size(request->objarray,5),cea.charge_event_act_id,request->objarray[
        idx].charge_event_act_id), srvstat = uar_srvsetdouble(hlist,"loc_nurse_unit_cd",request->
        objarray[chrgidx].loc_nurse_unit_cd), srvstat = uar_srvsetdouble(hlist,"fin_class_cd",request
        ->objarray[chrgidx].fin_class_cd),
       srvstat = uar_srvsetdouble(hlist,"encntr_type_cd",request->objarray[chrgidx].encntr_type_cd),
       srvstat = uar_srvsetdouble(hlist,"health_plan_id",request->objarray[chrgidx].health_plan_id),
       srvstat = uar_srvsetdouble(hlist,"ord_loc_cd",request->objarray[chrgidx].ord_loc_cd)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM encounter e
      WHERE e.encntr_id=dencntrid
      DETAIL
       srvstat = uar_srvsetdouble(hlist,"encntr_org_id",e.organization_id)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo("Perform the request")
    SET iret = uar_crmperform(hsteprelease)
    IF (iret != 0)
     CALL echo(build("CRM Perform failed -> ",iret))
    ELSE
     CALL echo("CRM Perform successfull!")
     EXECUTE pft_log "pfmt_afc_114001", "Server CRM Perform was successfull", 3
     SET hreply = uar_crmgetreply(hsteprelease)
     IF (hreply > 0)
      SET litemcount = uar_srvgetitemcount(hreply,"charges")
      SET stat = alterlist(reply->charges,litemcount)
      CALL echo(build("lItemCount: ",litemcount))
      FOR (lloopcount = 1 TO litemcount)
        SET hlist = uar_srvgetitem(hreply,"charges",(lloopcount - 1))
        IF (validate(reply->charges[lloopcount].charge_item_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].charge_item_id = uar_srvgetdouble(hlist,"charge_item_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].charge_act_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].charge_act_id = uar_srvgetdouble(hlist,"charge_act_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].charge_event_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].charge_event_id = uar_srvgetdouble(hlist,"charge_event_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].bill_item_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].bill_item_id = uar_srvgetdouble(hlist,"bill_item_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].charge_description,null_vc_d) != null_vc_d)
         SET reply->charges[lloopcount].charge_description = uar_srvgetstringptr(hlist,
          "charge_description")
        ENDIF
        IF (validate(reply->charges[lloopcount].price_sched_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].price_sched_id = uar_srvgetdouble(hlist,"price_sched_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].payor_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].payor_id = uar_srvgetdouble(hlist,"payor_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_quantity,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_quantity = uar_srvgetdouble(hlist,"item_quantity")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_price,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_price = uar_srvgetdouble(hlist,"item_price")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_extended_price,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_extended_price = uar_srvgetdouble(hlist,
          "item_extended_price")
        ENDIF
        IF (validate(reply->charges[lloopcount].charge_type_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].charge_type_cd = uar_srvgetdouble(hlist,"charge_type_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].suspense_rsn_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].suspense_rsn_cd = uar_srvgetdouble(hlist,"suspense_rsn_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].reason_comment,null_vc_d) != null_vc_d)
         SET reply->charges[lloopcount].reason_comment = uar_srvgetstringptr(hlist,"reason_comment")
        ENDIF
        IF (validate(reply->charges[lloopcount].posted_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].posted_cd = uar_srvgetdouble(hlist,"posted_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].ord_phys_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].ord_phys_id = uar_srvgetdouble(hlist,"ord_phys_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].perf_phys_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].perf_phys_id = uar_srvgetdouble(hlist,"perf_phys_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].order_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].order_id = uar_srvgetdouble(hlist,"order_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].beg_effective_dt_tm,null_f8) != null_f8)
         CALL uar_srvgetdate(hlist,"beg_effective_dt_tm",reply->charges[lloopcount].
          beg_effective_dt_tm)
        ENDIF
        IF (validate(reply->charges[lloopcount].person_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].person_id = uar_srvgetdouble(hlist,"person_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].encntr_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].encntr_id = uar_srvgetdouble(hlist,"encntr_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].admit_type_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].admit_type_cd = uar_srvgetdouble(hlist,"admit_type_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].med_service_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].med_service_cd = uar_srvgetdouble(hlist,"med_service_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].institution_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].institution_cd = uar_srvgetdouble(hlist,"institution_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].department_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].department_cd = uar_srvgetdouble(hlist,"department_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].section_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].section_cd = uar_srvgetdouble(hlist,"section_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].subsection_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].subsection_cd = uar_srvgetdouble(hlist,"subsection_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].level5_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].level5_cd = uar_srvgetdouble(hlist,"level5_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].service_dt_tm,null_f8) != null_f8)
         CALL uar_srvgetdate(hlist,"service_dt_tm",reply->charges[lloopcount].service_dt_tm)
        ENDIF
        IF (validate(reply->charges[lloopcount].process_flg,null_i4) != null_i4)
         SET reply->charges[lloopcount].process_flg = uar_srvgetshort(hlist,"process_flg")
        ENDIF
        IF (validate(reply->charges[lloopcount].parent_charge_item_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].parent_charge_item_id = uar_srvgetdouble(hlist,
          "parent_charge_item_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].interface_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].interface_id = uar_srvgetdouble(hlist,"interface_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].tier_group_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].tier_group_cd = uar_srvgetdouble(hlist,"tier_group_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].def_bill_item_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].def_bill_item_id = uar_srvgetdouble(hlist,"def_bill_item_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].verify_phys_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].verify_phys_id = uar_srvgetdouble(hlist,"verify_phys_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].gross_price,null_f8) != null_f8)
         SET reply->charges[lloopcount].gross_price = uar_srvgetdouble(hlist,"gross_price")
        ENDIF
        IF (validate(reply->charges[lloopcount].discount_amount,null_f8) != null_f8)
         SET reply->charges[lloopcount].discount_amount = uar_srvgetdouble(hlist,"discount_amount")
        ENDIF
        IF (validate(reply->charges[lloopcount].activity_type_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].activity_type_cd = uar_srvgetdouble(hlist,"activity_type_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].research_acct_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].research_acct_id = uar_srvgetdouble(hlist,"research_acct_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].cost_center_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].cost_center_cd = uar_srvgetdouble(hlist,"cost_center_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].abn_status_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].abn_status_cd = uar_srvgetdouble(hlist,"abn_status_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].perf_loc_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].perf_loc_cd = uar_srvgetdouble(hlist,"perf_loc_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].inst_fin_nbr,null_vc_d) != null_vc_d)
         SET reply->charges[lloopcount].inst_fin_nbr = uar_srvgetstringptr(hlist,"inst_fin_nbr")
        ENDIF
        IF (validate(reply->charges[lloopcount].ord_loc_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].ord_loc_cd = uar_srvgetdouble(hlist,"ord_loc_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].fin_class_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].fin_class_cd = uar_srvgetdouble(hlist,"fin_class_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].health_plan_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].health_plan_id = uar_srvgetdouble(hlist,"health_plan_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].manual_ind,null_i4) != null_i4)
         SET reply->charges[lloopcount].manual_ind = uar_srvgetshort(hlist,"manual_ind")
        ENDIF
        IF (validate(reply->charges[lloopcount].updt_ind,null_i2) != null_i2)
         SET reply->charges[lloopcount].updt_ind = uar_srvgetshort(hlist,"updt_ind")
        ENDIF
        IF (validate(reply->charges[lloopcount].payor_type_cd,null_f8) != null_f8)
         SET reply->charges[lloopcount].payor_type_cd = uar_srvgetdouble(hlist,"payor_type_cd")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_copay,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_copay = uar_srvgetdouble(hlist,"item_copay")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_reimbursement,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_reimbursement = uar_srvgetdouble(hlist,
          "item_reimbursement")
        ENDIF
        IF (validate(reply->charges[lloopcount].posted_dt_tm,null_f8) != null_f8)
         CALL uar_srvgetdate(hlist,"posted_dt_tm",reply->charges[lloopcount].posted_dt_tm)
        ENDIF
        IF (validate(reply->charges[lloopcount].item_interval_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_interval_id = uar_srvgetdouble(hlist,"item_interval_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].list_price,null_f8) != null_f8)
         SET reply->charges[lloopcount].list_price = uar_srvgetdouble(hlist,"list_price")
        ENDIF
        IF (validate(reply->charges[lloopcount].list_pirce_sched_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].list_price_sched_id = uar_srvgetdouble(hlist,
          "list_price_sched_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].realtime_ind,null_i2) != null_i2)
         SET reply->charges[lloopcount].realtime_ind = uar_srvgetshort(hlist,"realtime_ind")
        ENDIF
        IF (validate(reply->charges[lloopcount].epsdt_ind,null_i2) != null_i2)
         SET reply->charges[lloopcount].epsdt_ind = uar_srvgetshort(hlist,"epsdt_ind")
        ENDIF
        IF (validate(reply->charges[lloopcount].ref_phys_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].ref_phys_id = uar_srvgetdouble(hlist,"ref_phys_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].alpha_nomen_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].alpha_nomen_id = uar_srvgetdouble(hlist,"alpha_nomen_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].server_process_flag,null_i2) != null_i2)
         SET reply->charges[lloopcount].server_process_flag = uar_srvgetshort(hlist,
          "server_process_flag")
        ENDIF
        IF (validate(reply->charges[lloopcount].offset_charge_item_id,null_f8) != null_f8)
         SET reply->charges[lloopcount].offset_charge_item_id = uar_srvgetdouble(hlist,
          "offset_charge_item_id")
        ENDIF
        IF (validate(reply->charges[lloopcount].item_deductible_amt,null_f8) != null_f8)
         SET reply->charges[lloopcount].item_deductible_amt = uar_srvgetdouble(hlist,
          "item_deductible_amt")
        ENDIF
        IF (validate(reply->charges[lloopcount].patient_responsibility_flag,null_i2) != null_i2)
         SET reply->charges[lloopcount].patient_responsibility_flag = uar_srvgetshort(hlist,
          "patient_responsibility_flag")
        ENDIF
        EXECUTE pft_log "pfmt_afc_114001", build("item_quantity from server: ",reply->charges[
         lloopcount].item_quantity), 3
        EXECUTE pft_log "pfmt_afc_114001", build("process_flg: ",reply->charges[lloopcount].
         process_flg), 3
        SET hlist2 = uar_srvgetstruct(hlist,"mods")
        CALL echo(build("hList2 is: ",hlist2))
        SET lmodcount = uar_srvgetitemcount(hlist2,"charge_mods")
        SET stat = alterlist(reply->charges[lloopcount].mods,lmodcount)
        CALL echo(build("lModCount: ",lmodcount))
        FOR (lmodloopcount = 1 TO lmodcount)
          SET hlist3 = uar_srvgetitem(hlist2,"charge_mods",(lmodloopcount - 1))
          SET modifierpos = locateval(idx,1,size(reply->charges[lloopcount].mods,5),
           uar_srvgetstringptr(hlist3,"field6"),reply->charges[lloopcount].mods[idx].field6,
           uar_srvgetdouble(hlist3,"field1_id"),reply->charges[lloopcount].mods[idx].field1_id)
          IF (modifierpos=0)
           SET reply->charges[lloopcount].mods[lmodloopcount].mod_id = uar_srvgetdouble(hlist3,
            "mod_id")
           SET reply->charges[lloopcount].mods[lmodloopcount].charge_event_id = uar_srvgetdouble(
            hlist3,"charge_event_id")
           SET reply->charges[lloopcount].mods[lmodloopcount].charge_mod_type_cd = uar_srvgetdouble(
            hlist3,"charge_mod_type_cd")
           SET reply->charges[lloopcount].mods[lmodloopcount].charge_event_mod_type_cd =
           uar_srvgetdouble(hlist3,"charge_event_mod_type_cd")
           SET reply->charges[lloopcount].mods[lmodloopcount].field1 = uar_srvgetstringptr(hlist3,
            "field1")
           SET reply->charges[lloopcount].mods[lmodloopcount].field2 = uar_srvgetstringptr(hlist3,
            "field2")
           SET reply->charges[lloopcount].mods[lmodloopcount].field3 = uar_srvgetstringptr(hlist3,
            "field3")
           SET reply->charges[lloopcount].mods[lmodloopcount].field4 = uar_srvgetstringptr(hlist3,
            "field4")
           SET reply->charges[lloopcount].mods[lmodloopcount].field5 = uar_srvgetstringptr(hlist3,
            "field5")
           SET reply->charges[lloopcount].mods[lmodloopcount].field6 = uar_srvgetstringptr(hlist3,
            "field6")
           SET reply->charges[lloopcount].mods[lmodloopcount].field7 = uar_srvgetstringptr(hlist3,
            "field7")
           SET reply->charges[lloopcount].mods[lmodloopcount].field1_id = uar_srvgetdouble(hlist3,
            "field1_id")
           SET reply->charges[lloopcount].mods[lmodloopcount].field2_id = uar_srvgetdouble(hlist3,
            "field2_id")
           SET reply->charges[lloopcount].mods[lmodloopcount].field3_id = uar_srvgetdouble(hlist3,
            "field3_id")
           SET reply->charges[lloopcount].mods[lmodloopcount].cm1_nbr = uar_srvgetdouble(hlist3,
            "cm1_nbr")
           IF (validate(reply->charges[lloopcount].mods[lmodloopcount].charge_mod_source_cd) > 0)
            SET reply->charges[lloopcount].mods[lmodloopcount].charge_mod_source_cd =
            uar_srvgetdouble(hlist3,"charge_mod_source_cd")
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ELSE
      CALL echo("Could not get reply")
     ENDIF
     IF (requesthaschargeitemid=true
      AND validate(request->objarray[1].charge_event_act_id,0) > 0)
      DECLARE chargemodcount = i4 WITH noconstant(0)
      DECLARE chargemodidx = i4 WITH noconstant(0)
      DECLARE chargeidx = i4 WITH noconstant(0)
      DECLARE existingmodifieridx = i4 WITH noconstant(0)
      DECLARE replyidx = i4 WITH noconstant(0)
      DECLARE impactedchargecnt = i4 WITH noconstant(0)
      DECLARE impactedchargeidx = i4 WITH noconstant(0)
      DECLARE impactedchargepos = i4 WITH noconstant(0)
      IF (validate(debug,- (1)) > 0)
       CALL echo("Copying Manually Added Modifiers")
      ENDIF
      SELECT INTO "nl:"
       FROM charge c,
        charge_mod cm,
        dummyt d1
       PLAN (c
        WHERE expand(idx,1,size(request->objarray,5),c.charge_item_id,validate(request->objarray[idx]
          .charge_item_id,- (1.0)))
         AND c.charge_item_id > 0.0)
        JOIN (cm
        WHERE cm.charge_item_id=c.charge_item_id
         AND cm.active_ind=1
         AND cm.charge_mod_type_cd=cs13019_billcode_cd
         AND cm.charge_mod_source_cd=cs4518006_manually_added_cd)
        JOIN (d1
        WHERE uar_get_code_meaning(cm.field1_id)="MODIFIER")
       ORDER BY c.charge_item_id
       HEAD c.charge_item_id
        chargemodcount = 0, replyidx = locateval(chargeidx,1,size(reply->charges,5),c.charge_event_id,
         validate(reply->charges[chargeidx].charge_event_id,- (1.0)),
         c.charge_event_act_id,validate(reply->charges[chargeidx].charge_act_id,- (1.0)),c
         .bill_item_id,validate(reply->charges[chargeidx].bill_item_id,- (1.0)),c.tier_group_cd,
         validate(reply->charges[chargeidx].tier_group_cd,- (1.0)),c.item_interval_id,validate(reply
          ->charges[chargeidx].item_interval_id,- (1.0)))
        IF (replyidx > 0)
         chargemodcount = size(reply->charges[replyidx].mods,5)
        ENDIF
       DETAIL
        IF (replyidx > 0)
         IF (impactedchargecnt=0)
          impactedchargecnt += 1, stat = alterlist(impactedchargeindexlist->indexes,impactedchargecnt
           ), impactedchargeindexlist->indexes[impactedchargecnt].charge_index = replyidx
         ELSE
          impactedchargepos = locateval(impactedchargeidx,1,size(impactedchargeindexlist->indexes,5),
           replyidx,impactedchargeindexlist->indexes[impactedchargeidx].charge_index)
          IF (impactedchargepos=0)
           impactedchargecnt += 1, stat = alterlist(impactedchargeindexlist->indexes,
            impactedchargecnt), impactedchargeindexlist->indexes[impactedchargecnt].charge_index =
           replyidx
          ENDIF
         ENDIF
         existingmodifieridx = locateval(chargemodidx,1,size(reply->charges[replyidx].mods,5),cm
          .field6,validate(reply->charges[replyidx].mods[chargemodidx].field6,null),
          "MODIFIER",uar_get_code_meaning(validate(reply->charges[replyidx].mods[chargemodidx].
            field1_id,- (1.0))))
         IF (existingmodifieridx=0)
          chargemodcount += 1, stat = alterlist(reply->charges[replyidx].mods,chargemodcount), stat
           = assign(validate(reply->charges[replyidx].mods[chargemodcount].charge_mod_type_cd),cm
           .charge_mod_type_cd),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].charge_mod_source_cd),
           cm.charge_mod_source_cd), stat = assign(validate(reply->charges[replyidx].mods[
            chargemodcount].field1),cm.field1), stat = assign(validate(reply->charges[replyidx].mods[
            chargemodcount].field2),cm.field2),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field3),cm.field3),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field4),cm.field4),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field5),cm.field5),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field6),cm.field6),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field7),cm.field7),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field8),cm.field8),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field9),cm.field9),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field10),cm.field10),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field1_id),cm
           .field1_id),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field2_id),cm
           .field2_id), stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].
            field3_id),cm.field3_id), stat = assign(validate(reply->charges[replyidx].mods[
            chargemodcount].field4_id),cm.field4_id),
          stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].field5_id),cm
           .field5_id), stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].nomen_id
            ),cm.nomen_id), stat = assign(validate(reply->charges[replyidx].mods[chargemodcount].
            cm1_nbr),cm.cm1_nbr)
         ELSE
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].
            charge_mod_type_cd),cm.charge_mod_type_cd), stat = assign(validate(reply->charges[
            replyidx].mods[existingmodifieridx].charge_mod_source_cd),cm.charge_mod_source_cd), stat
           = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field1),cm.field1),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field2),cm.field2
           ), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field3),cm
           .field3), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field4
            ),cm.field4),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field5),cm.field5
           ), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field6),cm
           .field6), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field7
            ),cm.field7),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field8),cm.field8
           ), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field9),cm
           .field9), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].
            field10),cm.field10),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field1_id),cm
           .field1_id), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].
            field2_id),cm.field2_id), stat = assign(validate(reply->charges[replyidx].mods[
            existingmodifieridx].field3_id),cm.field3_id),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].field4_id),cm
           .field4_id), stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].
            field5_id),cm.field5_id), stat = assign(validate(reply->charges[replyidx].mods[
            existingmodifieridx].nomen_id),cm.nomen_id),
          stat = assign(validate(reply->charges[replyidx].mods[existingmodifieridx].cm1_nbr),cm
           .cm1_nbr)
         ENDIF
        ENDIF
       WITH nocounter, expand = 2
      ;end select
      IF (validate(debug,- (1)) > 0)
       CALL echo("Reply Prior to Sorting")
       CALL echorecord(reply)
       CALL echo("ImpactedChargeIndexList Contents")
       CALL echorecord(impactedchargeindexlist)
      ENDIF
      FOR (chargeloop = 1 TO size(reply->charges,5))
        DECLARE tempmodcount = i4 WITH noconstant(0)
        DECLARE num = i4 WITH noconstant(0)
        DECLARE modifiercnt = i4 WITH noconstant(0)
        DECLARE cptpriority = f8 WITH noconstant(0)
        DECLARE cnt = i4
        DECLARE modcnt = i4
        DECLARE manuallyaddedcnt = i4
        IF (impactedchargecnt > 0)
         SET impactedchargepos = locateval(impactedchargeidx,1,size(impactedchargeindexlist->indexes,
           5),chargeloop,impactedchargeindexlist->indexes[impactedchargeidx].charge_index)
        ENDIF
        IF (impactedchargecnt > 0
         AND impactedchargepos > 0)
         SET stat = copyrec(reply,temprec,0)
         SELECT INTO "nl:"
          sortval = evaluate(uar_get_code_meaning(validate(reply->charges[chargeloop].mods[d1.seq].
             charge_mod_source_cd,- (1.0))),"COPYFROMCEM",1,"MANUALLY_ADD",2,
           "REF_DATA",3,4)
          FROM (dummyt d1  WITH seq = value(size(reply->charges[chargeloop].mods,5)))
          PLAN (d1)
          ORDER BY sortval
          HEAD REPORT
           stat = alterlist(temprec->charges,1), stat = alterlist(temprec->charges[1].mods,size(reply
             ->charges[chargeloop].mods,5)), tempmodcount = 0
          DETAIL
           tempmodcount += 1, stat = assign(validate(temprec->charges[1].mods[tempmodcount].mod_id),
            validate(reply->charges[chargeloop].mods[d1.seq].mod_id,0.0)), stat = assign(validate(
             temprec->charges[1].mods[tempmodcount].charge_event_id),validate(reply->charges[
             chargeloop].mods[d1.seq].charge_event_id,0.0)),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].charge_event_mod_type_cd),
            validate(reply->charges[chargeloop].mods[d1.seq].charge_event_mod_type_cd,0.0)), stat =
           assign(validate(temprec->charges[1].mods[tempmodcount].charge_mod_type_cd),validate(reply
             ->charges[chargeloop].mods[d1.seq].charge_mod_type_cd,0.0)), stat = assign(validate(
             temprec->charges[1].mods[tempmodcount].charge_mod_source_cd),validate(reply->charges[
             chargeloop].mods[d1.seq].charge_mod_source_cd,0.0)),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field1),validate(reply->
             charges[chargeloop].mods[d1.seq].field1,"")), stat = assign(validate(temprec->charges[1]
             .mods[tempmodcount].field2),validate(reply->charges[chargeloop].mods[d1.seq].field2,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field3),validate(reply->
             charges[chargeloop].mods[d1.seq].field3,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field4),validate(reply->
             charges[chargeloop].mods[d1.seq].field4,"")), stat = assign(validate(temprec->charges[1]
             .mods[tempmodcount].field5),validate(reply->charges[chargeloop].mods[d1.seq].field5,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field6),validate(reply->
             charges[chargeloop].mods[d1.seq].field6,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field7),validate(reply->
             charges[chargeloop].mods[d1.seq].field7,"")), stat = assign(validate(temprec->charges[1]
             .mods[tempmodcount].field8),validate(reply->charges[chargeloop].mods[d1.seq].field8,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field9),validate(reply->
             charges[chargeloop].mods[d1.seq].field9,"")),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field10),validate(reply->
             charges[chargeloop].mods[d1.seq].field10,"")), stat = assign(validate(temprec->charges[1
             ].mods[tempmodcount].field1_id),validate(reply->charges[chargeloop].mods[d1.seq].
             field1_id,0.0)), stat = assign(validate(temprec->charges[1].mods[tempmodcount].field2_id
             ),validate(reply->charges[chargeloop].mods[d1.seq].field2_id,0.0)),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].field3_id),validate(reply->
             charges[chargeloop].mods[d1.seq].field3_id,0.0)), stat = assign(validate(temprec->
             charges[1].mods[tempmodcount].field4_id),validate(reply->charges[chargeloop].mods[d1.seq
             ].field4_id,0.0)), stat = assign(validate(temprec->charges[1].mods[tempmodcount].
             field5_id),validate(reply->charges[chargeloop].mods[d1.seq].field5_id,0.0)),
           stat = assign(validate(temprec->charges[1].mods[tempmodcount].nomen_id),validate(reply->
             charges[chargeloop].mods[d1.seq].nomen_id,0.0)), stat = assign(validate(temprec->
             charges[1].mods[tempmodcount].cm1_nbr),validate(reply->charges[chargeloop].mods[d1.seq].
             cm1_nbr,0.0))
          WITH nocounter
         ;end select
         IF (size(temprec->charges[1].mods,5) > 0)
          SET stat = movereclist(temprec->charges[1].mods,reply->charges[chargeloop].mods,1,1,size(
            temprec->charges[1].mods,5),
           0)
          IF (validate(debug,- (1)) > 0)
           CALL echo("Reply After Sorting")
           CALL echorecord(reply)
          ENDIF
         ENDIF
         FREE RECORD temprec
        ENDIF
        SET stat = alterlist(modifiers->qual,size(reply->charges[chargeloop].mods,5))
        SET modifiercnt = 0
        FOR (modloop = 1 TO size(reply->charges[chargeloop].mods,5))
          IF (uar_get_code_meaning(reply->charges[chargeloop].mods[modloop].field1_id)="MODIFIER")
           SET modifiercnt += 1
           SET modifiers->qual[modifiercnt].field1_id = reply->charges[chargeloop].mods[modloop].
           field1_id
           SET modifiers->qual[modifiercnt].field2_id = reply->charges[chargeloop].mods[modloop].
           field2_id
           SET modifiers->qual[modifiercnt].field6 = reply->charges[chargeloop].mods[modloop].field6
           SET modifiers->qual[modifiercnt].field3_id = reply->charges[chargeloop].mods[modloop].
           field3_id
           SET modifiers->qual[modifiercnt].field_value = 0
           SET modifiers->qual[modifiercnt].charge_mod_source_cd = validate(reply->charges[chargeloop
            ].mods[modloop].charge_mod_source_cd,0.0)
          ENDIF
        ENDFOR
        SET stat = alterlist(modifiers->qual,modifiercnt)
        IF (size(modifiers->qual,5) > 0)
         SELECT INTO "nl:"
          FROM code_value_extension cve
          WHERE expand(num,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[num].field3_id)
           AND cnvtupper(cve.field_name)="PRICE MODIFIER"
           AND cve.code_set=17769
          HEAD REPORT
           mod_idx = 0, mod_cnt = 0
          DETAIL
           IF (cnvtint(trim(cve.field_value,7))=1)
            mod_idx = locateval(mod_cnt,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[
             mod_cnt].field3_id), modifiers->qual[mod_idx].field_value = cnvtint(trim(cve.field_value,
              7))
           ENDIF
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          orderbypriority = evaluate(modifiers->qual[d.seq].charge_mod_source_cd,
           cs4518006_manually_added_cd,1,cs4518006_copyfromcem_cd,evaluate2(
            IF ((modifiers->qual[d.seq].field_value=1)) 2
            ELSE 4
            ENDIF
            ),
           0.0,evaluate2(
            IF ((modifiers->qual[d.seq].field_value=1)) 2
            ELSE 4
            ENDIF
            ),cs4518006_ref_data_cd,evaluate2(
            IF ((modifiers->qual[d.seq].field_value=1)) 3
            ELSE 5
            ENDIF
            ),6)
          FROM (dummyt d  WITH seq = value(size(modifiers->qual,5)))
          PLAN (d)
          ORDER BY orderbypriority, modifiers->qual[d.seq].field2_id
          HEAD REPORT
           cptpriority = 0, manuallyaddedcnt = 0
          DETAIL
           IF (orderbypriority=1)
            manuallyaddedcnt += 1, stat = alterlist(priorities->qual,manuallyaddedcnt), priorities->
            qual[manuallyaddedcnt].modpriority = modifiers->qual[d.seq].field2_id
           ELSE
            cptpriority += 1, pos = 1
            WHILE (pos != 0)
             pos = locateval(cnt,1,manuallyaddedcnt,cptpriority,priorities->qual[cnt].modpriority),
             IF (pos > 0)
              cptpriority += 1
             ENDIF
            ENDWHILE
            modpos = locateval(modcnt,1,size(reply->charges[chargeloop].mods,5),modifiers->qual[d.seq
             ].field6,reply->charges[chargeloop].mods[modcnt].field6,
             modifiers->qual[d.seq].field1_id,reply->charges[chargeloop].mods[modcnt].field1_id,
             modifiers->qual[d.seq].field3_id,reply->charges[chargeloop].mods[modcnt].field3_id)
            IF (modpos > 0)
             reply->charges[chargeloop].mods[modpos].field2_id = cptpriority
            ENDIF
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    CALL uar_crmendreq(hsteprelease)
    CALL uar_crmendtask(htaskrelease)
    CALL uar_crmendapp(happrelease)
   ENDIF
  ENDIF
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo("Final Reply")
  CALL echorecord(reply)
 ENDIF
#exit_script
END GO
