CREATE PROGRAM afc_rca_submit_charge_batches:dba
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
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD chargebatchreq
 RECORD chargebatchreq(
   1 chargebatchid = f8
 )
 FREE RECORD chargebatchrep
 RECORD chargebatchrep(
   1 chargebatchid = f8
   1 createdprsnlid = f8
   1 assignedprsnlid = f8
   1 userdefinedind = i2
   1 statuscd = f8
   1 statusdttm = dq8
   1 createddttm = dq8
   1 accesseddttm = dq8
   1 activeind = i2
   1 chargebatchalias = vc
   1 chargebatchdate = dq8
   1 updt_cnt = i4
   1 chargeevents[*]
     2 chargebatchdetailid = f8
     2 encounterid = f8
     2 personid = f8
     2 orderingphysid = f8
     2 renderingphysid = f8
     2 billitemid = f8
     2 serviceitemident = vc
     2 serviceitemidenttypecd = f8
     2 serviceitemqty = f8
     2 serviceitempriceamt = f8
     2 serviceitemdesc = vc
     2 servicedttm = dq8
     2 perfloccd = f8
     2 statuscd = f8
     2 extparentreferenceid = f8
     2 extparentreferencecontcd = f8
     2 updt_cnt = i4
     2 copayamt = f8
     2 deductibleamt = f8
     2 patrespflag = i2
     2 batchdetailcodes[*]
       3 chargebatchdetailcodeid = f8
       3 parententityname = vc
       3 parententityid = f8
       3 typecd = f8
       3 typeident = vc
       3 priorityseq = i4
       3 nomendesc = vc
     2 flexfields[*]
       3 fieldtypecd = f8
       3 fielddatetime = dq8
       3 fieldchar = vc
       3 fieldnbr = f8
       3 fieldind = i2
       3 fieldcd = f8
       3 fieldvaluetype = vc
     2 serviceresourcecd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD chrgbatchreq
 RECORD chrgbatchreq(
   1 objarray[*]
     2 charge_batch_id = f8
     2 active_ind = i2
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_tm_null = i2
     2 updt_cnt = i4
 )
 FREE RECORD chrgbatchrep
 RECORD chrgbatchrep(
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
 )
 FREE RECORD chrgeventreq
 RECORD chrgeventreq(
   1 objarray[*]
     2 charge_batch_detail_id = f8
     2 status_cd = f8
     2 updt_cnt = i4
 )
 FREE RECORD chrgeventrep
 RECORD chrgeventrep(
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
 )
 FREE RECORD applyspremitreq
 RECORD applyspremitreq(
   1 payment_details[*]
     2 payment_method_cd = f8
     2 payment_number_desc = vc
     2 payor_name = vc
     2 cc_auth_nbr = vc
     2 cc_beg_eff_dt_tm = dq8
     2 cc_end_eff_dt_tm = dq8
     2 check_date = dq8
     2 result_cur_cd = f8
     2 tendered_cur_cd = f8
     2 tendered_amount = f8
     2 change_due_amount = f8
     2 payment_amount = f8
   1 transactions[*]
     2 acct_id = f8
     2 encntr_id = f8
     2 pft_encntr_id = f8
     2 trans_alias_id = f8
     2 amount = f8
     2 post_dt_tm = dq8
     2 trans_comment_text = vc
 )
 FREE RECORD applyspremitrep
 RECORD applyspremitrep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 )
 IF ( NOT (validate(cs13016_charge_entry_cd)))
  DECLARE cs13016_charge_entry_cd = f8 WITH protect, constant(getcodevalue(13016,"CHARGE ENTRY",0))
 ENDIF
 IF ( NOT (validate(cs13028_charge_now_cd)))
  DECLARE cs13028_charge_now_cd = f8 WITH protect, constant(getcodevalue(13028,"CHARGE NOW",0))
 ENDIF
 IF ( NOT (validate(cs13029_ordered_cd)))
  DECLARE cs13029_ordered_cd = f8 WITH protect, constant(getcodevalue(13029,"ORDERED",0))
 ENDIF
 IF ( NOT (validate(cs13029_rendering_cd)))
  DECLARE cs13029_rendering_cd = f8 WITH protect, constant(getcodevalue(13029,"VERIFIED",0))
 ENDIF
 IF ( NOT (validate(cs13029_complete_cd)))
  DECLARE cs13029_complete_cd = f8 WITH protect, constant(getcodevalue(13029,"COMPLETE",0))
 ENDIF
 IF ( NOT (validate(cs4002321_modifier_cd)))
  DECLARE cs4002321_modifier_cd = f8 WITH protect, constant(getcodevalue(4002321,"MODIFIER",0))
 ENDIF
 IF ( NOT (validate(cs4002321_diag_cd)))
  DECLARE cs4002321_diag_cd = f8 WITH protect, constant(getcodevalue(4002321,"DIAG",0))
 ENDIF
 IF ( NOT (validate(cs13019_bill_code_cd)))
  DECLARE cs13019_bill_code_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs13019_flex_cd)))
  DECLARE cs13019_flex_cd = f8 WITH protect, constant(getcodevalue(13019,"FLEX",0))
 ENDIF
 IF ( NOT (validate(cs13019_prompt_cd)))
  DECLARE cs13019_prompt_cd = f8 WITH protect, constant(getcodevalue(13019,"PROMPT",0))
 ENDIF
 IF ( NOT (validate(cs14002_modifier_cd)))
  DECLARE cs14002_modifier_cd = f8 WITH protect, constant(getcodevalue(14002,"MODIFIER",0))
 ENDIF
 IF ( NOT (validate(cs14002_icd9_cd)))
  DECLARE cs14002_icd9_cd = f8 WITH protect, constant(getcodevalue(14002,"ICD9",0))
 ENDIF
 IF ( NOT (validate(cs4002322_submitted_cd)))
  DECLARE cs4002322_submitted_cd = f8 WITH protect, constant(getcodevalue(4002322,"SUBMITTED",0))
 ENDIF
 IF ( NOT (validate(cs4002322_pending_cd)))
  DECLARE cs4002322_pending_cd = f8 WITH protect, constant(getcodevalue(4002322,"PENDING",0))
 ENDIF
 IF ( NOT (validate(cs4002352_suprvsngprov_cd)))
  DECLARE cs4002352_suprvsngprov_cd = f8 WITH protect, constant(getcodevalue(4002352,"SUPRVSNGPROV",0
    ))
 ENDIF
 DECLARE cntdetail = i4 WITH protect, noconstant(0)
 DECLARE cntcodes = i4 WITH protect, noconstant(0)
 DECLARE appid = i4 WITH protect, constant(3202004)
 DECLARE taskid = i4 WITH protect, constant(3202004)
 DECLARE reqid = i4 WITH protect, constant(951093)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE hchargeevent = i4 WITH public, noconstant(0)
 DECLARE hchargeeventact = i4 WITH public, noconstant(0)
 DECLARE hprsnl = i4 WITH public, noconstant(0)
 DECLARE hmods = i4 WITH public, noconstant(0)
 DECLARE hchargeeventmod = i4 WITH public, noconstant(0)
 DECLARE srvstat = i4 WITH public, noconstant(0)
 DECLARE loopce = i4 WITH public, noconstant(0)
 DECLARE loopcem = i4 WITH public, noconstant(0)
 DECLARE loopflds = i4 WITH public, noconstant(0)
 DECLARE loopflds2 = i4 WITH public, noconstant(0)
 DECLARE cnttrans = i4 WITH public, noconstant(0)
 DECLARE loopbatch = i4 WITH public, noconstant(0)
 DECLARE defaultcptmodifier = f8 WITH public, noconstant(0.0)
 DECLARE chrgevntcnt = i4 WITH protect, noconstant(1)
 CALL beginservice("648504.016")
 CALL logmessage("Main","Begining main processing",log_debug)
 CALL impersonatepersonnelinfo(1)
 IF ( NOT (size(request->chargebatchids,5)=0))
  CALL initializeserver("")
 ENDIF
 CALL initializedefaultcptmodifier(defaultcptmodifier)
 FOR (loopbatchids = 1 TO size(request->chargebatchids,5))
   CALL reinitializerecords("")
   SET chargebatchreq->chargebatchid = request->chargebatchids[loopbatchids].chargebatchid
   IF ( NOT (processbatchcharge("")))
    CALL logmessage("Main","Batch unavailable to be submitted, proceed to next batch",log_debug)
   ELSE
    CALL logmessage("Main","Successfully submitted the batch",log_debug)
    FOR (chrgevntcnt = 1 TO size(chargebatchrep->chargeevents,5))
      IF ((chargebatchrep->chargeevents.serviceresourcecd > 0.0))
       CALL logmodcapability(chargebatchrep->chargebatchid)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF (size(request->chargebatchids,5) != 0)
  CALL logmessage("Main","Perform",log_debug)
  SET stat = uar_crmperform(hreq)
  IF (stat=0)
   CALL logmessage("Main","Status = Success",log_debug)
  ELSE
   CALL logmessage("Main","Status = Failure",log_debug)
  ENDIF
  IF (validate(debug,0)=1)
   CALL uar_oen_dump_object(hrequest)
  ENDIF
  CALL endapptaskandrequest("")
 ENDIF
 CALL exitservicesuccess("Exiting script")
 SUBROUTINE (getbilliteminfo(null=vc) =i2)
   CALL logmessage("getBillItemInfo","begin sub",log_debug)
   SELECT INTO "nl:"
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(chargebatchrep->chargeevents,5)))
    PLAN (d1)
     JOIN (b
     WHERE (b.bill_item_id=chargebatchrep->chargeevents[d1.seq].billitemid))
    DETAIL
     chargebatchrep->chargeevents[d1.seq].extparentreferenceid = b.ext_parent_reference_id,
     chargebatchrep->chargeevents[d1.seq].extparentreferencecontcd = b.ext_parent_contributor_cd
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("getBillItemInfo","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (getpersoninfo(null=vc) =i2)
   CALL logmessage("getPersonInfo","begin sub",log_debug)
   SELECT INTO "nl:"
    FROM encounter e,
     (dummyt d1  WITH seq = value(size(chargebatchrep->chargeevents,5)))
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=chargebatchrep->chargeevents[d1.seq].encounterid)
      AND e.active_ind=1)
    DETAIL
     chargebatchrep->chargeevents[d1.seq].personid = e.person_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("getPersonInfo","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (getnomeninfo(null=vc) =null)
   CALL logmessage("getNomenInfo","begin sub",log_debug)
   SELECT INTO "nl:"
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(size(chargebatchrep->chargeevents,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(chargebatchrep->chargeevents[d1.seq].batchdetailcodes,5)))
     JOIN (d2
     WHERE (chargebatchrep->chargeevents[d1.seq].batchdetailcodes[d2.seq].parententityname=
     "NOMENCLATURE"))
     JOIN (n
     WHERE (n.nomenclature_id=chargebatchrep->chargeevents[d1.seq].batchdetailcodes[d2.seq].
     parententityid))
    DETAIL
     chargebatchrep->chargeevents[d1.seq].batchdetailcodes[d2.seq].nomendesc = n.source_string
    WITH nocounter
   ;end select
   CALL logmessage("getNomenInfo","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (sendrequesttoserver(null=vc) =null)
   CALL logmessage("sendRequestToServer","begin sub",log_debug)
   SET srvstat = uar_srvsetshort(hrequest,"charge_event_qual",size(chargebatchrep->chargeevents,5))
   FOR (loopce = 1 TO size(chargebatchrep->chargeevents,5))
     SET curalias ce chargebatchrep->chargeevents[loopce]
     SET hchargeevent = uar_srvadditem(hrequest,"charge_event")
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_id",ce->chargebatchdetailid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_cont_cd",cs13016_charge_entry_cd)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_id",ce->extparentreferenceid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_cont_cd",ce->
      extparentreferencecontcd)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_id",ce->chargebatchdetailid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_cont_cd",cs13016_charge_entry_cd)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_id",ce->extparentreferenceid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_cont_cd",ce->
      extparentreferencecontcd)
     SET srvstat = uar_srvsetdouble(hchargeevent,"person_id",ce->personid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_id",ce->encounterid)
     SET srvstat = uar_srvsetdouble(hchargeevent,"perf_loc_cd",ce->perfloccd)
     SET srvstat = uar_srvsetshort(hchargeevent,"charge_event_act_qual",1)
     SET hchargeeventact = uar_srvadditem(hchargeevent,"charge_event_act")
     SET srvstat = uar_srvsetdate(hchargeeventact,"service_dt_tm",cnvtdatetime(ce->servicedttm))
     SET srvstat = uar_srvsetdouble(hchargeeventact,"cea_type_cd",cs13029_complete_cd)
     SET srvstat = uar_srvsetdouble(hchargeeventact,"charge_type_cd",cs13028_charge_now_cd)
     SET srvstat = uar_srvsetdouble(hchargeeventact,"rx_quantity",ce->serviceitemqty)
     SET srvstat = uar_srvsetshort(hchargeeventact,"prsnl_qual",1)
     SET srvstat = uar_srvsetdouble(hchargeeventact,"cea_misc5_id",ce->copayamt)
     SET srvstat = uar_srvsetdouble(hchargeeventact,"item_deductible_amt",ce->deductibleamt)
     SET srvstat = uar_srvsetshort(hchargeeventact,"patient_responsibility_flag",ce->patrespflag)
     SET srvstat = uar_srvsetdouble(hchargeeventact,"service_resource_cd",ce->serviceresourcecd)
     SET hprsnl = uar_srvadditem(hchargeeventact,"prsnl")
     SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",cs13029_ordered_cd)
     SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ce->orderingphysid)
     SET hprsnl = uar_srvadditem(hchargeeventact,"prsnl")
     SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",cs13029_rendering_cd)
     SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ce->renderingphysid)
     SET hmods = uar_srvgetstruct(hchargeevent,"mods")
     IF (size(ce->batchdetailcodes,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(ce->batchdetailcodes,5)))
       PLAN (d1
        WHERE (ce->batchdetailcodes[d1.seq].typecd IN (cs4002321_modifier_cd, cs4002321_diag_cd)))
       DETAIL
        hchargeeventmod = uar_srvadditem(hmods,"charge_mods"), srvstat = uar_srvsetdouble(
         hchargeeventmod,"charge_event_mod_type_cd",cs13019_bill_code_cd)
        IF ((ce->batchdetailcodes[d1.seq].typecd=cs4002321_modifier_cd))
         srvstat = uar_srvsetdouble(hchargeeventmod,"field1_id",defaultcptmodifier), srvstat =
         uar_srvsetdouble(hchargeeventmod,"field3_id",ce->batchdetailcodes[d1.seq].parententityid),
         srvstat = uar_srvsetstring(hchargeeventmod,"field7",uar_get_code_display(ce->
           batchdetailcodes[d1.seq].parententityid))
        ELSEIF ((ce->batchdetailcodes[d1.seq].typecd=cs4002321_diag_cd))
         srvstat = uar_srvsetdouble(hchargeeventmod,"field1_id",cs14002_icd9_cd), srvstat =
         uar_srvsetdouble(hchargeeventmod,"nomen_id",ce->batchdetailcodes[d1.seq].parententityid),
         srvstat = uar_srvsetstring(hchargeeventmod,"field7",nullterm(ce->batchdetailcodes[d1.seq].
           nomendesc))
        ENDIF
        srvstat = uar_srvsetstring(hchargeeventmod,"field6",nullterm(ce->batchdetailcodes[d1.seq].
          typeident)), srvstat = uar_srvsetdouble(hchargeeventmod,"field2_id",cnvtreal(ce->
          batchdetailcodes[d1.seq].priorityseq))
       WITH nocounter
      ;end select
     ENDIF
     SET hmods = uar_srvgetstruct(hchargeevent,"mods")
     IF (size(ce->flexfields,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(ce->flexfields,5))),
        bill_item_modifier bim
       PLAN (d1)
        JOIN (bim
        WHERE (bim.bill_item_id=ce->billitemid)
         AND (bim.key1_id=ce->flexfields[d1.seq].fieldtypecd)
         AND bim.bill_item_type_cd IN (cs13019_flex_cd, cs13019_prompt_cd)
         AND bim.active_ind=true)
       ORDER BY bim.key1_id
       DETAIL
        hchargeeventmod = uar_srvadditem(hmods,"charge_mods")
        IF (bim.bill_item_type_cd=cs13019_prompt_cd)
         srvstat = uar_srvsetdouble(hchargeeventmod,"charge_event_mod_type_cd",cs13019_prompt_cd),
         srvstat = uar_srvsetdouble(hchargeeventmod,"field3_id",bim.bim1_int), srvstat =
         uar_srvsetdouble(hchargeeventmod,"field4_id",cnvtreal(bim.bim_ind))
         IF ((ce->flexfields[d1.seq].fielddatetime != 0.0))
          srvstat = uar_srvsetstring(hchargeeventmod,"field6",nullterm(format(cnvtdatetime(ce->
              flexfields[d1.seq].fielddatetime),"YYYYMMDDHHMMSSCC;;q")))
         ELSE
          srvstat = uar_srvsetdouble(hchargeeventmod,"field2_id",ce->flexfields[d1.seq].fieldnbr)
         ENDIF
        ELSE
         srvstat = uar_srvsetdouble(hchargeeventmod,"charge_event_mod_type_cd",cs13019_flex_cd),
         srvstat = uar_srvsetdouble(hchargeeventmod,"field2_id",cnvtreal(ce->flexfields[d1.seq].
           fieldind))
        ENDIF
        IF ((ce->flexfields[d1.seq].fieldvaluetype="PROVLOOKUP"))
         srvstat = uar_srvsetdouble(hchargeeventmod,"field3_id",ce->flexfields[d1.seq].fieldnbr)
        ELSE
         srvstat = uar_srvsetdouble(hchargeeventmod,"cm1_nbr",ce->flexfields[d1.seq].fieldnbr)
        ENDIF
        srvstat = uar_srvsetdouble(hchargeeventmod,"field1_id",ce->flexfields[d1.seq].fieldtypecd),
        srvstat = uar_srvsetstring(hchargeeventmod,"field1",nullterm(ce->flexfields[d1.seq].fieldchar
          )), srvstat = uar_srvsetstring(hchargeeventmod,"field2",nullterm(ce->flexfields[d1.seq].
          fieldvaluetype)),
        srvstat = uar_srvsetstring(hchargeeventmod,"field7",uar_get_code_display(ce->flexfields[d1
          .seq].fieldtypecd)), srvstat = uar_srvsetdouble(hchargeeventmod,"code1_cd",ce->flexfields[
         d1.seq].fieldcd), srvstat = uar_srvsetdate(hchargeeventmod,"activity_dt_tm",cnvtdatetime(ce
          ->flexfields[d1.seq].fielddatetime))
       WITH outerjoin = d1, nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL logmessage("sendRequestToServer","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (updatebatchstatus(null=vc) =null)
   CALL logmessage("updateBatchStatus","begin sub",log_debug)
   SET stat = alterlist(chrgbatchreq->objarray,1)
   SET chrgbatchreq->objarray[1].charge_batch_id = chargebatchrep->chargebatchid
   SET chrgbatchreq->objarray[1].status_cd = cs4002322_submitted_cd
   SET chrgbatchreq->objarray[1].status_dt_tm = cnvtdatetime(sysdate)
   SET chrgbatchreq->objarray[1].updt_cnt = chargebatchrep->updt_cnt
   SET chrgbatchreq->objarray[1].active_ind = 1
   EXECUTE afc_da_upt_charge_batch  WITH replace("REQUEST",chrgbatchreq), replace("REPLY",
    chrgbatchrep)
   IF ((chrgbatchrep->status_data.status="S"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("updateBatchStatus","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (updatechargeeventstatus(null=vc) =i2)
   CALL logmessage("updateChargeEventStatus","begin sub",log_debug)
   SET cntdetail = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(chargebatchrep->chargeevents,5)))
    WHERE (chargebatchrep->chargeevents[d1.seq].chargebatchdetailid > 0)
    DETAIL
     cntdetail += 1
     IF (mod(cntdetail,10)=1)
      stat = alterlist(chrgeventreq->objarray,(cntdetail+ 9))
     ENDIF
     chrgeventreq->objarray[cntdetail].charge_batch_detail_id = chargebatchrep->chargeevents[d1.seq].
     chargebatchdetailid, chrgeventreq->objarray[cntdetail].status_cd = cs4002322_submitted_cd,
     chrgeventreq->objarray[cntdetail].updt_cnt = chargebatchrep->chargeevents[d1.seq].updt_cnt
    WITH nocounter
   ;end select
   SET stat = alterlist(chrgeventreq->objarray,cntdetail)
   EXECUTE afc_da_upt_charge_batch_detail  WITH replace("REQUEST",chrgeventreq), replace("REPLY",
    chrgeventrep)
   IF ((chrgeventrep->status_data.status="S"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("updateChargeEventStatus","end sub",log_debug)
 END ;Subroutine
 SUBROUTINE (applyselfpayremittance(null=vc) =null)
  FOR (loopce = 1 TO size(chargebatchrep->chargeevents,5))
    FOR (loopflds = 1 TO size(chargebatchrep->chargeevents[loopce].flexfields,5))
      IF (nullterm(uar_get_code_meaning(chargebatchrep->chargeevents[loopce].flexfields[loopflds].
        fieldtypecd))="TRANSALIAS")
       SET cnttrans += 1
       SET stat = alterlist(applyspremitreq->transactions,cnttrans)
       SET applyspremitreq->transactions[cnttrans].encntr_id = chargebatchrep->chargeevents[loopce].
       encounterid
       SET applyspremitreq->transactions[cnttrans].trans_alias_id = chargebatchrep->chargeevents[
       loopce].flexfields[loopflds].fieldcd
       FOR (loopflds2 = 1 TO size(chargebatchrep->chargeevents[loopce].flexfields,5))
         IF (((nullterm(uar_get_code_meaning(chargebatchrep->chargeevents[loopce].flexfields[
           loopflds2].fieldtypecd))="TRANSAMT") OR (nullterm(uar_get_code_meaning(chargebatchrep->
           chargeevents[loopce].flexfields[loopflds2].fieldtypecd))="TRANSCOMNT")) )
          IF (nullterm(uar_get_code_meaning(chargebatchrep->chargeevents[loopce].flexfields[loopflds2
            ].fieldtypecd))="TRANSAMT")
           SET applyspremitreq->transactions[cnttrans].amount = chargebatchrep->chargeevents[loopce].
           flexfields[loopflds2].fieldnbr
          ELSE
           SET applyspremitreq->transactions[cnttrans].trans_comment_text = chargebatchrep->
           chargeevents[loopce].flexfields[loopflds2].fieldchar
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
  IF (size(applyspremitreq->transactions,5) > 0)
   EXECUTE pft_apply_sp_remittance  WITH replace("REQUEST",applyspremitreq), replace("REPLY",
    applyspremitrep)
   IF ((reply->status_data.status != "S"))
    CALL logmessage("applySelfPayRemittance","Failed applying self pay remittance",log_debug)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (initializeserver(null=vc) =null)
   CALL logmessage("initializeServer","begin sub",log_debug)
   SET stat = uar_crmbeginapp(appid,happ)
   IF (stat=0)
    CALL logmessage("initializeServer","successful begin app",log_debug)
    SET stat = uar_crmbegintask(happ,taskid,htask)
    IF (stat=0)
     CALL logmessage("initializeServer","successful begin task",log_debug)
     SET stat = uar_crmbeginreq(htask,"",reqid,hreq)
     IF (stat=0)
      SET hrequest = uar_crmgetrequest(hreq)
      IF (hrequest=0)
       CALL endapptaskandrequest("")
       CALL exitservicefailure("Failed getting request",go_to_exit_script)
      ELSE
       CALL logmessage("initializeServer","Successful in getting Request",log_debug)
      ENDIF
     ELSE
      CALL uar_crmendtask(htask)
      CALL uar_crmendapp(happ)
      CALL exitservicefailure("Failed getting request handle",go_to_exit_script)
     ENDIF
    ELSE
     CALL uar_crmendapp(happ)
     CALL exitservicefailure("Failed getting task handle",go_to_exit_script)
    ENDIF
   ELSE
    CALL exitservicefailure("Failed getting app handle",go_to_exit_script)
   ENDIF
 END ;Subroutine
 SUBROUTINE (isvalidbatchid(null=vc) =i2)
   CALL logmessage("isValidBatchId","begin sub",log_debug)
   IF ((chargebatchrep->statuscd=cs4002322_submitted_cd))
    CALL logmessage("isValidBatchId","Batch has already been submitted",log_debug)
    RETURN(false)
   ENDIF
   FOR (cntdetail = 1 TO size(chargebatchrep->chargeevents,5))
     IF ((chargebatchrep->chargeevents[cntdetail].statuscd != cs4002322_pending_cd))
      CALL logmessage("isValidBatchId","Batch contains invalid charges",log_debug)
      RETURN(false)
     ENDIF
   ENDFOR
   CALL logmessage("isValidBatchId","Get bill item info",log_debug)
   IF ( NOT (getbilliteminfo("")))
    CALL logmessage("isValidBatchId","Failed getting bill item info",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage("isValidBatchId","Get person info",log_debug)
   IF ( NOT (getpersoninfo("")))
    CALL logmessage("isValidBatchId","Failed getting person info",log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (endapptaskandrequest(null=vc) =null)
   CALL logmessage("endAppTaskAndRequest","begin sub",log_debug)
   CALL uar_crmendreq(hreq)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
 END ;Subroutine
 SUBROUTINE (processbatchcharge(null=vc) =i2)
   CALL logmessage("processBatchCharge","begin sub",log_debug)
   EXECUTE afc_rca_get_charge_batch  WITH replace("REQUEST",chargebatchreq), replace("REPLY",
    chargebatchrep)
   IF ((chargebatchrep->status_data.status != "S"))
    CALL logmessage("processBatchCharge","Failed retrieving charge batch",log_debug)
    RETURN(false)
   ENDIF
   IF ( NOT (isvalidbatchid("")))
    CALL logmessage("processBatchCharge","INVALID BatchID",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage("processBatchCharge","Get nomen info",log_debug)
   CALL getnomeninfo("")
   CALL logmessage("processBatchCharge","Post adjustments",log_debug)
   CALL applyselfpayremittance("")
   CALL logmessage("processBatchCharge","Send the request to the server",log_debug)
   CALL sendrequesttoserver("")
   CALL logmessage("processBatchCharge","Update charge event status",log_debug)
   IF ( NOT (updatechargeeventstatus("")))
    CALL logmessage("processBatchCharge","Failed updating charge event status",log_debug)
    RETURN(false)
   ENDIF
   CALL logmessage("processBatchCharge","Update batch status",log_debug)
   IF ( NOT (updatebatchstatus("")))
    CALL logmessage("processBatchCharge","Failed updating batch status",log_debug)
    RETURN(false)
   ENDIF
   IF (validate(request->dohardcommit,false)=true)
    COMMIT
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (reinitializerecords(null=vc) =null)
   SET stat = initrec(chargebatchreq)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
   SET stat = initrec(chargebatchrep)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
   SET stat = initrec(applyspremitreq)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
   SET stat = initrec(applyspremitrep)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
   SET stat = initrec(chrgeventreq)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
   SET stat = initrec(chrgeventrep)
   IF (stat=0)
    CALL exitservicefailure("Failed to clear the record",go_to_exit_script)
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializedefaultcptmodifier(pdefaultcptmodifier=f8(ref)) =null)
   CALL logmessage("initializedefaultCPTModifier","Entering...",log_debug)
   DECLARE cptmodifierschedulecd = f8 WITH protect, noconstant(0.0)
   SET pdefaultcptmodifier = cs14002_modifier_cd
   CALL echo(build("pDefaultCPTModifier",pdefaultcptmodifier))
   IF (isbillcodeschedulesecurityturnedon(0))
    CALL getfirstcptmodifierschedforuser(cptmodifierschedulecd)
    IF (cptmodifierschedulecd > 0.0)
     SET pdefaultcptmodifier = cptmodifierschedulecd
    ENDIF
   ENDIF
   CALL echo(build("pDefaultCPTModifier",pdefaultcptmodifier))
   CALL logmessage("initializedefaultCPTModifier","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (isbillcodeschedulesecurityturnedon(dummyvar=i2) =i2)
   CALL logmessage("isBillCodeScheduleSecurityTurnedON","Entering...",log_debug)
   DECLARE statusind = i2 WITH protect, noconstant(false)
   FREE RECORD afc_dm_request
   RECORD afc_dm_request(
     1 info_name_qual = i2
     1 info[*]
       2 info_name = vc
     1 info_name = vc
   )
   FREE RECORD afc_dm_reply
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
   )
   SET afc_dm_request->info_name_qual = 1
   SET stat = alterlist(afc_dm_request->info,1)
   SET afc_dm_request->info[1].info_name = "BILL CODE SCHED SECURITY"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->dm_info_qual > 0))
    IF (cnvtupper(afc_dm_reply->dm_info[1].info_char)="Y")
     SET statusind = true
    ENDIF
   ENDIF
   CALL logmessage("isBillCodeScheduleSecurityTurnedON","Exiting...",log_debug)
   RETURN(statusind)
 END ;Subroutine
 SUBROUTINE (getfirstcptmodifierschedforuser(pfirstcptmodifiersched=f8(ref)) =null)
   CALL logmessage("getFirstCPTModifierSchedForUser","Entering...",log_debug)
   FREE RECORD getschedforuserrequest
   RECORD getschedforuserrequest(
     1 key1_entity_name = vc
     1 schedule_meaning = vc
   )
   FREE RECORD getschedforuserreply
   RECORD getschedforuserreply(
     1 list_for_user = vc
     1 cs_org_reltn_qual = i4
     1 cs_org_reltn[*]
       2 cs_org_reltn_id = f8
       2 organization_id = f8
       2 cs_org_reltn_type_cd = f8
       2 key1_id = f8
       2 org_name = c200
       2 active_ind = i2
   )
   SET getschedforuserrequest->key1_entity_name = "BC_SCHED"
   SET getschedforuserrequest->schedule_meaning = "MODIFIER"
   EXECUTE afc_get_sched_for_user  WITH replace("REQUEST",getschedforuserrequest), replace("REPLY",
    getschedforuserreply)
   IF ((getschedforuserreply->cs_org_reltn_qual > 0))
    SET pfirstcptmodifiersched = getschedforuserreply->cs_org_reltn[1].key1_id
   ENDIF
   CALL logmessage("getFirstCPTModifierSchedForUser","Exiting...",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (impersonatepersonnelinfo(dummyvar=i2) =null)
   DECLARE seccntxt = i4
   DECLARE namelen = i4
   DECLARE domainnamelen = i4
   DECLARE uar_secsetcontext(hctx=i4) = i2
   EXECUTE secrtl  WITH image_axp = "secrtl", image_aix = "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   SET namelen = (uar_secgetclientusernamelen()+ 1)
   SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
   SET stat = memalloc(name,1,build("C",namelen))
   SET stat = memalloc(domainname,1,build("C",domainnamelen))
   SET stat = uar_secgetclientusername(name,namelen)
   SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
   SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
 END ;Subroutine
#exit_script
 SUBROUTINE (logmodcapability(chargebatchid=f8) =null)
   DECLARE lon_collector_id = vc WITH protect, constant("2015.2.00161.1")
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub logModCapability")
    CALL echo("----------------------------------")
    CALL echorecord(chargebatchreq)
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
   SET stat = alterlist(capabilitylogrequest->entities,1)
   SET capabilitylogrequest->entities[1].entity_id = chargebatchid
   SET capabilitylogrequest->entities[1].entity_name = "CHARGE"
   CALL echorecord(capabilitylogrequest)
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace("REPLY",
    capabilitylogreply)
   CALL echorecord(capabilitylogreply)
   IF ((capabilitylogreply->status_data.status != "S"))
    CALL logmessage(curprog,"logCapabilityInfo: pft_log_solution_capability failed.",log_error)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
  CALL echorecord(chargebatchreq)
  CALL echorecord(chargebatchrep)
  CALL echorecord(applyspremitreq)
  CALL echo(build("Default CPT Modifier Code Value:",defaultcptmodifier))
 ENDIF
 FREE RECORD chargebatchreq
 FREE RECORD chargebatchrep
 FREE RECORD chrgbatchreq
 FREE RECORD chrgbatchrep
 FREE RECORD chrgeventreq
 FREE RECORD chrgeventrep
 FREE RECORD applyspremitreq
 FREE RECORD applyspremitrep
END GO
