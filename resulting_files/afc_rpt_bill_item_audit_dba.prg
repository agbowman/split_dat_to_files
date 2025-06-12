CREATE PROGRAM afc_rpt_bill_item_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email Address" = "",
  "Effective Date(mmddyy)" = "CURDATE",
  "Audit Mode" = "1",
  "Organizations To Include" = "",
  "Activity Type(s) To Include" = 0,
  "Schedule Type(s) To Include" = ""
  WITH outdev, email_to, eff_date,
  audit_mode, userorgs, act_type,
  sch_types
 EXECUTE ccl_prompt_api_dataset "all"
 CALL parsecommandline(null)
 DECLARE afc_rft_bill_item_audit_version = vc WITH private, constant("CHARGSRV-9205.005")
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
 DECLARE hi18n = i4 WITH noconstant(0)
 CALL uar_i18nlocalizationinit(hi18n,curprog," ",curcclrev)
 FREE SET t_where
 RECORD t_where(
   1 qual_cnt = i4
   1 qual[*]
     2 where_clause = vc
 )
 DECLARE report_data_temp_table = vc WITH protect, noconstant(" ")
 DECLARE enum_column_type_date = i2 WITH protect, constant(true)
 DECLARE enum_column_type_string = i2 WITH protect, constant(2)
 DECLARE enum_column_type_number = i2 WITH protect, constant(3)
 DECLARE enum_column_type_datetm = i2 WITH protect, constant(4)
 FREE RECORD table_rec
 RECORD table_rec(
   1 tbl_cnt = i4
   1 max_priority = i2
   1 error_ind = i2
   1 tbl_list[*]
     2 tbl_name = vc
     2 tbl_alias = vc
     2 tbl_priority = i2
     2 tbl_priority_ind = i2
     2 add_default_where_clause_ind = i2
     2 tbl_where_clause_cnt = i4
     2 tbl_where_clause[*]
       3 where_clause = vc
     2 tbl_added_to_from_clause = i2
     2 tbl_added_to_join_path = i2
   1 tbl_aggr_functions_cnt = i4
   1 tbl_aggr_functions[*]
     2 aggregate_function = vc
   1 tbl_group_by_fields_cnt = i4
   1 tbl_group_by_fields[*]
     2 group_by_field = vc
   1 tbl_order_by_fields_cnt = i4
   1 tbl_order_by_fields[*]
     2 order_by_field = vc
 )
 FREE RECORD export_reply
 RECORD export_reply(
   1 column_cnt = i4
   1 column[*]
     2 column_name = vc
     2 column_heading = vc
     2 column_type = i2
 )
 IF (validate(showquery,char(128))=char(128))
  SUBROUTINE (showquery(s_null_index=i2) =null)
    CALL echorecord(t_where)
  END ;Subroutine
 ENDIF
 IF (validate(definereporttemptable,char(128))=char(128))
  SUBROUTINE (definereporttemptable(s_table_name=vc) =null)
    SET report_data_temp_table = cnvtupper(trim(s_table_name,3))
  END ;Subroutine
 ENDIF
 IF (validate(usingreporttemptable,char(128))=char(128))
  SUBROUTINE (usingreporttemptable(s_null_index=i2) =i2)
    IF (size(trim(report_data_temp_table,3),1) > 0)
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(perform_query,char(128))=char(128))
  SUBROUTINE (perform_query(s_null_index=i2) =null)
   DECLARE rec_cnt = i4 WITH private, noconstant(0)
   FOR (rec_cnt = 1 TO t_where->qual_cnt)
    CALL parser(t_where->qual[rec_cnt].where_clause,1)
    IF (validate(debug,0)=1)
     CALL echo(t_where->qual[rec_cnt].where_clause)
    ENDIF
   ENDFOR
  END ;Subroutine
 ENDIF
 IF (validate(gettemptableselect,char(128))=char(128))
  SUBROUTINE (gettemptableselect(s_null_index=i2) =vc)
    DECLARE rec_cnt = i4 WITH private, noconstant(0)
    DECLARE tablequery = vc WITH protect, noconstant(" ")
    CALL echorecord(t_where)
    FOR (rec_cnt = 1 TO t_where->qual_cnt)
     SET tablequery = build2(tablequery," ",t_where->qual[rec_cnt].where_clause)
     IF (validate(debug,0)=1)
      CALL echo(t_where->qual[rec_cnt].where_clause)
     ENDIF
    ENDFOR
    RETURN(tablequery)
  END ;Subroutine
 ENDIF
 IF (validate(performtemptableinsert,char(128))=char(128))
  SUBROUTINE (performtemptableinsert(insertstatement=vc,selectfields=vc) =null)
    DECLARE tableinsert = vc WITH protect, noconstant(" ")
    DECLARE selectstatement = vc WITH protect, noconstant(" ")
    SET selectstatement = gettemptableselect(0)
    SET tableinsert = build2(insertstatement,"(select ",selectfields," ",selectstatement,
     ") go")
    CALL parser(tableinsert,1)
    IF (validate(debug,0)=1)
     CALL echo(tableinsert)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(performtemptableinsertwithorahint,char(128))=char(128))
  SUBROUTINE (performtemptableinsertwithorahint(insertstatement=vc,selectfields=vc,hintstatement=vc
   ) =null)
    DECLARE tableinsert = vc WITH protect, noconstant(" ")
    DECLARE selectstatement = vc WITH protect, noconstant(" ")
    SET selectstatement = gettemptableselect(0)
    SET tableinsert = build2(insertstatement,"(select ",selectfields," ",selectstatement,
     " ","with"," ",hintstatement,")go")
    CALL parser(tableinsert,1)
    IF (validate(debug,0)=1)
     CALL echo(tableinsert)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(free_query,char(128))=char(128))
  SUBROUTINE (free_query(s_null_index=i2) =null)
    SET stat = initrec(t_where)
  END ;Subroutine
 ENDIF
 IF (validate(add_where,char(128))=char(128))
  SUBROUTINE (add_where(new_line=vc) =null)
    SET t_where->qual_cnt += 1
    SET stat = alterlist(t_where->qual,t_where->qual_cnt)
    SET t_where->qual[t_where->qual_cnt].where_clause = trim(new_line,3)
  END ;Subroutine
 ENDIF
 IF (validate(add_default_where_clause,char(128))=char(128))
  SUBROUTINE (add_default_where_clause(tbl_alias=vc) =null)
    IF (trim(tbl_alias,3) != "")
     CALL add_where(concat("AND ",tbl_alias,".active_ind+0 = 1"))
     CALL add_where(concat("AND ",tbl_alias,
       ".beg_effective_dt_tm+0 <= cnvtdatetime(curdate, curtime3)"))
     CALL add_where(concat("AND ",tbl_alias,
       ".end_effective_dt_tm+0 > cnvtdatetime(curdate, curtime3)"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(parsedateargument,char(128))=char(128))
  SUBROUTINE (parsedateargument(my_date_arg=vc) =i4)
    DECLARE my_return_date = i4 WITH private, noconstant(0)
    IF (my_date_arg=cnvtupper("YESTERDAY"))
     SET my_return_date = (cnvtdate(cnvtdatetime(curdate,0)) - 1)
    ELSEIF (my_date_arg=cnvtupper("TODAY"))
     SET my_return_date = cnvtdate(cnvtdatetime(curdate,0))
    ELSE
     SET my_return_date = cnvtdate(cnvtint(my_date_arg))
    ENDIF
    IF (my_return_date <= 0)
     SET my_return_date = curdate
    ENDIF
    RETURN(my_return_date)
  END ;Subroutine
 ELSE
  CALL echo("*_*_* parsedate not valid *_*_*")
 ENDIF
 IF (validate(parsearguments,char(128))=char(128))
  SUBROUTINE (parsearguments(arg_nbr=i2,arg_rec=vc(ref),arg_data_type=vc) =null)
    DECLARE arg_list_cnt = i4 WITH private, noconstant(0)
    DECLARE cur_arg = i4 WITH private, noconstant(0)
    DECLARE arg_value = vc WITH private, noconstant("")
    DECLARE arg_type = vc WITH private, noconstant("")
    SET arg_list_cnt = getargumentlistcount(arg_nbr)
    IF (arg_list_cnt > 1)
     SET stat = alterlist(arg_rec->objarray,arg_list_cnt)
     SET arg_rec->arg_value_list_cnt = arg_list_cnt
    ELSE
     SET stat = alterlist(arg_rec->objarray,1)
     SET arg_rec->arg_value_list_cnt = 1
    ENDIF
    FOR (cur_arg = 1 TO arg_rec->arg_value_list_cnt)
      IF ((arg_rec->arg_value_list_cnt=1))
       SET arg_value = getargumentvalue(arg_nbr)
       SET arg_type = getargumenttype(arg_nbr)
      ELSE
       SET arg_value = getargumentlistitemvalue(arg_nbr,cur_arg)
       SET arg_type = getargumentlistitemtype(arg_nbr,cur_arg)
      ENDIF
      IF (validate(debug,0)=1)
       CALL echo(build("Arg_Value: ",arg_value))
      ENDIF
      IF (cnvtupper(trim(arg_value,3)) != "ALL"
       AND trim(arg_value,3) != "")
       CASE (arg_data_type)
        OF "I4":
         SET arg_rec->objarray[cur_arg].iarg_value = cnvtint(arg_value)
        OF "F8":
         SET arg_rec->objarray[cur_arg].darg_value = cnvtreal(arg_value)
        OF "VC":
         SET arg_rec->objarray[cur_arg].sarg_value = arg_value
        ELSE
         CALL echo(build("Unable to determine data type: ",arg_data_type))
         CALL echo("Search for All...")
         SET cur_arg = arg_rec->arg_value_list_cnt
         SET stat = initrec(arg_rec)
       ENDCASE
      ELSE
       CALL echo("Search for All...")
       SET cur_arg = arg_rec->arg_value_list_cnt
       SET stat = initrec(arg_rec)
      ENDIF
    ENDFOR
    IF (validate(debug,0)=1)
     CALL echorecord(arg_rec)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(create_in_clause,char(128))=char(128))
  SUBROUTINE (create_in_clause(data_type=vc,arg_rec=vc(ref),allow_zero_ind=i2) =vc)
    DECLARE in_clause = vc WITH private, noconstant("")
    DECLARE in_clause_ind = i2 WITH private, noconstant(false)
    DECLARE rec_list_cnt = i4 WITH private, noconstant(0)
    IF (validate(debug,0)=1)
     IF (allow_zero_ind=true)
      CALL echo("Zero or zero length values can be included in the IN clause (If Applicable)")
     ELSE
      CALL echo("Zero or zero length values will not be included in the IN clause (If Applicable)")
     ENDIF
    ENDIF
    FOR (rec_list_cnt = 1 TO arg_rec->arg_value_list_cnt)
      CASE (data_type)
       OF "F8":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].darg_value > 0.0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,19,2)
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,
            19,2))
         ENDIF
        ENDIF
       OF "I4":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].iarg_value > 0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,19)
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,
            19))
         ENDIF
        ENDIF
       OF "VC":
        IF (((allow_zero_ind=false
         AND trim(arg_rec->objarray[rec_list_cnt].sarg_value,3) != "") OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = concat('"',arg_rec->objarray[rec_list_cnt].sarg_value,'"')
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",'"',arg_rec->objarray[rec_list_cnt].sarg_value,'"')
         ENDIF
        ENDIF
       ELSE
        CALL echo(build("Unknown Data Type: ",data_type))
        RETURN("")
      ENDCASE
    ENDFOR
    RETURN(in_clause)
  END ;Subroutine
 ENDIF
 IF (validate(create_in_clause_grt_than1000,char(128))=char(128))
  SUBROUTINE (create_in_clause_grt_than1000(data_type=vc,arg_rec=vc(ref),allow_zero_ind=i2,attribute=
   vc) =vc)
    DECLARE in_clause = vc WITH noconstant("")
    DECLARE in_clause_ind = i2 WITH private, noconstant(false)
    DECLARE rec_list_cnt = i4 WITH private, noconstant(0)
    DECLARE in_clause_limt_cnt = i4 WITH private, noconstant(0)
    IF (validate(debug,0)=1)
     IF (allow_zero_ind=true)
      CALL echo("Zero or zero length values can be included in the IN clause (If Applicable)")
     ELSE
      CALL echo("Zero or zero length values will not be included in the IN clause (If Applicable)")
     ENDIF
    ENDIF
    SET in_clause = concat("(",attribute," IN (")
    SET in_clause_limt_cnt = 1
    FOR (rec_list_cnt = 1 TO arg_rec->arg_value_list_cnt)
      IF (in_clause_limt_cnt > 1000)
       SET in_clause = concat(in_clause,") OR ",attribute," IN (")
       SET in_clause_limt_cnt = 1
       SET in_clause_ind = false
      ENDIF
      CASE (data_type)
       OF "F8":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].darg_value > 0.0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = concat(in_clause,cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,19,2
            ))
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,
            19,2))
         ENDIF
        ENDIF
       OF "I4":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].iarg_value > 0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = concat(in_clause,cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,19))
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,
            19))
         ENDIF
        ENDIF
       OF "VC":
        IF (((allow_zero_ind=false
         AND trim(arg_rec->objarray[rec_list_cnt].sarg_value,3) != "") OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = concat(in_clause,'"',arg_rec->objarray[rec_list_cnt].sarg_value,'"')
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",'"',arg_rec->objarray[rec_list_cnt].sarg_value,'"')
         ENDIF
        ENDIF
       ELSE
        CALL echo(build("Unknown Data Type: ",data_type))
        RETURN("")
      ENDCASE
      SET in_clause_limt_cnt += 1
    ENDFOR
    SET in_clause = concat(in_clause,"))")
    RETURN(in_clause)
  END ;Subroutine
 ENDIF
 IF (validate(getdeliverysystem,char(128))=char(128))
  SUBROUTINE (getdeliverysystem(dummy=i2) =vc)
    DECLARE ds_name = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM delivery_system ds,
      billing_entity be
     PLAN (ds
      WHERE ds.active_ind=1
       AND ds.billing_entity_id > 0.0
       AND ds.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ds.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (be
      WHERE be.billing_entity_id=ds.billing_entity_id
       AND be.active_ind=1
       AND be.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND be.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      ds_name = trim(be.be_name,3)
     WITH nocounter
    ;end select
    IF (ds_name="")
     CALL echo("Unable to retrieve the default delivery system's name")
    ELSE
     CALL echo(build("Delivery System Name: ",ds_name))
    ENDIF
    RETURN(ds_name)
  END ;Subroutine
 ENDIF
 IF (validate(create_filter_list,char(128))=char(128))
  SUBROUTINE (create_filter_list(data_type=vc,arg_rec=vc(ref),allow_zero_ind=i2,dimension_name=vc,
   filter_title=vc) =vc)
    DECLARE in_clause = vc WITH private, noconstant("")
    DECLARE in_clause_ind = i2 WITH private, noconstant(false)
    DECLARE rec_list_cnt = i4 WITH private, noconstant(0)
    DECLARE arg_list_cnt = i4 WITH private, noconstant(0)
    DECLARE cur_arg = i4 WITH private, noconstant(0)
    DECLARE arg_value = vc WITH private, noconstant("")
    DECLARE arg_type = vc WITH private, noconstant("")
    DECLARE all_ind = i2 WITH private, noconstant(true)
    DECLARE def_ds_idx = i4 WITH private, noconstant(0)
    DECLARE def_ds_cnt = i4 WITH private, noconstant(0)
    IF (validate(debug,0)=1)
     IF (allow_zero_ind=true)
      CALL echo("Zero or zero length values can be included in the IN clause (If Applicable)")
     ELSE
      CALL echo("Zero or zero length values will not be included in the IN clause (If Applicable)")
     ENDIF
    ENDIF
    IF ((arg_rec->arg_value_list_cnt > 0))
     SET all_ind = false
    ENDIF
    IF (all_ind=false)
     CASE (cnvtupper(dimension_name))
      OF "ENCOUNTER_TYPE":
       FOR (x = 1 TO arg_rec->arg_value_list_cnt)
         IF (trim(arg_rec->objarray[x].sarg_value,3)="")
          SET arg_rec->objarray[x].sarg_value = "Unassigned Encounter Type"
         ENDIF
       ENDFOR
      OF "BILLING_ENTITY":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_billing_entity be
        PLAN (d)
         JOIN (be
         WHERE (be.rc_d_billing_entity_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Billing Entity"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = be.billing_entity_name
         ENDIF
        WITH nocounter
       ;end select
       SET def_ds_idx = locateval(def_ds_cnt,1,arg_rec->arg_value_list_cnt,- (99.99),arg_rec->
        objarray[def_ds_cnt].darg_value)
       IF (def_ds_idx > 0)
        SET arg_rec->objarray[def_ds_idx].sarg_value = getdeliverysystem(0)
       ENDIF
      OF "BENTITY":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         billing_entity be
        PLAN (d)
         JOIN (be
         WHERE (be.billing_entity_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = trim(be.be_name,3)
        WITH nocounter
       ;end select
      OF "EXTRACT_ENTITY":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         dem_xtrct dx,
         code_value cv
        PLAN (d)
         JOIN (dx
         WHERE (dx.xtrct_type_cd=arg_rec->objarray[d.seq].darg_value))
         JOIN (cv
         WHERE dx.xtrct_type_cd=cv.code_value)
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Entity"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = cv.display
         ENDIF
        WITH nocounter
       ;end select
      OF "FINANCIAL_CLASS":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_financial_class fc
        PLAN (d)
         JOIN (fc
         WHERE (fc.rc_d_financial_class_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Financial Class"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = fc.financial_class
         ENDIF
        WITH nocounter
       ;end select
      OF "FINANCIAL_CLASS_CD":
       FOR (x = 1 TO arg_rec->arg_value_list_cnt)
         IF ((arg_rec->objarray[x].darg_value=0))
          SET arg_rec->objarray[x].sarg_value = "Unassigned Financial Class"
         ENDIF
       ENDFOR
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         code_value cv
        PLAN (d)
         JOIN (cv
         WHERE (cv.code_value=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = cv.display
        WITH nocounter
       ;end select
      OF "HEALTH_PLAN":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_health_plan hp
        PLAN (d)
         JOIN (hp
         WHERE (hp.rc_d_health_plan_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Health_Plan"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = hp.health_plan_name
         ENDIF
        WITH nocounter
       ;end select
      OF "MEDICAL_SERVICE":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_medical_service ms
        PLAN (d)
         JOIN (ms
         WHERE (ms.rc_d_medical_service_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Medical Service"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = ms.medical_service
         ENDIF
        WITH nocounter
       ;end select
      OF "FACILITY":
      OF "BUILDING":
      OF "LOCATION":
       FOR (x = 1 TO arg_rec->arg_value_list_cnt)
         IF (trim(arg_rec->objarray[x].sarg_value,3)="")
          SET arg_rec->objarray[x].sarg_value = "Unassigned Patient Location"
         ENDIF
       ENDFOR
      OF "FACILITY_CD":
      OF "BUILDING_CD":
      OF "LOCATION_CD":
       FOR (x = 1 TO arg_rec->arg_value_list_cnt)
         IF ((arg_rec->objarray[x].darg_value=0))
          SET arg_rec->objarray[x].sarg_value = "Unassigned Patient Location"
         ENDIF
       ENDFOR
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         code_value cv
        PLAN (d)
         JOIN (cv
         WHERE (cv.code_value=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = cv.display
        WITH nocounter
       ;end select
      OF "ENCOUNTER_CLASS":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_encntr_type_class etc
        PLAN (d)
         JOIN (etc
         WHERE (((etc.rc_d_encntr_type_class_id=arg_rec->objarray[d.seq].darg_value)) OR ((etc
         .encounter_class=arg_rec->objarray[d.seq].sarg_value))) )
        DETAIL
         IF (etc.encounter_class IN ("Inpatient", "Skilled Nursing"))
          arg_rec->objarray[d.seq].sarg_value = "Inpatient"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = "Outpatient"
         ENDIF
        WITH nocounter
       ;end select
      OF "COST_CENTER":
       FOR (x = 1 TO arg_rec->arg_value_list_cnt)
         IF (trim(arg_rec->objarray[x].sarg_value,3)="")
          SET arg_rec->objarray[x].sarg_value = "Unassigned Cost Center"
         ENDIF
       ENDFOR
      OF "CHARGE_TYPE":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_tier_group t
        PLAN (d)
         JOIN (t
         WHERE (t.rc_d_tier_group_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Charge Type"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = t.tier_group_name
         ENDIF
        WITH nocounter
       ;end select
      OF "ROUND":
       IF (trim(arg_rec->objarray[1].sarg_value,3)="1")
        SET arg_rec->objarray[1].sarg_value = "Yes"
       ELSE
        SET arg_rec->objarray[1].sarg_value = "No"
       ENDIF
      OF "SUPERVISOR":
      OF "REPRESENTATIVE":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         person p
        PLAN (d)
         JOIN (p
         WHERE (p.person_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = trim(p.name_full_formatted,3)
        WITH nocounter
       ;end select
      OF "ACTCODE":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         code_value cv,
         code_value_extension cve,
         pft_wf_issue pwi
        PLAN (d)
         JOIN (cv
         WHERE (cv.code_value=arg_rec->objarray[d.seq].darg_value)
          AND cv.active_ind=1)
         JOIN (cve
         WHERE (cve.code_value= Outerjoin(cv.code_value))
          AND (cve.field_name= Outerjoin("ACTION CODE")) )
         JOIN (pwi
         WHERE (pwi.issue_cd= Outerjoin(cv.code_value))
          AND (pwi.active_ind= Outerjoin(1)) )
        DETAIL
         IF (trim(cve.field_value,3)="")
          IF (pwi.issue_cd != 0.0)
           IF (trim(pwi.alias,3)="")
            arg_rec->objarray[d.seq].sarg_value = cnvtupper(trim(pwi.display,3))
           ELSE
            arg_rec->objarray[d.seq].sarg_value = cnvtupper(build(trim(pwi.alias,3),"-",trim(pwi
               .display,3)))
           ENDIF
          ELSE
           arg_rec->objarray[d.seq].sarg_value = cnvtupper(trim(cv.display,3))
          ENDIF
         ELSE
          arg_rec->objarray[d.seq].sarg_value = cnvtupper(build(trim(cve.field_value,3),"-",trim(cv
             .display,3)))
         ENDIF
        WITH nocounter
       ;end select
      OF "CLAIMAMT":
      OF "ENCNTRBAL":
       IF ((arg_rec->objarray[1].darg_value=1.00))
        SET arg_rec->objarray[1].sarg_value = "$0-500"
       ELSEIF ((arg_rec->objarray[1].darg_value=2.00))
        SET arg_rec->objarray[1].sarg_value = "$501-1,500"
       ELSEIF ((arg_rec->objarray[1].darg_value=3.00))
        SET arg_rec->objarray[1].sarg_value = "$1,501-5,000"
       ELSEIF ((arg_rec->objarray[1].darg_value=4.00))
        SET arg_rec->objarray[1].sarg_value = "$5,001-10,000"
       ELSEIF ((arg_rec->objarray[1].darg_value=5.00))
        SET arg_rec->objarray[1].sarg_value = "$10,001-20,000"
       ELSEIF ((arg_rec->objarray[1].darg_value=6.00))
        SET arg_rec->objarray[1].sarg_value = "$20,001-50,000"
       ELSEIF ((arg_rec->objarray[1].darg_value=7.00))
        SET arg_rec->objarray[1].sarg_value = "$50,001-100,000"
       ELSEIF ((arg_rec->objarray[1].darg_value=8.00))
        SET arg_rec->objarray[1].sarg_value = "$100,001+"
       ENDIF
      OF "AGENCY_TYPE":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         code_value cv
        PLAN (d)
         JOIN (cv
         WHERE (cv.code_value=arg_rec->objarray[d.seq].darg_value)
          AND cv.active_ind=1)
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = cnvtupper(trim(cv.display,3))
        WITH nocounter
       ;end select
      OF "AGENCY":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         organization o
        PLAN (d)
         JOIN (o
         WHERE (o.organization_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         arg_rec->objarray[d.seq].sarg_value = cnvtupper(trim(o.org_name,3))
        WITH nocounter
       ;end select
      OF "DUNNING_LEVEL":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         rc_d_dunning_level rdll
        PLAN (d)
         JOIN (rdll
         WHERE (rdll.rc_d_dunning_level_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "Unassigned Statement Cycle"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = trim(rdll.dunning_level,3)
         ENDIF
        WITH nocounter
       ;end select
      OF "REND_PHYSICIAN":
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = arg_rec->arg_value_list_cnt),
         shr_d_person rp
        PLAN (d)
         JOIN (rp
         WHERE (rp.mill_person_id=arg_rec->objarray[d.seq].darg_value))
        DETAIL
         IF ((arg_rec->objarray[d.seq].darg_value=0.0))
          arg_rec->objarray[d.seq].sarg_value = "No Rendering Physician"
         ELSE
          arg_rec->objarray[d.seq].sarg_value = trim(rp.person_full_name,3)
         ENDIF
        WITH nocounter
       ;end select
     ENDCASE
    ENDIF
    FOR (rec_list_cnt = 1 TO arg_rec->arg_value_list_cnt)
      CASE (data_type)
       OF "F8":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].darg_value > 0.0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,19)
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].darg_value,
            19))
         ENDIF
        ENDIF
       OF "I4":
        IF (((allow_zero_ind=false
         AND (arg_rec->objarray[rec_list_cnt].iarg_value > 0)) OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,19)
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",cnvtstring(arg_rec->objarray[rec_list_cnt].iarg_value,
            19))
         ENDIF
        ENDIF
       OF "VC":
        IF (((allow_zero_ind=false
         AND trim(arg_rec->objarray[rec_list_cnt].sarg_value,3) != "") OR (allow_zero_ind=true)) )
         IF (in_clause_ind=false)
          SET in_clause = concat(filter_title,": ",arg_rec->objarray[rec_list_cnt].sarg_value)
          SET in_clause_ind = true
         ELSE
          SET in_clause = concat(in_clause,", ",arg_rec->objarray[rec_list_cnt].sarg_value)
         ENDIF
        ENDIF
       ELSE
        CALL echo(build("Unknown Data Type: ",data_type))
        RETURN("")
      ENDCASE
    ENDFOR
    IF (all_ind=false)
     SET in_clause = concat(in_clause,char(13),char(10))
    ENDIF
    RETURN(in_clause)
  END ;Subroutine
 ENDIF
 IF (validate(getcurrentmonthid,char(128))=char(128))
  SUBROUTINE (getcurrentmonthid(month_abbr=vc) =f8)
    DECLARE month_id = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM shr_d_month m
     WHERE m.month_abbreviation=month_abbr
     DETAIL
      month_id = m.shr_d_month_id
     WITH nocounter
    ;end select
    IF (month_id < 1.0)
     CALL echo(build("Unable to retrieve the month id for the abbreviation provided: ",month_abbr))
    ELSE
     CALL echo(build("SHR_D_MONTH_ID: ",month_id))
    ENDIF
    RETURN(month_id)
  END ;Subroutine
 ENDIF
 IF (validate(getfiscalyearpref,char(128))=char(128))
  SUBROUTINE (getfiscalyearpref(activity_date=i4,logicaldomainid=f8) =i4)
    EXECUTE prefrtl
    DECLARE hpref = i4 WITH private, noconstant(0)
    DECLARE lprefstat = i4 WITH private, noconstant(0)
    DECLARE hgroup = i4 WITH private, noconstant(0)
    DECLARE hgroup2 = i4 WITH private, noconstant(0)
    DECLARE hsection = i4 WITH private, noconstant(0)
    DECLARE hentry = i4 WITH private, noconstant(0)
    DECLARE hattr = i4 WITH private, noconstant(0)
    DECLARE hval = i4 WITH private, noconstant(0)
    DECLARE entryidx = i4 WITH private, noconstant(0)
    DECLARE entrycnt = i4 WITH private, noconstant(0)
    DECLARE attridx = i4 WITH private, noconstant(0)
    DECLARE attrcnt = i4 WITH private, noconstant(0)
    DECLARE validx = i4 WITH private, noconstant(0)
    DECLARE valcnt = i4 WITH private, noconstant(0)
    DECLARE namelength = i4 WITH private, noconstant(0)
    DECLARE entryname = c50 WITH private, noconstant("")
    DECLARE attrname = c50 WITH private, noconstant("")
    DECLARE valname = c50 WITH private, noconstant("")
    DECLARE fiscal_start_month = vc WITH protect
    DECLARE fiscal_start_day = vc WITH private
    DECLARE fiscal_year = vc WITH private
    DECLARE my_return_date = i4 WITH protect, noconstant(0)
    SET hpref = uar_prefcreateinstance(0)
    IF (hpref=0)
     CALL echo("uar_PrefCreateInstance failed")
    ENDIF
    SET lprefstat = uar_prefaddcontext(hpref,"default","system")
    IF (lprefstat != 1)
     CALL echo("uar_PrefAddContext failed")
    ENDIF
    SET lprefstat = uar_prefaddcontext(hpref,"logical domain",nullterm(cnvtstring(logicaldomainid,17,
       2)))
    IF (lprefstat != 1)
     CALL echo("uar_PrefAddContext failed")
    ENDIF
    SET lprefstat = uar_prefsetsection(hpref,"revenue cycle analytics")
    IF (lprefstat != 1)
     CALL echo("uar_PrefSetSection failed")
    ENDIF
    SET hgroup = uar_prefcreategroup()
    SET lprefstat = uar_prefsetgroupname(hgroup,"fiscal year")
    IF (lprefstat != 1)
     CALL echo("uar_PrefSetGroupName failed")
    ENDIF
    SET lprefstat = uar_prefaddgroup(hpref,hgroup)
    SET lprefstat = uar_prefperform(hpref)
    IF (lprefstat=false)
     CALL echo(
      "Unable to retrieve preferences for Fiscal Year. Check PreferenceManager.exe to make sure they are created."
      )
    ENDIF
    SET hsection = uar_prefgetsectionbyname(hpref,"revenue cycle analytics")
    IF (hsection=0)
     CALL echo("No Section Returned")
    ENDIF
    SET hgroup2 = uar_prefgetgroupbyname(hsection,"fiscal year")
    IF (hgroup2=0)
     CALL echo("No Groups Returned In Section")
    ENDIF
    SET lprefstat = uar_prefgetgroupentrycount(hgroup2,entrycnt)
    IF (entrycnt > 0)
     SET namelength = 50
     SET hentry = uar_prefgetgroupentry(hgroup2,entryidx)
     IF (hentry=0)
      CALL echo("Unable To Retrieve Entry")
     ENDIF
     SET lprefstat = uar_prefgetentryname(hentry,entryname,namelength)
     SET lprefstat = uar_prefgetentryattrcount(hentry,attrcnt)
     IF (lprefstat != 1)
      CALL echo("uar_PrefGetEntryAttrCount failed")
     ENDIF
     FOR (attridx = 0 TO (attrcnt - 1))
       SET namelength = 50
       SET hattr = uar_prefgetentryattr(hentry,attridx)
       SET lprefstat = uar_prefgetattrname(hattr,attrname,namelength)
       SET lprefstat = uar_prefgetattrvalcount(hattr,valcnt)
       FOR (validx = 0 TO (valcnt - 1))
        SET namelength = 50
        SET hval = uar_prefgetattrval(hattr,valname,namelength,validx)
       ENDFOR
     ENDFOR
    ENDIF
    IF (cnvtupper(trim(entryname,4))="FISCALMONTH")
     SET fiscal_start_month = replace(valname,char(0),"",0)
     IF (isnumeric(fiscal_start_month)=0)
      SELECT INTO "nl:"
       FROM shr_d_month m
       WHERE ((m.month_abbreviation=cnvtupper(fiscal_start_month)) OR (cnvtupper(m.month_name)=
       cnvtupper(fiscal_start_month)))
       DETAIL
        fiscal_start_month = cnvtstring(m.shr_d_month_id)
       WITH nocounter
      ;end select
      IF (curqual < 1)
       CALL echo("Month not found on SHR_D_MONTH table. Check table and check spelling.")
      ENDIF
     ENDIF
     IF (size(fiscal_start_month,1)=1)
      SET fiscal_start_month = concat("0",fiscal_start_month)
     ENDIF
     CALL echo(build2("Fiscal Start Month: ",fiscal_start_month))
    ELSE
     CALL echo(build2("Unable to determine preference: ",entryname))
    ENDIF
    SET fiscal_start_day = "01"
    CALL echo(build2("Fiscal Start Day: ",fiscal_start_day))
    IF (trim(fiscal_start_month,3) != ""
     AND trim(fiscal_start_day,3) != "")
     IF (cnvtint(fiscal_start_month) < month(activity_date))
      SET fiscal_year = cnvtstring(year(activity_date))
     ELSEIF (cnvtint(fiscal_start_month)=month(activity_date))
      IF (cnvtint(fiscal_start_day) <= day(activity_date))
       SET fiscal_year = cnvtstring(year(activity_date))
      ELSE
       SET fiscal_year = cnvtstring((year(activity_date) - 1))
      ENDIF
     ELSE
      SET fiscal_year = cnvtstring((year(activity_date) - 1))
     ENDIF
     SET my_return_date = cnvtdate(concat(fiscal_start_month,fiscal_start_day,fiscal_year))
     SELECT INTO "nl:"
      FROM omf_date
      WHERE dt_nbr=my_return_date
       AND dt_nbr > 0
      WITH nocounter
     ;end select
     IF (curqual < 1)
      SET my_return_date = cnvtdate(concat("01","01",cnvtstring(year(activity_date))))
     ENDIF
    ELSE
     SET my_return_date = cnvtdate(concat("01","01",cnvtstring(year(activity_date))))
    ENDIF
    CALL echo(build2("Fiscal Year Starts: ",format(cnvtdatetime(my_return_date,0),"MM/DD/YYYY ;;D")))
    CALL uar_prefdestroyinstance(hpref)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroyentry(hentry)
    CALL uar_prefdestroyattr(hattr)
    RETURN(my_return_date)
  END ;Subroutine
 ENDIF
 IF (validate(getdeliverysystemname,char(128))=char(128))
  SUBROUTINE (getdeliverysystemname(s_null_index=i2) =vc)
    DECLARE ds_name = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM delivery_system ds,
      billing_entity be
     PLAN (ds
      WHERE ds.active_ind=1
       AND ds.billing_entity_id > 0.0
       AND ds.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ds.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (be
      WHERE be.billing_entity_id=ds.billing_entity_id
       AND be.active_ind=1
       AND be.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND be.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      ds_name = be.be_name
     WITH nocounter
    ;end select
    IF (ds_name="")
     CALL echo("Unable to retrieve the default delivery system's name")
    ELSE
     CALL echo(build("Delivery System Name: ",ds_name))
    ENDIF
    RETURN(ds_name)
  END ;Subroutine
 ENDIF
 IF (validate(addheadsection,char(128))=char(128))
  SUBROUTINE (addheadsection(s_null_index=i2) =i2)
    CALL add_where("head report")
    CALL add_where("if(reply_obj->qual_cnt <= 0)")
    CALL add_where("stat = alterlist(reply_obj->objArray, 50)")
    CALL add_where("endif")
    CALL add_where("detail")
    CALL add_where("reply_obj->qual_cnt = reply_obj->qual_cnt + 1")
    CALL add_where("if(reply_obj->qual_cnt > size(reply_obj->objArray,5))")
    CALL add_where("stat = alterlist(reply_obj->objArray, reply_obj->qual_cnt + 50)")
    CALL add_where("endif")
  END ;Subroutine
 ENDIF
 IF (validate(addheadsectionwithdetail,char(128))=char(128))
  SUBROUTINE (addheadsectionwithdetail(s_null_index=i2) =i2)
    CALL add_where("head report")
    CALL add_where("if(reply_obj->qual_cnt <= 0)")
    CALL add_where("stat = alterlist(reply_obj->objArray, 50)")
    CALL add_where("endif")
    CALL add_where("detail")
  END ;Subroutine
 ENDIF
 IF (validate(addfootsection,char(128))=char(128))
  SUBROUTINE (addfootsection(s_null_index=i2) =i2)
    CALL add_where("foot report")
    CALL add_where("stat = alterlist(reply_obj->objArray, reply_obj->qual_cnt)")
    CALL add_where("with nocounter go")
  END ;Subroutine
 ENDIF
 IF (validate(generatenewquery,char(128))=char(128))
  SUBROUTINE (generatenewquery(s_null_index=i2) =i2)
    IF (generatequery(table_rec)=false)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(errorinquery,char(128))=char(128))
  SUBROUTINE (errorinquery(s_null_index=i2) =i2)
    IF ((table_rec->error_ind=true))
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(insertclause,char(128))=char(128))
  SUBROUTINE (inserttabledef(table_name=vc,table_alias=vc,priority_seq=i2,priority_ind=i2,
   where_clause=vc,default_where_clause_ind=i2) =i2)
    IF ((table_rec->tbl_cnt=0))
     SET table_rec->error_ind = false
    ENDIF
    IF (((trim(table_name,3)="") OR (((trim(table_alias,3)="") OR (trim(where_clause,3)="")) )) )
     CALL echo("There was an error inserting the table definition to the query.")
     IF (validate(debug,0)=1)
      CALL echo(build("Table Name: ",table_name))
      CALL echo(build("Table Alias: ",table_alias))
      CALL echo(build("Where Clause: ",where_clause))
     ENDIF
     SET table_rec->error_ind = true
     RETURN(false)
    ENDIF
    SET table_rec->tbl_cnt += 1
    SET stat = alterlist(table_rec->tbl_list,table_rec->tbl_cnt)
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_name = table_name
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_alias = table_alias
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_priority = priority_seq
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_priority_ind = priority_ind
    SET table_rec->tbl_list[table_rec->tbl_cnt].add_default_where_clause_ind =
    default_where_clause_ind
    IF ((priority_seq > table_rec->max_priority))
     SET table_rec->max_priority = priority_seq
    ENDIF
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_where_clause_cnt += 1
    SET stat = alterlist(table_rec->tbl_list[table_rec->tbl_cnt].tbl_where_clause,table_rec->
     tbl_list[table_rec->tbl_cnt].tbl_where_clause_cnt)
    SET table_rec->tbl_list[table_rec->tbl_cnt].tbl_where_clause[table_rec->tbl_list[table_rec->
    tbl_cnt].tbl_where_clause_cnt].where_clause = where_clause
    IF (validate(debug,0)=1)
     CALL echo(build2("Table: ",table_name," added successfully"))
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(insertclause,char(128))=char(128))
  SUBROUTINE (inserttableaggrfunction(aggregate_function=vc) =i2)
    IF ((table_rec->tbl_aggr_functions_cnt=0))
     SET table_rec->error_ind = false
    ENDIF
    IF (trim(aggregate_function,3)="")
     CALL echo("There was an error inserting the aggregate function to the query.")
     IF (validate(debug,0)=1)
      CALL echo(build("Aggregate Function: ",aggregate_function))
     ENDIF
     SET table_rec->error_ind = true
     RETURN(false)
    ENDIF
    SET table_rec->tbl_aggr_functions_cnt += 1
    SET stat = alterlist(table_rec->tbl_aggr_functions,table_rec->tbl_aggr_functions_cnt)
    SET table_rec->tbl_aggr_functions[table_rec->tbl_aggr_functions_cnt].aggregate_function =
    aggregate_function
    IF (validate(debug,0)=1)
     CALL echo(build2("Aggregate Function: ",aggregate_function," added successfully"))
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(insertclause,char(128))=char(128))
  SUBROUTINE (inserttablegroupby(group_by_field=vc) =i2)
    IF ((table_rec->tbl_group_by_fields_cnt=0))
     SET table_rec->error_ind = false
    ENDIF
    IF (trim(group_by_field,3)="")
     CALL echo("There was an error inserting the group by field to the query.")
     IF (validate(debug,0)=1)
      CALL echo(build("Group By Field: ",group_by_field))
     ENDIF
     SET table_rec->error_ind = true
     RETURN(false)
    ENDIF
    SET table_rec->tbl_group_by_fields_cnt += 1
    SET stat = alterlist(table_rec->tbl_group_by_fields,table_rec->tbl_group_by_fields_cnt)
    SET table_rec->tbl_group_by_fields[table_rec->tbl_group_by_fields_cnt].group_by_field =
    group_by_field
    IF (validate(debug,0)=1)
     CALL echo(build2("Group By Field: ",group_by_field," added successfully"))
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(insertclause,char(128))=char(128))
  SUBROUTINE (inserttableorderby(order_by_field=vc) =i2)
    IF ((table_rec->tbl_order_by_fields_cnt=0))
     SET table_rec->error_ind = false
    ENDIF
    IF (trim(order_by_field,3)="")
     CALL echo("There was an error inserting the order by field to the query.")
     IF (validate(debug,0)=1)
      CALL echo(build("Order By Field: ",order_by_field))
     ENDIF
     SET table_rec->error_ind = true
     RETURN(false)
    ENDIF
    SET table_rec->tbl_order_by_fields_cnt += 1
    SET stat = alterlist(table_rec->tbl_order_by_fields,table_rec->tbl_order_by_fields_cnt)
    SET table_rec->tbl_order_by_fields[table_rec->tbl_order_by_fields_cnt].order_by_field =
    order_by_field
    IF (validate(debug,0)=1)
     CALL echo(build2("Order By Field: ",order_by_field," added successfully"))
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(generatequery,char(128))=char(128))
  SUBROUTINE (generatequery(tbl_rec=vc(ref)) =i2)
    DECLARE cur_tbl = i4 WITH private, noconstant(0)
    DECLARE cur_priority = i2 WITH private, noconstant(0)
    DECLARE cur_index = i4 WITH private, noconstant(0)
    DECLARE cur_where_idx = i4 WITH private, noconstant(0)
    DECLARE first_table_ind = i2 WITH private, noconstant(0)
    DECLARE aggr_index = i4 WITH private, noconstant(0)
    DECLARE group_by_index = i4 WITH private, noconstant(0)
    DECLARE order_by_index = i4 WITH private, noconstant(0)
    IF ((tbl_rec->tbl_cnt != size(tbl_rec->tbl_list,5)))
     CALL echo("The table count property is not the same as the size of the table list")
     RETURN(false)
    ENDIF
    IF ((((tbl_rec->tbl_cnt < 1)) OR (size(tbl_rec->tbl_list,5) < 1)) )
     CALL echo("There are no tables to generate a query from.")
     RETURN(false)
    ENDIF
    CALL echo("Adding Prioritized Tables to From Clause")
    SET first_table_ind = true
    FOR (cur_priority = 1 TO tbl_rec->max_priority)
      SET cur_index = 0
      SET cur_index = locateval(cur_tbl,1,tbl_rec->tbl_cnt,cur_priority,tbl_rec->tbl_list[cur_tbl].
       tbl_priority)
      IF (cur_index > 0
       AND (tbl_rec->tbl_list[cur_index].tbl_priority_ind=true)
       AND (tbl_rec->tbl_list[cur_index].tbl_added_to_from_clause=false))
       IF ((((tbl_rec->tbl_list[cur_index].tbl_name="")) OR ((tbl_rec->tbl_list[cur_index].tbl_alias=
       ""))) )
        CALL echo(
         "Unable to generate query. Table name or alias was not provided for one or more of the tables requested."
         )
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF (first_table_ind=true)
        IF ((tbl_rec->tbl_aggr_functions_cnt > 0))
         IF ( NOT (usingreporttemptable(0)))
          CALL add_where("SELECT INTO 'nl:'")
          CALL add_where(tbl_rec->tbl_aggr_functions[1].aggregate_function)
          FOR (aggr_index = 2 TO tbl_rec->tbl_aggr_functions_cnt)
            CALL add_where(concat(", ",tbl_rec->tbl_aggr_functions[aggr_index].aggregate_function))
          ENDFOR
         ENDIF
         CALL add_where("FROM")
        ELSE
         IF ( NOT (usingreporttemptable(0)))
          CALL add_where("SELECT INTO 'nl:' FROM")
         ELSE
          CALL add_where(" FROM ")
         ENDIF
        ENDIF
        CALL add_where(concat(tbl_rec->tbl_list[cur_index].tbl_name," ",tbl_rec->tbl_list[cur_index].
          tbl_alias))
        SET first_table_ind = false
       ELSE
        CALL add_where(concat(", ",tbl_rec->tbl_list[cur_index].tbl_name," ",tbl_rec->tbl_list[
          cur_index].tbl_alias))
       ENDIF
       SET tbl_rec->tbl_list[cur_index].tbl_added_to_from_clause = true
      ENDIF
    ENDFOR
    CALL echo("Adding Non-Prioritized Tables to From Clause")
    FOR (cur_tbl = 1 TO tbl_rec->tbl_cnt)
      IF ((tbl_rec->tbl_list[cur_tbl].tbl_added_to_from_clause=false))
       IF ((((tbl_rec->tbl_list[cur_tbl].tbl_name="")) OR ((tbl_rec->tbl_list[cur_tbl].tbl_alias="")
       )) )
        CALL echo(
         "Unable to generate query. Table name or alias was not provided for one or more of the tables requested."
         )
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF (first_table_ind=true)
        IF ((tbl_rec->tbl_aggr_functions_cnt > 0))
         IF ( NOT (usingreporttemptable(0)))
          CALL add_where("SELECT INTO 'nl:'")
          CALL add_where(tbl_rec->tbl_aggr_functions[1].aggregate_function)
          FOR (aggr_index = 2 TO tbl_rec->tbl_aggr_functions_cnt)
            CALL add_where(concat(", ",tbl_rec->tbl_aggr_functions[1].aggregate_function))
          ENDFOR
         ENDIF
         CALL add_where("FROM")
        ELSE
         IF ( NOT (usingreporttemptable(0)))
          CALL add_where("SELECT INTO 'nl:' FROM")
         ELSE
          CALL add_where(" FROM ")
         ENDIF
        ENDIF
        CALL add_where(concat(tbl_rec->tbl_list[cur_index].tbl_name," ",tbl_rec->tbl_list[cur_index].
          tbl_alias))
        SET first_table_ind = false
       ELSE
        CALL add_where(concat(", ",tbl_rec->tbl_list[cur_tbl].tbl_name," ",tbl_rec->tbl_list[cur_tbl]
          .tbl_alias))
       ENDIF
       SET tbl_rec->tbl_list[cur_tbl].tbl_added_to_from_clause = true
      ENDIF
    ENDFOR
    CALL echo("Adding Prioritized Tables to Join Path")
    FOR (cur_priority = 1 TO tbl_rec->max_priority)
      SET cur_index = 0
      SET cur_index = locateval(cur_tbl,1,tbl_rec->tbl_cnt,cur_priority,tbl_rec->tbl_list[cur_tbl].
       tbl_priority)
      IF (cur_index > 0
       AND (tbl_rec->tbl_list[cur_index].tbl_priority_ind=true)
       AND (tbl_rec->tbl_list[cur_index].tbl_added_to_join_path=false))
       IF ((((tbl_rec->tbl_list[cur_index].tbl_name="")) OR ((tbl_rec->tbl_list[cur_index].tbl_alias=
       ""))) )
        CALL echo(
         "Unable to generate query. Table name or alias was not provided for one or more of the tables requested."
         )
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF ((tbl_rec->tbl_list[cur_index].tbl_where_clause_cnt != size(tbl_rec->tbl_list[cur_index].
        tbl_where_clause,5)))
        CALL echo("The where clause count does not equal the amount of where clauses in the list")
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF ((((tbl_rec->tbl_list[cur_index].tbl_where_clause_cnt < 1)) OR (size(tbl_rec->tbl_list[
        cur_index].tbl_where_clause,5) < 1)) )
        CALL echo(build("There was no where clause for the current table: ",tbl_rec->tbl_list[cur_tbl
          ].tbl_name))
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       FOR (cur_where_idx = 1 TO tbl_rec->tbl_list[cur_index].tbl_where_clause_cnt)
         IF ((tbl_rec->tbl_list[cur_index].tbl_where_clause[cur_where_idx].where_clause=""))
          CALL echo(build("The where clause at the current index: ",cur_where_idx,
            " for the current table: ",tbl_rec->tbl_list[cur_index].tbl_name," was empty"))
          IF (validate(debug,0)=1)
           CALL showquery(0)
           CALL echorecord(tbl_rec)
          ENDIF
          RETURN(false)
         ENDIF
         CALL add_where(tbl_rec->tbl_list[cur_index].tbl_where_clause[cur_where_idx].where_clause)
         IF ((tbl_rec->tbl_list[cur_index].add_default_where_clause_ind=true))
          CALL add_default_where_clause(tbl_rec->tbl_list[cur_index].tbl_alias)
         ENDIF
         SET tbl_rec->tbl_list[cur_index].tbl_added_to_join_path = true
       ENDFOR
      ENDIF
    ENDFOR
    CALL echo("Adding Non-Prioritized Tables to Join Path")
    FOR (cur_tbl = 1 TO tbl_rec->tbl_cnt)
      IF ((tbl_rec->tbl_list[cur_tbl].tbl_added_to_join_path=false))
       IF ((((tbl_rec->tbl_list[cur_tbl].tbl_name="")) OR ((tbl_rec->tbl_list[cur_tbl].tbl_alias="")
       )) )
        CALL echo(
         "Unable to generate query. Table name or alias was not provided for one or more of the tables requested."
         )
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF ((tbl_rec->tbl_list[cur_tbl].tbl_where_clause_cnt != size(tbl_rec->tbl_list[cur_tbl].
        tbl_where_clause,5)))
        CALL echo("The where clause count does not equal the amount of where clauses in the list")
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       IF ((((tbl_rec->tbl_list[cur_tbl].tbl_where_clause_cnt < 1)) OR (size(tbl_rec->tbl_list[
        cur_tbl].tbl_where_clause,5) < 1)) )
        CALL echo(build("There was no where clause for the current table: ",tbl_rec->tbl_list[cur_tbl
          ].tbl_name))
        IF (validate(debug,0)=1)
         CALL showquery(0)
         CALL echorecord(tbl_rec)
        ENDIF
        RETURN(false)
       ENDIF
       FOR (cur_where_idx = 1 TO tbl_rec->tbl_list[cur_tbl].tbl_where_clause_cnt)
         IF ((tbl_rec->tbl_list[cur_tbl].tbl_where_clause[cur_where_idx].where_clause=""))
          CALL echo(build("There was no where clause for the current table: ",tbl_rec->tbl_list[
            cur_tbl].tbl_name))
          IF (validate(debug,0)=1)
           CALL showquery(0)
           CALL echorecord(tbl_rec)
          ENDIF
          RETURN(false)
         ENDIF
         CALL add_where(tbl_rec->tbl_list[cur_tbl].tbl_where_clause[cur_where_idx].where_clause)
         IF ((tbl_rec->tbl_list[cur_tbl].add_default_where_clause_ind=true))
          CALL add_default_where_clause(tbl_rec->tbl_list[cur_tbl].tbl_alias)
         ENDIF
         SET tbl_rec->tbl_list[cur_tbl].tbl_added_to_join_path = true
       ENDFOR
      ENDIF
    ENDFOR
    IF ((tbl_rec->tbl_order_by_fields_cnt > 0))
     CALL add_where("ORDER BY")
     CALL add_where(tbl_rec->tbl_order_by_fields[1].order_by_field)
     FOR (order_by_index = 2 TO tbl_rec->tbl_order_by_fields_cnt)
       CALL add_where(concat(", ",tbl_rec->tbl_order_by_fields[order_by_index].order_by_field))
     ENDFOR
    ENDIF
    IF ((tbl_rec->tbl_group_by_fields_cnt > 0))
     CALL add_where("GROUP BY")
     CALL add_where(tbl_rec->tbl_group_by_fields[1].group_by_field)
     FOR (group_by_index = 2 TO tbl_rec->tbl_group_by_fields_cnt)
       CALL add_where(concat(", ",tbl_rec->tbl_group_by_fields[group_by_index].group_by_field))
     ENDFOR
    ENDIF
    SET stat = initrec(table_rec)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(exportreplyascsv,char(128))=char(128))
  SUBROUTINE (exportreplyascsv(file_name=vc) =i2)
    DECLARE output_report_file_prefix = vc WITH constant("cer_temp:pft_rpt_")
    DECLARE char34 = c1 WITH private, constant(char(34))
    DECLARE delimiter = vc WITH private, noconstant(",")
    DECLARE usingtemptable = i2 WITH private, constant(usingreporttemptable(0))
    DECLARE x = i4 WITH private, noconstant(0)
    DECLARE first_column_ind = i2 WITH private, noconstant(true)
    DECLARE parser_value = vc WITH private, noconstant("")
    DECLARE temp = vc WITH protect, noconstant(" ")
    DECLARE dm_delimiter = vc WITH protect, noconstant(" ")
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="MILL_OUTPUT_REPORT_FILE"
      AND d.info_name="DELIMITER"
     ORDER BY d.info_domain_id
     HEAD d.info_domain_id
      dm_delimiter = d.info_char
     WITH nocounter, maxrec = 1
    ;end select
    IF (findstring(output_report_file_prefix,file_name) > 0)
     IF (dm_delimiter=",")
      SET delimiter = ","
     ELSE
      SET delimiter = "|"
     ENDIF
    ENDIF
    IF (validate(reply_obj->objarray)=0)
     CALL echo("reply_obj->objArray does not exist")
     RETURN(false)
    ENDIF
    SET parser_value = concat("select into ",'"',file_name,'"')
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    IF (usingtemptable=true)
     SET parser_value = concat(" from ",report_data_temp_table,
      " rdtt plan rdtt head report temp = build(")
    ELSE
     SET parser_value =
     "from (dummyt d1 with seq = reply_obj->qual_cnt) plan d1  head report temp = build("
    ENDIF
    CALL parser(parser_value,1)
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    FOR (x = 1 TO export_reply->column_cnt)
      IF (first_column_ind=true)
       SET parser_value = concat("'",char34,"'",", '",export_reply->column[x].column_heading,
        "','",char34,"'")
       SET first_column_ind = false
      ELSE
       SET parser_value = concat(",'",char34,"'",", '",export_reply->column[x].column_heading,
        "','",char34,"'")
      ENDIF
      IF ((x != export_reply->column_cnt))
       SET parser_value = concat(parser_value,', "',delimiter,'"')
      ENDIF
      CALL parser(parser_value,1)
      IF (validate(debug,0)=1)
       CALL echo(parser_value)
      ENDIF
    ENDFOR
    SET first_column_ind = true
    SET parser_value = ") col 0 temp row +1 detail temp =build("
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    IF (usingtemptable=true)
     FOR (x = 1 TO export_reply->column_cnt)
       SET parser_value = " "
       IF ((export_reply->column[x].column_type=enum_column_type_date))
        SET parser_value = build("format(cnvtdatetime(rdtt.",export_reply->column[x].column_name,
         ',0), "mm/dd/yyyy;;d")')
       ELSEIF ((export_reply->column[x].column_type=enum_column_type_datetm))
        SET parser_value = build("format(cnvtdatetime(rdtt.",export_reply->column[x].column_name,
         '), "mm/dd/yyyy;;d")')
       ELSEIF ((export_reply->column[x].column_type=enum_column_type_string))
        SET parser_value = build("build('",char34,"', replace(rdtt.",export_reply->column[x].
         column_name,",char(34),CONCAT(char(34),char(34))),'",
         char34,"')")
       ELSE
        SET parser_value = build(" evaluate2(if(isNumeric(rdtt.",export_reply->column[x].column_name,
         "))")
        SET parser_value = build(parser_value," cnvtstring(rdtt.",export_reply->column[x].column_name,
         ",17,2) else ")
        SET parser_value = build(parser_value," build('",char34,"', rdtt.",export_reply->column[x].
         column_name,
         ",'",char34,"') endif)")
       ENDIF
       IF ((x < export_reply->column_cnt))
        SET parser_value = build(parser_value,",'",delimiter,"',")
       ENDIF
       CALL parser(parser_value,1)
       IF (validate(debug,0)=1)
        CALL echo(parser_value)
       ENDIF
     ENDFOR
    ELSE
     FOR (x = 1 TO export_reply->column_cnt)
       SET parser_value = ""
       IF ((export_reply->column[x].column_type=enum_column_type_date))
        SET parser_value = build("format(cnvtdatetime(reply_obj->objarray[d1.seq].",export_reply->
         column[x].column_name,',0), "mm/dd/yyyy;;d")')
       ELSEIF ((export_reply->column[x].column_type=enum_column_type_datetm))
        SET parser_value = build("format(cnvtdatetime(reply_obj->objarray[d1.seq].",export_reply->
         column[x].column_name,'), "mm/dd/yyyy;;d")')
       ELSEIF ((export_reply->column[x].column_type=enum_column_type_string))
        SET parser_value = build("build('",char34,"', replace(reply_obj->objarray[d1.seq].",
         export_reply->column[x].column_name,",char(34),CONCAT(char(34),char(34))),'",
         char34,"')")
       ELSE
        SET parser_value = build(" evaluate2(if(isNumeric(reply_obj->objarray[d1.seq].",export_reply
         ->column[x].column_name,"))")
        SET parser_value = build(parser_value," cnvtstring(reply_obj->objarray[d1.seq].",export_reply
         ->column[x].column_name,",17,2) else ")
        SET parser_value = build(parser_value," build('",char34,"', reply_obj->objarray[d1.seq].",
         export_reply->column[x].column_name,
         ",'",char34,"') endif)")
       ENDIF
       IF ((x < export_reply->column_cnt))
        SET parser_value = build(parser_value,",'",delimiter,"',")
       ENDIF
       CALL parser(parser_value,1)
       IF (validate(debug,0)=1)
        CALL echo(parser_value)
       ENDIF
     ENDFOR
    ENDIF
    SET parser_value =
    ") col 0 temp row +1 with nocounter, format=lfstream, noheading, maxcol = 10000, noformfeed, maxrow=1 go"
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addfieldtoexport,char(128))=char(128))
  SUBROUTINE (addfieldtoexport(field_name=vc,field_heading=vc,field_type=i2(value,false)) =null)
    IF (trim(field_name,3) != "")
     SET export_reply->column_cnt += 1
     SET stat = alterlist(export_reply->column,export_reply->column_cnt)
     SET export_reply->column[export_reply->column_cnt].column_name = trim(field_name,3)
     SET export_reply->column[export_reply->column_cnt].column_heading = uar_i18ngetmessage(hi18n,
      "Val1",nullterm(field_heading))
     SET export_reply->column[export_reply->column_cnt].column_type = field_type
     IF (validate(debug,0)=1)
      CALL echo(build("Adding Field: ",trim(field_name,3)))
      CALL echo(build("Adding Heading: ",trim(field_heading,3)))
      CALL echo(build("Field Type: ",field_type))
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(freeexport,char(128))=char(128))
  SUBROUTINE (freeexport(s_null_index=i2) =null)
    FREE RECORD export_reply
  END ;Subroutine
 ENDIF
 IF (validate(add_encntr_type_class_fields,char(128))=char(128))
  SUBROUTINE (add_encntr_type_class_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].encntr_type)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Encntr_Type = ",tbl_alias,
      ".encounter_type"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].encntr_class)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Encntr_Class = ",tbl_alias,
      ".encounter_class"))
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_billing_entity_fields,char(128))=char(128))
  SUBROUTINE (add_billing_entity_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].billing_entity_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Billing_Entity_Name = ",
       tbl_alias,".billing_entity_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].billing_entity_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Billing_Entity_Type = ",
       tbl_alias,".billing_entity_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].delivery_system)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Delivery_System =  ",tbl_alias,
       ".delivery_system"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_prsnl_fields,char(128))=char(128))
  SUBROUTINE (add_prsnl_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].prsnl_first_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Prsnl_First_Name = ",tbl_alias,
       ".person_first_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].prsnl_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Prsnl_Full_Name = ",tbl_alias,
       ".person_full_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].prsnl_last_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Prsnl_Last_Name = ",tbl_alias,
       ".person_last_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].prsnl_middle_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Prsnl_Middle_Name = ",tbl_alias,
       ".person_middle_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].prsnl_suprvsr_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Prsnl_Suprvsr_Full_Name = ",
       tbl_alias,".supervisor_full_name"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_person_fields,char(128))=char(128))
  SUBROUTINE (add_person_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_first_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_First_Name = ",tbl_alias,
       ".person_first_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Full_Name = ",tbl_alias,
       ".person_full_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_last_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Last_Name = ",tbl_alias,
       ".person_last_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_middle_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Middle_Name = ",tbl_alias,
       ".person_middle_name"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_claim_event_fields,char(128))=char(128))
  SUBROUTINE (add_claim_event_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_number_identifier)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_Number_Identifier = ",
       tbl_alias,".bill_number_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].claim_billed_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Claim_Billed_Amount = ",
       tbl_alias,".claim_billed_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].claim_event_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Claim_Event_Date = ",tbl_alias,
       ".claim_event_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].days_since_discharge_cnt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Days_Since_Discharge_Cnt = ",
       tbl_alias,".days_since_discharge_cnt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].days_since_generation_cnt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Days_Since_Generation_Cnt = ",
       tbl_alias,".days_since_generation_cnt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].days_since_submission_cnt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Days_Since_Submission_Cnt = ",
       tbl_alias,".days_since_submission_cnt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].priority_seq_number)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Priority_Seq_Number = ",
       tbl_alias,".priority_seq_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_bill_type_fields,char(128))=char(128))
  SUBROUTINE (add_bill_type_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_Type = ",tbl_alias,
       ".bill_type"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_claim_event_type_fields,char(128))=char(128))
  SUBROUTINE (add_claim_event_type_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].claim_event_sub_type)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Claim_Event_Sub_Type = ",
      tbl_alias,".claim_event_sub_type"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].claim_event_type)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Claim_Event_Type = ",tbl_alias,
      ".claim_event_type"))
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_financial_class_fields,char(128))=char(128))
  SUBROUTINE (add_financial_class_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].financial_class)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Financial_Class = ",tbl_alias,
      ".financial_class"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].net_percent_of_revenue)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Net_Percent_Of_Revenue = ",
      tbl_alias,".net_pct_of_revenue"))
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_health_plan_fields,char(128))=char(128))
  SUBROUTINE (add_health_plan_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].health_plan_class)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Health_Plan_Class = ",tbl_alias,
       ".health_plan_class"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].health_plan_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Health_Plan_Name = ",tbl_alias,
       ".health_plan_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].health_plan_product_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Health_Plan_Product_Type = ",
       tbl_alias,".health_plan_product_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].insurance_company)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Insurance_Company = ",tbl_alias,
       ".insurance_company"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_gl_alias_fields,char(128))=char(128))
  SUBROUTINE (add_gl_alias_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_company_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].GL_Company_Name = ",tbl_alias,
       ".gl_company_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_company_unit)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].GL_Company_Unit = ",tbl_alias,
       ".gl_company_unit"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_account_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].GL_Account_Name = ",tbl_alias,
       ".gl_account_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_account_unit)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].GL_Account_Unit = ",tbl_alias,
       ".gl_account_unit"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_account_alias_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].gl_account_alias_desc = ",
       tbl_alias,".gl_account_alias_desc"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_account_unit_alias_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].gl_account_unit_alias_desc = ",
       tbl_alias,".gl_account_unit_alias_desc"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_company_alias_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].gl_company_alias_desc = ",
       tbl_alias,".gl_company_alias_desc"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_company_unit_alias_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].gl_company_unit_alias_desc = ",
       tbl_alias,".gl_company_unit_alias_desc"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_medical_service_fields,char(128))=char(128))
  SUBROUTINE (add_medical_service_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].medical_service)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Medical_Service = ",tbl_alias,
       ".medical_service"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_revenue_fields,char(128))=char(128))
  SUBROUTINE (add_revenue_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].gl_interface_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].GL_Interface_Date = ",tbl_alias,
       ".gl_interface_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].service_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Service_Date = ",tbl_alias,
       ".service_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_charge_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Charge_Amount = ",
       tbl_alias,".total_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_quantity)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Quantity = ",tbl_alias,
       ".total_qty"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].admit_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Admit_Date = ",tbl_alias,
       ".admit_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_Date = ",tbl_alias,
       ".discharge_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].unit_price_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Unit_Price_Amt = ",tbl_alias,
       ".Unit_Price_Amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].relative_value_units_qty)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].relative_value_units_qty = ",
       tbl_alias,".relative_value_units_qty"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_performing_location_fields,char(128))=char(128))
  SUBROUTINE (add_performing_location_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].performing_facility)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Performing_Facility = ",
       tbl_alias,".facility"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].performing_building)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Performing_Building = ",
       tbl_alias,".building"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].performing_location_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Performing_Location_Desc = ",
       tbl_alias,".location_desc"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].performing_room)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Performing_Room = ",tbl_alias,
       ".room"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].performing_bed)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Performing_Bed = ",tbl_alias,
       ".bed"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_person_location_fields,char(128))=char(128))
  SUBROUTINE (add_person_location_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_facility)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Facility = ",tbl_alias,
       ".facility"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_building)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Building = ",tbl_alias,
       ".building"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_location_desc)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Location_Desc = ",
       tbl_alias,".location_desc"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_room)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Room = ",tbl_alias,
       ".room"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].person_bed)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Person_Bed = ",tbl_alias,".bed")
      )
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_bill_item_fields,char(128))=char(128))
  SUBROUTINE (add_bill_item_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Type = ",tbl_alias,
       ".activity_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].charge_description)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Charge_Description = ",tbl_alias,
       ".charge_description"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].revenue_code)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Revenue_Code = ",tbl_alias,
       ".revenue_code"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].hcpcs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].HCPCS = ",tbl_alias,".hcpcs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].cpt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].CPT = ",tbl_alias,".cpt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].procedure_code)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Procedure_Code = ",tbl_alias,
       ".procedure_code"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].cdm)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].CDM = ",tbl_alias,".cdm"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_accommodation_fields,char(128))=char(128))
  SUBROUTINE (add_accommodation_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].accommodation)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Accommodation = ",tbl_alias,
       ".accommodation"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_denial_fields,char(128))=char(128))
  SUBROUTINE (add_denial_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_number_identifier)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_Number_Identifier = ",
       tbl_alias,".bill_number_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Date = ",tbl_alias,
       ".denial_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].patient_liability_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Patient_Liability_Amt = ",
       tbl_alias,".patient_liability_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_billed_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Billed_Amt = ",tbl_alias,
       ".denial_billed_amt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_denial_alias_fields,char(128))=char(128))
  SUBROUTINE (add_denial_alias_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_alias_reason)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Alias_Reason = ",
       tbl_alias,".denial_alias_reason"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Type = ",tbl_alias,
       ".denial_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_group)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Group = ",tbl_alias,
       ".denial_group"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_cash_fields,char(128))=char(128))
  SUBROUTINE (add_cash_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].interface_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Interface_Date = ",tbl_alias,
       ".interface_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].post_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Post_date = ",tbl_alias,
       ".post_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].payment_method_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Payment_Method_Date = ",
       tbl_alias,".payment_method_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].batch_created_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Batch_Created_Date = ",tbl_alias,
       ".batch_created_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].payment_method_nbr)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Payment_Method_Nbr = ",tbl_alias,
       ".payment_method_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_number_identification)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_Number_Identification = ",
       tbl_alias,".bill_number_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transaction_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Transaction_Amount = ",tbl_alias,
       ".transaction_amt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_payment_method_fields,char(128))=char(128))
  SUBROUTINE (add_payment_method_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].payment_method)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Payment_Method = ",tbl_alias,
       ".payment_method"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_transaction_alias_fields,char(128))=char(128))
  SUBROUTINE (add_transaction_alias_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transaction_alias)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Transaction_Alias = ",tbl_alias,
       ".transaction_alias"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transaction_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Transaction_Type = ",tbl_alias,
       ".transaction_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transaction_sub_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Transaction_Sub_Type = ",
       tbl_alias,".transaction_sub_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transaction_reason)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Transaction_Reason = ",tbl_alias,
       ".transaction_reason"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_transaction_batch_fields,char(128))=char(128))
  SUBROUTINE (add_transaction_batch_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].batch_alias)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Batch_Alias = ",tbl_alias,
      ".batch_alias"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].batch_description)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Batch_Description = ",tbl_alias,
      ".batch_description"))
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_adjustment_fields,char(128))=char(128))
  SUBROUTINE (add_adjustment_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].billnumber)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].BillNumber = ",tbl_alias,
       ".BillNumber"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].transactionamount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].TransactionAmount = ",tbl_alias,
       ".transaction_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].batch_created_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Batch_Created_Date = ",tbl_alias,
       ".batch_created_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].post_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Post_Date = ",tbl_alias,
       ".post_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].interface_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Interface_Date = ",tbl_alias,
       ".interface_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_patient_ar_balance_fields,char(128))=char(128))
  SUBROUTINE (add_patient_ar_balance_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_age)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_Age = ",tbl_alias,
       ".bill_age"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_age)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_Age = ",tbl_alias,
       ".discharge_age"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_charge_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Charge_Amount = ",
       tbl_alias,".total_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_payment_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Payment_Amount = ",
       tbl_alias,".total_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_adjust_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Adjust_Amount = ",
       tbl_alias,".total_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_charge_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_Charge_Amount = ",
       tbl_alias,".daily_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_payment_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_Payment_Amount = ",
       tbl_alias,".daily_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_adjust_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_Adjust_Amount = ",
       tbl_alias,".daily_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_priority_seq_nbr)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Priority_Seq_Nbr = ",
       tbl_alias,".resp_priority_seq_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].final_coded_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Final_Coded_Date = ",tbl_alias,
       ".final_coded_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_Date = ",tbl_alias,
       ".discharge_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].admit_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Admit_Date = ",tbl_alias,
       ".admit_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].zero_bal_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Zero_Bal_Date = ",tbl_alias,
       ".zero_bal_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].balance)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Balance = ",tbl_alias,
       ".balance_amt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_age_category_fields,char(128))=char(128))
  SUBROUTINE (add_age_category_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].begin_age_day)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Begin_Age_Day = ",tbl_alias,
       ".begin_age_day"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].end_age_day)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].End_Age_Day = ",tbl_alias,
       ".end_age_day"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].category_description)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Category_Description = ",
       tbl_alias,".category_description"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_discharge_age_category_fields,char(128))=char(128))
  SUBROUTINE (add_discharge_age_category_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_begin_age_day)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_Begin_Age_Day = ",
       tbl_alias,".begin_age_day"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_end_age_day)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_End_Age_Day = ",
       tbl_alias,".end_age_day"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_category_description)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Discharge_Category_Description = ",tbl_alias,
       ".category_description"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_af_patient_ar_balance_fields,char(128))=char(128))
  SUBROUTINE (add_af_patient_ar_balance_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].mrn)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].MRN = ",tbl_alias,
       ".mrn_nbr_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].fin)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].FIN = ",tbl_alias,
       ".fin_nbr_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].account_nbr)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Account_Nbr = ",tbl_alias,
       ".account_nbr_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].dunning_level)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Dunning_Level = ",tbl_alias,
       ".dunning_level"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].financial_status)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Financial_Status = ",tbl_alias,
       ".financial_status"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].financial_sub_status)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Financial_Sub_Status = ",
       tbl_alias,".financial_sub_status"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_encntr_visit_fields,char(128))=char(128))
  SUBROUTINE (add_encntr_visit_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].final_coded_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Final_Coded_Date = ",tbl_alias,
       ".final_coded_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Discharge_Date = ",tbl_alias,
       ".discharge_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].admit_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Admit_Date = ",tbl_alias,
       ".admit_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].pre_reg_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Pre_Reg_Date = ",tbl_alias,
       ".pre_reg_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].verified_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Verified_Date = ",tbl_alias,
       ".ins_verified_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_phys_fields,char(128))=char(128))
  SUBROUTINE (add_phys_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].phys_first_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Phys_First_Name = ",tbl_alias,
       ".person_first_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].phys_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Phys_Full_Name = ",tbl_alias,
       ".person_full_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].phys_last_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Phys_Last_Name = ",tbl_alias,
       ".person_last_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].phys_middle_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Phys_Middle_Name = ",tbl_alias,
       ".person_middle_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].phys_suprvsr_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Phys_Suprvsr_Full_Name = ",
       tbl_alias,".supervisor_full_name"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_resp_health_plan_fields,char(128))=char(128))
  SUBROUTINE (add_resp_health_plan_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_health_plan_class)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Health_Plan_Class = ",
       tbl_alias,".health_plan_class"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_health_plan_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Health_Plan_Name = ",
       tbl_alias,".health_plan_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_health_plan_product_type)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Resp_Health_Plan_Product_Type = ",tbl_alias,
       ".health_plan_product_type"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_insurance_company)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Insurance_Company = ",
       tbl_alias,".insurance_company"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_resp_financial_class_fields,char(128))=char(128))
  SUBROUTINE (add_resp_financial_class_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_financial_class)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Financial_Class = ",
      tbl_alias,".financial_class"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].resp_net_percent_of_revenue)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Resp_Net_Percent_Of_Revenue = ",
      tbl_alias,".net_pct_of_revenue"))
   ENDIF
  END ;Subroutine
 ENDIF
 SUBROUTINE (add_hold_fields(tbl_alias=vc) =null)
  IF (validate(reply_obj->objarray[reply_obj->qual_cnt].hold_reason)=1)
   CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Hold_Reason = ",tbl_alias,
     ".hold_reason"))
  ENDIF
  IF (validate(reply_obj->objarray[reply_obj->qual_cnt].hold_type)=1)
   CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Hold_Type = ",tbl_alias,
     ".hold_type"))
  ENDIF
 END ;Subroutine
 IF (validate(add_encntr_visit_smry_fields,char(128))=char(128))
  SUBROUTINE (add_encntr_visit_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_patient_days)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Patient_Days = ",tbl_alias,
       ".total_patient_days"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_encntrs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Encntrs = ",tbl_alias,
       ".total_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_discharged_encntrs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Discharged_Encntrs = ",
       tbl_alias,".total_discharged_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_pre_reg_encntrs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Pre_Reg_Encntrs = ",
       tbl_alias,".total_pre_reg_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_pre_reg_verified_encntrs)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Total_Pre_Reg_Verified_Encntrs = ",tbl_alias,
       ".total_pre_reg_vrfd_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_admit_encntrs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Admit_Encntrs = ",
       tbl_alias,".total_admitted_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_admit_verified_encntrs)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Admit_Verified_Encntrs = ",
       tbl_alias,".total_admitted_vrfd_encntrs"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_discharge_length_of_stay)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Total_Discharge_Length_Of_Stay = ",tbl_alias,
       ".total_dschrg_length_of_stay"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].year_of_encntr_visit)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Year_Of_Encntr_Visit = ",
       tbl_alias,".activity_year"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_claim_event_smry_fields,char(128))=char(128))
  SUBROUTINE (add_claim_event_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].priority_seq)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Priority_seq = ",tbl_alias,
       ".priority_sequence"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_billed_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_billed_amt = ",tbl_alias,
       ".total_billed_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_days_since_disch)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_days_since_disch = ",
       tbl_alias,".total_days_since_discharge"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_days_since_gen)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_days_since_gen = ",tbl_alias,
       ".total_days_since_generation"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_days_since_sub)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_days_since_sub = ",tbl_alias,
       ".total_days_since_submission"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_nbr_claims)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_nbr_Claims = ",tbl_alias,
       ".total_number_of_claims"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].year_of_claim_event)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Year_of_Claim_Event = ",
       tbl_alias,".activity_year"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_denial_smry_fields,char(128))=char(128))
  SUBROUTINE (add_denial_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].denial_billed_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Denial_Billed_Amount = ",
       tbl_alias,".denial_billed_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].year_of_denial)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Year_Of_Denial = ",tbl_alias,
       ".activity_year"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_patient_ar_bal_smry,char(128))=char(128))
  SUBROUTINE (add_patient_ar_bal_smry(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_encntrs_final_coded)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Encntrs_Final_Coded = ",
       tbl_alias,".total_encounter_final_coded"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].discharge_final_coded_avg_days)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Discharge_Final_Coded_Avg_Days = ",tbl_alias,
       ".tot_dschrg_final_code_days"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_encntrs_final_coded_by_eod)=1)
     CALL add_where(concat(
       "reply_obj->objArray[reply_obj->qual_cnt].Total_Encntrs_Final_Coded_By_EOD = ",tbl_alias,
       ".tot_encntr_final_code_by_end"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_balance_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Balance_Amount = ",
       tbl_alias,".total_balance_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_zero_balance_count)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Zero_Balance_Count = ",
       tbl_alias,".total_zero_balance_cnt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_trans_smry_fields,char(128))=char(128))
  SUBROUTINE (add_trans_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_transaction_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_Transaction_amt = ",
       tbl_alias,".total_transaction_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].year_of_transaction)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Year_Of_Transaction = ",
       tbl_alias,".activity_year"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].DAILY_AMOUNT = ",tbl_alias,
       ".total_transaction_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_units)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].total_units = ",tbl_alias,
       ".total_service_units"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_trans_year_fields,char(128))=char(128))
  SUBROUTINE (add_trans_year_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].ytd_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].YTD_AMOUNT = ",tbl_alias,
       ".total_trans_amt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_trans_monthly_smry_fields,char(128))=char(128))
  SUBROUTINE (add_trans_monthly_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].mtd_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].MTD_AMOUNT = ",tbl_alias,
       ".total_trans_amt"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_month_fields,char(128))=char(128))
  SUBROUTINE (add_month_fields(tbl_alias=vc) =null)
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].month_abbreviation)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Month_Abbreviation = ",tbl_alias,
      ".month_abbreviation"))
   ENDIF
   IF (validate(reply_obj->objarray[reply_obj->qual_cnt].month_name)=1)
    CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Month_Name = ",tbl_alias,
      ".month_name"))
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_invoice_ar_balance_fields,char(128))=char(128))
  SUBROUTINE (add_invoice_ar_balance_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].org_bill_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Org_bill_date = ",tbl_alias,
       ".original_bill_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_charge_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_charge_amt = ",tbl_alias,
       ".daily_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_payment_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_payment_amt = ",tbl_alias,
       ".daily_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_adjust_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_Adjust_amt = ",tbl_alias,
       ".daily_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_charge_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_charge_amt = ",tbl_alias,
       ".total_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_payment_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_payment_amt = ",tbl_alias,
       ".total_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].total_adjust_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Total_Adjust_amt = ",tbl_alias,
       ".total_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].balance)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Balance = ",tbl_alias,
       ".balance_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_age)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_age = ",tbl_alias,
       ".bill_age"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].bill_number_ident)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Bill_number_ident = ",tbl_alias,
       ".bill_number_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_general_ar_balance_fields,char(128))=char(128))
  SUBROUTINE (add_general_ar_balance_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_payment_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_payment_amt = ",tbl_alias,
       ".total_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_adjust_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_adjust_amt = ",tbl_alias,
       ".total_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_payment_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_payment_amt = ",tbl_alias,
       ".daily_payment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_adjust_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Daily_adjust_amt = ",tbl_alias,
       ".daily_adjustment_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].balance)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Balance = ",tbl_alias,
       ".balance_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_account_fields,char(128))=char(128))
  SUBROUTINE (add_account_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].account_desp)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Account_desp = ",tbl_alias,
       ".account_description"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].account_ident)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Account_ident = ",tbl_alias,
       ".account_ident"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].account_sub_type)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Account_sub_type = ",tbl_alias,
       ".account_sub_type"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_tier_group_fields,char(128))=char(128))
  SUBROUTINE (add_tier_group_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tier_group_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].tier_group_name = ",tbl_alias,
       ".tier_group_name"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(add_cdm_smry_fields,char(128))=char(128))
  SUBROUTINE (add_cdm_smry_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].tot_charge_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Tot_Charge_amt = ",tbl_alias,
       ".total_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].year_of_transaction)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Year_Of_Transaction = ",
       tbl_alias,".activity_year"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].activity_date)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Activity_Date = ",tbl_alias,
       ".activity_dt_nbr"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].daily_amount)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].DAILY_AMOUNT = ",tbl_alias,
       ".total_charge_amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].unit_price_amt)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Unit_Price_Amt = ",tbl_alias,
       ".Unit_Price_Amt"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].relative_value_units_qty)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].relative_value_units_qty = ",
       tbl_alias,".relative_value_units_qty"))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(create_prod_amt_clause,char(128))=char(128))
  SUBROUTINE (create_prod_amt_clause(arg_rec=vc(ref),col_atrib=vc) =vc)
    DECLARE in_clause = vc WITH private, noconstant("")
    DECLARE range_lvl = f8 WITH private, noconstant(0.0)
    SET range_lvl = arg_rec->objarray[1].darg_value
    CASE (range_lvl)
     OF 1:
      SET in_clause = concat(col_atrib,">=0.00"," and ",col_atrib,"<= 500.00")
     OF 2:
      SET in_clause = concat(col_atrib,">=501.00"," and ",col_atrib,"<= 1500.00")
     OF 3:
      SET in_clause = concat(col_atrib,">=1501.00"," and ",col_atrib,"<= 5000.00")
     OF 4:
      SET in_clause = concat(col_atrib,">=5001.00"," and ",col_atrib,"<= 10000.00")
     OF 5:
      SET in_clause = concat(col_atrib,">=10001.00"," and ",col_atrib,"<= 20000.00")
     OF 6:
      SET in_clause = concat(col_atrib,">=20001.00"," and ",col_atrib,"<= 50000.00")
     OF 7:
      SET in_clause = concat(col_atrib,">=50001.00"," and ",col_atrib,"<= 100000.00")
     OF 8:
      SET in_clause = concat(col_atrib,">=100001.00")
    ENDCASE
    RETURN(in_clause)
  END ;Subroutine
 ENDIF
 SUBROUTINE (checkerrors(pft_failed=i2(ref)) =i2)
   DECLARE errmsg = vc WITH noconstant(" ")
   DECLARE errcode = i2 WITH noconstant(1)
   SET errcode = error(errmsg,0)
   IF (errcode=0)
    IF (pft_failed != true)
     SET pft_failed = 0
    ENDIF
   ELSE
    SET pft_failed = 1
   ENDIF
 END ;Subroutine
 IF (validate(add_rend_physician_fields,char(128))=char(128))
  SUBROUTINE (add_rend_physician_fields(tbl_alias=vc) =null)
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].rend_phys_person_first_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Rend_Phys_Person_First_Name = ",
       tbl_alias,".person_first_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].rend_phys_person_full_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Rend_Phys_Person_Full_Name = ",
       tbl_alias,".person_full_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].rend_phys_person_last_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Rend_Phys_Person_Last_Name = ",
       tbl_alias,".person_last_name"))
    ENDIF
    IF (validate(reply_obj->objarray[reply_obj->qual_cnt].rend_phys_person_middle_name)=1)
     CALL add_where(concat("reply_obj->objArray[reply_obj->qual_cnt].Rend_Phys_Person_Middle_Name = ",
       tbl_alias,".person_middle_name"))
    ENDIF
  END ;Subroutine
 ENDIF
 CALL echo("Begin PFT_MPAGE_HTML_SUBS.INC, version [305653.000]")
 SUBROUTINE (getfileasstring(pfilename=vc,pfilereturnstring=vc(ref)) =i2)
   FREE RECORD frec
   RECORD frec(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   ) WITH protect
   DECLARE bytes = i4 WITH protect, noconstant(0)
   DECLARE fileexists = i2 WITH protect, noconstant(false)
   SET frec->file_name = trim(pfilename)
   CALL echo(build("Opening:",frec->file_name))
   SET frec->file_buf = "r"
   SET fileexists = cclio("OPEN",frec)
   IF (fileexists)
    SET frec->file_buf = notrim(fillstring(100000," "))
    WHILE (cclio("EOF",frec)=0)
     SET bytes = cclio("READ",frec)
     SET pfilereturnstring = notrim(concat(pfilereturnstring,substring(1,bytes,frec->file_buf)))
    ENDWHILE
   ELSE
    CALL logmessage("getFileAsString",concat("Unable to find the file:",pfilename),log_error)
    CALL echorecord(frec)
    RETURN(false)
   ENDIF
   SET stat = cclio("CLOSE",frec)
   IF (findstring(char(13),pfilereturnstring,1,0)=0)
    SET pfilereturnstring = replace(pfilereturnstring,char(10),concat(char(13),char(10)))
   ENDIF
   SET pfilereturnstring = trim(pfilereturnstring,2)
   RETURN(true)
 END ;Subroutine
 IF (validate(getstylesheetrootpath,char(128))=char(128))
  SUBROUTINE (getstylesheetrootpath(rootpath=vc(ref)) =i2)
    SET rootpath = ""
    SELECT INTO "nl"
     FROM dm_info di
     WHERE di.info_name="FE_WH"
     DETAIL
      rootpath = trim(di.info_char)
     WITH nocounter
    ;end select
    IF (trim(rootpath)="")
     CALL logmessage("GetStyleSheetRootPath","Did not find root path",log_debug)
     RETURN(false)
    ENDIF
    SET lstat = 0
    SET lstat = findstring("winintel",rootpath)
    IF (lstat=0)
     SET rootpath = concat(rootpath,"\winintel")
    ENDIF
    SET rootpath = replace(rootpath,"\","\\",0)
    SET rootpath = replace(rootpath,"/","\\",0)
    SET rootpath = concat(rootpath,"\\STATIC_CONTENT")
    FREE RECORD frec
    RETURN(true)
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
 IF ( NOT (validate(reply_obj)))
  RECORD reply_obj(
    1 qual_cnt = i4
    1 objarray[*]
      2 bill_item_id = f8
      2 parent_reference_id = f8
      2 child_reference_id = f8
      2 long_description = vc
      2 short_description = vc
      2 activity_type = vc
      2 sub_activity_type = vc
      2 stats_only_ind = vc
      2 misc_ind = vc
      2 bill_item_type = vc
      2 bill_item_sched = vc
      2 chrg_level = vc
      2 chrg_point = vc
      2 chrg_attributes = vc
      2 bill_code = vc
      2 bill_code_qcf = f8
      2 cdm_sched_desc = vc
      2 price = vc
      2 ao_description = vc
      2 ao_bill_item_id = f8
      2 ao_qty = f8
      2 nc_result = vc
      2 nc_auth = vc
      2 nc_supp_info = vc
  ) WITH protect
 ENDIF
 RECORD facility_list(
   1 arg_value_list_cnt = i4
   1 objarray[*]
     2 darg_value = f8
     2 iarg_value = i4
     2 sarg_value = vc
 ) WITH protect
 RECORD org_list(
   1 arg_value_list_cnt = i4
   1 objarray[*]
     2 darg_value = f8
     2 iarg_value = i4
     2 sarg_value = vc
 ) WITH protect
 RECORD schd_list(
   1 arg_value_list_cnt = i4
   1 objarray[*]
     2 darg_value = f8
     2 iarg_value = i4
     2 sarg_value = vc
 ) WITH protect
 RECORD bill_item_audit(
   1 bia_cnt = i4
   1 bia_detail[*]
     2 bill_item_id = f8
     2 parent_reference_id = f8
     2 child_reference_id = f8
     2 child_contributor_cd = f8
     2 long_description = vc
     2 short_description = vc
     2 activity_type_cd = f8
     2 activity_type = vc
     2 sub_activity_type = vc
     2 stats_only_ind = i2
     2 misc_ind = i2
     2 cp_cnt = i4
     2 cp_detail[*]
       3 cp_bi_mod_id = f8
       3 chrg_point_sched_cd = f8
       3 chrg_point_sched = vc
       3 chrg_point = vc
       3 chrg_level = vc
       3 chrg_attributes = vc
     2 bc_cnt = i4
     2 bc_detail[*]
       3 bc_bi_mod_id = f8
       3 bill_code_sched_cd = f8
       3 bill_code = vc
       3 bill_code_qcf = f8
       3 cdm_sched_desc = vc
       3 bc_item_interval_id = f8
     2 p_cnt = i4
     2 p_detail[*]
       3 price_sched_items_id = f8
       3 price_sched_id = f8
       3 price_sched_desc = vc
       3 price = vc
       3 price_beg_date = vc
       3 price_end_date = vc
       3 interval_template_cd = f8
       3 i_detail[*]
         4 item_interval_id = f8
         4 calc_type_cd = f8
         4 unit_type_cd = f8
         4 unit_factor = vc
         4 interval_beg_value = f8
         4 interval_end_value = f8
         4 interval_price = vc
     2 ao_cnt = i4
     2 ao_detail[*]
       3 ao_bi_mod_id = f8
       3 ao_description = vc
       3 ao_bill_item_id = f8
       3 ao_qty = f8
     2 nc_cnt = i4
     2 nc_detail[*]
       3 nc_bi_mod_id = f8
       3 nc_sched_cd = f8
       3 nc_result = vc
       3 nc_auth = vc
       3 nc_supp_info = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD schedules(
   1 price_cnt = i4
   1 price_detail[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
   1 bill_code_cnt = i4
   1 bill_code_detail[*]
     2 bill_code_cd = f8
     2 bill_code_desc = vc
     2 bill_code_sched_type = f8
   1 chrg_process_cnt = i4
   1 chrg_process_detail[*]
     2 chrg_process_cd = f8
     2 chrg_process_desc = vc
   1 non_covered_cnt = i4
   1 non_covered_detail[*]
     2 non_covered_cd = f8
     2 non_covered_desc = vc
     2 non_covered_sched_type = f8
 ) WITH protect
 DECLARE cs13036_coverage_sched_cd = f8 WITH protect, constant(getcodevalue(13036,"COVERAGE",1))
 DECLARE cs13036_charge_point_cd = f8 WITH protect, constant(getcodevalue(13036,"CHARGE POINT",0))
 DECLARE cs13036_cdm_sched_cd = f8 WITH protect, constant(getcodevalue(13036,"CDM_SCHED",0))
 DECLARE cs13036_cpt4_cd = f8 WITH protect, constant(getcodevalue(13036,"CPT4",0))
 DECLARE cs13036_hcpcs_cd = f8 WITH protect, constant(getcodevalue(13036,"HCPCS",0))
 DECLARE cs13036_modifier_cd = f8 WITH protect, constant(getcodevalue(13036,"MODIFIER",0))
 DECLARE cs13036_price_sched_cd = f8 WITH protect, constant(getcodevalue(13036,"PRICESCHED",0))
 DECLARE cs13036_revenue_cd = f8 WITH protect, constant(getcodevalue(13036,"REVENUE",0))
 DECLARE cs13036_procedure_cd = f8 WITH protect, constant(getcodevalue(13036,"PROCCODE",0))
 DECLARE cs14002_pharm_cdm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14002,
   "CDMSCHEDPHARM"))
 DECLARE cs278_client_org_type_cd = f8 WITH protect, constant(getcodevalue(278,"CLIENT",0))
 DECLARE cs13019_chrg_point_sch_cd = f8 WITH protect, constant(getcodevalue(13019,"CHARGE POINT",0))
 DECLARE cs13019_bill_code_sch_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 DECLARE cs13019_interval_code = f8 WITH protect, constant(getcodevalue(13019,"INTERVALCODE",0))
 DECLARE cs13019_add_on_assigned_cd = f8 WITH protect, constant(getcodevalue(13019,"ADD ON",0))
 DECLARE cs13019_noncovered_cd = f8 WITH protect, constant(getcodevalue(13019,"NONCOVERED",1))
 DECLARE cs13019_alpha_response_cd = f8 WITH protect, constant(getcodevalue(13016,"ALPHA RESP",0))
 DECLARE cs106_rad_activity_type_cd = f8 WITH protect, constant(getcodevalue(106,"RADIOLOGY",0))
 DECLARE cs106_pharm_activity_type_cd = f8 WITH protect, constant(getcodevalue(106,"PHARMACY",0))
 DECLARE cs11000_ndc_med_id_type_cd = f8 WITH protect, constant(getcodevalue(11000,"NDC",0))
 DECLARE cs11000_cdm_med_id_type_cd = f8 WITH protect, constant(getcodevalue(11000,"CDM",0))
 DECLARE cs4500_inpt_pharmacy_type_cd = f8 WITH protect, constant(getcodevalue(4500,"INPATIENT",0))
 DECLARE cs222_facility_location_type_cd = f8 WITH protect, constant(getcodevalue(222,"FACILITY",0))
 DECLARE cs4062_syspkgtyp_flex_type_cd = f8 WITH protect, constant(getcodevalue(4062,"SYSPKGTYP",0))
 DECLARE cs4062_system_flex_type_cd = f8 WITH protect, constant(getcodevalue(4062,"SYSTEM",0))
 DECLARE pharm_cdm_cnvtstring_temp = vc WITH protect, constant(trim(cnvtstring(cs14002_pharm_cdm_cd))
  )
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_is_rad = i2 WITH protect, noconstant(false)
 DECLARE activity_type_is_pharm = i2 WITH protect, noconstant(false)
 DECLARE pharm_cdm_exists = i2 WITH protect, noconstant(false)
 DECLARE chrg_process_cd_parser = vc WITH protect, noconstant(" ")
 DECLARE price_id_parser = vc WITH protect, noconstant(" ")
 DECLARE price_interval_parser = vc WITH protect, noconstant(" ")
 DECLARE bill_code_cd_parser = vc WITH protect, noconstant(" ")
 DECLARE non_covered_cd_parser = vc WITH protect, noconstant(" ")
 DECLARE organizationparser = vc WITH protect, noconstant(" ")
 DECLARE domainfacilities = vc WITH protect, noconstant(" ")
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE num2 = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE pos2 = i4 WITH protect, noconstant(0)
 DECLARE orginclauseind = i2 WITH protect, noconstant(false)
 DECLARE orginclause = vc WITH protect, noconstant("")
 DECLARE email_address = vc WITH protect, noconstant(" ")
 DECLARE email_file_name = vc WITH protect, noconstant(" ")
 DECLARE output_type = vc WITH protect, noconstant(" ")
 DECLARE tab_char = vc WITH protect, constant(char(09))
 DECLARE row_detail = vc WITH protect, noconstant(" ")
 DECLARE bill_item_detail = vc WITH protect, noconstant(" ")
 DECLARE total_header = vc WITH protect, noconstant(" ")
 DECLARE bi_header = vc WITH protect, constant(concat("BILL_ITEM_ID",tab_char,"PARENT_REFERENCE_ID",
   tab_char,"CHILD_REFERENCE_ID",
   tab_char,"LONG_DESCRIPTION",tab_char,"SHORT_DESCRIPTION",tab_char,
   "ACTIVITY_TYPE",tab_char,"ACTIVITY_SUB_TYPE",tab_char,"STATS_ONLY",
   tab_char,"MISC_IND",tab_char))
 DECLARE bi_interval_header = vc WITH protect, constant(concat("BILL_ITEM_ID",tab_char,
   "PARENT_REFERENCE_ID",tab_char,"CHILD_REFERENCE_ID",
   tab_char,"LONG_DESCRIPTION",tab_char,"SHORT_DESCRIPTION",tab_char,
   "ACTIVITY_TYPE",tab_char,"ACTIVITY_SUB_TYPE",tab_char))
 DECLARE interval_details_header = vc WITH protect, constant(concat("PRICE_SCHEDULE",tab_char,
   "PRICE_SCHED_BEG_DATE",tab_char,"PRICE_SCHED_END_DATE",
   tab_char,"INTERVAL_TEMPLATE",tab_char,"FLEX_BILL_CODES",tab_char,
   "INTERVAL_BEGIN",tab_char,"INTERVAL_END",tab_char,"INTERVAL_CALCULATION_TYPE",
   tab_char,"UNIT_TYPE",tab_char,"FACTOR",tab_char,
   "PRICE",tab_char))
 DECLARE interval_bill_codes_header = vc WITH protect, constant(concat("CDM_SCHEDULE",tab_char,"CDM",
   tab_char,"CDM_DESCRIPTION",
   tab_char,"CPT_SCHEDULE",tab_char,"CPT",tab_char,
   "HCPCS_SCHEDULE",tab_char,"HCPCS",tab_char,"CPT_MODIFIER_SCHEDULE",
   tab_char,"CPT_MODIFIER",tab_char,"ICD_PROCEDURE_SCHEDULE",tab_char,
   "ICD_PROCEDURE",tab_char))
 DECLARE cp_header = vc WITH protect, noconstant(" ")
 DECLARE price_header = vc WITH protect, noconstant(" ")
 DECLARE bc_header = vc WITH protect, noconstant(" ")
 DECLARE ao_header = vc WITH protect, constant(concat("GENERIC ADD-ONS",tab_char))
 DECLARE non_covered_header = vc WITH protect, noconstant(" ")
 DECLARE display_message = vc WITH protect, noconstant(" ")
 DECLARE ao_quantity = vc WITH protect, noconstant(" ")
 DECLARE dclcom = vc WITH protect, noconstant(" ")
 DECLARE status = i2 WITH protect, noconstant(0)
 DECLARE pharm_cdm_findstring = i4 WITH protect, noconstant(0)
 DECLARE len = i4 WITH protect, noconstant(0)
 DECLARE dclstat = i4 WITH protect, noconstant(0)
 DECLARE sub_act_type_temp = f8 WITH protect, noconstant(0.0)
 DECLARE charge_processing_ind = i2 WITH protect, noconstant(false)
 DECLARE price_sched_ind = i2 WITH protect, noconstant(false)
 DECLARE bill_code_ind = i2 WITH protect, noconstant(false)
 DECLARE coverage_ind = i2 WITH protect, noconstant(false)
 DECLARE audit_intervals_ind = i2 WITH protect, noconstant(false)
 DECLARE sfilelinuxversiontemp = vc WITH protect, constant(build2("rpt_os_ver.dat"))
 DECLARE sdcloutput = vc WITH protect, noconstant("")
 DECLARE sversion = vc WITH protect, noconstant("")
 DECLARE slinuxversion = i4 WITH protect, noconstant(0)
 DECLARE nc_result_covered = vc WITH protect, constant("Covered")
 DECLARE nc_result_non_covered = vc WITH protect, constant("Non Covered")
 DECLARE nc_result_auth_cond = vc WITH protect, constant("Conditional")
 DECLARE nc_result_na = vc WITH protect, constant("N/A")
 DECLARE nc_auth_yes = vc WITH protect, constant("Yes")
 DECLARE nc_auth_no = vc WITH protect, constant("No")
 DECLARE nc_unknown = vc WITH protect, constant("Unknown")
 DECLARE cdm_opt_drug_formulation = i2 WITH protect, constant(1)
 DECLARE cdm_opt_manufactured_item = i2 WITH protect, constant(0)
 DECLARE emptyoranyactivityind = i2 WITH constant(parameter(6,1))
 IF (( $EMAIL_TO != ""))
  SET email_address = trim( $EMAIL_TO)
 ENDIF
 DECLARE eff_dt_tm = dq8 WITH constant(cnvtdatetime( $EFF_DATE)), protect
 IF ( NOT (getlogicaldomain(ld_concept_prsnl,logicaldomainid)))
  CALL exitservicefailure("Unable to retrieve LOGICAL_DOMAIN_ID",true)
 ENDIF
 CALL parsearguments(5,org_list,"F8")
 IF (validate(debug,0)=1)
  CALL echorecord(org_list)
 ENDIF
 CALL parsearguments(7,schd_list,"I4")
 IF (validate(debug,0)=1)
  CALL echorecord(schd_list)
 ENDIF
 IF ((org_list->arg_value_list_cnt > 0))
  FOR (reclistcnt = 1 TO org_list->arg_value_list_cnt)
    IF ((org_list->objarray[reclistcnt].darg_value > 0))
     IF (orginclauseind=false)
      SET orginclause = cnvtstring(org_list->objarray[reclistcnt].darg_value,17,1)
      SET orginclauseind = true
     ELSE
      SET orginclause = concat(orginclause,", ",cnvtstring(org_list->objarray[reclistcnt].darg_value,
        17,1))
     ENDIF
    ENDIF
  ENDFOR
  CALL echo(build2("org clause",orginclause))
  IF (trim(orginclause,3) != "")
   SET organizationparser = concat(organizationparser," o.organization_id IN (",orginclause,") ")
  ENDIF
 ELSE
  SET organizationparser = "1=1"
 ENDIF
 IF ((schd_list->arg_value_list_cnt=0))
  SET charge_processing_ind = true
  SET price_sched_ind = true
  SET bill_code_ind = true
  SET coverage_ind = true
  SET audit_intervals_ind = false
 ELSE
  FOR (schlistcnt = 1 TO schd_list->arg_value_list_cnt)
    IF ((schd_list->objarray[schlistcnt].iarg_value=0))
     SET charge_processing_ind = true
     SET price_sched_ind = true
     SET bill_code_ind = true
     SET coverage_ind = true
     SET audit_intervals_ind = false
    ELSEIF ((schd_list->objarray[schlistcnt].iarg_value=1))
     SET charge_processing_ind = true
    ELSEIF ((schd_list->objarray[schlistcnt].iarg_value=2))
     SET price_sched_ind = true
    ELSEIF ((schd_list->objarray[schlistcnt].iarg_value=3))
     SET bill_code_ind = true
    ELSEIF ((schd_list->objarray[schlistcnt].iarg_value=4))
     SET coverage_ind = true
     IF (cs13036_coverage_sched_cd=0.0)
      SET coverage_ind = false
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (( $AUDIT_MODE="2"))
  SET audit_intervals_ind = true
  SET charge_processing_ind = false
  SET price_sched_ind = true
  SET bill_code_ind = true
  SET coverage_ind = false
  SET price_interval_parser = "psi.interval_template_cd > 0.0"
 ELSE
  SET price_interval_parser = "1=1"
 ENDIF
 IF (validate(debug))
  CALL echo("Indicator value")
  CALL echo(build2("Charge Processing ind:",charge_processing_ind))
  CALL echo(build2("price sched ind:",price_sched_ind))
  CALL echo(build2("bill code ind:",bill_code_ind))
  CALL echo(build2("coverage ind:",coverage_ind))
  CALL echo(build2("audit intervals ind:",audit_intervals_ind))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  bi.ext_owner_cd
  FROM bill_item bi
  WHERE (((bi.ext_owner_cd= $ACT_TYPE)) OR ((emptyoranyactivityind=- (1))
   AND bi.ext_owner_cd > 0.0))
  DETAIL
   IF (bi.ext_owner_cd=cs106_pharm_activity_type_cd)
    activity_type_is_pharm = true
   ENDIF
   IF (bi.ext_owner_cd=cs106_rad_activity_type_cd)
    activity_type_is_rad = true
   ENDIF
  WITH nocounter
 ;end select
 IF (retrievefromtier(true))
  SET pharm_cdm_findstring = findstring(pharm_cdm_cnvtstring_temp,bill_code_cd_parser,1,0)
  IF (pharm_cdm_findstring > 0)
   SET pharm_cdm_exists = true
  ENDIF
  IF (validate(debug))
   CALL echo(build2("Pharmacy present ind:",pharm_cdm_exists))
  ENDIF
  IF (audit_intervals_ind=false)
   CALL retrievefrombillitem(bill_code_cd_parser,chrg_process_cd_parser,non_covered_cd_parser)
   IF (pharm_cdm_exists=true
    AND activity_type_is_pharm=true)
    CALL retrievepharmacy(domainfacilities)
   ENDIF
   IF (price_sched_ind=true)
    CALL retrievepricesched(logicaldomainid,price_id_parser)
   ENDIF
  ELSE
   CALL retrievepricesched(logicaldomainid,price_id_parser)
   CALL retrieveintervalbillcodes(bill_code_cd_parser)
  ENDIF
  IF (activity_type_is_rad=true)
   CALL updateradiologyinfo(1)
  ENDIF
  CALL updateactivityforalpharesponse(1)
  IF (audit_intervals_ind=false)
   CALL generatecsv(1)
  ELSE
   CALL generateintervalcsv(1)
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", display_message = build2(
     "There is no data to output.  Consider changing the prompt selections."), row 0,
    col 0, display_message
   WITH nocounter, nullreport, maxcol = 300,
    dio = postscript
  ;end select
 ENDIF
 SUBROUTINE (retrievefromtier(dummyvar=i2) =i2)
   SELECT DISTINCT INTO "nl:"
    tier_cell_display =
    IF (tm.tier_cell_entity_name="CODE_VALUE") trim(uar_get_code_display(tm.tier_cell_value_id))
    ELSEIF (tm.tier_cell_entity_name="PRICE_SCHED") trim(ps.price_sched_desc)
    ENDIF
    , tier_cell_type_meaning = uar_get_code_meaning(tm.tier_cell_type_cd)
    FROM org_type_reltn otr,
     organization o,
     bill_org_payor bop,
     tier_matrix tm,
     price_sched ps
    PLAN (otr
     WHERE otr.org_type_cd=cs278_client_org_type_cd)
     JOIN (o
     WHERE o.organization_id=otr.organization_id
      AND o.logical_domain_id=logicaldomainid
      AND parser(organizationparser))
     JOIN (bop
     WHERE bop.organization_id=o.organization_id
      AND bop.bill_org_type_cd IN (
     (SELECT
      cv3.code_value
      FROM code_value cv3
      WHERE ((cv3.code_set+ 0)=13031)
       AND trim(cv3.cdf_meaning) IN ("CLTTIERGROUP", "TIERGROUP")
       AND cv3.active_ind=1))
      AND bop.active_ind=1
      AND bop.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND bop.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (tm
     WHERE tm.tier_group_cd=bop.bill_org_type_id
      AND tm.tier_cell_type_cd IN (cs13036_charge_point_cd, cs13036_cdm_sched_cd, cs13036_cpt4_cd,
     cs13036_hcpcs_cd, cs13036_modifier_cd,
     cs13036_price_sched_cd, cs13036_revenue_cd, cs13036_coverage_sched_cd, cs13036_procedure_cd)
      AND tm.active_ind=1
      AND tm.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
      AND tm.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
     JOIN (ps
     WHERE (ps.price_sched_id= Outerjoin(tm.tier_cell_value_id))
      AND (ps.active_ind= Outerjoin(1))
      AND (ps.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (ps.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY tier_cell_type_meaning, tier_cell_display
    HEAD REPORT
     price_cnt = 0, bill_code_cnt = 0, chrg_process_cnt = 0,
     non_covered_cnt = 0
    DETAIL
     IF (tm.tier_cell_type_cd=cs13036_charge_point_cd
      AND charge_processing_ind=true)
      chrg_process_cnt += 1, stat = alterlist(schedules->chrg_process_detail,chrg_process_cnt),
      schedules->chrg_process_detail[chrg_process_cnt].chrg_process_cd = tm.tier_cell_value_id,
      schedules->chrg_process_detail[chrg_process_cnt].chrg_process_desc = trim(uar_get_code_display(
        tm.tier_cell_value_id),3)
      IF (textlen(chrg_process_cd_parser)=0)
       chrg_process_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
      ELSE
       chrg_process_cd_parser = concat(chrg_process_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0
         ))
      ENDIF
      cp_header = concat(cp_header,trim(schedules->chrg_process_detail[chrg_process_cnt].
        chrg_process_desc),tab_char)
     ELSEIF (tm.tier_cell_type_cd=cs13036_price_sched_cd
      AND price_sched_ind=true)
      price_cnt += 1
      IF (mod(price_cnt,5)=1)
       stat = alterlist(schedules->price_detail,(price_cnt+ 4))
      ENDIF
      schedules->price_detail[price_cnt].price_sched_id = tm.tier_cell_value_id, schedules->
      price_detail[price_cnt].price_sched_desc = trim(ps.price_sched_desc)
      IF (textlen(price_id_parser)=0)
       price_id_parser = cnvtstring(tm.tier_cell_value_id,0)
      ELSE
       price_id_parser = concat(price_id_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
      ENDIF
      price_header = concat(price_header,trim(schedules->price_detail[price_cnt].price_sched_desc),
       tab_char)
     ELSEIF (tm.tier_cell_type_cd=cs13036_coverage_sched_cd
      AND coverage_ind=true)
      non_covered_cnt += 1
      IF (mod(non_covered_cnt,5)=1)
       stat = alterlist(schedules->non_covered_detail,(non_covered_cnt+ 4))
      ENDIF
      schedules->non_covered_detail[non_covered_cnt].non_covered_cd = tm.tier_cell_value_id,
      schedules->non_covered_detail[non_covered_cnt].non_covered_desc = trim(uar_get_code_display(tm
        .tier_cell_value_id)), schedules->non_covered_detail[non_covered_cnt].non_covered_sched_type
       = tm.tier_cell_type_cd
      IF (textlen(non_covered_cd_parser)=0)
       non_covered_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
      ELSE
       non_covered_cd_parser = concat(non_covered_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
      ENDIF
      non_covered_header = concat(non_covered_header,trim(schedules->non_covered_detail[
        non_covered_cnt].non_covered_desc),tab_char)
     ELSEIF (bill_code_ind=true
      AND audit_intervals_ind=false
      AND tm.tier_cell_type_cd != cs13036_coverage_sched_cd
      AND tm.tier_cell_type_cd != cs13036_price_sched_cd
      AND tm.tier_cell_type_cd != cs13036_charge_point_cd
      AND tm.tier_cell_type_cd != cs13036_procedure_cd)
      bill_code_cnt += 1
      IF (mod(bill_code_cnt,5)=1)
       stat = alterlist(schedules->bill_code_detail,(bill_code_cnt+ 4))
      ENDIF
      schedules->bill_code_detail[bill_code_cnt].bill_code_cd = tm.tier_cell_value_id, schedules->
      bill_code_detail[bill_code_cnt].bill_code_desc = trim(uar_get_code_display(tm
        .tier_cell_value_id)), schedules->bill_code_detail[bill_code_cnt].bill_code_sched_type = tm
      .tier_cell_type_cd
      IF (textlen(bill_code_cd_parser)=0)
       bill_code_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
      ELSE
       bill_code_cd_parser = concat(bill_code_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
      ENDIF
      IF (tm.tier_cell_type_cd=cs13036_hcpcs_cd)
       combine_desc_qcf = concat(" ^ QCF"), bc_header = concat(bc_header,schedules->bill_code_detail[
        bill_code_cnt].bill_code_desc,trim(combine_desc_qcf),tab_char)
      ELSEIF (tm.tier_cell_type_cd=cs13036_cdm_sched_cd)
       combine_desc_cdm = concat(trim(substring(1,100,schedules->bill_code_detail[bill_code_cnt].
          bill_code_desc))," - Description"), bc_header = concat(bc_header,schedules->
        bill_code_detail[bill_code_cnt].bill_code_desc,tab_char,trim(combine_desc_cdm),tab_char)
      ELSE
       bc_header = concat(bc_header,schedules->bill_code_detail[bill_code_cnt].bill_code_desc,
        tab_char)
      ENDIF
     ELSEIF (bill_code_ind=true
      AND audit_intervals_ind=true
      AND tm.tier_cell_type_cd != cs13036_coverage_sched_cd
      AND tm.tier_cell_type_cd != cs13036_price_sched_cd
      AND tm.tier_cell_type_cd != cs13036_charge_point_cd
      AND tm.tier_cell_type_cd != cs13036_revenue_cd)
      bill_code_cnt += 1
      IF (mod(bill_code_cnt,5)=1)
       stat = alterlist(schedules->bill_code_detail,(bill_code_cnt+ 4))
      ENDIF
      schedules->bill_code_detail[bill_code_cnt].bill_code_cd = tm.tier_cell_value_id, schedules->
      bill_code_detail[bill_code_cnt].bill_code_desc = trim(uar_get_code_display(tm
        .tier_cell_value_id)), schedules->bill_code_detail[bill_code_cnt].bill_code_sched_type = tm
      .tier_cell_type_cd
      IF (textlen(bill_code_cd_parser)=0)
       bill_code_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
      ELSE
       bill_code_cd_parser = concat(bill_code_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (charge_processing_ind=true
      AND textlen(chrg_process_cd_parser) != 0)
      chrg_process_cd_parser = concat(" bim.key1_id in (",chrg_process_cd_parser,")")
     ELSE
      chrg_process_cd_parser = concat("0 = 1")
     ENDIF
     IF (price_sched_ind=true
      AND textlen(price_id_parser) != 0)
      price_id_parser = concat(" psi.price_sched_id in (",price_id_parser,")")
     ELSE
      price_id_parser = concat("0 = 1")
     ENDIF
     IF (bill_code_ind=true
      AND textlen(bill_code_cd_parser) != 0)
      bill_code_cd_parser = concat(" bim.key1_id in (",bill_code_cd_parser,")")
     ELSE
      bill_code_cd_parser = concat("0 = 1")
     ENDIF
     IF (coverage_ind=true
      AND textlen(non_covered_cd_parser) != 0)
      non_covered_cd_parser = concat(" bim.key1_id in (",non_covered_cd_parser,")")
     ELSE
      non_covered_cd_parser = concat("0 = 1")
     ENDIF
     stat = alterlist(schedules->price_detail,price_cnt), schedules->price_cnt = price_cnt, stat =
     alterlist(schedules->bill_code_detail,bill_code_cnt),
     schedules->bill_code_cnt = bill_code_cnt, stat = alterlist(schedules->chrg_process_detail,
      chrg_process_cnt), schedules->chrg_process_cnt = chrg_process_cnt,
     stat = alterlist(schedules->non_covered_detail,non_covered_cnt), schedules->non_covered_cnt =
     non_covered_cnt
     IF (validate(debug))
      CALL echo(build2("charge process : ",chrg_process_cd_parser)),
      CALL echo(build2("price Id : ",price_id_parser)),
      CALL echo(build2("Bill Code : ",bill_code_cd_parser)),
      CALL echo(build2("non covered parser :",non_covered_cd_parser)),
      CALL echo(build2("Activity Type parser :", $ACT_TYPE)),
      CALL echo(build2("emptyOrAnyActivityInd :",emptyoranyactivityind))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (retrievefrombillitem(billcodecd=vc,chrgprocesscd=vc,noncoveredcd=vc) =i2)
  SELECT INTO "nl:"
   bill_code_sched_meaning = uar_get_code_meaning(bim.key1_id), bill_code_sched_display =
   uar_get_code_display(bim.key1_id)
   FROM bill_item bi,
    bill_item_modifier bim
   PLAN (bi
    WHERE (((bi.ext_owner_cd= $ACT_TYPE)
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) ) OR (((bi.ext_owner_cd=0.00
     AND bi.ext_child_contributor_cd=cs13019_alpha_response_cd) OR ((emptyoranyactivityind=- (1))
     AND bi.ext_owner_cd > 0.0
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) )) ))
     AND ((bi.active_ind+ 0)=1)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND ((((bim.bill_item_type_cd+ 0)=cs13019_chrg_point_sch_cd)
     AND parser(chrgprocesscd)
     AND charge_processing_ind=true) OR (((((bim.bill_item_type_cd+ 0)=cs13019_bill_code_sch_cd)
     AND parser(billcodecd)
     AND bill_code_ind=true) OR (((((bim.bill_item_type_cd+ 0)=cs13019_add_on_assigned_cd)
     AND  EXISTS (
    (SELECT
     bi2.bill_item_id
     FROM bill_item bi2
     WHERE bi2.bill_item_id=bim.key1_id
      AND ((bi2.logical_domain_enabled_ind=false) OR (bi2.logical_domain_enabled_ind=true
      AND bi2.logical_domain_id=logicaldomainid)) ))) OR (((bim.bill_item_type_cd+ 0)=
    cs13019_noncovered_cd)
     AND parser(noncoveredcd)
     AND coverage_ind=true)) )) ))
     AND bim.active_ind=1
     AND ((bim.beg_effective_dt_tm+ 0) <= cnvtdatetime(eff_dt_tm))
     AND ((bim.end_effective_dt_tm+ 0) > cnvtdatetime(eff_dt_tm)))
   ORDER BY bi.bill_item_id, bill_code_sched_meaning, bill_code_sched_display,
    bim.bim1_int
   HEAD REPORT
    bia_cnt = 0
   HEAD bi.bill_item_id
    bia_cnt += 1
    IF (mod(bia_cnt,1000)=1)
     stat = alterlist(bill_item_audit->bia_detail,(bia_cnt+ 999))
    ENDIF
    bill_item_audit->bia_detail[bia_cnt].bill_item_id = bi.bill_item_id, bill_item_audit->bia_detail[
    bia_cnt].parent_reference_id = bi.ext_parent_reference_id, bill_item_audit->bia_detail[bia_cnt].
    child_reference_id = bi.ext_child_reference_id,
    bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
    bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description), bill_item_audit
    ->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
    bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd, bill_item_audit->
    bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)), msstat = assign(
     sub_act_type_temp,validate(bi.ext_sub_owner_cd,0.0)),
    bill_item_audit->bia_detail[bia_cnt].sub_activity_type = trim(uar_get_code_display(
      sub_act_type_temp)), bill_item_audit->bia_detail[bia_cnt].stats_only_ind = bi.stats_only_ind,
    bill_item_audit->bia_detail[bia_cnt].misc_ind = bi.misc_ind,
    cp_cnt = 0, bc_cnt = 0, ao_cnt = 0,
    nc_cnt = 0
   DETAIL
    IF (bim.bill_item_type_cd=cs13019_chrg_point_sch_cd
     AND parser(chrgprocesscd))
     cp_cnt += 1
     IF (mod(cp_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].cp_detail,(cp_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].cp_bi_mod_id = bim.bill_item_mod_id,
     bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point_sched_cd = bim.key1_id,
     bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point_sched = trim(
      uar_get_code_display(bim.key1_id)),
     bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point = trim(uar_get_code_display(
       bim.key2_id)), bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_level = trim(
      uar_get_code_display(bim.key4_id))
     CASE (bim.bim1_int)
      OF 1:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "M"
      OF 2:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "D"
      OF 3:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MD"
      OF 4:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "P"
      OF 5:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MP"
      OF 6:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DP"
      OF 7:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDP"
      OF 8:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "Q"
      OF 9:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MQ"
      OF 10:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DQ"
      OF 11:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDQ"
      OF 12:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "PQ"
      OF 13:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MPQ"
      OF 14:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DPQ"
      OF 15:
       bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDPQ"
     ENDCASE
    ELSEIF (bim.bill_item_type_cd=cs13019_bill_code_sch_cd
     AND parser(billcodecd))
     bc_cnt += 1
     IF (mod(bc_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].bc_detail,(bc_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bc_bi_mod_id = bim.bill_item_mod_id,
     bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_sched_cd = bim.key1_id,
     bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code = trim(bim.key6),
     bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_qcf = bim.bim1_nbr
     IF (uar_get_code_meaning(bim.key1_id)="CDM_SCHED")
      bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].cdm_sched_desc = trim(bim.key7)
     ENDIF
    ELSEIF (bim.bill_item_type_cd=cs13019_add_on_assigned_cd)
     ao_cnt += 1
     IF (mod(ao_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].ao_detail,(ao_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_bi_mod_id = bim.bill_item_mod_id,
     bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_description = concat(build2(trim(bim
        .key6,7))), bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_bill_item_id = bim
     .key1_id,
     bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_qty = bim.bim1_int
    ELSEIF (bim.bill_item_type_cd=cs13019_noncovered_cd
     AND parser(noncoveredcd))
     nc_cnt += 1
     IF (mod(nc_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].nc_detail,(nc_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_bi_mod_id = bim.bill_item_mod_id,
     bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_sched_cd = bim.key1_id,
     bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_supp_info = trim(bim.key7)
     IF (bim.bim_ind=1)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_result = nc_result_non_covered
     ELSEIF (bim.bim_ind=0)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_result = nc_result_covered
     ELSE
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_result = nc_unknown
     ENDIF
     IF (bim.bim_ind=1)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_auth = nc_result_na
     ELSEIF (bim.bim1_ind=0
      AND bim.bim_ind=0)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_auth = nc_result_auth_cond
     ELSEIF (bim.bim1_ind=1
      AND bim.bim_ind=0)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_auth = nc_auth_no
     ELSEIF (bim.bim1_ind=2
      AND bim.bim_ind=0)
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_auth = nc_auth_yes
     ELSE
      bill_item_audit->bia_detail[bia_cnt].nc_detail[nc_cnt].nc_auth = nc_unknown
     ENDIF
    ENDIF
   FOOT  bi.bill_item_id
    stat = alterlist(bill_item_audit->bia_detail[bia_cnt].cp_detail,cp_cnt), bill_item_audit->
    bia_detail[bia_cnt].cp_cnt = cp_cnt, stat = alterlist(bill_item_audit->bia_detail[bia_cnt].
     bc_detail,bc_cnt),
    bill_item_audit->bia_detail[bia_cnt].bc_cnt = bc_cnt, stat = alterlist(bill_item_audit->
     bia_detail[bia_cnt].ao_detail,ao_cnt), bill_item_audit->bia_detail[bia_cnt].ao_cnt = ao_cnt,
    stat = alterlist(bill_item_audit->bia_detail[bia_cnt].nc_detail,nc_cnt), bill_item_audit->
    bia_detail[bia_cnt].nc_cnt = nc_cnt
   FOOT REPORT
    stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->bia_cnt = bia_cnt
   WITH nocounter, filesort
  ;end select
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (retrieveintervalbillcodes(billcodecd=vc) =i2)
   DECLARE biindx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    bill_code_sched_meaning = uar_get_code_meaning(bim.key1_id), bill_code_sched_display =
    uar_get_code_display(bim.key1_id)
    FROM bill_item bi,
     bill_item_modifier bim
    PLAN (bi
     WHERE expand(biindx,1,size(bill_item_audit->bia_detail,5),bi.bill_item_id,bill_item_audit->
      bia_detail[biindx].bill_item_id)
      AND (((bi.ext_owner_cd= $ACT_TYPE)
      AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
      AND bi.logical_domain_id=logicaldomainid)) ) OR (((bi.ext_owner_cd=0.00
      AND bi.ext_child_contributor_cd=cs13019_alpha_response_cd) OR ((emptyoranyactivityind=- (1))
      AND bi.ext_owner_cd > 0.0
      AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
      AND bi.logical_domain_id=logicaldomainid)) )) ))
      AND ((bi.active_ind+ 0)=1)
      AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
      AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND ((bim.bill_item_type_cd+ 0)=cs13019_interval_code)
      AND parser(billcodecd)
      AND bill_code_ind=true
      AND bim.active_ind=1
      AND bim.key2_id > 0.0)
    ORDER BY bi.bill_item_id, bim.key2_id, bill_code_sched_meaning,
     bill_code_sched_display, bim.bim1_int, bim.bill_item_mod_id
    HEAD REPORT
     num = 0
    HEAD bi.bill_item_id
     bc_cnt = 0, pos = locateval(num,1,size(bill_item_audit->bia_detail,5),bim.bill_item_id,
      bill_item_audit->bia_detail[num].bill_item_id)
    DETAIL
     IF (bim.bill_item_type_cd=cs13019_interval_code
      AND parser(billcodecd))
      IF (pos > 0)
       bc_cnt += 1
       IF (mod(bc_cnt,5)=1)
        stat = alterlist(bill_item_audit->bia_detail[pos].bc_detail,(bc_cnt+ 4))
       ENDIF
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bc_bi_mod_id = bim.bill_item_mod_id,
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code_sched_cd = bim.key1_id,
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code = trim(bim.key6),
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code_qcf = bim.bim1_nbr,
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bc_item_interval_id = bim.key2_id
       IF (uar_get_code_meaning(bim.key1_id)="CDM_SCHED")
        bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].cdm_sched_desc = trim(bim.key7)
       ENDIF
      ENDIF
     ENDIF
    FOOT  bi.bill_item_id
     stat = alterlist(bill_item_audit->bia_detail[pos].bc_detail,bc_cnt), bill_item_audit->
     bia_detail[pos].bc_cnt = bc_cnt
    WITH nocounter, filesort
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (retrievepharmacy(domainfacilities=vc) =null)
   DECLARE pharm_pref = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_prefs d
    WHERE d.application_nbr=300000
     AND d.person_id=0.0
     AND d.pref_domain="PHARMNET-INPATIENT"
     AND d.pref_section="BILLING"
     AND d.pref_name="CDM OPTION"
    DETAIL
     IF (((d.pref_nbr=cdm_opt_drug_formulation) OR (d.pref_nbr=cdm_opt_manufactured_item)) )
      pharm_pref = d.pref_nbr
     ELSE
      CALL exitservicefailure("CDM Option in table dm_prefs not set correctly or not supported",true)
     ENDIF
    WITH nocounter
   ;end select
   SELECT
    IF (pharm_pref=cdm_opt_drug_formulation)
     FROM bill_item bi,
      med_def_flex mdf,
      med_identifier mi3,
      med_def_flex mdf2,
      med_flex_object_idx mfoi
     PLAN (bi
      WHERE bi.ext_owner_cd=cs106_pharm_activity_type_cd
       AND bi.active_ind=1)
      JOIN (mdf
      WHERE mdf.med_def_flex_id=bi.ext_parent_reference_id
       AND mdf.pharmacy_type_cd=cs4500_inpt_pharmacy_type_cd
       AND mdf.flex_type_cd=cs4062_system_flex_type_cd
       AND mdf.active_ind=1)
      JOIN (mi3
      WHERE mi3.item_id=mdf.item_id
       AND mi3.active_ind=1
       AND mi3.med_identifier_type_cd=cs11000_cdm_med_id_type_cd
       AND mi3.sequence=1)
      JOIN (mdf2
      WHERE mdf2.item_id=mi3.item_id
       AND mdf2.flex_type_cd=cs4062_syspkgtyp_flex_type_cd
       AND mdf2.pharmacy_type_cd=cs4500_inpt_pharmacy_type_cd
       AND mdf2.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
       AND ((mfoi.parent_entity_id=0) OR ( EXISTS (
      (SELECT
       l.location_cd
       FROM organization o,
        location l
       WHERE o.logical_domain_id=logicaldomainid
        AND o.active_ind=1
        AND parser(organizationparser)
        AND l.organization_id=o.organization_id
        AND l.location_type_cd=cs222_facility_location_type_cd
        AND l.location_cd=mfoi.parent_entity_id))))
       AND mfoi.active_ind=1)
    ELSEIF (pharm_pref=cdm_opt_manufactured_item)
     FROM bill_item bi,
      med_product mp,
      med_identifier mi1,
      med_identifier mi3,
      med_def_flex mdf,
      med_flex_object_idx mfoi
     PLAN (bi
      WHERE bi.ext_owner_cd=cs106_pharm_activity_type_cd
       AND ((bi.active_ind+ 0)=1))
      JOIN (mp
      WHERE mp.manf_item_id=bi.ext_parent_reference_id
       AND mp.active_ind=1)
      JOIN (mi1
      WHERE mi1.med_product_id=mp.med_product_id
       AND mi1.active_ind=1
       AND mi1.primary_ind=1
       AND mi1.med_identifier_type_cd=cs11000_ndc_med_id_type_cd)
      JOIN (mi3
      WHERE mi3.item_id=mi1.item_id
       AND mi3.active_ind=1
       AND mi3.med_identifier_type_cd=cs11000_cdm_med_id_type_cd)
      JOIN (mdf
      WHERE mdf.item_id=mi3.item_id
       AND mdf.pharmacy_type_cd=cs4500_inpt_pharmacy_type_cd
       AND mdf.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND ((mfoi.parent_entity_id=0) OR ( EXISTS (
      (SELECT
       l.location_cd
       FROM organization o,
        location l
       WHERE o.logical_domain_id=logicaldomainid
        AND o.active_ind=1
        AND parser(organizationparser)
        AND l.organization_id=o.organization_id
        AND l.location_type_cd=cs222_facility_location_type_cd
        AND l.location_cd=mfoi.parent_entity_id))))
       AND mfoi.active_ind=1)
    ELSE
    ENDIF
    INTO "nl:"
    FROM dummyt
    ORDER BY bi.bill_item_id
    HEAD bi.bill_item_id
     pos = locateval(num,1,bill_item_audit->bia_cnt,bi.bill_item_id,bill_item_audit->bia_detail[num].
      bill_item_id)
     IF (pos=0)
      bia_cnt = (bill_item_audit->bia_cnt+ 1), stat = alterlist(bill_item_audit->bia_detail,bia_cnt),
      bill_item_audit->bia_detail[bia_cnt].bill_item_id = bi.bill_item_id,
      bill_item_audit->bia_detail[bia_cnt].parent_reference_id = bi.ext_parent_reference_id,
      bill_item_audit->bia_detail[bia_cnt].child_reference_id = bi.ext_child_reference_id,
      bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
      bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description),
      bill_item_audit->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
      bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd,
      bill_item_audit->bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)
       ), msstat = assign(sub_act_type_temp,validate(bi.ext_sub_owner_cd,0.0)), bill_item_audit->
      bia_detail[bia_cnt].sub_activity_type = trim(uar_get_code_display(sub_act_type_temp)),
      bill_item_audit->bia_cnt = bia_cnt, bc_cnt = (bill_item_audit->bia_detail[bia_cnt].bc_cnt+ 1),
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].bc_detail,bc_cnt),
      bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_sched_cd =
      cs14002_pharm_cdm_cd, bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code = trim(
       mi3.value), bill_item_audit->bia_detail[bia_cnt].bc_cnt = bc_cnt
     ELSE
      pos2 = locateval(num2,1,bill_item_audit->bia_detail[pos].bc_cnt,cs14002_pharm_cdm_cd,
       bill_item_audit->bia_detail[pos].bc_detail[num2].bill_code_sched_cd)
      IF (pos2=0)
       bc_cnt = (bill_item_audit->bia_detail[pos].bc_cnt+ 1), stat = alterlist(bill_item_audit->
        bia_detail[pos].bc_detail,bc_cnt), bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].
       bill_code_sched_cd = cs14002_pharm_cdm_cd,
       bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code = trim(mi3.value),
       bill_item_audit->bia_detail[pos].bc_cnt = bc_cnt
      ELSEIF (pos2 > 0
       AND textlen(trim(bill_item_audit->bia_detail[pos].bc_detail[num2].bill_code))=0)
       bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code_sched_cd = cs14002_pharm_cdm_cd,
       bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code = trim(mi3.value)
      ENDIF
     ENDIF
    WITH nocounter, filesort
   ;end select
 END ;Subroutine
 SUBROUTINE (retrievepricesched(logicaldomain=f8,pricescedid=vc) =i2)
  SELECT INTO "nl:"
   FROM price_sched_items psi,
    bill_item bi,
    price_sched ps
   PLAN (psi
    WHERE parser(pricescedid)
     AND parser(price_interval_parser)
     AND psi.active_ind=1
     AND psi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND psi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (bi
    WHERE bi.bill_item_id=psi.bill_item_id
     AND (((bi.ext_owner_cd= $ACT_TYPE)
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) ) OR (((bi.ext_owner_cd=0.00
     AND bi.ext_child_contributor_cd=cs13019_alpha_response_cd) OR ((emptyoranyactivityind=- (1))
     AND bi.ext_owner_cd > 0.0
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) )) ))
     AND ((bi.active_ind+ 0)=1)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1
     AND ps.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ps.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY psi.bill_item_id, ps.price_sched_desc
   HEAD REPORT
    bia_cnt = bill_item_audit->bia_cnt, num = 0
   HEAD psi.bill_item_id
    pos = locateval(num,1,size(bill_item_audit->bia_detail,5),psi.bill_item_id,bill_item_audit->
     bia_detail[num].bill_item_id)
    IF (pos=0)
     bia_cnt += 1, stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->
     bia_detail[bia_cnt].bill_item_id = bi.bill_item_id,
     bill_item_audit->bia_detail[bia_cnt].parent_reference_id = bi.ext_parent_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_reference_id = bi.ext_child_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
     bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description),
     bill_item_audit->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
     bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd,
     bill_item_audit->bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)),
     msstat = assign(sub_act_type_temp,validate(bi.ext_sub_owner_cd,0.0)), bill_item_audit->
     bia_detail[bia_cnt].sub_activity_type = trim(uar_get_code_display(sub_act_type_temp)),
     bill_item_audit->bia_detail[bia_cnt].stats_only_ind = bi.stats_only_ind, bill_item_audit->
     bia_detail[bia_cnt].misc_ind = bi.misc_ind, bill_item_audit->bia_cnt = bia_cnt
    ENDIF
    p_cnt = 0
   DETAIL
    IF (pos > 0)
     p_cnt += 1
     IF (mod(p_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,(p_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_items_id = psi.price_sched_items_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_id = psi.price_sched_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_desc = ps.price_sched_desc,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].interval_template_cd = psi.interval_template_cd,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_beg_date = format(psi.beg_effective_dt_tm,
      "MM/DD/YYYY"), bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_end_date = format(psi
      .end_effective_dt_tm,"MM/DD/YYYY"),
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = trim(format(psi.price,
       "###########.##;R"),3)
     IF (psi.interval_template_cd > 0.00)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = concat(build2("interval - ",
        uar_get_code_display(psi.interval_template_cd)))
     ENDIF
     IF (psi.stats_only_ind=1)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = "STAT"
     ENDIF
    ELSE
     p_cnt += 1
     IF (mod(p_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].p_detail,(p_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_sched_items_id = psi
     .price_sched_items_id, bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_sched_id = psi
     .price_sched_id, bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_sched_desc = ps
     .price_sched_desc,
     bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].interval_template_cd = psi
     .interval_template_cd, bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_beg_date =
     format(psi.beg_effective_dt_tm,"MM/DD/YYYY"), bill_item_audit->bia_detail[bia_cnt].p_detail[
     p_cnt].price_end_date = format(psi.end_effective_dt_tm,"MM/DD/YYYY"),
     bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = trim(format(psi.price,
       "###########.##;R"),3)
     IF (psi.interval_template_cd > 0.00)
      bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = concat(build2("interval - ",
        uar_get_code_display(psi.interval_template_cd)))
     ENDIF
     IF (psi.stats_only_ind=1)
      bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = "STAT"
     ENDIF
    ENDIF
   FOOT  psi.bill_item_id
    IF (pos > 0)
     stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,p_cnt), bill_item_audit->bia_detail[
     pos].p_cnt = p_cnt
    ELSE
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].p_detail,p_cnt), bill_item_audit->
     bia_detail[bia_cnt].p_cnt = p_cnt
    ENDIF
   FOOT REPORT
    stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->bia_cnt = bia_cnt
   WITH nocounter, filesort
  ;end select
  IF (audit_intervals_ind=true)
   DECLARE interval_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM interval_table it,
     item_interval_table iit,
     code_value_extension cve,
     (dummyt d1  WITH seq = value(size(bill_item_audit->bia_detail,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(bill_item_audit->bia_detail[d1.seq].p_detail,5)))
     JOIN (d2)
     JOIN (iit
     WHERE (iit.parent_entity_id=bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].
     price_sched_items_id)
      AND iit.active_ind=1)
     JOIN (it
     WHERE it.interval_template_cd=iit.interval_template_cd
      AND it.interval_id=iit.interval_id
      AND it.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=it.unit_type_cd
      AND cve.field_name="DENOMINATOR")
    ORDER BY iit.parent_entity_id, it.beg_value
    HEAD REPORT
     num = 0
    HEAD iit.parent_entity_id
     interval_cnt = 0
    DETAIL
     pos = locateval(num,1,size(bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail,5),iit
      .item_interval_id,bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[num].
      item_interval_id)
     IF (pos=0)
      interval_cnt += 1, stat = alterlist(bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].
       i_detail,interval_cnt), bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[
      interval_cnt].item_interval_id = iit.item_interval_id,
      bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[interval_cnt].calc_type_cd = it
      .calc_type_cd, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[interval_cnt].
      interval_beg_value = it.beg_value, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].
      i_detail[interval_cnt].interval_end_value = it.end_value,
      bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[interval_cnt].unit_factor = cve
      .field_value, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[interval_cnt].
      unit_type_cd = it.unit_type_cd, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[
      interval_cnt].interval_price = trim(format(iit.price,"###########.##;R"),3)
     ELSE
      bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].item_interval_id = iit
      .item_interval_id, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].
      calc_type_cd = it.calc_type_cd, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[
      pos].interval_beg_value = it.beg_value,
      bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].interval_end_value = it
      .end_value, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].unit_factor =
      cve.field_value, bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].
      unit_type_cd = it.unit_type_cd,
      bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[pos].interval_price = trim(format
       (iit.price,"###########.##;R"),3)
     ENDIF
    WITH nocounter, filesort
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (updateradiologyinfo(dummyvar=i2) =null)
   SELECT INTO "nl:"
    primary_sort = bill_item_audit->bia_detail[d.seq].parent_reference_id, secondary_sort =
    bill_item_audit->bia_detail[d.seq].child_reference_id
    FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt)),
     bill_item bi
    PLAN (d
     WHERE (bill_item_audit->bia_detail[d.seq].activity_type_cd=cs106_rad_activity_type_cd)
      AND cnvtupper(trim(bill_item_audit->bia_detail[d.seq].long_description))="REPORT")
     JOIN (bi
     WHERE (bi.ext_parent_reference_id=bill_item_audit->bia_detail[d.seq].parent_reference_id)
      AND bi.ext_child_reference_id=0.00
      AND (((bi.ext_owner_cd= $ACT_TYPE)
      AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
      AND bi.logical_domain_id=logicaldomainid)) ) OR ((emptyoranyactivityind=- (1))
      AND bi.ext_owner_cd > 0.0
      AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
      AND bi.logical_domain_id=logicaldomainid)) ))
      AND bi.active_ind=1
      AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
      AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    ORDER BY primary_sort, secondary_sort
    DETAIL
     bill_item_audit->bia_detail[d.seq].long_description = concat(trim(bi.ext_description),
      " - Report")
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (updateactivityforalpharesponse(dummyvar=i2) =null)
  SET num = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt)),
    bill_item bi
   PLAN (d
    WHERE (bill_item_audit->bia_detail[d.seq].child_reference_id > 0.00)
     AND (bill_item_audit->bia_detail[d.seq].activity_type_cd=0.00)
     AND (bill_item_audit->bia_detail[d.seq].parent_reference_id > 0.00))
    JOIN (bi
    WHERE (bi.ext_child_reference_id=bill_item_audit->bia_detail[d.seq].parent_reference_id)
     AND bi.ext_parent_reference_id=0.0
     AND (((bi.ext_owner_cd= $ACT_TYPE)
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) ) OR ((emptyoranyactivityind=- (1))
     AND bi.ext_owner_cd > 0.0
     AND ((bi.logical_domain_enabled_ind=false) OR (bi.logical_domain_enabled_ind=true
     AND bi.logical_domain_id=logicaldomainid)) ))
     AND bi.active_ind=1
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
   DETAIL
    bill_item_audit->bia_detail[d.seq].activity_type_cd = bi.ext_owner_cd, bill_item_audit->
    bia_detail[d.seq].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)), bill_item_audit->
    bia_detail[d.seq].long_description = concat(trim(bi.ext_description)," -> ",trim(bill_item_audit
      ->bia_detail[d.seq].long_description))
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (generatecsv(dummyvar=i2) =null)
   DECLARE cdmrow = vc WITH protect, noconstant(" ")
   DECLARE cdmdescrow = vc WITH protect, noconstant(" ")
   DECLARE cdmrowcount = i4 WITH protect, noconstant(0)
   SET total_header = build2(bi_header,cp_header,bc_header,price_header,ao_header,
    non_covered_header)
   SET output_type = validate(request->output_device,"X")
   SET email_file_name = concat(cnvtlower( $OUTDEV),format(cnvtdatetime(sysdate),"mmddyyyy_hhmm;;q"))
   CALL echo(build2("Output type :",output_type))
   SELECT
    IF (output_type="MINE")INTO  $OUTDEV
    ELSE INTO concat(email_file_name,".tsv")
    ENDIF
    primary_sort = bill_item_audit->bia_detail[d.seq].activity_type, secondary_sort = bill_item_audit
    ->bia_detail[d.seq].long_description
    FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt))
    PLAN (d
     WHERE (((bill_item_audit->bia_detail[d.seq].activity_type_cd > 0.00)) OR ((emptyoranyactivityind
     =- (1))
      AND (bill_item_audit->bia_detail[d.seq].activity_type_cd >= 0.00))) )
    ORDER BY primary_sort, secondary_sort
    HEAD REPORT
     col 0, total_header, row + 1
    DETAIL
     row_detail = "", row_detail = build2(bill_item_audit->bia_detail[d.seq].bill_item_id,tab_char,
      bill_item_audit->bia_detail[d.seq].parent_reference_id,tab_char,bill_item_audit->bia_detail[d
      .seq].child_reference_id,
      tab_char,bill_item_audit->bia_detail[d.seq].long_description,tab_char,bill_item_audit->
      bia_detail[d.seq].short_description,tab_char,
      bill_item_audit->bia_detail[d.seq].activity_type,tab_char,bill_item_audit->bia_detail[d.seq].
      sub_activity_type,tab_char,evaluate(bill_item_audit->bia_detail[d.seq].stats_only_ind,1,"X",0,
       ""),
      tab_char,evaluate(bill_item_audit->bia_detail[d.seq].misc_ind,1,"X",0,""),tab_char)
     IF (charge_processing_ind=true)
      FOR (i = 1 TO size(schedules->chrg_process_detail,5))
        found = 0
        FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].cp_detail,5))
          IF ((schedules->chrg_process_detail[i].chrg_process_cd=bill_item_audit->bia_detail[d.seq].
          cp_detail[bi].chrg_point_sched_cd))
           IF (found > 0)
            row_detail = build2(row_detail,"<and>")
           ENDIF
           IF (textlen(trim(bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_attributes))=0)
            row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].cp_detail[bi].
             chrg_level,"/",bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_point)
           ELSE
            row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].cp_detail[bi].
             chrg_level,"/",bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_point,"/",
             bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_attributes)
           ENDIF
           found += 1
          ENDIF
        ENDFOR
        row_detail = build2(row_detail,tab_char)
      ENDFOR
     ENDIF
     IF (bill_code_ind=true)
      FOR (i = 1 TO size(schedules->bill_code_detail,5))
        found = 0, cdm_descrip_found = 0, cdmrowcount = 0,
        cdmrow = " ", cdmdescrow = " "
        FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].bc_detail,5))
          IF ((schedules->bill_code_detail[i].bill_code_cd=bill_item_audit->bia_detail[d.seq].
          bc_detail[bi].bill_code_sched_cd))
           IF (found > 0
            AND uar_get_code_meaning(bill_item_audit->bia_detail[d.seq].bc_detail[bi].
            bill_code_sched_cd) != "CDM_SCHED")
            row_detail = build2(row_detail,"<and>")
           ELSEIF (found > 0)
            cdmrow = build2(cdmrow,"<and>",bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code
             ), cdmdescrow = build2(cdmdescrow,"<and>",bill_item_audit->bia_detail[d.seq].bc_detail[
             bi].cdm_sched_desc), cdmrowcount += 1
           ENDIF
           IF ((schedules->bill_code_detail[i].bill_code_sched_type=cs13036_hcpcs_cd))
            row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code,
             "^",trim(cnvtstring(bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code_qcf,0,2))
             )
           ELSEIF (uar_get_code_meaning(bill_item_audit->bia_detail[d.seq].bc_detail[bi].
            bill_code_sched_cd)="CDM_SCHED")
            IF (found=0)
             cdmrow = build2(cdmrow,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code),
             cdmdescrow = build2(cdmdescrow,bill_item_audit->bia_detail[d.seq].bc_detail[bi].
              cdm_sched_desc), cdmrowcount += 1,
             cdm_descrip_found += 1
            ENDIF
           ELSE
            row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code
             )
           ENDIF
           found += 1
          ENDIF
        ENDFOR
        IF (cdmrowcount > 0
         AND cdm_descrip_found > 0)
         row_detail = build2(row_detail,cdmrow,tab_char,cdmdescrow)
        ENDIF
        IF ((schedules->bill_code_detail[i].bill_code_sched_type=cs13036_cdm_sched_cd)
         AND cdm_descrip_found=0)
         row_detail = build2(row_detail,tab_char,tab_char)
        ELSE
         row_detail = build2(row_detail,tab_char)
        ENDIF
      ENDFOR
     ENDIF
     IF (price_sched_ind=true)
      FOR (i = 1 TO size(schedules->price_detail,5))
        found = 0
        FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].p_detail,5))
          IF ((schedules->price_detail[i].price_sched_id=bill_item_audit->bia_detail[d.seq].p_detail[
          bi].price_sched_id))
           IF (found > 0)
            row_detail = build2(row_detail,"<and>")
           ENDIF
           row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].p_detail[bi].price),
           found += 1
          ENDIF
        ENDFOR
        row_detail = build2(row_detail,tab_char)
      ENDFOR
     ENDIF
     ao_total = size(bill_item_audit->bia_detail[d.seq].ao_detail,5)
     FOR (i = 1 TO size(bill_item_audit->bia_detail[d.seq].ao_detail,5))
       ao_total -= 1, ao_quantity = build(cnvtstring(bill_item_audit->bia_detail[d.seq].ao_detail[i].
         ao_qty)), row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].ao_detail[i].
        ao_description,"^",ao_quantity,"^",
        cnvtstring(bill_item_audit->bia_detail[d.seq].ao_detail[i].ao_bill_item_id))
       IF (ao_total != 0)
        row_detail = build2(row_detail,";")
       ENDIF
     ENDFOR
     row_detail = build2(row_detail,tab_char)
     IF (coverage_ind=true)
      FOR (i = 1 TO size(schedules->non_covered_detail,5))
        found = 0
        FOR (nc = 1 TO size(bill_item_audit->bia_detail[d.seq].nc_detail,5))
          IF ((schedules->non_covered_detail[i].non_covered_cd=bill_item_audit->bia_detail[d.seq].
          nc_detail[nc].nc_sched_cd))
           IF (found > 0)
            row_detail = build2(row_detail,"<and>")
           ENDIF
           nc_auth = build(bill_item_audit->bia_detail[d.seq].nc_detail[nc].nc_auth), nc_supp = build
           (bill_item_audit->bia_detail[d.seq].nc_detail[nc].nc_supp_info), row_detail = build2(
            row_detail,bill_item_audit->bia_detail[d.seq].nc_detail[nc].nc_result,"^",nc_auth,"^",
            nc_supp),
           found += 1
          ENDIF
        ENDFOR
        row_detail = build2(row_detail,tab_char)
      ENDFOR
     ENDIF
     col 0, row_detail, row + 1
    WITH nocounter, nullreport, noformfeed,
     format = variable, noheading, maxcol = 32000
   ;end select
   IF (output_type != "MINE")
    SET dclcom = concat("zip -j ",email_file_name,".zip ",email_file_name,".tsv")
    SET len = size(trim(dclcom))
    SET status = - (1)
    SET dclstat = dcl(dclcom,len,status)
    IF (validate(debug))
     CALL echo(build("*** zip command returned status: ",status," ***"))
    ENDIF
    IF (cursys2 IN ("AIX"))
     SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
      '| mailx -s "Bill Item Audit Report" ',email_address)
    ELSEIF (cursys2 IN ("LNX"))
     CALL currentlnxversion(1)
     IF (slinuxversion >= 6)
      SET dclcom = concat("echo ",'"Audit Report in excel format" ',"| mailx -s ",
       '"Bill Item Audit Report" -a ',email_file_name,
       ".zip ",email_address)
     ELSE
      SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
       '| mailx -s "Bill Item Audit Report" ',email_address)
     ENDIF
    ELSEIF (cursys2 IN ("HPX"))
     SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
      '| mailx -m -s "Bill Item Audit Report" ',email_address)
    ENDIF
    SET len = size(trim(dclcom))
    SET status = - (1)
    SET dclstat = dcl(dclcom,len,status)
    IF (validate(debug))
     CALL echo(build("*** Attempted to send email to address: ",email_address," ***"))
     CALL echo(build("*** mailx returned status: ",status," ***"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (generateintervalcsv(dummyvar=i2) =null)
   DECLARE cdm_found = i2 WITH protect, noconstant(0)
   DECLARE cpt_found = i2 WITH protect, noconstant(0)
   DECLARE hcpcs_found = i2 WITH protect, noconstant(0)
   DECLARE modifier_found = i2 WITH protect, noconstant(0)
   DECLARE proc_found = i2 WITH protect, noconstant(0)
   DECLARE cdm = vc WITH protect, noconstant("")
   DECLARE cpt = vc WITH protect, noconstant("")
   DECLARE hcpcs = vc WITH protect, noconstant("")
   DECLARE modifier = vc WITH protect, noconstant("")
   DECLARE proc = vc WITH protect, noconstant("")
   SET total_header = build2(bi_interval_header,interval_details_header,interval_bill_codes_header)
   SET output_type = validate(request->output_device,"X")
   SET email_file_name = concat(cnvtlower( $OUTDEV),format(cnvtdatetime(sysdate),"mmddyyyy_hhmm;;q"))
   CALL echo(build2("Output type :",output_type))
   SELECT
    IF (output_type="MINE")INTO  $OUTDEV
    ELSE INTO concat(email_file_name,".tsv")
    ENDIF
    primary_sort = bill_item_audit->bia_detail[d1.seq].activity_type, secondary_sort =
    bill_item_audit->bia_detail[d1.seq].long_description, tertiary_sort = bill_item_audit->
    bia_detail[d1.seq].bill_item_id,
    quaternary_sort = bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].price_sched_desc,
    quinary_sort = bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].price_beg_date
    FROM (dummyt d1  WITH seq = value(size(bill_item_audit->bia_detail,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(bill_item_audit->bia_detail[d1.seq].p_detail,5))
      AND (((bill_item_audit->bia_detail[d1.seq].activity_type_cd > 0.00)) OR ((emptyoranyactivityind
     =- (1))
      AND (bill_item_audit->bia_detail[d1.seq].activity_type_cd >= 0.00))) )
     JOIN (d2)
    ORDER BY primary_sort, secondary_sort, tertiary_sort,
     quaternary_sort, quinary_sort
    HEAD REPORT
     col 0, total_header, row + 1
    HEAD tertiary_sort
     row_detail = "", bill_item_detail = "", bill_item_detail = build2(bill_item_audit->bia_detail[d1
      .seq].bill_item_id,tab_char,bill_item_audit->bia_detail[d1.seq].parent_reference_id,tab_char,
      bill_item_audit->bia_detail[d1.seq].child_reference_id,
      tab_char,bill_item_audit->bia_detail[d1.seq].long_description,tab_char,bill_item_audit->
      bia_detail[d1.seq].short_description,tab_char,
      bill_item_audit->bia_detail[d1.seq].activity_type,tab_char,bill_item_audit->bia_detail[d1.seq].
      sub_activity_type,tab_char)
    DETAIL
     FOR (i = 1 TO size(bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail,5))
       row_detail = bill_item_detail, row_detail = build2(row_detail,bill_item_audit->bia_detail[d1
        .seq].p_detail[d2.seq].price_sched_desc,tab_char,bill_item_audit->bia_detail[d1.seq].
        p_detail[d2.seq].price_beg_date,tab_char,
        bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].price_end_date,tab_char,
        uar_get_code_display(bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].
         interval_template_cd),tab_char)
       IF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].
        interval_template_cd)="CODETEMPLATE")
        row_detail = build2(row_detail,"X",tab_char)
       ELSE
        row_detail = build2(row_detail,"",tab_char)
       ENDIF
       row_detail = build2(row_detail,bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[i
        ].interval_beg_value,tab_char)
       IF ((bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[i].interval_end_value=- (1)
       ))
        row_detail = build2(row_detail,"",tab_char)
       ELSE
        row_detail = build2(row_detail,bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[
         i].interval_end_value,tab_char)
       ENDIF
       row_detail = build2(row_detail,uar_get_code_display(bill_item_audit->bia_detail[d1.seq].
         p_detail[d2.seq].i_detail[i].calc_type_cd),tab_char,uar_get_code_display(bill_item_audit->
         bia_detail[d1.seq].p_detail[d2.seq].i_detail[i].unit_type_cd),tab_char,
        bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[i].unit_factor,tab_char,
        bill_item_audit->bia_detail[d1.seq].p_detail[d2.seq].i_detail[i].interval_price,tab_char),
       cdm = build2(tab_char,tab_char), cpt = build2(tab_char),
       hcpcs = build2(tab_char), modifier = build2(tab_char), proc = build2(tab_char)
       FOR (intervaliterator = 1 TO size(schedules->bill_code_detail,5))
         cdm_found = 0, cpt_found = 0, hcpcs_found = 0,
         modifier_found = 0, proc_found = 0, cdm_descrip_found = 0
         FOR (j = 1 TO size(bill_item_audit->bia_detail[d1.seq].bc_detail,5))
           IF ((bill_item_audit->bia_detail[d1.seq].bc_detail[j].bc_item_interval_id=bill_item_audit
           ->bia_detail[d1.seq].p_detail[d2.seq].i_detail[i].item_interval_id)
            AND (schedules->bill_code_detail[intervaliterator].bill_code_cd=bill_item_audit->
           bia_detail[d1.seq].bc_detail[j].bill_code_sched_cd))
            IF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
             bill_code_sched_cd)="CDM_SCHED")
             IF (cdm_found=0)
              cdm = build2(uar_get_code_display(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
                bill_code_sched_cd),tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].
               bill_code,tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].cdm_sched_desc)
             ELSEIF (cdm_found=1)
              cdm = build2(cdm,"<and>","CHECK FOR DUPLICATE BUILD")
             ENDIF
             cdm_found += 1
            ELSEIF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
             bill_code_sched_cd)="CPT4")
             IF (cpt_found=0)
              cpt = build2(uar_get_code_display(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
                bill_code_sched_cd),tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].
               bill_code)
             ELSEIF (cpt_found=1)
              cpt = build2(cpt,"<and>","CHECK FOR DUPLICATE BUILD")
             ENDIF
             cpt_found += 1
            ELSEIF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
             bill_code_sched_cd)="HCPCS")
             IF (hcpcs_found=0)
              hcpcs = build2(uar_get_code_display(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
                bill_code_sched_cd),tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].
               bill_code)
             ELSEIF (hcpcs_found=1)
              hcpcs = build2(hcpcs,"<and>","CHECK FOR DUPLICATE BUILD")
             ENDIF
             hcpcs_found += 1
            ELSEIF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
             bill_code_sched_cd)="MODIFIER")
             IF (modifier_found=0)
              modifier = build2(uar_get_code_display(bill_item_audit->bia_detail[d1.seq].bc_detail[j]
                .bill_code_sched_cd),tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].
               bill_code)
             ELSEIF (modifier_found=1)
              modifier = build2(modifier,"<and>","CHECK FOR DUPLICATE BUILD")
             ENDIF
             modifier_found += 1
            ELSEIF (uar_get_code_meaning(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
             bill_code_sched_cd)="PROCCODE")
             IF (proc_found=0)
              proc = build2(uar_get_code_display(bill_item_audit->bia_detail[d1.seq].bc_detail[j].
                bill_code_sched_cd),tab_char,bill_item_audit->bia_detail[d1.seq].bc_detail[j].
               bill_code)
             ELSEIF (proc_found=1)
              proc = build2(proc,"<and>","CHECK FOR DUPLICATE BUILD")
             ENDIF
             proc_found += 1
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       row_detail = build2(row_detail,cdm,tab_char,cpt,tab_char,
        hcpcs,tab_char,modifier,tab_char,proc,
        tab_char), col 0, row_detail,
       row + 1, row_detail = ""
     ENDFOR
    WITH nocounter, nullreport, noformfeed,
     format = variable, noheading, maxcol = 32000
   ;end select
   IF (output_type != "MINE")
    SET dclcom = concat("zip -j ",email_file_name,".zip ",email_file_name,".tsv")
    SET len = size(trim(dclcom))
    SET status = - (1)
    SET dclstat = dcl(dclcom,len,status)
    IF (validate(debug))
     CALL echo(build("*** zip command returned status: ",status," ***"))
    ENDIF
    IF (cursys2 IN ("AIX"))
     SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
      '| mailx -s "Bill Item Audit Report" ',email_address)
    ELSEIF (cursys2 IN ("LNX"))
     CALL currentlnxversion(1)
     IF (slinuxversion >= 6)
      SET dclcom = concat("echo ",'"Audit Report in excel format" ',"| mailx -s ",
       '"Bill Item Audit Report" -a ',email_file_name,
       ".zip ",email_address)
     ELSE
      SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
       '| mailx -s "Bill Item Audit Report" ',email_address)
     ENDIF
    ELSEIF (cursys2 IN ("HPX"))
     SET dclcom = concat("uuencode ",email_file_name,".zip ",email_file_name,".zip ",
      '| mailx -m -s "Bill Item Audit Report" ',email_address)
    ENDIF
    SET len = size(trim(dclcom))
    SET status = - (1)
    SET dclstat = dcl(dclcom,len,status)
    IF (validate(debug))
     CALL echo(build("*** Attempted to send email to address: ",email_address," ***"))
     CALL echo(build("*** mailx returned status: ",status," ***"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (currentlnxversion(dummyvar=i2) =vc)
   SET dclcom = build2("cat /etc/redhat-release >> ",trim(sfilelinuxversiontemp,3))
   SET len = size(trim(dclcom))
   SET status = - (1)
   SET dclstat = dcl(dclcom,len,status)
   FREE DEFINE rtl
   DEFINE rtl sfilelinuxversiontemp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     sdcloutput = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET sversion = substring((findstring("RELEASE",sdcloutput)+ 8),1,sdcloutput)
   IF (isnumeric(sversion) > 0)
    SET slinuxversion = cnvtreal(sversion)
   ENDIF
   IF (validate(debug))
    CALL echo(build2("Os : ",sdcloutput))
    CALL echo(build2("Os Version : ",slinuxversion))
   ENDIF
   RETURN(slinuxversion)
 END ;Subroutine
 IF (validate(debug))
  CALL echorecord(schedules)
  CALL echorecord(bill_item_audit)
 ENDIF
END GO
