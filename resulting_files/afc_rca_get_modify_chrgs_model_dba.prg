CREATE PROGRAM afc_rca_get_modify_chrgs_model:dba
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
 CALL beginservice("CHARGSRV-14216.003")
 RECORD reply(
   1 chargedetaillist[*]
     2 chargeid = f8
     2 serviceitemid = f8
     2 serviceitemdescription = vc
     2 servicedatetime = dq8
     2 orderingphysicianid = f8
     2 orderingphysicianname = vc
     2 renderingphysicianid = f8
     2 renderingphysicianname = vc
     2 performinglocationcd = f8
     2 billcodesmodel[*]
       3 billcodetype = vc
       3 billcodevalues = vc
       3 billcodes[*]
         4 chargemodifierid = f8
         4 chargeeventmodid = f8
         4 field6 = vc
         4 field7 = vc
         4 field1id = f8
         4 field2id = f8
         4 field3id = f8
         4 field4id = f8
         4 field5id = f8
         4 nomenid = f8
         4 cm1nbr = f8
         4 code1cd = f8
         4 sourcevocabularydisplay = vc
     2 flexfieldsmodel[*]
       3 categorydescription = vc
       3 chargemodifiermodel[*]
         4 chargemodifierid = f8
         4 chargeeventmodid = f8
         4 modifierdescription = vc
         4 modifiercd = f8
         4 requiredind = i2
         4 fielddatatype = vc
         4 fieldvalueoptionlist[*]
           5 optionvalue = vc
           5 optioncd = f8
         4 fieldvaluedatetime = dq8
         4 fieldvaluechar = vc
         4 fieldvaluenumber = f8
         4 fieldvalueid = f8
       3 categorycd = f8
   1 ismodifyicddiagschedule = i2
   1 ismodifyicdprocschedule = i2
   1 ismodifymodifierschedule = i2
   1 icddiagschedfield1id = f8
   1 icdprocschedfield1id = f8
   1 modifierschedfield1id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD billcodeschedules(
   1 billcodeschedule[*]
     2 bcschedid = f8
 ) WITH protect
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE chridx = i4 WITH protect, noconstant(0)
 DECLARE isscsaenabled = i2 WITH protect, noconstant(false)
 IF ( NOT (validate(_hi18n)))
  DECLARE _hi18n = i4 WITH protect, noconstant(0)
 ENDIF
 SET stat = uar_i18nlocalizationinit(_hi18n,curprog,"",curcclrev)
 DECLARE i18n_qty_calculation = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,"Val1",
   "Quantity Calculation"))
 DECLARE rca_task_modify_icd_diag_schedule = i4 WITH protect, constant(130134)
 DECLARE rca_task_modify_icd_proc_schedule = i4 WITH protect, constant(130136)
 DECLARE rca_task_modify_modifier_schedule = i4 WITH protect, constant(130138)
 IF ( NOT (validate(cs13019_bill_code)))
  DECLARE cs13019_bill_code = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs26078_sched_cd)))
  DECLARE cs26078_sched_cd = f8 WITH protect, constant(getcodevalue(26078,"BC_SCHED",0))
 ENDIF
 IF ( NOT (validate(cs13019_flex_cd)))
  DECLARE cs13019_flex_cd = f8 WITH protect, constant(getcodevalue(13019,"FLEX",0))
 ENDIF
 IF ( NOT (validate(sc_sa_toggle_name)))
  DECLARE sc_sa_toggle_name = vc WITH constant(
   "urn:cerner:revenue-cycle:cpa:sc-sa-indicator-visibility")
 ENDIF
 FOR (num = 1 TO size(request->chargedetaillist,5))
   IF ((request->chargedetaillist[num].chargeid <= 0.0))
    CALL exitservicefailure("ChargeId is required",true)
   ENDIF
 ENDFOR
 IF ( NOT (getfeaturetoggledetail(sc_sa_toggle_name,isscsaenabled)))
  CALL logmessage("getFeatureToggleDetail",build("Failed to get Feature Toggle details : ",
    sc_sa_toggle_name),log_debug)
 ENDIF
 IF ( NOT (getchargedata(0)))
  CALL exitservicefailure("Failed to find charge",true)
 ENDIF
 CALL gettaskaccess(0)
 CALL getbillcodedata(0)
 CALL logmodcapability(0)
 IF (isscsaenabled)
  FOR (chridx = 1 TO size(reply->chargedetaillist,5))
    IF (validate(reply->chargedetaillist[chridx].flexfieldsmodel))
     IF ( NOT (getflexfielddata(reply->chargedetaillist[chridx].serviceitemid,reply->
      chargedetaillist[chridx].chargeid,chridx,reply)))
      CALL logmessage("getFlexFieldData",build("Failed to get Flex field details for charge id : ",
        reply->chargedetaillist[chridx].chargeid),log_debug)
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 CALL exitservicesuccess("Successfully read the charge data for the given charge ids")
#exit_script
 IF (validate(debug) > 0)
  CALL echorecord(reply)
 ENDIF
 SUBROUTINE (getchargedata(dummyvar=i4) =i2)
   CALL logmessage("getChargeData","Entering...",log_debug)
   DECLARE statusind = i2 WITH protect, noconstant(false)
   DECLARE count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM charge c,
     prsnl p,
     prsnl p1
    PLAN (c
     WHERE expand(num,1,size(request->chargedetaillist,5),c.charge_item_id,request->chargedetaillist[
      num].chargeid))
     JOIN (p
     WHERE (p.person_id= Outerjoin(c.ord_phys_id)) )
     JOIN (p1
     WHERE (p1.person_id= Outerjoin(c.verify_phys_id)) )
    ORDER BY c.charge_item_id
    HEAD REPORT
     count = 0, stat = alterlist(reply->chargedetaillist,10)
    HEAD c.charge_item_id
     count += 1
     IF (mod(count,10)=1
      AND count > 10)
      stat = alterlist(reply->chargedetaillist,(count+ 10))
     ENDIF
     reply->chargedetaillist[count].chargeid = c.charge_item_id, reply->chargedetaillist[count].
     serviceitemid = c.bill_item_id, reply->chargedetaillist[count].serviceitemdescription = c
     .charge_description,
     reply->chargedetaillist[count].servicedatetime = c.service_dt_tm, reply->chargedetaillist[count]
     .orderingphysicianid = c.ord_phys_id, reply->chargedetaillist[count].orderingphysicianname = p
     .name_full_formatted,
     reply->chargedetaillist[count].renderingphysicianid = c.verify_phys_id, reply->chargedetaillist[
     count].renderingphysicianname = p1.name_full_formatted, reply->chargedetaillist[count].
     performinglocationcd = c.perf_loc_cd
    FOOT REPORT
     stat = alterlist(reply->chargedetaillist,count)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL logmessage("getChargeData","Failed to find charge details for the given charge ids",
     log_error)
   ELSE
    SET statusind = true
   ENDIF
   CALL logmessage("getChargeData","Exiting...",log_debug)
   RETURN(statusind)
 END ;Subroutine
 SUBROUTINE (gettaskaccess(dummyvar=i2) =null)
   CALL logmessage("getTaskAccess","Entering...",log_debug)
   DECLARE btaskenable = i2 WITH protect, noconstant(false)
   SET btaskenable = isvalidtask(rca_task_modify_icd_diag_schedule)
   IF (btaskenable)
    SET reply->ismodifyicddiagschedule = btaskenable
   ENDIF
   SET btaskenable = isvalidtask(rca_task_modify_icd_proc_schedule)
   IF (btaskenable)
    SET reply->ismodifyicdprocschedule = btaskenable
   ENDIF
   SET btaskenable = isvalidtask(rca_task_modify_modifier_schedule)
   IF (btaskenable)
    SET reply->ismodifymodifierschedule = btaskenable
   ENDIF
   CALL logmessage("getTaskAccess","Exiting...",log_debug)
 END ;Subroutine
 IF (validate(isvalidtask,char(128))=char(128))
  SUBROUTINE (isvalidtask(tasknumber=i4) =i2)
    CALL logmessage("isValidTask","Entering...",log_debug)
    DECLARE isvalid = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM task_access ta,
      application_group ag
     PLAN (ta
      WHERE ta.task_number=tasknumber
       AND ta.app_group_cd > 0)
      JOIN (ag
      WHERE (ag.position_cd=reqinfo->position_cd)
       AND ag.app_group_cd=ta.app_group_cd
       AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      isvalid = true
     WITH nocounter, maxrec = 1
    ;end select
    CALL logmessage("isValidTask","Exiting...",log_debug)
    RETURN(isvalid)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getbillcodedata(dummy=i2) =i2)
   CALL logmessage("getBillCodeData","Entering...",log_debug)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE billcodemodelcount = i4 WITH protect, noconstant(0)
   DECLARE billcodecount = i4 WITH protect, noconstant(0)
   DECLARE billcodevalues = vc WITH protect, noconstant("")
   DECLARE sourcevocabularydisplay = vc WITH protect, noconstant("")
   CALL getbillcodeschedidforuser(0)
   SELECT
    IF (size(billcodeschedules->billcodeschedule,5) > 0)
     FROM charge_mod cm,
      nomenclature n
     PLAN (cm
      WHERE expand(num,1,size(request->chargedetaillist,5),cm.charge_item_id,request->
       chargedetaillist[num].chargeid)
       AND cm.charge_mod_type_cd=cs13019_bill_code
       AND cm.active_ind=true
       AND expand(num,1,size(billcodeschedules->billcodeschedule,5),cm.field1_id,billcodeschedules->
       billcodeschedule[num].bcschedid))
      JOIN (n
      WHERE (n.nomenclature_id= Outerjoin(cm.nomen_id))
       AND (n.active_ind= Outerjoin(true)) )
    ELSE
     FROM charge_mod cm,
      nomenclature n
     PLAN (cm
      WHERE expand(num,1,size(request->chargedetaillist,5),cm.charge_item_id,request->
       chargedetaillist[num].chargeid)
       AND cm.charge_mod_type_cd=cs13019_bill_code
       AND cm.active_ind=true)
      JOIN (n
      WHERE (n.nomenclature_id= Outerjoin(cm.nomen_id))
       AND (n.active_ind= Outerjoin(true)) )
    ENDIF
    DISTINCT INTO "nl:"
    billcodemeaning = cnvtupper(uar_get_code_meaning(cm.field1_id))
    ORDER BY cm.charge_item_id, billcodemeaning, cm.field2_id
    HEAD cm.charge_item_id
     billcodemodelcount = 0, pos = locateval(idx,1,size(reply->chargedetaillist,5),cm.charge_item_id,
      reply->chargedetaillist[idx].chargeid)
    HEAD billcodemeaning
     billcodemodelcount += 1, stat = alterlist(reply->chargedetaillist[pos].billcodesmodel,
      billcodemodelcount), reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].
     billcodetype = billcodemeaning,
     billcodecount = 0, billcodevalues = "", sourcevocabularydisplay = ""
    DETAIL
     billcodecount += 1, stat = alterlist(reply->chargedetaillist[pos].billcodesmodel[
      billcodemodelcount].billcodes,billcodecount), reply->chargedetaillist[pos].billcodesmodel[
     billcodemodelcount].billcodes[billcodecount].chargemodifierid = cm.charge_mod_id,
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[billcodecount].field6
      = cm.field6, reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[
     billcodecount].field7 = cm.field7, reply->chargedetaillist[pos].billcodesmodel[
     billcodemodelcount].billcodes[billcodecount].field1id = cm.field1_id,
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[billcodecount].
     field2id = cm.field2_id, reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].
     billcodes[billcodecount].field3id = cm.field3_id, reply->chargedetaillist[pos].billcodesmodel[
     billcodemodelcount].billcodes[billcodecount].field4id = cm.field4_id,
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[billcodecount].
     field5id = cm.field5_id, reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].
     billcodes[billcodecount].nomenid = cm.nomen_id, reply->chargedetaillist[pos].billcodesmodel[
     billcodemodelcount].billcodes[billcodecount].cm1nbr = cm.cm1_nbr,
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[billcodecount].code1cd
      = cm.code1_cd
     IF (n.source_vocabulary_cd > 0.0)
      sourcevocabularydisplay = uar_get_code_display(n.source_vocabulary_cd)
     ELSE
      sourcevocabularydisplay = ""
     ENDIF
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodes[billcodecount].
     sourcevocabularydisplay = sourcevocabularydisplay
     IF (((billcodemeaning="MODIFIER") OR (billcodemeaning="ICD9")) )
      IF (billcodecount=1)
       billcodevalues = cm.field6
      ELSEIF (billcodecount < 5)
       billcodevalues = concat(billcodevalues," ",cm.field6)
      ENDIF
     ELSEIF (cm.field2_id <= 1)
      billcodevalues = cm.field6
     ENDIF
    FOOT  billcodemeaning
     IF (billcodecount > 4)
      billcodevalues = concat(billcodevalues,"...")
     ENDIF
     reply->chargedetaillist[pos].billcodesmodel[billcodemodelcount].billcodevalues = billcodevalues
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->chargedetaillist,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     charge c,
     charge_event_mod cem
    PLAN (d1
     WHERE maxrec(d2,size(reply->chargedetaillist[d1.seq].billcodesmodel,5)))
     JOIN (d2
     WHERE maxrec(d3,size(reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes,5)))
     JOIN (d3)
     JOIN (c
     WHERE (c.charge_item_id=reply->chargedetaillist[d1.seq].chargeid))
     JOIN (cem
     WHERE cem.charge_event_id=c.charge_event_id
      AND cem.charge_event_mod_type_cd=cs13019_bill_code
      AND (cem.field1_id=reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes[d3.seq].
     field1id)
      AND (cem.field3_id=reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes[d3.seq].
     field3id)
      AND (cem.field6=reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes[d3.seq].field6
     )
      AND (cem.nomen_id=reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes[d3.seq].
     nomenid)
      AND cem.active_ind=true)
    DETAIL
     reply->chargedetaillist[d1.seq].billcodesmodel[d2.seq].billcodes[d3.seq].chargeeventmodid = cem
     .charge_event_mod_id
    WITH nocounter
   ;end select
   CALL logmessage("getBillCodeData","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getbillcodeschedidforuser(dummyvar=i2) =null)
   CALL logmessage("getBillCodeSchedIdForUser","Entering...",log_debug)
   DECLARE cntbcsched = i4 WITH protect, noconstant(0)
   DECLARE securitypref = i2 WITH protect, noconstant(false)
   SET securitypref = initbcschedsecuritypreference(0)
   SELECT
    IF (securitypref)
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      code_value cv
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=cs26078_sched_cd
       AND cor.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=cor.key1_id
       AND cv.code_set=14002
       AND cv.active_ind=1)
    ELSE
     FROM code_value cv
     WHERE cv.code_set=14002
      AND cv.active_ind=true
      AND cv.cdf_meaning IN ("ICD9", "PROCCODE", "MODIFIER")
    ENDIF
    INTO "nl:"
    ORDER BY cv.code_value
    HEAD cv.code_value
     IF (securitypref)
      cntbcsched += 1, stat = alterlist(billcodeschedules->billcodeschedule,cntbcsched),
      billcodeschedules->billcodeschedule[cntbcsched].bcschedid = cv.code_value
     ENDIF
     IF (cv.cdf_meaning="ICD9"
      AND (reply->icddiagschedfield1id=0.0))
      reply->icddiagschedfield1id = cv.code_value
     ELSEIF (cv.cdf_meaning="PROCCODE"
      AND (reply->icdprocschedfield1id=0.0))
      reply->icdprocschedfield1id = cv.code_value
     ELSEIF (cv.cdf_meaning="MODIFIER"
      AND (reply->modifierschedfield1id=0.0))
      reply->modifierschedfield1id = cv.code_value
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage("getBillCodeSchedIdForUser","Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (initbcschedsecuritypreference(dummyvar=i2) =i2)
   CALL logmessage("initBCSchedSecurityPreference","Entering...",log_debug)
   DECLARE nrepcount = i4 WITH protect, noconstant(0)
   DECLARE iflag = i2 WITH protect, noconstant(false)
   RECORD afc_dm_request(
     1 info_name_qual = i2
     1 info[1]
       2 info_name = vc
     1 info_name = vc
   ) WITH protect
   RECORD afc_dm_reply(
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
   SET afc_dm_request->info_name_qual = 1
   SET afc_dm_request->info[1].info_name = "BILL CODE SCHED SECURITY"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    FOR (nrepcount = 1 TO size(afc_dm_reply->dm_info,5))
      IF ((afc_dm_reply->dm_info[nrepcount].info_name="BILL CODE SCHED SECURITY")
       AND (afc_dm_reply->dm_info[nrepcount].info_char="Y"))
       SET iflag = true
      ENDIF
    ENDFOR
   ENDIF
   CALL logmessage("initBCSchedSecurityPreference","Exiting...",log_debug)
   RETURN(iflag)
 END ;Subroutine
 SUBROUTINE (logmodcapability(dummyvar=i2) =null)
   DECLARE lon_collector_id = vc WITH protect, constant("2015.2.00025.1")
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub logModCapability")
    CALL echo("----------------------------------")
    CALL echorecord(request)
    CALL echo(lon_collector_id)
   ENDIF
   RECORD capabilitylogrequest(
     1 capability_ident = vc
     1 teamname = vc
     1 entities[*]
       2 entity_id = f8
       2 entity_name = vc
   ) WITH protect
   RECORD capabilitylogreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET capabilitylogrequest->capability_ident = lon_collector_id
   SET capabilitylogrequest->teamname = "PATIENT_ACCOUNTING"
   SET stat = alterlist(capabilitylogrequest->entities,size(request->chargedetaillist,5))
   FOR (num = 1 TO size(request->chargedetaillist,5))
    SET capabilitylogrequest->entities[num].entity_id = request->chargedetaillist[num].chargeid
    SET capabilitylogrequest->entities[num].entity_name = "CHARGE"
   ENDFOR
   CALL echorecord(capabilitylogrequest)
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace("REPLY",
    capabilitylogreply)
   IF ((capabilitylogreply->status_data.status != "S"))
    CALL logmessage(curprog,"logCapabilityInfo: pft_log_solution_capability failed.",log_error)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getflexfielddata(pserviceitemid=f8,pchargeid=f8,pchargeidx=i4,prchargeinfo=vc(ref)) =i2)
   CALL logmessage("getFlexFieldData","Entering...",log_debug)
   DECLARE flexfieldcnt = i2 WITH protect, noconstant(0)
   DECLARE categorycnt = i4 WITH protect, noconstant(0)
   DECLARE icount = i4 WITH protect, noconstant(0)
   RECORD afcgetfieldsrequest(
     1 serviceitems[1]
       2 serviceitemid = f8
       2 chargeid = f8
   ) WITH protect
   RECORD afcgetfieldsreply(
     1 serviceitems[*]
       2 serviceitemid = f8
       2 categories[*]
         3 categoryname = vc
         3 fields[*]
           4 fieldcode = f8
           4 fieldrequiredind = i2
           4 fielddisplay = vc
           4 fieldtype = vc
           4 optionlist[*]
             5 optionvalue = vc
             5 optioncd = f8
           4 fieldmeaning = vc
         3 categorycd = f8
         3 categorymeaning = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET afcgetfieldsrequest->serviceitems[1].serviceitemid = pserviceitemid
   SET afcgetfieldsrequest->serviceitems[1].chargeid = pchargeid
   EXECUTE afc_rca_get_flds_for_svc_item  WITH replace("REQUEST",afcgetfieldsrequest), replace(
    "REPLY",afcgetfieldsreply)
   IF ((afcgetfieldsreply->status_data.status != "S"))
    CALL logmessage("getFlexFieldData","afc_rca_get_flds_for_svc_item did not return success",
     log_error)
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(afcgetfieldsreply->serviceitems[1].categories,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields,5)))
     JOIN (d2)
    ORDER BY d1.seq
    HEAD d1.seq
     flexfieldcnt = 0, icount = 1
    DETAIL
     IF ((afcgetfieldsreply->serviceitems[1].categories[d1.seq].categoryname != i18n_qty_calculation)
     )
      IF (icount=1)
       categorycnt += 1, stat = alterlist(prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel,
        categorycnt), prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].
       categorydescription = afcgetfieldsreply->serviceitems[1].categories[d1.seq].categoryname,
       prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].categorycd =
       afcgetfieldsreply->serviceitems[1].categories[d1.seq].categorycd
      ENDIF
      flexfieldcnt += 1, stat = alterlist(prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[
       categorycnt].chargemodifiermodel,flexfieldcnt), prchargeinfo->chargedetaillist[pchargeidx].
      flexfieldsmodel[categorycnt].chargemodifiermodel[flexfieldcnt].modifiercd = afcgetfieldsreply->
      serviceitems[1].categories[d1.seq].fields[d2.seq].fieldcode,
      prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].chargemodifiermodel[
      flexfieldcnt].requiredind = afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields[d2.seq
      ].fieldrequiredind, prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].
      chargemodifiermodel[flexfieldcnt].modifierdescription = afcgetfieldsreply->serviceitems[1].
      categories[d1.seq].fields[d2.seq].fielddisplay, prchargeinfo->chargedetaillist[pchargeidx].
      flexfieldsmodel[categorycnt].chargemodifiermodel[flexfieldcnt].fielddatatype =
      afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields[d2.seq].fieldtype
      IF ((afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields[d2.seq].fieldtype="INDICATOR"
      ))
       prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].chargemodifiermodel[
       flexfieldcnt].fieldvaluenumber = - (1)
      ENDIF
      IF (size(afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields[d2.seq].optionlist,5) > 0
      )
       stat = movereclist(afcgetfieldsreply->serviceitems[1].categories[d1.seq].fields[d2.seq].
        optionlist,prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[categorycnt].
        chargemodifiermodel[flexfieldcnt].fieldvalueoptionlist,1,0,size(afcgetfieldsreply->
         serviceitems[1].categories[d1.seq].fields[d2.seq].optionlist,5),
        true)
      ENDIF
      icount += 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel,
       5))),
     (dummyt d2  WITH seq = 1),
     charge_mod cm,
     charge c,
     charge_event_mod cem
    PLAN (d1
     WHERE maxrec(d2,size(prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].
       chargemodifiermodel,5)))
     JOIN (d2)
     JOIN (cm
     WHERE cm.charge_item_id=pchargeid
      AND cm.active_ind=true
      AND cm.charge_mod_type_cd=cs13019_flex_cd
      AND (cm.field1_id=prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].
     chargemodifiermodel[d2.seq].modifiercd))
     JOIN (c
     WHERE c.charge_item_id=cm.charge_item_id
      AND c.active_ind=true)
     JOIN (cem
     WHERE cem.charge_event_id=c.charge_event_id
      AND cem.charge_event_mod_type_cd=cs13019_flex_cd
      AND (cem.field1_id=prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].
     chargemodifiermodel[d2.seq].modifiercd))
    DETAIL
     prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].chargemodifiermodel[d2.seq].
     chargemodifierid = cm.charge_mod_id, prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[
     d1.seq].chargemodifiermodel[d2.seq].chargeeventmodid = cem.charge_event_mod_id
     IF ((prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].chargemodifiermodel[d2
     .seq].fielddatatype="INDICATOR"))
      prchargeinfo->chargedetaillist[pchargeidx].flexfieldsmodel[d1.seq].chargemodifiermodel[d2.seq].
      fieldvaluenumber = cm.field2_id
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage("getFlexFieldData","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
END GO
