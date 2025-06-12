CREATE PROGRAM afc_rpt_build:dba
 DECLARE max_landscape = i4 WITH noconstant(45), private
 DECLARE max_portrait = i4 WITH noconstant(66), private
 DECLARE land_str = vc
 DECLARE port_str = vc
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=20790
    AND cv.cdf_meaning IN ("RPTMAXLAND", "RPTMAXPORT"))
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND cve.field_name="OPTION"
    AND cve.field_value != "")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "RPTMAXLAND":
     land_str = cve.field_value
    OF "RPTMAXPORT":
     port_str = cve.field_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (textlen(land_str) > 0)
  SET max_landscape = cnvtint(land_str)
 ENDIF
 IF (textlen(port_str) > 0)
  SET max_portrait = cnvtint(port_str)
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
 IF ("Z"=validate(afc_rpt_build_vrsn,"Z"))
  DECLARE afc_rpt_build_vrsn = vc WITH noconstant("384634.028")
 ENDIF
 SET afc_rpt_build_vrsn = "384634.028"
 EXECUTE cclseclogin
 SET message = nowindow
 CALL echorecord(request,"ccluserdir:afc_pm.dat")
 RECORD reply(
   1 nbr_lines = i4
   1 list[*]
     2 line = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE credit_cd = f8
 DECLARE pharmacy_cd = f8
 DECLARE logicaldomainid = f8 WITH noconstant(0.0), protect
 DECLARE bbillcodecheck = i2 WITH noconstant(0), protect
 DECLARE ndc_cd = f8 WITH noconstant(0.0), protect
 DECLARE dbillcode = f8 WITH noconstant(0.0), protect
 SET credit_cd = 0.0
 SET pharmacy_cd = 0.0
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,credit_cd)
 CALL echo(build("the credit value is: ",credit_cd))
 SET codeset = 106
 SET cdf_meaning = "PHARMACY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,pharmacy_cd)
 CALL echo(build("the pharmacy value is: ",pharmacy_cd))
 SET codeset = 14002
 SET cdf_meaning = "NDC"
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),1,ndc_cd)
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
#0100_start
 EXECUTE cpm_create_file_name "cer_print:pm", "dat"
 SET request->file_name = cpm_cfn_info->file_name
 IF (validate(reply->file_name_exists,0)=1)
  SET reply->file_name = request->file_name
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE uar_get_code_display(p1) = c40
 DECLARE uar_fmt_accession(p1,p2) = c25
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF ((request->parameters_ind=false))
  EXECUTE FROM 2000_load_report TO 2099_load_report_exit
  EXECUTE FROM 2000_load_header TO 2099_load_header_exit
  EXECUTE FROM 2000_load_filter TO 2099_load_filter_exit
  EXECUTE FROM 2000_load_filter_values TO 2099_load_filter_values_exit
  EXECUTE FROM 2000_load_order TO 2099_load_order_exit
  EXECUTE FROM 2000_load_group TO 2099_load_group_exit
 ELSE
  SET hold = request
 ENDIF
 EXECUTE FROM 3000_create_report TO 3099_create_report_exit
 IF (request->print_preview_ind)
  EXECUTE FROM 4000_load_reply TO 4099_load_reply_exit
 ENDIF
 SET reply->status_data.status = "S"
 GO TO 9999_end
#1000_initialize
 SET true = 1
 SET false = 0
 SET pn = 1
 SET pb[500] = fillstring(130," ")
 SET cp = 0
 SET pn_len = 0
 SET fill = fillstring(130,"-")
 SET debug_file = fillstring(20," ")
 SET nbr_lines = 0
 SET hold_days = 0
 SET hold_date = fillstring(11," ")
 SET linespace = 0
 SET org_ind = "N"
 SET acc_ind = "N"
 SET mrn_yn = "N"
 SET fin_nbr_yn = "N"
 SET process_flg_yn = "N"
 SET process_flg_ind = fillstring(4," ")
 SET process_flg_ind2 = fillstring(4," ")
 SET mrn_cd = 0.0
 SET fin_nbr_cd = 0.0
 SET filter_yn = "N"
 SET cpt4_yn = "N"
 SET cpt4_count = 0
 RECORD cpt4codes(
   1 cpt_qual = i4
   1 cpt_header[*]
     2 cpt_value = c100
     2 cpt_meaning = c20
     2 cpt_display = c12
 )
 SET cdm_yn = "N"
 SET cdm_count = 0
 RECORD cdmcodes(
   1 cdm_qual = i4
   1 cdm_header[*]
     2 cdm_value = c100
     2 cdm_meaning = c20
     2 cdm_display = c12
 )
 SET icd9_yn = "N"
 SET icd9_count = 0
 RECORD icd9codes(
   1 icd9_qual = i4
   1 icd9_header[*]
     2 icd9_value = c100
     2 icd9_meaning = c20
     2 icd9_display = c12
 )
 SET gl1_yn = "N"
 SET gl1_count = 0
 RECORD gl1codes(
   1 gl1_qual = i4
   1 gl1_header[*]
     2 gl1_value = c100
     2 gl1_meaning = c20
     2 gl1_display = c12
 )
 SET snwm_yn = "N"
 SET snwm_count = 0
 RECORD snwmcodes(
   1 snwm_qual = i4
   1 snwm_header[*]
     2 snwm_value = c100
     2 snwm_meaning = c20
     2 snwm_display = c12
 )
 SET proccode_yn = "N"
 SET proccode_count = 0
 RECORD proccodes(
   1 proccode_qual = i4
   1 proccode_header[*]
     2 proccode_value = c100
     2 proccode_meaning = c20
     2 proccode_display = c12
 )
 SET modrsncomment_yn = "N"
 SET modrsncd_yn = "N"
 SET chargemod_ind = "n"
 SET item_price_yn = "n"
 SET item_ext_price_yn = "n"
 SET gross_price_yn = "n"
 SET discount_amount_yn = "n"
 SET item_price_col = 0
 SET item_ext_price_col = 0
 SET gross_price_col = 0
 SET discount_amount_col = 0
 SET hold_item_price = 0.00
 SET hold_discount_amount = 0.00
 SET hold_gross_price = 0.00
 SET hold_item_ext_price = 0.00
 SET grand_item_price = 0.00
 SET grand_discount_amount = 0.00
 SET grand_gross_price = 0.00
 SET grand_item_ext_price = 0.00
 SET grand_total = 0
 IF (cursys="AIX")
  SET com = concat("$rm cer_temp:pmrpt",trim(request->curuser),".dat")
 ELSE
  SET com = concat("$del cer_temp:pmrpt",trim(request->curuser),".dat;*/nolog")
 ENDIF
 CALL dcl(com,size(trim(com)),0)
 RECORD hold(
   1 report_id = f8
   1 file_name = c32
   1 parameters_ind = i2
   1 curuser = c8
   1 debug_ind = i2
   1 print_preview_ind = i2
   1 report_name = c20
   1 description = c100
   1 report_type = c1
   1 transaction_type = c4
   1 program_name = c20
   1 detail_ind = i2
   1 total_ind = i2
   1 retention_days = i4
   1 title = c40
   1 task_number = i4
   1 landscape_ind = i2
   1 doublespace_ind = i2
   1 pm_rpt_header_qual = i4
   1 pm_rpt_header[*]
     2 header_id = f8
     2 field_id = f8
     2 field_name = c32
     2 field_type = c3
     2 table_name = c32
     2 field_help = c6
     2 header_display = c20
     2 header_sequence = i4
     2 header_length = i4
     2 time_ind = i2
     2 seconds_ind = i2
     2 string_ind = i2
   1 pm_rpt_filter_qual = i4
   1 pm_rpt_filter[*]
     2 filter_id = f8
     2 field_id = f8
     2 field_name = c32
     2 field_type = c3
     2 table_name = c32
     2 field_help = c6
     2 between_ind = i2
     2 pm_rpt_filter_values_qual = i4
     2 pm_rpt_filter_values[*]
       3 filter_values_id = f8
       3 value = c100
       3 start_ind = i2
       3 end_ind = i2
   1 pm_rpt_order_qual = i4
   1 pm_rpt_order[*]
     2 order_id = f8
     2 field_id = f8
     2 field_name = c32
     2 field_type = c3
     2 table_name = c32
     2 field_help = c6
     2 order_sequence = i4
     2 descending_ind = i2
   1 pm_rpt_group_qual = i4
   1 pm_rpt_group[*]
     2 group_id = f8
     2 header_id = f8
     2 header_length = i4
     2 field_id = f8
     2 field_name = c32
     2 field_type = c3
     2 table_name = c32
     2 field_help = c6
     2 group_sequence = i4
     2 group_total_ind = i2
 )
 DECLARE dmodrsn = f8
 SET stat = uar_get_meaning_by_codeset(13019,"MOD RSN",1,dmodrsn)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,dbillcode)
