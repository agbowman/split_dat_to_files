CREATE PROGRAM bb_act_get_product:dba
 RECORD reply(
   1 products[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c40
     2 product_mean = c12
     2 product_cat_cd = f8
     2 product_cat_disp = c40
     2 product_cat_mean = c12
     2 product_class_cd = f8
     2 product_class_disp = c40
     2 product_class_mean = c12
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 flag_chars = c2
     2 pooled_product_id = f8
     2 modified_product_id = f8
     2 locked_ind = i2
     2 cur_inv_locn_cd = f8
     2 cur_inv_locn_disp = c40
     2 cur_inv_locn_mean = c12
     2 orig_inv_locn_cd = f8
     2 orig_inv_locn_disp = c40
     2 orig_inv_locn_mean = c12
     2 cur_supplier_id = f8
     2 recv_dt_tm = dq8
     2 recv_prsnl_id = f8
     2 orig_ship_cond_cd = f8
     2 orig_ship_cond_disp = c40
     2 orig_ship_cond_mean = c12
     2 orig_vis_insp_cd = f8
     2 orig_vis_insp_disp = c40
     2 orig_vis_insp_mean = c12
     2 storage_temp_cd = f8
     2 storage_temp_disp = c40
     2 storage_temp_mean = c12
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c40
     2 cur_unit_meas_mean = c12
     2 orig_unit_meas_cd = f8
     2 orig_unit_meas_disp = c40
     2 orig_unit_meas_mean = c12
     2 pooled_product_ind = i2
     2 modified_product_ind = i2
     2 corrected_ind = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_applctx = i4
     2 updt_id = f8
     2 active_ind = i2
     2 cur_expire_dt_tm = dq8
     2 cur_owner_area_cd = f8
     2 cur_owner_area_disp = c40
     2 cur_owner_area_mean = c12
     2 cur_inv_area_cd = f8
     2 cur_inv_area_disp = c40
     2 cur_inv_area_mean = c12
     2 cur_inv_device_id = f8
     2 cur_dispense_device_id = f8
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_mean = c12
     2 pool_option_id = f8
     2 barcode_nbr = c20
     2 create_dt_tm = dq8
     2 class_flag = i4
     2 product_note_ind = i2
     2 donated_by_relative_ind = i2
     2 disease_cd = f8
     2 disease_disp = c40
     2 donation_type_cd = f8
     2 donation_type_disp = c40
     2 donation_type_mean = c12
     2 electronic_entry_flag = i2
     2 req_label_verify_ind = i2
     2 cur_inv_org_id = f8
     2 cur_inv_org_name = vc
     2 intended_use_print_parm_txt = c1
     2 derivatives
       3 product_cd = f8
       3 product_disp = c40
       3 product_mean = c12
       3 item_volume = i4
       3 item_unit_meas_cd = f8
       3 item_unit_meas_disp = c40
       3 item_unit_meas_mean = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 manufacturer_id = f8
       3 cur_avail_qty = i4
       3 cur_intl_units = i4
       3 units_per_vial = i4
       3 manufacturer_disp = c100
     2 bloodproducts
       3 product_cd = f8
       3 product_disp = c40
       3 product_mean = c12
       3 supplier_prefix = c20
       3 cur_volume = i4
       3 orig_label_abo_cd = f8
       3 orig_label_abo_disp = c40
       3 orig_label_abo_mean = c12
       3 orig_label_rh_cd = f8
       3 orig_label_rh_disp = c40
       3 orig_label_rh_mean = c12
       3 cur_abo_cd = f8
       3 cur_abo_disp = c40
       3 cur_abo_mean = c12
       3 cur_rh_cd = f8
       3 cur_rh_disp = c40
       3 cur_rh_mean = c12
       3 segment_nbr = c25
       3 orig_expire_dt_tm = dq8
       3 orig_volume = i4
       3 lot_nbr = c25
       3 autologous_ind = i2
       3 directed_ind = i2
       3 drawn_dt_tm = dq8
       3 updt_cnt = i4
       3 active_ind = i2
       3 donor_person_id = f8
     2 productnote
       3 product_note_id = f8
       3 product_note = vc
       3 updt_cnt = i4
       3 long_text_id = f8
       3 long_text_updt_cnt = i4
     2 specialtests[*]
       3 special_testing_id = f8
       3 special_testing_cd = f8
       3 special_testing_disp = c40
       3 special_testing_mean = c12
       3 confirmed_ind = i2
       3 updt_cnt = i4
       3 active_ind = i2
       3 product_rh_phenotype_id = f8
       3 barcode_value = c20
       3 modifiable_flag = i2
       3 special_isbt = vc
     2 productevents[*]
       3 product_event_id = f8
       3 product_id = f8
       3 order_id = f8
       3 bb_result_id = f8
       3 event_type_cd = f8
       3 event_type_disp = c40
       3 event_type_mean = c12
       3 event_dt_tm = dq8
       3 event_prsnl_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 person_id = f8
       3 encntr_id = f8
       3 override_ind = i2
       3 override_reason_cd = f8
       3 override_reason_disp = c40
       3 override_reason_mean = c12
       3 related_product_event_id = f8
       3 mo_ind = i2
       3 qu_ind = i2
       3 pd_ind = i2
       3 dr_ind = i2
       3 qr_ind = i2
       3 re_ind = i2
       3 tr_ind = i2
       3 tf_ind = i2
       3 at_ind = i2
       3 bd_ind = i2
       3 as_ind = i2
       3 ar_ind = i2
       3 dn_ind = i2
       3 ad_ind = i2
       3 xm_ind = i2
       3 di_ind = i2
       3 bi_ind = i2
       3 event_status_flag = i2
       3 accession = vc
       3 owner_area_cd = f8
       3 owner_area_disp = vc
       3 inventory_area_cd = f8
       3 inventory_area_disp = vc
       3 organization_id = f8
       3 organization_name = vc
       3 disposition
         4 disposed_intl_units = i4
         4 reason_cd = f8
         4 reason_disp = c40
         4 reason_mean = c12
         4 disposed_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
       3 quarantinerelease
         4 quar_release_id = f8
         4 release_dt_tm = dq8
         4 release_prsnl_id = f8
         4 release_reason_cd = f8
         4 release_reason_disp = c40
         4 release_reason_mean = c12
         4 release_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 release_intl_units = i4
       3 quarantine
         4 quar_reason_cd = f8
         4 quar_reason_disp = c40
         4 quar_reason_mean = c12
         4 updt_cnt = i4
         4 active_ind = i2
         4 orig_quar_qty = i4
         4 cur_quar_qty = i4
         4 orig_quar_intl_units = i4
         4 cur_quar_intl_units = i4
       3 autodirected
         4 person_id = f8
         4 associated_dt_tm = dq8
         4 updt_cnt = i4
         4 active_ind = i2
         4 encntr_id = f8
         4 expected_usage_dt_tm = dq8
         4 name_full_formatted = vc
         4 mrn_alias = vc
         4 abo_cd = f8
         4 abo_disp = c40
         4 rh_cd = f8
         4 rh_disp = c40
         4 donated_by_relative_ind = i2
       3 modification
         4 orig_expire_dt_tm = dq8
         4 orig_volume = i4
         4 orig_unit_meas_cd = f8
         4 orig_unit_meas_disp = c40
         4 orig_unit_meas_mean = c12
         4 cur_expire_dt_tm = dq8
         4 cur_volume = i4
         4 cur_unit_meas_cd = f8
         4 cur_unit_meas_disp = c40
         4 cur_unit_meas_mean = c12
         4 modified_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 crossover_reason_cd = f8
         4 crossover_reason_disp = c40
         4 crossover_reason_mean = c12
         4 option_id = f8
         4 device_type_cd = f8
         4 device_type_disp = c40
         4 device_type_mean = c12
         4 accessory = vc
         4 lot_nbr = vc
         4 start_dt_tm = dq8
         4 stop_dt_tm = dq8
         4 vis_insp_cd = f8
         4 vis_insp_disp = c40
         4 vis_insp_mean = c12
       3 assign
         4 assign_reason_cd = f8
         4 assign_reason_disp = c40
         4 assign_reason_mean = c12
         4 person_id = f8
         4 prov_id = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 orig_assign_qty = i4
         4 cur_assign_qty = i4
         4 orig_assign_intl_units = i4
         4 cur_assign_intl_units = i4
         4 name_full_formatted = vc
         4 bb_id_nbr = c20
       3 transfusion
         4 person_id = f8
         4 transfused_intl_units = i4
         4 bag_returned_ind = i2
         4 tag_returned_ind = i2
         4 transfused_vol = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 orig_transfused_qty = i4
         4 cur_transfused_qty = i4
         4 name_full_formatted = vc
       3 destruction
         4 method_cd = f8
         4 method_disp = c40
         4 method_mean = c12
         4 box_nbr = c50
         4 manifest_nbr = c50
         4 destroyed_qty = i4
         4 autoclave_ind = i2
         4 destruction_org_id = f8
         4 updt_cnt = i4
         4 active_ind = i2
       3 abotesting
         4 product_id = f8
         4 result_id = f8
         4 abo_group_cd = f8
         4 abo_group_disp = c40
         4 abo_group_mean = c12
         4 rh_type_cd = f8
         4 rh_type_disp = c40
         4 rh_type_mean = c12
         4 current_updated_ind = i2
         4 updt_cnt = i4
         4 active_ind = i2
         4 abo_testing_id = f8
       3 transfer
         4 transferring_locn_cd = f8
         4 transferring_locn_disp = c40
         4 transferring_locn_mean = c12
         4 transfer_cond_cd = f8
         4 transfer_cond_disp = c40
         4 trnasfer_cond_mean = c12
         4 transfer_reason_cd = f8
         4 transfer_reason_disp = c40
         4 transfer_reason_mean = c12
         4 transfer_vis_insp_cd = f8
         4 transfer_vis_insp_disp = c40
         4 transfer_vis_insp_mean = c12
         4 transfer_qty = i4
         4 login_dt_tm = dq8
         4 login_prsnl_id = f8
         4 login_cond_cd = f8
         4 login_cond_disp = c40
         4 login_cond_mean = c12
         4 login_vis_insp_cd = f8
         4 login_vis_insp_disp = c40
         4 login_vis_insp_mean = c12
         4 login_qty = i4
         4 return_dt_tm = dq8
         4 return_prsnl_id = f8
         4 return_reason_cd = f8
         4 return_reason_disp = c40
         4 return_reason_mean = c12
         4 return_cond_cd = f8
         4 return_cond_disp = c40
         4 return_cond_mean = c12
         4 return_vis_insp_cd = f8
         4 return_vis_insp_disp = c40
         4 return_vis_insp_mean = c12
         4 return_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
       3 crossmatch
         4 crossmatch_qty = i4
         4 release_dt_tm = dq8
         4 release_prsnl_id = f8
         4 release_reason_cd = f8
         4 release_reason_disp = c40
         4 release_reason_mean = c12
         4 release_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 crossmatch_exp_dt_tm = dq8
         4 reinstate_reason_cd = f8
         4 reinstate_reason_disp = c40
         4 reinstate_reason_mean = c12
         4 bb_id_nbr = c20
         4 xm_reason_cd = f8
         4 xm_reason_disp = c40
         4 xm_reason_mean = c12
         4 person_id = f8
         4 name_full_formatted = vc
       3 dispensereturn
         4 dispense_return_id = f8
         4 return_dt_tm = dq8
         4 return_prsnl_id = f8
         4 return_reason_cd = f8
         4 return_reason_disp = c40
         4 return_reason_mean = c12
         4 return_vis_insp_cd = f8
         4 return_vis_insp_disp = c40
         4 return_vis_insp_mean = c12
         4 return_courier_id = f8
         4 return_qty = i4
         4 return_intl_units = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 return_courier_text = c100
       3 receipt
         4 active_ind = i2
         4 ship_cond_cd = f8
         4 ship_cond_disp = c40
         4 ship_cond_mean = c12
         4 vis_insp_cd = f8
         4 vis_insp_disp = c40
         4 vis_insp_mean = c12
         4 orig_rcvd_qty = i4
         4 orig_intl_units = i4
         4 updt_cnt = i4
         4 bb_supplier_id = f8
         4 alpha_translation_id = f8
         4 temperature_value = f8
         4 temperature_degree_cd = f8
         4 temperature_degree_disp = c40
         4 temperature_degree_mean = c12
       3 patientdispense
         4 person_id = f8
         4 dispense_prov_id = f8
         4 dispense_reason_cd = f8
         4 dispense_reason_disp = c40
         4 dispense_reason_mean = c12
         4 dispense_to_locn_cd = f8
         4 dispense_to_locn_disp = c40
         4 dispense_to_locn_mean = c12
         4 dispense_from_locn_cd = f8
         4 dispense_from_locn_disp = c40
         4 dispense_from_locn_mean = c12
         4 device_id = f8
         4 dispense_vis_insp_cd = f8
         4 dispense_vis_insp_disp = c40
         4 dispense_vis_insp_mean = c12
         4 dispense_cooler_id = f8
         4 dispense_cooler_text = c40
         4 dispense_courier_id = f8
         4 dispense_status_flag = i4
         4 orig_dispense_intl_units = i4
         4 cur_dispense_intl_units = i4
         4 orig_dispense_qty = i4
         4 cur_dispense_qty = i4
         4 unknown_patient_ind = i2
         4 unknown_patient_text = c50
         4 updt_cnt = i4
         4 active_ind = i2
         4 dispense_courier_text = c100
         4 bb_id_nbr = c20
         4 name_full_formatted = vc
       3 assignrelease
         4 assign_release_id = f8
         4 product_event_id = f8
         4 product_id = f8
         4 release_dt_tm = dq8
         4 release_prsnl_id = f8
         4 release_reason_cd = f8
         4 release_reason_disp = c40
         4 release_reason_mean = c12
         4 release_qty = i4
         4 updt_cnt = i4
         4 active_ind = i2
         4 release_intl_units = i4
       3 bbdevicetransfer
         4 from_device_id = f8
         4 to_device_id = f8
         4 reason_cd = f8
         4 reason_disp = c40
         4 reason_mean = c12
         4 updt_cnt = i4
       3 bbinventorytransfer
         4 from_owner_area_cd = f8
         4 from_owner_area_disp = c40
         4 from_inv_area_cd = f8
         4 from_inv_area_disp = c40
         4 to_owner_area_cd = f8
         4 to_owner_area_disp = c40
         4 to_inv_area_cd = f8
         4 to_inv_area_disp = c40
         4 transfer_reason_cd = f8
         4 transfer_reason_disp = c40
         4 transfer_reason_mean = c12
         4 updt_cnt = i4
         4 transferred_qty = i4
         4 transferred_iu = i4
         4 to_product_event_id = f8
         4 event_type_cd = f8
     2 recon_type_flag = i2
     2 product_type_barcode = vc
     2 serial_number_txt = c22
     2 interface_product_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 products[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 flag_chars = c2
     2 pooled_product_id = f8
     2 modified_product_id = f8
     2 locked_ind = i2
     2 cur_inv_locn_cd = f8
     2 orig_inv_locn_cd = f8
     2 cur_supplier_id = f8
     2 recv_dt_tm = dq8
     2 recv_prsnl_id = f8
     2 orig_ship_cond_cd = f8
     2 orig_vis_insp_cd = f8
     2 storage_temp_cd = f8
     2 cur_unit_meas_cd = f8
     2 orig_unit_meas_cd = f8
     2 pooled_product_ind = i2
     2 modified_product_ind = i2
     2 corrected_ind = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_applctx = i4
     2 updt_id = f8
     2 active_ind = i2
     2 cur_expire_dt_tm = dq8
     2 cur_owner_area_cd = f8
     2 cur_inv_area_cd = f8
     2 cur_inv_device_id = f8
     2 cur_dispense_device_id = f8
     2 contributor_system_cd = f8
     2 pool_option_id = f8
     2 barcode_nbr = c20
     2 create_dt_tm = dq8
     2 class_flag = i4
     2 product_note_ind = i2
     2 product_ok = i2
     2 donated_by_relative_ind = i2
     2 disease_cd = f8
     2 donation_type_cd = f8
     2 electronic_entry_flag = i2
     2 req_label_verify_ind = i2
     2 cur_inv_org_id = f8
     2 cur_inv_org_name = vc
     2 intended_use_print_parm_txt = c1
     2 derivatives
       3 product_cd = f8
       3 item_volume = i4
       3 item_unit_meas_cd = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 manufacturer_id = f8
       3 cur_avail_qty = i4
       3 cur_intl_units = i4
       3 units_per_vial = i4
       3 manufacturer_disp = c100
     2 bloodproducts
       3 product_cd = f8
       3 supplier_prefix = c20
       3 cur_volume = i4
       3 orig_label_abo_cd = f8
       3 orig_label_rh_cd = f8
       3 cur_abo_cd = f8
       3 cur_rh_cd = f8
       3 segment_nbr = c25
       3 orig_expire_dt_tm = dq8
       3 orig_volume = i4
       3 lot_nbr = c25
       3 autologous_ind = i2
       3 directed_ind = i2
       3 drawn_dt_tm = dq8
       3 updt_cnt = i4
       3 active_ind = i2
       3 donor_person_id = f8
     2 productnote
       3 product_note_id = f8
       3 product_note = vc
       3 updt_cnt = i4
       3 long_text_id = f8
       3 long_text_updt_cnt = i4
     2 specialtests[*]
       3 special_testing_id = f8
       3 special_testing_cd = f8
       3 confirmed_ind = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 product_rh_phenotype_id = f8
       3 barcode_value = c20
       3 modifiable_flag = i2
       3 special_isbt = vc
     2 productevents[*]
       3 product_event_id = f8
       3 product_id = f8
       3 order_id = f8
       3 bb_result_id = f8
       3 event_type_cd = f8
       3 event_dt_tm = dq8
       3 event_prsnl_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 person_id = f8
       3 encntr_id = f8
       3 override_ind = i2
       3 override_reason_cd = f8
       3 related_product_event_id = f8
       3 event_status_flag = i2
       3 accession = vc
       3 owner_area_cd = f8
       3 owner_area_disp = vc
       3 inventory_area_cd = f8
       3 inventory_area_disp = vc
       3 organization_id = f8
       3 organization_name = vc
     2 recon_type_flag = i2
     2 product_type_barcode = vc
     2 serial_number_txt = c22
     2 interface_product_id = f8
 )
 DECLARE ncnt = i2
 DECLARE ncnt2 = i2
 DECLARE i = i2
 DECLARE j = i2
 DECLARE k = i2
 DECLARE active_cond = i2
 DECLARE table_name = c2
 DECLARE prod_ok = i2
 DECLARE productclass_mean_blood = c12 WITH constant("BLOOD")
 DECLARE productclass_mean_derivative = c12 WITH constant("DERIVATIVE")
 DECLARE dmrntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE where1 = vc
 DECLARE where2 = vc
 SET product_not_valid = 0
 SET product_not_found = 0
 SET ncnt = 0
 SET failures = 0
 SET prod_ok = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,dmrntypecd)
 SET where1 = concat("(pr.product_nbr = trim(request->translated_product_nbr) or",
  " pr.product_nbr = trim(request->untranslated_product_nbr))")
 IF ((request->retrieve_inactive_events_ind=1))
  SET active_cond = 0
 ELSE
  SET active_cond = 1
 ENDIF
 IF (trim(request->serial_number_txt) > " ")
  SELECT INTO "nl:"
   FROM product pr
   WHERE ((pr.product_nbr=trim(request->translated_product_nbr)) OR (pr.product_nbr=trim(request->
    untranslated_product_nbr)))
    AND pr.serial_number_txt=trim(request->serial_number_txt)
   WITH nocounter
  ;end select
  IF (curqual >= 1)
   SET where2 = concat(where1," and (pr.serial_number_txt = trim(request->serial_number_txt))")
  ELSE
   SET where2 = concat(where1," and (nullval(pr.serial_number_txt,' ')=' ')")
  ENDIF
 ELSE
  SET where2 = where1
 ENDIF
 SET prodtypecnt = size(request->validproducttypes,5)
 IF (trim(request->translated_product_nbr) > "")
  SELECT
   IF (prodtypecnt > 0)
    FROM product pr,
     (dummyt d  WITH seq = value(prodtypecnt)),
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (d)
     JOIN (pr
     WHERE ((pr.product_nbr=trim(request->translated_product_nbr)) OR (pr.product_nbr=trim(request->
      untranslated_product_nbr)))
      AND pr.active_ind=1
      AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ELSE
    FROM product pr,
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (pr
     WHERE parser(where2)
      AND pr.active_ind=1)
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ENDIF
   INTO "nl:"
   *
   HEAD REPORT
    stat = alterlist(temp->products,10)
   DETAIL
    ncnt += 1
    IF (mod(ncnt,10)=1
     AND ncnt != 1)
     stat = alterlist(temp->products,(ncnt+ 9))
    ENDIF
    temp->products[ncnt].product_id = pr.product_id, temp->products[ncnt].product_cd = pr.product_cd,
    temp->products[ncnt].product_cat_cd = pr.product_cat_cd,
    temp->products[ncnt].product_class_cd = pr.product_class_cd, temp->products[ncnt].product_nbr =
    pr.product_nbr, temp->products[ncnt].serial_number_txt = pr.serial_number_txt,
    temp->products[ncnt].product_sub_nbr = pr.product_sub_nbr, temp->products[ncnt].alternate_nbr =
    pr.alternate_nbr, temp->products[ncnt].flag_chars = pr.flag_chars,
    temp->products[ncnt].pooled_product_id = pr.pooled_product_id, temp->products[ncnt].
    modified_product_id = pr.modified_product_id, temp->products[ncnt].locked_ind = pr.locked_ind,
    temp->products[ncnt].cur_inv_locn_cd = pr.cur_inv_locn_cd, temp->products[ncnt].orig_inv_locn_cd
     = pr.orig_inv_locn_cd, temp->products[ncnt].cur_supplier_id = pr.cur_supplier_id,
    temp->products[ncnt].recv_dt_tm = pr.recv_dt_tm, temp->products[ncnt].recv_prsnl_id = pr
    .recv_prsnl_id, temp->products[ncnt].orig_ship_cond_cd = pr.orig_ship_cond_cd,
    temp->products[ncnt].orig_vis_insp_cd = pr.orig_vis_insp_cd, temp->products[ncnt].storage_temp_cd
     = pr.storage_temp_cd, temp->products[ncnt].cur_unit_meas_cd = pr.cur_unit_meas_cd,
    temp->products[ncnt].orig_unit_meas_cd = pr.orig_unit_meas_cd, temp->products[ncnt].
    pooled_product_ind = pr.pooled_product_ind, temp->products[ncnt].modified_product_ind = pr
    .modified_product_ind,
    temp->products[ncnt].corrected_ind = pr.corrected_ind, temp->products[ncnt].updt_cnt = pr
    .updt_cnt, temp->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
    temp->products[ncnt].updt_task = pr.updt_task, temp->products[ncnt].updt_applctx = pr
    .updt_applctx, temp->products[ncnt].updt_id = pr.updt_id,
    temp->products[ncnt].active_ind = pr.active_ind, temp->products[ncnt].cur_expire_dt_tm = pr
    .cur_expire_dt_tm, temp->products[ncnt].cur_owner_area_cd = pr.cur_owner_area_cd,
    temp->products[ncnt].cur_inv_area_cd = pr.cur_inv_area_cd, temp->products[ncnt].cur_inv_device_id
     = pr.cur_inv_device_id, temp->products[ncnt].cur_dispense_device_id = pr.cur_dispense_device_id,
    temp->products[ncnt].contributor_system_cd = pr.contributor_system_cd, temp->products[ncnt].
    pool_option_id = pr.pool_option_id, temp->products[ncnt].barcode_nbr = pr.barcode_nbr,
    temp->products[ncnt].create_dt_tm = pr.create_dt_tm, temp->products[ncnt].donated_by_relative_ind
     = pr.donated_by_relative_ind, temp->products[ncnt].disease_cd = pr.disease_cd,
    temp->products[ncnt].donation_type_cd = pr.donation_type_cd, temp->products[ncnt].
    electronic_entry_flag = pr.electronic_entry_flag, temp->products[ncnt].req_label_verify_ind = pr
    .req_label_verify_ind,
    temp->products[ncnt].cur_inv_org_id = l.organization_id, temp->products[ncnt].cur_inv_org_name =
    o.org_name, temp->products[ncnt].intended_use_print_parm_txt = pr.intended_use_print_parm_txt,
    temp->products[ncnt].product_type_barcode = pr.product_type_barcode, temp->products[ncnt].
    interface_product_id = pr.interface_product_id
    IF (pr.pooled_product_ind=1
     AND bmo.recon_rbc_ind=1)
     temp->products[ncnt].recon_type_flag = 1
    ELSE
     temp->products[ncnt].recon_type_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Select on product by product_nbr"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->products,ncnt)
  IF (size(temp->products,5) > 0)
   SET ncnt = 0
   SELECT INTO "nl:"
    *
    FROM special_testing st,
     (dummyt d  WITH seq = value(size(temp->products,5))),
     bb_isbt_attribute_r biar,
     bb_isbt_attribute bia
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=temp->products[d.seq].product_id))
     JOIN (biar
     WHERE (biar.attribute_cd= Outerjoin(st.special_testing_cd))
      AND (biar.active_ind= Outerjoin(1)) )
     JOIN (bia
     WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
      AND (bia.active_ind= Outerjoin(1)) )
    ORDER BY st.product_id
    HEAD st.product_id
     ncnt = 0
    DETAIL
     ncnt += 1, stat = alterlist(temp->products[d.seq].specialtests,ncnt), temp->products[d.seq].
     specialtests[ncnt].special_testing_id = st.special_testing_id,
     temp->products[d.seq].specialtests[ncnt].special_testing_cd = st.special_testing_cd, temp->
     products[d.seq].specialtests[ncnt].confirmed_ind = st.confirmed_ind, temp->products[d.seq].
     specialtests[ncnt].updt_cnt = st.updt_cnt,
     temp->products[d.seq].specialtests[ncnt].active_ind = st.active_ind, temp->products[d.seq].
     specialtests[ncnt].product_rh_phenotype_id = st.product_rh_phenotype_id, temp->products[d.seq].
     specialtests[ncnt].barcode_value = st.barcode_value_txt,
     temp->products[d.seq].specialtests[ncnt].modifiable_flag = st.modifiable_flag, temp->products[d
     .seq].specialtests[ncnt].special_isbt = bia.standard_display
    WITH nocounter
   ;end select
  ELSE
   SET product_not_found = 1
  ENDIF
 ELSEIF (trim(request->untranslated_product_nbr) > "")
  SELECT
   IF (prodtypecnt > 0)
    FROM product pr,
     (dummyt d  WITH seq = value(prodtypecnt)),
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (d)
     JOIN (pr
     WHERE pr.product_nbr=trim(request->untranslated_product_nbr)
      AND pr.active_ind=1
      AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ELSE
    FROM product pr,
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (pr
     WHERE pr.product_nbr=trim(request->untranslated_product_nbr)
      AND pr.active_ind=1)
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ENDIF
   INTO "nl:"
   *
   HEAD REPORT
    stat = alterlist(temp->products,10)
   DETAIL
    ncnt += 1
    IF (mod(ncnt,10)=1
     AND ncnt != 1)
     stat = alterlist(temp->products,(ncnt+ 9))
    ENDIF
    temp->products[ncnt].product_id = pr.product_id, temp->products[ncnt].product_cd = pr.product_cd,
    temp->products[ncnt].product_cat_cd = pr.product_cat_cd,
    temp->products[ncnt].product_class_cd = pr.product_class_cd, temp->products[ncnt].product_nbr =
    pr.product_nbr, temp->products[ncnt].serial_number_txt = pr.serial_number_txt,
    temp->products[ncnt].product_sub_nbr = pr.product_sub_nbr, temp->products[ncnt].alternate_nbr =
    pr.alternate_nbr, temp->products[ncnt].flag_chars = pr.flag_chars,
    temp->products[ncnt].pooled_product_id = pr.pooled_product_id, temp->products[ncnt].
    modified_product_id = pr.modified_product_id, temp->products[ncnt].locked_ind = pr.locked_ind,
    temp->products[ncnt].cur_inv_locn_cd = pr.cur_inv_locn_cd, temp->products[ncnt].orig_inv_locn_cd
     = pr.orig_inv_locn_cd, temp->products[ncnt].cur_supplier_id = pr.cur_supplier_id,
    temp->products[ncnt].recv_dt_tm = pr.recv_dt_tm, temp->products[ncnt].recv_prsnl_id = pr
    .recv_prsnl_id, temp->products[ncnt].orig_ship_cond_cd = pr.orig_ship_cond_cd,
    temp->products[ncnt].orig_vis_insp_cd = pr.orig_vis_insp_cd, temp->products[ncnt].storage_temp_cd
     = pr.storage_temp_cd, temp->products[ncnt].cur_unit_meas_cd = pr.cur_unit_meas_cd,
    temp->products[ncnt].orig_unit_meas_cd = pr.orig_unit_meas_cd, temp->products[ncnt].
    pooled_product_ind = pr.pooled_product_ind, temp->products[ncnt].modified_product_ind = pr
    .modified_product_ind,
    temp->products[ncnt].corrected_ind = pr.corrected_ind, temp->products[ncnt].updt_cnt = pr
    .updt_cnt, temp->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
    temp->products[ncnt].updt_task = pr.updt_task, temp->products[ncnt].updt_applctx = pr
    .updt_applctx, temp->products[ncnt].updt_id = pr.updt_id,
    temp->products[ncnt].active_ind = pr.active_ind, temp->products[ncnt].cur_expire_dt_tm = pr
    .cur_expire_dt_tm, temp->products[ncnt].cur_owner_area_cd = pr.cur_owner_area_cd,
    temp->products[ncnt].cur_inv_area_cd = pr.cur_inv_area_cd, temp->products[ncnt].cur_inv_device_id
     = pr.cur_inv_device_id, temp->products[ncnt].cur_dispense_device_id = pr.cur_dispense_device_id,
    temp->products[ncnt].contributor_system_cd = pr.contributor_system_cd, temp->products[ncnt].
    pool_option_id = pr.pool_option_id, temp->products[ncnt].barcode_nbr = pr.barcode_nbr,
    temp->products[ncnt].create_dt_tm = pr.create_dt_tm, temp->products[ncnt].donated_by_relative_ind
     = pr.donated_by_relative_ind, temp->products[ncnt].disease_cd = pr.disease_cd,
    temp->products[ncnt].donation_type_cd = pr.donation_type_cd, temp->products[ncnt].
    electronic_entry_flag = pr.electronic_entry_flag, temp->products[ncnt].req_label_verify_ind = pr
    .req_label_verify_ind,
    temp->products[ncnt].cur_inv_org_id = l.organization_id, temp->products[ncnt].cur_inv_org_name =
    o.org_name, temp->products[ncnt].intended_use_print_parm_txt = pr.intended_use_print_parm_txt,
    temp->products[ncnt].product_type_barcode = pr.product_type_barcode, temp->products[ncnt].
    interface_product_id = pr.interface_product_id
    IF (pr.pooled_product_ind=1
     AND bmo.recon_rbc_ind=1)
     temp->products[ncnt].recon_type_flag = 1
    ELSE
     temp->products[ncnt].recon_type_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Select on product by product_nbr"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->products,ncnt)
  IF (size(temp->products,5) > 0)
   SET ncnt = 0
   SELECT INTO "nl:"
    *
    FROM special_testing st,
     (dummyt d  WITH seq = value(size(temp->products,5))),
     bb_isbt_attribute_r biar,
     bb_isbt_attribute bia
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=temp->products[d.seq].product_id))
     JOIN (biar
     WHERE (biar.attribute_cd= Outerjoin(st.special_testing_cd))
      AND (biar.active_ind= Outerjoin(1)) )
     JOIN (bia
     WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
      AND (bia.active_ind= Outerjoin(1)) )
    ORDER BY st.product_id
    HEAD st.product_id
     ncnt = 0
    DETAIL
     ncnt += 1, stat = alterlist(temp->products[d.seq].specialtests,ncnt), temp->products[d.seq].
     specialtests[ncnt].special_testing_id = st.special_testing_id,
     temp->products[d.seq].specialtests[ncnt].special_testing_cd = st.special_testing_cd, temp->
     products[d.seq].specialtests[ncnt].confirmed_ind = st.confirmed_ind, temp->products[d.seq].
     specialtests[ncnt].updt_cnt = st.updt_cnt,
     temp->products[d.seq].specialtests[ncnt].active_ind = st.active_ind, temp->products[d.seq].
     specialtests[ncnt].product_rh_phenotype_id = st.product_rh_phenotype_id, temp->products[d.seq].
     specialtests[ncnt].barcode_value = st.barcode_value_txt,
     temp->products[d.seq].specialtests[ncnt].modifiable_flag = st.modifiable_flag, temp->products[d
     .seq].specialtests[ncnt].special_isbt = bia.standard_display
    WITH nocounter
   ;end select
  ELSE
   SET product_not_found = 1
  ENDIF
 ELSEIF (trim(request->alternate_nbr) > "")
  SELECT
   IF (prodtypecnt > 0)
    FROM product pr,
     (dummyt d  WITH seq = value(prodtypecnt)),
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (d)
     JOIN (pr
     WHERE (pr.alternate_nbr=request->alternate_nbr)
      AND pr.active_ind=1
      AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ELSE
    FROM product pr,
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (pr
     WHERE (pr.alternate_nbr=request->alternate_nbr)
      AND pr.active_ind=1)
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ENDIF
   INTO "nl:"
   *
   HEAD REPORT
    stat = alterlist(temp->products,10)
   DETAIL
    ncnt += 1
    IF (mod(ncnt,10)=1
     AND ncnt != 1)
     stat = alterlist(temp->products,(ncnt+ 9))
    ENDIF
    temp->products[ncnt].product_id = pr.product_id, temp->products[ncnt].product_cd = pr.product_cd,
    temp->products[ncnt].product_cat_cd = pr.product_cat_cd,
    temp->products[ncnt].product_class_cd = pr.product_class_cd, temp->products[ncnt].product_nbr =
    pr.product_nbr, temp->products[ncnt].serial_number_txt = pr.serial_number_txt,
    temp->products[ncnt].product_sub_nbr = pr.product_sub_nbr, temp->products[ncnt].alternate_nbr =
    pr.alternate_nbr, temp->products[ncnt].flag_chars = pr.flag_chars,
    temp->products[ncnt].pooled_product_id = pr.pooled_product_id, temp->products[ncnt].
    modified_product_id = pr.modified_product_id, temp->products[ncnt].locked_ind = pr.locked_ind,
    temp->products[ncnt].cur_inv_locn_cd = pr.cur_inv_locn_cd, temp->products[ncnt].orig_inv_locn_cd
     = pr.orig_inv_locn_cd, temp->products[ncnt].cur_supplier_id = pr.cur_supplier_id,
    temp->products[ncnt].recv_dt_tm = pr.recv_dt_tm, temp->products[ncnt].recv_prsnl_id = pr
    .recv_prsnl_id, temp->products[ncnt].orig_ship_cond_cd = pr.orig_ship_cond_cd,
    temp->products[ncnt].orig_vis_insp_cd = pr.orig_vis_insp_cd, temp->products[ncnt].storage_temp_cd
     = pr.storage_temp_cd, temp->products[ncnt].cur_unit_meas_cd = pr.cur_unit_meas_cd,
    temp->products[ncnt].orig_unit_meas_cd = pr.orig_unit_meas_cd, temp->products[ncnt].
    pooled_product_ind = pr.pooled_product_ind, temp->products[ncnt].modified_product_ind = pr
    .modified_product_ind,
    temp->products[ncnt].corrected_ind = pr.corrected_ind, temp->products[ncnt].updt_cnt = pr
    .updt_cnt, temp->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
    temp->products[ncnt].updt_task = pr.updt_task, temp->products[ncnt].updt_applctx = pr
    .updt_applctx, temp->products[ncnt].updt_id = pr.updt_id,
    temp->products[ncnt].active_ind = pr.active_ind, temp->products[ncnt].cur_expire_dt_tm = pr
    .cur_expire_dt_tm, temp->products[ncnt].cur_owner_area_cd = pr.cur_owner_area_cd,
    temp->products[ncnt].cur_inv_area_cd = pr.cur_inv_area_cd, temp->products[ncnt].cur_inv_device_id
     = pr.cur_inv_device_id, temp->products[ncnt].cur_dispense_device_id = pr.cur_dispense_device_id,
    temp->products[ncnt].contributor_system_cd = pr.contributor_system_cd, temp->products[ncnt].
    pool_option_id = pr.pool_option_id, temp->products[ncnt].barcode_nbr = pr.barcode_nbr,
    temp->products[ncnt].create_dt_tm = pr.create_dt_tm, temp->products[ncnt].donated_by_relative_ind
     = pr.donated_by_relative_ind, temp->products[ncnt].disease_cd = pr.disease_cd,
    temp->products[ncnt].donation_type_cd = pr.donation_type_cd, temp->products[ncnt].
    electronic_entry_flag = pr.electronic_entry_flag, temp->products[ncnt].req_label_verify_ind = pr
    .req_label_verify_ind,
    temp->products[ncnt].cur_inv_org_id = l.organization_id, temp->products[ncnt].cur_inv_org_name =
    o.org_name, temp->products[ncnt].intended_use_print_parm_txt = pr.intended_use_print_parm_txt,
    temp->products[ncnt].product_type_barcode = pr.product_type_barcode, temp->products[ncnt].
    interface_product_id = pr.interface_product_id
    IF (pr.pooled_product_ind=1
     AND bmo.recon_rbc_ind=1)
     temp->products[ncnt].recon_type_flag = 1
    ELSE
     temp->products[ncnt].recon_type_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Select on product by alternate_nbr"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->products,ncnt)
  IF (size(temp->products,5) > 0)
   SET ncnt = 0
   SELECT INTO "nl:"
    *
    FROM special_testing st,
     (dummyt d  WITH seq = value(size(temp->products,5))),
     bb_isbt_attribute_r biar,
     bb_isbt_attribute bia
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=temp->products[d.seq].product_id))
     JOIN (biar
     WHERE (biar.attribute_cd= Outerjoin(st.special_testing_cd))
      AND (biar.active_ind= Outerjoin(1)) )
     JOIN (bia
     WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
      AND (bia.active_ind= Outerjoin(1)) )
    ORDER BY st.product_id
    HEAD st.product_id
     ncnt = 0
    DETAIL
     ncnt += 1, stat = alterlist(temp->products[d.seq].specialtests,ncnt), temp->products[d.seq].
     specialtests[ncnt].special_testing_id = st.special_testing_id,
     temp->products[d.seq].specialtests[ncnt].special_testing_cd = st.special_testing_cd, temp->
     products[d.seq].specialtests[ncnt].confirmed_ind = st.confirmed_ind, temp->products[d.seq].
     specialtests[ncnt].updt_cnt = st.updt_cnt,
     temp->products[d.seq].specialtests[ncnt].active_ind = st.active_ind, temp->products[d.seq].
     specialtests[ncnt].product_rh_phenotype_id = st.product_rh_phenotype_id, temp->products[d.seq].
     specialtests[ncnt].barcode_value = st.barcode_value_txt,
     temp->products[d.seq].specialtests[ncnt].modifiable_flag = st.modifiable_flag, temp->products[d
     .seq].specialtests[ncnt].special_isbt = bia.standard_display
    WITH nocounter
   ;end select
  ELSE
   SET product_not_found = 1
  ENDIF
 ELSEIF (size(request->productids,5) > 0)
  SELECT
   IF (prodtypecnt > 0)
    FROM product pr,
     (dummyt d  WITH seq = value(size(request->productids,5))),
     (dummyt d2  WITH seq = value(prodtypecnt)),
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (d)
     JOIN (pr
     WHERE (pr.product_id=request->productids[d.seq].product_id))
     JOIN (d2
     WHERE (pr.product_cd=request->validproducttypes[d2.seq].product_cd))
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ELSE
    FROM product pr,
     (dummyt d  WITH seq = value(size(request->productids,5))),
     location l,
     organization o,
     bb_mod_option bmo
    PLAN (d)
     JOIN (pr
     WHERE (pr.product_id=request->productids[d.seq].product_id))
     JOIN (bmo
     WHERE bmo.option_id=pr.pool_option_id)
     JOIN (l
     WHERE (l.location_cd= Outerjoin(pr.cur_inv_area_cd)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(l.organization_id)) )
   ENDIF
   INTO "nl:"
   *
   HEAD REPORT
    stat = alterlist(temp->products,10)
   DETAIL
    ncnt += 1
    IF (mod(ncnt,10)=1
     AND ncnt != 1)
     stat = alterlist(temp->products,(ncnt+ 9))
    ENDIF
    temp->products[ncnt].product_id = pr.product_id, temp->products[ncnt].product_cd = pr.product_cd,
    temp->products[ncnt].product_cat_cd = pr.product_cat_cd,
    temp->products[ncnt].product_class_cd = pr.product_class_cd, temp->products[ncnt].product_nbr =
    pr.product_nbr, temp->products[ncnt].serial_number_txt = pr.serial_number_txt,
    temp->products[ncnt].product_sub_nbr = pr.product_sub_nbr, temp->products[ncnt].alternate_nbr =
    pr.alternate_nbr, temp->products[ncnt].flag_chars = pr.flag_chars,
    temp->products[ncnt].pooled_product_id = pr.pooled_product_id, temp->products[ncnt].
    modified_product_id = pr.modified_product_id, temp->products[ncnt].locked_ind = pr.locked_ind,
    temp->products[ncnt].cur_inv_locn_cd = pr.cur_inv_locn_cd, temp->products[ncnt].orig_inv_locn_cd
     = pr.orig_inv_locn_cd, temp->products[ncnt].cur_supplier_id = pr.cur_supplier_id,
    temp->products[ncnt].recv_dt_tm = pr.recv_dt_tm, temp->products[ncnt].recv_prsnl_id = pr
    .recv_prsnl_id, temp->products[ncnt].orig_ship_cond_cd = pr.orig_ship_cond_cd,
    temp->products[ncnt].orig_vis_insp_cd = pr.orig_vis_insp_cd, temp->products[ncnt].storage_temp_cd
     = pr.storage_temp_cd, temp->products[ncnt].cur_unit_meas_cd = pr.cur_unit_meas_cd,
    temp->products[ncnt].orig_unit_meas_cd = pr.orig_unit_meas_cd, temp->products[ncnt].
    pooled_product_ind = pr.pooled_product_ind, temp->products[ncnt].modified_product_ind = pr
    .modified_product_ind,
    temp->products[ncnt].corrected_ind = pr.corrected_ind, temp->products[ncnt].updt_cnt = pr
    .updt_cnt, temp->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
    temp->products[ncnt].updt_task = pr.updt_task, temp->products[ncnt].updt_applctx = pr
    .updt_applctx, temp->products[ncnt].updt_id = pr.updt_id,
    temp->products[ncnt].active_ind = pr.active_ind, temp->products[ncnt].cur_expire_dt_tm = pr
    .cur_expire_dt_tm, temp->products[ncnt].cur_owner_area_cd = pr.cur_owner_area_cd,
    temp->products[ncnt].cur_inv_area_cd = pr.cur_inv_area_cd, temp->products[ncnt].cur_inv_device_id
     = pr.cur_inv_device_id, temp->products[ncnt].cur_dispense_device_id = pr.cur_dispense_device_id,
    temp->products[ncnt].contributor_system_cd = pr.contributor_system_cd, temp->products[ncnt].
    pool_option_id = pr.pool_option_id, temp->products[ncnt].barcode_nbr = pr.barcode_nbr,
    temp->products[ncnt].create_dt_tm = pr.create_dt_tm, temp->products[ncnt].donated_by_relative_ind
     = pr.donated_by_relative_ind, temp->products[ncnt].disease_cd = pr.disease_cd,
    temp->products[ncnt].donation_type_cd = pr.donation_type_cd, temp->products[ncnt].
    electronic_entry_flag = pr.electronic_entry_flag, temp->products[ncnt].req_label_verify_ind = pr
    .req_label_verify_ind,
    temp->products[ncnt].cur_inv_org_id = l.organization_id, temp->products[ncnt].cur_inv_org_name =
    o.org_name, temp->products[ncnt].intended_use_print_parm_txt = pr.intended_use_print_parm_txt,
    temp->products[ncnt].product_type_barcode = pr.product_type_barcode, temp->products[ncnt].
    interface_product_id = pr.interface_product_id
    IF (pr.pooled_product_ind=1
     AND bmo.recon_rbc_ind=1)
     temp->products[ncnt].recon_type_flag = 1
    ELSE
     temp->products[ncnt].recon_type_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Select on product by product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->products,ncnt)
  IF (size(temp->products,5) > 0)
   SET ncnt = 0
   SELECT INTO "nl:"
    *
    FROM special_testing st,
     (dummyt d  WITH seq = value(size(temp->products,5))),
     bb_isbt_attribute_r biar,
     bb_isbt_attribute bia
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=temp->products[d.seq].product_id))
     JOIN (biar
     WHERE (biar.attribute_cd= Outerjoin(st.special_testing_cd))
      AND (biar.active_ind= Outerjoin(1)) )
     JOIN (bia
     WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
      AND (bia.active_ind= Outerjoin(1)) )
    ORDER BY st.product_id
    HEAD st.product_id
     ncnt = 0
    DETAIL
     ncnt += 1, stat = alterlist(temp->products[d.seq].specialtests,ncnt), temp->products[d.seq].
     specialtests[ncnt].special_testing_id = st.special_testing_id,
     temp->products[d.seq].specialtests[ncnt].special_testing_cd = st.special_testing_cd, temp->
     products[d.seq].specialtests[ncnt].confirmed_ind = st.confirmed_ind, temp->products[d.seq].
     specialtests[ncnt].updt_cnt = st.updt_cnt,
     temp->products[d.seq].specialtests[ncnt].active_ind = st.active_ind, temp->products[d.seq].
     specialtests[ncnt].product_rh_phenotype_id = st.product_rh_phenotype_id, temp->products[d.seq].
     specialtests[ncnt].barcode_value = st.barcode_value_txt,
     temp->products[d.seq].specialtests[ncnt].modifiable_flag = st.modifiable_flag, temp->products[d
     .seq].specialtests[ncnt].special_isbt = bia.standard_display
    WITH nocounter
   ;end select
  ELSE
   SET product_not_found = 1
  ENDIF
 ENDIF
 IF (size(temp->products,5)=0)
  GO TO check_history
 ENDIF
 SET ncnt = 0
 SELECT INTO "nl:"
  *
  FROM derivative de,
   (dummyt d1  WITH seq = value(size(temp->products,5))),
   organization o
  PLAN (d1)
   JOIN (de
   WHERE (temp->products[d1.seq].product_id=de.product_id)
    AND ((de.active_ind=1) OR (de.active_ind=active_cond)) )
   JOIN (o
   WHERE (de.manufacturer_id= Outerjoin(o.organization_id)) )
  DETAIL
   temp->products[d1.seq].derivatives.product_cd = de.product_cd, temp->products[d1.seq].derivatives.
   item_volume = de.item_volume, temp->products[d1.seq].derivatives.item_unit_meas_cd = de
   .item_unit_meas_cd,
   temp->products[d1.seq].derivatives.updt_cnt = de.updt_cnt, temp->products[d1.seq].derivatives.
   active_ind = de.active_ind, temp->products[d1.seq].derivatives.manufacturer_id = de
   .manufacturer_id,
   temp->products[d1.seq].derivatives.manufacturer_disp = o.org_name, temp->products[d1.seq].
   derivatives.cur_avail_qty = de.cur_avail_qty, temp->products[d1.seq].derivatives.cur_intl_units =
   de.cur_intl_units,
   temp->products[d1.seq].derivatives.units_per_vial = de.units_per_vial, temp->products[d1.seq].
   class_flag = 2
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select on derivative by product_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 SET ncnt = 0
 SELECT INTO "nl:"
  *
  FROM blood_product bp,
   (dummyt d2  WITH seq = value(size(temp->products,5)))
  PLAN (d2)
   JOIN (bp
   WHERE (temp->products[d2.seq].product_id=bp.product_id)
    AND ((bp.active_ind=1) OR (bp.active_ind=active_cond)) )
  DETAIL
   temp->products[d2.seq].bloodproducts.product_cd = bp.product_cd, temp->products[d2.seq].
   bloodproducts.supplier_prefix = bp.supplier_prefix, temp->products[d2.seq].bloodproducts.
   cur_volume = bp.cur_volume,
   temp->products[d2.seq].bloodproducts.orig_label_abo_cd = bp.orig_label_abo_cd, temp->products[d2
   .seq].bloodproducts.orig_label_rh_cd = bp.orig_label_rh_cd, temp->products[d2.seq].bloodproducts.
   cur_abo_cd = bp.cur_abo_cd,
   temp->products[d2.seq].bloodproducts.cur_rh_cd = bp.cur_rh_cd, temp->products[d2.seq].
   bloodproducts.segment_nbr = bp.segment_nbr, temp->products[d2.seq].bloodproducts.orig_expire_dt_tm
    = bp.orig_expire_dt_tm,
   temp->products[d2.seq].bloodproducts.orig_volume = bp.orig_volume, temp->products[d2.seq].
   bloodproducts.lot_nbr = bp.lot_nbr, temp->products[d2.seq].bloodproducts.autologous_ind = bp
   .autologous_ind,
   temp->products[d2.seq].bloodproducts.directed_ind = bp.directed_ind, temp->products[d2.seq].
   bloodproducts.drawn_dt_tm = bp.drawn_dt_tm, temp->products[d2.seq].bloodproducts.updt_cnt = bp
   .updt_cnt,
   temp->products[d2.seq].bloodproducts.active_ind = bp.active_ind, temp->products[d2.seq].
   bloodproducts.donor_person_id = bp.donor_person_id, temp->products[d2.seq].class_flag = 1
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select on blood_product by product_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM product_note pn,
   long_text lt,
   (dummyt d2  WITH seq = value(size(temp->products,5)))
  PLAN (d2)
   JOIN (pn
   WHERE (temp->products[d2.seq].product_id=pn.product_id)
    AND pn.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=pn.long_text_id
    AND lt.active_ind=1)
  DETAIL
   temp->products[d2.seq].product_note_ind = 1, temp->products[d2.seq].productnote.product_note_id =
   pn.product_note_id, temp->products[d2.seq].productnote.updt_cnt = pn.updt_cnt,
   temp->products[d2.seq].productnote.long_text_id = lt.long_text_id, temp->products[d2.seq].
   productnote.long_text_updt_cnt = lt.updt_cnt, temp->products[d2.seq].productnote.product_note = lt
   .long_text
  WITH nocounter
 ;end select
 SET ncnt = 0
 SET ncnt2 = 0
 SELECT INTO "nl:"
  *
  FROM product_event pe,
   (dummyt d  WITH seq = value(size(temp->products,5))),
   accession_order_r aor,
   location l,
   organization o
  PLAN (d)
   JOIN (pe
   WHERE (pe.product_id=temp->products[d.seq].product_id)
    AND ((pe.active_ind=1) OR ((request->retrieve_inactive_events_ind=1))) )
   JOIN (aor
   WHERE (aor.order_id= Outerjoin(pe.order_id))
    AND (aor.primary_flag= Outerjoin(0)) )
   JOIN (l
   WHERE (l.location_cd= Outerjoin(pe.inventory_area_cd)) )
   JOIN (o
   WHERE (o.organization_id= Outerjoin(l.organization_id)) )
  ORDER BY pe.product_id
  HEAD pe.product_id
   ncnt2 = 0, stat = alterlist(temp->products[d.seq].productevents,5)
  DETAIL
   ncnt2 += 1
   IF (mod(ncnt2,5)=1
    AND ncnt2 != 1)
    stat = alterlist(temp->products[d.seq].productevents,(ncnt2+ 4))
   ENDIF
   temp->products[d.seq].productevents[ncnt2].product_event_id = pe.product_event_id, temp->products[
   d.seq].productevents[ncnt2].product_id = pe.product_id, temp->products[d.seq].productevents[ncnt2]
   .order_id = pe.order_id,
   temp->products[d.seq].productevents[ncnt2].bb_result_id = pe.bb_result_id, temp->products[d.seq].
   productevents[ncnt2].event_type_cd = pe.event_type_cd, temp->products[d.seq].productevents[ncnt2].
   event_dt_tm = pe.event_dt_tm,
   temp->products[d.seq].productevents[ncnt2].event_prsnl_id = pe.event_prsnl_id, temp->products[d
   .seq].productevents[ncnt2].updt_cnt = pe.updt_cnt, temp->products[d.seq].productevents[ncnt2].
   active_ind = pe.active_ind,
   temp->products[d.seq].productevents[ncnt2].person_id = pe.person_id, temp->products[d.seq].
   productevents[ncnt2].encntr_id = pe.encntr_id, temp->products[d.seq].productevents[ncnt2].
   override_ind = pe.override_ind,
   temp->products[d.seq].productevents[ncnt2].override_reason_cd = pe.override_reason_cd, temp->
   products[d.seq].productevents[ncnt2].related_product_event_id = pe.related_product_event_id, temp
   ->products[d.seq].productevents[ncnt2].event_status_flag = pe.event_status_flag,
   temp->products[d.seq].productevents[ncnt2].owner_area_cd = pe.owner_area_cd, temp->products[d.seq]
   .productevents[ncnt2].inventory_area_cd = pe.inventory_area_cd, temp->products[d.seq].
   productevents[ncnt2].organization_id = o.organization_id,
   temp->products[d.seq].productevents[ncnt2].accession = cnvtacc(aor.accession), temp->products[d
   .seq].productevents[ncnt2].organization_name = o.org_name
  FOOT  pe.product_id
   stat = alterlist(temp->products[d.seq].productevents,ncnt2)
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select on product_event by product_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 IF (size(request->validproductevents,5) > 0)
  FOR (i = 1 TO size(temp->products,5))
    SET event_not_found = 0
    FOR (j = 1 TO size(temp->products[i].productevents,5))
      SET valid_event_found = 0
      FOR (k = 1 TO size(request->validproductevents,5))
        IF ((temp->products[i].productevents[j].event_type_cd=request->validproductevents[k].
        event_type_cd))
         SET valid_event_found = 1
        ENDIF
      ENDFOR
      IF (valid_event_found=0)
       SET event_not_found = 1
      ENDIF
    ENDFOR
    IF (event_not_found=0)
     SET temp->products[i].product_ok = 1
    ENDIF
  ENDFOR
 ELSE
  FOR (i = 1 TO size(temp->products,5))
    SET temp->products[i].product_ok = 1
  ENDFOR
 ENDIF
 SET ncnt = 0
 SET stat = alterlist(reply->products,5)
 FOR (i = 1 TO size(temp->products,5))
   IF ((temp->products[i].product_ok=1))
    SET ncnt += 1
    IF (mod(ncnt,5)=1
     AND ncnt != 1)
     SET stat = alterlist(reply->products,(ncnt+ 4))
    ENDIF
    SET reply->products[ncnt].product_id = temp->products[i].product_id
    SET reply->products[ncnt].product_cd = temp->products[i].product_cd
    SET reply->products[ncnt].product_cat_cd = temp->products[i].product_cat_cd
    SET reply->products[ncnt].product_class_cd = temp->products[i].product_class_cd
    SET reply->products[ncnt].product_nbr = temp->products[i].product_nbr
    SET reply->products[ncnt].product_sub_nbr = temp->products[i].product_sub_nbr
    SET reply->products[ncnt].alternate_nbr = temp->products[i].alternate_nbr
    SET reply->products[ncnt].flag_chars = temp->products[i].flag_chars
    SET reply->products[ncnt].pooled_product_id = temp->products[i].pooled_product_id
    SET reply->products[ncnt].modified_product_id = temp->products[i].modified_product_id
    SET reply->products[ncnt].locked_ind = temp->products[i].locked_ind
    SET reply->products[ncnt].cur_inv_locn_cd = temp->products[i].cur_inv_locn_cd
    SET reply->products[ncnt].orig_inv_locn_cd = temp->products[i].orig_inv_locn_cd
    SET reply->products[ncnt].cur_supplier_id = temp->products[i].cur_supplier_id
    SET reply->products[ncnt].recv_dt_tm = temp->products[i].recv_dt_tm
    SET reply->products[ncnt].recv_prsnl_id = temp->products[i].recv_prsnl_id
    SET reply->products[ncnt].orig_ship_cond_cd = temp->products[i].orig_ship_cond_cd
    SET reply->products[ncnt].orig_vis_insp_cd = temp->products[i].orig_vis_insp_cd
    SET reply->products[ncnt].storage_temp_cd = temp->products[i].storage_temp_cd
    SET reply->products[ncnt].cur_unit_meas_cd = temp->products[i].cur_unit_meas_cd
    SET reply->products[ncnt].orig_unit_meas_cd = temp->products[i].orig_unit_meas_cd
    SET reply->products[ncnt].pooled_product_ind = temp->products[i].pooled_product_ind
    SET reply->products[ncnt].modified_product_ind = temp->products[i].modified_product_ind
    SET reply->products[ncnt].corrected_ind = temp->products[i].corrected_ind
    SET reply->products[ncnt].updt_cnt = temp->products[i].updt_cnt
    SET reply->products[ncnt].updt_dt_tm = temp->products[i].updt_dt_tm
    SET reply->products[ncnt].updt_task = temp->products[i].updt_task
    SET reply->products[ncnt].updt_applctx = temp->products[i].updt_applctx
    SET reply->products[ncnt].updt_id = temp->products[i].updt_id
    SET reply->products[ncnt].active_ind = temp->products[i].active_ind
    SET reply->products[ncnt].cur_expire_dt_tm = temp->products[i].cur_expire_dt_tm
    SET reply->products[ncnt].cur_owner_area_cd = temp->products[i].cur_owner_area_cd
    SET reply->products[ncnt].cur_inv_area_cd = temp->products[i].cur_inv_area_cd
    SET reply->products[ncnt].cur_inv_device_id = temp->products[i].cur_inv_device_id
    SET reply->products[ncnt].cur_dispense_device_id = temp->products[i].cur_dispense_device_id
    SET reply->products[ncnt].contributor_system_cd = temp->products[i].contributor_system_cd
    SET reply->products[ncnt].pool_option_id = temp->products[i].pool_option_id
    SET reply->products[ncnt].barcode_nbr = temp->products[i].barcode_nbr
    SET reply->products[ncnt].create_dt_tm = temp->products[i].create_dt_tm
    SET reply->products[ncnt].donated_by_relative_ind = temp->products[i].donated_by_relative_ind
    SET reply->products[ncnt].disease_cd = temp->products[i].disease_cd
    SET reply->products[ncnt].donation_type_cd = temp->products[i].donation_type_cd
    SET reply->products[ncnt].electronic_entry_flag = temp->products[i].electronic_entry_flag
    SET reply->products[ncnt].req_label_verify_ind = temp->products[i].req_label_verify_ind
    SET reply->products[ncnt].cur_inv_org_id = temp->products[i].cur_inv_org_id
    SET reply->products[ncnt].cur_inv_org_name = temp->products[i].cur_inv_org_name
    SET reply->products[ncnt].intended_use_print_parm_txt = temp->products[i].
    intended_use_print_parm_txt
    SET reply->products[ncnt].recon_type_flag = temp->products[i].recon_type_flag
    SET reply->products[ncnt].class_flag = temp->products[i].class_flag
    SET reply->products[ncnt].product_note_ind = temp->products[i].product_note_ind
    SET reply->products[ncnt].product_type_barcode = temp->products[i].product_type_barcode
    SET reply->products[ncnt].serial_number_txt = temp->products[i].serial_number_txt
    SET reply->products[ncnt].interface_product_id = temp->products[i].interface_product_id
    SET reply->products[ncnt].derivatives.product_cd = temp->products[i].derivatives.product_cd
    SET reply->products[ncnt].derivatives.item_volume = temp->products[i].derivatives.item_volume
    SET reply->products[ncnt].derivatives.item_unit_meas_cd = temp->products[i].derivatives.
    item_unit_meas_cd
    SET reply->products[ncnt].derivatives.updt_cnt = temp->products[i].derivatives.updt_cnt
    SET reply->products[ncnt].derivatives.active_ind = temp->products[i].derivatives.active_ind
    SET reply->products[ncnt].derivatives.manufacturer_id = temp->products[i].derivatives.
    manufacturer_id
    SET reply->products[ncnt].derivatives.manufacturer_disp = temp->products[i].derivatives.
    manufacturer_disp
    SET reply->products[ncnt].derivatives.cur_avail_qty = temp->products[i].derivatives.cur_avail_qty
    SET reply->products[ncnt].derivatives.cur_intl_units = temp->products[i].derivatives.
    cur_intl_units
    SET reply->products[ncnt].derivatives.units_per_vial = temp->products[i].derivatives.
    units_per_vial
    SET reply->products[ncnt].bloodproducts.product_cd = temp->products[i].bloodproducts.product_cd
    SET reply->products[ncnt].bloodproducts.supplier_prefix = temp->products[i].bloodproducts.
    supplier_prefix
    SET reply->products[ncnt].bloodproducts.cur_volume = temp->products[i].bloodproducts.cur_volume
    SET reply->products[ncnt].bloodproducts.orig_label_abo_cd = temp->products[i].bloodproducts.
    orig_label_abo_cd
    SET reply->products[ncnt].bloodproducts.orig_label_rh_cd = temp->products[i].bloodproducts.
    orig_label_rh_cd
    SET reply->products[ncnt].bloodproducts.cur_abo_cd = temp->products[i].bloodproducts.cur_abo_cd
    SET reply->products[ncnt].bloodproducts.cur_rh_cd = temp->products[i].bloodproducts.cur_rh_cd
    SET reply->products[ncnt].bloodproducts.segment_nbr = temp->products[i].bloodproducts.segment_nbr
    SET reply->products[ncnt].bloodproducts.orig_expire_dt_tm = temp->products[i].bloodproducts.
    orig_expire_dt_tm
    SET reply->products[ncnt].bloodproducts.orig_volume = temp->products[i].bloodproducts.orig_volume
    SET reply->products[ncnt].bloodproducts.lot_nbr = temp->products[i].bloodproducts.lot_nbr
    SET reply->products[ncnt].bloodproducts.autologous_ind = temp->products[i].bloodproducts.
    autologous_ind
    SET reply->products[ncnt].bloodproducts.directed_ind = temp->products[i].bloodproducts.
    directed_ind
    SET reply->products[ncnt].bloodproducts.drawn_dt_tm = temp->products[i].bloodproducts.drawn_dt_tm
    SET reply->products[ncnt].bloodproducts.updt_cnt = temp->products[i].bloodproducts.updt_cnt
    SET reply->products[ncnt].bloodproducts.active_ind = temp->products[i].bloodproducts.active_ind
    SET reply->products[ncnt].bloodproducts.donor_person_id = temp->products[i].bloodproducts.
    donor_person_id
    SET reply->products[ncnt].productnote.product_note_id = temp->products[i].productnote.
    product_note_id
    SET reply->products[ncnt].productnote.updt_cnt = temp->products[i].productnote.updt_cnt
    SET reply->products[ncnt].productnote.long_text_id = temp->products[i].productnote.long_text_id
    SET reply->products[ncnt].productnote.long_text_updt_cnt = temp->products[i].productnote.
    long_text_updt_cnt
    SET reply->products[ncnt].productnote.product_note = temp->products[i].productnote.product_note
    SET stat = alterlist(reply->products[ncnt].specialtests,size(temp->products[i].specialtests,5))
    SET ncnt2 = 0
    FOR (j = 1 TO size(temp->products[i].specialtests,5))
      SET ncnt2 += 1
      SET reply->products[ncnt].specialtests[ncnt2].special_testing_id = temp->products[i].
      specialtests[j].special_testing_id
      SET reply->products[ncnt].specialtests[ncnt2].special_testing_cd = temp->products[i].
      specialtests[j].special_testing_cd
      SET reply->products[ncnt].specialtests[ncnt2].confirmed_ind = temp->products[i].specialtests[j]
      .confirmed_ind
      SET reply->products[ncnt].specialtests[ncnt2].updt_cnt = temp->products[i].specialtests[j].
      updt_cnt
      SET reply->products[ncnt].specialtests[ncnt2].active_ind = temp->products[i].specialtests[j].
      active_ind
      SET reply->products[ncnt].specialtests[ncnt2].product_rh_phenotype_id = temp->products[i].
      specialtests[j].product_rh_phenotype_id
      SET reply->products[ncnt].specialtests[ncnt2].barcode_value = temp->products[i].specialtests[j]
      .barcode_value
      SET reply->products[ncnt].specialtests[ncnt2].modifiable_flag = temp->products[i].specialtests[
      j].modifiable_flag
      SET reply->products[ncnt].specialtests[ncnt2].special_isbt = temp->products[i].specialtests[j].
      special_isbt
    ENDFOR
   ENDIF
   IF (size(request->returnproductevents,5) > 0)
    SET ncnt2 = 0
    FOR (j = 1 TO size(temp->products[i].productevents,5))
      FOR (k = 1 TO size(request->returnproductevents,5))
        IF ((temp->products[i].productevents[j].event_type_cd=request->returnproductevents[k].
        event_type_cd))
         SET ncnt2 += 1
         SET stat = alterlist(reply->products[ncnt].productevents,ncnt2)
         SET reply->products[ncnt].productevents[ncnt2].product_event_id = temp->products[i].
         productevents[j].product_event_id
         SET reply->products[ncnt].productevents[ncnt2].product_id = temp->products[i].productevents[
         j].product_id
         SET reply->products[ncnt].productevents[ncnt2].order_id = temp->products[i].productevents[j]
         .order_id
         SET reply->products[ncnt].productevents[ncnt2].bb_result_id = temp->products[i].
         productevents[j].bb_result_id
         SET reply->products[ncnt].productevents[ncnt2].event_type_cd = temp->products[i].
         productevents[j].event_type_cd
         SET reply->products[ncnt].productevents[ncnt2].event_dt_tm = temp->products[i].
         productevents[j].event_dt_tm
         SET reply->products[ncnt].productevents[ncnt2].event_prsnl_id = temp->products[i].
         productevents[j].event_prsnl_id
         SET reply->products[ncnt].productevents[ncnt2].updt_cnt = temp->products[i].productevents[j]
         .updt_cnt
         SET reply->products[ncnt].productevents[ncnt2].active_ind = temp->products[i].productevents[
         j].active_ind
         SET reply->products[ncnt].productevents[ncnt2].person_id = temp->products[i].productevents[j
         ].person_id
         SET reply->products[ncnt].productevents[ncnt2].encntr_id = temp->products[i].productevents[j
         ].encntr_id
         SET reply->products[ncnt].productevents[ncnt2].override_ind = temp->products[i].
         productevents[j].override_ind
         SET reply->products[ncnt].productevents[ncnt2].override_reason_cd = temp->products[i].
         productevents[j].override_reason_cd
         SET reply->products[ncnt].productevents[ncnt2].event_status_flag = temp->products[i].
         productevents[j].event_status_flag
         SET reply->products[ncnt].productevents[ncnt2].accession = temp->products[i].productevents[j
         ].accession
         SET reply->products[ncnt].productevents[ncnt2].owner_area_cd = temp->products[i].
         productevents[j].owner_area_cd
         SET reply->products[ncnt].productevents[ncnt2].inventory_area_cd = temp->products[i].
         productevents[j].inventory_area_cd
         SET reply->products[ncnt].productevents[ncnt2].organization_id = temp->products[i].
         productevents[j].organization_id
         SET reply->products[ncnt].productevents[ncnt2].organization_name = temp->products[i].
         productevents[j].organization_name
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    SET stat = alterlist(reply->products[ncnt].productevents,size(temp->products[i].productevents,5))
    FOR (j = 1 TO size(temp->products[i].productevents,5))
      SET reply->products[ncnt].productevents[j].product_event_id = temp->products[i].productevents[j
      ].product_event_id
      SET reply->products[ncnt].productevents[j].product_id = temp->products[i].productevents[j].
      product_id
      SET reply->products[ncnt].productevents[j].order_id = temp->products[i].productevents[j].
      order_id
      SET reply->products[ncnt].productevents[j].bb_result_id = temp->products[i].productevents[j].
      bb_result_id
      SET reply->products[ncnt].productevents[j].event_type_cd = temp->products[i].productevents[j].
      event_type_cd
      SET reply->products[ncnt].productevents[j].event_dt_tm = temp->products[i].productevents[j].
      event_dt_tm
      SET reply->products[ncnt].productevents[j].event_prsnl_id = temp->products[i].productevents[j].
      event_prsnl_id
      SET reply->products[ncnt].productevents[j].updt_cnt = temp->products[i].productevents[j].
      updt_cnt
      SET reply->products[ncnt].productevents[j].active_ind = temp->products[i].productevents[j].
      active_ind
      SET reply->products[ncnt].productevents[j].person_id = temp->products[i].productevents[j].
      person_id
      SET reply->products[ncnt].productevents[j].encntr_id = temp->products[i].productevents[j].
      encntr_id
      SET reply->products[ncnt].productevents[j].override_ind = temp->products[i].productevents[j].
      override_ind
      SET reply->products[ncnt].productevents[j].override_reason_cd = temp->products[i].
      productevents[j].override_reason_cd
      SET reply->products[ncnt].productevents[j].event_status_flag = temp->products[i].productevents[
      j].event_status_flag
      SET reply->products[ncnt].productevents[j].accession = temp->products[i].productevents[j].
      accession
      SET reply->products[ncnt].productevents[j].owner_area_cd = temp->products[i].productevents[j].
      owner_area_cd
      SET reply->products[ncnt].productevents[j].inventory_area_cd = temp->products[i].productevents[
      j].inventory_area_cd
      SET reply->products[ncnt].productevents[j].organization_id = temp->products[i].productevents[j]
      .organization_id
      SET reply->products[ncnt].productevents[j].organization_name = temp->products[i].productevents[
      j].organization_name
    ENDFOR
   ENDIF
   SET ncnt2 = 0
 ENDFOR
 SET stat = alterlist(reply->products,ncnt)
 IF (size(reply->products,5)=0)
  SET product_not_valid = 1
  GO TO exit_script
 ENDIF
 SET event_mean = fillstring(12," ")
 FOR (i = 1 TO size(reply->products,5))
   FOR (j = 1 TO size(reply->products[i].productevents,5))
    SET event_mean = uar_get_code_meaning(reply->products[i].productevents[j].event_type_cd)
    IF (event_mean="5")
     SELECT INTO "nl:"
      *
      FROM disposition di
      WHERE (reply->products[i].productevents[j].product_event_id=di.product_event_id)
      DETAIL
       reply->products[i].productevents[j].disposition.disposed_intl_units = di.disposed_intl_units,
       reply->products[i].productevents[j].disposition.reason_cd = di.reason_cd, reply->products[i].
       productevents[j].disposition.disposed_qty = di.disposed_qty,
       reply->products[i].productevents[j].disposition.updt_cnt = di.updt_cnt, reply->products[i].
       productevents[j].disposition.active_ind = di.active_ind, reply->products[i].productevents[j].
       di_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on disposition by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="2")
     SELECT INTO "nl:"
      *
      FROM quarantine qu
      WHERE (reply->products[i].productevents[j].product_event_id=qu.product_event_id)
      DETAIL
       reply->products[i].productevents[j].quarantine.quar_reason_cd = qu.quar_reason_cd, reply->
       products[i].productevents[j].quarantine.updt_cnt = qu.updt_cnt, reply->products[i].
       productevents[j].quarantine.active_ind = qu.active_ind,
       reply->products[i].productevents[j].quarantine.orig_quar_qty = qu.orig_quar_qty, reply->
       products[i].productevents[j].quarantine.cur_quar_qty = qu.cur_quar_qty, reply->products[i].
       productevents[j].quarantine.orig_quar_intl_units = qu.orig_quar_intl_units,
       reply->products[i].productevents[j].quarantine.cur_quar_intl_units = qu.cur_quar_intl_units,
       reply->products[i].productevents[j].qu_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on quarantine by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
     IF ((reply->products[i].productevents[j].active_ind=0))
      SELECT INTO "nl:"
       *
       FROM quarantine_release qr
       WHERE (reply->products[i].productevents[j].product_event_id=qr.product_event_id)
       DETAIL
        reply->products[i].productevents[j].quarantinerelease.quar_release_id = qr.quar_release_id,
        reply->products[i].productevents[j].quarantinerelease.release_dt_tm = qr.release_dt_tm, reply
        ->products[i].productevents[j].quarantinerelease.release_prsnl_id = qr.release_prsnl_id,
        reply->products[i].productevents[j].quarantinerelease.release_reason_cd = qr
        .release_reason_cd, reply->products[i].productevents[j].quarantinerelease.release_qty = qr
        .release_qty, reply->products[i].productevents[j].quarantinerelease.updt_cnt = qr.updt_cnt,
        reply->products[i].productevents[j].quarantinerelease.active_ind = qr.active_ind, reply->
        products[i].productevents[j].quarantinerelease.release_intl_units = qr.release_intl_units,
        reply->products[i].productevents[j].qr_ind = 1
       WITH nocounter
      ;end select
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname =
       "Select on quarantine_release by product_event_id"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF (((event_mean="10") OR (event_mean="11")) )
     SELECT INTO "nl:"
      *
      FROM auto_directed ad,
       person p,
       encntr_alias ea,
       person_aborh pa
      PLAN (ad
       WHERE (reply->products[i].productevents[j].product_event_id=ad.product_event_id))
       JOIN (p
       WHERE ad.person_id=p.person_id)
       JOIN (ea
       WHERE (ea.encntr_id= Outerjoin(ad.encntr_id))
        AND (ea.encntr_alias_type_cd= Outerjoin(dmrntypecd))
        AND (ea.active_ind= Outerjoin(1)) )
       JOIN (pa
       WHERE (pa.person_id= Outerjoin(p.person_id))
        AND (pa.active_ind= Outerjoin(1)) )
      DETAIL
       reply->products[i].productevents[j].autodirected.person_id = ad.person_id, reply->products[i].
       productevents[j].autodirected.associated_dt_tm = ad.associated_dt_tm, reply->products[i].
       productevents[j].autodirected.updt_cnt = ad.updt_cnt,
       reply->products[i].productevents[j].autodirected.active_ind = ad.active_ind, reply->products[i
       ].productevents[j].autodirected.encntr_id = ad.encntr_id, reply->products[i].productevents[j].
       autodirected.expected_usage_dt_tm = ad.expected_usage_dt_tm,
       reply->products[i].productevents[j].autodirected.donated_by_relative_ind = ad
       .donated_by_relative_ind, reply->products[i].productevents[j].autodirected.name_full_formatted
        = p.name_full_formatted, reply->products[i].productevents[j].autodirected.mrn_alias = ea
       .alias,
       reply->products[i].productevents[j].autodirected.abo_cd = pa.abo_cd, reply->products[i].
       productevents[j].autodirected.rh_cd = pa.rh_cd, reply->products[i].productevents[j].ad_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on auto_directed by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="8")
     SELECT INTO "nl:"
      *
      FROM modification mo
      WHERE (reply->products[i].productevents[j].product_event_id=mo.product_event_id)
      DETAIL
       reply->products[i].productevents[j].modification.orig_expire_dt_tm = mo.orig_expire_dt_tm,
       reply->products[i].productevents[j].modification.orig_volume = mo.orig_volume, reply->
       products[i].productevents[j].modification.orig_unit_meas_cd = mo.orig_unit_meas_cd,
       reply->products[i].productevents[j].modification.cur_expire_dt_tm = mo.cur_expire_dt_tm, reply
       ->products[i].productevents[j].modification.cur_volume = mo.cur_volume, reply->products[i].
       productevents[j].modification.cur_unit_meas_cd = mo.cur_unit_meas_cd,
       reply->products[i].productevents[j].modification.modified_qty = mo.modified_qty, reply->
       products[i].productevents[j].modification.updt_cnt = mo.updt_cnt, reply->products[i].
       productevents[j].modification.active_ind = mo.active_ind,
       reply->products[i].productevents[j].modification.crossover_reason_cd = mo.crossover_reason_cd,
       reply->products[i].productevents[j].modification.option_id = mo.option_id, reply->products[i].
       productevents[j].modification.device_type_cd = mo.device_type_cd,
       reply->products[i].productevents[j].modification.accessory = mo.accessory, reply->products[i].
       productevents[j].modification.lot_nbr = mo.lot_nbr, reply->products[i].productevents[j].
       modification.start_dt_tm = cnvtdatetime(mo.start_dt_tm),
       reply->products[i].productevents[j].modification.stop_dt_tm = cnvtdatetime(mo.stop_dt_tm),
       reply->products[i].productevents[j].modification.vis_insp_cd = mo.vis_insp_cd, reply->
       products[i].productevents[j].mo_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on modification by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="17")
     SELECT INTO "nl:"
      *
      FROM modification mo
      WHERE (reply->products[i].productevents[j].product_event_id=mo.product_event_id)
      DETAIL
       reply->products[i].productevents[j].modification.orig_expire_dt_tm = mo.orig_expire_dt_tm,
       reply->products[i].productevents[j].modification.orig_volume = mo.orig_volume, reply->
       products[i].productevents[j].modification.orig_unit_meas_cd = mo.orig_unit_meas_cd,
       reply->products[i].productevents[j].modification.cur_expire_dt_tm = mo.cur_expire_dt_tm, reply
       ->products[i].productevents[j].modification.cur_volume = mo.cur_volume, reply->products[i].
       productevents[j].modification.cur_unit_meas_cd = mo.cur_unit_meas_cd,
       reply->products[i].productevents[j].modification.modified_qty = mo.modified_qty, reply->
       products[i].productevents[j].modification.updt_cnt = mo.updt_cnt, reply->products[i].
       productevents[j].modification.active_ind = mo.active_ind,
       reply->products[i].productevents[j].modification.crossover_reason_cd = mo.crossover_reason_cd,
       reply->products[i].productevents[j].modification.option_id = mo.option_id, reply->products[i].
       productevents[j].modification.device_type_cd = mo.device_type_cd,
       reply->products[i].productevents[j].modification.accessory = mo.accessory, reply->products[i].
       productevents[j].modification.lot_nbr = mo.lot_nbr, reply->products[i].productevents[j].
       modification.start_dt_tm = cnvtdatetime(mo.start_dt_tm),
       reply->products[i].productevents[j].modification.stop_dt_tm = cnvtdatetime(mo.stop_dt_tm),
       reply->products[i].productevents[j].modification.vis_insp_cd = mo.vis_insp_cd, reply->
       products[i].productevents[j].mo_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on modification by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="1")
     SELECT INTO "nl:"
      *
      FROM assign a,
       person p
      PLAN (a
       WHERE (reply->products[i].productevents[j].product_event_id=a.product_event_id))
       JOIN (p
       WHERE a.person_id=p.person_id)
      DETAIL
       reply->products[i].productevents[j].assign.assign_reason_cd = a.assign_reason_cd, reply->
       products[i].productevents[j].assign.person_id = a.person_id, reply->products[i].productevents[
       j].assign.prov_id = a.prov_id,
       reply->products[i].productevents[j].assign.updt_cnt = a.updt_cnt, reply->products[i].
       productevents[j].assign.active_ind = a.active_ind, reply->products[i].productevents[j].assign.
       orig_assign_qty = a.orig_assign_qty,
       reply->products[i].productevents[j].assign.cur_assign_qty = a.cur_assign_qty, reply->products[
       i].productevents[j].assign.orig_assign_intl_units = a.orig_assign_intl_units, reply->products[
       i].productevents[j].assign.cur_assign_intl_units = a.cur_assign_intl_units,
       reply->products[i].productevents[j].assign.name_full_formatted = p.name_full_formatted, reply
       ->products[i].productevents[j].as_ind = 1, reply->products[i].productevents[j].assign.
       bb_id_nbr = a.bb_id_nbr
      WITH nocounter
     ;end select
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "S"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
     IF ((reply->products[i].productevents[j].active_ind=0))
      SELECT INTO "nl:"
       *
       FROM assign_release ar
       WHERE (reply->products[i].productevents[j].product_event_id=ar.product_event_id)
       DETAIL
        reply->products[i].productevents[j].assignrelease.assign_release_id = ar.assign_release_id,
        reply->products[i].productevents[j].assignrelease.product_event_id = ar.product_event_id,
        reply->products[i].productevents[j].assignrelease.product_id = ar.product_id,
        reply->products[i].productevents[j].assignrelease.release_dt_tm = ar.release_dt_tm, reply->
        products[i].productevents[j].assignrelease.release_prsnl_id = ar.release_prsnl_id, reply->
        products[i].productevents[j].assignrelease.release_reason_cd = ar.release_reason_cd,
        reply->products[i].productevents[j].assignrelease.release_qty = ar.release_qty, reply->
        products[i].productevents[j].assignrelease.updt_cnt = ar.updt_cnt, reply->products[i].
        productevents[j].assignrelease.active_ind = ar.active_ind,
        reply->products[i].productevents[j].assignrelease.release_intl_units = ar.release_intl_units,
        reply->products[i].productevents[j].ar_ind = 1
       WITH nocounter
      ;end select
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname =
       "Select on assign_release by product_event_id"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF (event_mean="7")
     SELECT INTO "nl:"
      *
      FROM transfusion tf,
       person p
      PLAN (tf
       WHERE (reply->products[i].productevents[j].product_event_id=tf.product_event_id))
       JOIN (p
       WHERE tf.person_id=p.person_id)
      DETAIL
       reply->products[i].productevents[j].transfusion.person_id = tf.person_id, reply->products[i].
       productevents[j].transfusion.name_full_formatted = p.name_full_formatted, reply->products[i].
       productevents[j].transfusion.transfused_intl_units = tf.transfused_intl_units,
       reply->products[i].productevents[j].transfusion.bag_returned_ind = tf.bag_returned_ind, reply
       ->products[i].productevents[j].transfusion.tag_returned_ind = tf.tag_returned_ind, reply->
       products[i].productevents[j].transfusion.transfused_vol = tf.transfused_vol,
       reply->products[i].productevents[j].transfusion.updt_cnt = tf.updt_cnt, reply->products[i].
       productevents[j].transfusion.active_ind = tf.active_ind, reply->products[i].productevents[j].
       transfusion.orig_transfused_qty = tf.orig_transfused_qty,
       reply->products[i].productevents[j].transfusion.cur_transfused_qty = tf.cur_transfused_qty,
       reply->products[i].productevents[j].tf_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on transfusion by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="14")
     SELECT INTO "nl:"
      *
      FROM destruction dn
      WHERE (reply->products[i].productevents[j].product_event_id=dn.product_event_id)
      DETAIL
       reply->products[i].productevents[j].destruction.method_cd = dn.method_cd, reply->products[i].
       productevents[j].destruction.box_nbr = dn.box_nbr, reply->products[i].productevents[j].
       destruction.manifest_nbr = dn.manifest_nbr,
       reply->products[i].productevents[j].destruction.destroyed_qty = dn.destroyed_qty, reply->
       products[i].productevents[j].destruction.autoclave_ind = dn.autoclave_ind, reply->products[i].
       productevents[j].destruction.destruction_org_id = dn.destruction_org_id,
       reply->products[i].productevents[j].destruction.updt_cnt = dn.updt_cnt, reply->products[i].
       productevents[j].destruction.active_ind = dn.active_ind, reply->products[i].productevents[j].
       dn_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on destruction by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="19")
     SELECT INTO "nl:"
      *
      FROM abo_testing at
      WHERE (reply->products[i].productevents[j].product_event_id=at.product_event_id)
      DETAIL
       reply->products[i].productevents[j].abotesting.product_id = at.product_id, reply->products[i].
       productevents[j].abotesting.result_id = at.result_id, reply->products[i].productevents[j].
       abotesting.abo_group_cd = at.abo_group_cd,
       reply->products[i].productevents[j].abotesting.rh_type_cd = at.rh_type_cd, reply->products[i].
       productevents[j].abotesting.current_updated_ind = at.current_updated_ind, reply->products[i].
       productevents[j].abotesting.updt_cnt = at.updt_cnt,
       reply->products[i].productevents[j].abotesting.active_ind = at.active_ind, reply->products[i].
       productevents[j].abotesting.abo_testing_id = at.abo_testing_id, reply->products[i].
       productevents[j].at_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on abo_testing by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="6")
     SELECT INTO "nl:"
      *
      FROM transfer tr
      WHERE (reply->products[i].productevents[j].product_event_id=tr.product_event_id)
      DETAIL
       reply->products[i].productevents[j].transfer.transferring_locn_cd = tr.transferring_locn_cd,
       reply->products[i].productevents[j].transfer.transfer_cond_cd = tr.transfer_cond_cd, reply->
       products[i].productevents[j].transfer.transfer_reason_cd = tr.transfer_reason_cd,
       reply->products[i].productevents[j].transfer.transfer_vis_insp_cd = tr.transfer_vis_insp_cd,
       reply->products[i].productevents[j].transfer.transfer_qty = tr.transfer_qty, reply->products[i
       ].productevents[j].transfer.login_dt_tm = tr.login_dt_tm,
       reply->products[i].productevents[j].transfer.login_prsnl_id = tr.login_prsnl_id, reply->
       products[i].productevents[j].transfer.login_cond_cd = tr.login_cond_cd, reply->products[i].
       productevents[j].transfer.login_vis_insp_cd = tr.login_vis_insp_cd,
       reply->products[i].productevents[j].transfer.login_qty = tr.login_qty, reply->products[i].
       productevents[j].transfer.return_dt_tm = tr.return_dt_tm, reply->products[i].productevents[j].
       transfer.return_prsnl_id = tr.return_prsnl_id,
       reply->products[i].productevents[j].transfer.return_reason_cd = tr.return_reason_cd, reply->
       products[i].productevents[j].transfer.return_cond_cd = tr.return_cond_cd, reply->products[i].
       productevents[j].transfer.return_vis_insp_cd = tr.return_vis_insp_cd,
       reply->products[i].productevents[j].transfer.return_qty = tr.return_qty, reply->products[i].
       productevents[j].transfer.updt_cnt = tr.updt_cnt, reply->products[i].productevents[j].transfer
       .active_ind = tr.active_ind,
       reply->products[i].productevents[j].tr_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on transfer by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      *
      FROM bb_device_transfer bd
      WHERE (reply->products[i].productevents[j].product_event_id=bd.product_event_id)
      DETAIL
       reply->products[i].productevents[j].bbdevicetransfer.from_device_id = bd.from_device_id, reply
       ->products[i].productevents[j].bbdevicetransfer.to_device_id = bd.to_device_id, reply->
       products[i].productevents[j].bbdevicetransfer.reason_cd = bd.reason_cd,
       reply->products[i].productevents[j].bbdevicetransfer.updt_cnt = bd.updt_cnt, reply->products[i
       ].productevents[j].bd_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on bb_device_transfer by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      *
      FROM bb_inventory_transfer bit
      WHERE (reply->products[i].productevents[j].product_event_id=bit.product_event_id)
      DETAIL
       reply->products[i].productevents[j].bbinventorytransfer.from_owner_area_cd = bit
       .from_owner_area_cd, reply->products[i].productevents[j].bbinventorytransfer.from_inv_area_cd
        = bit.from_inv_area_cd, reply->products[i].productevents[j].bbinventorytransfer.
       to_owner_area_cd = bit.to_owner_area_cd,
       reply->products[i].productevents[j].bbinventorytransfer.to_inv_area_cd = bit.to_inv_area_cd,
       reply->products[i].productevents[j].bbinventorytransfer.transfer_reason_cd = bit
       .transfer_reason_cd, reply->products[i].productevents[j].bbinventorytransfer.updt_cnt = bit
       .updt_cnt,
       reply->products[i].productevents[j].bbinventorytransfer.transferred_qty = bit.transferred_qty,
       reply->products[i].productevents[j].bbinventorytransfer.transferred_iu = bit
       .transferred_intl_unit, reply->products[i].productevents[j].bbinventorytransfer.
       to_product_event_id = bit.to_product_event_id,
       reply->products[i].productevents[j].bbinventorytransfer.event_type_cd = bit.event_type_cd,
       reply->products[i].productevents[j].bi_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on bb_inventory_transfer by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="3")
     SELECT INTO "nl:"
      *
      FROM crossmatch xm,
       person p
      PLAN (xm
       WHERE (reply->products[i].productevents[j].product_event_id=xm.product_event_id))
       JOIN (p
       WHERE xm.person_id=p.person_id)
      DETAIL
       reply->products[i].productevents[j].crossmatch.crossmatch_qty = xm.crossmatch_qty, reply->
       products[i].productevents[j].crossmatch.release_dt_tm = xm.release_dt_tm, reply->products[i].
       productevents[j].crossmatch.release_prsnl_id = xm.release_prsnl_id,
       reply->products[i].productevents[j].crossmatch.release_reason_cd = xm.release_reason_cd, reply
       ->products[i].productevents[j].crossmatch.release_qty = xm.release_qty, reply->products[i].
       productevents[j].crossmatch.updt_cnt = xm.updt_cnt,
       reply->products[i].productevents[j].crossmatch.active_ind = xm.active_ind, reply->products[i].
       productevents[j].crossmatch.crossmatch_exp_dt_tm = xm.crossmatch_exp_dt_tm, reply->products[i]
       .productevents[j].crossmatch.reinstate_reason_cd = xm.reinstate_reason_cd,
       reply->products[i].productevents[j].crossmatch.bb_id_nbr = xm.bb_id_nbr, reply->products[i].
       productevents[j].crossmatch.xm_reason_cd = xm.xm_reason_cd, reply->products[i].productevents[j
       ].crossmatch.person_id = xm.person_id,
       reply->products[i].productevents[j].crossmatch.name_full_formatted = p.name_full_formatted,
       reply->products[i].productevents[j].xm_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on crossmatch by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ELSEIF (event_mean="4")
     SELECT INTO "nl:"
      *
      FROM patient_dispense pd,
       person p
      PLAN (pd
       WHERE (reply->products[i].productevents[j].product_event_id=pd.product_event_id))
       JOIN (p
       WHERE pd.person_id=p.person_id)
      DETAIL
       reply->products[i].productevents[j].patientdispense.person_id = pd.person_id, reply->products[
       i].productevents[j].patientdispense.name_full_formatted = p.name_full_formatted, reply->
       products[i].productevents[j].patientdispense.dispense_prov_id = pd.dispense_prov_id,
       reply->products[i].productevents[j].patientdispense.dispense_reason_cd = pd.dispense_reason_cd,
       reply->products[i].productevents[j].patientdispense.dispense_to_locn_cd = pd
       .dispense_to_locn_cd, reply->products[i].productevents[j].patientdispense.
       dispense_from_locn_cd = pd.dispense_from_locn_cd,
       reply->products[i].productevents[j].patientdispense.device_id = pd.device_id, reply->products[
       i].productevents[j].patientdispense.dispense_vis_insp_cd = pd.dispense_vis_insp_cd, reply->
       products[i].productevents[j].patientdispense.dispense_cooler_id = pd.dispense_cooler_id,
       reply->products[i].productevents[j].patientdispense.dispense_cooler_text = pd
       .dispense_cooler_text, reply->products[i].productevents[j].patientdispense.dispense_courier_id
        = pd.dispense_courier_id, reply->products[i].productevents[j].patientdispense.
       dispense_status_flag = pd.dispense_status_flag,
       reply->products[i].productevents[j].patientdispense.orig_dispense_intl_units = pd
       .orig_dispense_intl_units, reply->products[i].productevents[j].patientdispense.
       cur_dispense_intl_units = pd.cur_dispense_intl_units, reply->products[i].productevents[j].
       patientdispense.orig_dispense_qty = pd.orig_dispense_qty,
       reply->products[i].productevents[j].patientdispense.cur_dispense_qty = pd.cur_dispense_qty,
       reply->products[i].productevents[j].patientdispense.unknown_patient_ind = pd
       .unknown_patient_ind, reply->products[i].productevents[j].patientdispense.unknown_patient_text
        = pd.unknown_patient_text,
       reply->products[i].productevents[j].patientdispense.updt_cnt = pd.updt_cnt, reply->products[i]
       .productevents[j].patientdispense.active_ind = pd.active_ind, reply->products[i].
       productevents[j].patientdispense.dispense_courier_text = pd.dispense_courier_text,
       reply->products[i].productevents[j].patientdispense.bb_id_nbr = pd.bb_id_nbr, reply->products[
       i].productevents[j].pd_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on patient_dispense by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
     IF ((reply->products[i].productevents[j].active_ind=0))
      SELECT INTO "nl:"
       *
       FROM dispense_return dr
       WHERE (reply->products[i].productevents[j].product_event_id=dr.product_event_id)
       DETAIL
        reply->products[i].productevents[j].dispensereturn.dispense_return_id = dr.dispense_return_id,
        reply->products[i].productevents[j].dispensereturn.return_dt_tm = dr.return_dt_tm, reply->
        products[i].productevents[j].dispensereturn.return_prsnl_id = dr.return_prsnl_id,
        reply->products[i].productevents[j].dispensereturn.return_reason_cd = dr.return_reason_cd,
        reply->products[i].productevents[j].dispensereturn.return_vis_insp_cd = dr.return_vis_insp_cd,
        reply->products[i].productevents[j].dispensereturn.return_courier_id = dr.return_courier_id,
        reply->products[i].productevents[j].dispensereturn.return_qty = dr.return_qty, reply->
        products[i].productevents[j].dispensereturn.return_intl_units = dr.return_intl_units, reply->
        products[i].productevents[j].dispensereturn.updt_cnt = dr.updt_cnt,
        reply->products[i].productevents[j].dispensereturn.active_ind = dr.active_ind, reply->
        products[i].productevents[j].dispensereturn.return_courier_text = dr.return_courier_text,
        reply->products[i].productevents[j].dr_ind = 1
       WITH nocounter
      ;end select
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname =
       "Select on dispense_return by product_event_id"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF (event_mean="13")
     SELECT INTO "nl:"
      *
      FROM receipt re
      WHERE (reply->products[i].productevents[j].product_event_id=re.product_event_id)
      DETAIL
       reply->products[i].productevents[j].receipt.active_ind = re.active_ind, reply->products[i].
       productevents[j].receipt.ship_cond_cd = re.ship_cond_cd, reply->products[i].productevents[j].
       receipt.vis_insp_cd = re.vis_insp_cd,
       reply->products[i].productevents[j].receipt.orig_rcvd_qty = re.orig_rcvd_qty, reply->products[
       i].productevents[j].receipt.orig_intl_units = re.orig_intl_units, reply->products[i].
       productevents[j].receipt.updt_cnt = re.updt_cnt,
       reply->products[i].productevents[j].receipt.bb_supplier_id = re.bb_supplier_id, reply->
       products[i].productevents[j].receipt.alpha_translation_id = re.alpha_translation_id, reply->
       products[i].productevents[j].receipt.temperature_value = re.temperature_value,
       reply->products[i].productevents[j].receipt.temperature_degree_cd = re.temperature_degree_cd,
       reply->products[i].productevents[j].re_ind = 1
      WITH nocounter
     ;end select
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Select on receipt by product_event_id"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 SET serror_check = error(serrormsg,0)
#check_history
 SET ncnt = size(reply->products,5)
 IF ((request->search_history_ind=1))
  IF (trim(request->translated_product_nbr) > "")
   SELECT
    IF (prodtypecnt > 0)
     FROM bbhist_product pr,
      (dummyt d  WITH seq = value(prodtypecnt))
     PLAN (d)
      JOIN (pr
      WHERE ((pr.product_nbr=trim(request->translated_product_nbr)) OR (pr.product_nbr=trim(request->
       untranslated_product_nbr)))
       AND pr.active_ind=1
       AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
    ELSE
     FROM bbhist_product pr
     WHERE ((pr.product_nbr=trim(request->translated_product_nbr)) OR (pr.product_nbr=trim(request->
      untranslated_product_nbr)))
      AND pr.active_ind=1
    ENDIF
    INTO "nl:"
    class_mean = uar_get_code_meaning(pr.product_class_cd)
    HEAD REPORT
     stat = alterlist(reply->products,(ncnt+ 10))
    DETAIL
     ncnt += 1
     IF (mod(ncnt,10)=1)
      stat = alterlist(reply->products,(ncnt+ 9))
     ENDIF
     reply->products[ncnt].product_id = pr.product_id, reply->products[ncnt].product_cd = pr
     .product_cd, reply->products[ncnt].product_nbr = pr.product_nbr,
     reply->products[ncnt].product_sub_nbr = pr.product_sub_nbr, reply->products[ncnt].
     product_class_cd = pr.product_class_cd, reply->products[ncnt].alternate_nbr = pr.alternate_nbr,
     reply->products[ncnt].pooled_product_id = pr.pooled_product_id, reply->products[ncnt].
     modified_product_id = pr.modified_product_id, reply->products[ncnt].cur_supplier_id = pr
     .supplier_id,
     reply->products[ncnt].cur_unit_meas_cd = pr.unit_meas_cd, reply->products[ncnt].
     pooled_product_ind = pr.pooled_product_ind, reply->products[ncnt].modified_product_ind = pr
     .modified_product_ind,
     reply->products[ncnt].updt_cnt = pr.updt_cnt, reply->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
     reply->products[ncnt].updt_task = pr.updt_task,
     reply->products[ncnt].updt_applctx = pr.updt_applctx, reply->products[ncnt].updt_id = pr.updt_id,
     reply->products[ncnt].active_ind = pr.active_ind,
     reply->products[ncnt].cur_owner_area_cd = pr.owner_area_cd, reply->products[ncnt].
     cur_inv_area_cd = pr.inv_area_cd, reply->products[ncnt].contributor_system_cd = pr
     .contributor_system_cd,
     reply->products[ncnt].cur_expire_dt_tm = pr.expire_dt_tm, reply->products[ncnt].
     req_label_verify_ind = 0, reply->products[ncnt].cur_inv_org_id = 0.0,
     reply->products[ncnt].bloodproducts.cur_abo_cd = pr.abo_cd, reply->products[ncnt].bloodproducts.
     cur_rh_cd = pr.rh_cd, reply->products[ncnt].bloodproducts.supplier_prefix = pr.supplier_prefix,
     reply->products[ncnt].bloodproducts.cur_volume = pr.volume
     IF (class_mean=productclass_mean_blood)
      reply->products[ncnt].class_flag = 1
     ELSEIF (class_mean=productclass_mean_derivative)
      reply->products[ncnt].class_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product by product_nbr - 1"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->products,ncnt)
   IF (size(reply->products,5) > 1)
    SET mult_return = 1
   ENDIF
  ELSEIF (trim(request->untranslated_product_nbr) > "")
   SELECT
    IF (prodtypecnt > 0)
     FROM bbhist_product pr,
      (dummyt d  WITH seq = value(prodtypecnt))
     PLAN (d)
      JOIN (pr
      WHERE pr.product_nbr=trim(request->untranslated_product_nbr)
       AND pr.active_ind=1
       AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
    ELSE
     FROM bbhist_product pr
     WHERE pr.product_nbr=trim(request->untranslated_product_nbr)
      AND pr.active_ind=1
    ENDIF
    INTO "nl:"
    class_mean = uar_get_code_meaning(pr.product_class_cd)
    HEAD REPORT
     stat = alterlist(reply->products,(ncnt+ 10))
    DETAIL
     ncnt += 1
     IF (mod(ncnt,10)=1)
      stat = alterlist(reply->products,(ncnt+ 9))
     ENDIF
     reply->products[ncnt].product_id = pr.product_id, reply->products[ncnt].product_cd = pr
     .product_cd, reply->products[ncnt].product_nbr = pr.product_nbr,
     reply->products[ncnt].product_sub_nbr = pr.product_sub_nbr, reply->products[ncnt].
     product_class_cd = pr.product_class_cd, reply->products[ncnt].alternate_nbr = pr.alternate_nbr,
     reply->products[ncnt].pooled_product_id = pr.pooled_product_id, reply->products[ncnt].
     modified_product_id = pr.modified_product_id, reply->products[ncnt].cur_supplier_id = pr
     .supplier_id,
     reply->products[ncnt].cur_unit_meas_cd = pr.unit_meas_cd, reply->products[ncnt].
     pooled_product_ind = pr.pooled_product_ind, reply->products[ncnt].modified_product_ind = pr
     .modified_product_ind,
     reply->products[ncnt].updt_cnt = pr.updt_cnt, reply->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
     reply->products[ncnt].updt_task = pr.updt_task,
     reply->products[ncnt].updt_applctx = pr.updt_applctx, reply->products[ncnt].updt_id = pr.updt_id,
     reply->products[ncnt].active_ind = pr.active_ind,
     reply->products[ncnt].cur_owner_area_cd = pr.owner_area_cd, reply->products[ncnt].
     cur_inv_area_cd = pr.inv_area_cd, reply->products[ncnt].contributor_system_cd = pr
     .contributor_system_cd,
     reply->products[ncnt].cur_expire_dt_tm = pr.expire_dt_tm, reply->products[ncnt].
     req_label_verify_ind = 0, reply->products[ncnt].cur_inv_org_id = 0.0,
     reply->products[ncnt].bloodproducts.cur_abo_cd = pr.abo_cd, reply->products[ncnt].bloodproducts.
     cur_rh_cd = pr.rh_cd, reply->products[ncnt].bloodproducts.supplier_prefix = pr.supplier_prefix,
     reply->products[ncnt].bloodproducts.cur_volume = pr.volume
     IF (class_mean=productclass_mean_blood)
      reply->products[ncnt].class_flag = 1
     ELSEIF (class_mean=productclass_mean_derivative)
      reply->products[ncnt].class_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product by product_nbr - 2"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->products,ncnt)
   IF (size(reply->products,5) > 1)
    SET mult_return = 1
   ENDIF
  ELSEIF (trim(request->alternate_nbr) > "")
   SELECT
    IF (prodtypecnt > 0)
     FROM bbhist_product pr,
      (dummyt d  WITH seq = value(prodtypecnt))
     PLAN (d)
      JOIN (pr
      WHERE (pr.alternate_nbr=request->alternate_nbr)
       AND pr.active_ind=1
       AND (pr.product_cd=request->validproducttypes[d.seq].product_cd))
    ELSE
     FROM bbhist_product pr
     WHERE (pr.alternate_nbr=request->alternate_nbr)
      AND pr.active_ind=1
    ENDIF
    INTO "nl:"
    class_mean = uar_get_code_meaning(pr.product_class_cd)
    HEAD REPORT
     stat = alterlist(reply->products,(ncnt+ 10))
    DETAIL
     ncnt += 1
     IF (mod(ncnt,10)=1)
      stat = alterlist(reply->products,(ncnt+ 9))
     ENDIF
     reply->products[ncnt].product_id = pr.product_id, reply->products[ncnt].product_cd = pr
     .product_cd, reply->products[ncnt].product_nbr = pr.product_nbr,
     reply->products[ncnt].product_sub_nbr = pr.product_sub_nbr, reply->products[ncnt].
     product_class_cd = pr.product_class_cd, reply->products[ncnt].alternate_nbr = pr.alternate_nbr,
     reply->products[ncnt].pooled_product_id = pr.pooled_product_id, reply->products[ncnt].
     modified_product_id = pr.modified_product_id, reply->products[ncnt].cur_supplier_id = pr
     .supplier_id,
     reply->products[ncnt].cur_unit_meas_cd = pr.unit_meas_cd, reply->products[ncnt].
     pooled_product_ind = pr.pooled_product_ind, reply->products[ncnt].modified_product_ind = pr
     .modified_product_ind,
     reply->products[ncnt].updt_cnt = pr.updt_cnt, reply->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
     reply->products[ncnt].updt_task = pr.updt_task,
     reply->products[ncnt].updt_applctx = pr.updt_applctx, reply->products[ncnt].updt_id = pr.updt_id,
     reply->products[ncnt].active_ind = pr.active_ind,
     reply->products[ncnt].cur_owner_area_cd = pr.owner_area_cd, reply->products[ncnt].
     cur_inv_area_cd = pr.inv_area_cd, reply->products[ncnt].contributor_system_cd = pr
     .contributor_system_cd,
     reply->products[ncnt].cur_expire_dt_tm = pr.expire_dt_tm, reply->products[ncnt].
     req_label_verify_ind = 0, reply->products[ncnt].cur_inv_org_id = 0.0,
     reply->products[ncnt].bloodproducts.cur_abo_cd = pr.abo_cd, reply->products[ncnt].bloodproducts.
     cur_rh_cd = pr.rh_cd, reply->products[ncnt].bloodproducts.supplier_prefix = pr.supplier_prefix,
     reply->products[ncnt].bloodproducts.cur_volume = pr.volume
     IF (class_mean=productclass_mean_blood)
      reply->products[ncnt].class_flag = 1
     ELSEIF (class_mean=productclass_mean_derivative)
      reply->products[ncnt].class_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product by alternate_nbr"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->products,ncnt)
   IF (size(reply->products,5) > 1)
    SET mult_return = 1
   ENDIF
  ELSEIF (size(request->productids,5) > 0)
   SELECT
    IF (prodtypecnt > 0)
     FROM bbhist_product pr,
      (dummyt d  WITH seq = value(size(request->productids,5))),
      (dummyt d2  WITH seq = value(prodtypecnt))
     PLAN (d)
      JOIN (pr
      WHERE (pr.product_id=request->productids[d.seq].product_id))
      JOIN (d2
      WHERE (pr.product_cd=request->validproducttypes[d2.seq].product_cd))
    ELSE
     FROM bbhist_product pr,
      (dummyt d  WITH seq = value(size(request->productids,5)))
     PLAN (d)
      JOIN (pr
      WHERE (pr.product_id=request->productids[d.seq].product_id))
    ENDIF
    INTO "nl:"
    class_mean = uar_get_code_meaning(pr.product_class_cd)
    HEAD REPORT
     stat = alterlist(reply->products,(ncnt+ 10))
    DETAIL
     ncnt += 1
     IF (mod(ncnt,10)=1)
      stat = alterlist(reply->products,(ncnt+ 9))
     ENDIF
     reply->products[ncnt].product_id = pr.product_id, reply->products[ncnt].product_cd = pr
     .product_cd, reply->products[ncnt].product_nbr = pr.product_nbr,
     reply->products[ncnt].product_sub_nbr = pr.product_sub_nbr, reply->products[ncnt].
     product_class_cd = pr.product_class_cd, reply->products[ncnt].alternate_nbr = pr.alternate_nbr,
     reply->products[ncnt].pooled_product_id = pr.pooled_product_id, reply->products[ncnt].
     modified_product_id = pr.modified_product_id, reply->products[ncnt].cur_supplier_id = pr
     .supplier_id,
     reply->products[ncnt].cur_unit_meas_cd = pr.unit_meas_cd, reply->products[ncnt].
     pooled_product_ind = pr.pooled_product_ind, reply->products[ncnt].modified_product_ind = pr
     .modified_product_ind,
     reply->products[ncnt].updt_cnt = pr.updt_cnt, reply->products[ncnt].updt_dt_tm = pr.updt_dt_tm,
     reply->products[ncnt].updt_task = pr.updt_task,
     reply->products[ncnt].updt_applctx = pr.updt_applctx, reply->products[ncnt].updt_id = pr.updt_id,
     reply->products[ncnt].active_ind = pr.active_ind,
     reply->products[ncnt].cur_owner_area_cd = pr.owner_area_cd, reply->products[ncnt].
     cur_inv_area_cd = pr.inv_area_cd, reply->products[ncnt].contributor_system_cd = pr
     .contributor_system_cd,
     reply->products[ncnt].cur_expire_dt_tm = pr.expire_dt_tm, reply->products[ncnt].
     req_label_verify_ind = 0, reply->products[ncnt].cur_inv_org_id = 0.0,
     reply->products[ncnt].bloodproducts.cur_abo_cd = pr.abo_cd, reply->products[ncnt].bloodproducts.
     cur_rh_cd = pr.rh_cd, reply->products[ncnt].bloodproducts.supplier_prefix = pr.supplier_prefix,
     reply->products[ncnt].bloodproducts.cur_volume = pr.volume
     IF (class_mean=productclass_mean_blood)
      reply->products[ncnt].class_flag = 1
     ELSEIF (class_mean=productclass_mean_derivative)
      reply->products[ncnt].class_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product by product_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->products,ncnt)
  ENDIF
  SET ncnt2 = 0
  SELECT INTO "nl:"
   *
   FROM bbhist_product_event pe,
    (dummyt d  WITH seq = value(size(reply->products,5)))
   PLAN (d)
    JOIN (pe
    WHERE (pe.product_id=reply->products[d.seq].product_id)
     AND ((pe.active_ind=1) OR ((request->retrieve_inactive_events_ind=1))) )
   ORDER BY pe.product_id
   HEAD pe.product_id
    ncnt2 = 0, stat = alterlist(reply->products[d.seq].productevents,5)
   DETAIL
    ncnt2 += 1
    IF (mod(ncnt2,5)=1
     AND ncnt2 != 1)
     stat = alterlist(reply->products[d.seq].productevents,(ncnt2+ 4))
    ENDIF
    reply->products[d.seq].productevents[ncnt2].product_event_id = pe.product_event_id, reply->
    products[d.seq].productevents[ncnt2].product_id = pe.product_id, reply->products[d.seq].
    productevents[ncnt2].event_type_cd = pe.event_type_cd,
    reply->products[d.seq].productevents[ncnt2].event_dt_tm = pe.event_dt_tm, reply->products[d.seq].
    productevents[ncnt2].event_prsnl_id = pe.prsnl_id, reply->products[d.seq].productevents[ncnt2].
    updt_cnt = pe.updt_cnt,
    reply->products[d.seq].productevents[ncnt2].active_ind = pe.active_ind, reply->products[d.seq].
    productevents[ncnt2].person_id = pe.person_id, reply->products[d.seq].productevents[ncnt2].
    encntr_id = pe.encntr_id
   FOOT  pe.product_id
    stat = alterlist(reply->products[d.seq].productevents,ncnt2)
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_product.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Select on bbhist_product_event by product_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (serror_check=0)
  IF (size(reply->products,5) > 0
   AND (reply->status_data.status != "F"))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname =
   "F - Not Found | V - Not Valid | U - Unknown"
   IF (product_not_found)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSEIF (product_not_valid)
    SET reply->status_data.subeventstatus[1].operationstatus = "V"
   ELSE
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
END GO
