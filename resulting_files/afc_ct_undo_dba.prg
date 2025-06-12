CREATE PROGRAM afc_ct_undo:dba
 DECLARE afc_ct_undo_version = vc WITH private, noconstant("CHARGSRV-15575.FT.004")
 EXECUTE crmrtl
 EXECUTE srvrtl
 RECORD reply(
   1 batch_qual = i4
   1 batch[*]
     2 cs_cpp_undo_id = f8
     2 success_ind = i2
     2 reason = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD adjustrequest
 RECORD adjustrequest(
   1 charge_item_id = f8
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = i4
   1 process_flg = i2
 )
 FREE RECORD adjustreply
 RECORD adjustreply(
   1 new_charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD addcreditreq
 RECORD addcreditreq(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 )
 FREE RECORD addcreditreply
 RECORD addcreditreply(
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
   1 original_charge_qual = i2
   1 item_price_adj_amt = f8
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
 FREE RECORD finalcharges
 RECORD finalcharges(
   1 charges[*]
     2 charge_item_id = f8
     2 interface_file_id = f8
 )
 FREE RECORD afcinterfacecharge_request
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 FREE RECORD afcinterfacecharge_reply
 RECORD afcinterfacecharge_reply(
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
     2 item_price_adj_amt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD afcprofit_request
 RECORD afcprofit_request(
   1 remove_commit_ind = i2
   1 follow_combined_parent_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD afcprofit_reply
 RECORD afcprofit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
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
 )
 FREE RECORD workdata
 RECORD workdata(
   1 batch[*]
     2 cs_cpp_undo_id = f8
     2 batch_valid = i2
     2 charges[*]
       3 charge_item_id = f8
       3 original_ind = i2
 )
 DECLARE dinactivecd = f8 WITH public, noconstant(0.0)
 DECLARE dcreditcd = f8 WITH public, noconstant(0.0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE cntbatch = i4 WITH public, noconstant(0)
 DECLARE cntcharges = i4 WITH public, noconstant(0)
 DECLARE cntfinal = i4 WITH public, noconstant(0)
 DECLARE loopbatch = i4 WITH public, noconstant(0)
 DECLARE loopchg = i4 WITH public, noconstant(0)
 DECLARE v_err_code2 = i4 WITH public, noconstant(0)
 DECLARE v_errmsg2 = vc WITH public
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,dinactivecd)
 SET stat = uar_get_meaning_by_codeset(13028,"CR",1,dcreditcd)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cs_cpp_undo u,
   cs_cpp_undo_detail ud,
   charge c,
   (dummyt d  WITH seq = value(size(request->batch,5)))
  PLAN (d)
   JOIN (u
   WHERE (u.cs_cpp_undo_id=request->batch[d.seq].cs_cpp_undo_id)
    AND u.cs_cpp_undo_id != 0
    AND u.active_ind=1)
   JOIN (ud
   WHERE ud.cs_cpp_undo_id=u.cs_cpp_undo_id
    AND ((ud.cs_cpp_undo_detail_id+ 0) != 0)
    AND ud.active_ind=1)
   JOIN (c
   WHERE c.charge_item_id=ud.charge_item_id
    AND c.charge_type_cd != dcreditcd)
  HEAD u.cs_cpp_undo_id
   cntbatch += 1, stat = alterlist(workdata->batch,cntbatch), workdata->batch[cntbatch].
   cs_cpp_undo_id = u.cs_cpp_undo_id,
   workdata->batch[cntbatch].batch_valid = 1
  DETAIL
   cntcharges += 1, stat = alterlist(workdata->batch[cntbatch].charges,cntcharges), workdata->batch[
   cntbatch].charges[cntcharges].charge_item_id = c.charge_item_id,
   workdata->batch[cntbatch].charges[cntcharges].original_ind = ud.original_ind
   IF (c.offset_charge_item_id != 0
    AND ud.original_ind=0)
    workdata->batch[cntbatch].batch_valid = 0
   ENDIF
  WITH nocounter
 ;end select
 SET cntbatch = 0
 FOR (loopbatch = 1 TO size(workdata->batch,5))
   SET cntbatch += 1
   SET stat = alterlist(reply->batch,cntbatch)
   SET reply->batch_qual = cntbatch
   SET reply->batch[cntbatch].cs_cpp_undo_id = workdata->batch[loopbatch].cs_cpp_undo_id
   IF ((workdata->batch[loopbatch].batch_valid=1))
    FOR (loopchg = 1 TO size(workdata->batch[loopbatch].charges,5))
      SET stat = initrec(addcreditreq)
      SET stat = initrec(addcreditreply)
      SET stat = initrec(adjustrequest)
      SET stat = initrec(adjustreply)
      IF ((workdata->batch[loopbatch].charges[loopchg].original_ind=1))
       SET adjustrequest->charge_item_id = workdata->batch[loopbatch].charges[loopchg].charge_item_id
       SET adjustrequest->process_flg = - (1)
      ELSE
       SET addcreditreq->charge_qual = 1
       SET stat = alterlist(addcreditreq->charge,1)
       SET addcreditreq->charge[1].charge_item_id = workdata->batch[loopbatch].charges[loopchg].
       charge_item_id
       SET addcreditreq->charge[1].reason_comment = "afc_ct_undo"
      ENDIF
      CALL processrecords(0)
    ENDFOR
    SET reply->batch[cntbatch].success_ind = 1
    SET reply->batch[cntbatch].reason = ""
   ELSE
    SET reply->batch[cntbatch].success_ind = 0
    SET reply->batch[cntbatch].reason = uar_i18ngetmessage(i18nhandle,"k1",
     "One or more charges have been modified since transformation.")
   ENDIF
 ENDFOR
 COMMIT
 CALL processinterfaces(0)
 SUBROUTINE processrecords(dummy)
   IF ((adjustrequest->charge_item_id != 0))
    CALL echorecord(adjustrequest)
    EXECUTE afc_ct_adjust_charge  WITH replace("REQUEST",adjustrequest), replace("REPLY",adjustreply)
   ENDIF
   IF (size(addcreditreq->charge,5) != 0)
    CALL echorecord(addcreditreq)
    EXECUTE afc_add_credit  WITH replace("REQUEST",addcreditreq), replace("REPLY",addcreditreply)
   ENDIF
   IF ((adjustreply->new_charge_item_id != 0))
    SET cntfinal += 1
    SET stat = alterlist(finalcharges->charges,cntfinal)
    SET finalcharges->charges[cntfinal].charge_item_id = adjustreply->new_charge_item_id
   ENDIF
   IF (size(addcreditreply->charge,5) >= 1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(addcreditreply->charge,5)))
     PLAN (d)
     DETAIL
      cntfinal += 1, stat = alterlist(finalcharges->charges,cntfinal), finalcharges->charges[cntfinal
      ].charge_item_id = addcreditreply->charge[d.seq].charge_item_id,
      finalcharges->charges[cntfinal].interface_file_id = addcreditreply->charge[d.seq].
      interface_file_id
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE processinterfaces(dummy)
   IF (size(finalcharges->charges,5) >= 1)
    SELECT INTO "nl:"
     FROM charge c,
      (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=finalcharges->charges[d.seq].charge_item_id))
     DETAIL
      finalcharges->charges[d.seq].interface_file_id = c.interface_file_id
     WITH nocounter
    ;end select
    SET finalcnt = 0
    SET finalcnt2 = 0
    SELECT INTO "nl:"
     FROM interface_file i,
      (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
     PLAN (d)
      JOIN (i
      WHERE (i.interface_file_id=finalcharges->charges[d.seq].interface_file_id))
     DETAIL
      IF (i.realtime_ind=1)
       finalcnt += 1, stat = alterlist(afcinterfacecharge_request->interface_charge,finalcnt),
       afcinterfacecharge_request->interface_charge[finalcnt].charge_item_id = finalcharges->charges[
       d.seq].charge_item_id
      ELSEIF (i.profit_type_cd > 0)
       finalcnt2 += 1, stat = alterlist(afcprofit_request->charges,finalcnt2), afcprofit_request->
       charges[finalcnt2].charge_item_id = finalcharges->charges[d.seq].charge_item_id
      ENDIF
     WITH nocounter
    ;end select
    IF (size(afcprofit_request->charges,5) > 0)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(afcprofit_request)
     ENDIF
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
      afcprofit_reply)
    ENDIF
    IF (size(afcinterfacecharge_request->interface_charge,5) > 0)
     EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
      "REPLY",afcinterfacecharge_reply)
     IF ((afcinterfacecharge_reply->status_data.status="f"))
      CALL echo("afc_srv_interface_charge failed")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(v_err_code2)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = v_errmsg2
 ENDIF
END GO
