CREATE PROGRAM afc_rca_save_modify_chrg_model:dba
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
 CALL echo("Begin PFT_WF_WORK_ITEM_COMMON.INC, version [ENABTECH-15949.033]")
 CALL echo("Begin PFT_GET_ORGANIZATION_SUBS.INC, version [565928.008]")
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
 IF ( NOT (validate(cs278_facility_cd)))
  DECLARE cs278_facility_cd = f8 WITH protect, constant(getcodevalue(278,"FACILITY",1))
 ENDIF
 IF ( NOT (validate(cs20849_client_cd)))
  DECLARE cs20849_client_cd = f8 WITH protect, constant(getcodevalue(20849,"CLIENT",1))
 ENDIF
 IF ( NOT (validate(getauthorizedorganizations)))
  SUBROUTINE (getauthorizedorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedOrganizations","Failed to retrieve logical domain ID...",log_error
      )
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM prsnl_org_reltn por,
       code_value cv,
       organization o
      PLAN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
       JOIN (o
       WHERE o.organization_id=por.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY por.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM organization o,
       org_type_reltn otr
      PLAN (o
       WHERE o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (otr
       WHERE otr.organization_id=o.organization_id
        AND otr.org_type_cd=cs278_facility_cd
        AND otr.active_ind=true)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedprofitorganizations)))
  SUBROUTINE (getauthorizedprofitorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedProFitOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedProFitOrganizations","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       be_org_reltn bor,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM billing_entity be,
       be_org_reltn bor,
       organization o
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY o.organization_id
      DETAIL
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedProFitOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedclientorganizations)))
  SUBROUTINE (getauthorizedclientorganizations(authorizedorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedClientOrganizations","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedClientOrganizations","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       account a,
       pft_acct_reltn par,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (a
       WHERE a.billing_entity_id=be.billing_entity_id
        AND a.active_ind=true
        AND a.acct_sub_type_cd=cs20849_client_cd)
       JOIN (par
       WHERE par.acct_id=a.acct_id
        AND par.active_ind=true
        AND par.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=par.parent_entity_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY o.organization_id
      HEAD o.organization_id
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
       .collation_seq
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM billing_entity be,
       account a,
       pft_acct_reltn par,
       organization o
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (a
       WHERE a.billing_entity_id=be.billing_entity_id
        AND a.active_ind=true
        AND a.acct_sub_type_cd=cs20849_client_cd)
       JOIN (par
       WHERE par.acct_id=a.acct_id
        AND par.active_ind=true
        AND par.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=par.parent_entity_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY o.organization_id
      HEAD o.organization_id
       organizationcount += 1
       IF (mod(organizationcount,20)=1)
        stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
       ENDIF
       authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
       authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
      FOOT REPORT
       stat = alterlist(authorizedorganizations->organizations,organizationcount)
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
    CALL logmessage("getAuthorizedClientOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedprofitandclientorganizations)))
  SUBROUTINE (getauthorizedprofitandclientorganizations(authorizedclientorganizations=vc(ref),
   authorizedprofitorganizations=vc(ref)) =i2)
    CALL logmessage("getAuthorizedProFitAndClientOrganizations","Entering...",log_debug)
    FREE RECORD combinedorganizations
    RECORD combinedorganizations(
      1 organizations[*]
        2 organizationid = f8
        2 confidentialitylevel = i4
    )
    DECLARE num = i4 WITH protect, noconstant(0)
    DECLARE organizationcount = i4 WITH protect, noconstant(0)
    DECLARE startidx = i4 WITH protect, noconstant(0)
    DECLARE combinedorgcnt = i4 WITH protect, noconstant(0)
    DECLARE clientorgcnt = i4 WITH protect, noconstant(size(authorizedclientorganizations->
      organizations,5))
    DECLARE profitorgcnt = i4 WITH protect, noconstant(size(authorizedprofitorganizations->
      organizations,5))
    IF (profitorgcnt=0)
     CALL logmessage("getAuthorizedProFitAndClientOrganizations","No ProFit org to merge, exiting...",
      log_debug)
     RETURN(true)
    ELSEIF (clientorgcnt=0)
     SET stat = initrec(authorizedclientorganizations)
     SET stat = moverec(authorizedprofitorganizations,authorizedclientorganizations)
     CALL logmessage("getAuthorizedProFitAndClientOrganizations","No Client org to merge, exiting...",
      log_debug)
     RETURN(true)
    ENDIF
    SET stat = moverec(authorizedclientorganizations,combinedorganizations)
    FOR (loopidx = 1 TO profitorgcnt)
      IF (locateval(num,1,clientorgcnt,authorizedprofitorganizations->organizations[loopidx].
       organizationid,authorizedclientorganizations->organizations[num].organizationid)=0)
       SET combinedorgcnt = (size(combinedorganizations->organizations,5)+ 1)
       SET stat = alterlist(combinedorganizations->organizations,combinedorgcnt)
       SET combinedorganizations->organizations[combinedorgcnt].organizationid =
       authorizedprofitorganizations->organizations[loopidx].organizationid
       SET combinedorganizations->organizations[combinedorgcnt].confidentialitylevel =
       authorizedprofitorganizations->organizations[loopidx].confidentialitylevel
      ENDIF
    ENDFOR
    SET stat = initrec(authorizedclientorganizations)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(combinedorganizations->organizations,5)))
     PLAN (d1
      WHERE (combinedorganizations->organizations[d1.seq].organizationid > 0.0))
     ORDER BY combinedorganizations->organizations[d1.seq].organizationid
     DETAIL
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedclientorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedclientorganizations->organizations[organizationcount].organizationid =
      combinedorganizations->organizations[d1.seq].organizationid, authorizedclientorganizations->
      organizations[organizationcount].confidentialitylevel = combinedorganizations->organizations[d1
      .seq].confidentialitylevel
     FOOT REPORT
      stat = alterlist(authorizedclientorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
    FREE RECORD combinedorganizations
    CALL logmessage("getAuthorizedProFitAndClientOrganizations","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getbillingentities)))
  SUBROUTINE (getbillingentities(billingentities=vc(ref)) =i2)
    CALL logmessage("getBillingEntities","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getBillingEntities","Failed to retrieve logical domain ID...",log_error)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM billing_entity be,
      organization o
     PLAN (be
      WHERE be.active_ind=true)
      JOIN (o
      WHERE o.organization_id=be.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
     ORDER BY be.billing_entity_id
     HEAD REPORT
      billingentitycount = 0
     DETAIL
      billingentitycount += 1, stat = alterlist(billingentities->billingentities,billingentitycount),
      billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedbillingentities)))
  SUBROUTINE (getauthorizedbillingentities(billingentities=vc(ref)) =i2)
    CALL logmessage("getAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    DECLARE billingentitycount = i4 WITH protect, noconstant(0)
    DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    CALL echorecord(billingentities)
    IF (isorgsecurityon)
     SELECT INTO "nl:"
      FROM billing_entity be,
       organization o,
       prsnl_org_reltn por,
       code_value cv
      PLAN (be
       WHERE be.active_ind=true)
       JOIN (o
       WHERE o.organization_id=be.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
       JOIN (por
       WHERE por.organization_id=o.organization_id
        AND (por.person_id=reqinfo->updt_id)
        AND por.active_ind=true
        AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (cv
       WHERE cv.code_value=por.confid_level_cd)
      ORDER BY be.billing_entity_id
      HEAD be.billing_entity_id
       billingentitycount += 1
       IF (mod(billingentitycount,20)=1)
        stat = alterlist(billingentities->billingentities,(billingentitycount+ 19))
       ENDIF
       billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
      FOOT REPORT
       stat = alterlist(billingentities->billingentities,billingentitycount)
      WITH nocounter
     ;end select
    ELSE
     IF ( NOT (getbillingentities(billingentities)))
      CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve Billing Entity ID's...",
       log_error)
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getauthorizedbillingentitiesbyuserid)))
  SUBROUTINE (getauthorizedbillingentitiesbyuserid(billingentities=vc(ref)) =i2)
    CALL logmessage("getAuthorizedBillingEntitiesByUserId","Entering...",log_debug)
    DECLARE billingentitycount = i4 WITH protect, noconstant(0)
    DECLARE isbillingentitysecurityon = i2 WITH protect, constant(isbillingentitysecurityon(0))
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("getAuthorizedBillingEntitiesByUserId","Failed to retrieve logical domain ID...",
      log_error)
     RETURN(false)
    ENDIF
    IF (isbillingentitysecurityon)
     SELECT DISTINCT
      be.billing_entity_id
      FROM billing_entity be,
       be_org_reltn bor,
       organization o,
       be_prsnl_group_r bg,
       pft_prsnl_group_r pg
      PLAN (pg
       WHERE (pg.prsnl_id=reqinfo->updt_id)
        AND pg.active_ind=true)
       JOIN (bg
       WHERE bg.pft_prsnl_group_id=pg.pft_prsnl_group_id
        AND bg.active_ind=true)
       JOIN (be
       WHERE be.billing_entity_id=bg.billing_entity_id
        AND be.active_ind=true)
       JOIN (bor
       WHERE bor.billing_entity_id=be.billing_entity_id
        AND bor.active_ind=true)
       JOIN (o
       WHERE o.organization_id=bor.organization_id
        AND o.active_ind=true
        AND o.logical_domain_id=organizationlogicaldomainid)
      ORDER BY be.billing_entity_id
      DETAIL
       billingentitycount += 1
       IF (mod(billingentitycount,20)=1)
        stat = alterlist(billingentities->billingentities,(billingentitycount+ 19))
       ENDIF
       billingentities->billingentities[billingentitycount].billingentityid = be.billing_entity_id
      FOOT REPORT
       stat = alterlist(billingentities->billingentities,billingentitycount)
      WITH nocounter
     ;end select
    ELSE
     IF ( NOT (getbillingentities(billingentities)))
      CALL logmessage("getAuthorizedBillingEntities","Failed to retrieve Billing Entity ID's...",
       log_error)
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0))
     CALL echorecord(billingentities)
    ENDIF
    CALL logmessage("getAuthorizedBillingEntitiesByUserId","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isorganizationsecurityon)))
  DECLARE isorganizationsecurityon(null) = i2
  SUBROUTINE isorganizationsecurityon(null)
    CALL logmessage("isOrganizationSecurityOn","Entering...",log_debug)
    DECLARE isorgsecurityon = i2 WITH protect, noconstant(false)
    IF (validate(ccldminfo->mode,0))
     IF ((ccldminfo->sec_org_reltn > 0))
      SET isorgsecurityon = true
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name="SEC_ORG_RELTN"
       AND di.info_domain="SECURITY"
       AND di.info_number > 0.0
      DETAIL
       isorgsecurityon = true
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("isOrganizationSecurityOn",build2("Organization security is ",evaluate(
       isorgsecurityon,true,"on","off")),log_debug)
    CALL logmessage("isOrganizationSecurityOn","Exiting...",log_debug)
    RETURN(isorgsecurityon)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isbillingentitysecurityon)))
  DECLARE isbillingentitysecurityon(null) = i2
  SUBROUTINE isbillingentitysecurityon(null)
    CALL logmessage("isBillingEntitySecurityOn","Entering...",log_debug)
    DECLARE isbillingentitysecurityon = i2 WITH protect, noconstant(false)
    DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
    IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
     CALL logmessage("isBillingEntitySecurityOn","Failed to retrieve logical domain ID...",log_error)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_BE_RELTN"
      AND di.info_domain="SECURITY"
      AND di.info_domain_id=organizationlogicaldomainid
      AND di.info_number > 0.0
     DETAIL
      isbillingentitysecurityon = true
     WITH nocounter
    ;end select
    CALL logmessage("isBillingEntitySecurityOn",build2("Billing Entity security is ",evaluate(
       isbillingentitysecurityon,true,"on","off")),log_debug)
    CALL logmessage("isBillingEntitynSecurityOn","Exiting...",log_debug)
    RETURN(isbillingentitysecurityon)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isconfidentialitysecurityon)))
  DECLARE isconfidentialitysecurityon(null) = i2
  SUBROUTINE isconfidentialitysecurityon(null)
    CALL logmessage("isConfidentialitySecurityOn","Entering...",log_debug)
    DECLARE isconfidsecurityon = i2 WITH protect, noconstant(false)
    IF (validate(ccldminfo->mode,0))
     IF ((ccldminfo->sec_confid > 0))
      SET isconfidsecurityon = true
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name="SEC_CONFID"
       AND di.info_domain="SECURITY"
       AND di.info_number > 0.0
      DETAIL
       isconfidsecurityon = true
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("isConfidentialitySecurityOn",build2("Confidentiality level security is ",
      evaluate(isconfidsecurityon,true,"on","off")),log_debug)
    CALL logmessage("isConfidentialitySecurityOn","Exiting...",log_debug)
    RETURN(isconfidsecurityon)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getauthorizedprofitorgsforbe(billingentityids=vc,authorizedorganizations=vc(ref)) =i2)
   CALL logmessage("getAuthorizedProFitOrgsForBe","Entering...",log_debug)
   DECLARE organizationlogicaldomainid = f8 WITH protect, noconstant(0.0)
   DECLARE isorgsecurityon = i2 WITH protect, constant(isorganizationsecurityon(0))
   DECLARE organizationcount = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   IF ( NOT (getlogicaldomain(ld_concept_organization,organizationlogicaldomainid)))
    CALL logmessage("getAuthorizedProFitOrgsForBe","Failed to retrieve logical domain ID...",
     log_error)
    RETURN(false)
   ENDIF
   IF (isorgsecurityon)
    SELECT INTO "nl:"
     FROM billing_entity be,
      be_org_reltn bor,
      organization o,
      prsnl_org_reltn por,
      code_value cv
     PLAN (be
      WHERE expand(iidx,1,size(billingentityids->billingentities,5),be.billing_entity_id,
       billingentityids->billingentities[iidx].billingentityid)
       AND be.active_ind=true)
      JOIN (bor
      WHERE bor.billing_entity_id=be.billing_entity_id
       AND bor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=bor.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
      JOIN (por
      WHERE por.organization_id=o.organization_id
       AND (por.person_id=reqinfo->updt_id)
       AND por.active_ind=true
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (cv
      WHERE cv.code_value=por.confid_level_cd)
     ORDER BY o.organization_id
     HEAD o.organization_id
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
      authorizedorganizations->organizations[organizationcount].confidentialitylevel = cv
      .collation_seq
     FOOT REPORT
      stat = alterlist(authorizedorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM billing_entity be,
      be_org_reltn bor,
      organization o
     PLAN (be
      WHERE expand(iidx,1,size(billingentityids->billingentities,5),be.billing_entity_id,
       billingentityids->billingentities[iidx].billingentityid)
       AND be.active_ind=true)
      JOIN (bor
      WHERE bor.billing_entity_id=be.billing_entity_id
       AND bor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=bor.organization_id
       AND o.active_ind=true
       AND o.logical_domain_id=organizationlogicaldomainid)
     ORDER BY o.organization_id
     HEAD o.organization_id
      organizationcount += 1
      IF (mod(organizationcount,20)=1)
       stat = alterlist(authorizedorganizations->organizations,(organizationcount+ 19))
      ENDIF
      authorizedorganizations->organizations[organizationcount].organizationid = o.organization_id,
      authorizedorganizations->organizations[organizationcount].confidentialitylevel = 99
     FOOT REPORT
      stat = alterlist(authorizedorganizations->organizations,organizationcount)
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(format(cnvtdatetime(sysdate),"hhmmsscc;3;M"))
   CALL logmessage("getAuthorizedProFitOrgsForBe","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 CALL beginservice("565928.005")
 IF (validate(getprofitauthorizedbillingentities,char(128))=char(128))
  SUBROUTINE (getprofitauthorizedbillingentities(authorizedgrpbillingenitities=vc(ref)) =i2)
    CALL logmessage("getProfitAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE becount = i4 WITH protect, noconstant(0)
    SELECT DISTINCT INTO "nl:"
     FROM be_prsnl_group_r bpg,
      billing_entity be,
      pft_prsnl_group_r pgr
     PLAN (pgr
      WHERE (pgr.prsnl_id=reqinfo->updt_id)
       AND pgr.active_ind=true)
      JOIN (bpg
      WHERE bpg.pft_prsnl_group_id=pgr.pft_prsnl_group_id
       AND bpg.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=bpg.billing_entity_id
       AND be.active_ind=true)
     DETAIL
      becount += 1, stat = alterlist(authorizedgrpbillingenitities->billingentities,becount),
      authorizedgrpbillingenitities->billingentities[becount].billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    CALL logmessage("getProfitAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getuserauthorizedbillingentities,char(128))=char(128))
  SUBROUTINE (getuserauthorizedbillingentities(authorizedbillingentities=vc(ref)) =i2)
    CALL logmessage("getUserAuthorizedBillingEntities","Entering...",log_debug)
    DECLARE bcnt = i4 WITH protect, noconstant(0)
    DECLARE rcnt = i4 WITH protect, noconstant(0)
    DECLARE lidx = i4 WITH protect, noconstant(0)
    DECLARE bposition = i4 WITH protect, noconstant(0)
    RECORD userauthorizedbillingentities(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    RECORD profitauthorizedbillingentities(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    IF ( NOT (getauthorizedbillingentities(userauthorizedbillingentities)))
     CALL exitservicefailure("Unable to retrieve Authorized Biling Entity ID's",true)
    ENDIF
    IF ( NOT (getprofitauthorizedbillingentities(profitauthorizedbillingentities)))
     CALL exitservicefailure("Unable to retrieve Logical Biling Entity ID's",true)
    ENDIF
    FOR (bcnt = 1 TO size(profitauthorizedbillingentities->billingentities,5))
     SET bposition = locateval(lidx,1,size(userauthorizedbillingentities->billingentities,5),
      profitauthorizedbillingentities->billingentities[bcnt].billingentityid,
      userauthorizedbillingentities->billingentities[lidx].billingentityid)
     IF (bposition > 0)
      SET rcnt += 1
      SET stat = alterlist(authorizedbillingentities->billingentities,rcnt)
      SET authorizedbillingentities->billingentities[rcnt].billingentityid =
      profitauthorizedbillingentities->billingentities[bcnt].billingentityid
     ENDIF
    ENDFOR
    CALL logmessage("getUserAuthorizedBillingEntities","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(validatemultiaccountencountersexist,char(128))=char(128))
  SUBROUTINE (validatemultiaccountencountersexist(pencounterid=f8) =i2)
    CALL logmessage("validateMultiAccountEncountersExist","Enter",log_debug)
    DECLARE cs20849_acct_sub_type_cd_patient = f8 WITH protect, constant(getcodevalue(20849,"PATIENT",
      0))
    DECLARE multiaccountcount = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      account a
     PLAN (pe
      WHERE pe.encntr_id=pencounterid
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.acct_sub_type_cd=cs20849_acct_sub_type_cd_patient
       AND a.active_ind=true)
     ORDER BY pe.acct_id
     HEAD pe.acct_id
      multiaccountcount += 1
     WITH nocounter
    ;end select
    CALL logmessage("validateMultiAccountEncountersExist","Exit",log_debug)
    IF (multiaccountcount > 1)
     RETURN(true)
    ENDIF
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(isbedifferentforencandfinancialenc,char(128))=char(128))
  SUBROUTINE (isbedifferentforencandfinancialenc(pencounterid=f8) =i2)
    CALL logmessage("isBEDifferentForEncAndFinancialEnc","Enter",log_debug)
    DECLARE isbillingentitydiff = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      be_org_reltn bor
     PLAN (e
      WHERE e.encntr_id=pencounterid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (bor
      WHERE bor.organization_id=e.organization_id
       AND bor.active_ind=true)
     DETAIL
      IF (pe.billing_entity_id != bor.billing_entity_id)
       isbillingentitydiff = true
      ENDIF
     WITH nocounter
    ;end select
    CALL logmessage("isBEDifferentForEncAndFinancialEnc","Exit",log_debug)
    RETURN(isbillingentitydiff)
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
 CALL echo("Begin PFT_RCA_CONTEXT_CONSTANTS.INC, version [700704.011]")
 DECLARE entity_type_patient_account = i4 WITH protect, constant(1)
 DECLARE entity_type_encounter = i4 WITH protect, constant(2)
 DECLARE entity_type_financial_encounter = i4 WITH protect, constant(3)
 DECLARE entity_type_insurance_balance = i4 WITH protect, constant(5)
 DECLARE entity_type_self_pay_balance = i4 WITH protect, constant(6)
 DECLARE entity_type_statement = i4 WITH protect, constant(7)
 DECLARE entity_type_consolidated_statement = i4 WITH protect, constant(8)
 DECLARE entity_type_claim = i4 WITH protect, constant(9)
 DECLARE entity_type_charge = i4 WITH protect, constant(10)
 DECLARE entity_type_itrans_balance = i4 WITH protect, constant(11)
 DECLARE entity_type_itrans_claim = i4 WITH protect, constant(12)
 DECLARE entity_type_itrans_charge = i4 WITH protect, constant(13)
 DECLARE entity_type_sptrans_statement = i4 WITH protect, constant(14)
 DECLARE entity_type_sptrans_charge = i4 WITH protect, constant(15)
 DECLARE entity_type_sptrans_balance = i4 WITH protect, constant(16)
 DECLARE entity_type_denial_claim = i4 WITH protect, constant(17)
 DECLARE entity_type_denial_charge = i4 WITH protect, constant(18)
 DECLARE entity_type_personnel = i4 WITH protect, constant(19)
 DECLARE entity_type_guarantor = i4 WITH protect, constant(20)
 DECLARE entity_type_charge_batch = i4 WITH protect, constant(21)
 DECLARE entity_type_client_account = i4 WITH protect, constant(22)
 DECLARE entity_type_client_invoice = i4 WITH protect, constant(23)
 DECLARE entity_type_transaction_batch = i4 WITH protect, constant(24)
 DECLARE entity_type_general_ar = i4 WITH protect, constant(25)
 DECLARE entity_type_prsnl_workflow_entity = i4 WITH protect, constant(26)
 DECLARE entity_type_patient = i4 WITH protect, constant(27)
 DECLARE entity_type_visit = i4 WITH protect, constant(28)
 DECLARE entity_type_remittance = i4 WITH protect, constant(29)
 DECLARE entity_type_general_account = i4 WITH protect, constant(31)
 DECLARE entity_type_ime_claim = i4 WITH protect, constant(32)
 DECLARE entity_type_eob = i4 WITH protect, constant(33)
 DECLARE entity_type_pending_transaction = i4 WITH protect, constant(34)
 DECLARE entity_type_modify_eob_detail = i4 WITH protect, constant(35)
 DECLARE entity_type_person = i4 WITH protect, constant(36)
 DECLARE entity_type_multi_acct_encounter = i4 WITH protect, constant(37)
 DECLARE entity_type_insurance_pending_transaction = i4 WITH protect, constant(39)
 DECLARE entity_type_invoice_transaction = i4 WITH protect, constant(40)
 DECLARE entity_type_claim_line_item = i4 WITH protect, constant(41)
 DECLARE entity_type_research_account = i4 WITH protect, constant(42)
 DECLARE entity_type_invoice = i4 WITH protect, constant(43)
 DECLARE entity_type_guarantor_account = i4 WITH protect, constant(44)
 DECLARE entity_type_billing_hold = i4 WITH protect, constant(45)
 CALL echo("End PFT_RCA_CONTEXT_CONSTANTS.INC")
 IF ( NOT (validate(cs354_selfpay_cd)))
  DECLARE cs354_selfpay_cd = f8 WITH protect, constant(getcodevalue(354,"SELFPAY",0))
 ENDIF
 IF (validate(getbillingentitybyencounter,char(128))=char(128))
  SUBROUTINE (getbillingentitybyencounter(pencntrid=f8,prbillingentityid=f8(ref)) =i2)
    DECLARE facilitycd = f8 WITH protect, noconstant(0.0)
    SET prbillingentityid = 0.0
    SELECT INTO "nl:"
     FROM encounter e
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
     DETAIL
      facilitycd = e.loc_facility_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM encntr_pending e
      PLAN (e
       WHERE e.encntr_id=pencntrid
        AND e.active_ind=true)
      DETAIL
       facilitycd = e.pend_facility_cd
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     FROM location l,
      be_org_reltn bor,
      billing_entity be
     PLAN (l
      WHERE l.location_cd=facilitycd
       AND l.active_ind=true
       AND l.location_cd > 0.0)
      JOIN (bor
      WHERE bor.organization_id=l.organization_id
       AND bor.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=bor.billing_entity_id
       AND be.active_ind=true)
     DETAIL
      prbillingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getaccountbillingentityforfinancialencounter,char(128))=char(128))
  SUBROUTINE (getaccountbillingentityforfinancialencounter(ppftencntrid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      account a,
      billing_entity be
     PLAN (pe
      WHERE pe.pft_encntr_id=ppftencntrid
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getaccountbillingentityforencounter,char(128))=char(128))
  SUBROUTINE (getaccountbillingentityforencounter(pencntrid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentitiesforencounterwithmultipleaccounts,char(128))=char(128))
  SUBROUTINE (getbillingentitiesforencounterwithmultipleaccounts(pencntrid=f8,prbes=vc(ref)) =i2)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      becnt += 1, stat = alterlist(prbes->billingentities,becnt), prbes->billingentities[becnt].
      billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentityforaccount,char(128))=char(128))
  SUBROUTINE (getbillingentityforaccount(pacctid=f8,prbeid=f8(ref)) =i2)
    SET prbeid = 0.0
    SELECT INTO "nl:"
     FROM account a,
      billing_entity be
     PLAN (a
      WHERE a.acct_id=pacctid
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      prbeid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getbillingentitiesforperson,char(128))=char(128))
  SUBROUTINE (getbillingentitiesforperson(ppersonid=f8,prbes=vc(ref)) =i2)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM person p,
      encounter e,
      pft_encntr pe,
      account a,
      billing_entity be
     PLAN (p
      WHERE p.person_id=ppersonid
       AND p.active_ind=true)
      JOIN (e
      WHERE e.person_id=p.person_id
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
      JOIN (be
      WHERE be.billing_entity_id=a.billing_entity_id
       AND be.active_ind=true)
     ORDER BY be.billing_entity_id
     HEAD be.billing_entity_id
      becnt += 1, stat = alterlist(prbes->billingentities,becnt), prbes->billingentities[becnt].
      billingentityid = be.billing_entity_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getviewablebillingentitiesforentity,char(128))=char(128))
  SUBROUTINE (getviewablebillingentitiesforentity(pentityid=f8,pentitytype=i4,prbes=vc(ref)) =i2)
    RECORD entitybes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    RECORD authorizedbes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    DECLARE beid = f8 WITH protect, noconstant(0.0)
    DECLARE beidx = i4 WITH protect, noconstant(0)
    DECLARE authbeidx = i4 WITH protect, noconstant(0)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    IF ( NOT (getuserauthorizedbillingentities(authorizedbes)))
     CALL exitservicefailure("Unable to retrieve authorized biling entity ids",true)
    ENDIF
    CASE (pentitytype)
     OF entity_type_person:
      SET stat = getbillingentitiesforperson(pentityid,entitybes)
     OF entity_type_patient_account:
      SET stat = getbillingentityforaccount(pentityid,beid)
     OF entity_type_multi_acct_encounter:
      SET stat = getbillingentitiesforencounterwithmultipleaccounts(pentityid,entitybes)
     OF entity_type_encounter:
      SET stat = getaccountbillingentityforencounter(pentityid,beid)
     OF entity_type_financial_encounter:
      SET stat = getaccountbillingentityforfinancialencounter(pentityid,beid)
     ELSE
      RETURN(false)
    ENDCASE
    IF (beid > 0.0)
     SET stat = alterlist(entitybes->billingentities,1)
     SET entitybes->billingentities[1].billingentityid = beid
    ENDIF
    FOR (beidx = 1 TO size(entitybes->billingentities,5))
     SET bepos = locateval(authbeidx,1,size(authorizedbes->billingentities,5),entitybes->
      billingentities[beidx].billingentityid,authorizedbes->billingentities[authbeidx].
      billingentityid)
     IF (bepos > 0)
      SET becnt += 1
      SET stat = alterlist(prbes->billingentities,becnt)
      SET prbes->billingentities[becnt].billingentityid = entitybes->billingentities[beidx].
      billingentityid
     ENDIF
    ENDFOR
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(facilitylist->facilities)))
  RECORD facilitylist(
    1 facilities[*]
      2 billingentityid = f8
      2 timezoneindex = i4
      2 logicaldomainid = f8
      2 activity_flag = i2
  )
  CALL initializefacilitytimezone(null)
 ENDIF
 IF (validate(initializefacilitytimezone,char(128))=char(128))
  DECLARE initializefacilitytimezone(null) = null
  SUBROUTINE initializefacilitytimezone(null)
    DECLARE cs222_facility_cd = f8 WITH noconstant(uar_get_code_by("MEANING",222,"FACILITY")),
    protect
    DECLARE billingentiycount = i4 WITH noconstant(0), protect
    SELECT INTO "nl:"
     FROM billing_entity be,
      organization o,
      location l,
      time_zone_r tzr
     PLAN (be
      WHERE be.billing_entity_id > 0.0
       AND be.active_ind=1)
      JOIN (o
      WHERE o.organization_id=be.organization_id
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
     ORDER BY be.billing_entity_id
     DETAIL
      billingentiycount += 1, stat = alterlist(facilitylist->facilities,billingentiycount),
      facilitylist->facilities[billingentiycount].billingentityid = be.billing_entity_id,
      facilitylist->facilities[billingentiycount].activity_flag = be.gl_date_activity_flag
      IF (tzr.parent_entity_id != 0.0)
       facilitylist->facilities[billingentiycount].timezoneindex = datetimezonebyname(tzr.time_zone)
      ELSE
       facilitylist->facilities[billingentiycount].timezoneindex = curtimezoneapp
      ENDIF
      facilitylist->facilities[billingentiycount].logicaldomainid = o.logical_domain_id
     WITH nocounter
    ;end select
    IF (validate(debug))
     CALL echorecord(facilitylist)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getfacilitytimezoneidx,char(128))=char(128))
  SUBROUTINE (getfacilitytimezoneidx(pbillingentityid=f8) =i4)
    DECLARE timezoneindex = i4 WITH protect, noconstant(0)
    DECLARE billingentitypos = i4 WITH protect, noconstant(0)
    DECLARE billingentitylidx = i4 WITH protect, noconstant(0)
    IF (pbillingentityid <= 0.0)
     SET timezoneindex = curtimezoneapp
    ELSE
     SET billingentitypos = locatevalsort(billingentitylidx,1,size(facilitylist->facilities,5),
      pbillingentityid,facilitylist->facilities[billingentitylidx].billingentityid)
     IF (billingentitypos > 0)
      SET timezoneindex = facilitylist->facilities[billingentitypos].timezoneindex
     ELSE
      SET timezoneindex = curtimezoneapp
     ENDIF
    ENDIF
    RETURN(timezoneindex)
  END ;Subroutine
 ENDIF
 IF (validate(getfacilitybeginningofday,char(128))=char(128))
  SUBROUTINE (getfacilitybeginningofday(pbillingentityid=f8,pdatetimeutc=dq8) =dq8)
    DECLARE timezoneindex = i4 WITH protect, noconstant(0)
    DECLARE billingentitypos = i4 WITH protect, noconstant(0)
    DECLARE billingentitylidx = i4 WITH protect, noconstant(0)
    IF (pbillingentityid <= 0.0)
     SET timezoneindex = curtimezoneapp
    ELSE
     SET billingentitypos = locatevalsort(billingentitylidx,1,size(facilitylist->facilities,5),
      pbillingentityid,facilitylist->facilities[billingentitylidx].billingentityid)
     IF (billingentitypos > 0)
      SET timezoneindex = facilitylist->facilities[billingentitypos].timezoneindex
     ELSE
      SET timezoneindex = curtimezoneapp
     ENDIF
    ENDIF
    DECLARE intdate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect
    SET facilitydate = cnvtdatetimeutc(pdatetimeutc,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET intdate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate),"##;P0"
       ),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(intdate),0),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getfacilityendofday,char(128))=char(128))
  SUBROUTINE (getfacilityendofday(pbillingentityid=f8,pdatetimeutc=dq8) =dq8)
    DECLARE timezoneindex = i4 WITH protect, noconstant(0)
    DECLARE billingentitypos = i4 WITH protect, noconstant(0)
    DECLARE billingentitylidx = i4 WITH protect, noconstant(0)
    IF (pbillingentityid <= 0.0)
     SET timezoneindex = curtimezoneapp
    ELSE
     SET billingentitypos = locatevalsort(billingentitylidx,1,size(facilitylist->facilities,5),
      pbillingentityid,facilitylist->facilities[billingentitylidx].billingentityid)
     IF (billingentitypos > 0)
      SET timezoneindex = facilitylist->facilities[billingentitypos].timezoneindex
     ELSE
      SET timezoneindex = curtimezoneapp
     ENDIF
    ENDIF
    DECLARE intdate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect
    SET facilitydate = cnvtdatetimeutc(pdatetimeutc,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET intdate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate),"##;P0"
       ),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(intdate),235959),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getfacilityendofpreviousday,char(128))=char(128))
  SUBROUTINE (getfacilityendofpreviousday(pbillingentityid=f8,pdatetimeutc=dq8) =dq8)
    DECLARE facilitydate = dq8 WITH protect, noconstant(0.0)
    IF (curutc)
     DECLARE timezoneindex = i4 WITH protect, noconstant(0)
     DECLARE billingentitypos = i4 WITH protect, noconstant(0)
     DECLARE billingentitylidx = i4 WITH protect, noconstant(0)
     IF (pbillingentityid <= 0.0)
      SET timezoneindex = curtimezoneapp
     ELSE
      SET billingentitypos = locatevalsort(billingentitylidx,1,size(facilitylist->facilities,5),
       pbillingentityid,facilitylist->facilities[billingentitylidx].billingentityid)
      IF (billingentitypos > 0)
       SET timezoneindex = facilitylist->facilities[billingentitypos].timezoneindex
      ENDIF
      IF (timezoneindex <= 0)
       SET timezoneindex = curtimezoneapp
      ENDIF
     ENDIF
     DECLARE intdate = i4 WITH protect, noconstant(0)
     DECLARE juliandate = i4 WITH protect, noconstant(0)
     SET facilitydate = cnvtdatetimeutc(pdatetimeutc,2,timezoneindex)
     SET facilitydate = cnvtdatetimeutc(facilitydate,1)
     SET intdate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate),
        "##;P0"),year(facilitydate)))
     SET juliandate = cnvtdate(intdate)
     SET juliandate -= 1
     SET facilitydate = cnvtdatetimeutc(cnvtdatetime(juliandate,235959),2)
     SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
     RETURN(facilitydate)
    ENDIF
    IF (curutc=0)
     SET facilitydate = cnvtdatetime(datetimeadd(pdatetimeutc,- (1)),235959)
     RETURN(facilitydate)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getfacilitycurrenttimeofday,char(128))=char(128))
  SUBROUTINE (getfacilitycurrenttimeofday(pbillingentityid=f8,pdatetimeutc=dq8) =dq8)
    DECLARE timezoneindex = i4 WITH protect, noconstant(0)
    DECLARE billingentitypos = i4 WITH protect, noconstant(0)
    DECLARE billingentitylidx = i4 WITH protect, noconstant(0)
    IF (pbillingentityid <= 0.0)
     SET timezoneindex = curtimezoneapp
    ELSE
     SET billingentitypos = locatevalsort(billingentitylidx,1,size(facilitylist->facilities,5),
      pbillingentityid,facilitylist->facilities[billingentitylidx].billingentityid)
     IF (billingentitypos > 0)
      SET timezoneindex = facilitylist->facilities[billingentitypos].timezoneindex
     ELSE
      SET timezoneindex = curtimezoneapp
     ENDIF
    ENDIF
    DECLARE intdate = i4 WITH protect, noconstant(0)
    DECLARE facilitydate = dq8 WITH protect
    SET facilitydate = cnvtdatetimeutc(pdatetimeutc,2,timezoneindex)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1)
    SET intdate = cnvtint(build2(format(month(facilitydate),"##;P0"),format(day(facilitydate),"##;P0"
       ),year(facilitydate)))
    SET facilitydate = cnvtdatetimeutc(cnvtdatetime(cnvtdate(intdate),curtime3),2)
    SET facilitydate = cnvtdatetimeutc(facilitydate,1,timezoneindex)
    RETURN(facilitydate)
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
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
 ENDIF
 CALL echo("Begin pft_get_guarantor_subs.inc, version [RCBACM-21889.058]")
 IF ( NOT (validate(rawguarresponsibilities->begindate)))
  RECORD rawguarresponsibilities(
    1 billingentityid = f8
    1 patientid = f8
    1 begindate = dq8
    1 enddate = dq8
    1 guarantors[*]
      2 guarantorid1 = f8
      2 guarantorid2 = f8
      2 guarorgid = f8
      2 coguarantortypecd = f8
      2 begineffectivedate = dq8
      2 endeffectivedate = dq8
      2 guarfinancialrespid = f8
      2 guarrespacctid = f8
      2 finrespcd = f8
      2 finrespvalue = f8
      2 activeind = i2
      2 updatedate = dq8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(prencounterlist)))
  RECORD prencounterlist(
    1 encounters[*]
      2 encntrid = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(guarantors->guarantorresps.guarid1)))
  RECORD guarantors(
    1 billingentityid = f8
    1 guarantorresps[*]
      2 guarname = vc
      2 guarid1 = f8
      2 guarid2 = f8
      2 guarorgid = f8
      2 guaraccts[*]
        3 acctid = f8
        3 patientid = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(cs351_defguar_cd)))
  DECLARE cs351_defguar_cd = f8 WITH protect, constant(getcodevalue(351,"DEFGUAR",0))
 ENDIF
 IF ( NOT (validate(cs352_guarantor)))
  DECLARE cs352_guarantor = f8 WITH protect, constant(getcodevalue(352,"GUARANTOR",0))
 ENDIF
 IF ( NOT (validate(cs20790_priorityseq)))
  DECLARE cs20790_priorityseq = f8 WITH protect, constant(getcodevalue(20790,"PRIORITY_SEQ",0))
 ENDIF
 IF ( NOT (validate(cs18736_ar)))
  DECLARE cs18736_ar = f8 WITH protect, constant(getcodevalue(18736,"A/R",0))
 ENDIF
 IF ( NOT (validate(cs20849_patient)))
  DECLARE cs20849_patient = f8 WITH noconstant(getcodevalue(20849,"PATIENT",0))
 ENDIF
 IF ( NOT (validate(cs354_selfpay_cd)))
  DECLARE cs354_selfpay_cd = f8 WITH protect, noconstant(getcodevalue(354,"SELFPAY",1))
 ENDIF
 IF ( NOT (validate(cs24451_cancelled_cd)))
  DECLARE cs24451_cancelled_cd = f8 WITH protect, noconstant(getcodevalue(24451,"CANCELLED",1))
 ENDIF
 IF ( NOT (validate(cs24451_invalid_cd)))
  DECLARE cs24451_invalid_cd = f8 WITH protect, noconstant(getcodevalue(24451,"INVALID",1))
 ENDIF
 IF ( NOT (validate(cs24451_complete_cd)))
  DECLARE cs24451_complete_cd = f8 WITH protect, noconstant(getcodevalue(24451,"COMPLETE",1))
 ENDIF
 IF ( NOT (validate(cs387573_dailyamount_cd)))
  DECLARE cs387573_dailyamount_cd = f8 WITH protect, constant(getcodevalue(387573,"DAILYAMOUNT",1))
 ENDIF
 IF ( NOT (validate(cs4092002_transfer_cd)))
  DECLARE cs4092002_transfer_cd = f8 WITH protect, constant(getcodevalue(4092002,"TRANSFER",0))
 ENDIF
 IF ( NOT (validate(cs20509_posted_cd)))
  DECLARE cs20509_posted_cd = f8 WITH protect, constant(getcodevalue(20509,"POSTED",0))
 ENDIF
 IF ( NOT (validate(cs387572_joint)))
  DECLARE cs387572_joint = f8 WITH protect, constant(getcodevalue(387572,"JOINT",0))
 ENDIF
 IF ( NOT (validate(cs18936_guarantor)))
  DECLARE cs18936_guarantor = f8 WITH protect, constant(getcodevalue(18936,"GUARANTOR",0))
 ENDIF
 IF ( NOT (validate(cs20849_guarantor)))
  DECLARE cs20849_guarantor = f8 WITH protect, constant(getcodevalue(20849,"GUARANTOR",0))
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(getguarantorbyencounter,char(128))=char(128))
  SUBROUTINE (getguarantorbyencounter(pencntrid=f8,prguarantorid=f8(ref),pencountermodsflag=i2(value,
    false)) =i2)
    DECLARE adt_constant = i4 WITH protect, constant(99)
    DECLARE primaryguarantorseq = i4 WITH protect, noconstant(0)
    DECLARE primaryguarantor = f8 WITH protect, noconstant(0.0)
    DECLARE externalguarantor = f8 WITH protect, noconstant(0.0)
    DECLARE pftencounterid = f8 WITH protect, noconstant(0.0)
    DECLARE orgguarantorid = f8 WITH protect, noconstant(0.0)
    SET prguarantorid = 0.0
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr p
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (p
      WHERE p.encntr_id=e.encntr_id
       AND p.active_ind=true)
     DETAIL
      pftencounterid = p.pft_encntr_id
     WITH nocounter
    ;end select
    SET stat = getprimaryguarantorsequence(primaryguarantorseq)
    SELECT INTO "nl:"
     FROM encntr_person_reltn epr,
      person p
     PLAN (epr
      WHERE epr.encntr_id=pencntrid
       AND epr.person_reltn_type_cd=cs351_defguar_cd
       AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND epr.active_ind=true
       AND epr.priority_seq IN (primaryguarantorseq, adt_constant))
      JOIN (p
      WHERE p.person_id=epr.related_person_id
       AND p.active_ind=true)
     DETAIL
      IF (epr.priority_seq=primaryguarantorseq)
       primaryguarantor = p.person_id
      ELSEIF (epr.priority_seq=adt_constant)
       externalguarantor = p.person_id
      ENDIF
     WITH nocounter
    ;end select
    IF (primaryguarantor > 0.0)
     SET prguarantorid = primaryguarantor
    ELSEIF (externalguarantor > 0.0)
     SET prguarantorid = externalguarantor
     IF (pencountermodsflag=true)
      IF ( NOT (publishguarantorworkflowevent(pftencounterid)))
       CALL exitservicefailure("publishGuarantorWorkflowEvent did not return success",
        go_to_exit_script)
      ENDIF
     ENDIF
    ENDIF
    IF (prguarantorid=0.0)
     SET stat = getorgguarantorbyencounter(pencntrid,orgguarantorid)
     IF (pencountermodsflag=true
      AND orgguarantorid=0.0)
      IF ( NOT (publishguarantorworkflowevent(pftencounterid)))
       CALL exitservicefailure("publishGuarantorWorkflowEvent did not return success",
        go_to_exit_script)
      ENDIF
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbyfinencounter,char(128))=char(128))
  SUBROUTINE (getguarantorbyfinencounter(ppftencntrid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    DECLARE status = i2 WITH protect, noconstant(0)
    SET status = getencounterbyfinancialencounter(ppftencntrid,encntrid)
    SET status = getguarantorbyencounter(encntrid,prguarantorid)
    RETURN(status)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantoratpatientlevel,char(128))=char(128))
  SUBROUTINE (getguarantoratpatientlevel(ppersonid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE primaryguarantorseq = i4 WITH protect, noconstant(0)
    SET prguarantorid = 0.0
    SET stat = getprimaryguarantorsequence(primaryguarantorseq)
    SELECT INTO "nl:"
     FROM person_person_reltn ppr
     WHERE ppr.person_id=ppersonid
      AND ppr.active_ind=true
      AND ppr.person_reltn_type_cd=cs351_defguar_cd
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ppr.active_ind=true
      AND ppr.priority_seq=primaryguarantorseq
     DETAIL
      prguarantorid = ppr.related_person_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbyappointment,char(128))=char(128))
  SUBROUTINE (getguarantorbyappointment(pscheventid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE patientid = f8 WITH protect, noconstant(0.0)
    DECLARE encounterid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM sch_event_patient sep
     WHERE sep.sch_event_id=pscheventid
      AND sep.active_ind=true
      AND sep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     DETAIL
      patientid = sep.person_id, encounterid = sep.encntr_id
     WITH nocounter
    ;end select
    IF (encounterid > 0.0)
     RETURN(getguarantorbyencounter(encounterid,prguarantorid))
    ELSEIF (patientid > 0.0)
     RETURN(getguarantoratpatientlevel(patientid,prguarantorid))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorfinancialresp,char(128))=char(128))
  SUBROUTINE (getguarantorfinancialresp(ppftencntrid=f8,pencntrid=f8,ppftdate=dq8,prrawguarresp=vc(
    ref),pskipcreateacct=i2) =i2)
    DECLARE guarindex = i4 WITH protect, noconstant(0)
    DECLARE guarantorid1 = f8 WITH protect, noconstant(0.0)
    DECLARE respactive = i2 WITH protect, noconstant(0)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    DECLARE pewhere = vc WITH protect, noconstant("1 = 1")
    DECLARE ebegindate = dq8 WITH protect, noconstant(cnvtdatetime(0.0))
    DECLARE eenddate = dq8 WITH protect, noconstant(cnvtdatetime("31-dec-2100 23:59:59"))
    DECLARE gtype = f8 WITH protect, noconstant(0.0)
    DECLARE gbegdate = dq8 WITH protect, noconstant(cnvtdatetime(0.0))
    DECLARE genddate = dq8 WITH protect, noconstant(cnvtdatetime(0.0))
    DECLARE addguarantor = i2 WITH protect, noconstant(0)
    DECLARE patientid = f8 WITH protect, noconstant(0.0)
    DECLARE rtnval = i2 WITH protect, noconstant(true)
    DECLARE responsibilitytype = f8 WITH protect, noconstant(0.0)
    SET stat = initrec(prrawguarresp)
    SET guarindex = size(prrawguarresp->guarantors,5)
    IF (ppftencntrid <= 0.0
     AND pencntrid <= 0.0)
     SET rtnval = false
    ELSE
     IF (ppftencntrid > 0.0)
      CALL getfinancialservicedatesforguarresps(ppftencntrid,encntrid,ebegindate,eenddate)
      SET prrawguarresp->begindate = ebegindate
      SET prrawguarresp->enddate = eenddate
      SET pewhere = build2("pe.pft_encntr_id = ",ppftencntrid)
     ELSE
      SET encntrid = pencntrid
     ENDIF
     SELECT INTO "nl:"
      FROM pft_encntr pe,
       account a,
       encounter e,
       encntr_org_reltn er,
       guar_fin_resp_reltn gr,
       guar_financial_resp gf
      PLAN (e
       WHERE e.encntr_id=encntrid
        AND e.active_ind=true)
       JOIN (er
       WHERE er.encntr_id=e.encntr_id
        AND er.encntr_org_reltn_cd=cs352_guarantor)
       JOIN (gr
       WHERE gr.parent_entity_id=er.encntr_org_reltn_id
        AND gr.parent_entity_name="ENCNTR_ORG_RELTN")
       JOIN (gf
       WHERE gf.guar_financial_resp_id=gr.guar_financial_resp_id)
       JOIN (pe
       WHERE (pe.encntr_id= Outerjoin(e.encntr_id))
        AND (pe.active_ind= Outerjoin(true))
        AND parser(pewhere))
       JOIN (a
       WHERE (a.acct_id= Outerjoin(pe.acct_id))
        AND (a.active_ind= Outerjoin(true)) )
      ORDER BY a.billing_entity_id, e.person_id, gr.guar_financial_resp_id,
       er.organization_id
      HEAD a.billing_entity_id
       prrawguarresp->billingentityid = a.billing_entity_id
      HEAD e.person_id
       prrawguarresp->patientid = e.person_id
      HEAD gr.guar_financial_resp_id
       respactive = band(er.active_ind,band(gr.active_ind,gf.active_ind)), gtype = evaluate(gf
        .guar_financial_resp_type_cd,0.0,gr.guar_financial_resp_type_cd,gf
        .guar_financial_resp_type_cd), gbegdate = evaluate(gf.guar_financial_resp_type_cd,0.0,gr
        .beg_effective_dt_tm,gf.beg_effective_dt_tm),
       genddate = evaluate(gf.guar_financial_resp_type_cd,0.0,gr.end_effective_dt_tm,gf
        .end_effective_dt_tm), orgguarantorid = er.organization_id, addguarantor = true
      DETAIL
       respactive = band(respactive,er.active_ind)
       IF (respactive=true
        AND responsibilitytype=0.0)
        responsibilitytype = gf.fin_resp_qual_cd
       ENDIF
       IF (responsibilitytype != gf.fin_resp_qual_cd
        AND responsibilitytype != 0.0)
        CALL addtracemessage("getGuarantorFinancialResp",
        "Guarantor Responsibility only supports one type at the time. (Daily Amount OR Percentage)"),
        rtnval = false
       ENDIF
       IF (((ppftencntrid=0.0) OR (ebegindate <= genddate
        AND gbegdate <= eenddate)) )
        IF (addguarantor)
         guarindex += 1, stat = alter3(prrawguarresp->guarantors,guarindex), stat = assign(validate(
           prrawguarresp->guarantors[guarindex].guarorgid),orgguarantorid),
         prrawguarresp->guarantors[guarindex].coguarantortypecd = gtype, prrawguarresp->guarantors[
         guarindex].begineffectivedate = gbegdate, prrawguarresp->guarantors[guarindex].
         endeffectivedate = genddate,
         prrawguarresp->guarantors[guarindex].guarfinancialrespid = gr.guar_financial_resp_id,
         prrawguarresp->guarantors[guarindex].finrespcd = gf.fin_resp_qual_cd, addguarantor = false
        ENDIF
        prrawguarresp->guarantors[guarindex].finrespvalue = evaluate(respactive,true,gf
         .fin_resp_value,0.0), prrawguarresp->guarantors[guarindex].activeind = respactive
       ENDIF
      FOOT  gr.guar_financial_resp_id
       respactive = true, orgguarantorid = 0.0, addguarantor = false
      WITH nocounter
     ;end select
     SET guarindex = size(prrawguarresp->guarantors,5)
     SELECT INTO "nl:"
      FROM pft_encntr pe,
       account a,
       encounter e,
       encntr_person_reltn er,
       guar_fin_resp_reltn gr,
       guar_financial_resp gf
      PLAN (e
       WHERE e.encntr_id=encntrid
        AND e.active_ind=true)
       JOIN (er
       WHERE er.encntr_id=e.encntr_id
        AND er.person_reltn_type_cd=cs351_defguar_cd)
       JOIN (gr
       WHERE gr.parent_entity_id=er.encntr_person_reltn_id
        AND gr.parent_entity_name="ENCNTR_PERSON_RELTN")
       JOIN (gf
       WHERE gf.guar_financial_resp_id=gr.guar_financial_resp_id)
       JOIN (pe
       WHERE (pe.encntr_id= Outerjoin(e.encntr_id))
        AND (pe.active_ind= Outerjoin(true))
        AND parser(pewhere))
       JOIN (a
       WHERE (a.acct_id= Outerjoin(pe.acct_id))
        AND (a.active_ind= Outerjoin(true)) )
      ORDER BY a.billing_entity_id, e.person_id, gr.guar_financial_resp_id,
       er.related_person_id
      HEAD a.billing_entity_id
       prrawguarresp->billingentityid = a.billing_entity_id
      HEAD e.person_id
       prrawguarresp->patientid = e.person_id
      HEAD gr.guar_financial_resp_id
       respactive = band(er.active_ind,band(gr.active_ind,gf.active_ind)), gtype = evaluate(gf
        .guar_financial_resp_type_cd,0.0,gr.guar_financial_resp_type_cd,gf
        .guar_financial_resp_type_cd), gbegdate = evaluate(gf.guar_financial_resp_type_cd,0.0,gr
        .beg_effective_dt_tm,gf.beg_effective_dt_tm),
       genddate = evaluate(gf.guar_financial_resp_type_cd,0.0,gr.end_effective_dt_tm,gf
        .end_effective_dt_tm), guarantorid1 = er.related_person_id, addguarantor = true
      DETAIL
       respactive = band(respactive,er.active_ind)
       IF (respactive=true
        AND responsibilitytype=0.0)
        responsibilitytype = gf.fin_resp_qual_cd
       ENDIF
       IF (responsibilitytype != gf.fin_resp_qual_cd
        AND responsibilitytype != 0.0)
        CALL addtracemessage("getGuarantorFinancialResp",
        "Guarantor Responsibility only supports one type at the time. (Daily Amount OR Percentage)"),
        rtnval = false
       ENDIF
       IF (((ppftencntrid=0.0) OR (ebegindate <= genddate
        AND gbegdate <= eenddate)) )
        IF (addguarantor)
         guarindex += 1, stat = alter3(prrawguarresp->guarantors,guarindex), prrawguarresp->
         guarantors[guarindex].guarantorid1 = guarantorid1,
         prrawguarresp->guarantors[guarindex].coguarantortypecd = gtype, prrawguarresp->guarantors[
         guarindex].begineffectivedate = gbegdate, prrawguarresp->guarantors[guarindex].
         endeffectivedate = genddate,
         prrawguarresp->guarantors[guarindex].guarfinancialrespid = gr.guar_financial_resp_id,
         prrawguarresp->guarantors[guarindex].finrespcd = gf.fin_resp_qual_cd, addguarantor = false
        ENDIF
        prrawguarresp->guarantors[guarindex].finrespvalue = evaluate(respactive,true,gf
         .fin_resp_value,0.0), prrawguarresp->guarantors[guarindex].activeind = respactive
        IF (guarantorid1 != er.related_person_id)
         prrawguarresp->guarantors[guarindex].guarantorid2 = er.related_person_id
        ENDIF
       ENDIF
      FOOT  gr.guar_financial_resp_id
       respactive = true, guarantorid1 = 0.0, addguarantor = false
      WITH nocounter
     ;end select
     FOR (guarindex = 1 TO size(prrawguarresp->guarantors,5))
      SET prrawguarresp->guarantors[guarindex].guarrespacctid = getguarantorrespaccountid(
       prrawguarresp->guarantors[guarindex].guarantorid1,prrawguarresp->guarantors[guarindex].
       guarantorid2,validate(prrawguarresp->guarantors[guarindex].guarorgid,0.0),prrawguarresp->
       patientid,prrawguarresp->billingentityid,
       pskipcreateacct)
      IF ((prrawguarresp->guarantors[guarindex].guarrespacctid <= 0.0)
       AND pskipcreateacct=false)
       SET stat = initrec(prrawguarresp)
       CALL addtracemessage("getGuarantorFinancialResp","Couldn't create guarantor account id")
       SET rtnval = false
      ENDIF
     ENDFOR
    ENDIF
    RETURN(rtnval)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorrespaccountid,char(128))=char(128))
  SUBROUTINE (getguarantorrespaccountid(pguarantorid1=f8,pguarantorid2=f8,pguarorgid=f8,ppatientid=f8,
   pbillingentityid=f8,pskipcreateacct=i2) =f8 WITH protect)
    DECLARE guaracctid = f8 WITH protect, noconstant(0.0)
    RECORD createguarrequest(
      1 billingentityid = f8
      1 guarantorid1 = f8
      1 guarantorid2 = f8
      1 guarorgid = f8
      1 patientid = f8
      1 skipcreateacct = i2
    ) WITH protect
    RECORD createguarreply(
      1 accountid = f8
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
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(rawguarresponsibilities->guarantors,5)))
     PLAN (d
      WHERE (rawguarresponsibilities->guarantors[d.seq].guarantorid1=pguarantorid1)
       AND (rawguarresponsibilities->guarantors[d.seq].guarantorid2=pguarantorid2)
       AND (rawguarresponsibilities->guarantors[d.seq].guarrespacctid != 0.0)
       AND validate(rawguarresponsibilities->guarantors[d.seq].guarorgid,0.0)=pguarorgid)
     HEAD REPORT
      guaracctid = rawguarresponsibilities->guarantors[d.seq].guarrespacctid
     WITH nocounter
    ;end select
    IF (guaracctid=0.0)
     SET createguarrequest->billingentityid = pbillingentityid
     SET createguarrequest->guarantorid1 = pguarantorid1
     SET createguarrequest->guarantorid2 = pguarantorid2
     SET createguarrequest->guarorgid = pguarorgid
     SET createguarrequest->patientid = ppatientid
     SET createguarrequest->skipcreateacct = pskipcreateacct
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(createguarrequest)
     ENDIF
     EXECUTE pft_create_guarantor_acct  WITH replace("REQUEST",createguarrequest), replace("REPLY",
      createguarreply)
     IF ((createguarreply->status_data.status="S"))
      SET guaracctid = createguarreply->accountid
     ELSE
      CALL copytracemessages(createguarreply,reply)
      CALL addtracemessage("getGuarantorRespAccountId",
       "Error occured while calling the pft_create_guarantor_acct script")
     ENDIF
    ENDIF
    RETURN(guaracctid)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbyencntrid,char(128))=char(128))
  SUBROUTINE (getguarantorbyencntrid(pencounterid=f8,prguarantors=vc(ref)) =i2)
    DECLARE gidx = i4 WITH protect, noconstant(0)
    DECLARE pos = i4 WITH protect, noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE p1name = vc WITH protect, noconstant("")
    DECLARE p2name = vc WITH protect, noconstant("")
    DECLARE orgname = vc WITH protect, noconstant("")
    SET gidx = size(prguarantors->guarantorresps,5)
    IF ( NOT (getguarantorfinancialresp(0.0,pencounterid,cnvtdatetime(0.0),rawguarresponsibilities,
     true)))
     CALL logmessage("getGuarantorInfo",
      "Error getting guarantors found from getGuarantorFinancialResp",log_debug)
     RETURN(false)
    ENDIF
    IF (size(rawguarresponsibilities->guarantors,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rawguarresponsibilities->guarantors,5))),
       person p1,
       person p2,
       organization o
      PLAN (d
       WHERE (rawguarresponsibilities->guarantors[d.seq].activeind=true))
       JOIN (p1
       WHERE (p1.person_id= Outerjoin(rawguarresponsibilities->guarantors[d.seq].guarantorid1)) )
       JOIN (p2
       WHERE (p2.person_id= Outerjoin(rawguarresponsibilities->guarantors[d.seq].guarantorid2)) )
       JOIN (o
       WHERE (o.organization_id= Outerjoin(rawguarresponsibilities->guarantors[d.seq].guarorgid)) )
      ORDER BY p1.name_full_formatted, p2.name_full_formatted, p1.person_id,
       p2.person_id, o.org_name, o.organization_id
      HEAD REPORT
       prguarantors->billingentityid = rawguarresponsibilities->billingentityid, prguarantors->
       patientid = rawguarresponsibilities->patientid
      HEAD p1.person_id
       p1name = p1.name_full_formatted
      HEAD p2.person_id
       p2name = evaluate(p2.person_id,0.0,"",concat("; ",p2.name_full_formatted))
      HEAD o.organization_id
       orgname = o.org_name
      DETAIL
       pos = locateval(idx,1,size(prguarantors->guarantorresps,5),rawguarresponsibilities->
        guarantors[d.seq].guarantorid1,prguarantors->guarantorresps[idx].guarantorid1,
        rawguarresponsibilities->guarantors[d.seq].guarantorid2,prguarantors->guarantorresps[idx].
        guarantorid2,rawguarresponsibilities->guarantors[d.seq].guarrespacctid,prguarantors->
        guarantorresps[idx].guarantoraccountid,rawguarresponsibilities->guarantors[d.seq].guarorgid,
        prguarantors->guarantorresps[idx].guarantororgid)
       IF (pos=0
        AND (((rawguarresponsibilities->guarantors[d.seq].guarantorid1 > 0.0)) OR ((((
       rawguarresponsibilities->guarantors[d.seq].guarantorid2 > 0.0)) OR ((rawguarresponsibilities->
       guarantors[d.seq].guarorgid > 0.0))) )) )
        gidx += 1, stat = alterlist(prguarantors->guarantorresps,gidx)
        IF (((p1.person_id > 0.0) OR (p2.person_id > 0.0)) )
         prguarantors->guarantorresps[gidx].guarantorname = trim(build2(trim(p1name,7),trim(p2name,7)
           ),3)
        ELSEIF (o.organization_id > 0.0)
         prguarantors->guarantorresps[gidx].guarantorname = trim(orgname,3)
        ENDIF
        prguarantors->guarantorresps[gidx].guarantoraccountid = rawguarresponsibilities->guarantors[d
        .seq].guarrespacctid, prguarantors->guarantorresps[gidx].guarantorid1 =
        rawguarresponsibilities->guarantors[d.seq].guarantorid1, prguarantors->guarantorresps[gidx].
        guarantorid2 = rawguarresponsibilities->guarantors[d.seq].guarantorid2,
        prguarantors->guarantorresps[gidx].guarantororgid = rawguarresponsibilities->guarantors[d.seq
        ].guarorgid
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    SET stat = initrec(rawguarresponsibilities)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorrespsforencntr,char(128))=char(128))
  SUBROUTINE (getguarantorrespsforencntr(ppftencntrid=f8,pencntrid=f8) =i2)
    DECLARE gidx = i4 WITH protect, noconstant(0)
    DECLARE aidx = i4 WITH protect, noconstant(0)
    DECLARE pos = i4 WITH protect, noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE p1name = vc WITH protect, noconstant("")
    DECLARE p2name = vc WITH protect, noconstant("")
    DECLARE rtnval = i2 WITH protect, noconstant(true)
    SET gidx = size(guarantors->guarantorresps,5)
    IF ( NOT (getguarantorfinancialresp(ppftencntrid,pencntrid,cnvtdatetime(0.0),
     rawguarresponsibilities,false)))
     CALL logmessage("getGuarantorRespsForEncntr",
      "Error retrieving encounter guarantors from getGuarantorFinancialResp",log_debug)
     SET rtnval = false
    ENDIF
    IF ((guarantors->billingentityid > 0.0)
     AND (guarantors->billingentityid != rawguarresponsibilities->billingentityid))
     CALL logmessage("getGuarantorRespsForEncntr",
      "Error Encounter Billing Entity Id doesn't match Guarantors Record's Billing Entity Id",
      log_debug)
     SET rtnval = false
    ENDIF
    IF (rtnval
     AND size(rawguarresponsibilities->guarantors,5) > 0)
     SET guarantors->billingentityid = rawguarresponsibilities->billingentityid
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rawguarresponsibilities->guarantors,5))),
       person p1,
       person p2
      PLAN (d
       WHERE (rawguarresponsibilities->guarantors[d.seq].activeind=true))
       JOIN (p1
       WHERE (p1.person_id=rawguarresponsibilities->guarantors[d.seq].guarantorid1))
       JOIN (p2
       WHERE (p2.person_id=rawguarresponsibilities->guarantors[d.seq].guarantorid2))
      ORDER BY p1.name_full_formatted, p2.name_full_formatted, p1.person_id,
       p2.person_id
      HEAD p1.person_id
       p1name = p1.name_full_formatted
      HEAD p2.person_id
       p2name = evaluate(p2.person_id,0.0,"",concat("; ",p2.name_full_formatted))
      DETAIL
       IF ((((rawguarresponsibilities->guarantors[d.seq].guarantorid1 > 0.0)) OR ((
       rawguarresponsibilities->guarantors[d.seq].guarantorid2 > 0.0))) )
        pos = locateval(idx,1,size(guarantors->guarantorresps,5),rawguarresponsibilities->guarantors[
         d.seq].guarantorid1,guarantors->guarantorresps[idx].guarid1,
         rawguarresponsibilities->guarantors[d.seq].guarantorid2,guarantors->guarantorresps[idx].
         guarid2)
        IF (pos=0)
         gidx = (size(guarantors->guarantorresps,5)+ 1), stat = alterlist(guarantors->guarantorresps,
          gidx), guarantors->guarantorresps[gidx].guarname = trim(build2(trim(p1name,7),trim(p2name,7
            )),3),
         guarantors->guarantorresps[gidx].guarid1 = rawguarresponsibilities->guarantors[d.seq].
         guarantorid1, guarantors->guarantorresps[gidx].guarid2 = rawguarresponsibilities->
         guarantors[d.seq].guarantorid2
        ELSE
         gidx = pos
        ENDIF
        IF (gidx > 0)
         pos = locateval(idx,1,size(guarantors->guarantorresps[gidx].guaraccts,5),
          rawguarresponsibilities->guarantors[d.seq].guarrespacctid,guarantors->guarantorresps[gidx].
          guaraccts[idx].acctid,
          rawguarresponsibilities->patientid,guarantors->guarantorresps[gidx].guaraccts[idx].
          patientid)
         IF (pos=0)
          aidx = (size(guarantors->guarantorresps[gidx].guaraccts,5)+ 1), stat = alterlist(guarantors
           ->guarantorresps[gidx].guaraccts,aidx), guarantors->guarantorresps[gidx].guaraccts[aidx].
          acctid = rawguarresponsibilities->guarantors[d.seq].guarrespacctid,
          guarantors->guarantorresps[gidx].guaraccts[aidx].patientid = rawguarresponsibilities->
          patientid
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(rawguarresponsibilities->guarantors,5))),
       organization o
      PLAN (d
       WHERE (rawguarresponsibilities->guarantors[d.seq].activeind=true))
       JOIN (o
       WHERE (o.organization_id=rawguarresponsibilities->guarantors[d.seq].guarorgid))
      ORDER BY o.org_name, o.organization_id
      HEAD o.organization_id
       IF ((rawguarresponsibilities->guarantors[d.seq].guarorgid > 0.0))
        pos = locateval(idx,1,size(guarantors->guarantorresps,5),rawguarresponsibilities->guarantors[
         d.seq].guarorgid,guarantors->guarantorresps[idx].guarorgid)
        IF (pos=0)
         gidx = (size(guarantors->guarantorresps,5)+ 1), stat = alterlist(guarantors->guarantorresps,
          gidx), guarantors->guarantorresps[gidx].guarname = trim(o.org_name,3),
         guarantors->guarantorresps[gidx].guarorgid = rawguarresponsibilities->guarantors[d.seq].
         guarorgid
        ELSE
         gidx = pos
        ENDIF
        IF (gidx > 0)
         pos = locateval(idx,1,size(guarantors->guarantorresps,5),rawguarresponsibilities->
          guarantors[d.seq].guarrespacctid,guarantors->guarantorresps[gidx].guaraccts[idx].acctid,
          rawguarresponsibilities->patientid,guarantors->guarantorresps[gidx].guaraccts[idx].
          patientid)
         IF (pos=0)
          aidx = (size(guarantors->guarantorresps[gidx].guaraccts,5)+ 1), stat = alterlist(guarantors
           ->guarantorresps[gidx].guaraccts,aidx), guarantors->guarantorresps[gidx].guaraccts[aidx].
          acctid = rawguarresponsibilities->guarantors[d.seq].guarrespacctid,
          guarantors->guarantorresps[gidx].guaraccts[aidx].patientid = rawguarresponsibilities->
          patientid
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (size(guarantors->guarantorresps,5) <= 0)
     SET rtnval = false
    ENDIF
    RETURN(rtnval)
  END ;Subroutine
 ENDIF
 IF (validate(getfinancialservicedatesforguarresps,char(128))=char(128))
  SUBROUTINE (getfinancialservicedatesforguarresps(ppftencntrid=f8,prencntrid=f8(ref),prbegdate=dq8(
    ref),prenddate=dq8(ref)) =i2)
    DECLARE rtnval = i2 WITH protect, noconstant(true)
    IF (ppftencntrid <= 0.0)
     SET rtnval = false
    ELSE
     SELECT INTO "nl:"
      e.encntr_id, e.reg_dt_tm, e.disch_dt_tm,
      pe.recur_current_month, pe.recur_current_year, a.billing_entity_id,
      tmp_getfinsrvdt4guarresps_cmaxdate = max(c.service_dt_tm), tmp_getfinsrvdt4guarresps_cmindate
       = min(c.service_dt_tm)
      FROM pft_encntr pe,
       encounter e,
       account a,
       pft_charge pc,
       charge c
      PLAN (pe
       WHERE pe.pft_encntr_id=ppftencntrid
        AND pe.active_ind=true)
       JOIN (e
       WHERE e.encntr_id=pe.encntr_id
        AND e.active_ind=true)
       JOIN (a
       WHERE a.acct_id=pe.acct_id
        AND a.active_ind=true)
       JOIN (pc
       WHERE (pc.pft_encntr_id= Outerjoin(pe.pft_encntr_id))
        AND (pc.active_ind= Outerjoin(true)) )
       JOIN (c
       WHERE (c.charge_item_id= Outerjoin(pc.charge_item_id))
        AND (c.active_ind= Outerjoin(true)) )
      GROUP BY e.reg_dt_tm, e.disch_dt_tm, pe.recur_current_month,
       pe.recur_current_year, a.billing_entity_id, e.encntr_id
      FOOT  e.reg_dt_tm
       prencntrid = e.encntr_id, rtnval = calculatefinancialservicedatesforguarresps(e.reg_dt_tm,e
        .disch_dt_tm,pe.recur_current_month,pe.recur_current_year,tmp_getfinsrvdt4guarresps_cmaxdate,
        tmp_getfinsrvdt4guarresps_cmindate,prbegdate,prenddate), prbegdate =
       getfacilitybeginningofday(a.billing_entity_id,prbegdate),
       prenddate = getfacilityendofday(a.billing_entity_id,prenddate)
      WITH nocounter
     ;end select
    ENDIF
    RETURN(rtnval)
  END ;Subroutine
 ENDIF
 IF (validate(calculatefinancialservicedatesforguarresps,char(128))=char(128))
  SUBROUTINE (calculatefinancialservicedatesforguarresps(pregdate=dq8,pdisdate=dq8,precurmonth=i4,
   precuryear=i4,pchrgmaxdate=dq8,pchrgmindate=dq8,prbegdate=dq8(ref),prenddate=dq8(ref)) =i2)
    DECLARE startdate = vc WITH noconstant("")
    DECLARE rtnval = i2 WITH protect, noconstant(true)
    IF (validate(debug,- (1)) > 0)
     CALL echo("Before Calculating Service Dates")
     CALL echo(build2("    pRegDate: ",format(pregdate,"MM/dd/yy HH:MM;;d"),"     pDisDate: ",format(
        pdisdate,"MM/dd/yy HH:MM;;d")," pRecurMonth: ",
       precurmonth," pRecurYear: ",precuryear))
     CALL echo(build2("pChrgMaxDate: ",format(pchrgmaxdate,"MM/dd/yy HH:MM;;d")," pChrgMinDate: ",
       format(pchrgmindate,"MM/dd/yy HH:MM;;d")," prBegDate: ",
       format(prbegdate,"MM/dd/yy HH:MM;;d")," prEndDate: ",format(prenddate,"MM/dd/yy HH:MM;;d")))
    ENDIF
    SET prbegdate = pregdate
    SET prenddate = pdisdate
    IF (precurmonth > 0
     AND precuryear > 0)
     IF (((month(prbegdate) != precurmonth) OR (year(prbegdate) != precuryear)) )
      SET startdate = concat(cnvtstring(precurmonth,2,0,r),"01",cnvtstring(precuryear))
      SET prbegdate = cnvtdatetime(cnvtdate(startdate),0)
     ENDIF
     IF (((precurmonth != month(prenddate)) OR (precuryear != year(prenddate))) )
      SET prenddate = datetimefind(cnvtdatetime(cnvtdate(prbegdate),0),"M","E","E")
     ENDIF
    ENDIF
    SET prenddate = evaluate(prenddate,0.0,cnvtdatetime("31-dec-2100 23:59:59"),prenddate)
    IF (((pchrgmindate > 0.0
     AND pchrgmindate < prbegdate) OR (prbegdate=0.0
     AND pchrgmindate > 0.0)) )
     SET prbegdate = pchrgmindate
    ENDIF
    IF (pchrgmaxdate > prenddate)
     SET prenddate = pchrgmaxdate
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL echo("After Calculating Service Dates")
     CALL echo(build2("    pRegDate: ",format(pregdate,"MM/dd/yy HH:MM;;d"),"     pDisDate: ",format(
        pdisdate,"MM/dd/yy HH:MM;;d")," pRecurMonth: ",
       precurmonth," pRecurYear: ",precuryear))
     CALL echo(build2("pChrgMaxDate: ",format(pchrgmaxdate,"MM/dd/yy HH:MM;;d")," pChrgMinDate: ",
       format(pchrgmindate,"MM/dd/yy HH:MM;;d")," prBegDate: ",
       format(prbegdate,"MM/dd/yy HH:MM;;d")," prEndDate: ",format(prenddate,"MM/dd/yy HH:MM;;d")))
    ENDIF
    RETURN(rtnval)
  END ;Subroutine
 ENDIF
 IF (validate(ismultiguarantor2match,char(128))=char(128))
  SUBROUTINE (ismultiguarantor2match(ptablepersonid=f8,precordpersonid=f8) =i2)
   IF (((ptablepersonid <= 0.0
    AND precordpersonid <= 0.0) OR (ptablepersonid=precordpersonid
    AND precordpersonid > 0.0)) )
    RETURN(true)
   ENDIF
   RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(publishguarantorworkflowevent,char(128))=char(128))
  SUBROUTINE (publishguarantorworkflowevent(ppftencntrid=f8) =i2)
    IF (checkprg("PFT_PUBLISH_EVENT")=0)
     RETURN(true)
    ENDIF
    IF ( NOT (validate(cs23369_wfevent)))
     DECLARE cs23369_wfevent = f8 WITH protect, noconstant(getcodevalue(23369,"WFEVENT",1))
    ENDIF
    IF ( NOT (validate(cs29322_guarnotfound)))
     DECLARE cs29322_guarnotfound = f8 WITH protect, constant(getcodevalue(29322,"GUARNOTFOUND",1))
    ENDIF
    RECORD publisheventrequest(
      1 eventlist[*]
        2 entitytypekey = vc
        2 entityid = f8
        2 eventtypecd = f8
        2 eventcd = f8
        2 params[*]
          3 paramcd = f8
          3 paramvalue = f8
    ) WITH protect
    RECORD publisheventreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET stat = alterlist(publisheventrequest->eventlist,1)
    SET publisheventrequest->eventlist[1].entitytypekey = "PFTENCNTR"
    SET publisheventrequest->eventlist[1].entityid = ppftencntrid
    SET publisheventrequest->eventlist[1].eventcd = cs29322_guarnotfound
    SET publisheventrequest->eventlist[1].eventtypecd = cs23369_wfevent
    EXECUTE pft_publish_event  WITH replace("REQUEST",publisheventrequest), replace("REPLY",
     publisheventreply)
    IF ((publisheventreply->status_data.status != "S"))
     CALL logmessage("publishGuarantorWorkflowEvent","Call to pft_publish_event failed",log_error)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getprimaryguarantorsequence,char(128))=char(128))
  SUBROUTINE (getprimaryguarantorsequence(prprimaryguarseq=i4(ref)) =i2)
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_value=cs20790_priorityseq
      AND cve.code_set=20790
      AND cve.field_name="OPTION")
    DETAIL
     prprimaryguarseq = cnvtint(cve.field_value)
    WITH nocounter
   ;end select
   RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getorgguarantorbyencounter,char(128))=char(128))
  SUBROUTINE (getorgguarantorbyencounter(pencntrid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE adt_constant = i4 WITH protect, constant(99)
    DECLARE primaryguarseq = i4 WITH protect, noconstant(0)
    DECLARE internalguarind = i4 WITH protect, noconstant(false)
    SET prguarantorid = 0.0
    SET stat = getprimaryguarantorsequence(primaryguarseq)
    SELECT INTO "nl:"
     FROM encntr_org_reltn eor,
      organization o
     PLAN (eor
      WHERE eor.encntr_id=pencntrid
       AND eor.encntr_org_reltn_cd=cs352_guarantor
       AND eor.priority_seq IN (primaryguarseq, adt_constant)
       AND eor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND eor.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND eor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=eor.organization_id
       AND o.active_ind=true)
     DETAIL
      IF (eor.priority_seq=primaryguarseq)
       prguarantorid = o.organization_id, internalguarind = true
      ELSEIF (eor.priority_seq=adt_constant
       AND  NOT (internalguarind))
       prguarantorid = o.organization_id
      ENDIF
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getorgguarantorbyfinencounter,char(128))=char(128))
  SUBROUTINE (getorgguarantorbyfinencounter(ppftencntrid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    SET stat = getencounterbyfinancialencounter(ppftencntrid,encntrid)
    SET stat = getorgguarantorbyencounter(encntrid,prguarantorid)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getencounterbyfinancialencounter,char(128))=char(128))
  SUBROUTINE (getencounterbyfinancialencounter(ppftencntrid=f8,prencntrid=f8(ref)) =i2)
    SET prencntrid = 0.0
    SELECT INTO "nl:"
     FROM pft_encntr pe
     PLAN (pe
      WHERE pe.pft_encntr_id=ppftencntrid
       AND pe.active_ind=true)
     ORDER BY pe.encntr_id
     HEAD pe.encntr_id
      prencntrid = pe.encntr_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getfinanciallyresponsiblepersonguarantorsforencounter,char(128))=char(128))
  SUBROUTINE (getfinanciallyresponsiblepersonguarantorsforencounter(prencounterlist=vc(ref),prguars=
   vc(ref)) =i2)
    DECLARE guarcnt = i4 WITH protect, noconstant(size(prguars->guarlist,5))
    DECLARE cboscnt = i4 WITH protect, noconstant(size(prencounterlist->encounters,5))
    DECLARE encntridx = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM encounter e,
      encntr_person_reltn epr,
      person p,
      guar_fin_resp_reltn gfrr,
      guar_financial_resp gfr
     PLAN (e
      WHERE expand(encntridx,1,cboscnt,e.encntr_id,prencounterlist->encounters[encntridx].encntrid)
       AND e.active_ind=true)
      JOIN (epr
      WHERE epr.encntr_id=e.encntr_id
       AND epr.person_reltn_type_cd=cs351_defguar_cd
       AND epr.active_ind=true)
      JOIN (p
      WHERE p.person_id=epr.related_person_id
       AND p.active_ind=true)
      JOIN (gfrr
      WHERE gfrr.parent_entity_id=epr.encntr_person_reltn_id
       AND gfrr.parent_entity_name="ENCNTR_PERSON_RELTN"
       AND gfrr.active_ind=true)
      JOIN (gfr
      WHERE gfr.guar_financial_resp_id=gfrr.guar_financial_resp_id
       AND gfr.fin_resp_value >= 0.0
       AND gfr.active_ind=true)
     ORDER BY p.person_id
     HEAD p.person_id
      guarcnt += 1, stat = alterlist(prguars->guarlist,guarcnt), prguars->guarlist[guarcnt].personid
       = p.person_id
      IF (gfr.guar_financial_resp_type_cd=cs387572_joint)
       prguars->guarlist[guarcnt].jointresponsibilityind = true
      ENDIF
     WITH nocounter, expand = 1
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getfinanciallyresponsibleorganizationguarantorsforencounter,char(128))=char(128))
  SUBROUTINE (getfinanciallyresponsibleorganizationguarantorsforencounter(prencounterlist=vc(ref),
   prguars=vc(ref)) =i2)
    DECLARE guarcnt = i4 WITH protect, noconstant(size(prguars->guarlist,5))
    DECLARE cboscnt = i4 WITH protect, noconstant(size(prencounterlist->encounters,5))
    DECLARE encntridx = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM encounter e,
      encntr_org_reltn eor,
      organization o,
      guar_fin_resp_reltn gfrr,
      guar_financial_resp gfr
     PLAN (e
      WHERE expand(encntridx,1,cboscnt,e.encntr_id,prencounterlist->encounters[encntridx].encntrid)
       AND e.encntr_id > 0.0
       AND e.active_ind=true)
      JOIN (eor
      WHERE eor.encntr_id=e.encntr_id
       AND eor.encntr_org_reltn_cd=cs352_guarantor
       AND eor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=eor.organization_id
       AND o.active_ind=true)
      JOIN (gfrr
      WHERE gfrr.parent_entity_id=eor.encntr_org_reltn_id
       AND gfrr.parent_entity_name="ENCNTR_ORG_RELTN"
       AND gfrr.active_ind=true)
      JOIN (gfr
      WHERE gfr.guar_financial_resp_id=gfrr.guar_financial_resp_id
       AND gfr.fin_resp_value >= 0.0
       AND gfr.active_ind=true)
     ORDER BY o.organization_id
     HEAD o.organization_id
      guarcnt += 1, stat = alterlist(prguars->guarlist,guarcnt), prguars->guarlist[guarcnt].orgid = o
      .organization_id
      IF (gfr.guar_financial_resp_type_cd=cs387572_joint)
       prguars->guarlist[guarcnt].jointresponsibilityind = true
      ENDIF
     WITH nocounter, expand = 1
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getfinanciallyresponsibleguarantorsforencounter,char(128))=char(128))
  SUBROUTINE (getfinanciallyresponsibleguarantorsforencounter(pencntrid=f8,prguars=vc(ref)) =i2)
    SET stat = alterlist(prencounterlist->encounters,1)
    SET prencounterlist->encounters[1].encntrid = pencntrid
    SET stat = getfinanciallyresponsiblepersonguarantorsforencounter(prencounterlist,prguars)
    SET stat = getfinanciallyresponsibleorganizationguarantorsforencounter(prencounterlist,prguars)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getfinanciallyresponsibleguarantorsforencounterlist,char(128))=char(128))
  SUBROUTINE (getfinanciallyresponsibleguarantorsforencounterlist(prguars=vc(ref),prencounterlist=vc(
    ref)) =i2)
    SET stat = getfinanciallyresponsiblepersonguarantorsforencounter(prencounterlist,prguars)
    SET stat = getfinanciallyresponsibleorganizationguarantorsforencounter(prencounterlist,prguars)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getfinanciallyresponsibleguarantorsforfinancialencounter,char(128))=char(128))
  SUBROUTINE (getfinanciallyresponsibleguarantorsforfinancialencounter(ppftencntrid=f8,prguars=vc(ref
    )) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    SET stat = getencounterbyfinancialencounter(ppftencntrid,encntrid)
    SET stat = getfinanciallyresponsibleguarantorsforencounter(encntrid,prguars)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getprimarypersonguarantorforencounter,char(128))=char(128))
  SUBROUTINE (getprimarypersonguarantorforencounter(pencntrid=f8,prguarantorid=f8(ref),prexternalind=
   i2(ref)) =i2)
    DECLARE adt_constant = i4 WITH protect, constant(99)
    DECLARE primaryguarantorseq = i4 WITH protect, noconstant(0)
    SET prguarantorid = 0.0
    SET prexternalind = false
    SET stat = getprimaryguarantorsequence(primaryguarantorseq)
    SELECT INTO "nl:"
     FROM encounter e,
      encntr_person_reltn epr,
      person p
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (epr
      WHERE epr.encntr_id=pencntrid
       AND epr.person_reltn_type_cd=cs351_defguar_cd
       AND epr.priority_seq IN (primaryguarantorseq, adt_constant)
       AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND epr.active_ind=true)
      JOIN (p
      WHERE p.person_id=epr.related_person_id
       AND p.active_ind=true)
     ORDER BY p.person_id
     HEAD p.person_id
      IF (epr.priority_seq=adt_constant
       AND prguarantorid <= 0.0)
       prguarantorid = p.person_id, prexternalind = true
      ENDIF
      IF (epr.priority_seq=primaryguarantorseq)
       prguarantorid = p.person_id, prexternalind = false
      ENDIF
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getprimaryorganizationguarantorforencounter,char(128))=char(128))
  SUBROUTINE (getprimaryorganizationguarantorforencounter(pencntrid=f8,prguarantorid=f8(ref),
   prexternalind=i2(ref)) =i2)
    DECLARE adt_constant = i4 WITH protect, constant(99)
    DECLARE primaryguarantorseq = i4 WITH protect, noconstant(0)
    SET prguarantorid = 0.0
    SET prexternalind = false
    SET stat = getprimaryguarantorsequence(primaryguarantorseq)
    SELECT INTO "nl:"
     FROM encounter e,
      encntr_org_reltn eor,
      organization o
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (eor
      WHERE eor.encntr_id=pencntrid
       AND eor.encntr_org_reltn_cd=cs352_guarantor
       AND eor.priority_seq IN (primaryguarantorseq, adt_constant)
       AND eor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND eor.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND eor.active_ind=true)
      JOIN (o
      WHERE o.organization_id=eor.organization_id
       AND o.active_ind=true)
     ORDER BY o.organization_id
     HEAD o.organization_id
      IF (eor.priority_seq=adt_constant
       AND prguarantorid <= 0.0)
       prguarantorid = o.organization_id, prexternalind = true
      ENDIF
      IF (eor.priority_seq=primaryguarantorseq)
       prguarantorid = o.organization_id, prexternalind = false
      ENDIF
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getprimaryguarantorforencounter,char(128))=char(128))
  SUBROUTINE (getprimaryguarantorforencounter(pencntrid=f8,prguarantorid=f8(ref),prpersonind=i2(ref)
   ) =i2)
    DECLARE externalguarantorind = i2 WITH protect, noconstant(false)
    DECLARE personguarantorid = f8 WITH protect, noconstant(0.0)
    SET prguarantorid = 0.0
    SET prpersonind = false
    SET stat = getprimarypersonguarantorforencounter(pencntrid,prguarantorid,externalguarantorind)
    IF (prguarantorid > 0.0)
     SET personguarantorid = prguarantorid
     SET prpersonind = true
     IF ( NOT (externalguarantorind))
      RETURN(true)
     ENDIF
    ENDIF
    SET prguarantorid = 0.0
    SET stat = getprimaryorganizationguarantorforencounter(pencntrid,prguarantorid,
     externalguarantorind)
    IF (prguarantorid > 0.0)
     SET prpersonind = false
     IF ( NOT (externalguarantorind))
      RETURN(true)
     ELSE
      IF (personguarantorid > 0.0)
       SET prguarantorid = personguarantorid
       SET prpersonind = true
       RETURN(true)
      ENDIF
     ENDIF
    ELSE
     IF (personguarantorid > 0.0)
      SET prguarantorid = personguarantorid
      SET prpersonind = true
      RETURN(true)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getprimaryguarantorforfinancialencounter,char(128))=char(128))
  SUBROUTINE (getprimaryguarantorforfinancialencounter(ppftencntrid=f8,prguarantorid=f8(ref),
   prpersonind=i2(ref)) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    SET prguarantorid = 0.0
    SET prpersonind = false
    SET stat = getencounterbyfinancialencounter(ppftencntrid,encntrid)
    SET stat = getprimaryguarantorforencounter(encntrid,prguarantorid,prpersonind)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(ismultipleguarantorencounter,char(128))=char(128))
  SUBROUTINE (ismultipleguarantorencounter(pencntrid=f8) =i2)
    RECORD encntrguars(
      1 guarlist[*]
        2 personid = f8
        2 orgid = f8
        2 jointresponsibilityind = i2
    ) WITH protect
    SET stat = getfinanciallyresponsibleguarantorsforencounter(pencntrid,encntrguars)
    RETURN(evaluate(size(encntrguars->guarlist,5),0,false,true))
  END ;Subroutine
 ENDIF
 IF (validate(ismultipleguarantorencounterlist,char(128))=char(128))
  SUBROUTINE (ismultipleguarantorencounterlist(prencounterlist=vc(ref)) =i2)
    RECORD encntrguars(
      1 guarlist[*]
        2 personid = f8
        2 orgid = f8
        2 jointresponsibilityind = i2
    ) WITH protect
    SET stat = getfinanciallyresponsibleguarantorsforencounterlist(encntrguars,prencounterlist)
    RETURN(evaluate(size(encntrguars->guarlist,5),0,false,true))
  END ;Subroutine
 ENDIF
 IF (validate(ismultipleguarantorfinancialencounter,char(128))=char(128))
  SUBROUTINE (ismultipleguarantorfinancialencounter(ppftencntrid=f8) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    SET stat = getencounterbyfinancialencounter(ppftencntrid,encntrid)
    RETURN(ismultipleguarantorencounter(encntrid))
  END ;Subroutine
 ENDIF
 IF (validate(isuserauthorizedtoviewencounter,char(128))=char(128))
  SUBROUTINE (isuserauthorizedtoviewencounter(pencntrid=f8) =i2)
    RECORD authorizedbes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    DECLARE beidx = i4 WITH protect, noconstant(0)
    DECLARE becnt = i4 WITH protect, noconstant(0)
    DECLARE userauthind = i2 WITH protect, noconstant(false)
    IF ( NOT (getuserauthorizedbillingentities(authorizedbes)))
     CALL exitservicefailure("Unable to retrieve authorized biling entity ids",true)
    ENDIF
    SET becnt = size(authorizedbes->billingentities,5)
    SELECT INTO "nl:"
     FROM encounter e,
      be_org_reltn bor
     PLAN (e
      WHERE e.encntr_id=pencntrid
       AND e.active_ind=true)
      JOIN (bor
      WHERE bor.organization_id=e.organization_id
       AND bor.active_ind=true
       AND expand(beidx,1,becnt,bor.billing_entity_id,authorizedbes->billingentities[beidx].
       billingentityid))
     ORDER BY e.encntr_id
     HEAD e.encntr_id
      userauthind = true
     WITH nocounter
    ;end select
    RETURN(userauthind)
  END ;Subroutine
 ENDIF
 IF (validate(getviewableguarantoraccountsforencounters,char(128))=char(128))
  SUBROUTINE (getviewableguarantoraccountsforencounters(pentityid=f8,pentitytype=i4,prencntrs=vc(ref),
   prguars=vc(ref)) =i2)
    RECORD viewablebes(
      1 billingentities[*]
        2 billingentityid = f8
    ) WITH protect
    DECLARE encntridx = i4 WITH protect, noconstant(0)
    SET stat = getviewablebillingentitiesforentity(pentityid,pentitytype,viewablebes)
    FOR (encntridx = 1 TO size(prencntrs->encntrs,5))
     SET stat = getpersonguarantoraccounts(prencntrs->encntrs[encntridx].encntrid,prencntrs->encntrs[
      encntridx].multiguarantorencntrind,viewablebes,prguars)
     SET stat = getorganizationguarantoraccounts(viewablebes,prguars)
    ENDFOR
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpersonguarantoraccounts,char(128))=char(128))
  SUBROUTINE (getpersonguarantoraccounts(pencntrid=f8,pfinrespind=i2,prbes=vc(ref),prguars=vc(ref)) =
   i2)
    DECLARE beidx = i4 WITH protect, noconstant(0)
    DECLARE becnt = i4 WITH protect, noconstant(size(prbes->billingentities,5))
    DECLARE acctidx = i4 WITH protect, noconstant(0)
    DECLARE acctcnt = i4 WITH protect, noconstant(0)
    DECLARE acctloc = i4 WITH protect, noconstant(0)
    IF (pfinrespind)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(prguars->guarlist,5)),
       person p1,
       pft_acct_reltn par1,
       account a,
       pft_acct_reltn par2,
       person p2,
       cbos_pe_reltn cpr,
       pft_encntr pe,
       encounter e
      PLAN (d
       WHERE (prguars->guarlist[d.seq].personid > 0.0))
       JOIN (p1
       WHERE (p1.person_id=prguars->guarlist[d.seq].personid)
        AND p1.active_ind=true)
       JOIN (par1
       WHERE par1.parent_entity_id=p1.person_id
        AND par1.parent_entity_name="GUARANTOR"
        AND par1.role_type_cd=cs18936_guarantor
        AND par1.active_ind=true)
       JOIN (a
       WHERE a.acct_id=par1.acct_id
        AND a.acct_type_cd=cs18736_ar
        AND a.acct_sub_type_cd=cs20849_guarantor
        AND expand(beidx,1,becnt,a.billing_entity_id,prbes->billingentities[beidx].billingentityid)
        AND a.active_ind=true)
       JOIN (par2
       WHERE (par2.acct_id= Outerjoin(par1.acct_id))
        AND (par2.parent_entity_id!= Outerjoin(par1.parent_entity_id))
        AND (par2.parent_entity_name= Outerjoin(par1.parent_entity_name))
        AND (par2.role_type_cd= Outerjoin(par1.role_type_cd))
        AND (par2.active_ind= Outerjoin(true)) )
       JOIN (p2
       WHERE (p2.person_id= Outerjoin(par2.parent_entity_id))
        AND (p2.active_ind= Outerjoin(true)) )
       JOIN (cpr
       WHERE cpr.acct_id=a.acct_id
        AND cpr.active_ind=true)
       JOIN (pe
       WHERE pe.pft_encntr_id=cpr.pft_encntr_id
        AND pe.active_ind=true)
       JOIN (e
       WHERE e.encntr_id=pe.encntr_id
        AND e.encntr_id=pencntrid
        AND e.active_ind=true)
      ORDER BY d.seq, a.acct_id
      HEAD d.seq
       acctcnt = size(prguars->guarlist[d.seq].accounts,5)
      HEAD a.acct_id
       acctloc = locateval(acctidx,1,acctcnt,a.acct_id,prguars->guarlist[d.seq].accounts[acctidx].
        accountid)
       IF (acctloc=0)
        acctcnt += 1, stat = alterlist(prguars->guarlist[d.seq].accounts,acctcnt), prguars->guarlist[
        d.seq].accounts[acctcnt].accountid = a.acct_id,
        prguars->guarlist[d.seq].accounts[acctcnt].accountnumber = trim(a.ext_acct_id_txt,3)
        IF (p2.person_id > 0.0)
         prguars->guarlist[d.seq].accounts[acctcnt].jointaccountind = true, prguars->guarlist[d.seq].
         accounts[acctcnt].jointentityname = trim(p2.name_full_formatted,3), prguars->guarlist[d.seq]
         .accounts[acctcnt].jointentityid = p2.person_id
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(prguars->guarlist,5)),
       person p,
       pft_acct_reltn par,
       account a
      PLAN (d
       WHERE (prguars->guarlist[d.seq].personid > 0.0))
       JOIN (p
       WHERE (p.person_id=prguars->guarlist[d.seq].personid)
        AND p.active_ind=true)
       JOIN (par
       WHERE par.parent_entity_id=p.person_id
        AND par.parent_entity_name="GUARANTOR"
        AND par.role_type_cd=cs18936_guarantor
        AND par.active_ind=true
        AND  NOT ( EXISTS (
       (SELECT
        1
        FROM pft_acct_reltn par1
        WHERE par1.acct_id=par.acct_id
         AND par1.parent_entity_id != par.parent_entity_id
         AND par1.parent_entity_name=par.parent_entity_name
         AND par1.role_type_cd=par.role_type_cd
         AND par1.active_ind=par.active_ind))))
       JOIN (a
       WHERE a.acct_id=par.acct_id
        AND a.acct_type_cd=cs18736_ar
        AND a.acct_sub_type_cd=cs20849_guarantor
        AND expand(beidx,1,becnt,a.billing_entity_id,prbes->billingentities[beidx].billingentityid)
        AND a.active_ind=true)
      ORDER BY d.seq, a.acct_id
      HEAD d.seq
       acctcnt = size(prguars->guarlist[d.seq].accounts,5)
      HEAD a.acct_id
       acctloc = locateval(acctidx,1,acctcnt,a.acct_id,prguars->guarlist[d.seq].accounts[acctidx].
        accountid)
       IF (acctloc=0)
        acctcnt += 1, stat = alterlist(prguars->guarlist[d.seq].accounts,acctcnt), prguars->guarlist[
        d.seq].accounts[acctcnt].accountid = a.acct_id,
        prguars->guarlist[d.seq].accounts[acctcnt].accountnumber = trim(a.ext_acct_id_txt,3)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getorganizationguarantoraccounts,char(128))=char(128))
  SUBROUTINE (getorganizationguarantoraccounts(prbes=vc(ref),prguars=vc(ref)) =i2)
    DECLARE beidx = i4 WITH protect, noconstant(0)
    DECLARE becnt = i4 WITH protect, noconstant(size(prbes->billingentities,5))
    DECLARE acctcnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(prguars->guarlist,5)),
      organization o,
      pft_acct_reltn par,
      account a
     PLAN (d
      WHERE (prguars->guarlist[d.seq].orgid > 0.0))
      JOIN (o
      WHERE (o.organization_id=prguars->guarlist[d.seq].orgid)
       AND o.active_ind=true)
      JOIN (par
      WHERE par.parent_entity_id=o.organization_id
       AND par.parent_entity_name="ORGANIZATION"
       AND par.role_type_cd=cs18936_guarantor
       AND par.active_ind=true)
      JOIN (a
      WHERE a.acct_id=par.acct_id
       AND a.acct_type_cd=cs18736_ar
       AND a.acct_sub_type_cd=cs20849_guarantor
       AND expand(beidx,1,becnt,a.billing_entity_id,prbes->billingentities[beidx].billingentityid)
       AND a.active_ind=true)
     ORDER BY d.seq, a.acct_id
     HEAD d.seq
      acctcnt = 0
     HEAD a.acct_id
      acctcnt += 1, stat = alterlist(prguars->guarlist[d.seq].accounts,acctcnt), prguars->guarlist[d
      .seq].accounts[acctcnt].accountid = a.acct_id,
      prguars->guarlist[d.seq].accounts[acctcnt].accountnumber = trim(a.ext_acct_id_txt,3)
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getdefaultguarantorbyencntrid,char(128))=char(128))
  SUBROUTINE (getdefaultguarantorbyencntrid(pencounterid=f8,prguarantors=vc(ref)) =i2)
    DECLARE gidx = i4 WITH protect, noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE pos = i4 WITH protect, noconstant(0)
    SET gidx = size(prguarantors->guarantorresps,5)
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe,
      cbos_pe_reltn cper,
      cbos_person_reltn cpr,
      person p,
      organization o,
      account a
     PLAN (e
      WHERE e.encntr_id=pencounterid
       AND e.active_ind=true)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true)
      JOIN (cper
      WHERE cper.pft_encntr_id=pe.pft_encntr_id
       AND cper.active_ind=true)
      JOIN (cpr
      WHERE cpr.cons_bo_sched_id=cper.cons_bo_sched_id
       AND cpr.active_ind=true)
      JOIN (p
      WHERE (p.person_id= Outerjoin(cpr.person_id))
       AND (p.active_ind= Outerjoin(true)) )
      JOIN (o
      WHERE (o.organization_id= Outerjoin(cpr.organization_id))
       AND (o.active_ind= Outerjoin(true)) )
      JOIN (a
      WHERE a.acct_id=pe.acct_id
       AND a.active_ind=true)
     ORDER BY e.person_id, a.billing_entity_id
     HEAD e.person_id
      prguarantors->patientid = e.person_id
     HEAD a.billing_entity_id
      prguarantors->billingentityid = a.billing_entity_id
     DETAIL
      pos = locateval(idx,1,size(prguarantors->guarantorresps,5),p.person_id,prguarantors->
       guarantorresps[idx].guarantorid1,
       cper.acct_id,prguarantors->guarantorresps[idx].guarantoraccountid,o.organization_id,
       prguarantors->guarantorresps[idx].guarantororgid)
      IF (pos=0
       AND ((p.person_id > 0.0) OR (o.organization_id > 0.0)) )
       gidx += 1, stat = alterlist(prguarantors->guarantorresps,gidx)
       IF (p.person_id > 0.0)
        prguarantors->guarantorresps[gidx].guarantorname = trim(p.name_full_formatted,3)
       ELSEIF (o.organization_id > 0.0)
        prguarantors->guarantorresps[gidx].guarantorname = trim(o.org_name,3)
       ENDIF
       prguarantors->guarantorresps[gidx].guarantoraccountid = cper.acct_id, prguarantors->
       guarantorresps[gidx].guarantorid1 = p.person_id, prguarantors->guarantorresps[gidx].
       guarantororgid = o.organization_id
      ENDIF
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorsforguarantoraccount,char(128))=char(128))
  SUBROUTINE (getguarantorsforguarantoraccount(pguaracctid=f8,prguars=vc(ref)) =i2)
    SET stat = initrec(prguars)
    DECLARE gcnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM account a,
      pft_acct_reltn paro,
      organization o,
      pft_acct_reltn parp,
      person p,
      pft_acct_reltn parp2,
      person p2
     PLAN (a
      WHERE a.acct_id=pguaracctid
       AND a.acct_type_cd=cs18736_ar
       AND a.acct_sub_type_cd=cs20849_guarantor
       AND a.active_ind=true)
      JOIN (parp
      WHERE (parp.acct_id= Outerjoin(a.acct_id))
       AND (parp.parent_entity_name= Outerjoin("GUARANTOR"))
       AND (parp.role_type_cd= Outerjoin(cs18936_guarantor))
       AND (parp.active_ind= Outerjoin(true)) )
      JOIN (p
      WHERE (p.person_id= Outerjoin(parp.parent_entity_id))
       AND (p.active_ind= Outerjoin(true)) )
      JOIN (parp2
      WHERE (parp2.acct_id= Outerjoin(parp.acct_id))
       AND (parp2.parent_entity_id!= Outerjoin(parp.parent_entity_id))
       AND (parp2.parent_entity_name= Outerjoin(parp.parent_entity_name))
       AND (parp2.role_type_cd= Outerjoin(parp.role_type_cd))
       AND (parp2.active_ind= Outerjoin(true)) )
      JOIN (p2
      WHERE (p2.person_id= Outerjoin(parp2.parent_entity_id))
       AND (p2.active_ind= Outerjoin(true)) )
      JOIN (paro
      WHERE (paro.acct_id= Outerjoin(a.acct_id))
       AND (paro.parent_entity_name= Outerjoin("ORGANIZATION"))
       AND (paro.role_type_cd= Outerjoin(cs18936_guarantor))
       AND (paro.active_ind= Outerjoin(true)) )
      JOIN (o
      WHERE (o.organization_id= Outerjoin(paro.parent_entity_id))
       AND (o.active_ind= Outerjoin(true)) )
     ORDER BY p.person_id, o.organization_id
     HEAD p.person_id
      IF (p.person_id > 0.0)
       gcnt = (size(prguars->guarlist,5)+ 1), stat = alterlist(prguars->guarlist,gcnt), prguars->
       guarlist[gcnt].personid = p.person_id,
       stat = alterlist(prguars->guarlist[gcnt].accounts,1), prguars->guarlist[gcnt].accounts[1].
       accountid = pguaracctid, prguars->guarlist[gcnt].accounts[1].guaracctbalance = evaluate(a
        .dr_cr_flag,2,(a.acct_balance * - (1.0)),a.acct_balance),
       prguars->guarlist[gcnt].accounts[1].accountnumber = trim(a.ext_acct_id_txt,3), prguars->
       guarlist[gcnt].accounts[1].acctstatus = uar_get_code_display(a.acct_status_cd)
       IF (p2.person_id > 0.0)
        prguars->guarlist[gcnt].accounts[1].jointaccountind = true, prguars->guarlist[gcnt].accounts[
        1].jointentityname = trim(p2.name_full_formatted,3), prguars->guarlist[gcnt].accounts[1].
        jointentityid = p2.person_id
       ENDIF
      ENDIF
     HEAD o.organization_id
      IF (o.organization_id > 0.0)
       gcnt = (size(prguars->guarlist,5)+ 1), stat = alterlist(prguars->guarlist,gcnt), prguars->
       guarlist[gcnt].orgid = o.organization_id,
       stat = alterlist(prguars->guarlist[gcnt].accounts,1), prguars->guarlist[gcnt].accounts[1].
       accountid = pguaracctid, prguars->guarlist[gcnt].accounts[1].guaracctbalance = evaluate(a
        .dr_cr_flag,2,(a.acct_balance * - (1.0)),a.acct_balance),
       prguars->guarlist[gcnt].accounts[1].accountnumber = trim(a.ext_acct_id_txt,3), prguars->
       guarlist[gcnt].accounts[1].acctstatus = uar_get_code_display(a.acct_status_cd)
      ENDIF
     WITH nocounter
    ;end select
    IF (validate(debug,0) > 0)
     CALL echorecord(prguars)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(createbohpcbos,char(128))=char(128))
  SUBROUTINE (createbohpcbos(pencntrid=f8,ppftencntrid=f8,pacctid=f8) =i2)
    RECORD cbosrequest(
      1 encntr_id = f8
      1 acct_id = f8
      1 pft_encntr_id = f8
      1 cons_bo_sched_id = f8
    ) WITH protect
    RECORD cbosreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET cbosrequest->encntr_id = pencntrid
    SET cbosrequest->pft_encntr_id = ppftencntrid
    SET cbosrequest->acct_id = pacctid
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(cbosrequest)
    ENDIF
    EXECUTE pft_bo_hp_cbos  WITH replace("REQUEST",cbosrequest), replace("REPLY",cbosreply)
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(cbosreply)
    ENDIF
    IF ((cbosreply->status_data.status != "S"))
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbyschedulingentry,char(128))=char(128))
  SUBROUTINE (getguarantorbyschedulingentry(pschentryid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE patientid = f8 WITH protect, noconstant(0.0)
    DECLARE encounterid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM sch_entry se
     WHERE se.sch_entry_id=pschentryid
      AND se.active_ind=true
      AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     DETAIL
      patientid = se.person_id, encounterid = se.encntr_id
     WITH nocounter
    ;end select
    IF (encounterid > 0.0)
     RETURN(getguarantorbyencounter(encounterid,prguarantorid))
    ELSEIF (patientid > 0.0)
     RETURN(getguarantoratpatientlevel(patientid,prguarantorid))
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
 ENDIF
 CALL echo("Begin PFT_WF_WORK_ITEM_CONST.INC, version [664227.020]")
 IF ( NOT (validate(wi_state_assessment)))
  DECLARE wi_state_assessment = vc WITH public, constant("ISSUEASSESS")
 ENDIF
 IF ( NOT (validate(wi_state_resolution)))
  DECLARE wi_state_resolution = vc WITH public, constant("ISSUERESOLUT")
 ENDIF
 IF ( NOT (validate(wi_state_review)))
  DECLARE wi_state_review = vc WITH public, constant("ISSUEREVIEW")
 ENDIF
 IF ( NOT (validate(wi_state_complete)))
  DECLARE wi_state_complete = vc WITH public, constant("COMPLETE")
 ENDIF
 IF ( NOT (validate(wi_role_assessor)))
  DECLARE wi_role_assessor = vc WITH public, constant("ISSUEASSESS")
 ENDIF
 IF ( NOT (validate(wi_role_resolver)))
  DECLARE wi_role_resolver = vc WITH public, constant("ISSUERESOLUT")
 ENDIF
 IF ( NOT (validate(wi_role_reviewer)))
  DECLARE wi_role_reviewer = vc WITH public, constant("ISSUEREVIEW")
 ENDIF
 IF ( NOT (validate(wi_owner_department)))
  DECLARE wi_owner_department = vc WITH constant("DEPARTMENT")
 ENDIF
 IF ( NOT (validate(wi_owner_guarantor)))
  DECLARE wi_owner_guarantor = vc WITH constant("GUARANTOR")
 ENDIF
 IF ( NOT (validate(wi_owner_personnel)))
  DECLARE wi_owner_personnel = vc WITH constant("PERSONNEL")
 ENDIF
 IF ( NOT (validate(wi_owner_subscriber)))
  DECLARE wi_owner_subscriber = vc WITH constant("SUBSCRIBER")
 ENDIF
 IF ( NOT (validate(wi_owner_healthplan)))
  DECLARE wi_owner_healthplan = vc WITH constant("HEALTHPLAN")
 ENDIF
 IF ( NOT (validate(wi_owner_advanced)))
  DECLARE wi_owner_advanced = vc WITH constant("ADVANCED")
 ENDIF
 IF ( NOT (validate(wi_owner_wicreator)))
  DECLARE wi_owner_wicreator = vc WITH constant("WICREATOR")
 ENDIF
 IF ( NOT (validate(wi_owner_patient)))
  DECLARE wi_owner_patient = vc WITH constant("PATIENT")
 ENDIF
 IF ( NOT (validate(wi_entity_clinical_encounter)))
  DECLARE wi_entity_clinical_encounter = vc WITH constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(wi_entity_financial_encounter)))
  DECLARE wi_entity_financial_encounter = vc WITH constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(wi_entity_insurance_balance)))
  DECLARE wi_entity_insurance_balance = vc WITH constant("INSURANCE")
 ENDIF
 IF ( NOT (validate(wi_entity_claim)))
  DECLARE wi_entity_claim = vc WITH constant("CLAIM")
 ENDIF
 IF ( NOT (validate(wi_entity_person)))
  DECLARE wi_entity_person = vc WITH constant("PERSON")
 ENDIF
 IF ( NOT (validate(wi_entity_scheduling_event)))
  DECLARE wi_entity_scheduling_event = vc WITH constant("SCHEVENT")
 ENDIF
 IF ( NOT (validate(wi_entity_referral)))
  DECLARE wi_entity_referral = vc WITH constant("REFERRAL")
 ENDIF
 IF ( NOT (validate(wi_entity_billing_entity)))
  DECLARE wi_entity_billing_entity = vc WITH constant("BILL_ENTITY")
 ENDIF
 IF ( NOT (validate(wi_entity_tenant)))
  DECLARE wi_entity_tenant = vc WITH constant("TENANT")
 ENDIF
 IF ( NOT (validate(wi_entity_account)))
  DECLARE wi_entity_account = vc WITH constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(wi_entity_scheduling_entry)))
  DECLARE wi_entity_scheduling_entry = vc WITH constant("SCHENTRY")
 ENDIF
 IF ( NOT (validate(pft_encntr_table)))
  DECLARE pft_encntr_table = vc WITH protect, constant("PFT_ENCNTR")
 ENDIF
 IF ( NOT (validate(bo_hp_reltn_table)))
  DECLARE bo_hp_reltn_table = vc WITH protect, constant("BO_HP_RELTN")
 ENDIF
 IF ( NOT (validate(encounter_table)))
  DECLARE encounter_table = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(person_table)))
  DECLARE person_table = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(bill_rec_table)))
  DECLARE bill_rec_table = vc WITH protect, constant("BILL_REC")
 ENDIF
 IF ( NOT (validate(pft_line_item_table)))
  DECLARE pft_line_item_table = vc WITH protect, constant("PFT_LINE_ITEM")
 ENDIF
 IF ( NOT (validate(sch_event_table)))
  DECLARE sch_event_table = vc WITH protect, constant("SCH_EVENT")
 ENDIF
 IF ( NOT (validate(referral_ext_table)))
  DECLARE referral_ext_table = vc WITH protect, constant("REFERRAL_EXT")
 ENDIF
 IF ( NOT (validate(billing_entity_table)))
  DECLARE billing_entity_table = vc WITH protect, constant("BILLING_ENTITY")
 ENDIF
 IF ( NOT (validate(logical_domain_table)))
  DECLARE logical_domain_table = vc WITH protect, constant("LOGICAL_DOMAIN")
 ENDIF
 IF ( NOT (validate(account_table)))
  DECLARE account_table = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(pft_charge_table)))
  DECLARE pft_charge_table = vc WITH protect, constant("PFT_CHARGE")
 ENDIF
 IF ( NOT (validate(code_value_table)))
  DECLARE code_value_table = vc WITH protect, constant("CODE_VALUE")
 ENDIF
 IF ( NOT (validate(organization_table)))
  DECLARE organization_table = vc WITH protect, constant("ORGANIZATION")
 ENDIF
 IF ( NOT (validate(sch_entry_table)))
  DECLARE sch_entry_table = vc WITH protect, constant("SCH_ENTRY")
 ENDIF
 DECLARE identified_flag = i2 WITH protect, constant(1)
 DECLARE approved_flag = i2 WITH protect, constant(2)
 DECLARE denied_flag = i2 WITH protect, constant(3)
 DECLARE resolved_flag = i2 WITH protect, constant(4)
 DECLARE completed_flag = i2 WITH protect, constant(5)
 DECLARE incompleted_flag = i2 WITH protect, constant(6)
 DECLARE cancelled_flag = i2 WITH protect, constant(7)
 DECLARE reassign_flag = i2 WITH protect, constant(8)
 DECLARE no_action_flag = i2 WITH protect, constant(9)
 DECLARE follow_up_flag = i2 WITH protect, constant(10)
 DECLARE out_of_office_flag = i2 WITH protect, constant(11)
 IF ( NOT (validate(wi_action_identified)))
  DECLARE wi_action_identified = vc WITH protect, constant("IDENTIFIED")
 ENDIF
 IF ( NOT (validate(wi_action_approve)))
  DECLARE wi_action_approve = vc WITH protect, constant("APPROVE")
 ENDIF
 IF ( NOT (validate(wi_action_deny)))
  DECLARE wi_action_deny = vc WITH protect, constant("DENY")
 ENDIF
 IF ( NOT (validate(wi_action_resolve)))
  DECLARE wi_action_resolve = vc WITH protect, constant("RESOLVE")
 ENDIF
 IF ( NOT (validate(wi_action_complete)))
  DECLARE wi_action_complete = vc WITH protect, constant("COMPLETE")
 ENDIF
 IF ( NOT (validate(wi_action_incomplete)))
  DECLARE wi_action_incomplete = vc WITH protect, constant("INCOMPLETE")
 ENDIF
 IF ( NOT (validate(wi_action_cancelled)))
  DECLARE wi_action_cancelled = vc WITH protect, constant("CANCELLED")
 ENDIF
 IF ( NOT (validate(wi_no_action)))
  DECLARE wi_no_action = vc WITH protect, constant("NOACTION")
 ENDIF
 DECLARE assessment_flag = i2 WITH protect, constant(1)
 DECLARE resolution_flag = i2 WITH protect, constant(2)
 DECLARE review_flag = i2 WITH protect, constant(3)
 DECLARE systemuser_group_id = f8 WITH protect, constant(1.0)
 DECLARE pfs_dept_id = f8 WITH protect, constant(2.0)
 DECLARE personnel_group_id = f8 WITH protect, constant(3.0)
 IF ( NOT (validate(pfs)))
  DECLARE pfs = vc WITH constant("PFS")
 ENDIF
 IF ( NOT (validate(personnel)))
  DECLARE personnel = vc WITH protect, constant("PERSONNEL")
 ENDIF
 IF ( NOT (validate(system)))
  DECLARE system = vc WITH constant("SYSTEM")
 ENDIF
 IF ( NOT (validate(claim_queue_claim_status)))
  DECLARE claim_queue_claim_status = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(claim_queue_facility)))
  DECLARE claim_queue_facility = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(claim_queue_payer)))
  DECLARE claim_queue_payer = i2 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(claim_queue_encounter_type)))
  DECLARE claim_queue_encounter_type = i2 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(selfpay_queue_balance_status)))
  DECLARE selfpay_queue_balance_status = i2 WITH protect, constant(5)
 ENDIF
 IF ( NOT (validate(insurance_queue_balance_status)))
  DECLARE insurance_queue_balance_status = i2 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(insurance_queue_payer)))
  DECLARE insurance_queue_payer = i2 WITH protect, constant(7)
 ENDIF
 IF ( NOT (validate(encounter_queue_encounter_type)))
  DECLARE encounter_queue_encounter_type = i2 WITH protect, constant(8)
 ENDIF
 IF ( NOT (validate(encounter_queue_fin_class)))
  DECLARE encounter_queue_fin_class = i2 WITH protect, constant(9)
 ENDIF
 IF ( NOT (validate(encounter_queue_facility)))
  DECLARE encounter_queue_facility = i2 WITH protect, constant(10)
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
 IF (validate(isequal,char(128))=char(128))
  SUBROUTINE (isequal(amount1=f8,amount2=f8) =i2)
   DECLARE tmpdiff = f8 WITH private, noconstant(abs((abs(amount1) - abs(amount2))))
   IF (tmpdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(cs14250_patient_meaning)))
  DECLARE cs14250_patient_meaning = vc WITH protect, constant("PATIENT")
 ENDIF
 IF (validate(getpatientbyencounter,char(128))=char(128))
  SUBROUTINE (getpatientbyencounter(pencntrid=f8,prpatientid=f8(ref)) =i2)
    SET prpatientid = 0.0
    SELECT INTO "nl:"
     FROM encounter e
     WHERE e.encntr_id=pencntrid
      AND e.active_ind=true
     DETAIL
      prpatientid = e.person_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpatientbyfinencounter,char(128))=char(128))
  SUBROUTINE (getpatientbyfinencounter(ppftencntrid=f8,prpatientid=f8(ref)) =i2)
    DECLARE encntrid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM pft_encntr pe
     WHERE pe.pft_encntr_id=ppftencntrid
      AND pe.active_ind=true
     DETAIL
      encntrid = pe.encntr_id
     WITH nocounter
    ;end select
    RETURN(getpatientbyencounter(encntrid,prpatientid))
  END ;Subroutine
 ENDIF
 IF (validate(getpatientbyappointment,char(128))=char(128))
  SUBROUTINE (getpatientbyappointment(pscheventid=f8,prpatientid=f8(ref)) =i2)
    SET prpatientid = 0.0
    SELECT INTO "nl:"
     FROM sch_appt sa
     WHERE sa.sch_event_id=pscheventid
      AND sa.role_meaning=cs14250_patient_meaning
      AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND sa.active_ind=true
     DETAIL
      prpatientid = sa.person_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpatientbyschedulingentry,char(128))=char(128))
  SUBROUTINE (getpatientbyschedulingentry(pschentryid=f8,prpatientid=f8(ref)) =i2)
    DECLARE prpatientid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM sch_entry se
     WHERE se.sch_entry_id=pschentryid
      AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND se.active_ind=true
     DETAIL
      prpatientid = se.person_id
     WITH nocounter
    ;end select
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(ownertypescache)))
  RECORD ownertypescache(
    1 isinitialized = i2
    1 ownertypes[*]
      2 ownertypekey = vc
      2 isexternal = i2
      2 isvalidassessor = i2
      2 isvalidresolver = i2
      2 isvalidreviewer = i2
  )
 ENDIF
 IF ( NOT (validate(publishworkfloweventrequest)))
  RECORD publishworkfloweventrequest(
    1 eventlist[*]
      2 entitytypekey = vc
      2 entityid = f8
      2 eventcd = f8
      2 parameters[*]
        3 paramcd = f8
        3 paramvalue = vc
        3 newparamind = i2
        3 doublevalue = f8
        3 stringvalue = vc
        3 datevalue = dq8
        3 parententityname = vc
        3 parententityid = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(workitementitylist)))
  RECORD workitementitylist(
    1 workitementity[*]
      2 workitemid = f8
      2 entityid = f8
      2 entitytypekey = vc
      2 queuename = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(cs23369_wfevent)))
  DECLARE cs23369_wfevent = f8 WITH protect, constant(getcodevalue(23369,"WFEVENT",1))
 ENDIF
 IF ( NOT (validate(cs29322_workitemcrtd)))
  DECLARE cs29322_workitemcrtd = f8 WITH constant(getcodevalue(29322,"WORKITEMCRTD",1))
 ENDIF
 IF ( NOT (validate(cs29322_workitemuptd)))
  DECLARE cs29322_workitemuptd = f8 WITH constant(getcodevalue(29322,"WORKITEMUPTD",1))
 ENDIF
 IF ( NOT (validate(cs29322_workitemrslv)))
  DECLARE cs29322_workitemrslv = f8 WITH constant(getcodevalue(29322,"WORKITEMRSLV",1))
 ENDIF
 IF ( NOT (validate(cs29322_workitemcncl)))
  DECLARE cs29322_workitemcncl = f8 WITH constant(getcodevalue(29322,"WORKITEMCNCL",1))
 ENDIF
 IF ( NOT (validate(cs29320_pftencntr)))
  DECLARE cs29320_pftencntr = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"PFTENCNTR"))
 ENDIF
 IF ( NOT (validate(cs29320_insurance)))
  DECLARE cs29320_insurance = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"INSURANCE"))
 ENDIF
 IF ( NOT (validate(cs29320_clin_encounter)))
  DECLARE cs29320_clin_encounter = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,
    "ENCOUNTER"))
 ENDIF
 IF ( NOT (validate(cs29320_person)))
  DECLARE cs29320_person = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"PERSON"))
 ENDIF
 IF ( NOT (validate(cs29320_claim)))
  DECLARE cs29320_claim = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"CLAIM"))
 ENDIF
 IF ( NOT (validate(cs29320_schevent)))
  DECLARE cs29320_schevent = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"SCHEVENT"))
 ENDIF
 IF ( NOT (validate(cs29320_schentry)))
  DECLARE cs29320_schentry = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"SCHENTRY"))
 ENDIF
 IF ( NOT (validate(cs29320_referral)))
  DECLARE cs29320_referral = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"REFERRAL"))
 ENDIF
 IF ( NOT (validate(cs29320_tenant)))
  DECLARE cs29320_tenant = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"TENANT"))
 ENDIF
 IF ( NOT (validate(cs29320_bill_entity)))
  DECLARE cs29320_bill_entity = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,
    "BILL_ENTITY"))
 ENDIF
 IF ( NOT (validate(cs29320_account)))
  DECLARE cs29320_account = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"ACCOUNT"))
 ENDIF
 IF ( NOT (validate(cs29320_selfpay)))
  DECLARE cs29320_selfpay = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"SELFPAY"))
 ENDIF
 IF ( NOT (validate(cs29320_transbatch)))
  DECLARE cs29320_transbatch = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"TRANSBATCH"
    ))
 ENDIF
 IF ( NOT (validate(cs29320_image)))
  DECLARE cs29320_image = f8 WITH protect, constant(uar_get_code_by("MEANING",29320,"IMAGE"))
 ENDIF
 IF ( NOT (validate(cs24454_wfqueuename)))
  DECLARE cs24454_wfqueuename = f8 WITH constant(getcodevalue(24454,"WFQUEUENAME",1))
 ENDIF
 IF ( NOT (validate(pft_queue_item)))
  DECLARE pft_queue_item = vc WITH protect, constant("PFT_QUEUE_ITEM")
 ENDIF
 IF ( NOT (validate(insurance_type_key)))
  DECLARE insurance_type_key = vc WITH protect, constant("INSURANCE")
 ENDIF
 IF (validate(isvalidworkitementitytype,char(128))=char(128))
  SUBROUTINE (isvalidworkitementitytype(pentitytype=vc) =i2)
    DECLARE isvalid = i2 WITH protect, noconstant(false)
    IF (pentitytype IN (wi_entity_clinical_encounter, wi_entity_financial_encounter,
    wi_entity_insurance_balance, wi_entity_claim, wi_entity_person,
    wi_entity_scheduling_event, wi_entity_referral, wi_entity_billing_entity, wi_entity_tenant,
    wi_entity_account,
    wi_entity_scheduling_entry))
     SET isvalid = true
    ENDIF
    RETURN(isvalid)
  END ;Subroutine
 ENDIF
 IF (validate(parententitynametowientity,char(128))=char(128))
  SUBROUTINE (parententitynametowientity(pparententityname=vc) =vc)
    RETURN(evaluate(pparententityname,pft_encntr_table,wi_entity_financial_encounter,
     bo_hp_reltn_table,wi_entity_insurance_balance,
     encounter_table,wi_entity_clinical_encounter,person_table,wi_entity_person,bill_rec_table,
     wi_entity_claim,pft_line_item_table,wi_entity_claim,sch_event_table,wi_entity_scheduling_event,
     referral_ext_table,wi_entity_referral,billing_entity_table,wi_entity_billing_entity,
     logical_domain_table,
     wi_entity_tenant,account_table,wi_entity_account,sch_entry_table,wi_entity_scheduling_entry,
     ""))
  END ;Subroutine
 ENDIF
 IF (validate(isvalidassessortype,char(128))=char(128))
  SUBROUTINE (isvalidassessortype(pownertype=vc) =i2)
    RETURN(isvalidownertypeforrole(pownertype,wi_role_assessor))
  END ;Subroutine
 ENDIF
 IF (validate(initializeownertypescache,char(128))=char(128))
  SUBROUTINE (initializeownertypescache(null=i2) =i2)
    DECLARE index = i4 WITH protect, noconstant(0)
    DECLARE ownertypecount = i4 WITH protect, noconstant(0)
    FREE RECORD retrieveownertypesrequest
    RECORD retrieveownertypesrequest(
      1 role = vc
    )
    FREE RECORD retrieveownertypesreply
    RECORD retrieveownertypesreply(
      1 ownertypes[*]
        2 ownertypeid = f8
        2 ownertypekey = vc
        2 ownertypedisplay = vc
        2 isexternal = i2
        2 isvalidassessor = i2
        2 isvalidresolver = i2
        2 isvalidreviewer = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    EXECUTE pft_r_work_item_owner_type  WITH replace("REQUEST",retrieveownertypesrequest), replace(
     "REPLY",retrieveownertypesreply)
    IF ((retrieveownertypesreply->status_data.status="F"))
     CALL logmessage("retrieveOwnerTypesRequest","Failed to retrieve owner types",log_error)
     RETURN(false)
    ENDIF
    SET ownertypecount = size(retrieveownertypesreply->ownertypes,5)
    SET stat = alterlist(ownertypescache->ownertypes,ownertypecount)
    FOR (index = 1 TO ownertypecount)
      SET ownertypescache->ownertypes[index].ownertypekey = retrieveownertypesreply->ownertypes[index
      ].ownertypekey
      SET ownertypescache->ownertypes[index].isexternal = retrieveownertypesreply->ownertypes[index].
      isexternal
      SET ownertypescache->ownertypes[index].isvalidassessor = retrieveownertypesreply->ownertypes[
      index].isvalidassessor
      SET ownertypescache->ownertypes[index].isvalidresolver = retrieveownertypesreply->ownertypes[
      index].isvalidresolver
      SET ownertypescache->ownertypes[index].isvalidreviewer = retrieveownertypesreply->ownertypes[
      index].isvalidreviewer
    ENDFOR
    SET ownertypescache->isinitialized = true
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(isvalidresolvertype,char(128))=char(128))
  SUBROUTINE (isvalidresolvertype(pownertype=vc) =i2)
    RETURN(isvalidownertypeforrole(pownertype,wi_role_resolver))
  END ;Subroutine
 ENDIF
 IF (validate(isvalidreviewertype,char(128))=char(128))
  SUBROUTINE (isvalidreviewertype(pownertype=vc) =i2)
    RETURN(isvalidownertypeforrole(pownertype,wi_role_reviewer))
  END ;Subroutine
 ENDIF
 IF (validate(isvalidownertypeforrole,char(128))=char(128))
  SUBROUTINE (isvalidownertypeforrole(pownertype=vc,prole=vc) =i2)
    DECLARE isvalid = i2 WITH protect, noconstant(false)
    DECLARE index = i4 WITH protect, noconstant(0)
    IF ( NOT (ownertypescache->isinitialized))
     IF ( NOT (initializeownertypescache(0)))
      CALL logmessage("isValidOwnerType","Failed to retrieve valid owner types",log_error)
      RETURN(false)
     ENDIF
    ENDIF
    SET index = locateval(index,1,size(ownertypescache->ownertypes,5),pownertype,ownertypescache->
     ownertypes[index].ownertypekey)
    IF (index > 0)
     IF (((prole=wi_role_assessor
      AND ownertypescache->ownertypes[index].isvalidassessor) OR (((prole=wi_role_resolver
      AND ownertypescache->ownertypes[index].isvalidresolver) OR (prole=wi_role_reviewer
      AND ownertypescache->ownertypes[index].isvalidreviewer)) )) )
      SET isvalid = true
     ENDIF
    ENDIF
    RETURN(isvalid)
  END ;Subroutine
 ENDIF
 IF (validate(isexternalresolvertype,char(128))=char(128))
  SUBROUTINE (isexternalresolvertype(presolvertype=vc) =i2)
    DECLARE isexternal = i2 WITH protect, noconstant(false)
    DECLARE index = i4 WITH protect, noconstant(0)
    IF ( NOT (isvalidresolvertype(presolvertype)))
     CALL logmessage("isExternalResolverType",build2("Invalid resolver type specified: ",
       presolvertype),log_error)
     RETURN(false)
    ENDIF
    SET index = locateval(index,1,size(ownertypescache->ownertypes,5),presolvertype,ownertypescache->
     ownertypes[index].ownertypekey)
    IF (index > 0)
     SET isexternal = ownertypescache->ownertypes[index].isexternal
    ENDIF
    RETURN(isexternal)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorforentity,char(128))=char(128))
  SUBROUTINE (getguarantorforentity(pentitytype=vc,pentityid=f8,prguarantorid=f8(ref)) =i2)
    SET prguarantorid = 0.0
    CASE (pentitytype)
     OF wi_entity_clinical_encounter:
      RETURN(getguarantorbyencounter(pentityid,prguarantorid))
     OF wi_entity_financial_encounter:
      RETURN(getguarantorbyfinencounter(pentityid,prguarantorid))
     OF wi_entity_insurance_balance:
      RETURN(getguarantorbybalance(pentityid,prguarantorid))
     OF wi_entity_claim:
      RETURN(getguarantorbyclaim(pentityid,prguarantorid))
     OF wi_entity_scheduling_event:
      RETURN(getguarantorbyappointment(pentityid,prguarantorid))
     OF wi_entity_scheduling_entry:
      RETURN(getguarantorbyschedulingentry(pentityid,prguarantorid))
     OF wi_entity_person:
      RETURN(getguarantoratpatientlevel(pentityid,prguarantorid))
    ENDCASE
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbyclaim,char(128))=char(128))
  SUBROUTINE (getguarantorbyclaim(pentityid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE relatedfinancialencounterid = f8 WITH protect, noconstant(0.00)
    SELECT INTO "nl:"
     FROM bill_rec brec,
      bill_reltn br,
      bo_hp_reltn bhr,
      benefit_order bo
     PLAN (brec
      WHERE brec.corsp_activity_id=pentityid)
      JOIN (br
      WHERE br.corsp_activity_id=brec.corsp_activity_id
       AND br.parent_entity_name="BO_HP_RELTN"
       AND br.active_ind=true)
      JOIN (bhr
      WHERE bhr.bo_hp_reltn_id=br.parent_entity_id
       AND bhr.active_ind=true)
      JOIN (bo
      WHERE bo.benefit_order_id=bhr.benefit_order_id
       AND bo.active_ind=true)
     DETAIL
      relatedfinancialencounterid = bo.pft_encntr_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(false)
    ENDIF
    RETURN(getguarantorbyfinencounter(relatedfinancialencounterid,prguarantorid))
  END ;Subroutine
 ENDIF
 IF (validate(getguarantorbybalance,char(128))=char(128))
  SUBROUTINE (getguarantorbybalance(pentityid=f8,prguarantorid=f8(ref)) =i2)
    DECLARE relatedfinancialencounterid = f8 WITH protect, noconstant(0.00)
    SELECT INTO "nl:"
     FROM bo_hp_reltn bhr,
      benefit_order bo
     PLAN (bhr
      WHERE bhr.bo_hp_reltn_id=pentityid
       AND bhr.active_ind=true)
      JOIN (bo
      WHERE bo.benefit_order_id=bhr.benefit_order_id
       AND bo.active_ind=true)
     DETAIL
      relatedfinancialencounterid = bo.pft_encntr_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(false)
    ENDIF
    RETURN(getguarantorbyfinencounter(relatedfinancialencounterid,prguarantorid))
  END ;Subroutine
 ENDIF
 IF (validate(getsubscriberforentity,char(128))=char(128))
  SUBROUTINE (getsubscriberforentity(pentityid=f8,prsubscriberid=f8(ref)) =i2)
    IF ( NOT (validate(cs351_insured_cd)))
     DECLARE cs351_insured_cd = f8 WITH protect, constant(getcodevalue(351,"INSURED",1))
    ENDIF
    SELECT INTO "nl:"
     FROM bo_hp_reltn bhr,
      encntr_plan_reltn epr,
      encntr_person_reltn epr2
     PLAN (bhr
      WHERE bhr.bo_hp_reltn_id=pentityid
       AND bhr.active_ind=true)
      JOIN (epr
      WHERE epr.encntr_plan_reltn_id=bhr.encntr_plan_reltn_id
       AND epr.active_ind=true)
      JOIN (epr2
      WHERE epr2.encntr_id=epr.encntr_id
       AND epr2.related_person_id=epr.person_id
       AND epr2.person_reltn_type_cd=cs351_insured_cd
       AND epr2.active_ind=true)
     ORDER BY epr2.beg_effective_dt_tm
     HEAD epr.encntr_plan_reltn_id
      null
     DETAIL
      null
     FOOT  epr.encntr_plan_reltn_id
      prsubscriberid = epr.person_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(true)
    ELSE
     SELECT INTO "nl:"
      FROM bill_rec br,
       bill_reltn brl,
       bo_hp_reltn bhr,
       encntr_plan_reltn epr,
       encntr_person_reltn epr2
      PLAN (br
       WHERE br.corsp_activity_id=pentityid)
       JOIN (brl
       WHERE brl.corsp_activity_id=br.corsp_activity_id
        AND brl.parent_entity_name="BO_HP_RELTN"
        AND brl.bill_vrsn_nbr=br.bill_vrsn_nbr)
       JOIN (bhr
       WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
        AND bhr.active_ind=true)
       JOIN (epr
       WHERE epr.encntr_plan_reltn_id=bhr.encntr_plan_reltn_id
        AND epr.active_ind=true)
       JOIN (epr2
       WHERE epr2.encntr_id=epr.encntr_id
        AND epr2.related_person_id=epr.person_id
        AND epr2.active_ind=true)
      ORDER BY epr2.beg_effective_dt_tm
      HEAD epr.encntr_plan_reltn_id
       null
      DETAIL
       null
      FOOT  epr.encntr_plan_reltn_id
       prsubscriberid = epr.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (curqual > 0)
     RETURN(true)
    ENDIF
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(gethealthplanforentity,char(128))=char(128))
  SUBROUTINE (gethealthplanforentity(pentityid=f8,prhealthplanid=f8(ref)) =i2)
    IF ( NOT (validate(cs351_insured_cd)))
     DECLARE cs351_insured_cd = f8 WITH protect, constant(getcodevalue(351,"INSURED",1))
    ENDIF
    SELECT INTO "nl:"
     FROM bo_hp_reltn bhr,
      encntr_plan_reltn epr,
      encntr_person_reltn epr2
     PLAN (bhr
      WHERE bhr.bo_hp_reltn_id=pentityid
       AND bhr.active_ind=true)
      JOIN (epr
      WHERE epr.encntr_plan_reltn_id=bhr.encntr_plan_reltn_id
       AND epr.active_ind=true)
      JOIN (epr2
      WHERE epr2.encntr_id=epr.encntr_id
       AND epr2.related_person_id=epr.person_id
       AND epr2.person_reltn_type_cd=cs351_insured_cd
       AND epr2.active_ind=true)
     ORDER BY epr2.beg_effective_dt_tm
     HEAD epr.encntr_plan_reltn_id
      null
     DETAIL
      null
     FOOT  epr.encntr_plan_reltn_id
      prhealthplanid = epr.health_plan_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(true)
    ELSE
     SELECT INTO "nl:"
      FROM bill_rec br,
       bill_reltn brl,
       bo_hp_reltn bhr
      PLAN (br
       WHERE br.corsp_activity_id=pentityid)
       JOIN (brl
       WHERE brl.corsp_activity_id=br.corsp_activity_id
        AND brl.parent_entity_name="BO_HP_RELTN"
        AND brl.bill_vrsn_nbr=br.bill_vrsn_nbr)
       JOIN (bhr
       WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
        AND bhr.active_ind=true)
      DETAIL
       prhealthplanid = bhr.health_plan_id
      WITH nocounter
     ;end select
    ENDIF
    IF (curqual > 0)
     RETURN(true)
    ENDIF
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(getpatientforentity,char(128))=char(128))
  SUBROUTINE (getpatientforentity(pentitytype=vc,pentityid=f8,prpatientid=f8(ref)) =i2)
    SET prpatientid = 0.0
    CASE (pentitytype)
     OF wi_entity_clinical_encounter:
      RETURN(getpatientbyencounter(pentityid,prpatientid))
     OF wi_entity_financial_encounter:
      RETURN(getpatientbyfinencounter(pentityid,prpatientid))
     OF wi_entity_person:
      SET prpatientid = pentityid
     OF wi_entity_scheduling_event:
      RETURN(getpatientbyappointment(pentityid,prpatientid))
     OF wi_entity_scheduling_entry:
      RETURN(getpatientbyschedulingentry(pentityid,prpatientid))
    ENDCASE
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(determineexternalresolver,char(128))=char(128))
  SUBROUTINE (determineexternalresolver(pentitytype=vc,pentityid=f8,presolvertype=vc,prresolverid=f8(
    ref)) =i2)
    IF ( NOT (isvalidworkitementitytype(pentitytype)))
     CALL logmessage("determineExternalResolver",build2("Invalid entity type specified: ",pentitytype
       ),log_error)
     RETURN(false)
    ENDIF
    IF (pentityid <= 0.0
     AND pentitytype != wi_entity_tenant)
     CALL logmessage("determineExternalResolver",build2("Invalid entity ID specified: ",pentityid),
      log_error)
     RETURN(false)
    ENDIF
    IF ( NOT (isexternalresolvertype(presolvertype)))
     CALL logmessage("determineExternalResolver",build2("Invalid external resolver type specified: ",
       presolvertype),log_error)
     RETURN(false)
    ENDIF
    SET prresolverid = 0.0
    CASE (presolvertype)
     OF wi_owner_guarantor:
      RETURN(getguarantorforentity(pentitytype,pentityid,prresolverid))
     OF wi_owner_subscriber:
      RETURN(getsubscriberforentity(pentityid,prresolverid))
     OF wi_owner_healthplan:
      RETURN(gethealthplanforentity(pentityid,prresolverid))
     OF wi_owner_patient:
      RETURN(getpatientforentity(pentitytype,pentityid,prresolverid))
    ENDCASE
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpersonname,char(128))=char(128))
  SUBROUTINE (getpersonname(ppersonid=f8,prname=vc(ref)) =i2)
    SET prname = ""
    SELECT INTO "nl:"
     FROM person p
     WHERE person_id=ppersonid
     DETAIL
      prname = p.name_full_formatted
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmessage("getPersonName",build2("Invalid person specified: ",ppersonid),log_error)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getdepartmentname,char(128))=char(128))
  SUBROUTINE (getdepartmentname(pdepartmentid=f8,prname=vc(ref)) =i2)
    SET prname = ""
    SELECT INTO "nl:"
     FROM prsnl_group p
     WHERE p.prsnl_group_id=pdepartmentid
     DETAIL
      prname = p.prsnl_group_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmessage("getDepartmentName",build2("Invalid department specified: ",pdepartmentid),
      log_error)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(gethealthplanname,char(128))=char(128))
  SUBROUTINE (gethealthplanname(phealthplanid=f8,prname=vc(ref)) =i2)
    SET prname = ""
    SELECT INTO "nl:"
     FROM health_plan hp
     WHERE hp.health_plan_id=phealthplanid
     DETAIL
      prname = hp.plan_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmessage("getHealthPlanName",build2("Invalid health plan specified: ",phealthplanid),
      log_error)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getadvancedrulename,char(128))=char(128))
  SUBROUTINE (getadvancedrulename(passignmentid=f8,prname=vc(ref)) =i2)
    SET prname = ""
    SELECT INTO "nl:"
     FROM pft_assignment_rule par
     WHERE par.pft_assignment_rule_id=passignmentid
     DETAIL
      prname = par.assignment_rule_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmessage("getAdvancedRuleName",build2("Invalid Assignment Id specified: ",passignmentid),
      log_error)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getworkitemownername,char(128))=char(128))
  SUBROUTINE (getworkitemownername(pownertype=vc,pownerid=f8,prname=vc(ref)) =i2)
    SET prname = ""
    CASE (pownertype)
     OF wi_owner_guarantor:
     OF wi_owner_personnel:
     OF wi_owner_subscriber:
     OF wi_owner_patient:
      RETURN(getpersonname(pownerid,prname))
     OF wi_owner_department:
      RETURN(getdepartmentname(pownerid,prname))
     OF wi_owner_healthplan:
      RETURN(gethealthplanname(pownerid,prname))
     OF wi_owner_advanced:
      RETURN(getadvancedrulename(pownerid,prname))
    ENDCASE
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(entityhadworkitem,char(128))=char(128))
  SUBROUTINE (entityhadworkitem(pentityid=f8,pentitytype=vc,pworkitemid=f8) =i2)
    CALL logmessage("entityHadWorkItem","Entering...",log_debug)
    DECLARE hadworkitem = i2 WITH protect, noconstant(false)
    DECLARE entityparser = vc WITH protect, noconstant("")
    IF (entityhasworkitem(pentityid,pentitytype,pworkitemid))
     CALL logmessage("entityHadWorkItem","Entity currently has work items that are not completed",
      log_debug)
     RETURN(false)
    ENDIF
    IF (pentitytype=wi_entity_clinical_encounter)
     SET entityparser = concat("pq.encntr_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_financial_encounter)
     SET entityparser = concat("pq.pft_encntr_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_insurance_balance)
     SET entityparser = concat("pq.bo_hp_reltn_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_claim)
     SET entityparser = concat("pq.corsp_activity_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_scheduling_event)
     SET entityparser = concat("pq.sch_event_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_referral)
     SET entityparser = concat("pq.referral_ext_ident = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_person)
     SET entityparser = concat("pq.person_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_tenant)
     SET entityparser = concat("pq.logical_domain_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_billing_entity)
     SET entityparser = concat("pq.billing_entity_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_account)
     SET entityparser = concat("pq.acct_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_scheduling_entry)
     SET entityparser = concat("pq.sch_entry_id = ",cnvtstring(pentityid,17,3))
    ENDIF
    SELECT INTO "nl:"
     FROM pft_queue_item_hist pq,
      pft_wf_issue pi
     PLAN (pi
      WHERE pi.pft_wf_issue_id=pworkitemid)
      JOIN (pq
      WHERE pq.item_status_cd=pi.issue_cd
       AND pq.active_ind=true
       AND parser(entityparser))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET hadworkitem = true
    ENDIF
    CALL logmessage("entityHadWorkItem","Exiting...",log_debug)
    RETURN(hadworkitem)
  END ;Subroutine
 ENDIF
 IF (validate(entityhasworkitem,char(128))=char(128))
  SUBROUTINE (entityhasworkitem(pentityid=f8,pentitytype=vc,pworkitemid=f8) =i2)
    CALL logmessage("entityHasWorkItem","Entering...",log_debug)
    DECLARE hasworkitem = i2 WITH protect, noconstant(false)
    DECLARE entityparser = vc WITH protect, noconstant("")
    IF (pentitytype=wi_entity_clinical_encounter)
     SET entityparser = concat("pq.encntr_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_financial_encounter)
     SET entityparser = concat("pq.pft_encntr_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_insurance_balance)
     SET entityparser = concat("pq.bo_hp_reltn_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_claim)
     SET entityparser = concat("pq.corsp_activity_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_scheduling_event)
     SET entityparser = concat("pq.sch_event_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_referral)
     SET entityparser = concat("pq.referral_ext_ident = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_person)
     SET entityparser = concat("pq.person_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_tenant)
     SET entityparser = concat("pq.logical_domain_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_billing_entity)
     SET entityparser = concat("pq.billing_entity_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_account)
     SET entityparser = concat("pq.acct_id = ",cnvtstring(pentityid,17,3))
    ELSEIF (pentitytype=wi_entity_scheduling_entry)
     SET entityparser = concat("pq.sch_entry_id = ",cnvtstring(pentityid,17,3))
    ENDIF
    SELECT INTO "nl:"
     FROM pft_queue_item pq,
      pft_wf_issue pi
     PLAN (pq
      WHERE pq.active_ind=true
       AND parser(entityparser))
      JOIN (pi
      WHERE pi.issue_cd=pq.item_status_cd
       AND pi.pft_wf_issue_id=pworkitemid)
    ;end select
    IF (curqual > 0)
     SET hasworkitem = true
    ENDIF
    CALL logmessage("entityHasWorkItem","Exiting...",log_debug)
    RETURN(hasworkitem)
  END ;Subroutine
 ENDIF
 IF (validate(entityhasclaimworkitem,char(128))=char(128))
  SUBROUTINE (entityhasclaimworkitem(pentityid=f8,pentitytype=vc,pworkflowitemid=f8) =i2)
    CALL logmessage("entityHasClaimWorkItem","Entering...",log_debug)
    DECLARE hasworkitem = i2 WITH protect, noconstant(false)
    IF (pentitytype=wi_entity_insurance_balance)
     SELECT INTO "nl:"
      FROM bo_hp_reltn bohp,
       bill_reltn brl,
       bill_rec br,
       pft_queue_item pqi,
       pft_queue_item_wf_hist pqiwh
      PLAN (bohp
       WHERE bohp.bo_hp_reltn_id=pentityid)
       JOIN (brl
       WHERE brl.parent_entity_id=bohp.bo_hp_reltn_id
        AND brl.parent_entity_name="BO_HP_RELTN")
       JOIN (br
       WHERE br.corsp_activity_id=brl.corsp_activity_id)
       JOIN (pqi
       WHERE pqi.corsp_activity_id=br.corsp_activity_id
        AND pqi.active_ind=true)
       JOIN (pqiwh
       WHERE pqiwh.parent_entity_id=br.corsp_activity_id
        AND pqiwh.parent_entity_name="BILL_REC"
        AND pqiwh.pft_queue_item_id != pworkflowitemid)
      HEAD pqiwh.pft_queue_item_id
       hasworkitem = true
      WITH nocounter
     ;end select
    ELSEIF (pentitytype=wi_entity_claim)
     SELECT INTO "nl:"
      FROM pft_queue_item_wf_hist pqiwh
      PLAN (pqiwh
       WHERE pqiwh.parent_entity_id=pentityid
        AND pqiwh.parent_entity_name="BILL_REC"
        AND pqiwh.pft_queue_item_id != pworkflowitemid)
      HEAD pqiwh.pft_queue_item_id
       hasworkitem = true
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("entityHasClaimWorkItem","Exiting...",log_debug)
    RETURN(hasworkitem)
  END ;Subroutine
 ENDIF
 SUBROUTINE containsworkflowitem(workflowitemid,workflowitemhaswi)
   DECLARE hasworkitemind = i2 WITH protect, noconstant(false)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET locindex = locateval(idx,1,size(workflowitemhaswi->array,5),workflowitemid,workflowitemhaswi->
    array[idx].workflowitemid)
   IF (locindex > 0)
    SET hasworkitemind = true
   ENDIF
   CALL logmessage("containsWorkFlowItem:",build("workFlowItemId: ",workflowitemid,"-",hasworkitemind
     ),log_debug)
   RETURN(hasworkitemind)
 END ;Subroutine
 SUBROUTINE getamountforcontvar(claimid,varianceamt)
   CALL logmessage("getAmountForContVar","Entering",log_debug)
   DECLARE contvaramount = f8 WITH protect, noconstant(0.0)
   IF ( NOT (isequal(varianceamt,0.0)))
    SET contvaramount = varianceamt
   ELSE
    SELECT INTO "nl:"
     FROM pft_line_item pli
     PLAN (pli
      WHERE pli.corsp_activity_id=claimid)
     DETAIL
      contvaramount += pli.variance_amt
     WITH nocounter
    ;end select
   ENDIF
   RETURN(contvaramount)
 END ;Subroutine
 SUBROUTINE getamountforclaimworkitem(workitemid,workitemamt)
   CALL logmessage("getAmountForClaimWorkItem","Entering",log_debug)
   DECLARE claimworkitemamt = f8 WITH protect, noconstant(0.0)
   IF ( NOT (validate(cs29322_calcadjpost)))
    DECLARE cs29322_calcadjpost = f8 WITH protect, constant(getcodevalue(29322,"CALCADJPOST",1))
   ENDIF
   SELECT INTO "nl:"
    FROM pft_queue_item pqi,
     pft_queue_item_wf_hist pqiwh,
     pft_queue_item_wf_reltn pqiwr,
     pft_line_item pli
    PLAN (pqi
     WHERE pqi.pft_queue_item_id=workitemid
      AND pqi.event_cd != cs29322_calcadjpost
      AND pqi.active_ind=true)
     JOIN (pqiwh
     WHERE pqiwh.pft_queue_item_id=pqi.pft_queue_item_id
      AND pqiwh.active_ind=true)
     JOIN (pqiwr
     WHERE pqiwr.pft_queue_item_wf_hist_id=pqiwh.pft_queue_item_wf_hist_id
      AND pqiwr.parent_entity_name=pft_line_item_table
      AND pqiwr.parent_entity_id != 0.00)
     JOIN (pli
     WHERE pli.pft_line_item_id=pqiwr.parent_entity_id)
    DETAIL
     claimworkitemamt = pli.variance_amt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET claimworkitemamt = workitemamt
   ENDIF
   RETURN(claimworkitemamt)
 END ;Subroutine
 IF (validate(checkforexcludedactioncode,char(128))=char(128))
  SUBROUTINE (checkforexcludedactioncode(pactioncode=f8,prisactioncodeexcluded=i2(ref)) =i2)
    CALL logmessage("checkForExcludedActionCode","Entering",log_debug)
    DECLARE actionjson = vc WITH protect, noconstant(" ")
    DECLARE noerrorhasoccurred = i2 WITH protect, noconstant(true)
    SELECT INTO "nl:"
     FROM long_text_reference ltr
     PLAN (ltr
      WHERE ltr.parent_entity_name="CODE_VALUE"
       AND ltr.parent_entity_id=pactioncode
       AND ltr.active_ind=true)
     DETAIL
      actionjson = ltr.long_text
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET stat = cnvtjsontorec(actionjson)
     IF (stat=0)
      CALL logmessage("checkForExcludedActionCode",
       "Error: Unable to convert JSON string to ACTION structure",log_error)
      SET noerrorhasoccurred = false
     ELSE
      IF ( NOT (validate(action)))
       CALL logmessage("checkForExcludedActionCode","Error: Missing ACTION",log_error)
       SET noerrorhasoccurred = false
      ELSEIF ( NOT (validate(action->name)))
       CALL logmessage("checkForExcludedActionCode","Error: Missing ACTION->name",log_error)
       SET noerrorhasoccurred = false
      ELSEIF ( NOT (validate(action->actionkey)))
       CALL logmessage("checkForExcludedActionCode","Error: Missing ACTION->actionKey",log_error)
       SET noerrorhasoccurred = false
      ELSEIF ( NOT (validate(action->adapter)))
       CALL logmessage("checkForExcludedActionCode","Error: Missing ACTION->adapter",log_error)
       SET noerrorhasoccurred = false
      ENDIF
      IF (noerrorhasoccurred)
       IF ((action->actionkey IN ("REPRICE_CLAIM")))
        SET prisactioncodeexcluded = true
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    CALL logmessage("checkForExcludedActionCode","Exiting...",log_debug)
    RETURN(noerrorhasoccurred)
  END ;Subroutine
 ENDIF
 IF (validate(publishworkfloweventfactory,char(128))=char(128))
  SUBROUTINE (publishworkfloweventfactory(prscriptrequest=vc(ref)) =null)
    CALL logmessage("publishWorkflowEventFactory","Entering...",log_debug)
    DECLARE entitytypekey = vc WITH noconstant(""), protect
    DECLARE entityid = f8 WITH noconstant(0), protect
    DECLARE eventcd = f8 WITH noconstant(0), protect
    DECLARE eventoccurid = f8 WITH noconstant(0), protect
    DECLARE eventidx = i4 WITH noconstant(0), protect
    DECLARE stringvalue = vc WITH noconstant(""), protect
    DECLARE paramcd = f8 WITH noconstant(0), protect
    DECLARE parententityid = f8 WITH noconstant(0), protect
    DECLARE parententityname = vc WITH noconstant(""), protect
    IF (size(prscriptrequest,5) > 0)
     FOR (eventidx = 1 TO size(prscriptrequest->eventlist,5))
       SET entitytypekey = prscriptrequest->eventlist[eventidx].entitytypekey
       SET eventcd = prscriptrequest->eventlist[eventidx].eventcd
       SET entityid = prscriptrequest->eventlist[eventidx].entityid
       SET stringvalue = prscriptrequest->eventlist[eventidx].parameters[1].stringvalue
       SET parententityid = prscriptrequest->eventlist[eventidx].parameters[1].parententityid
       SET parententityname = prscriptrequest->eventlist[eventidx].parameters[1].parententityname
       SET paramcd = prscriptrequest->eventlist[eventidx].parameters[1].paramcd
       IF (entitytypekey != ""
        AND entityid > 0
        AND eventcd > 0)
        IF (entitytypekey=insurance_type_key
         AND ((eventcd=cs29322_workitemcrtd) OR (eventcd=cs29322_workitemrslv))
         AND paramcd=cs24454_wfqueuename
         AND ((stringvalue="At Risk Claim") OR (stringvalue="Past Due")) )
         SET eventoccurid = savecommonworklistworkflowevent(prscriptrequest,eventidx)
         IF (eventoccurid != 0)
          IF (shouldeventbebridged(eventcd))
           CALL prepareforeventbridging(prscriptrequest,eventidx,eventoccurid)
          ELSE
           CALL logmessage("publishWorkflowEventFactory","shouldEventBeBridged() returned false.",
            log_error)
          ENDIF
         ELSE
          CALL logmessage("publishWorkflowEventFactory",
           "Publishing failed - eventOccurId is equals to 0.",log_error)
         ENDIF
        ENDIF
       ELSE
        CALL logmessage("publishWorkflowEventFactory",
         "entityTypeKey, entityId, and eventCd should be populated to publish the event.",log_error)
       ENDIF
     ENDFOR
    ENDIF
    CALL logmessage("publishWorkflowEventFactory","Exiting...",log_debug)
  END ;Subroutine
 ENDIF
 IF (validate(populateentitydetailsforworkitems,char(128))=char(128))
  SUBROUTINE (populateentitydetailsforworkitems(prworkitementitylist=vc(ref)) =null)
    CALL logmessage("populateEntityDetailsForWorkItems","Entering...",log_debug)
    DECLARE entitytypekey = vc WITH noconstant(""), protect
    DECLARE entityid = f8 WITH noconstant(0), protect
    IF (validate(prworkitementitylist)
     AND size(prworkitementitylist->workitementity,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(prworkitementitylist->workitementity,5)),
       pft_queue_item q
      PLAN (d)
       JOIN (q
       WHERE (q.pft_queue_item_id=prworkitementitylist->workitementity[d.seq].workitemid)
        AND q.active_ind=true)
      DETAIL
       IF (q.pft_encntr_id > 0.0
        AND q.pft_entity_type_cd=cs29320_pftencntr)
        entityid = q.pft_encntr_id
       ELSEIF (q.bo_hp_reltn_id > 0.0
        AND ((q.pft_entity_type_cd=cs29320_insurance) OR (q.pft_entity_type_cd=cs29320_selfpay)) )
        entityid = q.bo_hp_reltn_id
       ELSEIF (q.encntr_id > 0.0
        AND q.pft_entity_type_cd=cs29320_clin_encounter)
        entityid = q.encntr_id
       ELSEIF (q.person_id > 0.0
        AND q.pft_entity_type_cd=cs29320_person)
        entityid = q.person_id
       ELSEIF (q.corsp_activity_id > 0.0
        AND q.pft_entity_type_cd=cs29320_claim)
        entityid = q.corsp_activity_id
       ELSEIF (q.sch_event_id > 0.0
        AND q.pft_entity_type_cd=cs29320_schevent)
        entityid = q.sch_event_id
       ELSEIF (q.sch_entry_id > 0.0
        AND q.pft_entity_type_cd=cs29320_schentry)
        entityid = q.sch_entry_id
       ELSEIF (q.referral_ext_ident > 0.0
        AND q.pft_entity_type_cd=cs29320_referral)
        entityid = q.referral_ext_ident
       ELSEIF (q.pft_entity_type_cd=cs29320_tenant)
        entityid = q.logical_domain_id
       ELSEIF (q.billing_entity_id > 0.0
        AND q.pft_entity_type_cd=cs29320_bill_entity)
        entityid = q.billing_entity_id
       ELSEIF (q.acct_id > 0.0
        AND q.pft_entity_type_cd=cs29320_account)
        entityid = q.acct_id
       ELSEIF (q.batch_trans_id > 0.0
        AND q.pft_entity_type_cd=cs29320_transbatch)
        entityid = q.batch_trans_id
       ELSEIF (q.blob_ref_id > 0.0
        AND q.pft_entity_type_cd=cs29320_image)
        entityid = q.blob_ref_id
       ENDIF
       entitytypekey = uar_get_code_meaning(q.pft_entity_type_cd)
       IF (entitytypekey != ""
        AND entityid > 0)
        prworkitementitylist->workitementity[d.seq].entityid = entityid, prworkitementitylist->
        workitementity[d.seq].entitytypekey = entitytypekey, prworkitementitylist->workitementity[d
        .seq].queuename = uar_get_code_display(q.pft_entity_status_cd)
       ENDIF
       entityid = 0, entitytypekey = ""
      WITH nocounter
     ;end select
    ENDIF
    CALL logmessage("populateEntityDetailsForWorkItems","Exiting...",log_debug)
  END ;Subroutine
 ENDIF
 IF (validate(savecommonworklistworkflowevent,char(128))=char(128))
  SUBROUTINE (savecommonworklistworkflowevent(prscriptrequest=vc(ref),peventidx=i4) =i2)
    CALL logmessage("saveCommonWorkListWorkflowEvent","Entering...",log_debug)
    RECORD wfeventreq(
      1 eventcd = f8
      1 entityid = f8
      1 entityname = vc
      1 params[*]
        2 paramcd = f8
        2 paramvalue = vc
        2 newparamind = i2
        2 doublevalue = f8
        2 stringvalue = vc
        2 datevalue = dq8
        2 parententityname = vc
        2 parententityid = f8
    ) WITH protect
    RECORD wfeventrep(
      1 pfteventoccurid = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    DECLARE eventoccurid = f8 WITH protect, noconstant(0)
    SET stat = alterlist(wfeventreq->params,1)
    SET wfeventreq->eventcd = prscriptrequest->eventlist[peventidx].eventcd
    SET wfeventreq->entityid = prscriptrequest->eventlist[peventidx].entityid
    SET wfeventreq->entityname = prscriptrequest->eventlist[peventidx].entitytypekey
    IF ((prscriptrequest->eventlist[peventidx].parameters[1].paramcd=cs24454_wfqueuename))
     SET wfeventreq->params[1].paramcd = prscriptrequest->eventlist[peventidx].parameters[1].paramcd
     SET wfeventreq->params[1].stringvalue = prscriptrequest->eventlist[peventidx].parameters[1].
     stringvalue
     SET wfeventreq->params[1].parententityid = prscriptrequest->eventlist[peventidx].parameters[1].
     parententityid
     SET wfeventreq->params[1].parententityname = prscriptrequest->eventlist[eventidx].parameters[1].
     parententityname
     SET wfeventreq->params[1].newparamind = 1
    ENDIF
    EXECUTE pft_r_workflow_event_save  WITH replace("REQUEST",wfeventreq), replace("REPLY",wfeventrep
     )
    IF ((wfeventrep->status_data.status != "S"))
     SET eventoccurid = 0
     CALL logmessage("saveCommonWorkListWorkflowEvent","Error: Failed to save event occurance",
      log_error)
    ELSE
     SET eventoccurid = wfeventrep->pfteventoccurid
     CALL logmessage("saveCommonWorkListWorkflowEvent","Exiting...",log_debug)
    ENDIF
    RETURN(eventoccurid)
  END ;Subroutine
 ENDIF
 IF (validate(shouldeventbebridged,char(128))=char(128))
  SUBROUTINE (shouldeventbebridged(peventcd=f8) =i2)
    CALL logmessage("shouldEventBeBridged","Entering...",log_debug)
    DECLARE eventbridgingvalue = vc WITH protect, noconstant("0")
    DECLARE iseventbridgingenabled = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM code_value_extension cve
     PLAN (cve
      WHERE cve.code_value=peventcd
       AND cve.field_name="EVENT BRIDGING")
     DETAIL
      eventbridgingvalue = cve.field_value
     WITH nocounter
    ;end select
    IF (eventbridgingvalue="1")
     SET iseventbridgingenabled = true
    ENDIF
    CALL logmessage("shouldEventBeBridged","Exiting...",log_debug)
    RETURN(iseventbridgingenabled)
  END ;Subroutine
 ENDIF
 IF (validate(prepareforeventbridging,char(128))=char(128))
  SUBROUTINE (prepareforeventbridging(prscriptrequest=vc(ref),peventidx=i4,peventoccurid=f8) =null)
    CALL logmessage("prepareForEventBridging","Entering...",log_debug)
    RECORD addtaskqueuerequest(
      1 workflowtaskqueueid = f8
      1 requestjson = vc
      1 replyjson = vc
      1 originaltaskqueueid = f8
      1 processdttm = dq8
      1 taskident = vc
      1 retrycount = i4
      1 queuestatuscd = f8
      1 entityid = f8
      1 entityname = vc
      1 taskdatatxt = vc
    ) WITH protect
    RECORD addtaskqueuereply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD publisheventsbridging(
      1 entitytypekey = vc
      1 entityid = f8
      1 eventcd = f8
      1 eventoccurid = f8
      1 parameters[*]
        2 name = vc
        2 value = vc
    ) WITH protect
    SET stat = alterlist(publisheventsbridging->parameters,1)
    SET publisheventsbridging->entitytypekey = prscriptrequest->eventlist[peventidx].entitytypekey
    SET publisheventsbridging->entityid = prscriptrequest->eventlist[peventidx].entityid
    SET publisheventsbridging->eventcd = prscriptrequest->eventlist[peventidx].eventcd
    SET publisheventsbridging->eventoccurid = peventoccurid
    IF ((prscriptrequest->eventlist[peventidx].parameters[1].paramcd=cs24454_wfqueuename))
     SET publisheventsbridging->parameters[1].name = uar_get_code_display(prscriptrequest->eventlist[
      peventidx].parameters[1].paramcd)
     SET publisheventsbridging->parameters[1].value = prscriptrequest->eventlist[peventidx].
     parameters[1].stringvalue
    ENDIF
    SET addtaskqueuerequest->requestjson = replace(cnvtrectojson(publisheventsbridging),
     "PUBLISHEVENTSBRIDGING","WTPTASKREQUEST")
    SET addtaskqueuerequest->taskident = "PFT_PUBLISH_EVENT_TO_ENT"
    SET addtaskqueuerequest->processdttm = cnvtdatetime(sysdate)
    SET addtaskqueuerequest->entityid = prscriptrequest->eventlist[peventidx].entityid
    SET addtaskqueuerequest->entityname = prscriptrequest->eventlist[peventidx].entitytypekey
    EXECUTE wtp_workflow_task_save  WITH replace("REQUEST",addtaskqueuerequest), replace("REPLY",
     addtaskqueuereply)
    IF ((addtaskqueuereply->status_data.status != "S"))
     CALL logmessage("prepareForEventBridging","Error: Failed to bridge event",log_error)
    ELSE
     CALL logmessage("prepareForEventBridging","Exiting...",log_debug)
    ENDIF
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
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 IF ( NOT (validate(cs20849_client_cd)))
  DECLARE cs20849_client_cd = f8 WITH protect, constant(getcodevalue(20849,"CLIENT",1))
 ENDIF
 IF ( NOT (validate(cs20849_research_cd)))
  DECLARE cs20849_research_cd = f8 WITH protect, constant(getcodevalue(20849,"RESEARCH",1))
 ENDIF
 SUBROUTINE (checkworkitemexist(paccountid=f8,prpftqueueitemid=f8(ref),prpreworkitemamount=f8(ref),
  prupdatecnt=i4(ref),prworkitemupdtdate=f8(ref)) =i2)
   CALL logmsg(curprog,"Entering... checkWorkItemExist()",log_debug)
   IF ( NOT (validate(cs29320_account_cd)))
    DECLARE cs29320_account_cd = f8 WITH protect, constant(getcodevalue(29320,"ACCOUNT",1))
   ENDIF
   IF ( NOT (validate(cs29322_unbillinv_cd)))
    DECLARE cs29322_unbillinv_cd = f8 WITH protect, constant(getcodevalue(29322,"UNBILLINV",1))
   ENDIF
   DECLARE workitemexistsind = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM pft_queue_item pqi
    PLAN (pqi
     WHERE pqi.acct_id=paccountid
      AND pqi.pft_entity_type_cd=cs29320_account_cd
      AND pqi.event_cd=cs29322_unbillinv_cd
      AND pqi.active_ind=true)
    ORDER BY pqi.pft_queue_item_id DESC
    DETAIL
     workitemexistsind = true, prpftqueueitemid = pqi.pft_queue_item_id, prpreworkitemamount = pqi
     .work_item_amt,
     prworkitemupdtdate = pqi.updt_dt_tm, prupdatecnt = pqi.updt_cnt
    WITH nocounter, maxrec = 1
   ;end select
   CALL logmsg(curprog,"Exiting... checkWorkItemExist()",log_debug)
   RETURN(workitemexistsind)
 END ;Subroutine
 SUBROUTINE (checkequalbalances(paccountid=f8,pworkitemamount=f8,prlastinvbilleddate=f8(ref)) =i2)
   CALL logmsg(curprog,"Entering... checkEqualBalances()",log_debug)
   DECLARE totalinvoicebalance = f8 WITH protect, noconstant(0.0)
   DECLARE amountdiff = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM account a,
     bill_reltn brl,
     bill_rec br
    PLAN (a
     WHERE a.acct_id=paccountid
      AND a.acct_sub_type_cd IN (cs20849_client_cd, cs20849_research_cd)
      AND a.active_ind=true)
     JOIN (brl
     WHERE brl.parent_entity_id=a.acct_id
      AND brl.active_ind=true
      AND brl.parent_entity_name="ACCOUNT")
     JOIN (br
     WHERE br.corsp_activity_id=brl.corsp_activity_id
      AND br.balance > 0.0
      AND br.active_ind=true)
    ORDER BY br.corsp_activity_id DESC
    DETAIL
     totalinvoicebalance = br.balance, prlastinvbilleddate = br.updt_dt_tm
    WITH nocounter, maxrec = 1
   ;end select
   SET amountdiff = abs((totalinvoicebalance - pworkitemamount))
   IF (amountdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 CALL echo(build("Begin PFT_RCA_WORKFLOW_COMMON_INC, version [",nullterm("ENABTECH-15032.015"),"]"))
 CALL echo("Begin pft_feature_toggle_common.inc, version[674984.002]")
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
 IF ( NOT (validate(getfeaturetoggledetail)))
  SUBROUTINE (getfeaturetoggledetail(pfeaturetogglekey=vc,prisfeatureenabled=i2(ref)) =i2)
    RECORD featuretogglerequest(
      1 togglename = vc
      1 username = vc
      1 positioncd = f8
      1 systemidentifier = vc
      1 solutionname = vc
    ) WITH protect
    RECORD featuretogglereply(
      1 togglename = vc
      1 isenabled = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET featuretogglerequest->togglename = pfeaturetogglekey
    SET featuretogglerequest->systemidentifier = "urn:cerner:revenue-cycle"
    EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
     featuretogglereply)
    IF ((featuretogglereply->status_data.status="S"))
     SET prisfeatureenabled = featuretogglereply->isenabled
     CALL logmsg("getFeatureToggleDetail",build("Feature Toggle of ",pfeaturetogglekey," : ",
       prisfeatureenabled),log_debug)
    ELSE
     CALL logmsg("getFeatureToggleDetail","Call to sys_check_feature_toggle failed",log_debug)
     RETURN(false)
    ENDIF
    RETURN(true)
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
 IF ( NOT (validate(event_default)))
  DECLARE event_default = vc WITH protect, constant("DEFAULT")
 ENDIF
 IF ( NOT (validate(event_edit_failure)))
  DECLARE event_edit_failure = vc WITH protect, constant("CLMEDITFAIL")
 ENDIF
 IF ( NOT (validate(event_variance)))
  DECLARE event_variance = vc WITH protect, constant("VARCREATE")
 ENDIF
 IF ( NOT (validate(event_remit_failure)))
  DECLARE event_remit_failure = vc WITH protect, constant("REMITFAILURE")
 ENDIF
 IF ( NOT (validate(sort_status_date)))
  DECLARE sort_status_date = i2 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(sort_amount)))
  DECLARE sort_amount = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(sort_failure_category)))
  DECLARE sort_failure_category = i2 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(sort_failure_category_group)))
  DECLARE sort_failure_category_group = i2 WITH protect, constant(5)
 ENDIF
 IF ( NOT (validate(sort_failure_severity)))
  DECLARE sort_failure_severity = i2 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(sort_failure_alias)))
  DECLARE sort_failure_alias = i2 WITH protect, constant(7)
 ENDIF
 IF ( NOT (validate(sort_patient_last_name)))
  DECLARE sort_patient_last_name = i2 WITH protect, constant(8)
 ENDIF
 IF ( NOT (validate(sort_encntr_nbr)))
  DECLARE sort_encntr_nbr = i2 WITH protect, constant(9)
 ENDIF
 IF ( NOT (validate(sort_mrn)))
  DECLARE sort_mrn = i2 WITH protect, constant(10)
 ENDIF
 IF ( NOT (validate(sort_adm_date)))
  DECLARE sort_adm_date = i2 WITH protect, constant(11)
 ENDIF
 IF ( NOT (validate(sort_timely_filing_deadline)))
  DECLARE sort_timely_filing_deadline = i2 WITH protect, constant(12)
 ENDIF
 IF ( NOT (validate(sort_updated_status_date)))
  DECLARE sort_updated_status_date = i2 WITH protect, constant(13)
 ENDIF
 IF ( NOT (validate(sort_priority)))
  DECLARE sort_priority = i2 WITH protect, constant(14)
 ENDIF
 IF ( NOT (validate(cs4002623_department)))
  DECLARE cs4002623_department = f8 WITH protect, constant(getcodevalue(4002623,"DEPARTMENT",0))
 ENDIF
 IF ( NOT (validate(cs19189_department)))
  DECLARE cs19189_department = f8 WITH protect, constant(getcodevalue(19189,"DEPARTMENT",0))
 ENDIF
 IF ( NOT (validate(cs4002623_advanced)))
  DECLARE cs4002623_advanced = f8 WITH protect, constant(getcodevalue(4002623,"ADVANCED",0))
 ENDIF
 IF ( NOT (validate(cs649723_nondept)))
  DECLARE cs649723_nondept = f8 WITH protect, constant(getcodevalue(649723,"NONDEPT",0))
 ENDIF
 IF ( NOT (validate(cs649723_loadbalanced)))
  DECLARE cs649723_loadbalanced = f8 WITH protect, constant(getcodevalue(649723,"LOADBALANCED",0))
 ENDIF
 IF ( NOT (validate(cs649723_usergroup)))
  DECLARE cs649723_usergroup = f8 WITH protect, constant(getcodevalue(649723,"USERGROUP",0))
 ENDIF
 IF ( NOT (validate(cs649723_justintime)))
  DECLARE cs649723_justintime = f8 WITH protect, constant(getcodevalue(649723,"JUSTINTIME",0))
 ENDIF
 IF ( NOT (validate(wf_group_queue_feature_toggle_key)))
  DECLARE wf_group_queue_feature_toggle_key = vc WITH protect, constant(
   "urn:cerner:revenue-cycle:cpa:wf.group.queue.enabled")
 ENDIF
 IF ( NOT (validate(wf_jit_feature_toggle_key)))
  DECLARE wf_jit_feature_toggle_key = vc WITH protect, constant(
   "urn:cerner:revenue-cycle:cpa:wf.jit.assignment.queue.enabled")
 ENDIF
 IF ( NOT (validate(wf_cwl_feature_toggle_key)))
  DECLARE wf_cwl_feature_toggle_key = vc WITH protect, constant(
   "urn:cerner:revenue-cycle:cpa:wf.common.work.list.enabled")
 ENDIF
 DECLARE work_item_owner_unassigned = vc WITH protect, constant("<unassigned>")
 DECLARE locvalcnt = i4 WITH protect, noconstant(0)
 DECLARE locvalindex = i4 WITH protect, noconstant(0)
 DECLARE expidx = i4 WITH protect, noconstant(0)
 DECLARE isgqfeatureenabled = i2 WITH protect, noconstant(true)
 DECLARE isjitfeatureenabled = i2 WITH protect, noconstant(true)
 DECLARE prsnlvaluewithoutzeroprsnlid = vc WITH protect, noconstant("(0.0)")
 RECORD supportedworkflowevents(
   1 events[*]
     2 workfloweventcdfmeaning = vc
     2 workfloweventcd = f8
 ) WITH protect
 RECORD personnellist(
   1 personnels[*]
     2 personnelid = f8
 ) WITH protect
 RECORD usergroupprsnllist(
   1 personnels[*]
     2 personnelid = f8
 ) WITH protect
 SET stat = alterlist(supportedworkflowevents->events,3)
 SET supportedworkflowevents->events[1].workfloweventcdfmeaning = event_edit_failure
 SET supportedworkflowevents->events[1].workfloweventcd = uar_get_code_by("MEANING",29322,
  event_edit_failure)
 SET supportedworkflowevents->events[2].workfloweventcdfmeaning = event_variance
 SET supportedworkflowevents->events[2].workfloweventcd = uar_get_code_by("MEANING",29322,
  event_variance)
 SET supportedworkflowevents->events[3].workfloweventcdfmeaning = event_remit_failure
 SET supportedworkflowevents->events[3].workfloweventcd = uar_get_code_by("MEANING",29322,
  event_remit_failure)
 IF ( NOT (validate(constructworkfloweventqual)))
  SUBROUTINE (constructworkfloweventqual(ptablealias=vc,peventtypeflag=i2) =vc)
    DECLARE eventidx = i4 WITH protect, noconstant(0)
    DECLARE eventcdstring = vc WITH protect, noconstant(" ")
    DECLARE eventqualstring = vc WITH protect, noconstant(" 1=1 ")
    FOR (eventidx = 1 TO size(supportedworkflowevents->events,5))
      SET eventcdstring = concat(eventcdstring,trim(cnvtstring(supportedworkflowevents->events[
         eventidx].workfloweventcd,17,2),3),",")
    ENDFOR
    IF (size(supportedworkflowevents->events,5) > 0
     AND size(trim(validate(ptablealias,""),3)) > 0)
     IF (peventtypeflag=1)
      SET eventqualstring = concat(" ",ptablealias,".event_cd"," in (",eventcdstring)
     ELSEIF (peventtypeflag=0)
      SET eventqualstring = concat(" ",ptablealias,".event_cd"," not in (",eventcdstring)
     ENDIF
     SET eventqualstring = substring(1,(size(eventqualstring,3) - 1),eventqualstring)
     SET eventqualstring = concat(eventqualstring," ) ")
    ENDIF
    RETURN(eventqualstring)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isstatebasedqueue)))
  SUBROUTINE (isstatebasedqueue(plogicaldomainid=f8,pworkflowstatecd=f8) =i2)
    SELECT INTO "nl:"
     FROM pft_queue_item pq,
      pft_wf_issue pw
     PLAN (pq
      WHERE pq.pft_entity_status_cd=pworkflowstatecd
       AND pq.logical_domain_id=plogicaldomainid
       AND pq.active_ind=true)
      JOIN (pw
      WHERE pw.issue_cd=pq.item_status_cd
       AND pw.active_ind=true)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(populatepersonneldata)))
  SUBROUTINE (populatepersonneldata(prsnlvalue=vc(ref)) =i2)
    CALL logmessage("populatePersonnelData","Entering..",log_debug)
    DECLARE prsnlcnt = i4 WITH protect, noconstant(0)
    IF (validate(request->personnels) > 0)
     IF (size(request->personnels,5) > 0)
      FOR (prsnlcnt = 1 TO size(request->personnels,5))
       SET stat = alterlist(personnellist->personnels,prsnlcnt)
       SET personnellist->personnels[prsnlcnt].personnelid = request->personnels[prsnlcnt].
       personnelid
      ENDFOR
     ENDIF
    ENDIF
    IF (size(personnellist->personnels,5)=0)
     SET stat = alterlist(personnellist->personnels,1)
     IF (isjitfeatureenabled
      AND validate(request->personnelid,0.0)=0.0)
      SET personnellist->personnels[1].personnelid = 0.0
     ELSEIF (validate(request->personnelid,0.0) > 0.0)
      SET personnellist->personnels[1].personnelid = request->personnelid
     ENDIF
    ENDIF
    IF (size(personnellist->personnels,5) > 0)
     IF (validate(request->filters.workitemownerind,0)=1)
      IF (isjitfeatureenabled
       AND validate(request->filters.workitemownercd,0.0)=0.0)
       SET prsnlvalue = build2("(",0.0,")")
      ELSEIF (validate(request->filters.workitemownercd,0.0) > 0.0)
       SET prsnlvalue = build2("(",request->filters.workitemownercd,")")
       SET prsnlvaluewithoutzeroprsnlid = prsnlvalue
      ENDIF
      CALL logmessage("populatePersonnelData","Exiting - Success with owner filter",log_debug)
      RETURN(true)
     ELSE
      FOR (prsnlcnt = 1 TO size(personnellist->personnels,5))
        IF (prsnlcnt=1)
         SET prsnlvalue = build2(personnellist->personnels[prsnlcnt].personnelid)
         IF ((personnellist->personnels[prsnlcnt].personnelid > 0.0))
          SET prsnlvaluewithoutzeroprsnlid = prsnlvalue
         ENDIF
        ELSE
         SET prsnlvalue = build2(prsnlvalue,", ",personnellist->personnels[prsnlcnt].personnelid)
         IF ((personnellist->personnels[prsnlcnt].personnelid > 0.0))
          SET prsnlvaluewithoutzeroprsnlid = build2(prsnlvaluewithoutzeroprsnlid,", ",personnellist->
           personnels[prsnlcnt].personnelid)
         ENDIF
        ENDIF
      ENDFOR
      SET prsnlvalue = build2("(",prsnlvalue,")")
      SET prsnlvaluewithoutzeroprsnlid = build2("(",prsnlvaluewithoutzeroprsnlid,")")
      CALL logmessage("populatePersonnelData","Exiting - Success with personnel",log_debug)
      RETURN(true)
     ENDIF
    ENDIF
    CALL logmessage("populatePersonnelData",
     "Exiting - Failed to populate prsnl list. No personnelIds in request",log_debug)
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(populatedepartmentdata)))
  SUBROUTINE (populatedepartmentdata(prsnldeptlist=vc(ref),deptids=vc(ref)) =i2)
    CALL logmessage("populateDepartmentData","Entering..",log_debug)
    DECLARE prsnlcnt = i4 WITH protect, noconstant(0)
    DECLARE deptcnt = i4 WITH protect, noconstant(0)
    DECLARE deptind = i2 WITH protect, noconstant(false)
    IF (size(prsnldeptlist->personnellist,5) > 0)
     FOR (prsnlcnt = 1 TO size(prsnldeptlist->personnellist,5))
       IF (validate(prsnldeptlist->personnellist[prsnlcnt].departmentlist))
        IF (size(prsnldeptlist->personnellist[prsnlcnt].departmentlist,5) > 0)
         SET deptind = true
         FOR (deptcnt = 1 TO size(prsnldeptlist->personnellist[prsnlcnt].departmentlist,5))
           IF (prsnlcnt=1
            AND deptcnt=1)
            SET deptids = build2(prsnldeptlist->personnellist[prsnlcnt].departmentlist[deptcnt].
             departmentid)
           ELSE
            SET deptids = build2(deptids,", ",prsnldeptlist->personnellist[prsnlcnt].departmentlist[
             deptcnt].departmentid)
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
     IF (deptind)
      CALL logmessage("populateDepartmentData","Exiting - Success with departments in prsnlDeptList",
       log_debug)
      RETURN(true)
     ELSE
      CALL logmessage("populateDepartmentData","Exiting - Failure no departments in prsnlDeptList",
       log_debug)
      RETURN(false)
     ENDIF
    ENDIF
    CALL logmessage("populateDepartmentData","Exiting - Failure no personnels in prsnlDeptList",
     log_debug)
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(populateworkitemownerfilter)))
  SUBROUTINE (populateworkitemownerfilter(dummyvar=i2) =i2)
    CALL logmessage("populateWorkItemOwnerFilter","Entering..",log_debug)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE filtercnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE expand(expidx,1,size(personnellist->personnels,5),p.person_id,personnellist->personnels[
       expidx].personnelid)
       AND p.active_ind=true)
     DETAIL
      IF (size(trim(p.name_full_formatted)) > 0)
       filtercnt += 1, stat = alterlist(reply->filtervalues.workitemowners,filtercnt), reply->
       filtervalues.workitemowners[filtercnt].workitemownercd = p.person_id,
       reply->filtervalues.workitemowners[filtercnt].workitemownername = p.name_full_formatted
      ENDIF
     WITH nocounter
    ;end select
    IF (isjitfeatureenabled)
     FOR (idx = 1 TO size(personnellist->personnels,5))
       IF ((personnellist->personnels[idx].personnelid=0.0))
        SET filtercnt += 1
        SET stat = alterlist(reply->filtervalues.workitemowners,filtercnt)
        SET reply->filtervalues.workitemowners[filtercnt].workitemownercd = 0.0
        SET reply->filtervalues.workitemowners[filtercnt].workitemownername =
        work_item_owner_unassigned
       ENDIF
     ENDFOR
    ENDIF
    IF (size(reply->filtervalues.workitemowners,5) > 0)
     CALL logmessage("populateWorkItemOwnerFilter",
      "Exiting - Successfully populated workitem owner filter",log_debug)
     RETURN(true)
    ENDIF
    CALL logmessage("populateWorkItemOwnerFilter",
     "Exiting - Failed to populate workitem owner filter",log_debug)
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(setworkflowitemownerdisplay)))
  SUBROUTINE (setworkflowitemownerdisplay(dummyvar=i2) =null)
    CALL logmessage("setWorkflowItemOwnerDisplay","Entering..",log_debug)
    SELECT INTO "nl:"
     FROM pft_queue_item pqi,
      prsnl p
     PLAN (pqi
      WHERE expand(expidx,1,size(reply->workflowitemlist,5),pqi.pft_queue_item_id,reply->
       workflowitemlist[expidx].workflowitemid)
       AND pqi.active_ind=true)
      JOIN (p
      WHERE (p.person_id= Outerjoin(pqi.assigned_prsnl_id))
       AND (p.active_ind= Outerjoin(true)) )
     DETAIL
      locvalindex = 0, locvalindex = locateval(locvalcnt,1,size(reply->workflowitemlist,5),pqi
       .pft_queue_item_id,reply->workflowitemlist[locvalcnt].workflowitemid)
      IF (locvalindex > 0)
       IF (isjitfeatureenabled
        AND pqi.assigned_prsnl_id=0)
        reply->workflowitemlist[locvalindex].workitemownerdisplay = work_item_owner_unassigned
       ELSE
        reply->workflowitemlist[locvalindex].workitemownerdisplay = p.name_full_formatted
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    CALL logmessage("setWorkflowItemOwnerDisplay","Exiting..",log_debug)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(populateusergroupworkitemownerfilter)))
  SUBROUTINE (populateusergroupworkitemownerfilter(dummyvar=i2) =i2)
    CALL logmessage("populateUserGroupWorkItemOwnerFilter","Entering..",log_debug)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE filtercnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE expand(idx,1,size(usergroupprsnllist->personnels,5),p.person_id,usergroupprsnllist->
       personnels[idx].personnelid)
       AND p.active_ind=true)
     DETAIL
      IF (size(trim(p.name_full_formatted)) > 0)
       filtercnt += 1, stat = alterlist(reply->filtervalues.workitemowners,filtercnt), reply->
       filtervalues.workitemowners[filtercnt].workitemownercd = p.person_id,
       reply->filtervalues.workitemowners[filtercnt].workitemownername = p.name_full_formatted
      ENDIF
     WITH nocounter
    ;end select
    IF (size(reply->filtervalues.workitemowners,5) > 0)
     CALL logmessage("populateUserGroupWorkItemOwnerFilter",
      "Exiting - Successfully populated workitem owner filter",log_debug)
     RETURN(true)
    ENDIF
    CALL logmessage("populateUserGroupWorkItemOwnerFilter",
     "Exiting - Failed to populate workitem owner filter",log_debug)
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isgroupqueuefeatureenabled)))
  DECLARE isgroupqueuefeatureenabled(null) = i2
  SUBROUTINE isgroupqueuefeatureenabled(null)
    CALL logmessage("isGroupQueueFeatureEnabled","Entering..",log_debug)
    IF (size(trim(wf_group_queue_feature_toggle_key),1) > 0)
     IF ( NOT (getfeaturetoggledetail(wf_group_queue_feature_toggle_key,isgqfeatureenabled)))
      CALL logmessage("getFeatureToggleDetail",build("Failed to get Feature Toggle details : ",
        wf_group_queue_feature_toggle_key),log_debug)
     ENDIF
    ENDIF
    CALL logmessage("isGroupQueueFeatureEnabled","Exiting..",log_debug)
    RETURN(isgqfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isjitqueuefeatureenabled)))
  DECLARE isjitqueuefeatureenabled(null) = i2
  SUBROUTINE isjitqueuefeatureenabled(null)
    CALL logmessage("isJITQueueFeatureEnabled","Entering..",log_debug)
    IF (size(trim(wf_jit_feature_toggle_key),1) > 0)
     IF ( NOT (getfeaturetoggledetail(wf_jit_feature_toggle_key,isjitfeatureenabled)))
      CALL logmessage("getFeatureToggleDetail",build("Failed to get Feature Toggle details : ",
        wf_jit_feature_toggle_key),log_debug)
     ENDIF
    ENDIF
    CALL logmessage("isJITQueueFeatureEnabled","Exiting..",log_debug)
    RETURN(isjitfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(iscwlfeatureenabled)))
  DECLARE iscwlfeatureenabled(null) = i2
  SUBROUTINE iscwlfeatureenabled(null)
    CALL logmessage("isCWLFeatureEnabled","Entering..",log_debug)
    DECLARE iscfeatureenabled = i2 WITH protect, noconstant(true)
    IF (size(trim(wf_cwl_feature_toggle_key),1) > 0)
     IF ( NOT (getfeaturetoggledetail(wf_cwl_feature_toggle_key,iscfeatureenabled)))
      CALL logmessage("getFeatureToggleDetail",build("Failed to get Feature Toggle details : ",
        wf_cwl_feature_toggle_key),log_debug)
     ENDIF
    ENDIF
    CALL logmessage("isCWLFeatureEnabled","Exiting..",log_debug)
    RETURN(iscfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isrevelatefeaturetoggleenabled)))
  SUBROUTINE (isrevelatefeaturetoggleenabled(dummyvar=i2) =i2)
    DECLARE system_identifier_feature_toggle_key = vc WITH protect, constant("urn:cerner:revelate")
    DECLARE revelate_enable_feature_toggle_key = vc WITH protect, constant(
     "urn:cerner:revelate:enable")
    DECLARE isrevelatefeatureenabled = i2 WITH noconstant(false)
    SET isrevelatefeatureenabled = revelategetfeaturetoggle(revelate_enable_feature_toggle_key,
     system_identifier_feature_toggle_key)
    CALL logmessage("isRevElateFeatureToggleEnabled",build2(" Feature Toggle - ",
      revelate_enable_feature_toggle_key," value is = ",isrevelatefeatureenabled),log_debug)
    RETURN(isrevelatefeatureenabled)
  END ;Subroutine
 ENDIF
 IF (validate(revelategetfeaturetoggle,char(128))=char(128))
  SUBROUTINE (revelategetfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) =i2)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logmessage("revElateGetFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled),log_debug)
     ELSE
      CALL logmessage("revElateGetFeatureToggle","Call to sys_check_feature_toggle failed",log_debug)
     ENDIF
    ELSE
     CALL logmessage("revElateGetFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."),log_debug)
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 SUBROUTINE (isworkitemoftypejit(workflowitemid=f8) =i2)
  SELECT INTO "nl:"
   FROM pft_queue_item pqi
   WHERE pqi.pft_queue_item_id=workflowitemid
    AND pqi.department_type_cd=cs649723_justintime
    AND pqi.pft_entity_status_cd > 0.0
    AND pqi.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN(true)
  ELSE
   RETURN(false)
  ENDIF
 END ;Subroutine
 IF ( NOT (validate(fetchworkflowqueueassignmenttype)))
  SUBROUTINE (fetchworkflowqueueassignmenttype(pworkflowstatuscd=f8) =f8)
    CALL logmessage("fetchWorkflowQueueAssignmentType","Entering..",log_debug)
    DECLARE workflowqueueassignmenttype = f8 WITH protect, noconstant(0)
    SELECT DISTINCT INTO "nl:"
     pqi.department_type_cd
     FROM pft_queue_item pqi
     WHERE pqi.pft_entity_status_cd=pworkflowstatuscd
      AND pqi.active_ind=true
     DETAIL
      IF (pqi.department_type_cd=cs649723_nondept)
       workflowqueueassignmenttype = cs649723_nondept
      ELSEIF (pqi.department_type_cd=cs649723_loadbalanced)
       workflowqueueassignmenttype = cs649723_loadbalanced
      ELSEIF (pqi.department_type_cd=cs649723_usergroup)
       workflowqueueassignmenttype = cs649723_usergroup
      ELSEIF (pqi.department_type_cd=cs649723_justintime)
       workflowqueueassignmenttype = cs649723_justintime
      ELSE
       workflowqueueassignmenttype = cs649723_nondept
      ENDIF
     WITH nocounter
    ;end select
    CALL logmessage("fetchWorkflowQueueAssignmentType","Exiting..",log_debug)
    RETURN(workflowqueueassignmenttype)
  END ;Subroutine
 ENDIF
 RECORD ocreq(
   1 charge_item_id = f8
   1 charge_items[*]
     2 charge_item_id = f8
 ) WITH protect
 RECORD ocrep(
   1 charge_item_count = i4
   1 charge_items[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 username = vc
     2 payor_id = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = vc
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 charge_type_dis = vc
     2 charge_type_mean = vc
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 activity_type_cd = f8
     2 admit_type_cd = f8
     2 bundle_id = f8
     2 department_cd = f8
     2 institution_cd = f8
     2 level5_cd = f8
     2 med_service_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 abn_status_cd = f8
     2 cost_center_cd = f8
     2 inst_fin_nbr = vc
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 item_reimbursement = f8
     2 list_price_sched_id = f8
     2 payor_type_cd = f8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 offset_charge_item_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 charge_mod_count = i4
     2 charge_mods[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
       3 active_ind = i2
       3 chk_presence_flg = i2
       3 delete_flg = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD changelogrecord(
   1 charge_modifications[*]
     2 charge_item_id = f8
     2 old_value = vc
     2 new_value = vc
     2 mod_type = vc
     2 old_value_id = f8
     2 new_value_id = f8
     2 reason_cd = vc
     2 reason_comment = vc
 ) WITH protect
 RECORD cmreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cmrep(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE i18n_ordering_physician = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "Ordering Physician","Ordering Physician"))
 DECLARE i18n_rendering_physician = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "Rendering Physician","Rendering Physician"))
 IF ( NOT (validate(i18n_research_account)))
  DECLARE i18n_research_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "Research Account","Research Account"))
 ENDIF
 DECLARE i18n_abn_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"ABN Status",
   "ABN Status"))
 DECLARE i18n_service_date = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Service Date",
   "Service Date"))
 DECLARE i18n_performing_location = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "Performing Location","Performing Location"))
 DECLARE i18n_charge_description = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "Charge Description","Charge Description"))
 DECLARE i18n_price = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Price","Price"))
 DECLARE i18n_quantity = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Quantity","Quantity"))
 DECLARE i18n_extended_price = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Extended Price",
   "Extended Price"))
 DECLARE i18n_priority = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Priority","Priority"))
 DECLARE i18n_qcf = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"QCF","QCF"))
 DECLARE i18n_ndc_code = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"NDC Code","NDC Code"))
 DECLARE i18n_ndc_factor = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"NDC Factor",
   "NDC Factor"))
 DECLARE i18n_ndc_uom = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"NDC UOM","NDC UOM"))
 IF ( NOT (validate(cs13019_changelog)))
  DECLARE cs13019_changelog = f8 WITH protect, constant(getcodevalue(13019,"CHANGELOG",0))
 ENDIF
 IF ( NOT (validate(cs13019_billcode)))
  DECLARE cs13019_billcode = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs13019_user_def)))
  DECLARE cs13019_user_def = f8 WITH protect, constant(getcodevalue(13019,"USER DEF",0))
 ENDIF
 IF ( NOT (validate(cs13019_mod_rsn)))
  DECLARE cs13019_mod_rsn = f8 WITH protect, constant(getcodevalue(13019,"MOD RSN",0))
 ENDIF
 IF ( NOT (validate(cs29322_chargeupdate)))
  DECLARE cs29322_chargeupdate = f8 WITH protect, constant(getcodevalue(29322,"CHARGEUPDATE",0))
 ENDIF
 IF ( NOT (validate(cs23369_wfevent)))
  DECLARE cs23369_wfevent = f8 WITH protect, noconstant(getcodevalue(23369,"WFEVENT",0))
 ENDIF
 IF ( NOT (validate(cs13028_debit_cd)))
  DECLARE cs13028_debit_cd = f8 WITH protect, noconstant(getcodevalue(13028,"DR",0))
 ENDIF
 IF ( NOT (validate(cs24454_chrgitemid)))
  DECLARE cs24454_chrgitemid = f8 WITH protect, noconstant(getcodevalue(24454,"CHRGITEMID",0))
 ENDIF
 IF ( NOT (validate(cs24454_contributor_cd)))
  DECLARE cs24454_contributor_cd = f8 WITH protect, noconstant(getcodevalue(24454,"CONTRIBSYS",0))
 ENDIF
 IF ( NOT (validate(cs24454_chrggrpid)))
  DECLARE cs24454_chrggrpid = f8 WITH protect, noconstant(getcodevalue(24454,"CHRGGRPID",0))
 ENDIF
 IF ( NOT (validate(interfaced)))
  DECLARE interfaced = i4 WITH protect, constant(999)
 ENDIF
 IF ( NOT (validate(posted)))
  DECLARE posted = i4 WITH protect, constant(100)
 ENDIF
 DECLARE addbcschedmodifydetails(pchargeitemid=f8,pchargemodpos1=i4,pchargemodpos2=i4) = null
 SUBROUTINE (savechargechangelogattributes(prcharge=vc(ref)) =i2)
   IF (validate(prcharge->charge_qual)=0)
    CALL logmessage("saveChargeChangeLogAttributes",
     "The record item charge_qual in prCharge does not exist: ",log_error)
    RETURN(false)
   ENDIF
   IF ((prcharge->charge_qual <= 0))
    CALL logmessage("saveChargeChangeLogAttributes",
     "Can not create changelog for charge attribute modification: ",log_error)
    RETURN(false)
   ENDIF
   CALL comparechargeattributes(prcharge)
   CALL addchargemodrsncomment(prcharge->charge[1].charge_item_id)
   CALL savechangelog(changelogrecord)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (savechargemodchangelogattributes(prchargemod=vc(ref)) =i2)
   IF (validate(prchargemod->charge_mod_qual)=0)
    CALL logmessage("saveChargeModChangeLogAttributes",
     "The record item CHARGE_MOD_QUAL in prChargeMod does not exist: ",log_error)
    RETURN(false)
   ENDIF
   IF ((prchargemod->charge_mod_qual <= 0))
    CALL logmessage("saveChargeModChangeLogAttributes",
     "Cannot create changelog for charge Mod attribute modification: ",log_error)
    RETURN(false)
   ENDIF
   CALL comparechargemodattributes(prchargemod)
   IF (size(prchargemod->charge_mod,5)=1)
    IF (validate(prchargemod->charge_mod[1].charge_mod_type_cd) > 0)
     IF ((prchargemod->charge_mod[1].charge_mod_type_cd=cs13019_user_def))
      CALL addchargemodrsncomment(prchargemod->charge_mod[1].charge_item_id)
     ENDIF
    ENDIF
   ENDIF
   CALL savechangelog(changelogrecord)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getoldchargeitemdetails(poldchargeitemid=f8) =i2)
   SET stat = initrec(ocreq)
   SET stat = initrec(ocrep)
   SET ocreq->charge_item_id = poldchargeitemid
   EXECUTE afc_charge_find  WITH replace("REQUEST",ocreq), replace("REPLY",ocrep)
   IF ((ocrep->status_data.status != "S"))
    CALL logmessage("AFC_CHARGE_FIND","Cannot find the charge details: ",log_error)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (savechangelogdetails(poldchargeitemid=f8,pnewchargeitemid=f8) =i2)
   IF (((poldchargeitemid <= 0.0) OR (pnewchargeitemid <= 0.0)) )
    CALL logmessage("saveChangeLogDetails",
     "Cannot create changelog for charge and charge mod attribute modification: ",log_error)
    RETURN(false)
   ENDIF
   CALL getoldnewchargeitemdetails(poldchargeitemid,pnewchargeitemid)
   CALL comparepostedchargeattributes(poldchargeitemid)
   CALL comparepostedchargemodattributes(poldchargeitemid)
   CALL addchargemodrsncomment(pnewchargeitemid)
   CALL savechangelog(changelogrecord)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (savechangelogforencntrmod(proldcharge=vc(ref),prnewcharge=vc(ref)) =i2)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE occount = i4 WITH protect, noconstant(0)
   IF (((validate(proldcharge->charges)=0) OR (validate(prnewcharge->charges)=0)) )
    CALL logmessage("saveChangeLogForEncntrMod",
     "The record item CHARGES in prOldCharge or in prNewCharge does not exist: ",log_error)
    RETURN(false)
   ENDIF
   IF (((size(proldcharge->charges,5) <= 0) OR (size(prnewcharge->charges,5) <= 0)) )
    CALL logmessage("saveChangeLogForEncntrMod",
     "Cannot create changelog for charge or charge Mod attribute modification: ",log_error)
    RETURN(false)
   ENDIF
   FOR (occount = 1 TO size(proldcharge->charges,5))
     SET num = 0
     SET pos = locateval(num,1,size(prnewcharge->charges,5),proldcharge->charges[occount].
      charge_item_id,prnewcharge->charges[num].parent_charge_item_id)
     IF (pos > 0)
      CALL getoldnewchargeitemdetails(proldcharge->charges[occount].charge_item_id,prnewcharge->
       charges[pos].charge_item_id)
      CALL comparepostedchargeattributes(proldcharge->charges[occount].charge_item_id)
      CALL comparepostedchargemodattributes(proldcharge->charges[occount].charge_item_id)
      CALL addchargemodrsncomment(prnewcharge->charges[pos].charge_item_id)
     ENDIF
   ENDFOR
   CALL savechangelog(changelogrecord)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (savechargemodchangelogforencntrmod(prchargemod=vc(ref)) =i2)
   SET stat = initrec(changelogrecord)
   IF (validate(prchargemod->charge_mod_qual)=0)
    CALL logmessage("saveChargeModChangeLogAttributes",
     "The record item CHARGE_MOD_QUAL in prChargeMod does not exist: ",log_error)
    RETURN(false)
   ENDIF
   IF ((prchargemod->charge_mod_qual <= 0))
    CALL logmessage("saveChargeModChangeLogAttributes",
     "Cannot create changelog for charge Mod attribute modification: ",log_error)
    RETURN(false)
   ENDIF
   CALL comparechargemodattributesencntrmod(prchargemod)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(changelogrecord->charge_modifications,5))),
     charge c
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_item_id=changelogrecord->charge_modifications[d1.seq].charge_item_id))
    DETAIL
     changelogrecord->charge_modifications[d1.seq].reason_cd = uar_get_code_display(c.suspense_rsn_cd
      ), changelogrecord->charge_modifications[d1.seq].reason_comment = c.reason_comment
    WITH nocounter
   ;end select
   CALL savechangelog(changelogrecord)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updatechargemodrsncomment(prcharge=vc(ref)) =i2)
   DECLARE suspensersn = vc WITH protect, noconstant("")
   IF (validate(prcharge->charge_qual)=0)
    CALL logmessage("updateChargeModRsnComment",
     "The record item CHARGE_QUAL in prCharge does not exist: ",log_error)
    RETURN(false)
   ENDIF
   IF ((prcharge->charge_qual <= 0))
    CALL logmessage("updateChargeModRsnComment","Cannot update changelog in charge mod with modrsn: ",
     log_error)
    RETURN(false)
   ENDIF
   SET suspensersn = uar_get_code_display(prcharge->charge[1].suspense_rsn_cd)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(cmreq->objarray,0)
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE (cm.charge_item_id=prcharge->charge[1].charge_item_id)
     AND cm.charge_mod_type_cd=cs13019_changelog
     AND trim(cm.field4)=null
     AND trim(cm.field5)=null
    DETAIL
     billcdcnt += 1, stat = alterlist(cmreq->objarray,billcdcnt), cmreq->objarray[billcdcnt].
     action_type = "UPT",
     cmreq->objarray[billcdcnt].charge_mod_id = cm.charge_mod_id, cmreq->objarray[billcdcnt].
     charge_item_id = cm.charge_item_id, cmreq->objarray[billcdcnt].updt_cnt = cm.updt_cnt,
     cmreq->objarray[billcdcnt].field4 = suspensersn, cmreq->objarray[billcdcnt].field5 = prcharge->
     charge[1].reason_comment, cmreq->objarray[billcdcnt].charge_mod_type_cd = cm.charge_mod_type_cd,
     cmreq->objarray[billcdcnt].field1 = cm.field1, cmreq->objarray[billcdcnt].field2 = cm.field2,
     cmreq->objarray[billcdcnt].field3 = cm.field3,
     cmreq->objarray[billcdcnt].field6 = cm.field6, cmreq->objarray[billcdcnt].field7 = cm.field7,
     cmreq->objarray[billcdcnt].field8 = cm.field8,
     cmreq->objarray[billcdcnt].field9 = cm.field9, cmreq->objarray[billcdcnt].field10 = cm.field10,
     cmreq->objarray[billcdcnt].active_ind = cm.active_ind,
     cmreq->objarray[billcdcnt].active_status_cd = cm.active_status_cd, cmreq->objarray[billcdcnt].
     active_status_dt_tm = cm.active_status_dt_tm, cmreq->objarray[billcdcnt].active_status_prsnl_id
      = cm.active_status_prsnl_id,
     cmreq->objarray[billcdcnt].beg_effective_dt_tm = cm.beg_effective_dt_tm, cmreq->objarray[
     billcdcnt].end_effective_dt_tm = cm.end_effective_dt_tm, cmreq->objarray[billcdcnt].code1_cd =
     cm.code1_cd,
     cmreq->objarray[billcdcnt].nomen_id = cm.nomen_id, cmreq->objarray[billcdcnt].field1_id = cm
     .field1_id, cmreq->objarray[billcdcnt].field2_id = cm.field2_id,
     cmreq->objarray[billcdcnt].field3_id = cm.field3_id, cmreq->objarray[billcdcnt].field4_id = cm
     .field4_id, cmreq->objarray[billcdcnt].field5_id = cm.field5_id,
     cmreq->objarray[billcdcnt].cm1_nbr = cm.cm1_nbr, cmreq->objarray[billcdcnt].activity_dt_tm = cm
     .activity_dt_tm
    WITH nocounter
   ;end select
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to update")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getoldchargeitemdetailsforencntrmod(prchargemod=vc(ref)) =i2)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE chargeitemid = f8 WITH protect, noconstant(0.0)
   SET stat = initrec(ocreq)
   SET stat = initrec(ocrep)
   SELECT INTO "nl:"
    chargeitemid = prchargemod->charge_mod[d1.seq].charge_item_id
    FROM (dummyt d1  WITH seq = value(prchargemod->charge_mod_qual))
    HEAD chargeitemid
     count += 1, stat = alterlist(ocreq->charge_items,count), ocreq->charge_items[count].
     charge_item_id = prchargemod->charge_mod[d1.seq].charge_item_id
    WITH nocounter
   ;end select
   EXECUTE afc_charge_find  WITH replace("REQUEST",ocreq), replace("REPLY",ocrep)
   IF ((ocrep->status_data.status != "S"))
    CALL logmessage("AFC_CHARGE_FIND","Cannot find the charge details: ",log_error)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getoldnewchargeitemdetails(poldchargeitemid=f8,pnewchargeitemid=f8) =i2)
   SET stat = initrec(ocreq)
   SET stat = initrec(ocrep)
   SET stat = alterlist(ocreq->charge_items,2)
   SET ocreq->charge_items[1].charge_item_id = poldchargeitemid
   SET ocreq->charge_items[2].charge_item_id = pnewchargeitemid
   EXECUTE afc_charge_find  WITH replace("REQUEST",ocreq), replace("REPLY",ocrep)
   IF ((ocrep->status_data.status != "S"))
    CALL logmessage("AFC_CHARGE_FIND","Cannot find the charge details: ",log_error)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (comparechargeattributes(prnewcharge=vc(ref)) =null)
   DECLARE extendedpricenew = f8 WITH protect, noconstant(0.0)
   SET curalias oldcharge ocrep->charge_items[1]
   SET curalias newcharge prnewcharge->charge[1]
   IF (validate(newcharge->perf_loc_cd) > 0)
    IF ((newcharge->perf_loc_cd != oldcharge->perf_loc_cd)
     AND  NOT ((oldcharge->perf_loc_cd=0)
     AND (newcharge->perf_loc_cd=- (1))))
     CALL fillidfields(newcharge->charge_item_id,i18n_performing_location,oldcharge->perf_loc_cd,
      newcharge->perf_loc_cd)
    ENDIF
   ENDIF
   IF (validate(newcharge->ord_phys_id) > 0)
    IF ((newcharge->ord_phys_id != oldcharge->ord_phys_id)
     AND  NOT ((oldcharge->ord_phys_id=0)
     AND (newcharge->ord_phys_id=- (1))))
     CALL fillidfields(newcharge->charge_item_id,i18n_ordering_physician,oldcharge->ord_phys_id,
      newcharge->ord_phys_id)
    ENDIF
   ENDIF
   IF (validate(newcharge->verify_phys_id) > 0)
    IF ((newcharge->verify_phys_id != oldcharge->verify_phys_id)
     AND  NOT ((oldcharge->verify_phys_id=0)
     AND (newcharge->verify_phys_id=- (1))))
     CALL fillidfields(newcharge->charge_item_id,i18n_rendering_physician,oldcharge->verify_phys_id,
      newcharge->verify_phys_id)
    ENDIF
   ENDIF
   IF (validate(newcharge->research_acct_id) > 0)
    IF ((newcharge->research_acct_id != oldcharge->research_acct_id)
     AND  NOT ((oldcharge->research_acct_id=0)
     AND (newcharge->research_acct_id=- (1))))
     CALL fillidfields(newcharge->charge_item_id,i18n_research_account,oldcharge->research_acct_id,
      newcharge->research_acct_id)
    ENDIF
   ENDIF
   IF (validate(newcharge->abn_status_cd) > 0)
    IF ((newcharge->abn_status_cd != oldcharge->abn_status_cd)
     AND  NOT ((oldcharge->abn_status_cd=0)
     AND (newcharge->abn_status_cd=- (1))))
     CALL fillidfields(newcharge->charge_item_id,i18n_abn_status,oldcharge->abn_status_cd,newcharge->
      abn_status_cd)
    ENDIF
   ENDIF
   IF (validate(newcharge->service_dt_tm) > 0)
    IF ((newcharge->service_dt_tm != oldcharge->service_dt_tm)
     AND (newcharge->service_dt_tm != 0))
     CALL fillvcfields(newcharge->charge_item_id,i18n_service_date,format(oldcharge->service_dt_tm,
       ";;Q"),format(newcharge->service_dt_tm,";;Q"))
    ENDIF
   ENDIF
   IF (validate(newcharge->item_quantity) > 0)
    IF ((newcharge->item_quantity != oldcharge->item_quantity)
     AND (newcharge->item_quantity != 0.0))
     CALL fillidfields(newcharge->charge_item_id,i18n_quantity,oldcharge->item_quantity,newcharge->
      item_quantity)
    ENDIF
   ENDIF
   IF (validate(newcharge->item_price) > 0)
    IF ((newcharge->item_price != oldcharge->item_price)
     AND (newcharge->item_price != 0.0))
     CALL fillidfields(newcharge->charge_item_id,i18n_price,oldcharge->item_price,newcharge->
      item_price)
    ENDIF
   ENDIF
   IF (validate(newcharge->item_price) > 0
    AND validate(newcharge->item_quantity) > 0)
    SET extendedpricenew = (newcharge->item_price * newcharge->item_quantity)
    IF ((extendedpricenew != oldcharge->item_extended_price)
     AND extendedpricenew != 0.0)
     CALL fillidfields(newcharge->charge_item_id,i18n_extended_price,oldcharge->item_extended_price,
      extendedpricenew)
    ENDIF
   ENDIF
   IF (validate(newcharge->charge_description) > 0)
    IF ((newcharge->charge_description != oldcharge->charge_description)
     AND trim(newcharge->charge_description) != "")
     CALL fillvcfields(newcharge->charge_item_id,i18n_charge_description,oldcharge->
      charge_description,newcharge->charge_description)
    ENDIF
   ENDIF
   SET curalias oldcharge off
   SET curalias newcharge off
 END ;Subroutine
 SUBROUTINE (comparepostedchargeattributes(poldchargeitemid=f8) =null)
   DECLARE extendedpricenew = f8 WITH protect, noconstant(0.0)
   IF ((ocrep->charge_items[1].charge_item_id=poldchargeitemid))
    SET curalias oldcharge ocrep->charge_items[1]
    SET curalias newcharge ocrep->charge_items[2]
   ELSE
    SET curalias newcharge ocrep->charge_items[1]
    SET curalias oldcharge ocrep->charge_items[2]
   ENDIF
   IF ((newcharge->perf_loc_cd != oldcharge->perf_loc_cd)
    AND  NOT ((oldcharge->perf_loc_cd=0)
    AND (newcharge->perf_loc_cd=- (1))))
    CALL fillidfields(newcharge->charge_item_id,i18n_performing_location,oldcharge->perf_loc_cd,
     newcharge->perf_loc_cd)
   ENDIF
   IF ((newcharge->ord_phys_id != oldcharge->ord_phys_id)
    AND  NOT ((oldcharge->ord_phys_id=0)
    AND (newcharge->ord_phys_id=- (1))))
    CALL fillidfields(newcharge->charge_item_id,i18n_ordering_physician,oldcharge->ord_phys_id,
     newcharge->ord_phys_id)
   ENDIF
   IF ((newcharge->verify_phys_id != oldcharge->verify_phys_id)
    AND  NOT ((oldcharge->verify_phys_id=0)
    AND (newcharge->verify_phys_id=- (1))))
    CALL fillidfields(newcharge->charge_item_id,i18n_rendering_physician,oldcharge->verify_phys_id,
     newcharge->verify_phys_id)
   ENDIF
   IF ((newcharge->research_acct_id != oldcharge->research_acct_id)
    AND  NOT ((oldcharge->research_acct_id=0)
    AND (newcharge->research_acct_id=- (1))))
    CALL fillidfields(newcharge->charge_item_id,i18n_research_account,oldcharge->research_acct_id,
     newcharge->research_acct_id)
   ENDIF
   IF ((newcharge->abn_status_cd != oldcharge->abn_status_cd)
    AND  NOT ((oldcharge->abn_status_cd=0)
    AND (newcharge->abn_status_cd=- (1))))
    CALL fillidfields(newcharge->charge_item_id,i18n_abn_status,oldcharge->abn_status_cd,newcharge->
     abn_status_cd)
   ENDIF
   IF ((newcharge->service_dt_tm != oldcharge->service_dt_tm)
    AND (newcharge->service_dt_tm != 0))
    CALL fillvcfields(newcharge->charge_item_id,i18n_service_date,format(oldcharge->service_dt_tm,
      ";;Q"),format(newcharge->service_dt_tm,";;Q"))
   ENDIF
   IF ((newcharge->item_quantity != oldcharge->item_quantity)
    AND (newcharge->item_quantity != 0.0))
    CALL fillidfields(newcharge->charge_item_id,i18n_quantity,oldcharge->item_quantity,newcharge->
     item_quantity)
   ENDIF
   IF ((newcharge->item_price != oldcharge->item_price)
    AND (newcharge->item_price != 0.0))
    CALL fillidfields(newcharge->charge_item_id,i18n_price,oldcharge->item_price,newcharge->
     item_price)
   ENDIF
   SET extendedpricenew = (newcharge->item_price * newcharge->item_quantity)
   IF ((extendedpricenew != oldcharge->item_extended_price)
    AND extendedpricenew != 0.0)
    CALL fillidfields(newcharge->charge_item_id,i18n_extended_price,oldcharge->item_extended_price,
     extendedpricenew)
   ENDIF
   IF ((newcharge->charge_description != oldcharge->charge_description)
    AND trim(newcharge->charge_description) != "")
    CALL fillvcfields(newcharge->charge_item_id,i18n_charge_description,oldcharge->charge_description,
     newcharge->charge_description)
   ENDIF
   SET curalias oldcharge off
   SET curalias newcharge off
 END ;Subroutine
 SUBROUTINE (comparechargemodattributes(prnewchargemod=vc(ref)) =null)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET curalias oldc ocrep->charge_items[1]
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(prnewchargemod->charge_mod_qual))
    DETAIL
     IF ((prnewchargemod->charge_mod[d1.seq].action_type="ADD"))
      IF ((prnewchargemod->charge_mod[d1.seq].charge_mod_type_cd=cs13019_user_def))
       CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,prnewchargemod->charge_mod[d1
       .seq].field6,"",prnewchargemod->charge_mod[d1.seq].field7)
      ELSE
       IF (uar_get_code_meaning(prnewchargemod->charge_mod[d1.seq].field1_id)="NDC")
        CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,i18n_ndc_code,"",
        prnewchargemod->charge_mod[d1.seq].field6),
        CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,i18n_ndc_factor,"",cnvtstring(
         prnewchargemod->charge_mod[d1.seq].field3_id))
        IF ((prnewchargemod->charge_mod[d1.seq].field4_id > 0.0))
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,i18n_ndc_uom,"",
         uar_get_code_display(prnewchargemod->charge_mod[d1.seq].field4_id))
        ENDIF
       ELSE
        CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,uar_get_code_display(
         prnewchargemod->charge_mod[d1.seq].field1_id),"",prnewchargemod->charge_mod[d1.seq].field6)
       ENDIF
      ENDIF
     ELSEIF ((prnewchargemod->charge_mod[d1.seq].action_type="DEL"))
      pos = locateval(num,1,size(oldc->charge_mods,5),prnewchargemod->charge_mod[d1.seq].
       charge_mod_id,oldc->charge_mods[num].charge_mod_id)
      IF (pos > 0)
       IF ((oldc->charge_mods[pos].charge_mod_type_cd=cs13019_user_def))
        CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,oldc->charge_mods[pos].field6,
        oldc->charge_mods[pos].field7,"")
       ELSE
        CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,uar_get_code_display(oldc->
         charge_mods[pos].field1_id),oldc->charge_mods[pos].field6,"")
       ENDIF
      ENDIF
     ELSEIF ((prnewchargemod->charge_mod[d1.seq].action_type="UPT"))
      num = 0, pos = locateval(num,1,size(oldc->charge_mods,5),prnewchargemod->charge_mod[d1.seq].
       charge_mod_id,oldc->charge_mods[num].charge_mod_id)
      IF (pos > 0)
       IF ((prnewchargemod->charge_mod[d1.seq].charge_mod_type_cd=cs13019_user_def))
        IF ((oldc->charge_mods[pos].field7 != prnewchargemod->charge_mod[d1.seq].field7))
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,prnewchargemod->charge_mod[d1
         .seq].field6,oldc->charge_mods[pos].field7,prnewchargemod->charge_mod[d1.seq].field7)
        ENDIF
       ELSE
        IF ((oldc->charge_mods[pos].field6 != prnewchargemod->charge_mod[d1.seq].field6))
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,uar_get_code_display(
          prnewchargemod->charge_mod[d1.seq].field1_id),oldc->charge_mods[pos].field6,prnewchargemod
         ->charge_mod[d1.seq].field6)
        ENDIF
        IF ((oldc->charge_mods[pos].field2_id != prnewchargemod->charge_mod[d1.seq].field2_id))
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,concat(trim(
           uar_get_code_display(oldc->charge_mods[pos].field1_id)),"-",oldc->charge_mods[pos].field6,
          "(",i18n_priority,
          ")"),cnvtstring(oldc->charge_mods[pos].field2_id,17,2),cnvtstring(prnewchargemod->
          charge_mod[d1.seq].field2_id,17,2))
        ENDIF
        IF ((oldc->charge_mods[pos].cm1_nbr != prnewchargemod->charge_mod[d1.seq].cm1_nbr))
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,concat(trim(
           uar_get_code_display(oldc->charge_mods[pos].field1_id)),"-",oldc->charge_mods[pos].field6,
          "(",i18n_qcf,
          ")"),cnvtstring(oldc->charge_mods[pos].cm1_nbr,17,2),cnvtstring(prnewchargemod->charge_mod[
          d1.seq].cm1_nbr,17,2))
        ENDIF
        IF ((oldc->charge_mods[pos].field3_id != prnewchargemod->charge_mod[d1.seq].field3_id)
         AND uar_get_code_meaning(prnewchargemod->charge_mod[d1.seq].field1_id)="NDC")
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,i18n_ndc_factor,cnvtstring(
          oldc->charge_mods[pos].field3_id),cnvtstring(prnewchargemod->charge_mod[d1.seq].field3_id))
        ENDIF
        IF ((oldc->charge_mods[pos].field4_id != prnewchargemod->charge_mod[d1.seq].field4_id)
         AND uar_get_code_meaning(prnewchargemod->charge_mod[d1.seq].field1_id)="NDC")
         CALL fillvcfields(prnewchargemod->charge_mod[1].charge_item_id,i18n_ndc_uom,
         uar_get_code_display(oldc->charge_mods[pos].field4_id),uar_get_code_display(prnewchargemod->
          charge_mod[d1.seq].field4_id))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET curalias oldc off
 END ;Subroutine
 SUBROUTINE (comparechargemodattributesencntrmod(prnewchargemod=vc(ref)) =null)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE pos1 = i4 WITH protect, noconstant(0)
   DECLARE cmqcount = i4 WITH protect, noconstant(0)
   FOR (cmqcount = 1 TO prnewchargemod->charge_mod_qual)
     IF ((prnewchargemod->charge_mod[cmqcount].action_type="ADD"))
      CALL fillvcfields(prnewchargemod->charge_mod[cmqcount].charge_item_id,uar_get_code_display(
        prnewchargemod->charge_mod[cmqcount].field1_id),"",prnewchargemod->charge_mod[cmqcount].
       field6)
     ELSEIF ((prnewchargemod->charge_mod[cmqcount].action_type="DEL"))
      SET pos1 = locateval(num,1,ocrep->charge_item_count,prnewchargemod->charge_mod[cmqcount].
       charge_item_id,ocrep->charge_items[num].charge_item_id)
      SET num = 0
      IF (pos1 > 0)
       SET pos = locateval(num,1,size(ocrep->charge_items[pos1].charge_mods,5),prnewchargemod->
        charge_mod[cmqcount].charge_mod_id,ocrep->charge_items[pos1].charge_mods[num].charge_mod_id)
       IF (pos > 0)
        CALL fillvcfields(prnewchargemod->charge_mod[cmqcount].charge_item_id,uar_get_code_display(
          ocrep->charge_items[pos1].charge_mods[pos].field1_id),ocrep->charge_items[pos1].
         charge_mods[pos].field6,"")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (comparepostedchargemodattributes(poldchargeitemid=f8) =null)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos1 = i4 WITH protect, noconstant(0)
   DECLARE pos2 = i4 WITH protect, noconstant(0)
   DECLARE pos3 = i4 WITH protect, noconstant(0)
   DECLARE pos4 = i4 WITH protect, noconstant(0)
   DECLARE pos5 = i4 WITH protect, noconstant(0)
   DECLARE pos6 = i4 WITH protect, noconstant(0)
   DECLARE occnt = i4 WITH protect, noconstant(0)
   DECLARE nccnt = i4 WITH protect, noconstant(0)
   DECLARE occnt1 = i4 WITH protect, noconstant(0)
   DECLARE field1_disp = vc WITH protect, noconstant("")
   IF ((ocrep->charge_items[1].charge_item_id=poldchargeitemid))
    SET curalias oldcharge ocrep->charge_items[1]
    SET curalias newcharge ocrep->charge_items[2]
   ELSE
    SET curalias newcharge ocrep->charge_items[1]
    SET curalias oldcharge ocrep->charge_items[2]
   ENDIF
   FOR (occnt = 1 TO oldcharge->charge_mod_count)
     IF ((oldcharge->charge_mods[occnt].charge_mod_type_cd=cs13019_billcode))
      IF ((oldcharge->charge_mods[occnt].active_ind=1))
       SET oldcharge->charge_mods[occnt].chk_presence_flg = 0
       SET pos1 = locateval(num,1,newcharge->charge_mod_count,oldcharge->charge_mods[occnt].field1_id,
        newcharge->charge_mods[num].field1_id,
        oldcharge->charge_mods[occnt].field6,newcharge->charge_mods[num].field6,oldcharge->
        charge_mods[occnt].field3_id,newcharge->charge_mods[num].field3_id,oldcharge->charge_mods[
        occnt].field4_id,
        newcharge->charge_mods[num].field4_id)
       IF (pos1 > 0)
        SET newcharge->charge_mods[pos1].chk_presence_flg = 1
        SET oldcharge->charge_mods[occnt].chk_presence_flg = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (nccnt = 1 TO newcharge->charge_mod_count)
     IF ((newcharge->charge_mods[nccnt].charge_mod_type_cd=cs13019_billcode))
      IF ((newcharge->charge_mods[nccnt].active_ind=1))
       IF (uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC")
        SET field1_disp = i18n_ndc_code
       ELSE
        SET field1_disp = uar_get_code_display(newcharge->charge_mods[nccnt].field1_id)
       ENDIF
       SET pos2 = locateval(num,1,oldcharge->charge_mod_count,newcharge->charge_mods[nccnt].field1_id,
        oldcharge->charge_mods[num].field1_id,
        newcharge->charge_mods[nccnt].field6,oldcharge->charge_mods[num].field6,newcharge->
        charge_mods[nccnt].field2_id,oldcharge->charge_mods[num].field2_id,newcharge->charge_mods[
        nccnt].field3_id,
        oldcharge->charge_mods[num].field3_id,newcharge->charge_mods[nccnt].field4_id,oldcharge->
        charge_mods[num].field4_id,0,oldcharge->charge_mods[num].delete_flg)
       IF (pos2 > 0)
        CALL addbcqcfmodifydetails(newcharge->charge_item_id,pos2,nccnt)
        SET oldcharge->charge_mods[pos2].delete_flg = 1
       ELSE
        SET pos3 = locateval(num,1,oldcharge->charge_mod_count,newcharge->charge_mods[nccnt].
         field1_id,oldcharge->charge_mods[num].field1_id,
         newcharge->charge_mods[nccnt].field6,oldcharge->charge_mods[num].field6,0,oldcharge->
         charge_mods[num].delete_flg)
        IF (pos3 > 0)
         IF ((newcharge->charge_mods[nccnt].field2_id != oldcharge->charge_mods[pos3].field2_id)
          AND (newcharge->charge_mods[nccnt].chk_presence_flg=1))
          CALL addbcprioritymodifydetails(newcharge->charge_item_id,pos3,nccnt)
         ENDIF
         IF ((newcharge->charge_mods[nccnt].field3_id != oldcharge->charge_mods[pos3].field3_id)
          AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC"
          AND (newcharge->charge_mods[nccnt].chk_presence_flg=0))
          SET oldcharge->charge_mods[pos3].delete_flg = 1
          CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_factor,cnvtstring(oldcharge->
            charge_mods[pos3].field3_id),cnvtstring(newcharge->charge_mods[nccnt].field3_id))
         ENDIF
         IF ((newcharge->charge_mods[nccnt].field4_id != oldcharge->charge_mods[pos3].field4_id)
          AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC"
          AND (newcharge->charge_mods[nccnt].chk_presence_flg=0))
          SET oldcharge->charge_mods[pos3].delete_flg = 1
          CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_uom,uar_get_code_display(oldcharge->
            charge_mods[pos3].field4_id),uar_get_code_display(newcharge->charge_mods[nccnt].field4_id
            ))
         ENDIF
         CALL addbcqcfmodifydetails(newcharge->charge_item_id,pos3,nccnt)
        ELSE
         SET pos4 = locateval(num,1,oldcharge->charge_mod_count,newcharge->charge_mods[nccnt].
          field1_id,oldcharge->charge_mods[num].field1_id,
          newcharge->charge_mods[nccnt].field2_id,oldcharge->charge_mods[num].field2_id,0,oldcharge->
          charge_mods[num].delete_flg)
         IF (pos4 > 0)
          IF ((newcharge->charge_mods[nccnt].field6 != oldcharge->charge_mods[pos4].field6)
           AND (newcharge->charge_mods[nccnt].chk_presence_flg=0)
           AND (oldcharge->charge_mods[pos4].chk_presence_flg=1))
           CALL fillvcfields(newcharge->charge_item_id,field1_disp,"",newcharge->charge_mods[nccnt].
            field6)
          ELSEIF ((newcharge->charge_mods[nccnt].field6 != oldcharge->charge_mods[pos4].field6)
           AND (newcharge->charge_mods[nccnt].chk_presence_flg=0))
           SET oldcharge->charge_mods[pos4].delete_flg = 1
           CALL fillvcfields(newcharge->charge_item_id,field1_disp,oldcharge->charge_mods[pos4].
            field6,newcharge->charge_mods[nccnt].field6)
           CALL addbcqcfmodifydetails(newcharge->charge_item_id,pos4,nccnt)
          ENDIF
          IF ((newcharge->charge_mods[nccnt].field3_id != oldcharge->charge_mods[pos4].field3_id)
           AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC"
           AND (newcharge->charge_mods[nccnt].chk_presence_flg=0))
           SET oldcharge->charge_mods[pos4].delete_flg = 1
           CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_factor,cnvtstring(oldcharge->
             charge_mods[pos4].field3_id),cnvtstring(newcharge->charge_mods[nccnt].field3_id))
          ENDIF
          IF ((newcharge->charge_mods[nccnt].field4_id != oldcharge->charge_mods[pos4].field4_id)
           AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC"
           AND (newcharge->charge_mods[nccnt].chk_presence_flg=0))
           SET oldcharge->charge_mods[pos4].delete_flg = 1
           CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_uom,uar_get_code_display(oldcharge->
             charge_mods[pos4].field4_id),uar_get_code_display(newcharge->charge_mods[nccnt].
             field4_id))
          ENDIF
         ELSE
          SET pos5 = locateval(num,1,oldcharge->charge_mod_count,newcharge->charge_mods[nccnt].
           field1_id,oldcharge->charge_mods[num].field1_id,
           0,oldcharge->charge_mods[num].delete_flg)
          IF (pos5 > 0)
           IF ((newcharge->charge_mods[nccnt].field6 != oldcharge->charge_mods[pos5].field6)
            AND (newcharge->charge_mods[nccnt].field2_id != oldcharge->charge_mods[pos5].field2_id)
            AND (newcharge->charge_mods[nccnt].chk_presence_flg=0)
            AND (oldcharge->charge_mods[pos5].chk_presence_flg=0))
            SET oldcharge->charge_mods[pos5].delete_flg = 1
            CALL fillvcfields(newcharge->charge_item_id,field1_disp,oldcharge->charge_mods[pos5].
             field6,newcharge->charge_mods[nccnt].field6)
            CALL addbcprioritymodifydetails(newcharge->charge_item_id,pos5,nccnt)
            CALL addbcqcfmodifydetails(newcharge->charge_item_id,pos5,nccnt)
           ELSEIF ((newcharge->charge_mods[nccnt].field6 != oldcharge->charge_mods[pos5].field6)
            AND (newcharge->charge_mods[nccnt].field2_id != oldcharge->charge_mods[pos5].field2_id)
            AND (newcharge->charge_mods[nccnt].chk_presence_flg=0)
            AND (oldcharge->charge_mods[pos5].chk_presence_flg=1))
            CALL fillvcfields(newcharge->charge_item_id,field1_disp,"",newcharge->charge_mods[nccnt].
             field6)
           ENDIF
          ELSE
           CALL fillvcfields(newcharge->charge_item_id,field1_disp,"",newcharge->charge_mods[nccnt].
            field6)
           IF ((newcharge->charge_mods[nccnt].field3_id > 0.0)
            AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC")
            CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_factor,"",cnvtstring(newcharge->
              charge_mods[nccnt].field3_id))
           ENDIF
           IF ((newcharge->charge_mods[nccnt].field4_id > 0.0)
            AND uar_get_code_meaning(newcharge->charge_mods[nccnt].field1_id)="NDC")
            CALL fillvcfields(newcharge->charge_item_id,i18n_ndc_uom,"",uar_get_code_display(
              newcharge->charge_mods[nccnt].field4_id))
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((newcharge->charge_mods[nccnt].charge_mod_type_cd=cs13019_user_def))
      SET pos6 = locateval(num,1,oldcharge->charge_mod_count,newcharge->charge_mods[nccnt].
       charge_mod_type_cd,oldcharge->charge_mods[num].charge_mod_type_cd)
      IF (pos6 > 0)
       IF ((newcharge->charge_mods[nccnt].field7=oldcharge->charge_mods[pos6].field7)
        AND (oldcharge->charge_mods[pos6].delete_flg=0))
        SET oldcharge->charge_mods[pos6].delete_flg = 1
       ELSEIF ((newcharge->charge_mods[nccnt].field7 != oldcharge->charge_mods[pos6].field7))
        CALL fillvcfields(newcharge->charge_item_id,newcharge->charge_mods[nccnt].field6,oldcharge->
         charge_mods[pos6].field7,newcharge->charge_mods[nccnt].field7)
        SET oldcharge->charge_mods[pos6].delete_flg = 1
       ENDIF
      ELSEIF (pos6=0)
       CALL fillvcfields(newcharge->charge_item_id,newcharge->charge_mods[nccnt].field6,"",newcharge
        ->charge_mods[nccnt].field7)
      ENDIF
     ENDIF
   ENDFOR
   FOR (occnt1 = 1 TO oldcharge->charge_mod_count)
    IF (uar_get_code_meaning(oldcharge->charge_mods[occnt1].field1_id)="NDC")
     SET field1_disp = i18n_ndc_code
    ELSE
     SET field1_disp = uar_get_code_display(oldcharge->charge_mods[occnt1].field1_id)
    ENDIF
    IF ((oldcharge->charge_mods[occnt1].charge_mod_type_cd=cs13019_billcode))
     IF ((oldcharge->charge_mods[occnt1].delete_flg=0)
      AND (oldcharge->charge_mods[occnt1].active_ind=1))
      CALL fillvcfields(newcharge->charge_item_id,field1_disp,oldcharge->charge_mods[occnt1].field6,
       "")
     ENDIF
    ELSEIF ((oldcharge->charge_mods[occnt1].charge_mod_type_cd=cs13019_user_def))
     IF ((oldcharge->charge_mods[occnt1].delete_flg=0)
      AND (oldcharge->charge_mods[occnt1].active_ind=1))
      CALL fillvcfields(newcharge->charge_item_id,oldcharge->charge_mods[occnt1].field6,oldcharge->
       charge_mods[occnt1].field7,"")
     ENDIF
    ENDIF
   ENDFOR
   SET curalias oldcharge off
   SET curalias newcharge off
 END ;Subroutine
 SUBROUTINE (addbcprioritymodifydetails(pchargeitemid=f8,pchrgmodpos1=i4,pchrgmodpos2=i4) =null)
   IF ((ocrep->charge_items[1].charge_item_id=pchargeitemid))
    SET curalias newc ocrep->charge_items[1]
    SET curalias oldc ocrep->charge_items[2]
   ELSE
    SET curalias oldc ocrep->charge_items[1]
    SET curalias newc ocrep->charge_items[2]
   ENDIF
   SET oldc->charge_mods[pchrgmodpos1].delete_flg = 1
   CALL fillvcfields(pchargeitemid,concat(trim(uar_get_code_display(oldc->charge_mods[pchrgmodpos1].
       field1_id)),"-",oldc->charge_mods[pchrgmodpos1].field6,"(",i18n_priority,
     ")"),cnvtstring(oldc->charge_mods[pchrgmodpos1].field2_id,17,2),cnvtstring(newc->charge_mods[
     pchrgmodpos2].field2_id,17,2))
   SET curalias oldc off
   SET curalias newc off
 END ;Subroutine
 SUBROUTINE (addbcqcfmodifydetails(pchargeitemid=f8,pchrgmodpos1=i4,pchrgmodpos2=i4) =null)
   IF ((ocrep->charge_items[1].charge_item_id=pchargeitemid))
    SET curalias newc ocrep->charge_items[1]
    SET curalias oldc ocrep->charge_items[2]
   ELSE
    SET curalias oldc ocrep->charge_items[1]
    SET curalias newc ocrep->charge_items[2]
   ENDIF
   IF ((newc->charge_mods[pchrgmodpos2].cm1_nbr > 0.0)
    AND (newc->charge_mods[pchrgmodpos2].cm1_nbr != oldc->charge_mods[pchrgmodpos1].cm1_nbr))
    SET oldc->charge_mods[pchrgmodpos1].delete_flg = 1
    CALL fillvcfields(pchargeitemid,concat(trim(uar_get_code_display(oldc->charge_mods[pchrgmodpos1].
        field1_id)),"-",oldc->charge_mods[pchrgmodpos1].field6,"(",i18n_qcf,
      ")"),cnvtstring(oldc->charge_mods[pchrgmodpos1].cm1_nbr,17,2),cnvtstring(newc->charge_mods[
      pchrgmodpos2].cm1_nbr,17,2))
   ENDIF
   SET curalias oldc off
   SET curalias newc off
 END ;Subroutine
 SUBROUTINE (fillvcfields(pchargeitemid=f8,pmodtype=vc,poldvalue=vc,pnewvalue=vc) =null)
   DECLARE count = i4 WITH protect, noconstant(0)
   SET count = (size(changelogrecord->charge_modifications,5)+ 1)
   SET stat = alterlist(changelogrecord->charge_modifications,count)
   SET changelogrecord->charge_modifications[count].charge_item_id = pchargeitemid
   SET changelogrecord->charge_modifications[count].mod_type = pmodtype
   SET changelogrecord->charge_modifications[count].old_value = poldvalue
   SET changelogrecord->charge_modifications[count].new_value = pnewvalue
 END ;Subroutine
 SUBROUTINE (fillidfields(pchargeitemid=f8,pmodtype=vc,poldvalueid=f8,pnewvalueid=f8) =null)
   DECLARE count = i4 WITH protect, noconstant(0)
   SET count = (size(changelogrecord->charge_modifications,5)+ 1)
   SET stat = alterlist(changelogrecord->charge_modifications,count)
   SET changelogrecord->charge_modifications[count].charge_item_id = pchargeitemid
   SET changelogrecord->charge_modifications[count].mod_type = pmodtype
   SET changelogrecord->charge_modifications[count].old_value_id = poldvalueid
   SET changelogrecord->charge_modifications[count].new_value_id = evaluate(pnewvalueid,- (1.0),0.0,
    pnewvalueid)
 END ;Subroutine
 SUBROUTINE (addchargemodrsncomment(pchargeitemid=f8) =null)
   DECLARE chnglogcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE cm.charge_item_id=pchargeitemid
     AND cm.charge_mod_type_cd=cs13019_mod_rsn
    ORDER BY cm.charge_mod_id DESC
    DETAIL
     FOR (chnglogcnt = 1 TO size(changelogrecord->charge_modifications,5))
      changelogrecord->charge_modifications[chnglogcnt].reason_cd = uar_get_code_display(cm.field2_id
       ),changelogrecord->charge_modifications[chnglogcnt].reason_comment = cm.field7
     ENDFOR
    WITH maxrec = 1
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM charge c
     WHERE c.charge_item_id=pchargeitemid
     DETAIL
      FOR (chnglogcnt = 1 TO size(changelogrecord->charge_modifications,5))
       changelogrecord->charge_modifications[chnglogcnt].reason_cd = uar_get_code_display(c
        .suspense_rsn_cd),changelogrecord->charge_modifications[chnglogcnt].reason_comment = c
       .reason_comment
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (savechangelog(changelogrecord=vc) =i2)
   DECLARE new_nbr = f8 WITH protect, noconstant(0.0)
   DECLARE clcnt = i4 WITH protect, noconstant(0)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(cmreq->objarray,0)
   FOR (clcnt = 1 TO size(changelogrecord->charge_modifications,5))
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      nextnum = seq(charge_event_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(nextnum)
      WITH format, counter
     ;end select
     IF (curqual=0)
      CALL logmessage("saveChangeLog","Failed to generate Unique charge mod id ",log_error)
      RETURN(false)
     ENDIF
     SET billcdcnt += 1
     SET stat = alterlist(cmreq->objarray,billcdcnt)
     SET cmreq->objarray[billcdcnt].action_type = "ADD"
     SET cmreq->objarray[billcdcnt].charge_mod_id = new_nbr
     SET cmreq->objarray[billcdcnt].charge_item_id = changelogrecord->charge_modifications[clcnt].
     charge_item_id
     SET cmreq->objarray[billcdcnt].charge_mod_type_cd = cs13019_changelog
     SET cmreq->objarray[billcdcnt].field2 = changelogrecord->charge_modifications[clcnt].old_value
     SET cmreq->objarray[billcdcnt].field3 = changelogrecord->charge_modifications[clcnt].new_value
     SET cmreq->objarray[billcdcnt].field2_id = changelogrecord->charge_modifications[clcnt].
     old_value_id
     SET cmreq->objarray[billcdcnt].field3_id = changelogrecord->charge_modifications[clcnt].
     new_value_id
     SET cmreq->objarray[billcdcnt].field7 = changelogrecord->charge_modifications[clcnt].mod_type
     SET cmreq->objarray[billcdcnt].field4 = changelogrecord->charge_modifications[clcnt].reason_cd
     SET cmreq->objarray[billcdcnt].field5 = changelogrecord->charge_modifications[clcnt].
     reason_comment
     SET cmreq->objarray[billcdcnt].activity_dt_tm = cnvtdatetime(sysdate)
     SET cmreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
     SET cmreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     SET cmreq->objarray[billcdcnt].active_ind = 1
     SET cmreq->objarray[billcdcnt].active_status_prsnl_id = reqinfo->updt_id
     SET cmreq->objarray[billcdcnt].active_status_dt_tm = cnvtdatetime(sysdate)
   ENDFOR
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to insert")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (publisheventforchargeupdate(prpublishchargerequest=vc(ref),processflag=i4) =i2)
   CALL logmsg(curprog,"Entering... publishEventForChargeUpdate()",log_debug)
   DECLARE eventcount = i4 WITH protect, noconstant(0)
   DECLARE paramcount = i4 WITH protect, noconstant(0)
   RECORD publisheventrequest(
     1 eventlist[*]
       2 entitytypekey = vc
       2 entityid = f8
       2 eventcd = f8
       2 eventtypecd = f8
       2 workitemamount = f8
       2 params[*]
         3 paramcd = f8
         3 paramvalue = f8
         3 newparamind = i2
         3 doublevalue = f8
   ) WITH protect
   RECORD publisheventreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   IF (processflag=interfaced)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prpublishchargerequest->charges)),
      charge c,
      charge_mod cm,
      encounter e
     PLAN (d
      WHERE (prpublishchargerequest->charges[d.seq].charge_item_id > 0.0))
      JOIN (c
      WHERE (c.charge_item_id=prpublishchargerequest->charges[d.seq].charge_item_id)
       AND c.active_ind=true
       AND c.process_flg=interfaced
       AND c.charge_type_cd=cs13028_debit_cd)
      JOIN (cm
      WHERE cm.charge_item_id=c.charge_item_id
       AND cm.charge_mod_type_cd=cs13019_mod_rsn
       AND cm.active_ind=true)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND e.active_ind=true)
     ORDER BY c.charge_item_id DESC, cm.charge_mod_id DESC
     HEAD c.charge_item_id
      eventcount += 1, stat = alterlist(publisheventrequest->eventlist,eventcount),
      publisheventrequest->eventlist[eventcount].entitytypekey = "ENCOUNTER",
      publisheventrequest->eventlist[eventcount].entityid = e.encntr_id, publisheventrequest->
      eventlist[eventcount].eventtypecd = cs23369_wfevent, publisheventrequest->eventlist[eventcount]
      .eventcd = cs29322_chargeupdate,
      publisheventrequest->eventlist[eventcount].workitemamount = c.item_extended_price, paramcount
       += 1, stat = alterlist(publisheventrequest->eventlist[eventcount].params,paramcount),
      publisheventrequest->eventlist[eventcount].params[paramcount].paramcd = cs24454_chrgitemid,
      publisheventrequest->eventlist[eventcount].params[paramcount].doublevalue = c.charge_item_id,
      publisheventrequest->eventlist[eventcount].params[paramcount].newparamind = true,
      paramcount += 1, stat = alterlist(publisheventrequest->eventlist[eventcount].params,paramcount),
      publisheventrequest->eventlist[eventcount].params[paramcount].paramcd = cs24454_contributor_cd,
      publisheventrequest->eventlist[eventcount].params[paramcount].doublevalue = cm.code1_cd,
      publisheventrequest->eventlist[eventcount].params[paramcount].newparamind = true
     WITH nocounter
    ;end select
   ELSEIF (processflag=posted)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prpublishchargerequest->charges)),
      charge c,
      charge_mod cm,
      pft_charge pc,
      pft_charge_bo_reltn pcbr,
      benefit_order bo,
      pft_encntr pe
     PLAN (d
      WHERE (prpublishchargerequest->charges[d.seq].charge_item_id > 0.0))
      JOIN (c
      WHERE (c.charge_item_id=prpublishchargerequest->charges[d.seq].charge_item_id)
       AND c.active_ind=true
       AND c.process_flg=posted
       AND c.charge_type_cd=cs13028_debit_cd)
      JOIN (cm
      WHERE cm.charge_item_id=c.charge_item_id
       AND cm.charge_mod_type_cd=cs13019_mod_rsn
       AND cm.active_ind=true)
      JOIN (pc
      WHERE pc.charge_item_id=c.charge_item_id
       AND pc.ext_billed_ind=false
       AND pc.active_ind=true)
      JOIN (pcbr
      WHERE pcbr.pft_charge_id=pc.pft_charge_id
       AND pcbr.active_ind=true)
      JOIN (bo
      WHERE bo.benefit_order_id=pcbr.benefit_order_id
       AND bo.active_ind=true)
      JOIN (pe
      WHERE pe.pft_encntr_id=bo.pft_encntr_id
       AND pe.active_ind=true)
     ORDER BY c.charge_item_id DESC, cm.charge_mod_id DESC
     HEAD c.charge_item_id
      eventcount += 1, stat = alterlist(publisheventrequest->eventlist,eventcount),
      publisheventrequest->eventlist[eventcount].entitytypekey = "PFTENCNTR",
      publisheventrequest->eventlist[eventcount].entityid = pe.pft_encntr_id, publisheventrequest->
      eventlist[eventcount].eventtypecd = cs23369_wfevent, publisheventrequest->eventlist[eventcount]
      .eventcd = cs29322_chargeupdate,
      publisheventrequest->eventlist[eventcount].workitemamount = c.item_extended_price, paramcount
       += 1, stat = alterlist(publisheventrequest->eventlist[eventcount].params,paramcount),
      publisheventrequest->eventlist[eventcount].params[paramcount].paramcd = cs24454_chrgitemid,
      publisheventrequest->eventlist[eventcount].params[paramcount].doublevalue = c.charge_item_id,
      publisheventrequest->eventlist[eventcount].params[paramcount].newparamind = true,
      paramcount += 1, stat = alterlist(publisheventrequest->eventlist[eventcount].params,paramcount),
      publisheventrequest->eventlist[eventcount].params[paramcount].paramcd = cs24454_contributor_cd,
      publisheventrequest->eventlist[eventcount].params[paramcount].doublevalue = cm.code1_cd,
      publisheventrequest->eventlist[eventcount].params[paramcount].newparamind = true, paramcount
       += 1,
      stat = alterlist(publisheventrequest->eventlist[eventcount].params,paramcount),
      publisheventrequest->eventlist[eventcount].params[paramcount].paramcd = cs24454_chrggrpid,
      publisheventrequest->eventlist[eventcount].params[paramcount].doublevalue = bo.bt_condition_id,
      publisheventrequest->eventlist[eventcount].params[paramcount].newparamind = true
     WITH nocounter
    ;end select
   ENDIF
   IF (size(publisheventrequest->eventlist,5) > 0)
    EXECUTE pft_publish_event  WITH replace("REQUEST",publisheventrequest), replace("REPLY",
     publisheventreply)
    IF ((publisheventreply->status_data.status != "S"))
     IF (validate(debug,0)=1)
      CALL echorecord(publisheventrequest)
      CALL echorecord(publisheventreply)
     ENDIF
     RETURN(false)
    ENDIF
   ENDIF
   CALL logmsg(curprog,"Exiting... publishEventForChargeUpdate()",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (publishunbilledinvoiceworkitem(prpublishchargerequest=vc(ref)) =i2)
   CALL logmsg(curprog,"Entering.. publishUnbilledInvoiceWorkItem()",log_debug)
   IF ( NOT (validate(cs23369_wfevent_cd)))
    DECLARE cs23369_wfevent_cd = f8 WITH protect, constant(getcodevalue(23369,"WFEVENT",1))
   ENDIF
   IF ( NOT (validate(cs20509_posted_cd)))
    DECLARE cs20509_posted_cd = f8 WITH protect, constant(getcodevalue(20509,"POSTED",1))
   ENDIF
   IF ( NOT (validate(cs20849_client_cd)))
    DECLARE cs20849_client_cd = f8 WITH protect, constant(getcodevalue(20849,"CLIENT",1))
   ENDIF
   IF ( NOT (validate(cs20849_research_cd)))
    DECLARE cs20849_research_cd = f8 WITH protect, constant(getcodevalue(20849,"RESEARCH",1))
   ENDIF
   IF ( NOT (validate(cs29322_unbillinv_cd)))
    DECLARE cs29322_unbillinv_cd = f8 WITH protect, constant(getcodevalue(29322,"UNBILLINV",1))
   ENDIF
   DECLARE workitemexists = i2 WITH protect, noconstant(false)
   DECLARE pftqueueitemid = f8 WITH protect, noconstant(0.0)
   DECLARE prupdatecnt = i4 WITH protect, noconstant(0)
   DECLARE preworkitemamount = f8 WITH protect, noconstant(0.0)
   DECLARE prworkitemupdtdate = f8 WITH protect, noconstant(0.0)
   DECLARE workitemamount = f8 WITH protect, noconstant(0.0)
   DECLARE modchrgamount = f8 WITH protect, noconstant(0.0)
   RECORD addwihistoryrequest(
     1 objarray[*]
       2 pftqueueitemid = f8
       2 workitemamount = f8
       2 transactionactioncodeflag = i2
       2 entitystatuscd = f8
   ) WITH protect
   RECORD addwihistoryreply(
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
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD uptworkitemrequest(
     1 objarray[*]
       2 pft_queue_item_id = f8
       2 work_item_amt = f8
       2 updt_cnt = i4
   ) WITH protect
   RECORD uptworkitemreply(
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
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD publishunbilledinvoiceeventrequest(
     1 eventlist[*]
       2 entitytypekey = vc
       2 entityid = f8
       2 eventcd = f8
       2 eventtypecd = f8
       2 workitemamount = f8
       2 params[*]
         3 paramcd = f8
         3 paramvalue = f8
         3 newparamind = i2
         3 doublevalue = f8
   ) WITH protect
   RECORD publishunbilledinvoiceeventreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD unbilledinvoiceaccountdetails(
     1 acct[*]
       2 accountid = f8
       2 amount = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM charge c,
     charge c2,
     pft_charge pc,
     account a
    PLAN (c
     WHERE (c.charge_item_id=prpublishchargerequest->charges[1].charge_item_id)
      AND c.active_ind=true)
     JOIN (c2
     WHERE c2.parent_charge_item_id=c.parent_charge_item_id
      AND c2.active_ind=true)
     JOIN (pc
     WHERE pc.charge_item_id=c.charge_item_id
      AND pc.pft_charge_status_cd=cs20509_posted_cd
      AND pc.active_ind=true)
     JOIN (a
     WHERE a.acct_id=pc.dr_acct_id
      AND a.acct_sub_type_cd IN (cs20849_client_cd, cs20849_research_cd)
      AND a.active_ind=true)
    HEAD REPORT
     stat = alterlist(unbilledinvoiceaccountdetails->acct,1), unbilledinvoiceaccountdetails->acct[1].
     accountid = a.acct_id
    DETAIL
     IF (c2.item_price < 0.0)
      modchrgamount = abs(c2.item_price)
     ENDIF
     unbilledinvoiceaccountdetails->acct[1].amount += c2.item_price
    WITH nocounter
   ;end select
   IF (size(unbilledinvoiceaccountdetails->acct,5) > 0)
    SET workitemexists = checkworkitemexist(unbilledinvoiceaccountdetails->acct[1].accountid,
     pftqueueitemid,preworkitemamount,prupdatecnt,prworkitemupdtdate)
    IF (workitemexists)
     SET stat = alterlist(uptworkitemrequest->objarray,1)
     SET uptworkitemrequest->objarray[1].pft_queue_item_id = pftqueueitemid
     SET uptworkitemrequest->objarray[1].work_item_amt = (preworkitemamount+
     unbilledinvoiceaccountdetails->acct[1].amount)
     SET uptworkitemrequest->objarray[1].updt_cnt = prupdatecnt
     EXECUTE pft_da_upt_wf_item  WITH replace("REQUEST",uptworkitemrequest), replace("REPLY",
      uptworkitemreply)
     IF ((uptworkitemreply->status_data.status != "S"))
      CALL logmsg(curprog,"Work item's amount could not updated in the pft_queue_item table",
       log_error)
      RETURN(false)
     ENDIF
     SET workitemamount = uptworkitemrequest->objarray[1].work_item_amt
     IF (iscwlfeatureenabled(null))
      SET stat = alterlist(workitementitylist->workitementity,1)
      SET workitementitylist->workitementity[1].workitemid = uptworkitemrequest->objarray[1].
      pft_queue_item_id
      CALL populateentitydetailsforworkitems(workitementitylist)
      SET stat = alterlist(publishworkfloweventrequest->eventlist,1)
      SET stat = alterlist(publishworkfloweventrequest->eventlist[1].parameters,1)
      SET publishworkfloweventrequest->eventlist[1].entitytypekey = workitementitylist->
      workitementity[1].entitytypekey
      SET publishworkfloweventrequest->eventlist[1].entityid = workitementitylist->workitementity[1].
      entityid
      SET publishworkfloweventrequest->eventlist[1].parameters[1].stringvalue = workitementitylist->
      workitementity[1].queuename
      SET publishworkfloweventrequest->eventlist[1].parameters[1].parententityid = workitementitylist
      ->workitementity[1].workitemid
      SET publishworkfloweventrequest->eventlist[1].parameters[1].parententityname = pft_queue_item
      SET publishworkfloweventrequest->eventlist[1].parameters[1].paramcd = cs24454_wfqueuename
      SET publishworkfloweventrequest->eventlist[1].eventcd = cs29322_workitemuptd
      CALL publishworkfloweventfactory(publishworkfloweventrequest)
     ENDIF
     SELECT INTO "nl:"
      FROM pft_queue_item_wf_hist pqiwh
      PLAN (pqiwh
       WHERE pqiwh.pft_queue_item_id=pftqueueitemid
        AND pqiwh.active_ind=true)
      DETAIL
       stat = alterlist(addwihistoryrequest->objarray,1), addwihistoryrequest->objarray[1].
       pftqueueitemid = pqiwh.pft_queue_item_id, addwihistoryrequest->objarray[1].workitemamount =
       workitemamount,
       addwihistoryrequest->objarray[1].transactionactioncodeflag = pqiwh.work_item_action_flag,
       addwihistoryrequest->objarray[1].entitystatuscd = pqiwh.pft_entity_status_cd
      WITH nocounter
     ;end select
     EXECUTE pft_wf_add_wi_hist_transition  WITH replace("REQUEST",addwihistoryrequest), replace(
      "REPLY",addwihistoryreply)
     IF ((addwihistoryreply->status_data.status != "S"))
      CALL logmsg(curprog,"Work item's amount could not updated in the history table",log_error)
      RETURN(false)
     ENDIF
    ELSE
     SET stat = alterlist(publishunbilledinvoiceeventrequest->eventlist,1)
     SET publishunbilledinvoiceeventrequest->eventlist[1].entitytypekey = "ACCOUNT"
     SET publishunbilledinvoiceeventrequest->eventlist[1].entityid = unbilledinvoiceaccountdetails->
     acct[1].accountid
     SET publishunbilledinvoiceeventrequest->eventlist[1].eventtypecd = cs23369_wfevent_cd
     SET publishunbilledinvoiceeventrequest->eventlist[1].eventcd = cs29322_unbillinv_cd
     SET publishunbilledinvoiceeventrequest->eventlist[1].workitemamount = (
     unbilledinvoiceaccountdetails->acct[1].amount+ modchrgamount)
    ENDIF
    IF (size(publishunbilledinvoiceeventrequest->eventlist,5) > 0)
     EXECUTE pft_publish_event  WITH replace("REQUEST",publishunbilledinvoiceeventrequest), replace(
      "REPLY",publishunbilledinvoiceeventreply)
     IF ((publishunbilledinvoiceeventreply->status_data.status != "S"))
      IF ((publishunbilledinvoiceeventreply->status_data.status="Z"))
       CALL logmsg(curprog,"Reply did not return any value to publish the Unbilled Invoice Event ",
        log_debug)
      ELSE
       CALL logmsg(curprog,"Failed to publish the Unbilled Invoice Event",log_debug)
      ENDIF
      IF (validate(debug,0)=1)
       CALL echorecord(publishunbilledinvoiceeventrequest)
       CALL echorecord(publishunbilledinvoiceeventreply)
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    CALL logmsg(curprog,"Exiting.. publishUnbilledInvoiceWorkItem()",log_debug)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
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
 CALL echo("Begin including AFC_CHECK_TIER_QUAL_SUBS.INC, version [639876.002]")
 IF ( NOT (validate(cs13036_cptmodifier_cd)))
  DECLARE cs13036_cptmodifier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "CPT MODIFIER"))
 ENDIF
 IF ( NOT (validate(cs13036_orderingphys_cd)))
  DECLARE cs13036_orderingphys_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "ORDERINGPHYS"))
 ENDIF
 IF ( NOT (validate(cs13036_orderphysgrp_cd)))
  DECLARE cs13036_orderphysgrp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "ORDERPHYSGRP"))
 ENDIF
 IF ( NOT (validate(cs13036_renderingphy_cd)))
  DECLARE cs13036_renderingphy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "RENDERINGPHY"))
 ENDIF
 IF ( NOT (validate(cs13036_rendphysgrp_cd)))
  DECLARE cs13036_rendphysgrp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "RENDPHYSGRP"))
 ENDIF
 IF ( NOT (validate(cs13036_perf_loc_cd)))
  DECLARE cs13036_perf_loc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,"PERF LOC")
   )
 ENDIF
 IF ( NOT (validate(cs13036_providerspc_cd)))
  DECLARE cs13036_providerspc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13036,
    "PROVIDERSPC"))
 ENDIF
 IF (validate(checktierforcptmod,char(128))=char(128))
  SUBROUTINE (checktierforcptmod(chargeitemid=f8) =i2)
    DECLARE cptmodqualifierfound = i2 WITH protect, noconstant(false)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering checkTierForCptMod, charge_item_id is: ",chargeitemid))
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      tier_matrix tm
     PLAN (c
      WHERE c.charge_item_id=chargeitemid
       AND c.active_ind=1)
      JOIN (tm
      WHERE tm.tier_group_cd=c.tier_group_cd
       AND tm.active_ind=1
       AND tm.tier_cell_type_cd=cs13036_cptmodifier_cd
       AND tm.beg_effective_dt_tm <= c.service_dt_tm
       AND tm.end_effective_dt_tm >= c.service_dt_tm)
     DETAIL
      cptmodqualifierfound = true
     WITH nocounter
    ;end select
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Returning from checkTierForCptMod, reply is: ",cptmodqualifierfound))
    ENDIF
    RETURN(cptmodqualifierfound)
  END ;Subroutine
 ENDIF
 IF (validate(checktierforordphys,char(128))=char(128))
  SUBROUTINE (checktierforordphys(chargeitemid=f8) =i2)
    DECLARE ordphysqualifierfound = i2 WITH protect, noconstant(false)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering checkTierForOrdPhys, charge_item_id is: ",chargeitemid))
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      tier_matrix tm
     PLAN (c
      WHERE c.charge_item_id=chargeitemid
       AND c.active_ind=1)
      JOIN (tm
      WHERE tm.tier_group_cd=c.tier_group_cd
       AND tm.active_ind=1
       AND ((tm.tier_cell_type_cd=cs13036_orderingphys_cd) OR (tm.tier_cell_type_cd=
      cs13036_orderphysgrp_cd))
       AND tm.beg_effective_dt_tm <= c.service_dt_tm
       AND tm.end_effective_dt_tm >= c.service_dt_tm)
     DETAIL
      ordphysqualifierfound = true
     WITH nocounter
    ;end select
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Returning from checkTierForOrdPhys, reply is: ",ordphysqualifierfound))
    ENDIF
    RETURN(ordphysqualifierfound)
  END ;Subroutine
 ENDIF
 IF (validate(checktierforrendphys,char(128))=char(128))
  SUBROUTINE (checktierforrendphys(chargeitemid=f8) =i2)
    DECLARE rendphysqualifierfound = i2 WITH protect, noconstant(false)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering checkTierForRendPhys, charge_item_id is: ",chargeitemid))
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      tier_matrix tm
     PLAN (c
      WHERE c.charge_item_id=chargeitemid
       AND c.active_ind=1)
      JOIN (tm
      WHERE tm.tier_group_cd=c.tier_group_cd
       AND tm.active_ind=1
       AND ((tm.tier_cell_type_cd=cs13036_renderingphy_cd) OR (tm.tier_cell_type_cd=
      cs13036_rendphysgrp_cd))
       AND tm.beg_effective_dt_tm <= c.service_dt_tm
       AND tm.end_effective_dt_tm >= c.service_dt_tm)
     DETAIL
      rendphysqualifierfound = true
     WITH nocounter
    ;end select
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Returning from checkTierForRendPhys, reply is: ",rendphysqualifierfound))
    ENDIF
    RETURN(rendphysqualifierfound)
  END ;Subroutine
 ENDIF
 IF (validate(checktierforperflocation,char(128))=char(128))
  SUBROUTINE (checktierforperflocation(chargeitemid=f8) =i2)
    DECLARE perflocationqualifierfound = i2 WITH protect, noconstant(false)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering CheckTierForPerfLocation, charge_item_id is: ",chargeitemid))
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      tier_matrix tm
     PLAN (c
      WHERE c.charge_item_id=chargeitemid
       AND c.active_ind=1)
      JOIN (tm
      WHERE tm.tier_group_cd=c.tier_group_cd
       AND tm.active_ind=1
       AND tm.tier_cell_type_cd=cs13036_perf_loc_cd
       AND tm.beg_effective_dt_tm <= c.service_dt_tm
       AND tm.end_effective_dt_tm >= c.service_dt_tm)
     DETAIL
      perflocationqualifierfound = true
     WITH nocounter
    ;end select
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Returning from CheckTierForPerfLocation, reply is: ",
       perflocationqualifierfound))
    ENDIF
    RETURN(perflocationqualifierfound)
  END ;Subroutine
 ENDIF
 IF (validate(checktierforproviderspec,char(128))=char(128))
  SUBROUTINE (checktierforproviderspec(chargeitemid=f8) =i2)
    DECLARE providerspecialtyqualifierfound = i2 WITH protect, noconstant(false)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering CheckTierForProviderSpec, charge_item_id is: ",chargeitemid))
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      tier_matrix tm
     PLAN (c
      WHERE c.charge_item_id=chargeitemid
       AND c.active_ind=1)
      JOIN (tm
      WHERE tm.tier_group_cd=c.tier_group_cd
       AND tm.active_ind=1
       AND tm.tier_cell_type_cd=cs13036_providerspc_cd
       AND tm.beg_effective_dt_tm <= c.service_dt_tm
       AND tm.end_effective_dt_tm >= c.service_dt_tm)
     DETAIL
      providerspecialtyqualifierfound = true
     WITH nocounter
    ;end select
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Returning from CheckTierForProviderSpec, reply is: ",
       providerspecialtyqualifierfound))
    ENDIF
    RETURN(providerspecialtyqualifierfound)
  END ;Subroutine
 ENDIF
 CALL echo("End including AFC_CHECK_TIER_QUAL_SUBS.INC")
 CALL echo("Begin including AFC_REPROCESS_RESEARCH_ACCT.INC, version [648814.001]")
 IF ( NOT (validate(cs13019_mod_rsn_cd)))
  DECLARE cs13019_mod_rsn_cd = f8 WITH protect, constant(getcodevalue(13019,"MOD RSN",0))
 ENDIF
 IF ( NOT (validate(cs4001989_modify_cd)))
  DECLARE cs4001989_modify_cd = f8 WITH protect, constant(getcodevalue(4001989,"MODIFY",0))
 ENDIF
 IF (validate(modifyresearchacct,char(128))=char(128))
  SUBROUTINE (modifyresearchacct(researchacctid=f8,chargeeventid=f8,chargeeventactid=f8,suspensersncd
   =f8,reasoncomment=vc) =i2)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("Entering modifyResearchAcct:"))
     CALL echo(build2("  researchAcctId is: ",researchacctid))
     CALL echo(build2("  chargeEventId is: ",chargeeventid))
     CALL echo(build2("  chargeEventActId is: ",chargeeventactid))
    ENDIF
    DECLARE previousresacctid = f8 WITH protect, noconstant(0.0)
    DECLARE existingchrgcnt = i4 WITH protect, noconstant(0)
    DECLARE existingchrgidx = i4 WITH protect, noconstant(0)
    DECLARE chrgpos = i4 WITH protect, noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE chrgcnt = i4 WITH protect, noconstant(0)
    DECLARE ichargecount = i4 WITH protect, noconstant(0)
    DECLARE ichargeloop = i4 WITH protect, noconstant(0)
    DECLARE iret = i4 WITH protect, noconstant(0)
    DECLARE dreprocess_cs13029 = f8 WITH protect, noconstant(0.0)
    DECLARE ireprocessappid = i4 WITH protect, noconstant(951020)
    DECLARE ireprocesstaskid = i4 WITH protect, noconstant(951020)
    DECLARE ireprocessreqid = i4 WITH protect, noconstant(951359)
    DECLARE happreprocess = i4 WITH protect, noconstant(0)
    DECLARE htaskreprocess = i4 WITH protect, noconstant(0)
    DECLARE hstepreprocess = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hlist = i4 WITH protect, noconstant(0)
    DECLARE hlist2 = i4 WITH protect, noconstant(0)
    DECLARE hreply = i4 WITH protect, noconstant(0)
    SET stat = uar_get_meaning_by_codeset(13029,"REPROCESS",1,dreprocess_cs13029)
    IF (stat != 0)
     CALL logmsg(curprog,
      "reprocessResearchAcct - Failed to find Reprocess code_value: dReprocess_CS13029.",log_debug)
     RETURN(false)
    ENDIF
    RECORD existingcharges(
      1 charge[*]
        2 charge_item_id = f8
    ) WITH protect
    RECORD reprocessreply(
      1 charge[*]
        2 charge_item_id = f8
        2 charge_type_cd = f8
        2 interface_id = f8
        2 offset_charge_item_id = f8
        2 process_flg = i2
        2 tier_group_cd = f8
        2 original_charge = i2
        2 parent_charge_item_id = f8
        2 payor_id = f8
    ) WITH protect
    RECORD addchargemodreqrc(
      1 charge_mod_qual = i2
      1 charge_mod[*]
        2 charge_mod_id = f8
        2 charge_item_id = f8
        2 charge_mod_type_cd = f8
        2 field1 = c200
        2 field2 = c200
        2 field3 = c200
        2 field4 = c200
        2 field5 = c200
        2 field6 = c200
        2 field7 = c200
        2 field8 = c200
        2 field9 = c200
        2 field10 = c200
        2 activity_dt_tm = dq8
        2 field1_id = f8
        2 field2_id = f8
        2 field3_id = f8
        2 field4_id = f8
        2 field5_id = f8
        2 nomen_id = f8
        2 cm1_nbr = f8
        2 active_ind_ind = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 active_status_dt_tm = dq8
        2 active_status_prsnl_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 action_type = c3
      1 skip_charge_event_mod_ind = i2
    ) WITH protect
    RECORD addchargemodreprc(
      1 charge_mod_qual = i2
      1 charge_mod[*]
        2 charge_mod_id = f8
        2 charge_item_id = f8
        2 charge_mod_type_cd = f8
        2 field1_id = f8
        2 field2_id = f8
        2 field3_id = f8
        2 field6 = vc
        2 field7 = vc
        2 nomen_id = f8
        2 action_type = c3
        2 nomen_entity_reltn_id = f8
        2 cm1_nbr = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD newcharges(
      1 numberofcharges = i4
      1 charges[*]
        2 charge_item_id = f8
        2 process_flg = i4
    ) WITH protect
    SELECT INTO "nl:"
     FROM charge_event ce
     WHERE ce.charge_event_id=chargeeventid
     DETAIL
      previousresacctid = ce.research_account_id
     WITH nocounter
    ;end select
    UPDATE  FROM charge_event ce
     SET ce.research_account_id =
      IF (researchacctid < 0) 0
      ELSE researchacctid
      ENDIF
      , ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_dt_tm = cnvtdatetime(sysdate),
      ce.updt_id = reqinfo->updt_id, ce.updt_task = reqinfo->updt_task, ce.updt_applctx = reqinfo->
      updt_applctx
     WHERE ce.charge_event_id=chargeeventid
     WITH nocounter
    ;end update
    SELECT INTO "nl:"
     FROM charge_event ce,
      charge c
     PLAN (ce
      WHERE ce.charge_event_id=chargeeventid)
      JOIN (c
      WHERE c.charge_event_id=ce.charge_event_id
       AND c.person_id=ce.person_id
       AND c.encntr_id=ce.encntr_id
       AND c.offset_charge_item_id=0
       AND c.active_ind=1)
     DETAIL
      existingchrgcnt += 1, stat = alterlist(existingcharges->charge,existingchrgcnt),
      existingcharges->charge[existingchrgcnt].charge_item_id = c.charge_item_id
     WITH nocounter
    ;end select
    CALL impersonatepersonnelinfo(1)
    SET iret = uar_crmbeginapp(ireprocessappid,happreprocess)
    IF (iret != 0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to begin App.",log_debug)
     RETURN(false)
    ENDIF
    SET iret = uar_crmbegintask(happreprocess,ireprocesstaskid,htaskreprocess)
    IF (iret != 0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to begin Task.",log_debug)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET iret = uar_crmbeginreq(htaskreprocess,"",ireprocessreqid,hstepreprocess)
    IF (iret != 0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to begin Step.",log_debug)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET hreq = uar_crmgetrequest(hstepreprocess)
    IF (hreq=0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to get request handle",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET stat = uar_srvsetshort(hreq,"charge_event_qual",1)
    SET stat = uar_srvsetdouble(hreq,"process_type_cd",dreprocess_cs13029)
    SET hlist = uar_srvadditem(hreq,"process_event")
    IF (hlist=0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to get process_event handle",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET stat = uar_srvsetdouble(hlist,"charge_event_id",chargeeventid)
    SET hlist2 = uar_srvadditem(hlist,"charge_acts")
    IF (hlist2=0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to get charge_acts handle",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET stat = uar_srvsetdouble(hlist2,"charge_event_act_id",chargeeventactid)
    COMMIT
    SET iret = uar_crmperform(hstepreprocess)
    IF (iret != 0)
     CALL logmsg(curprog,build("modifyResearchAcct - Server returned Failure. CRMSTAT:",iret),
      log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET hreply = uar_crmgetreply(hstepreprocess)
    IF (hreply=0)
     CALL logmsg(curprog,"modifyResearchAcct - Failed to get handle to Reply",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET ichargecount = uar_srvgetitemcount(hreply,"charges")
    IF (ichargecount=0)
     CALL logmsg(curprog,"modifyResearchAcct - Reply has no charges in it",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    SET stat = alterlist(reprocessreply->charge,ichargecount)
    SET stat = alterlist(addchargemodreqrc->charge_mod,ichargecount)
    SET addchargemodreqrc->charge_mod_qual = ichargecount
    SET chrgcnt = 0
    FOR (ichargeloop = 1 TO ichargecount)
      SET hlist = uar_srvgetitem(hreply,"charges",(ichargeloop - 1))
      IF (hlist=0)
       CALL logmsg(curprog,"modifyResearchAcct - Failed to get handle to reply's charge",log_debug)
       CALL uar_crmendreq(hstepreprocess)
       CALL uar_crmendtask(htaskreprocess)
       CALL uar_crmendapp(happreprocess)
       RETURN(false)
      ENDIF
      SET reprocessreply->charge[ichargeloop].charge_item_id = uar_srvgetdouble(hlist,
       "charge_item_id")
      SET reprocessreply->charge[ichargeloop].offset_charge_item_id = uar_srvgetdouble(hlist,
       "offset_charge_item_id")
      SET reprocessreply->charge[ichargeloop].process_flg = uar_srvgetshort(hlist,"process_flg")
      SET reprocessreply->charge[ichargeloop].interface_id = uar_srvgetdouble(hlist,"interface_id")
      SET reprocessreply->charge[ichargeloop].tier_group_cd = uar_srvgetdouble(hlist,"tier_group_cd")
      SET reprocessreply->charge[ichargeloop].charge_type_cd = uar_srvgetdouble(hlist,
       "charge_type_cd")
      SET reprocessreply->charge[ichargeloop].parent_charge_item_id = uar_srvgetdouble(hlist,
       "parent_charge_item_id")
      SET reprocessreply->charge[ichargeloop].payor_id = uar_srvgetdouble(hlist,"payor_id")
      SET existingchrgidx = locateval(chrgpos,1,size(existingcharges->charge,5),reprocessreply->
       charge[ichargeloop].charge_item_id,existingcharges->charge[chrgpos].charge_item_id)
      IF (existingchrgidx > 0)
       SET reprocessreply->charge[ichargeloop].original_charge = 1
      ELSE
       SET newcharges->numberofcharges += 1
       SET stat = alterlist(newcharges->charges,newcharges->numberofcharges)
       SET newcharges->charges[newcharges->numberofcharges].charge_item_id = reprocessreply->charge[
       ichargeloop].charge_item_id
       SET newcharges->charges[newcharges->numberofcharges].process_flg = reprocessreply->charge[
       ichargeloop].process_flg
      ENDIF
      SET addchargemodreqrc->charge_mod[ichargeloop].charge_item_id = reprocessreply->charge[
      ichargeloop].charge_item_id
      SET addchargemodreqrc->charge_mod[ichargeloop].charge_mod_type_cd = cs13019_mod_rsn_cd
      SET addchargemodreqrc->charge_mod[ichargeloop].field6 = "The research account was modified"
      SET addchargemodreqrc->charge_mod[ichargeloop].field7 = reasoncomment
      SET addchargemodreqrc->charge_mod[ichargeloop].field1_id = cs4001989_modify_cd
      SET addchargemodreqrc->charge_mod[ichargeloop].field2_id = suspensersncd
      SET addchargemodreqrc->charge_mod[ichargeloop].action_type = "ADD"
      CALL echorecord(addchargemodreqrc)
    ENDFOR
    IF (validate(action_begin))
     SET action_begin = 1
     SET action_end = addchargemodreqrc->charge_mod_qual
    ENDIF
    EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreqrc), replace("REPLY",
     addchargemodreprc)
    IF ((addchargemodreprc->status_data.status="F"))
     CALL logmsg(curprog,"modifyResearchAcct - Call to afc_add_charge_mod failed",log_debug)
     CALL uar_crmendreq(hstepreprocess)
     CALL uar_crmendtask(htaskreprocess)
     CALL uar_crmendapp(happreprocess)
     RETURN(false)
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL logmsg(curprog,"modifyResearchAcct - Reprocess Research Account reply",log_debug)
     CALL echorecord(reprocessreply)
    ENDIF
    SET stat = alterlist(reply->charge,size(newcharges->charges,5))
    SET reply->charge_qual = size(newcharges->charges,5)
    FOR (i = 1 TO size(newcharges->charges,5))
      SET reply->charge[i].charge_item_id = newcharges->charges[i].charge_item_id
    ENDFOR
    CALL uar_crmendreq(hstepreprocess)
    CALL uar_crmendtask(htaskreprocess)
    CALL uar_crmendapp(happreprocess)
    IF ( NOT (postresearchaccountcharges(newcharges)))
     CALL logmsg(curprog,"modifyResearchAcct - postResearchAccountCharges returned failure",log_debug
      )
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(postresearchaccountcharges,char(128))=char(128))
  SUBROUTINE (postresearchaccountcharges(chargestosend=vc(ref)) =i2)
    CALL logmsg(curprog,"Entering postResearchAccountCharges",log_debug)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE profitcnt = i4 WITH protect, noconstant(0)
    DECLARE invalidinterfacefilefound = i2 WITH protect, noconstant(false)
    RECORD profitcharges(
      1 cp_debug_ind = i2
      1 remove_commit_ind = i2
      1 charges[*]
        2 charge_item_id = f8
        2 reprocess_ind = i2
        2 dupe_ind = i2
    )
    RECORD profitchargesreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SELECT INTO "nl:"
     FROM charge c,
      interface_file i
     PLAN (c
      WHERE expand(idx,1,size(chargestosend->charges,5),c.charge_item_id,chargestosend->charges[idx].
       charge_item_id,
       0,chargestosend->charges[idx].process_flg))
      JOIN (i
      WHERE i.interface_file_id=c.interface_file_id)
     DETAIL
      IF (i.profit_type_cd > 0
       AND i.realtime_ind=1)
       invalidinterfacefilefound = true
      ELSEIF (i.profit_type_cd > 0)
       profitcnt += 1, stat = alterlist(profitcharges->charges,profitcnt), profitcharges->charges[
       profitcnt].charge_item_id = c.charge_item_id
      ENDIF
     WITH nocounter, expand = 2
    ;end select
    IF (invalidinterfacefilefound)
     CALL logmsg(curprog,"Exiting postResearchAccountCharges, Invalid Interface file found",log_debug
      )
     RETURN(false)
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL echo("postResearchAccountCharges - profitCharges")
     CALL echorecord(profitcharges)
    ENDIF
    IF (size(profitcharges->charges,5) > 0)
     IF (validate(researchacctpostchargessync,true))
      EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",profitcharges), replace("REPLY",
       profitchargesreply)
     ELSE
      EXECUTE pft_nt_post_charges_async  WITH replace("REQUEST",profitcharges), replace("REPLY",
       profitchargesreply)
     ENDIF
     IF ((profitchargesreply->status_data.status != "S"))
      CALL logmsg(curprog,"Exiting postResearchAccountCharges,failed to post the new charges",
       log_debug)
      RETURN(false)
     ELSE
      CALL logmsg(curprog,"pft_nt_post_charges_async/pft_nt_chrg_billing, returned success",log_debug
       )
     ENDIF
    ELSE
     CALL logmsg(curprog,"No charges qualified to be sent to be posted",log_debug)
    ENDIF
    COMMIT
    CALL logmsg(curprog,"Exiting postResearchAccountCharges, Successfully posted charges",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 CALL echo("End including AFC_REPROCESS_RESEARCH_ACCT.INC")
 CALL beginservice("CHARSGRV-11258.039")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 charge_qual = i2
    1 dequeued_ind = i2
    1 charge[*]
      2 charge_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  ) WITH protect
 ENDIF
 RECORD modifychargerequest(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_event_mod_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c200
     2 field4 = c200
     2 field5 = c200
     2 field6 = c200
     2 field7 = c200
     2 field8 = c200
     2 field9 = c200
     2 field10 = c200
     2 activity_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 cm1_nbr = f8
     2 code1_cd = f8
     2 action_type = vc
     2 charge_mod_source_cd = f8
   1 skip_charge_event_mod_ind = i2
 ) WITH protect
 RECORD modifychargereply(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
     2 nomen_id = f8
     2 action_type = c3
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
     2 field4_id = f8
     2 field5_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 ) WITH protect
 RECORD creditchargerequest(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 ) WITH protect
 RECORD creditchargereply(
   1 charge_qual = i2
   1 dequeued_ind = i2
   1 charge[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 ord_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 charge_type_disp = c40
     2 charge_type_desc = c60
     2 charge_type_mean = c12
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 suspense_rsn_disp = c40
     2 suspense_rsn_desc = c60
     2 suspense_rsn_mean = c12
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 price_sched_id = f8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 username = vc
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 bundle_id = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 inst_fin_nbr = c50
     2 cost_center_cd = f8
     2 cost_center_disp = c40
     2 cost_center_desc = c60
     2 cost_center_mean = c12
     2 abn_status_cd = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 payor_type_cd = f8
     2 item_reimbursement = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 list_price_sched_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 interface_flag = i2
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
       3 active_ind = i2
   1 original_charge_qual = i2
   1 original_charge[*]
     2 charge_item_id = f8
     2 process_flg = f8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD addchargedetailsrequest(
   1 objarray[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 payor_id = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 verify_phys_id = f8
     2 def_bill_item_id = f8
     2 verfify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 activity_type_cd = f8
     2 activity_dt_tm = dq8
     2 admit_type_cd = f8
     2 bundle_id = f8
     2 department_cd = f8
     2 institution_cd = f8
     2 level5_cd = f8
     2 med_service_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 abn_status_cd = f8
     2 cost_center_cd = f8
     2 inst_fin_nbr = c50
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 item_reimbursement = f8
     2 list_price_sched_id = f8
     2 payor_type_cd = f8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 server_process_flag = i2
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 alpha_nomen_id = f8
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 activity_dt_tm = dq8
       3 updt_cnt = i2
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_task = i4
       3 updt_applctx = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 code1_cd = f8
       3 nomen_id = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 cm1_nbr = f8
     2 offset_charge_item_id = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
 ) WITH protect
 RECORD addchargedetailsreply(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD cm_request(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 activity_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = f8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
     2 updt_cnt = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 ) WITH protect
 RECORD cm_reply(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
     2 nomen_id = f8
     2 action_type = c3
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
     2 field4_id = f8
     2 field5_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 ) WITH protect
 RECORD reproc_request(
   1 process_type_cd = f8
   1 charge_event_qual = i2
   1 process_event[*]
     2 charge_event_id = f8
     2 charge_acts[*]
       3 charge_event_act_id = f8
     2 charge_item_qual = i2
     2 charge_item[*]
       3 charge_item_id = f8
     2 ignored_event_mod_qual = i2
     2 ignored_event_mod[*]
       3 field6 = vc
     2 ignored_charge_mod_qual = i2
     2 ignored_charge_mod[*]
       3 field6 = vc
 ) WITH protect
 RECORD syncrelease_reply(
   1 charge_items[*]
     2 charge_item_id = f8
 ) WITH protect
 RECORD chargefind_request(
   1 charge_item_id = f8
 ) WITH protect
 RECORD chargefind_reply(
   1 charge_item_count = i4
   1 charge_items[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 username = vc
     2 payor_id = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 activity_type_cd = f8
     2 admit_type_cd = f8
     2 bundle_id = f8
     2 department_cd = f8
     2 institution_cd = f8
     2 level5_cd = f8
     2 med_service_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 abn_status_cd = f8
     2 cost_center_cd = f8
     2 inst_fin_nbr = vc
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 item_reimbursement = f8
     2 list_price_sched_id = f8
     2 payor_type_cd = f8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 offset_charge_item_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 charge_mod_count = i4
     2 charge_mods[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD afcprofit_request(
   1 remove_commit_ind = i2
   1 end_on_first_suspend_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 ) WITH protect
 RECORD afcprofit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
   1 charges[*]
     2 charge_item_id = f8
     2 ar_acct_id = f8
     2 rev_acct_id = f8
     2 pft_encntr_id = f8
     2 pft_charge_id = f8
     2 self_pay_benefit_order_id = f8
     2 non_self_pay_benefit_order_id = f8
     2 process_flg = i4
     2 suspense_reason_cd = f8
     2 error_prog = vc
     2 error_sub = vc
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD chargemod(
   1 modifierslist[*]
     2 field6 = vc
     2 field2_id = f8
 ) WITH protect
 RECORD chargediagnosisdetail(
   1 diagnosislist[*]
     2 field2_id = f8
     2 field6 = vc
 ) WITH protect
 RECORD addchargeeventmodreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD addchargeeventmodrep(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD uptchargeeventmodreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD uptchargeeventmodrep(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD publishupdatedchargerequest(
   1 charges[*]
     2 charge_item_id = f8
 ) WITH protect
 DECLARE inactivateparentcodes(dummyvar=i2) = i2
 DECLARE chrgmodcnt = i4 WITH protect, noconstant(0)
 DECLARE pending_status = i4 WITH protect, constant(0)
 DECLARE itc = f8 WITH noconstant(0.0)
 DECLARE dquantity = f8 WITH noconstant(0.0)
 DECLARE reprocessind = i2 WITH noconstant(0)
 DECLARE reprocessmodind = i2 WITH noconstant(0)
 DECLARE pftind = i2 WITH noconstant(0)
 DECLARE action_begin = i4 WITH protect, noconstant(0)
 DECLARE action_end = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH noconstant(0)
 DECLARE cptmodcnt = i4 WITH noconstant(0)
 DECLARE changeind = i2 WITH noconstant(false)
 DECLARE physicianmodification = i2 WITH noconstant(false)
 DECLARE cvs14002_afc_schedule_type = f8 WITH protect, constant(14002.0)
 DECLARE icdcodecnt = i4 WITH noconstant(0)
 DECLARE researchacctpostchargessync = i2 WITH protect, constant(true)
 DECLARE postedflag = i4 WITH protect, constant(100)
 IF ( NOT (validate(cs13028_cr_cd)))
  DECLARE cs13028_cr_cd = f8 WITH protect, constant(getcodevalue(13028,"CR",0))
 ENDIF
 IF ( NOT (validate(cs13028_dr_cd)))
  DECLARE cs13028_dr_cd = f8 WITH protect, constant(getcodevalue(13028,"DR",0))
 ENDIF
 IF ( NOT (validate(cs13019_flex_cd)))
  DECLARE cs13019_flex_cd = f8 WITH protect, constant(getcodevalue(13019,"FLEX",0))
 ENDIF
 IF ( NOT (validate(cs13019_mod_rsn_cd)))
  DECLARE cs13019_mod_rsn_cd = f8 WITH protect, constant(getcodevalue(13019,"MOD RSN",0))
 ENDIF
 IF ( NOT (validate(cs13019_changelog_cd)))
  DECLARE cs13019_changelog_cd = f8 WITH protect, constant(getcodevalue(13019,"CHANGELOG",0))
 ENDIF
 IF ( NOT (validate(cs4001989_modify_cd)))
  DECLARE cs4001989_modify_cd = f8 WITH protect, constant(getcodevalue(4001989,"MODIFY",0))
 ENDIF
 IF ( NOT (validate(cs13029_verified_cd)))
  DECLARE cs13029_verified_cd = f8 WITH protect, constant(getcodevalue(13029,"VERIFIED",0))
 ENDIF
 IF ( NOT (validate(cs13029_ordered_cd)))
  DECLARE cs13029_ordered_cd = f8 WITH protect, constant(getcodevalue(13029,"ORDERED",0))
 ENDIF
 IF ( NOT (validate(cs13019_suspense_cd)))
  DECLARE cs13019_suspense_cd = f8 WITH protect, constant(getcodevalue(13019,"SUSPENSE",0))
 ENDIF
 IF ( NOT (validate(cs13029_released_cd)))
  DECLARE cs13029_released_cd = f8 WITH protect, constant(getcodevalue(13029,"RELEASED",0))
 ENDIF
 IF ( NOT (validate(cs48_active_code)))
  DECLARE cs48_active_code = f8 WITH protect, constant(getcodevalue(48,"ACTIVE",0))
 ENDIF
 IF ( NOT (validate(cs13019_bill_code)))
  DECLARE cs13019_bill_code = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs13030_partial_credit)))
  DECLARE cs13030_partial_credit = f8 WITH protect, constant(getcodevalue(13030,"PARTCREDIT",0))
 ENDIF
 IF ( NOT (validate(cs4518006_ref_data)))
  DECLARE cs4518006_ref_data = f8 WITH protect, constant(getcodevalue(4518006,"REF_DATA",0))
 ENDIF
 IF ( NOT (validate(cs4518006_manually_add)))
  DECLARE cs4518006_manually_add = f8 WITH protect, constant(getcodevalue(4518006,"MANUALLY_ADD",0))
 ENDIF
 IF ( NOT (validate(cs222_facility_cd)))
  DECLARE cs222_facility_cd = f8 WITH protect, constant(getcodevalue(222,"FACILITY",1))
 ENDIF
 IF ( NOT (validate(cs222_building_cd)))
  DECLARE cs222_building_cd = f8 WITH protect, constant(getcodevalue(222,"BUILDING",1))
 ENDIF
 IF ( NOT (validate(cs222_nurseunit_cd)))
  DECLARE cs222_nurseunit_cd = f8 WITH protect, constant(getcodevalue(222,"NURSEUNIT",1))
 ENDIF
 IF ( NOT (validate(cs222_ambulatory_cd)))
  DECLARE cs222_ambulatory_cd = f8 WITH protect, constant(getcodevalue(222,"AMBULATORY",1))
 ENDIF
 IF ( NOT (validate(cs222_room_cd)))
  DECLARE cs222_room_cd = f8 WITH protect, constant(getcodevalue(222,"ROOM",1))
 ENDIF
 IF ( NOT (validate(cs222_bed_cd)))
  DECLARE cs222_bed_cd = f8 WITH protect, constant(getcodevalue(222,"BED",1))
 ENDIF
 IF ((request->chargeid <= 0.0))
  CALL exitservicefailure("ChargeId is required",true)
 ENDIF
 IF ( NOT (evaluatechargeformodification(0)))
  CALL exitservicefailure("Failed to evaluate charge for modification",true)
 ENDIF
 IF ( NOT (findcharge(0)))
  CALL exitservicefailure("Failed to find charge Details",true)
 ENDIF
 IF ((((request->researchaccountid > 0)
  AND (request->researchaccountid != chargefind_reply->charge_items[1].research_acct_id)) OR ((
 request->researchaccountid=0)
  AND (chargefind_reply->charge_items[1].research_acct_id > 0))) )
  IF ( NOT (modifyresearchacct(request->researchaccountid,chargefind_reply->charge_items[1].
   charge_event_id,chargefind_reply->charge_items[1].charge_event_act_id,request->suspensersncd,
   request->reasoncomment)))
   CALL echo("ModifyResearchAcct was not successful.")
   SET reply->status_data.status = "F"
   CALL exitservicefailure("Failed to modify the research account",true)
  ELSE
   CALL echo("ModifyResearchAcct was successful.")
   SET reply->status_data.status = "S"
   CALL exitservicesuccess("")
  ENDIF
  GO TO end_program
 ENDIF
 IF ((chargefind_reply->charge_items[1].item_interval_id <= 0))
  SELECT INTO "nl:"
   FROM price_sched_items psi
   WHERE (psi.bill_item_id=chargefind_reply->charge_items[1].bill_item_id)
    AND (psi.price_sched_id=chargefind_reply->charge_items[1].price_sched_id)
    AND psi.beg_effective_dt_tm <= cnvtdatetime(chargefind_reply->charge_items[1].service_dt_tm)
    AND psi.end_effective_dt_tm >= cnvtdatetime(chargefind_reply->charge_items[1].service_dt_tm)
    AND psi.active_ind=1
   DETAIL
    itc = psi.interval_template_cd
   WITH nocounter
  ;end select
 ENDIF
 CALL loadchargerequest(0)
 IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)) OR (itc > 0)) )
  SELECT INTO "nl:"
   FROM charge_event_act cea
   WHERE (cea.charge_event_act_id=chargefind_reply->charge_items[1].charge_event_act_id)
   DETAIL
    dquantity = cea.quantity
   WITH nocounter
  ;end select
 ELSE
  SET dquantity = chargefind_reply->charge_items[1].item_quantity
 ENDIF
 IF ((( NOT (isequal(request->billitemquantity,dquantity))) OR ((((request->chargedescription !=
 chargefind_reply->charge_items[1].charge_description)) OR ((request->itemprice != chargefind_reply->
 charge_items[1].item_price))) )) )
  IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)) OR (itc > 0)) )
   SET reprocessind = 1
  ENDIF
 ENDIF
 SET reprocessmodind = checkforcptmodifierchange(0)
 SET physicianmodification = updatephysandabnstatusresearchaccount(0)
 IF (((reprocessind) OR (((reprocessmodind) OR (((physicianmodification) OR (uar_get_code_meaning(
  chargefind_reply->charge_items[1].activity_type_cd)="PHARMACY")) )) )) )
  IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)) OR (itc > 0)) )
   CALL get_all_related_charges(0)
  ENDIF
  UPDATE  FROM charge_event_act cea
   SET cea.quantity = request->billitemquantity, cea.item_price = request->itemprice, cea
    .item_ext_price = (request->billitemquantity * request->itemprice),
    cea.updt_id = reqinfo->updt_id, cea.updt_applctx = reqinfo->updt_applctx, cea.updt_task = reqinfo
    ->updt_task,
    cea.updt_cnt = (cea.updt_cnt+ 1), cea.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE (cea.charge_event_act_id=chargefind_reply->charge_items[1].charge_event_act_id)
  ;end update
 ENDIF
 IF ( NOT (createnewcreditcharge(0)))
  CALL exitservicefailure("Failed to create the credit charge",true)
 ENDIF
 FOR (cnt2 = 1 TO size(addchargedetailsrequest->objarray,5))
  SET addchargedetailsrequest->objarray[cnt2].parent_charge_item_id = addchargedetailsrequest->
  objarray[cnt2].charge_item_id
  SET addchargedetailsrequest->objarray[cnt2].charge_item_id = 0.0
 ENDFOR
 IF ( NOT (createnewdebitcharge(0)))
  CALL exitservicefailure("Failed to create the debit charge",true)
 ENDIF
 IF ( NOT (postcharges(afcprofit_request,afcprofit_reply)))
  CALL exitservicefailure("Failed to post the charges",true)
 ENDIF
 IF (size(publishupdatedchargerequest->charges,5) > 0)
  IF ( NOT (publisheventforchargeupdate(publishupdatedchargerequest,postedflag)))
   CALL logmsg(curprog,"Failed to publish the Charge Update Event",log_debug)
  ENDIF
 ENDIF
 CALL exitservicesuccess("")
#end_program
#exit_script
 IF (validate(debug) > 0)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD modifychargerequest
 FREE RECORD modifychargereply
 FREE RECORD publishupdatedchargerequest
 SUBROUTINE (evaluatechargeformodification(dummyvar=i2) =i2)
   CALL logmessage(curprog,"Entering...evaluateChargeForModification",log_debug)
   DECLARE statusind = i2 WITH protect, noconstant(false)
   DECLARE posted_status = i4 WITH protect, noconstant(100)
   SELECT INTO "nl:"
    FROM charge c
    WHERE (c.charge_item_id=request->chargeid)
     AND c.process_flg=posted_status
     AND c.offset_charge_item_id=0.0
     AND ((c.active_ind+ 0)=true)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL logmessage(curprog,"evaluateChargeForModification - Failed to validate charge",log_debug)
   ELSE
    SET statusind = true
   ENDIF
   CALL logmessage(curprog,"evaluateChargeForModification Exiting...",log_debug)
   RETURN(statusind)
 END ;Subroutine
 SUBROUTINE findcharge(dummyvar)
   CALL logmessage(curprog,"Executing AFC_CHARGE_FIND",log_debug)
   SET chargefind_request->charge_item_id = request->chargeid
   EXECUTE afc_charge_find  WITH replace("REQUEST",chargefind_request), replace("REPLY",
    chargefind_reply)
   IF ((chargefind_reply->status_data.status != "S"))
    RETURN(false)
   ENDIF
   CALL logmessage(curprog,"Exiting AFC_CHARGE_FIND",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (createnewcreditcharge(dummyvar=i2) =i2)
   CALL logmessage(curprog,"createNewCreditCharge - Entering...",log_debug)
   DECLARE pending_status = i4 WITH protect, noconstant(0)
   DECLARE pftind = i4 WITH noconstant(0)
   DECLARE rtcnt = i4 WITH noconstant(0)
   DECLARE cnt2 = i4 WITH noconstant(0)
   FOR (cnt2 = 1 TO size(addchargedetailsrequest->objarray,5))
     IF ((addchargedetailsrequest->objarray[cnt2].charge_item_id > 0.0))
      SET stat = alterlist(creditchargerequest->charge,cnt2)
      SET creditchargerequest->charge[cnt2].charge_item_id = addchargedetailsrequest->objarray[cnt2].
      charge_item_id
      SET creditchargerequest->charge[cnt2].suspense_rsn_cd = request->suspensersncd
      SET creditchargerequest->charge[cnt2].reason_comment = request->reasoncomment
     ENDIF
   ENDFOR
   SET creditchargerequest->charge_qual = size(addchargedetailsrequest->objarray,5)
   CALL echo(build("creditChargeRequest->charge_qual:",creditchargerequest->charge_qual))
   IF (((reprocessind=1) OR (((reprocessmodind=1) OR (physicianmodification)) )) )
    CALL getduplicateaddonforcredit(0)
   ENDIF
   EXECUTE afc_add_credit  WITH replace("REQUEST",creditchargerequest), replace("REPLY",
    creditchargereply)
   IF ((creditchargereply->status_data.status != "S"))
    RETURN(false)
   ENDIF
   SET pftind = size(afcprofit_request->charges,5)
   SELECT INTO "nl:"
    FROM interface_file i,
     (dummyt d1  WITH seq = value(size(creditchargereply->charge,5)))
    PLAN (d1)
     JOIN (i
     WHERE (i.interface_file_id=creditchargereply->charge[d1.seq].interface_file_id))
    DETAIL
     IF (i.profit_type_cd > 0
      AND (creditchargereply->charge[d1.seq].charge_item_id > 0.0))
      pftind += 1, stat = alterlist(afcprofit_request->charges,pftind), afcprofit_request->charges[
      pftind].charge_item_id = creditchargereply->charge[d1.seq].charge_item_id
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage(curprog,"createNewCreditCharge Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getduplicateaddonforcredit(dummy=i2) =null)
   DECLARE crchrgcount = i4 WITH protect, noconstant(0.0)
   DECLARE cs13028_debit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"DR"))
   DECLARE bill_item_ext_owner_cd = f8 WITH protect, noconstant(0.0)
   IF ( NOT (validate(cs106_genericaddon)))
    DECLARE cs106_genericaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD GEN",0))
   ENDIF
   IF ( NOT (validate(cs106_specificaddon)))
    DECLARE cs106_specificaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD SPEC",0))
   ENDIF
   IF ( NOT (validate(cs106_defaultaddon)))
    DECLARE cs106_defaultaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD DEF",0))
   ENDIF
   IF ( NOT (validate(cs13019_add_on_cd)))
    DECLARE cs13019_add_on_cd = f8 WITH protect, constant(getcodevalue(13019,"ADD ON",0))
   ENDIF
   SET crchrgcount = creditchargerequest->charge_qual
   SELECT INTO "nl:"
    FROM charge c,
     bill_item b
    PLAN (c
     WHERE (c.charge_item_id=request->chargeid)
      AND c.active_ind=true)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
    DETAIL
     bill_item_ext_owner_cd = b.ext_owner_cd
    WITH nocounter
   ;end select
   IF (bill_item_ext_owner_cd=cs106_genericaddon)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build(
       "getDuplicateAddonForCredit(): Charge is a Generic ADD-ON. Returning from subroutine"))
    ENDIF
    RETURN(null)
   ELSEIF (bill_item_ext_owner_cd=cs106_specificaddon)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build(
       "getDuplicateAddonForCredit(): Charge is a Specific ADD-ON. Returning from subroutine"))
    ENDIF
    RETURN(null)
   ELSEIF (bill_item_ext_owner_cd=cs106_defaultaddon)
    IF (validate(debug,- (1)) > 0)
     CALL echo(build(
       "getDuplicateAddonForCredit(): Charge is a Default ADD-ON. Returning from subroutine"))
    ENDIF
    RETURN(null)
   ELSE
    SELECT INTO "nl:"
     FROM charge c,
      bill_item b,
      bill_item_modifier bim,
      charge c2
     PLAN (c
      WHERE (c.charge_event_id=chargefind_reply->charge_items[1].charge_event_id))
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
      JOIN (bim
      WHERE bim.key1_id=b.bill_item_id
       AND bim.key2_id=cs106_defaultaddon
       AND bim.bill_item_type_cd=cs13019_add_on_cd
       AND bim.active_ind=1)
      JOIN (c2
      WHERE c2.bill_item_id=b.bill_item_id
       AND (c2.charge_item_id=request->chargeid))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     IF (validate(debug,- (1)) > 0)
      CALL echo(build(
        "getDuplicateAddonForCredit(): Charge is a Default ADD-ON. Returning from subroutine"))
     ENDIF
     RETURN(null)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM charge c,
     bill_item b
    PLAN (c
     WHERE (c.charge_item_id != request->chargeid)
      AND (c.charge_event_id=chargefind_reply->charge_items[1].charge_event_id)
      AND (c.tier_group_cd=chargefind_reply->charge_items[1].tier_group_cd)
      AND c.active_ind=1
      AND c.charge_type_cd=cs13028_debit_cd
      AND c.offset_charge_item_id=0
      AND c.process_flg != 1)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id
      AND b.active_ind=1
      AND ((b.ext_owner_cd=cs106_genericaddon) OR (((b.ext_owner_cd=cs106_specificaddon) OR (b
     .ext_owner_cd=cs106_defaultaddon)) )) )
    DETAIL
     crchrgcount += 1, stat = alterlist(creditchargerequest->charge,crchrgcount), creditchargerequest
     ->charge[crchrgcount].charge_item_id = c.charge_item_id,
     creditchargerequest->charge[crchrgcount].late_charge_processing_ind = 0.0, creditchargerequest->
     charge[crchrgcount].reason_comment = request->reasoncomment, creditchargerequest->charge[
     crchrgcount].suspense_rsn_cd = request->suspensersncd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM charge c,
     bill_item b,
     bill_item_modifier bim
    PLAN (c
     WHERE (c.charge_item_id != request->chargeid)
      AND (c.charge_event_id=chargefind_reply->charge_items[1].charge_event_id)
      AND (c.tier_group_cd=chargefind_reply->charge_items[1].tier_group_cd)
      AND c.active_ind=1
      AND c.charge_type_cd=cs13028_debit_cd
      AND c.offset_charge_item_id=0
      AND c.process_flg != 1)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
     JOIN (bim
     WHERE bim.key1_id=b.bill_item_id
      AND bim.key2_id=cs106_defaultaddon
      AND bim.bill_item_type_cd=cs13019_add_on_cd
      AND bim.active_ind=1)
    DETAIL
     crchrgcount += 1, stat = alterlist(creditchargerequest->charge,crchrgcount), creditchargerequest
     ->charge[crchrgcount].charge_item_id = c.charge_item_id,
     creditchargerequest->charge[crchrgcount].late_charge_processing_ind = 0.0, creditchargerequest->
     charge[crchrgcount].reason_comment = request->reasoncomment, creditchargerequest->charge[
     crchrgcount].suspense_rsn_cd = request->suspensersncd
    WITH nocounter
   ;end select
   SET creditchargerequest->charge_qual = crchrgcount
 END ;Subroutine
 SUBROUTINE (createnewdebitcharge(dummyvar=i2) =i2)
   CALL logmessage(curprog,"createNewDebitCharge Entering...",log_debug)
   DECLARE new_cem_id = f8 WITH noconstant(0.0)
   DECLARE counter1 = i4 WITH noconstant(0)
   DECLARE chargepos = i4 WITH noconstant(0)
   DECLARE chargecnt = i4 WITH noconstant(0)
   DECLARE cptmodifiercnt = i4 WITH noconstant(0)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE modifierpos = i4 WITH noconstant(0)
   DECLARE icdidx = i4 WITH noconstant(0)
   DECLARE icdpos = i4 WITH noconstant(0)
   DECLARE i = i4 WITH noconstant(0)
   IF (((reprocessind=1) OR (((physicianmodification) OR (reprocessmodind=1)) )) )
    SET addchargedetailsrequest->objarray[1].server_process_flag = 0
   ENDIF
   EXECUTE afc_add_charge  WITH replace("REQUEST",addchargedetailsrequest), replace("REPLY",
    addchargedetailsreply)
   IF ((addchargedetailsreply->status_data.status != "S"))
    CALL logmessage(curprog,"afc_add_charge did not return success",log_debug)
    RETURN(false)
   ENDIF
   CALL loadflexfielddataforchargerequest(0)
   CALL loadbillcodedetails(0)
   CALL loadchargemodifierswithoutflexfields(0)
   CALL loadcptmodifiers(0)
   IF ( NOT (loaddiagnosisdetail(0)))
    CALL logmessage(curprog,"No Diagnosis details present",log_debug)
   ENDIF
   IF ((modifychargerequest->charge_mod_qual > 0))
    DECLARE billcdcnt = i4 WITH protect, noconstant(0)
    DECLARE billcdcnt2 = i4 WITH protect, noconstant(0)
    FOR (i = 1 TO modifychargerequest->charge_mod_qual)
      SET codeset14002meaning = uar_get_code_meaning(modifychargerequest->charge_mod[i].field1_id)
      SET codeset13019meaning = uar_get_code_meaning(modifychargerequest->charge_mod[i].
       charge_mod_type_cd)
      SET codeset4518006meaning = uar_get_code_meaning(modifychargerequest->charge_mod[i].
       charge_mod_source_cd)
      IF (((codeset14002meaning="ICD9") OR (((codeset14002meaning="MODIFIER"
       AND codeset4518006meaning != "MANUALLY_ADD") OR (((codeset13019meaning="FLEX") OR (
      codeset14002meaning="NDC")) )) )) )
       SET changeind = false
       IF (codeset14002meaning="MODIFIER")
        SET cptmodcnt += 1
        SET modifierpos = locateval(idx,1,size(chargemod->modifierslist,5),modifychargerequest->
         charge_mod[i].field6,chargemod->modifierslist[idx].field6)
        IF (modifierpos=0)
         SET changeind = true
        ENDIF
       ELSEIF (codeset14002meaning="ICD9")
        SET icdcodecnt += 1
        SET icdpos = locateval(icdidx,1,size(chargediagnosisdetail->diagnosislist,5),
         modifychargerequest->charge_mod[i].field6,chargediagnosisdetail->diagnosislist[icdidx].
         field6,
         modifychargerequest->charge_mod[i].field2_id,chargediagnosisdetail->diagnosislist[icdidx].
         field2_id)
        IF (icdpos=0)
         SET changeind = true
        ENDIF
       ELSE
        SET changeind = true
       ENDIF
       IF (changeind)
        IF ((modifychargerequest->charge_mod[i].charge_event_mod_id=0.0))
         SELECT INTO "nl:"
          cc = seq(charge_event_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_cem_id = cnvtreal(cc)
          WITH format, counter
         ;end select
         SET modifychargerequest->charge_mod[i].charge_event_mod_id = new_cem_id
         SET billcdcnt += 1
         SET stat = alterlist(addchargeeventmodreq->objarray,billcdcnt)
         SET addchargeeventmodreq->objarray[billcdcnt].action_type = "ADD"
         SET addchargeeventmodreq->objarray[billcdcnt].charge_event_mod_id = new_cem_id
         SET addchargeeventmodreq->objarray[billcdcnt].charge_event_id = chargefind_reply->
         charge_items[1].charge_event_id
         SET addchargeeventmodreq->objarray[billcdcnt].charge_event_mod_type_cd = modifychargerequest
         ->charge_mod[i].charge_mod_type_cd
         SET addchargeeventmodreq->objarray[billcdcnt].field6 = modifychargerequest->charge_mod[i].
         field6
         SET addchargeeventmodreq->objarray[billcdcnt].field7 = modifychargerequest->charge_mod[i].
         field7
         SET addchargeeventmodreq->objarray[billcdcnt].nomen_id = modifychargerequest->charge_mod[i].
         nomen_id
         SET addchargeeventmodreq->objarray[billcdcnt].field1_id = modifychargerequest->charge_mod[i]
         .field1_id
         SET addchargeeventmodreq->objarray[billcdcnt].field2_id = modifychargerequest->charge_mod[i]
         .field2_id
         SET addchargeeventmodreq->objarray[billcdcnt].field3_id = modifychargerequest->charge_mod[i]
         .field3_id
         SET addchargeeventmodreq->objarray[billcdcnt].field4_id = modifychargerequest->charge_mod[i]
         .field4_id
         SET addchargeeventmodreq->objarray[billcdcnt].field5_id = modifychargerequest->charge_mod[i]
         .field5_id
         SET addchargeeventmodreq->objarray[billcdcnt].updt_cnt = 0
         SET addchargeeventmodreq->objarray[billcdcnt].active_ind = 1
         SET addchargeeventmodreq->objarray[billcdcnt].active_status_dt_tm = cnvtdatetime(sysdate)
         SET addchargeeventmodreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
         SET addchargeeventmodreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime(
          "31-dec-2100 23:59:59")
         SET addchargeeventmodreq->objarray[billcdcnt].field1 = modifychargerequest->charge_mod[i].
         field1
         SET addchargeeventmodreq->objarray[billcdcnt].field2 = modifychargerequest->charge_mod[i].
         field2
         SET addchargeeventmodreq->objarray[billcdcnt].activity_dt_tm = cnvtdatetime(
          modifychargerequest->charge_mod[i].activity_dt_tm)
         SET addchargeeventmodreq->objarray[billcdcnt].cm1_nbr = modifychargerequest->charge_mod[i].
         cm1_nbr
         SET addchargeeventmodreq->objarray[billcdcnt].code1_cd = modifychargerequest->charge_mod[i].
         code1_cd
        ELSE
         SET billcdcnt2 += 1
         SET stat = alterlist(uptchargeeventmodreq->objarray,billcdcnt2)
         SELECT INTO "nl:"
          FROM charge_event_mod cem
          WHERE (cem.charge_event_mod_id=modifychargerequest->charge_mod[i].charge_event_mod_id)
          DETAIL
           uptchargeeventmodreq->objarray[billcdcnt2].action_type = "UPT", uptchargeeventmodreq->
           objarray[billcdcnt2].charge_event_mod_id = modifychargerequest->charge_mod[i].
           charge_event_mod_id, uptchargeeventmodreq->objarray[billcdcnt2].charge_event_id = cem
           .charge_event_id,
           uptchargeeventmodreq->objarray[billcdcnt2].charge_event_mod_type_cd = modifychargerequest
           ->charge_mod[i].charge_mod_type_cd, uptchargeeventmodreq->objarray[billcdcnt2].field3 =
           cem.field3, uptchargeeventmodreq->objarray[billcdcnt2].field4 = cem.field4,
           uptchargeeventmodreq->objarray[billcdcnt2].field5 = cem.field5, uptchargeeventmodreq->
           objarray[billcdcnt2].field6 = modifychargerequest->charge_mod[i].field6,
           uptchargeeventmodreq->objarray[billcdcnt2].field7 = modifychargerequest->charge_mod[i].
           field7,
           uptchargeeventmodreq->objarray[billcdcnt2].field8 = cem.field8, uptchargeeventmodreq->
           objarray[billcdcnt2].field9 = cem.field9, uptchargeeventmodreq->objarray[billcdcnt2].
           field10 = cem.field10,
           uptchargeeventmodreq->objarray[billcdcnt2].nomen_id = modifychargerequest->charge_mod[i].
           nomen_id, uptchargeeventmodreq->objarray[billcdcnt2].field1_id = modifychargerequest->
           charge_mod[i].field1_id, uptchargeeventmodreq->objarray[billcdcnt2].field2_id =
           modifychargerequest->charge_mod[i].field2_id,
           uptchargeeventmodreq->objarray[billcdcnt2].field3_id = modifychargerequest->charge_mod[i].
           field3_id, uptchargeeventmodreq->objarray[billcdcnt2].field4_id = modifychargerequest->
           charge_mod[i].field4_id, uptchargeeventmodreq->objarray[billcdcnt2].field5_id =
           modifychargerequest->charge_mod[i].field5_id,
           uptchargeeventmodreq->objarray[billcdcnt2].updt_cnt = cem.updt_cnt, uptchargeeventmodreq->
           objarray[billcdcnt2].active_ind = 1, uptchargeeventmodreq->objarray[billcdcnt2].
           active_status_cd = cem.active_status_cd,
           uptchargeeventmodreq->objarray[billcdcnt2].active_status_prsnl_id = reqinfo->updt_id,
           uptchargeeventmodreq->objarray[billcdcnt2].active_status_dt_tm = cem.active_status_dt_tm,
           uptchargeeventmodreq->objarray[billcdcnt2].beg_effective_dt_tm = cem.beg_effective_dt_tm,
           uptchargeeventmodreq->objarray[billcdcnt2].end_effective_dt_tm = cem.end_effective_dt_tm
           IF (validate(modifychargerequest->charge_mod[i].field1,char(128)) != char(128))
            uptchargeeventmodreq->objarray[billcdcnt2].field1 = modifychargerequest->charge_mod[i].
            field1
           ELSE
            uptchargeeventmodreq->objarray[billcdcnt2].field1 = cem.field1
           ENDIF
           IF (validate(modifychargerequest->charge_mod[i].field2,char(128)) != char(128))
            uptchargeeventmodreq->objarray[billcdcnt2].field2 = modifychargerequest->charge_mod[i].
            field2
           ELSE
            uptchargeeventmodreq->objarray[billcdcnt2].field2 = cem.field2
           ENDIF
           IF (validate(modifychargerequest->charge_mod[i].activity_dt_tm,0.0) > 0.0)
            uptchargeeventmodreq->objarray[billcdcnt2].activity_dt_tm = cnvtdatetime(
             modifychargerequest->charge_mod[i].activity_dt_tm)
           ELSE
            uptchargeeventmodreq->objarray[billcdcnt2].activity_dt_tm = cem.activity_dt_tm
           ENDIF
           IF ((validate(modifychargerequest->charge_mod[i].cm1_nbr,- (0.00001)) != - (0.00001)))
            uptchargeeventmodreq->objarray[billcdcnt2].cm1_nbr = modifychargerequest->charge_mod[i].
            cm1_nbr
           ELSE
            uptchargeeventmodreq->objarray[billcdcnt2].cm1_nbr = cem.cm1_nbr
           ENDIF
           IF ((validate(modifychargerequest->charge_mod[i].code1_cd,- (0.00001)) != - (0.00001)))
            uptchargeeventmodreq->objarray[billcdcnt2].code1_cd = modifychargerequest->charge_mod[i].
            code1_cd
           ELSE
            uptchargeeventmodreq->objarray[billcdcnt2].code1_cd = cem.code1_cd
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
      ELSEIF (codeset14002meaning="MODIFIER"
       AND codeset4518006meaning="MANUALLY_ADD")
       SET modifierpos = locateval(idx,1,size(chargemod->modifierslist,5),modifychargerequest->
        charge_mod[i].field6,chargemod->modifierslist[idx].field6)
       IF (modifierpos > 0)
        DECLARE cemid = f8 WITH protect, noconstant(0)
        SELECT INTO "nl:"
         FROM charge c,
          charge_event_mod cem
         PLAN (c
          WHERE (c.charge_item_id=request->chargeid)
           AND c.active_ind=true)
          JOIN (cem
          WHERE cem.charge_event_id=c.charge_event_id
           AND (cem.field6=modifychargerequest->charge_mod[i].field6)
           AND cem.active_ind=true)
         DETAIL
          cemid = cem.charge_event_mod_id
         WITH nocounter
        ;end select
        IF (curqual > 0)
         IF (uptchargeeventmodactiveind(cemid,modifychargerequest->charge_mod[i].field6))
          CALL logmessage(curprog,build("Successfully updated active ind for charge_event_mod_id: ",
            modifychargerequest->charge_mod[i].charge_event_mod_id),log_debug)
         ELSE
          CALL logmessage(curprog,
           "uptChargeEventModActiveInd failed to update charge_event_mod table",log_debug)
          RETURN(false)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (size(addchargeeventmodreq->objarray,5) <= 0)
     CALL echo("No charge_event_mods to add")
    ELSE
     EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",addchargeeventmodreq), replace("REPLY",
      addchargeeventmodrep)
     IF ((addchargeeventmodrep->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(addchargeeventmodreq)
       CALL echorecord(addchargeeventmodrep)
      ENDIF
     ENDIF
    ENDIF
    IF (size(uptchargeeventmodreq->objarray,5) <= 0)
     CALL echo("No charge_event_mods to update")
    ELSE
     EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargeeventmodreq), replace("REPLY",
      uptchargeeventmodrep)
     IF ((uptchargeeventmodrep->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(uptchargeeventmodreq)
       CALL echorecord(uptchargeeventmodrep)
      ENDIF
     ENDIF
    ENDIF
    SET stat = alterlist(addchargeeventmodreq->objarray,0)
    SET stat = alterlist(uptchargeeventmodreq->objarray,0)
    IF ( NOT (inactivemodinchargeeventmod(0)))
     CALL logmessage("inactiveModInChargeEventMod",
      "Failed to inactivate active_ind in charge_event_mod table",log_debug)
    ENDIF
    IF ( NOT (inactivedxinchargeeventmod(0)))
     CALL logmessage("inactiveDXInChargeEventMod",
      "Failed to inactivate active_ind in charge_event_mod table",log_debug)
    ENDIF
   ENDIF
   FREE RECORD chargemod
   SET action_begin = 1
   SET action_end = modifychargerequest->charge_mod_qual
   SET modifychargerequest->skip_charge_event_mod_ind = 1
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",modifychargerequest), replace("REPLY",
    modifychargereply)
   IF ((modifychargereply->status_data.status != "S"))
    CALL logmessage(curprog,"Failed to save charge mod.........",log_debug)
    RETURN(false)
   ENDIF
   IF (((physicianmodification) OR (((reprocessmodind) OR (reprocessind)) )) )
    CALL synchrelease(physicianmodification)
   ENDIF
   CALL loadreasoncodeintochargemodifier(0)
   IF ((cm_request->charge_mod_qual > 0))
    SET action_begin = 1
    SET action_end = cm_request->charge_mod_qual
    EXECUTE afc_add_charge_mod  WITH replace("REQUEST",cm_request), replace("REPLY",cm_reply)
    IF ((cm_reply->status_data.status != "S"))
     CALL logmessage(curprog,
      "createNewDebitCharge- afc_add_charge_mod did not return success for partial credit reason",
      log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   IF (cnvtreal(addchargedetailsreply->mod_objs[1].mod_recs[1].pk_values) > 0.0)
    SET pftind = size(afcprofit_request->charges,5)
    FOR (counter1 = 1 TO size(addchargedetailsreply->mod_objs[1].mod_recs,5))
      SET pftind += 1
      SET stat = alterlist(afcprofit_request->charges,pftind)
      SET stat = alterlist(publishupdatedchargerequest->charges,counter1)
      SET afcprofit_request->charges[pftind].charge_item_id = cnvtreal(addchargedetailsreply->
       mod_objs[1].mod_recs[counter1].pk_values)
      SET publishupdatedchargerequest->charges[counter1].charge_item_id = cnvtreal(
       addchargedetailsreply->mod_objs[1].mod_recs[counter1].pk_values)
    ENDFOR
    IF (size(syncrelease_reply->charge_items,5) > 0)
     FOR (counter1 = 1 TO size(syncrelease_reply->charge_items,5))
      SET chargepos = locateval(chargecnt,1,size(afcprofit_request->charges,5),syncrelease_reply->
       charge_items[counter1].charge_item_id,afcprofit_request->charges[chargecnt].charge_item_id)
      IF (chargepos=0)
       SET pftind += 1
       SET stat = alterlist(afcprofit_request->charges,pftind)
       SET afcprofit_request->charges[pftind].charge_item_id = syncrelease_reply->charge_items[
       counter1].charge_item_id
      ENDIF
     ENDFOR
    ENDIF
   ELSE
    CALL logmessage(curprog,"createNewDebitCharge - Debit charge ChargeItemID is Zero",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage(curprog,"createNewDebitCharge - Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE loadchargerequest(dummyvar)
   CALL logmessage(curprog,"loadChargeRequest - Entering...",log_debug)
   SET stat = alterlist(addchargedetailsrequest->objarray,1)
   SET addchargedetailsrequest->objarray[1].charge_item_id = request->chargeid
   SET addchargedetailsrequest->objarray[1].parent_charge_item_id = 0.0
   SET addchargedetailsrequest->objarray[1].charge_event_act_id = chargefind_reply->charge_items[1].
   charge_event_act_id
   SET addchargedetailsrequest->objarray[1].charge_event_id = chargefind_reply->charge_items[1].
   charge_event_id
   SET addchargedetailsrequest->objarray[1].bill_item_id = chargefind_reply->charge_items[1].
   bill_item_id
   SET addchargedetailsrequest->objarray[1].order_id = chargefind_reply->charge_items[1].order_id
   SET addchargedetailsrequest->objarray[1].encntr_id = chargefind_reply->charge_items[1].encntr_id
   SET addchargedetailsrequest->objarray[1].person_id = chargefind_reply->charge_items[1].person_id
   SET addchargedetailsrequest->objarray[1].payor_id = chargefind_reply->charge_items[1].payor_id
   SET addchargedetailsrequest->objarray[1].ord_loc_cd = chargefind_reply->charge_items[1].ord_loc_cd
   SET addchargedetailsrequest->objarray[1].perf_phys_id = chargefind_reply->charge_items[1].
   perf_phys_id
   SET addchargedetailsrequest->objarray[1].price_sched_id = chargefind_reply->charge_items[1].
   price_sched_id
   SET addchargedetailsrequest->objarray[1].item_allowable = chargefind_reply->charge_items[1].
   item_allowable
   SET addchargedetailsrequest->objarray[1].item_copay = chargefind_reply->charge_items[1].item_copay
   SET addchargedetailsrequest->objarray[1].posted_cd = chargefind_reply->charge_items[1].posted_cd
   SET addchargedetailsrequest->objarray[1].posted_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].posted_dt_tm)
   SET addchargedetailsrequest->objarray[1].activity_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].activity_dt_tm)
   SET addchargedetailsrequest->objarray[1].active_ind = chargefind_reply->charge_items[1].active_ind
   SET addchargedetailsrequest->objarray[1].active_status_cd = chargefind_reply->charge_items[1].
   active_status_cd
   SET addchargedetailsrequest->objarray[1].active_status_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].active_status_dt_tm)
   SET addchargedetailsrequest->objarray[1].active_status_prsnl_id = chargefind_reply->charge_items[1
   ].active_status_prsnl_id
   SET addchargedetailsrequest->objarray[1].beg_effective_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].beg_effective_dt_tm)
   SET addchargedetailsrequest->objarray[1].end_effective_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].end_effective_dt_tm)
   SET addchargedetailsrequest->objarray[1].adjusted_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].adjusted_dt_tm)
   SET addchargedetailsrequest->objarray[1].interface_file_id = chargefind_reply->charge_items[1].
   interface_file_id
   SET addchargedetailsrequest->objarray[1].tier_group_cd = chargefind_reply->charge_items[1].
   tier_group_cd
   SET addchargedetailsrequest->objarray[1].def_bill_item_id = chargefind_reply->charge_items[1].
   def_bill_item_id
   SET addchargedetailsrequest->objarray[1].gross_price = chargefind_reply->charge_items[1].
   gross_price
   SET addchargedetailsrequest->objarray[1].discount_amount = chargefind_reply->charge_items[1].
   discount_amount
   SET addchargedetailsrequest->objarray[1].manual_ind = chargefind_reply->charge_items[1].manual_ind
   SET addchargedetailsrequest->objarray[1].combine_ind = chargefind_reply->charge_items[1].
   combine_ind
   SET addchargedetailsrequest->objarray[1].activity_type_cd = chargefind_reply->charge_items[1].
   activity_type_cd
   SET addchargedetailsrequest->objarray[1].activity_sub_type_cd = chargefind_reply->charge_items[1].
   activity_sub_type_cd
   SET addchargedetailsrequest->objarray[1].provider_specialty_cd = chargefind_reply->charge_items[1]
   .provider_specialty_cd
   SET addchargedetailsrequest->objarray[1].activity_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].activity_dt_tm)
   SET addchargedetailsrequest->objarray[1].admit_type_cd = chargefind_reply->charge_items[1].
   admit_type_cd
   SET addchargedetailsrequest->objarray[1].bundle_id = chargefind_reply->charge_items[1].bundle_id
   SET addchargedetailsrequest->objarray[1].department_cd = chargefind_reply->charge_items[1].
   department_cd
   SET addchargedetailsrequest->objarray[1].institution_cd = chargefind_reply->charge_items[1].
   institution_cd
   SET addchargedetailsrequest->objarray[1].level5_cd = chargefind_reply->charge_items[1].level5_cd
   SET addchargedetailsrequest->objarray[1].med_service_cd = chargefind_reply->charge_items[1].
   med_service_cd
   SET addchargedetailsrequest->objarray[1].section_cd = chargefind_reply->charge_items[1].section_cd
   SET addchargedetailsrequest->objarray[1].subsection_cd = chargefind_reply->charge_items[1].
   subsection_cd
   SET addchargedetailsrequest->objarray[1].cost_center_cd = chargefind_reply->charge_items[1].
   cost_center_cd
   SET addchargedetailsrequest->objarray[1].inst_fin_nbr = chargefind_reply->charge_items[1].
   inst_fin_nbr
   SET addchargedetailsrequest->objarray[1].fin_class_cd = chargefind_reply->charge_items[1].
   fin_class_cd
   SET addchargedetailsrequest->objarray[1].health_plan_id = chargefind_reply->charge_items[1].
   health_plan_id
   SET addchargedetailsrequest->objarray[1].item_interval_id = chargefind_reply->charge_items[1].
   item_interval_id
   SET addchargedetailsrequest->objarray[1].item_list_price = chargefind_reply->charge_items[1].
   item_list_price
   SET addchargedetailsrequest->objarray[1].item_reimbursement = chargefind_reply->charge_items[1].
   item_reimbursement
   SET addchargedetailsrequest->objarray[1].list_price_sched_id = chargefind_reply->charge_items[1].
   list_price_sched_id
   SET addchargedetailsrequest->objarray[1].payor_type_cd = chargefind_reply->charge_items[1].
   payor_type_cd
   SET addchargedetailsrequest->objarray[1].epsdt_ind = chargefind_reply->charge_items[1].epsdt_ind
   SET addchargedetailsrequest->objarray[1].ref_phys_id = chargefind_reply->charge_items[1].
   ref_phys_id
   SET addchargedetailsrequest->objarray[1].start_dt_tm = cnvtdatetime(chargefind_reply->
    charge_items[1].start_dt_tm)
   SET addchargedetailsrequest->objarray[1].stop_dt_tm = cnvtdatetime(chargefind_reply->charge_items[
    1].stop_dt_tm)
   SET addchargedetailsrequest->objarray[1].server_process_flag = chargefind_reply->charge_items[1].
   server_process_flag
   SET addchargedetailsrequest->objarray[1].item_deductible_amt = chargefind_reply->charge_items[1].
   item_deductible_amt
   SET addchargedetailsrequest->objarray[1].patient_responsibility_flag = chargefind_reply->
   charge_items[1].patient_responsibility_flag
   SET addchargedetailsrequest->objarray[1].perf_loc_cd = request->performinglocationcd
   SET addchargedetailsrequest->objarray[1].ord_phys_id = request->orderingphysicianid
   SET addchargedetailsrequest->objarray[1].charge_description = request->chargedescription
   SET addchargedetailsrequest->objarray[1].item_price = request->itemprice
   IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)) OR (itc > 0)) )
    SET addchargedetailsrequest->objarray[1].item_quantity = request->quantity
    SET addchargedetailsrequest->objarray[1].item_extended_price = chargefind_reply->charge_items[1].
    item_extended_price
   ELSE
    IF (validate(request->billitemquantity,0) > 0)
     SET addchargedetailsrequest->objarray[1].item_quantity = request->billitemquantity
     SET addchargedetailsrequest->objarray[1].item_extended_price = (request->itemprice * request->
     billitemquantity)
    ELSE
     SET addchargedetailsrequest->objarray[1].item_quantity = request->quantity
     SET addchargedetailsrequest->objarray[1].item_extended_price = (request->itemprice * request->
     quantity)
    ENDIF
   ENDIF
   SET addchargedetailsrequest->objarray[1].charge_type_cd = cs13028_dr_cd
   SET addchargedetailsrequest->objarray[1].research_acct_id = request->researchaccountid
   SET addchargedetailsrequest->objarray[1].suspense_rsn_cd = evaluate(cs4001989_modify_cd,0.0,
    request->suspensersncd,0.0)
   SET addchargedetailsrequest->objarray[1].reason_comment = evaluate(cs4001989_modify_cd,0.0,request
    ->reasoncomment,"")
   SET addchargedetailsrequest->objarray[1].process_flg = pending_status
   SET addchargedetailsrequest->objarray[1].service_dt_tm = cnvtdatetime(request->servicedatetime)
   SET addchargedetailsrequest->objarray[1].updt_cnt = 0
   SET addchargedetailsrequest->objarray[1].updt_dt_tm = cnvtdatetime(sysdate)
   SET addchargedetailsrequest->objarray[1].updt_id = reqinfo->updt_id
   SET addchargedetailsrequest->objarray[1].updt_task = reqinfo->updt_task
   SET addchargedetailsrequest->objarray[1].updt_applctx = reqinfo->updt_applctx
   SET addchargedetailsrequest->objarray[1].credited_dt_tm = cnvtdatetime(sysdate)
   SET addchargedetailsrequest->objarray[1].verify_phys_id = request->renderingphysicianid
   SET addchargedetailsrequest->objarray[1].abn_status_cd = request->abnstatuscd
   SET addchargedetailsrequest->objarray[1].offset_charge_item_id = 0.0
   CALL logmessage(curprog,"loadChargeRequest - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (loadreasoncodeintochargemodifier(dummyvar=i2) =null)
   IF ((((request->suspensersncd > 0)) OR (trim(request->reasoncomment) != ""))
    AND cs4001989_modify_cd > 0)
    DECLARE count1 = i4 WITH noconstant(0)
    SET cm_request->charge_mod_qual = 1
    SET stat = alterlist(cm_request->charge_mod,1)
    SET cm_request->charge_mod[1].charge_item_id = cnvtreal(addchargedetailsreply->mod_objs[1].
     mod_recs[1].pk_values)
    SET cm_request->charge_mod[1].charge_mod_type_cd = cs13019_mod_rsn_cd
    SET cm_request->charge_mod[1].field1_id = cs4001989_modify_cd
    SET cm_request->charge_mod[1].field6 = "The charge was modified"
    SET cm_request->charge_mod[1].field7 = request->reasoncomment
    SET cm_request->charge_mod[1].field2_id = request->suspensersncd
    SET cm_request->charge_mod[1].activity_dt_tm = cnvtdatetime(sysdate)
    SET cm_request->charge_mod[1].updt_cnt = 0
    SET cm_request->charge_mod[1].updt_dt_tm = cnvtdatetime(sysdate)
    SET cm_request->charge_mod[1].updt_id = reqinfo->updt_id
    SET cm_request->charge_mod[1].updt_task = reqinfo->updt_task
    SET cm_request->charge_mod[1].updt_applctx = reqinfo->updt_applctx
    SET cm_request->charge_mod[1].active_ind = 1
    SET cm_request->charge_mod[1].active_status_cd = cs48_active_code
    SET cm_request->charge_mod[1].active_status_dt_tm = cnvtdatetime(sysdate)
    SET cm_request->charge_mod[1].active_status_prsnl_id = reqinfo->updt_id
    SET cm_request->charge_mod[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
    SET cm_request->charge_mod[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99")
    SET cm_request->charge_mod[1].action_type = "ADD"
    IF (size(addchargedetailsreply->mod_objs[1].mod_recs,5) > 1)
     SET cm_request->charge_mod_qual = size(addchargedetailsreply->mod_objs[1].mod_recs,5)
     SET stat = alterlist(cm_request->charge_mod,size(addchargedetailsreply->mod_objs[1].mod_recs,5))
     FOR (count1 = 2 TO size(addchargedetailsreply->mod_objs[1].mod_recs,5))
       SET cm_request->charge_mod[count1].action_type = "ADD"
       SET cm_request->charge_mod[count1].charge_item_id = cnvtreal(addchargedetailsreply->mod_objs[1
        ].mod_recs[count1].pk_values)
       SET cm_request->charge_mod[count1].charge_mod_type_cd = cs13019_suspense_cd
       SET cm_request->charge_mod[count1].field1_id = cs13030_partial_credit
       SET cm_request->charge_mod[count1].field6 = uar_get_code_display(cs13030_partial_credit)
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadflexfielddataforchargerequest(dummyvar=i2) =null)
   CALL logmessage(curprog,"loadFlexFieldDataForChargeRequest - Entering...",log_debug)
   DECLARE fielddatatype = vc WITH protect, noconstant("")
   SET chrgmodcnt = 0
   IF (size(request->flexfieldsmodel,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(request->flexfieldsmodel,5))),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(request->flexfieldsmodel[d1.seq].chargemodifiermodel,5)))
      JOIN (d2)
     HEAD REPORT
      chrgmodcnt = size(modifychargerequest->charge_mod,5)
     DETAIL
      chrgmodcnt += 1, stat = alterlist(modifychargerequest->charge_mod,chrgmodcnt),
      modifychargerequest->charge_mod[chrgmodcnt].charge_item_id = cnvtreal(addchargedetailsreply->
       mod_objs[1].mod_recs[1].pk_values),
      modifychargerequest->charge_mod[chrgmodcnt].charge_event_mod_id = request->flexfieldsmodel[d1
      .seq].chargemodifiermodel[d2.seq].chargeeventmodid, modifychargerequest->charge_mod[chrgmodcnt]
      .action_type = "ADD", modifychargerequest->charge_mod[chrgmodcnt].charge_mod_type_cd =
      cs13019_flex_cd,
      modifychargerequest->charge_mod[chrgmodcnt].active_ind = 1, modifychargerequest->charge_mod[
      chrgmodcnt].field1_id = request->flexfieldsmodel[d1.seq].chargemodifiermodel[d2.seq].modifiercd,
      modifychargerequest->charge_mod[chrgmodcnt].field7 = uar_get_code_display(request->
       flexfieldsmodel[d1.seq].chargemodifiermodel[d2.seq].modifiercd),
      fielddatatype = request->flexfieldsmodel[d1.seq].chargemodifiermodel[d2.seq].fielddatatype,
      modifychargerequest->charge_mod[chrgmodcnt].field2 = fielddatatype
      IF (fielddatatype="STRING")
       modifychargerequest->charge_mod[chrgmodcnt].field1 = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvaluechar
      ELSEIF (fielddatatype IN ("NUMBER", "CURRENCY"))
       modifychargerequest->charge_mod[chrgmodcnt].cm1_nbr = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvaluenumber
      ELSEIF (fielddatatype="PROVLOOKUP")
       modifychargerequest->charge_mod[chrgmodcnt].field3_id = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvalueid
      ELSEIF (fielddatatype="CODE")
       modifychargerequest->charge_mod[chrgmodcnt].code1_cd = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvaluenumber
      ELSEIF (fielddatatype="DATE")
       modifychargerequest->charge_mod[chrgmodcnt].activity_dt_tm = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvaluedatetime
      ELSEIF (fielddatatype="INDICATOR")
       modifychargerequest->charge_mod[chrgmodcnt].field2_id = request->flexfieldsmodel[d1.seq].
       chargemodifiermodel[d2.seq].fieldvaluenumber
      ENDIF
     FOOT REPORT
      modifychargerequest->charge_mod_qual = chrgmodcnt
     WITH nocounter
    ;end select
   ENDIF
   CALL logmessage(curprog,"loadFlexFieldDataForChargeRequest - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (loadbillcodedetails(dummyvar=i2) =null)
   CALL logmessage(curprog,"loadBillCodeDetails - Entering...",log_debug)
   SET chrgmodcnt = size(modifychargerequest->charge_mod,5)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(request->billcodesmodel,5)))
    DETAIL
     chrgmodcnt += 1, stat = alterlist(modifychargerequest->charge_mod,chrgmodcnt),
     modifychargerequest->charge_mod[chrgmodcnt].charge_item_id = cnvtreal(addchargedetailsreply->
      mod_objs[1].mod_recs[1].pk_values),
     modifychargerequest->charge_mod[chrgmodcnt].charge_event_mod_id = request->billcodesmodel[d1.seq
     ].chargeeventmodid, modifychargerequest->charge_mod[chrgmodcnt].charge_mod_type_cd =
     cs13019_bill_code, modifychargerequest->charge_mod[chrgmodcnt].cm1_nbr = request->
     billcodesmodel[d1.seq].cm1nbr,
     modifychargerequest->charge_mod[chrgmodcnt].code1_cd = request->billcodesmodel[d1.seq].code1cd,
     modifychargerequest->charge_mod[chrgmodcnt].field1_id = request->billcodesmodel[d1.seq].field1id,
     modifychargerequest->charge_mod[chrgmodcnt].field2_id = request->billcodesmodel[d1.seq].field2id,
     modifychargerequest->charge_mod[chrgmodcnt].field3_id = request->billcodesmodel[d1.seq].field3id,
     modifychargerequest->charge_mod[chrgmodcnt].field4_id = request->billcodesmodel[d1.seq].field4id,
     modifychargerequest->charge_mod[chrgmodcnt].field5_id = request->billcodesmodel[d1.seq].field5id,
     CALL populatefields1to5(null), modifychargerequest->charge_mod[chrgmodcnt].field6 = request->
     billcodesmodel[d1.seq].field6, modifychargerequest->charge_mod[chrgmodcnt].field7 = request->
     billcodesmodel[d1.seq].field7,
     modifychargerequest->charge_mod[chrgmodcnt].nomen_id = request->billcodesmodel[d1.seq].nomenid,
     modifychargerequest->charge_mod[chrgmodcnt].active_ind = 1, modifychargerequest->charge_mod[
     chrgmodcnt].action_type = "ADD",
     modifychargerequest->charge_mod[chrgmodcnt].charge_mod_source_cd = validate(request->
      billcodesmodel[d1.seq].chargemodsourcecd,0.0)
    FOOT REPORT
     modifychargerequest->charge_mod_qual = chrgmodcnt
    WITH nocounter
   ;end select
   DECLARE chrgmodqualcnt = i4 WITH protect, noconstant(0)
   IF ((modifychargerequest->charge_mod_qual > 0))
    FOR (chrgmodqualcnt = 1 TO modifychargerequest->charge_mod_qual)
      SELECT INTO "nl:"
       FROM charge c,
        charge_event_mod cem
       PLAN (c
        WHERE (c.charge_item_id=modifychargerequest->charge_mod[chrgmodqualcnt].charge_item_id)
         AND c.active_ind=1)
        JOIN (cem
        WHERE cem.charge_event_id=c.charge_event_id
         AND (cem.field6=modifychargerequest->charge_mod[chrgmodqualcnt].field6)
         AND (cem.field1_id=modifychargerequest->charge_mod[chrgmodqualcnt].field1_id)
         AND cem.active_ind=1)
       DETAIL
        IF ((modifychargerequest->charge_mod[chrgmodqualcnt].charge_event_mod_id=0))
         modifychargerequest->charge_mod[chrgmodqualcnt].charge_event_mod_id = cem
         .charge_event_mod_id
        ENDIF
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
   CALL logmessage(curprog,"loadBillCodeDetails - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (populatefields1to5(dummy=i2) =null)
   IF (validate(request->billcodesmodel[d1.seq].field1))
    SET modifychargerequest->charge_mod[chrgmodcnt].field1 = request->billcodesmodel[d1.seq].field1
    SET modifychargerequest->charge_mod[chrgmodcnt].field2 = request->billcodesmodel[d1.seq].field2
    SET modifychargerequest->charge_mod[chrgmodcnt].field3 = request->billcodesmodel[d1.seq].field3
    SET modifychargerequest->charge_mod[chrgmodcnt].field4 = request->billcodesmodel[d1.seq].field4
    SET modifychargerequest->charge_mod[chrgmodcnt].field5 = request->billcodesmodel[d1.seq].field5
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadchargemodifierswithoutflexfields(dummyvar=i2) =null)
   CALL logmessage(curprog,"loadChargeModifierswithoutFlexFields - Entering...",log_debug)
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE (cm.charge_item_id=request->chargeid)
     AND  NOT (cm.charge_mod_type_cd IN (cs13019_bill_code, cs13019_flex_cd, cs13019_changelog_cd))
     AND ((cm.active_ind+ 0)=1)
    HEAD REPORT
     chrgmodcnt = size(modifychargerequest->charge_mod,5)
    DETAIL
     chrgmodcnt += 1, stat = alterlist(modifychargerequest->charge_mod,chrgmodcnt),
     modifychargerequest->charge_mod[chrgmodcnt].charge_item_id = cnvtreal(addchargedetailsreply->
      mod_objs[1].mod_recs[1].pk_values),
     modifychargerequest->charge_mod[chrgmodcnt].charge_mod_id = cm.charge_mod_id,
     modifychargerequest->charge_mod[chrgmodcnt].activity_dt_tm = cm.activity_dt_tm,
     modifychargerequest->charge_mod[chrgmodcnt].charge_mod_type_cd = cm.charge_mod_type_cd,
     modifychargerequest->charge_mod[chrgmodcnt].cm1_nbr = cm.cm1_nbr, modifychargerequest->
     charge_mod[chrgmodcnt].code1_cd = cm.code1_cd, modifychargerequest->charge_mod[chrgmodcnt].
     field1 = cm.field1,
     modifychargerequest->charge_mod[chrgmodcnt].field1_id = cm.field1_id, modifychargerequest->
     charge_mod[chrgmodcnt].field2 = cm.field2, modifychargerequest->charge_mod[chrgmodcnt].field2_id
      = cm.field2_id,
     modifychargerequest->charge_mod[chrgmodcnt].field3_id = cm.field3_id, modifychargerequest->
     charge_mod[chrgmodcnt].field4_id = cm.field4_id, modifychargerequest->charge_mod[chrgmodcnt].
     field5_id = cm.field5_id,
     modifychargerequest->charge_mod[chrgmodcnt].field6 = cm.field6, modifychargerequest->charge_mod[
     chrgmodcnt].field7 = cm.field7, modifychargerequest->charge_mod[chrgmodcnt].nomen_id = cm
     .nomen_id,
     modifychargerequest->charge_mod[chrgmodcnt].action_type = "ADD"
    FOOT REPORT
     modifychargerequest->charge_mod_qual = chrgmodcnt
    WITH nocounter
   ;end select
   CALL logmessage(curprog,"loadChargeModifierswithoutFlexFields - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (postcharges(prafcprofitrequest=vc(ref),prafcprofitreply=vc(ref)) =null)
   CALL logmessage(curprog,"postCharges - Entering...",log_debug)
   EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",prafcprofitrequest), replace("REPLY",
    prafcprofitreply)
   IF ((prafcprofitreply->status_data.status="F"))
    CALL logmessage(curprog,"postCharges - pft_nt_chrg_billing did not return Success",log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
   CALL logmessage(curprog,"postCharges - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (updatephysandabnstatusresearchaccount(dummyvar=i2) =i2)
   DECLARE temp_charge_act_id = f8
   DECLARE temp_abn_status_cd = f8
   DECLARE temp_charge_ev_id = f8
   DECLARE ordphysmodificationind = i2 WITH noconstant(false)
   DECLARE rendphysmodificationind = i2 WITH noconstant(false)
   DECLARE provspecind = i2 WITH noconstant(false)
   DECLARE tempordphyid = f8 WITH protect, noconstant(0.0)
   DECLARE temprendphyid = f8 WITH protect, noconstant(0.0)
   DECLARE tempprovspeccd = f8 WITH protect, noconstant(0.0)
   DECLARE newprovspeccd = f8 WITH protect, noconstant(0.0)
   DECLARE tempperfphysid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM charge c
    WHERE (c.charge_item_id=request->chargeid)
    DETAIL
     temp_charge_act_id = c.charge_event_act_id, tempordphyid = c.ord_phys_id, temprendphyid = c
     .verify_phys_id,
     tempperfphysid = c.perf_phys_id, tempprovspeccd = c.provider_specialty_cd
    WITH nocounter
   ;end select
   CALL getproviderspecialty(tempperfphysid)
   SET temp_phys_id = 0
   SET activeind = 0
   SELECT INTO "nl:"
    FROM charge_event_act_prsnl ceap,
     prsnl p
    PLAN (ceap
     WHERE ceap.charge_event_act_id=temp_charge_act_id
      AND ceap.prsnl_type_cd=cs13029_ordered_cd)
     JOIN (p
     WHERE p.person_id=ceap.prsnl_id
      AND p.physician_ind=true
      AND p.active_ind=true)
    DETAIL
     temp_phys_id = ceap.prsnl_id, activeind = ceap.active_ind
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ((request->orderingphysicianid=0)
     AND (request->orderingphysicianid != temp_phys_id)
     AND activeind=1)
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 0, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
        sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_ordered_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      GO TO end_program
     ELSE
      IF (tempprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = 0.0
      ENDIF
     ENDIF
     IF (checktierforordphys(request->chargeid))
      SET ordphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ELSEIF ((request->orderingphysicianid != 0)
     AND (request->orderingphysicianid != temp_phys_id))
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 1, ceap.prsnl_id = request->orderingphysicianid, ceap.updt_cnt = (ceap
       .updt_cnt+ 1),
       ceap.updt_dt_tm = cnvtdatetime(sysdate), ceap.updt_id = reqinfo->updt_id, ceap.updt_task =
       reqinfo->updt_task,
       ceap.updt_applctx = reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_ordered_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      RETURN(false)
     ELSE
      IF (tempprovspeccd != newprovspeccd)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforordphys(request->chargeid))
      SET ordphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ELSEIF ((request->orderingphysicianid=temp_phys_id)
     AND activeind=0)
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 1, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
        sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_ordered_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      RETURN(false)
     ELSE
      IF (newprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforordphys(request->chargeid))
      SET ordphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ENDIF
   ELSE
    IF ((request->orderingphysicianid != 0))
     INSERT  FROM charge_event_act_prsnl ceap
      SET ceap.prsnl_id = request->orderingphysicianid, ceap.prsnl_type_cd = cs13029_ordered_cd, ceap
       .charge_event_act_id = temp_charge_act_id,
       ceap.active_ind = 1, ceap.updt_cnt = 0, ceap.updt_dt_tm = cnvtdatetime(sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      RETURN(false)
     ELSE
      IF (newprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforordphys(request->chargeid))
      SET ordphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ENDIF
   ENDIF
   IF ((tempordphyid=request->orderingphysicianid)
    AND tempordphyid != 0.0)
    SET ordphysmodificationind = false
   ENDIF
   SET temp_phys_id = 0
   SET activeind = 0
   SELECT INTO "nl:"
    FROM charge_event_act_prsnl ceap,
     prsnl p
    PLAN (ceap
     WHERE ceap.charge_event_act_id=temp_charge_act_id
      AND ceap.prsnl_type_cd=cs13029_verified_cd)
     JOIN (p
     WHERE p.person_id=ceap.prsnl_id
      AND p.physician_ind=true
      AND p.active_ind=true)
    DETAIL
     temp_phys_id = ceap.prsnl_id, activeind = ceap.active_ind
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ((request->renderingphysicianid=0)
     AND (request->renderingphysicianid != temp_phys_id)
     AND activeind=1)
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 0, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
        sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_verified_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      GO TO end_program
     ELSE
      IF (tempprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = 0.0
      ENDIF
     ENDIF
     IF (checktierforrendphys(request->chargeid))
      SET rendphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ELSEIF ((request->renderingphysicianid != 0)
     AND (request->renderingphysicianid != temp_phys_id))
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 1, ceap.prsnl_id = request->renderingphysicianid, ceap.updt_cnt = (ceap
       .updt_cnt+ 1),
       ceap.updt_dt_tm = cnvtdatetime(sysdate), ceap.updt_id = reqinfo->updt_id, ceap.updt_task =
       reqinfo->updt_task,
       ceap.updt_applctx = reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_verified_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      RETURN(false)
     ELSE
      IF (tempprovspeccd != newprovspeccd)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforrendphys(request->chargeid))
      SET rendphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ELSEIF ((request->renderingphysicianid=temp_phys_id)
     AND activeind=0)
     UPDATE  FROM charge_event_act_prsnl ceap
      SET ceap.active_ind = 1, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
        sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WHERE ceap.charge_event_act_id=temp_charge_act_id
       AND ceap.prsnl_type_cd=cs13029_verified_cd
      WITH nocounter
     ;end update
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      GO TO end_program
     ELSE
      IF (newprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforrendphys(request->chargeid))
      SET rendphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ENDIF
   ELSE
    IF ((request->renderingphysicianid != 0))
     INSERT  FROM charge_event_act_prsnl ceap
      SET ceap.prsnl_id = request->renderingphysicianid, ceap.prsnl_type_cd = cs13029_verified_cd,
       ceap.charge_event_act_id = temp_charge_act_id,
       ceap.active_ind = 1, ceap.updt_cnt = 0, ceap.updt_dt_tm = cnvtdatetime(sysdate),
       ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
       reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual < 1)
      SET reply->status_data.status = "F"
      RETURN(false)
     ELSE
      IF (newprovspeccd != 0)
       SET addchargedetailsrequest->objarray[1].provider_specialty_cd = newprovspeccd
      ENDIF
     ENDIF
     IF (checktierforrendphys(request->chargeid))
      SET rendphysmodificationind = true
     ELSEIF (checktierforproviderspec(request->chargeid))
      SET provspecind = true
     ENDIF
    ENDIF
   ENDIF
   IF ((temprendphyid=request->renderingphysicianid)
    AND temprendphyid != 0.0)
    SET rendphysmodificationind = false
   ENDIF
   SELECT INTO "nl:"
    FROM charge_event ce,
     charge c
    PLAN (c
     WHERE (c.charge_item_id=request->chargeid))
     JOIN (ce
     WHERE ce.charge_event_id=c.charge_event_id)
    DETAIL
     temp_abn_status_cd = ce.abn_status_cd, temp_charge_ev_id = c.charge_event_id
    WITH nocounter
   ;end select
   IF ((temp_abn_status_cd != request->abnstatuscd))
    UPDATE  FROM charge_event ce
     SET ce.abn_status_cd = request->abnstatuscd, ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_dt_tm =
      cnvtdatetime(sysdate),
      ce.updt_id = reqinfo->updt_id, ce.updt_task = reqinfo->updt_task, ce.updt_applctx = reqinfo->
      updt_applctx
     WHERE ce.charge_event_id=temp_charge_ev_id
     WITH nocounter
    ;end update
   ENDIF
   UPDATE  FROM charge_event ce
    SET ce.research_account_id = addchargedetailsrequest->objarray[1].research_acct_id, ce.updt_cnt
      = (ce.updt_cnt+ 1), ce.updt_dt_tm = cnvtdatetime(sysdate),
     ce.updt_id = reqinfo->updt_id, ce.updt_task = reqinfo->updt_task, ce.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ce.charge_event_id=chargefind_reply->charge_items[1].charge_event_id)
    WITH nocounter
   ;end update
   IF (((ordphysmodificationind) OR (((rendphysmodificationind) OR (provspecind)) )) )
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_all_related_charges(dummyvar=i2) =null)
   DECLARE peid = f8 WITH noconstant(0.0)
   CALL logmessage(curprog,"Entering sub-routine get_all_related_charges",log_debug)
   SELECT INTO "nl:"
    FROM item_interval_table i
    WHERE (i.item_interval_id=chargefind_reply->charge_items[1].item_interval_id)
     AND i.parent_entity_name="PRICE_SCHED_ITEMS"
     AND i.active_ind=1
    DETAIL
     peid = i.parent_entity_id
    WITH nocounter
   ;end select
   CALL logmessage(curprog,build("Parent_entity_id: ",peid),log_debug)
   CALL logmessage(curprog,"Getting interval charges related to primary charge",log_debug)
   SET ccount = 1
   SELECT INTO "nl:"
    FROM item_interval_table iit,
     charge c
    PLAN (iit
     WHERE (iit.item_interval_id != chargefind_reply->charge_items[1].item_interval_id)
      AND iit.parent_entity_id=peid
      AND iit.parent_entity_name="PRICE_SCHED_ITEMS"
      AND iit.active_ind=1)
     JOIN (c
     WHERE c.item_interval_id=iit.item_interval_id
      AND (c.charge_event_act_id=chargefind_reply->charge_items[1].charge_event_act_id)
      AND (c.tier_group_cd=chargefind_reply->charge_items[1].tier_group_cd)
      AND c.offset_charge_item_id=0.0)
    DETAIL
     ccount += 1, stat = alterlist(addchargedetailsrequest->objarray,ccount), addchargedetailsrequest
     ->objarray[ccount].charge_item_id = c.charge_item_id,
     addchargedetailsrequest->objarray[ccount].parent_charge_item_id = c.parent_charge_item_id,
     addchargedetailsrequest->objarray[ccount].charge_event_act_id = c.charge_event_act_id,
     addchargedetailsrequest->objarray[ccount].charge_event_id = c.charge_event_id,
     addchargedetailsrequest->objarray[ccount].bill_item_id = c.bill_item_id, addchargedetailsrequest
     ->objarray[ccount].order_id = c.order_id, addchargedetailsrequest->objarray[ccount].encntr_id =
     c.encntr_id,
     addchargedetailsrequest->objarray[ccount].person_id = c.person_id, addchargedetailsrequest->
     objarray[ccount].payor_id = c.payor_id, addchargedetailsrequest->objarray[ccount].ord_loc_cd = c
     .ord_loc_cd,
     addchargedetailsrequest->objarray[ccount].perf_loc_cd = c.perf_loc_cd, addchargedetailsrequest->
     objarray[ccount].ord_phys_id = c.ord_phys_id, addchargedetailsrequest->objarray[ccount].
     perf_phys_id = c.perf_phys_id,
     addchargedetailsrequest->objarray[ccount].charge_description = c.charge_description,
     addchargedetailsrequest->objarray[ccount].price_sched_id = c.price_sched_id,
     addchargedetailsrequest->objarray[ccount].item_quantity = c.item_quantity,
     addchargedetailsrequest->objarray[ccount].item_price = c.item_price, addchargedetailsrequest->
     objarray[ccount].item_extended_price = c.item_extended_price, addchargedetailsrequest->objarray[
     ccount].item_allowable = c.item_allowable,
     addchargedetailsrequest->objarray[ccount].item_copay = c.item_copay, addchargedetailsrequest->
     objarray[ccount].charge_type_cd = c.charge_type_cd, addchargedetailsrequest->objarray[ccount].
     research_acct_id = c.research_acct_id,
     addchargedetailsrequest->objarray[ccount].suspense_rsn_cd = c.suspense_rsn_cd,
     addchargedetailsrequest->objarray[ccount].reason_comment = c.reason_comment
     IF (cs13019_mod_rsn_cd <= 0.0)
      addchargedetailsrequest->objarray[ccount].suspense_rsn_cd = request->suspensersncd,
      addchargedetailsrequest->objarray[ccount].reason_comment = request->reasoncomment
     ENDIF
     addchargedetailsrequest->objarray[ccount].posted_cd = c.posted_cd, addchargedetailsrequest->
     objarray[ccount].posted_dt_tm = c.posted_dt_tm, addchargedetailsrequest->objarray[ccount].
     process_flg = 1,
     addchargedetailsrequest->objarray[ccount].service_dt_tm = c.service_dt_tm,
     addchargedetailsrequest->objarray[ccount].activity_dt_tm = c.activity_dt_tm,
     addchargedetailsrequest->objarray[ccount].updt_cnt = c.updt_cnt,
     addchargedetailsrequest->objarray[ccount].updt_dt_tm = c.updt_dt_tm, addchargedetailsrequest->
     objarray[ccount].updt_id = c.updt_id, addchargedetailsrequest->objarray[ccount].updt_task = c
     .updt_task,
     addchargedetailsrequest->objarray[ccount].updt_applctx = c.updt_applctx, addchargedetailsrequest
     ->objarray[ccount].active_status_dt_tm = c.active_status_dt_tm, addchargedetailsrequest->
     objarray[ccount].active_status_prsnl_id = c.active_status_prsnl_id,
     addchargedetailsrequest->objarray[ccount].active_ind = 1, addchargedetailsrequest->objarray[
     ccount].active_status_cd = c.active_status_cd, addchargedetailsrequest->objarray[ccount].
     beg_effective_dt_tm = c.beg_effective_dt_tm,
     addchargedetailsrequest->objarray[ccount].end_effective_dt_tm = c.end_effective_dt_tm,
     addchargedetailsrequest->objarray[ccount].credited_dt_tm = c.credited_dt_tm,
     addchargedetailsrequest->objarray[ccount].adjusted_dt_tm = c.adjusted_dt_tm,
     addchargedetailsrequest->objarray[ccount].interface_file_id = c.interface_file_id,
     addchargedetailsrequest->objarray[ccount].tier_group_cd = c.tier_group_cd,
     addchargedetailsrequest->objarray[ccount].def_bill_item_id = c.def_bill_item_id,
     addchargedetailsrequest->objarray[ccount].verify_phys_id = c.verify_phys_id,
     addchargedetailsrequest->objarray[ccount].gross_price = c.gross_price, addchargedetailsrequest->
     objarray[ccount].discount_amount = c.discount_amount,
     addchargedetailsrequest->objarray[ccount].manual_ind = c.manual_ind, addchargedetailsrequest->
     objarray[ccount].combine_ind = c.combine_ind, addchargedetailsrequest->objarray[ccount].
     activity_type_cd = c.activity_type_cd,
     addchargedetailsrequest->objarray[ccount].activity_sub_type_cd = c.activity_sub_type_cd,
     addchargedetailsrequest->objarray[ccount].provider_specialty_cd = c.provider_specialty_cd,
     addchargedetailsrequest->objarray[ccount].admit_type_cd = c.admit_type_cd,
     addchargedetailsrequest->objarray[ccount].bundle_id = c.bundle_id, addchargedetailsrequest->
     objarray[ccount].department_cd = c.department_cd, addchargedetailsrequest->objarray[ccount].
     institution_cd = c.institution_cd,
     addchargedetailsrequest->objarray[ccount].level5_cd = c.level5_cd, addchargedetailsrequest->
     objarray[ccount].med_service_cd = c.med_service_cd, addchargedetailsrequest->objarray[ccount].
     section_cd = c.section_cd,
     addchargedetailsrequest->objarray[ccount].subsection_cd = c.subsection_cd,
     addchargedetailsrequest->objarray[ccount].abn_status_cd = c.abn_status_cd,
     addchargedetailsrequest->objarray[ccount].cost_center_cd = c.cost_center_cd,
     addchargedetailsrequest->objarray[ccount].inst_fin_nbr = c.inst_fin_nbr, addchargedetailsrequest
     ->objarray[ccount].fin_class_cd = c.fin_class_cd, addchargedetailsrequest->objarray[ccount].
     health_plan_id = c.health_plan_id,
     addchargedetailsrequest->objarray[ccount].item_interval_id = c.item_interval_id,
     addchargedetailsrequest->objarray[ccount].item_list_price = c.item_list_price,
     addchargedetailsrequest->objarray[ccount].item_reimbursement = c.item_reimbursement,
     addchargedetailsrequest->objarray[ccount].list_price_sched_id = c.list_price_sched_id,
     addchargedetailsrequest->objarray[ccount].payor_type_cd = c.payor_type_cd,
     addchargedetailsrequest->objarray[ccount].epsdt_ind = c.epsdt_ind,
     addchargedetailsrequest->objarray[ccount].ref_phys_id = c.ref_phys_id, addchargedetailsrequest->
     objarray[ccount].start_dt_tm = c.start_dt_tm, addchargedetailsrequest->objarray[ccount].
     stop_dt_tm = c.stop_dt_tm,
     addchargedetailsrequest->objarray[ccount].alpha_nomen_id = c.alpha_nomen_id,
     addchargedetailsrequest->objarray[ccount].server_process_flag = c.server_process_flag,
     addchargedetailsrequest->objarray[ccount].offset_charge_item_id = c.offset_charge_item_id,
     addchargedetailsrequest->objarray[ccount].item_deductible_amt = c.item_deductible_amt,
     addchargedetailsrequest->objarray[ccount].patient_responsibility_flag = c
     .patient_responsibility_flag
    WITH nocounter
   ;end select
   CALL logmessage(curprog,"Leaving subroutine get_all_related_charges",log_debug)
 END ;Subroutine
 SUBROUTINE synchrelease(physmodification)
   DECLARE appid = i4 WITH public, noconstant(0)
   DECLARE taskid = i4 WITH public, noconstant(0)
   DECLARE reqid = i4 WITH public, noconstant(0)
   DECLARE happ = i4 WITH public, noconstant(0)
   DECLARE htask = i4 WITH public, noconstant(0)
   DECLARE hreq = i4 WITH public, noconstant(0)
   DECLARE hrequest = i4 WITH public, noconstant(0)
   DECLARE hlist = i4 WITH public, noconstant(0)
   DECLARE hlist1 = i4 WITH public, noconstant(0)
   DECLARE hlist2 = i4 WITH public, noconstant(0)
   DECLARE hlist3 = i4 WITH public, noconstant(0)
   DECLARE hlist4 = i4 WITH public, noconstant(0)
   DECLARE hreply = i4 WITH public, noconstant(0)
   DECLARE hcharge = i4 WITH public, noconstant(0)
   DECLARE crmstatus = i4 WITH public, noconstant(0)
   DECLARE utc = f8 WITH noconstant(0.0)
   DECLARE fieldvalue = i4 WITH noconstant(0)
   DECLARE iresult = i4 WITH noconstant(0)
   DECLARE begvalue = f8 WITH noconstant(0.0)
   DECLARE chargeeventmodcount = i4 WITH noconstant(0)
   DECLARE chargemodcount = i4 WITH noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE nreprocessloop = i4 WITH protect, noconstant(0)
   DECLARE nreprocessloop2 = i4 WITH protect, noconstant(0)
   DECLARE nreprocessloop3 = i4 WITH protect, noconstant(0)
   DECLARE nreprocessloop4 = i4 WITH protect, noconstant(0)
   DECLARE eflag_interval = i2 WITH constant(3)
   SET appid = 951020
   SET taskid = 951020
   SET reqid = 951359
   SET happ = 0
   SET htask = 0
   SET hreq = 0
   SET hrequest = 0
   SET hlist1 = 0
   SET hlist2 = 0
   SET hlist3 = 0
   SET hlist4 = 0
   SET hreply = 0
   SET hcharge = 0
   SET crmstatus = 0
   CALL logmessage(curprog,"Entering synchRelease ",log_debug)
   IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)
    AND (request->billitemquantity > 0)) OR (((itc > 0
    AND (request->billitemquantity > 0)) OR (((physmodification) OR (((reprocessmodind) OR (
   reprocessind)) )) )) )) )
    FOR (nreprocessrequest = 1 TO size(addchargedetailsreply->mod_objs[1].mod_recs,5))
      IF (nreprocessrequest <= 1)
       SET stat = alterlist(reproc_request->process_event,1)
       SET reproc_request->process_event[nreprocessrequest].charge_event_id = chargefind_reply->
       charge_items[1].charge_event_id
      ENDIF
      SET stat = alterlist(reproc_request->process_event[1].charge_item,nreprocessrequest)
      SET reproc_request->process_event[1].charge_item[nreprocessrequest].charge_item_id = cnvtreal(
       addchargedetailsreply->mod_objs[1].mod_recs[nreprocessrequest].pk_values)
    ENDFOR
    SET reproc_request->charge_event_qual = size(reproc_request->process_event[1].charge_item,5)
    SELECT INTO "nl:"
     FROM charge_event_mod cem,
      code_value cv
     PLAN (cem
      WHERE (cem.charge_event_id=chargefind_reply->charge_items[1].charge_event_id)
       AND cem.active_ind=true
       AND  NOT (expand(idx,1,size(modifychargerequest->charge_mod,5),cem.charge_event_mod_id,
       modifychargerequest->charge_mod[idx].charge_event_mod_id)))
      JOIN (cv
      WHERE cv.code_value=cem.field1_id
       AND cv.code_set=cvs14002_afc_schedule_type
       AND cv.cdf_meaning="MODIFIER"
       AND cv.active_ind=1)
     DETAIL
      chargeeventmodcount += 1, stat = alterlist(reproc_request->process_event[1].ignored_event_mod,
       chargeeventmodcount), reproc_request->process_event[1].ignored_event_mod[chargeeventmodcount].
      field6 = cem.field6
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM charge_mod cm,
      code_value cv
     PLAN (cm
      WHERE (cm.charge_item_id=chargefind_reply->charge_items[1].charge_item_id)
       AND cm.charge_mod_type_cd=cs13019_bill_code
       AND cm.active_ind=true
       AND ((cm.charge_mod_source_cd=cs4518006_ref_data) OR (cm.charge_mod_source_cd=0))
       AND  NOT (expand(idx,1,size(modifychargerequest->charge_mod,5),cm.field6,modifychargerequest->
       charge_mod[idx].field6,
       cs4518006_ref_data,modifychargerequest->charge_mod[idx].charge_mod_source_cd)))
      JOIN (cv
      WHERE cv.code_value=cm.field1_id
       AND cv.code_set=cvs14002_afc_schedule_type
       AND cv.cdf_meaning="MODIFIER"
       AND cv.active_ind=1)
     DETAIL
      chargemodcount += 1, stat = alterlist(reproc_request->process_event[1].ignored_charge_mod,
       chargemodcount), reproc_request->process_event[1].ignored_charge_mod[chargemodcount].field6 =
      cm.field6
     WITH nocounter
    ;end select
    SET reproc_request->process_event[1].ignored_event_mod_qual = chargeeventmodcount
    SET reproc_request->process_event[1].ignored_charge_mod_qual = chargemodcount
    IF (size(reproc_request->process_event,5) > 0)
     CALL logmessage(curprog,"Reprocess the charges",log_debug)
     SET crmstatus = uar_crmbeginapp(appid,happ)
     IF (crmstatus=0)
      SET crmstatus = uar_crmbegintask(happ,taskid,htask)
      IF (crmstatus=0)
       SET crmstatus = uar_crmbeginreq(htask,"",reqid,hreq)
       IF (crmstatus=0)
        IF (hreq=0)
         CALL logmessage(curprog,"Failure on begin request",log_debug)
        ELSE
         SET hrequest = uar_crmgetrequest(hreq)
         IF (hrequest=0)
          CALL logmessage(curprog,"Invalid hRequest handle returned from CrmGetRequest",log_debug)
         ELSE
          SET stat = uar_srvsetshort(hrequest,"charge_event_qual",reproc_request->charge_event_qual)
          SET stat = uar_srvsetdouble(hrequest,"process_type_cd",cs13029_released_cd)
          FOR (nreprocessloop = 1 TO size(reproc_request->process_event,5))
            SET hlist1 = uar_srvadditem(hrequest,"process_event")
            SET stat = uar_srvsetdouble(hlist1,"charge_event_id",reproc_request->process_event[
             nreprocessloop].charge_event_id)
            FOR (nreprocessloop2 = 1 TO size(reproc_request->process_event[nreprocessloop].
             charge_item,5))
             SET hlist2 = uar_srvadditem(hlist1,"charge_item")
             SET stat = uar_srvsetdouble(hlist2,"charge_item_id",reproc_request->process_event[
              nreprocessloop].charge_item[nreprocessloop2].charge_item_id)
            ENDFOR
            SET stat = uar_srvsetshort(hlist1,"ignored_event_mod_qual",reproc_request->process_event[
             nreprocessloop].ignored_event_mod_qual)
            FOR (nreprocessloop3 = 1 TO size(reproc_request->process_event[nreprocessloop].
             ignored_event_mod,5))
             SET hlist3 = uar_srvadditem(hlist1,"ignored_event_mod")
             SET stat = uar_srvsetstring(hlist3,"field6",nullterm(reproc_request->process_event[
               nreprocessloop].ignored_event_mod[nreprocessloop3].field6))
            ENDFOR
            SET stat = uar_srvsetshort(hlist1,"ignored_charge_mod_qual",reproc_request->
             process_event[nreprocessloop].ignored_charge_mod_qual)
            FOR (nreprocessloop4 = 1 TO size(reproc_request->process_event[nreprocessloop].
             ignored_charge_mod,5))
             SET hlist4 = uar_srvadditem(hlist1,"ignored_charge_mod")
             SET stat = uar_srvsetstring(hlist4,"field6",nullterm(reproc_request->process_event[
               nreprocessloop].ignored_charge_mod[nreprocessloop4].field6))
            ENDFOR
          ENDFOR
         ENDIF
        ENDIF
        COMMIT
        SET crmstatus = uar_crmperform(hreq)
        IF (crmstatus=0)
         CALL logmessage(curprog,build("Synchronous Perform Succeeded, CRM Status is  ",crmstatus),
          log_debug)
         SET hreply = uar_crmgetreply(hreq)
         IF (hreply > 0)
          SET litemcount = uar_srvgetitemcount(hreply,"charges")
          SET stat = alterlist(syncrelease_reply->charge_items,litemcount)
          FOR (lloopcount = 1 TO litemcount)
           SET hlist = uar_srvgetitem(hreply,"charges",(lloopcount - 1))
           IF (validate(syncrelease_reply->charge_items[lloopcount].charge_item_id,null_f8) !=
           null_f8)
            SET syncrelease_reply->charge_items[lloopcount].charge_item_id = uar_srvgetdouble(hlist,
             "charge_item_id")
           ENDIF
          ENDFOR
         ENDIF
        ELSE
         CALL logmessage(curprog,build("Synchronous Perform Failed, CRM Status is ",crmstatus),
          log_debug)
         RETURN(false)
        ENDIF
        CALL uar_crmendreq(hreq)
       ELSE
        CALL logmessage(curprog,"Failure on BeginReq",log_debug)
       ENDIF
       CALL uar_crmendtask(htask)
      ELSE
       CALL logmessage(curprog,"Failure on BeginTask",log_debug)
      ENDIF
      CALL uar_crmendapp(happ)
     ELSE
      CALL logmessage(curprog,"Failure on BeginApp",log_debug)
     ENDIF
    ENDIF
    CALL logmessage(curprog,"End Synchronous Release",log_debug)
    IF ((((chargefind_reply->charge_items[1].item_interval_id > 0)) OR (itc > 0)) )
     SELECT INTO "nl:"
      FROM item_interval_table iit,
       interval_table it
      PLAN (iit
       WHERE (iit.item_interval_id=chargefind_reply->charge_items[1].item_interval_id))
       JOIN (it
       WHERE it.interval_id=iit.interval_id)
      DETAIL
       utc = it.unit_type_cd
      WITH nocounter
     ;end select
     CALL logmessage(curprog,build("Unit Type Code: ",utc),log_debug)
     SELECT INTO "nl:"
      FROM code_value_extension cve
      WHERE cve.code_value=utc
       AND cve.field_name="DENOMINATOR"
      DETAIL
       fieldvalue = cnvtint(cve.field_value)
      WITH nocounter
     ;end select
     CALL logmessage(curprog,build("Field Value: ",fieldvalue),log_debug)
     IF (fieldvalue=0)
      SET fieldvalue = 1
      CALL logmessage(curprog,"Field Value = 0, setting Field Value to 1",log_debug)
     ENDIF
     SET iresult = ceil((request->billitemquantity/ fieldvalue))
     FOR (loopcnt = 1 TO size(addchargedetailsrequest->objarray,5))
      SELECT INTO "nl:"
       FROM item_interval_table iit,
        interval_table it
       PLAN (iit
        WHERE (iit.item_interval_id=addchargedetailsrequest->objarray[loopcnt].item_interval_id))
        JOIN (it
        WHERE it.interval_id=iit.interval_id)
       DETAIL
        begvalue = it.beg_value
       WITH nocounter
      ;end select
      IF (iresult < begvalue)
       UPDATE  FROM charge c
        SET c.active_ind = 0, c.active_status_prsnl_id = reqinfo->updt_id, c.updt_id = reqinfo->
         updt_id,
         c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.updt_cnt = (c
         .updt_cnt+ 1),
         c.updt_dt_tm = cnvtdatetime(sysdate)
        WHERE (charge_item_id=addchargedetailsrequest->objarray[loopcnt].charge_item_id)
         AND c.server_process_flag=eflag_interval
       ;end update
      ENDIF
     ENDFOR
    ENDIF
    IF (size(afcprofit_request->charges,5) > 0)
     COMMIT
    ENDIF
   ENDIF
   CALL logmessage(curprog,"Exiting synchRelease.... ",log_debug)
 END ;Subroutine
 SUBROUTINE (checkforcptmodifierchange(dummyvar=i2) =i2)
   CALL logmessage(curprog,"Entering checkForCptModifierChange ",log_debug)
   DECLARE oldcptcount = i4 WITH protect, noconstant(0)
   DECLARE newcptcount = i4 WITH protect, noconstant(0)
   DECLARE matchcptcount = i4 WITH protect, noconstant(0)
   DECLARE billcodemodificationind = i2 WITH protect, noconstant(true)
   IF (checktierforcptmod(chargefind_reply->charge_items[1].charge_item_id)=false)
    SET billcodemodificationind = false
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(chargefind_reply->charge_items[1].charge_mods,5))),
      code_value cv
     PLAN (d1
      WHERE (chargefind_reply->charge_items[1].charge_mods[d1.seq].active_ind=1))
      JOIN (cv
      WHERE (cv.code_value=chargefind_reply->charge_items[1].charge_mods[d1.seq].field1_id)
       AND cv.code_set=cvs14002_afc_schedule_type
       AND cv.cdf_meaning="MODIFIER"
       AND cv.active_ind=1)
     DETAIL
      oldcptcount += 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d2  WITH seq = value(size(request->billcodesmodel,5))),
      code_value cv
     PLAN (d2)
      JOIN (cv
      WHERE (cv.code_value=request->billcodesmodel[d2.seq].field1id)
       AND cv.code_set=cvs14002_afc_schedule_type
       AND cv.cdf_meaning="MODIFIER"
       AND cv.active_ind=1)
     DETAIL
      newcptcount += 1
     WITH nocounter
    ;end select
    IF (oldcptcount=newcptcount)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(chargefind_reply->charge_items[1].charge_mods,5))),
       (dummyt d2  WITH seq = value(size(request->billcodesmodel,5))),
       code_value cv
      PLAN (d1
       WHERE (chargefind_reply->charge_items[1].charge_mods[d1.seq].active_ind=1))
       JOIN (d2
       WHERE (request->billcodesmodel[d2.seq].field1id=chargefind_reply->charge_items[1].charge_mods[
       d1.seq].field1_id)
        AND (request->billcodesmodel[d2.seq].field2id=chargefind_reply->charge_items[1].charge_mods[
       d1.seq].field2_id)
        AND (chargefind_reply->charge_items[1].charge_mods[d1.seq].field3_id=request->billcodesmodel[
       d2.seq].field3id))
       JOIN (cv
       WHERE (cv.code_value=chargefind_reply->charge_items[1].charge_mods[d1.seq].field1_id)
        AND cv.code_set=cvs14002_afc_schedule_type
        AND cv.cdf_meaning="MODIFIER"
        AND cv.active_ind=1)
      DETAIL
       matchcptcount += 1
      WITH nocounter
     ;end select
     IF (newcptcount=matchcptcount)
      SET billcodemodificationind = false
     ENDIF
    ENDIF
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echo(build2("Return value: ",billcodemodificationind))
   ENDIF
   CALL logmessage(curprog,"Exiting checkForCptModifierChange ",log_debug)
   RETURN(billcodemodificationind)
 END ;Subroutine
 SUBROUTINE (loadcptmodifiers(dummyvar=i2) =null)
   SELECT INTO "nl:"
    FROM charge_mod cm,
     code_value cv
    PLAN (cm
     WHERE (cm.charge_item_id=request->chargeid)
      AND cm.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=cm.field1_id
      AND cv.code_set=cvs14002_afc_schedule_type
      AND cv.cdf_meaning="MODIFIER"
      AND cv.active_ind=1)
    DETAIL
     cptmodifiercnt += 1, stat = alterlist(chargemod->modifierslist,cptmodifiercnt), chargemod->
     modifierslist[cptmodifiercnt].field6 = cm.field6,
     chargemod->modifierslist[cptmodifiercnt].field2_id = cm.field2_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (inactivemodinchargeeventmod(dummyvar=i2) =i2)
   CALL logmessage(curprog,"Entering inactiveModInChargeEventMod...",log_debug)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE chargeeventmodid = f8 WITH protect, noconstant(0.0)
   DECLARE cdfmeaning = vc WITH protect, constant("MODIFIER")
   DECLARE modcnt = i4 WITH protect, noconstant(0)
   DECLARE modexistsind = i2 WITH protect, noconstant(false)
   FOR (modcnt = 1 TO size(chargemod->modifierslist,5))
     SET modexistsind = false
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = size(request->billcodesmodel,5))
      PLAN (d1
       WHERE (request->billcodesmodel[d1.seq].field6=chargemod->modifierslist[modcnt].field6)
        AND uar_get_code_meaning(request->billcodesmodel[d1.seq].field1id)=cdfmeaning
        AND validate(request->billcodesmodel[d1.seq].chargeeventmodid,0.0) > 0)
      DETAIL
       modexistsind = true
      WITH nocounter
     ;end select
     SET chargeeventmodid = 0.0
     IF (modexistsind=false)
      IF (getchargeeventmodid(request->chargeid,chargemod->modifierslist[modcnt].field6,cdfmeaning,
       chargeeventmodid))
       IF (uptchargeeventmodactiveind(chargeeventmodid,chargemod->modifierslist[modcnt].field6))
        CALL logmessage(curprog,build("Successfully updated active ind for charge_event_mod_id: ",
          chargeeventmodid),log_debug)
       ELSE
        CALL logmessage(curprog,"uptChargeEventModActiveInd failed to update charge_event_mod table",
         log_debug)
        CALL logmessage(curprog,"Exiting inactiveModInChargeEventMod...",log_debug)
        RETURN(false)
       ENDIF
      ELSE
       CALL logmessage(curprog,"NO Charge_event_mod_id present in charge_event_mod table",log_debug)
      ENDIF
     ENDIF
     IF (checkdminfotoremoveparentcodes(0))
      SET modexistsind = false
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = size(request->billcodesmodel,5))
       PLAN (d1
        WHERE (request->billcodesmodel[d1.seq].field6=chargemod->modifierslist[modcnt].field6)
         AND uar_get_code_meaning(request->billcodesmodel[d1.seq].field1id)=cdfmeaning
         AND (request->billcodesmodel[d1.seq].field2id=chargemod->modifierslist[modcnt].field2_id)
         AND validate(request->billcodesmodel[d1.seq].chargemodsourcecd,0.0) !=
        cs4518006_manually_add)
       DETAIL
        modexistsind = true
       WITH nocounter
      ;end select
      IF (modexistsind=false)
       IF (inactivateparentcodes(request->chargeid,chargemod->modifierslist[modcnt].field6,cdfmeaning
        ))
        CALL logmessage(curprog,"Successfully removed parent Diagnosis codes.",log_debug)
       ELSE
        CALL logmessage(curprog,"inactivateParentCodes failed",log_debug)
        CALL logmessage(curprog,"Exiting inactiveDXInChargeEventMod...",log_debug)
        RETURN(false)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL logmessage(curprog,"Exiting inactiveModInChargeEventMod...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (loaddiagnosisdetail(dummyvar=i2) =i2)
   CALL logmessage(curprog,"Entering loadDiagnosisDetail...",log_debug)
   DECLARE dxreccnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM charge_mod cm,
     code_value cv
    PLAN (cm
     WHERE (cm.charge_item_id=request->chargeid)
      AND cm.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=cm.field1_id
      AND cv.code_set=cvs14002_afc_schedule_type
      AND cv.cdf_meaning="ICD9"
      AND cv.active_ind=true)
    DETAIL
     dxreccnt += 1, stat = alterlist(chargediagnosisdetail->diagnosislist,dxreccnt),
     chargediagnosisdetail->diagnosislist[dxreccnt].field2_id = cm.field2_id,
     chargediagnosisdetail->diagnosislist[dxreccnt].field6 = cm.field6
    WITH nocounter
   ;end select
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(chargediagnosisdetail)
   ENDIF
   IF (dxreccnt=0)
    CALL logmessage(curprog,"Exiting loadDiagnosisDetail...",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage(curprog,"Exiting loadDiagnosisDetail...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (inactivedxinchargeeventmod(dummyvar=i2) =i2)
   CALL logmessage(curprog,"Entering inactiveDXInChargeEventMod...",log_debug)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE dxidxcnt = i4 WITH protect, noconstant(0)
   DECLARE modexistsind = i2 WITH protect, noconstant(false)
   DECLARE chargeeventmodid = f8 WITH protect, noconstant(0.0)
   DECLARE cdfmeaning = vc WITH protect, constant("ICD9")
   FOR (dxidxcnt = 1 TO size(chargediagnosisdetail->diagnosislist,5))
     SET modexistsind = false
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = size(request->billcodesmodel,5))
      PLAN (d1
       WHERE (request->billcodesmodel[d1.seq].field6=chargediagnosisdetail->diagnosislist[dxidxcnt].
       field6)
        AND uar_get_code_meaning(request->billcodesmodel[d1.seq].field1id)=cdfmeaning)
      DETAIL
       modexistsind = true
      WITH nocounter
     ;end select
     SET chargeeventmodid = 0.0
     IF (modexistsind=false)
      IF (getchargeeventmodid(request->chargeid,chargediagnosisdetail->diagnosislist[dxidxcnt].field6,
       cdfmeaning,chargeeventmodid))
       IF (uptchargeeventmodactiveind(chargeeventmodid,chargediagnosisdetail->diagnosislist[dxidxcnt]
        .field6))
        CALL logmessage(curprog,build("Successfully updated active ind for charge_event_mod_id: ",
          chargeeventmodid),log_debug)
       ELSE
        CALL logmessage(curprog,"uptChargeEventModActiveInd failed to update charge_event_mod table",
         log_debug)
        CALL logmessage(curprog,"Exiting inactiveDXInChargeEventMod...",log_debug)
        RETURN(false)
       ENDIF
      ELSE
       CALL logmessage(curprog,"No charge_event_mod_id present in charge_event_mod table",log_debug)
      ENDIF
     ENDIF
     IF (checkdminfotoremoveparentcodes(0))
      SET modexistsind = false
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = size(request->billcodesmodel,5))
       PLAN (d1
        WHERE (request->billcodesmodel[d1.seq].field6=chargediagnosisdetail->diagnosislist[dxidxcnt].
        field6)
         AND uar_get_code_meaning(request->billcodesmodel[d1.seq].field1id)=cdfmeaning
         AND (request->billcodesmodel[d1.seq].field2id=chargediagnosisdetail->diagnosislist[dxidxcnt]
        .field2_id))
       DETAIL
        modexistsind = true
       WITH nocounter
      ;end select
      IF (modexistsind=false)
       IF (inactivateparentcodes(request->chargeid,chargediagnosisdetail->diagnosislist[dxidxcnt].
        field6,cdfmeaning))
        CALL logmessage(curprog,"Successfully removed parent Diagnosis codes.",log_debug)
       ELSE
        CALL logmessage(curprog,"inactivateParentCodes failed",log_debug)
        CALL logmessage(curprog,"Exiting inactiveDXInChargeEventMod...",log_debug)
        RETURN(false)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL logmessage(curprog,"Exiting inactiveDXInChargeEventMod...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (checkdminfotoremoveparentcodes(dummyvar=i2) =i2)
   DECLARE settingenabled = i2 WITH noconstant(0)
   DECLARE logical_domain_id = f8 WITH noconstant(0.0)
   CALL logmessage(curprog,"Entering checkDmInfoToRemoveParentCodes...",log_debug)
   SELECT INTO "nl:"
    FROM charge c,
     encounter e,
     organization o
    PLAN (c
     WHERE (c.charge_item_id=request->chargeid))
     JOIN (e
     WHERE e.encntr_id=c.encntr_id)
     JOIN (o
     WHERE o.organization_id=e.organization_id)
    DETAIL
     logical_domain_id = o.logical_domain_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="CHARGE SERVICES"
      AND d.info_name="INACTIVATE PARENT EVENT ICD AND MODIFIERS"
      AND d.info_domain_id=logical_domain_id)
    DETAIL
     IF (cnvtupper(d.info_char)="Y")
      settingenabled = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage(curprog,"Exiting checkDmInfoToRemoveParentCodes...",log_debug)
   RETURN(settingenabled)
 END ;Subroutine
 SUBROUTINE inactivateparentcodes(chargeitemid,field6,meaning)
   CALL logmessage(curprog,"Entering inactivateParentCodes...",log_debug)
   RECORD parentchargeeventmods(
     1 cnt = i4
     1 cemids[*]
       2 charge_event_mod_id = f8
       2 field6 = vc
   )
   DECLARE m_event_id = f8 WITH noconstant(0.0)
   DECLARE m_event_cont_cd = f8 WITH noconstant(0.0)
   DECLARE p_event_id = f8 WITH noconstant(0.0)
   DECLARE p_event_cont_cd = f8 WITH noconstant(0.0)
   DECLARE parentfound = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM charge c,
     charge_event ce
    PLAN (c
     WHERE c.charge_item_id=chargeitemid)
     JOIN (ce
     WHERE ce.charge_event_id=c.charge_event_id
      AND ce.ext_p_event_id != ce.ext_i_event_id)
    DETAIL
     m_event_id = ce.ext_m_event_id, m_event_cont_cd = ce.ext_m_event_cont_cd, p_event_id = ce
     .ext_p_event_id,
     p_event_cont_cd = ce.ext_p_event_cont_cd
    WITH nocounter
   ;end select
   WHILE (p_event_id > 0
    AND p_event_cont_cd > 0)
     SET parentfound = 0
     SELECT INTO "nl:"
      field1_id_meaning = uar_get_code_meaning(cem.field1_id)
      FROM charge_event ce,
       charge_event_mod cem
      PLAN (ce
       WHERE ce.ext_m_event_id=m_event_id
        AND ce.ext_m_event_cont_cd=m_event_cont_cd
        AND ce.ext_i_event_id=p_event_id
        AND ce.ext_i_event_cont_cd=p_event_cont_cd)
       JOIN (cem
       WHERE (cem.charge_event_id= Outerjoin(ce.charge_event_id))
        AND (cem.active_ind= Outerjoin(1))
        AND (cem.charge_event_mod_type_cd= Outerjoin(cs13019_bill_code)) )
      ORDER BY ce.charge_event_id
      HEAD ce.charge_event_id
       p_event_id = ce.ext_p_event_id, p_event_cont_cd = ce.ext_p_event_cont_cd, parentfound = 1
      DETAIL
       IF (cem.charge_event_mod_id > 0
        AND trim(field1_id_meaning)=trim(meaning)
        AND trim(cem.field6)=trim(field6))
        parentchargeeventmods->cnt += 1, stat = alterlist(parentchargeeventmods->cemids,
         parentchargeeventmods->cnt), parentchargeeventmods->cemids[parentchargeeventmods->cnt].
        charge_event_mod_id = cem.charge_event_mod_id,
        parentchargeeventmods->cemids[parentchargeeventmods->cnt].field6 = cem.field6
       ENDIF
      WITH nocounter
     ;end select
     IF ( NOT (parentfound))
      SET p_event_id = 0.0
      SET p_event_cont_cd = 0.0
     ENDIF
   ENDWHILE
   IF (validate(debug,- (1)) > 0)
    CALL echo("checking parent mods")
    CALL echorecord(parentchargeeventmods)
   ENDIF
   FOR (cemcnt = 1 TO parentchargeeventmods->cnt)
     IF (uptchargeeventmodactiveind(parentchargeeventmods->cemids[cemcnt].charge_event_mod_id,
      parentchargeeventmods->cemids[cemcnt].field6))
      CALL logmessage(curprog,build("Successfully updated active ind for charge_event_mod_id: ",
        parentchargeeventmods->cemids[cemcnt].charge_event_mod_id),log_debug)
     ELSE
      CALL logmessage(curprog,
       "uptChargeEventModActiveInd failed to update parent charge_event_mod table",log_debug)
     ENDIF
   ENDFOR
   CALL logmessage(curprog,"Exiting inactivateParentCodes...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getchargeeventmodid(prchargeitemid=f8,prfield6=vc,prcdfmeaning=vc,prchargeeventmodid=f8(
   ref)) =i2)
   CALL logmessage(curprog,"Entering getChargeEventModId...",log_debug)
   DECLARE scheduletype = f8 WITH protect, constant(14002.0)
   SELECT INTO "nl:"
    FROM charge_event_mod cem,
     charge c,
     code_value cv
    PLAN (c
     WHERE c.charge_item_id=prchargeitemid
      AND c.active_ind=1)
     JOIN (cem
     WHERE cem.charge_event_id=c.charge_event_id
      AND cem.charge_event_mod_type_cd=cs13019_bill_code
      AND cem.field6=prfield6
      AND cem.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=cem.field1_id
      AND cv.code_set=scheduletype
      AND cv.cdf_meaning=prcdfmeaning
      AND cv.active_ind=1)
    DETAIL
     prchargeeventmodid = cem.charge_event_mod_id
    WITH counter
   ;end select
   IF (prchargeeventmodid <= 0.0)
    CALL logmessage(curprog,"Exiting getChargeEventModId...",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage(curprog,"Exiting getChargeEventModId...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (uptchargeeventmodactiveind(prchargeeventmodid=f8,prfield6=vc) =i2)
   CALL logmessage(curprog,"Entering uptChargeEventModActiveInd...",log_debug)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   SET billcdcnt += 1
   SET stat = alterlist(uptchargeeventmodreq->objarray,billcdcnt)
   SELECT INTO "nl:"
    FROM charge_event_mod cem
    WHERE cem.charge_event_mod_id=prchargeeventmodid
     AND cem.field6=prfield6
     AND cem.active_ind=true
    DETAIL
     uptchargeeventmodreq->objarray[billcdcnt].action_type = "DEL", uptchargeeventmodreq->objarray[
     billcdcnt].charge_event_id = cem.charge_event_id, uptchargeeventmodreq->objarray[billcdcnt].
     charge_event_mod_id = prchargeeventmodid,
     uptchargeeventmodreq->objarray[billcdcnt].updt_cnt = cem.updt_cnt, uptchargeeventmodreq->
     objarray[billcdcnt].active_ind = false
    WITH nocounter
   ;end select
   IF (size(uptchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to update")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargeeventmodreq), replace("REPLY",
     uptchargeeventmodrep)
    IF ((uptchargeeventmodrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(uptchargeeventmodreq)
      CALL echorecord(uptchargeeventmodrep)
     ENDIF
     SET stat = alterlist(uptchargeeventmodreq->objarray,0)
     CALL logmessage(curprog,"Exiting uptChargeEventModActiveInd...",log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   SET stat = alterlist(uptchargeeventmodreq->objarray,0)
   CALL logmessage(curprog,"Exiting uptChargeEventModActiveInd...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getproviderspecialty(perfphysid=f8) =null)
   RECORD lochierarchy(
     1 list[*]
       2 level_cd = f8
   ) WITH protect
   DECLARE providerid = f8 WITH noconstant(0.0)
   DECLARE spcloccd = f8 WITH noconstant(0.0)
   DECLARE cnt = i4 WITH noconstant(0)
   DECLARE curcd = f8 WITH noconstant(0.00)
   DECLARE found = i2 WITH noconstant(false)
   IF ((request->renderingphysicianid > 0))
    SET providerid = request->renderingphysicianid
   ELSEIF (perfphysid > 0)
    SET providerid = perfphysid
   ELSEIF ((request->orderingphysicianid > 0))
    SET providerid = request->orderingphysicianid
   ENDIF
   IF ((request->performinglocationcd > 0))
    SET spcloccd = request->performinglocationcd
   ELSE
    SELECT INTO "nl:"
     FROM charge c,
      encounter e
     PLAN (c
      WHERE (c.charge_item_id=request->chargeid)
       AND c.active_ind=1)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND e.active_ind=1)
     DETAIL
      spcloccd = e.location_cd
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_value=spcloccd
     AND c.active_ind=true
    DETAIL
     CASE (uar_get_code_meaning(c.code_value))
      OF "FACILITY":
       cnt = 1
      OF "BUILDING":
       cnt = 2
      OF "NURSEUNIT":
      OF "AMBULATORY":
       cnt = 3
      OF "ROOM":
       cnt = 4
      OF "BED":
       cnt = 5
     ENDCASE
    WITH nocounter
   ;end select
   SET curcd = spcloccd
   SET stat = alterlist(lochierarchy->list,cnt)
   IF (cnt > 0)
    SET lochierarchy->list[cnt].level_cd = curcd
   ENDIF
   WHILE (cnt > 0)
    SELECT INTO "nl:"
     l.parent_loc_cd, l.child_loc_cd, l.location_group_type_cd
     FROM location_group l
     WHERE l.child_loc_cd=curcd
      AND l.active_ind=1
      AND l.root_loc_cd=0
     DETAIL
      IF (((cnt=4
       AND l.location_group_type_cd=cs222_room_cd) OR (((cnt=3
       AND ((l.location_group_type_cd=cs222_nurseunit_cd) OR (l.location_group_type_cd=
      cs222_ambulatory_cd)) ) OR (((cnt=2
       AND l.location_group_type_cd=cs222_building_cd) OR (cnt=1
       AND l.location_group_type_cd=cs222_facility_cd)) )) )) )
       curcd = l.parent_loc_cd, lochierarchy->list[cnt].level_cd = curcd
      ENDIF
     WITH nocounter
    ;end select
    SET cnt -= 1
   ENDWHILE
   SET cnt = size(alterlist(lochierarchy->list,5))
   WHILE (cnt > 0)
     SET spcloccd = lochierarchy->list[cnt].level_cd
     SELECT INTO "nl:"
      FROM prsnl_specialty_reltn psr,
       prsnl_specialty_loc_reltn pslr
      PLAN (psr
       WHERE psr.prsnl_id=providerid
        AND psr.active_ind=true
        AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
       JOIN (pslr
       WHERE pslr.prsnl_specialty_reltn_id=psr.prsnl_specialty_reltn_id
        AND pslr.location_cd=spcloccd
        AND pslr.active_ind=true
        AND pslr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND pslr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
      ORDER BY psr.prsnl_id, pslr.beg_effective_dt_tm
      HEAD psr.prsnl_id
       newprovspeccd = psr.specialty_cd
      DETAIL
       found = true
      WITH nocounter
     ;end select
     IF (found=true)
      SET cnt = 0
     ELSE
      SET cnt -= 1
     ENDIF
   ENDWHILE
   IF (found=false)
    SELECT INTO "nl:"
     FROM prsnl_specialty_reltn psr
     WHERE psr.prsnl_id=providerid
      AND psr.primary_ind=true
      AND psr.active_ind=true
      AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
     DETAIL
      newprovspeccd = psr.specialty_cd
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
END GO
