CREATE PROGRAM afc_add_credit:dba
 SET afc_add_credit = "CHARGSRV-14536.FT.041"
 RECORD reply(
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
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 provider_specialty_disp = c40
     2 provider_specialty_desc = c60
     2 provider_specialty_mean = c12
     2 patient_responsibility_flag = i2
     2 charge_mod_qual = i4
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
       3 code1_cd = f8
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
 )
 RECORD chargerequest(
   1 charge_item_id = f8
 )
 RECORD chargereply(
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
       3 code1_cd = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 item_price_adj_amt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD unique_encounters(
   1 encntr[*]
     2 encntr_id = f8
 )
 RECORD dequeue_request(
   1 pft_queue_event_cd = f8
   1 entity[1]
     2 pft_entity_type_cd = f8
     2 entity_id = f8
 )
 RECORD addchargerequest(
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
     2 old_process_flg = i4
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 item_price_adj_amt = f8
 )
 RECORD addchargereply(
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
 RECORD addchargemodrequest(
   1 charge_mod_qual = i4
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
     2 code1_cd = f8
   1 skip_charge_event_mod_ind = i2
 )
 RECORD addchargemodreply(
   1 charge_mod_qual = i4
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
 CALL echo("Begin including PFT_NT_GLOBAL_SUBS.INC, version [694705.005]")
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
 IF ( NOT (validate(max_lock_attempts)))
  DECLARE max_lock_attempts = i4 WITH constant(4)
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  SUBROUTINE (getcodevalue(pcodeset=i4,pmeaning=vc,poptionflag=i2) =f8)
    DECLARE lcodevalue = f8 WITH private, noconstant(0.0)
    SET lcodevalue = uar_get_code_by("MEANING",value(pcodeset),value(pmeaning))
    IF (lcodevalue > 0.0)
     RETURN(lcodevalue)
    ELSE
     IF (poptionflag=1)
      CALL logmessage("getCodeValue",build("Error loading code value from code set [",pcodeset,
        "] with meaning [",pmeaning,"]"),log_error)
      GO TO handle_error
     ELSEIF (poptionflag=2)
      CALL setdetails("getCodeValue",build("Error loading code value from codeset [",pcodeset,
        "] with meaning [",pmeaning,"]"))
      GO TO handle_error
     ELSE
      RETURN(0.0)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(logmsg,char(128))=char(128))
  SUBROUTINE (logmsg(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE llevel = vc WITH private, noconstant("")
    CASE (plevel)
     OF log_error:
      SET llevel = "ERROR"
     OF log_warning:
      SET llevel = "WARNING"
     OF log_audit:
      SET llevel = "AUDIT"
     OF log_info:
      SET llevel = "INFO"
     ELSE
      SET llevel = "DEBUG"
    ENDCASE
    IF (psubroutine > "")
     CALL echo(concat(llevel," : ",curprog," : ",psubroutine,
       "() : ",pmessage))
    ELSE
     CALL echo(concat(llevel," : ",curprog," : ",pmessage))
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setdetails,char(128))=char(128))
  SUBROUTINE (setdetails(psubroutine=vc,pmessage=vc) =null)
    CALL logmsg(psubroutine,pmessage,log_error)
    IF (validate(reply->error_prog))
     SET reply->error_prog = curprog
    ENDIF
    IF (validate(reply->error_sub))
     SET reply->error_sub = psubroutine
    ENDIF
    IF (validate(reply->error_msg))
     SET reply->error_msg = pmessage
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(lockencounter,char(128))=char(128))
  SUBROUTINE (lockencounter(ppftencntrid=f8) =i2)
    DECLARE lindex = i4 WITH private, noconstant(0)
    DECLARE llockind = i2 WITH private, noconstant(0)
    WHILE (lindex < max_lock_attempts
     AND llockind=false)
     SELECT INTO "nl:"
      FROM pft_encntr pe
      WHERE pe.pft_encntr_id=ppftencntrid
      WITH forupdate(pe)
     ;end select
     IF (curqual=0)
      SET lindex += 1
      IF (lindex < max_lock_attempts)
       CALL logmessage("lockEncounter","Failed to lock encounter, waiting 2 seconds...",log_debug)
       CALL pause(2)
      ENDIF
     ELSE
      CALL logmessage("lockEncounter","Successfully locked encounter",log_debug)
      SET llockind = true
     ENDIF
    ENDWHILE
    RETURN(llockind)
  END ;Subroutine
 ENDIF
 IF (validate(lockaccount,char(128))=char(128))
  SUBROUTINE (lockaccount(paccountid=f8) =i2)
    DECLARE lindex = i4 WITH private, noconstant(0)
    DECLARE llockind = i2 WITH private, noconstant(0)
    WHILE (lindex < max_lock_attempts
     AND llockind=false)
     SELECT INTO "nl:"
      FROM account a
      WHERE a.acct_id=paccountid
      WITH forupdate(a)
     ;end select
     IF (curqual=0)
      SET lindex += 1
      IF (lindex < max_lock_attempts)
       CALL logmessage("lockAccount","Failed to lock account, waiting 2 seconds...",log_debug)
       CALL pause(2)
      ENDIF
     ELSE
      CALL logmessage("lockAccount","Successfully locked account",log_debug)
      SET llockind = true
     ENDIF
    ENDWHILE
    RETURN(llockind)
  END ;Subroutine
 ENDIF
 IF (validate(getaccountcreationlock,char(128))=char(128))
  SUBROUTINE (getaccountcreationlock(dummy_var=i4) =i2)
    DECLARE lindex = i4 WITH private, noconstant(0)
    DECLARE llockind = i2 WITH private, noconstant(0)
    SELECT INTO "nl:"
     FROM dm_info di
     PLAN (di
      WHERE di.info_domain="PROFIT - SERIALIZED ACCOUNT CREATION LOCK")
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM dm_info d
      SET d.info_char = null, d.info_date = null, d.info_domain =
       "PROFIT - SERIALIZED ACCOUNT CREATION LOCK",
       d.info_long_id = 0.0, d.info_name = "PROFIT - SERIALIZED ACCOUNT CREATION LOCK", d.info_number
        = null,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate),
       d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL logmessage("getAccountCreationLock","Failed to create DM_INFO record",log_error)
      RETURN(false)
     ENDIF
    ENDIF
    WHILE (lindex < max_lock_attempts
     AND llockind=false)
     SELECT INTO "nl:"
      FROM dm_info di
      PLAN (di
       WHERE di.info_domain="PROFIT - SERIALIZED ACCOUNT CREATION LOCK"
        AND di.info_name="PROFIT - SERIALIZED ACCOUNT CREATION LOCK")
      WITH forupdate(di)
     ;end select
     IF (curqual=0)
      SET lindex += 1
      IF (lindex < max_lock_attempts)
       CALL logmessage("getAccountCreationLock",
        "Failed to obtain guarantor account creation lock, waiting 2 seconds...",log_debug)
       CALL pause(2)
      ENDIF
     ELSE
      CALL logmessage("getAccountCreationLock",
       "Successfully obtained guarantor account creation lock",log_debug)
      SET llockind = true
     ENDIF
    ENDWHILE
    RETURN(llockind)
  END ;Subroutine
 ENDIF
 IF (validate(getguarantoraccountcreationlock,char(128))=char(128))
  SUBROUTINE (getguarantoraccountcreationlock(pguarantorid1=f8,pguarorgid=f8,pbillingentityid=f8) =i2
   )
    DECLARE lindex = i4 WITH private, noconstant(0)
    DECLARE llockind = i2 WITH private, noconstant(0)
    DECLARE acctcnt = i4 WITH protect, noconstant(0)
    RECORD relatedaccounts(
      1 accounts[*]
        2 acctid = f8
    ) WITH protect
    IF ( NOT (validate(cs24269_history_cd)))
     DECLARE cs24269_history_cd = f8 WITH protect, constant(getcodevalue(24269,"HISTORY",0))
    ENDIF
    IF ( NOT (validate(cs351_def_guar_cd)))
     DECLARE cs351_def_guar_cd = f8 WITH protect, constant(getcodevalue(351,"DEFGUAR",0))
    ENDIF
    IF ( NOT (validate(cs352_eor_guar_cd)))
     DECLARE cs352_eor_guar_cd = f8 WITH protect, constant(getcodevalue(352,"GUARANTOR",0))
    ENDIF
    IF ( NOT (validate(cs18736_ar_cd)))
     DECLARE cs18736_ar_cd = f8 WITH protect, constant(getcodevalue(18736,"A/R",1))
    ENDIF
    IF ( NOT (validate(cs20849_patient_cd)))
     DECLARE cs20849_patient_cd = f8 WITH protect, constant(getcodevalue(20849,"PATIENT",1))
    ENDIF
    IF (pguarantorid1 > 0.0)
     SELECT INTO "nl:"
      FROM encntr_person_reltn epr,
       encounter e,
       pft_encntr pe,
       account a
      PLAN (epr
       WHERE epr.related_person_id=pguarantorid1
        AND epr.active_ind=true
        AND epr.person_reltn_type_cd=cs351_def_guar_cd)
       JOIN (e
       WHERE e.encntr_id=epr.encntr_id
        AND e.active_ind=true)
       JOIN (pe
       WHERE pe.encntr_id=e.encntr_id
        AND pe.active_ind=true
        AND pe.pft_encntr_status_cd != cs24269_history_cd)
       JOIN (a
       WHERE a.acct_id=pe.acct_id
        AND a.active_ind=true
        AND a.acct_type_cd=cs18736_ar_cd
        AND a.acct_sub_type_cd=cs20849_patient_cd
        AND a.billing_entity_id=pbillingentityid)
      ORDER BY a.acct_id
      HEAD a.acct_id
       acctcnt += 1, stat = alterlist(relatedaccounts->accounts,acctcnt), relatedaccounts->accounts[
       acctcnt].acctid = a.acct_id
      WITH nocounter
     ;end select
    ELSEIF (pguarorgid > 0.0)
     SELECT INTO "nl:"
      FROM encntr_org_reltn eor,
       encounter e,
       pft_encntr pe,
       account a
      PLAN (eor
       WHERE eor.organization_id=pguarorgid
        AND eor.active_ind=true
        AND eor.encntr_org_reltn_cd=cs352_eor_guar_cd)
       JOIN (e
       WHERE e.encntr_id=eor.encntr_id
        AND e.active_ind=true)
       JOIN (pe
       WHERE pe.encntr_id=e.encntr_id
        AND pe.active_ind=true
        AND pe.pft_encntr_status_cd != cs24269_history_cd)
       JOIN (a
       WHERE a.acct_id=pe.acct_id
        AND a.active_ind=true
        AND a.acct_type_cd=cs18736_ar_cd
        AND a.acct_sub_type_cd=cs20849_patient_cd
        AND a.billing_entity_id=pbillingentityid)
      ORDER BY a.acct_id
      HEAD a.acct_id
       acctcnt += 1, stat = alterlist(relatedaccounts->accounts,acctcnt), relatedaccounts->accounts[
       acctcnt].acctid = a.acct_id
      WITH nocounter
     ;end select
    ENDIF
    IF (size(relatedaccounts->accounts,5)=0)
     CALL logmessage("getGuarantorAccountCreationLock","No accounts need to be locked",log_debug)
     RETURN(true)
    ENDIF
    WHILE (lindex < max_lock_attempts
     AND llockind=false)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(relatedaccounts->accounts,5))),
       account a
      PLAN (d1)
       JOIN (a
       WHERE (a.acct_id=relatedaccounts->accounts[d1.seq].acctid))
      WITH forupdate(a)
     ;end select
     IF (curqual=0)
      SET lindex += 1
      IF (lindex < max_lock_attempts)
       CALL logmessage("getGuarantorAccountCreationLock",
        "Failed to obtain account creation lock, waiting 2 seconds...",log_debug)
       CALL pause(2)
      ENDIF
     ELSE
      CALL logmessage("getGuarantorAccountCreationLock","Successfully obtained account creation lock",
       log_debug)
      SET llockind = true
     ENDIF
    ENDWHILE
    IF (llockind=false)
     CALL logmessage("getGuarantorAccountCreationLock",
      "Failed to get guarantor account creation lock",log_error)
    ENDIF
    RETURN(llockind)
  END ;Subroutine
 ENDIF
 IF (validate(isoffsettingcharge,char(128))=char(128))
  SUBROUTINE (isoffsettingcharge(pencntrid=f8,pchargeitemid=f8) =i2)
    DECLARE encntrcombinedetid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM encntr_combine ec,
      encntr_combine_det ecd
     PLAN (ec
      WHERE ec.from_encntr_id=pencntrid)
      JOIN (ecd
      WHERE ecd.encntr_combine_id=ec.encntr_combine_id
       AND ecd.entity_id=pchargeitemid
       AND ecd.entity_name="CHARGE"
       AND ecd.combine_action_cd=cs327_add_cd
       AND ecd.combine_desc_cd IN (cs14200_offsetdebit_cd, cs14200_offsetcredit_cd))
     DETAIL
      encntrcombinedetid = ecd.encntr_combine_det_id
     WITH nocounter
    ;end select
    IF (encntrcombinedetid > 0.0)
     CALL logmessage("isOffsettingCharge","Offsetting charge created by a clinical encounter combine",
      log_debug)
     RETURN(true)
    ENDIF
    CALL logmessage("isOffsettingCharge","Exiting...",log_debug)
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(lockcharge,char(128))=char(128))
  SUBROUTINE (lockcharge(pchargeitemid=f8) =i2)
    DECLARE lindex = i4 WITH private, noconstant(0)
    DECLARE llockind = i2 WITH private, noconstant(0)
    WHILE (lindex < max_lock_attempts
     AND llockind=false)
     SELECT INTO "nl:"
      FROM charge c
      WHERE c.charge_item_id=pchargeitemid
      WITH forupdate(c)
     ;end select
     IF (curqual=0)
      SET lindex += 1
      IF (lindex < max_lock_attempts)
       CALL logmessage("lockCharge","Failed to lock charge, waiting 2 seconds...",log_debug)
       CALL pause(2)
      ENDIF
     ELSE
      CALL logmessage("lockCharge","Successfully locked charge",log_debug)
      SET llockind = true
     ENDIF
    ENDWHILE
    RETURN(llockind)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(cs327_add_cd)))
  DECLARE cs327_add_cd = f8 WITH protect, constant(getcodevalue(327,"ADD",1))
 ENDIF
 IF ( NOT (validate(cs14200_offsetcredit_cd)))
  DECLARE cs14200_offsetcredit_cd = f8 WITH protect, constant(getcodevalue(14200,"OFFSETCREDIT",1))
 ENDIF
 IF ( NOT (validate(cs14200_offsetdebit_cd)))
  DECLARE cs14200_offsetdebit_cd = f8 WITH protect, constant(getcodevalue(14200,"OFFSETDEBIT",1))
 ENDIF
 CALL echo("End including PFT_NT_GLOBAL_SUBS.INC")
 DECLARE action_begin = i4 WITH public, noconstant(0)
 DECLARE action_end = i4 WITH public, noconstant(0)
 DECLARE new_charge_id = f8 WITH public, noconstant(0.0)
 DECLARE original_charge_count = i4 WITH public, noconstant(0)
 DECLARE encntr_counter = i4 WITH public, noconstant(0)
 DECLARE dequeue_ind = i2 WITH public, noconstant(0)
 DECLARE dcorspactivityid = f8 WITH public, noconstant(0.0)
 DECLARE dchargeitemid = f8 WITH public, noconstant(0.0)
 DECLARE charge_add_count = i4 WITH public, noconstant(0)
 DECLARE charge_mod_add_count = i4 WITH public, noconstant(0)
 DECLARE ischargelocked = i2 WITH protect, noconstant(true)
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
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
 ENDIF
 SET reply->status_data.status = "F"
 SET action_begin = 1
 SET action_end = request->charge_qual
 DECLARE active_code = f8
 DECLARE credited_charge_type_cd = f8
 DECLARE e_pftptacct = f8
 DECLARE e_pftcltbill = f8
 DECLARE e_pftcltacct = f8
 DECLARE queue_event_cd = f8
 DECLARE entity_type_cd = f8
 DECLARE 13019_mod_rsn_cd = f8
 DECLARE 4001989_credit_cd = f8
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_code)
 SET stat = uar_get_meaning_by_codeset(13028,"CR",1,credited_charge_type_cd)
 SET stat = uar_get_meaning_by_codeset(22449,"PFTPTACCT",1,e_pftptacct)
 SET stat = uar_get_meaning_by_codeset(22449,"PFTCLTBILL",1,e_pftcltbill)
 SET stat = uar_get_meaning_by_codeset(22449,"PFTCLTACCT",1,e_pftcltacct)
 SET stat = uar_get_meaning_by_codeset(29322,"WRITOFCREDIT",1,queue_event_cd)
 SET stat = uar_get_meaning_by_codeset(29320,"CLAIM",1,entity_type_cd)
 SET stat = uar_get_meaning_by_codeset(13019,"MOD RSN",1,13019_mod_rsn_cd)
 SET stat = uar_get_meaning_by_codeset(4001989,"CREDIT",1,4001989_credit_cd)
 CALL echo(build("ACTIVE_CD: ",active_code))
 CALL echo(build("CREDITED_CHARGE_TYPE_CD: ",credited_charge_type_cd))
 CALL echo(build("E_PFTPTACCT: ",e_pftptacct))
 CALL echo(build("E_PFTCLTBILL: ",e_pftcltbill))
 CALL echo(build("E_PFTCLTACCT: ",e_pftcltacct))
 CALL echo(build("QUEUE_EVENT_CD: ",queue_event_cd))
 CALL echo(build("ENTITY_TYPE_CD: ",entity_type_cd))
 CALL echo(build("13019_MOD_RSN_CD: ",13019_mod_rsn_cd))
 CALL echo(build("4001989_CREDIT_CD: ",4001989_credit_cd))
 FOR (ccount = action_begin TO action_end)
   CALL echo(ccount)
   SET chargerequest->charge_item_id = request->charge[ccount].charge_item_id
   SET ischargelocked = true
   IF ( NOT (lockcharge(chargerequest->charge_item_id)))
    SET ischargelocked = false
   ENDIF
   IF (ischargelocked)
    CALL echo("Getting Charge Information")
    EXECUTE afc_charge_find  WITH replace("REQUEST","CHARGEREQUEST"), replace("REPLY","CHARGEREPLY")
    CALL echorecord(chargereply)
    IF ((chargereply->charge_item_count > 0))
     IF ((chargereply->charge_items[1].process_flg != 10))
      CALL echo("Adding Credit Charge To List")
      SELECT INTO "nl:"
       nextchargeseq = seq(charge_event_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_charge_id = cnvtreal(nextchargeseq)
       WITH format, counter
      ;end select
      IF (curqual=0)
       GO TO end_program
      ENDIF
      SET charge_add_count += 1
      SET stat = alterlist(addchargerequest->objarray,charge_add_count)
      SET addchargerequest->objarray[charge_add_count].charge_item_id = new_charge_id
      SET addchargerequest->objarray[charge_add_count].parent_charge_item_id = chargereply->
      charge_items[1].charge_item_id
      SET addchargerequest->objarray[charge_add_count].offset_charge_item_id = chargereply->
      charge_items[1].charge_item_id
      SET addchargerequest->objarray[charge_add_count].charge_type_cd = credited_charge_type_cd
      SET addchargerequest->objarray[charge_add_count].item_quantity = chargereply->charge_items[1].
      item_quantity
      SET addchargerequest->objarray[charge_add_count].item_price = - ((1 * chargereply->
      charge_items[1].item_price))
      SET addchargerequest->objarray[charge_add_count].item_extended_price = - ((1 * chargereply->
      charge_items[1].item_extended_price))
      SET addchargerequest->objarray[charge_add_count].credited_dt_tm = cnvtdatetime(sysdate)
      SET addchargerequest->objarray[charge_add_count].charge_event_act_id = chargereply->
      charge_items[1].charge_event_act_id
      SET addchargerequest->objarray[charge_add_count].charge_event_id = chargereply->charge_items[1]
      .charge_event_id
      SET addchargerequest->objarray[charge_add_count].bill_item_id = chargereply->charge_items[1].
      bill_item_id
      SET addchargerequest->objarray[charge_add_count].order_id = chargereply->charge_items[1].
      order_id
      SET addchargerequest->objarray[charge_add_count].encntr_id = chargereply->charge_items[1].
      encntr_id
      SET addchargerequest->objarray[charge_add_count].person_id = chargereply->charge_items[1].
      person_id
      SET addchargerequest->objarray[charge_add_count].payor_id = chargereply->charge_items[1].
      payor_id
      SET addchargerequest->objarray[charge_add_count].ord_loc_cd = chargereply->charge_items[1].
      ord_loc_cd
      SET addchargerequest->objarray[charge_add_count].perf_loc_cd = chargereply->charge_items[1].
      perf_loc_cd
      SET addchargerequest->objarray[charge_add_count].ord_phys_id = chargereply->charge_items[1].
      ord_phys_id
      SET addchargerequest->objarray[charge_add_count].perf_phys_id = chargereply->charge_items[1].
      perf_phys_id
      SET addchargerequest->objarray[charge_add_count].charge_description = chargereply->
      charge_items[1].charge_description
      SET addchargerequest->objarray[charge_add_count].price_sched_id = chargereply->charge_items[1].
      price_sched_id
      SET addchargerequest->objarray[charge_add_count].item_allowable = chargereply->charge_items[1].
      item_allowable
      SET addchargerequest->objarray[charge_add_count].item_copay = chargereply->charge_items[1].
      item_copay
      SET addchargerequest->objarray[charge_add_count].research_acct_id = chargereply->charge_items[1
      ].research_acct_id
      IF (4001989_credit_cd=0)
       SET addchargerequest->objarray[charge_add_count].suspense_rsn_cd = request->charge[ccount].
       suspense_rsn_cd
       SET addchargerequest->objarray[charge_add_count].reason_comment = request->charge[ccount].
       reason_comment
      ENDIF
      SET addchargerequest->objarray[charge_add_count].posted_cd = chargereply->charge_items[1].
      posted_cd
      SET addchargerequest->objarray[charge_add_count].service_dt_tm = chargereply->charge_items[1].
      service_dt_tm
      SET addchargerequest->objarray[charge_add_count].activity_dt_tm = chargereply->charge_items[1].
      activity_dt_tm
      SET addchargerequest->objarray[charge_add_count].updt_cnt = chargereply->charge_items[1].
      updt_cnt
      SET addchargerequest->objarray[charge_add_count].active_ind = chargereply->charge_items[1].
      active_ind
      SET addchargerequest->objarray[charge_add_count].active_status_cd = chargereply->charge_items[1
      ].active_status_cd
      SET addchargerequest->objarray[charge_add_count].beg_effective_dt_tm = chargereply->
      charge_items[1].beg_effective_dt_tm
      SET addchargerequest->objarray[charge_add_count].end_effective_dt_tm = chargereply->
      charge_items[1].end_effective_dt_tm
      SET addchargerequest->objarray[charge_add_count].adjusted_dt_tm = chargereply->charge_items[1].
      adjusted_dt_tm
      SET addchargerequest->objarray[charge_add_count].interface_file_id = chargereply->charge_items[
      1].interface_file_id
      SET addchargerequest->objarray[charge_add_count].tier_group_cd = chargereply->charge_items[1].
      tier_group_cd
      SET addchargerequest->objarray[charge_add_count].def_bill_item_id = chargereply->charge_items[1
      ].def_bill_item_id
      SET addchargerequest->objarray[charge_add_count].verify_phys_id = chargereply->charge_items[1].
      verify_phys_id
      SET addchargerequest->objarray[charge_add_count].gross_price = chargereply->charge_items[1].
      gross_price
      SET addchargerequest->objarray[charge_add_count].discount_amount = chargereply->charge_items[1]
      .discount_amount
      SET addchargerequest->objarray[charge_add_count].manual_ind = chargereply->charge_items[1].
      manual_ind
      SET addchargerequest->objarray[charge_add_count].combine_ind = chargereply->charge_items[1].
      combine_ind
      SET addchargerequest->objarray[charge_add_count].activity_type_cd = chargereply->charge_items[1
      ].activity_type_cd
      SET addchargerequest->objarray[charge_add_count].activity_sub_type_cd = chargereply->
      charge_items[1].activity_sub_type_cd
      SET addchargerequest->objarray[charge_add_count].provider_specialty_cd = chargereply->
      charge_items[1].provider_specialty_cd
      SET addchargerequest->objarray[charge_add_count].admit_type_cd = chargereply->charge_items[1].
      admit_type_cd
      SET addchargerequest->objarray[charge_add_count].bundle_id = chargereply->charge_items[1].
      bundle_id
      SET addchargerequest->objarray[charge_add_count].department_cd = chargereply->charge_items[1].
      department_cd
      SET addchargerequest->objarray[charge_add_count].institution_cd = chargereply->charge_items[1].
      institution_cd
      SET addchargerequest->objarray[charge_add_count].level5_cd = chargereply->charge_items[1].
      level5_cd
      SET addchargerequest->objarray[charge_add_count].med_service_cd = chargereply->charge_items[1].
      med_service_cd
      SET addchargerequest->objarray[charge_add_count].section_cd = chargereply->charge_items[1].
      section_cd
      SET addchargerequest->objarray[charge_add_count].subsection_cd = chargereply->charge_items[1].
      subsection_cd
      SET addchargerequest->objarray[charge_add_count].abn_status_cd = chargereply->charge_items[1].
      abn_status_cd
      SET addchargerequest->objarray[charge_add_count].cost_center_cd = chargereply->charge_items[1].
      cost_center_cd
      SET addchargerequest->objarray[charge_add_count].inst_fin_nbr = chargereply->charge_items[1].
      inst_fin_nbr
      SET addchargerequest->objarray[charge_add_count].fin_class_cd = chargereply->charge_items[1].
      fin_class_cd
      SET addchargerequest->objarray[charge_add_count].health_plan_id = chargereply->charge_items[1].
      health_plan_id
      SET addchargerequest->objarray[charge_add_count].item_interval_id = chargereply->charge_items[1
      ].item_interval_id
      SET addchargerequest->objarray[charge_add_count].item_list_price = chargereply->charge_items[1]
      .item_list_price
      SET addchargerequest->objarray[charge_add_count].item_reimbursement = chargereply->
      charge_items[1].item_reimbursement
      SET addchargerequest->objarray[charge_add_count].list_price_sched_id = chargereply->
      charge_items[1].list_price_sched_id
      SET addchargerequest->objarray[charge_add_count].payor_type_cd = chargereply->charge_items[1].
      payor_type_cd
      SET addchargerequest->objarray[charge_add_count].epsdt_ind = chargereply->charge_items[1].
      epsdt_ind
      SET addchargerequest->objarray[charge_add_count].ref_phys_id = chargereply->charge_items[1].
      ref_phys_id
      SET addchargerequest->objarray[charge_add_count].start_dt_tm = chargereply->charge_items[1].
      start_dt_tm
      SET addchargerequest->objarray[charge_add_count].stop_dt_tm = chargereply->charge_items[1].
      stop_dt_tm
      SET addchargerequest->objarray[charge_add_count].alpha_nomen_id = chargereply->charge_items[1].
      alpha_nomen_id
      SET addchargerequest->objarray[charge_add_count].server_process_flag = chargereply->
      charge_items[1].server_process_flag
      SET addchargerequest->objarray[charge_add_count].item_deductible_amt = chargereply->
      charge_items[1].item_deductible_amt
      SET addchargerequest->objarray[charge_add_count].patient_responsibility_flag = chargereply->
      charge_items[1].patient_responsibility_flag
      SET addchargerequest->objarray[charge_add_count].item_price_adj_amt = chargereply->
      charge_items[1].item_price_adj_amt
      SET addchargerequest->objarray[charge_add_count].old_process_flg = chargereply->charge_items[1]
      .process_flg
      IF ((chargereply->charge_items[1].process_flg != 999)
       AND (chargereply->charge_items[1].process_flg != 100)
       AND (chargereply->charge_items[1].process_flg != 6))
       SET addchargerequest->objarray[charge_add_count].process_flg = 10
      ELSE
       SET addchargerequest->objarray[charge_add_count].process_flg = 0
      ENDIF
      SET stat = alterlist(reply->charge,ccount)
      SET reply->charge[ccount].charge_item_id = new_charge_id
      SET reply->charge_qual = ccount
      CALL echo("Add Charge Mods to List")
      FOR (z = 1 TO chargereply->charge_items[1].charge_mod_count)
        SET charge_mod_add_count += 1
        SET stat = alterlist(addchargemodrequest->charge_mod,charge_mod_add_count)
        SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_item_id = new_charge_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_mod_type_cd = chargereply->
        charge_items[1].charge_mods[z].charge_mod_type_cd
        SET addchargemodrequest->charge_mod[charge_mod_add_count].action_type = "ADD"
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field1_id = chargereply->
        charge_items[1].charge_mods[z].field1_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field2_id = chargereply->
        charge_items[1].charge_mods[z].field2_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field3_id = chargereply->
        charge_items[1].charge_mods[z].field3_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field4_id = chargereply->
        charge_items[1].charge_mods[z].field4_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field5_id = chargereply->
        charge_items[1].charge_mods[z].field5_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field1 = chargereply->charge_items[
        1].charge_mods[z].field1
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field2 = chargereply->charge_items[
        1].charge_mods[z].field2
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field3 = chargereply->charge_items[
        1].charge_mods[z].field3
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field4 = chargereply->charge_items[
        1].charge_mods[z].field4
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field5 = chargereply->charge_items[
        1].charge_mods[z].field5
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field6 = chargereply->charge_items[
        1].charge_mods[z].field6
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field7 = chargereply->charge_items[
        1].charge_mods[z].field7
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field8 = chargereply->charge_items[
        1].charge_mods[z].field8
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field9 = chargereply->charge_items[
        1].charge_mods[z].field9
        SET addchargemodrequest->charge_mod[charge_mod_add_count].field10 = chargereply->
        charge_items[1].charge_mods[z].field10
        IF (validate(addchargemodrequest->charge_mod[charge_mod_add_count].code1_cd))
         SET addchargemodrequest->charge_mod[charge_mod_add_count].code1_cd = chargereply->
         charge_items[1].charge_mods[z].code1_cd
        ENDIF
        SET addchargemodrequest->charge_mod[charge_mod_add_count].nomen_id = chargereply->
        charge_items[1].charge_mods[z].nomen_id
        SET addchargemodrequest->charge_mod[charge_mod_add_count].cm1_nbr = chargereply->
        charge_items[1].charge_mods[z].cm1_nbr
        SET addchargemodrequest->charge_mod[charge_mod_add_count].activity_dt_tm = chargereply->
        charge_items[1].charge_mods[z].activity_dt_tm
        SET addchargemodrequest->charge_mod[charge_mod_add_count].active_ind_ind = 1
        SET addchargemodrequest->charge_mod[charge_mod_add_count].active_ind = chargereply->
        charge_items[1].charge_mods[z].active_ind
      ENDFOR
      IF ((((request->charge[ccount].suspense_rsn_cd > 0)) OR (trim(request->charge[ccount].
       reason_comment) != ""))
       AND 4001989_credit_cd > 0)
       SET charge_mod_add_count += 1
       SET addchargemodrequest->charge_mod_qual = charge_mod_add_count
       SET stat = alterlist(addchargemodrequest->charge_mod,charge_mod_add_count)
       SET addchargemodrequest->charge_mod[charge_mod_add_count].action_type = "ADD"
       SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_item_id = new_charge_id
       SET addchargemodrequest->charge_mod[charge_mod_add_count].charge_mod_type_cd =
       13019_mod_rsn_cd
       SET addchargemodrequest->charge_mod[charge_mod_add_count].field1_id = 4001989_credit_cd
       SET addchargemodrequest->charge_mod[charge_mod_add_count].field6 = "The charge was credited"
       SET addchargemodrequest->charge_mod[charge_mod_add_count].field7 = request->charge[ccount].
       reason_comment
       SET addchargemodrequest->charge_mod[charge_mod_add_count].field2_id = request->charge[ccount].
       suspense_rsn_cd
       SET addchargemodrequest->charge_mod[charge_mod_add_count].activity_dt_tm = cnvtdatetime(
        sysdate)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET addchargemodrequest->charge_mod_qual = charge_mod_add_count
 CALL echorecord(addchargerequest)
 CALL echorecord(addchargemodrequest)
 IF (size(addchargerequest->objarray,5) > 0)
  CALL echo("Adding Credit Charges and Charge Mods")
  EXECUTE afc_add_charge  WITH replace("REQUEST",addchargerequest), replace("REPLY",addchargereply)
  IF ((addchargereply->status_data.status="F"))
   SET reply->status_data.status = "F"
   GO TO end_program
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET addchargemodreply->status_data.status = "Z"
 SET action_begin = 1
 SET action_end = addchargemodrequest->charge_mod_qual
 SET addchargemodrequest->skip_charge_event_mod_ind = 1
 IF (size(addchargemodrequest->charge_mod,5) > 0)
  EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodrequest), replace("REPLY",
   addchargemodreply)
  IF ((addchargemodreply->status_data.status="F"))
   SET reply->status_data.status = "F"
   GO TO end_program
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echorecord(addchargemodreply)
 CALL echo("Updating Old Debit Charge")
 FOR (z = 1 TO charge_add_count)
  UPDATE  FROM charge c
   SET c.offset_charge_item_id = addchargerequest->objarray[z].charge_item_id, c.process_flg =
    IF ((addchargerequest->objarray[z].process_flg < 900)
     AND (addchargerequest->objarray[z].process_flg != 100)
     AND (addchargerequest->objarray[z].process_flg != 6)
     AND (addchargerequest->objarray[z].process_flg != 0)) 10
    ELSE addchargerequest->objarray[z].old_process_flg
    ENDIF
    , c.updt_cnt = (c.updt_cnt+ 1),
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
    updt_applctx,
    c.updt_task = reqinfo->updt_task
   WHERE (c.charge_item_id=addchargerequest->objarray[z].offset_charge_item_id)
   WITH nocounter
  ;end update
  IF (curqual > 0)
   CALL echo("Updated old charge successfully!")
   SET reply->status_data.status = "S"
   SET original_charge_count += 1
   SET reply->original_charge_qual = original_charge_count
   SET stat = alterlist(reply->original_charge,original_charge_count)
   SET reply->original_charge[original_charge_count].charge_item_id = addchargerequest->objarray[z].
   offset_charge_item_id
   SET reply->original_charge[original_charge_count].updt_id = reqinfo->updt_id
   SET reply->original_charge[original_charge_count].updt_dt_tm = cnvtdatetime(sysdate)
   SET reply->original_charge[original_charge_count].updt_applctx = reqinfo->updt_applctx
   SET reply->original_charge[original_charge_count].updt_task = reqinfo->updt_task
   IF ((addchargerequest->objarray[z].process_flg < 900)
    AND (addchargerequest->objarray[z].process_flg != 100)
    AND (addchargerequest->objarray[z].process_flg != 6)
    AND (addchargerequest->objarray[z].process_flg != 0))
    SET reply->original_charge[original_charge_count].process_flg = 10
   ELSE
    SET reply->original_charge[original_charge_count].process_flg = addchargerequest->objarray[z].
    old_process_flg
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   GO TO end_program
  ENDIF
 ENDFOR
 CALL echorecord(addchargerequest)
 CALL echorecord(reply)
 IF ((reply->status_data.status != "F"))
  FOR (x = 1 TO reply->charge_qual)
    SET chargerequest->charge_item_id = reply->charge[x].charge_item_id
    EXECUTE afc_charge_find  WITH replace("REQUEST",chargerequest), replace("REPLY",chargereply)
    IF ((chargereply->status_data.status != "F")
     AND (chargereply->charge_item_count > 0))
     SET reply->charge[x].parent_charge_item_id = chargereply->charge_items[1].parent_charge_item_id
     SET reply->charge[x].charge_event_act_id = chargereply->charge_items[1].charge_event_act_id
     SET reply->charge[x].charge_event_id = chargereply->charge_items[1].charge_event_id
     SET reply->charge[x].bill_item_id = chargereply->charge_items[1].bill_item_id
     SET reply->charge[x].order_id = chargereply->charge_items[1].order_id
     SET reply->charge[x].encntr_id = chargereply->charge_items[1].encntr_id
     SET reply->charge[x].person_id = chargereply->charge_items[1].person_id
     SET reply->charge[x].payor_id = chargereply->charge_items[1].payor_id
     SET reply->charge[x].perf_loc_cd = chargereply->charge_items[1].perf_loc_cd
     SET reply->charge[x].ord_loc_cd = chargereply->charge_items[1].ord_loc_cd
     SET reply->charge[x].ord_phys_id = chargereply->charge_items[1].ord_phys_id
     SET reply->charge[x].perf_phys_id = chargereply->charge_items[1].perf_phys_id
     SET reply->charge[x].charge_description = chargereply->charge_items[1].charge_description
     SET reply->charge[x].price_sched_id = chargereply->charge_items[1].price_sched_id
     SET reply->charge[x].item_quantity = chargereply->charge_items[1].item_quantity
     SET reply->charge[x].item_price = chargereply->charge_items[1].item_price
     SET reply->charge[x].item_extended_price = chargereply->charge_items[1].item_extended_price
     SET reply->charge[x].item_allowable = chargereply->charge_items[1].item_allowable
     SET reply->charge[x].item_copay = chargereply->charge_items[1].item_copay
     SET reply->charge[x].charge_type_cd = chargereply->charge_items[1].charge_type_cd
     SET reply->charge[x].research_acct_id = chargereply->charge_items[1].research_acct_id
     SET reply->charge[x].suspense_rsn_cd = chargereply->charge_items[1].suspense_rsn_cd
     SET reply->charge[x].reason_comment = chargereply->charge_items[1].reason_comment
     SET reply->charge[x].posted_cd = chargereply->charge_items[1].posted_cd
     SET reply->charge[x].posted_dt_tm = chargereply->charge_items[1].posted_dt_tm
     SET reply->charge[x].process_flg = chargereply->charge_items[1].process_flg
     SET reply->charge[x].service_dt_tm = chargereply->charge_items[1].service_dt_tm
     SET reply->charge[x].activity_dt_tm = chargereply->charge_items[1].activity_dt_tm
     SET reply->charge[x].credited_dt_tm = chargereply->charge_items[1].credited_dt_tm
     SET reply->charge[x].adjusted_dt_tm = chargereply->charge_items[1].adjusted_dt_tm
     SET reply->charge[x].interface_file_id = chargereply->charge_items[1].interface_file_id
     SET reply->charge[x].tier_group_cd = chargereply->charge_items[1].tier_group_cd
     SET reply->charge[x].def_bill_item_id = chargereply->charge_items[1].def_bill_item_id
     SET reply->charge[x].verify_phys_id = chargereply->charge_items[1].verify_phys_id
     SET reply->charge[x].gross_price = chargereply->charge_items[1].gross_price
     SET reply->charge[x].discount_amount = chargereply->charge_items[1].discount_amount
     SET reply->charge[x].manual_ind = chargereply->charge_items[1].manual_ind
     SET reply->charge[x].combine_ind = chargereply->charge_items[1].combine_ind
     SET reply->charge[x].bundle_id = chargereply->charge_items[1].bundle_id
     SET reply->charge[x].institution_cd = chargereply->charge_items[1].institution_cd
     SET reply->charge[x].department_cd = chargereply->charge_items[1].department_cd
     SET reply->charge[x].section_cd = chargereply->charge_items[1].section_cd
     SET reply->charge[x].subsection_cd = chargereply->charge_items[1].subsection_cd
     SET reply->charge[x].level5_cd = chargereply->charge_items[1].level5_cd
     SET reply->charge[x].admit_type_cd = chargereply->charge_items[1].admit_type_cd
     SET reply->charge[x].med_service_cd = chargereply->charge_items[1].med_service_cd
     SET reply->charge[x].activity_type_cd = chargereply->charge_items[1].activity_type_cd
     IF (validate(reply->charge[x].activity_sub_type_cd))
      SET reply->charge[x].activity_sub_type_cd = chargereply->charge_items[1].activity_sub_type_cd
     ENDIF
     IF (validate(reply->charge[x].provider_specialty_cd))
      SET reply->charge[x].provider_specialty_cd = chargereply->charge_items[1].provider_specialty_cd
     ENDIF
     SET reply->charge[x].inst_fin_nbr = chargereply->charge_items[1].inst_fin_nbr
     SET reply->charge[x].cost_center_cd = chargereply->charge_items[1].cost_center_cd
     SET reply->charge[x].abn_status_cd = chargereply->charge_items[1].abn_status_cd
     SET reply->charge[x].health_plan_id = chargereply->charge_items[1].health_plan_id
     SET reply->charge[x].fin_class_cd = chargereply->charge_items[1].fin_class_cd
     SET reply->charge[x].payor_type_cd = chargereply->charge_items[1].payor_type_cd
     SET reply->charge[x].item_reimbursement = chargereply->charge_items[1].item_reimbursement
     SET reply->charge[x].item_interval_id = chargereply->charge_items[1].item_interval_id
     SET reply->charge[x].item_list_price = chargereply->charge_items[1].item_list_price
     SET reply->charge[x].list_price_sched_id = chargereply->charge_items[1].list_price_sched_id
     SET reply->charge[x].start_dt_tm = chargereply->charge_items[1].start_dt_tm
     SET reply->charge[x].stop_dt_tm = chargereply->charge_items[1].stop_dt_tm
     SET reply->charge[x].epsdt_ind = chargereply->charge_items[1].epsdt_ind
     SET reply->charge[x].ref_phys_id = chargereply->charge_items[1].ref_phys_id
     SET reply->charge[x].item_deductible_amt = chargereply->charge_items[1].item_deductible_amt
     SET reply->charge[x].patient_responsibility_flag = chargereply->charge_items[1].
     patient_responsibility_flag
     SET reply->charge[x].person_name = chargereply->charge_items[1].person_name
     SET reply->charge[x].username = chargereply->charge_items[1].username
     SET reply->charge[x].updt_cnt = chargereply->charge_items[1].updt_cnt
     SET reply->charge[x].updt_dt_tm = chargereply->charge_items[1].updt_dt_tm
     SET reply->charge[x].updt_id = chargereply->charge_items[1].updt_id
     SET reply->charge[x].updt_task = chargereply->charge_items[1].updt_task
     SET reply->charge[x].updt_applctx = chargereply->charge_items[1].updt_applctx
     SET reply->charge[x].active_ind = chargereply->charge_items[1].active_ind
     SET reply->charge[x].active_status_cd = chargereply->charge_items[1].active_status_cd
     SET reply->charge[x].active_status_dt_tm = chargereply->charge_items[1].active_status_dt_tm
     SET reply->charge[x].active_status_prsnl_id = chargereply->charge_items[1].
     active_status_prsnl_id
     SET reply->charge[x].beg_effective_dt_tm = chargereply->charge_items[1].beg_effective_dt_tm
     SET reply->charge[x].end_effective_dt_tm = chargereply->charge_items[1].end_effective_dt_tm
     FOR (z = 1 TO chargereply->charge_items[1].charge_mod_count)
       SET stat = alterlist(reply->charge[x].charge_mod,z)
       SET reply->charge[x].charge_mod[z].charge_mod_id = chargereply->charge_items[1].charge_mods[z]
       .charge_mod_id
       SET reply->charge[x].charge_mod[z].charge_mod_type_cd = chargereply->charge_items[1].
       charge_mods[z].charge_mod_type_cd
       SET reply->charge[x].charge_mod[z].field1_id = chargereply->charge_items[1].charge_mods[z].
       field1_id
       SET reply->charge[x].charge_mod[z].field2_id = chargereply->charge_items[1].charge_mods[z].
       field2_id
       SET reply->charge[x].charge_mod[z].field3_id = chargereply->charge_items[1].charge_mods[z].
       field3_id
       SET reply->charge[x].charge_mod[z].field4_id = chargereply->charge_items[1].charge_mods[z].
       field4_id
       SET reply->charge[x].charge_mod[z].field5_id = chargereply->charge_items[1].charge_mods[z].
       field5_id
       SET reply->charge[x].charge_mod[z].field1 = chargereply->charge_items[1].charge_mods[z].field1
       SET reply->charge[x].charge_mod[z].field2 = chargereply->charge_items[1].charge_mods[z].field2
       SET reply->charge[x].charge_mod[z].field3 = chargereply->charge_items[1].charge_mods[z].field3
       SET reply->charge[x].charge_mod[z].field4 = chargereply->charge_items[1].charge_mods[z].field4
       SET reply->charge[x].charge_mod[z].field5 = chargereply->charge_items[1].charge_mods[z].field5
       SET reply->charge[x].charge_mod[z].field6 = chargereply->charge_items[1].charge_mods[z].field6
       SET reply->charge[x].charge_mod[z].field7 = chargereply->charge_items[1].charge_mods[z].field7
       SET reply->charge[x].charge_mod[z].field8 = chargereply->charge_items[1].charge_mods[z].field8
       SET reply->charge[x].charge_mod[z].field9 = chargereply->charge_items[1].charge_mods[z].field9
       SET reply->charge[x].charge_mod[z].field10 = chargereply->charge_items[1].charge_mods[z].
       field10
       IF (validate(reply->charge[x].charge_mod[z].code1_cd))
        SET reply->charge[x].charge_mod[z].code1_cd = chargereply->charge_items[1].charge_mods[z].
        code1_cd
       ENDIF
       SET reply->charge[x].charge_mod[z].nomen_id = chargereply->charge_items[1].charge_mods[z].
       nomen_id
       SET reply->charge[x].charge_mod[z].cm1_nbr = chargereply->charge_items[1].charge_mods[z].
       cm1_nbr
       SET reply->charge[x].charge_mod_qual = z
     ENDFOR
    ELSE
     SET reply->status_data.status = "F"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM charge c,
    (dummyt d1  WITH seq = value(size(request->charge,5)))
   PLAN (d1
    WHERE (request->charge[d1.seq].late_charge_processing_ind=1))
    JOIN (c
    WHERE (c.charge_item_id=request->charge[d1.seq].charge_item_id))
   ORDER BY c.encntr_id
   HEAD c.encntr_id
    encntr_counter += 1, stat = alterlist(unique_encounters->encntr,encntr_counter),
    unique_encounters->encntr[encntr_counter].encntr_id = c.encntr_id
   DETAIL
    dchargeitemid = c.charge_item_id
   WITH nocounter
  ;end select
  IF (dchargeitemid > 0)
   UPDATE  FROM pft_charge pc
    SET pc.late_chrg_flag = 3
    WHERE pc.charge_item_id=dchargeitemid
    WITH nocounter
   ;end update
   SELECT INTO "nl:"
    FROM charge c,
     pft_charge pc,
     (dummyt d1  WITH seq = value(size(unique_encounters->encntr,5))),
     (dummyt d2  WITH seq = value(size(request->charge,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (request->charge[d2.seq].late_charge_processing_ind=1))
     JOIN (c
     WHERE (c.encntr_id=unique_encounters->encntr[d1.seq].encntr_id)
      AND (c.charge_item_id != request->charge[d2.seq].charge_item_id)
      AND c.active_ind=1)
     JOIN (pc
     WHERE pc.charge_item_id=c.charge_item_id
      AND pc.late_chrg_flag=1)
    DETAIL
     dequeue_ind = 1
    WITH nocounter
   ;end select
   IF (dequeue_ind=0)
    CALL echo("Dequeue Claim")
    SELECT INTO "nl:"
     FROM charge c,
      pft_charge pc,
      pft_charge_bo_reltn pcbr,
      bill_reltn br
     PLAN (c
      WHERE c.charge_item_id=dchargeitemid)
      JOIN (pc
      WHERE pc.charge_item_id=c.charge_item_id
       AND pc.active_ind=1)
      JOIN (pcbr
      WHERE pcbr.pft_charge_id=pc.pft_charge_id
       AND pcbr.active_ind=1)
      JOIN (br
      WHERE br.parent_entity_name="BENEFIT ORDER"
       AND br.parent_entity_id=pcbr.benefit_order_id
       AND br.active_ind=1)
     DETAIL
      dcorspactivityid = br.corsp_activity_id
     WITH nocounter
    ;end select
    SET reply->dequeued_ind = 1
    SET dequeue_request->pft_queue_event_cd = queue_event_cd
    SET dequeue_request->entity[1].pft_entity_type_cd = entity_type_cd
    SET dequeue_request->entity[1].entity_id = dcorspactivityid
    EXECUTE pft_wf_publish_queue_event  WITH replace("REQUEST",dequeue_request), replace("REPLY",
     dequeue_reply)
    IF ((dequeue_reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     GO TO end_program
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#end_program
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE SET chargerequest
 FREE SET chargereply
 FREE SET unique_encounters
 FREE SET dequeue_request
 FREE SET addchargerequest
 FREE SET addchargereply
 FREE SET addchargemodrequest
 FREE SET addchargemodreply
 CALL echorecord(reply)
END GO
