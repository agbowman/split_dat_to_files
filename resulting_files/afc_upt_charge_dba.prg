CREATE PROGRAM afc_upt_charge:dba
 SET afc_upt_charge = "719977.022"
 RECORD addchargemodrequest(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c350
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
 )
 RECORD addchargemodreply(
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
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD reprocesschargelist(
   1 charge_event_qual = i4
   1 charge_event[*]
     2 charge_event_id = f8
     2 charge_qual = i4
     2 charge[*]
       3 charge_item_id = f8
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
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
 CALL echo("Begin AFC_MODIFY_CHARGE_SUBS.inc, version [639876.001]")
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
 IF ( NOT (validate(afcaddcreditreq->charge)))
  RECORD afcaddcreditreq(
    1 charge_qual = i2
    1 charge[*]
      2 charge_item_id = f8
      2 suspense_rsn_cd = f8
      2 reason_comment = vc
      2 late_charge_processing_ind = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(afcaddcreditreply->status_data)))
  RECORD afcaddcreditreply(
    1 charge_qual = i4
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
      2 original_org_id = f8
    1 original_charge_qual = i4
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
 ENDIF
 IF ( NOT (validate(cs13028_debit_cd)))
  DECLARE cs13028_debit_cd = f8 WITH protect, constant(getcodevalue(13028,"DR",0))
 ENDIF
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
 IF (validate(creditrelatedaddonsbeforereprocessing,char(128))=char(128))
  SUBROUTINE (creditrelatedaddonsbeforereprocessing(pchargeitemid=f8,preasoncomment=vc,
   psuspensreasoncode=f8) =i2)
    CALL logmessage("creditRelatedAddonsBeforeReprocessing","Entering...",log_debug)
    SET stat = initrec(afcaddcreditreq)
    SET stat = initrec(afcaddcreditreply)
    IF (pchargeitemid <= 0)
     CALL echo(build("pChargeItemID is less than or equal to 0, returning False"))
     CALL logmessage(curprog,build("pChargeItemID is less than or equal to 0, returning false"),
      log_debug)
     CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("pChargeItemId is: ",pchargeitemid))
     CALL echo(build2("pReasonComment is: ",preasoncomment))
     CALL echo(build2("pSuspensReasonCode is: ",psuspensreasoncode))
    ENDIF
    DECLARE charge_event_id = f8 WITH protect, noconstant(0.0)
    DECLARE tier_group_cd = f8 WITH protect, noconstant(0.0)
    DECLARE crchrgcount = i4 WITH protect, noconstant(0)
    DECLARE bill_item_ext_owner_cd = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM charge c,
      bill_item b
     PLAN (c
      WHERE c.charge_item_id=pchargeitemid
       AND c.active_ind=1)
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
     DETAIL
      charge_event_id = c.charge_event_id, tier_group_cd = c.tier_group_cd, bill_item_ext_owner_cd =
      b.ext_owner_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo(build("pChargeItemID is not a valid active charge"))
     CALL logmessage(curprog,build("pChargeItemID is not a valid active charge, returning false"),
      log_debug)
     CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF (bill_item_ext_owner_cd=cs106_genericaddon)
     IF (validate(debug,- (1)) > 0)
      CALL echo(build("Charge is a Generic ADD-ON. Returning from subroutine"))
     ENDIF
     CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
     RETURN(true)
    ELSEIF (bill_item_ext_owner_cd=cs106_specificaddon)
     IF (validate(debug,- (1)) > 0)
      CALL echo(build("Charge is a Specific ADD-ON. Returning from subroutine"))
     ENDIF
     CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
     RETURN(true)
    ELSEIF (bill_item_ext_owner_cd=cs106_defaultaddon)
     IF (validate(debug,- (1)) > 0)
      CALL echo(build("Charge is a Default ADD-ON. Returning from subroutine"))
     ENDIF
     CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
     RETURN(true)
    ELSE
     SELECT INTO "nl:"
      FROM charge c,
       bill_item b,
       bill_item_modifier bim,
       charge c2
      PLAN (c
       WHERE c.charge_event_id=charge_event_id)
       JOIN (b
       WHERE b.bill_item_id=c.bill_item_id)
       JOIN (bim
       WHERE bim.key1_id=b.bill_item_id
        AND bim.key2_id=cs106_defaultaddon
        AND bim.bill_item_type_cd=cs13019_add_on_cd
        AND bim.active_ind=1)
       JOIN (c2
       WHERE c2.bill_item_id=b.bill_item_id
        AND c2.charge_item_id=pchargeitemid)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      IF (validate(debug,- (1)) > 0)
       CALL echo(build("Charge is a Default ADD-ON. Returning from subroutine"))
      ENDIF
      CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
      RETURN(true)
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM charge c,
      bill_item b
     PLAN (c
      WHERE c.charge_item_id != pchargeitemid
       AND c.charge_event_id=charge_event_id
       AND c.tier_group_cd=tier_group_cd
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
      crchrgcount += 1, stat = alterlist(afcaddcreditreq->charge,crchrgcount), afcaddcreditreq->
      charge_qual = crchrgcount,
      afcaddcreditreq->charge[crchrgcount].charge_item_id = c.charge_item_id, afcaddcreditreq->
      charge[crchrgcount].late_charge_processing_ind = 0, afcaddcreditreq->charge[crchrgcount].
      reason_comment = preasoncomment,
      afcaddcreditreq->charge[crchrgcount].suspense_rsn_cd = psuspensreasoncode
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM charge c,
      bill_item b,
      bill_item_modifier bim
     PLAN (c
      WHERE c.charge_item_id != pchargeitemid
       AND c.charge_event_id=charge_event_id
       AND c.tier_group_cd=tier_group_cd
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
      crchrgcount += 1, stat = alterlist(afcaddcreditreq->charge,crchrgcount), afcaddcreditreq->
      charge_qual = crchrgcount,
      afcaddcreditreq->charge[crchrgcount].charge_item_id = c.charge_item_id, afcaddcreditreq->
      charge[crchrgcount].late_charge_processing_ind = 0, afcaddcreditreq->charge[crchrgcount].
      reason_comment = preasoncomment,
      afcaddcreditreq->charge[crchrgcount].suspense_rsn_cd = psuspensreasoncode
     WITH nocounter
    ;end select
    IF (crchrgcount > 0)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(afcaddcreditreq)
     ENDIF
     EXECUTE afc_add_credit  WITH replace("REQUEST",afcaddcreditreq), replace("REPLY",
      afcaddcreditreply)
     IF ((afcaddcreditreply->status_data.status="F"))
      CALL echo(build("Add Credit Reply Status is F"))
      CALL logmessage(curprog,build("Add Credit Reply Status is F"),log_debug)
      CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
      RETURN(false)
     ENDIF
    ENDIF
    CALL logmessage("creditRelatedAddonsBeforeReprocessing","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(evaluatechargeforreprocess,char(128))=char(128))
  SUBROUTINE (evaluatechargeforreprocess(chargereq=vc(ref),chargeidx=i4,chargefindreply=vc(ref)) =i2)
    CALL logmessage("evaluateChargeForReprocess","Entering...",log_debug)
    IF (((validate(chargereq->charge[chargeidx].charge_item_id) <= 0) OR (validate(chargefindreply->
     charge_items[1].charge_item_id) <= 0)) )
     IF (validate(debug,- (1)) > 0)
      CALL echo(
       "Charge Item Id wasn't found within the chargeReq or chargeFindReply - don't flag for reprocess"
       )
     ENDIF
     CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF ((chargereq->charge[chargeidx].charge_item_id <= 0))
     IF (validate(debug,- (1)) > 0)
      CALL echo("Charge Item Id is < 0 - don't flag for reprocess")
     ENDIF
     CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF ((chargereq->charge[chargeidx].charge_item_id != chargefindreply->charge_items[1].
    charge_item_id))
     IF (validate(debug,- (1)) > 0)
      CALL echo(
       "ChargeReq and ChargeFindReply charge item ids don't match - don't flag for reprocess")
     ENDIF
     CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF (validate(chargereq->charge[chargeidx].ord_phys_id) > 0
     AND validate(chargefindreply->charge_items[1].ord_phys_id) > 0)
     IF ((chargereq->charge[chargeidx].ord_phys_id != 0)
      AND (chargereq->charge[chargeidx].ord_phys_id != chargefindreply->charge_items[1].ord_phys_id))
      IF (checktierforordphys(chargereq->charge[chargeidx].charge_item_id))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "ORD_PHYS_ID change and tiering by Ord_Phys or Provider Specialty - flagged charge for reprocess"
         )
       ENDIF
       RETURN(true)
      ENDIF
     ENDIF
    ELSE
     IF (validate(debug,- (1)) > 0)
      CALL echo(
       "ORD_PHYS_ID couldn't be found on either the chargeReq or the chargeFindReply - don't flag for reprocess"
       )
     ENDIF
     RETURN(false)
    ENDIF
    IF (validate(chargereq->charge[chargeidx].verify_phys_id) > 0
     AND validate(chargefindreply->charge_items[1].verify_phys_id) > 0)
     IF ((chargereq->charge[chargeidx].verify_phys_id != 0)
      AND (chargereq->charge[chargeidx].verify_phys_id != chargefindreply->charge_items[1].
     verify_phys_id))
      IF (checktierforrendphys(chargereq->charge[chargeidx].charge_item_id))
       IF (validate(debug,- (1)) > 0)
        CALL echo(
         "VERIFY_PHYS_ID change and tiering by Verify_Phys or Provider Specialty - flagged charge for reprocess"
         )
       ENDIF
       RETURN(true)
      ENDIF
     ENDIF
    ELSE
     IF (validate(debug,- (1)) > 0)
      CALL echo(
       "VERIFY_PHYS_ID couldn't be found on either the chargeReq or the chargeFindReply - don't flag for reprocess"
       )
     ENDIF
     RETURN(false)
    ENDIF
    IF (validate(chargereq->charge[chargeidx].charge_mod) > 0)
     IF (checktierforcptmod(chargereq->charge[chargeidx].charge_item_id))
      DECLARE chargemodcnt = i4 WITH noconstant(0)
      FOR (chargemodcnt = 1 TO size(chargereq->charge[chargeidx].charge_mod,5))
        IF (validate(chargereq->charge[chargeidx].charge_mod[chargemodcnt].field1_id) > 0
         AND validate(chargereq->charge[chargeidx].charge_mod[chargemodcnt].action_type) > 0
         AND validate(chargereq->charge[chargeidx].charge_mod[chargemodcnt].charge_mod_id) > 0)
         IF (uar_get_code_meaning(chargereq->charge[chargeidx].charge_mod[chargemodcnt].field1_id)=
         "MODIFIER"
          AND (chargereq->charge[chargeidx].charge_mod[chargemodcnt].action_type != "EXI"))
          IF (validate(debug,- (1)) > 0)
           CALL echo("Modifier change - flagged charge for reprocess")
          ENDIF
          RETURN(true)
         ELSE
          IF ((((chargereq->charge[chargeidx].charge_mod[chargemodcnt].action_type="DEL")) OR ((
          chargereq->charge[chargeidx].charge_mod[chargemodcnt].field1_id=0.0))) )
           DECLARE schedtype = f8 WITH protect, noconstant(0.0)
           SELECT INTO "nl:"
            FROM charge_mod cm
            WHERE (cm.charge_mod_id=chargereq->charge[chargeidx].charge_mod[chargemodcnt].
            charge_mod_id)
            DETAIL
             schedtype = cm.field1_id
            WITH nocounter
           ;end select
           IF (uar_get_code_meaning(schedtype)="MODIFIER")
            IF (validate(debug,- (1)) > 0)
             CALL echo("Modifier delete - flagged charge for reprocess")
            ENDIF
            RETURN(true)
           ENDIF
          ENDIF
         ENDIF
        ELSE
         IF (validate(debug,- (1)) > 0)
          CALL echo(
           "CHARGE_MOD->FIELD1_ID/ACTION_TYPE/CHARGE_MOD_ID couldn't be found - don't flag for reprocess"
           )
         ENDIF
         CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
         RETURN(false)
        ENDIF
      ENDFOR
     ELSE
      IF (validate(debug,- (1)) > 0)
       CALL echo(
        "The tier for this charge doesn't have any modifiers built in it - continue processing")
      ENDIF
     ENDIF
    ELSE
     IF (validate(debug,- (1)) > 0)
      CALL echo(
       "CHARGE_MOD(s) couldn't be found on either the chargeReq or the chargeFindReply - don't charge for reprocess"
       )
     ENDIF
     CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
     RETURN(false)
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL echo("No changes found that require the charge to be reprocessed - returning false")
    ENDIF
    CALL logmessage("evaluateChargeForReprocess","Exiting...",log_debug)
    RETURN
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_qual = i2
    1 charge[*]
      2 charge_item_id = f8
      2 perf_loc_cd = f8
      2 perf_loc_disp = c40
      2 perf_loc_desc = c60
      2 perf_loc_mean = c12
      2 ord_phys_id = f8
      2 verify_phys_id = f8
      2 research_acct_id = f8
      2 abn_status_cd = f8
      2 service_dt_tm = dq8
      2 suspense_rsn_cd = f8
      2 reason_comment = vc
      2 process_flg = i4
      2 original_org_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET reply->charge_qual = request->charge_qual
 ENDIF
 SET action_begin = 1
 SET action_end = request->charge_qual
 DECLARE charge_mod_add_count = i4 WITH public, noconstant(0)
 DECLARE 13019_mod_rsn_cd = f8
 DECLARE 4001989_modify_cd = f8
 SET stat = uar_get_meaning_by_codeset(13019,"MOD RSN",1,13019_mod_rsn_cd)
 SET stat = uar_get_meaning_by_codeset(4001989,"MODIFY",1,4001989_modify_cd)
 CALL echo(build("13019_MOD_RSN_CD: ",13019_mod_rsn_cd))
 CALL echo(build("4001989_CREDIT_CD: ",4001989_modify_cd))
 SET charge_qual_count = 0
 CALL echo(build(action_begin," ACTION_BEGIN"))
 CALL echo(build(action_end," ACTION_END"))
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE"
 CALL echo("Calling UPT_CHARGE subroutine")
 CALL upt_charge(action_begin,action_end)
 CALL echo("Back from UPT_CHARGE subroutine")
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 CALL echo("Made it to the UPT CHARGE subroutine")
 SUBROUTINE upt_charge(upt_begin,upt_end)
   DECLARE temp_phys_id = f8 WITH public, noconstant(0.0)
   DECLARE temp_abn_status_cd = f8 WITH public, noconstant(0.0)
   DECLARE ver_phys_code = f8 WITH public, noconstant(0.0)
   DECLARE ord_phys_code = f8 WITH public, noconstant(0.0)
   DECLARE temp_charge_act_id = f8 WITH public, noconstant(0.0)
   DECLARE temp_charge_ev_id = f8 WITH public, noconstant(0.0)
   DECLARE temp_charge_ev_id2 = f8 WITH public, noconstant(0.0)
   DECLARE ord_phys_change_ind = i2 WITH protect, noconstant(false)
   DECLARE rend_phys_change_ind = i2 WITH protect, noconstant(false)
   DECLARE temp_charge_ev_act_id = f8 WITH public, noconstant(0.0)
   DECLARE temp_serv_date = dq8
   DECLARE temp_serv_date2 = dq8
   SET stat = uar_get_meaning_by_codeset(13029,"ORDERED",1,ord_phys_code)
   SET stat = uar_get_meaning_by_codeset(13029,"VERIFIED",1,ver_phys_code)
   FOR (x = upt_begin TO upt_end)
     SET new_nbr = 0.0
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0.0
     SET ord_phys_change_ind = false
     SET rend_phys_change_ind = false
     SELECT INTO "nl:"
      c.*
      FROM charge c
      WHERE (c.charge_item_id=request->charge[x].charge_item_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF ((request->charge[x].active_status_cd > 0))
        active_status_code = c.active_status_cd
       ENDIF
      WITH forupdate(c)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     SELECT INTO "nl:"
      FROM charge c
      WHERE (c.charge_item_id=request->charge[x].charge_item_id)
       AND c.active_ind=1
      DETAIL
       IF ((request->charge[x].ord_phys_id != 0)
        AND (c.ord_phys_id != request->charge[x].ord_phys_id)
        AND  NOT (c.ord_phys_id=0
        AND (request->charge[x].ord_phys_id=- (1))))
        ord_phys_change_ind = true
       ENDIF
       IF ((request->charge[x].verify_phys_id != 0)
        AND (c.verify_phys_id != request->charge[x].verify_phys_id)
        AND  NOT (c.verify_phys_id=0
        AND (request->charge[x].verify_phys_id=- (1))))
        rend_phys_change_ind = true
       ENDIF
      WITH nocounter
     ;end select
     DECLARE admittypecd = f8 WITH protect, noconstant(validate(request->charge[x].admit_type_cd,0.0)
      )
     DECLARE healthplanid = f8 WITH protect, noconstant(validate(request->charge[x].health_plan_id,
       0.0))
     DECLARE finclasscd = f8 WITH protect, noconstant(validate(request->charge[x].fin_class_cd,0.0))
     DECLARE originalorgid = f8 WITH protect, noconstant(validate(request->charge[x].original_org_id,
       0.0))
     DECLARE medservicecd = f8 WITH protect, noconstant(validate(request->charge[x].med_service_cd,
       0.0))
     UPDATE  FROM charge c
      SET c.parent_charge_item_id = evaluate(request->charge[x].parent_charge_item_id,0.0,c
        .parent_charge_item_id,- (1.0),0.0,
        request->charge[x].parent_charge_item_id), c.charge_event_act_id = evaluate(request->charge[x
        ].charge_event_act_id,0.0,c.charge_event_act_id,- (1.0),0.0,
        request->charge[x].charge_event_act_id), c.charge_event_id = evaluate(request->charge[x].
        charge_event_id,0.0,c.charge_event_id,- (1.0),0.0,
        request->charge[x].charge_event_id),
       c.bill_item_id = evaluate(request->charge[x].bill_item_id,0.0,c.bill_item_id,- (1.0),0.0,
        request->charge[x].bill_item_id), c.order_id = evaluate(request->charge[x].order_id,0.0,c
        .order_id,- (1.0),0.0,
        request->charge[x].order_id), c.encntr_id = evaluate(request->charge[x].encntr_id,0.0,c
        .encntr_id,- (1.0),0.0,
        request->charge[x].encntr_id),
       c.person_id = evaluate(request->charge[x].person_id,0.0,c.person_id,- (1.0),0.0,
        request->charge[x].person_id), c.payor_id = evaluate(request->charge[x].payor_id,0.0,c
        .payor_id,- (1.0),0.0,
        request->charge[x].payor_id), c.ord_loc_cd = evaluate(request->charge[x].ord_loc_cd,0.0,c
        .ord_loc_cd,- (1.0),0.0,
        request->charge[x].ord_loc_cd),
       c.perf_loc_cd = evaluate(request->charge[x].perf_loc_cd,0.0,c.perf_loc_cd,- (1.0),0.0,
        request->charge[x].perf_loc_cd), c.ord_phys_id = evaluate(request->charge[x].ord_phys_id,0.0,
        c.ord_phys_id,- (1.0),0.0,
        request->charge[x].ord_phys_id), c.perf_phys_id = evaluate(request->charge[x].perf_phys_id,
        0.0,c.perf_phys_id,- (1.0),0.0,
        request->charge[x].perf_phys_id),
       c.verify_phys_id = evaluate(request->charge[x].verify_phys_id,0.0,c.verify_phys_id,- (1.0),0.0,
        request->charge[x].verify_phys_id), c.charge_description = nullcheck(c.charge_description,
        request->charge[x].charge_description,
        IF (trim(request->charge[x].charge_description)="") 0
        ELSE 1
        ENDIF
        ), c.price_sched_id = evaluate(request->charge[x].price_sched_id,0.0,c.price_sched_id,- (1.0),
        0.0,
        request->charge[x].price_sched_id),
       c.item_quantity = evaluate(request->charge[x].item_quantity,0.0,c.item_quantity,- (1.0),0.0,
        request->charge[x].item_quantity), c.item_price = evaluate(request->charge[x].item_price,0.0,
        c.item_price,- (1.0),0.0,
        request->charge[x].item_price), c.item_extended_price = evaluate(request->charge[x].
        item_extended_price,0.0,c.item_extended_price,- (1.0),0.0,
        request->charge[x].item_extended_price),
       c.item_allowable = evaluate(request->charge[x].item_allowable,0.0,c.item_allowable,- (1.0),0.0,
        request->charge[x].item_allowable), c.item_copay = evaluate(request->charge[x].item_copay,0.0,
        c.item_copay,- (1.0),0.0,
        request->charge[x].item_copay), c.charge_type_cd = evaluate(request->charge[x].charge_type_cd,
        0.0,c.charge_type_cd,- (1.0),0.0,
        request->charge[x].charge_type_cd),
       c.research_acct_id = evaluate(request->charge[x].research_acct_id,0.0,c.research_acct_id,- (
        1.0),0.0,
        request->charge[x].research_acct_id), c.suspense_rsn_cd =
       IF (4001989_modify_cd=0) evaluate(request->charge[x].suspense_rsn_cd,0.0,c.suspense_rsn_cd,- (
         1.0),0.0,
         request->charge[x].suspense_rsn_cd)
       ELSE 0.0
       ENDIF
       , c.reason_comment =
       IF (4001989_modify_cd=0) evaluate(request->charge[x].reason_comment,"",c.reason_comment,'""',
         null,
         request->charge[x].reason_comment)
       ELSE ""
       ENDIF
       ,
       c.posted_cd = evaluate(request->charge[x].posted_cd,0.0,c.posted_cd,- (1.0),0.0,
        request->charge[x].posted_cd), c.posted_dt_tm = evaluate(request->charge[x].posted_dt_tm,0.0,
        c.posted_dt_tm,blank_date,null,
        cnvtdatetime(request->charge[x].posted_dt_tm)), c.process_flg = request->charge[x].
       process_flg,
       c.service_dt_tm = evaluate(request->charge[x].service_dt_tm,0.0,c.service_dt_tm,blank_date,
        null,
        cnvtdatetime(request->charge[x].service_dt_tm)), c.activity_dt_tm = evaluate(request->charge[
        x].activity_dt_tm,0.0,c.activity_dt_tm,blank_date,null,
        cnvtdatetime(request->charge[x].activity_dt_tm)), c.beg_effective_dt_tm = evaluate(request->
        charge[x].beg_effective_dt_tm,0.0,c.beg_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->charge[x].beg_effective_dt_tm)),
       c.end_effective_dt_tm = evaluate(request->charge[x].end_effective_dt_tm,0.0,c
        .end_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->charge[x].end_effective_dt_tm)), c.active_ind = nullcheck(c.active_ind,
        request->charge[x].active_ind,
        IF ((request->charge[x].active_ind=false)) 0
        ELSE 1
        ENDIF
        ), c.active_status_cd = nullcheck(c.active_status_cd,request->charge[x].active_status_cd,
        IF ((request->charge[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       c.active_status_prsnl_id = nullcheck(c.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->charge[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), c.active_status_dt_tm = nullcheck(c.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->charge[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), c.abn_status_cd = evaluate(request->charge[x].abn_status_cd,0.0,c.abn_status_cd,- (1.0),
        0.0,
        request->charge[x].abn_status_cd),
       c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->
       updt_id,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c
       .item_deductible_amt = evaluate(request->charge[x].item_deductible_amt,0.0,c
        .item_deductible_amt,- (1.0),0.0,
        request->charge[x].item_deductible_amt),
       c.patient_responsibility_flag = nullcheck(c.patient_responsibility_flag,request->charge[x].
        patient_responsibility_flag,
        IF ((request->charge[x].patient_responsibility_flag=false)) 0
        ELSE 1
        ENDIF
        ), c.health_plan_id = evaluate(healthplanid,0.0,c.health_plan_id,- (1.0),0.0,
        healthplanid), c.fin_class_cd = evaluate(finclasscd,0.0,c.fin_class_cd,- (1.0),0.0,
        finclasscd),
       c.admit_type_cd = evaluate(admittypecd,0.0,c.admit_type_cd,- (1.0),0.0,
        admittypecd), c.original_org_id = evaluate(originalorgid,0.0,c.original_org_id,- (1.0),0.0,
        originalorgid), c.med_service_cd = evaluate(medservicecd,0.0,c.med_service_cd,- (1.0),0.0,
        medservicecd)
      WHERE (c.charge_item_id=request->charge[x].charge_item_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL echo("curqual = 0 in afc_upt_charge")
      SET failed = update_error
      RETURN
     ELSE
      CALL echo("curqual != 0 in afc_upt_charge")
      IF ((validate(reply->charge_qual,- (1)) != - (1)))
       SELECT INTO "nl:"
        c.charge_item_id
        FROM charge c
        WHERE c.charge_item_id IN (request->charge[x].charge_item_id, new_nbr)
        DETAIL
         IF (c.charge_item_id > 0)
          charge_qual_count += 1, stat = alterlist(reply->charge,charge_qual_count), reply->charge[
          charge_qual_count].charge_item_id = c.charge_item_id,
          reply->charge[charge_qual_count].perf_loc_cd = c.perf_loc_cd, reply->charge[
          charge_qual_count].ord_phys_id = c.ord_phys_id, reply->charge[charge_qual_count].
          verify_phys_id = c.verify_phys_id,
          reply->charge[charge_qual_count].research_acct_id = c.research_acct_id, reply->charge[
          charge_qual_count].abn_status_cd = c.abn_status_cd, reply->charge[charge_qual_count].
          suspense_rsn_cd = c.suspense_rsn_cd,
          reply->charge[charge_qual_count].reason_comment = c.reason_comment, reply->charge[
          charge_qual_count].process_flg = c.process_flg, stat = assign(validate(reply->charge[
            charge_qual_count].original_org_id),c.original_org_id),
          CALL echo(concat("process_flg is ",cnvtstring(c.process_flg))),
          CALL echo(concat("charge_item_id ",cnvtstring(c.charge_item_id,17,2)))
         ENDIF
        WITH nocounter
       ;end select
       SET reply->charge_qual = charge_qual_count
       SET stat = alterlist(reply->charge,charge_qual_count)
       CALL echo(concat("reply qual is ",cnvtstring(charge_qual_count)))
       CALL echo(concat("record size: ",cnvtstring(size(reply->charge,5))))
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM charge c
      WHERE (c.charge_item_id=request->charge[x].charge_item_id)
      DETAIL
       temp_charge_act_id = c.charge_event_act_id
      WITH nocounter
     ;end select
     IF ((request->charge[x].ord_phys_id != 0))
      IF ((request->charge[x].ord_phys_id=- (1)))
       SELECT INTO "nl:"
        FROM charge_event_act_prsnl ceap
        WHERE ceap.charge_event_act_id=temp_charge_act_id
         AND ceap.prsnl_type_cd=ord_phys_code
        WITH nocounter
       ;end select
       IF (curqual > 0)
        UPDATE  FROM charge_event_act_prsnl ceap
         SET ceap.active_ind = 0, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
           sysdate),
          ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
          reqinfo->updt_applctx
         WHERE ceap.charge_event_act_id=temp_charge_act_id
          AND ceap.prsnl_type_cd=ord_phys_code
         WITH nocounter
        ;end update
        IF (curqual < 1)
         SET failed = update_error
         RETURN
        ENDIF
       ENDIF
      ELSE
       SET temp_phys_id = 0.0
       SELECT INTO "nl:"
        FROM charge_event_act_prsnl ceap
        WHERE ceap.charge_event_act_id=temp_charge_act_id
         AND ceap.prsnl_type_cd=ord_phys_code
        DETAIL
         temp_phys_id = ceap.prsnl_id
        WITH nocounter
       ;end select
       IF (temp_phys_id=0)
        INSERT  FROM charge_event_act_prsnl ceap
         SET ceap.prsnl_id = request->charge[x].ord_phys_id, ceap.prsnl_type_cd = ord_phys_code, ceap
          .charge_event_act_id = temp_charge_act_id,
          ceap.updt_cnt = 0, ceap.updt_dt_tm = cnvtdatetime(sysdate), ceap.updt_id = reqinfo->updt_id,
          ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual < 1)
         SET failed = insert_error
         RETURN
        ENDIF
       ELSEIF ((temp_phys_id != request->charge[x].ord_phys_id))
        UPDATE  FROM charge_event_act_prsnl ceap
         SET ceap.prsnl_id = request->charge[x].ord_phys_id, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap
          .updt_dt_tm = cnvtdatetime(sysdate),
          ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
          reqinfo->updt_applctx
         WHERE ceap.charge_event_act_id=temp_charge_act_id
          AND ceap.prsnl_type_cd=ord_phys_code
         WITH nocounter
        ;end update
        IF (curqual < 1)
         SET failed = update_error
         RETURN
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((request->charge[x].verify_phys_id != 0))
      IF ((request->charge[x].verify_phys_id=- (1)))
       SELECT INTO "nl:"
        FROM charge_event_act_prsnl ceap
        WHERE ceap.charge_event_act_id=temp_charge_act_id
         AND ceap.prsnl_type_cd=ver_phys_code
        WITH nocounter
       ;end select
       IF (curqual > 0)
        UPDATE  FROM charge_event_act_prsnl ceap
         SET ceap.active_ind = 0, ceap.updt_cnt = (ceap.updt_cnt+ 1), ceap.updt_dt_tm = cnvtdatetime(
           sysdate),
          ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
          reqinfo->updt_applctx
         WHERE ceap.charge_event_act_id=temp_charge_act_id
          AND ceap.prsnl_type_cd=ver_phys_code
         WITH nocounter
        ;end update
        IF (curqual < 1)
         SET failed = update_error
         RETURN
        ENDIF
       ENDIF
      ELSE
       SET temp_phys_id = 0.0
       SELECT INTO "nl:"
        FROM charge_event_act_prsnl ceap
        WHERE ceap.charge_event_act_id=temp_charge_act_id
         AND ceap.prsnl_type_cd=ver_phys_code
        DETAIL
         temp_phys_id = ceap.prsnl_id
        WITH nocounter
       ;end select
       IF (temp_phys_id=0)
        INSERT  FROM charge_event_act_prsnl ceap
         SET ceap.prsnl_id = request->charge[x].verify_phys_id, ceap.prsnl_type_cd = ver_phys_code,
          ceap.charge_event_act_id = temp_charge_act_id,
          ceap.updt_cnt = 0, ceap.updt_dt_tm = cnvtdatetime(sysdate), ceap.updt_id = reqinfo->updt_id,
          ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual < 1)
         SET failed = insert_error
         RETURN
        ENDIF
       ELSEIF ((temp_phys_id != request->charge[x].verify_phys_id))
        UPDATE  FROM charge_event_act_prsnl ceap
         SET ceap.prsnl_id = request->charge[x].verify_phys_id, ceap.updt_cnt = (ceap.updt_cnt+ 1),
          ceap.updt_dt_tm = cnvtdatetime(sysdate),
          ceap.updt_id = reqinfo->updt_id, ceap.updt_task = reqinfo->updt_task, ceap.updt_applctx =
          reqinfo->updt_applctx
         WHERE ceap.charge_event_act_id=temp_charge_act_id
          AND ceap.prsnl_type_cd=ver_phys_code
         WITH nocounter
        ;end update
        IF (curqual < 1)
         SET failed = update_error
         RETURN
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((request->charge[x].abn_status_cd != 0))
      SELECT INTO "nl:"
       FROM charge_event ce,
        charge c
       PLAN (c
        WHERE (c.charge_item_id=request->charge[x].charge_item_id))
        JOIN (ce
        WHERE ce.charge_event_id=c.charge_event_id)
       DETAIL
        temp_abn_status_cd = ce.abn_status_cd, temp_charge_ev_id = c.charge_event_id
       WITH nocounter
      ;end select
      IF ((request->charge[x].abn_status_cd=- (1)))
       IF (temp_abn_status_cd != 0)
        UPDATE  FROM charge_event ce
         SET ce.abn_status_cd = 0
         WHERE ce.charge_event_id=temp_charge_ev_id
         WITH nocounter
        ;end update
       ENDIF
      ELSE
       IF ((temp_abn_status_cd != request->charge[x].abn_status_cd))
        UPDATE  FROM charge_event ce
         SET ce.abn_status_cd = request->charge[x].abn_status_cd
         WHERE ce.charge_event_id=temp_charge_ev_id
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM charge_event ce,
       charge c
      PLAN (c
       WHERE (c.charge_item_id=request->charge[x].charge_item_id))
       JOIN (ce
       WHERE ce.charge_event_id=c.charge_event_id)
      DETAIL
       temp_charge_ev_id2 = c.charge_event_id
      WITH nocounter
     ;end select
     IF ((request->charge[x].research_acct_id=- (1)))
      UPDATE  FROM charge_event ce
       SET ce.research_account_id = 0
       WHERE ce.charge_event_id=temp_charge_ev_id2
       WITH nocounter
      ;end update
     ELSE
      IF ((request->charge[x].research_acct_id > 0))
       UPDATE  FROM charge_event ce
        SET ce.research_account_id = request->charge[x].research_acct_id
        WHERE ce.charge_event_id=temp_charge_ev_id2
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
     SELECT INTO "n1:"
      FROM charge_event_act cea,
       charge c
      PLAN (c
       WHERE (c.charge_item_id=request->charge[x].charge_item_id))
       JOIN (cea
       WHERE cea.charge_event_act_id=c.charge_event_act_id)
      DETAIL
       temp_charge_ev_act_id = c.charge_event_act_id, temp_serv_date = c.service_dt_tm,
       temp_serv_date2 = cea.service_dt_tm
      WITH nocounter
     ;end select
     IF (temp_serv_date != temp_serv_date2)
      UPDATE  FROM charge_event_act cea
       SET cea.service_dt_tm = cnvtdatetime(temp_serv_date)
       WHERE cea.charge_event_act_id=temp_charge_ev_act_id
      ;end update
     ENDIF
     IF ((((request->charge[x].suspense_rsn_cd > 0)) OR (trim(request->charge[x].reason_comment) !=
     ""))
      AND 4001989_modify_cd > 0)
      SET charge_mod_add_count += 1
      SET addchargemodrequest->charge_mod_qual = charge_mod_add_count
      SET stat = alterlist(addchargemodrequest->charge_mod,charge_mod_add_count)
      SET addchargemodrequest->charge_mod[charge_mod_add_count].action_type = "ADD"
      SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_item_id = request->charge[x].
      charge_item_id
      SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_mod_type_cd = 13019_mod_rsn_cd
      SET addchargemodrequest->charge_mod[charge_mod_add_count].field1_id = 4001989_modify_cd
      SET addchargemodrequest->charge_mod[charge_mod_add_count].field6 = "The charge was modified"
      SET addchargemodrequest->charge_mod[charge_mod_add_count].field7 = request->charge[x].
      reason_comment
      SET addchargemodrequest->charge_mod[charge_mod_add_count].field2_id = request->charge[x].
      suspense_rsn_cd
      SET addchargemodrequest->charge_mod[charge_mod_add_count].activity_dt_tm = cnvtdatetime(sysdate
       )
      CALL echorecord(addchargemodrequest)
      SET addchargemodreply->status_data.status = "Z"
      SET action_begin = 1
      SET action_end = addchargemodrequest->charge_mod_qual
      EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodrequest), replace("REPLY",
       addchargemodreply)
      IF ((addchargemodreply->status_data.status="F"))
       SET reply->status_data.status = "F"
       GO TO end_program
      ELSE
       SET reply->status_data.status = "S"
      ENDIF
      CALL echorecord(addchargemodreply)
     ENDIF
     IF (validate(reprocesssettings->no_reprocess,0)=0)
      IF (((ord_phys_change_ind
       AND checktierforordphys(request->charge[x].charge_item_id)) OR (rend_phys_change_ind
       AND checktierforrendphys(request->charge[x].charge_item_id))) )
       IF (validate(debug,- (1)) > 0)
        CALL echo("Charge should be reprocessed, looking for existing charge event")
       ENDIF
       DECLARE chargeeventfound = i2 WITH protect, noconstant(false)
       FOR (idx2 = 1 TO reprocesschargelist->charge_event_qual)
         IF ((reprocesschargelist->charge_event[idx2].charge_event_id=request->charge[x].
         charge_event_id))
          IF (validate(debug,- (1)) > 0)
           CALL echo(build2(
             "Existing charge event found in reprocess record, adding charge to event: ",
             reprocesschargelist->charge_event[idx2].charge_event_id))
          ENDIF
          SET chargeeventfound = true
          SET reprocesschargelist->charge_event[idx2].charge_qual += 1
          SET stat = alterlist(reprocesschargelist->charge_event[idx2].charge,reprocesschargelist->
           charge_event[idx2].charge_qual)
          SET reprocesschargelist->charge_event[idx2].charge[reprocesschargelist->charge_event[idx2].
          charge_qual].charge_item_id = request->charge[x].charge_item_id
          SET idx2 = (reprocesschargelist->charge_event_qual+ 1)
         ENDIF
       ENDFOR
       IF (chargeeventfound=false)
        IF (validate(debug,- (1)) > 0)
         CALL echo("No charge event found in reprocess record, adding charge to new charge event")
        ENDIF
        SET reprocesschargelist->charge_event_qual += 1
        SET stat = alterlist(reprocesschargelist->charge_event,reprocesschargelist->charge_event_qual
         )
        SET reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].charge_qual +=
        1
        SET stat = alterlist(reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual
         ].charge,reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].
         charge_qual)
        SET reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].charge[
        reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].charge_qual].
        charge_item_id = request->charge[x].charge_item_id
        IF (validate(request->charge[x].charge_event_id,- (1)) <= 0)
         SELECT INTO "nl:"
          FROM charge c
          WHERE (c.charge_item_id=request->charge[x].charge_item_id)
          DETAIL
           reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].charge_event_id
            = c.charge_event_id
          WITH nocounter
         ;end select
        ELSE
         SET reprocesschargelist->charge_event[reprocesschargelist->charge_event_qual].
         charge_event_id = request->charge[x].charge_event_id
        ENDIF
       ENDIF
       UPDATE  FROM charge c
        SET c.server_process_flag = 0, c.process_flg = 1
        WHERE (c.charge_item_id=request->charge[x].charge_item_id)
       ;end update
       IF ( NOT (creditrelatedaddonsbeforereprocessing(request->charge[x].charge_item_id,validate(
         request->charge[x].reason_comment,""),validate(request->charge[x].suspense_rsn_cd,0.0))))
        CALL echo(concat("creditRelatedAddonsBeforeReprocessing returned a failure status"))
        SET failed = true
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
        GO TO check_error
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF ((reprocesschargelist->charge_event_qual > 0)
    AND failed=false)
    IF (validate(debug,- (1)) > 0)
     CALL echo("Reprocessing charges:")
     CALL echorecord(reprocesschargelist)
    ENDIF
    DECLARE hreq = i4
    DECLARE happrelease = i4
    DECLARE htaskrelease = i4
    DECLARE hsteprelease = i4
    DECLARE srvstat = i4
    DECLARE iret = i4
    DECLARE hprocess = i4
    DECLARE hcharge = i4
    DECLARE releaseappid = i4 WITH protect, constant(951020)
    DECLARE releasetaskid = i4 WITH protect, constant(951020)
    DECLARE releasereqid = i4 WITH protect, constant(951359)
    DECLARE nreprocessloop = i4 WITH noconstant(0)
    DECLARE nreprocessloop2 = i4 WITH noconstant(0)
    CALL impersonatepersonnelinfo(1)
    SET iret = uar_crmbeginapp(releaseappid,happrelease)
    IF (iret=0)
     SET iret = uar_crmbegintask(happrelease,releasetaskid,htaskrelease)
     IF (iret=0)
      SET iret = uar_crmbeginreq(htaskrelease,"",releasereqid,hsteprelease)
      IF (iret=0)
       SET hreq = uar_crmgetrequest(hsteprelease)
       SET srvstat = uar_srvsetshort(hreq,"charge_event_qual",reprocesschargelist->charge_event_qual)
       FOR (nreprocessloop = 1 TO reprocesschargelist->charge_event_qual)
         SET hprocess = uar_srvadditem(hreq,"process_event")
         SET srvstat = uar_srvsetdouble(hprocess,"charge_event_id",reprocesschargelist->charge_event[
          nreprocessloop].charge_event_id)
         SET srvstat = uar_srvsetshort(hprocess,"charge_item_qual",reprocesschargelist->charge_event[
          nreprocessloop].charge_qual)
         FOR (nreprocessloop2 = 1 TO reprocesschargelist->charge_event[nreprocessloop].charge_qual)
          SET hcharge = uar_srvadditem(hprocess,"charge_item")
          SET srvstat = uar_srvsetdouble(hcharge,"charge_item_id",reprocesschargelist->charge_event[
           nreprocessloop].charge[nreprocessloop2].charge_item_id)
         ENDFOR
       ENDFOR
       COMMIT
       SET iret = uar_crmperform(hsteprelease)
       IF (iret != 0)
        CALL echo(concat("CRM perform failed:",build(iret)))
        SET failed = true
        SET reply->status_data.subeventstatus[1].operationname = "CRM_PERF"
       ELSE
        CALL echo("crmperform success")
       ENDIF
       CALL uar_crmendreq(hsteprelease)
      ELSE
       CALL echo(concat("Begin request unsuccessful: ",build(iret)))
       SET failed = true
       SET reply->status_data.subeventstatus[1].operationname = "BEG_REQ"
      ENDIF
      CALL uar_crmendtask(htaskrelease)
     ELSE
      CALL echo(concat("Unsuccessful begin task: ",build(iret)))
      SET failed = true
      SET reply->status_data.subeventstatus[1].operationname = "BEG_TASK"
     ENDIF
     CALL uar_crmendapp(happrelease)
    ELSE
     CALL echo(concat("Begin app failed with code: ",build(iret)))
     SET failed = true
     SET reply->status_data.subeventstatus[1].operationname = "BEG_APP"
    ENDIF
    IF (validate(debug,- (1)) > 0)
     CALL echo("End charge reprocessing")
    ENDIF
   ENDIF
   CALL echo("Leaving the UPT_CHARGE subroutine")
 END ;Subroutine
#end_program
END GO
