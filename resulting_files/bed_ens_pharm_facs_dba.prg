CREATE PROGRAM bed_ens_pharm_facs:dba
 SET modify = skipsrvmsg
 FREE SET request_main
 RECORD request_main(
   1 items[*]
     2 item_id = f8
     2 reuse_ind = i2
     2 dispense_from_flag = i2
     2 facilities[*]
       3 action_flag = i2
       3 code_value = f8
     2 locations[*]
       3 action_flag = i2
       3 code_value = f8
     2 mdf_id = f8
 )
 FREE SET temp_locs
 RECORD temp_locs(
   1 items[*]
     2 item_id = f8
     2 add_qual[*]
       3 location_cd = f8
     2 del_qual[*]
       3 location_cd = f8
 )
 DECLARE error_msg = vc
 SET len = size(request->items,5)
 SET stat = alterlist(request_main->items,len)
 SET stat = alterlist(temp_locs->items,len)
 FOR (x = 1 TO len)
   SET request_main->items[x].item_id = request->items[x].item_id
   SET request_main->items[x].reuse_ind = request->items[x].reuse_ind
   SET request_main->items[x].dispense_from_flag = request->items[x].dispense_from_flag
   SET temp_locs->items[x].item_id = request->items[x].item_id
   SET fac_len = size(request->items[x].facilities,5)
   SET stat = alterlist(request_main->items[x].facilities,fac_len)
   FOR (y = 1 TO fac_len)
    SET request_main->items[x].facilities[y].action_flag = request->items[x].facilities[y].
    action_flag
    SET request_main->items[x].facilities[y].code_value = request->items[x].facilities[y].code_value
   ENDFOR
   SET loc_len = size(request->items[x].locations,5)
   SET stat = alterlist(request_main->items[x].locations,loc_len)
   SET stat = alterlist(temp_locs->items[x].add_qual,loc_len)
   SET stat = alterlist(temp_locs->items[x].del_qual,loc_len)
   SET del_cnt = 0
   SET add_cnt = 0
   FOR (y = 1 TO loc_len)
     SET request_main->items[x].locations[y].action_flag = request->items[x].locations[y].action_flag
     SET request_main->items[x].locations[y].code_value = request->items[x].locations[y].code_value
     IF ((request->items[x].locations[y].action_flag=1))
      SET add_cnt = (add_cnt+ 1)
      SET temp_locs->items[x].add_qual[add_cnt].location_cd = request->items[x].locations[y].
      code_value
     ELSEIF ((request->items[x].locations[y].action_flag=3))
      SET del_cnt = (del_cnt+ 1)
      SET temp_locs->items[x].del_qual[del_cnt].location_cd = request->items[x].locations[y].
      code_value
     ENDIF
   ENDFOR
   SET stat = alterlist(temp_locs->items[x].add_qual,add_cnt)
   SET stat = alterlist(temp_locs->items[x].del_qual,del_cnt)
 ENDFOR
 FREE SET request
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
     2 parent_item_id = f8
     2 inv_master_id = f8
     2 group_rx_mnem = vc
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
     2 ordcat[1]
       3 item_id = f8
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
         4 alt_sel_category_id = f8
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
       3 pack[1]
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
         4 update_value_ind = i2
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
           5 update_tpn_ind = i2
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
           5 updt_cnt = i4
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
           5 ord_as_synonym_exists = i2
           5 ord_as_mnemonic = vc
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
           5 item_master_id = f8
           5 inner_pkg_type_id = f8
           5 outer_pkg_type_id = f8
           5 base_uom_cd = f8
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
             6 updt_name = vc
           5 storedat[*]
             6 location_cd = f8
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
     2 locqual[*]
       3 db_rec_status = i2
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
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
       3 normalized_rate_ind = i2
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
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
     2 tpn_group_qual[*]
       3 tpn_group_cd = f8
     2 premix_ind = i2
     2 inv_factor_nbr = f8
     2 inv_base_pkg_uom_cd = f8
     2 inv_tracking_level = i2
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
     2 tpn_filter_ind = i2
     2 max_par_supply = i4
     2 divisible_ind = i2
     2 infinite_div_ind = i2
     2 used_as_base_ind = i2
     2 always_dispense_from_flag = i2
     2 dispense_qty = i4
     2 updt_cnt = i4
     2 med_oe_defaults_id = f8
     2 freetext_dose = vc
     2 route_cd = f8
     2 frequency_cd = f8
     2 prn_ind = i2
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
   1 add_id_qual[*]
     2 item1_id = f8
     2 item2_id = f8
     2 tag1 = f8
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
     2 replacement_upn_id = f8
     2 replaced_upn_id = f8
     2 item_level_flag = i2
     2 contributor_cd = f8
     2 pha_type_flag = i2
   1 chg_id_qual[*]
     2 identifier_id = f8
     2 id_type_cd = f8
     2 package_type_id = f8
     2 salable_by_vendor_ind = i2
     2 salable_by_mfr_ind = i2
     2 object_id = f8
     2 value = vc
     2 sequence = i4
     2 primary_ind = i2
     2 primary_nbr_ind = i2
     2 updt_cnt = i4
     2 replacement_upn_id = f8
     2 replaced_upn_id = f8
     2 contributor_cd = f8
   1 del_id_qual[*]
     2 identifier_id = f8
     2 object_id = f8
     2 active_status_cd = f8
     2 updt_cnt = i4
   1 rmv_id_qual[*]
     2 identifier_id = f8
     2 object_id = f8
     2 active_status_cd = f8
     2 updt_cnt = i4
   1 und_id_qual[*]
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
     2 package_type_id = f8
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
   1 total_ids_to_rmv = i4
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
   1 synonym_id = f8
   1 synonym_cki = vc
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
     2 id_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cost = f8
     2 active_ind = i2
     2 updt_cnt = i4
   1 del_qual[*]
     2 location_cd = f8
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
 FREE SET reply
 RECORD reply(
   1 meddefqual[*]
     2 item_id = f8
     2 compound_text_id = f8
     2 pack[*]
       3 package_type_id = f8
     2 medingredqual[*]
       3 med_ingred_set_id = f8
     2 ordcat[1]
       3 catalog_cd = f8
       3 qual_mnemonic[*]
         4 synonym_id = f8
     2 meddefflexqual[*]
       3 med_def_flex_id = f8
       3 parent_entity_id = f8
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
             6 updt_id = i4
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
     2 component_text_id = f8
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
 FREE SET bad_items
 RECORD bad_items(
   1 items[*]
     2 item_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE check_rx_unique_id = vc
 DECLARE del_fac_parse = vc
 FREE SET rxa_get_req
 FREE SET rxa_get_reply
 EXECUTE rxa_get_medprod_rr_incl  WITH replace("REQUEST","RXA_GET_REQ"), replace("REPLY",
  "RXA_GET_REPLY")
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET system_code_value = 0.0
 SET system_package_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSTEM", "SYSPKGTYP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSPKGTYP")
    system_package_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET med_product_code_value = 0.0
 SET med_oe_defaults_code_value = 0.0
 SET orderable_code_value = 0.0
 SET med_dispense_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4063
   AND cv.cdf_meaning IN ("MEDPRODUCT", "OEDEF", "ORDERABLE", "DISPENSE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="MEDPRODUCT")
    med_product_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="OEDEF")
    med_oe_defaults_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="ORDERABLE")
    orderable_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPENSE")
    med_dispense_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE sys_format = vc
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="RDDSFORMAT"
  DETAIL
   IF (findstring("/f",dp.pref_str,1,1))
    sys_format = dp.pref_str
   ENDIF
  WITH nocounter
 ;end select
 SET format_set_ind = 0
 IF (sys_format > " ")
  SET format_set_ind = 1
 ENDIF
 SET dup_check_ind = 0
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="RDDSUNIQUE"
  DETAIL
   dup_check_ind = dp.pref_nbr
  WITH nocounter
 ;end select
 SET meddef_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11001
   AND cv.cdf_meaning="MED_DEF"
   AND cv.active_ind=1
  DETAIL
   meddef_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET desc_code_value = 0.0
 SET unique_code_value = 0.0
 SET short_desc_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("DESC", "RX_UNIQUEID", "DESC_SHORT")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DESC")
    desc_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="RX_UNIQUEID")
    unique_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC_SHORT")
    short_desc_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 FREE SET temp_del
 RECORD temp_del(
   1 ids[*]
     2 id = f8
 )
 FREE SET temp_add
 RECORD temp_add(
   1 rows[*]
     2 mdf_id = f8
     2 fac_code = f8
     2 pname = vc
 )
 FREE SET temp_mdisp
 RECORD temp_mdisp(
   1 rows[*]
     2 md_id = f8
     2 reuse_ind = i2
     2 disp_flag = i2
 )
 FREE SET temp_uid
 RECORD temp_uid(
   1 ids[*]
     2 item_id = f8
     2 mdf_id = f8
     2 old_fac_disp = vc
 )
 FREE SET temp_uid2
 RECORD temp_uid2(
   1 ids[*]
     2 upd_ind = i2
     2 item_id = f8
     2 currxident = vc
     2 sysgenrxident = vc
     2 newrxident = vc
     2 fac_disp = vc
     2 desc = vc
     2 sdesc = vc
     2 mdf_id = f8
     2 old_fac_disp = vc
 )
 SET reqcnt = size(request_main->items,5)
 IF (reqcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reqcnt)),
    med_def_flex mdf
   PLAN (d)
    JOIN (mdf
    WHERE (mdf.item_id=request_main->items[d.seq].item_id)
     AND mdf.flex_type_cd=system_package_code_value
     AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
     AND ((mdf.sequence+ 0)=0)
     AND ((mdf.med_def_flex_id+ 0) != 0)
     AND ((mdf.active_ind+ 0)=1))
   ORDER BY d.seq
   HEAD d.seq
    request_main->items[d.seq].mdf_id = mdf.med_def_flex_id
   WITH nocounter
  ;end select
  SET itcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reqcnt)),
    (dummyt d2  WITH seq = 1),
    med_flex_object_idx mfoi
   PLAN (d
    WHERE maxrec(d2,size(request_main->items[d.seq].facilities,5))
     AND (request_main->items[d.seq].mdf_id > 0))
    JOIN (d2
    WHERE (request_main->items[d.seq].facilities[d2.seq].action_flag=3))
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id=request_main->items[d.seq].mdf_id)
     AND mfoi.flex_object_type_cd=orderable_code_value
     AND ((mfoi.parent_entity_name="CODE_VALUE"
     AND (mfoi.parent_entity_id=request_main->items[d.seq].facilities[d2.seq].code_value)) OR (mfoi
    .parent_entity_id=0
     AND (mfoi.parent_entity_id=request_main->items[d.seq].facilities[d2.seq].code_value))) )
   ORDER BY mfoi.med_flex_object_id
   HEAD REPORT
    icnt = 0, itcnt = 0, stat = alterlist(temp_del->ids,100),
    stat = alterlist(temp_uid->ids,100)
   HEAD mfoi.med_flex_object_id
    icnt = (icnt+ 1), itcnt = (itcnt+ 1)
    IF (icnt > 100)
     stat = alterlist(temp_del->ids,(itcnt+ 100)), stat = alterlist(temp_uid->ids,(itcnt+ 100)), icnt
      = 1
    ENDIF
    temp_del->ids[itcnt].id = mfoi.med_flex_object_id, temp_uid->ids[itcnt].item_id = request_main->
    items[d.seq].item_id, temp_uid->ids[itcnt].mdf_id = request_main->items[d.seq].mdf_id
   FOOT REPORT
    stat = alterlist(temp_del->ids,itcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reqcnt)),
    (dummyt d2  WITH seq = 1),
    med_flex_object_idx mfoi
   PLAN (d
    WHERE maxrec(d2,size(request_main->items[d.seq].facilities,5))
     AND (request_main->items[d.seq].mdf_id > 0))
    JOIN (d2
    WHERE (request_main->items[d.seq].facilities[d2.seq].action_flag=1))
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id=request_main->items[d.seq].mdf_id)
     AND mfoi.flex_object_type_cd=orderable_code_value
     AND mfoi.parent_entity_id=0)
   ORDER BY mfoi.med_flex_object_id
   HEAD REPORT
    icnt = 0, stat = alterlist(temp_del->ids,(itcnt+ 100)), stat = alterlist(temp_uid->ids,(itcnt+
     100))
   HEAD mfoi.med_flex_object_id
    icnt = (icnt+ 1), itcnt = (itcnt+ 1)
    IF (icnt > 100)
     stat = alterlist(temp_del->ids,(itcnt+ 100)), stat = alterlist(temp_uid->ids,(itcnt+ 100)), icnt
      = 1
    ENDIF
    temp_del->ids[itcnt].id = mfoi.med_flex_object_id, temp_uid->ids[itcnt].item_id = request_main->
    items[d.seq].item_id, temp_uid->ids[itcnt].mdf_id = request_main->items[d.seq].mdf_id
   FOOT REPORT
    stat = alterlist(temp_del->ids,itcnt)
   WITH nocounter
  ;end select
  IF (itcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(itcnt)),
     med_flex_object_idx mfoi
    PLAN (d)
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=temp_uid->ids[d.seq].mdf_id)
      AND mfoi.flex_object_type_cd=orderable_code_value)
    ORDER BY d.seq
    HEAD d.seq
     IF (mfoi.parent_entity_id=0)
      temp_uid->ids[d.seq].old_fac_disp = "All"
     ELSE
      temp_uid->ids[d.seq].old_fac_disp = uar_get_code_display(mfoi.parent_entity_id)
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = 0
   DELETE  FROM med_flex_object_idx m,
     (dummyt d  WITH seq = value(itcnt))
    SET m.seq = 1
    PLAN (d)
     JOIN (m
     WHERE (m.med_flex_object_id=temp_del->ids[d.seq].id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    GO TO main_exit_script
   ENDIF
  ENDIF
  SET stat = initrec(temp_del)
  SET rcnt = 0
  FOR (x = 1 TO reqcnt)
   SET faccnt = size(request_main->items[x].facilities,5)
   FOR (y = 1 TO faccnt)
     IF ((request_main->items[x].mdf_id > 0)
      AND (request_main->items[x].facilities[y].action_flag=1))
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(temp_add->rows,rcnt)
      SET temp_add->rows[rcnt].mdf_id = request_main->items[x].mdf_id
      SET temp_add->rows[rcnt].fac_code = request_main->items[x].facilities[y].code_value
      IF ((temp_add->rows[rcnt].fac_code > 0))
       SET temp_add->rows[rcnt].pname = "CODE_VALUE"
      ELSE
       SET temp_add->rows[rcnt].pname = ""
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
  IF (rcnt > 0)
   SET ierrcode = 0
   INSERT  FROM med_flex_object_idx m,
     (dummyt d  WITH seq = value(rcnt))
    SET m.active_ind = 1, m.flex_object_type_cd = orderable_code_value, m.med_def_flex_id = temp_add
     ->rows[d.seq].mdf_id,
     m.med_flex_object_id = seq(medflex_seq,nextval), m.parent_entity_id = temp_add->rows[d.seq].
     fac_code, m.parent_entity_name = temp_add->rows[d.seq].pname,
     m.sequence = 0, m.updt_cnt = 0, m.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     m.updt_task = reqinfo->updt_task, m.updt_id = reqinfo->updt_id, m.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (m)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    GO TO main_exit_script
   ENDIF
  ENDIF
  SET stat = initrec(temp_add)
  SET itcnt = 0
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_dispense mdisp,
    (dummyt d  WITH seq = value(reqcnt))
   PLAN (d)
    JOIN (mdf
    WHERE (mdf.item_id=request_main->items[d.seq].item_id)
     AND mdf.flex_type_cd=system_package_code_value
     AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
     AND ((mdf.sequence+ 0)=0)
     AND ((mdf.med_def_flex_id+ 0) != 0)
     AND ((mdf.active_ind+ 0)=1))
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
     AND mfoi.flex_object_type_cd=med_dispense_code_value
     AND ((mfoi.parent_entity_id+ 0) != 0)
     AND ((mfoi.active_ind+ 0)=1))
    JOIN (mdisp
    WHERE (mdisp.med_dispense_id=(mfoi.parent_entity_id+ 0))
     AND (((mdisp.reusable_ind != request_main->items[d.seq].reuse_ind)) OR ((mdisp
    .always_dispense_from_flag != request_main->items[d.seq].dispense_from_flag))) )
   ORDER BY mdisp.med_dispense_id
   HEAD REPORT
    icnt = 0, itcnt = 0, stat = alterlist(temp_mdisp->rows,100)
   HEAD mdisp.med_dispense_id
    icnt = (icnt+ 1), itcnt = (itcnt+ 1)
    IF (icnt > 100)
     stat = alterlist(temp_mdisp->rows,(itcnt+ 100)), icnt = 1
    ENDIF
    temp_mdisp->rows[itcnt].md_id = mdisp.med_dispense_id, temp_mdisp->rows[itcnt].reuse_ind =
    request_main->items[d.seq].reuse_ind, temp_mdisp->rows[itcnt].disp_flag = request_main->items[d
    .seq].dispense_from_flag
   FOOT REPORT
    stat = alterlist(temp_mdisp->rows,itcnt)
   WITH nocounter
  ;end select
  IF (itcnt > 0)
   SET ierrcode = 0
   UPDATE  FROM med_dispense m,
     (dummyt d  WITH seq = value(itcnt))
    SET m.always_dispense_from_flag = temp_mdisp->rows[d.seq].disp_flag, m.reusable_ind = temp_mdisp
     ->rows[d.seq].reuse_ind, m.updt_cnt = (m.updt_cnt+ 1),
     m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_task = reqinfo->updt_task, m.updt_id =
     reqinfo->updt_id,
     m.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (m
     WHERE (m.med_dispense_id=temp_mdisp->rows[d.seq].md_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    GO TO main_exit_script
   ENDIF
  ENDIF
  SET stat = initrec(temp_mdisp)
  SET uid_size = size(temp_uid->ids,5)
  IF (dup_check_ind=1
   AND unique_code_value > 0
   AND format_set_ind=1
   AND uid_size > 0)
   SET ucnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(uid_size))
    PLAN (d
     WHERE (temp_uid->ids[d.seq].item_id > 0))
    ORDER BY temp_uid->ids[d.seq].item_id
    HEAD REPORT
     ucnt = 0, stat = alterlist(temp_uid2->ids,uid_size), prev_id = 0.0
    DETAIL
     IF (((prev_id > 0
      AND (prev_id != temp_uid->ids[d.seq].item_id)) OR (prev_id=0)) )
      ucnt = (ucnt+ 1), temp_uid2->ids[ucnt].item_id = temp_uid->ids[d.seq].item_id, temp_uid2->ids[
      ucnt].old_fac_disp = temp_uid->ids[d.seq].old_fac_disp,
      temp_uid2->ids[ucnt].newrxident = sys_format, temp_uid2->ids[ucnt].newrxident = replace(
       temp_uid2->ids[ucnt].newrxident,"/a","Active"), temp_uid2->ids[ucnt].newrxident = replace(
       temp_uid2->ids[ucnt].newrxident,"/p","Inpatient"),
      temp_uid2->ids[ucnt].sysgenrxident = sys_format, temp_uid2->ids[ucnt].sysgenrxident = replace(
       temp_uid2->ids[ucnt].sysgenrxident,"/a","Active"), temp_uid2->ids[ucnt].sysgenrxident =
      replace(temp_uid2->ids[ucnt].sysgenrxident,"/p","Inpatient"),
      temp_uid2->ids[ucnt].sysgenrxident = replace(temp_uid2->ids[ucnt].sysgenrxident,"/f",temp_uid2
       ->ids[ucnt].old_fac_disp), temp_uid2->ids[ucnt].mdf_id = temp_uid->ids[d.seq].mdf_id
     ENDIF
     prev_id = temp_uid->ids[d.seq].item_id
    FOOT REPORT
     stat = alterlist(temp_uid2->ids,ucnt)
    WITH nocounter
   ;end select
   SET stat = initrec(temp_uid)
   IF (ucnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(ucnt)),
      med_flex_object_idx mfoi
     PLAN (d)
      JOIN (mfoi
      WHERE (mfoi.med_def_flex_id=temp_uid2->ids[d.seq].mdf_id)
       AND mfoi.flex_object_type_cd=orderable_code_value)
     ORDER BY d.seq
     HEAD d.seq
      IF (mfoi.parent_entity_id=0)
       temp_uid2->ids[d.seq].newrxident = replace(temp_uid2->ids[d.seq].newrxident,"/f","All")
      ELSE
       temp_uid2->ids[d.seq].fac_disp = uar_get_code_display(mfoi.parent_entity_id), temp_uid2->ids[d
       .seq].newrxident = replace(temp_uid2->ids[d.seq].newrxident,"/f",temp_uid2->ids[d.seq].
        fac_disp)
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(ucnt)),
      med_identifier mi
     PLAN (d)
      JOIN (mi
      WHERE (mi.item_id=temp_uid2->ids[d.seq].item_id)
       AND mi.pharmacy_type_cd=inpatient_code_value
       AND mi.med_identifier_type_cd IN (desc_code_value, unique_code_value, short_desc_code_value)
       AND ((mi.flex_type_cd+ 0)=system_code_value)
       AND mi.med_product_id=0
       AND ((mi.active_ind+ 0)=1))
     ORDER BY d.seq
     HEAD d.seq
      sd_ind = 0, d_ind = 0, u_ind = 0
     DETAIL
      CASE (mi.med_identifier_type_cd)
       OF desc_code_value:
        temp_uid2->ids[d.seq].desc = trim(mi.value),temp_uid2->ids[d.seq].newrxident = replace(
         temp_uid2->ids[d.seq].newrxident,"/d",trim(mi.value)),temp_uid2->ids[d.seq].sysgenrxident =
        replace(temp_uid2->ids[d.seq].sysgenrxident,"/d",trim(mi.value)),
        d_ind = 1
       OF unique_code_value:
        temp_uid2->ids[d.seq].currxident = mi.value,u_ind = 1
       OF short_desc_code_value:
        temp_uid2->ids[d.seq].sdesc = trim(mi.value),temp_uid2->ids[d.seq].newrxident = replace(
         temp_uid2->ids[d.seq].newrxident,"/s",trim(mi.value)),temp_uid2->ids[d.seq].sysgenrxident =
        replace(temp_uid2->ids[d.seq].sysgenrxident,"/s",trim(mi.value)),
        sd_ind = 1
      ENDCASE
     FOOT  d.seq
      IF (sd_ind=1
       AND d_ind=1
       AND u_ind=1)
       IF ((temp_uid2->ids[d.seq].currxident=temp_uid2->ids[d.seq].sysgenrxident)
        AND (temp_uid2->ids[d.seq].currxident != temp_uid2->ids[d.seq].newrxident))
        temp_uid2->ids[d.seq].upd_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    DECLARE check_rx_unique_id = vc
    FOR (main_i = 1 TO ucnt)
      IF ((temp_uid2->ids[main_i].upd_ind=1))
       SET duplicate_ind = 1
       SET concat_cnt = 0
       SET check_rx_unique_id = temp_uid2->ids[main_i].newrxident
       WHILE (duplicate_ind=1)
         SET duplicate_ind = 0
         SELECT INTO "nl:"
          FROM object_identifier_index oii
          PLAN (oii
           WHERE oii.value_key=cnvtupper(cnvtalphanum(check_rx_unique_id))
            AND ((oii.identifier_type_cd+ 0) IN (unique_code_value, desc_code_value))
            AND ((oii.object_type_cd+ 0)=meddef_code_value)
            AND ((oii.vendor_manf_cd+ 0)=0)
            AND ((oii.generic_object+ 0)=0)
            AND ((oii.object_id+ 0) != temp_uid2->ids[main_i].item_id))
          DETAIL
           duplicate_ind = 1
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          FROM med_identifier mi
          PLAN (mi
           WHERE mi.value_key=cnvtupper(cnvtalphanum(check_rx_unique_id))
            AND mi.med_identifier_type_cd=unique_code_value
            AND (mi.item_id != temp_uid2->ids[main_i].item_id))
          DETAIL
           duplicate_ind = 1
          WITH nocounter
         ;end select
         IF (duplicate_ind=1)
          SET concat_cnt = (concat_cnt+ 1)
          SET check_rx_unique_id = concat(temp_uid2->ids[main_i].newrxident," - ",trim(cnvtstring(
             concat_cnt)))
         ENDIF
       ENDWHILE
       SET temp_uid2->ids[main_i].newrxident = check_rx_unique_id
       SET stat = initrec(rxa_get_req)
       SET stat = initrec(request)
       SET error_ind = 0
       SET stat = alterlist(rxa_get_req->qual,1)
       SET rxa_get_req->pharm_type_cd = inpatient_code_value
       SET rxa_get_req->qual[1].item_id = temp_uid2->ids[main_i].item_id
       EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",request)
       IF ((request->status_data.status="Z"))
        SET error_ind = 1
       ENDIF
       IF (error_ind=0)
        SET cnt = size(request->meddefqual,5)
        FOR (x = 1 TO cnt)
          IF ((request->meddefqual[x].item_id=temp_uid2->ids[main_i].item_id))
           SET request->prod_rec_status = 1
           SET request->prod_id_rec_status = 3
           SET request->oc_rec_status = 1
           SET request->sent_rec_status = 1
           SET request->meddefqual[x].db_rec_status = 1
           SET request->meddefqual[x].ordcat[1].db_rec_status = 1
           SELECT INTO "nl:"
            FROM (dummyt d  WITH seq = size(request->meddefqual[x].ordcat[1].qual_mnemonic,5))
            DETAIL
             request->meddefqual[x].ordcat[1].qual_mnemonic[d.seq].db_rec_status = 1
            WITH nocounter
           ;end select
           IF (size(request->meddefqual[x].ordcat[1].ahfs_qual,5) > 0)
            IF ((request->meddefqual[x].ordcat[1].ahfs_qual[1].ahfs_code IN ("", " ", null)))
             SET request->meddefqual[x].ordcat[1].ahfs_qual[1].ahfs_code = "000000"
            ENDIF
           ENDIF
           FOR (y = 1 TO size(request->meddefqual[x].meddefflexqual,5))
             IF ((request->meddefqual[x].meddefflexqual[y].flex_type_cd=system_code_value))
              SET request->meddefqual[x].meddefflexqual[y].db_rec_status = 1
              IF (size(request->meddefqual[x].meddefflexqual[y].medidentifierqual,5) > 0)
               SELECT INTO "nl:"
                FROM (dummyt d  WITH seq = size(request->meddefqual[x].meddefflexqual[y].
                  medidentifierqual,5))
                PLAN (d
                 WHERE (request->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].
                 med_identifier_type_cd=unique_code_value)
                  AND (request->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].primary_ind=
                 1)
                  AND (request->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].active_ind=1
                 ))
                ORDER BY d.seq
                DETAIL
                 request->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].value = temp_uid2
                 ->ids[main_i].newrxident, request->meddefqual[x].meddefflexqual[y].
                 medidentifierqual[d.seq].db_rec_status = 1
                WITH nocounter
               ;end select
              ENDIF
              FOR (z = 1 TO size(request->meddefqual[x].meddefflexqual[y].medflexobjidxqual,5))
               SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].db_rec_status = 1
               IF ((request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].flex_object_type_cd
               =med_product_code_value))
                SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].db_rec_status = 1
                SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].medproductqual[1].
                db_rec_status = 1
                SELECT INTO "nl:"
                 FROM med_flex_object_idx m
                 WHERE (m.med_flex_object_id=request->meddefqual[x].meddefflexqual[y].
                 medflexobjidxqual[z].med_flex_object_id)
                 DETAIL
                  request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].medproductqual[1].
                  active_ind = m.active_ind
                 WITH nocounter
                ;end select
               ELSEIF ((request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
               flex_object_type_cd=med_oe_defaults_code_value))
                SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].db_rec_status = 1
                SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1
                ].db_rec_status = 1
                SET request->meddefqual[x].comment2_text = request->meddefqual[x].meddefflexqual[y].
                medflexobjidxqual[z].medoedefaultsqual[1].comment2_text
                SET request->meddefqual[x].comment1_text = request->meddefqual[x].meddefflexqual[y].
                medflexobjidxqual[z].medoedefaultsqual[1].comment1_text
               ENDIF
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
        EXECUTE rxa_upd_medproduct
        DECLARE child_status = c1
        SET child_status = reply->status_data.status
        IF (child_status="F")
         SET error_flag = "Y"
         SET error_msg = concat("Could not update item: ",trim(cnvtstring(temp_uid2->ids[main_i].
            item_id)))
         GO TO main_exit_script
        ENDIF
       ENDIF
       SET stat = initrec(request)
       SET stat = initrec(reply)
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 SET b = 0
 FOR (main_x = 1 TO size(temp_locs->items,5))
   FREE SET request
   RECORD request(
     1 item_id = f8
     1 pharm_type_cd = f8
     1 add_qual[*]
       2 location_cd = f8
     1 del_qual[*]
       2 location_cd = f8
   )
   FREE SET reply
   RECORD reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET error_ind = 0
   IF (size(bad_items->items,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(bad_items->items,5))
     PLAN (d
      WHERE (bad_items->items[d.seq].item_id=temp_locs->items[main_x].item_id))
     ORDER BY d.seq
     DETAIL
      error_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (error_ind=0)
    SET request->item_id = temp_locs->items[main_x].item_id
    SET request->pharm_type_cd = inpatient_code_value
    SET stat = alterlist(request->add_qual,size(temp_locs->items[main_x].add_qual,5))
    FOR (main_y = 1 TO size(temp_locs->items[main_x].add_qual,5))
      SET request->add_qual[main_y].location_cd = temp_locs->items[main_x].add_qual[main_y].
      location_cd
    ENDFOR
    SET stat = alterlist(request->del_qual,size(temp_locs->items[main_x].del_qual,5))
    FOR (main_y = 1 TO size(temp_locs->items[main_x].del_qual,5))
      SET request->del_qual[main_y].location_cd = temp_locs->items[main_x].del_qual[main_y].
      location_cd
    ENDFOR
    EXECUTE mm_upd_chk_loc_relations
    DECLARE child_status = c1
    SET child_status = reply->status_data.status
    IF (child_status="F")
     SET error_flag = "Y"
     SET error_msg = concat("Could not update locations for item: ",trim(cnvtstring(temp_locs->items[
        main_x].item_id)))
     GO TO main_exit_script
    ENDIF
   ENDIF
 ENDFOR
#main_exit_script
 SET modify = noskipsrvmsg
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 items_not_saved[*]
     2 item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (size(bad_items->items,5) > 0)
  SET stat = alterlist(reply->items_not_saved,size(bad_items->items,5))
  FOR (x = 1 TO size(bad_items->items,5))
    SET reply->items_not_saved[x].item_id = bad_items->items[x].item_id
  ENDFOR
 ENDIF
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
