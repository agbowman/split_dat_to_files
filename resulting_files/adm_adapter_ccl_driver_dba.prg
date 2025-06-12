CREATE PROGRAM adm_adapter_ccl_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Request Key (string):" = 0,
  "Request Payload (json string):" = 0
  WITH outdev, requestkey, requestpayload
 RECORD med_availability_reply(
   1 reply_data
     2 orders[*]
       3 taskid = f8
       3 childorderid = f8
       3 parentorderid = f8
       3 orderdisplay = vc
       3 taskdttm = dq8
       3 lastdispensedttm = dq8
       3 startdttm = dq8
       3 orderenteredby = vc
       3 ordertype = vc
       3 isqueued = i4
       3 isqueueable = i4
       3 orderitems[*]
         4 itemid = f8
         4 itemdesc = vc
         4 witnessrequiredind = i2
         4 dispensealerts[*]
           5 alerttype = vc
           5 alertvalue = vc
         4 lastissuedata
           5 issuedttmdisp = vc
           5 username = vc
           5 locationname = vc
         4 ced_item_key = vc
         4 tnfid = f8
       3 dispenseroutinglocations[*]
         4 locationcd = f8
         4 locationdisp = vc
         4 bestlocationind = i4
         4 itemavailabilityind = i4
         4 dispenselocationtypeind = i4
         4 pendingtasks[*]
           5 taskid = f8
           5 tasktypedisp = vc
           5 locationcd = f8
           5 locationdisp = vc
         4 patient_specific_cabinet_ind = i2
       3 isverified = i2
       3 orderedasmnemonic = vc
       3 powerchartdisplay = vc
       3 isrejected = i2
       3 pendingrequests[*]
         4 username = vc
         4 requestdttmdisp = vc
         4 quantity = f8
         4 isforcurrentuser = i2
       3 unabletoqueuereason = vc
       3 range_dose_ind = i2
       3 minimum_range_dose = f8
       3 maximum_range_dose = f8
       3 amount_units_of_measure = vc
       3 ced_order_key = vc
       3 ced_amount = f8
       3 ced_amount_uom_key = vc
       3 ced_due_dt_tm = vc
       3 cedorderitems[*]
         4 ced_item_key = vc
         4 item_identifier = vc
         4 ced_amount = f8
         4 ced_amount_uom_key = vc
     2 caservice_statusinfo
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
     2 admuser_statusinfo
       3 adm_user_alias_exists = i4
       3 prsnl_alias_link_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD queue_task_reply(
   1 reply_data
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
     2 tasks[*]
       3 queue_id = f8
       3 task_id = f8
       3 data_state
         4 data_locked_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD dequeue_task_reply(
   1 reply_data
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
     2 tasks[*]
       3 queue_id = f8
       3 assigned_prsnl_id = f8
       3 task_id = f8
       3 data_state
         4 data_locked_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD retrieve_tasks_reply(
   1 reply_data
     2 tasks[*]
       3 patient_id = vc
       3 task_description = vc
       3 task_details[*]
         4 task_detail_id = vc
         4 task_detail_key_type_ind = i4
         4 task_detail_key_value = vc
       3 create_dt_tm = dq8
       3 expired_flag = i4
       3 task_id = f8
       3 foreign_user_id = f8
       3 task_type_ind = i4
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD user_maintenance_reply(
   1 reply_data
     2 user
       3 native_id = vc
       3 foreign_id = vc
       3 person_id = f8
       3 user_name = vc
       3 user_indicators
         4 can_queue_ind = i4
         4 can_waste_ind = i4
         4 can_witness_ind = i4
         4 can_credit_waste_ind = i4
       3 admuser_statusinfo
         4 adm_user_alias_exists = i4
         4 prsnl_alias_link_status = i4
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD remote_waste_reply(
   1 reply_data
     2 waste_statuses[*]
       3 waste_status = vc
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD search_item_reply(
   1 reply_data
     2 items[*]
       3 description = vc
       3 brand_name = vc
       3 item_identifier = vc
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD retrieve_txs_to_waste_reply(
   1 reply_data
     2 waste_txs[*]
       3 cdc_inputs[*]
         4 cdc_select_code_ind = i4
         4 cat_num = f8
         4 cat_name = vc
         4 required_ind = i4
         4 once_ind = i4
         4 override_ind = i4
         4 enter_ind = i4
         4 skipped_ind = i4
         4 list_num = f8
         4 list_name = vc
         4 list_abbr = vc
         4 cdc_answers[*]
           5 answer_num = f8
           5 answer_name = vc
           5 answer_abbr = vc
           5 list_num = f8
         4 answer_1 = vc
         4 answer_2 = vc
         4 answer_3 = vc
       3 give_amount = f8
       3 med_id = vc
       3 order_id = vc
       3 patient_credited_ind = i4
       3 patient_id = vc
       3 total_patient_transfer_amount = f8
       3 remaining_amount = f8
       3 remove_amount = f8
       3 orig_removed_med_tx_seq = i8
       3 orig_removed_med_tx_time = i8
       3 format_orig_rmved_med_tx_time = vc
       3 total_return_amount = f8
       3 total_waste_amount = f8
       3 waste_amount = f8
       3 waste_user_id = vc
       3 waste_user_name = vc
       3 witness_required_ind = i4
       3 witness_user_name = vc
       3 witness_id = vc
       3 device_id = vc
       3 fractional_flag_ind = i4
       3 undocumented_waste_ind = i4
       3 brand_name = vc
       3 generic_name = vc
       3 patient_name = vc
       3 strength = f8
       3 strength_units = vc
       3 volume = f8
       3 volume_units = vc
       3 waste_tx_time = dq8
       3 waste_tx_seq = i8
       3 waste_statuses[*]
         4 waste_status = vc
       3 waste_by_tx_ind = i4
       3 removed_by_user_name = vc
       3 removed_by_user_id = vc
       3 amount_units_of_measure = vc
       3 units_of_measure = vc
       3 dosage = vc
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
     2 waste_preferences
       3 area_type_ind = i2
       3 force_waste_dose_balance_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD invalid_request_key_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD retrieve_items_to_override_reply(
   1 reply_data
     2 override_items[*]
       3 med_id = vc
       3 generic_name = vc
       3 brand_name = vc
       3 amount_units_of_measure = vc
       3 format_orig_rmved_med_tx_time = vc
       3 removed_by_user_name = vc
       3 last_issue_location = vc
       3 warnings[*]
         4 value = vc
       3 witness_required_ind = i4
       3 admin_sites_required_ind = i4
       3 physician_required_ind = i4
     2 override_reasons_required_ind = i4
     2 admin_sites_info[*]
       3 admin_site = vc
     2 physician_info[*]
       3 physician_name = vc
     2 default_physician_name = vc
     2 override_reasons_info[*]
       3 override_reason = vc
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD remote_override_reply(
   1 reply_data
     2 override_items[*]
       3 item_availabilty_ind = i4
       3 dispense_locations[*]
         4 location_cd = f8
         4 location_disp = vc
         4 availability_ind = i4
         4 available_quantity = f8
         4 patient_specific_cabinet_ind = i4
     2 status_info
       3 operation_status_flag = i4
       3 operation_name = vc
       3 operation_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD get_adm_preferences_reply(
   1 reply_data
     2 adm_prefs[*]
       3 id = f8
       3 name = vc
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD get_retractable_orders_reply(
   1 retractable_orders_reply_data
     2 orders[*]
       3 order_id = f8
       3 description = vc
       3 dispense_hx_id = f8
       3 dispense_dt_tm = dq8
       3 executor
         4 personnel_id = f8
         4 formatted_name = vc
       3 retractable_total_volume = f8
       3 multi_ingredient_order_ind = i2
       3 product_activities[*]
         4 item
           5 item_id = f8
           5 description = vc
           5 strength_ind = i2
           5 strength
             6 uom_cd = f8
             6 uom_display = vc
             6 value = f8
           5 volume_ind = i2
           5 volume
             6 uom_cd = f8
             6 uom_display = vc
             6 value = f8
           5 dummy_ind = i2
           5 legalstatus
             6 legal_status_cd = f8
             6 display = vc
             6 controlled_ind = i2
         4 dispense_qty = f8
         4 retractable_qty = f8
         4 prediction
           5 strength_prediction_ind = i2
           5 strength_prediction
             6 uom_cd = f8
             6 uom_display = vc
             6 value = f8
           5 volume_prediction_ind = i2
           5 volume_prediction
             6 uom_cd = f8
             6 uom_display = vc
             6 value = f8
       3 accessibility
         4 wasteable_ind = i2
         4 returnable_ind = i2
         4 waste_witness_ind = i2
         4 return_witness_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD save_order_dispenses_reply(
   1 reply_data
     2 order_dispenses[*]
       3 dispense_hx_id = f8
       3 dispense_status
         4 status = vc
         4 status_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD get_waste_reason_codes_reply(
   1 events[*]
     2 event_cd = f8
     2 reasons[*]
       3 reason_cd = f8
       3 credit_ind = i2
       3 text_required_ind = i2
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD create_med_request_alerts_reply(
   1 requested_medications[*]
     2 rxs_med_request_id = f8
     2 order_id = f8
     2 item_id = f8
     2 alert_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD get_med_request_alerts_reply(
   1 alerts[*]
     2 alert_source = i2
     2 rxs_alert_id = f8
     2 alert_status_cd = f8
     2 alert_type_cd = f8
     2 alert_svrty_cd = f8
     2 create_prsnl_id = f8
     2 create_prsnl_name = vc
     2 create_dt_tm = dq8
     2 cluster_cd = f8
     2 location_cd = f8
     2 location_disp = vc
     2 locator_cd = f8
     2 locator_disp = vc
     2 alert_text = vc
     2 items[*]
       3 inv_item_id = f8
       3 med_item_id = f8
       3 item_description = vc
       3 item_brand_name = vc
       3 legal_status_cd = f8
     2 audit_history[*]
       3 rx_audit_hx_id = f8
       3 audit_type_cd = f8
       3 prsnl_id = f8
       3 prsnl_name = vc
       3 audit_dt_tm = dq8
     2 med_request[*]
       3 med_req_id = f8
       3 med_req_prsnl_id = f8
       3 med_req_prsnl_name = vc
       3 med_req_type_cd = f8
       3 med_req_dt_tm = dq8
       3 med_req_reason_cd = f8
       3 med_req_reason_text = vc
     2 alert_description = vc
     2 update_dt_tm = dq8
     2 last_updt_hrs = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD get_adm_domain_type_by_encounter_id_reply(
   1 reply_data
     2 adm_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_authentication_reply(
   1 reply_data
     2 authentication_detail
       3 adm_domain = vc
       3 ibus_domain = vc
       3 login_url = vc
       3 status_flag = i2
     2 can_queue = i2
     2 can_waste = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_retrieve_wasteables_reply(
   1 reply_data
     2 wasteable_details[*]
       3 wasteable_key = vc
       3 medication_display = vc
       3 removed_user = vc
       3 removed_dt_tm_formatted = vc
       3 is_partial_dose = i2
       3 is_strength_visible = i2
       3 is_strength_editable = i2
       3 is_volume_visible = i2
       3 is_volume_editable = i2
       3 strength_display_code = vc
       3 volume_display_code = vc
       3 dosage_form = vc
       3 available_dose_dispose_amt = f8
       3 available_strength_dispose_amt = f8
       3 available_volume_dispose_amt = f8
       3 is_controlled = i2
       3 dispose_amount = f8
       3 dispose_amount_uom = vc
       3 undocumented_amount = f8
       3 undocumented_amount_uom = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_waste_start_reply(
   1 reply_data
     2 waste_cdcs[*]
       3 cdc_key = vc
       3 answer_type = vc
       3 question_text = vc
       3 question_title = vc
       3 possible_answers[*]
         4 cdc_answer_key = vc
         4 code = vc
         4 text = vc
     2 wasteable_detail
       3 wasteable_key = vc
       3 medication_display = vc
       3 removed_user = vc
       3 removed_dt_tm_formatted = vc
       3 is_partial_dose = i2
       3 is_strength_visible = i2
       3 is_strength_editable = i2
       3 is_volume_visible = i2
       3 is_volume_editable = i2
       3 strength_display_code = vc
       3 volume_display_code = vc
       3 dosage_form = vc
       3 available_dose_dispose_amt = f8
       3 available_strength_dispose_amt = f8
       3 available_volume_dispose_amt = f8
       3 is_controlled = i2
       3 dispose_amount = f8
       3 dispose_amount_uom = vc
       3 undocumented_amount = f8
       3 undocumented_amount_uom = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_waste_submit_cdcs_reply(
   1 reply_data
     2 wasteable_detail
       3 wasteable_key = vc
       3 medication_display = vc
       3 removed_user = vc
       3 removed_dt_tm_formatted = vc
       3 is_partial_dose = i2
       3 is_strength_visible = i2
       3 is_strength_editable = i2
       3 is_volume_visible = i2
       3 is_volume_editable = i2
       3 strength_display_code = vc
       3 volume_display_code = vc
       3 dosage_form = vc
       3 available_dose_dispose_amt = f8
       3 available_strength_dispose_amt = f8
       3 available_volume_dispose_amt = f8
       3 is_controlled = i2
       3 dispose_amount = f8
       3 dispose_amount_uom = vc
       3 undocumented_amount = f8
       3 undocumented_amount_uom = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_waste_submit_quantities_reply(
   1 reply_data
     2 witness_required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mses_waste_submit_witness_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lapp_num = i4 WITH protect, constant(3202004)
 DECLARE ltask_num = i4 WITH protect, constant(3202004)
 DECLARE ecrmok = i2 WITH protect, constant(0)
 DECLARE string40 = i4 WITH protect, constant(40)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE hstatusdata = i4 WITH protect, noconstant(0)
 DECLARE ncrmstat = i2 WITH protect, noconstant(0)
 DECLARE nsrvstat = i2 WITH protect, noconstant(0)
 DECLARE g_perform_failed = i2 WITH protect, noconstant(0)
 SUBROUTINE (initializeapptaskrequest(recorddata=vc(ref),appnumber=i4(val),tasknumber=i4(val),
  requestnumber=i4(val)) =null WITH protect)
   SET ncrmstat = uar_crmbeginapp(appnumber,happ)
   IF (((ncrmstat != ecrmok) OR (happ=0)) )
    CALL handleerror("BEGIN","F","Application Handle",cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
   SET ncrmstat = uar_crmbegintask(happ,tasknumber,htask)
   IF (((ncrmstat != ecrmok) OR (htask=0)) )
    CALL handleerror("BEGIN","F","Task Handle",cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
   SET ncrmstat = uar_crmbeginreq(htask,0,requestnumber,hstep)
   IF (((ncrmstat != ecrmok) OR (hstep=0)) )
    CALL handleerror("BEGIN","F","Req Handle",cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    CALL handleerror("GET","F","Req Handle",cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializerequest(recorddata=vc(ref),requestnumber=i4(val)) =null WITH protect)
   CALL initializeapptaskrequest(recorddata,lapp_num,ltask_num,requestnumber)
 END ;Subroutine
 SUBROUTINE (createdatetimefromhandle(hhandle=i4(ref),sdatedataelement=vc(val),stimezonedataelement=
  vc(val)) =vc WITH protect)
   DECLARE time_zone = i4 WITH noconstant(0), protect
   DECLARE return_val = vc WITH noconstant(""), protect
   SET stat = uar_srvgetdate(hhandle,nullterm(sdatedataelement),recdate->datetime)
   IF (stimezonedataelement != "")
    SET time_zone = uar_srvgetlong(hhandle,nullterm(stimezonedataelement))
   ENDIF
   IF (validate(recdate->datetime,0))
    SET return_val = build(replace(datetimezoneformat(cnvtdatetime(recdate->datetime),
       datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET return_val = ""
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (handleerror(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc,
  recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "F"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   SET g_perform_failed = 1
 END ;Subroutine
 SUBROUTINE (handlenodata(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc,recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "Z"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE (exit_servicerequest(happ=i4,htask=i4,hstep=i4) =null WITH protect)
   IF (hstep != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE exit_srvrequest(hmsg,hreq,hrep)
   IF (hmsg != 0)
    SET nsrvstat = uar_srvdestroyinstance(hmsg)
   ENDIF
   IF (hreq != 0)
    SET nsrvstat = uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hrep != 0)
    SET nsrvstat = uar_srvdestroyinstance(hrep)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereply(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2) =i4 WITH protect
  )
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus="Z")
     CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
     IF (zeroforceexit=1)
      GO TO exit_script
     ENDIF
    ELSEIF (sstatus != "S")
     SET subeventstatuscount = uar_srvgetitemcount(hstatusdata,"subeventstatus")
     IF (subeventstatuscount > 0)
      SET stat = alterlist(recorddata->status_data.subeventstatus,subeventstatuscount)
      SET recorddata->status_data.status = "F"
      FOR (x = 0 TO (subeventstatuscount - 1))
        SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",x)
        SET recorddata->status_data.subeventstatus[(x+ 1)].operationname = uar_srvgetstringptr(hitem,
         "OperationName")
        SET recorddata->status_data.subeventstatus[(x+ 1)].operationstatus = uar_srvgetstringptr(
         hitem,"OperationStatus")
        SET recorddata->status_data.subeventstatus[(x+ 1)].targetobjectname = uar_srvgetstringptr(
         hitem,"TargetObjectName")
        SET recorddata->status_data.subeventstatus[(x+ 1)].targetobjectvalue = uar_srvgetstringptr(
         hitem,"TargetObjectValue")
      ENDFOR
     ELSE
      CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicatordynamic(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc,statusblock=vc) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE successind = i2 WITH noconstant(0), protect
   DECLARE errormessage = vc WITH noconstant(""), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,nullterm(statusblock))
    SET successind = uar_srvgetshort(hstatusdata,"success_ind")
    SET errormessage = uar_srvgetstringptr(hstatusdata,"debug_error_message")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status Indicator: ",successind))
     CALL echo(build("Error Message: ",errormessage))
    ENDIF
    IF (successind != 1)
     CALL handleerror("ValidateReplyIndicator","F",srv_request,errormessage,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ELSEIF (trim(recordname) != "")
     SET resultlistcnt = uar_srvgetitemcount(hrep,nullterm(recordname))
     IF (resultlistcnt=0)
      IF (validate(debug_ind,0)=1)
       CALL echo(build("ZERO RESULTS found in [",trim(recordname,3),"]"))
      ENDIF
      CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
      IF (zeroforceexit=1)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicator(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc) =i4 WITH protect)
   CALL validatereplyindicatordynamic(ncrmstat,hstep,recorddata,zeroforceexit,recordname,
    "status_data")
 END ;Subroutine
 DECLARE med_availability_request_number = i4 WITH protect, constant(395113)
 DECLARE med_availability_srv_request = vc WITH constant("RxsGetMedAvailabilityDetails"), protect
 SUBROUTINE (processmedavailabilityrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processMedAvailabilityRequest started...")
   CALL initializerequest(med_availability_reply,med_availability_request_number)
   CALL preparemedavailability(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,med_availability_reply,1)
   IF ((med_availability_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translatemedavailability(hrep)
   ENDIF
   SET med_availability_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparemedavailability(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request...")
   SET nsrvstat = uar_srvsetdouble(srvrequest,"personId",cnvtreal(med_availability_request->
     patient_id))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"encounterId",cnvtreal(med_availability_request->
     encounter_id))
   SET nsrvstat = uar_srvsetdate(srvrequest,"dateRangeStartDtTm",cnvtdatetime(
     med_availability_request->start_date_time))
   SET nsrvstat = uar_srvsetdate(srvrequest,"dateRangeEndDtTm",cnvtdatetime(med_availability_request
     ->end_date_time))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"userId",cnvtreal(med_availability_request->provider_id
     ))
   SET nsrvstat = uar_srvsetstring(srvrequest,"admUserId",nullterm(med_availability_request->
     provider_foreign_id))
   SET nsrvstat = uar_srvsetshort(srvrequest,"admTypeInd",cnvtint(validate(med_availability_request->
      adm_type_ind,"0")))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"position_cd",cnvtreal(med_availability_request->
     position_cd))
   CALL echo("Exit prepareMedAvailability")
 END ;Subroutine
 SUBROUTINE (translatemedavailability(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateMedAvailability()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE hordertasklistitem = i4 WITH noconstant(0), protect
   DECLARE hdisproutingloclistitem = i4 WITH noconstant(0), protect
   DECLARE hitemslistitem = i4 WITH noconstant(0), protect
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   DECLARE hadmuserservicestatusinfoitem = i4 WITH noconstant(0), protect
   DECLARE hpendingtasklistitem = i4 WITH noconstant(0), protect
   DECLARE hamountinstance = i4 WITH noconstant(0), protect
   DECLARE pendingtaskscnt = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE pendingtaskidx = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("caservice_statusInfo")
    )
   SET med_availability_reply->reply_data.caservice_statusinfo.operation_status_flag =
   uar_srvgetshort(hcaservicestatusinfoitem,"operation_status_flag")
   SET med_availability_reply->reply_data.caservice_statusinfo.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET med_availability_reply->reply_data.caservice_statusinfo.operation_detail = uar_srvgetstringptr
   (hcaservicestatusinfoitem,"operation_detail")
   SET hadmuserservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm(
     "admuser_statusInfo"))
   SET med_availability_reply->reply_data.admuser_statusinfo.adm_user_alias_exists = uar_srvgetshort(
    hadmuserservicestatusinfoitem,"adm_user_alias_exists")
   SET med_availability_reply->reply_data.admuser_statusinfo.prsnl_alias_link_status =
   uar_srvgetshort(hadmuserservicestatusinfoitem,"prsnl_alias_link_status")
   SET ordertasklistcnt = uar_srvgetitemcount(replydatainstance,nullterm("orderTaskList"))
   SET stat = alterlist(med_availability_reply->reply_data.orders,ordertasklistcnt)
   FOR (x = 1 TO ordertasklistcnt)
     SET hordertasklistitem = uar_srvgetitem(replydatainstance,nullterm("orderTaskList"),(x - 1))
     SET med_availability_reply->reply_data.orders[x].taskid = uar_srvgetdouble(hordertasklistitem,
      "taskId")
     SET med_availability_reply->reply_data.orders[x].childorderid = uar_srvgetdouble(
      hordertasklistitem,"childOrderId")
     SET med_availability_reply->reply_data.orders[x].parentorderid = uar_srvgetdouble(
      hordertasklistitem,"parentOrderId")
     SET med_availability_reply->reply_data.orders[x].orderedasmnemonic = uar_srvgetstringptr(
      hordertasklistitem,"orderedAsMnemonic")
     SET med_availability_reply->reply_data.orders[x].orderdisplay = uar_srvgetstringptr(
      hordertasklistitem,"orderDisplay")
     SET stat = uar_srvgetdate(hordertasklistitem,"taskDtTm",med_availability_reply->reply_data.
      orders[x].taskdttm)
     SET stat = uar_srvgetdate(hordertasklistitem,"lastDispenseDtTm",med_availability_reply->
      reply_data.orders[x].lastdispensedttm)
     SET stat = uar_srvgetdate(hordertasklistitem,"startDtTm",med_availability_reply->reply_data.
      orders[x].startdttm)
     SET med_availability_reply->reply_data.orders[x].orderenteredby = uar_srvgetstringptr(
      hordertasklistitem,"orderEnteredBy")
     SET med_availability_reply->reply_data.orders[x].ordertype = uar_srvgetstringptr(
      hordertasklistitem,"orderType")
     SET med_availability_reply->reply_data.orders[x].isqueued = uar_srvgetshort(hordertasklistitem,
      "isQueued")
     SET med_availability_reply->reply_data.orders[x].isqueueable = uar_srvgetshort(
      hordertasklistitem,"isQueueable")
     SET med_availability_reply->reply_data.orders[x].isverified = uar_srvgetshort(hordertasklistitem,
      "isVerified")
     SET med_availability_reply->reply_data.orders[x].powerchartdisplay = uar_srvgetstringptr(
      hordertasklistitem,"powerchart_display")
     SET med_availability_reply->reply_data.orders[x].isrejected = uar_srvgetshort(hordertasklistitem,
      "isRejected")
     SET med_availability_reply->reply_data.orders[x].unabletoqueuereason = uar_srvgetstringptr(
      hordertasklistitem,"unable_to_queue_reason")
     SET rangedose = evaluate(uar_srvgetshort(hordertasklistitem,"range_dose_ind"),1,1,0,0)
     IF (validate(rangedose))
      SET med_availability_reply->reply_data.orders[x].range_dose_ind = uar_srvgetshort(
       hordertasklistitem,"range_dose_ind")
      SET med_availability_reply->reply_data.orders[x].minimum_range_dose = uar_srvgetdouble(
       hordertasklistitem,"minimum_range_dose")
     ENDIF
     SET maximumdose = evaluate(uar_srvgetdouble(hordertasklistitem,"maximum_range_dose"),1,1,0,0)
     IF (validate(maximumdose))
      SET med_availability_reply->reply_data.orders[x].maximum_range_dose = uar_srvgetdouble(
       hordertasklistitem,"maximum_range_dose")
      SET med_availability_reply->reply_data.orders[x].amount_units_of_measure = uar_srvgetstringptr(
       hordertasklistitem,"amount_units_of_measure")
     ENDIF
     SET hcedextension = uar_srvgetstruct(hordertasklistitem,nullterm("ced_order_extension"))
     SET med_availability_reply->reply_data.orders[x].ced_order_key = uar_srvgetstringptr(
      hcedextension,"order_key")
     SET med_availability_reply->reply_data.orders[x].ced_amount = uar_srvgetdouble(hcedextension,
      "amount")
     SET med_availability_reply->reply_data.orders[x].ced_amount_uom_key = uar_srvgetstringptr(
      hcedextension,"uom_key")
     SET med_availability_reply->reply_data.orders[x].ced_due_dt_tm = uar_srvgetstringptr(
      hcedextension,"duedatetime")
     SET itemslistcnt = uar_srvgetitemcount(hcedextension,nullterm("itemList"))
     SET stat = alterlist(med_availability_reply->reply_data.orders[x].cedorderitems,itemslistcnt)
     FOR (z = 1 TO itemslistcnt)
       SET hitemslistitem = uar_srvgetitem(hcedextension,nullterm("itemList"),(z - 1))
       SET med_availability_reply->reply_data.orders[x].cedorderitems[z].ced_item_key =
       uar_srvgetstringptr(hitemslistitem,"itemKey")
       SET med_availability_reply->reply_data.orders[x].cedorderitems[z].item_identifier =
       uar_srvgetstringptr(hitemslistitem,"itemIdentifier")
       SET hamountinstance = uar_srvgetstruct(hitemslistitem,nullterm("amount"))
       SET med_availability_reply->reply_data.orders[x].cedorderitems[z].ced_amount =
       uar_srvgetdouble(hamountinstance,"amount")
       SET med_availability_reply->reply_data.orders[x].cedorderitems[z].ced_amount_uom_key =
       uar_srvgetstringptr(hamountinstance,"uom_key")
     ENDFOR
     SET itemslistcnt = uar_srvgetitemcount(hordertasklistitem,nullterm("itemsList"))
     SET stat = alterlist(med_availability_reply->reply_data.orders[x].orderitems,itemslistcnt)
     FOR (z = 1 TO itemslistcnt)
       SET hitemslistitem = uar_srvgetitem(hordertasklistitem,nullterm("itemsList"),(z - 1))
       SET med_availability_reply->reply_data.orders[x].orderitems[z].itemid = uar_srvgetdouble(
        hitemslistitem,"itemId")
       SET med_availability_reply->reply_data.orders[x].orderitems[z].itemdesc = uar_srvgetstringptr(
        hitemslistitem,"itemDescription")
       SET med_availability_reply->reply_data.orders[x].orderitems[z].witnessrequiredind =
       uar_srvgetshort(hitemslistitem,"witness_required_ind")
       SET dispensealertslistcnt = uar_srvgetitemcount(hitemslistitem,nullterm("dispense_alerts"))
       SET stat = alterlist(med_availability_reply->reply_data.orders[x].orderitems[z].dispensealerts,
        dispensealertslistcnt)
       FOR (dispensealertsidx = 1 TO dispensealertslistcnt)
         SET hdispensealertslistitem = uar_srvgetitem(hitemslistitem,nullterm("dispense_alerts"),(
          dispensealertsidx - 1))
         SET med_availability_reply->reply_data.orders[x].orderitems[z].dispensealerts[
         dispensealertsidx].alerttype = uar_srvgetstringptr(hdispensealertslistitem,"alert_type")
         SET med_availability_reply->reply_data.orders[x].orderitems[z].dispensealerts[
         dispensealertsidx].alertvalue = uar_srvgetstringptr(hdispensealertslistitem,"alert_value")
       ENDFOR
       SET lastissuedatainstance = uar_srvgetstruct(hitemslistitem,nullterm("last_issue_data"))
       SET med_availability_reply->reply_data.orders[x].orderitems[z].lastissuedata.issuedttmdisp =
       uar_srvgetstringptr(lastissuedatainstance,"issue_dt_tm_disp")
       SET med_availability_reply->reply_data.orders[x].orderitems[z].lastissuedata.username =
       uar_srvgetstringptr(lastissuedatainstance,"user_name")
       SET med_availability_reply->reply_data.orders[x].orderitems[z].lastissuedata.locationname =
       uar_srvgetstringptr(lastissuedatainstance,"location_name")
       SET hceditemextension = uar_srvgetstruct(hitemslistitem,nullterm("ced_item_extension"))
       SET med_availability_reply->reply_data.orders[x].orderitems[z].ced_item_key =
       uar_srvgetstringptr(hceditemextension,"itemkey")
       SET med_availability_reply->reply_data.orders[x].orderitems[z].tnfid = uar_srvgetdouble(
        hitemslistitem,"tnfId")
     ENDFOR
     SET dispenseroutingloclistcnt = uar_srvgetitemcount(hordertasklistitem,nullterm(
       "dispenseRoutingLocationList"))
     SET stat = alterlist(med_availability_reply->reply_data.orders[x].dispenseroutinglocations,
      dispenseroutingloclistcnt)
     FOR (y = 1 TO dispenseroutingloclistcnt)
       SET hdisproutingloclistitem = uar_srvgetitem(hordertasklistitem,nullterm(
         "dispenseRoutingLocationList"),(y - 1))
       SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].locationcd =
       uar_srvgetdouble(hdisproutingloclistitem,"locationCd")
       SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].locationdisp =
       uar_srvgetstringptr(hdisproutingloclistitem,"locationDisp")
       SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].bestlocationind
        = uar_srvgetshort(hdisproutingloclistitem,"bestLocationInd")
       SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].
       itemavailabilityind = uar_srvgetshort(hdisproutingloclistitem,"itemAvailabilityInd")
       SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].
       dispenselocationtypeind = uar_srvgetshort(hdisproutingloclistitem,"dispenseLocationTypeInd")
       SET pendingtaskscnt = uar_srvgetitemcount(hdisproutingloclistitem,nullterm("pendingTasks"))
       SET stat = alterlist(med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].
        pendingtasks,pendingtaskscnt)
       FOR (pendingtaskidx = 1 TO pendingtaskscnt)
         SET hpendingtasklistitem = uar_srvgetitem(hdisproutingloclistitem,nullterm("pendingTasks"),(
          pendingtaskidx - 1))
         SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].pendingtasks[
         pendingtaskidx].taskid = uar_srvgetdouble(hpendingtasklistitem,"taskId")
         SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].pendingtasks[
         pendingtaskidx].tasktypedisp = uar_srvgetstringptr(hpendingtasklistitem,"taskTypeDisp")
         SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].pendingtasks[
         pendingtaskidx].locationcd = uar_srvgetdouble(hpendingtasklistitem,"locationCd")
         SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].pendingtasks[
         pendingtaskidx].locationdisp = uar_srvgetstringptr(hpendingtasklistitem,"locationDisp")
       ENDFOR
       SET patientspecificcabinet = evaluate(uar_srvgetshort(hordertasklistitem,
         "patient_specific_cabinet_ind"),1,1,0,0)
       IF (validate(patientspecificcabinet))
        SET med_availability_reply->reply_data.orders[x].dispenseroutinglocations[y].
        patient_specific_cabinet_ind = uar_srvgetshort(hdisproutingloclistitem,
         "patient_specific_cabinet_ind")
       ENDIF
     ENDFOR
     SET pendingrequestslistcnt = uar_srvgetitemcount(hordertasklistitem,nullterm("pending_requests")
      )
     SET stat = alterlist(med_availability_reply->reply_data.orders[x].pendingrequests,
      pendingrequestslistcnt)
     FOR (pendingrequestsidx = 1 TO pendingrequestslistcnt)
       SET hpendingrequestslistitem = uar_srvgetitem(hordertasklistitem,nullterm("pending_requests"),
        (pendingrequestsidx - 1))
       SET med_availability_reply->reply_data.orders[x].pendingrequests[pendingrequestsidx].username
        = uar_srvgetstringptr(hpendingrequestslistitem,"user_name")
       SET med_availability_reply->reply_data.orders[x].pendingrequests[pendingrequestsidx].
       requestdttmdisp = uar_srvgetstringptr(hpendingrequestslistitem,"request_dt_tm_disp")
       SET med_availability_reply->reply_data.orders[x].pendingrequests[pendingrequestsidx].quantity
        = uar_srvgetdouble(hpendingrequestslistitem,"quantity")
       SET med_availability_reply->reply_data.orders[x].pendingrequests[pendingrequestsidx].
       isforcurrentuser = uar_srvgetshort(hpendingrequestslistitem,"is_for_current_user")
     ENDFOR
   ENDFOR
   CALL echorecord(med_availability_reply)
   CALL echo(build("Exit translateMedAvailability(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 DECLARE queue_task_request_number = i4 WITH protect, constant(395201)
 DECLARE retrieve_tasks_request_number = i4 WITH protect, constant(395202)
 DECLARE queue_task_srv_request = vc WITH constant("QueueTask"), protect
 DECLARE retrieve_tasks_srv_request = vc WITH constant("RetrieveTasks"), protect
 DECLARE adm_cfn = i2 WITH protect, constant(0)
 DECLARE adm_rxs = i2 WITH protect, constant(1)
 DECLARE srv_request = vc WITH protect
 SUBROUTINE (processqueuetaskrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processQueueTaskRequest started...")
   DECLARE adm_type = i2 WITH protect, constant(cnvtint(validate(queue_task_request->adm_type_ind,"0"
      )))
   IF (adm_type=adm_rxs)
    CALL handlerxsqueuetaskrequest(cclrequest)
   ELSE
    SET srv_request = queue_task_srv_request
    CALL initializerequest(queue_task_reply,queue_task_request_number)
    CALL preparequeuetask(cclrequest,hreq)
    SET ncrmstat = uar_crmperform(hstep)
    SET hrep = validatereply(ncrmstat,hstep,queue_task_reply,1)
    IF ((queue_task_reply->status_data.status="Z"))
     GO TO exit_script
    ELSE
     CALL translatequeuetask(hrep)
    ENDIF
    SET queue_task_reply->status_data.status = "S"
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (processdequeuetaskrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processDequeueTaskRequest started...")
   DECLARE adm_type = i2 WITH protect, constant(cnvtint(validate(dequeue_task_request->adm_type_ind,
      "0")))
   IF (adm_type=adm_rxs)
    CALL handlerxsdequeuetaskrequest(cclrequest)
   ELSE
    CALL handleerror("adm_adapter_ccl_tasks","F","processDequeueTaskRequest",build(
      "unsupported ADM TYPE:",adm_type),dequeue_task_reply)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (preparequeuetask(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request...")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(queue_task_request->user.
     person_id))
   DECLARE taskinstance = i4 WITH noconstant(0), protect
   SET taskinstance = uar_srvgetstruct(srvrequest,nullterm("task"))
   SET nsrvstat = uar_srvsetdouble(taskinstance,"patient_id",cnvtreal(queue_task_request->task.
     patient_id))
   SET nsrvstat = uar_srvsetdouble(taskinstance,"encounter_id",cnvtreal(queue_task_request->task.
     encounter_id))
   SET nsrvstat = uar_srvsetshort(taskinstance,"task_type_ind",queue_task_request->task.task_type_ind
    )
   DECLARE taskdetailsinstance = i4 WITH noconstant(0), protect
   DECLARE taskdetailcount = i4 WITH noconstant(0), protect
   FOR (taskdetailcount = 1 TO size(queue_task_request->task.task_details,5))
     SET taskdetailsinstance = uar_srvadditem(taskinstance,"task_details")
     SET nsrvstat = uar_srvsetshort(taskdetailsinstance,"task_detail_key_type_ind",queue_task_request
      ->task.task_details[taskdetailcount].task_detail_key_type_ind)
     SET nsrvstat = uar_srvsetstring(taskdetailsinstance,"task_detail_key_value",nullterm(
       queue_task_request->task.task_details[taskdetailcount].task_detail_key_value))
     IF (validate(queue_task_request->task.task_details[taskdetailcount].task_detail_events))
      DECLARE taskdetaileventsinstance = i4 WITH noconstant(0), protect
      DECLARE taskdetaileventscount = i4 WITH noconstant(0), protect
      FOR (taskdetaileventscount = 1 TO size(queue_task_request->task.task_details[taskdetailcount].
       task_detail_events,5))
       SET taskdetaileventsinstance = uar_srvadditem(taskdetailsinstance,"task_detail_events")
       SET nsrvstat = uar_srvsetdate(taskdetaileventsinstance,"due_time",
        convertisodatetimetoccldatetime(queue_task_request->task.task_details[taskdetailcount].
         task_detail_events[taskdetaileventscount].due_time))
      ENDFOR
     ENDIF
     IF (validate(queue_task_request->task.task_details[taskdetailcount].intended_dose))
      SET nsrvstat = uar_srvsetdouble(taskdetailsinstance,"intended_dose",cnvtreal(queue_task_request
        ->task.task_details[taskdetailcount].intended_dose))
     ENDIF
   ENDFOR
   CALL echorecord(queue_task_request)
 END ;Subroutine
 SUBROUTINE (translatequeuetask(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateQueueTask()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE statusinfoinstance = i4 WITH noconstant(0), protect
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   SET statusinfoinstance = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET queue_task_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    statusinfoinstance,"operation_status_flag")
   SET queue_task_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    statusinfoinstance,"operation_name")
   SET queue_task_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    statusinfoinstance,"operation_detail")
   CALL echorecord(queue_task_reply)
   CALL echo(build("Exit translateQueueTask(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)))
 END ;Subroutine
 SUBROUTINE (processretrievetasksrequest(cclrequest=i4(ref)) =null WITH protect)
   CALL echo("processRetrieveTasksRequest started...")
   SET srv_request = retrieve_tasks_srv_request
   CALL initializerequest(retrieve_tasks_reply,retrieve_tasks_request_number)
   CALL prepareretrievetasks(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,retrieve_tasks_reply,1)
   IF ((retrieve_tasks_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateretrievetasks(hrep)
   ENDIF
   SET retrieve_tasks_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (prepareretrievetasks(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request...")
   SET nsrvstat = uar_srvsetshort(srvrequest,"retrieve_task_detail_filter_ind",cclrequest->
    retrieve_task_detail_filter_ind)
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetstring(userinstance,"native_id",nullterm(cclrequest->user.native_id))
   SET nsrvstat = uar_srvsetstring(userinstance,"foreign_id",nullterm(cclrequest->user.foreign_id))
   CALL echo(srvrequest)
 END ;Subroutine
 SUBROUTINE (translateretrievetasks(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateRetrieveTasks()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE statusinfoinstance = i4 WITH noconstant(0), protect
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   SET statusinfoinstance = uar_srvgetstruct(replydatainstance,nullterm("statusInfo"))
   SET retrieve_tasks_reply->reply_data.statusinfo.operation_status_flag = uar_srvgetshort(
    statusinfoinstance,"operation_status_flag")
   SET retrieve_tasks_reply->reply_data.statusinfo.operation_name = uar_srvgetstringptr(
    statusinfoinstance,"operation_name")
   SET retrieve_tasks_reply->reply_data.statusinfo.operation_detail = uar_srvgetstringptr(
    statusinfoinstance,"operation_detail")
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE taskinstance = i4 WITH noconstant(0), protect
   SET taskscnt = uar_srvgetitemcount(reply_data,nullterm("tasks"))
   SET stat = alterlist(retrieve_tasks_reply->reply_data.tasks,taskscnt)
   FOR (x = 0 TO (taskscnt - 1))
     SET taskinstance = uar_srvgetitem(reply_data,nullterm("tasks"),x)
     SET retrieve_tasks_reply->reply_data.tasks[x].patientid = uar_srvgetstring(taskinstance,
      "patient_id")
     SET retrieve_tasks_reply->reply_data.tasks[x].taskdescription = uar_srvgetstring(taskinstance,
      "task_description")
     SET retrieve_tasks_reply->reply_data.tasks[x].createdttm = uar_srvgetdate(taskinstance,
      "create_dt_tm")
     SET retrieve_tasks_reply->reply_data.tasks[x].expiredflag = uar_srvgetshort(taskinstance,
      "expired_flag")
     SET retrieve_tasks_reply->reply_data.tasks[x].taskid = uar_srvgetstring(taskinstance,"task_id")
     SET retrieve_tasks_reply->reply_data.tasks[x].foreignuserid = uar_srvgetstring(taskinstance,
      "foreign_user_id")
     SET retrieve_tasks_reply->reply_data.tasks[x].tasktypeind = uar_srvgetshort(taskinstance,
      "task_type_ind")
     SET taskdetailscnt = uar_srvgetitemcount(taskinstance,nullterm("task_details"))
     SET stat = alterlist(retrieve_tasks_reply->reply_data.tasks[x].taskdetails,tasksdetailscnt)
     FOR (y = 0 TO (tasksdetailscnt - 1))
       SET retrieve_tasks_reply->reply_data.tasks[x].taskdetails[y].taskdetailid = uar_srvgetstring(
        taskinstance,"task_detail_id")
       SET retrieve_tasks_reply->reply_data.tasks[x].taskdetails[y].taskdetailkeytypeind =
       uar_srvgetshort(taskinstance,"task_detail_key_type_ind")
       SET retrieve_tasks_reply->reply_data.tasks[x].taskdetails[y].taskdetailkeyvalue =
       uar_srvgetstring(taskinstance,"task_detail_key_value")
     ENDFOR
   ENDFOR
   CALL echorecord(retrieve_tasks_reply)
   CALL echo(build("Exit translateRetrieveTasks(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 SUBROUTINE (handlerxsqueuetaskrequest(cclrequest=i4(ref)) =null WITH protect)
   CALL echo("Entering handleRxsQueueTaskRequest")
   DECLARE errormsg = vc WITH protect, noconstant("")
   DECLARE block_size = i4 WITH protect, constant(5)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE taskidx = i4 WITH protect, noconstant(1)
   DECLARE orderidx = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE rxstaskidx = i4 WITH protect, noconstant(0)
   CALL echorecord(queue_task_request)
   EXECUTE rxs_declare_395123
   SET req395123->lock_ind = 1
   SET stat = alterlist(req395123->personnel,1)
   SET req395123->personnel[1].assigned_prsnl_id = cnvtreal(queue_task_request->user.person_id)
   FOR (taskidx = 1 TO size(queue_task_request->task.task_details,5))
     SET orderidx = locateval(idx,1,ordercnt,cnvtreal(queue_task_request->task.task_details[taskidx].
       order_id),req395123->personnel[1].orders[idx].order_id)
     IF (orderidx=0)
      SET ordercnt += 1
      IF (mod(ordercnt,block_size)=1)
       SET stat = alterlist(req395123->personnel[1].orders,((ordercnt+ block_size) - 1))
      ENDIF
      SET orderidx = ordercnt
      SET req395123->personnel[1].orders[orderidx].order_id = cnvtreal(queue_task_request->task.
       task_details[taskidx].order_id)
      SET req395123->personnel[1].orders[orderidx].patient_id = cnvtreal(queue_task_request->task.
       patient_id)
     ENDIF
     SET rxstaskidx = locateval(idx,1,size(req395123->personnel[1].orders[orderidx].tasks,5),cnvtreal
      (queue_task_request->task.task_details[taskidx].task_id),req395123->personnel[1].orders[
      orderidx].tasks[idx].task_id)
     IF (rxstaskidx=0)
      SET rxstaskidx = (size(req395123->personnel[1].orders[orderidx].tasks,5)+ 1)
      SET stat = alterlist(req395123->personnel[1].orders[orderidx].tasks,rxstaskidx)
      SET req395123->personnel[1].orders[orderidx].tasks[rxstaskidx].task_id = cnvtreal(
       queue_task_request->task.task_details[taskidx].task_id)
     ENDIF
   ENDFOR
   SET stat = alterlist(req395123->personnel[1].orders,ordercnt)
   CALL echorecord(req395123)
   EXECUTE rxs_add_activity_queue  WITH replace("REQUEST","REQ395123"), replace("REPLY","REPLY395123"
    )
   CALL echorecord(reply395123)
   IF ((((reply395123->status_data.status="F")) OR (error(errormsg,1) != 0)) )
    SET queue_task_reply->reply_data.status_info.operation_status_flag = - (1)
    SET queue_task_reply->reply_data.status_info.operation_name = "handleRxsQueueTaskRequest"
    SET queue_task_reply->reply_data.status_info.operation_detail = errormsg
    CALL handleerror("adm_adapter_ccl_tasks","F","handleRxsQueueTaskRequest","F",queue_task_reply)
    FREE RECORD req395123
    FREE RECORD reply395123
    GO TO exit_script
   ENDIF
   DECLARE found_ind = i2 WITH protect, noconstant(0)
   SET taskidx = 0
   FOR (idx = 1 TO size(reply395123->personnel,5))
     IF (found_ind=0
      AND (reply395123->personnel[idx].assigned_prsnl_id=req395123->personnel[1].assigned_prsnl_id))
      SET found_ind = 1
      FOR (orderidx = 1 TO size(reply395123->personnel[idx].orders,5))
       SET stat = alterlist(queue_task_reply->reply_data.tasks,(size(queue_task_reply->reply_data.
         tasks,5)+ size(reply395123->personnel[idx].orders[orderidx].tasks,5)))
       FOR (rxstaskidx = 1 TO size(reply395123->personnel[idx].orders[orderidx].tasks,5))
         SET taskidx += 1
         SET queue_task_reply->reply_data.tasks[taskidx].queue_id = reply395123->personnel[idx].
         orders[orderidx].tasks[rxstaskidx].rxs_order_queue_id
         SET queue_task_reply->reply_data.tasks[taskidx].task_id = reply395123->personnel[idx].
         orders[orderidx].tasks[rxstaskidx].task_id
         SET queue_task_reply->reply_data.tasks[taskidx].data_state.data_locked_ind = reply395123->
         personnel[idx].orders[orderidx].tasks[rxstaskidx].data_state.data_locked_ind
       ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   SET queue_task_reply->status_data.status = reply395123->status_data.status
   SET queue_task_reply->reply_data.status_info.operation_status_flag = 0
   SET queue_task_reply->reply_data.status_info.operation_name = "adm_adapter_ccl_tasks"
   SET queue_task_reply->reply_data.status_info.operation_detail =
   "handleRxsQueueTaskRequest:SUCCESS"
   CALL echorecord(queue_task_reply)
   FREE RECORD req395123
   FREE RECORD reply395123
   CALL echo("Leaving handleRxsQueueTaskRequest")
 END ;Subroutine
 SUBROUTINE (handlerxsdequeuetaskrequest(cclrequest=i4(ref)) =null WITH protect)
   CALL echo("Entering handleRxsDequeueTaskRequest")
   CALL echorecord(dequeue_task_request)
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE errormsg = vc WITH protect, noconstant("")
   EXECUTE rxs_declare_395124
   SET req395124->lock_ind = 1
   SET req395124->update_queue_dt_tm_ind = 1
   SET stat = alterlist(req395124->orders,size(dequeue_task_request->task.task_details,5))
   FOR (idx = 1 TO size(dequeue_task_request->task.task_details,5))
    SET req395124->orders[idx].taskqual.assigned_prsnl_id = cnvtreal(dequeue_task_request->user.
     person_id)
    SET req395124->orders[idx].taskqual.task_id = cnvtreal(dequeue_task_request->task.task_details[
     idx].task_id)
   ENDFOR
   CALL echorecord(req395124)
   EXECUTE rxs_delete_activity_queue  WITH replace("REQUEST","REQ395124"), replace("REPLY",
    "REPLY395124")
   CALL echorecord(reply395124)
   IF ((((reply395124->status_data.status="F")) OR (error(errormsg,1) != 0)) )
    SET dequeue_task_reply->reply_data.status_info.operation_status_flag = - (1)
    SET dequeue_task_reply->reply_data.status_info.operation_name = "handleRxsDequeueTaskRequest"
    SET dequeue_task_reply->reply_data.status_info.operation_detail = errormsg
    CALL handleerror("adm_adapter_ccl_tasks","F","handleRxsDequeueTaskRequest","F",dequeue_task_reply
     )
    FREE RECORD req395124
    FREE RECORD reply395124
    GO TO exit_script
   ENDIF
   SET stat = alterlist(dequeue_task_reply->reply_data.tasks,size(reply395124->orders,5))
   FOR (idx = 1 TO size(reply395124->orders,5))
     SET dequeue_task_reply->reply_data.tasks[idx].queue_id = reply395124->orders[idx].
     rxs_order_task_queue_id
     SET dequeue_task_reply->reply_data.tasks[idx].assigned_prsnl_id = reply395124->orders[idx].
     assigned_prsnl_id
     SET dequeue_task_reply->reply_data.tasks[idx].task_id = reply395124->orders[idx].task_id
     SET dequeue_task_reply->reply_data.tasks[idx].data_state.data_locked_ind = reply395124->orders[
     idx].data_state.data_locked_ind
   ENDFOR
   SET dequeue_task_reply->status_data.status = reply395124->status_data.status
   SET dequeue_task_reply->reply_data.status_info.operation_status_flag = 0
   SET dequeue_task_reply->reply_data.status_info.operation_name = "adm_adapter_ccl_tasks"
   SET dequeue_task_reply->reply_data.status_info.operation_detail =
   "handleRxsDequeueTaskRequest:SUCCESS"
   CALL echorecord(dequeue_task_reply)
   FREE RECORD req395124
   FREE RECORD reply395124
   CALL echo("Leaving handleRxsDequeueTaskRequest")
 END ;Subroutine
 DECLARE retrieve_tx_to_waste_request_number = i4 WITH protect, constant(395203)
 DECLARE retrieve_tx_to_waste_srv_request = vc WITH constant("RetrieveTxToWaste"), protect
 DECLARE remote_waste_request_number = i4 WITH protect, constant(395204)
 DECLARE remote_waste_srv_request = vc WITH constant("ProcessWaste"), protect
 DECLARE search_item_to_waste_request_number = i4 WITH protect, constant(395205)
 DECLARE search_item_to_waste_srv_request = vc WITH constant("SearchItem"), protect
 SUBROUTINE (processretrievetxtowasterequest(cclrequest=i4) =null WITH protect)
   CALL echo("processRetrieveTxToWaste started...")
   CALL initializerequest(retrieve_txs_to_waste_reply,retrieve_tx_to_waste_request_number)
   CALL prepareretrievetxtowaste(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,retrieve_txs_to_waste_reply,1)
   IF ((retrieve_txs_to_waste_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateretrievetxtowaste(hrep)
   ENDIF
   SET retrieve_txs_to_waste_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (processsearchforitemtowasterequest(cclrequest=i4) =null WITH protect)
   CALL echo("processSearchForItemToWasteRequest started...")
   CALL initializerequest(search_item_reply,search_item_to_waste_request_number)
   CALL preparesearchforitemtowaste(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,search_item_reply,1)
   IF ((search_item_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translatesearchforitemtowaste(hrep)
   ENDIF
   SET search_item_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (processremotewasterequest(cclrequest=i4) =null WITH protect)
   CALL echo("processRemoteWaste started...")
   CALL initializerequest(remote_waste_reply,remote_waste_request_number)
   CALL prepareremotewaste(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,remote_waste_reply,1)
   IF ((remote_waste_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateremotewaste(hrep)
   ENDIF
   SET remote_waste_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (prepareretrievetxtowaste(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request in prepareRetrieveTxToWaste")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(retrieve_tx_to_waste_request->
     user.person_id))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"patient_id",cnvtreal(retrieve_tx_to_waste_request->
     patient_id))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"encounter_id",cnvtreal(retrieve_tx_to_waste_request->
     encounter_id))
   SET nsrvstat = uar_srvsetstring(srvrequest,"item_id",nullterm(retrieve_tx_to_waste_request->
     item_id))
   SET nsrvstat = uar_srvsetstring(srvrequest,"order_id",nullterm(retrieve_tx_to_waste_request->
     order_id))
   SET nsrvstat = uar_srvsetlong(srvrequest,"remove_qty",retrieve_tx_to_waste_request->remove_qty)
   SET nsrvstat = uar_srvsetshort(srvrequest,"retrieve_waste_tx_filter_ind",
    retrieve_tx_to_waste_request->retrieve_waste_tx_filter_ind)
   CALL echorecord(retrieve_tx_to_waste_request)
   CALL echo("Exit prepareRetrieveTxToWaste")
 END ;Subroutine
 SUBROUTINE (preparesearchforitemtowaste(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request in prepareSearchForItemToWaste")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET searchcriteriainstance = uar_srvgetstruct(srvrequest,nullterm("search_criteria"))
   SET userinstance = uar_srvgetstruct(searchcriteriainstance,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(search_item_request->user.
     person_id))
   SET nsrvstat = uar_srvsetdouble(searchcriteriainstance,"patient_id",cnvtreal(search_item_request->
     patient_id))
   SET nsrvstat = uar_srvsetdouble(searchcriteriainstance,"encounter_id",cnvtreal(search_item_request
     ->encounter_id))
   SET nsrvstat = uar_srvsetstring(searchcriteriainstance,"search_text",nullterm(search_item_request
     ->search_text))
   CALL echorecord(search_item_request)
   CALL echo("Exit prepareSearchForItemToWaste")
 END ;Subroutine
 SUBROUTINE (prepareremotewaste(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request in prepareRemoteWaste")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(remote_waste_request->user.
     person_id))
   DECLARE wasteinstance = i4 WITH noconstant(0), protect
   SET wasteinstance = uar_srvgetstruct(srvrequest,nullterm("waste"))
   DECLARE cdcinputinstance = i4 WITH noconstant(0), protect
   DECLARE cdcinputcount = i4 WITH noconstant(0), protect
   FOR (cdcinputcount = 1 TO size(remote_waste_request->waste.cdc_inputs,5))
     SET cdcinputinstance = uar_srvadditem(wasteinstance,"cdc_inputs")
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"cdc_select_code_ind",remote_waste_request->
      waste.cdc_inputs[cdcinputcount].cdc_select_code_ind)
     SET nsrvstat = uar_srvsetdouble(cdcinputinstance,"cat_num",cnvtreal(remote_waste_request->waste.
       cdc_inputs[cdcinputcount].cat_num))
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"cat_name",nullterm(remote_waste_request->waste
       .cdc_inputs[cdcinputcount].cat_name))
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"required_ind",remote_waste_request->waste.
      cdc_inputs[cdcinputcount].required_ind)
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"once_ind",remote_waste_request->waste.
      cdc_inputs[cdcinputcount].once_ind)
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"override_ind",remote_waste_request->waste.
      cdc_inputs[cdcinputcount].override_ind)
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"enter_ind",remote_waste_request->waste.
      cdc_inputs[cdcinputcount].enter_ind)
     SET nsrvstat = uar_srvsetshort(cdcinputinstance,"skipped_ind",remote_waste_request->waste.
      cdc_inputs[cdcinputcount].skipped_ind)
     SET nsrvstat = uar_srvsetdouble(cdcinputinstance,"list_num",cnvtreal(remote_waste_request->waste
       .cdc_inputs[cdcinputcount].list_num))
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"list_name",nullterm(remote_waste_request->
       waste.cdc_inputs[cdcinputcount].list_name))
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"list_abbr",nullterm(remote_waste_request->
       waste.cdc_inputs[cdcinputcount].list_abbr))
     DECLARE cdcanswerinstance = i4 WITH noconstant(0), protect
     DECLARE cdcanswercount = i4 WITH noconstant(0), protect
     FOR (cdcanswercount = 1 TO size(remote_waste_request->waste.cdc_inputs[cdcinputcount].
      cdc_answers,5))
       SET cdcanswerinstance = uar_srvadditem(cdcinputinstance,"cdc_answers")
       SET nsrvstat = uar_srvsetdouble(cdcanswerinstance,"answer_num",cnvtreal(remote_waste_request->
         waste.cdc_inputs[cdcinputcount].cdc_answers[cdcanswercount].answer_num))
       SET nsrvstat = uar_srvsetstring(cdcanswerinstance,"answer_name",nullterm(remote_waste_request
         ->waste.cdc_inputs[cdcinputcount].cdc_answers[cdcanswercount].answer_name))
       SET nsrvstat = uar_srvsetstring(cdcanswerinstance,"answer_abbr",nullterm(remote_waste_request
         ->waste.cdc_inputs[cdcinputcount].cdc_answers[cdcanswercount].answer_abbr))
       SET nsrvstat = uar_srvsetdouble(cdcanswerinstance,"list_num",cnvtreal(remote_waste_request->
         waste.cdc_inputs[cdcinputcount].cdc_answers[cdcanswercount].list_num))
     ENDFOR
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"answer_1",nullterm(remote_waste_request->waste
       .cdc_inputs[cdcinputcount].answer_1))
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"answer_2",nullterm(remote_waste_request->waste
       .cdc_inputs[cdcinputcount].answer_2))
     SET nsrvstat = uar_srvsetstring(cdcinputinstance,"answer_3",nullterm(remote_waste_request->waste
       .cdc_inputs[cdcinputcount].answer_3))
   ENDFOR
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"give_amount",cnvtreal(remote_waste_request->waste.
     give_amount))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"med_id",nullterm(remote_waste_request->waste.med_id
     ))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"order_id",nullterm(remote_waste_request->waste.
     order_id))
   SET nsrvstat = uar_srvsetshort(wasteinstance,"patient_credited_ind",remote_waste_request->waste.
    patient_credited_ind)
   SET nsrvstat = uar_srvsetstring(wasteinstance,"patient_id",nullterm(remote_waste_request->waste.
     patient_id))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"total_patient_transfer_amount",cnvtreal(
     remote_waste_request->waste.total_patient_transfer_amount))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"remaining_amount",cnvtreal(remote_waste_request->
     waste.remaining_amount))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"remove_amount",cnvtreal(remote_waste_request->waste
     .remove_amount))
   SET nsrvstat = uar_srvsetlong(wasteinstance,"orig_removed_med_tx_seq",remote_waste_request->waste.
    orig_removed_med_tx_seq)
   SET nsrvstat = uar_srvsetlong(wasteinstance,"orig_removed_med_tx_time",remote_waste_request->waste
    .orig_removed_med_tx_time)
   SET nsrvstat = uar_srvsetstring(wasteinstance,"format_orig_rmved_med_tx_time",nullterm(
     remote_waste_request->waste.format_orig_rmved_med_tx_time))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"total_return_amount",cnvtreal(remote_waste_request
     ->waste.total_return_amount))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"total_waste_amount",cnvtreal(remote_waste_request->
     waste.total_waste_amount))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"waste_amount",cnvtreal(remote_waste_request->waste.
     waste_amount))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"waste_user_id",nullterm(remote_waste_request->waste
     .waste_user_id))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"waste_user_name",nullterm(remote_waste_request->
     waste.waste_user_name))
   SET nsrvstat = uar_srvsetshort(wasteinstance,"witness_required_ind",remote_waste_request->waste.
    witness_required_ind)
   SET nsrvstat = uar_srvsetstring(wasteinstance,"witness_user_name",nullterm(remote_waste_request->
     waste.witness_user_name))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"witness_id",nullterm(remote_waste_request->waste.
     witness_id))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"device_id",nullterm(remote_waste_request->waste.
     device_id))
   SET nsrvstat = uar_srvsetshort(wasteinstance,"fractional_flag_ind",remote_waste_request->waste.
    fractional_flag_ind)
   SET nsrvstat = uar_srvsetshort(wasteinstance,"undocumented_waste_ind",remote_waste_request->waste.
    undocumented_waste_ind)
   SET nsrvstat = uar_srvsetstring(wasteinstance,"brand_name",nullterm(remote_waste_request->waste.
     brand_name))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"generic_name",nullterm(remote_waste_request->waste.
     generic_name))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"patient_name",nullterm(remote_waste_request->waste.
     patient_name))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"strength",cnvtreal(remote_waste_request->waste.
     strength))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"strength_units",nullterm(remote_waste_request->
     waste.strength_units))
   SET nsrvstat = uar_srvsetdouble(wasteinstance,"volume",cnvtreal(remote_waste_request->waste.volume
     ))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"volume_units",nullterm(remote_waste_request->waste.
     volume_units))
   SET nsrvstat = uar_srvsetdate(wasteinstance,"waste_tx_time",convertisodatetimetoccldatetime(
     remote_waste_request->waste.waste_tx_time))
   SET nsrvstat = uar_srvsetshort(wasteinstance,"waste_tx_seq",remote_waste_request->waste.
    waste_tx_seq)
   DECLARE wastestatusinstance = i4 WITH noconstant(0), protect
   DECLARE wastestatuscount = i4 WITH noconstant(0), protect
   FOR (wastestatuscount = 1 TO size(remote_waste_request->waste.waste_statuses,5))
    SET wastestatusinstance = uar_srvadditem(wastestatusinstance,"waste_statuses")
    SET nsrvstat = uar_srvsetstring(wastestatusinstance,"waste_status",nullterm(remote_waste_request
      ->waste.waste_statuses[wastestatuscount].waste_status))
   ENDFOR
   SET nsrvstat = uar_srvsetshort(wasteinstance,"waste_by_tx_ind",remote_waste_request->waste.
    waste_by_tx_ind)
   SET nsrvstat = uar_srvsetstring(wasteinstance,"removed_by_user_name",nullterm(remote_waste_request
     ->waste.removed_by_user_name))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"removed_by_user_id",nullterm(remote_waste_request->
     waste.removed_by_user_id))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"amount_units_of_measure",nullterm(
     remote_waste_request->waste.amount_units_of_measure))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"units_of_measure",nullterm(remote_waste_request->
     waste.units_of_measure))
   SET nsrvstat = uar_srvsetstring(wasteinstance,"dosage",nullterm(remote_waste_request->waste.dosage
     ))
   SET nsrvstat = uar_srvsetshort(srvrequest,"process_waste_type_ind",remote_waste_request->
    process_waste_type_ind)
   IF (validate(remote_waste_request->patient_context))
    SET patientinstance = uar_srvgetstruct(srvrequest,nullterm("patient_context"))
    SET nsrvstat = uar_srvsetdouble(patientinstance,"person_id",cnvtreal(remote_waste_request->
      patient_context.person_id))
    SET nsrvstat = uar_srvsetdouble(patientinstance,"encounter_id",cnvtreal(remote_waste_request->
      patient_context.encounter_id))
   ENDIF
   CALL echorecord(remote_waste_request)
   CALL echo("Exit prepareRemoteWaste")
 END ;Subroutine
 SUBROUTINE (translateretrievetxtowaste(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateRetrieveTxToWaste()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE hwastetxsitem = i4 WITH noconstant(0), protect
   DECLARE hcdcinputitem = i4 WITH noconstant(0), protect
   DECLARE hcdcansweritem = i4 WITH noconstant(0), protect
   DECLARE hwastestatusitem = i4 WITH noconstant(0), protect
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET retrieve_txs_to_waste_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    hcaservicestatusinfoitem,"operation_status_flag")
   SET retrieve_txs_to_waste_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET retrieve_txs_to_waste_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_detail")
   SET wastetxscnt = uar_srvgetitemcount(replydatainstance,nullterm("waste_txs"))
   SET stat = alterlist(retrieve_txs_to_waste_reply->reply_data.waste_txs,wastetxscnt)
   FOR (x = 1 TO wastetxscnt)
     SET hwastetxsitem = uar_srvgetitem(replydatainstance,nullterm("waste_txs"),(x - 1))
     SET cdcinputcnt = uar_srvgetitemcount(hwastetxsitem,nullterm("cdc_inputs"))
     SET stat = alterlist(retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs,cdcinputcnt
      )
     FOR (y = 1 TO cdcinputcnt)
       SET hcdcinputitem = uar_srvgetitem(hwastetxsitem,nullterm("cdc_inputs"),(y - 1))
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cdc_select_code_ind =
       uar_srvgetshort(hcdcinputitem,"cdc_select_code_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cat_num =
       uar_srvgetdouble(hcdcinputitem,"cat_num")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cat_name =
       uar_srvgetstringptr(hcdcinputitem,"cat_name")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].required_ind =
       uar_srvgetshort(hcdcinputitem,"required_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].once_ind =
       uar_srvgetshort(hcdcinputitem,"once_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].override_ind =
       uar_srvgetshort(hcdcinputitem,"override_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].enter_ind =
       uar_srvgetshort(hcdcinputitem,"enter_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].skipped_ind =
       uar_srvgetshort(hcdcinputitem,"skipped_ind")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].list_num =
       uar_srvgetdouble(hcdcinputitem,"list_num")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].list_name =
       uar_srvgetstringptr(hcdcinputitem,"list_name")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].list_abbr =
       uar_srvgetstringptr(hcdcinputitem,"list_abbr")
       SET cdcanswercnt = uar_srvgetitemcount(hcdcinputitem,nullterm("cdc_answers"))
       SET stat = alterlist(retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].
        cdc_answers,cdcanswercnt)
       FOR (z = 1 TO cdcanswercnt)
         SET hcdcansweritem = uar_srvgetitem(hcdcinputitem,nullterm("cdc_answers"),(z - 1))
         SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cdc_answers[z].
         answer_num = uar_srvgetdouble(hcdcansweritem,"answer_num")
         SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cdc_answers[z].
         answer_name = uar_srvgetstringptr(hcdcansweritem,"answer_name")
         SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cdc_answers[z].
         answer_abbr = uar_srvgetstringptr(hcdcansweritem,"answer_abbr")
         SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].cdc_answers[z].
         list_num = uar_srvgetdouble(hcdcansweritem,"list_num")
       ENDFOR
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].answer_1 =
       uar_srvgetstringptr(hcdcinputitem,"answer_1")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].answer_2 =
       uar_srvgetstringptr(hcdcinputitem,"answer_2")
       SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].cdc_inputs[y].answer_3 =
       uar_srvgetstringptr(hcdcinputitem,"answer_3")
     ENDFOR
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].give_amount = uar_srvgetdouble(
      hwastetxsitem,"give_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].med_id = uar_srvgetstringptr(
      hwastetxsitem,"med_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].order_id = uar_srvgetstringptr(
      hwastetxsitem,"order_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].patient_credited_ind = uar_srvgetshort(
      hwastetxsitem,"patient_credited_ind")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].patient_id = uar_srvgetstringptr(
      hwastetxsitem,"patient_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].total_patient_transfer_amount =
     uar_srvgetdouble(hwastetxsitem,"total_patient_transfer_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].remaining_amount = uar_srvgetdouble(
      hwastetxsitem,"remaining_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].remove_amount = uar_srvgetdouble(
      hwastetxsitem,"remove_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].orig_removed_med_tx_seq =
     uar_srvgetlong(hwastetxsitem,"orig_removed_med_tx_seq")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].orig_removed_med_tx_time =
     uar_srvgetlong(hwastetxsitem,"orig_removed_med_tx_time")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].format_orig_rmved_med_tx_time =
     uar_srvgetstringptr(hwastetxsitem,"format_orig_rmved_med_tx_time")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].total_return_amount = uar_srvgetdouble(
      hwastetxsitem,"total_return_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].total_waste_amount = uar_srvgetdouble(
      hwastetxsitem,"total_waste_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_amount = uar_srvgetdouble(
      hwastetxsitem,"waste_amount")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_user_id = uar_srvgetstringptr(
      hwastetxsitem,"waste_user_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_user_name = uar_srvgetstringptr(
      hwastetxsitem,"waste_user_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].witness_required_ind = uar_srvgetshort(
      hwastetxsitem,"witness_required_ind")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].witness_user_name = uar_srvgetstringptr
     (hwastetxsitem,"witness_user_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].witness_id = uar_srvgetstringptr(
      hwastetxsitem,"witness_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].device_id = uar_srvgetstringptr(
      hwastetxsitem,"device_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].fractional_flag_ind = uar_srvgetshort(
      hwastetxsitem,"fractional_flag_ind")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].undocumented_waste_ind =
     uar_srvgetshort(hwastetxsitem,"undocumented_waste_ind")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].brand_name = uar_srvgetstringptr(
      hwastetxsitem,"brand_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].generic_name = uar_srvgetstringptr(
      hwastetxsitem,"generic_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].patient_name = uar_srvgetstringptr(
      hwastetxsitem,"patient_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].strength = uar_srvgetdouble(
      hwastetxsitem,"strength")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].strength_units = uar_srvgetstringptr(
      hwastetxsitem,"strength_units")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].volume = uar_srvgetdouble(hwastetxsitem,
      "volume")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].volume_units = uar_srvgetstringptr(
      hwastetxsitem,"volume_units")
     SET stat = uar_srvgetdate(hwastetxsitem,"waste_tx_time",retrieve_txs_to_waste_reply->reply_data.
      waste_txs[x].waste_tx_time)
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_tx_seq = uar_srvgetlong(
      hwastetxsitem,"waste_tx_seq")
     SET wastestatusescnt = uar_srvgetitemcount(hwastetxsitem,nullterm("waste_statuses"))
     SET stat = alterlist(retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_statuses,
      wastestatusescnt)
     FOR (y = 1 TO wastestatusescnt)
      SET hwastestatusitem = uar_srvgetitem(hwastetxsitem,nullterm("waste_statuses"),(y - 1))
      SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_statuses[y].waste_status =
      uar_srvgetstringptr(hwastestatusitem,"waste_status")
     ENDFOR
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].waste_by_tx_ind = uar_srvgetshort(
      hwastetxsitem,"waste_by_tx_ind")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].removed_by_user_name =
     uar_srvgetstringptr(hwastetxsitem,"removed_by_user_name")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].removed_by_user_id =
     uar_srvgetstringptr(hwastetxsitem,"removed_by_user_id")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].amount_units_of_measure =
     uar_srvgetstringptr(hwastetxsitem,"amount_units_of_measure")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].units_of_measure = uar_srvgetstringptr(
      hwastetxsitem,"units_of_measure")
     SET retrieve_txs_to_waste_reply->reply_data.waste_txs[x].dosage = uar_srvgetstringptr(
      hwastetxsitem,"dosage")
   ENDFOR
   SET hwastepreferencesitem = uar_srvgetstruct(replydatainstance,nullterm("waste_preferences"))
   SET retrieve_txs_to_waste_reply->reply_data.waste_preferences.area_type_ind = uar_srvgetshort(
    hwastepreferencesitem,"area_type_ind")
   SET retrieve_txs_to_waste_reply->reply_data.waste_preferences.force_waste_dose_balance_ind =
   uar_srvgetshort(hwastepreferencesitem,"force_waste_dose_balance_ind")
   CALL echorecord(retrieve_txs_to_waste_reply)
   CALL echo(build("Exit translateRetrieveTxToWaste(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 SUBROUTINE (translatesearchforitemtowaste(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateSearchForItemToWaste()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE hwastestatusitem = i4 WITH noconstant(0), protect
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET search_item_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    hcaservicestatusinfoitem,"operation_status_flag")
   SET search_item_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET search_item_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_detail")
   SET itemcnt = uar_srvgetitemcount(replydatainstance,nullterm("items"))
   SET stat = alterlist(search_item_reply->reply_data.items,itemcnt)
   FOR (x = 1 TO itemcnt)
     SET hsearchresultitem = uar_srvgetitem(replydatainstance,nullterm("items"),(x - 1))
     SET search_item_reply->reply_data.items[x].description = uar_srvgetstringptr(hsearchresultitem,
      "description")
     SET search_item_reply->reply_data.items[x].brand_name = uar_srvgetstringptr(hsearchresultitem,
      "brand_name")
     SET search_item_reply->reply_data.items[x].item_identifier = uar_srvgetstringptr(
      hsearchresultitem,"item_identifier")
   ENDFOR
   CALL echorecord(search_item_reply)
   CALL echo(build("Exit translateSearchForItemToWaste(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 SUBROUTINE (translateremotewaste(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateRemoteWaste()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE hwastestatusitem = i4 WITH noconstant(0), protect
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET remote_waste_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    hcaservicestatusinfoitem,"operation_status_flag")
   SET remote_waste_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET remote_waste_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_detail")
   SET wastestatuscnt = uar_srvgetitemcount(replydatainstance,nullterm("waste_statuses"))
   SET stat = alterlist(remote_waste_reply->reply_data.waste_statuses,wastestatuscnt)
   FOR (x = 1 TO wastestatuscnt)
    SET hwastestatusitem = uar_srvgetitem(replydatainstance,nullterm("waste_statuses"),(x - 1))
    SET remote_waste_reply->reply_data.waste_statuses[x].waste_status = uar_srvgetstringptr(
     hwastestatusitem,"waste_status")
   ENDFOR
   CALL echorecord(remote_waste_reply)
   CALL echo(build("Exit translateRemoteWaste(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)))
 END ;Subroutine
 DECLARE retrieve_items_to_override_request_number = i4 WITH protect, constant(395210)
 DECLARE retrieve_items_to_override_srv_request = vc WITH constant("GetOverrideItems"), protect
 DECLARE remote_override_request_number = i4 WITH protect, constant(395211)
 DECLARE remote_override_srv_request = vc WITH constant("RemoteOverride"), protect
 SUBROUTINE (processretrieveitemstooverriderequest(cclrequest=i4) =null WITH protect)
   CALL echo("processRetrieveItemsToOverrideRequest started...")
   CALL initializerequest(retrieve_items_to_override_reply,retrieve_items_to_override_request_number)
   CALL prepareretrieveitemstooverride(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,retrieve_items_to_override_reply,1)
   IF ((retrieve_items_to_override_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateretrieveitemstooverride(hrep)
   ENDIF
   SET retrieve_items_to_override_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (processremoteoverriderequest(cclrequest=i4) =null WITH protect)
   CALL echo("processRemoteOverrideRequest started...")
   CALL initializerequest(remote_override_reply,remote_override_request_number)
   CALL prepareremoteoverride(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,remote_override_reply,1)
   IF ((remote_override_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateremoteoverride(hrep)
   ENDIF
   SET remote_override_reply->status_data.status = "S"
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (prepareretrieveitemstooverride(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect
  )
   CALL echo("Loading SRV Request in prepareRetrieveItemsToOverride")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(
     retrieve_items_to_override_request->user.person_id))
   SET patientinstance = uar_srvgetstruct(srvrequest,nullterm("patient_info"))
   SET nsrvstat = uar_srvsetdouble(patientinstance,"person_id",cnvtreal(
     retrieve_items_to_override_request->patient_info.person_id))
   SET nsrvstat = uar_srvsetdouble(patientinstance,"encounter_id",cnvtreal(
     retrieve_items_to_override_request->patient_info.encounter_id))
   SET nsrvstat = uar_srvsetstring(srvrequest,"item_id",nullterm(retrieve_items_to_override_request->
     item_id))
   CALL echorecord(retrieve_items_to_override_request)
   CALL echo("Exit prepareRetrieveItemsToOverride")
 END ;Subroutine
 SUBROUTINE (prepareremoteoverride(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request in prepareRemoteOverride")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",cnvtreal(remote_override_request->user.
     person_id))
   SET patientinstance = uar_srvgetstruct(srvrequest,nullterm("patient_info"))
   SET nsrvstat = uar_srvsetdouble(patientinstance,"person_id",cnvtreal(remote_override_request->
     patient_info.person_id))
   SET nsrvstat = uar_srvsetdouble(patientinstance,"encounter_id",cnvtreal(remote_override_request->
     patient_info.encounter_id))
   DECLARE overridenitemsinstance = i4 WITH noconstant(0), protect
   DECLARE overridenitemscount = i4 WITH noconstant(0), protect
   FOR (overridenitemscount = 1 TO size(remote_override_request->overriden_items,5))
     SET overridenitemsinstance = uar_srvadditem(srvrequest,"overriden_items")
     SET nsrvstat = uar_srvsetstring(overridenitemsinstance,"item_id",nullterm(
       remote_override_request->overriden_items[overridenitemscount].item_id))
     SET nsrvstat = uar_srvsetdouble(overridenitemsinstance,"intended_dose",cnvtreal(
       remote_override_request->overriden_items[overridenitemscount].intended_dose))
     SET nsrvstat = uar_srvsetstring(overridenitemsinstance,"amount_units_of_measure",nullterm(
       remote_override_request->overriden_items[overridenitemscount].amount_units_of_measure))
     SET nsrvstat = uar_srvsetstring(overridenitemsinstance,"physician_name",nullterm(
       remote_override_request->overriden_items[overridenitemscount].physician_name))
     SET nsrvstat = uar_srvsetstring(overridenitemsinstance,"admin_site",nullterm(
       remote_override_request->overriden_items[overridenitemscount].admin_site))
   ENDFOR
   SET nsrvstat = uar_srvsetstring(srvrequest,"override_reason",nullterm(remote_override_request->
     override_reason))
   CALL echorecord(remote_override_request)
   CALL echo("Exit prepareRemoteOverride")
 END ;Subroutine
 SUBROUTINE (translateretrieveitemstooverride(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateRetrieveItemsToOverride()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   DECLARE hoverrideitem = i4 WITH noconstant(0), protect
   DECLARE hadminsite = i4 WITH noconstant(0), protect
   DECLARE hphysicianname = i4 WITH noconstant(0), protect
   DECLARE hoverridereason = i4 WITH noconstant(0), protect
   DECLARE hwarningitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET retrieve_items_to_override_reply->reply_data.status_info.operation_status_flag =
   uar_srvgetshort(hcaservicestatusinfoitem,"operation_status_flag")
   SET retrieve_items_to_override_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET retrieve_items_to_override_reply->reply_data.status_info.operation_detail =
   uar_srvgetstringptr(hcaservicestatusinfoitem,"operation_detail")
   SET overridableitemcnt = uar_srvgetitemcount(replydatainstance,nullterm("override_items"))
   SET stat = alterlist(retrieve_items_to_override_reply->reply_data.override_items,
    overridableitemcnt)
   FOR (x = 1 TO overridableitemcnt)
     SET hoverrideitem = uar_srvgetitem(replydatainstance,nullterm("override_items"),(x - 1))
     SET retrieve_items_to_override_reply->reply_data.override_items[x].med_id = uar_srvgetstringptr(
      hoverrideitem,"med_id")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].generic_name =
     uar_srvgetstringptr(hoverrideitem,"generic_name")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].brand_name =
     uar_srvgetstringptr(hoverrideitem,"brand_name")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].amount_units_of_measure =
     uar_srvgetstringptr(hoverrideitem,"amount_units_of_measure")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].format_orig_rmved_med_tx_time
      = uar_srvgetstringptr(hoverrideitem,"format_orig_rmved_med_tx_time")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].removed_by_user_name =
     uar_srvgetstringptr(hoverrideitem,"removed_by_user_name")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].last_issue_location =
     uar_srvgetstringptr(hoverrideitem,"last_issue_location")
     SET warnningcnt = uar_srvgetitemcount(hoverrideitem,nullterm("warnings"))
     SET stat = alterlist(retrieve_items_to_override_reply->reply_data.override_items[x].warnings,
      warnningcnt)
     FOR (y = 1 TO warnningcnt)
      SET hwarningitem = uar_srvgetitem(hoverrideitem,nullterm("warnings"),(y - 1))
      SET retrieve_items_to_override_reply->reply_data.override_items[x].warnings[y].value =
      uar_srvgetstringptr(hwarningitem,"value")
     ENDFOR
     SET retrieve_items_to_override_reply->reply_data.override_items[x].witness_required_ind =
     uar_srvgetshort(hoverrideitem,"witness_required_ind")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].admin_sites_required_ind =
     uar_srvgetshort(hoverrideitem,"admin_sites_required_ind")
     SET retrieve_items_to_override_reply->reply_data.override_items[x].physician_required_ind =
     uar_srvgetshort(hoverrideitem,"physician_required_ind")
   ENDFOR
   SET retrieve_items_to_override_reply->reply_data.override_reasons_required_ind = uar_srvgetshort(
    replydatainstance,nullterm("override_reasons_required_ind"))
   SET adminsitescnt = uar_srvgetitemcount(replydatainstance,nullterm("admin_sites_info"))
   SET stat = alterlist(retrieve_items_to_override_reply->reply_data.admin_sites_info,adminsitescnt)
   FOR (x = 1 TO adminsitescnt)
    SET hadminsite = uar_srvgetitem(replydatainstance,nullterm("admin_sites_info"),(x - 1))
    SET retrieve_items_to_override_reply->reply_data.admin_sites_info[x].admin_site =
    uar_srvgetstringptr(hadminsite,"admin_site")
   ENDFOR
   SET physiciannamecnt = uar_srvgetitemcount(replydatainstance,nullterm("physician_info"))
   SET stat = alterlist(retrieve_items_to_override_reply->reply_data.physician_info,physiciannamecnt)
   FOR (x = 1 TO physiciannamecnt)
    SET hphysicianname = uar_srvgetitem(replydatainstance,nullterm("physician_info"),(x - 1))
    SET retrieve_items_to_override_reply->reply_data.physician_info[x].physician_name =
    uar_srvgetstringptr(hphysicianname,"physician_name")
   ENDFOR
   SET retrieve_items_to_override_reply->reply_data.default_physician_name = uar_srvgetstringptr(
    replydatainstance,nullterm("default_physician_name"))
   SET overridereasonscnt = uar_srvgetitemcount(replydatainstance,nullterm("override_reasons_info"))
   SET stat = alterlist(retrieve_items_to_override_reply->reply_data.override_reasons_info,
    overridereasonscnt)
   FOR (x = 1 TO overridereasonscnt)
    SET hoverridereason = uar_srvgetitem(replydatainstance,nullterm("override_reasons_info"),(x - 1))
    SET retrieve_items_to_override_reply->reply_data.override_reasons_info[x].override_reason =
    uar_srvgetstringptr(hoverridereason,"override_reason")
   ENDFOR
   CALL echorecord(retrieve_items_to_override_reply)
   CALL echo(build("Exit translateRetrieveItemsToOverride(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 SUBROUTINE (translateremoteoverride(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateRemoteOverride()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   DECLARE hoverrideitem = i4 WITH noconstant(0), protect
   DECLARE hdisplocitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET remote_override_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    hcaservicestatusinfoitem,"operation_status_flag")
   SET remote_override_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET remote_override_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_detail")
   SET overridableitemcnt = uar_srvgetitemcount(replydatainstance,nullterm("override_items"))
   SET stat = alterlist(remote_override_reply->reply_data.override_items,overridableitemcnt)
   FOR (x = 1 TO overridableitemcnt)
     SET hoverrideitem = uar_srvgetitem(replydatainstance,nullterm("override_items"),(x - 1))
     SET remote_override_reply->reply_data.override_items[x].item_availabilty_ind = uar_srvgetshort(
      hoverrideitem,"item_availabilty_ind")
     SET dispenselocationcnt = uar_srvgetitemcount(hoverrideitem,nullterm("dispense_locations"))
     SET stat = alterlist(remote_override_reply->reply_data.override_items[x].dispense_locations,
      dispenselocationcnt)
     FOR (y = 1 TO dispenselocationcnt)
       SET hdisplocitem = uar_srvgetitem(hoverrideitem,nullterm("dispense_locations"),(y - 1))
       SET remote_override_reply->reply_data.override_items[x].dispense_locations[y].location_cd =
       uar_srvgetdouble(hdisplocitem,"location_cd")
       SET remote_override_reply->reply_data.override_items[x].dispense_locations[y].location_disp =
       uar_srvgetstringptr(hdisplocitem,"location_disp")
       SET remote_override_reply->reply_data.override_items[x].dispense_locations[y].availability_ind
        = uar_srvgetshort(hdisplocitem,"availability_ind")
       SET availablequantity = evaluate(uar_srvgetdouble(hdisplocitem,"available_quantity"),1,1,0,0)
       IF (validate(availablequantity))
        SET remote_override_reply->reply_data.override_items[x].dispense_locations[y].
        available_quantity = uar_srvgetdouble(hdisplocitem,"available_quantity")
       ENDIF
       SET patientspecificcabinet = evaluate(uar_srvgetshort(hdisplocitem,"patient_specific_bin_ind"),
        1,1,0,0)
       IF (validate(patientspecificcabinet))
        SET remote_override_reply->reply_data.override_items[x].dispense_locations[y].
        patient_specific_cabinet_ind = uar_srvgetshort(hdisplocitem,"patient_specific_bin_ind")
       ENDIF
     ENDFOR
   ENDFOR
   CALL echorecord(remote_override_reply)
   CALL echo(build("Exit translateRemoteOverride(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 DECLARE user_maintenance_request_number = i4 WITH protect, constant(395107)
 DECLARE user_maintenance_srv_request = vc WITH constant("HandleUserMaintenance"), protect
 SUBROUTINE (processusermaintenancerequest(cclrequest=i4) =null WITH protect)
   CALL echo("processUserMaintenance started...")
   CALL initializerequest(user_maintenance_reply,user_maintenance_request_number)
   CALL prepareusermaintenance(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   SET hrep = validatereply(ncrmstat,hstep,user_maintenance_reply,1)
   IF ((user_maintenance_reply->status_data.status="Z"))
    GO TO exit_script
   ELSE
    CALL translateusermaintenance(hrep)
   ENDIF
   IF ((user_maintenance_reply->status_data.status=""))
    SET user_maintenance_reply->status_data.status = "S"
   ENDIF
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (prepareusermaintenance(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request for UserMaintenance...")
   DECLARE userinstance = i4 WITH noconstant(0), protect
   SET userinstance = uar_srvgetstruct(srvrequest,nullterm("user"))
   SET nsrvstat = uar_srvsetstring(userinstance,"native_id",nullterm(user_maintenance_request->user.
     native_id))
   SET nsrvstat = uar_srvsetstring(userinstance,"foreign_id",nullterm(user_maintenance_request->user.
     foreign_id))
   SET nsrvstat = uar_srvsetstring(userinstance,"user_pswd",nullterm(user_maintenance_request->user.
     user_pswd))
   SET person_id = cnvtreal(user_maintenance_request->user.person_id)
   SET nsrvstat = uar_srvsetdouble(userinstance,"person_id",person_id)
   DECLARE indicatorsinstance = i4 WITH noconstant(0), protect
   SET indicatorsinstance = uar_srvgetstruct(srvrequest,nullterm("request_indicators"))
   SET nsrvstat = uar_srvsetshort(indicatorsinstance,"transaction_ind",user_maintenance_request->
    request_indicators.transaction_ind)
   DECLARE privtypesidx = i4 WITH protect, noconstant(1)
   DECLARE privtypessize = i4 WITH protect, noconstant(0)
   DECLARE privtypeinst = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE exceptionsize = i4 WITH protect, noconstant(0)
   DECLARE exceptioninstance = i4 WITH protect, noconstant(0)
   IF (validate(user_maintenance_request->request_indicators.privilege_types))
    SET privtypessize = size(user_maintenance_request->request_indicators.privilege_types,5)
   ENDIF
   FOR (privtypesidx = 1 TO privtypessize)
     SET privtypeinst = uar_srvadditem(indicatorsinstance,"privilege_types")
     SET nsrvsat = uar_srvsetstring(privtypeinst,"privilege_type_identifier",nullterm(
       user_maintenance_request->request_indicators.privilege_types[privtypesidx].
       privilege_type_identifier))
     SET exceptionsize = size(user_maintenance_request->request_indicators.privilege_types[
      privtypesidx].exceptions,5)
     FOR (idx = 1 TO exceptionsize)
      SET exceptioninstance = uar_srvadditem(privtypeinst,"exceptions")
      SET nsrvstat = uar_srvsetdouble(exceptioninstance,"exception_cd",cnvtreal(
        user_maintenance_request->request_indicators.privilege_types[privtypesidx].exceptions[idx].
        exception_cd))
     ENDFOR
   ENDFOR
   SET witnessuserinstance = uar_srvgetstruct(srvrequest,nullterm("witness_user"))
   SET nsrvstat = uar_srvsetstring(witnessuserinstance,"native_id",nullterm(user_maintenance_request
     ->witness_user.native_id))
   SET nsrvstat = uar_srvsetstring(witnessuserinstance,"foreign_id",nullterm(user_maintenance_request
     ->witness_user.foreign_id))
   SET nsrvstat = uar_srvsetstring(witnessuserinstance,"user_pswd",nullterm(user_maintenance_request
     ->witness_user.user_pswd))
   SET witness_person_id = cnvtreal(user_maintenance_request->witness_user.person_id)
   SET nsrvstat = uar_srvsetdouble(witnessuserinstance,"person_id",witness_person_id)
   SET nsrvstat = uar_srvsetshort(srvrequest,"adm_type_ind",cnvtint(validate(user_maintenance_request
      ->adm_type_ind,"0")))
   IF (validate(user_maintenance_request->patient_context))
    SET patientinstance = uar_srvgetstruct(srvrequest,nullterm("patient_context"))
    SET nsrvstat = uar_srvsetdouble(patientinstance,"person_id",cnvtreal(user_maintenance_request->
      patient_context.person_id))
    SET nsrvstat = uar_srvsetdouble(patientinstance,"encounter_id",cnvtreal(user_maintenance_request
      ->patient_context.encounter_id))
   ENDIF
   CALL echorecord(user_maintenance_request)
   CALL echo("Exit prepareUserMaintenance")
 END ;Subroutine
 SUBROUTINE (translateusermaintenance(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateUserMaintenance()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE hcaservicestatusinfoitem = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   SET huserinfoitem = uar_srvgetstruct(replydatainstance,nullterm("user"))
   SET user_maintenance_reply->reply_data.user.native_id = uar_srvgetstringptr(huserinfoitem,
    "native_id")
   SET user_maintenance_reply->reply_data.user.foreign_id = uar_srvgetstringptr(huserinfoitem,
    "foreign_id")
   SET user_maintenance_reply->reply_data.user.person_id = uar_srvgetdouble(huserinfoitem,"person_id"
    )
   SET user_maintenance_reply->reply_data.user.user_name = uar_srvgetstringptr(huserinfoitem,
    "user_name")
   SET huserindicatorsitem = uar_srvgetstruct(huserinfoitem,nullterm("user_indicators"))
   SET user_maintenance_reply->reply_data.user.user_indicators.can_queue_ind = uar_srvgetshort(
    huserindicatorsitem,"can_queue_ind")
   SET user_maintenance_reply->reply_data.user.user_indicators.can_waste_ind = uar_srvgetshort(
    huserindicatorsitem,"can_waste_ind")
   SET user_maintenance_reply->reply_data.user.user_indicators.can_witness_ind = uar_srvgetshort(
    huserindicatorsitem,"can_witness_ind")
   SET user_maintenance_reply->reply_data.user.user_indicators.can_credit_waste_ind = uar_srvgetshort
   (huserindicatorsitem,"can_credit_waste_ind")
   SET huserstatusinfoitem = uar_srvgetstruct(huserinfoitem,nullterm("admuser_statusInfo"))
   SET user_maintenance_reply->reply_data.user.admuser_statusinfo.adm_user_alias_exists =
   uar_srvgetshort(huserstatusinfoitem,"adm_user_alias_exists")
   SET user_maintenance_reply->reply_data.user.admuser_statusinfo.prsnl_alias_link_status =
   uar_srvgetshort(huserstatusinfoitem,"prsnl_alias_link_status")
   SET hcaservicestatusinfoitem = uar_srvgetstruct(replydatainstance,nullterm("status_info"))
   SET user_maintenance_reply->reply_data.status_info.operation_status_flag = uar_srvgetshort(
    hcaservicestatusinfoitem,"operation_status_flag")
   SET user_maintenance_reply->reply_data.status_info.operation_name = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_name")
   SET user_maintenance_reply->reply_data.status_info.operation_detail = uar_srvgetstringptr(
    hcaservicestatusinfoitem,"operation_detail")
   IF (validate(user_maintenance_reply->reply_data.is_es_mode))
    SET user_maintenance_reply->reply_data.is_es_mode = uar_srvgetshort(replydatainstance,
     "is_es_mode")
   ENDIF
   CALL echorecord(user_maintenance_reply)
   CALL echo(build("Exit translateUserMaintenance(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 DECLARE get_adm_preferences_request_number = i4 WITH protect, constant(395207)
 DECLARE get_adm_preferences_srv_request = vc WITH constant("GetADMPreferences"), protect
 SUBROUTINE (processgetadmpreferencesrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processGetADMPreferences started...")
   CALL initializerequest(get_adm_preferences_reply,get_adm_preferences_request_number)
   CALL preparegetadmpreferences(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo("back from step")
   CALL echo(build("nCrmStat is ",ncrmstat))
   CALL echo(build("hstep=",hstep))
   SET hrep = validatereply(ncrmstat,hstep,get_adm_preferences_reply,1)
   IF ((get_adm_preferences_reply->status_data.status="Z"))
    CALL echo("zero status")
    GO TO exit_script
   ELSE
    CALL echo("translate")
    CALL translategetadmpreferences(hrep)
   ENDIF
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparegetadmpreferences(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo("Loading SRV Request for GetADMPreferences...")
   DECLARE qualifiersinstance = i4 WITH noconstant(0), protect
   SET qualifiersinstance = uar_srvgetstruct(srvrequest,nullterm("adm_prefs_request_qualifiers"))
   SET nsrvstat = uar_srvsetdouble(qualifiersinstance,"encounter_id",cnvtreal(
     get_adm_preferences_request->adm_prefs_request_qualifiers.encounter_id))
   DECLARE admprefkeysinstance = i4 WITH noconstant(0), protect
   DECLARE prefkeyssize = i4 WITH constant(size(get_adm_preferences_request->adm_pref_names,5)),
   protect
   DECLARE y = i4 WITH noconstant(0), protect
   FOR (y = 1 TO prefkeyssize)
    SET admprefkeysinstance = uar_srvadditem(srvrequest,"adm_pref_names")
    SET nsrvstat = uar_srvsetstring(admprefkeysinstance,"name",nullterm(get_adm_preferences_request->
      adm_pref_names[y].name))
   ENDFOR
   SET nsrvstat = uar_srvsetshort(srvrequest,"adm_type_flag",cnvtint(validate(
      get_adm_preferences_request->adm_type_flag,"0")))
   CALL echo(uar_srvgetstringptr(srvrequest,"adm_type_flag"))
   CALL echorecord(get_adm_preferences_request)
   CALL echo("Exit prepareGetADMPreferences")
 END ;Subroutine
 SUBROUTINE (translategetadmpreferences(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateGetADMPreferences()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE statusinstance = i4 WITH noconstant(0), protect
   DECLARE hprefitem = i4 WITH noconstant(0), protect
   DECLARE prefcnt = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   SET statusinstance = uar_srvgetstruct(hreply,nullterm("status_data"))
   SET prefcnt = uar_srvgetitemcount(replydatainstance,nullterm("adm_prefs"))
   SET stat = alterlist(get_adm_preferences_reply->reply_data.adm_prefs,prefcnt)
   FOR (x = 1 TO prefcnt)
     SET hprefitem = uar_srvgetitem(replydatainstance,nullterm("adm_prefs"),(x - 1))
     SET get_adm_preferences_reply->reply_data.adm_prefs[x].id = uar_srvgetdouble(hprefitem,"id")
     SET get_adm_preferences_reply->reply_data.adm_prefs[x].name = uar_srvgetstringptr(hprefitem,
      "name")
     SET get_adm_preferences_reply->reply_data.adm_prefs[x].value = uar_srvgetstringptr(hprefitem,
      "value")
   ENDFOR
   SET get_adm_preferences_reply->status_data.status = uar_srvgetstringptr(statusinstance,"status")
   CALL echorecord(get_adm_preferences_reply)
   CALL echo(build("Exit translateGetADMPreferences(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 DECLARE get_retractable_orders_request_number = i4 WITH protect, constant(395137)
 DECLARE get_retractable_orders_srv_request = vc WITH constant("AdmGetRetractableOrders"), protect
 DECLARE save_order_dispenses_request_number = i4 WITH protect, constant(395138)
 DECLARE save_order_dispenses_srv_request = vc WITH constant("AdmSaveOrderDispenses"), protect
 DECLARE device_waste = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"DEVICEWASTE"))
 DECLARE success = i2 WITH protect, constant(1)
 DECLARE fail = i2 WITH protect, constant(0)
 SUBROUTINE (processgetretractableordersrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processGetRetractableOrdersRequest started...")
   CALL initializerequest(get_retractable_orders_reply,get_retractable_orders_request_number)
   IF ((get_retractable_orders_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL preparegetretractableorders(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo(build("nCrmStat: ",ncrmstat," hstep: ",hstep))
   SET hrep = validatereply(ncrmstat,hstep,get_retractable_orders_reply,1)
   IF ((get_retractable_orders_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL translategetretractableorders(hrep)
   CALL echo("processGetRetractableOrdersRequest ended.")
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (processsaveorderdispensesrequest(cclrequest=i4) =null WITH protect)
   DECLARE status = i2 WITH protect, noconstant(success)
   CALL echo("processSaveOrderDispensesRequest started...")
   CALL initializerequest(save_order_dispenses_reply,save_order_dispenses_request_number)
   IF ((save_order_dispenses_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   SET status = preparesaveorderdispenses(cclrequest,hreq)
   IF (status=fail)
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo(build("nCrmStat: ",ncrmstat," hstep: ",hstep))
   SET hrep = validatereply(ncrmstat,hstep,save_order_dispenses_reply,1)
   IF ((save_order_dispenses_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL translatesaveorderdispenses(hrep)
   CALL echo("processSaveOrderDispensesRequest ended.")
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparesaveorderdispenses(cclrequest=i4(ref),srvrequest=i4(ref)) =i2 WITH protect)
   CALL echo(build("Loading SRV Request for ",save_order_dispenses_srv_request))
   CALL echorecord(save_order_dispenses_request)
   DECLARE ordercnt = i4 WITH protect, constant(size(save_order_dispenses_request->order_dispenses,5)
    )
   DECLARE dispensecnt = i4 WITH protect, noconstant(0)
   DECLARE orderidx = i4 WITH protect, noconstant(0)
   DECLARE dispidx = i4 WITH protect, noconstant(0)
   DECLARE orderinst = i4 WITH protect, noconstant(0)
   DECLARE dispenseinst = i4 WITH protect, noconstant(0)
   DECLARE iteminst = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   FOR (orderidx = 1 TO ordercnt)
     SET orderinst = uar_srvadditem(srvrequest,"order_dispenses")
     SET nsrvstat = uar_srvsetdouble(orderinst,"order_id",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].order_id))
     SET nsrvstat = uar_srvsetdouble(orderinst,"encounter_id",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].encounter_id))
     SET nsrvstat = uar_srvsetdouble(orderinst,"dispense_hx_id",cnvtreal(save_order_dispenses_request
       ->order_dispenses[orderidx].dispense_hx_id))
     SET nsrvstat = uar_srvsetdouble(orderinst,"patient_id",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].patient_id))
     SET nsrvstat = uar_srvsetdouble(orderinst,"personnel_id",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].personnel_id))
     SET nsrvstat = uar_srvsetdouble(orderinst,"witness_id",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].witness_id))
     SET nsrvstat = uar_srvsetdate(orderinst,"dispense_dt_tm",cnvtdatetime(
       save_order_dispenses_request->order_dispenses[orderidx].dispense_dt_tm))
     SET nsrvstat = uar_srvsetdouble(orderinst,"reason_cd",cnvtreal(save_order_dispenses_request->
       order_dispenses[orderidx].reason_cd))
     SET nsrvstat = uar_srvsetdouble(orderinst,"dispense_event_type_cd",cnvtreal(
       save_order_dispenses_request->order_dispenses[orderidx].dispense_event_type_cd))
     SET dispensecnt = size(save_order_dispenses_request->order_dispenses[orderidx].
      dispense_activities,5)
     FOR (dispidx = 1 TO dispensecnt)
       SET dispenseinst = uar_srvadditem(orderinst,"dispense_activities")
       SET iteminst = uar_srvgetstruct(dispenseinst,nullterm("item"))
       SET nsrvstat = uar_srvsetdouble(iteminst,"item_id",cnvtreal(save_order_dispenses_request->
         order_dispenses[orderidx].dispense_activities[dispidx].item.item_id))
       SET nsrvstat = uar_srvsetdouble(dispenseinst,"dispense_quantity",cnvtreal(
         save_order_dispenses_request->order_dispenses[orderidx].dispense_activities[dispidx].
         dispense_quantity))
     ENDFOR
     CALL echo(build("SRV Request for ",save_order_dispenses_srv_request," is populated."))
   ENDFOR
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (preparegetretractableorders(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo(build("Loading SRV Request for ",get_retractable_orders_srv_request))
   CALL echorecord(get_retractable_orders_request)
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE encountersize = i4 WITH protect, constant(size(get_retractable_orders_request->encounters,
     5))
   DECLARE encounterinst = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   SET nsrvstat = uar_srvsetdouble(srvrequest,"patient_id",cnvtreal(get_retractable_orders_request->
     patient_id))
   SET nsrvstat = uar_srvsetdouble(srvrequest,"personnel_id",cnvtreal(get_retractable_orders_request
     ->personnel_id))
   SET nsrvstat = uar_srvsetdate(srvrequest,"dispense_start_dt_tm",cnvtdatetime(
     get_retractable_orders_request->dispense_start_dt_tm))
   SET nsrvstat = uar_srvsetdate(srvrequest,"dispense_end_dt_tm",cnvtdatetime(
     get_retractable_orders_request->dispense_end_dt_tm))
   FOR (idx = 1 TO encountersize)
    SET encounterinst = uar_srvadditem(srvrequest,"encounters")
    SET nsrvstat = uar_srvsetdouble(encounterinst,"encounter_id",cnvtreal(
      get_retractable_orders_request->encounters[idx].encounter_id))
   ENDFOR
   CALL echo(build("SRV Request for ",get_retractable_orders_srv_request," is populated."))
 END ;Subroutine
 SUBROUTINE (translatesaveorderdispenses(hreply=i4(ref)) =null WITH protect)
   CALL echo(build("Translating SRV Reply for ",save_order_dispenses_srv_request))
   DECLARE replydatainstance = i4 WITH protect, noconstant(0)
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE dispensecnt = i4 WITH protect, constant(uar_srvgetitemcount(replydatainstance,nullterm(
      "order_dispenses")))
   DECLARE dispenseidx = i4 WITH protect, noconstant(0)
   DECLARE dispenseinstance = i4 WITH protect, noconstant(0)
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   CALL populatestatus(save_order_dispenses_reply,hreply)
   SET stat = alterlist(save_order_dispenses_reply->order_dispenses,dispensecnt)
   FOR (dispenseidx = 1 TO dispensecnt)
     SET dispenseinstance = uar_srvgetitem(replydatainstance,nullterm("order_dispenses"),(dispenseidx
       - 1))
     SET save_order_dispenses_reply->order_dispenses[dispenseidx].dispense_hx_id = uar_srvgetdouble(
      dispenseinstance,"dispense_hx_id")
     SET statusinstance = uar_srvgetstruct(dispenseinstance,nullterm("dispense_status"))
     SET save_order_dispenses_reply->order_dispenses[dispenseidx].dispense_status.status =
     uar_srvgetstringptr(statusinstance,"status")
     SET save_order_dispenses_reply->order_dispenses[dispenseidx].dispense_status.status_detail =
     uar_srvgetstringptr(statusinstance,"status_detail")
   ENDFOR
   CALL echorecord(save_order_dispenses_reply)
   CALL echo(build("SRV Reply for ",save_order_dispenses_srv_request," is translated."))
 END ;Subroutine
 SUBROUTINE (translategetretractableorders(hreply=i4(ref)) =null WITH protect)
   CALL echo(build("Translating SRV Reply for ",get_retractable_orders_srv_request))
   DECLARE replydatainstance = i4 WITH protect, noconstant(0)
   DECLARE orderinstance = i4 WITH protect, noconstant(0)
   DECLARE activityinstance = i4 WITH protect, noconstant(0)
   DECLARE iteminstance = i4 WITH protect, noconstant(0)
   DECLARE measurementinstance = i4 WITH protect, noconstant(0)
   DECLARE legalstatusinstance = i4 WITH protect, noconstant(0)
   DECLARE predictioninstance = i4 WITH protect, noconstant(0)
   DECLARE accessinstance = i4 WITH protect, noconstant(0)
   DECLARE executorinstance = i4 WITH protect, noconstant(0)
   DECLARE orderidx = i4 WITH protect, noconstant(0)
   DECLARE activityidx = i4 WITH protect, noconstant(0)
   DECLARE activitysize = i4 WITH protect, noconstant(0)
   CALL populatestatus(get_retractable_orders_reply,hreply)
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("retractable_orders_reply_data"))
   DECLARE orderssize = i4 WITH protect, constant(uar_srvgetitemcount(replydatainstance,nullterm(
      "orders")))
   SET stat = alterlist(get_retractable_orders_reply->retractable_orders_reply_data.orders,orderssize
    )
   FOR (orderidx = 1 TO orderssize)
     SET orderinstance = uar_srvgetitem(replydatainstance,nullterm("orders"),(orderidx - 1))
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].order_id =
     uar_srvgetdouble(orderinstance,"order_id")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].description =
     uar_srvgetstringptr(orderinstance,"description")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].dispense_hx_id
      = uar_srvgetdouble(orderinstance,"dispense_hx_id")
     SET stat = uar_srvgetdate(orderinstance,"dispense_dt_tm",get_retractable_orders_reply->
      retractable_orders_reply_data.orders[orderidx].dispense_dt_tm)
     SET executorinstance = uar_srvgetstruct(orderinstance,nullterm("executor"))
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].executor.
     personnel_id = uar_srvgetdouble(executorinstance,"personnel_id")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].executor.
     formatted_name = uar_srvgetstringptr(executorinstance,"formatted_name")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
     retractable_total_volume = uar_srvgetdouble(orderinstance,"retractable_total_volume")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
     multi_ingredient_order_ind = uar_srvgetshort(orderinstance,"multi_ingredient_order_ind")
     SET activitysize = uar_srvgetitemcount(orderinstance,nullterm("product_activities"))
     SET stat = alterlist(get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx
      ].product_activities,activitysize)
     FOR (activityidx = 1 TO activitysize)
       SET activityinstance = uar_srvgetitem(orderinstance,nullterm("product_activities"),(
        activityidx - 1))
       SET iteminstance = uar_srvgetstruct(activityinstance,nullterm("item"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.item_id = uar_srvgetdouble(iteminstance,"item_id")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.description = uar_srvgetstringptr(iteminstance,
        "description")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.dummy_ind = uar_srvgetshort(iteminstance,"dummy_ind")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.strength_ind = uar_srvgetshort(iteminstance,
        "strength_ind")
       SET measurementinstance = uar_srvgetstruct(iteminstance,nullterm("strength"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.strength.uom_cd = uar_srvgetdouble(measurementinstance,
        "uom_cd")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.strength.uom_display = uar_srvgetstringptr(
        measurementinstance,"uom_display")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.strength.value = uar_srvgetdouble(measurementinstance,
        "value")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.volume_ind = uar_srvgetshort(iteminstance,"volume_ind")
       SET measurementinstance = uar_srvgetstruct(iteminstance,nullterm("volume"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.volume.uom_cd = uar_srvgetdouble(measurementinstance,
        "uom_cd")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.volume.uom_display = uar_srvgetstringptr(
        measurementinstance,"uom_display")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.volume.value = uar_srvgetdouble(measurementinstance,
        "value")
       SET legalstatusinstance = uar_srvgetstruct(iteminstance,nullterm("legalStatus"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.legalstatus.legal_status_cd = uar_srvgetdouble(
        legalstatusinstance,"legal_status_cd")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.legalstatus.display = uar_srvgetstringptr(
        legalstatusinstance,"display")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].item.legalstatus.controlled_ind = uar_srvgetshort(
        legalstatusinstance,"controlled_ind")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].dispense_qty = uar_srvgetdouble(activityinstance,
        "dispense_qty")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].retractable_qty = uar_srvgetdouble(activityinstance,
        "retractable_qty")
       SET predictioninstance = uar_srvgetstruct(activityinstance,nullterm("prediction"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.strength_prediction_ind = uar_srvgetshort(
        predictioninstance,"strength_prediction_ind")
       SET measurementinstance = uar_srvgetstruct(predictioninstance,nullterm("strength_prediction"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.strength_prediction.uom_cd = uar_srvgetdouble(
        measurementinstance,"uom_cd")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.strength_prediction.uom_display =
       uar_srvgetstringptr(measurementinstance,"uom_display")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.strength_prediction.value = uar_srvgetdouble(
        measurementinstance,"value")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.volume_prediction_ind = uar_srvgetshort(
        predictioninstance,"volume_prediction_ind")
       SET measurementinstance = uar_srvgetstruct(predictioninstance,nullterm("volume_prediction"))
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.volume_prediction.uom_cd = uar_srvgetdouble(
        measurementinstance,"uom_cd")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.volume_prediction.uom_display = uar_srvgetstringptr
       (measurementinstance,"uom_display")
       SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].
       product_activities[activityidx].prediction.volume_prediction.value = uar_srvgetdouble(
        measurementinstance,"value")
     ENDFOR
     SET accessinstance = uar_srvgetstruct(orderinstance,nullterm("accessibility"))
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].accessibility.
     wasteable_ind = uar_srvgetshort(accessinstance,"wasteable_ind")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].accessibility.
     returnable_ind = uar_srvgetshort(accessinstance,"returnable_ind")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].accessibility.
     waste_witness_ind = uar_srvgetshort(accessinstance,"waste_witness_ind")
     SET get_retractable_orders_reply->retractable_orders_reply_data.orders[orderidx].accessibility.
     return_witness_ind = uar_srvgetshort(accessinstance,"waste_witness_ind")
   ENDFOR
   CALL echorecord(get_retractable_orders_reply)
   CALL echo(build("SRV Reply for ",get_retractable_orders_srv_request," is translated."))
 END ;Subroutine
 SUBROUTINE (populatestatus(recorddata=vc(ref),hreply=i4(ref)) =null WITH protect)
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   DECLARE substatusinstance = i4 WITH protect, noconstant(0)
   DECLARE statussize = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET statusinstance = uar_srvgetstruct(hreply,"status_data")
   SET recorddata->status_data.status = uar_srvgetstringptr(statusinstance,"status")
   SET statussize = uar_srvgetitemcount(statusinstance,"subeventstatus")
   SET stat = alterlist(recorddata->status_data.subeventstatus,statussize)
   FOR (idx = 0 TO (statussize - 1))
     SET substatusinstance = uar_srvgetitem(statusinstance,"subeventstatus",idx)
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationname = uar_srvgetstringptr(
      substatusinstance,"OperationName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationstatus = uar_srvgetstringptr(
      substatusinstance,"OperationStatus")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectname = uar_srvgetstringptr(
      substatusinstance,"TargetObjectName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectvalue = uar_srvgetstringptr(
      substatusinstance,"TargetObjectValue")
   ENDFOR
 END ;Subroutine
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH constant(1), persist
  DECLARE emsglog_commit = i4 WITH constant(0), persist
  DECLARE emsglvl_error = i4 WITH constant(0), persist
  DECLARE emsglvl_warning = i4 WITH constant(1), persist
  DECLARE emsglvl_audit = i4 WITH constant(2), persist
  DECLARE emsglvl_info = i4 WITH constant(3), persist
  DECLARE emsglvl_debug = i4 WITH constant(4), persist
  EXECUTE msgrtl
  DECLARE msg_default = i4 WITH persist
  SET msg_default = uar_msgdefhandle()
 ENDIF
 SUBROUTINE (addcodetolist(code_value=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt += 1
     IF (codelistcnt > size(record_data->codes,5))
      SET stat = alterlist(record_data->codes,(codelistcnt+ 9))
     ENDIF
     SET record_data->codes[codelistcnt].code = code_value
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputcodelist(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputCodeList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (codelistcnt > 0)
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
    DECLARE nrecordsize = i4 WITH noconstant(0), protect
    SET nrecordsize = codelistcnt
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(record_data->codes,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET record_data->codes[i].code = record_data->codes[nrecordsize].code
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      code_value cv
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cv
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cv.code_value,record_data->codes[idx].code,
       bind_cnt))
     HEAD REPORT
      code_seq = 0
     DETAIL
      code_seq = locateval(idx,1,codelistcnt,cv.code_value,record_data->codes[idx].code), record_data
      ->codes[code_seq].sequence = cv.collation_seq, record_data->codes[code_seq].meaning = cv
      .cdf_meaning,
      record_data->codes[code_seq].display = cv.display, record_data->codes[code_seq].description =
      cv.description, record_data->codes[code_seq].code_set = cv.code_set
     FOOT REPORT
      stat = alterlist(record_data->codes,codelistcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"CODE_VALUE","OutputCodeList",1,0,
     record_data)
   ENDIF
   CALL log_message(build("Exit OutputCodeList(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addpersonneltolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id) <= 0)) )
     SET prsnllistcnt += 1
     IF (prsnllistcnt > size(record_data->prsnl,5))
      SET stat = alterlist(record_data->prsnl,(prsnllistcnt+ 9))
     ENDIF
     SET record_data->prsnl[prsnllistcnt].id = prsnl_id
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputpersonnellist(report_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   DECLARE snamefull = vc WITH noconstant(""), protect
   DECLARE snamefirst = vc WITH noconstant(""), protect
   DECLARE snamemiddle = vc WITH noconstant(""), protect
   DECLARE snamelast = vc WITH noconstant(""), protect
   DECLARE susername = vc WITH noconstant(""), protect
   DECLARE stitle = vc WITH noconstant(""), protect
   DECLARE sinitials = vc WITH noconstant(""), protect
   IF (prsnllistcnt > 0)
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
    DECLARE nrecordsize = i4 WITH noconstant(0), protect
    SET nrecordsize = prsnllistcnt
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(report_data->prsnl,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET report_data->prsnl[i].id = report_data->prsnl[nrecordsize].id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      prsnl p,
      person_name pn,
      dummyt dpn
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (p
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),p.person_id,report_data->prsnl[idx].id,
       bind_cnt)
       AND p.end_effective_dt_tm > cnvtdatetime(current_date_time))
      JOIN (dpn)
      JOIN (pn
      WHERE pn.person_id=p.person_id
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.end_effective_dt_tm >= cnvtdatetime(current_date_time))
     ORDER BY p.person_id
     HEAD REPORT
      prsnl_seq = 0
     HEAD p.person_id
      prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id), snamefull =
      "", snamefirst = "",
      snamemiddle = "", snamelast = "", susername = "",
      stitle = "", sinitials = ""
      IF (pn.person_id > 0)
       snamefull = trim(pn.name_full,3), snamefirst = trim(pn.name_first,3), snamemiddle = trim(pn
        .name_middle,3),
       snamelast = trim(pn.name_last,3), susername = trim(p.username,3), sinitials = trim(pn
        .name_initials,3),
       stitle = trim(pn.name_initials,3)
      ELSE
       snamefull = trim(p.name_full_formatted,3), snamefirst = trim(p.name_first,3), snamelast = trim
       (pn.name_last,3),
       susername = trim(p.username,3)
      ENDIF
      report_data->prsnl[prsnl_seq].provider_name.name_full = snamefull, report_data->prsnl[prsnl_seq
      ].provider_name.name_first = snamefirst, report_data->prsnl[prsnl_seq].provider_name.
      name_middle = snamemiddle,
      report_data->prsnl[prsnl_seq].provider_name.name_last = snamelast, report_data->prsnl[prsnl_seq
      ].provider_name.username = susername, report_data->prsnl[prsnl_seq].provider_name.initials =
      sinitials,
      report_data->prsnl[prsnl_seq].provider_name.title = stitle
     DETAIL
      donothing = 0
     FOOT REPORT
      stat = alterlist(report_data->prsnl,prsnllistcnt)
     WITH nocounter, outerjoin = dpn
    ;end select
    CALL error_and_zero_check_rec(curqual,"PRSNL","OutputPersonnelList",1,0,
     report_data)
   ENDIF
   CALL log_message(build("Exit OutputPersonnelList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
  DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
  IF (validate(_memory_reply_string)=1)
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size(putrequest->document)
   EXECUTE eks_put_source  WITH replace(request,putrequest), replace(reply,putreply)
  ENDIF
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL putstringtofile(cnvtrectojson(record_data))
 END ;Subroutine
 SUBROUTINE (getparametervalues(index=i4(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protec
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = reflect(parameter(index,0))
   IF (validate(debug_ind,0)=1)
    CALL echo(par)
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(index,0)
    IF (param_value > 0)
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(index,lnum)
       IF (param_value > 0)
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlookbackdatebytype(units=i4(val),flag=i4(val)) =dq8 WITH protect)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(sysdate))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(sysdate))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(sysdate))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(sysdate))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(sysdate))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE (getcodevaluesfromcodeset(evt_set_rec=vc(ref),evt_cd_rec=vc(ref)) =null WITH protect)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt += 1, stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt), evt_cd_rec->qual[
    evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (convertisodatetimetoccldatetime(isodate=vc(ref)) =dq8 WITH protect)
   SET datestart = (findstring("(",isodate,1,0)+ 1)
   SET timeend = findstring("+",isodate,1,0)
   SET timestart = (findstring("T",isodate,datestart,0)+ 1)
   IF (timeend <= timestart)
    SET timeend = (size(isodate,1)+ 1)
   ENDIF
   SET timelength = (timeend - timestart)
   SET d1 = substring(datestart,10,isodate)
   SET t1 = substring(timestart,timelength,isodate)
   CALL echo(build("isoDate:",isodate))
   CALL echo(build("d1:",d1))
   CALL echo(build("t1:",t1))
   CALL echo(build("cnvtdate2",cnvtdate2(d1,"yyyy-mm-dd")))
   CALL echo(build("cnvttime2",cnvttime2(t1,"hh:mm:ss")))
   SET date_tm = cnvtdatetime(cnvtdate2(d1,"yyyy-mm-dd"),cnvttime2(t1,"hh:mm:ss"))
   CALL echo(date_tm)
   RETURN(date_tm)
 END ;Subroutine
 DECLARE get_reason_codes_request_number = i4 WITH protect, constant(395111)
 DECLARE get_reason_codes_srv_request = vc WITH constant("GetReasonCodesByEvents"), protect
 SUBROUTINE (processgetreasoncodesrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processGetReasonCodesRequest started...")
   CALL initializerequest(get_waste_reason_codes_reply,get_reason_codes_request_number)
   IF ((get_waste_reason_codes_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL preparegetreasoncodes(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo(build("nCrmStat: ",ncrmstat," hstep: ",hstep))
   SET hrep = validatereply(ncrmstat,hstep,get_waste_reason_codes_reply,1)
   IF ((get_waste_reason_codes_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL translategetreasoncodes(hrep)
   CALL echo("processGetReasonCodesRequest ended.")
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparegetreasoncodes(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo(build("Loading SRV Request for ",get_reason_codes_srv_request))
   CALL echorecord(get_waste_reason_codes_request)
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE eventssize = i4 WITH protect, constant(size(get_waste_reason_codes_request->events,5))
   DECLARE eventsinst = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO eventssize)
    SET eventsinst = uar_srvadditem(srvrequest,"events")
    SET nsrvstat = uar_srvsetdouble(eventsinst,"event_cd",cnvtreal(get_waste_reason_codes_request->
      events[idx].event_cd))
   ENDFOR
   CALL echo(build("SRV Request for ",get_reason_codes_srv_request," is populated."))
 END ;Subroutine
 SUBROUTINE (translategetreasoncodes(hreply=i4(ref)) =null WITH protect)
   CALL echo(build("Translating SRV Reply for ",get_reason_codes_srv_request))
   DECLARE replydatainstance = i4 WITH protect, noconstant(0)
   DECLARE eventinstance = i4 WITH protect, noconstant(0)
   DECLARE reasoninstance = i4 WITH protect, noconstant(0)
   DECLARE eventidx = i4 WITH protect, noconstant(0)
   DECLARE reasonidx = i4 WITH protect, noconstant(0)
   DECLARE reasonssize = i4 WITH protect, noconstant(0)
   CALL populatestatusreasoncodes(get_waste_reason_codes_reply)
   DECLARE eventssize = i4 WITH protect, constant(uar_srvgetitemcount(hrep,nullterm("events")))
   SET stat = alterlist(get_waste_reason_codes_reply->events,eventssize)
   FOR (eventidx = 1 TO eventssize)
     SET eventinstance = uar_srvgetitem(hreply,nullterm("events"),(eventidx - 1))
     SET get_waste_reason_codes_reply->events[eventidx].event_cd = uar_srvgetdouble(eventinstance,
      "event_cd")
     SET reasonssize = uar_srvgetitemcount(eventinstance,nullterm("reasons"))
     SET stat = alterlist(get_waste_reason_codes_reply->events[eventidx].reasons,reasonssize)
     FOR (reasonidx = 1 TO reasonssize)
       SET reasoninstance = uar_srvgetitem(eventinstance,nullterm("reasons"),(reasonidx - 1))
       SET get_waste_reason_codes_reply->events[eventidx].reasons[reasonidx].reason_cd =
       uar_srvgetdouble(reasoninstance,"reason_cd")
       SET get_waste_reason_codes_reply->events[eventidx].reasons[reasonidx].credit_ind =
       uar_srvgetshort(reasoninstance,"credit_ind")
       SET get_waste_reason_codes_reply->events[eventidx].reasons[reasonidx].text_required_ind =
       uar_srvgetshort(reasoninstance,"text_required_ind")
       SET get_waste_reason_codes_reply->events[eventidx].reasons[reasonidx].display =
       uar_srvgetstringptr(reasoninstance,"display")
     ENDFOR
   ENDFOR
   CALL echorecord(get_waste_reason_codes_reply)
   CALL echo(build("SRV Reply for ",get_reason_codes_srv_request," is translated."))
 END ;Subroutine
 SUBROUTINE (populatestatusreasoncodes(recorddata=vc(ref)) =null WITH protect)
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   DECLARE substatusinstance = i4 WITH protect, noconstant(0)
   DECLARE statussize = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET statusinstance = uar_srvgetstruct(hrep,"status_data")
   SET recorddata->status_data.status = uar_srvgetstringptr(statusinstance,"status")
   SET statussize = uar_srvgetitemcount(statusinstance,"subeventstatus")
   SET stat = alterlist(recorddata->status_data.subeventstatus,statussize)
   FOR (idx = 0 TO (statussize - 1))
     SET substatusinstance = uar_srvgetitem(statusinstance,"subeventstatus",idx)
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationname = uar_srvgetstringptr(
      substatusinstance,"OperationName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationstatus = uar_srvgetstringptr(
      substatusinstance,"OperationStatus")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectname = uar_srvgetstringptr(
      substatusinstance,"TargetObjectName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectvalue = uar_srvgetstringptr(
      substatusinstance,"TargetObjectValue")
   ENDFOR
 END ;Subroutine
 DECLARE create_med_req_alert_request_number = i4 WITH protect, constant(395146)
 DECLARE create_med_req_srv_request = vc WITH constant("AdmRequestMedications"), protect
 DECLARE get_med_req_alert_request_number = i4 WITH protect, constant(395100)
 DECLARE get_med_req_srv_request = vc WITH constant("GetAdmRequestMedications"), protect
 SUBROUTINE (processcreatemedrequestalert(cclrequest=i4) =null WITH protect)
   CALL echo("processCreateMedRequestAlert started...")
   CALL initializerequest(create_med_request_alerts_reply,create_med_req_alert_request_number)
   IF ((create_med_request_alerts_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL preparecreatemedrequestalert(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo(build("nCrmStat: ",ncrmstat," hstep: ",hstep))
   SET hrep = validatereply(ncrmstat,hstep,create_med_request_alerts_reply,1)
   CALL echo(build("hRep is =",hrep))
   IF ((create_med_request_alerts_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    CALL echo(build("exiting in validating reply"))
    CALL echo(build("create_med_request_alerts_reply->status_data.status-->",
      create_med_request_alerts_reply->status_data.status))
    GO TO exit_script
   ENDIF
   CALL translatecreatemedrequestalert(hrep)
   CALL echo("processCreateMedRequestAlert ended.")
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparecreatemedrequestalert(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo(build("Loading SRV Request for ",create_med_req_alert_request_number))
   CALL echorecord(create_med_request_alert_request)
   DECLARE medcnt = i4 WITH protect, constant(size(create_med_request_alert_request->
     requested_medications,5))
   DECLARE dispensecnt = i4 WITH protect, noconstant(0)
   DECLARE medidx = i4 WITH protect, noconstant(0)
   DECLARE dispidx = i4 WITH protect, noconstant(0)
   DECLARE medinst = i4 WITH protect, noconstant(0)
   DECLARE dispenseinst = i4 WITH protect, noconstant(0)
   DECLARE iteminst = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   SET nsrvstat = uar_srvsetshort(srvrequest,"adm_type_flag",cnvtint(validate(
      create_med_request_alert_request->adm_type_flag,"0")))
   SET nsrvstat = uar_srvsetshort(srvrequest,"print_label_ind",1)
   FOR (medidx = 1 TO medcnt)
     SET medinst = uar_srvadditem(srvrequest,"requested_medications")
     SET nsrvstat = uar_srvsetdouble(medinst,"order_id",cnvtreal(create_med_request_alert_request->
       requested_medications[medidx].order_id))
     SET nsrvstat = uar_srvsetdouble(medinst,"item_id",cnvtreal(create_med_request_alert_request->
       requested_medications[medidx].item_id))
     SET nsrvstat = uar_srvsetdouble(medinst,"requestor_prsnl_id",cnvtreal(
       create_med_request_alert_request->requested_medications[medidx].requestor_prsnl_id))
     SET nsrvstat = uar_srvsetdate(medinst,"request_dt_tm",cnvtdatetime(
       create_med_request_alert_request->requested_medications[medidx].request_dt_tm))
     SET nsrvstat = uar_srvsetdouble(medinst,"reason_cd",cnvtreal(create_med_request_alert_request->
       requested_medications[medidx].reason_cd))
     SET nsrvstat = uar_srvsetstring(medinst,"reason_text",nullterm(create_med_request_alert_request
       ->requested_medications[medidx].reason_text))
     SET nsrvstat = uar_srvsetdouble(medinst,"encounter_id",cnvtreal(create_med_request_alert_request
       ->requested_medications[medidx].encounter_id))
     IF (cnvtreal(create_med_request_alert_request->requested_medications[medidx].service_loc_cd) >
     0.0)
      SET nsrvstat = uar_srvsetdouble(medinst,"service_loc_cd",cnvtreal(
        create_med_request_alert_request->requested_medications[medidx].service_loc_cd))
     ELSE
      SET nsrvstat = uar_srvsetdouble(medinst,"service_loc_cd",resolvenurseunit(cnvtreal(
         create_med_request_alert_request->requested_medications[medidx].encounter_id)))
     ENDIF
     CALL echo(build("SRV Request for ",create_med_req_srv_request," is populated."))
   ENDFOR
 END ;Subroutine
 SUBROUTINE (resolvenurseunit(encounterid=f8) =f8 WITH protect)
   DECLARE servicelocationcd = f8 WITH protect, noconstant(0.0)
   IF (encounterid > 0.0)
    SELECT INTO "nl:"
     FROM encntr_domain ed
     WHERE ed.encntr_id=encounterid
     DETAIL
      servicelocationcd = ed.loc_nurse_unit_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(servicelocationcd)
 END ;Subroutine
 SUBROUTINE (translatecreatemedrequestalert(hreply=i4(ref)) =null WITH protect)
   CALL echo(build("Translating SRV Reply for ",create_med_req_srv_request))
   DECLARE replydatainstance = i4 WITH protect, noconstant(0)
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   DECLARE reqmedcnt = i4 WITH protect, constant(uar_srvgetitemcount(replydatainstance,nullterm(
      "requested_medications")))
   DECLARE reqmedidx = i4 WITH protect, noconstant(0)
   DECLARE reqmedinstance = i4 WITH protect, noconstant(0)
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   CALL populatestatusmedrequest(create_med_request_alerts_reply)
   SET stat = alterlist(create_med_request_alerts_reply->requested_medications,reqmedcnt)
   FOR (reqmedidx = 1 TO reqmedcnt)
     SET reqmedinstance = uar_srvgetitem(replydatainstance,nullterm("requested_medications"),(
      reqmedidx - 1))
     SET create_med_request_alerts_reply->requested_medications[reqmedidx].rxs_med_request_id =
     uar_srvgetdouble(reqmedinstance,"rxs_med_request_id")
     SET create_med_request_alerts_reply->requested_medications[reqmedidx].order_id =
     uar_srvgetdouble(reqmedinstance,"order_id")
     SET create_med_request_alerts_reply->requested_medications[reqmedidx].item_id = uar_srvgetdouble
     (reqmedinstance,"item_id")
     SET create_med_request_alerts_reply->requested_medications[reqmedidx].alert_id =
     uar_srvgetdouble(reqmedinstance,"alert_id")
   ENDFOR
   CALL echorecord(create_med_request_alerts_reply)
   CALL echo(build("SRV Reply for ",create_med_req_srv_request," is translated."))
 END ;Subroutine
 SUBROUTINE (populatestatusmedrequest(recorddata=vc(ref)) =null WITH protect)
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   DECLARE substatusinstance = i4 WITH protect, noconstant(0)
   DECLARE statussize = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET statusinstance = uar_srvgetstruct(hrep,"status_data")
   SET recorddata->status_data.status = uar_srvgetstringptr(statusinstance,"status")
   SET statussize = uar_srvgetitemcount(statusinstance,"subeventstatus")
   SET stat = alterlist(recorddata->status_data.subeventstatus,statussize)
   FOR (idx = 0 TO (statussize - 1))
     SET substatusinstance = uar_srvgetitem(statusinstance,"subeventstatus",idx)
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationname = uar_srvgetstringptr(
      substatusinstance,"OperationName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].operationstatus = uar_srvgetstringptr(
      substatusinstance,"OperationStatus")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectname = uar_srvgetstringptr(
      substatusinstance,"TargetObjectName")
     SET recorddata->status_data.subeventstatus[(idx+ 1)].targetobjectvalue = uar_srvgetstringptr(
      substatusinstance,"TargetObjectValue")
   ENDFOR
 END ;Subroutine
 SUBROUTINE (processgetmedrequestalert(cclrequest=i4) =null WITH protect)
   CALL echo("processGetMedRequestAlert started...")
   CALL initializerequest(get_med_request_alerts_reply,get_med_req_alert_request_number)
   IF ((get_med_request_alerts_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL preparegetmedrequestalert(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo(build("nCrmStat: ",ncrmstat," hstep: ",hstep))
   SET hrep = validatereply(ncrmstat,hstep,get_med_request_alerts_reply,1)
   IF ((get_med_request_alerts_reply->status_data.status="F"))
    CALL exit_servicerequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   CALL translategetmedrequestalert(hrep)
   CALL echo("processGetMedRequestAlert ended.")
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparegetmedrequestalert(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH protect)
   CALL echo(build("Loading SRV Request for ",get_med_req_alert_request_number))
   CALL echorecord(get_med_request_alert_request)
   DECLARE searchinstance = i4 WITH noconstant(0), protect
   SET searchinstance = uar_srvgetstruct(srvrequest,nullterm("search_criteria"))
   DECLARE loccnt = i4 WITH protect, constant(size(get_med_request_alert_request->search_criteria.
     locations,5))
   DECLARE locidx = i4 WITH protect, noconstant(0)
   DECLARE locinst = i4 WITH protect, noconstant(0)
   DECLARE typecnt = i4 WITH protect, constant(size(get_med_request_alert_request->search_criteria.
     alert_types,5))
   DECLARE typeidx = i4 WITH protect, noconstant(0)
   DECLARE typeinst = i4 WITH protect, noconstant(0)
   DECLARE statuscnt = i4 WITH protect, constant(size(get_med_request_alert_request->search_criteria.
     alert_statuses,5))
   DECLARE statusidx = i4 WITH protect, noconstant(0)
   DECLARE statusinst = i4 WITH protect, noconstant(0)
   DECLARE sevcnt = i4 WITH protect, constant(size(get_med_request_alert_request->search_criteria.
     alert_severities,5))
   DECLARE sevidx = i4 WITH protect, noconstant(0)
   DECLARE sevinst = i4 WITH protect, noconstant(0)
   DECLARE iteminst = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   SET nsrvstat = uar_srvsetdate(searchinstance,"start_dt_tm",cnvtdatetime(
     get_med_request_alert_request->search_criteria.start_dt_tm))
   SET nsrvstat = uar_srvsetdate(searchinstance,"end_dt_tm",cnvtdatetime(
     get_med_request_alert_request->search_criteria.end_dt_tm))
   FOR (locidx = 1 TO loccnt)
    SET locinst = uar_srvadditem(searchinstance,"locations")
    IF (cnvtreal(get_med_request_alert_request->search_criteria.locations[locidx].service_location_cd
     ) > 0.0)
     SET nsrvstat = uar_srvsetdouble(locinst,"service_location_cd",cnvtreal(
       get_med_request_alert_request->search_criteria.locations[locidx].service_location_cd))
    ELSE
     SET nsrvstat = uar_srvsetdouble(locinst,"service_location_cd",resolvenurseunit(cnvtreal(
        get_med_request_alert_request->search_criteria.encounter_id)))
    ENDIF
   ENDFOR
   FOR (typeidx = 1 TO typecnt)
    SET typeinst = uar_srvadditem(searchinstance,"alert_types")
    SET nsrvstat = uar_srvsetdouble(typeinst,"alert_type_cd",cnvtreal(get_med_request_alert_request->
      search_criteria.alert_types[typeidx].alert_type_cd))
   ENDFOR
   FOR (statusidx = 1 TO statuscnt)
    SET statusinst = uar_srvadditem(searchinstance,"alert_statuses")
    SET nsrvstat = uar_srvsetdouble(statusinst,"alert_status_cd",cnvtreal(
      get_med_request_alert_request->search_criteria.alert_statuses[statusidx].alert_status_cd))
   ENDFOR
   FOR (sevidx = 1 TO sevcnt)
    SET sevinst = uar_srvadditem(searchinstance,"alert_severities")
    SET nsrvstat = uar_srvsetdouble(sevinst,"alert_severity_cd",cnvtreal(
      get_med_request_alert_request->search_criteria.alert_severities[sevidx].alert_severity_cd))
   ENDFOR
   SET nsrvstat = uar_srvsetshort(searchinstance,"return_all_critical_alerts_ind",cnvtint(
     get_med_request_alert_request->search_criteria.return_all_critical_alerts_ind))
   SET nsrvstat = uar_srvsetshort(searchinstance,"return_audit_history_ind",cnvtint(
     get_med_request_alert_request->search_criteria.return_audit_history_ind))
   SET nsrvstat = uar_srvsetshort(searchinstance,"return_activity_history_ind",cnvtint(
     get_med_request_alert_request->search_criteria.return_activity_history_ind))
   CALL echo(build("SRV Request for ",get_med_req_srv_request," is populated."))
 END ;Subroutine
 SUBROUTINE (translategetmedrequestalert(hreply=i4(ref)) =null WITH protect)
   CALL echo(build("Translating SRV Reply for ",get_med_req_srv_request))
   DECLARE alertcnt = i4 WITH protect, constant(uar_srvgetitemcount(hreply,nullterm("alerts")))
   DECLARE alertidx = i4 WITH protect, noconstant(0)
   DECLARE alertinstance = i4 WITH protect, noconstant(0)
   DECLARE alertiteminst = i4 WITH noconstant(0), protect
   DECLARE alertaudithistinst = i4 WITH noconstant(0), protect
   DECLARE alertactivityinst = i4 WITH noconstant(0), protect
   DECLARE statusinstance = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE time_diff = f8 WITH protect, noconstant(0.0)
   DECLARE cur_dt_var = dq8 WITH protect, noconstant(0)
   SET cur_dt_var = cnvtdatetime(sysdate)
   CALL populatestatusmedrequest(get_med_request_alerts_reply)
   SET stat = alterlist(get_med_request_alerts_reply->alerts,alertcnt)
   FOR (alertidx = 1 TO alertcnt)
     SET alertinstance = uar_srvgetitem(hreply,nullterm("alerts"),(alertidx - 1))
     SET get_med_request_alerts_reply->alerts[alertidx].alert_source = uar_srvgetshort(alertinstance,
      "alert_source")
     SET get_med_request_alerts_reply->alerts[alertidx].rxs_alert_id = uar_srvgetdouble(alertinstance,
      "rxs_alert_id")
     SET get_med_request_alerts_reply->alerts[alertidx].alert_status_cd = uar_srvgetdouble(
      alertinstance,"alert_status_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].alert_type_cd = uar_srvgetdouble(
      alertinstance,"alert_type_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].alert_svrty_cd = uar_srvgetdouble(
      alertinstance,"alert_svrty_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].create_prsnl_id = uar_srvgetdouble(
      alertinstance,"create_prsnl_id")
     SET get_med_request_alerts_reply->alerts[alertidx].create_prsnl_name = uar_srvgetstringptr(
      alertinstance,"create_prsnl_name")
     SET stat = uar_srvgetdate(alertinstance,"create_dt_tm",get_med_request_alerts_reply->alerts[
      alertidx].create_dt_tm)
     SET get_med_request_alerts_reply->alerts[alertidx].cluster_cd = uar_srvgetdouble(alertinstance,
      "cluster_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].location_cd = uar_srvgetdouble(alertinstance,
      "location_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].location_disp = uar_srvgetstringptr(
      alertinstance,"location_disp")
     SET get_med_request_alerts_reply->alerts[alertidx].locator_cd = uar_srvgetdouble(alertinstance,
      "locator_cd")
     SET get_med_request_alerts_reply->alerts[alertidx].locator_disp = uar_srvgetstringptr(
      alertinstance,"locator_disp")
     SET get_med_request_alerts_reply->alerts[alertidx].alert_text = uar_srvgetstringptr(
      alertinstance,"alert_text")
     SET itemcnt = uar_srvgetitemcount(alertinstance,nullterm("items"))
     SET stat = alterlist(get_med_request_alerts_reply->alerts[alertidx].items,itemcnt)
     FOR (y = 1 TO itemcnt)
       SET alertiteminst = uar_srvgetitem(alertinstance,nullterm("items"),(y - 1))
       SET get_med_request_alerts_reply->alerts[alertidx].items[y].inv_item_id = uar_srvgetdouble(
        alertiteminst,"inv_item_id")
       SET get_med_request_alerts_reply->alerts[alertidx].items[y].med_item_id = uar_srvgetdouble(
        alertiteminst,"med_item_id")
       SET get_med_request_alerts_reply->alerts[alertidx].items[y].item_description =
       uar_srvgetstringptr(alertiteminst,"item_description")
       SET get_med_request_alerts_reply->alerts[alertidx].items[y].item_brand_name =
       uar_srvgetstringptr(alertiteminst,"item_brand_name")
       SET get_med_request_alerts_reply->alerts[alertidx].items[y].legal_status_cd = uar_srvgetdouble
       (alertiteminst,"legal_status_cd")
     ENDFOR
     SET auditcnt = uar_srvgetitemcount(alertinstance,nullterm("audit_history"))
     SET stat = alterlist(get_med_request_alerts_reply->alerts[alertidx].audit_history,auditcnt)
     FOR (y = 1 TO auditcnt)
       SET alertaudithistinst = uar_srvgetitem(alertinstance,nullterm("audit_history"),(y - 1))
       SET get_med_request_alerts_reply->alerts[alertidx].audit_history[y].rx_audit_hx_id =
       uar_srvgetdouble(alertaudithistinst,"rx_audit_hx_id")
       SET get_med_request_alerts_reply->alerts[alertidx].audit_history[y].audit_type_cd =
       uar_srvgetdouble(alertaudithistinst,"audit_type_cd")
       SET get_med_request_alerts_reply->alerts[alertidx].audit_history[y].prsnl_id =
       uar_srvgetdouble(alertaudithistinst,"prsnl_id")
       SET get_med_request_alerts_reply->alerts[alertidx].audit_history[y].prsnl_name =
       uar_srvgetstringptr(alertaudithistinst,"prsnl_name")
       SET stat = uar_srvgetdate(alertaudithistinst,"audit_dt_tm",get_med_request_alerts_reply->
        alerts[alertidx].audit_history[y].audit_dt_tm)
     ENDFOR
     SET activitycnt = uar_srvgetitemcount(alertinstance,nullterm("activities"))
     SET stat = alterlist(get_med_request_alerts_reply->alerts[alertidx].med_request,activitycnt)
     FOR (y = 1 TO activitycnt)
       SET alertactivityinst = uar_srvgetitem(alertinstance,nullterm("activities"),(y - 1))
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_id =
       uar_srvgetdouble(alertactivityinst,"activity_id")
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_prsnl_id =
       uar_srvgetdouble(alertactivityinst,"activity_prsnl_id")
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_type_cd =
       uar_srvgetdouble(alertactivityinst,"activity_type_cd")
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_prsnl_name =
       uar_srvgetstringptr(alertactivityinst,"activity_prsnl_name")
       SET stat = uar_srvgetdate(alertactivityinst,"activity_dt_tm",get_med_request_alerts_reply->
        alerts[alertidx].med_request[y].med_req_dt_tm)
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_reason_cd =
       uar_srvgetdouble(alertactivityinst,"reason_cd")
       SET get_med_request_alerts_reply->alerts[alertidx].med_request[y].med_req_reason_text =
       uar_srvgetstringptr(alertactivityinst,"reason_text")
     ENDFOR
     SET get_med_request_alerts_reply->alerts[alertidx].alert_description = uar_srvgetstringptr(
      alertinstance,"alert_description")
     SET stat = uar_srvgetdate(alertinstance,"update_dt_tm",get_med_request_alerts_reply->alerts[
      alertidx].update_dt_tm)
     SET time_diff = datetimediff(cnvtdatetime(cur_dt_var),cnvtdatetimeutc(
       get_med_request_alerts_reply->alerts[alertidx].update_dt_tm,1),3)
     SET get_med_request_alerts_reply->alerts[alertidx].last_updt_hrs = time_diff
   ENDFOR
   CALL echorecord(get_med_request_alerts_reply)
   CALL echo(build("SRV Reply for ",get_med_req_srv_request," is translated."))
 END ;Subroutine
 DECLARE get_adm_domain_type_by_encounter_id_request_number = i4 WITH protect, constant(395212)
 DECLARE get_adm_domain_type_by_encounter_id_srv_request = vc WITH constant(
  "GetADMDomainTypeByEncounterID"), protect
 SUBROUTINE (processgetadmdomaintypebyencounteridrequest(cclrequest=i4) =null WITH protect)
   CALL echo("processGetADMDomainTypeByEncounterIDRequest started...")
   CALL initializerequest(get_adm_domain_type_by_encounter_id_reply,
    get_adm_domain_type_by_encounter_id_request_number)
   CALL preparegetadmdomaintypebyencounterid(cclrequest,hreq)
   SET ncrmstat = uar_crmperform(hstep)
   CALL echo("back from step")
   CALL echo(build("nCrmStat is ",ncrmstat))
   CALL echo(build("hstep=",hstep))
   SET hrep = validatereply(ncrmstat,hstep,get_adm_domain_type_by_encounter_id_reply,1)
   IF ((get_adm_domain_type_by_encounter_id_reply->status_data.status="Z"))
    CALL echo("zero status")
    GO TO exit_script
   ELSE
    CALL echo("translate")
    CALL translategetadmdomaintypebyencounterid(hrep)
   ENDIF
   CALL exit_servicerequest(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (preparegetadmdomaintypebyencounterid(cclrequest=i4(ref),srvrequest=i4(ref)) =null WITH
  protect)
   CALL echo("Loading SRV Request for GetADMDomainTypeByEncounterID...")
   DECLARE qualifiersinstance = i4 WITH noconstant(0), protect
   SET qualifiersinstance = uar_srvgetstruct(srvrequest,nullterm("qualifiers"))
   SET nsrvstat = uar_srvsetdouble(qualifiersinstance,"encounter_id",cnvtreal(
     get_adm_domain_type_by_encounter_id_request->qualifiers.encounter_id))
   CALL echorecord(get_adm_domain_type_by_encounter_id_request)
   CALL echo("Exit prepareGetADMDomainTypeByEncounterID")
 END ;Subroutine
 SUBROUTINE (translategetadmdomaintypebyencounterid(hreply=i4(ref)) =null WITH protect)
   CALL echo("In translateGetADMDomainTypeByEncounterID()")
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replydatainstance = i4 WITH noconstant(0), protect
   DECLARE statusinstance = i4 WITH noconstant(0), protect
   SET replydatainstance = uar_srvgetstruct(hreply,nullterm("reply_data"))
   SET statusinstance = uar_srvgetstruct(hreply,nullterm("status_data"))
   SET get_adm_domain_type_by_encounter_id_reply->reply_data.adm_type_flag = uar_srvgetshort(
    replydatainstance,"adm_domain_type")
   SET get_adm_domain_type_by_encounter_id_reply->status_data.status = uar_srvgetstringptr(
    statusinstance,"status")
   CALL echorecord(get_adm_domain_type_by_encounter_id_reply)
   CALL echo(build("Exit translateGetADMDomainTypeByEncounterID(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)))
 END ;Subroutine
 DECLARE mses_app_num = i4 WITH protect, constant(3202004)
 DECLARE mses_task_num = i4 WITH protect, constant(3202004)
 DECLARE mses_authentication_request_number = i4 WITH protect, constant(395223)
 DECLARE mses_retrieve_wasteables_request_number = i4 WITH protect, constant(395218)
 DECLARE mses_waste_start_request_number = i4 WITH protect, constant(395219)
 DECLARE mses_waste_submit_cdcs_request_number = i4 WITH protect, constant(395220)
 DECLARE mses_waste_submit_quantities_request_number = i4 WITH protect, constant(395221)
 DECLARE mses_waste_submit_witness_request_number = i4 WITH protect, constant(395222)
 DECLARE mses_queue_orders_request_number = i4 WITH protect, constant(395201)
 SUBROUTINE (processmsesauthentication(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESAuthentication started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_authentication_request_number,"JSON",
    jsonrequest,
    "REC",mses_authentication_reply)
   CALL echo("processMSESAuthentication finished...")
 END ;Subroutine
 SUBROUTINE (processmsesretrievewasteables(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESRetrieveWasteables started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_retrieve_wasteables_request_number,"JSON",
    jsonrequest,
    "REC",mses_retrieve_wasteables_reply)
   CALL echo("processMSESRetrieveWasteables finished...")
 END ;Subroutine
 SUBROUTINE (processmsesstartwaste(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESStartWaste started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_waste_start_request_number,"JSON",
    jsonrequest,
    "REC",mses_waste_start_reply)
   CALL echo("processMSESStartWaste finished...")
 END ;Subroutine
 SUBROUTINE (processmsessubmitwastecdcs(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESSubmitWasteCDCs started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_waste_submit_cdcs_request_number,"JSON",
    jsonrequest,
    "REC",mses_waste_submit_cdcs_reply)
   CALL echo("processMSESSubmitWasteCDCs finished...")
 END ;Subroutine
 SUBROUTINE (processmsessubmitwastequantities(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESSubmitWasteQuantities started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_waste_submit_quantities_request_number,
    "JSON",jsonrequest,
    "REC",mses_waste_submit_quantities_reply)
   CALL echo("processMSESSubmitWasteQuantities finished...")
 END ;Subroutine
 SUBROUTINE (processmsessubmitwitness(jsonrequest=vc) =null WITH protect)
   CALL echo("processMSESSubmitWitness started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_waste_submit_witness_request_number,"JSON",
    jsonrequest,
    "REC",mses_waste_submit_witness_reply)
   CALL echo("processMSESSubmitWitness finished...")
 END ;Subroutine
 SUBROUTINE processmsesqueueorders(jsonrequest)
   CALL echo("processMSESQueueOrders started...")
   SET stat = tdbexecute(mses_app_num,mses_task_num,mses_queue_orders_request_number,"JSON",
    jsonrequest,
    "REC",queue_task_reply)
   CALL echo("processMSESQueueOrders finished...")
 END ;Subroutine
 DECLARE msg_debug = i4 WITH noconstant(0)
 SET msg_debug = uar_msgopen("adm_adapter_ccl_driver_dbg")
 CALL uar_msgsetlevel(msg_debug,emsglvl_debug)
 SET log_program_name = "ADM_ADAPTER_CCL_DRIVER"
 DECLARE ccldriverreply = i4 WITH protect, noconstant(0)
 DECLARE ccldriverrequest = i4 WITH protect, noconstant(0)
 CALL echo("####################")
 CALL echo(build("Request Action: ", $REQUESTKEY))
 CALL echo(build("Request Payload: ", $REQUESTPAYLOAD))
 CASE ( $REQUESTKEY)
  OF "GET_ADM_PREFERENCES":
   CALL processgetadmpreferencesrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "MED_AVAILABILITY":
   CALL processmedavailabilityrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "USER_MAINTENANCE":
   CALL processusermaintenancerequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "QUEUE_TASK":
   CALL processqueuetaskrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "DEQUEUE_TASK":
   CALL processdequeuetaskrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "RETRIEVE_TASKS":
   GO TO exit_script
  OF "REMOTE_WASTE":
   CALL processremotewasterequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "RETRIEVE_TX_TO_WASTE":
   CALL processretrievetxtowasterequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "SEARCH_ITEM_TO_WASTE":
   CALL processsearchforitemtowasterequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "RETRIEVE_ITEMS_TO_OVERRIDE":
   CALL processretrieveitemstooverriderequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "REMOTE_OVERRIDE":
   CALL processremoteoverriderequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "GET_RETRACTABLE_ORDERS":
   CALL processgetretractableordersrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "SAVE_ORDER_DISPENSES":
   CALL processsaveorderdispensesrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "GET_WASTE_REASON_CODES":
   CALL processgetreasoncodesrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "CREATE_MED_REQUEST_ALERT":
   CALL processcreatemedrequestalert(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "GET_MED_REQUEST_ALERT":
   CALL processgetmedrequestalert(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "GET_ADM_DOMAIN_DETAILS":
   CALL processgetadmdomaintypebyencounteridrequest(cnvtjsontorec( $REQUESTPAYLOAD))
   GO TO exit_script
  OF "MSES_AUTHENTICATION":
   CALL processmsesauthentication( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_RETRIEVE_WASTEABLES":
   CALL processmsesretrievewasteables( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_WASTE_START":
   CALL processmsesstartwaste( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_WASTE_SUBMIT_CDCS":
   CALL processmsessubmitwastecdcs( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_WASTE_SUBMIT_QUANTITIES":
   CALL processmsessubmitwastequantities( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_WASTE_SUBMIT_WITNESS":
   CALL processmsessubmitwitness( $REQUESTPAYLOAD)
   GO TO exit_script
  OF "MSES_QUEUE_ORDERS":
   CALL processmsesqueueorders( $REQUESTPAYLOAD)
   GO TO exit_script
  ELSE
   GO TO error
 ENDCASE
#error
 CALL echo("adm-adapter-ccl-driver request key invalid...")
#exit_script
 CALL echo("adm-adapter-ccl-driver request processing complete...")
 DECLARE stringreplyjson = vc
 CASE ( $REQUESTKEY)
  OF "GET_ADM_PREFERENCES":
   SET stringreplyjson = cnvtrectojson(get_adm_preferences_reply)
   CALL putjsonrecordtofile(get_adm_preferences_reply)
  OF "MED_AVAILABILITY":
   SET stringreplyjson = cnvtrectojson(med_availability_reply)
   CALL putjsonrecordtofile(med_availability_reply)
  OF "USER_MAINTENANCE":
   SET stringreplyjson = cnvtrectojson(user_maintenance_reply)
   CALL putjsonrecordtofile(user_maintenance_reply)
  OF "QUEUE_TASK":
   SET stringreplyjson = cnvtrectojson(queue_task_reply)
   CALL putjsonrecordtofile(queue_task_reply)
  OF "DEQUEUE_TASK":
   SET stringreplyjson = cnvtrectojson(dequeue_task_reply)
   CALL putjsonrecordtofile(dequeue_task_reply)
  OF "RETRIEVE_TASKS":
   SET stringreplyjson = cnvtrectojson(retrieve_tasks_reply)
   CALL putjsonrecordtofile(retrieve_tasks_reply)
  OF "REMOTE_WASTE":
   SET stringreplyjson = cnvtrectojson(remote_waste_reply)
   CALL putjsonrecordtofile(remote_waste_reply)
  OF "RETRIEVE_TX_TO_WASTE":
   SET stringreplyjson = cnvtrectojson(retrieve_txs_to_waste_reply)
   CALL putjsonrecordtofile(retrieve_txs_to_waste_reply)
  OF "SEARCH_ITEM_TO_WASTE":
   SET stringreplyjson = cnvtrectojson(search_item_reply)
   CALL putjsonrecordtofile(search_item_reply)
  OF "RETRIEVE_ITEMS_TO_OVERRIDE":
   SET stringreplyjson = cnvtrectojson(retrieve_items_to_override_reply)
   CALL putjsonrecordtofile(retrieve_items_to_override_reply)
  OF "REMOTE_OVERRIDE":
   SET stringreplyjson = cnvtrectojson(remote_override_reply)
   CALL putjsonrecordtofile(remote_override_reply)
  OF "GET_RETRACTABLE_ORDERS":
   SET stringreplyjson = cnvtrectojson(get_retractable_orders_reply)
   CALL putjsonrecordtofile(get_retractable_orders_reply)
  OF "SAVE_ORDER_DISPENSES":
   SET stringreplyjson = cnvtrectojson(save_order_dispenses_reply)
   CALL putjsonrecordtofile(save_order_dispenses_reply)
  OF "GET_WASTE_REASON_CODES":
   SET stringreplyjson = cnvtrectojson(get_waste_reason_codes_reply)
   CALL putjsonrecordtofile(get_waste_reason_codes_reply)
  OF "CREATE_MED_REQUEST_ALERT":
   SET stringreplyjson = cnvtrectojson(create_med_request_alerts_reply)
   CALL putjsonrecordtofile(create_med_request_alerts_reply)
  OF "GET_MED_REQUEST_ALERT":
   SET stringreplyjson = cnvtrectojson(get_med_request_alerts_reply)
   CALL putjsonrecordtofile(get_med_request_alerts_reply)
  OF "GET_ADM_DOMAIN_DETAILS":
   SET stringreplyjson = cnvtrectojson(get_adm_domain_type_by_encounter_id_reply)
   CALL putjsonrecordtofile(get_adm_domain_type_by_encounter_id_reply)
  OF "MSES_AUTHENTICATION":
   SET stringreplyjson = cnvtrectojson(mses_authentication_reply)
   CALL putjsonrecordtofile(mses_authentication_reply)
  OF "MSES_RETRIEVE_WASTEABLES":
   SET stringreplyjson = cnvtrectojson(mses_retrieve_wasteables_reply)
   CALL putjsonrecordtofile(mses_retrieve_wasteables_reply)
  OF "MSES_WASTE_START":
   SET stringreplyjson = cnvtrectojson(mses_waste_start_reply)
   CALL putjsonrecordtofile(mses_waste_start_reply)
  OF "MSES_WASTE_SUBMIT_CDCS":
   SET stringreplyjson = cnvtrectojson(mses_waste_submit_cdcs_reply)
   CALL putjsonrecordtofile(mses_waste_submit_cdcs_reply)
  OF "MSES_WASTE_SUBMIT_QUANTITIES":
   SET stringreplyjson = cnvtrectojson(mses_waste_submit_quantities_reply)
   CALL putjsonrecordtofile(mses_waste_submit_quantities_reply)
  OF "MSES_WASTE_SUBMIT_WITNESS":
   SET stringreplyjson = cnvtrectojson(mses_waste_submit_witness_reply)
   CALL putjsonrecordtofile(mses_waste_submit_witness_reply)
  OF "MSES_QUEUE_ORDERS":
   SET stringreplyjson = cnvtrectojson(queue_task_reply)
   CALL putjsonrecordtofile(queue_task_reply)
  ELSE
   SET stringreplyjson = cnvtrectojson(invalid_request_key_reply)
   CALL putjsonrecordtofile(invalid_request_key_reply)
 ENDCASE
 CALL uar_msgwrite(msg_debug,emsglog_commit,nullterm("adm_adapter_ccl_user_maint:"),emsglvl_info,
  nullterm(stringreplyjson))
 CALL echo("Printing JSON Reply")
 CALL echo(stringreplyjson)
 CALL echo("adm-adapter-ccl-driver JSON reply committed...")
 CALL echo("Mod Date: 01/30/2017")
END GO
