CREATE PROGRAM afc_rpt_batch_charge_entry:dba
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
 DECLARE afc_rpt_batch_charge_entry_version = vc WITH private, noconstant("332421.FT.019")
 SET width = 132
 RECORD reply(
   1 bce_event_log_qual = i2
   1 report_file_name = vc
   1 bce_event_log[*]
     2 batch_num = f8
     2 person_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 service_dt_tm = dq8
     2 charge_description = vc
     2 icd9_diag_code1 = vc
     2 icd9_diag_code2 = vc
     2 icd9_diag_code3 = vc
     2 icd9_diag_code4 = vc
     2 icd9_diag_code5 = vc
     2 icd9_diag_code6 = vc
     2 icd9_diag_code7 = vc
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier4_cd = f8
     2 code_modifier1_disp = c40
     2 code_modifier2_disp = c40
     2 code_modifier3_disp = c40
     2 code_modifier4_disp = c40
     2 quantity = f8
     2 price = f8
     2 updt_dt_tm = dq8
     2 user = vc
     2 updt_id = f8
     2 acct = c50
     2 fin_class_disp = c60
     2 process_flg = i4
     2 batch_alias = c200
     2 batch_description = c200
     2 ext_master_event_id = f8
     2 fin_nbr = vc
     2 cpt = vc
     2 organization = c200
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cpt_struct(
   1 arr[*]
     2 code_value = f8
 )
 DECLARE user = c50
 SET user = fillstring(50," ")
 DECLARE begdate = f8 WITH public, noconstant(0.0)
 DECLARE enddate = f8 WITH public, noconstant(0.0)
 DECLARE totalbatchquantity = f8 WITH public, noconstant(0.0)
 DECLARE totalbatchamount = f8 WITH public, noconstant(0.0)
 DECLARE totalquantity = f8 WITH public, noconstant(0.0)
 DECLARE totalamount = f8 WITH public, noconstant(0.0)
 DECLARE grandtotalamount = f8 WITH public, noconstant(0.0)
 DECLARE grandtotalquantity = f8 WITH public, noconstant(0.0)
 DECLARE batchnum = f8 WITH public, noconstant(0.0)
 DECLARE doservicedatereport = i4 WITH public, noconstant(0)
 DECLARE totalpages = i4 WITH public, noconstant(0)
 DECLARE whereparser = vc WITH public, noconstant(fillstring(200," "))
 DECLARE fullorgname = vc WITH public, noconstant(fillstring(200," "))
 DECLARE batchalias = vc WITH public, noconstant(fillstring(200," "))
 DECLARE i = i4 WITH public, noconstant(0)
 IF ( NOT (validate(curlogicaldomainid)))
  DECLARE curlogicaldomainid = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF ( NOT (validate(logicaldomaininuse)))
  DECLARE logicaldomainsinuse = i2 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(iorglevelsecurity)))
  DECLARE iorglevelsecurity = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE cnt = i4
 DECLARE cnt2 = i4
 DECLARE cpt = f8
 DECLARE finnbr = f8
 DECLARE chargeentrycd = f8
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,finnbr)
 SET stat = uar_get_meaning_by_codeset(13016,"CHARGE ENTRY",1,chargeentrycd)
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(14002,"CPT4",cnt,cpt)
 SET stat = alterlist(cpt_struct->arr,cnt)
 IF (cnt > 0)
  SET cpt_struct->arr[1].code_value = cpt
 ENDIF
 IF (cnt > 1)
  FOR (cnt2 = 2 TO cnt)
    SET i = cnt2
    SET stat = uar_get_meaning_by_codeset(14002,"CPT4",i,cpt)
    SET cpt_struct->arr[cnt2].code_value = cpt
  ENDFOR
 ENDIF
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
  EXECUTE cpm_create_file_name "afc", "dat"
  SET file_name = cpm_cfn_info->file_name_path
  SET reply->report_file_name = file_name
 ELSE
  SET prtr_name = "FILE"
  SET file_name = "MINE"
 ENDIF
 IF (validate(request->batch_alias,"") != "")
  SET batchalias = trim(request->batch_alias,3)
 ENDIF
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date != null))
   SET begdate = cnvtdatetime(request->ops_date)
   SET enddate = cnvtdatetime(request->ops_date)
   SET begdate = cnvtdatetime(concat(format(begdate,"DD-MMM-YYYY;;D")," 00:00:00.00"))
   SET enddate = cnvtdatetime(concat(format(enddate,"DD-MMM-YYYY;;D")," 23:59:59.99"))
  ELSEIF ((request->service_dt_tm_f != null))
   SET begdate = cnvtdatetime(format(request->service_dt_tm_f,"DD-MMM-YYYY hh:mm;;D"))
   SET enddate = cnvtdatetime(format(request->service_dt_tm_t,"DD-MMM-YYYY hh:mm;;D"))
   SET user = request->user
   SET batchnum = cnvtreal(request->batch_num)
  ELSE
   SET user = request->user
   SET batchnum = cnvtreal(request->batch_num)
   SET begdate = null
   SET enddate = null
  ENDIF
 ELSE
  CALL text(4,4,"Beg Date            :")
  CALL text(5,4,"End Date            :")
  SET mydate = cnvtdatetime(concat(format(curdate,"DD-MMM-YYYY;;D")," 00:00:00.00"))
  CALL accept(4,29,"nndpppdnnnndnndnn;cs",format(mydate,"dd-mmm-yyyy hh:mm;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=curaccept)
  SET begdate = cnvtdatetime(curaccept)
  SET mydate = cnvtdatetime(concat(format(curdate,"DD-MMM-YYYY;;D")," 23:59:59.99"))
  CALL accept(5,29,"nndpppdnnnndnndnn;cs",format(mydate,"dd-mmm-yyyy hh:mm;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=curaccept)
  SET enddate = cnvtdatetime(curaccept)
  CALL text(9,4,"Batch Number        :")
  CALL accept(9,29,"X(15);C")
  SET batchnum = cnvtreal(curaccept)
 ENDIF
 SET logicaldomainsinuse = arelogicaldomainsinuse(null)
 SET reply->status_data.status = "F"
 IF (logicaldomainsinuse)
  IF (validate(request->batch_selection," ") != " ")
   IF (trim(request->batch_selection)="")
    GO TO end_program
   ELSE
    SET curlogicaldomainid = cnvtreal(trim(request->batch_selection))
   ENDIF
  ELSE
   IF ( NOT (getlogicaldomain(ld_concept_organization,curlogicaldomainid)))
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date=null))
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
      AND i.info_domain_id=curlogicaldomainid
     DETAIL
      iorglevelsecurity = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 CALL echo("MAIN SELECT")
 SET count1 = 0
 SET stat = alterlist(reply->bce_event_log,count1)
 CALL echo(batchalias)
 IF (batchnum > 0)
  SET whereparser = concat("b.batch_num = ",trim(cnvtstring(batchnum,17)),".0")
  SET doservicedatereport = 0
 ELSEIF (batchalias != "")
  SET whereparser = concat('b.batch_alias = "',batchalias,'"')
  SET doservicedatereport = 1
 ELSE
  SET whereparser = concat('b.service_dt_tm between cnvtdatetime("',format(begdate,
    "DD-MMM-YYYY hh:mm;;D"),'") and cnvtdatetime("',format(enddate,"DD-MMM-YYYY hh:mm;;D"),'")')
  SET doservicedatereport = 2
 ENDIF
 CALL echo(whereparser)
 SELECT
  IF (iorglevelsecurity)
   FROM bce_event_log b,
    organization o,
    person p,
    charge_event ce,
    charge c,
    encntr_alias ea,
    encounter e,
    prsnl pr
   PLAN (b
    WHERE parser(whereparser)
     AND b.active_ind=1
     AND b.submit_ind=1)
    JOIN (p
    WHERE p.person_id=b.person_id)
    JOIN (ce
    WHERE ce.ext_m_event_id=b.ext_master_event_id
     AND ce.ext_m_event_cont_cd=chargeentrycd)
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id
     AND ((c.parent_charge_item_id+ 0)=0.0))
    JOIN (e
    WHERE e.encntr_id=b.encntr_id)
    JOIN (o
    WHERE o.organization_id=e.organization_id
     AND o.logical_domain_id=curlogicaldomainid
     AND  EXISTS (
    (SELECT
     por.organization_id
     FROM prsnl_org_reltn por
     WHERE (por.person_id=reqinfo->updt_id)
      AND por.organization_id=o.organization_id
      AND por.active_ind=1
      AND ((por.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((por.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate)))))
    JOIN (pr
    WHERE pr.person_id=b.updt_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(b.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(finnbr))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ELSE
   FROM bce_event_log b,
    organization o,
    person p,
    charge_event ce,
    charge c,
    encntr_alias ea,
    encounter e,
    prsnl pr
   PLAN (b
    WHERE parser(whereparser)
     AND b.active_ind=1
     AND b.submit_ind=1)
    JOIN (p
    WHERE p.person_id=b.person_id)
    JOIN (ce
    WHERE ce.ext_m_event_id=b.ext_master_event_id
     AND ce.ext_m_event_cont_cd=chargeentrycd)
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id
     AND ((c.parent_charge_item_id+ 0)=0.0))
    JOIN (e
    WHERE e.encntr_id=b.encntr_id)
    JOIN (o
    WHERE o.organization_id=e.organization_id
     AND o.logical_domain_id=curlogicaldomainid)
    JOIN (pr
    WHERE pr.person_id=b.updt_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(b.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(finnbr))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ENDIF
  INTO "nl:"
  ORDER BY c.charge_item_id, c.charge_event_id
  DETAIL
   count1 += 1, stat = alterlist(reply->bce_event_log,count1), reply->bce_event_log[count1].batch_num
    = b.batch_num,
   reply->bce_event_log[count1].batch_alias = b.batch_alias, reply->bce_event_log[count1].
   batch_description = b.batch_description, reply->bce_event_log[count1].ext_master_event_id = b
   .ext_master_event_id,
   reply->bce_event_log[count1].quantity = b.quantity, reply->bce_event_log[count1].person_id = b
   .person_id, reply->bce_event_log[count1].encntr_id = b.encntr_id,
   reply->bce_event_log[count1].service_dt_tm = b.service_dt_tm, reply->bce_event_log[count1].
   charge_description = b.charge_description, reply->bce_event_log[count1].icd9_diag_code1 = b
   .diag_code1,
   reply->bce_event_log[count1].icd9_diag_code2 = b.diag_code2, reply->bce_event_log[count1].
   icd9_diag_code3 = b.diag_code3, reply->bce_event_log[count1].icd9_diag_code4 = b.diag_code4,
   reply->bce_event_log[count1].icd9_diag_code5 = b.diag_code5, reply->bce_event_log[count1].
   icd9_diag_code6 = b.diag_code6, reply->bce_event_log[count1].icd9_diag_code7 = b.diag_code7,
   reply->bce_event_log[count1].code_modifier1_cd = b.code_modifier1_cd, reply->bce_event_log[count1]
   .code_modifier2_cd = b.code_modifier2_cd, reply->bce_event_log[count1].code_modifier3_cd = b
   .code_modifier3_cd,
   reply->bce_event_log[count1].code_modifier4_cd = b.code_modifier4_cd, reply->bce_event_log[count1]
   .code_modifier1_disp = uar_get_code_display(b.code_modifier1_cd), reply->bce_event_log[count1].
   code_modifier2_disp = uar_get_code_display(b.code_modifier2_cd),
   reply->bce_event_log[count1].code_modifier3_disp = uar_get_code_display(b.code_modifier3_cd),
   reply->bce_event_log[count1].code_modifier4_disp = uar_get_code_display(b.code_modifier4_cd),
   reply->bce_event_log[count1].updt_dt_tm = b.updt_dt_tm,
   reply->bce_event_log[count1].updt_id = b.updt_id, reply->bce_event_log[count1].person_name = p
   .name_full_formatted, reply->bce_event_log[count1].price = c.item_extended_price,
   reply->bce_event_log[count1].process_flg = c.process_flg, reply->bce_event_log[count1].
   fin_class_disp = uar_get_code_display(e.financial_class_cd), reply->bce_event_log[count1].
   organization = o.org_name,
   reply->bce_event_log[count1].user = pr.username, reply->bce_event_log[count1].fin_nbr = cnvtalias(
    ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
 CALL echo(count1)
 SET stat = alterlist(reply->bce_event_log,count1)
 SET reply->bce_event_log_qual = count1
 IF (count1 > 0)
  SELECT INTO "nl:"
   c.charge_item_id, c.charge_event_id
   FROM (dummyt d1  WITH seq = value(reply->bce_event_log_qual)),
    (dummyt d2  WITH seq = value(size(cpt_struct->arr,5))),
    charge_event ce,
    charge c,
    charge_mod cm
   PLAN (d1)
    JOIN (ce
    WHERE (ce.ext_m_event_id=reply->bce_event_log[d1.seq].ext_master_event_id))
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id)
    JOIN (d2)
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND (cm.field1_id=cpt_struct->arr[d2.seq].code_value)
     AND cm.active_ind=1)
   ORDER BY c.charge_item_id, c.charge_event_id
   HEAD c.charge_event_id
    reply->bce_event_log[d1.seq].cpt = cm.field6
   DETAIL
    i += 1
   WITH nocounter
  ;end select
  SET first_time = 0
  SELECT INTO value(file_name)
   batch_num = trim(cnvtstring(reply->bce_event_log[d1.seq].batch_num,17),3), batch_alias = trim(
    reply->bce_event_log[d1.seq].batch_alias,3), batch_description = trim(reply->bce_event_log[d1.seq
    ].batch_description,3),
   organization = reply->bce_event_log[d1.seq].organization, patient = trim(substring(1,40,reply->
     bce_event_log[d1.seq].person_name),3), encntr = trim(cnvtstring(reply->bce_event_log[d1.seq].
     encntr_id,17),3),
   fin = trim(substring(1,40,reply->bce_event_log[d1.seq].fin_nbr),3), reportbegindate = format(
    cnvtdatetime(begdate),"MM/DD/YYYY hh:mm;R;DATE"), reportenddate = format(cnvtdatetime(enddate),
    "MM/DD/YYYY hh:mm;R;DATE"),
   servicedatetime = format(reply->bce_event_log[d1.seq].service_dt_tm,"MM/DD/YY;R;DATE"), submitdate
    = format(reply->bce_event_log[d1.seq].updt_dt_tm,"MM/DD/YY HH:MM;R;DATE"), chargedesc = substring
   (1,55,reply->bce_event_log[d1.seq].charge_description),
   cpt4 = substring(1,5,reply->bce_event_log[d1.seq].cpt), quantity = trim(cnvtstring(reply->
     bce_event_log[d1.seq].quantity),3), amount = reply->bce_event_log[d1.seq].price,
   suser = reply->bce_event_log[d1.seq].user, processflag = reply->bce_event_log[d1.seq].process_flg,
   sfinclass = reply->bce_event_log[d1.seq].fin_class_disp,
   diagcode1 = substring(1,8,reply->bce_event_log[d1.seq].icd9_diag_code1), diagcode2 = substring(1,8,
    reply->bce_event_log[d1.seq].icd9_diag_code2), diagcode3 = substring(1,8,reply->bce_event_log[d1
    .seq].icd9_diag_code3),
   diagcode4 = substring(1,8,reply->bce_event_log[d1.seq].icd9_diag_code4), diagcode5 = substring(1,8,
    reply->bce_event_log[d1.seq].icd9_diag_code5), diagcode6 = substring(1,8,reply->bce_event_log[d1
    .seq].icd9_diag_code6),
   diagcode7 = substring(1,8,reply->bce_event_log[d1.seq].icd9_diag_code7), smodcode1 = substring(1,2,
    reply->bce_event_log[d1.seq].code_modifier1_disp), smodcode2 = reply->bce_event_log[d1.seq].
   code_modifier2_disp,
   smodcode3 = reply->bce_event_log[d1.seq].code_modifier3_disp, smodcode4 = reply->bce_event_log[d1
   .seq].code_modifier4_disp
   FROM (dummyt d1  WITH seq = value(reply->bce_event_log_qual))
   ORDER BY organization, batch_num, encntr
   HEAD REPORT
    today = format(curdate,"MM/DD/YYYY;;D"), now = format(curtime,"HH:MM:SS;;S"), totalamount = 0.0,
    totalquantity = 0.0, totalbatchamount = 0.0, totalbatchquantity = 0.0,
    totalbillcodeencounter = 0.0, totalbillcodebatch = 0.0, totalbillcodegrand = 0.0,
    totalpages = 0
    IF (first_time=0)
     first_time = 1
    ENDIF
    row + 0
   HEAD PAGE
    row 0
    IF (doservicedatereport=0)
     col 52, "BCE Charges by Batch Number"
    ELSEIF (doservicedatereport=1)
     col 52, "BCE Charges by Batch Alias"
    ELSEIF (doservicedatereport=2)
     col 52, "BCE Charges by Service Date"
    ENDIF
    row + 1, fullorgname = trim(concat("Organization: ",trim(organization,3)),3), fullorgpos = ((132
     - size(fullorgname,1))/ 2),
    col fullorgpos, fullorgname
    IF (doservicedatereport=2)
     row + 1, col 39, "For Service Dates:",
     col + 1, reportbegindate, col + 1,
     "-", col + 1, reportenddate
    ENDIF
    row + 2, col 1, "Date:",
    col + 1, today, row + 1,
    col 1, "Time:", col + 1,
    now, col 120, "Page:",
    col + 1, curpage"#####"
    IF (first_time=0)
     row + 2
    ENDIF
    totalpages += 1
   HEAD organization
    IF (first_time=0)
     BREAK
    ELSE
     first_time = 0
    ENDIF
   HEAD batch_num
    totalbatchquantity = 0.0, totalbatchamount = 0.0
    IF (((row+ 7) > maxrow))
     BREAK
    ENDIF
    row + 2, col 1, "Batch Number:",
    col + 1, batch_num"###############", col 30,
    "Batch Alias:", col + 1, batch_alias"##############################",
    col 73, "Batch Description:", col + 1,
    batch_description"##############################", row + 1, col 1,
    "User:", col + 1, suser"###############",
    col 30, "Submit Date/Time:", col + 1,
    submitdate
   HEAD encntr
    totalquantity = 0.0, totalamount = 0.0
    IF (((row+ 7) > maxrow))
     BREAK
    ENDIF
    row + 2, col 1, "Person",
    col 45, "FIN", row + 1,
    col 1, patient, col 45,
    fin, row + 2, col 10,
    "Service Date", col 26, "CPT",
    col 33, "Charge Description", col 97,
    "Status", col 117, "Qty",
    col 126, "Price"
   DETAIL
    row + 1
    IF (((row+ 7) > maxrow))
     BREAK
    ENDIF
    col 12, servicedatetime, col 25,
    cpt4, col 33, chargedesc,
    processflagpos = 97
    IF (processflag=0)
     col processflagpos, "Pending"
    ELSEIF (processflag=1)
     col processflagpos, "Suspended"
    ELSEIF (processflag=2)
     col processflagpos, "Review"
    ELSEIF (processflag=3)
     col processflagpos, "On Hold"
    ELSEIF (processflag=4)
     col processflagpos, "Manual"
    ELSEIF (processflag=5)
     col processflagpos, "Skipped"
    ELSEIF (processflag=6)
     col processflagpos, "Combine"
    ELSEIF (processflag=7)
     col processflagpos, "Absorbed"
    ELSEIF (processflag=8)
     col processflagpos, "ABN Required"
    ELSEIF (processflag=10)
     col processflagpos, "Offset"
    ELSEIF (processflag=11)
     col processflagpos, "Adjusted"
    ELSEIF (processflag=12)
     col processflagpos, "Grouped"
    ELSEIF (processflag=777)
     col processflagpos, "Bundled"
    ELSEIF (processflag=177)
     col processflagpos, "Profit Bundled"
    ELSEIF (processflag=996)
     col processflagpos, "OMF Stats Only"
    ELSEIF (processflag=977)
     col processflagpos, "Bundled Interfaced"
    ELSEIF (processflag=100)
     col processflagpos, "Posted"
    ELSE
     otherprocessflag = cnvtstring(processflag), col processflagpos, otherprocessflag
    ENDIF
    col 117, quantity, col 122,
    amount"######.##", totalquantity += cnvtreal(quantity), totalamount += cnvtreal(amount),
    totalbatchquantity += cnvtreal(quantity), totalbatchamount += cnvtreal(amount),
    grandtotalquantity += cnvtreal(quantity),
    grandtotalamount += cnvtreal(amount)
   FOOT  encntr
    row + 2, col 90, "Encounter Total Quantity:",
    col 122, totalquantity"######.##", row + 1,
    col 90, "Encounter Total Amount:", col 122,
    totalamount"######.##"
   FOOT  batch_num
    row + 2, col 90, "Batch Total Quantity:",
    col 121, totalbatchquantity"#######.##", row + 1,
    col 90, "Batch Total Amount:", col 121,
    totalbatchamount"#######.##"
   FOOT REPORT
    IF (doservicedatereport=2)
     row + 2, col 90, "Report Total Quantity:",
     col 119, grandtotalquantity"#########.##", row + 1,
     col 90, "Report Total Amount:", col 119,
     grandtotalamount"#########.##"
    ENDIF
    row + 2, col 113, "Total Pages:",
    col + 1, totalpages"#####"
   WITH nocounter, compress, nolandscape,
    maxrow = 60, maxcol = 132
  ;end select
  IF (trim(printer) != " "
   AND validate(request->from_951351,0)=0)
   SET com = concat("print/que=",trim(prtr_name)," ",value(file_name))
   CALL dcl(com,size(trim(com)),0)
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_program
 FREE SET cpt_struct
END GO
