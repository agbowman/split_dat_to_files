CREATE PROGRAM afc_add_credit_wrapper:dba
 DECLARE afc_add_credit_wrapper = vc WITH constant("707748.000")
 CALL echo(build2("afc_add_credit_wrapper version: ",afc_add_credit_wrapper))
 IF ( NOT (validate(reply)))
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
 ENDIF
 SET stat = tdbexecute(3202004,3202004,951048,"REC",request,
  "REC",reply)
 IF (stat != 0)
  SET reply->status_data.status = "F"
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo(build("tdbexecuteStatus = ",stat))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
