CREATE PROGRAM afc_drop_charge_sync:dba
 SET afc_drop_charge_sync = "CHARGSRV-15902.FT.003"
 RECORD reply(
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
     2 charge_mod_qual = i4
     2 charge_mods[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = c200
       3 field2 = c200
       3 field3 = c200
       3 field4 = c200
       3 field5 = c200
       3 field6 = c200
       3 field7 = c200
       3 field8 = c200
       3 field9 = c200
       3 field10 = c200
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
     2 item_price_adj_amt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE appid = i4 WITH public, noconstant(0)
 DECLARE taskid = i4 WITH public, noconstant(0)
 DECLARE reqid = i4 WITH public, noconstant(0)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE iret = i4 WITH public, noconstant(0)
 DECLARE hchargeevent = i4 WITH public, noconstant(0)
 DECLARE hlist3 = i4 WITH public, noconstant(0)
 DECLARE hlist4 = i4 WITH public, noconstant(0)
 DECLARE srvstat = i4 WITH public, noconstant(0)
 DECLARE htemphandle = i4 WITH public, noconstant(0)
 DECLARE hrcharges = i4 WITH public, noconstant(0)
 DECLARE hrchild = i4 WITH public, noconstant(0)
 DECLARE hrchildjr = i4 WITH public, noconstant(0)
 DECLARE num_charges = i4 WITH public, noconstant(0)
 DECLARE num_charge_mods = i4 WITH public, noconstant(0)
 DECLARE hprsnl = i4 WITH public, noconstant(0)
 SET appid = 951020
 SET taskid = 951020
 SET reqid = 951360
 SET curalias ce request->charge_event[x]
 SET curalias cea request->charge_event[x].charge_event_act[y]
 SET curalias cepe request->charge_event[x].parent_events[y]
 SET curalias cem request->charge_event[x].mods.charge_mods[y]
 SET curalias c request->charge_event[x].charges[y]
 SET curalias cm request->charge_event[x].charges[y].mods.charge_mods[z]
 SET curalias ceap request->charge_event[x].charge_event_act[y].prsnl[z]
 SET reply->status_data.status = "F"
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
    SET srvstat = uar_srvsetstring(hrequest,"action_type",nullterm(request->action_type))
    SET srvstat = uar_srvsetshort(hrequest,"charge_event_qual",request->charge_event_qual)
    FOR (x = 1 TO request->charge_event_qual)
      SET hchargeevent = uar_srvadditem(hrequest,"charge_event")
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
        SET hlist3 = uar_srvadditem(hchargeevent,"charge_event_act")
        SET srvstat = uar_srvsetshort(hlist3,"phleb_group_ind",cea->phleb_group_ind)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_type_cd",cea->cea_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"service_resource_cd",cea->service_resource_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"service_loc_cd",cea->service_loc_cd)
        SET srvstat = uar_srvsetdate(hlist3,"service_dt_tm",cnvtdatetime(cea->service_dt_tm))
        SET srvstat = uar_srvsetdate(hlist3,"charge_dt_tm",cnvtdatetime(cea->charge_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist3,"charge_type_cd",cea->charge_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"alpha_nomen_id",cea->alpha_nomen_id)
        SET srvstat = uar_srvsetlong(hlist3,"quantity",cea->quantity)
        SET srvstat = uar_srvsetdouble(hlist3,"rx_quantity",cea->rx_quantity)
        SET srvstat = uar_srvsetstring(hlist3,"result",nullterm(cea->result))
        SET srvstat = uar_srvsetdouble(hlist3,"units",cea->units)
        SET srvstat = uar_srvsetlong(hlist3,"unit_type_cd",cea->unit_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"reason_cd",cea->reason_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"accession_id",cea->accession_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_prsnl_id",cea->cea_prsnl_id)
        SET srvstat = uar_srvsetdouble(hlist3,"position_cd",cea->position_cd)
        SET srvstat = uar_srvsetshort(hlist3,"repeat_ind",cea->repeat_ind)
        SET srvstat = uar_srvsetshort(hlist3,"misc_ind",cea->misc_ind)
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc1",nullterm(cea->cea_misc1))
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc2",nullterm(cea->cea_misc2))
        SET srvstat = uar_srvsetstring(hlist3,"cea_misc3",nullterm(cea->cea_misc3))
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc1_id",cea->cea_misc1_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc2_id",cea->cea_misc2_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc3_id",cea->cea_misc3_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc4_id",cea->cea_misc4_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc5_id",cea->cea_misc5_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc6_id",cea->cea_misc6_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cea_misc7_id",cea->cea_misc7_id)
        SET srvstat = uar_srvsetshort(hlist3,"prsnl_qual",cea->prsnl_qual)
        FOR (z = 1 TO cea->prsnl_qual)
          SET hlist4 = uar_srvadditem(hlist3,"prsnl")
          SET srvstat = uar_srvsetdouble(hlist4,"prsnl_id",ceap->prsnl_id)
          SET srvstat = uar_srvsetdouble(hlist4,"prsnl_type_cd",ceap->prsnl_type_cd)
        ENDFOR
        SET srvstat = uar_srvsetdouble(hlist3,"CHARGE_EVENT_ID",cea->charge_event_id)
        SET srvstat = uar_srvsetdouble(hlist3,"REFERENCE_RANGE_FACTOR_ID",cea->
         reference_range_factor_id)
        SET srvstat = uar_srvsetdouble(hlist3,"PATIENT_LOC_CD",cea->patient_loc_cd)
        SET srvstat = uar_srvsetdate(hlist3,"IN_TRANSIT_DT_TM",cnvtdatetime(cea->in_transit_dt_tm))
        SET srvstat = uar_srvsetdate(hlist3,"IN_LAB_DT_TM",cnvtdatetime(cea->in_lab_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_PRSNL_TYPE_CD",cea->cea_prsnl_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_SERVICE_RESOURCE_CD",cea->cea_service_resource_cd)
        SET srvstat = uar_srvsetdate(hlist3,"ceact_dt_tm",cnvtdatetime(cea->ceact_dt_tm))
        SET srvstat = uar_srvsetlong(hlist3,"ELAPSED_TIME",cea->elapsed_time)
        SET srvstat = uar_srvsetdouble(hlist3,"CEA_LOC_CD",cea->cea_loc_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"priority_cd",cea->priority_cd)
        SET srvstat = uar_srvsetshort(hlist3,"patient_responsibility_flag",cea->
         patient_responsibility_flag)
        SET srvstat = uar_srvsetdouble(hlist3,"item_deductible_amt",cea->item_deductible_amt)
      ENDFOR
      SET htemphandle = uar_srvgetstruct(hchargeevent,"mods")
      FOR (y = 1 TO size(ce->mods.charge_mods,5))
        SET hlist3 = uar_srvadditem(htemphandle,"charge_mods")
        SET srvstat = uar_srvsetdouble(hlist3,"charge_event_mod_type_cd",cem->
         charge_event_mod_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_mod_type_cd",cem->charge_mod_type_cd)
        SET srvstat = uar_srvsetstring(hlist3,"field1",nullterm(cem->field1))
        SET srvstat = uar_srvsetstring(hlist3,"field2",nullterm(cem->field2))
        SET srvstat = uar_srvsetstring(hlist3,"field3",nullterm(cem->field3))
        SET srvstat = uar_srvsetstring(hlist3,"field4",nullterm(cem->field4))
        SET srvstat = uar_srvsetstring(hlist3,"field5",nullterm(cem->field5))
        SET srvstat = uar_srvsetstring(hlist3,"field6",nullterm(cem->field6))
        SET srvstat = uar_srvsetstring(hlist3,"field7",nullterm(cem->field7))
        SET srvstat = uar_srvsetstring(hlist3,"field8",nullterm(cem->field8))
        SET srvstat = uar_srvsetstring(hlist3,"field9",nullterm(cem->field9))
        SET srvstat = uar_srvsetstring(hlist3,"field10",nullterm(cem->field10))
        SET srvstat = uar_srvsetdouble(hlist3,"field1_id",cem->field1_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field2_id",cem->field2_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field3_id",cem->field3_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field4_id",cem->field4_id)
        SET srvstat = uar_srvsetdouble(hlist3,"field5_id",cem->field5_id)
        SET srvstat = uar_srvsetdouble(hlist3,"nomen_id",cem->nomen_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cm1_nbr",cem->cm1_nbr)
      ENDFOR
      FOR (y = 1 TO size(ce->parent_events,5))
        SET hlist3 = uar_srvadditem(hchargeevent,"parent_events")
        SET srvstat = uar_srvsetdouble(hlist3,"ext_p_ref_id",cepe->ext_p_ref_id)
        SET srvstat = uar_srvsetdouble(hlist3,"ext_p_ref_cd",cepe->ext_p_ref_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"ext_i_ref_id",cepe->ext_i_ref_id)
        SET srvstat = uar_srvsetdouble(hlist3,"ext_i_ref_cd",cepe->ext_i_ref_cd)
      ENDFOR
      CALL echo(size(ce->charges,5))
      FOR (y = 1 TO size(ce->charges,5))
        SET hlist3 = uar_srvadditem(hchargeevent,"charges")
        SET srvstat = uar_srvsetdouble(hlist3,"charge_item_id",c->charge_item_id)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_act_id",c->charge_act_id)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_event_id",c->charge_event_id)
        SET srvstat = uar_srvsetdouble(hlist3,"bill_item_id",c->bill_item_id)
        SET srvstat = uar_srvsetstring(hlist3,"charge_description",nullterm(c->charge_description))
        SET srvstat = uar_srvsetdouble(hlist3,"price_sched_id",c->price_sched_id)
        SET srvstat = uar_srvsetdouble(hlist3,"payor_id",c->payor_id)
        SET srvstat = uar_srvsetdouble(hlist3,"item_quantity",c->item_quantity)
        SET srvstat = uar_srvsetdouble(hlist3,"item_price",c->item_price)
        SET srvstat = uar_srvsetdouble(hlist3,"item_extended_price",c->item_extended_price)
        SET srvstat = uar_srvsetdouble(hlist3,"charge_type_cd",c->charge_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"suspense_rsn_cd",c->suspense_rsn_cd)
        SET srvstat = uar_srvsetstring(hlist3,"reason_comment",nullterm(c->reason_comment))
        SET srvstat = uar_srvsetdouble(hlist3,"posted_cd",c->posted_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"ord_phys_id",c->ord_phys_id)
        SET srvstat = uar_srvsetdouble(hlist3,"perf_phys_id",c->perf_phys_id)
        SET srvstat = uar_srvsetdouble(hlist3,"order_id",c->order_id)
        SET srvstat = uar_srvsetdate(hlist3,"beg_effective_dt_tm",cnvtdatetime(c->beg_effective_dt_tm
          ))
        SET srvstat = uar_srvsetdouble(hlist3,"person_id",c->person_id)
        SET srvstat = uar_srvsetdouble(hlist3,"encntr_id",c->encntr_id)
        SET srvstat = uar_srvsetdouble(hlist3,"admit_type_cd",c->admit_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"med_service_cd",c->med_service_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"institution_cd",c->institution_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"department_cd",c->department_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"section_cd",c->section_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"subsection_cd",c->subsection_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"level5_cd",c->level5_cd)
        SET srvstat = uar_srvsetdate(hlist3,"service_dt_tm",cnvtdatetime(c->service_dt_tm))
        SET srvstat = uar_srvsetshort(hlist3,"process_flg",c->process_flg)
        SET srvstat = uar_srvsetdouble(hlist3,"parent_charge_item_id",c->parent_charge_item_id)
        SET srvstat = uar_srvsetdouble(hlist3,"interface_id",c->interface_id)
        SET srvstat = uar_srvsetdouble(hlist3,"tier_group_cd",c->tier_group_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"def_bill_item_id",c->def_bill_item_id)
        SET srvstat = uar_srvsetdouble(hlist3,"verify_phys_id",c->verify_phys_id)
        SET srvstat = uar_srvsetdouble(hlist3,"gross_price",c->gross_price)
        SET srvstat = uar_srvsetdouble(hlist3,"discount_amount",c->discount_amount)
        SET srvstat = uar_srvsetdouble(hlist3,"activity_type_cd",c->activity_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"research_acct_id",c->research_acct_id)
        SET srvstat = uar_srvsetdouble(hlist3,"cost_center_cd",c->cost_center_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"abn_status_cd",c->abn_status_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"perf_loc_cd",c->perf_loc_cd)
        SET srvstat = uar_srvsetstring(hlist3,"inst_fin_nbr",nullterm(c->inst_fin_nbr))
        SET srvstat = uar_srvsetdouble(hlist3,"ord_loc_cd",c->ord_loc_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"fin_class_cd",c->fin_class_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"health_plan_id",c->health_plan_id)
        SET srvstat = uar_srvsetshort(hlist3,"manual_ind",c->manual_ind)
        SET srvstat = uar_srvsetshort(hlist3,"updt_ind",c->updt_ind)
        SET srvstat = uar_srvsetdouble(hlist3,"payor_type_cd",c->payor_type_cd)
        SET srvstat = uar_srvsetdouble(hlist3,"item_copay",c->item_copay)
        SET srvstat = uar_srvsetdouble(hlist3,"item_reimbursement",c->item_reimbursement)
        SET srvstat = uar_srvsetdate(hlist3,"posted_dt_tm",cnvtdatetime(c->posted_dt_tm))
        SET srvstat = uar_srvsetdouble(hlist3,"item_interval_id",c->item_interval_id)
        SET srvstat = uar_srvsetdouble(hlist3,"list_price",c->list_price)
        SET srvstat = uar_srvsetdouble(hlist3,"list_price_sched_id",c->list_price_sched_id)
        SET srvstat = uar_srvsetshort(hlist3,"realtime_ind",c->realtime_ind)
        SET srvstat = uar_srvsetshort(hlist3,"epsdt_ind",c->epsdt_ind)
        SET srvstat = uar_srvsetdouble(hlist3,"ref_phys_id",c->ref_phys_id)
        SET srvstat = uar_srvsetdouble(hlist3,"alpha_nomen_id",c->alpha_nomen_id)
        SET srvstat = uar_srvsetshort(hlist3,"server_process_flag",c->server_process_flag)
        SET htemphandle = uar_srvgetstruct(hlist3,"mods")
        FOR (z = 1 TO size(c->mods.charge_mods,5))
          SET hlist4 = uar_srvadditem(htemphandle,"charge_mods")
          SET srvstat = uar_srvsetdouble(hlist4,"mod_id",cm->mod_id)
          SET srvstat = uar_srvsetdouble(hlist4,"charge_event_id",cm->charge_event_id)
          SET srvstat = uar_srvsetdouble(hlist4,"charge_event_mod_type_cd",cm->
           charge_event_mod_type_cd)
          SET srvstat = uar_srvsetdouble(hlist4,"charge_item_id",cm->charge_item_id)
          SET srvstat = uar_srvsetdouble(hlist4,"charge_mod_type_cd",cm->charge_mod_type_cd)
          SET srvstat = uar_srvsetstring(hlist4,"field1",nullterm(cm->field1))
          SET srvstat = uar_srvsetstring(hlist4,"field2",nullterm(cm->field2))
          SET srvstat = uar_srvsetstring(hlist4,"field3",nullterm(cm->field3))
          SET srvstat = uar_srvsetstring(hlist4,"field4",nullterm(cm->field4))
          SET srvstat = uar_srvsetstring(hlist4,"field5",nullterm(cm->field5))
          SET srvstat = uar_srvsetstring(hlist4,"field6",nullterm(cm->field6))
          SET srvstat = uar_srvsetstring(hlist4,"field7",nullterm(cm->field7))
          SET srvstat = uar_srvsetstring(hlist4,"field8",nullterm(cm->field8))
          SET srvstat = uar_srvsetstring(hlist4,"field9",nullterm(cm->field9))
          SET srvstat = uar_srvsetstring(hlist4,"field10",nullterm(cm->field10))
          SET srvstat = uar_srvsetdouble(hlist4,"field1_id",cm->field1_id)
          SET srvstat = uar_srvsetdouble(hlist4,"field2_id",cm->field2_id)
          SET srvstat = uar_srvsetdouble(hlist4,"field3_id",cm->field3_id)
          SET srvstat = uar_srvsetdouble(hlist4,"field4_id",cm->field4_id)
          SET srvstat = uar_srvsetdouble(hlist4,"field5_id",cm->field5_id)
          SET srvstat = uar_srvsetdouble(hlist4,"nomen_id",cm->nomen_id)
          SET srvstat = uar_srvsetdouble(hlist4,"cm1_nbr",cm->cm1_nbr)
        ENDFOR
        SET srvstat = uar_srvsetdouble(hlist3,"offset_charge_item_id",c->offset_charge_item_id)
        SET srvstat = uar_srvsetshort(hlist3,"patient_responsibility_flag",c->
         patient_responsibility_flag)
        SET srvstat = uar_srvsetdouble(hlist3,"item_deductible_amt",c->item_deductible_amt)
        SET srvstat = uar_srvsetdouble(hlist3,"item_price_adj_amt",validate(c->item_price_adj_amt,
          null))
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
     SET reply->charge_qual = num_charges
     SET stat = alterlist(reply->charges,num_charges)
     CALL echo(build("num_charges",num_charges))
     IF (num_charges > 0)
      FOR (x = 1 TO num_charges)
        SET hrchild = uar_srvgetitem(hrcharges,"charges",(x - 1))
        SET reply->charges[x].charge_item_id = uar_srvgetdouble(hrchild,"charge_item_id")
        SET reply->charges[x].charge_act_id = uar_srvgetdouble(hrchild,"charge_act_id")
        SET reply->charges[x].charge_event_id = uar_srvgetdouble(hrchild,"charge_event_id")
        SET reply->charges[x].bill_item_id = uar_srvgetdouble(hrchild,"bill_item_id")
        SET reply->charges[x].charge_description = uar_srvgetstringptr(hrchild,"charge_description")
        SET reply->charges[x].price_sched_id = uar_srvgetdouble(hrchild,"price_sched_id")
        SET reply->charges[x].payor_id = uar_srvgetdouble(hrchild,"payor_id")
        SET reply->charges[x].item_quantity = uar_srvgetdouble(hrchild,"item_quantity")
        SET reply->charges[x].item_price = uar_srvgetdouble(hrchild,"item_price")
        SET reply->charges[x].item_extended_price = uar_srvgetdouble(hrchild,"item_extended_price")
        SET reply->charges[x].charge_type_cd = uar_srvgetdouble(hrchild,"charge_type_cd")
        SET reply->charges[x].suspense_rsn_cd = uar_srvgetdouble(hrchild,"suspense_rsn_cd")
        SET reply->charges[x].reason_comment = uar_srvgetstringptr(hrchild,"reason_comment")
        SET reply->charges[x].posted_cd = uar_srvgetdouble(hrchild,"posted_cd")
        SET reply->charges[x].ord_phys_id = uar_srvgetdouble(hrchild,"ord_phys_id")
        SET reply->charges[x].perf_phys_id = uar_srvgetdouble(hrchild,"perf_phys_id")
        SET reply->charges[x].order_id = uar_srvgetdouble(hrchild,"order_id")
        SET reply->charges[x].person_id = uar_srvgetdouble(hrchild,"person_id")
        SET reply->charges[x].encntr_id = uar_srvgetdouble(hrchild,"encntr_id")
        SET reply->charges[x].admit_type_cd = uar_srvgetdouble(hrchild,"admit_type_cd")
        SET reply->charges[x].med_service_cd = uar_srvgetdouble(hrchild,"med_service_cd")
        SET reply->charges[x].institution_cd = uar_srvgetdouble(hrchild,"institution_cd")
        SET reply->charges[x].department_cd = uar_srvgetdouble(hrchild,"department_cd")
        SET reply->charges[x].section_cd = uar_srvgetdouble(hrchild,"section_cd")
        SET reply->charges[x].subsection_cd = uar_srvgetdouble(hrchild,"subsection_cd")
        SET reply->charges[x].level5_cd = uar_srvgetdouble(hrchild,"level5_cd")
        SET reply->charges[x].process_flg = uar_srvgetshort(hrchild,"process_flg")
        SET reply->charges[x].parent_charge_item_id = uar_srvgetdouble(hrchild,
         "parent_charge_item_id")
        SET reply->charges[x].interface_id = uar_srvgetdouble(hrchild,"interface_id")
        SET reply->charges[x].tier_group_cd = uar_srvgetdouble(hrchild,"tier_group_cd")
        SET reply->charges[x].def_bill_item_id = uar_srvgetdouble(hrchild,"def_bill_item_id")
        SET reply->charges[x].verify_phys_id = uar_srvgetdouble(hrchild,"verify_phys_id")
        SET reply->charges[x].gross_price = uar_srvgetdouble(hrchild,"gross_price")
        SET reply->charges[x].discount_amount = uar_srvgetdouble(hrchild,"discount_amount")
        IF (validate(reply->charges[x].item_price_adj_amt,0))
         SET reply->charges[x].item_price_adj_amt = uar_srvgetdouble(hrchild,"item_price_adj_amt")
        ENDIF
        SET reply->charges[x].activity_type_cd = uar_srvgetdouble(hrchild,"activity_type_cd")
        SET reply->charges[x].research_acct_id = uar_srvgetdouble(hrchild,"research_acct_id")
        SET reply->charges[x].cost_center_cd = uar_srvgetdouble(hrchild,"cost_center_cd")
        SET reply->charges[x].abn_status_cd = uar_srvgetdouble(hrchild,"abn_status_cd")
        SET reply->charges[x].perf_loc_cd = uar_srvgetdouble(hrchild,"perf_loc_cd")
        SET reply->charges[x].inst_fin_nbr = uar_srvgetstringptr(hrchild,"inst_fin_nbr")
        SET reply->charges[x].ord_loc_cd = uar_srvgetdouble(hrchild,"ord_loc_cd")
        SET reply->charges[x].fin_class_cd = uar_srvgetdouble(hrchild,"fin_class_cd")
        SET reply->charges[x].health_plan_id = uar_srvgetdouble(hrchild,"health_plan_id")
        SET reply->charges[x].manual_ind = uar_srvgetshort(hrchild,"manual_ind")
        SET reply->charges[x].updt_ind = uar_srvgetshort(hrchild,"updt_ind")
        SET reply->charges[x].payor_type_cd = uar_srvgetdouble(hrchild,"payor_type_cd")
        SET reply->charges[x].item_copay = uar_srvgetdouble(hrchild,"item_copay")
        SET reply->charges[x].item_reimbursement = uar_srvgetdouble(hrchild,"item_reimbursement")
        SET reply->charges[x].item_interval_id = uar_srvgetdouble(hrchild,"item_interval_id")
        SET reply->charges[x].list_price = uar_srvgetdouble(hrchild,"list_price")
        SET reply->charges[x].list_price_sched_id = uar_srvgetdouble(hrchild,"list_price_sched_id")
        SET reply->charges[x].realtime_ind = uar_srvgetshort(hrchild,"realtime_ind")
        SET reply->charges[x].epsdt_ind = uar_srvgetshort(hrchild,"epsdt_ind")
        SET reply->charges[x].ref_phys_id = uar_srvgetdouble(hrchild,"ref_phys_id")
        SET reply->charges[x].alpha_nomen_id = uar_srvgetdouble(hrchild,"alpha_nomen_id")
        SET reply->charges[x].server_process_flag = uar_srvgetshort(hrchild,"server_process_flag")
        SET reply->charges[x].offset_charge_item_id = uar_srvgetdouble(hrchild,
         "offset_charge_item_id")
        SET reply->charges[x].item_deductible_amt = uar_srvgetdouble(hrchild,"item_deductible_amt")
        SET reply->charges[x].patient_responsibility_flag = uar_srvgetshort(hrchild,
         "patient_responsibility_flag")
        SET srvstat = uar_srvgetdate(hrchild,"beg_effective_dt_tm",reply->charges[x].
         beg_effective_dt_tm)
        SET srvstat = uar_srvgetdate(hrchild,"service_dt_tm",reply->charges[x].service_dt_tm)
        SET srvstat = uar_srvgetdate(hrchild,"posted_dt_tm",reply->charges[x].posted_dt_tm)
        SET htemphandle = uar_srvgetstruct(hrchild,"mods")
        SET num_charge_mods = uar_srvgetitemcount(htemphandle,"charge_mods")
        SET reply->charges[x].charge_mod_qual = num_charge_mods
        SET stat = alterlist(reply->charges[x].charge_mods,num_charge_mods)
        IF (num_charge_mods > 0)
         FOR (y = 1 TO num_charge_mods)
           SET hrchildjr = uar_srvgetitem(htemphandle,"charge_mods",(y - 1))
           SET reply->charges[x].charge_mods[y].mod_id = uar_srvgetdouble(hrchildjr,"mod_id")
           SET reply->charges[x].charge_mods[y].charge_event_id = uar_srvgetdouble(hrchildjr,
            "charge_event_id")
           SET reply->charges[x].charge_mods[y].charge_event_mod_type_cd = uar_srvgetdouble(hrchildjr,
            "charge_event_mod_type_cd")
           SET reply->charges[x].charge_mods[y].charge_item_id = uar_srvgetdouble(hrchildjr,
            "charge_item_id")
           SET reply->charges[x].charge_mods[y].charge_mod_type_cd = uar_srvgetdouble(hrchildjr,
            "charge_mod_type_cd")
           SET reply->charges[x].charge_mods[y].field1 = uar_srvgetstringptr(hrchildjr,"field1")
           SET reply->charges[x].charge_mods[y].field2 = uar_srvgetstringptr(hrchildjr,"field2")
           SET reply->charges[x].charge_mods[y].field3 = uar_srvgetstringptr(hrchildjr,"field3")
           SET reply->charges[x].charge_mods[y].field4 = uar_srvgetstringptr(hrchildjr,"field4")
           SET reply->charges[x].charge_mods[y].field5 = uar_srvgetstringptr(hrchildjr,"field5")
           SET reply->charges[x].charge_mods[y].field6 = uar_srvgetstringptr(hrchildjr,"field6")
           SET reply->charges[x].charge_mods[y].field7 = uar_srvgetstringptr(hrchildjr,"field7")
           SET reply->charges[x].charge_mods[y].field8 = uar_srvgetstringptr(hrchildjr,"field8")
           SET reply->charges[x].charge_mods[y].field9 = uar_srvgetstringptr(hrchildjr,"field9")
           SET reply->charges[x].charge_mods[y].field10 = uar_srvgetstringptr(hrchildjr,"field10")
           SET reply->charges[x].charge_mods[y].field1_id = uar_srvgetdouble(hrchildjr,"field1_id")
           SET reply->charges[x].charge_mods[y].field2_id = uar_srvgetdouble(hrchildjr,"field2_id")
           SET reply->charges[x].charge_mods[y].field3_id = uar_srvgetdouble(hrchildjr,"field3_id")
           SET reply->charges[x].charge_mods[y].field4_id = uar_srvgetdouble(hrchildjr,"field4_id")
           SET reply->charges[x].charge_mods[y].field5_id = uar_srvgetdouble(hrchildjr,"field5_id")
           SET reply->charges[x].charge_mods[y].nomen_id = uar_srvgetdouble(hrchildjr,"nomen_id")
           SET reply->charges[x].charge_mods[y].cm1_nbr = uar_srvgetdouble(hrchildjr,"cm1_nbr")
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
    ELSE
     CALL echo(concat("Fail on perform: ",cnvtstring(iret)))
     GO TO end_program
    ENDIF
    CALL uar_crmendreq(hreq)
   ELSE
    CALL echo(concat("Error on begin req: ",cnvtstring(iret)))
    GO TO end_program
   ENDIF
   CALL uar_crmendtask(htask)
  ELSE
   CALL echo(concat("Failure on begin task: ",cnvtstring(iret)))
   GO TO end_program
  ENDIF
  CALL uar_crmendapp(happ)
 ELSE
  CALL echo(concat("Failure on uar_crm_begin_app: ",cnvtstring(iret)))
  GO TO end_program
 ENDIF
 SET reply->status_data.status = "S"
#end_program
END GO
