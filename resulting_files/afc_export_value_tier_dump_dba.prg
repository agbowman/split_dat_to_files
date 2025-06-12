CREATE PROGRAM afc_export_value_tier_dump:dba
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
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE rowcount = i4 WITH protect, noconstant(0.0)
 IF (arelogicaldomainsinuse(0))
  IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
   CALL exitservicefailure("Unable to retrieve LOGICAL_DOMAIN_ID",go_to_exit_script)
  ENDIF
 ENDIF
 IF (cursys="AIX")
  SET syscmd = "rm $CCLUSERDIR/afc_tier_values.*"
  SET len = size(trim(syscmd))
  SET status = 0
  CALL dcl(syscmd,len,status)
 ELSE
  SET clean = remove("ccluserdir:afc_tier_values.dat;*")
 ENDIF
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), tier_group = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=13035
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), financial_class = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=354
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), admit_type = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=71
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(o.organization_id,20), organization = o.org_name
  "########################################"
  FROM organization o,
   code_value cv,
   org_type_reltn otr
  PLAN (o
   WHERE o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND o.active_ind=1)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND otr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=otr.org_type_cd
    AND cv.cdf_meaning="CLIENT"
    AND cv.code_set=278)
  ORDER BY o.org_name
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), order_location = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=220
   AND c.active_ind=1
   AND c.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), service_resource = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=221
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), report_priority = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=1905
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), patient_location = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=220
   AND c.active_ind=1
   AND c.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), collection_priority = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=2054
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), performing_location = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=220
   AND c.active_ind=1
   AND c.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), activity_type = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=106
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), activity_sub_type = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=5801
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(h.health_plan_id,20), health_plan = h.plan_name
  "########################################"
  FROM health_plan h
  WHERE h.active_ind=1
   AND h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND h.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), priority = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=1304
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(p.person_id,20), order_physician = p.name_full_formatted
  "########################################"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.logical_domain_id=logicaldomainid
    AND p.physician_ind=true)
  ORDER BY p.name_full_formatted
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(pg.prsnl_group_id,20), order_physician_grp = pg.prsnl_group_name
  "########################################"
  FROM prsnl_group pg
  PLAN (pg
   WHERE pg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pg.active_ind=1
    AND  EXISTS (
   (SELECT
    pgr.prsnl_group_id
    FROM prsnl_group_reltn pgr,
     prsnl p
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1
     AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pgr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND p.person_id=pgr.person_id
     AND p.logical_domain_id=logicaldomainid)))
  ORDER BY pg.prsnl_group_name
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(p.person_id,20), render_physician = p.name_full_formatted
  "########################################"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.logical_domain_id=logicaldomainid
    AND p.physician_ind=true)
  ORDER BY p.name_full_formatted
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(pg.prsnl_group_id,20), render_physician_grp = pg.prsnl_group_name
  "########################################"
  FROM prsnl_group pg
  PLAN (pg
   WHERE pg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pg.active_ind=1
    AND  EXISTS (
   (SELECT
    pgr.prsnl_group_id
    FROM prsnl_group_reltn pgr,
     prsnl p
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1
     AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pgr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND p.person_id=pgr.person_id
     AND p.logical_domain_id=logicaldomainid)))
  ORDER BY pg.prsnl_group_name
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), med_service = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=34
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), encounter_type = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=69
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(o.organization_id,20), insurance_org = o.org_name
  "########################################"
  FROM organization o,
   code_value cv,
   org_type_reltn otr
  PLAN (o
   WHERE o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND o.active_ind=1)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND otr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=otr.org_type_cd
    AND cv.cdf_meaning="INSCO"
    AND cv.code_set=278)
  ORDER BY o.org_name
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), cpt4_modifier_value = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=17769
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), provider_specialty = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14151
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), charge_processing = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="CHARGE POINT"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(p.price_sched_id,20), price_schedule = p.price_sched_desc
  "########################################"
  FROM price_sched p
  WHERE p.pharm_ind=0
   AND p.active_ind=1
   AND p.price_sched_id > 0
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(p.price_sched_id,20), list_price_schedule = p.price_sched_desc
  "########################################"
  FROM price_sched p
  WHERE p.pharm_ind=0
   AND p.active_ind=1
   AND p.price_sched_id > 0
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), cdm_schedule = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="CDM_SCHED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), cpt4_code = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="CPT4"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), cpt4_modifier = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="MODIFIER"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), snomed = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="SNMI95"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), hcpcs = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="HCPCS"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), icd9 = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="ICD9"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), icd9_procedure = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="PROCCODE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), revenue = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="REVENUE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), hold_suspense = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14160
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), general_ledger = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="GL"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), cost_center = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14058
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE afc_gen_addon_cd = f8
 SET codeset = 106
 SET cdf_meaning = "AFC ADD GEN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,afc_gen_addon_cd)
 CALL echo(build("the AFC_GEN_ADDON_CD code value is: ",afc_gen_addon_cd))
 SELECT INTO afc_tier_values
  code_value = cnvtstring(b.bill_item_id,20), add_on = b.ext_description
  "########################################"
  FROM bill_item b
  WHERE b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id=0
   AND b.ext_owner_cd=afc_gen_addon_cd
   AND b.active_ind=1
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(i.interface_file_id,20), interface_file = i.description
  "########################################"
  FROM interface_file i
  WHERE i.active_ind=1
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), client_report_type = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=25854
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 SELECT INTO afc_tier_values
  code_value = cnvtstring(c.code_value,20), coverage = c.display
  "########################################"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="NONCOVERED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH append
 ;end select
 SET rowcount = ((rowcount+ curqual)+ 1)
 CALL echo("Row Count")
 CALL echo(rowcount)
 IF (rowcount >= 1048576)
  CALL echo("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  CALL echo("Total number of values in dump exceeds the excel .xlsm row limit of 1,048,576!")
  CALL echo("The Import/Export utility will fail! Do not use this afc_tier_values.dat file!")
  CALL echo("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
 ENDIF
END GO
