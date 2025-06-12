CREATE PROGRAM afc_release_charge_sync:dba
 DECLARE afc_reprocess_charge_events = vc WITH protect, constant("CHARGSRV-15575.019")
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 asyncrequesthandle = i4
    1 charges[*]
      2 charge_item_id = f8
      2 charge_act_id = f8
      2 charge_event_id = f8
      2 bill_item_id = f8
      2 charge_description = c200
      2 price_sched_id = f8
      2 payor_id = f8
      2 item_quantity = f8
      2 item_price = f8
      2 item_extended_price = f8
      2 charge_type_cd = f8
      2 suspense_rsn_cd = f8
      2 reason_comment = c200
      2 posted_cd = f8
      2 ord_phys_id = f8
      2 perf_phys_id = f8
      2 order_id = f8
      2 beg_effective_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 admit_type_cd = f8
      2 med_service_cd = f8
      2 institution_cd = f8
      2 department_cd = f8
      2 section_cd = f8
      2 subsection_cd = f8
      2 level5_cd = f8
      2 service_dt_tm = dq8
      2 process_flg = i2
      2 parent_charge_item_id = f8
      2 interface_id = f8
      2 tier_group_cd = f8
      2 def_bill_item_id = f8
      2 verify_phys_id = f8
      2 gross_price = f8
      2 discount_amount = f8
      2 activity_type_cd = f8
      2 research_acct_id = f8
      2 cost_center_cd = f8
      2 abn_status_cd = f8
      2 perf_loc_cd = f8
      2 inst_fin_nbr = c50
      2 ord_loc_cd = f8
      2 fin_class_cd = f8
      2 health_plan_id = f8
      2 hp_beg_effective_dt_tm = dq8
      2 hp_end_effective_dt_tm = dq8
      2 manual_ind = i2
      2 updt_ind = i2
      2 payor_type_cd = f8
      2 item_copay = f8
      2 item_reimbursement = f8
      2 posted_dt_tm = dq8
      2 item_interval_id = f8
      2 list_price = f8
      2 list_price_sched_id = f8
      2 realtime_ind = i2
      2 epsdt_ind = i2
      2 ref_phys_id = f8
      2 alpha_nomen_id = f8
      2 server_process_flag = i2
      2 mods
        3 charge_mods[*]
          4 mod_id = f8
          4 charge_event_id = f8
          4 charge_event_mod_type_cd = f8
          4 charge_item_id = f8
          4 charge_mod_type_cd = f8
          4 field1 = c200
          4 field2 = c200
          4 field3 = c200
          4 field4 = c200
          4 field5 = c200
          4 field6 = c200
          4 field7 = c200
          4 field8 = c200
          4 field9 = c200
          4 field10 = c200
          4 field1_id = f8
          4 field2_id = f8
          4 field3_id = f8
          4 field4_id = f8
          4 field5_id = f8
          4 nomen_id = f8
          4 cm1_nbr = f8
          4 activity_dt_tm = dq8
          4 field3_ext = c350
          4 charge_mod_source_cd = f8
          4 code1_cd = f8
      2 offset_charge_item_id = f8
      2 patient_responsibility_flag = i2
      2 item_deductible_amt = f8
      2 activity_sub_type_cd = f8
      2 provider_specialty_cd = f8
      2 item_price_adj_amt = f8
    1 srv_diag[*]
      2 charge_event_mod_id = f8
      2 charge_event_id = f8
      2 charge_event_act_id = f8
      2 srv_diag_cd = f8
      2 srv_diag1_id = f8
      2 srv_diag2_id = f8
      2 srv_diag3_id = f8
      2 srv_diag_tier = f8
      2 srv_diag_reason = c200
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD priorities(
   1 qual[*]
     2 modpriority = f8
 )
 RECORD modifiers(
   1 qual[*]
     2 field1_id = f8
     2 field6 = c200
     2 field2_id = f8
     2 field_value = i2
     2 field3_id = f8
     2 charge_mod_source_cd = f8
 )
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
 CALL echo("Begin AFC_IMPERSONATE_PERSONNEL_SUB.INC, version [318318.001]")
 IF ( NOT (validate(impersonatepersonnelinfo)))
  SUBROUTINE (impersonatepersonnelinfo(dummyvar=i2) =null)
    DECLARE seccntxt = i4
    DECLARE namelen = i4
    DECLARE domainnamelen = i4
    DECLARE uar_secsetcontext(hctx=i4) = i2
    EXECUTE secrtl  WITH image_axp = "secrtl", image_aix = "libsec.a(libsec.o)", uar =
    "SecSetContext",
    persist
    SET namelen = (uar_secgetclientusernamelen()+ 1)
    SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
    SET stat = memalloc(name,1,build("C",namelen))
    SET stat = memalloc(domainname,1,build("C",domainnamelen))
    SET stat = uar_secgetclientusername(name,namelen)
    SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
    SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
  END ;Subroutine
 ENDIF
 CALL beginservice(afc_reprocess_charge_events)
 IF ( NOT (validate(cs13029_reprocess_cd)))
  DECLARE cs13029_reprocess_cd = f8 WITH protect, constant(getcodevalue(13029,"REPROCESS",0))
 ENDIF
 IF ( NOT (validate(cs13029_reprocess_no_commit_cd)))
  DECLARE cs13029_reprocess_no_commit_cd = f8 WITH protect, constant(getcodevalue(13029,"NOCOMMIT",0)
   )
 ENDIF
 IF ( NOT (validate(cs13019_billcd_mod_type_cd)))
  DECLARE cs13019_billcd_mod_type_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs13019_noncovered_cd)))
  DECLARE cs13019_noncovered_cd = f8 WITH protect, constant(getcodevalue(13019,"NONCOVERED",0))
 ENDIF
 IF ( NOT (validate(cs4518006_manually_added)))
  DECLARE cs4518006_manually_added = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,
    "MANUALLY_ADD"))
 ENDIF
 IF ( NOT (validate(cs4518006_copyfromcem)))
  DECLARE cs4518006_copyfromcem = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,
    "COPYFROMCEM"))
 ENDIF
 IF ( NOT (validate(cs4518006_ref_data)))
  DECLARE cs4518006_ref_data = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,"REF_DATA"
    ))
 ENDIF
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE appnum = i4 WITH protect, constant(951020)
 DECLARE tasknum = i4 WITH protect, constant(951020)
 DECLARE requestnum = i4 WITH protect, constant(951359)
 DECLARE asyncprocessingind = i2 WITH protect, noconstant(validate(request->asyncprocessingind,false)
  )
 DECLARE nocommitind = i2 WITH protect, noconstant(validate(request->nocommitind,false))
 DECLARE requesthandle = i4 WITH protect, noconstant(validate(request->asyncrequesthandle,0))
 DECLARE replyhandle = i4 WITH protect, noconstant(0)
 IF (asyncprocessingind
  AND requesthandle=0)
  IF (size(request->process_event,5)=0)
   CALL exitservicenodata("No chargeEvents in request to process",go_to_exit_script)
  ENDIF
  IF ( NOT (populateserverrequest(nocommitind,requesthandle)))
   CALL exitservicefailure("populateServerRequest did not return success",go_to_exit_script)
  ENDIF
  IF ( NOT (beginreprocessingofevents(requesthandle)))
   CALL exitservicefailure("beginReprocessingOfEvents did not return success",go_to_exit_script)
  ENDIF
  SET reply->asyncrequesthandle = requesthandle
 ELSE
  IF ( NOT (asyncprocessingind))
   IF (size(request->process_event,5)=0)
    CALL exitservicenodata("No chargeEvents in request to process",go_to_exit_script)
   ENDIF
   IF ( NOT (populateserverrequest(nocommitind,requesthandle)))
    CALL exitservicefailure("populateServerRequest did not return success",go_to_exit_script)
   ENDIF
   IF ( NOT (beginreprocessingofevents(requesthandle)))
    CALL exitservicefailure("beginReprocessingOfEvents did not return success",go_to_exit_script)
   ENDIF
  ENDIF
  IF ( NOT (endreprocessingofevents(requesthandle,replyhandle)))
   CALL exitservicefailure("endReprocessingOfEvents did not return success",go_to_exit_script)
  ENDIF
  IF ( NOT (populatereply(replyhandle)))
   CALL exitservicefailure("populateReply did not return success",go_to_exit_script)
  ENDIF
  IF ( NOT (checkcptmodifierpriorities(0)))
   CALL exitservicefailure("checkCPTModifierPriorities did not return success",go_to_exit_script)
  ENDIF
  IF ( NOT (retrievehealthplaneffectivedates(0)))
   CALL exitservicefailure("retrieveHealthPlanEffectiveDates",go_to_exit_script)
  ENDIF
  IF ( NOT (evaluatepatientresponsiblity(reply)))
   CALL exitservicefailure("evaluatePatientResponsiblity did not return success",go_to_exit_script)
  ENDIF
  SET stat = uar_crmendreq(requesthandle)
  SET stat = uar_crmendtask(htask)
  SET stat = uar_crmendapp(happ)
 ENDIF
 CALL exitservicesuccess("Finished processing registration modifications")
