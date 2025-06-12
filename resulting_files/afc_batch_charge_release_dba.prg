CREATE PROGRAM afc_batch_charge_release:dba
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
 CALL beginservice("15202.028")
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE hreq = i4
 DECLARE releaseappid = i4
 DECLARE releasetaskid = i4
 DECLARE releasereqid = i4
 DECLARE happrelease = i4
 DECLARE htaskrelease = i4
 DECLARE hsteprelease = i4
 DECLARE srvstat = i4
 DECLARE iret = i4
 DECLARE hprocess = i4
 DECLARE hcharge = i4
 DECLARE code_set = i4
 DECLARE cnt = i4
 DECLARE cdf_meaning = c12
 DECLARE suspense_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inactive_cd = f8
 DECLARE max_rows = i2 WITH protect, constant(100)
 DECLARE totalitemcnt = i4 WITH protect, noconstant(0)
 DECLARE completed = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE startidx = i4 WITH protect, noconstant(0)
 DECLARE endidx = i4 WITH protect, noconstant(0)
 DECLARE loopcnt = i4 WITH protect, noconstant(0)
 DECLARE unprocesseditemcnt = i4 WITH protect, noconstant(0)
 DECLARE cecnt = i4 WITH protect, noconstant(0)
 DECLARE chargecnt = i4 WITH protect, noconstant(0)
 DECLARE script_start_dt_tm = dm12 WITH protect, constant(systimestamp)
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 DECLARE profit_cnt = i4 WITH protect, noconstant(0)
 DECLARE real_time_cnt = i4 WITH protect, noconstant(0)
 DECLARE hl7_batch_cnt = i4 WITH protect, noconstant(0)
 DECLARE abn_missing_cnt = i4 WITH protect, noconstant(0)
 DECLARE batch_proprietary_cnt = i4 WITH protect, noconstant(0)
 EXECUTE cs_srv_declare_951021
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET srvitem
 RECORD srvitem(
   1 items[*]
     2 charge_event_id = f8
     2 charge_item_id = f8
 )
 RECORD itemcharge(
   1 charge_events[*]
     2 charge_event_id = f8
     2 chargeitems[*]
       3 charge_item_id = f8
 ) WITH protect
 FREE SET profit_charges
 RECORD profit_charges(
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
     2 processed_ind = i2
 )
 RECORD abn_required_missing_charges(
   1 charge_items[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 charge_mod_id = f8
     2 process_flg = i4
     2 interface_file_id = f8
 )
 FREE SET hl7_batch_charges
 RECORD hl7_batch_charges(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 charge_desc = vc
     2 quantity = f8
     2 item_price = f8
     2 ext_item_price = f8
     2 process_flg = i4
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 action_type = vc
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 bill_code_type_cd = vc
       3 bill_code = vc
       3 description = vc
       3 priority = vc
       3 field3_id = f8
       3 nomen_id = f8
       3 charge_mod_source_cd = f8
     2 reason_qual = i2
     2 reason[*]
       3 action_type = vc
       3 charge_mod_id = f8
 )
 FREE SET batch_proprietary_charges
 RECORD batch_proprietary_charges(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 charge_desc = vc
     2 quantity = f8
     2 item_price = f8
     2 ext_item_price = f8
     2 process_flg = i4
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 action_type = vc
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 bill_code_type_cd = vc
       3 bill_code = vc
       3 description = vc
       3 priority = vc
       3 field3_id = f8
       3 nomen_id = f8
       3 charge_mod_source_cd = f8
     2 reason_qual = i2
     2 reason[*]
       3 action_type = vc
       3 charge_mod_id = f8
 )
 FREE RECORD real_time_charges
 RECORD real_time_charges(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 RECORD afc_interface_charge_reply(
   1 interface_charge[*]
     2 abn_status_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_type_cd = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 admit_type_cd = f8
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 batch_num = i4
     2 bed_cd = f8
     2 beg_effective_dt_tm = dq8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 building_cd = f8
     2 charge_description = c200
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 code_revenue_cd = f8
     2 code_revenue_more_ind = i2
     2 cost_center_cd = f8
     2 department_cd = f8
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 discount_amount = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 facility_cd = f8
     2 fin_nbr = c50
     2 fin_nbr_type_flg = i4
     2 gross_price = f8
     2 icd9_proc_more_ind = i2
     2 institution_cd = f8
     2 interface_charge_id = f8
     2 interface_file_id = f8
     2 level5_cd = f8
     2 manual_ind = i2
     2 med_nbr = c50
     2 med_service_cd = f8
     2 net_ext_price = f8
     2 nurse_unit_cd = f8
     2 order_dept = i4
     2 order_nbr = c200
     2 ord_doc_nbr = c20
     2 ord_phys_id = f8
     2 organization_id = f8
     2 override_desc = c200
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 person_id = f8
     2 person_name = c100
     2 posted_dt_tm = dq8
     2 price = f8
     2 prim_cdm = c50
     2 prim_cdm_desc = c200
     2 prim_cpt = c50
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 quantity = f8
     2 referring_phys_id = f8
     2 room_cd = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 user_def_ind = i2
     2 ndc_ident = c40
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD suspended_charges(
   1 charge_items[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 charge_mod_id = f8
     2 field1_id = f8
     2 field3_id = f8
     2 process_flg = i4
     2 interface_file_id = f8
 )
 CALL echo("Begin including PFT_SYSTEM_ACTIVITY_LOG_SUBS.INC version [664227.024]")
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
 IF ( NOT (validate(cs23372_comp_wo_err_cd)))
  DECLARE cs23372_comp_wo_err_cd = f8 WITH protect, constant(getcodevalue(23372,"COMP WO ERR",2))
 ENDIF
 IF ( NOT (validate(cs23372_failed_cd)))
  DECLARE cs23372_failed_cd = f8 WITH protect, constant(getcodevalue(23372,"FAILED",2))
 ENDIF
 IF ( NOT (validate(claim_sys_log)))
  DECLARE claim_sys_log = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(statement_sys_log)))
  DECLARE statement_sys_log = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(entity_balance_sys_log)))
  DECLARE entity_balance_sys_log = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(entity_insurance_sys_log)))
  DECLARE entity_insurance_sys_log = vc WITH protect, constant("INSURANCE")
 ENDIF
 IF ( NOT (validate(entity_selfpay_sys_log)))
  DECLARE entity_selfpay_sys_log = vc WITH protect, constant("SELFPAY")
 ENDIF
 IF ( NOT (validate(pftencntr_sys_log)))
  DECLARE pftencntr_sys_log = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(encounter_sys_log)))
  DECLARE encounter_sys_log = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(bill_rec_sys_log)))
  DECLARE bill_rec_sys_log = vc WITH protect, constant("BILL_REC")
 ENDIF
 IF ( NOT (validate(bo_hp_reltn_sys_log)))
  DECLARE bo_hp_reltn_sys_log = vc WITH protect, constant("BO_HP_RELTN")
 ENDIF
 IF ( NOT (validate(pft_encntr_sys_log)))
  DECLARE pft_encntr_sys_log = vc WITH protect, constant("PFT_ENCNTR")
 ENDIF
 IF ( NOT (validate(charge_sys_log)))
  DECLARE charge_sys_log = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(pft_trans_sys_log)))
  DECLARE pft_trans_sys_log = vc WITH protect, constant("PFT_TRANS_LOG")
 ENDIF
 IF ( NOT (validate(batch_trans_sys_log)))
  DECLARE batch_trans_sys_log = vc WITH protect, constant("BATCH_TRANS")
 ENDIF
 IF ( NOT (validate(entity_trans_sys_log)))
  DECLARE entity_trans_sys_log = vc WITH protect, constant("TRANS_LOG")
 ENDIF
 IF ( NOT (validate(entity_account_sys_log)))
  DECLARE entity_account_sys_log = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_person_sys_log)))
  DECLARE entity_person_sys_log = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(entity_sch_event_sys_log)))
  DECLARE entity_sch_event_sys_log = vc WITH protect, constant("SCH_EVENT")
 ENDIF
 IF ( NOT (validate(entity_billing_entity_sys_log)))
  DECLARE entity_billing_entity_sys_log = vc WITH protect, constant("BILLING_ENTITY")
 ENDIF
 IF ( NOT (validate(batch_trans_file_sys_log)))
  DECLARE batch_trans_file_sys_log = vc WITH protect, constant("BATCH_TRANS_FILE")
 ENDIF
 IF ( NOT (validate(workflow_task_queue_hist_sys_log)))
  DECLARE workflow_task_queue_hist_sys_log = vc WITH protect, constant("WORKFLOW_TASK_QUEUE_HIST")
 ENDIF
 IF ( NOT (validate(pft_charge_sys_log)))
  DECLARE pft_charge_sys_log = vc WITH protect, constant("PFT_CHARGE")
 ENDIF
 IF ( NOT (validate(entity_sch_entry_sys_log)))
  DECLARE entity_sch_entry_sys_log = vc WITH protect, constant("SCH_ENTRY")
 ENDIF
 IF ( NOT (validate(pft_system_activity_log_subs)))
  DECLARE pft_system_activity_log_subs = vc WITH protect, constant("PFT_SYSTEM_ACTIVITY_LOG_SUBS")
 ENDIF
 IF ( NOT (validate(dm_info_domain_file_log)))
  DECLARE dm_info_domain_file_log = vc WITH protect, constant("PATIENT_ACCOUNTING_FILE_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_char_file_log)))
  DECLARE dm_info_char_file_log = vc WITH protect, constant("OPT_IN_FILE_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_domain_msgview_log)))
  DECLARE dm_info_domain_msgview_log = vc WITH protect, constant("PATIENT_ACCOUNTING_MSGVIEW_LOGGING"
   )
 ENDIF
 IF ( NOT (validate(dm_info_char_msgview_log)))
  DECLARE dm_info_char_msgview_log = vc WITH protect, constant("OPT_IN_MSGVIEW_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_domain_table_log)))
  DECLARE dm_info_domain_table_log = vc WITH protect, constant("PATIENT_ACCOUNTING_LOGGING")
 ENDIF
 IF ( NOT (validate(dm_info_char_table_log)))
  DECLARE dm_info_char_table_log = vc WITH protect, constant(
   "OPT_IN_LOGGING_FRAMEWORK_FOR_PATIENT_ACCOUNTING")
 ENDIF
 IF ( NOT (validate(log_system_activity_sub)))
  DECLARE log_system_activity_sub = vc WITH protect, constant("LogSystemActivity")
 ENDIF
 IF ( NOT (validate(base_log_file_name)))
  DECLARE base_log_file_name = vc WITH protect, constant(concat("SysAct_",trim(curprcname,3),"_"))
 ENDIF
 IF ( NOT (validate(max_file_size_in_bytes)))
  DECLARE max_file_size_in_bytes = f8 WITH protect, constant(100000000.0)
 ENDIF
 IF ( NOT (validate(max_msgview_file_name_size)))
  DECLARE max_msgview_file_name_size = f8 WITH protect, constant(31.0)
 ENDIF
 IF ( NOT (validate(script_level_timer)))
  DECLARE script_level_timer = f8 WITH protect, constant(1.0)
 ENDIF
 IF ( NOT (validate(script_and_detail_level_timer)))
  DECLARE script_and_detail_level_timer = f8 WITH protect, constant(2.0)
 ENDIF
 IF ( NOT (validate(main_select_timer_string)))
  DECLARE main_select_timer_string = vc WITH protect, constant("MAIN_SELECT_TIMER_STRING")
 ENDIF
 IF ( NOT (validate(tens_of_millisecs)))
  DECLARE tens_of_millisecs = i2 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(sysactlog)))
  RECORD sysactlog(
    1 finalstatuscd = f8
    1 entityname = vc
    1 entityid = f8
    1 taskname = vc
    1 completionmsg = vc
    1 logicaldomainid = f8
    1 locfacilitycd = f8
    1 organizationid = f8
    1 startdttm = dm12
    1 enddttm = dm12
    1 encntrid = f8
    1 personid = f8
    1 pfteventoccurlogid = f8
    1 currentnodename = vc
    1 servername = vc
    1 executiondurationsecs = f8
    1 timeridentifier = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(cachedtasks)))
  RECORD cachedtasks(
    1 task[*]
      2 taskname = vc
      2 tableloglevel = f8
      2 fileloglevel = f8
      2 msgviewloglevel = f8
      2 logicaldomainid = f8
  ) WITH protect
 ENDIF
 DECLARE sysactlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE sysactlogicaldomainind = i2 WITH protect, noconstant(false)
 IF (validate(getfilesize,char(128))=char(128))
  SUBROUTINE (getfilesize(pfilename=vc) =f8)
    DECLARE filesize = f8 WITH protect, noconstant(0.0)
    RECORD frec(
      1 file_desc = i4
      1 file_offset = i4
      1 file_dir = i4
      1 file_name = vc
      1 file_buf = vc
    ) WITH protect
    SET frec->file_name = pfilename
    SET frec->file_buf = "r"
    SET stat = cclio("OPEN",frec)
    SET frec->file_dir = 2
    SET frec->file_offset = 0
    SET stat = cclio("SEEK",frec)
    SET filesize = cclio("TELL",frec)
    RETURN(filesize)
  END ;Subroutine
 ENDIF
 IF (validate(transcribetofile,char(128))=char(128))
  SUBROUTINE (transcribetofile(pfilename=vc,pcontent=gvc,pmode=vc) =i2)
    RECORD frec(
      1 file_desc = i4
      1 file_offset = i4
      1 file_dir = i4
      1 file_name = vc
      1 file_buf = vc
    ) WITH protect
    SET frec->file_name = pfilename
    SET frec->file_buf = pmode
    SET stat = cclio("OPEN",frec)
    SET frec->file_buf = pcontent
    SET stat = cclio("WRITE",frec)
    SET stat = cclio("CLOSE",frec)
    RETURN(stat)
  END ;Subroutine
 ENDIF
 IF (validate(logsystemactivity,char(128))=char(128))
  SUBROUTINE (logsystemactivity(pstarttime=dm12,ptaskname=vc,pentityname=vc,pentityid=f8,pstatus=c1,
   pmessage=vc,plogtimer=f8(value,script_level_timer),ptimerident=vc(value,"")) =null)
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    DECLARE cacheidx = i4 WITH protect, noconstant(0)
    DECLARE cachecnt = i4 WITH protect, noconstant(0)
    DECLARE cachefound = i4 WITH protect, noconstant(0)
    DECLARE queriedind = i2 WITH protect, noconstant(true)
    DECLARE logfilemsg = vc WITH protect, noconstant("")
    DECLARE logfilename = vc WITH protect, noconstant("")
    DECLARE logfilenum = i4 WITH protect, noconstant(0)
    DECLARE logfilesize = f8 WITH protect, noconstant(max_file_size_in_bytes)
    DECLARE loggedmsgind = i2 WITH protect, noconstant(false)
    DECLARE logactivitytofile = i2 WITH protect, noconstant(false)
    DECLARE logactivitytotable = i2 WITH protect, noconstant(false)
    DECLARE logactivitytomsgview = i2 WITH protect, noconstant(false)
    DECLARE msgloglevel = i4 WITH protect, noconstant(0)
    DECLARE msghandle = i4 WITH protect, noconstant(0)
    DECLARE msglogevent = vc WITH protect, noconstant("")
    DECLARE msgfilename = vc WITH protect, noconstant("")
    SET stat = initrec(sysactlog)
    SET ptaskname = cnvtupper(ptaskname)
    SET cachecnt = size(cachedtasks->task,5)
    SET sysactlog->startdttm = pstarttime
    SET sysactlog->enddttm = systimestamp
    SET sysactlog->executiondurationsecs = timestampdiff(sysactlog->enddttm,sysactlog->startdttm)
    SET sysactlog->taskname = ptaskname
    SET sysactlog->entityid = pentityid
    SET sysactlog->completionmsg = pmessage
    SET sysactlog->currentnodename = curnode
    SET sysactlog->servername = build(curserver)
    SET sysactlog->timeridentifier = trim(ptimerident,3)
    IF ( NOT (sysactlogicaldomainind))
     CALL getlogicaldomain(ld_concept_person,sysactlogicaldomainid)
     SET sysactlogicaldomainind = true
    ENDIF
    SET cachefound = locateval(cacheidx,1,cachecnt,ptaskname,cachedtasks->task[cacheidx].taskname,
     sysactlogicaldomainid,cachedtasks->task[cacheidx].logicaldomainid)
    IF (cachefound=0)
     SET cachecnt += 1
     SET cachefound = cachecnt
     SET stat = alterlist(cachedtasks->task,cachecnt)
     SET cachedtasks->task[cachecnt].taskname = ptaskname
     SET cachedtasks->task[cachecnt].logicaldomainid = sysactlogicaldomainid
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_name=ptaskname
       AND di.info_domain_id=sysactlogicaldomainid
       AND ((di.info_domain=dm_info_domain_table_log
       AND di.info_char=dm_info_char_table_log) OR (((di.info_domain=dm_info_domain_file_log
       AND di.info_char=dm_info_char_file_log) OR (di.info_domain=dm_info_domain_msgview_log
       AND di.info_char=dm_info_char_msgview_log)) ))
      DETAIL
       IF (di.info_domain=dm_info_domain_table_log)
        cachedtasks->task[cachecnt].tableloglevel = di.info_number
       ELSEIF (di.info_domain=dm_info_domain_file_log)
        cachedtasks->task[cachecnt].fileloglevel = di.info_number
       ELSEIF (di.info_domain=dm_info_domain_msgview_log)
        cachedtasks->task[cachecnt].msgviewloglevel = di.info_number
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF ((cachedtasks->task[cachefound].tableloglevel >= plogtimer))
     SET logactivitytotable = true
    ENDIF
    IF ((cachedtasks->task[cachefound].fileloglevel >= plogtimer))
     SET logactivitytofile = true
    ENDIF
    IF ((cachedtasks->task[cachefound].msgviewloglevel >= plogtimer))
     SET logactivitytomsgview = true
    ENDIF
    IF (((logactivitytotable) OR (((logactivitytofile) OR (logactivitytomsgview)) )) )
     CASE (pstatus)
      OF "S":
       SET sysactlog->finalstatuscd = cs23372_comp_wo_err_cd
       SET msgloglevel = log_info
       SET msglogevent = "Script success"
      OF "F":
       SET sysactlog->finalstatuscd = cs23372_failed_cd
       SET msgloglevel = log_error
       SET msglogevent = "Script failure"
      ELSE
       SET sysactlog->finalstatuscd = 0.0
       SET msgloglevel = log_warning
       SET msglogevent = "No data"
     ENDCASE
     CASE (pentityname)
      OF claim_sys_log:
      OF statement_sys_log:
      OF bill_rec_sys_log:
       SET sysactlog->entityname = bill_rec_sys_log
      OF entity_balance_sys_log:
      OF entity_insurance_sys_log:
      OF entity_selfpay_sys_log:
      OF bo_hp_reltn_sys_log:
       SET sysactlog->entityname = bo_hp_reltn_sys_log
      OF pftencntr_sys_log:
      OF pft_encntr_sys_log:
       SET sysactlog->entityname = pft_encntr_sys_log
      OF encounter_sys_log:
       IF (pentityid > 0.0)
        SET sysactlog->entityname = encounter_sys_log
       ELSE
        SET sysactlog->entityname = pft_encntr_sys_log
       ENDIF
      OF charge_sys_log:
       SET sysactlog->entityname = charge_sys_log
      OF batch_trans_sys_log:
       SET sysactlog->entityname = batch_trans_sys_log
      OF entity_trans_sys_log:
       SET sysactlog->entityname = entity_trans_sys_log
      OF entity_account_sys_log:
       SET sysactlog->entityname = entity_account_sys_log
      OF entity_person_sys_log:
       SET sysactlog->entityname = entity_person_sys_log
      OF entity_sch_event_sys_log:
       SET sysactlog->entityname = entity_sch_event_sys_log
      OF entity_sch_entry_sys_log:
       SET sysactlog->entityname = entity_sch_entry_sys_log
      OF entity_billing_entity_sys_log:
       SET sysactlog->entityname = entity_billing_entity_sys_log
      OF batch_trans_file_sys_log:
       SET sysactlog->entityname = batch_trans_file_sys_log
      OF workflow_task_queue_hist_sys_log:
       SET sysactlog->entityname = workflow_task_queue_hist_sys_log
      OF pft_charge_sys_log:
       SET sysactlog->entityname = pft_charge_sys_log
      ELSE
       SET sysactlog->entityname = ""
     ENDCASE
     IF (pentityid > 0.0)
      CASE (sysactlog->entityname)
       OF bill_rec_sys_log:
        SELECT INTO "nl:"
         FROM bill_rec br,
          bill_reltn brn,
          bo_hp_reltn bhr,
          benefit_order bo,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (br
          WHERE br.corsp_activity_id=pentityid
           AND br.active_ind=true)
          JOIN (brn
          WHERE brn.corsp_activity_id=br.corsp_activity_id
           AND brn.parent_entity_name=bo_hp_reltn_sys_log
           AND brn.active_ind=true)
          JOIN (bhr
          WHERE bhr.bo_hp_reltn_id=brn.parent_entity_id
           AND bhr.active_ind=true)
          JOIN (bo
          WHERE bo.benefit_order_id=bhr.benefit_order_id
           AND bo.active_ind=true)
          JOIN (pe
          WHERE pe.pft_encntr_id=bo.pft_encntr_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY br.corsp_activity_id
         HEAD br.corsp_activity_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
        IF (curqual=0)
         SELECT INTO "nl:"
          FROM pft_pending_bill ppb,
           pft_encntr pe,
           encounter e,
           person p
          PLAN (ppb
           WHERE ppb.corsp_activity_id=pentityid)
           JOIN (pe
           WHERE pe.pft_encntr_id=ppb.pft_encntr_id
            AND pe.active_ind=true)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id
            AND e.active_ind=true)
           JOIN (p
           WHERE p.person_id=e.person_id
            AND p.active_ind=true)
          ORDER BY ppb.corsp_activity_id
          HEAD ppb.corsp_activity_id
           sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
           sysactlog->encntrid = e.encntr_id,
           sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e
           .organization_id
          WITH nocounter
         ;end select
        ENDIF
       OF bo_hp_reltn_sys_log:
        SELECT INTO "nl:"
         FROM bo_hp_reltn bhr,
          benefit_order bo,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (bhr
          WHERE bhr.bo_hp_reltn_id=pentityid)
          JOIN (bo
          WHERE bo.benefit_order_id=bhr.benefit_order_id
           AND bo.active_ind=true)
          JOIN (pe
          WHERE pe.pft_encntr_id=bo.pft_encntr_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY bhr.bo_hp_reltn_id
         HEAD bhr.bo_hp_reltn_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF pft_encntr_sys_log:
        SELECT INTO "nl:"
         FROM pft_encntr pe,
          encounter e,
          person p
         PLAN (pe
          WHERE pe.pft_encntr_id=pentityid
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY pe.encntr_id
         HEAD pe.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF encounter_sys_log:
        SET sysactlog->entityname = pft_encntr_sys_log
        SET sysactlog->entityid = 0.0
        SET sysactlog->encntrid = pentityid
        SELECT INTO "nl:"
         FROM encounter e,
          person p,
          pft_encntr pe
         PLAN (e
          WHERE e.encntr_id=pentityid
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
          JOIN (pe
          WHERE (pe.encntr_id= Outerjoin(e.encntr_id))
           AND (pe.active_ind= Outerjoin(true)) )
         ORDER BY pe.pft_encntr_id, e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->locfacilitycd = e.loc_facility_cd,
          sysactlog->organizationid = e.organization_id, sysactlog->entityid = pe.pft_encntr_id
         WITH nocounter
        ;end select
       OF charge_sys_log:
        SELECT INTO "nl:"
         FROM charge c,
          encounter e,
          person p
         PLAN (c
          WHERE c.charge_item_id=pentityid
           AND c.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=c.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF pft_charge_sys_log:
        SELECT INTO "nl:"
         FROM pft_charge pc,
          charge c,
          encounter e,
          person p
         PLAN (pc
          WHERE pc.pft_charge_id=pentityid
           AND pc.active_ind=true)
          JOIN (c
          WHERE c.charge_item_id=pc.charge_item_id
           AND c.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=c.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY e.encntr_id
         HEAD e.encntr_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF batch_trans_sys_log:
        SELECT INTO "nl:"
         FROM batch_trans bt
         WHERE bt.batch_trans_id=pentityid
         ORDER BY bt.batch_trans_id
         HEAD bt.batch_trans_id
          sysactlog->entityid = bt.batch_trans_id, sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF batch_trans_file_sys_log:
        SELECT INTO "nl:"
         FROM batch_trans_file btf,
          batch_trans bt
         PLAN (btf
          WHERE btf.batch_trans_file_id=pentityid
           AND btf.active_ind=true)
          JOIN (bt
          WHERE bt.batch_trans_id=btf.batch_trans_id
           AND bt.active_ind=true)
         ORDER BY btf.batch_trans_file_id
         HEAD btf.batch_trans_file_id
          sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_trans_sys_log:
        SELECT INTO "nl:"
         FROM trans_log t,
          batch_trans_reltn btr,
          batch_trans bt
         PLAN (t
          WHERE t.activity_id=pentityid
           AND t.active_ind=true)
          JOIN (btr
          WHERE btr.activity_id=t.activity_id
           AND btr.active_ind=true)
          JOIN (bt
          WHERE bt.batch_trans_id=btr.batch_trans_id
           AND bt.active_ind=true)
         ORDER BY t.activity_id
         HEAD t.activity_id
          sysactlog->logicaldomainid = bt.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_account_sys_log:
        SELECT INTO "nl:"
         FROM account a,
          pft_encntr pe,
          encounter e,
          person p
         PLAN (a
          WHERE a.acct_id=pentityid
           AND a.active_ind=true)
          JOIN (pe
          WHERE pe.acct_id=a.acct_id
           AND pe.active_ind=true)
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=true)
          JOIN (p
          WHERE p.person_id=e.person_id
           AND p.active_ind=true)
         ORDER BY a.acct_id
         HEAD a.acct_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id,
          sysactlog->encntrid = e.encntr_id,
          sysactlog->locfacilitycd = e.loc_facility_cd, sysactlog->organizationid = e.organization_id
         WITH nocounter
        ;end select
       OF entity_person_sys_log:
        SELECT INTO "nl:"
         FROM person p
         WHERE p.person_id=pentityid
          AND p.active_ind=true
         ORDER BY p.person_id
         HEAD p.person_id
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_billing_entity_sys_log:
        SELECT INTO "nl:"
         FROM billing_entity be,
          organization o
         PLAN (be
          WHERE be.billing_entity_id=pentityid
           AND be.active_ind=true)
          JOIN (o
          WHERE o.organization_id=be.organization_id
           AND o.active_ind=true)
         ORDER BY be.billing_entity_id
         HEAD be.billing_entity_id
          sysactlog->logicaldomainid = o.logical_domain_id, sysactlog->organizationid = o
          .organization_id
         WITH nocounter
        ;end select
       OF entity_sch_event_sys_log:
        SELECT INTO "nl:"
         FROM sch_event se,
          sch_appt sa,
          person p
         PLAN (se
          WHERE se.sch_event_id=pentityid
           AND se.active_ind=true)
          JOIN (sa
          WHERE sa.sch_event_id=se.sch_event_id
           AND sa.active_ind=true)
          JOIN (p
          WHERE p.person_id=sa.person_id
           AND p.active_ind=true)
         ORDER BY se.sch_event_id
         HEAD se.sch_event_id
          sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       OF entity_sch_entry_sys_log:
        SELECT INTO "nl:"
         FROM sch_entry se,
          person p
         PLAN (se
          WHERE se.sch_entry_id=pentityid
           AND se.active_ind=true)
          JOIN (p
          WHERE p.person_id=se.person_id
           AND p.active_ind=true)
         ORDER BY se.sch_entry_id
         HEAD se.sch_entry_id
          sysactlog->logicaldomainid = p.logical_domain_id, sysactlog->entityid = se.sch_entry_id
         WITH nocounter
        ;end select
       OF workflow_task_queue_hist_sys_log:
        SELECT INTO "nl:"
         FROM workflow_task_queue_hist wtqh,
          person p
         PLAN (wtqh
          WHERE wtqh.workflow_task_queue_hist_id=pentityid)
          JOIN (p
          WHERE p.person_id=wtqh.updt_id
           AND p.active_ind=true)
         DETAIL
          sysactlog->personid = p.person_id, sysactlog->logicaldomainid = p.logical_domain_id
         WITH nocounter
        ;end select
       ELSE
        CALL logmessage(log_system_activity_sub,build2("Invalid entity [",pentityname,"]"),
         log_warning)
        SET queriedind = false
      ENDCASE
      IF (queriedind)
       IF (curqual=0)
        CALL logmessage(log_system_activity_sub,build2("No results returned for entity id [",
          pentityid,"]"),log_warning)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (logactivitytotable)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",sysactlog->finalstatuscd)
     SET stat = uar_srvsetstring(hobjarray,"entity_name",nullterm(sysactlog->entityname))
     SET stat = uar_srvsetdouble(hobjarray,"entity_id",sysactlog->entityid)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(sysactlog->taskname))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(sysactlog->completionmsg))
     SET stat = uar_srvsetdouble(hobjarray,"logical_domain_id",sysactlog->logicaldomainid)
     SET stat = uar_srvsetdouble(hobjarray,"loc_facility_cd",sysactlog->locfacilitycd)
     SET stat = uar_srvsetdouble(hobjarray,"organization_id",sysactlog->organizationid)
     SET stat = uar_srvsetdate(hobjarray,"start_dt_tm",cnvtdatetime(sysactlog->startdttm))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysactlog->enddttm))
     SET stat = uar_srvsetdouble(hobjarray,"encntr_id",sysactlog->encntrid)
     SET stat = uar_srvsetdouble(hobjarray,"person_id",sysactlog->personid)
     SET stat = uar_srvsetdouble(hobjarray,"pft_event_occur_log_id",sysactlog->pfteventoccurlogid)
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(sysactlog->currentnodename))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(sysactlog->servername))
     SET stat = uar_srvsetstring(hobjarray,"current_process_name",nullterm(trim(curprcname,3)))
     SET stat = uar_srvsetdouble(hobjarray,"execution_duration_secs",sysactlog->executiondurationsecs
      )
     SET stat = uar_srvsetstring(hobjarray,"timer_ident",nullterm(sysactlog->timeridentifier))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     IF (validate(debug))
      CALL echorecord(sysactlog)
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
    IF (((logactivitytofile) OR (logactivitytomsgview)) )
     SET logfilemsg = build(sysactlog->entityname,"|",cnvtstring(sysactlog->entityid,17,2),"|",
      sysactlog->taskname,
      "|",cnvtstring(sysactlog->finalstatuscd,17,2),"|",sysactlog->completionmsg,"|",
      cnvtstring(sysactlog->personid,17,2),"|",cnvtstring(sysactlog->encntrid,17,2),"|",cnvtstring(
       sysactlog->organizationid,17,2),
      "|",cnvtstring(sysactlog->locfacilitycd,17,2),"|",cnvtstring(sysactlog->logicaldomainid,17,2),
      "|",
      cnvtstring(sysactlog->pfteventoccurlogid,17,2),"|",sysactlog->currentnodename,"|",sysactlog->
      servername,
      "|",trim(curprcname,3),"|",cnvtstring(sysactlog->executiondurationsecs,17,2),"|",
      sysactlog->timeridentifier,"|",format(sysactlog->startdttm,";;Q"),"|",format(sysactlog->enddttm,
       ";;Q"),
      char(13),char(10))
     WHILE (logfilesize >= max_file_size_in_bytes)
       SET logfilenum += 1
       SET msgfilename = concat(base_log_file_name,cnvtstring(logfilenum,11))
       SET logfilename = concat(msgfilename,".txt")
       SET logfilesize = getfilesize(logfilename)
     ENDWHILE
    ENDIF
    IF (logactivitytofile)
     IF (logfilesize=0)
      DECLARE logfileheader = vc WITH protect, noconstant("")
      SET logfileheader = build(
       "ENTITY_NAME|ENTITY_ID|TASK_NAME|FINAL_STATUS_CD|COMPLETION_MSG|PERSON_ID|ENCNTR_ID|",
       "ORGANIZATION_ID|LOC_FACILITY_CD|LOGICAL_DOMAIN_ID|PFT_EVENT_OCCUR_LOG_ID|",
       "CURRENT_NODE_NAME|SERVER_NAME|CURRENT_PROCESS_NAME|EXECUTION_DURATION_SECS|TIMER_IDENT|",
       "START_DT_TM|END_DT_TM",char(13),
       char(10))
      SET loggedmsgind = transcribetofile(logfilename,logfileheader,"a")
     ENDIF
     SET loggedmsgind = transcribetofile(logfilename,logfilemsg,"a")
     IF ( NOT (loggedmsgind))
      CALL logmessage(log_system_activity_sub,concat("Failed to write to file:",logfilename),
       log_warning)
     ENDIF
    ENDIF
    IF (logactivitytomsgview)
     IF (size(msgfilename,1) <= max_msgview_file_name_size)
      EXECUTE msgrtl
      SET msghandle = uar_msgopen(nullterm(msgfilename))
      IF (msghandle != 0)
       CALL uar_msgsetlevel(msghandle,msgloglevel)
       CALL uar_msgwrite(msghandle,0,nullterm(msglogevent),msgloglevel,nullterm(logfilemsg))
       CALL uar_msgclose(msghandle)
      ELSE
       CALL logmessage(log_system_activity_sub,"Failed to write to MsgView. No file handle obtained",
        log_warning)
      ENDIF
     ELSE
      CALL logmessage(log_system_activity_sub,concat("File name ",msgfilename,
        " exceeds 31 character limit"),log_warning)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(cs13031_orggroup_cd)))
  DECLARE cs13031_orggroup_cd = f8 WITH protect, constant(getcodevalue(13031,"ORGGROUP",0))
 ENDIF
 DECLARE pipecharpos = i2 WITH protect, noconstant(0)
 DECLARE org_group_code_value = f8 WITH protect, noconstant(0)
 DECLARE cs_4688059 = f8 WITH protect, constant(4688059)
 SET reply->status_data.status = "F"
 SET event_cnt = 0
 SET srvitemcnt = 0
 SET stat = 0
 SET hl7_batch_cnt = 0
 SET real_time_cnt = 0
 SET profit_cnt = 0
 SET abn_missing_cnt = 0
 SET batch_proprietary_cnt = 0
 SET releaseappid = 951020
 SET releasetaskid = 951020
 SET releasereqid = 951021
 SET codeset = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,suspense_cd)
 CALL echo(build("the suspense code is : ",suspense_cd))
 SET codeset = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,inactive_cd)
 CALL echo(build("the active code is : ",inactive_cd))
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(concat(format(request->ops_date,"DD-MMM-YYYY;;d")," 23:59:59.99"))
  ELSE
   SET rn_dt = cnvtdatetime(curdate,curtime)
  ENDIF
 ELSE
  SET rn_dt = cnvtdatetime(curdate,curtime)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 IF (validate(request->from_date,999) != 999)
  IF ((request->from_date > 0))
   SET frm_dt = cnvtdatetime(concat(format(request->from_date,"dd-mmm-yyyy;;d")," 00:00:00.00"))
  ELSE
   SET frm_dt = cnvtdatetime("01-jan-1900 00:00:00.00")
  ENDIF
 ELSE
  SET frm_dt = cnvtdatetime("01-jan-1900 00:00:00.00")
 ENDIF
 CALL echo(concat("AFC_BATCH_CHARGE_RELEASE: FRM_DT: ",format(frm_dt,"dd-mmm-yyyy;;d")," ",format(
    frm_dt,"hh:mm:ss;;s")))
 CALL echo(concat("AFC_BATCH_CHARGE_RELEASE: OPS_DT: ",format(rn_dt,"dd-mmm-yyyy;;d")," ",format(
    rn_dt,"hh:mm:ss;;s")))
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE num1 = i4 WITH noconstant(0)
 DECLARE chargecount = i4 WITH protect, noconstant(0)
 DECLARE meaningval = c12
 DECLARE abnflg = i2 WITH noconstant(false), protect
 DECLARE heldstr = vc WITH protect
 DECLARE batchselectionvalue = i4 WITH protect, noconstant(0)
 DECLARE abn_required_list_size = i4 WITH protect, noconstant(0)
 SET pipecharpos = findstring("|",trim(request->batch_selection),1)
 IF (pipecharpos=0)
  SET batchselectionvalue = cnvtint(trim(request->batch_selection))
 ELSE
  SET batchselectionvalue = cnvtint(substring(1,(pipecharpos - 1),trim(request->batch_selection)))
 ENDIF
 IF (validate(request->batch_selection)=1)
  IF (batchselectionvalue=1)
   SET abnflg = true
  ELSE
   SET abnflg = false
  ENDIF
 ELSE
  SET abnflg = false
 ENDIF
 IF (abnflg=true)
  SET heldstr = " c.process_flg in (1,8) "
 ELSE
  SET heldstr = " c.process_flg = 1 "
 ENDIF
 CALL echo("MAIN SELECT")
 SET org_group_code_value = cnvtint(substring((pipecharpos+ 1),textlen(trim(request->batch_selection)
    ),trim(request->batch_selection)))
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=cs_4688059
   AND c.code_value=org_group_code_value
   AND c.active_ind=true
  WITH nocounter
 ;end select
 SET chargecount = 0
 IF (curqual > 0)
  CALL getsuspendedchargesoforggroup(heldstr,org_group_code_value,frm_dt,rn_dt,chargecount)
 ELSE
  CALL getsuspendedcharges(heldstr,frm_dt,rn_dt,chargecount)
 ENDIF
 SET qualcount = curqual
 CALL echorecord(suspended_charges)
 CALL echo("GETTING 13030 CVE")
 SET cur_list_size = size(suspended_charges->charge_items,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET nstart = 1
 SET stat = alterlist(suspended_charges->charge_items,new_list_size)
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET suspended_charges->charge_items[idx].field1_id = suspended_charges->charge_items[cur_list_size
   ].field1_id
 ENDFOR
 CALL echo(build("CUR_LIST_SIZE: ",cur_list_size))
 CALL echo(build("LOOP_CNT: ",loop_cnt))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value_extension cve
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cve
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cve.code_value,suspended_charges->charge_items[
    idx].field1_id)
    AND cve.code_set=13030
    AND cve.field_name="SKIP_CHARGING_SERVER")
  ORDER BY cve.code_value
  HEAD cve.code_value
   index = locateval(num1,1,cur_list_size,cve.code_value,suspended_charges->charge_items[num1].
    field1_id)
   WHILE (index != 0)
    IF ((suspended_charges->charge_items[index].process_flg=8))
     abn_missing_cnt += 1, stat = alterlist(abn_required_missing_charges->charge_items,
      abn_missing_cnt), abn_required_missing_charges->charge_items[abn_missing_cnt].charge_item_id =
     suspended_charges->charge_items[num1].charge_item_id,
     abn_required_missing_charges->charge_items[abn_missing_cnt].charge_event_id = suspended_charges
     ->charge_items[num1].charge_event_id, abn_required_missing_charges->charge_items[abn_missing_cnt
     ].charge_mod_id = suspended_charges->charge_items[num1].charge_mod_id,
     abn_required_missing_charges->charge_items[abn_missing_cnt].process_flg = suspended_charges->
     charge_items[num1].process_flg,
     abn_required_missing_charges->charge_items[abn_missing_cnt].interface_file_id =
     suspended_charges->charge_items[num1].interface_file_id
    ELSE
     IF ((suspended_charges->charge_items[index].field3_id=0))
      meaningval = uar_get_code_meaning(suspended_charges->charge_items[index].field1_id)
      IF (meaningval != "POSTING")
       IF (cnvtint(cve.field_value)=1)
        profit_cnt += 1, stat = alterlist(profit_charges->charges,profit_cnt), profit_charges->
        charges[profit_cnt].charge_item_id = suspended_charges->charge_items[index].charge_item_id,
        profit_charges->charges[profit_cnt].reprocess_ind = 0, profit_charges->charges[profit_cnt].
        dupe_ind = 0
       ELSE
        srvitemcnt += 1, stat = alterlist(srvitem->items,srvitemcnt), srvitem->items[srvitemcnt].
        charge_event_id = suspended_charges->charge_items[index].charge_event_id,
        srvitem->items[srvitemcnt].charge_item_id = suspended_charges->charge_items[index].
        charge_item_id
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    ,index = locateval(num1,(index+ 1),cur_list_size,cve.code_value,suspended_charges->charge_items[
     num1].field1_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET abn_required_list_size = size(abn_required_missing_charges->charge_items,5)
 SET loop_cnt = ceil((cnvtreal(abn_required_list_size)/ batch_size))
 SELECT INTO "nl:"
  FROM interface_file inf
  PLAN (inf
   WHERE expand(idx,1,abn_required_list_size,inf.interface_file_id,abn_required_missing_charges->
    charge_items[idx].interface_file_id))
  ORDER BY inf.interface_file_id
  HEAD inf.interface_file_id
   index = locateval(num1,1,abn_required_list_size,inf.interface_file_id,abn_required_missing_charges
    ->charge_items[num1].interface_file_id)
   WHILE (index != 0)
    IF (inf.profit_type_cd > 0)
     profit_cnt += 1, stat = alterlist(profit_charges->charges,profit_cnt), profit_charges->charges[
     profit_cnt].charge_item_id = abn_required_missing_charges->charge_items[index].charge_item_id,
     profit_charges->charges[profit_cnt].reprocess_ind = 0, profit_charges->charges[profit_cnt].
     dupe_ind = 0
    ELSEIF (inf.realtime_ind=1)
     real_time_cnt += 1, stat = alterlist(real_time_charges->interface_charge,real_time_cnt),
     real_time_charges->interface_charge[real_time_cnt].charge_item_id = abn_required_missing_charges
     ->charge_items[index].charge_item_id
    ELSEIF (inf.hl7_ind=1)
     hl7_batch_cnt += 1, stat = alterlist(hl7_batch_charges->charge,hl7_batch_cnt), hl7_batch_charges
     ->charge_qual = hl7_batch_cnt,
     hl7_batch_charges->charge[hl7_batch_cnt].charge_item_id = abn_required_missing_charges->
     charge_items[index].charge_item_id, hl7_batch_charges->charge[hl7_batch_cnt].process_flg = 0
    ELSE
     batch_proprietary_cnt += 1, stat = alterlist(batch_proprietary_charges->charge,
      batch_proprietary_cnt), batch_proprietary_charges->charge_qual = batch_proprietary_cnt,
     batch_proprietary_charges->charge[batch_proprietary_cnt].charge_item_id =
     abn_required_missing_charges->charge_items[index].charge_item_id, batch_proprietary_charges->
     charge[batch_proprietary_cnt].process_flg = 0
    ENDIF
    ,index = locateval(num1,(index+ 1),abn_required_list_size,inf.interface_file_id,
     abn_required_missing_charges->charge_items[num1].interface_file_id)
   ENDWHILE
  WITH nocounter, expand = 2
 ;end select
 SET stat = alterlist(suspended_charges->charge_items,cur_list_size)
 SET cur_list_size = size(suspended_charges->charge_items,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET nstart = 1
 SET stat = alterlist(suspended_charges->charge_items,new_list_size)
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET suspended_charges->charge_items[idx].field1_id = suspended_charges->charge_items[cur_list_size
   ].field1_id
 ENDFOR
 CALL echo(build("CUR_LIST_SIZE: ",cur_list_size))
 CALL echo(build("LOOP_CNT: ",loop_cnt))
 SET index = locateval(num1,1,cur_list_size,0.0,suspended_charges->charge_items[num1].field1_id)
 WHILE (index != 0)
   SET srvitemcnt += 1
   SET stat = alterlist(srvitem->items,srvitemcnt)
   SET srvitem->items[srvitemcnt].charge_event_id = suspended_charges->charge_items[index].
   charge_event_id
   SET srvitem->items[srvitemcnt].charge_item_id = suspended_charges->charge_items[index].
   charge_item_id
   SET index = locateval(num1,(index+ 1),cur_list_size,0.0,suspended_charges->charge_items[num1].
    field1_id)
 ENDWHILE
 SET stat = alterlist(suspended_charges->charge_items,cur_list_size)
 CALL echo("GETTING 4001910 CVE")
 SET cur_list_size = size(suspended_charges->charge_items,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(suspended_charges->charge_items,new_list_size)
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET suspended_charges->charge_items[idx].field1_id = suspended_charges->charge_items[cur_list_size
   ].field1_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value_extension cve
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cve
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cve.code_value,suspended_charges->charge_items[
    idx].field3_id)
    AND cve.code_set=4001910
    AND cve.field_name="SKIP_CHARGING_SERVER")
  ORDER BY cve.code_value
  HEAD cve.code_value
   index = locateval(num1,1,cur_list_size,cve.code_value,suspended_charges->charge_items[num1].
    field3_id)
   WHILE (index != 0)
    IF ((suspended_charges->charge_items[index].field3_id > 0))
     meaningval = uar_get_code_meaning(suspended_charges->charge_items[index].field1_id)
     IF (meaningval="POSTING")
      IF (cnvtint(cve.field_value)=1)
       profit_cnt += 1, stat = alterlist(profit_charges->charges,profit_cnt), profit_charges->
       charges[profit_cnt].charge_item_id = suspended_charges->charge_items[index].charge_item_id,
       profit_charges->charges[profit_cnt].reprocess_ind = 0, profit_charges->charges[profit_cnt].
       dupe_ind = 0
      ELSE
       srvitemcnt += 1, stat = alterlist(srvitem->items,srvitemcnt), srvitem->items[srvitemcnt].
       charge_event_id = suspended_charges->charge_items[index].charge_event_id,
       srvitem->items[srvitemcnt].charge_item_id = suspended_charges->charge_items[index].
       charge_item_id
      ENDIF
     ENDIF
    ENDIF
    ,index = locateval(num1,(index+ 1),cur_list_size,cve.code_value,suspended_charges->charge_items[
     num1].field3_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(suspended_charges->charge_items,cur_list_size)
 CALL echorecord(profit_charges)
 CALL echorecord(srvitem)
 CALL echorecord(hl7_batch_charges)
 CALL echorecord(real_time_charges)
 CALL echorecord(batch_proprietary_charges)
 IF (size(srvitem->items,5) <= 0
  AND size(profit_charges->charges,5) <= 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET hl7_batch_cnt = size(hl7_batch_charges->charge,5)
 SET real_time_cnt = size(real_time_charges->interface_charge,5)
 SET stat = alterlist(hl7_batch_charges->charge,(hl7_batch_cnt+ real_time_cnt))
 SET hl7_batch_charges->charge_qual = (hl7_batch_cnt+ real_time_cnt)
 FOR (idx = 1 TO real_time_cnt)
  SET hl7_batch_charges->charge[(hl7_batch_cnt+ idx)].charge_item_id = real_time_charges->
  interface_charge[idx].charge_item_id
  SET hl7_batch_charges->charge[(hl7_batch_cnt+ idx)].process_flg = 0
 ENDFOR
 CALL echorecord(hl7_batch_charges)
 IF (size(hl7_batch_charges->charge,5) > 0)
  CALL echo("Executing afc_ens_release_charge to release qualifying  hl7 batch interface charges...")
  EXECUTE afc_ens_release_charge  WITH replace("REQUEST",hl7_batch_charges)
  IF ((reply->status_data.status="S"))
   CALL echo(build("hl7 batch  interface charges released successfully with status: ",reply->
     status_data.status))
   COMMIT
  ELSEIF ((reply->status_data.status="F"))
   CALL echo("hl7 batch  interface charges release failed ")
  ELSE
   CALL echo(build("Unknown status returned from afc_ens_release_charge script:",reply->status_data.
     status))
  ENDIF
 ENDIF
 IF (size(batch_proprietary_charges->charge,5) > 0)
  CALL echo(
   "Executing afc_ens_release_charge to release qualifying  batch proprietary interface charges...")
  EXECUTE afc_ens_release_charge  WITH replace("REQUEST",batch_proprietary_charges)
  IF ((reply->status_data.status="S"))
   CALL echo(build("batch proprietary interface charges released successfully with status: ",reply->
     status_data.status))
   COMMIT
  ELSEIF ((reply->status_data.status="F"))
   CALL echo("batch proprietary interface charges release failed ")
  ELSE
   CALL echo(build("Unknown status returned from afc_ens_release_charge script:",reply->status_data.
     status))
  ENDIF
 ENDIF
 IF (size(real_time_charges->interface_charge,5) > 0)
  CALL echo(
   "Executing afc_post_interface_charge to release qualifying  interface realtime charges...")
  EXECUTE afc_post_interface_charge  WITH replace("REQUEST",real_time_charges), replace("REPLY",
   afc_interface_charge_reply)
  IF ((reply->status_data.status="S"))
   CALL echo(build("interface realtime charges released successfully with status: ",reply->
     status_data.status))
  ELSEIF ((reply->status_data.status="F"))
   CALL echo("interface realtime charges release failed ")
  ELSE
   CALL echo(build("Unknown status returned from afc_post_interface_charge script:",reply->
     status_data.status))
  ENDIF
 ENDIF
 IF (size(profit_charges->charges,5) > 0)
  CALL logmessage("main","Posting charges to ProFit",log_debug)
  RECORD ntchrgbillingreq(
    1 charges[*]
      2 charge_item_id = f8
      2 reprocess_ind = i2
      2 dupe_ind = i2
      2 process_charge_ind = i2
  ) WITH protect
  RECORD ntchrgbillingrep(
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
  IF (validate(debug,0))
   CALL echorecord(profit_charges)
  ENDIF
  DECLARE totalremainingcharges = i4 WITH protect, noconstant(size(profit_charges->charges,5))
  DECLARE startbatchindex = i4 WITH protect, noconstant(1)
  DECLARE endbatchindex = i4 WITH protect, noconstant(0)
  DECLARE chargeloop = i4 WITH protect, noconstant(0)
  DECLARE chgidx = i4 WITH protect, noconstant(0)
  IF ( NOT (validate(max_charges)))
   DECLARE max_charges = i4 WITH protect, constant(50)
  ENDIF
  IF (totalremainingcharges > max_charges)
   SET endbatchindex = max_charges
  ELSE
   SET endbatchindex = totalremainingcharges
  ENDIF
  WHILE (totalremainingcharges)
    SET chargecount = 0
    SET stat = initrec(ntchrgbillingreq)
    SET stat = initrec(ntchrgbillingrep)
    SET stat = alterlist(ntchrgbillingreq->charges,((endbatchindex - startbatchindex)+ 1))
    FOR (chargeloop = startbatchindex TO endbatchindex)
      SET chargecount += 1
      SET ntchrgbillingreq->charges[chargecount].charge_item_id = profit_charges->charges[chargeloop]
      .charge_item_id
      SET ntchrgbillingreq->charges[chargecount].process_charge_ind = 1
    ENDFOR
    UPDATE  FROM charge c
     SET c.process_flg = 0
     WHERE expand(chgidx,1,size(ntchrgbillingreq->charges,5),c.charge_item_id,ntchrgbillingreq->
      charges[chgidx].charge_item_id)
     WITH nocounter
    ;end update
    EXECUTE pft_nt_chrg_billing  WITH replace(request,ntchrgbillingreq), replace(reply,
     ntchrgbillingrep)
    CASE (ntchrgbillingrep->status_data.status)
     OF "S":
      CALL logmessage("main","NT charge billing succeeded",log_debug)
     OF "F":
      CALL logmessage("main","NT charge billing failed",log_debug)
     ELSE
      CALL logmessage("main",build("NT charge billing returned:",ntchrgbillingrep->status_data.status
        ),log_debug)
    ENDCASE
    IF (validate(debug,0))
     CALL echorecord(ntchrgbillingrep)
    ENDIF
    SET totalremainingcharges -= chargecount
    SET startbatchindex = (endbatchindex+ 1)
    IF (totalremainingcharges > max_charges)
     SET endbatchindex += max_charges
    ELSE
     SET endbatchindex += totalremainingcharges
    ENDIF
  ENDWHILE
 ENDIF
 IF (size(srvitem->items,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(srvitem->items,5))),
    charge c
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=srvitem->items[d1.seq].charge_item_id))
   ORDER BY c.charge_event_id, c.charge_item_id
   HEAD c.charge_event_id
    cecnt += 1, stat = alterlist(itemcharge->charge_events,cecnt), itemcharge->charge_events[cecnt].
    charge_event_id = c.charge_event_id,
    chargecnt = 0
   DETAIL
    chargecnt += 1, stat = alterlist(itemcharge->charge_events[cecnt].chargeitems,chargecnt),
    itemcharge->charge_events[cecnt].chargeitems[chargecnt].charge_item_id = c.charge_item_id
   WITH nocounter
  ;end select
  SET startidx = 1
  SET totalitemcnt = size(itemcharge->charge_events,5)
  IF (totalitemcnt <= max_rows)
   SET endidx = totalitemcnt
  ELSE
   SET endidx = max_rows
  ENDIF
  SET unprocesseditemcnt = 0
  SET iret = uar_crmbeginapp(releaseappid,happrelease)
  IF (iret=0)
   CALL echo("Successful begin app")
   SET iret = uar_crmbegintask(happrelease,releasetaskid,htaskrelease)
   IF (iret=0)
    CALL echo("Successful begin task")
    WHILE (completed=0)
     SET iret = uar_crmbeginreq(htaskrelease,"",releasereqid,hsteprelease)
     IF (iret=0)
      CALL echo("Begin request successful")
      SET hreq = uar_crmgetrequest(hsteprelease)
      SET srvstat = uar_srvsetshort(hreq,"charge_event_qual",endidx)
      SET srvstat = uar_srvsetshort(hprocess,"charge_item_qual",endidx)
      FOR (loopcnt = startidx TO endidx)
        SET hprocess = uar_srvadditem(hreq,"process_event")
        SET srvstat = uar_srvsetdouble(hprocess,"charge_event_id",itemcharge->charge_events[loopcnt].
         charge_event_id)
        FOR (chargecnt = 1 TO size(itemcharge->charge_events[loopcnt].chargeitems,5))
         SET hcharge = uar_srvadditem(hprocess,"charge_item")
         SET srvstat = uar_srvsetdouble(hcharge,"charge_item_id",itemcharge->charge_events[loopcnt].
          chargeitems[chargecnt].charge_item_id)
        ENDFOR
      ENDFOR
      SET iret = uar_crmperform(hsteprelease)
      IF (iret != 0)
       CALL echo(concat("CRM perform failed:",build(iret)))
      ELSE
       CALL echo("crmperform success")
      ENDIF
      CALL uar_crmendreq(hsteprelease)
      SET unprocesseditemcnt = (totalitemcnt - endidx)
      IF (unprocesseditemcnt >= max_rows)
       SET startidx = (endidx+ 1)
       SET endidx += max_rows
      ELSEIF (unprocesseditemcnt < max_rows
       AND unprocesseditemcnt != 0)
       SET startidx = (endidx+ 1)
       SET endidx += unprocesseditemcnt
      ELSE
       SET completed = 1
      ENDIF
     ELSE
      CALL echo(concat("Begin request unsuccessful: ",build(iret)))
     ENDIF
    ENDWHILE
    CALL uar_crmendtask(htaskrelease)
   ELSE
    CALL echo(concat("Unsuccessful begin task: ",build(iret)))
   ENDIF
   CALL uar_crmendapp(happrelease)
  ELSE
   CALL echo(concat("Begin app failed with code: ",build(iret)))
  ENDIF
  CALL echo(build("AFC_BATCH_CHARGE_RELEASE: ",endidx," Suspended charges submitted."))
 ENDIF
 SUBROUTINE (getsuspendedcharges(pheldstr=vc,pfrmdt=dq8,prndt=dq8,prcount=i4(ref)) =i2 WITH protect)
  CALL logmessage("getSuspendedCharges","Entering",log_debug)
  SELECT INTO "nl:"
   FROM charge c,
    charge_mod cm
   PLAN (c
    WHERE parser(pheldstr)
     AND c.service_dt_tm BETWEEN cnvtdatetime(pfrmdt) AND cnvtdatetime(prndt)
     AND c.charge_item_id > 0
     AND c.active_ind=true)
    JOIN (cm
    WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
     AND (cm.charge_mod_type_cd= Outerjoin(suspense_cd))
     AND (cm.active_ind= Outerjoin(true)) )
   ORDER BY c.charge_event_id, c.charge_item_id
   HEAD c.charge_item_id
    prcount += 1, stat = alterlist(suspended_charges->charge_items,prcount), suspended_charges->
    charge_items[prcount].charge_item_id = c.charge_item_id,
    suspended_charges->charge_items[prcount].charge_event_id = c.charge_event_id, suspended_charges->
    charge_items[prcount].charge_mod_id = cm.charge_mod_id, suspended_charges->charge_items[prcount].
    field1_id = cm.field1_id,
    suspended_charges->charge_items[prcount].field3_id = cm.field3_id, suspended_charges->
    charge_items[prcount].process_flg = c.process_flg, suspended_charges->charge_items[prcount].
    interface_file_id = c.interface_file_id
   DETAIL
    null
   WITH nocounter, forupdate
  ;end select
 END ;Subroutine
 SUBROUTINE (getsuspendedchargesoforggroup(pheldstr=vc,porggroupcodevalue=f8,pfrmdt=dq8,prndt=dq8,
  prcount=i4(ref)) =i2 WITH protect)
  CALL logmessage("getSuspendedChargesOfOrgGroup","Entering",log_debug)
  SELECT INTO "nl:"
   FROM charge c,
    charge_mod cm,
    organization o,
    bill_org_payor bop
   PLAN (c
    WHERE parser(pheldstr)
     AND c.service_dt_tm BETWEEN cnvtdatetime(pfrmdt) AND cnvtdatetime(prndt)
     AND c.charge_item_id > 0
     AND c.active_ind=true)
    JOIN (cm
    WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
     AND (cm.charge_mod_type_cd= Outerjoin(suspense_cd))
     AND (cm.active_ind= Outerjoin(true)) )
    JOIN (bop
    WHERE bop.organization_id=c.payor_id
     AND bop.bill_org_type_cd=cs13031_orggroup_cd
     AND bop.bill_org_type_id=porggroupcodevalue
     AND bop.active_ind=true)
    JOIN (o
    WHERE o.organization_id=bop.organization_id
     AND o.active_ind=true)
   ORDER BY c.charge_event_id, c.charge_item_id
   HEAD c.charge_item_id
    prcount += 1, stat = alterlist(suspended_charges->charge_items,prcount), suspended_charges->
    charge_items[prcount].charge_item_id = c.charge_item_id,
    suspended_charges->charge_items[prcount].charge_event_id = c.charge_event_id, suspended_charges->
    charge_items[prcount].charge_mod_id = cm.charge_mod_id, suspended_charges->charge_items[prcount].
    field1_id = cm.field1_id,
    suspended_charges->charge_items[prcount].field3_id = cm.field3_id, suspended_charges->
    charge_items[prcount].process_flg = c.process_flg, suspended_charges->charge_items[prcount].
    interface_file_id = c.interface_file_id
   DETAIL
    null
   WITH nocounter, forupdate
  ;end select
 END ;Subroutine
#end_program
 CALL logsystemactivity(script_start_dt_tm,curprog," ",0.0,reply->status_data.status,
  build2("End calculation of the script execution time - ","Count[",qualcount,"]"),script_level_timer
  )
 CALL echo(build("status is: ",reply->status_data.status))
END GO