#1099_initialize_exit
#2000_load_report
 SELECT INTO "nl:"
  p.seq
  FROM pm_rpt_report p
  WHERE (p.report_id=request->report_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   hold->report_id = p.report_id, hold->report_name = p.report_name, hold->description = p
   .description,
   hold->report_type = p.report_type, hold->transaction_type = p.transaction_type, hold->program_name
    = p.program_name,
   hold->detail_ind = p.detail_ind, hold->total_ind = p.total_ind, hold->retention_days = p
   .retention_days,
   hold->title = p.title, hold->task_number = p.task_number, hold->landscape_ind = p.landscape_ind,
   hold->doublespace_ind = p.doublespace_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PM_RPT_REPORT"
  GO TO 9999_end
 ENDIF
#2099_load_report_exit
#2000_load_header
 SET cnt = 0
 SELECT INTO "nl:"
  p.seq
  FROM pm_rpt_header p,
   pm_rpt_field prf
  PLAN (p
   WHERE (p.report_id=request->report_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (prf
   WHERE prf.field_id=p.field_id)
  ORDER BY p.header_sequence
  DETAIL
   cnt += 1, stat = alterlist(hold->pm_rpt_header,cnt), hold->pm_rpt_header[cnt].header_id = p
   .header_id,
   hold->pm_rpt_header[cnt].field_id = p.field_id, hold->pm_rpt_header[cnt].field_name = prf
   .field_name, hold->pm_rpt_header[cnt].field_type = prf.field_type,
   hold->pm_rpt_header[cnt].table_name = prf.table_name, hold->pm_rpt_header[cnt].field_help = prf
   .field_help, hold->pm_rpt_header[cnt].header_display = p.header_display,
   hold->pm_rpt_header[cnt].header_sequence = p.header_sequence, hold->pm_rpt_header[cnt].
   header_length = p.header_length, hold->pm_rpt_header[cnt].time_ind = p.time_ind,
   hold->pm_rpt_header[cnt].seconds_ind = p.seconds_ind
   IF (substring(1,1,hold->pm_rpt_header[cnt].field_type)="C")
    hold->pm_rpt_header[cnt].string_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PM_RPT_HEADER"
  GO TO 9999_end
 ENDIF
 SET hold->pm_rpt_header_qual = cnt
#2099_load_header_exit
#2000_load_filter
 SET cnt = 0
 SELECT INTO "nl:"
  p.seq
  FROM pm_rpt_filter p,
   pm_rpt_field prf
  PLAN (p
   WHERE (p.report_id=request->report_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (prf
   WHERE prf.field_id=p.field_id)
  DETAIL
   cnt += 1, stat = alterlist(hold->pm_rpt_filter,cnt), hold->pm_rpt_filter[cnt].filter_id = p
   .filter_id,
   hold->pm_rpt_filter[cnt].field_id = p.field_id, hold->pm_rpt_filter[cnt].field_name = prf
   .field_name, hold->pm_rpt_filter[cnt].field_type = prf.field_type,
   hold->pm_rpt_filter[cnt].table_name = prf.table_name, hold->pm_rpt_filter[cnt].field_help = prf
   .field_help, hold->pm_rpt_filter[cnt].between_ind = p.between_ind
  WITH nocounter
 ;end select
 SET hold->pm_rpt_filter_qual = cnt
#2099_load_filter_exit
#2000_load_filter_values
 FOR (x = 1 TO hold->pm_rpt_filter_qual)
   SET cnt = 0
   SELECT INTO "nl:"
    p.seq
    FROM pm_rpt_filter_values p
    WHERE (p.filter_id=hold->pm_rpt_filter[x].filter_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY p.start_ind DESC
    DETAIL
     cnt += 1, stat = alterlist(hold->pm_rpt_filter[x].pm_rpt_filter_values,cnt), hold->
     pm_rpt_filter[x].pm_rpt_filter_values[cnt].filter_values_id = p.filter_values_id,
     hold->pm_rpt_filter[x].pm_rpt_filter_values[cnt].value = p.value, hold->pm_rpt_filter[x].
     pm_rpt_filter_values[cnt].start_ind = p.start_ind, hold->pm_rpt_filter[x].pm_rpt_filter_values[
     cnt].end_ind = p.end_ind
    WITH nocounter
   ;end select
   FOR (y = 1 TO hold->pm_rpt_filter_qual)
     IF ((hold->pm_rpt_filter[y].table_name="CHARGE_MOD"))
      SET filter_yn = "Y"
     ENDIF
   ENDFOR
   SET hold->pm_rpt_filter[x].pm_rpt_filter_values_qual = cnt
 ENDFOR
#2099_load_filter_values_exit
#2000_load_order
 SET cnt = 0
 SELECT INTO "nl:"
  p.seq
  FROM pm_rpt_order p,
   pm_rpt_field prf
  PLAN (p
   WHERE (p.report_id=request->report_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (prf
   WHERE prf.field_id=p.field_id)
  ORDER BY p.order_sequence
  DETAIL
   cnt += 1, stat = alterlist(hold->pm_rpt_order,cnt), hold->pm_rpt_order[cnt].order_id = p.order_id,
   hold->pm_rpt_order[cnt].field_id = p.field_id, hold->pm_rpt_order[cnt].field_name = prf.field_name,
   hold->pm_rpt_order[cnt].field_type = prf.field_type,
   hold->pm_rpt_order[cnt].table_name = prf.table_name, hold->pm_rpt_order[cnt].field_help = prf
   .field_help, hold->pm_rpt_order[cnt].order_sequence = p.order_sequence,
   hold->pm_rpt_order[cnt].descending_ind = p.descending_ind
  WITH nocounter
 ;end select
 SET hold->pm_rpt_order_qual = cnt
#2099_load_order_exit
#2000_load_group
 SET cnt = 0
 SELECT INTO "nl:"
  p.seq
  FROM pm_rpt_group p,
   pm_rpt_field prf,
   pm_rpt_header prh
  PLAN (p
   WHERE (p.report_id=request->report_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (prf
   WHERE prf.field_id=p.field_id)
   JOIN (prh
   WHERE prh.header_id=p.header_id)
  ORDER BY p.group_sequence
  DETAIL
   cnt += 1, stat = alterlist(hold->pm_rpt_group,cnt), hold->pm_rpt_group[cnt].group_id = p.group_id,
   hold->pm_rpt_group[cnt].header_id = p.header_id, hold->pm_rpt_group[cnt].header_length = prh
   .header_length, hold->pm_rpt_group[cnt].field_id = p.field_id,
   hold->pm_rpt_group[cnt].field_name = prf.field_name, hold->pm_rpt_group[cnt].field_type = prf
   .field_type, hold->pm_rpt_group[cnt].table_name = prf.table_name,
   hold->pm_rpt_group[cnt].field_help = prf.field_help, hold->pm_rpt_group[cnt].group_sequence = p
   .group_sequence, hold->pm_rpt_group[cnt].group_total_ind = p.group_total_ind
  WITH nocounter
 ;end select
 SET hold->pm_rpt_group_qual = cnt
#2099_load_group_exit
#3000_create_report
 IF ((request->doublespace_ind=true))
  SET linespace = 2
 ELSE
  SET linespace = 1
 ENDIF
 FOR (y = 1 TO hold->pm_rpt_header_qual)
   IF ((hold->pm_rpt_header[y].string_ind=1))
    SET pb[pn] = concat("declare ",hold->pm_rpt_header[y].field_name," = ",hold->pm_rpt_header[y].
     field_type," go")
    SET pn += 1
   ENDIF
 ENDFOR
 SET pb[pn] = concat('select into "',trim(request->file_name),'"')
 FOR (y = 1 TO hold->pm_rpt_header_qual)
  CASE (hold->pm_rpt_header[y].table_name)
   OF "CHARGE":
    SET hold->pm_rpt_header[y].table_name = "C"
   OF "ENCOUNTER":
    SET hold->pm_rpt_header[y].table_name = "E"
   OF "PERSON":
    SET hold->pm_rpt_header[y].table_name = "P"
   OF "CODE_VALUE":
    SET hold->pm_rpt_header[y].table_name = "CV"
   OF "ENCNTR_ALIAS":
    CASE (hold->pm_rpt_header[y].field_help)
     OF "MRN":
      SET hold->pm_rpt_header[y].table_name = "EA1"
      SET mrn_yn = "Y"
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE c.code_set=319
        AND c.cdf_meaning="MRN"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        mrn_cd = c.code_value
       WITH nocounter
      ;end select
     OF "FIN":
      SET fin_nbr_yn = "Y"
      SET hold->pm_rpt_header[y].table_name = "EA2"
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE c.code_set=319
        AND c.cdf_meaning="FIN NBR"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        fin_nbr_cd = c.code_value
       WITH nocounter
      ;end select
    ENDCASE
   OF "ACCESSION_ORDER_R":
    SET hold->pm_rpt_header[y].table_name = "AOR"
    SET acc_ind = "Y"
   OF "ORGANIZATION":
    SET hold->pm_rpt_header[y].table_name = "ORG"
    SET org_ind = "Y"
   OF "CHARGE_MOD":
    CASE (hold->pm_rpt_header[y].field_help)
     OF "CPT4":
      SET hold->pm_rpt_header[y].table_name = "CM1"
      SET cpt4_yn = "Y"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="CPT4"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        cpt4_count += 1, stat = alterlist(cpt4codes->cpt_header,cpt4_count), cpt4codes->cpt_qual =
        cpt4_count,
        cpt4codes->cpt_header[cpt4_count].cpt_value = cnvtstring(c.code_value,17,2), cpt4codes->
        cpt_header[cpt4_count].cpt_display = c.display, cpt4codes->cpt_header[cpt4_count].cpt_meaning
         = c.cdf_meaning
       WITH nocounter
      ;end select
     OF "CPTDES":
      SET hold->pm_rpt_header[y].table_name = "CM1"
     OF "CDM":
      SET cdm_yn = "Y"
      SET hold->pm_rpt_header[y].table_name = "CM2"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="CDM_SCHED"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        cdm_count += 1, stat = alterlist(cdmcodes->cdm_header,cdm_count), cdmcodes->cdm_qual =
        cdm_count,
        cdmcodes->cdm_header[cdm_count].cdm_value = cnvtstring(c.code_value,17,2), cdmcodes->
        cdm_header[cdm_count].cdm_display = c.display, cdmcodes->cdm_header[cdm_count].cdm_meaning =
        c.cdf_meaning
       WITH nocounter
      ;end select
     OF "CDMDES":
      SET hold->pm_rpt_header[y].table_name = "CM2"
     OF "ICD9":
      SET hold->pm_rpt_header[y].table_name = "CM3"
      SET icd9_yn = "Y"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="ICD9"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        icd9_count += 1, stat = alterlist(icd9codes->icd9_header,icd9_count), icd9codes->icd9_qual =
        icd9_count,
        icd9codes->icd9_header[icd9_count].icd9_value = cnvtstring(c.code_value,17,2), icd9codes->
        icd9_header[icd9_count].icd9_display = c.display, icd9codes->icd9_header[icd9_count].
        icd9_meaning = c.cdf_meaning
       WITH nocounter
      ;end select
     OF "ICDDES":
      SET hold->pm_rpt_header[y].table_name = "CM3"
     OF "GL1":
      SET hold->pm_rpt_header[y].table_name = "CM4"
      SET gl1_yn = "Y"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="GL"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        gl1_count += 1, stat = alterlist(gl1codes->gl1_header,gl1_count), gl1codes->gl1_qual =
        gl1_count,
        gl1codes->gl1_header[gl1_count].gl1_value = cnvtstring(c.code_value,17,2), gl1codes->
        gl1_header[gl1_count].gl1_display = c.display, gl1codes->gl1_header[gl1_count].gl1_meaning =
        c.cdf_meaning
       WITH nocounter
      ;end select
     OF "SNWMED":
      SET hold->pm_rpt_header[y].table_name = "CM5"
      SET snwm_yn = "Y"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="SNMI95"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        snwm_count += 1, stat = alterlist(snwmcodes->snwm_header,snwm_count), snwmcodes->snwm_qual =
        snwm_count,
        snwmcodes->snwm_header[snwm_count].snwm_value = cnvtstring(c.code_value,17,2), snwmcodes->
        snwm_header[snwm_count].snwm_display = c.display, snwmcodes->snwm_header[snwm_count].
        snwm_meaning = c.cdf_meaning
       WITH nocounter
      ;end select
     OF "PROC":
      SET hold->pm_rpt_header[y].table_name = "CM6"
      SET proccode_yn = "Y"
      SELECT INTO "nl:"
       c.code_value, c.display, c.cdf_meaning
       FROM code_value c
       WHERE c.code_set=14002
        AND c.cdf_meaning="PROCCODE"
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
        AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        proccode_count += 1, stat = alterlist(proccodes->proccode_header,proccode_count), proccodes->
        proccode_qual = proccode_count,
        proccodes->proccode_header[proccode_count].proccode_value = cnvtstring(c.code_value,17,2),
        proccodes->proccode_header[proccode_count].proccode_display = c.display, proccodes->
        proccode_header[proccode_count].proccode_meaning = c.cdf_meaning
       WITH nocounter
      ;end select
     OF "MODRSN":
      SET hold->pm_rpt_header[y].table_name = "CM7"
      SET modrsncomment_yn = "Y"
     ELSE
      IF ((hold->pm_rpt_header[y].field_help="1309"))
       SET hold->pm_rpt_header[y].table_name = "CM7"
       SET modrsncd_yn = "Y"
      ELSE
       SET chargemod_ind = "Y"
       SET hold->pm_rpt_header[y].table_name = "CM"
      ENDIF
    ENDCASE
  ENDCASE
  IF ((hold->pm_rpt_header[y].field_name="PROCESS_FLG"))
   SET process_flg_yn = "Y"
  ENDIF
 ENDFOR
 FOR (y = 1 TO hold->pm_rpt_header_qual)
   IF ((y=hold->pm_rpt_header_qual))
    IF ((hold->pm_rpt_header[y].field_name="PROCESS_FLG"))
     SET pn += 1
     SET pb[pn] = "cv.display, "
    ENDIF
    IF (((substring((size(trim(hold->pm_rpt_header[y].field_name)) - 2),3,hold->pm_rpt_header[y].
     field_name)="_CD") OR ((hold->pm_rpt_header[y].field_name="FIELD1_ID"))) )
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y]
       .field_name),",")
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
       field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_header[y].header_length)),
      ",uar_get_code_display(",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
       ].field_name),")))")
    ELSEIF ((hold->pm_rpt_header[y].field_name="FIELD2_ID")
     AND (hold->pm_rpt_header[y].table_name="CM7"))
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y]
       .field_name),",")
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
       field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_header[y].header_length)),
      ",uar_get_code_display(",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
       ].field_name),")))")
    ELSE
     IF ((hold->pm_rpt_header[y].field_type="DQ8"))
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
        ].field_name),",")
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
        field_name)," = cnvtdate(",trim(hold->pm_rpt_header[y].table_name),
       ".",trim(hold->pm_rpt_header[y].field_name),")")
     ELSE
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
        ].field_name))
     ENDIF
    ENDIF
   ELSE
    IF (((substring((size(trim(hold->pm_rpt_header[y].field_name)) - 2),3,hold->pm_rpt_header[y].
     field_name)="_CD") OR ((hold->pm_rpt_header[y].field_name="FIELD1_ID"))) )
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y]
       .field_name),",")
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
       field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_header[y].header_length)),
      ",uar_get_code_display(",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
       ].field_name),"))),")
    ELSEIF ((hold->pm_rpt_header[y].field_name="FIELD2_ID")
     AND (hold->pm_rpt_header[y].table_name="CM7"))
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y]
       .field_name),",")
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
       field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_header[y].header_length)),
      ",uar_get_code_display(",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
       ].field_name),"))),")
    ELSE
     IF ((hold->pm_rpt_header[y].field_type="DQ8"))
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
        ].field_name),",")
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
        field_name)," = cnvtdate(",trim(hold->pm_rpt_header[y].table_name),
       ".",trim(hold->pm_rpt_header[y].field_name),"),")
     ELSE
      SET pn += 1
      SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y
        ].field_name),",")
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET pn += 1
 SET pb[pn] = "from"
 IF (mrn_yn="Y")
  SET pn += 1
  SET pb[pn] = "  dummyt d1, encntr_alias ea1,"
 ENDIF
 IF (fin_nbr_yn="Y")
  SET pn += 1
  SET pb[pn] = "  dummyt d15, encntr_alias ea2,"
 ENDIF
 IF (org_ind="Y")
  SET pn += 1
  SET pb[pn] = "  organization org,  "
 ENDIF
 IF (acc_ind="Y")
  SET pn += 1
  SET pb[pn] = "  dummyt d7, accession_order_r aor,  "
 ENDIF
 IF (process_flg_yn="Y")
  SET pn += 1
  SET pb[pn] = " code_value cv,  "
 ENDIF
 IF (cpt4_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d2, charge_mod cm1, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm1, "
  ENDIF
 ENDIF
 IF (cdm_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d3, charge_mod cm2, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm2, "
  ENDIF
 ENDIF
 IF (icd9_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d4, charge_mod cm3, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm3, "
  ENDIF
 ENDIF
 IF (gl1_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d5, charge_mod cm4, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm4, "
  ENDIF
 ENDIF
 IF (snwm_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d6, charge_mod cm5, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm5, "
  ENDIF
 ENDIF
 IF (proccode_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  dummyt d9, charge_mod cm6, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm6, "
  ENDIF
 ENDIF
 IF (chargemod_ind="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = " dummyt d8, charge_mod cm, "
  ELSEIF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = "  charge_mod cm, "
  ENDIF
 ENDIF
 IF (((modrsncomment_yn="Y") OR (modrsncd_yn="Y")) )
  IF (filter_yn="Y")
   SET pn += 1
   SET pb[pn] = " charge_mod cm7, "
  ELSE
   SET pn += 1
   SET pb[pn] = " dummyt d10, charge_mod cm7, "
  ENDIF
 ENDIF
 SET pn += 1
 SET pb[pn] = "  encounter e, person p, charge c "
 FOR (y = 1 TO hold->pm_rpt_filter_qual)
   CASE (hold->pm_rpt_filter[y].table_name)
    OF "CHARGE":
     SET hold->pm_rpt_filter[y].table_name = "C"
    OF "ENCOUNTER":
     SET hold->pm_rpt_filter[y].table_name = "E"
    OF "PERSON":
     SET hold->pm_rpt_filter[y].table_name = "P"
    OF "CODE_VALUE":
     SET hold->pm_rpt_filter[y].table_name = "CV"
    OF "ENCNTR_ALIAS":
     CASE (hold->pm_rpt_filter[y].field_help)
      OF "MRN":
       SET hold->pm_rpt_filter[y].table_name = "EA1"
      OF "FIN":
       SET hold->pm_rpt_filter[y].table_name = "EA2"
     ENDCASE
    OF "ACCESSION_ORDER_R":
     SET hold->pm_rpt_filter[y].table_name = "AOR"
    OF "ORGANIZATION":
     SET hold->pm_rpt_filter[y].table_name = "ORG"
    OF "CHARGE_MOD":
     CASE (hold->pm_rpt_filter[y].field_help)
      OF "CPT4":
       SET hold->pm_rpt_filter[y].table_name = "CM1"
      OF "CDM":
       SET hold->pm_rpt_filter[y].table_name = "CM2"
      OF "ICD9":
       SET hold->pm_rpt_filter[y].table_name = "CM3"
      OF "GL1":
       SET hold->pm_rpt_filter[y].table_name = "CM4"
      OF "SNWMED":
       SET hold->pm_rpt_filter[y].table_name = "CM5"
       SET hold->pm_rpt_filter[y].table_name = "CM6"
      OF "MODRSN":
       SET hold->pm_rpt_filter[y].table_name = "CM7"
      ELSE
       IF (modrsncd_yn="Y")
        SET hold->pm_rpt_filter[y].table_name = "CM7"
       ELSE
        SET hold->pm_rpt_filter[y].table_name = "CM"
       ENDIF
     ENDCASE
   ENDCASE
 ENDFOR
 FOR (i = 1 TO 21)
  CASE (i)
   OF 1:
    SET pn += 1
    SET pb[pn] = "plan c where c.active_ind = 1"
    SET pn += 1
    SET pb[pn] = "  and c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
    SET pn += 1
    SET pb[pn] = "  and c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
   OF 2:
    SET pn += 1
    SET pb[pn] = "join e where e.encntr_id = c.encntr_id"
    SET pn += 1
    SET pb[pn] = "  and e.active_ind = 1"
    SET pn += 1
    SET pb[pn] = "  and e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
    SET pn += 1
    SET pb[pn] = "  and e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
   OF 3:
    SET pn += 1
    SET pb[pn] = "join p where p.person_id = c.person_id"
    SET pn += 1
    SET pb[pn] = " and p.logical_domain_id = logicalDomainID"
    SET pn += 1
    SET pb[pn] = "  and p.active_ind = 1"
    SET pn += 1
    SET pb[pn] = "  and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
    SET pn += 1
    SET pb[pn] = "  and p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
   OF 5:
    IF (org_ind="Y")
     SET pn += 1
     SET pb[pn] = "join org where org.organization_id = c.payor_id"
     SET pn += 1
     SET pb[pn] = " and org.logical_domain_id = p.logical_domain_id"
     SET pn += 1
     SET pb[pn] = "  and org.active_ind = 1"
    ENDIF
   OF 6:
    SET pn += 1
   OF 7:
    IF (process_flg_yn="Y")
     SET pn += 1
     SET pb[pn] = "join cv where cv.code_set = 16569"
     SET pn += 1
     SET pb[pn] = "and cv.cdf_meaning = cnvtstring(c.process_flg)"
    ENDIF
   OF 8:
    IF (chargemod_ind="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d8"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm where cm.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm.active_ind = 1"
    ENDIF
   OF 10:
    IF (cpt4_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d2"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm1 where cm1.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm1.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm1.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ","cm1.field1_id"," in (")
     FOR (y = 1 TO cpt4codes->cpt_qual)
       IF ((y=cpt4codes->cpt_qual))
        SET pn += 1
        SET pb[pn] = concat(trim(cpt4codes->cpt_header[y].cpt_value),")")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(trim(cpt4codes->cpt_header[y].cpt_value),",")
       ENDIF
     ENDFOR
    ENDIF
   OF 13:
    IF (cdm_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d3"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm2 where cm2.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm2.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm2.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ","cm2.field1_id"," in (")
     FOR (y = 1 TO cdmcodes->cdm_qual)
       IF ((y=cdmcodes->cdm_qual))
        SET pn += 1
        SET pb[pn] = concat(trim(cdmcodes->cdm_header[y].cdm_value),")")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(trim(cdmcodes->cdm_header[y].cdm_value),",")
       ENDIF
     ENDFOR
    ENDIF
   OF 14:
    IF (icd9_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d4"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm3 where cm3.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm3.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm3.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ","cm3.field1_id"," in (")
     FOR (y = 1 TO icd9codes->icd9_qual)
       IF ((y=icd9codes->icd9_qual))
        SET pn += 1
        SET pb[pn] = concat(trim(icd9codes->icd9_header[y].icd9_value),")")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(trim(icd9codes->icd9_header[y].icd9_value),",")
       ENDIF
     ENDFOR
    ENDIF
   OF 15:
    IF (gl1_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d5"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm4 where cm4.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm4.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm4.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ","cm4.field1_id"," in (")
     FOR (y = 1 TO gl1codes->gl1_qual)
       IF ((y=gl1codes->gl1_qual))
        SET pn += 1
        SET pb[pn] = concat(trim(gl1codes->gl1_header[y].gl1_value),")")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(trim(gl1codes->gl1_header[y].gl1_value),",")
       ENDIF
     ENDFOR
    ENDIF
   OF 16:
    IF (snwm_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d6"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm5 where cm5.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm5.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm5.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm5.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm5.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     IF ((snwmcodes->snwm_qual=0))
      SET pb[pn] = concat("  and ","cm5.field1_id"," in (0)")
     ELSE
      SET pb[pn] = concat("  and ","cm5.field1_id"," in (")
      FOR (y = 1 TO snwmcodes->snwm_qual)
        IF ((y=snwmcodes->snwm_qual))
         SET pn += 1
         SET pb[pn] = concat(trim(snwmcodes->snwm_header[y].snwm_value),")")
        ELSE
         SET pn += 1
         SET pb[pn] = concat(trim(snwmcodes->snwm_header[y].snwm_value),",")
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   OF 17:
    IF (proccode_yn="Y")
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d9"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm6 where cm6.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = "  and cm6.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and cm6.field2_id = 1"
     SET pn += 1
     SET pb[pn] = "  and cm6.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and cm6.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ","cm6.field1_id"," in (")
     FOR (y = 1 TO proccodes->proccode_qual)
       IF ((y=proccodes->proccode_qual))
        SET pn += 1
        SET pb[pn] = concat(trim(proccodes->proccode_header[y].proccode_value),")")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(trim(proccodes->proccode_header[y].proccode_value),",")
       ENDIF
     ENDFOR
    ENDIF
   OF 18:
    IF (((modrsncomment_yn="Y") OR (modrsncd_yn="Y")) )
     IF (filter_yn="N")
      SET pn += 1
      SET pb[pn] = "join d10"
     ENDIF
     SET pn += 1
     SET pb[pn] = "join cm7 where cm7.charge_item_id = c.charge_item_id"
     SET pn += 1
     SET pb[pn] = build(" and cm7.charge_mod_type_cd = ",dmodrsn)
     SET pn += 1
     SET pb[pn] = " and cm7.active_ind = 1"
    ENDIF
   OF 19:
    IF (acc_ind="Y")
     SET pn += 1
     SET pb[pn] = "join d7"
     SET pn += 1
     SET pb[pn] = "join aor where aor.order_id = c.order_id"
     SET pn += 1
     SET pb[pn] = "  and aor.accession_id != 0 and aor.accession_id != NULL"
    ENDIF
   OF 20:
    IF (mrn_yn="Y")
     SET pn += 1
     SET pb[pn] = "join d1"
     SET pn += 1
     SET pb[pn] = "join ea1 where ea1.encntr_id = e.encntr_id"
     SET pn += 1
     SET pb[pn] = "  and ea1.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ea1.encntr_alias_type_cd = ",trim(cnvtstring(mrn_cd,17,2)))
    ENDIF
   OF 21:
    IF (fin_nbr_yn="Y")
     SET pn += 1
     SET pb[pn] = "join d15"
     SET pn += 1
     SET pb[pn] = "join ea2 where ea2.encntr_id = c.encntr_id"
     SET pn += 1
     SET pb[pn] = "  and ea2.active_ind = 1"
     SET pn += 1
     SET pb[pn] = "  and ea2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = "  and ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
     SET pn += 1
     SET pb[pn] = concat("  and ea2.encntr_alias_type_cd = ",trim(cnvtstring(fin_nbr_cd,17,2)))
    ENDIF
  ENDCASE
  FOR (x = 1 TO hold->pm_rpt_filter_qual)
    IF (((i=1
     AND (hold->pm_rpt_filter[x].table_name="C")) OR (((i=2
     AND (hold->pm_rpt_filter[x].table_name="E")) OR (((i=3
     AND (hold->pm_rpt_filter[x].table_name="P")) OR (((i=4
     AND (hold->pm_rpt_filter[x].table_name="BO")) OR (((i=5
     AND (hold->pm_rpt_filter[x].table_name="ORG")) OR (((i=6
     AND (hold->pm_rpt_filter[x].table_name="CE")) OR (((i=7
     AND (hold->pm_rpt_filter[x].table_name="CV")) OR (((i=8
     AND (hold->pm_rpt_filter[x].table_name="CM")) OR (((i=10
     AND (hold->pm_rpt_filter[x].table_name="CM1")) OR (((i=13
     AND (hold->pm_rpt_filter[x].table_name="CM2")) OR (((i=14
     AND (hold->pm_rpt_filter[x].table_name="CM3")) OR (((i=15
     AND (hold->pm_rpt_filter[x].table_name="CM4")) OR (((i=16
     AND (hold->pm_rpt_filter[x].table_name="CM5")) OR (((i=17
     AND (hold->pm_rpt_filter[x].table_name="CM6")) OR (((i=18
     AND (hold->pm_rpt_filter[x].table_name="CM7")) OR (((i=19
     AND (hold->pm_rpt_filter[x].table_name="AOR")) OR (((i=20
     AND (hold->pm_rpt_filter[x].table_name="EA1")) OR (i=21
     AND (hold->pm_rpt_filter[x].table_name="EA2"))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
    )
     CASE (hold->pm_rpt_filter[x].field_type)
      OF "F8":
       IF (substring((size(trim(hold->pm_rpt_filter[x].field_name)) - 2),3,hold->pm_rpt_filter[x].
        field_name)="_ID")
        IF ((hold->pm_rpt_filter[x].between_ind=true))
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," between ",
          cnvtstring(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value,17,2)," and ",cnvtstring(
           hold->pm_rpt_filter[x].pm_rpt_filter_values[2].value,17,2))
        ELSE
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," in (")
         FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
           IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
            SET pn += 1
            SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),")")
           ELSE
            SET pn += 1
            SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),",")
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        SET pn += 1
        IF (trim(hold->pm_rpt_filter[x].field_name)="FIELD6")
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".FIELD1_ID"," in (")
        ELSE
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," in (")
        ENDIF
        FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
         IF (trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value)=trim(cnvtstring(dbillcode))
          AND trim(hold->pm_rpt_filter[x].field_name)="CHARGE_MOD_TYPE_CD")
          CALL echo("Identified bill code charge_mod_type_cd turning boolean value true")
          SET bbillcodecheck = 1
         ENDIF
         IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
          SET pn += 1
          SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),")")
         ELSE
          SET pn += 1
          SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),",")
         ENDIF
        ENDFOR
        IF (bbillcodecheck=1)
         SET bbillcodecheck = 0
         SET pn += 1
         SET pb[pn] = concat(" and ",trim(hold->pm_rpt_filter[x].table_name),".FIELD1_ID != ",trim(
           cnvtstring(value(ndc_cd),17,2)))
        ENDIF
       ENDIF
      OF "DQ8":
       FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
         IF (substring(1,1,hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value)="C")
          IF (substring(2,1,hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value)="+")
           SET hold_days = cnvtint(substring(3,3,hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value
             ))
           SET hold_date = format((curdate+ hold_days),"dd-mmm-yyyy;;d")
          ELSE
           SET hold_days = cnvtint(substring(3,3,hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value
             ))
           SET hold_date = format((curdate - hold_days),"dd-mmm-yyyy;;d")
          ENDIF
          SET hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value = concat(hold_date," ",substring(7,
            5,trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value)))
         ELSE
          SET hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value = substring(1,17,hold->
           pm_rpt_filter[x].pm_rpt_filter_values[y].value)
         ENDIF
       ENDFOR
       CASE (hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
        OF 1:
         IF (substring(13,1,hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value) > " ")
          SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),":00.00"
           )
          SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),":59.99")
         ELSE
          SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),
           " 00:00:00.00")
          SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),
           " 23:59:59.99")
         ENDIF
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name),' between cnvtdatetime("',
          trim(begin_date),'") and cnvtdatetime("',trim(end_date),'")')
        ELSE
         IF ((hold->pm_rpt_filter[x].between_ind=true))
          IF (substring(13,1,hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value) > " ")
           SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),
            ":00.00")
           SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[2].value),":59.99")
          ELSE
           SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),
            " 00:00:00.00")
           SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[2].value),
            " 23:59:59.99")
          ENDIF
          SET pn += 1
          SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
            pm_rpt_filter[x].field_name),' between cnvtdatetime("',
           trim(begin_date),'") and cnvtdatetime("',trim(end_date),'")')
         ELSE
          FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
            IF (substring(13,1,hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value) > " ")
             SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),
              ":00.00")
             SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),
              ":59.99")
            ELSE
             SET begin_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),
              " 00:00:00.00")
             SET end_date = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),
              " 23:59:59.99")
            ENDIF
            SET pn += 1
            IF (y=1)
             SET pb[pn] = concat("  and (",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
               pm_rpt_filter[x].field_name),' between cnvtdatetime("',
              trim(begin_date),'") and cnvtdatetime("',trim(end_date),'")')
            ELSE
             IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
              SET pb[pn] = concat("  or ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
                pm_rpt_filter[x].field_name),' between cnvtdatetime("',
               trim(begin_date),'") and cnvtdatetime("',trim(end_date),'"))')
             ELSE
              SET pb[pn] = concat("  or ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
                pm_rpt_filter[x].field_name),' between cnvtdatetime("',
               trim(begin_date),'") and cnvtdatetime("',trim(end_date),'")')
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
       ENDCASE
      OF "I2":
       SET pn += 1
       IF ((hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value="1"))
        SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
          pm_rpt_filter[x].field_name)," = TRUE")
       ELSE
        SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
          pm_rpt_filter[x].field_name)," = FALSE")
       ENDIF
      OF "I4":
       IF ((hold->pm_rpt_filter[x].field_name="PROCESS_FLG"))
        IF ((hold->pm_rpt_filter[x].between_ind=true))
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," between ",
          cnvtstring(process_flg_ind)," and ",cnvtstring(process_flg_ind2))
        ELSE
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," in (")
         FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
          SELECT INTO "nl:"
           c.cdf_meaning
           FROM code_value c
           WHERE c.code_value=cnvtreal(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value))
            AND c.code_set=16569
            AND c.active_ind=1
            AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
            AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
           DETAIL
            process_flg_ind = c.cdf_meaning
           WITH nocounter
          ;end select
          IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
           SET pn += 1
           SET pb[pn] = concat(trim(process_flg_ind),")")
          ELSE
           SET pn += 1
           SET pb[pn] = concat(trim(process_flg_ind),",")
          ENDIF
         ENDFOR
        ENDIF
       ELSE
        IF ((hold->pm_rpt_filter[x].between_ind=true))
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," between ",
          cnvtstring(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value)," and ",cnvtstring(hold->
           pm_rpt_filter[x].pm_rpt_filter_values[2].value))
        ELSE
         SET pn += 1
         SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
           pm_rpt_filter[x].field_name)," in (")
         FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
           IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
            SET pn += 1
            SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),")")
           ELSE
            SET pn += 1
            SET pb[pn] = concat(trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),",")
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ELSE
       IF ((hold->pm_rpt_filter[x].between_ind=true))
        SET pn += 1
        SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
          pm_rpt_filter[x].field_name),' between "',
         trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[1].value),'" and "',trim(hold->
          pm_rpt_filter[x].pm_rpt_filter_values[2].value),'"')
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  and ",trim(hold->pm_rpt_filter[x].table_name),".",trim(hold->
          pm_rpt_filter[x].field_name)," in (")
        FOR (y = 1 TO hold->pm_rpt_filter[x].pm_rpt_filter_values_qual)
          IF ((y=hold->pm_rpt_filter[x].pm_rpt_filter_values_qual))
           SET pn += 1
           SET pb[pn] = concat('"',trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),'")')
          ELSE
           SET pn += 1
           SET pb[pn] = concat('"',trim(hold->pm_rpt_filter[x].pm_rpt_filter_values[y].value),'",')
          ENDIF
        ENDFOR
       ENDIF
     ENDCASE
    ENDIF
  ENDFOR
 ENDFOR
 IF ((hold->pm_rpt_order_qual > 0))
  FOR (y = 1 TO hold->pm_rpt_order_qual)
    CASE (hold->pm_rpt_order[y].table_name)
     OF "CHARGE":
      SET hold->pm_rpt_order[y].table_name = "C"
     OF "ENCOUNTER":
      SET hold->pm_rpt_order[y].table_name = "E"
     OF "PERSON":
      SET hold->pm_rpt_order[y].table_name = "P"
     OF "CODE_VALUE":
      SET hold->pm_rpt_order[y].table_name = "CV"
     OF "ENCNTR_ALIAS":
      CASE (hold->pm_rpt_order[y].field_help)
       OF "MRN":
        SET hold->pm_rpt_order[y].table_name = "EA1"
       OF "FIN":
        SET hold->pm_rpt_order[y].table_name = "EA2"
      ENDCASE
     OF "ACCESSION_ORDER_R":
      SET hold->pm_rpt_order[y].table_name = "AOR"
     OF "ORGANIZATION":
      SET hold->pm_rpt_order[y].table_name = "ORG"
     OF "CHARGE_MOD":
      CASE (hold->pm_rpt_order[y].field_help)
       OF "CPT4":
        SET hold->pm_rpt_order[y].table_name = "CM1"
       OF "CDM":
        SET hold->pm_rpt_order[y].table_name = "CM2"
       OF "ICD9":
        SET hold->pm_rpt_order[y].table_name = "CM3"
       OF "GL1":
        SET hold->pm_rpt_order[y].table_name = "CM4"
       OF "SNWMED":
        SET hold->pm_rpt_order[y].table_name = "CM5"
       OF "PROC":
        SET hold->pm_rpt_order[y].table_name = "CM6"
       OF "MODRSN":
        SET hold->pm_rpt_order[y].table_name = "CM7"
       ELSE
        IF (modrsncd_yn="Y")
         SET hold->pm_rpt_order[y].table_name = "CM7"
        ELSE
         SET hold->pm_rpt_order[y].table_name = "CM"
        ENDIF
      ENDCASE
    ENDCASE
  ENDFOR
  SET pn += 1
  SET pb[pn] = "order by "
  FOR (y = 1 TO hold->pm_rpt_order_qual)
    IF ((y=hold->pm_rpt_order_qual))
     IF (substring((size(trim(hold->pm_rpt_order[y].field_name)) - 2),3,hold->pm_rpt_order[y].
      field_name)="_CD")
      IF ((hold->pm_rpt_order[y].descending_ind=true))
       SET pn += 1
       SET pb[pn] = concat(" uar_get_code_display(",trim(hold->pm_rpt_order[y].table_name),".",trim(
         hold->pm_rpt_order[y].field_name),") DESC")
      ELSE
       SET pn += 1
       SET pb[pn] = concat(" uar_get_code_display(",trim(hold->pm_rpt_order[y].table_name),".",trim(
         hold->pm_rpt_order[y].field_name),")")
      ENDIF
     ELSE
      IF ((hold->pm_rpt_order[y].field_type="DQ8"))
       IF ((hold->pm_rpt_order[y].descending_ind=true))
        SET pn += 1
        SET pb[pn] = concat(" cnvtdate(",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->
          pm_rpt_order[y].field_name),")",
         " DESC")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(" cnvtdate(",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->
          pm_rpt_order[y].field_name),")")
       ENDIF
      ELSE
       IF ((hold->pm_rpt_order[y].descending_ind=true))
        SET pn += 1
        SET pb[pn] = concat("  ",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->pm_rpt_order[y
          ].field_name)," DESC")
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  ",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->pm_rpt_order[y
          ].field_name))
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF (substring((size(trim(hold->pm_rpt_order[y].field_name)) - 2),3,hold->pm_rpt_order[y].
      field_name)="_CD")
      IF ((hold->pm_rpt_order[y].descending_ind=true))
       SET pn += 1
       SET pb[pn] = concat(" uar_get_code_display(",trim(hold->pm_rpt_order[y].table_name),".",trim(
         hold->pm_rpt_order[y].field_name),") DESC,")
      ELSE
       SET pn += 1
       SET pb[pn] = concat("  uar_get_code_display(",trim(hold->pm_rpt_order[y].table_name),".",trim(
         hold->pm_rpt_order[y].field_name),"),")
      ENDIF
     ELSE
      IF ((hold->pm_rpt_order[y].field_type="DQ8"))
       IF ((hold->pm_rpt_order[y].descending_ind=true))
        SET pn += 1
        SET pb[pn] = concat(" cnvtdate(",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->
          pm_rpt_order[y].field_name),")",
         " DESC,")
       ELSE
        SET pn += 1
        SET pb[pn] = concat(" cnvtdate(",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->
          pm_rpt_order[y].field_name),"),")
       ENDIF
      ELSE
       IF ((hold->pm_rpt_order[y].descending_ind=true))
        SET pn += 1
        SET pb[pn] = concat("  ",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->pm_rpt_order[y
          ].field_name)," DESC,")
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  ",trim(hold->pm_rpt_order[y].table_name),".",trim(hold->pm_rpt_order[y
          ].field_name),",")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET pn += 1
 SET pb[pn] = "HEAD REPORT"
 SET pn += 1
 SET pb[pn] = "  dummy = 0"
 IF ((hold->total_ind=true))
  SET pn += 1
  SET pb[pn] = "  total = 0"
  SET pn += 1
  SET pb[pn] = "  grand_total = 0"
  SET pn += 1
  SET pb[pn] = "  grand_item_price = 0.00"
  SET pn += 1
  SET pb[pn] = "  grand_gross_price = 0.00"
  SET pn += 1
  SET pb[pn] = "  grand_item_ext_price = 0.00"
 ENDIF
 SET pn += 1
 SET pb[pn] = "HEAD PAGE"
 SET pn += 1
 SET pb[pn] = "ROW + 1"
 SET pn += 1
 SET pb[pn] = '  col 0, "DATE: "'
 SET pn += 1
 SET pb[pn] = '  col 11, curdate "ddmmmyyyy;;d"'
 SET pn += 1
 IF ((hold->landscape_ind=0))
  SET pb[pn] = concat('  col 40, "',trim(hold->title),'"')
  SET pn += 1
  SET pb[pn] = '  col 106, "TIME: "'
  SET pn += 1
  SET pb[pn] = '  col 116, curtime3 "hh:mm:ss;;m"'
  SET pn += 1
  SET pb[pn] = "  row + 1"
  SET pn += 1
  SET pb[pn] = '  col 0, "REPORT_ID: "'
  SET pn += 1
  SET pb[pn] = concat('  col 11,"',trim(cnvtstring(hold->report_id,17,2)),'"')
  SET pn += 1
  SET pb[pn] = '  col 106, "PREPARED: "'
  SET pn += 1
  SET pb[pn] = concat("  col 116, ",'"',substring(1,15,trim(request->curuser)),'"')
  SET pn += 1
  SET pb[pn] = "  row + 1"
  SET pn += 1
  SET pb[pn] = concat('  col 0, "RETENTION: "')
  SET pn += 1
  SET pb[pn] = concat('  col 11,"',trim(cnvtstring(hold->retention_days)),' days"')
  SET pn += 1
  SET pb[pn] = concat('  col 106, "PAGE NO: "')
  SET pn += 1
  SET pb[pn] = '  col 116, curpage "####;l"'
  SET pn += 1
 ELSE
  SET pb[pn] = concat('  col 75, "',trim(hold->title),'"')
  SET pn += 1
  SET pb[pn] = '  col 160, "TIME: "'
  SET pn += 1
  SET pb[pn] = '  col 170, curtime3 "hh:mm:ss;;m"'
  SET pn += 1
  SET pb[pn] = "row + 1"
  SET pn += 1
  SET pb[pn] = '  col 0, "REPORT_ID: "'
  SET pn += 1
  SET pb[pn] = concat('  col 11,"',trim(cnvtstring(hold->report_id,17,2)),'"')
  SET pn += 1
  SET pb[pn] = '  col 160, "PREPARED: "'
  SET pn += 1
  SET pb[pn] = concat("  col 170, ",'"',trim(request->curuser),'"')
  SET pn += 1
  SET pb[pn] = "row + 1"
  SET pn += 1
  SET pb[pn] = concat('  col 0, "RETENTION: "')
  SET pn += 1
  SET pb[pn] = concat('  col 11,"',trim(cnvtstring(hold->retention_days)),' days"')
  SET pn += 1
  SET pb[pn] = concat('  col 160, "PAGE NO: "')
  SET pn += 1
  SET pb[pn] = '  col 170, curpage "####;l"'
  SET pn += 1
 ENDIF
 SET pb[pn] = "  row + 2"
 FOR (y = 1 TO hold->pm_rpt_header_qual)
   SET pn += 1
   SET temp_size = size(trim(hold->pm_rpt_header[y].header_display))
   IF ((temp_size <= hold->pm_rpt_header[y].header_length))
    SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),', "',trim(substring(1,temp_size,trim(hold->
        pm_rpt_header[y].header_display))),'"')
   ELSE
    SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),', "',trim(substring(1,hold->pm_rpt_header[y].
       header_length,trim(hold->pm_rpt_header[y].header_display))),'"')
   ENDIF
   SET cp += hold->pm_rpt_header[y].header_length
   SET cp += 3
 ENDFOR
 SET cp = 0
 SET pn += 1
 SET pb[pn] = "  row + 1"
 FOR (y = 1 TO hold->pm_rpt_header_qual)
   SET pn += 1
   SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),', "',substring(1,hold->pm_rpt_header[y].
     header_length,fill),'"')
   SET cp += hold->pm_rpt_header[y].header_length
   SET cp += 3
 ENDFOR
 SET pn += 1
 SET pb[pn] = "  row + 1"
 IF ((hold->pm_rpt_group_qual > 0))
  FOR (y = 1 TO hold->pm_rpt_group_qual)
    CASE (hold->pm_rpt_group[y].table_name)
     OF "CHARGE":
      SET hold->pm_rpt_group[y].table_name = "C"
     OF "ENCOUNTER":
      SET hold->pm_rpt_group[y].table_name = "E"
     OF "PERSON":
      SET hold->pm_rpt_group[y].table_name = "P"
     OF "CODE_VALUE":
      SET hold->pm_rpt_group[y].table_name = "CV"
     OF "ENCNTR_ALIAS":
      CASE (hold->pm_rpt_group[y].field_help)
       OF "MRN":
        SET hold->pm_rpt_group[y].table_name = "EA1"
       OF "FIN":
        SET hold->pm_rpt_group[y].table_name = "EA2"
      ENDCASE
     OF "ACCESSION_ORDER_R":
      SET hold->pm_rpt_group[y].table_name = "AOR"
     OF "ORGANIZATION":
      SET hold->pm_rpt_group[y].table_name = "ORG"
      SET hold->pm_rpt_group[y].table_name = "BO"
     OF "CHARGE_MOD":
      CASE (hold->pm_rpt_group[y].field_help)
       OF "CPT4":
        SET hold->pm_rpt_group[y].table_name = "CM1"
       OF "CDM":
        SET hold->pm_rpt_group[y].table_name = "CM2"
       OF "ICD9":
        SET hold->pm_rpt_group[y].table_name = "CM3"
       OF "GL1":
        SET hold->pm_rpt_group[y].table_name = "CM4"
       OF "SNWMED":
        SET hold->pm_rpt_group[y].table_name = "CM5"
       OF "PROC":
        SET hold->pm_rpt_group[y].table_name = "CM6"
       OF "MODRSN":
        SET hold->pm_rpt_group[y].table_name = "CM7"
       ELSE
        IF (modrsncd_yn="Y")
         SET hold->pm_rpt_order[y].table_name = "CM7"
        ELSE
         SET hold->pm_rpt_group[y].table_name = "CM"
        ENDIF
      ENDCASE
    ENDCASE
  ENDFOR
  FOR (y = 1 TO hold->pm_rpt_group_qual)
    IF ((hold->pm_rpt_group[y].field_type="DQ8"))
     SET pn += 1
     SET pb[pn] = concat("HEAD ",trim(hold->pm_rpt_group[y].table_name),trim(hold->pm_rpt_group[y].
       field_name))
    ELSE
     SET pn += 1
     SET pb[pn] = concat("HEAD ",trim(hold->pm_rpt_group[y].table_name),".",trim(hold->pm_rpt_group[y
       ].field_name))
    ENDIF
    SET pn += 1
    SET pb[pn] = concat("  ",trim(hold->pm_rpt_group[y].field_name),"_TOTAL = 0")
  ENDFOR
 ENDIF
 SET pn += 1
 SET pb[pn] = "  hold_item_price = 0.00"
 SET pn += 1
 SET pb[pn] = "  hold_discount_amount = 0.00"
 SET pn += 1
 SET pb[pn] = "  hold_gross_price = 0.00"
 SET pn += 1
 SET pb[pn] = "  hold_item_ext_price = 0.00"
 SET pn += 1
 SET pb[pn] = "  item_price = 0.00"
 SET pn += 1
 SET pb[pn] = "  gross_price = 0.00"
 SET pn += 1
 SET pb[pn] = "  item_ext_price = 0.00"
 SET pn += 1
 SET pb[pn] = "HEAD C.CHARGE_ITEM_ID"
 SET pn += 1
 SET pb[pn] = "  charge_item_id_total = 0"
 IF ((hold->detail_ind=true))
  SET cp = 0
  SET pn += 1
  SET pb[pn] = "DETAIL"
  IF ((hold->total_ind=true))
   SET pn += 1
   SET pb[pn] = "  grand_item_price = grand_item_price + item_price"
   SET pn += 1
   SET pb[pn] = "  grand_total = grand_total + 1"
  ENDIF
  IF ((hold->pm_rpt_group_qual > 0))
   FOR (y = 1 TO hold->pm_rpt_group_qual)
    SET pn += 1
    SET pb[pn] = concat("  ",trim(hold->pm_rpt_group[y].field_name),"_TOTAL = ",trim(hold->
      pm_rpt_group[y].field_name),"_TOTAL + 1")
   ENDFOR
  ENDIF
  FOR (y = 1 TO hold->pm_rpt_header_qual)
    CASE (hold->pm_rpt_header[y].field_type)
     OF "F8":
      IF (((substring((size(trim(hold->pm_rpt_header[y].field_name)) - 2),3,hold->pm_rpt_header[y].
       field_name)="_CD") OR ((hold->pm_rpt_header[y].field_name="FIELD1_ID"))) )
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        trim(hold->pm_rpt_header[y].field_name))
      ELSEIF ((hold->pm_rpt_header[y].field_name="FIELD2_ID")
       AND (hold->pm_rpt_header[y].table_name="CM7"))
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        trim(hold->pm_rpt_header[y].field_name))
      ELSE
       IF ((hold->pm_rpt_header[y].field_help="PRICE"))
        IF ((hold->pm_rpt_header[y].field_name="ITEM_PRICE"))
         SET item_price_yn = "y"
         SET item_price_col = cp
         SET pn += 1
         SET pb[pn] = concat("  if ((c.charge_type_cd =",trim(cnvtstring(value(credit_cd),17,2)),
          ") and (c.activity_type_cd =",trim(cnvtstring(value(pharmacy_cd),17,2))," ))")
         SET pn += 1
         SET pb[pn] = "     item_price = -1*round(abs(C.ITEM_PRICE),2)"
         SET pn += 1
         SET pb[pn] = "     hold_item_price = hold_item_price + item_price"
         SET pn += 1
         SET pb[pn] = "  else"
         SET pn += 1
         SET pb[pn] = "     item_price = round(C.ITEM_PRICE,2)"
         SET pn += 1
         SET pb[pn] = "     hold_item_price = hold_item_price + item_price"
         SET pn += 1
         SET pb[pn] = "  endif"
         SET pn += 1
         SET pb[pn] = concat("  col ",trim(cnvtstring((cp - 2))),", ","item_price",'"')
         FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
           IF ((z=hold->pm_rpt_header[y].header_length))
            SET pb[pn] = concat(trim(pb[pn]),'.##;r"')
           ELSE
            SET pb[pn] = concat(trim(pb[pn]),"#")
           ENDIF
         ENDFOR
        ENDIF
        IF ((hold->pm_rpt_header[y].field_name="ITEM_EXTENDED_PRICE"))
         SET item_ext_price_yn = "y"
         SET item_ext_price_col = cp
         SET pn += 1
         SET pb[pn] = concat("  if ((c.charge_type_cd =",trim(cnvtstring(value(credit_cd),17,2)),
          ") and (c.activity_type_cd =",trim(cnvtstring(value(pharmacy_cd),17,2)),"))")
         SET pn += 1
         SET pb[pn] = "     item_ext_price = -1*round(abs(C.ITEM_EXTENDED_PRICE),2)"
         SET pn += 1
         SET pb[pn] = "     hold_item_ext_price = hold_item_ext_price + item_ext_price"
         SET pn += 1
         SET pb[pn] = "  else"
         SET pn += 1
         SET pb[pn] = "     item_ext_price = round(C.ITEM_EXTENDED_PRICE,2)"
         SET pn += 1
         SET pb[pn] = "     hold_item_ext_price = hold_item_ext_price + item_ext_price"
         SET pn += 1
         SET pb[pn] = "  endif"
         SET pn += 1
         SET pb[pn] = concat("  col ",trim(cnvtstring((cp - 2))),", ","item_ext_price",'"')
         FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
           IF ((z=hold->pm_rpt_header[y].header_length))
            SET pb[pn] = concat(trim(pb[pn]),'.##;r"')
           ELSE
            SET pb[pn] = concat(trim(pb[pn]),"#")
           ENDIF
         ENDFOR
        ENDIF
        IF ((hold->pm_rpt_header[y].field_name="GROSS_PRICE"))
         SET gross_price_yn = "y"
         SET gross_price_col = cp
         SET pn += 1
         SET pb[pn] = concat("  if ((c.charge_type_cd =",trim(cnvtstring(value(credit_cd),17,2)),
          ") and (c.activity_type_cd =",trim(cnvtstring(value(pharmacy_cd),17,2)),"))")
         SET pn += 1
         SET pb[pn] = "     gross_price = -1*round(abs(C.GROSS_PRICE),2)"
         SET pn += 1
         SET pb[pn] = "     hold_gross_price = hold_gross_price + gross_price"
         SET pn += 1
         SET pb[pn] = "  else"
         SET pn += 1
         SET pb[pn] = "     gross_price = round(C.GROSS_PRICE,2)"
         SET pn += 1
         SET pb[pn] = "     hold_gross_price = hold_gross_price + gross_price"
         SET pn += 1
         SET pb[pn] = "  endif"
         SET pn += 1
         SET pb[pn] = concat("  col ",trim(cnvtstring((cp - 2))),", ","gross_price",'"')
         FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
           IF ((z=hold->pm_rpt_header[y].header_length))
            SET pb[pn] = concat(trim(pb[pn]),'.##;r"')
           ELSE
            SET pb[pn] = concat(trim(pb[pn]),"#")
           ENDIF
         ENDFOR
        ENDIF
        IF ((hold->pm_rpt_header[y].field_name="DISCOUNT_AMOUNT"))
         SET discount_amount_yn = "y"
         SET discount_amount_col = cp
         SET pn += 1
         SET pb[pn] = "  hold_discount_amount = hold_discount_amount + round(C.DISCOUNT_AMOUNT,2)"
        ENDIF
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name
          ),".",
         trim(hold->pm_rpt_header[y].field_name),'"')
        FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
          IF ((z=hold->pm_rpt_header[y].header_length))
           SET pb[pn] = concat(trim(pb[pn]),'#;l"')
          ELSE
           SET pb[pn] = concat(trim(pb[pn]),"#")
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     OF "I2":
      SET pn += 1
      SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
       ".",
       trim(hold->pm_rpt_header[y].field_name),' "')
      FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
        IF ((z=hold->pm_rpt_header[y].header_length))
         SET pb[pn] = concat(trim(pb[pn]),'#;l"')
        ELSE
         SET pb[pn] = concat(trim(pb[pn]),"#")
        ENDIF
      ENDFOR
     OF "I4":
      IF ((hold->pm_rpt_header[y].table_name="C")
       AND (hold->pm_rpt_header[y].field_name="PROCESS_FLG"))
       SET pn += 1
       SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
         field_name)," = trim(substring(1,10,cv.display))")
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        trim(hold->pm_rpt_header[y].field_name))
      ELSE
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        ".",
        trim(hold->pm_rpt_header[y].field_name),' "')
       FOR (z = 1 TO hold->pm_rpt_header[y].header_length)
         IF ((z=hold->pm_rpt_header[y].header_length))
          SET pb[pn] = concat(trim(pb[pn]),'#;l"')
         ELSE
          SET pb[pn] = concat(trim(pb[pn]),"#")
         ENDIF
       ENDFOR
      ENDIF
     OF "DQ8":
      IF ((hold->pm_rpt_header[y].time_ind=true))
       IF ((hold->pm_rpt_header[y].seconds_ind=true))
        SET pn += 1
        SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name
          ),".",
         trim(hold->pm_rpt_header[y].field_name),' "DD/MMM/YYYY HH:MM:SS"')
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name
          ),".",
         trim(hold->pm_rpt_header[y].field_name),' "DD/MMM/YYYY HH:MM"')
       ENDIF
      ELSE
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        ".",
        trim(hold->pm_rpt_header[y].field_name),' "DD/MMM/YYYY"')
      ENDIF
     ELSE
      IF ((hold->pm_rpt_header[y].table_name="AOR"))
       SET pn += 1
       SET pb[pn] = " If (aor.accession_id > 0 and aor.accession_id != NULL)"
       SET pn += 1
       SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
         field_name)," = uar_fmt_accession(aor.accession, size(aor.accession,1))")
       SET pn += 1
       SET pb[pn] = " else"
       SET pn += 1
       SET pb[pn] = '  AORACCESSION = ""'
       SET pn += 1
       SET pb[pn] = " endif"
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        trim(hold->pm_rpt_header[y].field_name))
      ELSE
       SET pn += 1
       SET pb[pn] = concat("  ",trim(hold->pm_rpt_header[y].table_name),trim(hold->pm_rpt_header[y].
         field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_header[y].header_length)),
        ", ",trim(hold->pm_rpt_header[y].table_name),".",trim(hold->pm_rpt_header[y].field_name),"))"
        )
       SET pn += 1
       SET pb[pn] = concat("  col ",trim(cnvtstring(cp)),", ",trim(hold->pm_rpt_header[y].table_name),
        trim(hold->pm_rpt_header[y].field_name))
      ENDIF
    ENDCASE
    SET cp += hold->pm_rpt_header[y].header_length
    SET cp += 3
  ENDFOR
 ELSE
  IF ((hold->total_ind=true))
   SET pn += 1
   SET pb[pn] = "DETAIL"
   SET pn += 1
   IF ((hold->detail_ind=false))
    SET pb[pn] = "  grand_item_price = grand_item_price + item_price"
    SET pn += 1
    SET pb[pn] = "  grand_total = grand_total + 1"
   ENDIF
   IF ((hold->pm_rpt_group_qual > 0))
    FOR (y = 1 TO hold->pm_rpt_group_qual)
     SET pn += 1
     SET pb[pn] = concat("  ",trim(hold->pm_rpt_group[y].field_name),"_TOTAL = ",trim(hold->
       pm_rpt_group[y].field_name),"_TOTAL + 1")
    ENDFOR
   ENDIF
   FOR (y = 1 TO hold->pm_rpt_header_qual)
     IF ((hold->pm_rpt_header[y].field_name="ITEM_PRICE"))
      SET item_price_yn = "y"
      SET item_price_col = cp
      SET pn += 1
      SET pb[pn] = "     item_price = round(C.ITEM_PRICE,2)"
      SET pn += 1
      SET pb[pn] = "     hold_item_price = hold_item_price + item_price"
      SET pn += 1
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((hold->detail_ind=true))
  SET pn += 1
  SET pb[pn] = "FOOT  C.CHARGE_ITEM_ID"
  SET pn += 1
  SET pb[pn] = concat("  row + ",cnvtstring(linespace))
 ENDIF
 IF ((hold->pm_rpt_group_qual > 0))
  FOR (y = 1 TO hold->pm_rpt_group_qual)
    IF ((hold->pm_rpt_group[y].field_type="DQ8"))
     SET pn += 1
     SET pb[pn] = concat("FOOT  ",trim(hold->pm_rpt_group[y].table_name),trim(hold->pm_rpt_group[y].
       field_name))
    ELSE
     SET pn += 1
     SET pb[pn] = concat("FOOT  ",trim(hold->pm_rpt_group[y].table_name),".",trim(hold->pm_rpt_group[
       y].field_name))
    ENDIF
    SET pn += 1
    SET pb[pn] = concat("  row + ",cnvtstring(linespace))
    IF ((hold->pm_rpt_group[y].group_total_ind=true))
     CASE (hold->pm_rpt_group[y].field_type)
      OF "F8":
       IF (((substring((size(trim(hold->pm_rpt_group[y].field_name)) - 2),3,hold->pm_rpt_group[y].
        field_name)="_CD") OR ((hold->pm_rpt_header[y].field_name="FIELD1_ID"))) )
        SET pn += 1
        SET pb[pn] = concat("  temp_size = size(trim(",trim(hold->pm_rpt_group[y].table_name),trim(
          hold->pm_rpt_group[y].field_name),"))")
        SET pn += 1
        SET pb[pn] = concat('  col 3, "Total (", ',trim(hold->pm_rpt_group[y].table_name),trim(hold->
          pm_rpt_group[y].field_name))
        SET pn += 1
        SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
         '_TOTAL "#########;r"')
       ELSE
        SET pn += 1
        SET pb[pn] = concat("  temp_size = size(trim(cnvtstring(",trim(hold->pm_rpt_group[y].
          table_name),".",trim(hold->pm_rpt_group[y].field_name),")))")
        SET pn += 1
        SET pb[pn] = concat("  temp_attr = trim(cnvtstring(",trim(hold->pm_rpt_group[y].table_name),
         ".",trim(hold->pm_rpt_group[y].field_name),"))")
        SET pn += 1
        SET pb[pn] = '  col 3, "Total (", temp_attr'
        SET pn += 1
        SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
         '_TOTAL "#########;r"')
       ENDIF
      OF "DQ8":
       SET pn += 1
       SET pb[pn] = "  temp_size = 8"
       SET pn += 1
       SET pb[pn] = concat('  col 3, "Total (", ',trim(hold->pm_rpt_group[y].table_name),".",trim(
         hold->pm_rpt_group[y].field_name))
       SET pn += 1
       SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
        '_TOTAL "#########;r"')
      OF "I2":
       SET pn += 1
       SET pb[pn] = concat("  temp_size = size(trim(cnvtstring(",trim(hold->pm_rpt_group[y].
         table_name),".",trim(hold->pm_rpt_group[y].field_name),")))")
       SET pn += 1
       SET pb[pn] = concat("  temp_attr = trim(cnvtstring(",trim(hold->pm_rpt_group[y].table_name),
        ".",trim(hold->pm_rpt_group[y].field_name),"))")
       SET pn += 1
       SET pb[pn] = '  col 3, "Total (", temp_attr'
       SET pn += 1
       SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
        '_TOTAL "#########;r"')
      OF "I4":
       SET pn += 1
       SET pb[pn] = concat("  temp_size = size(trim(cnvtstring(",trim(hold->pm_rpt_group[y].
         table_name),".",trim(hold->pm_rpt_group[y].field_name),")))")
       SET pn += 1
       SET pb[pn] = concat("  temp_attr = trim(cnvtstring(",trim(hold->pm_rpt_group[y].table_name),
        ".",trim(hold->pm_rpt_group[y].field_name),"))")
       SET pn += 1
       SET pb[pn] = '  col 3, "Total (", temp_attr'
       SET pn += 1
       SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
        '_TOTAL "#########;r"')
      ELSE
       SET pn += 1
       SET pb[pn] = concat("  temp_size = size(trim(",trim(hold->pm_rpt_group[y].table_name),".",trim
        (hold->pm_rpt_group[y].field_name),"))")
       SET pn += 1
       SET pb[pn] = concat("  ",trim(hold->pm_rpt_group[y].table_name),trim(hold->pm_rpt_group[y].
         field_name)," = trim(substring(1,",trim(cnvtstring(hold->pm_rpt_group[y].header_length)),
        ", ",trim(hold->pm_rpt_group[y].table_name),".",trim(hold->pm_rpt_group[y].field_name),"))")
       SET pn += 1
       SET pb[pn] = concat('  col 3, "Total (", ',trim(hold->pm_rpt_group[y].table_name),trim(hold->
         pm_rpt_group[y].field_name))
       SET pn += 1
       SET pb[pn] = concat("  col 10 + temp_size,",'")"',",",trim(hold->pm_rpt_group[y].field_name),
        '_TOTAL "#########;r"')
     ENDCASE
    ENDIF
    IF (item_price_yn="y")
     SET pn += 1
     SET pb[pn] = concat("  row + 1")
     SET pn += 1
     SET pb[pn] = concat("  col 10 + temp_size,",'hold_item_price "#######.##"')
    ENDIF
    IF (item_ext_price_yn="y")
     SET pn += 1
     SET pb[pn] = concat("  row + 1")
     SET pn += 1
     SET pb[pn] = concat("  col 10 + temp_size,",'hold_item_ext_price "#######.##"')
     SET pn += 1
     SET pb[pn] = "  grand_item_ext_price = hold_item_ext_price + grand_item_ext_price "
    ENDIF
    IF (gross_price_yn="y")
     SET pn += 1
     SET pb[pn] = concat("  row + 1")
     SET pn += 1
     SET pb[pn] = concat("  col 10 + temp_size,",'hold_gross_price "#######.##"')
     SET pn += 1
     SET pb[pn] = "  grand_gross_price = hold_gross_price + grand_gross_price"
    ENDIF
    IF (discount_amount_yn="y")
     SET pn += 1
     SET pb[pn] = concat("  row + 1")
     SET pn += 1
     SET pb[pn] = concat("  col 10 + temp_size,",'hold_discount_amount "#######.##"')
     SET pn += 1
     SET pb[pn] = "  grand_discount_amount = hold_discount_amount + grand_discount_amount"
    ENDIF
    SET pn += 1
    SET pb[pn] = concat("  row + ",cnvtstring(linespace))
    SET pn += 1
    SET pb[pn] = concat("  row + ",cnvtstring(linespace))
  ENDFOR
 ENDIF
 IF ((hold->total_ind=true))
  SET pn += 1
  SET pb[pn] = "FOOT REPORT"
  SET pn += 1
  SET pb[pn] = concat("  row + ",cnvtstring(linespace))
  SET pn += 1
  SET pb[pn] = concat("  col 17,",'total "########;l"')
  SET pb[pn] = '  col 0,  "Report Grand Total: "'
  SET pn += 1
  SET pb[pn] = concat("  col 21,",'grand_total "########;l"')
  IF (item_price_yn="y")
   SET pn += 1
   SET pb[pn] = concat("  row + 1")
   SET pn += 1
   SET pb[pn] = '  col 0,  "Report Total: "'
   SET pn += 1
   SET pb[pn] = concat("  col ",trim(cnvtstring((item_price_col - 15))),", ",
    'grand_item_price "##########.##"')
  ENDIF
  IF (item_ext_price_yn="y")
   SET pn += 1
   SET pb[pn] = concat("  row + 1")
   SET pn += 1
   SET pb[pn] = '  col 0,  "Report Total: "'
   SET pn += 1
   SET pb[pn] = concat("  col ",trim(cnvtstring((item_ext_price_col - 15))),", ",
    'grand_item_ext_price "##########.##"')
  ENDIF
  IF (gross_price_yn="y")
   SET pn += 1
   SET pb[pn] = concat("  row + 1")
   SET pn += 1
   SET pb[pn] = '  col 0,  "Report Total: "'
   SET pn += 1
   SET pb[pn] = concat("  col ",trim(cnvtstring((gross_price_col - 15))),", ",
    'grand_gross_price "##########.##"')
  ENDIF
  IF (discount_amount_yn="y")
   SET pn += 1
   SET pb[pn] = concat("  row + 1")
   SET pn += 1
   SET pb[pn] = '  col 0,  "Report Total: "'
   SET pn += 1
   SET pb[pn] = concat("  col ",trim(cnvtstring((discount_amount_col - 15))),", ",
    'grand_discount_amount "##########.##"')
  ENDIF
 ENDIF
 SET pn += 1
 SET pb[pn] = "with"
 IF (acc_ind="Y")
  SET pn += 1
  SET pb[pn] = "  maxqual(aor,1), outerjoin = d7, dontcare = aor,"
 ENDIF
 IF (chargemod_ind="Y")
  SET pn += 1
  SET pb[pn] = "  outerjoin = d8, dontcare = cm,"
 ENDIF
 IF (cpt4_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm1,1), outerjoin = d2, dontcare = cm1,"
  ENDIF
 ENDIF
 IF (cdm_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm2,1), outerjoin = d3, dontcare = cm2,"
  ENDIF
 ENDIF
 IF (icd9_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm3,1), outerjoin = d4, dontcare = cm3,"
  ENDIF
 ENDIF
 IF (((modrsncomment_yn="Y") OR (modrsncd_yn="Y")) )
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = " maxqual(cm7,1), outerjoin = d10, dontcare = cm7,"
  ENDIF
 ENDIF
 IF (gl1_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm4,1), outerjoin = d5, dontcare = cm4,"
  ENDIF
 ENDIF
 IF (snwm_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm5,1), outerjoin = d6, dontcare = cm5,"
  ENDIF
 ENDIF
 IF (proccode_yn="Y")
  IF (filter_yn="N")
   SET pn += 1
   SET pb[pn] = "  maxqual(cm6,1), outerjoin = d9, dontcare = cm6,"
  ENDIF
 ENDIF
 IF (mrn_yn="Y")
  SET pn += 1
  SET pb[pn] = "  maxqual(ea1,1), outerjoin = d1, dontcare = ea1,"
 ENDIF
 IF (fin_nbr_yn="Y")
  SET pn += 1
  SET pb[pn] = "  maxqual(ea2,1), outerjoin = d15, dontcare = ea2,"
 ENDIF
 SET pn += 1
 IF ((hold->landscape_ind=0))
  SET pb[pn] = "  nocounter, compress, nullreport, maxrow = value(max_portrait) go"
 ELSE
  SET pb[pn] =
  "  nocounter, landscape, compress, nullreport, maxrow=value(max_landscape), maxcol=180, format=variable go"
 ENDIF
 IF ((request->debug_ind=true))
  SET debug_file = concat("CER_TEMP:PMDBG",trim(request->curuser),".DAT")
  SELECT INTO value(debug_file)
   d.seq
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO pn)
      col 0, pb[x], row + 1
    ENDFOR
   WITH nocounter, noheading, maxrow = 1,
    noformfeed, format = variable, maxcol = 150
  ;end select
 ENDIF
 FOR (x = 1 TO pn)
   CALL parser(pb[x])
 ENDFOR
#3099_create_report_exit
#4000_load_reply
 FREE DEFINE rtl
 DEFINE rtl concat(trim(request->file_name))
 SELECT INTO "NL:"
  log = r.line
  FROM rtlt r
  DETAIL
   nbr_lines += 1, stat = alterlist(reply->list,nbr_lines), reply->list[nbr_lines].line = r.line
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->nbr_lines = nbr_lines
 ENDIF
#4099_load_reply_exit
#9999_end
END GO
