CREATE PROGRAM ams_pha_iv_sets_add_procedures:dba
 DECLARE controlled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4200,"2")), protect
 DECLARE ea_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",54,"Each")), protect
 DECLARE dispense_cd = f8 WITH constant(uar_get_code_by("MEANING",4063,"DISPENSE")), protect
 DECLARE orderable_cd = f8 WITH constant(uar_get_code_by("MEANING",4063,"ORDERABLE")), protect
 DECLARE desc_short_cd = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC_SHORT")), protect
 DECLARE rx_uniqueid_cd = f8 WITH constant(uar_get_code_by("MEANING",11000,"RX_UNIQUEID")), protect
 DECLARE desc_cd = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC")), protect
 DECLARE syspkgtyp_cd = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP")), protect
 DECLARE inpatient_cd = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE system_cd = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSTEM")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE formulary_cd = f8 WITH constant(uar_get_code_by("MEANING",4512,"FORMULARY")), protect
 DECLARE ii1 = i4
 FREE RECORD reply_340200
 RECORD reply_340200(
   1 meddefqual[*]
     2 med_type_flag = i2
     2 item_id = f8
     2 mdx_gfc_nomen_id = f8
     2 form_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 given_strength = vc
     2 meq_factor = f8
     2 mmol_factor = f8
     2 compound_text_id = f8
     2 compound_text = vc
     2 cki = vc
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
     2 updt_cnt = i4
     2 group_rx_mnem = vc
     2 parent_item_id = f8
     2 inv_master_id = f8
     2 pha_type_flag = i2
     2 pack[*]
       3 item_id = f8
       3 description = c40
       3 uom_cd = f8
       3 base_uom_cd = f8
       3 qty = f8
       3 package_type_id = f8
       3 base_package_type_ind = i2
       3 active_ind = i2
       3 updt_cnt = i4
     2 medingredqual[*]
       3 med_ingred_set_id = f8
       3 parent_item_id = f8
       3 sequence = i4
       3 child_item_id = f8
       3 catalog_cd = f8
       3 child_med_prod_id = f8
       3 child_pkg_type_id = f8
       3 inc_in_total_ind = i2
       3 base_ind = i2
       3 cmpd_qty = f8
       3 default_action_cd = f8
       3 updt_cnt = i4
       3 mnemonic = vc
       3 desc = vc
       3 pack[1]
         4 item_id = f8
         4 description = c40
         4 uom_cd = f8
         4 base_uom_cd = f8
         4 qty = f8
         4 package_type_id = f8
         4 base_package_type_ind = i2
         4 active_ind = i2
         4 updt_cnt = i4
       3 normalized_rate_ind = i2
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
     2 locqual[*]
       3 db_rec_status = i2
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
       3 updt_cnt = i4
     2 ordcat[1]
       3 item_id = f8
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
       3 mdx_gcr_nomen_id = f8
       3 cki = vc
       3 gcr_desc = vc
       3 ahfs_qual[*]
         4 alt_sel_category_id = f8
         4 ahfs_code = vc
       3 qual_mnemonic[*]
         4 item_id = f8
         4 db_rec_status = i2
         4 synonym_id = f8
         4 mnemonic = vc
         4 mnemonic_type_cd = f8
         4 active_ind = i2
         4 order_sentence_id = f8
         4 orderable_type_flag = i2
         4 synonym_cki = vc
         4 updt_cnt = i4
     2 meddefflexqual[*]
       3 med_def_flex_id = f8
       3 parent_entity_id = f8
       3 parent_entity = vc
       3 sequence = i4
       3 flex_type_cd = f8
       3 flex_sort_flag = i4
       3 pharmacy_type_cd = f8
       3 parent_med_def_flex_id = f8
       3 package_type_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 medidentifierqual[*]
         4 med_identifier_id = f8
         4 order_set_id = f8
         4 item_id = f8
         4 med_def_flex_id = f8
         4 package_type_id = f8
         4 med_product_id = f8
         4 sequence = i4
         4 pharmacy_type_cd = f8
         4 parent_entity_id = f8
         4 parent_entity = vc
         4 flex_type_cd = f8
         4 flex_sort_flag = i4
         4 med_identifier_type_cd = f8
         4 value = vc
         4 value_key = vc
         4 med_type_flag = i2
         4 active_ind = i2
         4 primary_ind = i2
         4 updt_cnt = i4
       3 pack[1]
         4 item_id = f8
         4 description = c40
         4 uom_cd = f8
         4 base_uom_cd = f8
         4 qty = f8
         4 package_type_id = f8
         4 base_package_type_ind = i2
         4 active_ind = i2
         4 updt_cnt = i4
       3 medflexobjidxqual[*]
         4 med_flex_object_id = f8
         4 med_def_flex_id = f8
         4 parent_entity_id = f8
         4 sequence = i4
         4 parent_entity = vc
         4 flex_object_type_cd = f8
         4 value = f8
         4 value_unit = f8
         4 active_ind = i2
         4 updt_cnt = i4
         4 meddispensequal[*]
           5 med_dispense_id = f8
           5 item_id = f8
           5 package_type_id = f8
           5 pharmacy_type_cd = f8
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
           5 divisible_ind = i2
           5 used_as_base_ind = i2
           5 always_dispense_from_flag = i2
           5 dispense_qty = f8
           5 dispense_factor = f8
           5 label_ratio = f8
           5 pat_orderable_ind = i2
           5 reusable_ind = i2
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 base_issue_factor = f8
           5 infinite_div_ind = i2
           5 updt_cnt = i4
           5 pkg_qty_per_pkg = f8
           5 pkg_disp_more_ind = i2
           5 override_clsfctn_cd = f8
           5 rx_station_notes = vc
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
           5 inv_factor_nbr = f8
           5 poc_charge_flag = i2
           5 witness_inv_count_ind = i2
           5 witness_adhoc_refill_ind = i2
           5 witness_empty_return_ind = i2
           5 witness_expire_mgmt_ind = i2
           5 witness_sched_task_ind = i2
           5 prod_assign_flag = i2
           5 billing_factor_nbr = f8
           5 billing_uom_cd = f8
           5 skip_dispense_flag = i2
         4 medoedefaultsqual[*]
           5 med_oe_defaults_id = f8
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 freetext_dose = vc
           5 route_cd = f8
           5 frequency_cd = f8
           5 prn_ind = i2
           5 prn_reason_cd = f8
           5 infuse_over = f8
           5 infuse_over_cd = f8
           5 duration = f8
           5 duration_unit_cd = f8
           5 stop_type_cd = f8
           5 default_par_doses = i4
           5 dispense_category_cd = f8
           5 alternate_dispense_category_cd = f8
           5 comment1_id = f8
           5 comment1_type = i2
           5 comment2_id = f8
           5 comment2_type = i2
           5 comment1_text = vc
           5 comment2_text = vc
           5 diluent_id = f8
           5 diluent_volume = f8
           5 price_sched_id = f8
           5 max_par_supply = i4
           5 active_ind = i2
           5 updt_cnt = i4
           5 rx_qty = f8
           5 daw_cd = f8
           5 sig_codes = vc
           5 nbr_labels = i4
           5 ord_as_synonym_id = f8
           5 ord_as_mnemonic = vc
           5 rate = f8
           5 rate_cd = f8
           5 normalized_rate = f8
           5 normalized_rate_cd = f8
           5 freetext_rate = vc
           5 grace_period_days = i4
         4 medproductqual[*]
           5 med_product_id = f8
           5 manf_item_id = f8
           5 item_master_id = f8
           5 inner_pkg_type_id = f8
           5 outer_pkg_type_id = f8
           5 bio_equiv_ind = i2
           5 cost_factor_nbr = f8
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
           5 base_uom_cd = f8
           5 medidentifierqual[*]
             6 med_identifier_id = f8
             6 med_def_flex_id = f8
             6 package_type_id = f8
             6 order_set_id = f8
             6 item_id = f8
             6 med_product_id = f8
             6 sequence = i4
             6 pharmacy_type_cd = f8
             6 parent_entity_id = f8
             6 parent_entity = vc
             6 flex_type_cd = f8
             6 flex_sort_flag = i4
             6 med_identifier_type_cd = f8
             6 value = vc
             6 value_key = vc
             6 med_type_flag = i2
             6 active_ind = i2
             6 primary_ind = i2
             6 updt_cnt = i4
           5 pack[*]
             6 item_id = f8
             6 description = c40
             6 uom_cd = f8
             6 base_uom_cd = f8
             6 qty = f8
             6 package_type_id = f8
             6 base_package_type_ind = i2
             6 active_ind = i2
             6 updt_cnt = i4
           5 medcosthxqual[*]
             6 med_cost_hx_id = f8
             6 med_product_id = f8
             6 cost_type_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 cost = f8
             6 active_ind = i2
             6 updt_cnt = i4
             6 updt_id = f8
             6 updt_name = vc
             6 updt_dt_tm = dq8
           5 storedat[*]
             6 location_cd = f8
           5 medproddescqual[*]
             6 med_prod_desc_id = f8
             6 field_type_cd = f8
             6 field_value_str_txt = vc
             6 updt_task = i4
             6 long_blob_id = f8
           5 inv_factor_nbr = f8
           5 inv_base_pkg_uom_cd = f8
           5 multi_lot_transfer_ind = i2
           5 pre_exp_date_period_nbr = f8
           5 pre_exp_date_uom_cd = f8
     2 tempingredqual[*]
       3 ndc = vc
       3 desc = vc
     2 premix_ind = i2
     2 volunitusedincompvolcalc = i2
     2 prodbaseuomcd = f8
     2 multi_lot_transfer_ind = i2
     2 pre_exp_date_period_nbr = f8
     2 pre_exp_date_uom_cd = f8
   1 debug[*]
     2 msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_340200
 RECORD request_340200(
   1 pharm_type_cd = f8
   1 qual[*]
     2 item_id = f8
   1 do_not_load_cost_ind = i2
 )
 FREE RECORD reply_340240
 RECORD reply_340240(
   1 meddefqual[*]
     2 item_id = f8
     2 compound_text_id = f8
     2 pack[*]
       3 package_type_id = f8
       3 qty = f8
     2 medingredqual[*]
       3 med_ingred_set_id = f8
     2 ordcat[1]
       3 catalog_cd = f8
       3 qual_mnemonic[*]
         4 synonym_id = f8
     2 meddefflexqual[*]
       3 med_def_flex_id = f8
       3 parent_entity_id = f8
       3 package_type_id = f8
       3 pack[1]
         4 package_type_id = f8
         4 qty = f8
       3 medidentifierqual[*]
         4 med_identifier_id = f8
         4 parent_entity_id = f8
       3 medflexobjidxqual[*]
         4 med_flex_object_id = f8
         4 parent_entity_id = f8
         4 meddispensequal[*]
           5 med_dispense_id = f8
           5 parent_entity_id = f8
         4 medoedefaultsqual[*]
           5 med_oe_defaults_id = f8
           5 comment1_id = f8
           5 comment2_id = f8
         4 medproductqual[*]
           5 med_product_id = f8
           5 manf_item_id = f8
           5 item_master_id = f8
           5 package_type_id = f8
           5 pack[*]
             6 package_type_id = f8
             6 qty = f8
             6 base_package_type_ind = i2
           5 medidentifierqual[*]
             6 med_identifier_id = f8
             6 parent_entity_id = f8
           5 medcosthxqual[*]
             6 med_cost_hx_id = f8
             6 updt_dt_tm = dq8
             6 updt_id = f8
           5 medproddescqual[*]
             6 med_prod_desc_id = f8
             6 field_type_cd = f8
             6 updt_dt_tm = dq8
   1 qual[*]
     2 med_def_flex_id = f8
     2 item_id = f8
     2 object_id = f8
     2 comment1_id = f8
     2 comment2_id = f8
     2 compound_text_id = f8
     2 object_type_cd = f8
     2 id_qual[*]
       3 identifier_id = f8
       3 identifier_type_cd = f8
       3 package_type_id = f8
     2 pack_qual[*]
       3 package_type_id = f8
   1 catalog_cd = f8
   1 catalog_type_cd = f8
   1 catalog_type_disp = c40
   1 activity_type_cd = f8
   1 description = vc
   1 cki = vc
   1 mdx_gcr_nomen_id = f8
   1 synonym_id = f8
   1 mnemonic = vc
   1 mnemonic_type_cd = f8
   1 mnem_active_ind = i2
   1 order_sentence_id = f8
   1 elapsed_time = f8
   1 parent_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 fullpath[*]
       3 location_cd = f8
   1 ic_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 ic_defined_at = f8
     2 stock_type_ind = i2
     2 stock_package_type_id = f8
     2 lot_tracking_level_cd = f8
     2 charge_type_cd = f8
     2 count_cycle_cd = f8
     2 instance_ind = i2
     2 abc_class_cd = f8
     2 cost_center_cd = f8
     2 sub_account_cd = f8
     2 ic_updt_cnt = i4
     2 full_path = vc
     2 short_full_path = vc
     2 list_role_id = f8
     2 sch_qty = i4
   1 ac_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 ac_defined_at = f8
     2 fill_location_cd = f8
     2 economic_order_qty = f8
     2 average_lead_time = i4
     2 average_lead_time_uom_cd = f8
     2 product_origin_cd = f8
     2 syscalc_eoq_ind = i2
     2 primary_vendor_cd = f8
     2 primary_vendor_item_id = f8
     2 primary_vendor_item_desc = vc
     2 reorder_package_type_id = f8
     2 ac_updt_cnt = i4
     2 full_path = vc
     2 short_full_path = vc
   1 qr_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 qr_defined_at = f8
     2 reorder_point = f8
     2 reorder_type_cd = f8
     2 minimum_level = f8
     2 maximum_level = f8
     2 average_daily_usage = f8
     2 average_weeks_order_qty = f8
     2 acc_stockout_freq_cd = f8
     2 last_syscalc_dt_tm = dq8
     2 max_days_adu = i4
     2 min_days_adu = i4
     2 reorder_method_cd = f8
     2 safety_stock_qty = f8
     2 seasonal_item_ind = i2
     2 syscalc_freq_nbr_days = i4
     2 syscalc_abc_class_ind = i2
     2 syscalc_reorder_point_ind = i2
     2 syscalc_safety_stock_ind = i2
     2 syscalc_par_level_ind = i2
     2 qr_updt_cnt = i4
     2 full_path = vc
     2 short_full_path = vc
   1 st_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 st_defined_at = f8
     2 st_updt_cnt = i4
     2 full_path = vc
     2 short_full_path = vc
   1 qh_qual[*]
     2 item_id = f8
     2 location_cd = f8
     2 qh_defined_at = f8
     2 full_path = vc
     2 short_full_path = vc
     2 qh_list[*]
       3 qoh_type_cd = f8
       3 package_type_id = f8
       3 qty = f8
       3 qh_updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
   1 ifailure_type = i2
   1 timers[1]
     2 mm_add_item_timer = f8
     2 orm_add_rx_oc_info = f8
     2 orm_upd_rx_oc_syn = f8
     2 rx_add_ahfs_list = f8
     2 mm_add_item_manf = f8
     2 mm_upd_object_id_relation = f8
   1 debug[*]
     2 msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_340240
 RECORD request_340240(
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
   1 side_effect_code = vc
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
     2 given_strength = vc
     2 meq_factor = f8
     2 mmol_factor = f8
     2 compound_text_id = f8
     2 compound_text = vc
     2 comment1_text = vc
     2 comment2_text = vc
     2 comment1_id = f8
     2 comment2_id = f8
     2 cki = vc
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
       3 description = vc
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
         4 ahfs_code = vc
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
       3 parent_entity = vc
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
         4 description = vc
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
         4 parent_entity = vc
         4 flex_type_cd = f8
         4 med_identifier_type_cd = f8
         4 value = vc
         4 value_key = vc
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
         4 parent_entity = vc
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
             6 parent_entity = vc
             6 flex_type_cd = f8
             6 med_identifier_type_cd = f8
             6 value = vc
             6 value_key = vc
             6 med_type_flag = i2
             6 active_ind = i2
             6 primary_ind = i2
             6 updt_cnt = i4
           5 pack[*]
             6 db_rec_status = i2
             6 item_id = f8
             6 package_type_id = f8
             6 description = vc
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
           5 multi_lot_transfer_ind = i2
           5 pre_exp_date_period_nbr = f8
           5 pre_exp_date_uom_cd = f8
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
     2 multi_lot_transfer_ind = i2
     2 pre_exp_date_period_nbr = f8
     2 pre_exp_date_uom_cd = f8
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
     2 side_effect_code = vc
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
     2 given_strength = vc
     2 meq_factor = f8
     2 mmol_factor = f8
     2 compound_text_id = f8
     2 cki = vc
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
     2 parent_entity = vc
     2 sequence = i4
     2 flex_type_cd = f8
     2 flex_sort_flag = i4
     2 pharmacy_type_cd = f8
     2 parent_med_def_flex_id = f8
     2 med_identifier_id = f8
     2 order_set_id = f8
     2 med_product_id = f8
     2 med_identifier_type_cd = f8
     2 value = vc
     2 value_key = vc
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
     2 multi_lot_transfer_ind = i2
     2 pre_exp_date_period_nbr = f8
     2 pre_exp_date_uom_cd = f8
   1 add_id_qual[*]
     2 sequence = i4
     2 package_type_id = f8
     2 salable_by_vendor_ind = i2
     2 salable_by_mfr_ind = i2
     2 db_rec_status = i2
     2 object_id = f8
     2 object_id_pe = vc
     2 object_type_cd = f8
     2 object_active_ind = i2
     2 id_type_cd = f8
     2 id_type_mean = vc
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
     2 description = vc
     2 uom_cd = f8
     2 qty = f8
     2 base_package_type_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
   1 chg_pack_qual[*]
     2 package_type_id = i4
     2 description = vc
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
   1 mnemonic = vc
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
 DECLARE index = i4 WITH noconstant(0)
 DECLARE flex_sort_flag = i4 WITH noconstant(0)
 DECLARE flex_sort_flag1 = i4 WITH noconstant(0)
 DECLARE ingrd_seq = i4
 DECLARE dose1 = vc
 DECLARE dose2 = vc
 DECLARE i = i4
 DECLARE k = i4
 DECLARE ingrd_cnt = i4
 SET ingrd_cnt = 0
 FREE RECORD ingrd
 RECORD ingrd(
   1 qual[*]
     2 item_id = f8
 )
 CALL echorecord(file_content)
 CALL echo("File Size")
 CALL echo(size(file_content->qual,5))
 FOR (i = 1 TO size(file_content->qual,5))
   CALL echo("I-->")
   CALL echo(i)
   SET stat = initrec(request_340240)
   SET stat = initrec(ingrd)
   SET ingrd_cnt = 0
   SELECT INTO "nl:"
    FROM med_identifier mi
    WHERE cnvtupper(mi.value)=cnvtupper(trim(file_content->qual[i].diluent))
     AND mi.active_ind=1
    ORDER BY mi.value
    HEAD mi.value
     ingrd_cnt = (ingrd_cnt+ 1), stat = alterlist(ingrd->qual,ingrd_cnt), ingrd->qual[ingrd_cnt].
     item_id = mi.item_id
    WITH nocounter
   ;end select
   FOR (j = 1 TO size(file_content->qual[i].addi,5))
     SELECT INTO "nl:"
      FROM med_identifier mi
      WHERE cnvtupper(mi.value)=cnvtupper(trim(file_content->qual[i].addi[j].additive))
       AND mi.active_ind=1
      ORDER BY mi.value
      HEAD mi.value
       ingrd_cnt = (ingrd_cnt+ 1), stat = alterlist(ingrd->qual,ingrd_cnt), ingrd->qual[ingrd_cnt].
       item_id = mi.item_id
      WITH nocounter
     ;end select
   ENDFOR
   CALL echorecord(ingrd)
   SET stat = alterlist(request_340240->meddefqual,1)
   SET stat = alterlist(request_340240->meddefqual[1].ordcat,1)
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual,(2+ size(ingrd->qual,5)))
   CALL echo(size(request_340240->meddefqual[1].meddefflexqual,5))
   CALL echo(size(ingrd->qual,5))
   CALL echo((2+ size(ingrd->qual,5)))
   SET stat = alterlist(request_340240->meddefqual[1].medingredqual,size(ingrd->qual,5))
   SET request_340240->item_group_active_ind = 0
   SET request_340240->item1_id = 0.00
   SET request_340240->item2_id = 0.00
   SET request_340240->tag1 = 0.00
   SET request_340240->cost1 = 0.00
   SET request_340240->cost2 = 0.00
   SET request_340240->awp = 0.00
   SET request_340240->nbr_packs_to_chg = 0
   SET request_340240->nbr_packs_to_add = 0
   SET request_340240->id_type_cd = 0.00
   SET request_340240->prep_into_flag = 0
   SET request_340240->catalog_type_disp = ""
   SET request_340240->iv_ingredient_ind = 0
   SET request_340240->gcr_desc = ""
   SET request_340240->package_type_id = 0.00
   SET request_340240->order_alert1_cd = 0.00
   SET request_340240->order_alert2_cd = 0.00
   SET request_340240->side_effect_code = ""
   SET request_340240->primary_manf_item_id = 0.00
   SET request_340240->nbr_ids_to_add = 0
   SET request_340240->comment1_text = ""
   SET request_340240->comment2_text = ""
   SET request_340240->compound_text = ""
   SET request_340240->countable_ind = 0
   SET request_340240->fda_reportable_ind = 0
   SET request_340240->active_status_cd = 0.00
   SET request_340240->shelf_life = 0
   SET request_340240->shelf_life_uom_cd = 0.00
   SET request_340240->component_usage_ind = 0
   SET request_340240->component_ind = 0
   SET request_340240->quickadd_ind = 0
   SET request_340240->approved_ind = 0
   SET request_340240->item_type_cd = 0.00
   SET request_340240->db_rec_status = 0
   SET request_340240->prod_rec_status = 3
   SET request_340240->manf_rec_status = 0
   SET request_340240->prod_id_rec_status = 3
   SET request_340240->oc_rec_status = 0
   SET request_340240->sent_rec_status = 3
   SET request_340240->pack_rec_status = 3
   SET request_340240->meddefqual[1].gfc_description = ""
   SET request_340240->meddefqual[1].active_status_cd = active_cd
   SET request_340240->meddefqual[1].updt_cnt = 0
   SET request_340240->meddefqual[1].db_rec_status = 3
   SET request_340240->meddefqual[1].med_type_flag = 3
   SET request_340240->meddefqual[1].item_id = 0.00
   SET request_340240->meddefqual[1].mdx_gfc_nomen_id = 0.00
   SET request_340240->meddefqual[1].form_cd = 0.00
   SET request_340240->meddefqual[1].strength = 0.00
   SET request_340240->meddefqual[1].strength_unit_cd = 0.00
   SET request_340240->meddefqual[1].volume = 0.00
   SET request_340240->meddefqual[1].volume_unit_cd = 0.00
   SET request_340240->meddefqual[1].given_strength = " "
   SET request_340240->meddefqual[1].meq_factor = 0.00
   SET request_340240->meddefqual[1].mmol_factor = 0.00
   SET request_340240->meddefqual[1].compound_text_id = 0.00
   SET request_340240->meddefqual[1].compound_text = ""
   SET request_340240->meddefqual[1].comment1_text = ""
   SET request_340240->meddefqual[1].comment2_text = ""
   SET request_340240->meddefqual[1].comment1_id = 0.00
   SET request_340240->meddefqual[1].comment2_id = 0.00
   SET request_340240->meddefqual[1].cki = " "
   SET request_340240->meddefqual[1].schedulable_ind = 0
   SET request_340240->meddefqual[1].reusable_ind = 0
   SET request_340240->meddefqual[1].cdm = ""
   SET request_340240->meddefqual[1].critical_ind = 0
   SET request_340240->meddefqual[1].sub_account_cd = 0.00
   SET request_340240->meddefqual[1].cost_center_cd = 0.00
   SET request_340240->meddefqual[1].storage_requirement_cd = 0.00
   SET request_340240->meddefqual[1].sterilization_required_ind = 0
   SET request_340240->meddefqual[1].base_issue_factor = 1.00
   SET request_340240->meddefqual[1].active_ind = 1
   SET request_340240->meddefqual[1].package_type_id = 0.00
   SET request_340240->meddefqual[1].template_catalog_cd = 0.00
   SET request_340240->meddefqual[1].template_synonym_id = 0.00
   SET request_340240->meddefqual[1].primary_synonym_mnemonic = ""
   SET request_340240->meddefqual[1].ordcat[1].prep_into_flag = 0
   SET request_340240->meddefqual[1].ordcat[1].db_rec_status = 0
   SET request_340240->meddefqual[1].ordcat[1].catalog_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].consent_form_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].active_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].catalog_type_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].catalog_type_disp = ""
   SET request_340240->meddefqual[1].ordcat[1].activity_type_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].activity_subtype_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].requisition_format_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].requisition_routing_cd = 0.00
   SET request_340240->meddefqual[1].ordcat[1].inst_restriction_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].schedule_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].description = ""
   SET request_340240->meddefqual[1].ordcat[1].iv_ingredient_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].print_req_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].oe_format_id = 0.00
   SET request_340240->meddefqual[1].ordcat[1].orderable_type_flag = 1
   SET request_340240->meddefqual[1].ordcat[1].complete_upon_order_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].quick_chart_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].comment_template_flag = 0
   SET request_340240->meddefqual[1].ordcat[1].prep_info_flag = 0
   SET request_340240->meddefqual[1].ordcat[1].updt_cnt = 0
   SET request_340240->meddefqual[1].ordcat[1].valid_iv_additive_ind = 0
   SET request_340240->meddefqual[1].ordcat[1].dc_display_days = - (1)
   SET request_340240->meddefqual[1].ordcat[1].dc_interaction_days = - (1)
   SET request_340240->meddefqual[1].ordcat[1].op_dc_display_days = 0
   SET request_340240->meddefqual[1].ordcat[1].op_dc_interaction_days = 0
   SET request_340240->meddefqual[1].ordcat[1].set_op_days = 0
   SET request_340240->meddefqual[1].ordcat[1].mdx_gcr_nomen_id = 0.00
   SET request_340240->meddefqual[1].ordcat[1].cki = ""
   SET request_340240->meddefqual[1].ordcat[1].gcr_desc = ""
   SET request_340240->meddefqual[1].meddefflexqual[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].sequence = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].flex_type_cd = system_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].flex_sort_flag = 600
   SET request_340240->meddefqual[1].meddefflexqual[1].pharmacy_type_cd = inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].parent_med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].active_status_cd = active_cd
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[1].pack,1)
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].description = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].uom_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].base_uom_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].qty = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].base_package_type_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].pack[1].updt_cnt = 0
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual,3)
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].salable_by_vendor_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].salable_by_mfr_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].id_type_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].flex_sort_flag = 600
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_identifier_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].order_set_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_product_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].sequence = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].pharmacy_type_cd =
   inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].flex_type_cd = system_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_identifier_type_cd =
   desc_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value = trim(file_content
    ->qual[i].name_iv_set)
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value_key = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_type_flag = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].primary_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[1].updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].salable_by_vendor_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].salable_by_mfr_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].id_type_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].flex_sort_flag = 600
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_identifier_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].order_set_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_product_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].sequence = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].pharmacy_type_cd =
   inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].flex_type_cd = system_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_identifier_type_cd =
   rx_uniqueid_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value = concat(trim(
     file_content->qual[i].name_iv_set)," - All - ",trim(file_content->qual[i].short_desc),
    " - Active")
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value_key = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_type_flag = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].primary_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[2].updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].salable_by_vendor_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].salable_by_mfr_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].id_type_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].flex_sort_flag = 600
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_identifier_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].order_set_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_product_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].sequence = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].pharmacy_type_cd =
   inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].flex_type_cd = system_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_identifier_type_cd =
   desc_short_cd
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value = trim(file_content
    ->qual[i].short_desc)
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value_key = " "
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_type_flag = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].primary_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medidentifierqual[3].updt_cnt = 0
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual,1)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_flex_object_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].sequence = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity =
   "MED_OE_DEFAULTS"
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].flex_object_type_cd =
   2427289
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value_unit = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].updt_cnt = 0
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].
    medoedefaultsqual,1)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   freetext_dose = ""
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   diluent_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   diluent_volume = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment1_text = ""
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment2_text = ""
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   default_par_doses = - (1)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   max_par_supply = - (1)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   med_oe_defaults_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   strength = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   strength_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   volume = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   volume_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   route_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   frequency_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   prn_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   prn_reason_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   infuse_over = cnvtreal(trim(file_content->qual[i].infuse_over))
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=54
     AND cv.display_key=cnvtupper(trim(file_content->qual[i].infuse_value))
    DETAIL
     request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
     infuse_over_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   duration = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   duration_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   stop_type_cd = 0.00
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=4008
     AND cv.display=trim(file_content->qual[i].dispense_catagory)
    DETAIL
     request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
     dispense_category_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   alternate_dispense_category_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment1_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment1_type = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment2_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment2_type = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   price_sched_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   rx_qty = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   daw_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   sig_codes = ""
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   nbr_labels = 0
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   ord_as_synonym_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].rate
    = - (1.00)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   rate_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   normalized_rate = - (1.00)
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   normalized_rate_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   freetext_rate = ""
   SET request_340240->meddefqual[1].meddefflexqual[2].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[2].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[2].sequence = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].flex_type_cd = syspkgtyp_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].flex_sort_flag = 500
   SET request_340240->meddefqual[1].meddefflexqual[2].pharmacy_type_cd = inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].parent_med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].active_status_cd = active_cd
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[2].pack,1)
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].description = "EA"
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].uom_cd = ea_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].base_uom_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].qty = 1.00
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].base_package_type_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].pack[1].updt_cnt = 0
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual,2)
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_flex_object_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].sequence = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity =
   "MED_DISPENSE"
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].flex_object_type_cd =
   dispense_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value_unit = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].active_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].updt_cnt = 0
   SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].
    meddispensequal,1)
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pharmacy_type_cd = inpatient_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pat_orderable_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   med_dispense_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   package_type_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   package_type_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   parent_entity = ""
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   flex_type_cd = syspkgtyp_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   flex_sort_flag = 500
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   legal_status_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   formulary_status_cd = formulary_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   oe_format_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   med_filter_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   continuous_filter_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   intermittent_filter_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_filter_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   max_par_supply = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   infinite_div_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   divisible_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   used_as_base_ind = 1
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   always_dispense_from_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   dispense_qty = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   dispense_factor = 1.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   label_ratio = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   reusable_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   strength = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   strength_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].volume
    = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   volume_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   base_issue_factor = 1.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   updt_cnt = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pkg_qty_per_pkg = - (1.00)
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pkg_disp_more_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   override_clsfctn_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   rx_station_notes = ""
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   rx_station_notes_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_dispense_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_return_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_adhoc_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_override_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_waste_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   workflow_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_balance_method_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_chloride_pct = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_default_ingred_item_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_fill_method_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_include_ions_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_overfill_amt = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_overfill_unit_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_preferred_cation_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_product_type_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_scale_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   lot_tracking_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   poc_charge_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_inv_count_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_empty_return_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_expire_mgmt_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_adhoc_refill_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   witness_sched_task_ind = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   prod_assign_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   billing_factor_nbr = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   billing_uom_cd = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   skip_dispense_flag = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].db_rec_status = 3
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].med_def_flex_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].med_flex_object_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity_id = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].sequence = 0
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity = " "
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].flex_object_type_cd =
   orderable_cd
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].value = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].value_unit = 0.00
   SET request_340240->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].active_ind = 1
   SET index = 2
   FOR (j = 1 TO size(ingrd->qual,5))
     SET index = (index+ 1)
     SET stat = initrec(request_340200)
     SET stat = alterlist(request_340200->qual,1)
     SET request_340200->qual[1].item_id = ingrd->qual[j].item_id
     SET request_340200->pharm_type_cd = inpatient_cd
     SET stat = tdbexecute(309000,340200,340200,"REC",request_340200,
      "REC",reply_340200)
     SET request_340240->meddefqual[1].meddefflexqual[index].db_rec_status = 3
     SET request_340240->meddefqual[1].meddefflexqual[index].med_def_flex_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].parent_entity_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].parent_entity = ""
     SET request_340240->meddefqual[1].meddefflexqual[index].sequence = (index - 1)
     SET request_340240->meddefqual[1].meddefflexqual[index].flex_type_cd = 2427285.00
     SET request_340240->meddefqual[1].meddefflexqual[index].flex_sort_flag = 500
     SET request_340240->meddefqual[1].meddefflexqual[index].pharmacy_type_cd = 685387.00
     SET request_340240->meddefqual[1].meddefflexqual[index].parent_med_def_flex_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].package_type_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].updt_cnt = 0
     SET request_340240->meddefqual[1].meddefflexqual[index].active_ind = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].active_status_cd = 188.00
     SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[index].pack,1)
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].db_rec_status = 3
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].item_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].package_type_id = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].description = " "
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].uom_cd = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].base_uom_cd = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].qty = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].base_package_type_ind = 0
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].active_ind = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].pack[1].updt_cnt = 0
     SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual,2)
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].db_rec_status = 3
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].med_def_flex_id =
     0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].med_flex_object_id
      = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].parent_entity_id =
     0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].sequence = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].parent_entity =
     "MED_DISPENSE"
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].flex_object_type_cd
      = 2427287.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].value = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].value_unit = 0.00
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].active_ind = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].updt_cnt = 0
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].active_ind = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].db_rec_status = 3
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].parent_entity =
     "MED_OE_DEFAULTS"
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].flex_object_type_cd
      = 2427289.000000
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].sequence = 1
     SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].
      meddispensequal,1)
     SET stat = alterlist(request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].
      medoedefaultsqual,1)
     FOR (ii1 = 1 TO size(reply_340200->meddefqual[1].meddefflexqual,5))
       FOR (k = 1 TO size(reply_340200->meddefqual[1].meddefflexqual[ii1].medflexobjidxqual,5))
        IF (size(reply_340200->meddefqual[1].meddefflexqual[ii1].medflexobjidxqual[k].meddispensequal,
         5) != 0)
         SET dispmeddefflexqual = ii1
         SET dispmedflexobjidxqual = k
        ENDIF
        IF (size(reply_340200->meddefqual[1].meddefflexqual[ii1].medflexobjidxqual[k].
         medoedefaultsqual,5) != 0)
         SET oefieldmeddefflexqual = ii1
         SET oefieldmedflexobjidxqual = k
        ENDIF
       ENDFOR
     ENDFOR
     CALL echo(oefieldmeddefflexqual)
     CALL echo(oefieldmedflexobjidxqual)
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     always_dispense_from_flag = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].always_dispense_from_flag
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     base_issue_factor = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].base_issue_factor
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     billing_factor_nbr = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].billing_factor_nbr
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     billing_uom_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].billing_uom_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     continuous_filter_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].continuous_filter_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     db_rec_status = 3
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     dispense_factor = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].dispense_factor
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     dispense_qty = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].dispense_qty
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     divisible_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].divisible_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     flex_sort_flag = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].flex_sort_flag
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     flex_type_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].flex_type_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     formulary_status_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].formulary_status_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     infinite_div_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].infinite_div_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     intermittent_filter_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].intermittent_filter_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     label_ratio = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].label_ratio
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     legal_status_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].legal_status_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     lot_tracking_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].lot_tracking_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     med_dispense_id = 0
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     oe_format_flag = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].oe_format_flag
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     strength = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].strength
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     strength_unit_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].strength_unit_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     used_as_base_ind = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].used_as_base_ind
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     volume = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].volume
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     volume_unit_cd = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].volume_unit_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     updt_cnt = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].medflexobjidxqual[
     dispmedflexobjidxqual].meddispensequal[1].updt_cnt
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[1].meddispensequal[1].
     pkg_qty_per_pkg = reply_340200->meddefqual[1].meddefflexqual[dispmeddefflexqual].
     medflexobjidxqual[dispmedflexobjidxqual].meddispensequal[1].pkg_qty_per_pkg
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].active_ind = 1
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].alternate_dispense_category_cd = reply_340200->meddefqual[1].meddefflexqual[
     oefieldmeddefflexqual].medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].
     alternate_dispense_category_cd
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment1_id = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment1_id
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment1_text = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment1_text
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment1_type = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment1_type
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment2_id = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment2_id
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment2_text = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment2_text
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].comment2_type = reply_340200->meddefqual[1].meddefflexqual[oefieldmeddefflexqual].
     medflexobjidxqual[oefieldmedflexobjidxqual].medoedefaultsqual[1].comment2_type
     SET request_340240->meddefqual[1].meddefflexqual[index].medflexobjidxqual[2].medoedefaultsqual[1
     ].db_rec_status = 3
     SET request_340240->meddefqual[1].medingredqual[j].child_item_id = ingrd->qual[j].item_id
     SET request_340240->meddefqual[1].medingredqual[j].sequence = j
   ENDFOR
   SET stat = tdbexecute(309000,340200,340240,"REC",request_340240,
    "REC",reply_340240)
 ENDFOR
 SET script_ver = " 000 04/01/16 DS042261  Initial Release "
END GO
