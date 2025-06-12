CREATE PROGRAM afc_load_menu:dba
 PAINT
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
 DECLARE logicaldomainid = f8 WITH noconstant(0.0), protect
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  GO TO the_end
 ENDIF
 EXECUTE cclseclogin
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET fuser = 0.0
 SET cuser = curuser
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE p.email=cuser
  DETAIL
   fuser = p.person_id
  WITH nocounter
 ;end select
 SET reqinfo->updt_id = fuser
 SET reqinfo->updt_applctx = 0
 SET reqinfo->updt_task = 951999
 DECLARE sel_owner_cd = f8
 FREE SET ext_owner
 RECORD ext_owner(
   1 count = i2
   1 prompt_row = i2
   1 qual[*]
     2 owner_cd = f8
     2 owner_disp = vc
     2 owner_mean = vc
     2 disp_row = i4
     2 disp_col = i4
 )
 SET report_mode = 0
#menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Charge Services Bill Item Load Scripts",w)
 CALL text(24,2,"Load/Choose Owner/Other/Exit (L/C/O/E)?")
 CALL text(06,05,"External Owner Code: ")
 CALL video(u)
 CALL display_owner_codes("dummy")
 CALL video(n)
 CALL text(24,50,"Choose other to load Tasks, Service Resources, and other Misc Bill Items")
 CALL accept(24,45,"x;cu","E"
  WHERE curaccept IN ("L", "C", "E", "O"))
 CASE (curaccept)
  OF "L":
   EXECUTE FROM load_items TO load_items_end
   SET ext_owner->count = 0
  OF "C":
   GO TO select_owner
  OF "O":
   GO TO other_options
  OF "E":
   GO TO the_end
 ENDCASE
 GO TO menu
#other_options
 SET other_type = fillstring(10," ")
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Charge Services Miscellaneous Load Scripts",w)
 CALL text(06,20," 1)  Load Task Bill Items")
 CALL text(08,20," 2)  Load Service Resource Bill Items")
 CALL text(10,20," 3)  Load Collection Bill Items")
 CALL text(12,20," 4)  Load Accommodation Code Bill Items")
 CALL text(14,20," 5)  Load Item Master Bill Items")
 CALL text(18,20," 6)  ")
 CALL video(r)
 CALL text(18,25,"Go Back")
 CALL video(n)
 CALL text(24,2,"Select Option (1,2,3,4,5...)")
 CALL accept(24,36,"9;",6
  WHERE curaccept IN (1, 2, 3, 5, 6))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   SET other_type = "TASKS"
   EXECUTE FROM load_other TO load_other_end
  OF 2:
   SET other_type = "SR"
   EXECUTE FROM load_other TO load_other_end
  OF 3:
   SET other_type = "COLL"
   EXECUTE FROM load_other TO load_other_end
  OF 4:
   SET other_type = "ACCOM"
   EXECUTE FROM load_other TO load_other_end
  OF 5:
   SET other_type = "ITM MSTR"
   EXECUTE FROM load_other TO load_other_end
  OF 6:
   GO TO menu
  ELSE
   GO TO other_options
 ENDCASE
 GO TO other_options
#other_options_end
#select_owner
 CALL text(6,50,"Enter 0 when done - Help Available <Shift+F5>")
 SET help =
 SELECT
  code_value = cv.code_value"#################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(06,26,"9(17);CDS",0)
 IF (cnvtreal(curaccept) != 0)
  SET sel_owner_cd = cnvtreal(curaccept)
  SET sel_owner_disp = fillstring(40," ")
  SET sel_owner_mean = fillstring(12," ")
  SET dup_ind = 0
  IF ((ext_owner->count > 0))
   SELECT INTO "nl:"
    my_code_value = ext_owner->qual[ext_owner->count].owner_cd
    FROM (dummyt d1  WITH seq = value(ext_owner->count))
    WHERE (ext_owner->qual[d1.seq].owner_cd=sel_owner_cd)
    DETAIL
     dup_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF (dup_ind=0)
   SET ext_owner->count += 1
   SET stat = alterlist(ext_owner->qual,ext_owner->count)
   SET sel_owner_disp = uar_get_code_display(sel_owner_cd)
   SET sel_owner_mean = uar_get_code_meaning(sel_owner_cd)
   SET ext_owner->qual[ext_owner->count].owner_cd = sel_owner_cd
   SET ext_owner->qual[ext_owner->count].owner_disp = sel_owner_disp
   SET ext_owner->qual[ext_owner->count].owner_mean = sel_owner_mean
  ENDIF
  CALL display_owner_codes("dummy")
  GO TO select_owner
 ENDIF
 SET help = off
 CALL clear(24,1)
 GO TO menu
#end_select_owner
#load_tasks
 CALL clear(24,1)
 CALL video(b)
 CALL text(24,5,"Loading Tasks...")
 EXECUTE tsk_load_task_info_for_afc
 CALL video(n)
 EXECUTE FROM commit_load TO commit_load_end