#exit_script
 IF ((reply->status_data.status="F"))
  SET stat = uar_crmendreq(requesthandle)
  SET stat = uar_crmendtask(htask)
  SET stat = uar_crmendapp(happ)
 ENDIF
 SUBROUTINE (populateserverrequest(nocommitind=i2,requesthandle=i4(ref)) =i2)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hceitem = i4 WITH protect, noconstant(0)
   DECLARE hciitem = i4 WITH protect, noconstant(0)
   DECLARE lloopcnt = i4 WITH protect, noconstant(0)
   DECLARE litemcnt = i4 WITH protect, noconstant(0)
   CALL impersonatepersonnelinfo(1)
   SET requesthandle = 0
   SET stat = uar_crmbeginapp(appnum,happ)
   IF (stat != 0)
    CALL addtracemessage("populateServerRequest",build("Failure on CrmBeginApp(",appnum,") stat:",
      stat))
    RETURN(false)
   ENDIF
   SET stat = uar_crmbegintask(happ,tasknum,htask)
   IF (stat != 0)
    CALL addtracemessage("populateServerRequest",build("Failure on CrmBeginTask(",tasknum,") stat:",
      stat))
    RETURN(false)
   ENDIF
   SET stat = uar_crmbeginreq(htask,"",requestnum,requesthandle)
   IF (((stat != 0) OR (requesthandle=0)) )
    CALL addtracemessage("populateServerRequest",build("Failure on CrmBeginReq(",requestnum,") stat:",
      stat))
    RETURN(false)
   ENDIF
   SET hreq = uar_crmgetrequest(requesthandle)
   IF (hreq=0)
    CALL addtracemessage("populateServerRequest",build("Failure on CrmGetReq(",requestnum,") stat:",
      stat))
    RETURN(false)
   ENDIF
   IF (nocommitind)
    SET stat = uar_srvsetdouble(hreq,"process_type_cd",cs13029_reprocess_no_commit_cd)
   ELSE
    IF (validate(request->process_type_cd))
     SET stat = uar_srvsetdouble(hreq,"process_type_cd",request->process_type_cd)
    ELSE
     SET stat = uar_srvsetdouble(hreq,"process_type_cd",cs13029_reprocess_cd)
    ENDIF
   ENDIF
   SET stat = uar_srvsetshort(hreq,"facility_transfer_ind",validate(request->facility_transfer_ind,0)
    )
   SET stat = uar_srvsetshort(hreq,"charge_event_qual",size(request->process_event,5))
   FOR (lloopcnt = 1 TO size(request->process_event,5))
     CALL echo(build("Chrg Event Count: ",lloopcnt))
     SET hceitem = uar_srvadditem(hreq,"process_event")
     SET srvstat = uar_srvsetdouble(hceitem,"charge_event_id",request->process_event[lloopcnt].
      charge_event_id)
     FOR (litemcnt = 1 TO size(request->process_event[lloopcnt].charge_item,5))
      SET hciitem = uar_srvadditem(hceitem,"charge_item")
      SET srvstat = uar_srvsetdouble(hciitem,"charge_item_id",request->process_event[lloopcnt].
       charge_item[litemcnt].charge_item_id)
     ENDFOR
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (beginreprocessingofevents(requesthandle=i4) =i2)
   DECLARE asyncstat = i4 WITH protect, noconstant(0)
   SET asyncstat = uar_crmperformasasync(requesthandle,"cs_srvsync")
   IF (asyncstat != 0)
    CALL addtracemessage("beginReprocessingOfEvents",build("uar_crmPerformAsAsync stat:",asyncstat))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (endreprocessingofevents(requesthandle=i4,replyhandle=i4(ref)) =i2)
   SET replyhandle = 0
   SET stat = uar_crmsynch(requesthandle)
   IF (stat != 0)
    CALL addtracemessage("endReprocessingOfEvents",build("uar_crmPerformSynch stat:",stat))
    RETURN(false)
   ENDIF
   SET replyhandle = uar_crmgetreply(requesthandle)
   IF (replyhandle=0)
    CALL addtracemessage("endReprocessingOfEvents","Could not get reply handle from request")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (populatereply(replyhandle=i4) =i2)
   DECLARE lmodcount = i4 WITH protect, noconstant(0)
   DECLARE lmodloopcount = i4 WITH protect, noconstant(0)
   DECLARE lloopcount = i4 WITH protect, noconstant(0)
   DECLARE litemcount = i4 WITH protect, noconstant(uar_srvgetitemcount(replyhandle,"charges"))
   DECLARE hlist = i4 WITH protect, noconstant(0)
   DECLARE hlist2 = i4 WITH protect, noconstant(0)
   DECLARE hlist3 = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->charges,litemcount)
   FOR (lloopcount = 1 TO litemcount)
     SET hlist = uar_srvgetitem(replyhandle,"charges",(lloopcount - 1))
     IF (validate(reply->charges[lloopcount].charge_item_id))
      SET reply->charges[lloopcount].charge_item_id = uar_srvgetdouble(hlist,"charge_item_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].charge_act_id))
      SET reply->charges[lloopcount].charge_act_id = uar_srvgetdouble(hlist,"charge_act_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].charge_event_id))
      SET reply->charges[lloopcount].charge_event_id = uar_srvgetdouble(hlist,"charge_event_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].bill_item_id))
      SET reply->charges[lloopcount].bill_item_id = uar_srvgetdouble(hlist,"bill_item_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].charge_description))
      SET reply->charges[lloopcount].charge_description = uar_srvgetstringptr(hlist,
       "charge_description")
     ENDIF
     IF (validate(reply->charges[lloopcount].price_sched_id))
      SET reply->charges[lloopcount].price_sched_id = uar_srvgetdouble(hlist,"price_sched_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].payor_id))
      SET reply->charges[lloopcount].payor_id = uar_srvgetdouble(hlist,"payor_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_quantity))
      SET reply->charges[lloopcount].item_quantity = uar_srvgetdouble(hlist,"item_quantity")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_price))
      SET reply->charges[lloopcount].item_price = uar_srvgetdouble(hlist,"item_price")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_extended_price))
      SET reply->charges[lloopcount].item_extended_price = uar_srvgetdouble(hlist,
       "item_extended_price")
     ENDIF
     IF (validate(reply->charges[lloopcount].charge_type_cd))
      SET reply->charges[lloopcount].charge_type_cd = uar_srvgetdouble(hlist,"charge_type_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].suspense_rsn_cd))
      SET reply->charges[lloopcount].suspense_rsn_cd = uar_srvgetdouble(hlist,"suspense_rsn_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].reason_comment))
      SET reply->charges[lloopcount].reason_comment = uar_srvgetstringptr(hlist,"reason_comment")
     ENDIF
     IF (validate(reply->charges[lloopcount].posted_cd))
      SET reply->charges[lloopcount].posted_cd = uar_srvgetdouble(hlist,"posted_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].ord_phys_id))
      SET reply->charges[lloopcount].ord_phys_id = uar_srvgetdouble(hlist,"ord_phys_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].perf_phys_id))
      SET reply->charges[lloopcount].perf_phys_id = uar_srvgetdouble(hlist,"perf_phys_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].order_id))
      SET reply->charges[lloopcount].order_id = uar_srvgetdouble(hlist,"order_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].beg_effective_dt_tm))
      CALL uar_srvgetdate(hlist,"beg_effective_dt_tm",reply->charges[lloopcount].beg_effective_dt_tm)
     ENDIF
     IF (validate(reply->charges[lloopcount].person_id))
      SET reply->charges[lloopcount].person_id = uar_srvgetdouble(hlist,"person_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].encntr_id))
      SET reply->charges[lloopcount].encntr_id = uar_srvgetdouble(hlist,"encntr_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].admit_type_cd))
      SET reply->charges[lloopcount].admit_type_cd = uar_srvgetdouble(hlist,"admit_type_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].med_service_cd))
      SET reply->charges[lloopcount].med_service_cd = uar_srvgetdouble(hlist,"med_service_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].institution_cd))
      SET reply->charges[lloopcount].institution_cd = uar_srvgetdouble(hlist,"institution_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].department_cd))
      SET reply->charges[lloopcount].department_cd = uar_srvgetdouble(hlist,"department_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].section_cd))
      SET reply->charges[lloopcount].section_cd = uar_srvgetdouble(hlist,"section_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].subsection_cd))
      SET reply->charges[lloopcount].subsection_cd = uar_srvgetdouble(hlist,"subsection_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].level5_cd))
      SET reply->charges[lloopcount].level5_cd = uar_srvgetdouble(hlist,"level5_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].service_dt_tm))
      CALL uar_srvgetdate(hlist,"service_dt_tm",reply->charges[lloopcount].service_dt_tm)
     ENDIF
     IF (validate(reply->charges[lloopcount].process_flg))
      SET reply->charges[lloopcount].process_flg = uar_srvgetshort(hlist,"process_flg")
     ENDIF
     IF (validate(reply->charges[lloopcount].parent_charge_item_id))
      SET reply->charges[lloopcount].parent_charge_item_id = uar_srvgetdouble(hlist,
       "parent_charge_item_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].interface_id))
      SET reply->charges[lloopcount].interface_id = uar_srvgetdouble(hlist,"interface_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].tier_group_cd))
      SET reply->charges[lloopcount].tier_group_cd = uar_srvgetdouble(hlist,"tier_group_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].def_bill_item_id))
      SET reply->charges[lloopcount].def_bill_item_id = uar_srvgetdouble(hlist,"def_bill_item_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].verify_phys_id))
      SET reply->charges[lloopcount].verify_phys_id = uar_srvgetdouble(hlist,"verify_phys_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].gross_price))
      SET reply->charges[lloopcount].gross_price = uar_srvgetdouble(hlist,"gross_price")
     ENDIF
     IF (validate(reply->charges[lloopcount].discount_amount))
      SET reply->charges[lloopcount].discount_amount = uar_srvgetdouble(hlist,"discount_amount")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_price_adj_amt))
      SET reply->charges[lloopcount].item_price_adj_amt = uar_srvgetdouble(hlist,"item_price_adj_amt"
       )
     ENDIF
     IF (validate(reply->charges[lloopcount].activity_type_cd))
      SET reply->charges[lloopcount].activity_type_cd = uar_srvgetdouble(hlist,"activity_type_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].activity_sub_type_cd))
      SET reply->charges[lloopcount].activity_sub_type_cd = uar_srvgetdouble(hlist,
       "activity_sub_type_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].provider_specialty_cd))
      SET reply->charges[lloopcount].provider_specialty_cd = uar_srvgetdouble(hlist,
       "provider_specialty_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].research_acct_id))
      SET reply->charges[lloopcount].research_acct_id = uar_srvgetdouble(hlist,"research_acct_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].cost_center_cd))
      SET reply->charges[lloopcount].cost_center_cd = uar_srvgetdouble(hlist,"cost_center_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].abn_status_cd))
      SET reply->charges[lloopcount].abn_status_cd = uar_srvgetdouble(hlist,"abn_status_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].perf_loc_cd))
      SET reply->charges[lloopcount].perf_loc_cd = uar_srvgetdouble(hlist,"perf_loc_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].inst_fin_nbr))
      SET reply->charges[lloopcount].inst_fin_nbr = uar_srvgetstringptr(hlist,"inst_fin_nbr")
     ENDIF
     IF (validate(reply->charges[lloopcount].ord_loc_cd))
      SET reply->charges[lloopcount].ord_loc_cd = uar_srvgetdouble(hlist,"ord_loc_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].fin_class_cd))
      SET reply->charges[lloopcount].fin_class_cd = uar_srvgetdouble(hlist,"fin_class_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].health_plan_id))
      SET reply->charges[lloopcount].health_plan_id = uar_srvgetdouble(hlist,"health_plan_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].manual_ind))
      SET reply->charges[lloopcount].manual_ind = uar_srvgetshort(hlist,"manual_ind")
     ENDIF
     IF (validate(reply->charges[lloopcount].updt_ind))
      SET reply->charges[lloopcount].updt_ind = uar_srvgetshort(hlist,"updt_ind")
     ENDIF
     IF (validate(reply->charges[lloopcount].payor_type_cd))
      SET reply->charges[lloopcount].payor_type_cd = uar_srvgetdouble(hlist,"payor_type_cd")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_copay))
      SET reply->charges[lloopcount].item_copay = uar_srvgetdouble(hlist,"item_copay")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_reimbursement))
      SET reply->charges[lloopcount].item_reimbursement = uar_srvgetdouble(hlist,"item_reimbursement"
       )
     ENDIF
     IF (validate(reply->charges[lloopcount].posted_dt_tm))
      CALL uar_srvgetdate(hlist,"posted_dt_tm",reply->charges[lloopcount].posted_dt_tm)
     ENDIF
     IF (validate(reply->charges[lloopcount].item_interval_id))
      SET reply->charges[lloopcount].item_interval_id = uar_srvgetdouble(hlist,"item_interval_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].list_price))
      SET reply->charges[lloopcount].list_price = uar_srvgetdouble(hlist,"list_price")
     ENDIF
     IF (validate(reply->charges[lloopcount].list_pirce_sched_id))
      SET reply->charges[lloopcount].list_price_sched_id = uar_srvgetdouble(hlist,
       "list_price_sched_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].realtime_ind))
      SET reply->charges[lloopcount].realtime_ind = uar_srvgetshort(hlist,"realtime_ind")
     ENDIF
     IF (validate(reply->charges[lloopcount].epsdt_ind))
      SET reply->charges[lloopcount].epsdt_ind = uar_srvgetshort(hlist,"epsdt_ind")
     ENDIF
     IF (validate(reply->charges[lloopcount].ref_phys_id))
      SET reply->charges[lloopcount].ref_phys_id = uar_srvgetdouble(hlist,"ref_phys_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].alpha_nomen_id))
      SET reply->charges[lloopcount].alpha_nomen_id = uar_srvgetdouble(hlist,"alpha_nomen_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].server_process_flag))
      SET reply->charges[lloopcount].server_process_flag = uar_srvgetshort(hlist,
       "server_process_flag")
     ENDIF
     IF (validate(reply->charges[lloopcount].offset_charge_item_id))
      SET reply->charges[lloopcount].offset_charge_item_id = uar_srvgetdouble(hlist,
       "offset_charge_item_id")
     ENDIF
     IF (validate(reply->charges[lloopcount].item_deductible_amt))
      SET reply->charges[lloopcount].item_deductible_amt = uar_srvgetdouble(hlist,
       "item_deductible_amt")
     ENDIF
     IF (validate(reply->charges[lloopcount].patient_responsibility_flag))
      SET reply->charges[lloopcount].patient_responsibility_flag = uar_srvgetshort(hlist,
       "patient_responsibility_flag")
     ENDIF
     IF (validate(reply->charges[lloopcount].mods.charge_mods))
      SET hlist2 = uar_srvgetstruct(hlist,"mods")
      SET lmodcount = uar_srvgetitemcount(hlist2,"charge_mods")
      SET stat = alterlist(reply->charges[lloopcount].mods.charge_mods,lmodcount)
      FOR (lmodloopcount = 1 TO lmodcount)
        SET hlist3 = uar_srvgetitem(hlist2,"charge_mods",(lmodloopcount - 1))
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].mod_id = uar_srvgetdouble(
         hlist3,"mod_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].charge_event_id =
        uar_srvgetdouble(hlist3,"charge_event_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].charge_event_mod_type_cd =
        uar_srvgetdouble(hlist3,"charge_event_mod_type_cd")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].charge_mod_type_cd =
        uar_srvgetdouble(hlist3,"charge_mod_type_cd")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].charge_mod_source_cd =
        uar_srvgetdouble(hlist3,"charge_mod_source_cd")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field1 = uar_srvgetstringptr(
         hlist3,"field1")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field2 = uar_srvgetstringptr(
         hlist3,"field2")
        IF ((reply->charges[lloopcount].mods.charge_mods[lmodloopcount].charge_event_mod_type_cd=
        cs13019_noncovered_cd))
         SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field3_ext =
         uar_srvgetstringptr(hlist3,"field3_ext")
        ELSE
         SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field3 = uar_srvgetstringptr(
          hlist3,"field3")
        ENDIF
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field4 = uar_srvgetstringptr(
         hlist3,"field4")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field5 = uar_srvgetstringptr(
         hlist3,"field5")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field6 = uar_srvgetstringptr(
         hlist3,"field6")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field7 = uar_srvgetstringptr(
         hlist3,"field7")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field1_id = uar_srvgetdouble(
         hlist3,"field1_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field2_id = uar_srvgetdouble(
         hlist3,"field2_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field3_id = uar_srvgetdouble(
         hlist3,"field3_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field4_id = uar_srvgetdouble(
         hlist3,"field4_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].field5_id = uar_srvgetdouble(
         hlist3,"field5_id")
        IF (validate(reply->charges[lloopcount].mods.charge_mods[lmodloopcount].code1_cd))
         SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].code1_cd = uar_srvgetdouble(
          hlist3,"code1_cd")
        ENDIF
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].nomen_id = uar_srvgetdouble(
         hlist3,"nomen_id")
        SET reply->charges[lloopcount].mods.charge_mods[lmodloopcount].cm1_nbr = uar_srvgetdouble(
         hlist3,"cm1_nbr")
        IF (validate(reply->charges[lloopcount].mods.charge_mods[lmodloopcount].activity_dt_tm))
         CALL uar_srvgetdate(hlist3,"activity_dt_tm",reply->charges[lloopcount].mods.charge_mods[
          lmodloopcount].activity_dt_tm)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(reply)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (evaluatepatientresponsiblity(reply=vc(ref)) =i2)
   DECLARE pccnt = i4 WITH private, protect, noconstant(0)
   DECLARE replycnt = i4 WITH private, protect, noconstant(0)
   DECLARE ruleidx = i4 WITH private, protect, noconstant(0)
   DECLARE objidx = i4 WITH private, protect, noconstant(0)
   DECLARE pcidx = i4 WITH private, protect, noconstant(0)
   DECLARE flag_review = i4 WITH private, protect, constant(2)
   IF ( NOT (validate(batchsize)))
    DECLARE batchsize = i4 WITH protect, constant(25)
   ENDIF
   IF ( NOT (validate(origsize)))
    DECLARE origsize = i4 WITH protect, noconstant(0)
   ENDIF
   IF ( NOT (validate(newsize)))
    DECLARE newsize = i4 WITH protect, noconstant(0)
   ENDIF
   IF ( NOT (validate(loopcount)))
    DECLARE loopcount = i4 WITH protect, noconstant(0)
   ENDIF
   IF ( NOT (validate(startidx)))
    DECLARE startidx = i4 WITH protect, noconstant(1)
   ENDIF
   IF ( NOT (validate(eidx)))
    DECLARE eidx = i2 WITH protect, noconstant(0)
   ENDIF
   FREE RECORD pbmrequest
   RECORD pbmrequest(
     1 eventkey = vc
     1 categorykey = vc
     1 htask = i4
     1 objarray[*]
       2 corspactivityid = f8
       2 activityid = f8
       2 pftchargeid = f8
       2 pftencntrid = f8
       2 encounterid = f8
       2 insurancebalanceid = f8
       2 scheventid = f8
       2 referralid = f8
       2 eventid = f8
       2 eventparams[*]
         3 paramkey = vc
         3 doublevalue = f8
         3 stringvalue = vc
         3 datevalue = dq8
         3 parententityname = vc
         3 parententityid = f8
         3 paramgroup = i4
       2 eventparamgroupcount = i4
       2 personid = f8
       2 billingentityid = f8
       2 accountid = f8
       2 schentryid = f8
   )
   FREE RECORD pbmreply
   RECORD pbmreply(
     1 rulesets[*]
       2 rulesetkey = vc
       2 eventkey = vc
       2 categorykey = vc
       2 objarray[*]
         3 corspactivityid = f8
         3 activityid = f8
         3 pftchargeid = f8
         3 pftencntrid = f8
         3 encounterid = f8
         3 insurancebalanceid = f8
         3 scheventid = f8
         3 referralid = f8
         3 actions[*]
           4 actionkey = vc
           4 params[*]
             5 paramkey = vc
             5 paramtype = vc
             5 paramvalue = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD chargeresponsibility
   RECORD chargeresponsibility(
     1 charges[*]
       2 pftchargeid = f8
       2 chargeitemid = f8
       2 qualifies = i2
   )
   SET origsize = size(reply->charges,5)
   SET loopcount = ceil((cnvtreal(origsize)/ batchsize))
   SET newsize = (loopcount * batchsize)
   SET stat = alterlist(reply->charges,newsize)
   FOR (pcidx = (origsize+ 1) TO newsize)
     SET reply->charges[pcidx].charge_item_id = reply->charges[origsize].charge_item_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loopcount)),
     pft_charge pc
    PLAN (d1
     WHERE initarray(startidx,evaluate(d1.seq,1,1,(startidx+ batchsize))))
     JOIN (pc
     WHERE expand(eidx,startidx,(startidx+ (batchsize - 1)),pc.charge_item_id,reply->charges[eidx].
      charge_item_id)
      AND pc.active_ind=true
      AND pc.client_bill_ind=0)
    DETAIL
     pccnt += 1, stat = alterlist(pbmrequest->objarray,pccnt), pbmrequest->objarray[pccnt].
     pftchargeid = pc.pft_charge_id,
     stat = alterlist(chargeresponsibility->charges,pccnt), chargeresponsibility->charges[pccnt].
     pftchargeid = pc.pft_charge_id, chargeresponsibility->charges[pccnt].chargeitemid = pc
     .charge_item_id
    WITH nocounter
   ;end select
   IF (size(pbmrequest->objarray,5)=0)
    SET stat = alterlist(reply->charges,origsize)
    RETURN(true)
   ENDIF
   SET pbmrequest->categorykey = "CHRGENTRY"
   SET pbmrequest->eventkey = "PAT_RESPBLTY"
   EXECUTE pft_eval_pbm_rules  WITH replace("REQUEST",pbmrequest), replace("REPLY",pbmreply)
   IF ((pbmreply->status_data.status="F"))
    CALL echorecord(pbmrequest)
    CALL echorecord(pbmreply)
    RETURN(false)
   ENDIF
   FOR (ruleidx = 1 TO size(pbmreply->rulesets,5))
     IF ((pbmreply->rulesets[ruleidx].rulesetkey="PATRESPBLTY"))
      FOR (objidx = 1 TO size(pbmreply->rulesets[ruleidx].objarray,5))
        SET pcidx = 0
        SET pcidx = locateval(pccnt,1,size(chargeresponsibility->charges,5),pbmreply->rulesets[
         ruleidx].objarray[objidx].pftchargeid,chargeresponsibility->charges[pccnt].pftchargeid)
        IF (pcidx > 0
         AND size(pbmreply->rulesets[ruleidx].objarray[objidx].actions,5) > 0)
         SET chargeresponsibility->charges[pcidx].qualifies = true
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FOR (replycnt = 1 TO size(reply->charges,5))
     SET pcidx = 0
     SET pcidx = locateval(pccnt,1,size(chargeresponsibility->charges,5),reply->charges[replycnt].
      charge_item_id,chargeresponsibility->charges[pccnt].chargeitemid)
     IF (pcidx > 0
      AND chargeresponsibility->charges[pcidx].qualifies)
      SET reply->charges[replycnt].process_flg = flag_review
     ELSE
      SET reply->charges[replycnt].item_deductible_amt = 0.0
      SET reply->charges[replycnt].patient_responsibility_flag = 0
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->charges,origsize)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (retrievehealthplaneffectivedates(dummyvar=i2) =i2)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->charges,5))),
     encntr_plan_reltn epr
    PLAN (d1)
     JOIN (epr
     WHERE (epr.encntr_id=reply->charges[d1.seq].encntr_id)
      AND (epr.health_plan_id=reply->charges[d1.seq].health_plan_id)
      AND epr.active_ind=1
      AND epr.priority_seq=1)
    DETAIL
     reply->charges[d1.seq].hp_beg_effective_dt_tm = cnvtdatetime(epr.beg_effective_dt_tm), reply->
     charges[d1.seq].hp_end_effective_dt_tm = cnvtdatetime(epr.end_effective_dt_tm)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkcptmodifierpriorities(dummyvar=i2) =i2)
   DECLARE chargecount = i2 WITH protect, noconstant(0)
   DECLARE chargeindex = i4 WITH protect, noconstant(0)
   SET chargecount = size(reply->charges,5)
   FOR (chargeindex = 1 TO chargecount)
     DECLARE modifiercnt = i4 WITH protect, noconstant(0)
     DECLARE mod_loop = i4 WITH protect, noconstant(0)
     DECLARE priority = f8 WITH protect, noconstant(0)
     DECLARE manuallyaddedcnt = i4 WITH protect, noconstant(0)
     DECLARE cnt = i4 WITH protect, noconstant(0)
     DECLARE pos = i4 WITH protect, noconstant(0)
     DECLARE modnum = i4 WITH protect, noconstant(0)
     DECLARE num = i4 WITH protect, noconstant(0)
     DECLARE modcnt = i4 WITH protect, noconstant(0)
     SET modifiercnt = 0
     SET stat = alterlist(modifiers->qual,size(reply->charges[chargeindex].mods.charge_mods,5))
     FOR (mod_loop = 1 TO size(reply->charges[chargeindex].mods.charge_mods,5))
       IF (uar_get_code_meaning(reply->charges[chargeindex].mods.charge_mods[mod_loop].field1_id)=
       "MODIFIER")
        SET modifiercnt += 1
        SET modifiers->qual[modifiercnt].field1_id = reply->charges[chargeindex].mods.charge_mods[
        mod_loop].field1_id
        SET modifiers->qual[modifiercnt].field2_id = reply->charges[chargeindex].mods.charge_mods[
        mod_loop].field2_id
        SET modifiers->qual[modifiercnt].field6 = reply->charges[chargeindex].mods.charge_mods[
        mod_loop].field6
        SET modifiers->qual[modifiercnt].field3_id = reply->charges[chargeindex].mods.charge_mods[
        mod_loop].field3_id
        SET modifiers->qual[modifiercnt].field_value = 0
        SET modifiers->qual[modifiercnt].charge_mod_source_cd = validate(reply->charges[chargeindex].
         mods.charge_mods[mod_loop].charge_mod_source_cd,0.0)
       ENDIF
     ENDFOR
     SET stat = alterlist(modifiers->qual,modifiercnt)
     IF (size(modifiers->qual,5) > 0)
      SELECT INTO "nl:"
       FROM code_value_extension cve
       WHERE expand(num,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[num].field3_id)
        AND cnvtupper(cve.field_name)="PRICE MODIFIER"
        AND cve.code_set=17769
       HEAD REPORT
        mod_idx = 0, modnum = 0
       DETAIL
        IF (cnvtint(trim(cve.field_value,7))=1)
         mod_idx = locateval(modnum,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[modnum].
          field3_id), modifiers->qual[mod_idx].field_value = cnvtint(trim(cve.field_value,7))
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       orderbypriority = evaluate(modifiers->qual[d.seq].charge_mod_source_cd,
        cs4518006_manually_added,1,cs4518006_copyfromcem,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 2
         ELSE 4
         ENDIF
         ),
        0.0,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 2
         ELSE 4
         ENDIF
         ),cs4518006_ref_data,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 3
         ELSE 5
         ENDIF
         ),6)
       FROM (dummyt d  WITH seq = value(size(modifiers->qual,5)))
       PLAN (d)
       ORDER BY orderbypriority, modifiers->qual[d.seq].field2_id
       HEAD REPORT
        priority = 0, manuallyaddedcnt = 0
       DETAIL
        IF (orderbypriority=1)
         manuallyaddedcnt += 1, stat = alterlist(priorities->qual,manuallyaddedcnt), priorities->
         qual[manuallyaddedcnt].modpriority = modifiers->qual[d.seq].field2_id
        ELSE
         priority += 1, pos = 1
         WHILE (pos != 0)
          pos = locateval(cnt,1,manuallyaddedcnt,priority,priorities->qual[cnt].modpriority),
          IF (pos > 0)
           priority += 1
          ENDIF
         ENDWHILE
         modpos = locateval(modcnt,1,size(reply->charges[chargeindex].mods.charge_mods,5),modifiers->
          qual[d.seq].field6,reply->charges[chargeindex].mods.charge_mods[modcnt].field6,
          modifiers->qual[d.seq].field1_id,reply->charges[chargeindex].mods.charge_mods[modcnt].
          field1_id,modifiers->qual[d.seq].field3_id,reply->charges[chargeindex].mods.charge_mods[
          modcnt].field3_id)
         IF (modpos > 0)
          reply->charges[chargeindex].mods.charge_mods[modpos].field2_id = priority
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
END GO
