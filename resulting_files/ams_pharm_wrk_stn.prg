CREATE PROGRAM ams_pharm_wrk_stn
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 RECORD reply_obj(
   1 max_coll_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD req_obj
 RECORD req_obj(
   1 code_set = f8
   1 cdf_meaning = vc
 )
 SET req_obj->code_set = 221
 SET req_obj->cdf_meaning = "PHARMWS"
 EXECUTE loc_get_cs_max_coll_seq:dba  WITH replace("REQUEST",req_obj), replace("reply",reply_obj)
 FREE RECORD request_details1
 RECORD request_details1(
   1 qual[*]
     2 parent_service_resource_cd = f8
     2 child_service_resource_cd = f8
     2 cdf_meaning = c12
     2 root_service_resource_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sequence = i4
 )
 FREE RECORD request_details
 RECORD request_details(
   1 qual[*]
     2 location_cd = f8
     2 specimen_login_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = vc
     2 short_desc = vc
     2 cdf_meaning = vc
     2 root_service_resource_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 discipline_type_cd = f8
     2 definition = vc
     2 organization_id = f8
     2 collation_seq = i4
     2 charge_cost_ratio = i4
     2 reimbursement_cost_ratio = i4
     2 transcript_que_cd = f8
     2 temp_multi_flag = i2
     2 nbr_exam_on_req = i4
     2 prelim_ind = i2
     2 expedite_nursing_ind = i2
     2 unread_films_ind = i2
     2 chk_diff_borr_ind = i2
     2 daily_folder_ind = i2
     2 folder_nbr_format_cd = f8
     2 return_loc_flag = i2
     2 lib_ind = i2
     2 purge_lib_ind = i2
     2 filing_method_cd = f8
     2 pull_list_by_sect_ind = i2
     2 inventory_resource_cd = f8
     2 pat_care_loc_ind = i2
     2 pharmacy_type_cd = f8
     2 rx_loc_type = i4
     2 rx_license = vc
     2 rx_code = vc
     2 nabp_nbr = vc
     2 mobile_cart = vc
     2 mobile_reorder_loc_cd = f8
     2 dispense_ind = i2
     2 supply_ind = i2
     2 atd_req_ind = i2
     2 rx_charge_ind = i2
     2 bb_device_type = i4
     2 bb_prod_ind = i2
     2 bb_monitored_temp_hi = f8
     2 bb_monitored_temp_lo = f8
     2 bb_barcode_id = f8
     2 location_type = i4
     2 primary_vendor = i4
     2 primary_fill_location = i4
     2 worklist_build_flag = i2
     2 worklist_hours = i4
     2 worklist_max = i4
     2 container_ind = i2
     2 gate_ind = i2
     2 autologin_ind = i2
     2 dispatch_download_ind = i2
     2 multiplexor_ind = i2
     2 strt_model_id = f8
     2 instr_identifier = i4
     2 point_of_care_flag = i2
     2 identifier_flag = i2
     2 auto_verify_flag = i2
     2 instr_alias = vc
     2 tax_payer_nbr = vc
     2 min_order_cost = f8
     2 master_account_nbr = vc
     2 comments = vc
     2 approved_vendor_status_cd = f8
     2 vendor_number = i4
     2 vendor_type_cd = f8
     2 auto_commit_po_ind = i2
     2 auto_commit_receipt_ind = i2
     2 acknowledgement_ind = i2
     2 output_dest_id = f8
     2 tax_exempt_ind = i2
     2 consolidate_rqstn_ind = i2
     2 blind_receipt_ind = i2
     2 manual_receipt_ind = i2
     2 allow_overshipments_ind = i2
     2 ack_variance_percent = f8
     2 ack_variance_amount = f8
     2 po_max_lines = i4
     2 allow_backorders_ind = i2
     2 accn_site_prefix = vc
     2 inv_location_cd = f8
     2 floorstock_ind = i2
     2 eso_tpn_cmpd_ind = i2
     2 eso_dose_msg_ind = i2
     2 eso_ingred_ind = i2
     2 autm_dspns_machn_cd = f8
     2 mpps_start_ind = i2
     2 mpps_reset_ind = i2
     2 clia_number = vc
     2 medical_director_name = vc
     2 examonly_hold_time_hrs = i2
 )
 FOR (i = 1 TO value(size(file_reply->qual,5)))
   SET stat = initrec(request_details)
   SET stat = alterlist(request_details->qual,1)
   SET request_details->qual[1].description = trim(file_reply->qual[i].description)
   SET request_details->qual[1].short_desc = trim(file_reply->qual[i].short_desc)
   SET active = cnvtupper(trim(file_reply->qual[i].active_ind))
   IF (active="YES")
    SET request_details->qual[1].active_ind = 1
   ELSE
    SET request_details->qual[1].active_ind = 0
   ENDIF
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=106
     AND cv.display_key="PHARMACY"
    DETAIL
     request_details->qual[1].activity_type_cd = cv.code_value
   ;end select
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6000
     AND cv.display_key="PHARMACY"
    DETAIL
     request_details->qual[1].discipline_type_cd = cv.code_value
   ;end select
   SET pharmacy_type = trim(file_reply->qual[i].pharmacy_type_cd)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=4500
     AND cv.display=pharmacy_type
    DETAIL
     request_details->qual[1].pharmacy_type_cd = cv.code_value
   ;end select
   SET pharmacy_loc = trim(file_reply->qual[i].location_cd)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.display=pharmacy_loc
    DETAIL
     request_details->qual[1].location_cd = cv.code_value
   ;end select
   SET inventory_loc = trim(file_reply->qual[i].inv_location_cd)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.description=inventory_loc
    DETAIL
     request_details->qual[1].inv_location_cd = cv.code_value
    WITH nocounter
   ;end select
   SET organization = trim(file_reply->qual[i].organization_id)
   SELECT
    o.organization_id
    FROM organization o
    WHERE o.org_name=organization
    DETAIL
     request_details->qual[1].organization_id = o.organization_id
    WITH nocounter
   ;end select
   SET request_details->qual[1].cdf_meaning = "PHARMWS"
   SET request_details->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request_details->qual[1].end_effective_dt_tm = cnvtdatetime(cnvtdate(12302100),183000)
   SET request_details->qual[1].collation_seq = reply_obj->max_coll_seq
   SET stat = tdbexecute(13000,13001,13001,"REC",request_details,
    "REC",reply)
 ENDFOR
 FOR (i = 1 TO value(size(file_reply->qual,5)))
   SET stat1 = initrec(request_details1)
   SET stat1 = alterlist(request_details1->qual,1)
   SET parent_resource = trim(file_reply->qual[i].parent_resource)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=221
     AND cv.description=parent_resource
    DETAIL
     request_details1->qual[1].parent_service_resource_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=221
     AND cv.display=trim(file_reply->qual[i].short_desc)
    DETAIL
     request_details1->qual[1].child_service_resource_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_details1->qual[1].cdf_meaning = "SUBSECTION"
   SET request_details1->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request_details1->qual[1].end_effective_dt_tm = cnvtdatetime(cnvtdate(12302100),curtime2)
   SET stat1 = tdbexecute(13000,13001,13023,"REC",request_details1,
    "REC",reply)
 ENDFOR
#exit_script
 SET script_ver = " 000 04/07/16 RK043114  Initial Release "
END GO
