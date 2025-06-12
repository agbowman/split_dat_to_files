CREATE PROGRAM bed_ens_rx_item_inv:dba
 SET modify = skipsrvmsg
 FREE SET request_main
 RECORD request_main(
   1 items[*]
     2 id = f8
     2 facilities[*]
       3 action_flag = i2
       3 code_value = f8
 )
 SET error_flag = "N"
 SET cnt = 0
 SET fcnt = 0
 SET cnt = size(request->items,5)
 SET stat = alterlist(request_main->items,cnt)
 FOR (x = 1 TO cnt)
   SET request_main->items[x].id = request->items[x].id
   SET fcnt = size(request->items[x].facilities,5)
   SET stat = alterlist(request_main->items[x].facilities,fcnt)
   FOR (y = 1 TO fcnt)
    SET request_main->items[x].facilities[y].action_flag = request->items[x].facilities[y].
    action_flag
    SET request_main->items[x].facilities[y].code_value = request->items[x].facilities[y].code_value
   ENDFOR
 ENDFOR
 DECLARE active_cd = f8
 DECLARE system_cd = f8
 DECLARE inpatient_cd = f8
 DECLARE oedef_cd = f8
 DECLARE ord_cd = f8
 DECLARE alert_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE dispense_cd = f8
 DECLARE medproduct_cd = f8
 DECLARE ea_cd = f8
 DECLARE formulary_cd = f8
 DECLARE legend_cd = f8
 DECLARE desc_cd = f8
 DECLARE unique_cd = f8
 DECLARE desc_short_cd = f8
 DECLARE meddef_cd = f8
 DECLARE comment1_text = vc
 DECLARE comment1_type = i4
 DECLARE comment2_text = vc
 DECLARE comment2_type = i4
 DECLARE del_fac_parse = vc
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET inpatient_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET alert_cd = uar_get_code_by("MEANING",4063,"ORDERALERT")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET dispense_cd = uar_get_code_by("MEANING",4063,"DISPENSE")
 SET medproduct_cd = uar_get_code_by("MEANING",4063,"MEDPRODUCT")
 SET ea_cd = uar_get_code_by("MEANING",54,"EA")
 SET formulary_cd = uar_get_code_by("MEANING",4512,"FORMULARY")
 SET legend_cd = uar_get_code_by("MEANING",4200,"LEGEND")
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET unique_cd = uar_get_code_by("MEANING",11000,"RX_UNIQUEID")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET meddef_cd = uar_get_code_by("MEANING",11001,"MED_DEF")
 DECLARE sys_format = vc
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="RDDSFORMAT"
  DETAIL
   sys_format = dp.pref_str
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
 FREE SET rxa_get_req
 FREE SET rxa_get_reply
 EXECUTE rxa_get_medprod_rr_incl  WITH replace("REQUEST","RXA_GET_REQ"), replace("REPLY",
  "RXA_GET_REPLY")
 FOR (main_i = 1 TO size(request_main->items,5))
   SET stat = alterlist(rxa_get_req->qual,1)
   SET rxa_get_req->pharm_type_cd = inpatient_cd
   SET rxa_get_req->qual[1].item_id = request_main->items[main_i].id
   EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",request)
   SET stat = alterlist(rxa_get_req->qual,1)
   SET rxa_get_req->pharm_type_cd = inpatient_cd
   SET rxa_get_req->qual[1].item_id = request_main->items[main_i].id
   EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",request)
   SET cnt = size(request->meddefqual,5)
   FOR (x = 1 TO cnt)
     IF ((request->meddefqual[x].item_id=request_main->items[main_i].id))
      SET request->prod_rec_status = 1
      SET request->prod_id_rec_status = 3
      SET request->oc_rec_status = 0
      SET request->sent_rec_status = 1
      SET request->meddefqual[x].db_rec_status = 1
      SET request->meddefqual[x].ordcat[1].db_rec_status = 1
      FOR (y = 1 TO size(request->meddefqual[x].meddefflexqual,5))
        IF ((request->meddefqual[x].meddefflexqual[y].flex_type_cd=syspkg_cd)
         AND (request->meddefqual[x].meddefflexqual[y].sequence=0))
         SET request->meddefqual[x].meddefflexqual[y].db_rec_status = 1
         FOR (l = 1 TO size(request_main->items[main_i].facilities,5))
           IF ((request_main->items[main_i].facilities[l].action_flag=1))
            IF (size(request->meddefqual[x].meddefflexqual[y].medflexobjidxqual,5) > 0)
             SELECT INTO "nl:"
              FROM (dummyt d  WITH seq = size(request->meddefqual[x].meddefflexqual[y].
                medflexobjidxqual,5))
              PLAN (d
               WHERE (request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].
               flex_object_type_cd=ord_cd)
                AND (request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].
               parent_entity_id=0))
              ORDER BY d.seq
              DETAIL
               request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].db_rec_status = 2,
               request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].active_ind = 0
              WITH nocounter
             ;end select
            ENDIF
            SET fac_cnt = (size(request->meddefqual[x].meddefflexqual[y].medflexobjidxqual,5)+ 1)
            SET stat = alterlist(request->meddefqual[x].meddefflexqual[y].medflexobjidxqual,fac_cnt)
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].active_ind = 1
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].db_rec_status = 3
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].
            flex_object_type_cd = ord_cd
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].med_def_flex_id
             = request->meddefqual[x].meddefflexqual[y].med_def_flex_id
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].
            med_flex_object_id = 0
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].parent_entity =
            "CODE_VALUE"
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].parent_entity_id
             = request_main->items[main_i].facilities[l].code_value
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].sequence = 0
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].update_value_ind
             = 1
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].updt_cnt = 0
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].value = 0
            SET request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[fac_cnt].value_unit = 0
           ELSEIF ((request_main->items[main_i].facilities[l].action_flag=3))
            SELECT INTO "nl:"
             FROM (dummyt d  WITH seq = size(request->meddefqual[x].meddefflexqual[y].
               medflexobjidxqual,5))
             PLAN (d
              WHERE (request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].
              flex_object_type_cd=ord_cd)
               AND (request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].
              parent_entity_id=request_main->items[main_i].facilities[l].code_value))
             ORDER BY d.seq
             DETAIL
              request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].db_rec_status = 2,
              request->meddefqual[x].meddefflexqual[y].medflexobjidxqual[d.seq].active_ind = 0
             WITH nocounter
            ;end select
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   EXECUTE rxa_upd_medproduct
   DECLARE child_status = c1
   SET child_status = reply->status_data.status
   IF ((reply->status_data.status="F"))
    SET error_flag = "Y"
    GO TO exit_script
   ENDIF
   SET stat = initrec(request)
   SET stat = initrec(reply)
 ENDFOR
#exit_script
 SET modify = noskipsrvmsg
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
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
