CREATE PROGRAM dm_cmb_drop_charge_sync:dba
 DECLARE dm_cmb_drop_charge_sync_version = vc WITH private, noconstant("CHARGSRV-14536.FT.020")
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
 RECORD reply(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 charge_event_id = f8
     2 tier_group_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
     2 primaryhealthplans[*]
       3 health_plan_id = f8
       3 priority_sequence = i4
     2 primaryhealthplancount = f8
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
         4 activity_dt_tm = dq8
         4 charge_mod_source_cd = f8
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
       3 activity_sub_type_cd = f8
       3 provider_specialty_cd = f8
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
       3 original_org_id = f8
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
           5 activity_dt_tm = dq8
           5 charge_mod_source_cd = f8
       3 offset_charge_item_id = f8
       3 patient_responsibility_flag = i2
       3 item_deductible_amt = f8
 )
 FREE RECORD dropchargereply
 RECORD dropchargereply(
   1 charge_qual = i4
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
     2 item_price_adj_amt = f8
     2 activity_type_cd = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
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
     2 original_org_id = f8
     2 mods
       3 charge_mod_qual = i2
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
 FREE RECORD eventreq
 RECORD eventreq(
   1 charge[*]
     2 charge_event_id = f8
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE mcnt = i4 WITH public, noconstant(0)
 DECLARE ceacnt = i4 WITH public, noconstant(0)
 DECLARE ceapcnt = i4 WITH public, noconstant(0)
 DECLARE cecnt = i4 WITH public, noconstant(0)
 DECLARE cemcnt = i4 WITH public, noconstant(0)
 DECLARE chrgcnt = i4 WITH public, noconstant(0)
 DECLARE cmcnt = i4 WITH public, noconstant(0)
 DECLARE appid = i4 WITH public, noconstant(0)
 DECLARE taskid = i4 WITH public, noconstant(0)
 DECLARE reqid = i4 WITH public, noconstant(0)
 DECLARE iret = i4 WITH public, noconstant(0)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE srvstat = i4 WITH public, noconstant(0)
 DECLARE hchargeevent = i4 WITH public, noconstant(0)
 DECLARE hlist3 = i4 WITH public, noconstant(0)
 DECLARE hlist4 = i4 WITH public, noconstant(0)
 DECLARE hlist5 = i4 WITH public, noconstant(0)
 DECLARE hlist6 = i4 WITH public, noconstant(0)
 DECLARE htemphandle = i4 WITH public, noconstant(0)
 DECLARE lceloop = i4 WITH public, noconstant(0)
 DECLARE lcealoop = i4 WITH public, noconstant(0)
 DECLARE lceaploop = i4 WITH public, noconstant(0)
 DECLARE lcemloop = i4 WITH public, noconstant(0)
 DECLARE lchrgloop = i4 WITH public, noconstant(0)
 DECLARE lcmloop = i4 WITH public, noconstant(0)
 DECLARE hrcharges = i4 WITH public, noconstant(0)
 DECLARE hrchild = i4 WITH public, noconstant(0)
 DECLARE hrchildjr = i4 WITH public, noconstant(0)
 DECLARE num_charges = i4 WITH public, noconstant(0)
 DECLARE num_charge_mods = i4 WITH public, noconstant(0)
 DECLARE lchargeloop = i4 WITH public, noconstant(0)
 DECLARE lchargemodloop = i4 WITH public, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant(" ")
 DECLARE addceatoreq = i2 WITH protect, noconstant(true)
 DECLARE hasreverseactivity = i2 WITH protect, noconstant(false)
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE hpsize = i4 WITH public, noconstant(0)
 DECLARE hpcount = i4 WITH public, noconstant(0)
 DECLARE hpstruct = i4 WITH public, noconstant(0)
 DECLARE hpcloop = i4 WITH public, noconstant(0)
 DECLARE hpcntloop = i4 WITH public, noconstant(0)
 SET appid = 951020
 SET taskid = 951020
 SET reqid = 951360
 SET stat = uar_get_meaning_by_codeset(13028,"CR",1,g_cs13028->cr)
 SET stat = uar_get_meaning_by_codeset(13028,"DR",1,g_cs13028->dr)
 IF ( NOT (validate(cs13029_collected_cd)))
  DECLARE cs13029_collected_cd = f8 WITH protect, constant(getcodevalue(13029,"COLLECTED",0))
 ENDIF
 IF ( NOT (validate(cs13029_reverse_cd)))
  DECLARE cs13029_reverse_cd = f8 WITH protect, constant(getcodevalue(13029,"REVERSE",0))
 ENDIF
 IF ( NOT (validate(cs13029_inlab_cd)))
  DECLARE cs13029_inlab_cd = f8 WITH protect, constant(getcodevalue(13029,"IN LAB",0))
 ENDIF
 IF ( NOT (validate(cs13029_ordered_cd)))
  DECLARE cs13029_ordered_cd = f8 WITH protect, constant(getcodevalue(13029,"ORDERED",0))
 ENDIF
 IF ( NOT (validate(cs13029_uncoluninlab_cd)))
  DECLARE cs13029_uncoluninlab_cd = f8 WITH protect, constant(getcodevalue(13029,"UNCOLUNINLAB",0))
 ENDIF
 IF ( NOT (validate(cs13029_cancel_cd)))
  DECLARE cs13029_cancel_cd = f8 WITH protect, constant(getcodevalue(13029,"CANCEL",0))
 ENDIF
 IF ( NOT (validate(cs13019_bill_code)))
  DECLARE cs13019_bill_code = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs4518006_manually_add_cd)))
  DECLARE cs4518006_manually_add_cd = f8 WITH protect, constant(getcodevalue(4518006,"MANUALLY_ADD",0
    ))
 ENDIF
 IF ( NOT (validate(cs4518006_copyfromcem_cd)))
  DECLARE cs4518006_copyfromcem_cd = f8 WITH protect, constant(getcodevalue(4518006,"COPYFROMCEM",0))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM charge c,
   (dummyt d  WITH seq = value(size(request->charge,5)))
  PLAN (d)
   JOIN (c
   WHERE (c.charge_item_id=request->charge[d.seq].charge_item_id))
  ORDER BY c.charge_event_id
  HEAD REPORT
   mcnt = 0, stat = alterlist(eventreq->charge,20)
  HEAD c.charge_event_id
   mcnt += 1
   IF (mcnt > size(eventreq->charge,5))
    stat = alterlist(eventreq->charge,(mcnt+ 20))
   ENDIF
   eventreq->charge[mcnt].charge_event_id = c.charge_event_id
  FOOT REPORT
   stat = alterlist(eventreq->charge,mcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM charge_event ce,
   charge_event_act cea,
   charge_event_act_prsnl ceap,
   (dummyt d  WITH seq = value(size(eventreq->charge,5)))
  PLAN (d)
   JOIN (ce
   WHERE (ce.charge_event_id=eventreq->charge[d.seq].charge_event_id))
   JOIN (cea
   WHERE cea.charge_event_id=ce.charge_event_id
    AND cea.active_ind=true)
   JOIN (ceap
   WHERE (ceap.charge_event_act_id= Outerjoin(cea.charge_event_act_id)) )
  ORDER BY ce.charge_event_id, cea.insert_dt_tm DESC, cea.charge_event_act_id DESC
  HEAD REPORT
   mcnt = 0, stat = alterlist(dropchargerequest->charge_event,20)
  HEAD ce.charge_event_id
   mcnt += 1, ceacnt = 0, ceapcnt = 0,
   hasreverseactivity = false
   IF (mcnt > size(dropchargerequest->charge_event,5))
    stat = alterlist(dropchargerequest->charge_event,(mcnt+ 20))
   ENDIF
   dropchargerequest->charge_event[mcnt].charge_event_id = ce.charge_event_id, dropchargerequest->
   charge_event[mcnt].ext_master_event_id = ce.ext_m_event_id, dropchargerequest->charge_event[mcnt].
   ext_master_event_cont_cd = ce.ext_m_event_cont_cd,
   dropchargerequest->charge_event[mcnt].ext_master_reference_id = ce.ext_m_reference_id,
   dropchargerequest->charge_event[mcnt].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd,
   dropchargerequest->charge_event[mcnt].ext_parent_event_id = ce.ext_p_event_id,
   dropchargerequest->charge_event[mcnt].ext_parent_event_cont_cd = ce.ext_p_event_cont_cd,
   dropchargerequest->charge_event[mcnt].ext_parent_reference_id = ce.ext_p_reference_id,
   dropchargerequest->charge_event[mcnt].ext_parent_reference_cont_cd = ce.ext_p_reference_cont_cd,
   dropchargerequest->charge_event[mcnt].ext_item_event_id = ce.ext_i_event_id, dropchargerequest->
   charge_event[mcnt].ext_item_event_cont_cd = ce.ext_i_event_cont_cd, dropchargerequest->
   charge_event[mcnt].ext_item_reference_id = ce.ext_i_reference_id,
   dropchargerequest->charge_event[mcnt].ext_item_reference_cont_cd = ce.ext_i_reference_cont_cd,
   dropchargerequest->charge_event[mcnt].order_id = ce.order_id
   IF ((request->to_person_id > 0))
    dropchargerequest->charge_event[mcnt].person_id = request->to_person_id
   ELSE
    dropchargerequest->charge_event[mcnt].person_id = ce.person_id
   ENDIF
   dropchargerequest->charge_event[mcnt].encntr_id = request->to_encntr_id, hpsize = validate(request
    ->primaryhealthplancount,0), stat = alterlist(dropchargerequest->charge_event[mcnt].
    primaryhealthplans,hpsize),
   hpcount = 0
   IF (hpsize > 0)
    FOR (hpcntloop = 1 TO hpsize)
      hpcount += 1, dropchargerequest->charge_event[mcnt].primaryhealthplans[hpcount].health_plan_id
       = validate(request->primaryhealthplans[hpcount].health_plan_id,0.0), dropchargerequest->
      charge_event[mcnt].primaryhealthplans[hpcount].priority_sequence = validate(request->
       primaryhealthplans[hpcount].priority_sequence,0)
    ENDFOR
   ENDIF
   dropchargerequest->charge_event[mcnt].primaryhealthplancount = validate(request->
    primaryhealthplancount,0), dropchargerequest->charge_event[mcnt].health_plan_id = validate(
    request->health_plan_id,0), dropchargerequest->charge_event[mcnt].accession = ce.accession,
   dropchargerequest->charge_event[mcnt].report_priority_cd = ce.report_priority_cd,
   dropchargerequest->charge_event[mcnt].collection_priority_cd = ce.collection_priority_cd,
   dropchargerequest->charge_event[mcnt].reference_nbr = ce.reference_nbr,
   dropchargerequest->charge_event[mcnt].research_acct_id = ce.research_account_id, dropchargerequest
   ->charge_event[mcnt].abn_status_cd = ce.abn_status_cd, dropchargerequest->charge_event[mcnt].
   perf_loc_cd = ce.perf_loc_cd,
   dropchargerequest->charge_event[mcnt].cancelled_ind = ce.cancelled_ind, dropchargerequest->
   charge_event[mcnt].epsdt_ind = ce.epsdt_ind
  HEAD cea.charge_event_act_id
   indx = 0, ipos = 0, addceatoreq = true
   IF (cea.cea_type_cd=cs13029_reverse_cd)
    hasreverseactivity = true, addceatoreq = false
   ENDIF
   IF (hasreverseactivity=true
    AND  NOT (cea.cea_type_cd IN (cs13029_collected_cd, cs13029_inlab_cd, cs13029_ordered_cd)))
    addceatoreq = false
   ENDIF
   IF (cea.cea_type_cd=cs13029_collected_cd)
    indx = locateval(ipos,1,ceacnt,cea.cea_type_cd,dropchargerequest->charge_event[mcnt].
     charge_event_act[ipos].cea_type_cd)
    IF (indx > 0)
     addceatoreq = false
    ENDIF
   ELSEIF (cea.cea_type_cd=cs13029_inlab_cd)
    indx = locateval(ipos,1,ceacnt,cea.cea_type_cd,dropchargerequest->charge_event[mcnt].
     charge_event_act[ipos].cea_type_cd)
    IF (indx > 0)
     addceatoreq = false
    ENDIF
   ELSEIF (cea.cea_type_cd IN (cs13029_uncoluninlab_cd, cs13029_cancel_cd))
    addceatoreq = false
   ENDIF
   IF (addceatoreq)
    ceacnt += 1, ceapcnt = 0, stat = alterlist(dropchargerequest->charge_event[mcnt].charge_event_act,
     ceacnt),
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_event_act_id = cea
    .charge_event_act_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_type_cd
     = cea.cea_type_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_prsnl_id
     = cea.cea_prsnl_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_dt_tm = cea.service_dt_tm,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_loc_cd = cea
    .service_loc_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_dt_tm =
    cea.charge_dt_tm,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_type_cd = cea
    .charge_type_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].alpha_nomen_id =
    cea.alpha_nomen_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].quantity = cea
    .quantity,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].result = cea.result,
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
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc2_id = cea.cea_misc2_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc3_id = cea.cea_misc3_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc4_id = cea.item_price,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc5_id = cea.cea_misc5_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc6_id = cea.cea_misc6_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc7_id = cea.cea_misc7_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].patient_loc_cd = cea
    .patient_loc_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].in_lab_dt_tm = cea.in_lab_dt_tm,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].priority_cd = cea.priority_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_resource_cd = cea
    .service_resource_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].patient_responsibility_flag = cea
    .patient_responsibility_flag, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
    reference_range_factor_id = cea.reference_range_factor_id, dropchargerequest->charge_event[mcnt].
    charge_event_act[ceacnt].item_deductible_amt = cea.item_deductible_amt
   ENDIF
  DETAIL
   indx = 0, ipos = 0, indx = locateval(ipos,1,ceacnt,cea.charge_event_act_id,dropchargerequest->
    charge_event[mcnt].charge_event_act[ipos].charge_event_act_id)
   IF (indx > 0)
    ceapcnt += 1, stat = alterlist(dropchargerequest->charge_event[mcnt].charge_event_act[indx].prsnl,
     ceapcnt), dropchargerequest->charge_event[mcnt].charge_event_act[indx].prsnl[ceapcnt].prsnl_id
     = ceap.prsnl_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[indx].prsnl[ceapcnt].prsnl_type_cd = ceap
    .prsnl_type_cd
   ENDIF
  FOOT  cea.charge_event_act_id
   IF (ceacnt > 0)
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl_qual = ceapcnt
   ENDIF
  FOOT  ce.charge_event_id
   dropchargerequest->charge_event[mcnt].charge_event_act_qual = ceacnt
  FOOT REPORT
   stat = alterlist(dropchargerequest->charge_event,mcnt), dropchargerequest->charge_event_qual =
   mcnt, dropchargerequest->action_type = "SNC"
  WITH nocounter
 ;end select
 IF (mcnt > 0)
  SELECT INTO "nl:"
   FROM charge_event_mod cem,
    (dummyt d  WITH seq = value(mcnt))
   PLAN (d)
    JOIN (cem
    WHERE (cem.charge_event_id=dropchargerequest->charge_event[d.seq].charge_event_id)
     AND cem.active_ind=1)
   ORDER BY cem.charge_event_id
   HEAD cem.charge_event_id
    cemcnt = 0
   DETAIL
    cemcnt += 1
    IF (mod(cemcnt,20)=1)
     stat = alterlist(dropchargerequest->charge_event[d.seq].mods.charge_mods,(cemcnt+ 19))
    ENDIF
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].charge_event_id = cem
    .charge_event_id, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].
    charge_event_mod_type_cd = cem.charge_event_mod_type_cd, dropchargerequest->charge_event[d.seq].
    mods.charge_mods[cemcnt].field1 = cem.field1,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field2 = cem.field2,
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
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].cm1_nbr = cem.cm1_nbr,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].activity_dt_tm = cem
    .activity_dt_tm, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].
    charge_mod_source_cd = cs4518006_copyfromcem_cd
   FOOT  cem.charge_event_id
    stat = alterlist(dropchargerequest->charge_event[d.seq].mods.charge_mods,cemcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event ce,
    charge c,
    charge_mod cm,
    (dummyt d  WITH seq = value(mcnt))
   PLAN (d)
    JOIN (ce
    WHERE (ce.charge_event_id=dropchargerequest->charge_event[d.seq].charge_event_id)
     AND ce.active_ind=1)
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id
     AND c.active_ind=1
     AND (c.charge_type_cd=g_cs13028->dr)
     AND c.offset_charge_item_id=0
     AND c.process_flg != 1)
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND cm.active_ind=1
     AND cm.charge_mod_type_cd=cs13019_bill_code
     AND cm.charge_mod_source_cd=cs4518006_manually_add_cd)
   ORDER BY ce.charge_event_id, c.charge_item_id
   HEAD ce.charge_event_id
    chrgcnt = 0
   HEAD c.charge_item_id
    chrgcnt += 1
    IF (mod(chrgcnt,10)=1)
     stat = alterlist(dropchargerequest->charge_event[d.seq].charges,(chrgcnt+ 9))
    ENDIF
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].charge_item_id = c.charge_item_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].charge_act_id = c.charge_event_act_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].charge_event_id = c.charge_event_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].bill_item_id = c.bill_item_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].charge_description = c.charge_description,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].price_sched_id = c.price_sched_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].payor_id = c.payor_id, dropchargerequest
    ->charge_event[d.seq].charges[chrgcnt].item_quantity = c.item_quantity, dropchargerequest->
    charge_event[d.seq].charges[chrgcnt].item_price = c.item_price,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].item_extended_price = c
    .item_extended_price, dropchargerequest->charge_event[d.seq].charges[chrgcnt].charge_type_cd = c
    .charge_type_cd, dropchargerequest->charge_event[d.seq].charges[chrgcnt].suspense_rsn_cd = c
    .suspense_rsn_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].reason_comment = c.reason_comment,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].posted_cd = c.posted_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].ord_phys_id = c.ord_phys_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].perf_phys_id = c.perf_phys_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].order_id = c.order_id, dropchargerequest
    ->charge_event[d.seq].charges[chrgcnt].beg_effective_dt_tm = c.beg_effective_dt_tm,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].person_id = c.person_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].encntr_id = c.encntr_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].admit_type_cd = c.admit_type_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].med_service_cd = c.med_service_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].institution_cd = c.institution_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].department_cd = c.department_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].section_cd = c.section_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].subsection_cd = c.subsection_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].level5_cd = c.level5_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].service_dt_tm = c.service_dt_tm,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].process_flg = c.process_flg,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].parent_charge_item_id = c
    .parent_charge_item_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].interface_id = c.interface_file_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].tier_group_cd = c.tier_group_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].def_bill_item_id = c.def_bill_item_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].verify_phys_id = c.verify_phys_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].gross_price = c.gross_price,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].discount_amount = c.discount_amount,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].research_acct_id = c.research_acct_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].activity_type_cd = c.activity_type_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].activity_sub_type_cd = c
    .activity_sub_type_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].cost_center_cd = c.cost_center_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].abn_status_cd = c.abn_status_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].perf_loc_cd = c.perf_loc_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].inst_fin_nbr = c.inst_fin_nbr,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].ord_loc_cd = c.ord_loc_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].fin_class_cd = c.fin_class_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].health_plan_id = c.health_plan_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].manual_ind = c.manual_ind,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].payor_type_cd = c.payor_type_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].item_interval_id = c.item_interval_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].list_price = c.item_list_price,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].list_price_sched_id = c
    .list_price_sched_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].epsdt_ind = c.epsdt_ind,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].ref_phys_id = c.ref_phys_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].alpha_nomen_id = c.alpha_nomen_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].server_process_flag = c
    .server_process_flag, dropchargerequest->charge_event[d.seq].charges[chrgcnt].
    offset_charge_item_id = c.offset_charge_item_id, dropchargerequest->charge_event[d.seq].charges[
    chrgcnt].patient_responsibility_flag = c.patient_responsibility_flag,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].item_deductible_amt = c
    .item_deductible_amt, cmcnt = 0
   DETAIL
    cmcnt += 1
    IF (mod(cmcnt,20)=1)
     stat = alterlist(dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods,(cmcnt
      + 19))
    ENDIF
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    charge_mod_type_cd = cm.charge_mod_type_cd, dropchargerequest->charge_event[d.seq].charges[
    chrgcnt].mods.charge_mods[cmcnt].charge_event_mod_type_cd = cm.charge_mod_type_cd,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field1 = cm
    .field1,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field2 = cm
    .field2, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field3
     = cm.field3, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    field4 = cm.field4,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field5 = cm
    .field5, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field6
     = cm.field6, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    field7 = cm.field7,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field8 = cm
    .field8, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field9
     = cm.field9, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    field10 = cm.field10,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field1_id = cm
    .field1_id, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    field2_id = cm.field2_id, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.
    charge_mods[cmcnt].field3_id = cm.field3_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].field4_id = cm
    .field4_id, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    field5_id = cm.field5_id, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.
    charge_mods[cmcnt].nomen_id = cm.nomen_id,
    dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].cm1_nbr = cm
    .cm1_nbr, dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods[cmcnt].
    charge_mod_source_cd = cm.charge_mod_source_cd, dropchargerequest->charge_event[d.seq].charges[
    chrgcnt].mods.charge_mods[cmcnt].activity_dt_tm = cm.activity_dt_tm
   FOOT  c.charge_item_id
    stat = alterlist(dropchargerequest->charge_event[d.seq].charges[chrgcnt].mods.charge_mods,cmcnt)
   FOOT  ce.charge_event_id
    stat = alterlist(dropchargerequest->charge_event[d.seq].charges,chrgcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(debug,0) > 0)
  CALL echorecord(dropchargerequest)
 ENDIF
 SET iret = uar_crmbeginapp(appid,happ)
 IF (iret=0)
  CALL echo("successful begin app")
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret=0)
   CALL echo("successful begin task")
   SET iret = uar_crmbeginreq(htask,"",reqid,hreq)
   IF (iret=0)
    SET hrequest = uar_crmgetrequest(hreq)
    IF (hrequest=0)
     CALL echo("Failed to get request struct")
     GO TO end_program
    ENDIF
    CALL echo("Begin UAR_Sets")
    SET srvstat = uar_srvsetstring(hrequest,"action_type",nullterm(dropchargerequest->action_type))
    SET srvstat = uar_srvsetshort(hrequest,"charge_event_qual",dropchargerequest->charge_event_qual)
    FOR (lceloop = 1 TO dropchargerequest->charge_event_qual)
      SET hchargeevent = uar_srvadditem(hrequest,"charge_event")
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_id",dropchargerequest->
       charge_event[lceloop].ext_master_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_event_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_master_event_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_id",dropchargerequest->
       charge_event[lceloop].ext_master_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_master_reference_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_master_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_event_id",dropchargerequest->
       charge_event[lceloop].ext_parent_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_event_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_parent_event_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_id",dropchargerequest->
       charge_event[lceloop].ext_parent_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_parent_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_id",dropchargerequest->
       charge_event[lceloop].ext_item_event_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_event_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_item_event_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_id",dropchargerequest->
       charge_event[lceloop].ext_item_reference_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ext_item_reference_cont_cd",dropchargerequest->
       charge_event[lceloop].ext_item_reference_cont_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"order_id",dropchargerequest->charge_event[lceloop]
       .order_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"person_id",dropchargerequest->charge_event[lceloop
       ].person_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_id",dropchargerequest->charge_event[lceloop
       ].encntr_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"PrimaryHealthPlanCount",validate(dropchargerequest
        ->charge_event[lceloop].primaryhealthplancount,0))
      IF (hpsize > 0)
       FOR (hpcloop = 1 TO hpsize)
         SET hpstruct = uar_srvadditem(hchargeevent,"PrimaryHealthPlans")
         SET srvstat = uar_srvsetdouble(hpstruct,"health_plan_id",validate(dropchargerequest->
           charge_event[lceloop].primaryhealthplans[hpcloop].health_plan_id,0.0))
         SET srvstat = uar_srvsetlong(hpstruct,"priority_sequence",validate(dropchargerequest->
           charge_event[lceloop].primaryhealthplans[hpcloop].priority_sequence,0))
       ENDFOR
      ELSE
       SET srvstat = uar_srvsetdouble(hchargeevent,"health_plan_id",dropchargerequest->charge_event[
        lceloop].health_plan_id)
      ENDIF
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_bill_type_cd",dropchargerequest->
       charge_event[lceloop].encntr_bill_type_cd)
      SET srvstat = uar_srvsetstring(hchargeevent,"accession",nullterm(dropchargerequest->
        charge_event[lceloop].accession))
      SET srvstat = uar_srvsetdouble(hchargeevent,"report_priority_cd",dropchargerequest->
       charge_event[lceloop].report_priority_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"collection_priority_cd",dropchargerequest->
       charge_event[lceloop].collection_priority_cd)
      SET srvstat = uar_srvsetstring(hchargeevent,"reference_nbr",nullterm(dropchargerequest->
        charge_event[lceloop].reference_nbr))
      SET srvstat = uar_srvsetdouble(hchargeevent,"research_acct_id",dropchargerequest->charge_event[
       lceloop].research_acct_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"abn_status_cd",dropchargerequest->charge_event[
       lceloop].abn_status_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"perf_loc_cd",dropchargerequest->charge_event[
       lceloop].perf_loc_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_type_cd",dropchargerequest->charge_event[
       lceloop].encntr_type_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"med_service_cd",dropchargerequest->charge_event[
       lceloop].med_service_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"encntr_org_id",dropchargerequest->charge_event[
       lceloop].encntr_org_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"research_org_id",dropchargerequest->charge_event[
       lceloop].research_org_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"fin_class_cd",dropchargerequest->charge_event[
       lceloop].fin_class_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"loc_nurse_unit_cd",dropchargerequest->
       charge_event[lceloop].loc_nurse_unit_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ord_loc_cd",dropchargerequest->charge_event[
       lceloop].ord_loc_cd)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ord_phys_id",dropchargerequest->charge_event[
       lceloop].ord_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"verify_phys_id",dropchargerequest->charge_event[
       lceloop].verify_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"perf_phys_id",dropchargerequest->charge_event[
       lceloop].perf_phys_id)
      SET srvstat = uar_srvsetdouble(hchargeevent,"ref_phys_id",dropchargerequest->charge_event[
       lceloop].ref_phys_id)
      SET srvstat = uar_srvsetshort(hchargeevent,"cancelled_ind",dropchargerequest->charge_event[
       lceloop].cancelled_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"no_charge_ind",dropchargerequest->charge_event[
       lceloop].no_charge_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"misc_ind",dropchargerequest->charge_event[lceloop].
       misc_ind)
      SET srvstat = uar_srvsetdouble(hchargeevent,"misc_price",dropchargerequest->charge_event[
       lceloop].misc_price)
      SET srvstat = uar_srvsetstring(hchargeevent,"misc_desc",nullterm(dropchargerequest->
        charge_event[lceloop].misc_desc))
      SET srvstat = uar_srvsetdouble(hchargeevent,"user_id",dropchargerequest->charge_event[lceloop].
       user_id)
      SET srvstat = uar_srvsetshort(hchargeevent,"epsdt_ind",dropchargerequest->charge_event[lceloop]
       .epsdt_ind)
      SET srvstat = uar_srvsetshort(hchargeevent,"charge_event_act_qual",dropchargerequest->
       charge_event[lceloop].charge_event_act_qual)
      FOR (lcealoop = 1 TO dropchargerequest->charge_event[lceloop].charge_event_act_qual)
        SET hlist3 = uar_srvadditem(hchargeevent,"charge_event_act")
        SET srvstat = uar_srvsetdouble(hlist3,"charge_event_act_id",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].charge_event_act_id)
        SET srvstat = uar_srvsetshort(hlist3,"phleb_group_ind",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].phleb_group_ind)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_type_cd",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].cea_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"service_resource_cd",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].service_resource_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"service_loc_cd",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].service_loc_cd)
        SET srvstat = uar_srvsetdate(hlist3,"service_dt_tm",cnvtdatetime(dropchargerequest->
          charge_event[lceloop].charge_event_act[lcealoop].service_dt_tm))
        SET srvstat = uar_srvsetdate(hlist3,"charge_dt_tm",cnvtdatetime(dropchargerequest->
          charge_event[lceloop].charge_event_act[lcealoop].charge_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist3,"charge_type_cd",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].charge_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"alpha_nomen_id",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].alpha_nomen_id)
        SET srvstat = uar_srvsetlong(hlist3,"quantity",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].quantity)
        SET srvstat = uar_srvsetdouble(hlist3,"rx_quantity",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].rx_quantity)
        SET srvstat = uar_srvsetstring(hlist3,"result",nullterm(dropchargerequest->charge_event[
          lceloop].charge_event_act[lcealoop].result))
        SET srvstat = uar_srvsetdouble(hlist3,"units",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].units)
        SET srvstat = uar_srvsetlong(hlist3,"unit_type_cd",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].unit_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"reason_cd",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].reason_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"accession_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].accession_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_prsnl_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_prsnl_id)
        SET srvstat = uar_srvsetdouble(hlist3,"position_cd",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].position_cd)
        SET srvstat = uar_srvsetshort(hlist3,"repeat_ind",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].repeat_ind)
        SET srvstat = uar_srvsetshort(hlist3,"misc_ind",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].misc_ind)
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc1",nullterm(dropchargerequest->charge_event[
          lceloop].charge_event_act[lcealoop].cea_misc1))
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc2",nullterm(dropchargerequest->charge_event[
          lceloop].charge_event_act[lcealoop].cea_misc2))
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc3",nullterm(dropchargerequest->charge_event[
          lceloop].charge_event_act[lcealoop].cea_misc3))
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc1_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc1_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc2_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc2_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc3_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc3_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc4_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc4_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc5_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc5_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc6_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc6_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc7_id",dropchargerequest->charge_event[lceloop]
         .charge_event_act[lcealoop].cea_misc7_id)
        SET srvstat = uar_srvsetshort(hlist3,"prsnl_qual",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].prsnl_qual)
        FOR (lceaploop = 1 TO dropchargerequest->charge_event[lceloop].charge_event_act[lcealoop].
        prsnl_qual)
          SET hlist4 = uar_srvadditem(hlist3,"prsnl")
          SET srvstat = uar_srvsetdouble(hlist4,"prsnl_id",dropchargerequest->charge_event[lceloop].
           charge_event_act[lcealoop].prsnl[lceaploop].prsnl_id)
          SET srvstat = uar_srvsetdouble(hlist4,"prsnl_type_cd",dropchargerequest->charge_event[
           lceloop].charge_event_act[lcealoop].prsnl[lceaploop].prsnl_type_cd)
        ENDFOR
        SET srvstat = uar_srvsetdouble(hlist3,"CHARGE_EVENT_ID",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].charge_event_id)
        SET srvstat = uar_srvsetdouble(hlist3,"REFERENCE_RANGE_FACTOR_ID",dropchargerequest->
         charge_event[lceloop].charge_event_act[lcealoop].reference_range_factor_id)
        SET srvstat = uar_srvsetdouble(hlist3,"PATIENT_LOC_CD",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].patient_loc_cd)
        SET srvstat = uar_srvsetdate(hlist3,"IN_TRANSIT_DT_TM",cnvtdatetime(dropchargerequest->
          charge_event[lceloop].charge_event_act[lcealoop].in_transit_dt_tm))
        SET srvstat = uar_srvsetdate(hlist3,"IN_LAB_DT_TM",cnvtdatetime(dropchargerequest->
          charge_event[lceloop].charge_event_act[lcealoop].in_lab_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_PRSNL_TYPE_CD",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].cea_prsnl_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_SERVICE_RESOURCE_CD",dropchargerequest->
         charge_event[lceloop].charge_event_act[lcealoop].cea_service_resource_cd)
        SET srvstat = uar_srvsetdate(hlist3,"ceact_dt_tm",cnvtdatetime(dropchargerequest->
          charge_event[lceloop].charge_event_act[lcealoop].ceact_dt_tm))
        SET srvstat = uar_srvsetlong(hlist3,"ELAPSED_TIME",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].elapsed_time)
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_LOC_CD",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].cea_loc_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"priority_cd",dropchargerequest->charge_event[lceloop].
         charge_event_act[lcealoop].priority_cd)
        SET srvstat = uar_srvsetshort(hlist3,"patient_responsibility_flag",dropchargerequest->
         charge_event[lceloop].charge_event_act[lcealoop].patient_responsibility_flag)
        SET srvstat = uar_srvsetdouble(hlist3,"item_deductible_amt",dropchargerequest->charge_event[
         lceloop].charge_event_act[lcealoop].item_deductible_amt)
      ENDFOR
      SET htemphandle = uar_srvgetstruct(hchargeevent,"mods")
      FOR (lcemloop = 1 TO size(dropchargerequest->charge_event[lceloop].mods.charge_mods,5))
        SET hlist3 = uar_srvadditem(htemphandle,"charge_mods")
        SET srvstat = uar_srvsetdouble(hlist3,"charge_event_mod_type_cd",dropchargerequest->
         charge_event[lceloop].mods.charge_mods[lcemloop].charge_event_mod_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_mod_type_cd",dropchargerequest->charge_event[
         lceloop].mods.charge_mods[lcemloop].charge_mod_type_cd)
        SET srvstat = uar_srvsetstring(hlist3,"field1",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field1))
        SET srvstat = uar_srvsetstring(hlist3,"field2",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field2))
        SET srvstat = uar_srvsetstring(hlist3,"field3",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field3))
        SET srvstat = uar_srvsetstring(hlist3,"field4",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field4))
        SET srvstat = uar_srvsetstring(hlist3,"field5",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field5))
        SET srvstat = uar_srvsetstring(hlist3,"field6",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field6))
        SET srvstat = uar_srvsetstring(hlist3,"field7",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field7))
        SET srvstat = uar_srvsetstring(hlist3,"field8",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field8))
        SET srvstat = uar_srvsetstring(hlist3,"field9",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field9))
        SET srvstat = uar_srvsetstring(hlist3,"field10",nullterm(dropchargerequest->charge_event[
          lceloop].mods.charge_mods[lcemloop].field10))
        SET srvstat = uar_srvsetdouble(hlist3,"field1_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].field1_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field2_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].field2_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field3_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].field3_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field4_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].field4_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field5_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].field5_id)
        SET srvstat = uar_srvsetdouble(hlist3,"nomen_id",dropchargerequest->charge_event[lceloop].
         mods.charge_mods[lcemloop].nomen_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cm1_nbr",dropchargerequest->charge_event[lceloop].mods
         .charge_mods[lcemloop].cm1_nbr)
        SET srvstat = uar_srvsetdate(hlist3,"activity_dt_tm",dropchargerequest->charge_event[lceloop]
         .mods.charge_mods[lcemloop].activity_dt_tm)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_mod_source_cd",dropchargerequest->charge_event[
         lceloop].mods.charge_mods[lcemloop].charge_mod_source_cd)
      ENDFOR
      FOR (lchrgloop = 1 TO size(dropchargerequest->charge_event[lceloop].charges,5))
        SET hlist5 = uar_srvadditem(hchargeevent,"charges")
        SET srvstat = uar_srvsetdouble(hlist5,"charge_item_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].charge_item_id)
        SET srvstat = uar_srvsetdouble(hlist5,"charge_act_id",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].charge_act_id)
        SET srvstat = uar_srvsetdouble(hlist5,"charge_event_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].charge_event_id)
        SET srvstat = uar_srvsetdouble(hlist5,"bill_item_id",dropchargerequest->charge_event[lceloop]
         .charges[lchrgloop].bill_item_id)
        SET srvstat = uar_srvsetstring(hlist5,"charge_description",nullterm(dropchargerequest->
          charge_event[lceloop].charges[lchrgloop].charge_description))
        SET srvstat = uar_srvsetdouble(hlist5,"price_sched_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].price_sched_id)
        SET srvstat = uar_srvsetdouble(hlist5,"payor_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].payor_id)
        SET srvstat = uar_srvsetdouble(hlist5,"item_quantity",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].item_quantity)
        SET srvstat = uar_srvsetdouble(hlist5,"item_price",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].item_price)
        SET srvstat = uar_srvsetdouble(hlist5,"item_extended_price",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].item_extended_price)
        SET srvstat = uar_srvsetdouble(hlist5,"charge_type_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].charge_type_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"suspense_rsn_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].suspense_rsn_cd)
        SET srvstat = uar_srvsetstring(hlist5,"reason_comment",nullterm(dropchargerequest->
          charge_event[lceloop].charges[lchrgloop].reason_comment))
        SET srvstat = uar_srvsetdouble(hlist5,"posted_cd",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].posted_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"ord_phys_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].ord_phys_id)
        SET srvstat = uar_srvsetdouble(hlist5,"perf_phys_id",dropchargerequest->charge_event[lceloop]
         .charges[lchrgloop].perf_phys_id)
        SET srvstat = uar_srvsetdouble(hlist5,"order_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].order_id)
        SET srvstat = uar_srvsetdate(hlist5,"beg_effective_dt_tm",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].beg_effective_dt_tm)
        SET srvstat = uar_srvsetdouble(hlist5,"person_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].person_id)
        SET srvstat = uar_srvsetdouble(hlist5,"encntr_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].encntr_id)
        SET srvstat = uar_srvsetdouble(hlist5,"admit_type_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].admit_type_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"med_service_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].med_service_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"institution_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].institution_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"department_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].department_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"section_cd",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].section_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"subsection_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].subsection_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"level5_cd",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].level5_cd)
        SET srvstat = uar_srvsetdate(hlist5,"service_dt_tm",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].service_dt_tm)
        SET srvstat = uar_srvsetshort(hlist5,"process_flg",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].process_flg)
        SET srvstat = uar_srvsetdouble(hlist5,"parent_charge_item_id",dropchargerequest->
         charge_event[lceloop].charges[lchrgloop].parent_charge_item_id)
        SET srvstat = uar_srvsetdouble(hlist5,"interface_id",dropchargerequest->charge_event[lceloop]
         .charges[lchrgloop].interface_id)
        SET srvstat = uar_srvsetdouble(hlist5,"tier_group_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].tier_group_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"def_bill_item_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].def_bill_item_id)
        SET srvstat = uar_srvsetdouble(hlist5,"verify_phys_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].verify_phys_id)
        SET srvstat = uar_srvsetdouble(hlist5,"gross_price",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].gross_price)
        SET srvstat = uar_srvsetdouble(hlist5,"discount_amount",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].discount_amount)
        SET srvstat = uar_srvsetdouble(hlist5,"research_acct_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].research_acct_id)
        SET srvstat = uar_srvsetdouble(hlist5,"activity_type_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].activity_type_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"activity_sub_type_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].activity_sub_type_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"cost_center_cd",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].cost_center_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"abn_status_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].abn_status_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"perf_loc_cd",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].perf_loc_cd)
        SET srvstat = uar_srvsetstring(hlist5,"inst_fin_nbr",nullterm(dropchargerequest->
          charge_event[lceloop].charges[lchrgloop].inst_fin_nbr))
        SET srvstat = uar_srvsetdouble(hlist5,"ord_loc_cd",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].ord_loc_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"fin_class_cd",dropchargerequest->charge_event[lceloop]
         .charges[lchrgloop].fin_class_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"health_plan_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].health_plan_id)
        SET srvstat = uar_srvsetshort(hlist5,"manual_ind",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].manual_ind)
        SET srvstat = uar_srvsetdouble(hlist5,"payor_type_cd",dropchargerequest->charge_event[lceloop
         ].charges[lchrgloop].payor_type_cd)
        SET srvstat = uar_srvsetdouble(hlist5,"item_interval_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].item_interval_id)
        SET srvstat = uar_srvsetdouble(hlist5,"list_price",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].list_price)
        SET srvstat = uar_srvsetdouble(hlist5,"list_price_sched_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].list_price_sched_id)
        SET srvstat = uar_srvsetshort(hlist5,"epsdt_ind",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].epsdt_ind)
        SET srvstat = uar_srvsetdouble(hlist5,"ref_phys_id",dropchargerequest->charge_event[lceloop].
         charges[lchrgloop].ref_phys_id)
        SET srvstat = uar_srvsetdouble(hlist5,"alpha_nomen_id",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].alpha_nomen_id)
        SET srvstat = uar_srvsetshort(hlist5,"server_process_flag",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].server_process_flag)
        SET srvstat = uar_srvsetdouble(hlist5,"offset_charge_item_id",dropchargerequest->
         charge_event[lceloop].charges[lchrgloop].offset_charge_item_id)
        SET srvstat = uar_srvsetshort(hlist5,"patient_responsibility_flag",dropchargerequest->
         charge_event[lceloop].charges[lchrgloop].patient_responsibility_flag)
        SET srvstat = uar_srvsetdouble(hlist5,"item_deductible_amt",dropchargerequest->charge_event[
         lceloop].charges[lchrgloop].item_deductible_amt)
        SET htemphandle = uar_srvgetstruct(hlist5,"mods")
        FOR (lcmloop = 1 TO size(dropchargerequest->charge_event[lceloop].charges[lchrgloop].mods.
         charge_mods,5))
          SET hlist6 = uar_srvadditem(htemphandle,"charge_mods")
          SET srvstat = uar_srvsetdouble(hlist6,"charge_event_mod_type_cd",dropchargerequest->
           charge_event[lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].
           charge_event_mod_type_cd)
          SET srvstat = uar_srvsetdouble(hlist6,"charge_mod_type_cd",dropchargerequest->charge_event[
           lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].charge_mod_type_cd)
          SET srvstat = uar_srvsetstring(hlist6,"field1",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field1))
          SET srvstat = uar_srvsetstring(hlist6,"field2",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field2))
          SET srvstat = uar_srvsetstring(hlist6,"field3",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field3))
          SET srvstat = uar_srvsetstring(hlist6,"field4",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field4))
          SET srvstat = uar_srvsetstring(hlist6,"field5",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field5))
          SET srvstat = uar_srvsetstring(hlist6,"field6",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field6))
          SET srvstat = uar_srvsetstring(hlist6,"field7",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field7))
          SET srvstat = uar_srvsetstring(hlist6,"field8",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field8))
          SET srvstat = uar_srvsetstring(hlist6,"field9",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field9))
          SET srvstat = uar_srvsetstring(hlist6,"field10",nullterm(dropchargerequest->charge_event[
            lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].field10))
          SET srvstat = uar_srvsetdouble(hlist6,"field1_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].field1_id)
          SET srvstat = uar_srvsetdouble(hlist6,"field2_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].field2_id)
          SET srvstat = uar_srvsetdouble(hlist6,"field3_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].field3_id)
          SET srvstat = uar_srvsetdouble(hlist6,"field4_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].field4_id)
          SET srvstat = uar_srvsetdouble(hlist6,"field5_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].field5_id)
          SET srvstat = uar_srvsetdouble(hlist6,"nomen_id",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].nomen_id)
          SET srvstat = uar_srvsetdouble(hlist6,"cm1_nbr",dropchargerequest->charge_event[lceloop].
           charges[lchrgloop].mods.charge_mods[lcmloop].cm1_nbr)
          SET srvstat = uar_srvsetdate(hlist6,"activity_dt_tm",dropchargerequest->charge_event[
           lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].activity_dt_tm)
          SET srvstat = uar_srvsetdouble(hlist6,"charge_mod_source_cd",dropchargerequest->
           charge_event[lceloop].charges[lchrgloop].mods.charge_mods[lcmloop].charge_mod_source_cd)
        ENDFOR
      ENDFOR
    ENDFOR
    CALL echo("Beginning CRMPerform")
    SET iret = uar_crmperform(hreq)
    IF (iret=0)
     CALL echo("Success, check reply")
     SET hrcharges = uar_crmgetreply(hreq)
     IF (hrcharges > 0)
      CALL echo("Reply Success")
     ELSE
      CALL echo("Reply Failure")
     ENDIF
     SET num_charges = uar_srvgetitemcount(hrcharges,"charges")
     SET dropchargereply->charge_qual = num_charges
     SET stat = alterlist(dropchargereply->charges,num_charges)
     CALL echo(build("num_charges",num_charges))
     IF (num_charges > 0)
      FOR (lchargeloop = 1 TO num_charges)
        SET hrchild = uar_srvgetitem(hrcharges,"charges",(lchargeloop - 1))
        SET dropchargereply->charges[lchargeloop].charge_item_id = uar_srvgetdouble(hrchild,
         "charge_item_id")
        SET dropchargereply->charges[lchargeloop].charge_act_id = uar_srvgetdouble(hrchild,
         "charge_act_id")
        SET dropchargereply->charges[lchargeloop].charge_event_id = uar_srvgetdouble(hrchild,
         "charge_event_id")
        SET dropchargereply->charges[lchargeloop].bill_item_id = uar_srvgetdouble(hrchild,
         "bill_item_id")
        SET dropchargereply->charges[lchargeloop].charge_description = uar_srvgetstringptr(hrchild,
         "charge_description")
        SET dropchargereply->charges[lchargeloop].price_sched_id = uar_srvgetdouble(hrchild,
         "price_sched_id")
        SET dropchargereply->charges[lchargeloop].payor_id = uar_srvgetdouble(hrchild,"payor_id")
        SET dropchargereply->charges[lchargeloop].item_quantity = uar_srvgetdouble(hrchild,
         "item_quantity")
        SET dropchargereply->charges[lchargeloop].item_price = uar_srvgetdouble(hrchild,"item_price")
        SET dropchargereply->charges[lchargeloop].item_extended_price = uar_srvgetdouble(hrchild,
         "item_extended_price")
        SET dropchargereply->charges[lchargeloop].charge_type_cd = uar_srvgetdouble(hrchild,
         "charge_type_cd")
        SET dropchargereply->charges[lchargeloop].suspense_rsn_cd = uar_srvgetdouble(hrchild,
         "suspense_rsn_cd")
        SET dropchargereply->charges[lchargeloop].reason_comment = uar_srvgetstringptr(hrchild,
         "reason_comment")
        SET dropchargereply->charges[lchargeloop].posted_cd = uar_srvgetdouble(hrchild,"posted_cd")
        SET dropchargereply->charges[lchargeloop].ord_phys_id = uar_srvgetdouble(hrchild,
         "ord_phys_id")
        SET dropchargereply->charges[lchargeloop].perf_phys_id = uar_srvgetdouble(hrchild,
         "perf_phys_id")
        SET dropchargereply->charges[lchargeloop].order_id = uar_srvgetdouble(hrchild,"order_id")
        SET dropchargereply->charges[lchargeloop].person_id = uar_srvgetdouble(hrchild,"person_id")
        SET dropchargereply->charges[lchargeloop].encntr_id = uar_srvgetdouble(hrchild,"encntr_id")
        SET dropchargereply->charges[lchargeloop].admit_type_cd = uar_srvgetdouble(hrchild,
         "admit_type_cd")
        SET dropchargereply->charges[lchargeloop].med_service_cd = uar_srvgetdouble(hrchild,
         "med_service_cd")
        SET dropchargereply->charges[lchargeloop].institution_cd = uar_srvgetdouble(hrchild,
         "institution_cd")
        SET dropchargereply->charges[lchargeloop].department_cd = uar_srvgetdouble(hrchild,
         "department_cd")
        SET dropchargereply->charges[lchargeloop].section_cd = uar_srvgetdouble(hrchild,"section_cd")
        SET dropchargereply->charges[lchargeloop].subsection_cd = uar_srvgetdouble(hrchild,
         "subsection_cd")
        SET dropchargereply->charges[lchargeloop].level5_cd = uar_srvgetdouble(hrchild,"level5_cd")
        SET dropchargereply->charges[lchargeloop].process_flg = uar_srvgetshort(hrchild,"process_flg"
         )
        SET dropchargereply->charges[lchargeloop].parent_charge_item_id = uar_srvgetdouble(hrchild,
         "parent_charge_item_id")
        SET dropchargereply->charges[lchargeloop].interface_id = uar_srvgetdouble(hrchild,
         "interface_id")
        SET dropchargereply->charges[lchargeloop].tier_group_cd = uar_srvgetdouble(hrchild,
         "tier_group_cd")
        SET dropchargereply->charges[lchargeloop].def_bill_item_id = uar_srvgetdouble(hrchild,
         "def_bill_item_id")
        SET dropchargereply->charges[lchargeloop].verify_phys_id = uar_srvgetdouble(hrchild,
         "verify_phys_id")
        SET dropchargereply->charges[lchargeloop].gross_price = uar_srvgetdouble(hrchild,
         "gross_price")
        SET dropchargereply->charges[lchargeloop].discount_amount = uar_srvgetdouble(hrchild,
         "discount_amount")
        SET dropchargereply->charges[lchargeloop].item_price_adj_amt = uar_srvgetdouble(hrchild,
         "item_price_adj_amt")
        SET dropchargereply->charges[lchargeloop].activity_type_cd = uar_srvgetdouble(hrchild,
         "activity_type_cd")
        SET dropchargereply->charges[lchargeloop].activity_sub_type_cd = uar_srvgetdouble(hrchild,
         "activity_sub_type_cd")
        SET dropchargereply->charges[lchargeloop].provider_specialty_cd = uar_srvgetdouble(hrchild,
         "provider_specialty_cd")
        SET dropchargereply->charges[lchargeloop].research_acct_id = uar_srvgetdouble(hrchild,
         "research_acct_id")
        SET dropchargereply->charges[lchargeloop].cost_center_cd = uar_srvgetdouble(hrchild,
         "cost_center_cd")
        SET dropchargereply->charges[lchargeloop].abn_status_cd = uar_srvgetdouble(hrchild,
         "abn_status_cd")
        SET dropchargereply->charges[lchargeloop].perf_loc_cd = uar_srvgetdouble(hrchild,
         "perf_loc_cd")
        SET dropchargereply->charges[lchargeloop].inst_fin_nbr = uar_srvgetstringptr(hrchild,
         "inst_fin_nbr")
        SET dropchargereply->charges[lchargeloop].ord_loc_cd = uar_srvgetdouble(hrchild,"ord_loc_cd")
        SET dropchargereply->charges[lchargeloop].fin_class_cd = uar_srvgetdouble(hrchild,
         "fin_class_cd")
        SET dropchargereply->charges[lchargeloop].health_plan_id = uar_srvgetdouble(hrchild,
         "health_plan_id")
        SET dropchargereply->charges[lchargeloop].manual_ind = uar_srvgetshort(hrchild,"manual_ind")
        SET dropchargereply->charges[lchargeloop].updt_ind = uar_srvgetshort(hrchild,"updt_ind")
        SET dropchargereply->charges[lchargeloop].payor_type_cd = uar_srvgetdouble(hrchild,
         "payor_type_cd")
        SET dropchargereply->charges[lchargeloop].item_copay = uar_srvgetdouble(hrchild,"item_copay")
        SET dropchargereply->charges[lchargeloop].item_reimbursement = uar_srvgetdouble(hrchild,
         "item_reimbursement")
        SET dropchargereply->charges[lchargeloop].item_interval_id = uar_srvgetdouble(hrchild,
         "item_interval_id")
        SET dropchargereply->charges[lchargeloop].list_price = uar_srvgetdouble(hrchild,"list_price")
        SET dropchargereply->charges[lchargeloop].list_price_sched_id = uar_srvgetdouble(hrchild,
         "list_price_sched_id")
        SET dropchargereply->charges[lchargeloop].realtime_ind = uar_srvgetshort(hrchild,
         "realtime_ind")
        SET dropchargereply->charges[lchargeloop].epsdt_ind = uar_srvgetshort(hrchild,"epsdt_ind")
        SET dropchargereply->charges[lchargeloop].ref_phys_id = uar_srvgetdouble(hrchild,
         "ref_phys_id")
        SET dropchargereply->charges[lchargeloop].alpha_nomen_id = uar_srvgetdouble(hrchild,
         "alpha_nomen_id")
        SET dropchargereply->charges[lchargeloop].server_process_flag = uar_srvgetshort(hrchild,
         "server_process_flag")
        SET dropchargereply->charges[lchargeloop].offset_charge_item_id = uar_srvgetdouble(hrchild,
         "offset_charge_item_id")
        SET dropchargereply->charges[lchargeloop].item_deductible_amt = uar_srvgetdouble(hrchild,
         "item_deductible_amt")
        SET dropchargereply->charges[lchargeloop].patient_responsibility_flag = uar_srvgetshort(
         hrchild,"patient_responsibility_flag")
        SET srvstat = uar_srvgetdate(hrchild,"beg_effective_dt_tm",dropchargereply->charges[
         lchargeloop].beg_effective_dt_tm)
        SET srvstat = uar_srvgetdate(hrchild,"service_dt_tm",dropchargereply->charges[lchargeloop].
         service_dt_tm)
        SET srvstat = uar_srvgetdate(hrchild,"posted_dt_tm",dropchargereply->charges[lchargeloop].
         posted_dt_tm)
        SET htemphandle = uar_srvgetstruct(hrchild,"mods")
        SET num_charge_mods = uar_srvgetitemcount(htemphandle,"charge_mods")
        SET dropchargereply->charges[lchargeloop].charge_mod_qual = num_charge_mods
        SET stat = alterlist(dropchargereply->charges[lchargeloop].charge_mods,num_charge_mods)
        IF (num_charge_mods > 0)
         FOR (lchargemodloop = 1 TO num_charge_mods)
           SET hrchildjr = uar_srvgetitem(htemphandle,"charge_mods",(lchargemodloop - 1))
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].mod_id =
           uar_srvgetdouble(hrchildjr,"mod_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].charge_event_id =
           uar_srvgetdouble(hrchildjr,"charge_event_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].
           charge_event_mod_type_cd = uar_srvgetdouble(hrchildjr,"charge_event_mod_type_cd")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].charge_item_id =
           uar_srvgetdouble(hrchildjr,"charge_item_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].charge_mod_type_cd
            = uar_srvgetdouble(hrchildjr,"charge_mod_type_cd")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field1 =
           uar_srvgetstringptr(hrchildjr,"field1")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field2 =
           uar_srvgetstringptr(hrchildjr,"field2")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field3 =
           uar_srvgetstringptr(hrchildjr,"field3")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field3_ext =
           uar_srvgetstringptr(hrchildjr,"field3_ext")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field4 =
           uar_srvgetstringptr(hrchildjr,"field4")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field5 =
           uar_srvgetstringptr(hrchildjr,"field5")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field6 =
           uar_srvgetstringptr(hrchildjr,"field6")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field7 =
           uar_srvgetstringptr(hrchildjr,"field7")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field8 =
           uar_srvgetstringptr(hrchildjr,"field8")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field9 =
           uar_srvgetstringptr(hrchildjr,"field9")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field10 =
           uar_srvgetstringptr(hrchildjr,"field10")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field1_id =
           uar_srvgetdouble(hrchildjr,"field1_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field2_id =
           uar_srvgetdouble(hrchildjr,"field2_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field3_id =
           uar_srvgetdouble(hrchildjr,"field3_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field4_id =
           uar_srvgetdouble(hrchildjr,"field4_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].field5_id =
           uar_srvgetdouble(hrchildjr,"field5_id")
           IF (validate(dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].code1_cd))
            SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].code1_cd =
            uar_srvgetdouble(hrchildjr,"code1_cd")
           ENDIF
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].nomen_id =
           uar_srvgetdouble(hrchildjr,"nomen_id")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].cm1_nbr =
           uar_srvgetdouble(hrchildjr,"cm1_nbr")
           SET dropchargereply->charges[lchargeloop].charge_mods[lchargemodloop].charge_mod_source_cd
            = uar_srvgetdouble(hrchildjr,"charge_mod_source_cd")
           SET srvstat = uar_srvgetdate(hrchildjr,"activity_dt_tm",dropchargereply->charges[
            lchargeloop].charge_mods[lchargemodloop].activity_dt_tm)
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
    ELSE
     CALL echo(concat("Fail on perform: ",cnvtstring(iret)))
     SET reply->status_data.status = "F"
     GO TO end_program
    ENDIF
    CALL uar_crmendreq(hreq)
   ELSE
    CALL echo(concat("Error on begin req: ",cnvtstring(iret)))
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   CALL uar_crmendtask(htask)
  ELSE
   CALL echo(concat("Failure on begin task: ",cnvtstring(iret)))
   SET reply->status_data.status = "F"
   GO TO end_program
  ENDIF
  CALL uar_crmendapp(happ)
 ELSE
  CALL echo(concat("Failure on uar_crm_begin_app: ",cnvtstring(iret)))
  SET reply->status_data.status = "F"
  GO TO end_program
 ENDIF
 IF (validate(debug,0) > 0)
  CALL echorecord(dropchargereply)
 ENDIF
 SET reply->status_data.status = "S"
 SET g_srvproperties->logreqrep = 0
 IF (size(dropchargereply->charges,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d2  WITH seq = dropchargereply->charge_qual),
    (dummyt d1  WITH seq = value(size(eventreq->charge,5))),
    charge c
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_event_id=eventreq->charge[d1.seq].charge_event_id)
     AND c.offset_charge_item_id=0.0
     AND c.item_interval_id=0.0)
    JOIN (d2
    WHERE (c.charge_event_id=dropchargereply->charges[d2.seq].charge_event_id)
     AND (c.tier_group_cd=dropchargereply->charges[d2.seq].tier_group_cd)
     AND (c.bill_item_id=dropchargereply->charges[d2.seq].bill_item_id)
     AND (c.item_quantity != dropchargereply->charges[d2.seq].item_quantity)
     AND c.active_ind=true)
   ORDER BY c.charge_item_id
   HEAD c.charge_item_id
    dropchargereply->charges[d2.seq].item_quantity = c.item_quantity, dropchargereply->charges[d2.seq
    ].item_extended_price = (c.item_quantity * c.item_price)
   WITH nocounter
  ;end select
  FOR (num_charges = 1 TO size(dropchargereply->charges,5))
   SET dropchargereply->charges[num_charges].reason_comment = "dm_cmb_drop_charge_sync: new debit"
   SET dropchargereply->charges[num_charges].charge_item_id = 0.0
  ENDFOR
  EXECUTE cs_srv_add_charge  WITH replace("REPLY",dropchargereply)
  FOR (num_charges = 1 TO size(dropchargereply->charges,5))
    SET stat = alterlist(reply->charges,num_charges)
    SET reply->charges[num_charges].charge_item_id = dropchargereply->charges[num_charges].
    charge_item_id
    SET reply->charges[num_charges].charge_type_cd = dropchargereply->charges[num_charges].
    charge_type_cd
    IF (validate(reply->charges[num_charges].charge_event_id))
     SET reply->charges[num_charges].charge_event_id = dropchargereply->charges[num_charges].
     charge_event_id
    ENDIF
    IF (validate(reply->charges[num_charges].tier_group_cd))
     SET reply->charges[num_charges].tier_group_cd = dropchargereply->charges[num_charges].
     tier_group_cd
    ENDIF
  ENDFOR
 ENDIF
#end_program
 FREE RECORD dropchargerequest
 FREE RECORD dropchargereply
END GO
