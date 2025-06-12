CREATE PROGRAM afc_reprocess_charges:dba
 SET afc_reprocess_charge_version = "46376.FT.015"
 RECORD reply(
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
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 collection_priority_cd = f8
     2 report_priority_cd = f8
     2 accession = vc
     2 epsdt_ind = i2
     2 order_mnemonic = c20
     2 mnemonic = c20
     2 activity_type_disp = c40
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_description = vc
     2 perf_loc_cd = f8
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_id = f8
       3 cea_type_cd = f8
       3 cea_type_disp = vc
       3 service_resource_cd = f8
       3 service_dt_tm = dq8
       3 charge_dt_tm = dq8
       3 charge_type_cd = f8
       3 reference_range_factor_id = f8
       3 alpha_nomen_id = f8
       3 quantity = i4
       3 units = f8
       3 unit_type_cd = f8
       3 patient_loc_cd = f8
       3 service_loc_cd = f8
       3 reason_cd = f8
       3 in_lab_dt_tm = dq8
       3 in_transit_dt_tm = dq8
       3 cea_prsnl_id = f8
       3 cea_prsnl_type_cd = f8
       3 details = vc
       3 price_sched_id = f8
       3 ext_price = f8
       3 cost = f8
       3 bill_code_sched_cd = f8
       3 bill_code = vc
       3 item_desc = vc
       3 pharm_quantity = f8
       3 item_price = f8
       3 misc_ind = i2
       3 result = vc
       3 item_copay = f8
       3 item_reimbursement = f8
       3 discount_amount = f8
       3 health_plan_id = f8
       3 prsnl_qual = i2
       3 prsnl[*]
         4 prsnl_id = f8
         4 prsnl_type_cd = f8
     2 charge_event_mod_qual = i2
     2 charge_event_mod[*]
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field1_id = f8
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 field2_id = f8
       3 field3_id = f8
       3 nomen_id = f8
     2 nomen_qual = i2
     2 nomen[*]
       3 nomen_id = f8
 )
 IF ((request->report_type="ORDERS"))
  EXECUTE afc_get_reprocess_orders
 ELSEIF ((request->report_type="SPECCOLL"))
  EXECUTE afc_get_spec_coll
 ELSEIF ((request->report_type="RESULTS"))
  EXECUTE afc_get_gl_results
 ELSEIF ((request->report_type="RADIOLOGY"))
  EXECUTE afc_get_rad_results
 ELSEIF ((request->report_type="RADSIGNOUT"))
  EXECUTE afc_get_rad_signout
 ELSEIF ((request->report_type="PHARMDISP"))
  EXECUTE afc_get_pharmacy_dispense
 ELSEIF ((request->report_type="PHARMDISPR"))
  EXECUTE afc_get_pharmacy_dispense_rx
 ELSEIF ((request->report_type="PHRMDISPHI"))
  EXECUTE afc_get_pharmacy_dispense_rx
 ELSEIF ((request->report_type="PHRMDISPLT"))
  EXECUTE afc_get_pharmacy_dispense_rx
 ELSEIF ((request->report_type="PHRMDISPMO"))
  EXECUTE afc_get_pharmacy_dispense_rx
 ELSEIF ((request->report_type="TASKS"))
  EXECUTE afc_get_tasks
 ELSEIF ((request->report_type="BCE"))
  EXECUTE afc_get_batch_charge_entry
 ELSEIF ((request->report_type="DOCUMENTAT"))
  EXECUTE afc_get_documentation
 ENDIF
END GO
