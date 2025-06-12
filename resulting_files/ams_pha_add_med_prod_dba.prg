CREATE PROGRAM ams_pha_add_med_prod:dba
 PROMPT
  "Select the directory and type the file name below:" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD request
 RECORD request(
   1 item_group_active_ind = i2
   1 item1_id = f8
   1 item2_id = f8
   1 tag1 = f8
   1 cost1 = f8
   1 cost2 = f8
   1 awp = f8
   1 nbr_packs_to_chg = i4
   1 nbr_packs_to_add = i4
   1 id_type_cd = f8
   1 prep_into_flag = i4
   1 catalog_type_disp = vc
   1 iv_ingredient_ind = i2
   1 gcr_desc = vc
   1 package_type_id = f8
   1 order_alert1_cd = f8
   1 order_alert2_cd = f8
   1 side_effect_code = c10
   1 primary_manf_item_id = f8
   1 nbr_ids_to_add = i4
   1 comment1_text = vc
   1 comment2_text = vc
   1 compound_text = vc
   1 countable_ind = i2
   1 fda_reportable_ind = i2
   1 active_status_cd = f8
   1 shelf_life = i4
   1 shelf_life_uom_cd = f8
   1 component_usage_ind = i2
   1 component_ind = i2
   1 quickadd_ind = i2
   1 approved_ind = i2
   1 item_type_cd = f8
   1 db_rec_status = i2
   1 prod_rec_status = i2
   1 manf_rec_status = i2
   1 prod_id_rec_status = i2
   1 oc_rec_status = i2
   1 sent_rec_status = i2
   1 pack_rec_status = i2
   1 meddefqual[*]
     2 gfc_description = vc
     2 active_status_cd = f8
     2 updt_cnt = i4
     2 db_rec_status = i2
     2 med_type_flag = i2
     2 item_id = f8
     2 mdx_gfc_nomen_id = f8
     2 form_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 given_strength = c25
     2 meq_factor = f8
     2 mmol_factor = f8
     2 compound_text_id = f8
     2 compound_text = vc
     2 comment1_text = vc
     2 comment2_text = vc
     2 comment1_id = f8
     2 comment2_id = f8
     2 cki = c255
     2 schedulable_ind = i2
     2 reusable_ind = i2
     2 cdm = vc
     2 critical_ind = i2
     2 sub_account_cd = f8
     2 cost_center_cd = f8
     2 storage_requirement_cd = f8
     2 sterilization_required_ind = i2
     2 base_issue_factor = f8
     2 active_ind = i2
     2 package_type_id = f8
     2 template_catalog_cd = f8
     2 template_synonym_id = f8
     2 primary_synonym_mnemonic = vc
     2 locqual[*]
       3 location_cd = f8
     2 pack[*]
       3 db_rec_status = i2
       3 item_id = f8
       3 package_type_id = f8
       3 description = c40
       3 uom_cd = f8
       3 base_uom_cd = f8
       3 qty = f8
       3 base_package_type_ind = i2
       3 active_ind = i2
       3 updt_cnt = i4
     2 ordcat[*]
       3 prep_into_flag = i4
       3 db_rec_status = i2
       3 catalog_cd = f8
       3 consent_form_ind = i2
       3 active_ind = i2
       3 catalog_type_cd = f8
       3 catalog_type_disp = vc
       3 activity_type_cd = f8
       3 activity_subtype_cd = f8
       3 requisition_format_cd = f8
       3 requisition_routing_cd = f8
       3 inst_restriction_ind = i2
       3 schedule_ind = i2
       3 description = vc
       3 iv_ingredient_ind = i2
       3 print_req_ind = i2
       3 oe_format_id = f8
       3 orderable_type_flag = i2
       3 complete_upon_order_ind = i2
       3 quick_chart_ind = i2
       3 comment_template_flag = i2
       3 prep_info_flag = i2
       3 updt_cnt = i4
       3 valid_iv_additive_ind = i2
       3 dc_display_days = i4
       3 dc_interaction_days = i4
       3 op_dc_display_days = i4
       3 op_dc_interaction_days = i4
       3 set_op_days = i2
       3 mdx_gcr_nomen_id = f8
       3 cki = vc
       3 gcr_desc = vc
       3 ahfs_qual[*]
         4 ahfs_code = c6
       3 qual_mnemonic[*]
         4 db_rec_status = i2
         4 item_id = f8
         4 synonym_id = f8
         4 mnemonic = vc
         4 mnemonic_type_cd = f8
         4 synonym_cki = vc
         4 active_ind = i2
         4 order_sentence_id = f8
         4 orderable_type_flag = i2
         4 updt_cnt = i4
     2 meddefflexqual[*]
       3 db_rec_status = i2
       3 med_def_flex_id = f8
       3 parent_entity_id = f8
       3 parent_entity = c32
       3 sequence = i4
       3 flex_type_cd = f8
       3 flex_sort_flag = i4
       3 pharmacy_type_cd = f8
       3 parent_med_def_flex_id = f8
       3 package_type_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 pack[*]
         4 db_rec_status = i2
         4 item_id = f8
         4 package_type_id = f8
         4 description = c40
         4 uom_cd = f8
         4 base_uom_cd = f8
         4 qty = f8
         4 base_package_type_ind = i2
         4 active_ind = i2
         4 updt_cnt = i4
       3 medidentifierqual[*]
         4 salable_by_vendor_ind = i2
         4 salable_by_mfr_ind = i2
         4 id_type_cd = f8
         4 db_rec_status = i2
         4 package_type_id = f8
         4 med_def_flex_id = f8
         4 flex_sort_flag = i4
         4 med_identifier_id = f8
         4 order_set_id = f8
         4 item_id = f8
         4 med_product_id = f8
         4 sequence = i4
         4 pharmacy_type_cd = f8
         4 parent_entity_id = f8
         4 parent_entity = c32
         4 flex_type_cd = f8
         4 med_identifier_type_cd = f8
         4 value = c200
         4 value_key = c200
         4 med_type_flag = i2
         4 active_ind = i2
         4 primary_ind = i2
         4 updt_cnt = i4
       3 medflexobjidxqual[*]
         4 db_rec_status = i2
         4 med_def_flex_id = f8
         4 med_flex_object_id = f8
         4 parent_entity_id = f8
         4 sequence = i4
         4 parent_entity = c32
         4 flex_object_type_cd = f8
         4 value = f8
         4 value_unit = f8
         4 active_ind = i2
         4 updt_cnt = i4
         4 meddispensequal[*]
           5 pharmacy_type_cd = f8
           5 pat_orderable_ind = i2
           5 db_rec_status = i2
           5 med_dispense_id = f8
           5 item_id = f8
           5 package_type_id = f8
           5 package_type_cd = f8
           5 parent_entity_id = f8
           5 parent_entity = vc
           5 flex_type_cd = f8
           5 flex_sort_flag = i4
           5 legal_status_cd = f8
           5 formulary_status_cd = f8
           5 oe_format_flag = i2
           5 med_filter_ind = i2
           5 continuous_filter_ind = i2
           5 intermittent_filter_ind = i2
           5 tpn_filter_ind = i2
           5 max_par_supply = i4
           5 infinite_div_ind = i2
           5 divisible_ind = i2
           5 used_as_base_ind = i2
           5 always_dispense_from_flag = i2
           5 dispense_qty = f8
           5 dispense_factor = f8
           5 label_ratio = f8
           5 reusable_ind = i2
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 base_issue_factor = f8
           5 updt_cnt = i4
           5 pkg_qty_per_pkg = f8
           5 pkg_disp_more_ind = i2
           5 override_clsfctn_cd = f8
           5 rx_station_notes = vc
           5 rx_station_notes_id = f8
           5 witness_dispense_ind = i2
           5 witness_return_ind = i2
           5 witness_adhoc_ind = i2
           5 witness_override_ind = i2
           5 witness_waste_ind = i2
           5 workflow_cd = f8
           5 tpn_balance_method_cd = f8
           5 tpn_chloride_pct = f8
           5 tpn_default_ingred_item_id = f8
           5 tpn_fill_method_cd = f8
           5 tpn_include_ions_flag = i2
           5 tpn_overfill_amt = f8
           5 tpn_overfill_unit_cd = f8
           5 tpn_preferred_cation_cd = f8
           5 tpn_product_type_flag = i2
           5 tpn_scale_flag = i2
           5 lot_tracking_ind = i2
           5 poc_charge_flag = i2
           5 witness_inv_count_ind = i2
           5 witness_empty_return_ind = i2
           5 witness_expire_mgmt_ind = i2
           5 witness_adhoc_refill_ind = i2
           5 witness_sched_task_ind = i2
           5 prod_assign_flag = i2
           5 billing_factor_nbr = f8
           5 billing_uom_cd = f8
           5 skip_dispense_flag = i2
         4 medoedefaultsqual[*]
           5 freetext_dose = vc
           5 diluent_id = f8
           5 diluent_volume = f8
           5 comment1_text = vc
           5 comment2_text = vc
           5 default_par_doses = i4
           5 max_par_supply = i4
           5 db_rec_status = i2
           5 med_oe_defaults_id = f8
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 route_cd = f8
           5 frequency_cd = f8
           5 prn_ind = i2
           5 prn_reason_cd = f8
           5 infuse_over = f8
           5 infuse_over_cd = f8
           5 duration = f8
           5 duration_unit_cd = f8
           5 stop_type_cd = f8
           5 dispense_category_cd = f8
           5 alternate_dispense_category_cd = f8
           5 comment1_id = f8
           5 comment1_type = i2
           5 comment2_id = f8
           5 comment2_type = i2
           5 price_sched_id = f8
           5 active_ind = i2
           5 updt_cnt = i4
           5 rx_qty = f8
           5 daw_cd = f8
           5 sig_codes = vc
           5 nbr_labels = i4
           5 ord_as_synonym_id = f8
           5 rate = f8
           5 rate_cd = f8
           5 normalized_rate = f8
           5 normalized_rate_cd = f8
           5 freetext_rate = vc
           5 grace_period_days = i4
         4 medproductqual[*]
           5 primary_ind = i2
           5 db_rec_status = i2
           5 med_product_id = f8
           5 manf_item_id = f8
           5 package_type_id = f8
           5 bio_equiv_ind = i2
           5 brand_ind = i2
           5 active_ind = i2
           5 updt_cnt = i4
           5 med_def_cki = vc
           5 unit_dose_ind = i2
           5 manufacturer_cd = f8
           5 awp_factor = f8
           5 schedulable_ind = i2
           5 reusable_ind = i2
           5 critical_ind = i2
           5 sub_account_cd = f8
           5 cost_center_cd = f8
           5 storage_requirement_cd = f8
           5 sterilization_required_ind = i2
           5 base_issue_factor = f8
           5 formulary_status_cd = f8
           5 medidentifierqual[*]
             6 salable_by_vendor_ind = i2
             6 salable_by_mfr_ind = i2
             6 id_type_cd = f8
             6 db_rec_status = i2
             6 package_type_id = f8
             6 med_def_flex_id = f8
             6 flex_sort_flag = i4
             6 med_identifier_id = f8
             6 order_set_id = f8
             6 item_id = f8
             6 med_product_id = f8
             6 sequence = i4
             6 pharmacy_type_cd = f8
             6 parent_entity_id = f8
             6 parent_entity = c32
             6 flex_type_cd = f8
             6 med_identifier_type_cd = f8
             6 value = c200
             6 value_key = c200
             6 med_type_flag = i2
             6 active_ind = i2
             6 primary_ind = i2
             6 updt_cnt = i4
           5 pack[*]
             6 db_rec_status = i2
             6 item_id = f8
             6 package_type_id = f8
             6 description = c40
             6 uom_cd = f8
             6 base_uom_cd = f8
             6 qty = f8
             6 base_package_type_ind = i2
             6 active_ind = i2
             6 updt_cnt = i4
           5 medcosthxqual[*]
             6 db_rec_status = i2
             6 med_cost_hx_id = f8
             6 med_product_id = f8
             6 cost_type_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 cost = f8
             6 active_ind = i2
             6 updt_cnt = i4
             6 updt_id = f8
             6 updt_dt_tm = dq8
           5 medproddescqual[*]
             6 med_prod_desc_id = f8
             6 field_type_cd = f8
             6 field_value_str_txt = vc
             6 updt_cnt = i4
             6 updt_task = i4
             6 updt_dt_tm = dq8
             6 db_rec_status = i2
           5 inv_factor_nbr = f8
           5 inv_base_pkg_uom_cd = f8
     2 medingredqual[*]
       3 med_ingred_set_id = f8
       3 parent_item_id = f8
       3 sequence = i4
       3 child_item_id = f8
       3 child_med_prod_id = f8
       3 child_pkg_type_id = f8
       3 inc_in_total_ind = i2
       3 base_ind = i2
       3 cmpd_qty = f8
       3 default_action_cd = f8
       3 updt_cnt = i4
       3 normalized_rate_ind = i2
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
     2 tpn_group_qual[*]
       3 tpn_group_cd = f8
     2 premix_ind = i2
     2 inv_factor_nbr = f8
     2 inv_base_pkg_uom_cd = f8
     2 inv_tracking_level = i2
     2 lot_tracking_ind = i2
   1 qual[*]
     2 nbr_ids_to_chg = i4
     2 nbr_packs_to_chg = i4
     2 cost1 = f8
     2 cost2 = f8
     2 awp = f8
     2 nbr_packs_to_add = i4
     2 id_type_cd = f8
     2 catalog_type_disp = vc
     2 iv_ingredient_ind = i2
     2 gcr_desc = vc
     2 order_alert1_cd = f8
     2 order_alert2_cd = f8
     2 side_effect_code = c10
     2 primary_manf_item_id = f8
     2 nbr_ids_to_add = i4
     2 total_ids_to_add = i4
     2 comment1_text = vc
     2 comment2_text = vc
     2 compound_text = vc
     2 order_sentence_id = f8
     2 countable_ind = i2
     2 fda_reportable_ind = i2
     2 active_status_cd = f8
     2 shelf_life = i4
     2 shelf_life_uom_cd = f8
     2 component_usage_ind = i2
     2 component_ind = i2
     2 quickadd_ind = i2
     2 approved_ind = i2
     2 item_type_cd = f8
     2 db_rec_status = i2
     2 item_id = f8
     2 location_cd = f8
     2 ic_dirty = i2
     2 ic_location_cd = f8
     2 stock_type_ind = i2
     2 stock_package_type_id = f8
     2 lot_tracking_level_cd = f8
     2 charge_type_cd = f8
     2 count_cycle_cd = f8
     2 instance_ind = i2
     2 abc_class_cd = f8
     2 ic_updt_cnt = i4
     2 list_role_id = f8
     2 sch_qty = i4
     2 st_dirty = i2
     2 st_location_cd = f8
     2 st_package_type_id = f8
     2 ac_dirty = i2
     2 qr_dirty = i2
     2 qh_dirty = i2
     2 mdx_gfc_nomen_id = f8
     2 form_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 given_strength = c25
     2 meq_factor = f8
     2 mmol_factor = f8
     2 compound_text_id = f8
     2 cki = c255
     2 schedulable_ind = i2
     2 reusable_ind = i2
     2 cdm = vc
     2 critical_ind = i2
     2 sub_account_cd = f8
     2 cost_center_cd = f8
     2 storage_requirement_cd = f8
     2 sterilization_required_ind = i2
     2 base_issue_factor = f8
     2 active_ind = i2
     2 package_type_id = f8
     2 med_def_flex_id = f8
     2 parent_entity_id = f8
     2 parent_entity = c32
     2 sequence = i4
     2 flex_type_cd = f8
     2 flex_sort_flag = i4
     2 pharmacy_type_cd = f8
     2 parent_med_def_flex_id = f8
     2 med_identifier_id = f8
     2 order_set_id = f8
     2 med_product_id = f8
     2 med_identifier_type_cd = f8
     2 value = c200
     2 value_key = c200
     2 med_type_flag = i2
     2 med_flex_object_id = f8
     2 flex_object_type_cd = f8
     2 med_dispense_id = f8
     2 package_type_cd = f8
     2 legal_status_cd = f8
     2 formulary_status_cd = f8
     2 oe_format_flag = i2
     2 med_filter_ind = i2
     2 continuous_filter_ind = i2
     2 intermittent_filter_ind = i2
     2 max_par_supply = i4
     2 divisible_ind = i2
     2 used_as_base_ind = i2
     2 always_dispense_from_flag = i2
     2 dispense_qty = i4
     2 updt_cnt = i4
     2 med_oe_defaults_id = f8
     2 freetext_dose = vc
     2 route_cd = f8
     2 frequency_cd = f8
     2 prn_ind = i2
     2 prn_reason_cd = f8
     2 infuse_over = f8
     2 infuse_over_cd = f8
     2 duration = f8
     2 duration_unit_cd = f8
     2 stop_type_cd = f8
     2 default_par_doses = f8
     2 dispense_category_cd = f8
     2 alternate_dispense_category_cd = f8
     2 comment1_id = f8
     2 comment1_type = i4
     2 comment2_id = f8
     2 comment2_type = i4
     2 price_sched_id = f8
     2 manf_item_id = f8
     2 bio_equiv_ind = i2
     2 brand_ind = i2
     2 med_def_cki = vc
     2 unit_dose_ind = i2
     2 manufacturer_cd = f8
     2 vendor_cd = f8
     2 awp_factor = f8
     2 med_cost_hx_id = f8
     2 cost_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cost = f8
     2 item1_id = f8
     2 item1_seq = i4
     2 item2_id = f8
     2 item2_seq = i4
     2 item_level_flag = i2
     2 pha_type_flag = i2
     2 fullpath[*]
       3 location_cd = f8
     2 premix_ind = i2
     2 lot_tracking_ind = i2
   1 add_id_qual[*]
     2 sequence = i4
     2 package_type_id = f8
     2 salable_by_vendor_ind = i2
     2 salable_by_mfr_ind = i2
     2 db_rec_status = i2
     2 object_id = f8
     2 object_id_pe = c32
     2 object_type_cd = f8
     2 object_active_ind = i2
     2 id_type_cd = f8
     2 id_type_mean = c12
     2 value = vc
     2 primary_ind = i2
     2 primary_nbr_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 vendor_manf_cd = f8
     2 add_id_qual_ind = i2
     2 identifier_id = f8
     2 item1_id = f8
     2 item1_seq = i4
     2 item1_type_cd = f8
     2 item1_vendor_mfg_cd = f8
     2 item2_id = f8
     2 item2_seq = i4
     2 item2_type_cd = f8
     2 item2_vendor_mfg_cd = f8
     2 tag1 = f8
     2 tag2 = vc
     2 replacement_upn_id = f8
     2 replaced_upn_id = f8
     2 item_level_flag = i2
     2 pha_type_flag = i2
   1 chg_id_qual[*]
     2 identifier_id = f8
     2 package_type_id = f8
     2 salable_by_vendor_ind = i2
     2 salable_by_mfr_ind = i2
     2 object_id = f8
     2 value = vc
     2 sequence = i4
     2 primary_ind = i2
     2 primary_nbr_ind = i2
     2 updt_cnt = i4
   1 del_id_qual[*]
     2 identifier_id = f8
     2 object_id = f8
     2 active_status_cd = f8
     2 updt_cnt = i4
   1 add_pack_qual[*]
     2 package_type_id = f8
     2 tag1 = f8
     2 db_rec_status = i2
     2 item_id = f8
     2 description = c40
     2 uom_cd = f8
     2 qty = f8
     2 base_package_type_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
   1 chg_pack_qual[*]
     2 package_type_id = i4
     2 description = c100
     2 qty = f8
     2 uom_cd = f8
     2 updt_cnt = i4
     2 base_package_type_ind = i2
     2 active_ind = i2
   1 rmv_pack_qual[*]
     2 package_type_id = f8
     2 item_id = f8
   1 del_pack_qual[*]
     2 package_type_id = f8
     2 item_id = f8
   1 total_ids_to_add = i4
   1 total_ids_to_chg = i4
   1 total_ids_to_del = i4
   1 total_packs_to_add = i4
   1 total_packs_to_chg = i4
   1 total_packs_to_del = i4
   1 total_packs_to_rmv = i4
   1 item_id = f8
   1 consent_form_ind = i2
   1 active_ind = i2
   1 catalog_cd = f8
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = vc
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 orc_text = vc
   1 valid_iv_additive_ind = i2
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 op_dc_display_days = i4
   1 op_dc_interaction_days = i4
   1 set_op_days = i2
   1 mdx_gcr_nomen_id = f8
   1 mnemonic = c100
   1 mnemonic_type_cd = f8
   1 order_sentence_id = f8
   1 mnem_active_ind = i2
   1 cki = vc
   1 syn_add_cnt = i4
   1 syn_upd_cnt = i4
   1 add_qual[*]
     2 db_rec_status = i2
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 synonym_cki = vc
     2 order_sentence_id = f8
     2 active_ind = i2
     2 item_id = f8
     2 location_cd = f8
     2 orderable_type_flag = i2
   1 upd_qual[*]
     2 db_rec_status = i2
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 synonym_cki = vc
     2 order_sentence_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 item_id = f8
   1 sent_cnt = i4
   1 sent_qual[*]
     2 db_rec_status = i2
     2 order_sentence_id = f8
     2 item_id = f8
     2 oe_format_id = f8
     2 field_cnt = i4
     2 field_qual[*]
       3 db_rec_status = i2
       3 oe_field_value = f8
       3 oe_field_id = f8
       3 field_type_flag = i2
       3 decode_field_ind = i2
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
   1 updt_cnt = i4
   1 location_group_type_cd = f8
   1 root_loc_cd = f8
   1 max_loc_cnt = i2
   1 get_fullpath_flag = i2
   1 get_ic_flag = i2
   1 get_ac_flag = i2
   1 get_qr_flag = i2
   1 get_st_flag = i2
   1 get_qh_flag = i2
   1 get_locator_flag = i2
   1 get_path_flag = i2
   1 get_pk_flag = i2
   1 get_rel_path_flag = i2
   1 replacement_upn_id = f8
   1 addqual[*]
     2 med_cost_hx_id = f8
     2 med_product_id = f8
     2 cost_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cost = f8
     2 active_ind = i2
     2 updt_cnt = i4
   1 updqual[*]
     2 med_cost_hx_id = f8
     2 med_product_id = f8
     2 cost_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cost = f8
     2 active_ind = i2
     2 updt_cnt = i4
   1 del_qual[*]
     2 location_cd = f8
   1 synonym_id = f8
   1 synonym_cki = vc
   1 nbr_of_add_locator = i2
   1 nbr_of_del_locator = i2
   1 view_type_cd = f8
 )
 DECLARE flag_600 = f8 WITH constant(600), protect
 DECLARE flag_500 = f8 WITH constant(500), protect
 DECLARE genname_var = f8 WITH constant(uar_get_code_by("MEANING",401,"GENNAME")), protect
 DECLARE genform_var = f8 WITH constant(uar_get_code_by("MEANING",401,"GENFORM")), protect
 DECLARE mul_drug_var = f8 WITH constant(uar_get_code_by("MEANING",400,"MUL.DRUG")), protect
 DECLARE mul_mmdc_var = f8 WITH constant(uar_get_code_by("MEANING",400,"MUL.MMDC")), protect
 DECLARE pharmacy_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")), protect
 DECLARE phar_act_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY")), protect
 DECLARE rxreqsn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6002,"RXREQSN")), protect
 DECLARE system_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4062,"SYSTEM")), protect
 DECLARE inpatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4500,"INPATIENT")), protect
 DECLARE oedefault_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4063,"OEDEFAULT")), protect
 DECLARE medproduct_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4063,"MEDPRODUCT")), protect
 DECLARE formulary_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4512,"FORMULARY")), protect
 DECLARE ndc_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"NDC")), protect
 DECLARE brand_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"BRANDNAME")), protect
 DECLARE description_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"DESCRIPTION")),
 protect
 DECLARE rxuniqueid_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"RXUNIQUEID")), protect
 DECLARE awp_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4050,"AWP")), protect
 DECLARE syspkgtyp_var = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP")), protect
 DECLARE dispense_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4063,"DISPENSE")), protect
 DECLARE orderable_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4063,"ORDERABLE")), protect
 DECLARE gen_form_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",401,"GENERICFORMULATION")),
 protect
 DECLARE active_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE display = vc WITH protect
 DECLARE display1 = vc WITH protect
 DECLARE display2 = vc WITH protect
 DECLARE catalod_code = f8
 DECLARE source = vc
 DECLARE cnt1 = i4
 DECLARE cnt2 = i4
 DECLARE cnt3 = i4
 DECLARE cnt4 = i4
 DECLARE cnt5 = i4
 DECLARE cnt6 = i4
 DECLARE cnt7 = i4
 DECLARE cnt8 = i4
 DECLARE val1 = vc
 DECLARE val2 = vc
 FREE RECORD data_request
 RECORD data_request(
   1 meds[*]
     2 item_group_active_ind = i2
     2 item1_id = f8
     2 item2_id = f8
     2 tag1 = f8
     2 cost1 = f8
     2 cost2 = f8
     2 awp = f8
     2 nbr_packs_to_chg = i4
     2 nbr_packs_to_add = i4
     2 id_type_cd = f8
     2 prep_into_flag = i4
     2 catalog_type_disp = vc
     2 iv_ingredient_ind = i2
     2 gcr_desc = vc
     2 package_type_id = f8
     2 order_alert1_cd = f8
     2 order_alert2_cd = f8
     2 side_effect_code = c10
     2 primary_manf_item_id = f8
     2 nbr_ids_to_add = i4
     2 comment1_text = vc
     2 comment2_text = vc
     2 compound_text = vc
     2 countable_ind = i2
     2 fda_reportable_ind = i2
     2 active_status_cd = f8
     2 shelf_life = i4
     2 shelf_life_uom_cd = f8
     2 component_usage_ind = i2
     2 component_ind = i2
     2 quickadd_ind = i2
     2 approved_ind = i2
     2 item_type_cd = f8
     2 db_rec_status = i2
     2 prod_rec_status = i2
     2 manf_rec_status = i2
     2 prod_id_rec_status = i2
     2 oc_rec_status = i2
     2 sent_rec_status = i2
     2 pack_rec_status = i2
     2 meddefqual[*]
       3 gfc_description = vc
       3 active_status_cd = f8
       3 updt_cnt = i4
       3 db_rec_status = i2
       3 med_type_flag = i2
       3 item_id = f8
       3 mdx_gfc_nomen_id = f8
       3 form_cd = vc
       3 strength = vc
       3 strength_unit_cd = vc
       3 volume = vc
       3 volume_unit_cd = vc
       3 given_strength = c25
       3 meq_factor = f8
       3 mmol_factor = f8
       3 compound_text_id = f8
       3 compound_text = vc
       3 comment1_text = vc
       3 comment2_text = vc
       3 comment1_id = f8
       3 comment2_id = f8
       3 cki = c255
       3 schedulable_ind = i2
       3 reusable_ind = i2
       3 cdm = vc
       3 critical_ind = i2
       3 sub_account_cd = f8
       3 cost_center_cd = f8
       3 storage_requirement_cd = f8
       3 sterilization_required_ind = i2
       3 base_issue_factor = f8
       3 active_ind = i2
       3 package_type_id = f8
       3 template_catalog_cd = f8
       3 template_synonym_id = f8
       3 primary_synonym_mnemonic = vc
       3 locqual[*]
         4 location_cd = f8
       3 pack[*]
         4 db_rec_status = i2
         4 item_id = f8
         4 package_type_id = f8
         4 description = c40
         4 uom_cd = vc
         4 base_uom_cd = f8
         4 qty = vc
         4 base_package_type_ind = i2
         4 active_ind = i2
         4 updt_cnt = i4
       3 ordcat[*]
         4 prep_into_flag = i4
         4 db_rec_status = i2
         4 catalog_cd = f8
         4 consent_form_ind = i2
         4 active_ind = i2
         4 catalog_type_cd = f8
         4 catalog_type_disp = vc
         4 activity_type_cd = f8
         4 activity_subtype_cd = f8
         4 requisition_format_cd = f8
         4 requisition_routing_cd = f8
         4 inst_restriction_ind = i2
         4 schedule_ind = i2
         4 description = vc
         4 iv_ingredient_ind = i2
         4 print_req_ind = i2
         4 oe_format_id = f8
         4 orderable_type_flag = i2
         4 complete_upon_order_ind = i2
         4 quick_chart_ind = i2
         4 comment_template_flag = i2
         4 prep_info_flag = i2
         4 updt_cnt = i4
         4 valid_iv_additive_ind = i2
         4 dc_display_days = i4
         4 dc_interaction_days = i4
         4 op_dc_display_days = i4
         4 op_dc_interaction_days = i4
         4 set_op_days = i2
         4 mdx_gcr_nomen_id = f8
         4 cki = vc
         4 gcr_desc = vc
         4 ahfs_qual[*]
           5 ahfs_code = c6
         4 qual_mnemonic[*]
           5 db_rec_status = i2
           5 item_id = f8
           5 synonym_id = f8
           5 mnemonic = vc
           5 mnemonic_type_cd = vc
           5 synonym_cki = vc
           5 active_ind = i2
           5 order_sentence_id = f8
           5 orderable_type_flag = i2
           5 updt_cnt = i4
       3 meddefflexqual[*]
         4 db_rec_status = i2
         4 med_def_flex_id = f8
         4 parent_entity_id = f8
         4 parent_entity = c32
         4 sequence = i4
         4 flex_type_cd = f8
         4 flex_sort_flag = i4
         4 pharmacy_type_cd = f8
         4 parent_med_def_flex_id = f8
         4 package_type_id = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 pack[*]
           5 db_rec_status = i2
           5 item_id = f8
           5 package_type_id = f8
           5 description = c40
           5 uom_cd = vc
           5 base_uom_cd = f8
           5 qty = vc
           5 base_package_type_ind = i2
           5 active_ind = i2
           5 updt_cnt = i4
         4 medidentifierqual[*]
           5 salable_by_vendor_ind = i2
           5 salable_by_mfr_ind = i2
           5 id_type_cd = f8
           5 db_rec_status = i2
           5 package_type_id = f8
           5 med_def_flex_id = f8
           5 flex_sort_flag = i4
           5 med_identifier_id = f8
           5 order_set_id = f8
           5 item_id = f8
           5 med_product_id = f8
           5 sequence = i4
           5 pharmacy_type_cd = f8
           5 parent_entity_id = f8
           5 parent_entity = c32
           5 flex_type_cd = f8
           5 med_identifier_type_cd = vc
           5 value = c200
           5 value_key = c200
           5 med_type_flag = i2
           5 active_ind = i2
           5 primary_ind = i2
           5 updt_cnt = i4
         4 medflexobjidxqual[*]
           5 db_rec_status = i2
           5 med_def_flex_id = f8
           5 med_flex_object_id = f8
           5 parent_entity_id = f8
           5 sequence = i4
           5 parent_entity = c32
           5 flex_object_type_cd = f8
           5 value = f8
           5 value_unit = f8
           5 active_ind = i2
           5 updt_cnt = i4
           5 meddispensequal[*]
             6 pharmacy_type_cd = f8
             6 pat_orderable_ind = i2
             6 db_rec_status = i2
             6 med_dispense_id = f8
             6 item_id = f8
             6 package_type_id = f8
             6 package_type_cd = f8
             6 parent_entity_id = f8
             6 parent_entity = vc
             6 flex_type_cd = f8
             6 flex_sort_flag = i4
             6 legal_status_cd = vc
             6 formulary_status_cd = f8
             6 oe_format_flag = i2
             6 med_filter_ind = i2
             6 continuous_filter_ind = i2
             6 intermittent_filter_ind = i2
             6 tpn_filter_ind = i2
             6 max_par_supply = i4
             6 infinite_div_ind = i2
             6 divisible_ind = i2
             6 used_as_base_ind = i2
             6 always_dispense_from_flag = i2
             6 dispense_qty = f8
             6 dispense_factor = f8
             6 label_ratio = f8
             6 reusable_ind = i2
             6 strength = vc
             6 strength_unit_cd = vc
             6 volume = vc
             6 volume_unit_cd = vc
             6 base_issue_factor = f8
             6 updt_cnt = i4
             6 pkg_qty_per_pkg = f8
             6 pkg_disp_more_ind = i2
             6 override_clsfctn_cd = f8
             6 rx_station_notes = vc
             6 rx_station_notes_id = f8
             6 witness_dispense_ind = i2
             6 witness_return_ind = i2
             6 witness_adhoc_ind = i2
             6 witness_override_ind = i2
             6 witness_waste_ind = i2
             6 workflow_cd = f8
             6 tpn_balance_method_cd = f8
             6 tpn_chloride_pct = f8
             6 tpn_default_ingred_item_id = f8
             6 tpn_fill_method_cd = f8
             6 tpn_include_ions_flag = i2
             6 tpn_overfill_amt = f8
             6 tpn_overfill_unit_cd = f8
             6 tpn_preferred_cation_cd = f8
             6 tpn_product_type_flag = i2
             6 tpn_scale_flag = i2
             6 lot_tracking_ind = i2
             6 poc_charge_flag = i2
             6 witness_inv_count_ind = i2
             6 witness_empty_return_ind = i2
             6 witness_expire_mgmt_ind = i2
             6 witness_adhoc_refill_ind = i2
             6 witness_sched_task_ind = i2
             6 prod_assign_flag = i2
             6 billing_factor_nbr = f8
             6 billing_uom_cd = f8
             6 skip_dispense_flag = i2
           5 medoedefaultsqual[*]
             6 freetext_dose = vc
             6 diluent_id = f8
             6 diluent_volume = f8
             6 comment1_text = vc
             6 comment2_text = vc
             6 default_par_doses = i4
             6 max_par_supply = i4
             6 db_rec_status = i2
             6 med_oe_defaults_id = f8
             6 strength = vc
             6 strength_unit_cd = vc
             6 volume = vc
             6 volume_unit_cd = vc
             6 route_cd = vc
             6 frequency_cd = vc
             6 prn_ind = i2
             6 prn_reason_cd = f8
             6 infuse_over = f8
             6 infuse_over_cd = f8
             6 duration = f8
             6 duration_unit_cd = f8
             6 stop_type_cd = f8
             6 dispense_category_cd = f8
             6 alternate_dispense_category_cd = f8
             6 comment1_id = f8
             6 comment1_type = i2
             6 comment2_id = f8
             6 comment2_type = i2
             6 price_sched_id = f8
             6 active_ind = i2
             6 updt_cnt = i4
             6 rx_qty = f8
             6 daw_cd = f8
             6 sig_codes = vc
             6 nbr_labels = i4
             6 ord_as_synonym_id = f8
             6 rate = f8
             6 rate_cd = f8
             6 normalized_rate = f8
             6 normalized_rate_cd = f8
             6 freetext_rate = vc
             6 grace_period_days = i4
           5 medproductqual[*]
             6 primary_ind = i2
             6 db_rec_status = i2
             6 med_product_id = f8
             6 manf_item_id = f8
             6 package_type_id = f8
             6 bio_equiv_ind = i2
             6 brand_ind = i2
             6 active_ind = i2
             6 updt_cnt = i4
             6 med_def_cki = vc
             6 unit_dose_ind = i2
             6 manufacturer_cd = vc
             6 awp_factor = f8
             6 schedulable_ind = i2
             6 reusable_ind = i2
             6 critical_ind = i2
             6 sub_account_cd = f8
             6 cost_center_cd = f8
             6 storage_requirement_cd = f8
             6 sterilization_required_ind = i2
             6 base_issue_factor = f8
             6 formulary_status_cd = f8
             6 medidentifierqual[*]
               7 salable_by_vendor_ind = i2
               7 salable_by_mfr_ind = i2
               7 id_type_cd = f8
               7 db_rec_status = i2
               7 package_type_id = f8
               7 med_def_flex_id = f8
               7 flex_sort_flag = i4
               7 med_identifier_id = f8
               7 order_set_id = f8
               7 item_id = f8
               7 med_product_id = f8
               7 sequence = i4
               7 pharmacy_type_cd = f8
               7 parent_entity_id = f8
               7 parent_entity = c32
               7 flex_type_cd = f8
               7 med_identifier_type_cd = f8
               7 value = c200
               7 value_key = c200
               7 med_type_flag = i2
               7 active_ind = i2
               7 primary_ind = i2
               7 updt_cnt = i4
             6 pack[*]
               7 db_rec_status = i2
               7 item_id = f8
               7 package_type_id = f8
               7 description = c40
               7 uom_cd = vc
               7 base_uom_cd = f8
               7 qty = vc
               7 base_package_type_ind = i2
               7 active_ind = i2
               7 updt_cnt = i4
             6 medcosthxqual[*]
               7 db_rec_status = i2
               7 med_cost_hx_id = f8
               7 med_product_id = f8
               7 cost_type_cd = f8
               7 beg_effective_dt_tm = dq8
               7 end_effective_dt_tm = dq8
               7 cost = vc
               7 active_ind = i2
               7 updt_cnt = i4
               7 updt_id = f8
               7 updt_dt_tm = dq8
             6 medproddescqual[*]
               7 med_prod_desc_id = f8
               7 field_type_cd = f8
               7 field_value_str_txt = vc
               7 updt_cnt = i4
               7 updt_task = i4
               7 updt_dt_tm = dq8
               7 db_rec_status = i2
             6 inv_factor_nbr = f8
             6 inv_base_pkg_uom_cd = f8
       3 medingredqual[*]
         4 med_ingred_set_id = f8
         4 parent_item_id = f8
         4 sequence = i4
         4 child_item_id = f8
         4 child_med_prod_id = f8
         4 child_pkg_type_id = f8
         4 inc_in_total_ind = i2
         4 base_ind = i2
         4 cmpd_qty = f8
         4 default_action_cd = f8
         4 updt_cnt = i4
         4 normalized_rate_ind = i2
         4 strength = vc
         4 strength_unit_cd = vc
         4 volume = vc
         4 volume_unit_cd = vc
       3 tpn_group_qual[*]
         4 tpn_group_cd = f8
       3 premix_ind = i2
       3 inv_factor_nbr = f8
       3 inv_base_pkg_uom_cd = f8
       3 inv_tracking_level = i2
       3 lot_tracking_ind = i2
     2 qual[*]
       3 nbr_ids_to_chg = i4
       3 nbr_packs_to_chg = i4
       3 cost1 = f8
       3 cost2 = f8
       3 awp = f8
       3 nbr_packs_to_add = i4
       3 id_type_cd = f8
       3 catalog_type_disp = vc
       3 iv_ingredient_ind = i2
       3 gcr_desc = vc
       3 order_alert1_cd = f8
       3 order_alert2_cd = f8
       3 side_effect_code = c10
       3 primary_manf_item_id = f8
       3 nbr_ids_to_add = i4
       3 total_ids_to_add = i4
       3 comment1_text = vc
       3 comment2_text = vc
       3 compound_text = vc
       3 order_sentence_id = f8
       3 countable_ind = i2
       3 fda_reportable_ind = i2
       3 active_status_cd = f8
       3 shelf_life = i4
       3 shelf_life_uom_cd = f8
       3 component_usage_ind = i2
       3 component_ind = i2
       3 quickadd_ind = i2
       3 approved_ind = i2
       3 item_type_cd = f8
       3 db_rec_status = i2
       3 item_id = f8
       3 location_cd = f8
       3 ic_dirty = i2
       3 ic_location_cd = f8
       3 stock_type_ind = i2
       3 stock_package_type_id = f8
       3 lot_tracking_level_cd = f8
       3 charge_type_cd = f8
       3 count_cycle_cd = f8
       3 instance_ind = i2
       3 abc_class_cd = f8
       3 ic_updt_cnt = i4
       3 list_role_id = f8
       3 sch_qty = i4
       3 st_dirty = i2
       3 st_location_cd = f8
       3 st_package_type_id = f8
       3 ac_dirty = i2
       3 qr_dirty = i2
       3 qh_dirty = i2
       3 mdx_gfc_nomen_id = f8
       3 form_cd = f8
       3 strength = vc
       3 strength_unit_cd = vc
       3 volume = vc
       3 volume_unit_cd = vc
       3 given_strength = c25
       3 meq_factor = f8
       3 mmol_factor = f8
       3 compound_text_id = f8
       3 cki = c255
       3 schedulable_ind = i2
       3 reusable_ind = i2
       3 cdm = vc
       3 critical_ind = i2
       3 sub_account_cd = f8
       3 cost_center_cd = f8
       3 storage_requirement_cd = f8
       3 sterilization_required_ind = i2
       3 base_issue_factor = f8
       3 active_ind = i2
       3 package_type_id = f8
       3 med_def_flex_id = f8
       3 parent_entity_id = f8
       3 parent_entity = c32
       3 sequence = i4
       3 flex_type_cd = f8
       3 flex_sort_flag = i4
       3 pharmacy_type_cd = f8
       3 parent_med_def_flex_id = f8
       3 med_identifier_id = f8
       3 order_set_id = f8
       3 med_product_id = f8
       3 med_identifier_type_cd = f8
       3 value = c200
       3 value_key = c200
       3 med_type_flag = i2
       3 med_flex_object_id = f8
       3 flex_object_type_cd = f8
       3 med_dispense_id = f8
       3 package_type_cd = f8
       3 legal_status_cd = f8
       3 formulary_status_cd = f8
       3 oe_format_flag = i2
       3 med_filter_ind = i2
       3 continuous_filter_ind = i2
       3 intermittent_filter_ind = i2
       3 max_par_supply = i4
       3 divisible_ind = i2
       3 used_as_base_ind = i2
       3 always_dispense_from_flag = i2
       3 dispense_qty = i4
       3 updt_cnt = i4
       3 med_oe_defaults_id = f8
       3 freetext_dose = vc
       3 route_cd = f8
       3 frequency_cd = f8
       3 prn_ind = i2
       3 prn_reason_cd = f8
       3 infuse_over = f8
       3 infuse_over_cd = f8
       3 duration = f8
       3 duration_unit_cd = f8
       3 stop_type_cd = f8
       3 default_par_doses = f8
       3 dispense_category_cd = f8
       3 alternate_dispense_category_cd = f8
       3 comment1_id = f8
       3 comment1_type = i4
       3 comment2_id = f8
       3 comment2_type = i4
       3 price_sched_id = f8
       3 manf_item_id = f8
       3 bio_equiv_ind = i2
       3 brand_ind = i2
       3 med_def_cki = vc
       3 unit_dose_ind = i2
       3 manufacturer_cd = f8
       3 vendor_cd = f8
       3 awp_factor = f8
       3 med_cost_hx_id = f8
       3 cost_type_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 cost = vc
       3 item1_id = f8
       3 item1_seq = i4
       3 item2_id = f8
       3 item2_seq = i4
       3 item_level_flag = i2
       3 pha_type_flag = i2
       3 fullpath[*]
         4 location_cd = f8
       3 premix_ind = i2
       3 lot_tracking_ind = i2
     2 add_id_qual[*]
       3 sequence = i4
       3 package_type_id = f8
       3 salable_by_vendor_ind = i2
       3 salable_by_mfr_ind = i2
       3 db_rec_status = i2
       3 object_id = f8
       3 object_id_pe = c32
       3 object_type_cd = f8
       3 object_active_ind = i2
       3 id_type_cd = f8
       3 id_type_mean = c12
       3 value = vc
       3 primary_ind = i2
       3 primary_nbr_ind = i2
       3 active_ind = i2
       3 active_status_cd = f8
       3 vendor_manf_cd = f8
       3 add_id_qual_ind = i2
       3 identifier_id = f8
       3 item1_id = f8
       3 item1_seq = i4
       3 item1_type_cd = f8
       3 item1_vendor_mfg_cd = f8
       3 item2_id = f8
       3 item2_seq = i4
       3 item2_type_cd = f8
       3 item2_vendor_mfg_cd = f8
       3 tag1 = f8
       3 tag2 = vc
       3 replacement_upn_id = f8
       3 replaced_upn_id = f8
       3 item_level_flag = i2
       3 pha_type_flag = i2
     2 chg_id_qual[*]
       3 identifier_id = f8
       3 package_type_id = f8
       3 salable_by_vendor_ind = i2
       3 salable_by_mfr_ind = i2
       3 object_id = f8
       3 value = vc
       3 sequence = i4
       3 primary_ind = i2
       3 primary_nbr_ind = i2
       3 updt_cnt = i4
     2 del_id_qual[*]
       3 identifier_id = f8
       3 object_id = f8
       3 active_status_cd = f8
       3 updt_cnt = i4
     2 add_pack_qual[*]
       3 package_type_id = f8
       3 tag1 = f8
       3 db_rec_status = i2
       3 item_id = f8
       3 description = c40
       3 uom_cd = vc
       3 qty = vc
       3 base_package_type_ind = i2
       3 active_ind = i2
       3 active_status_cd = f8
     2 chg_pack_qual[*]
       3 package_type_id = i4
       3 description = c100
       3 qty = vc
       3 uom_cd = f8
       3 updt_cnt = i4
       3 base_package_type_ind = i2
       3 active_ind = i2
     2 rmv_pack_qual[*]
       3 package_type_id = f8
       3 item_id = f8
     2 del_pack_qual[*]
       3 package_type_id = f8
       3 item_id = f8
     2 total_ids_to_add = i4
     2 total_ids_to_chg = i4
     2 total_ids_to_del = i4
     2 total_packs_to_add = i4
     2 total_packs_to_chg = i4
     2 total_packs_to_del = i4
     2 total_packs_to_rmv = i4
     2 item_id = f8
     2 consent_form_ind = i2
     2 active_ind = i2
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 requisition_format_cd = f8
     2 requisition_routing_cd = f8
     2 inst_restriction_ind = i2
     2 schedule_ind = i2
     2 description = vc
     2 print_req_ind = i2
     2 oe_format_id = f8
     2 orderable_type_flag = i2
     2 complete_upon_order_ind = i2
     2 quick_chart_ind = i2
     2 comment_template_flag = i2
     2 prep_info_flag = i2
     2 orc_text = vc
     2 valid_iv_additive_ind = i2
     2 dc_display_days = i4
     2 dc_interaction_days = i4
     2 op_dc_display_days = i4
     2 op_dc_interaction_days = i4
     2 set_op_days = i2
     2 mdx_gcr_nomen_id = f8
     2 mnemonic = c100
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 mnem_active_ind = i2
     2 cki = vc
     2 syn_add_cnt = i4
     2 syn_upd_cnt = i4
     2 add_qual[*]
       3 db_rec_status = i2
       3 mnemonic = vc
       3 mnemonic_type_cd = f8
       3 synonym_cki = vc
       3 order_sentence_id = f8
       3 active_ind = i2
       3 item_id = f8
       3 location_cd = f8
       3 orderable_type_flag = i2
     2 upd_qual[*]
       3 db_rec_status = i2
       3 synonym_id = f8
       3 mnemonic = vc
       3 mnemonic_type_cd = f8
       3 synonym_cki = vc
       3 order_sentence_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
       3 item_id = f8
     2 sent_cnt = i4
     2 sent_qual[*]
       3 db_rec_status = i2
       3 order_sentence_id = f8
       3 item_id = f8
       3 oe_format_id = f8
       3 field_cnt = i4
       3 field_qual[*]
         4 db_rec_status = i2
         4 oe_field_value = f8
         4 oe_field_id = f8
         4 field_type_flag = i2
         4 decode_field_ind = i2
         4 oe_field_display_value = vc
         4 oe_field_meaning_id = f8
     2 updt_cnt = i4
     2 location_group_type_cd = f8
     2 root_loc_cd = f8
     2 max_loc_cnt = i2
     2 get_fullpath_flag = i2
     2 get_ic_flag = i2
     2 get_ac_flag = i2
     2 get_qr_flag = i2
     2 get_st_flag = i2
     2 get_qh_flag = i2
     2 get_locator_flag = i2
     2 get_path_flag = i2
     2 get_pk_flag = i2
     2 get_rel_path_flag = i2
     2 replacement_upn_id = f8
     2 addqual[*]
       3 med_cost_hx_id = f8
       3 med_product_id = f8
       3 cost_type_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 cost = vc
       3 active_ind = i2
       3 updt_cnt = i4
     2 updqual[*]
       3 med_cost_hx_id = f8
       3 med_product_id = f8
       3 cost_type_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 cost = vc
       3 active_ind = i2
       3 updt_cnt = i4
     2 del_qual[*]
       3 location_cd = f8
     2 synonym_id = f8
     2 synonym_cki = vc
     2 nbr_of_add_locator = i2
     2 nbr_of_del_locator = i2
     2 view_type_cd = f8
 )
 FREE RECORD orig_data
 RECORD orig_data(
   1 qual[*]
     2 maufacturer = vc
     2 ndc = vc
     2 inner_ndc = vc
     2 generic_name = vc
     2 mnemonic = vc
     2 description = vc
     2 brand_name = vc
     2 base_awp = vc
     2 strength = vc
     2 package = vc
     2 package_unit = vc
     2 base_package_unit = vc
     2 outer_pakcage = vc
     2 outer_package_unit = vc
     2 unit_dose = vc
     2 bio = vc
     2 dosage_form = vc
     2 gb_indicator = vc
     2 suppress_clini_chk = vc
     2 legal_status = vc
     2 dose = vc
     2 route = vc
     2 frequency = vc
     2 infuse_over = vc
     2 infuse_untis = vc
     2 freetext_rate = vc
     2 normalized_rate = vc
     2 normalized_unit = vc
     2 rate = vc
     2 rate_unit = vc
     2 duration = vc
     2 duration_unit = vc
     2 stop_type = vc
     2 prn = vc
     2 prn_reason = vc
     2 def_ordered_as = vc
     2 sig = vc
     2 def_screen_format = vc
     2 notes1 = vc
     2 applies_to1 = vc
     2 notes2 = vc
     2 applies_to2 = vc
     2 filter = vc
     2 dose_strength = vc
     2 strength_unit = vc
     2 volume = vc
     2 volume_unit = vc
     2 used_in_total_volume_calculation = vc
     2 workflow_sequence = vc
     2 disp_stregnth = vc
     2 disp_volume = vc
     2 dispense_qty = vc
     2 disp_qty_unit = vc
     2 dispense_category = vc
     2 dispense_factor = vc
     2 prod_divisible = vc
     2 min_div_factor = vc
     2 ea = vc
     2 infinitely_divisible = vc
     2 package_disp_number = vc
     2 package_disp_unit = vc
     2 per_package = vc
     2 formulary_status = vc
     2 price_schedule = vc
     2 billing_factor = vc
     2 billing_factor_units = vc
     2 def_per_doses = vc
     2 max_par_quantity = vc
     2 point_of_care_charge = vc
     2 ordarable_facilities = vc
     2 update_pharmacies = vc
     2 update_floorstock = vc
     2 flex_by_facilities = vc
     2 dispense_from = vc
     2 prod_reusable = vc
     2 track_lot_numbers = vc
     2 aps_apa = vc
     2 disable = vc
     2 skip_dispense = vc
     2 generic_formulation = vc
     2 drug_formulation = vc
     2 therapeutice_class = vc
     2 dc_interaction = vc
     2 dc_display = vc
     2 suppress_alerts = vc
     2 upd_order_alerts = vc
     2 upd_label_warnings = vc
     2 supply_properties = vc
     2 identifier_type = vc
     2 identifier_description = vc
     2 active = vc
 )
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, header_flag = 0, stat = alterlist(orig_data->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    header_flag = (header_flag+ 1)
    IF (header_flag > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(orig_data->qual,(row_count+ 9))
     ENDIF
     orig_data->qual[row_count].ndc = piece(r.line,",",1,"not found"), orig_data->qual[row_count].
     maufacturer = piece(r.line,",",2,"not found"), orig_data->qual[row_count].generic_name = piece(r
      .line,",",3,"not found"),
     orig_data->qual[row_count].mnemonic = piece(r.line,",",4,"not found"), orig_data->qual[row_count
     ].description = piece(r.line,",",5,"not found"), orig_data->qual[row_count].brand_name = piece(r
      .line,",",6,"not found"),
     orig_data->qual[row_count].base_awp = piece(r.line,",",7,"not found"), orig_data->qual[row_count
     ].strength = piece(r.line,",",8,"not found"), orig_data->qual[row_count].package = piece(r.line,
      ",",9,"not found"),
     orig_data->qual[row_count].base_package_unit = piece(r.line,",",10,"not found"), orig_data->
     qual[row_count].outer_pakcage = piece(r.line,",",11,"not found"), orig_data->qual[row_count].
     unit_dose = piece(r.line,",",12,"not found"),
     orig_data->qual[row_count].bio = piece(r.line,",",13,"not found"), orig_data->qual[row_count].
     dosage_form = piece(r.line,",",14,"not found"), orig_data->qual[row_count].gb_indicator = piece(
      r.line,",",15,"not found"),
     orig_data->qual[row_count].legal_status = piece(r.line,",",16,"not found"), orig_data->qual[
     row_count].filter = piece(r.line,",",17,"not found"), orig_data->qual[row_count].disp_stregnth
      = piece(r.line,",",18,"not found"),
     orig_data->qual[row_count].disp_volume = piece(r.line,",",19,"not found"), orig_data->qual[
     row_count].used_in_total_volume_calculation = piece(r.line,",",20,"not found"), orig_data->qual[
     row_count].dispense_qty = piece(r.line,",",21,"not found"),
     orig_data->qual[row_count].infinitely_divisible = piece(r.line,",",22,"not found"), orig_data->
     qual[row_count].formulary_status = piece(r.line,",",23,"not found"), orig_data->qual[row_count].
     point_of_care_charge = piece(r.line,",",24,"not found"),
     orig_data->qual[row_count].ordarable_facilities = piece(r.line,",",25,"not found"), orig_data->
     qual[row_count].generic_formulation = piece(r.line,",",26,"not found"), orig_data->qual[
     row_count].drug_formulation = piece(r.line,",",27,"not found"),
     orig_data->qual[row_count].dose = piece(r.line,",",28,"not found"), orig_data->qual[row_count].
     route = piece(r.line,",",29,"not found"), orig_data->qual[row_count].frequency = piece(r.line,
      ",",30,"not found"),
     orig_data->qual[row_count].sig = piece(r.line,",",31,"not found"), orig_data->qual[row_count].
     notes1 = piece(r.line,",",32,"not found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_data->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET cnt1 = 0
 CALL echo(size(orig_data->qual,5))
 FOR (i = 1 TO size(orig_data->qual,5))
   IF (trim(orig_data->qual[i].ndc) != "")
    SET cnt1 = (cnt1+ 1)
    SET lbcnt = 0
    SET cnt2 = 0
    SET stat = alterlist(data_request->meds,cnt1)
   ENDIF
   SET cnt2 = (cnt2+ 1)
   SET stat = alterlist(data_request->meds[cnt1].meddefqual,cnt2)
   SET data_request->meds[cnt1].meddefqual[cnt2].gfc_description = orig_data->qual[i].
   drug_formulation
   SET data_request->meds[cnt1].meddefqual[cnt2].form_cd = orig_data->qual[i].dosage_form
   SET data_request->meds[cnt1].meddefqual[cnt2].given_strength = replace(orig_data->qual[i].strength,
    "_"," ")
   SET data_request->meds[cnt1].meddefqual[cnt2].comment1_text = orig_data->qual[i].notes1
   SET str_len = 0
   SET pos = 0
   SET val1 = ""
   SET val2 = ""
   SET val1 = piece(orig_data->qual[i].strength,"_",1,"")
   SET str_len = textlen(orig_data->qual[i].strength)
   SET pos = findstring("_",orig_data->qual[i].strength)
   SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].strength)
   SET data_request->meds[cnt1].meddefqual[cnt2].strength = val1
   SET data_request->meds[cnt1].meddefqual[cnt2].strength_unit_cd = val2
   SET cnt3 = 0
   IF ((orig_data->qual[i].package != ""))
    SET cnt3 = (cnt3+ 1)
    SET str_len = 0
    SET pos = 0
    SET val1 = ""
    SET val2 = ""
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].pack,cnt3)
    SET data_request->meds[cnt1].meddefqual[cnt2].pack[cnt3].description = orig_data->qual[i].package
    SET val1 = piece(orig_data->qual[i].package,"_",1,"")
    SET str_len = textlen(orig_data->qual[i].package)
    SET pos = findstring("_",orig_data->qual[i].package)
    SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].package)
    SET data_request->meds[cnt1].meddefqual[cnt2].pack[cnt3].qty = val1
    SET data_request->meds[cnt1].meddefqual[cnt2].pack[cnt3].uom_cd = val2
   ENDIF
   SET cnt4 = 0
   IF ((orig_data->qual[i].generic_formulation != ""))
    SET cnt4 = (cnt4+ 1)
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].ordcat,cnt4)
    SET data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].gcr_desc = orig_data->qual[i].
    generic_formulation
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].ahfs_qual,1)
    SET cnt5 = 0
    IF ((orig_data->qual[i].mnemonic != ""))
     SET cnt5 = (cnt5+ 1)
     SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic,cnt5)
     SET data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic[cnt5].mnemonic =
     orig_data->qual[i].mnemonic
     SET data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic[cnt5].mnemonic_type_cd
      = "Rx Mnemonic"
    ENDIF
    IF ((orig_data->qual[i].generic_name != ""))
     SET cnt5 = (cnt5+ 1)
     SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic,cnt5)
     SET data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic[cnt5].mnemonic =
     orig_data->qual[i].generic_name
     SET data_request->meds[cnt1].meddefqual[cnt2].ordcat[cnt4].qual_mnemonic[cnt5].mnemonic_type_cd
      = "Primary"
    ENDIF
   ENDIF
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual,2)
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual,
    4)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[1].value =
   orig_data->qual[i].generic_name
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[1].
   med_identifier_type_cd = "Generic Name"
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[2].value =
   orig_data->qual[i].mnemonic
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[2].
   med_identifier_type_cd = "Short Description"
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[3].value =
   orig_data->qual[i].description
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[3].
   med_identifier_type_cd = "Description"
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[4].value = build
   (orig_data->qual[i].description,char(9),"-",char(9),orig_data->qual[i].mnemonic,
    " - Inpatient - All - Active")
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medidentifierqual[4].
   med_identifier_type_cd = "RX Unique ID"
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual,
    2)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].parent_entity
    = "MED_OE_DEFAULTS"
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
    medflexobjidxqual[1].medoedefaultsqual,1)
   SET str_len = 0
   SET pos = 0
   SET val1 = ""
   SET val2 = ""
   SET val1 = piece(orig_data->qual[i].dose,"_",1,"")
   SET str_len = textlen(orig_data->qual[i].dose)
   SET pos = findstring("_",orig_data->qual[i].dose)
   SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].dose)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].strength = val1
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].strength_unit_cd = val2
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].comment1_text = orig_data->qual[i].notes1
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].sig_codes = orig_data->qual[i].sig
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].frequency_cd = orig_data->qual[i].frequency
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual[1].route_cd = orig_data->qual[i].route
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].parent_entity
    = "MED_PRODUCT"
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
    medflexobjidxqual[2].medproductqual,1)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
   medproductqual[1].manufacturer_cd = orig_data->qual[i].maufacturer
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
    medflexobjidxqual[2].medproductqual[1].medidentifierqual,4)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
   medproductqual[1].medidentifierqual[1].value = orig_data->qual[i].ndc
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
   medproductqual[1].medidentifierqual[2].value = orig_data->qual[i].brand_name
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
   medproductqual[1].medidentifierqual[3].value = build(orig_data->qual[i].generic_name,char(9),
    orig_data->qual[i].strength,char(9),orig_data->qual[i].dosage_form)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
   medproductqual[1].medidentifierqual[4].value = build(orig_data->qual[i].generic_name,char(9),
    replace(orig_data->qual[i].strength,"_"," "),char(9),orig_data->qual[i].dosage_form,
    " -  - Inpatient - All - Active - ",char(9),orig_data->qual[i].ndc)
   SET cnt6 = 0
   IF ((orig_data->qual[i].package != ""))
    SET cnt6 = (cnt6+ 1)
    SET val1 = ""
    SET val2 = ""
    SET str_len = 0
    SET pos = 0
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
     medflexobjidxqual[2].medproductqual[1].pack,cnt6)
    SET val1 = piece(orig_data->qual[i].package,"_",1,"")
    SET str_len = textlen(orig_data->qual[i].package)
    SET pos = findstring("_",orig_data->qual[i].package)
    SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].package)
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].qty = val1
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].uom_cd = val2
   ENDIF
   IF ((orig_data->qual[i].outer_pakcage != ""))
    SET cnt6 = (cnt6+ 1)
    SET val1 = ""
    SET val2 = ""
    SET str_len = 0
    SET pos = 0
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
     medflexobjidxqual[2].medproductqual[1].pack,cnt6)
    SET val1 = piece(orig_data->qual[i].outer_pakcage,"_",1,"")
    SET str_len = textlen(orig_data->qual[i].outer_pakcage)
    SET pos = findstring("_",orig_data->qual[i].outer_pakcage)
    SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].outer_pakcage)
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].qty = val1
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].uom_cd = val2
   ENDIF
   IF ((orig_data->qual[i].base_package_unit != ""))
    SET cnt6 = (cnt6+ 1)
    SET val1 = ""
    SET val2 = ""
    SET str_len = 0
    SET pos = 0
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
     medflexobjidxqual[2].medproductqual[1].pack,cnt6)
    SET val1 = piece(orig_data->qual[i].base_package_unit,"_",1,"")
    SET str_len = textlen(orig_data->qual[i].base_package_unit)
    SET pos = findstring("_",orig_data->qual[i].base_package_unit)
    SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].base_package_unit)
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].qty = val1
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].pack[cnt6].uom_cd = val2
   ENDIF
   SET cnt7 = 0
   IF ((orig_data->qual[i].base_awp != ""))
    SET cnt7 = (cnt7+ 1)
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].
     medflexobjidxqual[2].medproductqual[1].medcosthxqual,cnt7)
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].medcosthxqual[cnt7].cost = orig_data->qual[i].base_awp
   ENDIF
   SET cnt8 = 0
   IF ((orig_data->qual[i].dispense_qty != ""))
    SET cnt8 = (cnt8+ 1)
    SET val1 = ""
    SET val2 = ""
    SET str_len = 0
    SET pos = 0
    SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].pack,cnt8)
    SET val1 = piece(orig_data->qual[i].dispense_qty,"_",1,"")
    SET str_len = textlen(orig_data->qual[i].dispense_qty)
    SET pos = findstring("_",orig_data->qual[i].dispense_qty)
    SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].dispense_qty)
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].pack[cnt8].qty = val1
    SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].pack[cnt8].uom_cd = val2
   ENDIF
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual,
    2)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].parent_entity
    = "MED_DISPENSE"
   SET stat = alterlist(data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].
    medflexobjidxqual[1].meddispensequal,1)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].
   meddispensequal.legal_status_cd = orig_data->qual[i].legal_status
   CALL echo("Legal")
   CALL echo(orig_data->qual[i].legal_status)
   SET val1 = ""
   SET val2 = ""
   SET str_len = 0
   SET pos = 0
   SET val1 = piece(orig_data->qual[i].disp_stregnth,"_",1,"")
   SET str_len = textlen(orig_data->qual[i].disp_stregnth)
   SET pos = findstring("_",orig_data->qual[i].disp_stregnth)
   SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].disp_stregnth)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].
   meddispensequal[1].strength = val1
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].
   meddispensequal[1].strength_unit_cd = val2
   SET val1 = ""
   SET val2 = ""
   SET str_len = 0
   SET pos = 0
   SET val1 = piece(orig_data->qual[i].disp_volume,"_",1,"")
   SET str_len = textlen(orig_data->qual[i].disp_volume)
   SET pos = findstring("_",orig_data->qual[i].disp_volume)
   SET val2 = substring((pos+ 1),str_len,orig_data->qual[i].disp_volume)
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].
   meddispensequal[1].volume = val1
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[1].
   meddispensequal[1].volume_unit_cd = val2
   SET data_request->meds[cnt1].meddefqual[cnt2].meddefflexqual[2].medflexobjidxqual[2].parent_entity
    = ""
 ENDFOR
 SET pha_cnt = 0
 SET pha_size = size(data_request->meds,5)
 FOR (pha_cnt = 1 TO pha_size)
   SET request->item_group_active_ind = 0
   SET request->item1_id = 0.00
   SET request->item2_id = 0.00
   SET request->tag1 = 0.00
   SET request->cost1 = 0.00
   SET request->cost2 = 0.00
   SET request->awp = 0.00
   SET request->nbr_packs_to_chg = 0
   SET request->nbr_packs_to_add = 0
   SET request->id_type_cd = 0.00
   SET request->prep_into_flag = 0
   SET request->catalog_type_disp = ""
   SET request->iv_ingredient_ind = 0
   SET request->gcr_desc = ""
   SET request->package_type_id = 0.00
   SET request->order_alert1_cd = 0.00
   SET request->order_alert2_cd = 0.00
   SET request->side_effect_code = ""
   SET request->primary_manf_item_id = 0.00
   SET request->nbr_ids_to_add = 0
   SET request->comment1_text = ""
   SET request->comment2_text = ""
   SET request->compound_text = ""
   SET request->countable_ind = 0
   SET request->fda_reportable_ind = 0
   SET request->active_status_cd = 0.00
   SET request->shelf_life = 0
   SET request->shelf_life_uom_cd = 0.00
   SET request->component_usage_ind = 0
   SET request->component_ind = 0
   SET request->quickadd_ind = 0
   SET request->approved_ind = 0
   SET request->item_type_cd = 0.00
   SET request->db_rec_status = 0
   SET request->prod_rec_status = 3
   SET request->manf_rec_status = 0
   SET request->prod_id_rec_status = 3
   SET request->oc_rec_status = 0
   SET request->sent_rec_status = 3
   SET request->pack_rec_status = 3
   SET pha_cnt1 = 0
   SET meddefqual_size = size(data_request->meds[pha_cnt].meddefqual,5)
   FOR (pha_cnt1 = 1 TO meddefqual_size)
     SET stat = alterlist(request->meddefqual,pha_cnt1)
     SET request->meddefqual[pha_cnt1].gfc_description = data_request->meds[pha_cnt].meddefqual[
     pha_cnt1].gfc_description
     SET request->meddefqual[pha_cnt1].active_status_cd = active_var
     SET request->meddefqual[pha_cnt1].updt_cnt = 0
     SET request->meddefqual[pha_cnt1].db_rec_status = 3
     SET request->meddefqual[pha_cnt1].med_type_flag = 0
     SET request->meddefqual[pha_cnt1].item_id = 0.00
     SELECT INTO "nl:"
      n.nomenclature_id
      FROM nomenclature n
      PLAN (n
       WHERE (n.source_string=request->meddefqual[pha_cnt1].gfc_description)
        AND n.principle_type_cd=gen_form_var
        AND n.active_ind=1)
      ORDER BY n.nomenclature_id
      HEAD n.nomenclature_id
       request->meddefqual[pha_cnt1].mdx_gfc_nomen_id = n.nomenclature_id, request->meddefqual[
       pha_cnt1].cki = concat("MUL.FRMLTN!",n.source_identifier)
      WITH nocounter
     ;end select
     SET request->meddefqual[pha_cnt1].form_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
      pha_cnt1].form_cd,4002)
     SET request->meddefqual[pha_cnt1].strength = cnvtint(data_request->meds[pha_cnt].meddefqual[
      pha_cnt1].strength)
     SET request->meddefqual[pha_cnt1].strength_unit_cd = getcodevalue(data_request->meds[pha_cnt].
      meddefqual[pha_cnt1].strength_unit_cd,54)
     SET request->meddefqual[pha_cnt1].volume = 0.00
     SET request->meddefqual[pha_cnt1].volume_unit_cd = 0.00
     SET request->meddefqual[pha_cnt1].given_strength = data_request->meds[pha_cnt].meddefqual[
     pha_cnt1].given_strength
     SET request->meddefqual[pha_cnt1].meq_factor = 0.00
     SET request->meddefqual[pha_cnt1].mmol_factor = 0.00
     SET request->meddefqual[pha_cnt1].compound_text_id = 0.00
     SET request->meddefqual[pha_cnt1].compound_text = ""
     SET request->meddefqual[pha_cnt1].comment1_text = ""
     SET request->meddefqual[pha_cnt1].comment2_text = ""
     SET request->meddefqual[pha_cnt1].comment1_id = 0.00
     SET request->meddefqual[pha_cnt1].comment2_id = 0.00
     SET request->meddefqual[pha_cnt1].schedulable_ind = 0
     SET request->meddefqual[pha_cnt1].reusable_ind = 0
     SET request->meddefqual[pha_cnt1].cdm = ""
     SET request->meddefqual[pha_cnt1].critical_ind = 0
     SET request->meddefqual[pha_cnt1].sub_account_cd = 0.00
     SET request->meddefqual[pha_cnt1].cost_center_cd = 0.00
     SET request->meddefqual[pha_cnt1].storage_requirement_cd = 0.00
     SET request->meddefqual[pha_cnt1].sterilization_required_ind = 0
     SET request->meddefqual[pha_cnt1].base_issue_factor = 1.00
     SET request->meddefqual[pha_cnt1].active_ind = 1
     SET request->meddefqual[pha_cnt1].package_type_id = 0.00
     SET request->meddefqual[pha_cnt1].template_catalog_cd = 0.00
     SET request->meddefqual[pha_cnt1].template_synonym_id = 0.00
     SET request->meddefqual[pha_cnt1].primary_synonym_mnemonic = ""
     SET pha_cnt2 = 0
     SET meddefqual_pack_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].pack,5)
     FOR (pha_cnt2 = 1 TO meddefqual_pack_size)
       SET stat = alterlist(request->meddefqual[pha_cnt1].pack,pha_cnt2)
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].item_id = 0.00
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].description = replace(data_request->meds[
        pha_cnt].meddefqual[pha_cnt1].pack[pha_cnt2].description,"_"," ")
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].uom_cd = getcodevalue(data_request->meds[
        pha_cnt].meddefqual[pha_cnt1].pack[pha_cnt2].uom_cd,54)
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].base_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].qty = cnvtint(data_request->meds[pha_cnt].
        meddefqual[pha_cnt1].pack[pha_cnt2].qty)
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].base_package_type_ind = 1
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].active_ind = 1
       SET request->meddefqual[pha_cnt1].pack[pha_cnt2].updt_cnt = 0
     ENDFOR
     SET pha_cnt3 = 0
     SET meddefqual_ordcat_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat,5)
     FOR (pha_cnt3 = 1 TO meddefqual_ordcat_size)
       SET stat = alterlist(request->meddefqual[pha_cnt1].ordcat,pha_cnt3)
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].prep_into_flag = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].db_rec_status = 0
       SELECT INTO "nl:"
        n.nomenclature_id
        FROM nomenclature n
        PLAN (n
         WHERE (n.source_string=data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat[pha_cnt3].
         gcr_desc)
          AND n.active_ind=1
          AND n.end_effective_dt_tm > sysdate
          AND n.source_vocabulary_cd=mul_drug_var)
        ORDER BY n.nomenclature_id
        HEAD n.nomenclature_id
         request->meddefqual[pha_cnt1].ordcat[pha_cnt3].mdx_gcr_nomen_id = n.nomenclature_id, source
          = n.source_identifier
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        n.source_string
        FROM nomenclature n
        PLAN (n
         WHERE n.source_identifier=source
          AND ((n.principle_type_cd=genname_var
          AND n.source_vocabulary_cd=mul_drug_var) OR (n.principle_type_cd=genform_var
          AND n.source_vocabulary_cd=mul_mmdc_var))
          AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
          AND n.primary_vterm_ind=1)
        ORDER BY n.nomenclature_id
        HEAD n.nomenclature_id
         request->meddefqual[pha_cnt1].ordcat[pha_cnt3].description = n.source_string
        WITH nocounter
       ;end select
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].catalog_cd = getcodevalue(request->
        meddefqual[pha_cnt1].ordcat[pha_cnt3].description,200)
       SET catalod_code = request->meddefqual[pha_cnt1].ordcat[pha_cnt3].catalog_cd
       SELECT INTO "nl:"
        oc.updt_cnt, oc.oe_format_id, oc.cki
        FROM order_catalog oc
        WHERE oc.catalog_cd=catalod_code
         AND oc.active_ind=1
        HEAD oc.catalog_cd
         request->meddefqual[pha_cnt1].ordcat[pha_cnt3].updt_cnt = oc.updt_cnt, request->meddefqual[
         pha_cnt1].ordcat[pha_cnt3].oe_format_id = oc.oe_format_id, request->meddefqual[pha_cnt1].
         ordcat[pha_cnt3].cki = oc.cki,
         request->meddefqual[pha_cnt1].ordcat[pha_cnt3].requisition_routing_cd = oc
         .requisition_routing_cd
        WITH nocounter
       ;end select
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].consent_form_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].active_ind = 1
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].catalog_type_cd = pharmacy_var
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].catalog_type_disp = "Pharmacy"
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].activity_type_cd = phar_act_var
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].activity_subtype_cd = 0.00
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].requisition_format_cd = rxreqsn_var
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].inst_restriction_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].schedule_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].iv_ingredient_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].print_req_ind = 1
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].orderable_type_flag = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].complete_upon_order_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].quick_chart_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].comment_template_flag = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].prep_info_flag = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].valid_iv_additive_ind = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].dc_display_days = - (1)
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].dc_interaction_days = - (1)
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].op_dc_display_days = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].op_dc_interaction_days = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].set_op_days = 0
       SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].gcr_desc = data_request->meds[pha_cnt].
       meddefqual[pha_cnt1].ordcat[pha_cnt3].gcr_desc
       SET pha_cnt4 = 0
       SET ahfs_qual_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat[pha_cnt3].
        ahfs_qual,5)
       FOR (pha_cnt4 = 1 TO ahfs_qual_size)
        SET stat = alterlist(request->meddefqual[pha_cnt1].ordcat[pha_cnt3].ahfs_qual,pha_cnt4)
        SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].ahfs_qual[pha_cnt4].ahfs_code = "000000"
       ENDFOR
       SET pha_cnt5 = 0
       SET qual_mnem_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat[pha_cnt3].
        qual_mnemonic,5)
       FOR (pha_cnt5 = 1 TO qual_mnem_size)
         SET stat = alterlist(request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic,pha_cnt5)
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].db_rec_status = 3
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].item_id = 0.00
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].synonym_id = 0.00
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].mnemonic =
         data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].
         mnemonic
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].mnemonic_type_cd
          = getcodevalue(data_request->meds[pha_cnt].meddefqual[pha_cnt1].ordcat[pha_cnt3].
          qual_mnemonic[pha_cnt5].mnemonic_type_cd,6011)
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].synonym_cki = ""
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].active_ind = 1
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].order_sentence_id
          = 0.00
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].
         orderable_type_flag = 0
         SET request->meddefqual[pha_cnt1].ordcat[pha_cnt3].qual_mnemonic[pha_cnt5].updt_cnt = 0
       ENDFOR
     ENDFOR
     SET pha_cnt6 = 0
     SET meddefflex_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual,5)
     FOR (pha_cnt6 = 1 TO meddefflex_size)
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual,pha_cnt6)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].db_rec_status = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].sequence = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].flex_type_cd = system_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].flex_sort_flag = flag_600
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].active_status_cd = active_var
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack,1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].description = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].base_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].qty = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].base_package_type_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[1].updt_cnt = 0
       SET pha_cnt8 = 0
       SET medidentifier_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[
        pha_cnt6].medidentifierqual,5)
       FOR (pha_cnt8 = 1 TO medidentifier_size)
         SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].
          medidentifierqual,pha_cnt8)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         salable_by_vendor_ind = 0
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         salable_by_mfr_ind = 0
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         id_type_cd = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         db_rec_status = 3
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         package_type_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         med_def_flex_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         flex_sort_flag = flag_600
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         med_identifier_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         order_set_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         item_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         med_product_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         sequence = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         pharmacy_type_cd = inpatient_var
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         parent_entity_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         parent_entity = ""
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         flex_type_cd = system_var
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         med_identifier_type_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
          meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].med_identifier_type_cd,11000)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].value
          = data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].
         medidentifierqual[pha_cnt8].value
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         value_key = ""
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         med_type_flag = 0
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         active_ind = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         primary_ind = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medidentifierqual[pha_cnt8].
         updt_cnt = 0
       ENDFOR
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual,
        2)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].db_rec_status
        = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       med_flex_object_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].parent_entity
        = "MED_OE_DEFAULTS"
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       flex_object_type_cd = oedefault_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].value = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].value_unit =
       0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].updt_cnt = 0
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        1].meddispensequal,0)
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        1].medoedefaultsqual,1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].freetext_dose = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].diluent_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].diluent_volume = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment1_text = data_request->meds[pha_cnt].meddefqual[pha_cnt1].
       meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].comment1_text
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment2_text = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].default_par_doses = - (1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].max_par_supply = - (1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].med_oe_defaults_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].strength = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].strength)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].strength_unit_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].strength_unit_cd,
        54)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].volume = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].volume_unit_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].route_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].route_cd,4001)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].frequency_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].frequency_cd,
        4003)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].prn_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].prn_reason_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].infuse_over = - (1.00)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].infuse_over_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].duration = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].duration_unit_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].stop_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].dispense_category_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].alternate_dispense_category_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment1_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment1_type = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment2_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].comment2_type = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].price_sched_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].rx_qty = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].daw_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].sig_codes = data_request->meds[pha_cnt].meddefqual[pha_cnt1].
       meddefflexqual[pha_cnt6].medflexobjidxqual[1].medoedefaultsqual[1].sig_codes
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].nbr_labels = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].ord_as_synonym_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].rate = - (1.00)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].rate_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].normalized_rate = - (1.00)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].normalized_rate_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].freetext_rate = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       medoedefaultsqual[1].grace_period_days = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].db_rec_status
        = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       med_flex_object_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].parent_entity
        = "MED_PRODUCT"
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       flex_object_type_cd = medproduct_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].value = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].value_unit =
       0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].updt_cnt = 0
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        2].medproductqual,1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].primary_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].med_product_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].manf_item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].bio_equiv_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].brand_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].med_def_cki = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].unit_dose_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].manufacturer_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].medproductqual[1].manufacturer_cd,221
        )
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].awp_factor = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].schedulable_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].reusable_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].critical_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].sub_account_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].cost_center_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].storage_requirement_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].sterilization_required_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].base_issue_factor = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].formulary_status_cd = formulary_var
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        2].medproductqual[1].medidentifierqual,4)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].salable_by_vendor_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].salable_by_mfr_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].id_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].flex_sort_flag = flag_600
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].med_identifier_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].order_set_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].med_product_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].flex_type_cd = system_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].med_identifier_type_cd = ndc_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].value = data_request->meds[pha_cnt].meddefqual[pha_cnt1
       ].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medidentifierqual[1].value
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].value_key = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].med_type_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].primary_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[1].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].salable_by_vendor_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].salable_by_mfr_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].id_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].flex_sort_flag = flag_600
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].med_identifier_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].order_set_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].med_product_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].flex_type_cd = system_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].med_identifier_type_cd = brand_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].value = data_request->meds[pha_cnt].meddefqual[pha_cnt1
       ].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medidentifierqual[2].value
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].value_key = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].med_type_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].primary_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[2].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].salable_by_vendor_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].salable_by_mfr_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].id_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].flex_sort_flag = flag_600
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].med_identifier_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].order_set_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].med_product_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].flex_type_cd = system_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].med_identifier_type_cd = description_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].value = data_request->meds[pha_cnt].meddefqual[pha_cnt1
       ].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medidentifierqual[3].value
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].value_key = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].med_type_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].primary_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[3].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].salable_by_vendor_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].salable_by_mfr_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].id_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].flex_sort_flag = flag_600
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].med_identifier_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].order_set_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].med_product_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].flex_type_cd = system_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].med_identifier_type_cd = rxuniqueid_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].value = data_request->meds[pha_cnt].meddefqual[pha_cnt1
       ].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medidentifierqual[4].value
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].value_key = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].med_type_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].primary_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].medidentifierqual[4].updt_cnt = 0
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        2].medproductqual[1].pack,3)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].uom_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].uom_cd,54)
       SET display1 = data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[1].
       medflexobjidxqual[2].medproductqual[1].pack[1].uom_cd
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].base_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].qty = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].qty)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].description = build(display1,char(9),"of",char(9),cnvtint(request->
         meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].medproductqual[1].pack[1]
         .qty),
        char(9),display1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].base_package_type_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[1].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].uom_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].uom_cd,54)
       SET display2 = data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[1].
       medflexobjidxqual[2].medproductqual[1].pack[2].uom_cd
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].base_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].qty = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].qty)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].description = build(display2,char(9),"of",char(9),cnvtint(request->
         meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].medproductqual[1].pack[2]
         .qty),
        char(9),display1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].base_package_type_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[2].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].description = "1 mL"
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].uom_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].uom_cd,54)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].base_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].qty = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].qty)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].base_package_type_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       medproductqual[1].pack[3].updt_cnt = 0
       SET pha_cnt11 = 0
       SET medcosthx_size = size(data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[
        pha_cnt6].medflexobjidxqual[2].medproductqual[1].medcosthxqual,5)
       FOR (pha_cnt11 = 1 TO medcosthx_size)
         SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].
          medflexobjidxqual[2].medproductqual[1].medcosthxqual,pha_cnt11)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].db_rec_status = 3
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].med_cost_hx_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].med_product_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].cost_type_cd = awp_var
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"
          )
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].cost = cnvtint(data_request->meds[pha_cnt].meddefqual[
          pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
          pha_cnt11].cost)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].active_ind = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].updt_cnt = 0
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].updt_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].medcosthxqual[1].updt_dt_tm = cnvtdatetime(curdate,curtime3)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].inv_factor_nbr = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
         medproductqual[1].inv_base_pkg_uom_cd = 0.00
       ENDFOR
       SET pha_cnt6 = (pha_cnt6+ 1)
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual,pha_cnt6)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].db_rec_status = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].sequence = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].flex_type_cd = syspkgtyp_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].flex_sort_flag = flag_500
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].parent_med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].active_status_cd = active_var
       SET pha_cnt12 = 0
       SET medflex_size = alterlist(data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[
        pha_cnt6].pack,5)
       FOR (pha_cnt12 = 1 TO medflex_size)
         SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack,pha_cnt12)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].db_rec_status = 3
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].item_id = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].package_type_id
          = 0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].uom_cd =
         getcodevalue(data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[
          pha_cnt12].uom_cd,54)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].description =
         data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].
         uom_cd
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].base_uom_cd =
         0.00
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].qty = cnvtint(
          data_request->meds[pha_cnt].meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].
          qty)
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].
         base_package_type_ind = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].active_ind = 1
         SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].pack[pha_cnt12].updt_cnt = 0
       ENDFOR
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual,
        2)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].db_rec_status
        = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       med_flex_object_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].sequence = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].parent_entity
        = "MED_DISPENSE"
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       flex_object_type_cd = dispense_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].value = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].value_unit =
       0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].updt_cnt = 0
       SET stat = alterlist(request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[
        1].meddispensequal,1)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].pharmacy_type_cd = inpatient_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].pat_orderable_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].db_rec_status = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].med_dispense_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].package_type_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].package_type_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].parent_entity = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].flex_type_cd = syspkgtyp_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].flex_sort_flag = flag_500
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].legal_status_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].meddispensequal[1].legal_status_cd,
        4200)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].formulary_status_cd = formulary_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].oe_format_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].med_filter_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].continuous_filter_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].intermittent_filter_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_filter_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].max_par_supply = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].infinite_div_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].divisible_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].used_as_base_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].always_dispense_from_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].dispense_qty = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].dispense_factor = 1.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].label_ratio = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].reusable_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].strength = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[pha_cnt6].medflexobjidxqual[1].meddispensequal[1].strength)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].strength_unit_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].meddispensequal[1].strength_unit_cd,
        54)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].volume = cnvtint(data_request->meds[pha_cnt].meddefqual[pha_cnt1].
        meddefflexqual[pha_cnt6].medflexobjidxqual[1].meddispensequal[1].volume)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].volume_unit_cd = getcodevalue(data_request->meds[pha_cnt].meddefqual[
        pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].meddispensequal[1].volume_unit_cd,54)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].base_issue_factor = 1.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].updt_cnt = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].pkg_qty_per_pkg = - (1.00)
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].pkg_disp_more_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].override_clsfctn_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].rx_station_notes = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].rx_station_notes_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_dispense_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_return_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_adhoc_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_override_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_waste_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].workflow_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_balance_method_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_chloride_pct = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_default_ingred_item_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_fill_method_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_include_ions_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_overfill_amt = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_overfill_unit_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_preferred_cation_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_product_type_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].tpn_scale_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].lot_tracking_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].poc_charge_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_inv_count_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_empty_return_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_expire_mgmt_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_adhoc_refill_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].witness_sched_task_ind = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].prod_assign_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].billing_factor_nbr = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].billing_uom_cd = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[1].
       meddispensequal[1].skip_dispense_flag = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].db_rec_status
        = 3
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       med_def_flex_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       med_flex_object_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       parent_entity_id = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].sequence = 0
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].parent_entity
        = ""
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].
       flex_object_type_cd = orderable_var
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].value = 0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].value_unit =
       0.00
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].active_ind = 1
       SET request->meddefqual[pha_cnt1].meddefflexqual[pha_cnt6].medflexobjidxqual[2].updt_cnt = 0
     ENDFOR
     SET request->meddefqual[pha_cnt1].premix_ind = 0
     SET request->meddefqual[pha_cnt1].inv_factor_nbr = 0.00
     SET request->meddefqual[pha_cnt1].inv_base_pkg_uom_cd = 0.00
     SET request->meddefqual[pha_cnt1].inv_tracking_level = 0
     SET request->meddefqual[pha_cnt1].lot_tracking_ind = 0
   ENDFOR
   SET request->total_ids_to_add = 0
   SET request->total_ids_to_chg = 0
   SET request->total_ids_to_del = 0
   SET request->total_packs_to_add = 0
   SET request->total_packs_to_chg = 0
   SET request->total_packs_to_del = 0
   SET request->total_packs_to_rmv = 0
   SET request->item_id = 0.00
   SET request->consent_form_ind = 0
   SET request->active_ind = 0
   SET request->catalog_cd = 0.00
   SET request->catalog_type_cd = 0.00
   SET request->activity_type_cd = 0.00
   SET request->activity_subtype_cd = 0.00
   SET request->requisition_format_cd = 0.00
   SET request->requisition_routing_cd = 0.00
   SET request->inst_restriction_ind = 0
   SET request->schedule_ind = 0
   SET request->description = ""
   SET request->print_req_ind = 0
   SET request->oe_format_id = 0.00
   SET request->orderable_type_flag = 0
   SET request->complete_upon_order_ind = 0
   SET request->quick_chart_ind = 0
   SET request->comment_template_flag = 0
   SET request->prep_info_flag = 0
   SET request->orc_text = ""
   SET request->valid_iv_additive_ind = 0
   SET request->dc_display_days = 0
   SET request->dc_interaction_days = 0
   SET request->op_dc_display_days = 0
   SET request->op_dc_interaction_days = 0
   SET request->set_op_days = 0
   SET request->mdx_gcr_nomen_id = 0.00
   SET request->mnemonic = ""
   SET request->mnemonic_type_cd = 0.00
   SET request->order_sentence_id = 0.00
   SET request->mnem_active_ind = 0
   SET request->cki = ""
   SET request->syn_add_cnt = 0
   SET request->syn_upd_cnt = 0
   SET request->sent_cnt = 0
   SET request->updt_cnt = 0
   SET request->location_group_type_cd = 0.00
   SET request->root_loc_cd = 0.00
   SET request->max_loc_cnt = 0
   SET request->get_fullpath_flag = 0
   SET request->get_ic_flag = 0
   SET request->get_ac_flag = 0
   SET request->get_qr_flag = 0
   SET request->get_st_flag = 0
   SET request->get_qh_flag = 0
   SET request->get_locator_flag = 0
   SET request->get_path_flag = 0
   SET request->get_pk_flag = 0
   SET request->get_rel_path_flag = 0
   SET request->replacement_upn_id = 0.00
   SET request->synonym_id = 0.00
   SET request->synonym_cki = ""
   SET request->nbr_of_add_locator = 0
   SET request->nbr_of_del_locator = 0
   SET request->view_type_cd = 0.00
   CALL echorecord(request)
   EXECUTE rxa_add_medproduct:dba
 ENDFOR
 SELECT INTO "ams_pha_add_med_prod_output.csv"
  ndc = mi.value, mnemonic = orig_data->qual[d1.seq].mnemonic, generic_name = orig_data->qual[d1.seq]
  .generic_name,
  description = orig_data->qual[d1.seq].description, brand = orig_data->qual[d1.seq].brand_name
  FROM (dummyt d1  WITH seq = size(orig_data->qual,5)),
   med_identifier mi
  PLAN (d1)
   JOIN (mi
   WHERE (mi.value=orig_data->qual[d1.seq].ndc)
    AND mi.med_identifier_type_cd=ndc_var)
  WITH separator = ",", format
 ;end select
 SELECT INTO  $1
  "Output values has been saved in a file named ams_pha_add_med_prod_output.csv"
  FROM dummyt
  WITH separator = " ", format
 ;end select
 SUBROUTINE getcodevalue(string,codeset)
   DECLARE codevalue = f8
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE ((cv.display_key=cnvtupper(cnvtalphanum(string))) OR (((cv.display=string) OR (cv
     .description=string)) ))
      AND cv.active_ind=1
      AND cv.code_set=codeset)
    HEAD cv.code_value
     codevalue = cv.code_value
    WITH nocounter
   ;end select
   RETURN(codevalue)
 END ;Subroutine
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