#load_tasks_end
#load_items
 IF ((ext_owner->count=0))
  CALL pick_owner_box("dummy")
 ELSE
  EXECUTE FROM report_prompt TO end_report_prompt
  IF (report_mode != 0)
   EXECUTE cclseclogin
  ENDIF
  CALL clear(24,1)
  CALL video(b)
  FOR (ext_idx = 1 TO ext_owner->count)
    CASE (ext_owner->qual[ext_idx].owner_mean)
     OF "MICROBIOLOGY":
      CALL text(24,5,"Loading Microbiology...")
      EXECUTE afc_load_micro report_mode
     OF "BB":
      CALL text(24,5,"Loading Blood Bank...")
      EXECUTE afc_load_blood_bank report_mode
     OF "BB PRODUCT":
      CALL text(24,5,"Loading Blood Bank...")
      EXECUTE afc_load_blood_bank report_mode
     OF "PHARMACY":
      IF (report_mode=0)
       CALL no_report_warning("Pharmacy")
      ELSE
       EXECUTE afc_load_pharmacy
      ENDIF
     ELSE
      CALL text(24,5,concat("Loading ",ext_owner->qual[ext_idx].owner_disp))
      EXECUTE afc_load_gen_lab ext_owner->qual[ext_idx].owner_cd, report_mode
    ENDCASE
    CALL video(n)
    CALL text(ext_owner->qual[ext_idx].disp_row,ext_owner->qual[ext_idx].disp_col,"X")
    CALL video(b)
    CALL clear(24,1)
  ENDFOR
  CALL video(n)
  IF (report_mode=1)
   EXECUTE FROM commit_load TO commit_load_end
  ENDIF
 ENDIF
#load_items_end
 SUBROUTINE no_report_warning(strvar)
   CALL video(n)
   FOR (x = 10 TO 20)
     CALL clear(x,30,40)
   ENDFOR
   CALL video(b)
   CALL box(10,30,20,70)
   CALL video(n)
   CALL text(12,35,concat(strvar," Load cannot be run in"))
   CALL text(13,35,"Report Only Mode")
   CALL text(15,35,"Please Hit Enter to Continue")
   CALL accept(17,50,"XX;cu","OK"
    WHERE curaccept="OK")
   CALL video(b)
 END ;Subroutine
 SUBROUTINE pick_owner_box(strvar)
   CALL video(n)
   FOR (x = 10 TO 20)
     CALL clear(x,30,40)
   ENDFOR
   CALL video(b)
   CALL box(10,30,20,70)
   CALL video(n)
   CALL text(12,35,"You must select one or more Owner")
   CALL text(13,35,"Codes to Load.  Choose 'C' from")
   CALL text(14,35,"Main Menu to choose owner(s).")
   CALL text(15,35,"Please Hit Enter to Continue")
   CALL accept(17,50,"XX;cu","OK"
    WHERE curaccept="OK")
   CALL video(b)
 END ;Subroutine
#commit_load
 COMMIT
 CALL video(n)
 CALL box(9,35,17,85)
 CALL video(r)
 CALL text(10,36,"            ** Commit Loaded Items **            ")
 CALL video(n)
 CALL text(12,36,"        Updates have been commited.              ")
 CALL text(14,36,"        Hit Enter to Continue.                   ")
 CALL text(16,36,"                    OK                           ")
 CALL video(n)
 CALL accept(16,56,"xx;cud","OK"
  WHERE curaccept IN ("OK"))
 CALL clear(24,1)
#commit_load_end
#report_prompt
 CALL video(n)
 CALL box(9,35,17,85)
 CALL video(r)
 CALL text(10,36,"            ** Report Only or Load **            ")
 CALL video(n)
 CALL text(12,36,"   Run as Report Only, or Load Bill Items?       ")
 CALL text(13,36,"                                                 ")
 CALL text(14,36,"                                                 ")
 CALL video(r)
 CALL text(16,36,"                                     (R/L)     ")
 CALL video(n)
 CALL accept(16,81,"P;cud","R"
  WHERE curaccept IN ("L", "R"))
 IF (curaccept="L")
  CALL clear(24,1)
  CALL text(24,2,"Loading Bill Items...")
  SET report_mode = 1
 ELSEIF (curaccept="R")
  CALL clear(24,1)
  CALL text(24,2,"Creating Report...")
  SET report_mode = 0
 ENDIF
 CALL clear(24,1)
#end_report_prompt
 SUBROUTINE display_owner_codes(dummyvar)
   CALL video(l)
   SET start_row = 07
   SET start_col = 12
   SET new_row = 0
   SET idx = 0
   IF ((ext_owner->count=0))
    CALL text((start_row+ 1),start_col,"<NONE>")
   ELSE
    IF ((ext_owner->count < 2))
     SET to_val = ext_owner->count
    ELSE
     SET to_val = ((ext_owner->count/ 2)+ mod(ext_owner->count,2))
    ENDIF
    FOR (x = 1 TO to_val)
     IF (x > 1)
      SET start_col += 25
     ENDIF
     IF (start_col <= 65)
      FOR (y = 1 TO 15)
        IF ((idx < ext_owner->count))
         SET idx += 1
         SET new_row = (start_row+ y)
         CALL text((start_row+ y),start_col,substring(1,22,ext_owner->qual[idx].owner_disp))
         SET ext_owner->qual[idx].disp_row = new_row
         SET ext_owner->qual[idx].disp_col = (start_col - 2)
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL video(n)
 END ;Subroutine
#load_other
 CALL clear(24,1)
 CALL video(b)
 CASE (other_type)
  OF "TASKS":
   CALL text(24,5,"Loading Tasks...")
   EXECUTE tsk_load_task_info_for_afc
   EXECUTE FROM commit_load TO commit_load_end
  OF "SR":
   CALL text(24,5,"Loading Service Resources...")
   EXECUTE afc_load_service_resource
  OF "COLL":
   CALL text(24,5,"Loading Specimen/Collections...")
   EXECUTE afc_collection_setup
   EXECUTE FROM commit_load TO commit_load_end
  OF "ACCOM":
   CALL text(20,5,"Accommodation load Not yet available")
  OF "ITM MSTR":
   CALL text(24,5,"Loading Item Masters...")
   EXECUTE FROM report_prompt TO end_report_prompt
   EXECUTE mm_load_item_master report_mode, logicaldomainid
   IF (report_mode != 0)
    EXECUTE FROM commit_load TO commit_load_end
   ENDIF
 ENDCASE
 CALL video(n)
#load_other_end
#the_end
END GO
