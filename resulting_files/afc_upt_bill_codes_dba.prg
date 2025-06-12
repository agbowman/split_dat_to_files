CREATE PROGRAM afc_upt_bill_codes:dba
 DECLARE afc_ct_execute_version = vc WITH private, noconstant("CHARGSRV-13483.FT.008")
 FREE SET scheds
 RECORD scheds(
   1 scheds[*]
     2 code_value = f8
     2 cdf_meaning = c12
 )
 FREE SET bill_codes
 RECORD bill_codes(
   1 codes[*]
     2 bill_item_mod_id = f8
     2 key3_id = f8
     2 key5_id = f8
 )
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
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_code_sched_cd = f8
 DECLARE cpt4_source_cd = f8
 DECLARE icd9_source_cd = f8
 DECLARE hcpcs_source_cd = f8
 DECLARE cnt2 = i4
 DECLARE code_value = f8
 DECLARE tmp_cnt = i4
 DECLARE lfirstpositionfortype = i4
 DECLARE curlogicaldomain = f8 WITH protect, noconstant(0.0)
 IF (validate(request->ops_date,999)=999)
  IF ( NOT (validate(reqinfo->updt_id,0.0) > 0.0))
   EXECUTE cclseclogin
   SET message = nowindow
  ENDIF
 ENDIF
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,bill_code_sched_cd)
 CALL echo(build("the bill code sched code value is: ",bill_code_sched_cd))
 SET codeset = 400
 SET cdf_meaning = "CPT4"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,cpt4_source_cd)
 CALL echo(build("the cpt4 source vocab code value is: ",cpt4_source_cd))
 SET codeset = 400
 SET cdf_meaning = "ICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,icd9_source_cd)
 CALL echo(build("the icd9 source vocab code value is: ",icd9_source_cd))
 SET codeset = 400
 SET cdf_meaning = "HCPCS"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,hcpcs_source_cd)
 CALL echo(build("the hcpcs source vocab code value is: ",hcpcs_source_cd))
 SET prompt_sched =  $1
 CALL echo(build("the sched sent in is: ",prompt_sched))
 IF (prompt_sched=0)
  DECLARE ntotalremaining = i4
  DECLARE nstartidx = i4
  DECLARE nstartoffset = i4
  DECLARE noccurances = i4
  DECLARE ncnt = i4
  DECLARE x = i4
  CALL echo("Beginning of CPT4 code list")
  DECLARE dcodelist[20] = f8
  SET ncnt = size(scheds->scheds,5)
  SET nstartoffset = ncnt
  SET nstartidx = 1
  SET noccurances = 20
  CALL uar_get_code_list_by_meaning(14002,"CPT4",nstartidx,noccurances,ntotalremaining,
   dcodelist)
  SET ncnt = ((ncnt+ noccurances)+ ntotalremaining)
  SET stat = alterlist(scheds->scheds,ncnt)
  FOR (x = (nstartoffset+ 1) TO (nstartoffset+ noccurances))
   SET scheds->scheds[x].code_value = dcodelist[(x - nstartoffset)]
   SET scheds->scheds[x].cdf_meaning = "CPT4"
  ENDFOR
  IF (ntotalremaining > 0)
   SET nstartidx = (noccurances+ 1)
   SET noccurances = ntotalremaining
   SET stat = memrealloc(dcodelist,noccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"CPT4",nstartidx,noccurances,ntotalremaining,
    dcodelist)
   FOR (x = (nstartoffset+ nstartidx) TO ncnt)
    SET scheds->scheds[x].code_value = dcodelist[(((x - nstartidx) - nstartoffset)+ 1)]
    SET scheds->scheds[x].cdf_meaning = "CPT4"
   ENDFOR
  ENDIF
  CALL echo("Beginning of HCPCS code list")
  SET stat = memrealloc(dcodelist,20,"f8")
  SET ncnt = size(scheds->scheds,5)
  SET nstartoffset = ncnt
  SET nstartidx = 1
  SET noccurances = 20
  CALL uar_get_code_list_by_meaning(14002,"HCPCS",nstartidx,noccurances,ntotalremaining,
   dcodelist)
  SET ncnt = ((ncnt+ noccurances)+ ntotalremaining)
  SET stat = alterlist(scheds->scheds,ncnt)
  FOR (x = (nstartoffset+ 1) TO (nstartoffset+ noccurances))
   SET scheds->scheds[x].code_value = dcodelist[(x - nstartoffset)]
   SET scheds->scheds[x].cdf_meaning = "HCPCS"
  ENDFOR
  IF (ntotalremaining > 0)
   SET nstartidx = (noccurances+ 1)
   SET noccurances = ntotalremaining
   SET stat = memrealloc(dcodelist,noccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"HCPCS",nstartidx,noccurances,ntotalremaining,
    dcodelist)
   FOR (x = (nstartoffset+ nstartidx) TO ncnt)
    SET scheds->scheds[x].code_value = dcodelist[(((x - nstartidx) - nstartoffset)+ 1)]
    SET scheds->scheds[x].cdf_meaning = "HCPCS"
   ENDFOR
  ENDIF
  CALL echo("Beginning of MODIFIER code list")
  SET stat = memrealloc(dcodelist,20,"f8")
  SET ncnt = size(scheds->scheds,5)
  SET nstartoffset = ncnt
  SET nstartidx = 1
  SET noccurances = 20
  CALL uar_get_code_list_by_meaning(14002,"MODIFIER",nstartidx,noccurances,ntotalremaining,
   dcodelist)
  SET ncnt = ((ncnt+ noccurances)+ ntotalremaining)
  SET stat = alterlist(scheds->scheds,ncnt)
  FOR (x = (nstartoffset+ 1) TO (nstartoffset+ noccurances))
   SET scheds->scheds[x].code_value = dcodelist[(x - nstartoffset)]
   SET scheds->scheds[x].cdf_meaning = "MODIFIER"
  ENDFOR
  IF (ntotalremaining > 0)
   SET nstartidx = (noccurances+ 1)
   SET noccurances = ntotalremaining
   SET stat = memrealloc(dcodelist,noccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"MODIFIER",nstartidx,noccurances,ntotalremaining,
    dcodelist)
   FOR (x = (nstartoffset+ nstartidx) TO ncnt)
    SET scheds->scheds[x].code_value = dcodelist[(((x - nstartidx) - nstartoffset)+ 1)]
    SET scheds->scheds[x].cdf_meaning = "MODIFIER"
   ENDFOR
  ENDIF
  CALL echo("Beginning of PROCCODE code list")
  SET stat = memrealloc(dcodelist,20,"f8")
  SET ncnt = size(scheds->scheds,5)
  SET nstartoffset = ncnt
  SET nstartidx = 1
  SET noccurances = 20
  CALL uar_get_code_list_by_meaning(14002,"PROCCODE",nstartidx,noccurances,ntotalremaining,
   dcodelist)
  SET ncnt = ((ncnt+ noccurances)+ ntotalremaining)
  SET stat = alterlist(scheds->scheds,ncnt)
  FOR (x = (nstartoffset+ 1) TO (nstartoffset+ noccurances))
   SET scheds->scheds[x].code_value = dcodelist[(x - nstartoffset)]
   SET scheds->scheds[x].cdf_meaning = "PROCCODE"
  ENDFOR
  IF (ntotalremaining > 0)
   SET nstartidx = (noccurances+ 1)
   SET noccurances = ntotalremaining
   SET stat = memrealloc(dcodelist,noccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"PROCCODE",nstartidx,noccurances,ntotalremaining,
    dcodelist)
   FOR (x = (nstartoffset+ nstartidx) TO ncnt)
    SET scheds->scheds[x].code_value = dcodelist[(((x - nstartidx) - nstartoffset)+ 1)]
    SET scheds->scheds[x].cdf_meaning = "PROCCODE"
   ENDFOR
  ENDIF
  CALL echo("Beginning of REVENUE code list")
  SET stat = memrealloc(dcodelist,20,"f8")
  SET ncnt = size(scheds->scheds,5)
  SET nstartoffset = ncnt
  SET nstartidx = 1
  SET noccurances = 20
  CALL uar_get_code_list_by_meaning(14002,"REVENUE",nstartidx,noccurances,ntotalremaining,
   dcodelist)
  SET ncnt = ((ncnt+ noccurances)+ ntotalremaining)
  SET stat = alterlist(scheds->scheds,ncnt)
  FOR (x = (nstartoffset+ 1) TO (nstartoffset+ noccurances))
   SET scheds->scheds[x].code_value = dcodelist[(x - nstartoffset)]
   SET scheds->scheds[x].cdf_meaning = "REVENUE"
  ENDFOR
  IF (ntotalremaining > 0)
   SET nstartidx = (noccurances+ 1)
   SET noccurances = ntotalremaining
   SET stat = memrealloc(dcodelist,noccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"REVENUE",nstartidx,noccurances,ntotalremaining,
    dcodelist)
   FOR (x = (nstartoffset+ nstartidx) TO ncnt)
    SET scheds->scheds[x].code_value = dcodelist[(((x - nstartidx) - nstartoffset)+ 1)]
    SET scheds->scheds[x].cdf_meaning = "REVENUE"
   ENDFOR
  ENDIF
  CALL echo("Beginning of CDM code list")
  IF (processcdms(curlogicaldomain))
   RECORD cdmrequest(
     1 key1_entity_name = vc
     1 info_name = vc
     1 bc_sched_type = vc
   ) WITH protect
   RECORD cdmreply(
     1 bc_usr_org_reltn[*]
       2 code_value = f8
       2 display = vc
     1 bc_usr_org_count = f8
   ) WITH protect
   SET cdmrequest->info_name = "BILL CODE SCHED SECURITY"
   SET cdmrequest->key1_entity_name = "BC_SCHED"
   SET cdmrequest->bc_sched_type = "CDM_SCHED"
   EXECUTE afc_billcode_org_for_user  WITH replace("REQUEST",cdmrequest), replace("REPLY",cdmreply)
   SET nstartoffset = ncnt
   SET ncnt += cdmreply->bc_usr_org_count
   SET stat = alterlist(scheds->scheds,ncnt)
   FOR (x = (nstartoffset+ 1) TO ncnt)
    SET scheds->scheds[x].code_value = cdmreply->bc_usr_org_reltn[(x - nstartoffset)].code_value
    SET scheds->scheds[x].cdf_meaning = "CDM_SCHED"
   ENDFOR
  ENDIF
  CALL echorecord(scheds)
  FOR (i_var = 1 TO value(size(scheds->scheds,5)))
    CALL echo(scheds->scheds[i_var].cdf_meaning)
    CALL echo(scheds->scheds[i_var].code_value)
    CASE (scheds->scheds[i_var].cdf_meaning)
     OF "CDM_SCHED":
      CALL upt_cdm(scheds->scheds[i_var].code_value,curlogicaldomain)
     OF "CPT4":
      CALL upt_nomen(scheds->scheds[i_var].code_value,cpt4_source_cd)
     OF "HCPCS":
      CALL upt_nomen(scheds->scheds[i_var].code_value,hcpcs_source_cd)
     OF "PROCCODE":
      CALL upt_nomen(scheds->scheds[i_var].code_value,icd9_source_cd)
     OF "MODIFIER":
      CALL upt_cv(scheds->scheds[i_var].code_value,17769)
     OF "REVENUE":
      CALL upt_cv(scheds->scheds[i_var].code_value,20769)
     ELSE
      CALL echo("No cdf_meaning found!")
    ENDCASE
  ENDFOR
 ELSE
  SET cdf_meaning = fillstring(12," ")
  SET code_value = prompt_sched
  SET cdf_meaning = uar_get_code_meaning(code_value)
  CALL echo(build("cdf_meaning is: ",cdf_meaning))
  CASE (cdf_meaning)
   OF "CDM_SCHED":
    CALL upt_cdm(code_value,curlogicaldomain)
   OF "CPT4":
    CALL upt_nomen(code_value,cpt4_source_cd)
   OF "HCPCS":
    CALL upt_nomen(code_value,hcpcs_source_cd)
   OF "PROCCODE":
    CALL upt_nomen(code_value,icd9_source_cd)
   OF "MODIFIER":
    CALL upt_cv(code_value,17769)
   OF "REVENUE":
    CALL upt_cv(code_value,20769)
   ELSE
    CALL echo("No cdf_meaning found!")
  ENDCASE
 ENDIF
 SUBROUTINE upt_nomen(sched_passed,source_cd)
   DECLARE bc_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bill_item_modifier bm,
     nomenclature n
    PLAN (bm
     WHERE bm.key1_id=sched_passed
      AND bm.active_ind=1
      AND bm.bill_item_type_cd=bill_code_sched_cd)
     JOIN (n
     WHERE n.source_vocabulary_cd=source_cd
      AND n.source_identifier=trim(bm.key6)
      AND n.beg_effective_dt_tm <= bm.end_effective_dt_tm
      AND n.end_effective_dt_tm >= bm.beg_effective_dt_tm
      AND n.beg_effective_dt_tm != n.end_effective_dt_tm
      AND n.active_ind=1)
    ORDER BY bm.bill_item_mod_id, n.end_effective_dt_tm DESC
    HEAD bm.bill_item_mod_id
     IF (bm.key3_id != n.nomenclature_id
      AND bm.bill_item_mod_id > 0)
      bc_count += 1, stat = alterlist(bill_codes->codes,bc_count), bill_codes->codes[bc_count].
      bill_item_mod_id = bm.bill_item_mod_id,
      bill_codes->codes[bc_count].key3_id = n.nomenclature_id
     ENDIF
    WITH nocounter
   ;end select
   IF (size(bill_codes->codes,5) > 0)
    UPDATE  FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(size(bill_codes->codes,5)))
     SET bm.key3_id = bill_codes->codes[d1.seq].key3_id, bm.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), bm.key3_entity_name = "NOMENCLATURE",
      bm.updt_id = reqinfo->updt_id, bm.updt_cnt = (bm.updt_cnt+ 1), bm.updt_task = reqinfo->
      updt_task
     PLAN (d1)
      JOIN (bm
      WHERE (bm.bill_item_mod_id=bill_codes->codes[d1.seq].bill_item_mod_id))
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_cv(sched_sent_in,cd_set)
   DECLARE bc_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bill_item_modifier bm,
     code_value cv
    PLAN (bm
     WHERE bm.key1_id=sched_sent_in
      AND bm.active_ind=1
      AND bm.bill_item_type_cd=bill_code_sched_cd)
     JOIN (cv
     WHERE cv.code_set=cd_set
      AND cv.active_ind=1
      AND cv.display=trim(bm.key6))
    ORDER BY bm.bill_item_mod_id, cv.code_value
    HEAD bm.bill_item_mod_id
     IF (bm.key5_id != cv.code_value)
      bc_count += 1, stat = alterlist(bill_codes->codes,bc_count), bill_codes->codes[bc_count].
      bill_item_mod_id = bm.bill_item_mod_id,
      bill_codes->codes[bc_count].key5_id = cv.code_value
     ENDIF
    WITH nocounter
   ;end select
   IF (size(bill_codes->codes,5) > 0)
    UPDATE  FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(size(bill_codes->codes,5)))
     SET bm.key5_id = bill_codes->codes[d1.seq].key5_id, bm.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), bm.updt_id = reqinfo->updt_id,
      bm.updt_cnt = (bm.updt_cnt+ 1), bm.updt_task = reqinfo->updt_task
     PLAN (d1)
      JOIN (bm
      WHERE (bm.bill_item_mod_id=bill_codes->codes[d1.seq].bill_item_mod_id))
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (upt_cdm(sched_sent_in=f8,cur_logical_domain_id=f8) =null)
   DECLARE bc_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bill_item_modifier bm,
     charge_desc_master cdm
    PLAN (bm
     WHERE bm.key1_id=sched_sent_in
      AND bm.active_ind=1
      AND bm.bill_item_type_cd=bill_code_sched_cd)
     JOIN (cdm
     WHERE cdm.logical_domain_id=cur_logical_domain_id
      AND cdm.active_ind=1
      AND trim(cdm.cdm_code_txt)=trim(bm.key6))
    ORDER BY bm.bill_item_mod_id, cdm.charge_desc_master_id
    HEAD bm.bill_item_mod_id
     IF (bm.key5_id != cdm.charge_desc_master_id)
      bc_count += 1, stat = alterlist(bill_codes->codes,bc_count), bill_codes->codes[bc_count].
      bill_item_mod_id = bm.bill_item_mod_id,
      bill_codes->codes[bc_count].key5_id = cdm.charge_desc_master_id
     ENDIF
    WITH nocounter
   ;end select
   IF (size(bill_codes->codes,5) > 0)
    UPDATE  FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(size(bill_codes->codes,5)))
     SET bm.key5_id = bill_codes->codes[d1.seq].key5_id, bm.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), bm.updt_id = reqinfo->updt_id,
      bm.updt_cnt = (bm.updt_cnt+ 1), bm.updt_task = reqinfo->updt_task
     PLAN (d1)
      JOIN (bm
      WHERE (bm.bill_item_mod_id=bill_codes->codes[d1.seq].bill_item_mod_id))
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (processcdms(logicaldomainid=f8(ref)) =i2)
   DECLARE bprocesscdms = i2 WITH protect, noconstant(true)
   SET logicaldomainid = 0.0
   IF (arelogicaldomainsinuse(null))
    IF (validate(reqinfo->updt_id,0.0) > 0.0)
     IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
      CALL logmessage("processCDMs","Failed to retrieve logical domain",log_error)
      GO TO exit_script
     ENDIF
     RECORD bc_sec_request(
       1 info_name_qual = i2
       1 info[*]
         2 info_name = vc
       1 info_name = vc
     ) WITH protect
     RECORD bc_sec_reply(
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
     ) WITH protect
     SET bc_sec_request->info_name_qual = 1
     SET stat = alterlist(bc_sec_request->info,1)
     SET bc_sec_request->info[1].info_name = "BILL CODE SCHED SECURITY"
     EXECUTE afc_get_dm_info  WITH replace("REQUEST",bc_sec_request), replace("REPLY",bc_sec_reply)
     IF ((((bc_sec_reply->status_data.status != "S")) OR (cnvtupper(bc_sec_reply->dm_info[1].
      info_char) != "Y")) )
      CALL logmessage("processCDMs",
       "Multiple logicals in use, but bill code schedule security is not on, skipping CDMs",log_info)
      SET bprocesscdms = false
     ENDIF
    ELSE
     CALL logmessage("processCDMs","Logical domains in use, and login was bypassed, skipping CDMs",
      log_info)
     SET bprocesscdms = false
    ENDIF
   ENDIF
   RETURN(bprocesscdms)
 END ;Subroutine
#exit_script
END GO
