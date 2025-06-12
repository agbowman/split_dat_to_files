CREATE PROGRAM afc_get_cdm_by_key:dba
 IF ( NOT (validate(writesubevent)))
  IF ( NOT (validate(stat)))
   DECLARE stat = i4 WITH protect, noconstant(0)
  ENDIF
  IF ( NOT (validate(subevent_ndx)))
   DECLARE subevent_ndx = i4 WITH protect, noconstant(0)
  ENDIF
  SUBROUTINE (writesubevent(operationname=vc,operationstatus=c1,objectname=vc,objectvalue=vc) =null)
    SET subevent_ndx = (size(reply->status_data.subeventstatus,5)+ 1)
    SET stat = alter(reply->status_data.subeventstatus,subevent_ndx)
    SET reply->status_data.subeventstatus[subevent_ndx].operationname = operationname
    SET reply->status_data.subeventstatus[subevent_ndx].operationstatus = operationstatus
    SET reply->status_data.subeventstatus[subevent_ndx].targetobjectname = objectname
    SET reply->status_data.subeventstatus[subevent_ndx].targetobjectvalue = objectvalue
  END ;Subroutine
  SUBROUTINE (writemainevent(scriptstatus=c1,operationname=vc,operationstatus=c1,objectname=vc,
   objectvalue=vc) =null)
    SET reply->status_data.status = scriptstatus
    SET reply->status_data.subeventstatus[1].operationname = operationname
    SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
    SET reply->status_data.subeventstatus[1].targetobjectname = objectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = objectvalue
  END ;Subroutine
  SUBROUTINE (writesubeventdynamiclist(operationname=vc,operationstatus=c1,objectname=vc,objectvalue=
   vc) =null)
    SET subevent_ndx = (size(reply->status_data.subeventstatus,5)+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,subevent_ndx)
    SET reply->status_data.subeventstatus[subevent_ndx].operationname = operationname
    SET reply->status_data.subeventstatus[subevent_ndx].operationstatus = operationstatus
    SET reply->status_data.subeventstatus[subevent_ndx].targetobjectname = objectname
    SET reply->status_data.subeventstatus[subevent_ndx].targetobjectvalue = objectvalue
  END ;Subroutine
 ENDIF
 SUBROUTINE (copysubevents(childrecord=vc(ref)) =null)
   DECLARE nndx = i2 WITH protect
   DECLARE nsize = i2 WITH protect
   SET nsize = size(childrecord->status_data.subeventstatus,5)
   FOR (nndx = 1 TO nsize)
     CALL writesubevent(nullterm(trim(childrecord->status_data.subeventstatus[nndx].operationname)),
      nullterm(trim(childrecord->status_data.subeventstatus[nndx].operationstatus)),nullterm(trim(
        childrecord->status_data.subeventstatus[nndx].targetobjectname)),nullterm(trim(childrecord->
        status_data.subeventstatus[nndx].targetobjectvalue)))
   ENDFOR
 END ;Subroutine
 DECLARE checkforerrors() = i2
 SUBROUTINE checkforerrors(null)
   DECLARE serrmsg = vc WITH protect, noconstant(fillstring(132," "))
   DECLARE lerrcode = i2 WITH protect, noconstant(1)
   DECLARE lreturnval = i2 WITH noconstant(0), protect
   WHILE (lerrcode != 0)
    SET lerrcode = error(serrmsg,0)
    IF (lerrcode != 0)
     CALL writesubevent("ERROR()","F",build("CODE::",lerrcode),serrmsg)
     SET lreturnval = 1
    ENDIF
   ENDWHILE
   RETURN(lreturnval)
 END ;Subroutine
 SET modify = predeclare
 DECLARE checkbischedsec(dbillitemid=f8,dschedulecd=f8,nbcodesecon=i2,nbitemsecon=i2) = i2
 DECLARE isbillcodesecurityon(null) = i2
 DECLARE loaddcp(null) = null
 DECLARE mndebuginc = i2 WITH protect, noconstant(0)
 DECLARE mndcploaded = i2 WITH protect, noconstant(false)
 FREE RECORD dcpreply
 RECORD dcpreply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = vc
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = vc
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = vc
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = vc
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET mndebuginc = validate(request->ndebug,0)
 SUBROUTINE isbillcodesecurityon(null)
   DECLARE nbcsecurityon = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="CHARGE SERVICES"
     AND di.info_name="BILL CODE SCHED SECURITY"
     AND di.info_char="Y"
    DETAIL
     nbcsecurityon = true
    WITH nocounter
   ;end select
   RETURN(nbcsecurityon)
 END ;Subroutine
 SUBROUTINE (userhasprivs(dactivitytypecd=f8) =i2)
   DECLARE ldcpsize = i4 WITH protect, noconstant(0)
   DECLARE lrepcount = i4 WITH protect, noconstant(0)
   DECLARE nreturnvalue = i2 WITH protecet, noconstant(true)
   DECLARE smeaningforvalue = vc WITH protect, noconstant("")
   IF (mndcploaded=false)
    CALL loaddcp(null)
   ENDIF
   IF (mndebuginc=1)
    CALL echo(build("UserHasPrivs: activity_type ",dactivitytypecd,"and position: ",reqinfo->
      position_cd))
   ENDIF
   SET ldcpsize = size(dcpreply->qual,5)
   IF (ldcpsize > 0)
    FOR (lrepcount = 1 TO ldcpsize)
      SET smeaningforvalue = uar_get_code_meaning(dcpreply->qual[lrepcount].priv_value_cd)
      IF (mndebuginc=1)
       CALL echo(build("priv meaning: ",smeaningforvalue))
      ENDIF
      CASE (smeaningforvalue)
       OF "YES":
        SET nreturnvalue = true
       OF "NO":
        SET nreturnvalue = false
       OF "EXCLUDE":
        IF (inexceptionlist(dactivitytypecd,lrepcount)=true)
         SET nreturnvalue = false
        ENDIF
       OF "INCLUDE":
        SET nreturnvalue = false
        IF (inexceptionlist(dactivitytypecd,lrepcount)=true)
         SET nreturnvalue = true
        ENDIF
       ELSE
        IF (mndebuginc=1)
         CALL echo("Nothing built for this activity type/user")
        ENDIF
      ENDCASE
    ENDFOR
   ELSE
    IF (mndebuginc=1)
     CALL echo("Didn't find anything.  Nothing built in PrivTool")
    ENDIF
   ENDIF
   RETURN(nreturnvalue)
 END ;Subroutine
 SUBROUTINE (inexceptionlist(dactivitytypecd=f8,lrepcount=i4) =i2)
   DECLARE lexceptionloop = i4 WITH protect, noconstant(0)
   FOR (lexceptionloop = 1 TO dcpreply->qual[lrepcount].except_cnt)
     IF ((dcpreply->qual[lrepcount].excepts[lexceptionloop].exception_entity_name="ACTIVITY TYPE"))
      IF (mndebuginc=1)
       CALL echo(build("exception_cd: ",dcpreply->qual[lrepcount].excepts[lexceptionloop].
         exception_id))
       CALL echo(build("comparing against: ",dactivitytypecd))
      ENDIF
      IF ((dactivitytypecd=dcpreply->qual[lrepcount].excepts[lexceptionloop].exception_id))
       RETURN(true)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(false)
 END ;Subroutine
 SUBROUTINE loaddcp(null)
   DECLARE dchargeentrycd = f8 WITH protect, noconstant(0)
   DECLARE dchargevieentcd = f8 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE nrundcpagain = i2 WITH protect, noconstant(false)
   SET lstat = uar_get_meaning_by_codeset(6016,nullterm("CHARGEENTRY"),1,dchargeentrycd)
   SET lstat = uar_get_meaning_by_codeset(6016,nullterm("CHARGEVI&ENT"),1,dchargevieentcd)
   RECORD dcprequest(
     1 chk_prsnl_ind = i2
     1 prsnl_id = f8
     1 chk_psn_ind = i2
     1 position_cd = f8
     1 chk_ppr_ind = i2
     1 ppr_cd = f8
     1 plist[*]
       2 privilege_cd = f8
       2 privilege_mean = c12
   )
   SET lstat = initrec(dcpreply)
   SET dcprequest->chk_psn_ind = 1
   SET lstat = alterlist(dcprequest->plist,1)
   SET dcprequest->plist[1].privilege_mean = "CHARGEENTRY"
   SET dcprequest->plist[1].privilege_cd = dchargeentrycd
   SET modify = nopredeclare
   EXECUTE dcp_get_privs  WITH replace("REQUEST",dcprequest), replace("REPLY",dcpreply)
   IF (size(dcpreply->qual,5)=0)
    IF (mndebuginc=1)
     CALL echo("Did not find anything for CHARGEENTRY, trying CHARGEVIE&ENT")
    ENDIF
    SET nrundcpagain = true
   ELSEIF (size(dcpreply->qual,5)=1)
    IF (mndebuginc=1)
     CALL echo(build("priv_value_cd: ",dcpreply->qual[1].priv_value_cd))
    ENDIF
    IF ((dcpreply->qual[1].priv_value_cd=0))
     SET nrundcpagain = true
    ENDIF
   ENDIF
   IF (nrundcpagain=true)
    SET dcprequest->plist[1].privilege_mean = "CHARGEVI&ENT"
    SET dcprequest->plist[1].privilege_cd = dchargevieentcd
    EXECUTE dcp_get_privs  WITH replace("REQUEST",dcprequest), replace("REPLY",dcpreply)
   ENDIF
   SET modify = predeclare
   IF (mndebuginc=1)
    CALL echorecord(dcpreply)
   ENDIF
   SET mndcploaded = true
   FREE RECORD dcprequest
 END ;Subroutine
 SUBROUTINE checkbischedsec(dbillitemid,dschedulecd,nbcodesecon)
   DECLARE nreturnvalue = i2 WITH protect, noconstant(true)
   DECLARE nitemfound = i2 WITH protect, noconstant(false)
   DECLARE dbcschedcd = f8 WITH protect, noconstant(0)
   DECLARE dbillcodecd = f8 WITH protect, noconstant(0)
   DECLARE lstat = f8 WITH protect, noconstant(0)
   SET lstat = uar_get_meaning_by_codeset(26078,nullterm("BC_SCHED"),1,dbcschedcd)
   SET lstat = uar_get_meaning_by_codeset(13019,nullterm("BILL CODE"),1,dbillcodecd)
   IF (nbcodesecon=true)
    IF (mndebuginc=1)
     CALL echo(build("executing CheckBISchedSec for Bill Item: ",dbillitemid," and Schedule:  ",
       dschedulecd))
     CALL echo(build("User_id is ",reqinfo->updt_id))
    ENDIF
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      bill_item_modifier bim
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=dbcschedcd
       AND cor.key1_entity_name="BC_SCHED"
       AND cor.key1_id=dschedulecd
       AND cor.active_ind=1)
      JOIN (bim
      WHERE bim.key1_id=cor.key1_id
       AND bim.bill_item_id=dbillitemid
       AND bim.bill_item_type_cd=dbillcodecd
       AND bim.active_ind=1)
     DETAIL
      nitemfound = true
     WITH nocounter
    ;end select
    IF (nitemfound=false)
     SET nreturnvalue = false
    ENDIF
   ELSE
    IF (mndebuginc=1)
     CALL echo("Bill Code Schedule security option is off")
    ENDIF
   ENDIF
   RETURN(nreturnvalue)
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
 CALL beginservice("323720.004")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 billitems[*]
      2 dbillitemid = f8
      2 sextdescription = vc
      2 dbillitemmodid = f8
      2 sbillcodedesc = vc
      2 sbillcode = vc
      2 dextownercd = f8
      2 dkey1id = f8
      2 nprivind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET modify = predeclare
 DECLARE checksecurity(null) = i2
 DECLARE logicaldomainid = f8 WITH noconstant(0), protect
 DECLARE mnno_privs = i2 WITH protect, constant(1)
 DECLARE mndebug = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET mndebug = validate(request->ndebug,0)
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
 IF (size(request->ssearchstring)=0)
  CALL writemainevent("F","Main","F","Invalid input","The search string is blank.")
  GO TO exit_script
 ELSEIF (findcdm(request->ssearchstring,request->lsearchflg,request->sactivitytypemeaning)=true)
  CALL checksecurity(null)
  SET reply->status_data.status = "S"
 ELSE
  CALL writemainevent("F","Main","F","Search fail","FindCDM was not successful.")
  GO TO exit_script
 ENDIF
 IF (size(reply->billitems,5) != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FREE RECORD dcpreply
#exit_script
 SUBROUTINE (findcdm(stext=vc,lsearchflg=i4,sactivitymeaning=vc) =i2)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE dbillcd = f8 WITH protect, noconstant(0.0)
   DECLARE dchargepointcd = f8 WITH protect, noconstant(0.0)
   DECLARE dgroupcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbothcd = f8 WITH protect, noconstant(0.0)
   DECLARE ddetailnowcd = f8 WITH protect, noconstant(0.0)
   DECLARE skeyqualification = vc WITH protect, noconstant("")
   DECLARE dactivitytypecd = f8 WITH protect, noconstant(0.0)
   DECLARE dtask_assay_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
   SET lstat = uar_get_meaning_by_codeset(13019,nullterm("BILL CODE"),1,dbillcd)
   SET lstat = uar_get_meaning_by_codeset(13019,nullterm("CHARGE POINT"),1,dchargepointcd)
   SET lstat = uar_get_meaning_by_codeset(13020,nullterm("GROUP"),1,dgroupcd)
   SET lstat = uar_get_meaning_by_codeset(13020,nullterm("BOTH"),1,dbothcd)
   SET lstat = uar_get_meaning_by_codeset(13020,nullterm("DETAIL_NOW"),1,ddetailnowcd)
   IF (size(sactivitymeaning) > 0)
    SET lstat = uar_get_meaning_by_codeset(106,nullterm(sactivitymeaning),1,dactivitytypecd)
   ENDIF
   SET stext = cnvtupper(stext)
   SET stext = build(stext,"*")
   CASE (lsearchflg)
    OF 0:
     SET skeyqualification = "bim.key6 = patstring(sText)"
    OF 1:
     SET skeyqualification = "cnvtupper(bim.key7) = patstring(sText)"
    ELSE
     CALL writesubevent("FindCDM","F","Invalid input",build(cnvtstring(lsearchflg),
       " is not a valid search flag value."))
     RETURN(false)
   ENDCASE
   IF (mndebug=1)
    CALL echo(build("Search criteria: ",skeyqualification," ActivityTypeCd = ",dactivitytypecd))
   ENDIF
   SELECT
    IF (dactivitytypecd=0)
     FROM bill_item_modifier bim,
      bill_item b,
      bill_item_modifier bim2
     PLAN (bim
      WHERE bim.bill_item_type_cd=dbillcd
       AND  EXISTS (
      (SELECT
       cv.code_value
       FROM code_value cv
       WHERE cv.code_value=bim.key1_id
        AND cv.code_set=14002
        AND cv.cdf_meaning="CDM_SCHED"
        AND cv.active_ind=1))
       AND trim(bim.key6) != ""
       AND parser(skeyqualification)
       AND ((bim.bim1_int=1) OR (bim.key2_id=1))
       AND bim.active_ind=1
       AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
       AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
      JOIN (b
      WHERE b.bill_item_id=bim.bill_item_id
       AND b.ext_child_reference_id > 0
       AND b.active_ind=1
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (bim2
      WHERE bim2.bill_item_id=bim.bill_item_id
       AND bim2.bill_item_type_cd=dchargepointcd
       AND bim2.key4_id IN (dgroupcd, dbothcd, ddetailnowcd)
       AND bim2.active_ind=1)
    ELSE
     FROM bill_item_modifier bim,
      bill_item b,
      bill_item_modifier bim2,
      discrete_task_assay dta
     PLAN (bim
      WHERE bim.bill_item_type_cd=dbillcd
       AND  EXISTS (
      (SELECT
       cv.code_value
       FROM code_value cv
       WHERE cv.code_value=bim.key1_id
        AND cv.code_set=14002
        AND cv.cdf_meaning="CDM_SCHED"
        AND cv.active_ind=1))
       AND trim(bim.key6) != ""
       AND parser(skeyqualification)
       AND ((bim.bim1_int=1) OR (bim.key2_id=1))
       AND bim.active_ind=1
       AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
       AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
      JOIN (b
      WHERE b.bill_item_id=bim.bill_item_id
       AND b.ext_child_reference_id > 0
       AND b.active_ind=1
       AND b.ext_child_contributor_cd=dtask_assay_cd
       AND ((b.logical_domain_id=logicaldomainid
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
      JOIN (dta
      WHERE dta.task_assay_cd=b.ext_child_reference_id
       AND dta.activity_type_cd=dactivitytypecd)
      JOIN (bim2
      WHERE bim2.bill_item_id=bim.bill_item_id
       AND bim2.bill_item_type_cd=dchargepointcd
       AND bim2.key4_id IN (dgroupcd, dbothcd, ddetailnowcd)
       AND bim2.active_ind=1)
    ENDIF
    DISTINCT INTO "nl:"
    bim.bill_item_id
    ORDER BY bim.bill_item_id
    HEAD REPORT
     lcount = 0
    HEAD bim.bill_item_id
     lcount += 1
     IF (mod(lcount,5)=1)
      lstat = alterlist(reply->billitems,(lcount+ 5))
     ENDIF
     reply->billitems[lcount].dbillitemmodid = bim.bill_item_mod_id, reply->billitems[lcount].
     sextdescription = b.ext_description, reply->billitems[lcount].dbillitemid = bim.bill_item_id,
     reply->billitems[lcount].sbillcodedesc = bim.key7, reply->billitems[lcount].sbillcode = bim.key6,
     reply->billitems[lcount].dextownercd = b.ext_owner_cd,
     reply->billitems[lcount].dkey1id = bim.key1_id
    FOOT REPORT
     lstat = alterlist(reply->billitems,lcount)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE checksecurity(null)
   DECLARE nbcodesecon = i2 WITH protect, noconstant(false)
   DECLARE lindex = i4 WITH protect, noconstant(0)
   DECLARE lsize = i4 WITH protect, constant(size(reply->billitems,5))
   DECLARE nhasaccess = i2 WITH protect, noconstant(false)
   DECLARE dprevextownercd = f8 WITH protect, noconstant(- (1))
   SET nbcodesecon = isbillcodesecurityon(null)
   IF (mndebug=1)
    CALL echo(build("BillCodeSecurity: ",nbcodesecon))
   ENDIF
   FOR (lindex = 1 TO lsize)
    IF ( NOT ((dprevextownercd=reply->billitems[lindex].dextownercd)))
     SET nhasaccess = userhasprivs(reply->billitems[lindex].dextownercd)
     SET dprevextownercd = reply->billitems[lindex].dextownercd
    ENDIF
    IF (nhasaccess=true)
     IF (checkbischedsec(reply->billitems[lindex].dbillitemid,reply->billitems[lindex].dkey1id,
      nbcodesecon)=false)
      SET reply->billitems[lindex].nprivind = mnno_privs
     ENDIF
    ELSE
     SET reply->billitems[lindex].nprivind = mnno_privs
    ENDIF
   ENDFOR
 END ;Subroutine
END GO
