CREATE PROGRAM edw_create_bb_product:dba
 SELECT INTO value(bbprdct_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_product_sk,16))),
   v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_product_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bb_product_nbr_format_ref,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_product_sub_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_donor_person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].abo_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_orig_abo_ref,16))),
   v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_alternate_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_autologous_ind,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_barcode_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_biohazard_ind,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_contributor_system_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_corrected_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].p_create_dt_tm,0,
      cnvtdatetimeutc(bb_product_info->qual[d.seq].p_create_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].p_create_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].bb_cross_reference,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_avail_qty,16,4))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_cur_dispense_device_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_directed_ind,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].bp_drawn_dt_tm,0,
      cnvtdatetimeutc(bb_product_info->qual[d.seq].bp_drawn_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].bp_drawn_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_disease_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_donated_by_relative_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_donation_type_ref,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].bb_donor_xref_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_electronic_entry_flg,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].p_expire_dt_tm,0,
      cnvtdatetimeutc(bb_product_info->qual[d.seq].p_expire_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].p_expire_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].
      bp_orig_expire_dt_tm,0,cnvtdatetimeutc(bb_product_info->qual[d.seq].bp_orig_expire_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].bp_orig_expire_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_inv_area_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_inventory_loc,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_orig_inventory_loc,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_intl_units,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_cur_inv_device_id,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].bp_lot_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_owner_area_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_manufacturer_org,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_supplier_org,16))),
   v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].supplier_prefix,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_orig_volume,16,4))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_orig_unit_meas_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].volume,16,4))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_unit_meas_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_item_unit_meas_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_item_volume,16,4))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].d_units_per_vial,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_flag_chars,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_intended_use_print_param_txt,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_interfaced_device_flg,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_locked_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_modified_product_sk,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_modified_product_ind,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_orig_ship_cong_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_orig_vis_insp_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_pool_option_id,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_pooled_product_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_pooled_product_ind,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_product_cat_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_product_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_product_class_ref,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].p_product_type_barcode,str_find,str_replace,3
     ))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].p_recv_dt_tm,0,
      cnvtdatetimeutc(bb_product_info->qual[d.seq].p_recv_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].p_recv_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_received_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_req_label_verify_ind,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].bp_org_rh_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].rh_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_storage_temp_ref,16))), v_bar,
   CALL print(trim(replace(bb_product_info->qual[d.seq].bp_segment_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_product_info->qual[d.seq].bb_upload_dt_tm,
      0,cnvtdatetimeutc(bb_product_info->qual[d.seq].bb_upload_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(bb_product_info->qual[d.seq].bb_upload_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(bb_product_info->qual[d.seq].p_active_ind,16))), v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("BBPRDCT Count = ",curqual))
 CALL edwupdatescriptstatus("BBPRDCT",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 01/03/12 SM016593"
END GO
