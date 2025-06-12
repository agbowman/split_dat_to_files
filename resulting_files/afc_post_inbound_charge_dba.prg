CREATE PROGRAM afc_post_inbound_charge:dba
 DECLARE afc_post_inbound_charge_version = vc WITH private, noconstant("567201.FT.019")
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
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
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE i18n_duplicate_charge_events = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val1",
   "Duplicate Charges Events"))
 DECLARE i18n_locked_charges = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val1",
   "Unable to acquire lock"))
 EXECUTE crmrtl
 EXECUTE srvrtl
 RECORD reply(
   1 charge_event_qual = i4
   1 charge_event[*]
     2 charge_event_id = f8
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
 FREE RECORD addcreditrep
 RECORD addcreditrep(
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
     2 original_org_id = f8
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
 )
 FREE RECORD afcprofit_req
 RECORD afcprofit_req(
   1 remove_commit_ind = i2
   1 follow_combined_parent_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD afcinterfacecharge_req
 RECORD afcinterfacecharge_req(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 FREE RECORD afcinterfacecharge_rep
 RECORD afcinterfacecharge_rep(
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
     2 charge_event_id = f8
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
     2 ndc_ident = c40
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD g_srvproperties
 RECORD g_srvproperties(
   1 globalfactor = f8
   1 billcachesize = ui4
   1 loglevel = i2
   1 workloadind = i2
   1 timerind = i2
   1 phlebotomyind = i2
   1 replyind = i2
   1 logreqrep = i2
   1 rxversion = i2
 )
 FREE RECORD g_cs13028
 RECORD g_cs13028(
   1 charge_now = f8
   1 credit_now = f8
   1 cr = f8
   1 dr = f8
   1 no_charge = f8
   1 collection = f8
   1 workloadonly = f8
   1 pharmcr = f8
   1 pharmdr = f8
   1 pharmnc = f8
 )
 FREE RECORD cssrvaddchargereq
 RECORD cssrvaddchargereq(
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
     2 hp_beg_effective_dt_tm = dq8
     2 hp_end_effective_dt_tm = dq8
     2 original_org_id = f8
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
         4 field3_ext = c350
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 original_org_id = f8
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
 )
 FREE RECORD addchargeeventreq
 RECORD addchargeeventreq(
   1 charge_event_qual = i2
   1 charge_event[*]
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 ext_parent_event_id = f8
     2 ext_parent_event_cont_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_reference_cont_cd = f8
     2 ext_item_event_id = f8
     2 ext_item_event_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 accession = vc
     2 report_priority_cd = f8
     2 collection_priority_cd = f8
     2 reference_nbr = vc
     2 research_acct_id = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 charge_event_id = f8
     2 health_plan_id = f8
     2 cancelled_ind = i2
     2 epsdt_ind = i2
     2 active_status_cd = f8
 )
 FREE RECORD addchargeeventrep
 RECORD addchargeeventrep(
   1 charge_event_qual = i2
   1 charge_event[*]
     2 charge_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD tempcelist
 RECORD tempcelist(
   1 charge_events[*]
     2 charge_event_id = f8
     2 quantity = f8
   1 charges[*]
     2 charge_item_id = f8
 )
 FREE RECORD celist
 RECORD celist(
   1 charge_events[*]
     2 charge_event_id = f8
     2 quantity = f8
   1 charges[*]
     2 charge_item_id = f8
 )
 FREE RECORD celist2
 RECORD celist2(
   1 charge_events[*]
     2 charge_event_id = f8
 )
 FREE RECORD dropchargerequest
 RECORD dropchargerequest(
   1 action_type = c3
   1 charge_event_qual = i2
   1 charge_event[*]
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 ext_parent_event_id = f8
     2 ext_parent_event_cont_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_reference_cont_cd = f8
     2 ext_item_event_id = f8
     2 ext_item_event_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_bill_type_cd = f8
     2 accession = vc
     2 report_priority_cd = f8
     2 collection_priority_cd = f8
     2 reference_nbr = vc
     2 research_acct_id = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 charge_event_id = f8
     2 encntr_type_cd = f8
     2 med_service_cd = f8
     2 encntr_org_id = f8
     2 research_org_id = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 loc_nurse_unit_cd = f8
     2 ord_loc_cd = f8
     2 ord_phys_id = f8
     2 verify_phys_id = f8
     2 perf_phys_id = f8
     2 ref_phys_id = f8
     2 cancelled_ind = i2
     2 no_charge_ind = i2
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_desc = c200
     2 user_id = f8
     2 epsdt_ind = i2
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_act_id = f8
       3 phleb_group_ind = i2
       3 cea_type_cd = f8
       3 service_resource_cd = f8
       3 service_loc_cd = f8
       3 service_dt_tm = dq8
       3 charge_dt_tm = dq8
       3 charge_type_cd = f8
       3 alpha_nomen_id = f8
       3 quantity = i4
       3 rx_quantity = f8
       3 result = vc
       3 units = f8
       3 unit_type_cd = i4
       3 reason_cd = f8
       3 accession_id = f8
       3 cea_prsnl_id = f8
       3 position_cd = f8
       3 repeat_ind = i2
       3 misc_ind = i2
       3 cea_misc1 = c200
       3 cea_misc2 = c200
       3 cea_misc3 = c200
       3 cea_misc1_id = f8
       3 cea_misc2_id = f8
       3 cea_misc3_id = f8
       3 cea_misc4_id = f8
       3 cea_misc5_id = f8
       3 cea_misc6_id = f8
       3 cea_misc7_id = f8
       3 prsnl_qual = i2
       3 prsnl[*]
         4 prsnl_id = f8
         4 prsnl_type_cd = f8
       3 charge_event_id = f8
       3 reference_range_factor_id = f8
       3 patient_loc_cd = f8
       3 in_transit_dt_tm = dq8
       3 in_lab_dt_tm = dq8
       3 cea_prsnl_type_cd = f8
       3 cea_service_resource_cd = f8
       3 ceact_dt_tm = dq8
       3 cea_field1 = vc
       3 cea_field2 = vc
       3 cea_field3 = vc
       3 cea_field4 = vc
       3 cea_field5 = vc
       3 elapsed_time = i4
       3 cea_loc_cd = f8
       3 priority_cd = f8
       3 patient_responsibility_flag = i2
       3 item_deductible_amt = f8
     2 charge_event_mod_qual = i2
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
     2 parent_events[*]
       3 ext_p_ref_id = f8
       3 ext_p_ref_cd = f8
       3 ext_i_ref_id = f8
       3 ext_i_ref_cd = f8
     2 charges[*]
       3 charge_item_id = f8
       3 charge_act_id = f8
       3 charge_event_id = f8
       3 bill_item_id = f8
       3 charge_description = c200
       3 price_sched_id = f8
       3 payor_id = f8
       3 item_quantity = f8
       3 item_price = f8
       3 item_extended_price = f8
       3 charge_type_cd = f8
       3 suspense_rsn_cd = f8
       3 reason_comment = c200
       3 posted_cd = f8
       3 ord_phys_id = f8
       3 perf_phys_id = f8
       3 order_id = f8
       3 beg_effective_dt_tm = dq8
       3 person_id = f8
       3 encntr_id = f8
       3 admit_type_cd = f8
       3 med_service_cd = f8
       3 institution_cd = f8
       3 department_cd = f8
       3 section_cd = f8
       3 subsection_cd = f8
       3 level5_cd = f8
       3 service_dt_tm = dq8
       3 process_flg = i2
       3 parent_charge_item_id = f8
       3 interface_id = f8
       3 tier_group_cd = f8
       3 def_bill_item_id = f8
       3 verify_phys_id = f8
       3 gross_price = f8
       3 discount_amount = f8
       3 activity_type_cd = f8
       3 research_acct_id = f8
       3 cost_center_cd = f8
       3 abn_status_cd = f8
       3 perf_loc_cd = f8
       3 inst_fin_nbr = c50
       3 ord_loc_cd = f8
       3 fin_class_cd = f8
       3 health_plan_id = f8
       3 manual_ind = i2
       3 updt_ind = i2
       3 payor_type_cd = f8
       3 item_copay = f8
       3 item_reimbursement = f8
       3 posted_dt_tm = dq8
       3 item_interval_id = f8
       3 list_price = f8
       3 list_price_sched_id = f8
       3 realtime_ind = i2
       3 epsdt_ind = i2
       3 ref_phys_id = f8
       3 alpha_nomen_id = f8
       3 server_process_flag = i2
       3 mods
         4 charge_mods[*]
           5 mod_id = f8
           5 charge_event_id = f8
           5 charge_event_mod_type_cd = f8
           5 charge_item_id = f8
           5 charge_mod_type_cd = f8
           5 field1 = c200
           5 field2 = c200
           5 field3 = c200
           5 field4 = c200
           5 field5 = c200
           5 field6 = c200
           5 field7 = c200
           5 field8 = c200
           5 field9 = c200
           5 field10 = c200
           5 field1_id = f8
           5 field2_id = f8
           5 field3_id = f8
           5 field4_id = f8
           5 field5_id = f8
           5 nomen_id = f8
           5 cm1_nbr = f8
       3 offset_charge_item_id = f8
       3 patient_responsibility_flag = i2
       3 item_deductible_amt = f8
       3 activity_sub_type_cd = f8
       3 provider_specialty_cd = f8
       3 original_org_id = f8
 )
 DECLARE srvhandle = i4 WITH public, noconstant(0)
 DECLARE srvstat = i4 WITH public, noconstant(0)
 DECLARE hchargeevent = i4 WITH public, noconstant(0)
 DECLARE hchargeeventact = i4 WITH public, noconstant(0)
 DECLARE hlist = i4 WITH public, noconstant(0)
 DECLARE hlist2 = i4 WITH public, noconstant(0)
 DECLARE lceloop = i4 WITH public, noconstant(0)
 DECLARE lcealoop = i4 WITH public, noconstant(0)
 DECLARE lcecount = i4 WITH public, noconstant(0)
 DECLARE lceacount = i4 WITH public, noconstant(0)
 DECLARE nresult = i2 WITH public, noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE dencntrid = f8 WITH public, noconstant(0.0)
 DECLARE ditemeventid = f8 WITH public, noconstant(0.0)
 DECLARE ditemcontcd = f8 WITH public, noconstant(0.0)
 DECLARE drefid = f8 WITH public, noconstant(0.0)
 DECLARE drefcontcd = f8 WITH public, noconstant(0.0)
 DECLARE dquantity = f8 WITH public, noconstant(0.0)
 DECLARE dchargetypecd = f8 WITH public, noconstant(0.0)
 DECLARE dcreditchargetypecd = f8 WITH public, noconstant(0.0)
 DECLARE iret = i4 WITH noconstant(0)
 DECLARE dmastereventid = f8 WITH public, noconstant(0.0)
 DECLARE dmastercontcd = f8 WITH public, noconstant(0.0)
 DECLARE dparenteventid = f8 WITH public, noconstant(0.0)
 DECLARE dparentcontcd = f8 WITH public, noconstant(0.0)
 DECLARE lduplicate = i2 WITH noconstant(0)
 DECLARE ldupremove = i2 WITH noconstant(0)
 DECLARE mcnt = i4 WITH public, noconstant(0)
 DECLARE ceacnt = i4 WITH public, noconstant(0)
 DECLARE ceapcnt = i4 WITH public, noconstant(0)
 DECLARE cecnt = i4 WITH public, noconstant(0)
 DECLARE cemcnt = i4 WITH public, noconstant(0)
 DECLARE lcloop = i4 WITH public, noconstant(0)
 DECLARE chrgcnt = i4 WITH public, noconstant(0)
 DECLARE sceparser = vc WITH public, noconstant("")
 DECLARE lparsecnt = i4 WITH public, noconstant(0)
 DECLARE cecnt2 = i4 WITH public, noconstant(0)
 DECLARE lockchrgcnt = i4 WITH public, noconstant(0)
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE startidx = i4 WITH public, noconstant(0)
 DECLARE prevcelistchrgidx = i4 WITH public, noconstant(0)
 DECLARE tempchrgcnt = i4 WITH public, noconstant(0)
 DECLARE tempcecnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD servicedates(
   1 dtservicedate = dq8
   1 dtfromdate = dq8
   1 dtorigservicedate = dq8
 )
 DECLARE applypartialcredit(dummy) = null WITH protect
 DECLARE performfullcredit(dummy) = null WITH protect
 DECLARE nodebitfound(dummy) = null WITH protect
 DECLARE updatechrgeventact(dummy) = null WITH protect
 DECLARE callasync(dummy) = null WITH protect
 SET srvhandle = uar_crmgetrequest(request->crmhandle)
 SET lcecount = uar_srvgetitemcount(srvhandle,"charge_event")
 FOR (lceloop = 1 TO lcecount)
   SET hchargeevent = uar_srvgetitem(srvhandle,"charge_event",(lceloop - 1))
   SET dmastereventid = uar_srvgetdouble(hchargeevent,"ext_master_event_id")
   SET lceacount = uar_srvgetitemcount(hchargeevent,"charge_event_act")
   SET nresult = 0
   SET ignore = 0
   SET dceid = 0.0
   SET randomchrgitemind = 1
   SET randomchargeventind = 1
   SET tempcecnt = 0
   SET tempchrgcnt = 0
   SET stat = initrec(tempcelist)
   FOR (lcealoop = 1 TO lceacount)
     SET hchargeeventact = uar_srvgetitem(hchargeevent,"charge_event_act",(lcealoop - 1))
     SET dchargetypecd = uar_srvgetdouble(hchargeeventact,"charge_type_cd")
     IF (uar_get_code_meaning(dchargetypecd)="CR")
      SET srvstat = uar_srvgetdate(hchargeeventact,"service_dt_tm",servicedates->dtservicedate)
      SET servicedates->dtorigservicedate = servicedates->dtservicedate
      SET servicedates->dtservicedate = cnvtdatetime(cnvtdate(servicedates->dtservicedate),235959)
      SET servicedates->dtfromdate = datetimeadd(cnvtdatetime(cnvtdate(servicedates->dtservicedate),0
        ),- (7))
      SET dencntrid = uar_srvgetdouble(hchargeevent,"encntr_id")
      SET ditemeventid = uar_srvgetdouble(hchargeevent,"ext_item_event_id")
      SET ditemcontcd = uar_srvgetdouble(hchargeevent,"ext_item_event_cont_cd")
      SET drefid = uar_srvgetdouble(hchargeevent,"ext_item_reference_id")
      SET drefcontcd = uar_srvgetdouble(hchargeevent,"ext_item_reference_cont_cd")
      SET dquantity = uar_srvgetlong(hchargeeventact,"quantity")
      SET dcreditchargetypecd = uar_get_code_by("MEANING",13028,"CR")
      SET cs13028_dr = uar_get_code_by("MEANING",13028,"DR")
      IF (validate(debug,- (1)) > 0)
       CALL echo(build("dEncntrID: ",dencntrid))
       CALL echo(build("dItemEventID: ",ditemeventid))
       CALL echo(build("dItemContCD: ",ditemcontcd))
       CALL echo(build("dRefID: ",drefid))
       CALL echo(build("dRefContCD: ",drefcontcd))
       CALL echo(build("dCreditChargeTypeCD: ",dcreditchargetypecd))
       CALL echo(build("dQuantity: ",dquantity))
      ENDIF
      IF (size(celist2->charge_events,5) > 0)
       SET sceparser = "ce.charge_event_id not in ("
       FOR (lparsecnt = 1 TO size(celist2->charge_events,5))
         IF (lparsecnt > 1)
          SET sceparser = concat(sceparser,",",trim(cnvtstring(celist2->charge_events[lparsecnt].
             charge_event_id,17)),".0")
         ELSE
          SET sceparser = concat(sceparser,trim(cnvtstring(celist2->charge_events[lparsecnt].
             charge_event_id,17)),".0")
         ENDIF
       ENDFOR
       SET sceparser = concat(sceparser,")")
      ELSE
       SET sceparser = "1=1"
      ENDIF
      IF (validate(debug,- (1)) > 0)
       CALL echo(sceparser)
      ENDIF
      SELECT INTO "nl:"
       FROM charge_event ce,
        charge c,
        charge_event_act cea,
        pft_charge pc
       PLAN (ce
        WHERE ce.encntr_id=dencntrid
         AND ce.ext_i_event_cont_cd=ditemcontcd
         AND ce.ext_i_reference_id=drefid
         AND ce.ext_i_reference_cont_cd=drefcontcd
         AND parser(sceparser))
        JOIN (c
        WHERE c.charge_event_id=ce.charge_event_id
         AND c.charge_item_id != 0.0
         AND c.charge_type_cd IN (cs13028_dr, 0.0)
         AND c.offset_charge_item_id=0.0
         AND c.service_dt_tm BETWEEN cnvtdatetime(servicedates->dtfromdate) AND cnvtdatetime(
         servicedates->dtservicedate)
         AND  NOT (c.process_flg IN (5, 7, 10, 11, 177,
        222, 777, 977, 996))
         AND c.active_ind=1)
        JOIN (pc
        WHERE (pc.charge_item_id= Outerjoin(c.charge_item_id))
         AND (pc.active_ind= Outerjoin(1)) )
        JOIN (cea
        WHERE cea.charge_event_act_id=c.charge_event_act_id
         AND cea.quantity >= dquantity)
       ORDER BY ce.charge_event_id, c.charge_item_id
       HEAD ce.charge_event_id
        lockchrgcnt = 0
        IF (ignore=0)
         dceid = ce.charge_event_id
         IF (((ce.ext_m_event_id=dmastereventid
          AND cea.quantity > dquantity) OR (cea.quantity > dquantity
          AND randomchargeventind=1)) )
          IF (((c.process_flg=1
           AND ce.ext_m_event_id=dmastereventid) OR (c.charge_type_cd=cs13028_dr
           AND pc.offset_ind=0)) )
           IF (tempcecnt=0)
            tempcecnt += 1, stat = alterlist(tempcelist->charge_events,tempcecnt)
           ENDIF
           tempcelist->charge_events[tempcecnt].charge_event_id = ce.charge_event_id, tempcelist->
           charge_events[tempcecnt].quantity = (cea.quantity - dquantity), nresult = 1
          ENDIF
         ENDIF
        ENDIF
       DETAIL
        IF (((cea.quantity >= dquantity
         AND c.charge_event_id=dceid
         AND ce.ext_m_event_id=dmastereventid) OR (cea.quantity >= dquantity
         AND c.charge_event_id=dceid
         AND randomchrgitemind=1)) )
         IF (randomchrgitemind=0
          AND ignore=0)
          tempchrgcnt = 0, lockchrgcnt = 0, stat = alterlist(tempcelist->charges,tempchrgcnt)
         ENDIF
         IF (c.process_flg=1
          AND ce.ext_m_event_id=dmastereventid)
          ignore = 1, tempchrgcnt += 1, lockchrgcnt += 1,
          stat = alterlist(tempcelist->charges,tempchrgcnt), tempcelist->charges[tempchrgcnt].
          charge_item_id = c.charge_item_id, nresult = 1
         ELSE
          IF (c.charge_type_cd=cs13028_dr
           AND pc.offset_ind=0)
           IF (ce.ext_m_event_id=dmastereventid)
            ignore = 1
           ENDIF
           tempchrgcnt += 1, lockchrgcnt += 1, stat = alterlist(tempcelist->charges,tempchrgcnt),
           tempcelist->charges[tempchrgcnt].charge_item_id = c.charge_item_id, nresult = 1
          ENDIF
         ENDIF
        ENDIF
       FOOT  ce.charge_event_id
        IF (ce.ext_m_event_id=dmastereventid
         AND cea.quantity=dquantity)
         tempcecnt = 0, stat = alterlist(tempcelist->charge_events,tempcecnt), cecnt2 += 1,
         stat = alterlist(celist2->charge_events,cecnt2), celist2->charge_events[cecnt2].
         charge_event_id = ce.charge_event_id
        ENDIF
        IF (cea.quantity >= dquantity)
         randomchrgitemind = 0, randomchargeventind = 0
        ENDIF
       WITH nocounter
      ;end select
      IF (lockchrgcnt > 0)
       SET prevcelistchrgidx = (tempchrgcnt - lockchrgcnt)
       SET startidx = (prevcelistchrgidx+ 1)
       SELECT INTO "nl"
        FROM charge c
        WHERE expand(idx,startidx,tempchrgcnt,c.charge_item_id,tempcelist->charges[idx].
         charge_item_id)
        WITH nocounter, forupdate(c)
       ;end select
       IF (curqual=0)
        SET reply->charge_event_qual += 1
        SET stat = alterlist(reply->charge_event,reply->charge_event_qual)
        SET reply->status_data.subeventstatus[1].targetobjectname = i18n_locked_charges
        SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(format(dmastereventid,
          "###############.#;r"),3)
        GO TO exit_script
       ENDIF
      ENDIF
      IF (nresult=0)
       CALL nodebitfound(1)
      ENDIF
      SET stat = uar_srvremoveitem(srvhandle,"charge_event",(lceloop - 1))
      IF (lcecount > 1)
       SET lcecount -= 1
       SET lceloop -= 1
      ENDIF
     ENDIF
   ENDFOR
   FOR (tempcnt = 1 TO size(tempcelist->charge_events,5))
     SET cecnt += 1
     SET stat = alterlist(celist->charge_events,cecnt)
     SET celist->charge_events[cecnt].charge_event_id = tempcelist->charge_events[tempcnt].
     charge_event_id
     SET celist->charge_events[cecnt].quantity = tempcelist->charge_events[tempcnt].quantity
     SET cecnt2 += 1
     SET stat = alterlist(celist2->charge_events,cecnt2)
     SET celist2->charge_events[cecnt2].charge_event_id = tempcelist->charge_events[tempcnt].
     charge_event_id
   ENDFOR
   FOR (tempcnt1 = 1 TO size(tempcelist->charges,5))
     SET chrgcnt += 1
     SET stat = alterlist(celist->charges,chrgcnt)
     SET celist->charges[chrgcnt].charge_item_id = tempcelist->charges[tempcnt1].charge_item_id
   ENDFOR
 ENDFOR
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(celist)
  CALL echo("Checking for any remaining debits")
  CALL echo(build("CRM Handle: ",request->crmhandle))
  CALL echo(build("The number of items remaining: ",uar_srvgetitemcount(srvhandle,"charge_event")))
 ENDIF
 SET lcecount = uar_srvgetitemcount(srvhandle,"charge_event")
 IF (lcecount > 0)
  SET lduplicate = 0
  SET lceloop = 1
  WHILE (lceloop <= lcecount)
    SET ldupremove = 0
    SET hchargeevent = uar_srvgetitem(srvhandle,"charge_event",(lceloop - 1))
    SET dmastereventid = uar_srvgetdouble(hchargeevent,"ext_master_event_id")
    SET dmastercontcd = uar_srvgetdouble(hchargeevent,"ext_master_event_cont_cd")
    SET dparenteventid = uar_srvgetdouble(hchargeevent,"ext_parent_event_id")
    SET dparentcontcd = uar_srvgetdouble(hchargeevent,"ext_parent_event_cont_cd")
    SET ditemeventid = uar_srvgetdouble(hchargeevent,"ext_item_event_id")
    SET ditemcontcd = uar_srvgetdouble(hchargeevent,"ext_item_event_cont_cd")
    SELECT INTO "nl:"
     ce.charge_event_id, c.charge_item_id
     FROM charge_event ce,
      charge c
     PLAN (ce
      WHERE ce.ext_m_event_id=dmastereventid
       AND ce.ext_m_event_cont_cd=dmastercontcd
       AND ce.ext_p_event_id=dparenteventid
       AND ce.ext_p_event_cont_cd=dparentcontcd
       AND ce.ext_i_event_id=ditemeventid
       AND ce.ext_i_event_cont_cd=ditemcontcd)
      JOIN (c
      WHERE c.charge_event_id=ce.charge_event_id)
     DETAIL
      IF (c.charge_item_id > 0)
       lduplicate = 1, ldupremove = 1, reply->status_data.subeventstatus[1].targetobjectvalue =
       build2(reply->status_data.subeventstatus[1].targetobjectvalue,trim(format(dmastereventid,
          "###############.#;r"),3),"|")
      ENDIF
     WITH outerjoin = d1, maxread(c,1), nocounter
    ;end select
    IF (ldupremove=1)
     SET stat = uar_srvremoveitem(srvhandle,"charge_event",(lceloop - 1))
     IF (lcecount > 1)
      SET lcecount -= 1
      SET lceloop -= 1
     ENDIF
    ENDIF
    SET lceloop += 1
  ENDWHILE
 ENDIF
 CALL applypartialcredit(1)
 CALL performfullcredit(1)
 IF (uar_srvgetitemcount(srvhandle,"charge_event") > 0)
  SET iret = uar_crmperform(request->crmhandle)
 ENDIF
 IF (iret=0)
  IF (lduplicate=1)
   SET reply->charge_event_qual += 1
   SET stat = alterlist(reply->charge_event,reply->charge_event_qual)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = i18n_duplicate_charge_events
  ELSE
   SET reply->charge_event_qual += 1
   SET stat = alterlist(reply->charge_event,reply->charge_event_qual)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SUBROUTINE applypartialcredit(dummy)
   IF (size(celist->charge_events,5) > 0)
    SELECT INTO "nl:"
     FROM charge_event ce,
      charge_event_act cea,
      charge_event_act_prsnl ceap,
      (dummyt d  WITH seq = value(size(celist->charge_events,5)))
     PLAN (d)
      JOIN (ce
      WHERE (ce.charge_event_id=celist->charge_events[d.seq].charge_event_id))
      JOIN (cea
      WHERE cea.charge_event_id=ce.charge_event_id
       AND cea.active_ind=true)
      JOIN (ceap
      WHERE (ceap.charge_event_act_id= Outerjoin(cea.charge_event_act_id)) )
     ORDER BY ce.charge_event_id, cea.charge_event_act_id
     HEAD REPORT
      mcnt = 0, stat = alterlist(dropchargerequest->charge_event,mcnt)
     HEAD ce.charge_event_id
      mcnt += 1, ceacnt = 0, ceapcnt = 0,
      stat = alterlist(dropchargerequest->charge_event,mcnt), dropchargerequest->charge_event[mcnt].
      charge_event_id = - (2), dropchargerequest->charge_event[mcnt].ext_master_event_id = ce
      .ext_m_event_id,
      dropchargerequest->charge_event[mcnt].ext_master_event_cont_cd = ce.ext_m_event_cont_cd,
      dropchargerequest->charge_event[mcnt].ext_master_reference_id = ce.ext_m_reference_id,
      dropchargerequest->charge_event[mcnt].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd,
      dropchargerequest->charge_event[mcnt].ext_item_event_id = ce.ext_i_event_id, dropchargerequest
      ->charge_event[mcnt].ext_item_event_cont_cd = ce.ext_i_event_cont_cd, dropchargerequest->
      charge_event[mcnt].ext_item_reference_id = ce.ext_i_reference_id,
      dropchargerequest->charge_event[mcnt].ext_item_reference_cont_cd = ce.ext_i_reference_cont_cd,
      dropchargerequest->charge_event[mcnt].order_id = ce.order_id, dropchargerequest->charge_event[
      mcnt].person_id = ce.person_id,
      dropchargerequest->charge_event[mcnt].encntr_id = ce.encntr_id, dropchargerequest->
      charge_event[mcnt].accession = ce.accession, dropchargerequest->charge_event[mcnt].
      report_priority_cd = ce.report_priority_cd,
      dropchargerequest->charge_event[mcnt].collection_priority_cd = ce.collection_priority_cd,
      dropchargerequest->charge_event[mcnt].reference_nbr = ce.reference_nbr, dropchargerequest->
      charge_event[mcnt].research_acct_id = ce.research_account_id,
      dropchargerequest->charge_event[mcnt].abn_status_cd = ce.abn_status_cd, dropchargerequest->
      charge_event[mcnt].perf_loc_cd = ce.perf_loc_cd, dropchargerequest->charge_event[mcnt].
      cancelled_ind = ce.cancelled_ind,
      dropchargerequest->charge_event[mcnt].epsdt_ind = ce.epsdt_ind
     HEAD cea.charge_event_act_id
      ceacnt += 1, ceapcnt = 0, stat = alterlist(dropchargerequest->charge_event[mcnt].
       charge_event_act,ceacnt),
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_type_cd = cea.cea_type_cd,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_prsnl_id = cea.cea_prsnl_id,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_dt_tm = cea
      .service_dt_tm,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_loc_cd = cea
      .service_loc_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_dt_tm =
      cea.charge_dt_tm, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_type_cd
       = cea.charge_type_cd,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].alpha_nomen_id = cea
      .alpha_nomen_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].quantity =
      celist->charge_events[d.seq].quantity, dropchargerequest->charge_event[mcnt].charge_event_act[
      ceacnt].result = cea.result,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].units = cea.units,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].unit_type_cd = cea.unit_type_cd,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].reason_cd = cea.reason_cd,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].accession_id = cea.accession_id,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].repeat_ind = cea.repeat_ind,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].misc_ind = cea.misc_ind,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc1 = cea.cea_misc1,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc2 = cea.cea_misc2,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc3 = cea.cea_misc3,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc1_id = cea.cea_misc1_id,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc2_id = (cea.item_price
       * celist->charge_events[d.seq].quantity), dropchargerequest->charge_event[mcnt].
      charge_event_act[ceacnt].cea_misc3_id = cea.cea_misc3_id,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc4_id = cea.item_price,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc5_id = cea.item_copay,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc6_id = cea
      .item_reimbursement,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc7_id = cea
      .discount_amount, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].patient_loc_cd
       = cea.patient_loc_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
      in_lab_dt_tm = cea.in_lab_dt_tm,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].priority_cd = cea.priority_cd,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_resource_cd = cea
      .service_resource_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
      patient_responsibility_flag = cea.patient_responsibility_flag,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].reference_range_factor_id = cea
      .reference_range_factor_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
      item_deductible_amt = cea.item_deductible_amt
     DETAIL
      ceapcnt += 1, stat = alterlist(dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
       prsnl,ceapcnt), dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl[ceapcnt].
      prsnl_id = ceap.prsnl_id,
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl[ceapcnt].prsnl_type_cd =
      ceap.prsnl_type_cd
     FOOT  cea.charge_event_act_id
      dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl_qual = ceapcnt
     FOOT  ce.charge_event_id
      dropchargerequest->charge_event[mcnt].charge_event_act_qual = ceacnt
     FOOT REPORT
      dropchargerequest->charge_event_qual = mcnt
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM charge_event_mod cem,
      (dummyt d  WITH seq = value(mcnt))
     PLAN (d)
      JOIN (cem
      WHERE (cem.charge_event_id=dropchargerequest->charge_event[d.seq].charge_event_id))
     DETAIL
      cemcnt += 1, stat = alterlist(dropchargerequest->charge_event[d.seq].mods.charge_mods,cemcnt),
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].charge_event_id = cem
      .charge_event_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].charge_event_mod_type_cd = cem
      .charge_event_mod_type_cd, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].
      field1 = cem.field1, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field2 =
      cem.field2,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field3 = cem.field3,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field4 = cem.field4,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field5 = cem.field5,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field6 = cem.field6,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field7 = cem.field7,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field8 = cem.field8,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field9 = cem.field9,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field10 = cem.field10,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field1_id = cem.field1_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field2_id = cem.field2_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field3_id = cem.field3_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field4_id = cem.field4_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field5_id = cem.field5_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].nomen_id = cem.nomen_id,
      dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].cm1_nbr = cem.cm1_nbr
     WITH nocounter
    ;end select
    SET curalias ce dropchargerequest->charge_event[x]
    SET curalias cea dropchargerequest->charge_event[x].charge_event_act[y]
    SET curalias cepe dropchargerequest->charge_event[x].parent_events[y]
    SET curalias cem dropchargerequest->charge_event[x].mods.charge_mods[y]
    SET curalias c dropchargerequest->charge_event[x].charges[y]
    SET curalias cm dropchargerequest->charge_event[x].charges[y].mods.charge_mods[z]
    SET curalias ceap dropchargerequest->charge_event[x].charge_event_act[y].prsnl[z]
    FOR (x = 1 TO dropchargerequest->charge_event_qual)
      SET hchargeevent = uar_srvadditem(srvhandle,"charge_event")
      SET srvstat = uar_srvsetdouble(hchargeevent,"charge_event_id",ce->charge_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_id",ce->ext_master_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_cont_cd",ce->
       ext_master_event_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_id",ce->
       ext_master_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_cont_cd",ce->
       ext_master_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_event_id",ce->ext_parent_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_event_cont_cd",ce->
       ext_parent_event_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_id",ce->
       ext_parent_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_cont_cd",ce->
       ext_parent_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_id",ce->ext_item_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_cont_cd",ce->ext_item_event_cont_cd
       )
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_id",ce->ext_item_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_cont_cd",ce->
       ext_item_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"order_id",ce->order_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"person_id",ce->person_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_id",ce->encntr_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_bill_type_cd",ce->encntr_bill_type_cd)
      SET srvstat = uar_srvsetstring(hchargeevent,"accession",ce->encntr_bill_type_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"report_priority_cd",ce->report_priority_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"collection_priority_cd",ce->collection_priority_cd
       )
      SET srvstat = uar_srvsetstring(hchargeevent,"reference_nbr",ce->collection_priority_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"research_acct_id",ce->research_acct_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"abn_status_cd",ce->abn_status_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"perf_loc_cd",ce->perf_loc_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_type_cd",ce->encntr_type_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"med_service_cd",ce->med_service_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_org_id",ce->encntr_org_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"research_org_id",ce->research_org_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"fin_class_cd",ce->fin_class_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"health_plan_id",ce->health_plan_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"loc_nurse_unit_cd",ce->loc_nurse_unit_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ord_loc_cd",ce->ord_loc_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ord_phys_id",ce->ord_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"verify_phys_id",ce->verify_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"perf_phys_id",ce->perf_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ref_phys_id",ce->ref_phys_id)
      SET srvstat = uar_srvsetshort(hchargeevent,"cancelled_ind",ce->cancelled_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"no_charge_ind",ce->no_charge_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"misc_ind",ce->misc_ind)
      SET srvstat = uar_srvsetdouble(hchargeevent,"misc_price",ce->misc_price)
      SET srvstat = uar_srvsetstring(hchargeevent,"misc_desc",nullterm(ce->misc_desc))
      SET srvstat = uar_srvsetdouble(hchargeevent,"user_id",ce->user_id)
      SET srvstat = uar_srvsetshort(hchargeevent,"epsdt_ind",ce->epsdt_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"charge_event_act_qual",ce->charge_event_act_qual)
      FOR (y = 1 TO ce->charge_event_act_qual)
        SET hlist = uar_srvadditem(hchargeevent,"charge_event_act")
        SET srvstat = uar_srvsetshort(hlist,"phleb_group_ind",cea->phleb_group_ind)
        SET srvstat = uar_srvsetdouble(hlist,"cea_type_cd",cea->cea_type_cd)
        SET srvstat = uar_srvsetdouble(hlist,"service_resource_cd",cea->service_resource_cd)
        SET srvstat = uar_srvsetdouble(hlist,"service_loc_cd",cea->service_loc_cd)
        SET srvstat = uar_srvsetdate(hlist,"service_dt_tm",cnvtdatetime(cea->service_dt_tm))
        SET srvstat = uar_srvsetdate(hlist,"charge_dt_tm",cnvtdatetime(cea->charge_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist,"charge_type_cd",cea->charge_type_cd)
        SET srvstat = uar_srvsetdouble(hlist,"alpha_nomen_id",cea->alpha_nomen_id)
        SET srvstat = uar_srvsetlong(hlist,"quantity",cea->quantity)
        SET srvstat = uar_srvsetdouble(hlist,"rx_quantity",cea->rx_quantity)
        SET srvstat = uar_srvsetstring(hlist,"result",nullterm(cea->result))
        SET srvstat = uar_srvsetdouble(hlist,"units",cea->units)
        SET srvstat = uar_srvsetlong(hlist,"unit_type_cd",cea->unit_type_cd)
        SET srvstat = uar_srvsetdouble(hlist,"reason_cd",cea->reason_cd)
        SET srvstat = uar_srvsetdouble(hlist,"accession_id",cea->accession_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_prsnl_id",cea->cea_prsnl_id)
        SET srvstat = uar_srvsetdouble(hlist,"position_cd",cea->position_cd)
        SET srvstat = uar_srvsetshort(hlist,"repeat_ind",cea->repeat_ind)
        SET srvstat = uar_srvsetshort(hlist,"misc_ind",cea->misc_ind)
        SET srvstat = uar_srvsetstring(hlist,"cea_misc1",nullterm(cea->cea_misc1))
        SET srvstat = uar_srvsetstring(hlist,"cea_misc2",nullterm(cea->cea_misc2))
        SET srvstat = uar_srvsetstring(hlist,"cea_misc3",nullterm(cea->cea_misc3))
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc1_id",cea->cea_misc1_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc2_id",cea->cea_misc2_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc3_id",cea->cea_misc3_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc4_id",cea->cea_misc4_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc5_id",cea->cea_misc5_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc6_id",cea->cea_misc6_id)
        SET srvstat = uar_srvsetdouble(hlist,"cea_misc7_id",cea->cea_misc7_id)
        SET srvstat = uar_srvsetshort(hlist,"prsnl_qual",cea->prsnl_qual)
        FOR (z = 1 TO cea->prsnl_qual)
          SET hlist2 = uar_srvadditem(hlist,"prsnl")
          SET srvstat = uar_srvsetdouble(hlist2,"prsnl_id",ceap->prsnl_id)
          SET srvstat = uar_srvsetdouble(hlist2,"prsnl_type_cd",ceap->prsnl_type_cd)
        ENDFOR
        SET srvstat = uar_srvsetdouble(hlist,"REFERENCE_RANGE_FACTOR_ID",cea->
         reference_range_factor_id)
        SET srvstat = uar_srvsetdouble(hlist,"PATIENT_LOC_CD",cea->patient_loc_cd)
        SET srvstat = uar_srvsetdate(hlist,"IN_TRANSIT_DT_TM",cnvtdatetime(cea->in_transit_dt_tm))
        SET srvstat = uar_srvsetdate(hlist,"IN_LAB_DT_TM",cnvtdatetime(cea->in_lab_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist,"CEA_PRSNL_TYPE_CD",cea->cea_prsnl_type_cd)
        SET srvstat = uar_srvsetdouble(hlist,"CEA_SERVICE_RESOURCE_CD",cea->cea_service_resource_cd)
        SET srvstat = uar_srvsetdate(hlist,"ceact_dt_tm",cnvtdatetime(cea->ceact_dt_tm))
        SET srvstat = uar_srvsetlong(hlist,"ELAPSED_TIME",cea->elapsed_time)
        SET srvstat = uar_srvsetdouble(hlist,"CEA_LOC_CD",cea->cea_loc_cd)
        SET srvstat = uar_srvsetdouble(hlist,"priority_cd",cea->priority_cd)
        SET srvstat = uar_srvsetshort(hlist,"patient_responsibility_flag",cea->
         patient_responsibility_flag)
        SET srvstat = uar_srvsetdouble(hlist,"item_deductible_amt",cea->item_deductible_amt)
      ENDFOR
      SET htemphandle = uar_srvgetstruct(hchargeevent,"mods")
      FOR (y = 1 TO size(ce->mods.charge_mods,5))
        SET hlist = uar_srvadditem(htemphandle,"charge_mods")
        SET srvstat = uar_srvsetdouble(hlist,"charge_event_mod_type_cd",cem->charge_event_mod_type_cd
         )
        SET srvstat = uar_srvsetdouble(hlist,"charge_mod_type_cd",cem->charge_mod_type_cd)
        SET srvstat = uar_srvsetstring(hlist,"field1",nullterm(cem->field1))
        SET srvstat = uar_srvsetstring(hlist,"field2",nullterm(cem->field2))
        SET srvstat = uar_srvsetstring(hlist,"field3",nullterm(cem->field3))
        SET srvstat = uar_srvsetstring(hlist,"field4",nullterm(cem->field4))
        SET srvstat = uar_srvsetstring(hlist,"field5",nullterm(cem->field5))
        SET srvstat = uar_srvsetstring(hlist,"field6",nullterm(cem->field6))
        SET srvstat = uar_srvsetstring(hlist,"field7",nullterm(cem->field7))
        SET srvstat = uar_srvsetstring(hlist,"field8",nullterm(cem->field8))
        SET srvstat = uar_srvsetstring(hlist,"field9",nullterm(cem->field9))
        SET srvstat = uar_srvsetstring(hlist,"field10",nullterm(cem->field10))
        SET srvstat = uar_srvsetdouble(hlist,"field1_id",cem->field1_id)
        SET srvstat = uar_srvsetdouble(hlist,"field2_id",cem->field2_id)
        SET srvstat = uar_srvsetdouble(hlist,"field3_id",cem->field3_id)
        SET srvstat = uar_srvsetdouble(hlist,"field4_id",cem->field4_id)
        SET srvstat = uar_srvsetdouble(hlist,"field5_id",cem->field5_id)
        SET srvstat = uar_srvsetdouble(hlist,"nomen_id",cem->nomen_id)
        SET srvstat = uar_srvsetdouble(hlist,"cm1_nbr",cem->cm1_nbr)
      ENDFOR
      FOR (y = 1 TO size(ce->parent_events,5))
        SET hlist = uar_srvadditem(hchargeevent,"parent_events")
        SET srvstat = uar_srvsetdouble(hlist,"ext_p_ref_id",cepe->ext_p_ref_id)
        SET srvstat = uar_srvsetdouble(hlist,"ext_p_ref_cd",cepe->ext_p_ref_cd)
        SET srvstat = uar_srvsetdouble(hlist,"ext_i_ref_id",cepe->ext_i_ref_id)
        SET srvstat = uar_srvsetdouble(hlist,"ext_i_ref_cd",cepe->ext_i_ref_cd)
      ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE performfullcredit(dummy)
   DECLARE afcprofitcnt = i2 WITH protect, noconstant(0)
   DECLARE afcinterfacecnt = i2 WITH protect, noconstant(0)
   IF (size(celist->charges,5) > 0)
    SET stat = initrec(addcreditreq)
    SET stat = initrec(addcreditrep)
    SET stat = initrec(afcprofit_req)
    SET stat = initrec(afcinterfacecharge_req)
    SET stat = initrec(afcinterfacecharge_rep)
    SET addcreditreq->charge_qual = size(celist->charges,5)
    SET stat = alterlist(addcreditreq->charge,size(celist->charges,5))
    FOR (lcloop = 1 TO size(celist->charges,5))
     SET addcreditreq->charge[lcloop].charge_item_id = celist->charges[lcloop].charge_item_id
     SET addcreditreq->charge[lcloop].reason_comment = uar_i18ngetmessage(i18nhandle,"k2",
      "Credit applied by afc_post_inbound_charge")
    ENDFOR
    EXECUTE afc_add_credit  WITH replace("REQUEST",addcreditreq), replace("REPLY",addcreditrep)
    IF ((addcreditrep->status_data.status="S"))
     SET reply->charge_event_qual += size(celist->charges,5)
     SET stat = alterlist(reply->charge_event,reply->charge_event_qual)
     SET reply->charge_event[reply->charge_event_qual].charge_event_id = dceid
     SET reply->status_data.status = "S"
    ENDIF
    IF ((addcreditrep->charge_qual > 0))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(addcreditrep->charge_qual)),
       interface_file i
      PLAN (d1)
       JOIN (i
       WHERE (i.interface_file_id=addcreditrep->charge[d1.seq].interface_file_id))
      DETAIL
       IF (i.profit_type_cd > 0)
        afcprofitcnt += 1, stat = alterlist(afcprofit_req->charges,afcprofitcnt), afcprofit_req->
        remove_commit_ind = 1,
        afcprofit_req->charges[afcprofitcnt].charge_item_id = addcreditrep->charge[d1.seq].
        charge_item_id
       ELSEIF (i.realtime_ind=1)
        afcinterfacecnt += 1, stat = alterlist(afcinterfacecharge_req->interface_charge,
         afcinterfacecnt), afcinterfacecharge_req->interface_charge[afcinterfacecnt].charge_item_id
         = addcreditrep->charge[d1.seq].charge_item_id
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (size(afcprofit_req->charges,5) > 0)
     CALL callasync(0)
    ENDIF
    IF (size(afcinterfacecharge_req->interface_charge,5) > 0)
     EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_req), replace(
      "REPLY",afcinterfacecharge_rep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE nodebitfound(dummy)
   SET stat = initrec(g_srvproperties)
   SET stat = initrec(g_cs13028)
   SET stat = initrec(addchargeeventreq)
   SET stat = initrec(addchargeeventrep)
   SET stat = initrec(cssrvaddchargereq)
   SET g_srvproperties->logreqrep = 0
   SET g_cs13028->cr = uar_get_code_by("MEANING",13028,"CR")
   SET g_cs13028->dr = uar_get_code_by("MEANING",13028,"DR")
   SET charge_event_qual = 1
   SET stat = alterlist(addchargeeventreq->charge_event,1)
   SET addchargeeventreq->charge_event[1].ext_master_event_id = uar_srvgetdouble(hchargeevent,
    "ext_master_event_id")
   SET addchargeeventreq->charge_event[1].ext_master_event_cont_cd = uar_srvgetdouble(hchargeevent,
    "ext_master_event_cont_cd")
   SET addchargeeventreq->charge_event[1].ext_master_reference_id = uar_srvgetdouble(hchargeevent,
    "ext_master_reference_id")
   SET addchargeeventreq->charge_event[1].ext_master_reference_cont_cd = uar_srvgetdouble(
    hchargeevent,"ext_master_reference_cont_cd")
   SET addchargeeventreq->charge_event[1].ext_parent_event_id = uar_srvgetdouble(hchargeevent,
    "ext_parent_event_id")
   SET addchargeeventreq->charge_event[1].ext_parent_event_cont_cd = uar_srvgetdouble(hchargeevent,
    "ext_parent_event_cont_cd")
   SET addchargeeventreq->charge_event[1].ext_parent_reference_id = uar_srvgetdouble(hchargeevent,
    "ext_parent_reference_id")
   SET addchargeeventreq->charge_event[1].ext_parent_reference_cont_cd = uar_srvgetdouble(
    hchargeevent,"ext_parent_reference_cont_cd")
   SET addchargeeventreq->charge_event[1].ext_item_event_id = uar_srvgetdouble(hchargeevent,
    "ext_master_event_id")
   SET addchargeeventreq->charge_event[1].ext_item_event_cont_cd = uar_srvgetdouble(hchargeevent,
    "ext_item_event_cont_cd")
   SET addchargeeventreq->charge_event[1].ext_item_reference_id = uar_srvgetdouble(hchargeevent,
    "ext_item_reference_id")
   SET addchargeeventreq->charge_event[1].ext_item_reference_cont_cd = uar_srvgetdouble(hchargeevent,
    "ext_item_reference_cont_cd")
   SET addchargeeventreq->charge_event[1].order_id = uar_srvgetdouble(hchargeevent,"order_id")
   SET addchargeeventreq->charge_event[1].person_id = uar_srvgetdouble(hchargeevent,"person_id")
   SET addchargeeventreq->charge_event[1].encntr_id = uar_srvgetdouble(hchargeevent,"encntr_id")
   SET addchargeeventreq->charge_event[1].accession = uar_srvgetstringptr(hchargeevent,"accession")
   SET addchargeeventreq->charge_event[1].report_priority_cd = uar_srvgetdouble(hchargeevent,
    "report_priority_cd")
   SET addchargeeventreq->charge_event[1].collection_priority_cd = uar_srvgetdouble(hchargeevent,
    "collection_priority_cd")
   SET addchargeeventreq->charge_event[1].reference_nbr = uar_srvgetstringptr(hchargeevent,
    "reference_nbr")
   SET addchargeeventreq->charge_event[1].research_acct_id = uar_srvgetdouble(hchargeevent,
    "research_acct_id")
   SET addchargeeventreq->charge_event[1].abn_status_cd = uar_srvgetdouble(hchargeevent,
    "abn_status_cd")
   SET addchargeeventreq->charge_event[1].perf_loc_cd = uar_srvgetdouble(hchargeevent,"perf_loc_cd")
   SET addchargeeventreq->charge_event[1].health_plan_id = uar_srvgetdouble(hchargeevent,
    "health_plan_id")
   SET addchargeeventreq->charge_event[1].cancelled_ind = uar_srvgetshort(hchargeevent,
    "cancelled_ind")
   SET addchargeeventreq->charge_event[1].epsdt_ind = uar_srvgetshort(hchargeevent,"epsdt_ind")
   EXECUTE afc_add_charge_event  WITH replace("REQUEST",addchargeeventreq), replace("REPLY",
    addchargeeventrep)
   IF ((addchargeeventrep->status_data.status="S"))
    SET stat = alterlist(cssrvaddchargereq->charges,1)
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE (b.ext_parent_reference_id=addchargeeventreq->charge_event[1].ext_item_reference_id)
      AND (b.ext_parent_contributor_cd=addchargeeventreq->charge_event[1].ext_item_reference_cont_cd)
      AND b.ext_child_reference_id=0
      AND b.ext_child_contributor_cd=0
      AND b.active_ind=1
     DETAIL
      cssrvaddchargereq->charges[1].bill_item_id = b.bill_item_id, cssrvaddchargereq->charges[1].
      charge_description = b.ext_description
     WITH nocounter
    ;end select
    SET cssrvaddchargereq->charges[1].charge_event_id = addchargeeventrep->charge_event[1].
    charge_event_id
    SET cssrvaddchargereq->charges[1].item_quantity = uar_srvgetlong(hchargeeventact,"quantity")
    SET cssrvaddchargereq->charges[1].charge_type_cd = uar_srvgetdouble(hchargeeventact,
     "charge_type_cd")
    SET cssrvaddchargereq->charges[1].service_dt_tm = servicedates->dtorigservicedate
    SET cssrvaddchargereq->charges[1].order_id = uar_srvgetdouble(hchargeevent,"order_id")
    SET cssrvaddchargereq->charges[1].person_id = uar_srvgetdouble(hchargeevent,"person_id")
    SET cssrvaddchargereq->charges[1].encntr_id = uar_srvgetdouble(hchargeevent,"encntr_id")
    SET cssrvaddchargereq->charges[1].process_flg = 13
    EXECUTE cs_srv_add_charge  WITH replace("REPLY",cssrvaddchargereq)
   ENDIF
   SET reply->status_data.status = "S"
   SET reply->charge_event_qual += 1
   SET stat = alterlist(reply->charge_event,reply->charge_event_qual)
   SET reply->charge_event[reply->charge_event_qual].charge_event_id = 0.0
   SET reply->status_data.subeventstatus[1].operationname = "No Matching Debit Charge"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 END ;Subroutine
 SUBROUTINE callasync(dummy_var)
   CALL logmessage("callAsync","Entering...",log_debug)
   EXECUTE srvrtl
   EXECUTE crmrtl
   DECLARE happ = i4 WITH private, noconstant(0)
   DECLARE htask = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE lcrmstatus = i4 WITH private, noconstant(0)
   IF (uar_crmbeginapp(4050200,happ) != 0)
    CALL logmessage("callAsync","Begin application [4050200] failed",log_error)
    RETURN
   ENDIF
   IF (uar_crmbegintask(happ,4050100,htask) != 0)
    CALL uar_crmendapp(happ)
    CALL logmessage("callAsync","Begin task [4050100] failed",log_error)
    RETURN
   ENDIF
   IF (uar_crmbeginreq(htask,"pft_nt_chrg_billing",4050157,hreq) != 0)
    CALL uar_crmendapp(happ)
    CALL uar_crmendtask(htask)
    CALL logmessage("callAsync","Begin request [4050157] failed",log_error)
    RETURN
   ENDIF
   SET hrequest = uar_crmgetrequest(hreq)
   FOR (i = 1 TO size(afcprofit_req->charges,5))
    SET hcharge = uar_srvadditem(hrequest,"charges")
    SET stat = uar_srvsetdouble(hcharge,"charge_item_id",afcprofit_req->charges[i].charge_item_id)
   ENDFOR
   CALL logmessage("callAsync",build("Sending [",size(afcprofit_req->charges,5),
     "] charges to charge posting..."),log_debug)
   SET lcrmstatus = uar_crmperform(hreq)
   IF (lcrmstatus != 0)
    CALL logmessage("callAsync",build("Performing request [4050157] failed : status [",lcrmstatus,"]"
      ),log_error)
    CALL uar_crmendreq(hreq)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN
   ENDIF
   CALL uar_crmendreq(hreq)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
 END ;Subroutine
 FREE SET addcreditreq
 FREE SET addcreditrep
 FREE SET getinterfacefilerep
 FREE SET afcprofit_req
 FREE SET afcinterfacecharge_req
 FREE SET afcinterfacecharge_rep
 FREE SET addchargeeventreq
 FREE SET addchargeeventrep
 FREE SET celist
 FREE SET dropchargerequest
END GO
