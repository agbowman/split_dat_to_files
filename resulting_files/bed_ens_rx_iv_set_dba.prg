CREATE PROGRAM bed_ens_rx_iv_set:dba
 SET modify = skipsrvmsg
 FREE SET request_main
 RECORD request_main(
   1 action_flag = i2
   1 item_id = f8
   1 description = vc
   1 short_description = vc
   1 intermittent_ind = i2
   1 continuous_ind = i2
   1 default_flag = i2
   1 route_code_value = f8
   1 frequency_code_value = f8
   1 prn_ind = i2
   1 prn_reason_code_value = f8
   1 rate = f8
   1 rate_units_code_value = f8
   1 normal_rate = f8
   1 normal_rate_units_code_value = f8
   1 infuse_over = f8
   1 infuse_over_units_code_value = f8
   1 freetext_rate = vc
   1 stop_type_code_value = f8
   1 duration = f8
   1 duration_units_code_value = f8
   1 dispense_category_code_value = f8
   1 order_alert_code_value = f8
   1 price_schedule_id = f8
   1 ingredients[*]
     2 id = f8
     2 dose = f8
     2 dose_unit_code_value = f8
     2 freetext_dose = vc
     2 norm_rate_ind = i2
     2 strength_ind = i2
     2 volume_ind = i2
     2 diluent_ind = i2
     2 action_flag = i2
     2 sequence = i4
     2 mis_id = f8
     2 mis_seq = i4
     2 y_idx = i4
   1 facilities[*]
     2 action_flag = i2
     2 code_value = f8
   1 notes[*]
     2 text = vc
     2 mar_ind = i2
     2 label_ind = i2
     2 fill_list_ind = i2
 )
 SET error_flag = "N"
 SET cnt = 0
 SET icnt = 0
 SET request_main->action_flag = request->action_flag
 SET request_main->item_id = request->item_id
 SET request_main->description = request->description
 SET request_main->short_description = request->short_description
 SET request_main->intermittent_ind = request->intermittent_ind
 SET request_main->continuous_ind = request->continuous_ind
 SET request_main->default_flag = request->default_flag
 SET request_main->route_code_value = request->route_code_value
 SET request_main->frequency_code_value = request->frequency_code_value
 SET request_main->prn_ind = request->prn_ind
 SET request_main->prn_reason_code_value = request->prn_reason_code_value
 SET request_main->rate = request->rate
 SET request_main->rate_units_code_value = request->rate_units_code_value
 SET request_main->normal_rate = request->normal_rate
 SET request_main->normal_rate_units_code_value = request->normal_rate_units_code_value
 SET request_main->infuse_over = request->infuse_over
 SET request_main->infuse_over_units_code_value = request->infuse_over_units_code_value
 SET request_main->freetext_rate = request->freetext_rate
 SET request_main->stop_type_code_value = request->stop_type_code_value
 SET request_main->duration = request->duration
 SET request_main->duration_units_code_value = request->duration_units_code_value
 SET request_main->dispense_category_code_value = request->dispense_category_code_value
 SET request_main->order_alert_code_value = request->order_alert_code_value
 SET request_main->price_schedule_id = request->price_schedule_id
 SET cnt = size(request->ingredients,5)
 SET stat = alterlist(request_main->ingredients,cnt)
 DECLARE sequence_value = i4
 FOR (x = 1 TO cnt)
   SET request_main->ingredients[x].id = request->ingredients[x].id
   SET request_main->ingredients[x].dose = request->ingredients[x].dose
   SET request_main->ingredients[x].dose_unit_code_value = request->ingredients[x].
   dose_unit_code_value
   SET request_main->ingredients[x].freetext_dose = request->ingredients[x].freetext_dose
   SET request_main->ingredients[x].norm_rate_ind = request->ingredients[x].norm_rate_ind
   SET request_main->ingredients[x].strength_ind = request->ingredients[x].strength_ind
   SET request_main->ingredients[x].volume_ind = request->ingredients[x].volume_ind
   SET request_main->ingredients[x].diluent_ind = request->ingredients[x].diluent_ind
   SET request_main->ingredients[x].action_flag = request->ingredients[x].action_flag
   SET sequence_value = x
   IF (validate(request->ingredients[x].sequence))
    SET sequence_value = request->ingredients[x].sequence
   ENDIF
   SET request_main->ingredients[x].sequence = sequence_value
 ENDFOR
 SET cnt = size(request->facilities,5)
 SET stat = alterlist(request_main->facilities,cnt)
 FOR (x = 1 TO cnt)
  SET request_main->facilities[x].action_flag = request->facilities[x].action_flag
  SET request_main->facilities[x].code_value = request->facilities[x].code_value
 ENDFOR
 SET cnt = size(request->notes,5)
 SET stat = alterlist(request_main->notes,cnt)
 FOR (x = 1 TO cnt)
   SET request_main->notes[x].text = request->notes[x].text
   SET request_main->notes[x].mar_ind = request->notes[x].mar_ind
   SET request_main->notes[x].label_ind = request->notes[x].label_ind
   SET request_main->notes[x].fill_list_ind = request->notes[x].fill_list_ind
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
 DECLARE unique_id_pref = vc
 DECLARE unique_id_text = vc
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="RDDSFORMAT"
   AND dp.person_id=0
  DETAIL
   unique_id_pref = dp.pref_str
  WITH nocounter
 ;end select
 SET unique_id_text = unique_id_pref
 SET unique_id_text = replace(unique_id_text,"/f","All")
 SET unique_id_text = replace(unique_id_text,"/p","Inpatient")
 SET unique_id_text = replace(unique_id_text,"/d",trim(request_main->description))
 SET unique_id_text = replace(unique_id_text,"/s",trim(request_main->short_description))
 SET unique_id_text = replace(unique_id_text,"/a","Active")
 IF ((request_main->action_flag=1))
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
  FREE SET reply
  RECORD reply(
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
  SET request->item_group_active_ind = 0
  SET request->item1_id = 0
  SET request->item2_id = 0
  SET request->tag1 = 0
  SET request->cost1 = 0
  SET request->cost2 = 0
  SET request->awp = 0
  SET request->nbr_packs_to_chg = 0
  SET request->nbr_packs_to_add = 0
  SET request->id_type_cd = 0
  SET request->prep_into_flag = 0
  SET request->catalog_type_disp = ""
  SET request->iv_ingredient_ind = 0
  SET request->gcr_desc = ""
  SET request->package_type_id = 0
  SET request->order_alert1_cd = 0
  SET request->order_alert2_cd = 0
  SET request->side_effect_code = ""
  SET request->primary_manf_item_id = 0
  SET request->nbr_ids_to_add = 0
  SET request->comment1_text = ""
  SET request->comment2_text = ""
  SET request->compound_text = ""
  SET request->countable_ind = 0
  SET request->fda_reportable_ind = 0
  SET request->active_status_cd = 0
  SET request->shelf_life = 0
  SET request->shelf_life_uom_cd = 0
  SET request->component_usage_ind = 0
  SET request->component_ind = 0
  SET request->quickadd_ind = 0
  SET request->approved_ind = 0
  SET request->item_type_cd = 0
  SET request->db_rec_status = 0
  SET request->prod_rec_status = 3
  SET request->manf_rec_status = 0
  SET request->prod_id_rec_status = 3
  SET request->oc_rec_status = 0
  SET request->sent_rec_status = 3
  SET request->pack_rec_status = 3
  SET stat = alterlist(request->meddefqual,1)
  SET ncnt = size(request_main->notes,5)
  IF (ncnt > 0)
   SET comment1_text = request_main->notes[1].text
   IF ((request_main->notes[1].mar_ind=1))
    SET comment1_type = (comment1_type+ 2)
   ENDIF
   IF ((request_main->notes[1].fill_list_ind=1))
    SET comment1_type = (comment1_type+ 1)
   ENDIF
   IF ((request_main->notes[1].label_ind=1))
    SET comment1_type = (comment1_type+ 4)
   ENDIF
  ENDIF
  IF (ncnt=2)
   SET comment2_text = request_main->notes[2].text
   IF ((request_main->notes[2].mar_ind=1))
    SET comment2_type = (comment2_type+ 2)
   ENDIF
   IF ((request_main->notes[2].fill_list_ind=1))
    SET comment2_type = (comment2_type+ 1)
   ENDIF
   IF ((request_main->notes[2].label_ind=1))
    SET comment2_type = (comment2_type+ 4)
   ENDIF
  ENDIF
  SET request->meddefqual[1].gfc_description = ""
  SET request->meddefqual[1].active_status_cd = active_cd
  SET request->meddefqual[1].updt_cnt = 0
  SET request->meddefqual[1].db_rec_status = 3
  SET request->meddefqual[1].med_type_flag = 3
  SET request->meddefqual[1].item_id = 0
  SET request->meddefqual[1].mdx_gfc_nomen_id = 0
  SET request->meddefqual[1].form_cd = 0
  SET request->meddefqual[1].strength = 0
  SET request->meddefqual[1].strength_unit_cd = 0
  SET request->meddefqual[1].volume = 0
  SET request->meddefqual[1].volume_unit_cd = 0
  SET request->meddefqual[1].given_strength = ""
  SET request->meddefqual[1].meq_factor = 0
  SET request->meddefqual[1].mmol_factor = 0
  SET request->meddefqual[1].compound_text_id = 0
  SET request->meddefqual[1].compound_text = ""
  SET request->meddefqual[1].comment1_text = comment1_text
  SET request->meddefqual[1].comment2_text = comment2_text
  SET request->meddefqual[1].comment1_id = 0
  SET request->meddefqual[1].comment2_id = 0
  SET request->meddefqual[1].cki = ""
  SET request->meddefqual[1].schedulable_ind = 0
  SET request->meddefqual[1].reusable_ind = 0
  SET request->meddefqual[1].cdm = ""
  SET request->meddefqual[1].critical_ind = 0
  SET request->meddefqual[1].sub_account_cd = 0
  SET request->meddefqual[1].cost_center_cd = 0
  SET request->meddefqual[1].storage_requirement_cd = 0
  SET request->meddefqual[1].sterilization_required_ind = 0
  SET request->meddefqual[1].base_issue_factor = 1
  SET request->meddefqual[1].active_ind = 1
  SET request->meddefqual[1].package_type_id = 0
  SET request->meddefqual[1].template_catalog_cd = 0
  SET request->meddefqual[1].template_synonym_id = 0
  SET request->meddefqual[1].primary_synonym_mnemonic = ""
  SET stat = alterlist(request->meddefqual[1].locqual,0)
  SET stat = alterlist(request->meddefqual[1].pack,0)
  SET stat = alterlist(request->meddefqual[1].ordcat,1)
  SET request->meddefqual[1].ordcat[1].prep_into_flag = 0
  SET request->meddefqual[1].ordcat[1].db_rec_status = 0
  SET request->meddefqual[1].ordcat[1].catalog_cd = 0
  SET request->meddefqual[1].ordcat[1].consent_form_ind = 0
  SET request->meddefqual[1].ordcat[1].active_ind = 0
  SET request->meddefqual[1].ordcat[1].catalog_type_cd = 0
  SET request->meddefqual[1].ordcat[1].catalog_type_disp = ""
  SET request->meddefqual[1].ordcat[1].activity_type_cd = 0
  SET request->meddefqual[1].ordcat[1].activity_subtype_cd = 0
  SET request->meddefqual[1].ordcat[1].requisition_format_cd = 0
  SET request->meddefqual[1].ordcat[1].requisition_routing_cd = 0
  SET request->meddefqual[1].ordcat[1].inst_restriction_ind = 0
  SET request->meddefqual[1].ordcat[1].schedule_ind = 0
  SET request->meddefqual[1].ordcat[1].description = ""
  SET request->meddefqual[1].ordcat[1].iv_ingredient_ind = 0
  SET request->meddefqual[1].ordcat[1].print_req_ind = 0
  SET request->meddefqual[1].ordcat[1].oe_format_id = 0
  SET request->meddefqual[1].ordcat[1].orderable_type_flag = 1
  SET request->meddefqual[1].ordcat[1].complete_upon_order_ind = 0
  SET request->meddefqual[1].ordcat[1].quick_chart_ind = 0
  SET request->meddefqual[1].ordcat[1].comment_template_flag = 0
  SET request->meddefqual[1].ordcat[1].prep_info_flag = 0
  SET request->meddefqual[1].ordcat[1].updt_cnt = 0
  SET request->meddefqual[1].ordcat[1].valid_iv_additive_ind = 0
  SET request->meddefqual[1].ordcat[1].dc_display_days = - (1)
  SET request->meddefqual[1].ordcat[1].dc_interaction_days = - (1)
  SET request->meddefqual[1].ordcat[1].op_dc_display_days = 0
  SET request->meddefqual[1].ordcat[1].op_dc_interaction_days = 0
  SET request->meddefqual[1].ordcat[1].set_op_days = 0
  SET request->meddefqual[1].ordcat[1].mdx_gcr_nomen_id = 0
  SET request->meddefqual[1].ordcat[1].cki = ""
  SET request->meddefqual[1].ordcat[1].gcr_desc = ""
  SET stat = alterlist(request->meddefqual[1].ordcat[1].ahfs_qual,0)
  SET stat = alterlist(request->meddefqual[1].ordcat[1].qual_mnemonic,0)
  SET icnt = size(request_main->ingredients,5)
  SET stat = alterlist(request->meddefqual[1].meddefflexqual,2)
  SET request->meddefqual[1].meddefflexqual[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[1].parent_entity = ""
  SET request->meddefqual[1].meddefflexqual[1].sequence = 0
  SET request->meddefqual[1].meddefflexqual[1].flex_type_cd = system_cd
  SET request->meddefqual[1].meddefflexqual[1].flex_sort_flag = 600
  SET request->meddefqual[1].meddefflexqual[1].pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[1].parent_med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[1].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[1].active_ind = 1
  SET request->active_status_cd = active_cd
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].pack,1)
  SET request->meddefqual[1].meddefflexqual[1].pack[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].pack[1].item_id = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].description = ""
  SET request->meddefqual[1].meddefflexqual[1].pack[1].uom_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].base_uom_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].qty = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].base_package_type_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].pack[1].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].pack[1].updt_cnt = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,3)
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].salable_by_vendor_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].salable_by_mfr_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].id_type_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].flex_sort_flag = 600
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_identifier_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].order_set_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].item_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_product_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].sequence = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].flex_type_cd = system_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_identifier_type_cd =
  desc_short_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value = request_main->
  short_description
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value_key = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_type_flag = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].primary_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].salable_by_vendor_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].salable_by_mfr_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].id_type_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].flex_sort_flag = 600
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_identifier_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].order_set_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].item_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_product_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].sequence = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].flex_type_cd = system_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_identifier_type_cd =
  unique_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value = unique_id_text
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value_key = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_type_flag = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].primary_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].salable_by_vendor_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].salable_by_mfr_ind = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].id_type_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].flex_sort_flag = 600
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_identifier_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].order_set_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].item_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_product_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].sequence = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].flex_type_cd = system_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_identifier_type_cd = desc_cd
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value = request_main->description
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value_key = ""
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_type_flag = 3
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].primary_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].updt_cnt = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual,1)
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_flex_object_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].sequence = 1
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity = "MED_OE_DEFAULTS"
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].flex_object_type_cd = oedef_cd
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value_unit = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].updt_cnt = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].meddispensequal,
   0)
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].
   medoedefaultsqual,1)
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  freetext_dose = ""
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].diluent_id
   = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  diluent_volume = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  comment1_text = comment1_text
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  comment2_text = comment2_text
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  default_par_doses = - (1)
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  max_par_supply = - (1)
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  med_oe_defaults_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].strength = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  strength_unit_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].volume = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  volume_unit_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].route_cd =
  request_main->route_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].frequency_cd
   = request_main->frequency_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].prn_ind =
  request_main->prn_ind
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  prn_reason_cd = request_main->prn_reason_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].infuse_over
   = request_main->infuse_over
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  infuse_over_cd = request_main->infuse_over_units_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].duration =
  request_main->duration
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  duration_unit_cd = request_main->duration_units_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].stop_type_cd
   = request_main->stop_type_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  dispense_category_cd = request_main->dispense_category_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  alternate_dispense_category_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].comment1_id
   = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  comment1_type = comment1_type
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].comment2_id
   = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  comment2_type = comment2_type
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  price_sched_id = request_main->price_schedule_id
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].active_ind
   = 1
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].rx_qty = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].daw_cd = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].sig_codes =
  ""
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].nbr_labels
   = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  ord_as_synonym_id = 0
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].rate =
  request_main->rate
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].rate_cd =
  request_main->rate_units_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  normalized_rate = request_main->normal_rate
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  normalized_rate_cd = request_main->normal_rate_units_code_value
  SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
  freetext_rate = request_main->freetext_rate
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medproductqual,0
   )
  IF ((request_main->order_alert_code_value > 0))
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual,2)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].med_flex_object_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].parent_entity_id = request_main
   ->order_alert_code_value
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].sequence = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].parent_entity = "CODE_VALUE"
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].flex_object_type_cd = alert_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].value = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].meddispensequal,
    0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
    medoedefaultsqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual,
    0)
  ENDIF
  SET request->meddefqual[1].meddefflexqual[2].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[2].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[2].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[2].parent_entity = ""
  SET request->meddefqual[1].meddefflexqual[2].sequence = 0
  SET request->meddefqual[1].meddefflexqual[2].flex_type_cd = syspkg_cd
  SET request->meddefqual[1].meddefflexqual[2].flex_sort_flag = 500
  SET request->meddefqual[1].meddefflexqual[2].pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[2].parent_med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[2].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[2].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[2].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[2].active_status_cd = active_cd
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].pack,1)
  SET request->meddefqual[1].meddefflexqual[2].pack[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[2].pack[1].item_id = 0
  SET request->meddefqual[1].meddefflexqual[2].pack[1].package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[2].pack[1].description = "EA"
  SET request->meddefqual[1].meddefflexqual[2].pack[1].uom_cd = ea_cd
  SET request->meddefqual[1].meddefflexqual[2].pack[1].base_uom_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].pack[1].qty = 1
  SET request->meddefqual[1].meddefflexqual[2].pack[1].base_package_type_ind = 1
  SET request->meddefqual[1].meddefflexqual[2].pack[1].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[2].pack[1].updt_cnt = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medidentifierqual,0)
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,1)
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].db_rec_status = 3
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_def_flex_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_flex_object_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].sequence = 1
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity = "MED_DISPENSE"
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].flex_object_type_cd = dispense_cd
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value_unit = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].active_ind = 1
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].updt_cnt = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal,
   1)
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  pharmacy_type_cd = inpatient_cd
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  pat_orderable_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].db_rec_status
   = 3
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  med_dispense_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].item_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  package_type_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  package_type_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  parent_entity_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].parent_entity
   = ""
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].flex_type_cd
   = syspkg_cd
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].flex_sort_flag
   = 500
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  legal_status_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  formulary_status_cd = formulary_cd
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].oe_format_flag
   = request_main->default_flag
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].med_filter_ind
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  continuous_filter_ind = request_main->continuous_ind
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  intermittent_filter_ind = request_main->intermittent_ind
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].tpn_filter_ind
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].max_par_supply
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  infinite_div_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].divisible_ind
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  used_as_base_ind = 1
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  always_dispense_from_flag = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].dispense_qty
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  dispense_factor = 1
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].label_ratio =
  0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].reusable_ind
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].strength = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  strength_unit_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].volume = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].volume_unit_cd
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  base_issue_factor = 1
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].updt_cnt = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  pkg_qty_per_pkg = - (1)
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  pkg_disp_more_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  override_clsfctn_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  rx_station_notes = ""
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  rx_station_notes_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  witness_dispense_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  witness_return_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  witness_adhoc_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  witness_override_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  witness_waste_ind = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].workflow_cd =
  0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_balance_method_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_chloride_pct = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_default_ingred_item_id = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_fill_method_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_include_ions_flag = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_overfill_amt = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_overfill_unit_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_preferred_cation_cd = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  tpn_product_type_flag = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].tpn_scale_flag
   = 0
  SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
  lot_tracking_ind = 0
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].
   medoedefaultsqual,0)
  SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].medproductqual,0
   )
  SET fcnt = size(request_main->facilities,5)
  IF (fcnt=0)
   SET z = size(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,5)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,(z+ 1))
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].med_flex_object_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].sequence = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].parent_entity = ""
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].flex_object_type_cd =
   ord_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].value = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
    medoedefaultsqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
    medproductqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
    meddispensequal,0)
  ENDIF
  FOR (x = 1 TO fcnt)
    SET z = size(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,5)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,(z+ 1))
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].med_flex_object_id = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].parent_entity_id =
    request_main->facilities[x].code_value
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].sequence = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].parent_entity =
    "CODE_VALUE"
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].flex_object_type_cd =
    ord_cd
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].value = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].value_unit = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].updt_cnt = 0
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
     medoedefaultsqual,0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
     medproductqual,0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[(z+ 1)].
     meddispensequal,0)
  ENDFOR
  FOR (x = 1 TO icnt)
    SET z = size(request->meddefqual[1].meddefflexqual,5)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual,(z+ 1))
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_entity = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].sequence = x
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].flex_type_cd = syspkg_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].flex_sort_flag = 500
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pharmacy_type_cd = inpatient_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].updt_cnt = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].active_status_cd = active_cd
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].pack,1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].item_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].description = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].uom_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].base_uom_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].qty = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].base_package_type_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].updt_cnt = 0
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medidentifierqual,0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual,2)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].med_flex_object_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].sequence = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].parent_entity =
    "MED_DISPENSE"
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].flex_object_type_cd =
    dispense_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].value = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].value_unit = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].updt_cnt = 0
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
     meddispensequal,1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    pharmacy_type_cd = inpatient_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    pat_orderable_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    med_dispense_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].item_id
     = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    package_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    parent_entity = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    flex_type_cd = syspkg_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    flex_sort_flag = 500
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    legal_status_cd = legend_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    formulary_status_cd = formulary_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    oe_format_flag = request_main->default_flag
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    med_filter_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    continuous_filter_ind = request_main->continuous_ind
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    intermittent_filter_ind = request_main->intermittent_ind
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_filter_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    max_par_supply = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    infinite_div_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    divisible_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    used_as_base_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    always_dispense_from_flag = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    dispense_qty = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    dispense_factor = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    label_ratio = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    reusable_ind = 0
    IF ((request_main->ingredients[x].strength_ind=1))
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     strength = request_main->ingredients[x].dose
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     strength_unit_cd = request_main->ingredients[x].dose_unit_code_value
    ELSEIF ((request_main->ingredients[x].volume_ind=1))
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].volume
      = request_main->ingredients[x].dose
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     volume_unit_cd = request_main->ingredients[x].dose_unit_code_value
    ENDIF
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    base_issue_factor = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    updt_cnt = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    pkg_qty_per_pkg = - (1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    pkg_disp_more_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    override_clsfctn_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    rx_station_notes = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    rx_station_notes_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    witness_dispense_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    witness_return_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    witness_adhoc_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    witness_override_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    witness_waste_ind = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    workflow_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_balance_method_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_chloride_pct = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_default_ingred_item_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_fill_method_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_include_ions_flag = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_overfill_amt = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_overfill_unit_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_preferred_cation_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_product_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    tpn_scale_flag = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
    lot_tracking_ind = 0
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
     medoedefaultsqual,0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
     medproductqual,0)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].med_flex_object_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].sequence = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].parent_entity =
    "MED_OE_DEFAULTS"
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].flex_object_type_cd =
    oedef_cd
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].value = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].value_unit = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].updt_cnt = 0
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
     meddispensequal,0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
     medoedefaultsqual,1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    freetext_dose = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    diluent_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    diluent_volume = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment1_text = comment1_text
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment2_text = comment2_text
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    default_par_doses = - (1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    max_par_supply = - (1)
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    med_oe_defaults_id = 0
    IF ((request_main->ingredients[x].strength_ind=1))
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     strength = request_main->ingredients[x].dose
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     strength_unit_cd = request_main->ingredients[x].dose_unit_code_value
    ELSEIF ((request_main->ingredients[x].volume_ind=1))
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     volume = request_main->ingredients[x].dose
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     volume_unit_cd = request_main->ingredients[x].dose_unit_code_value
    ENDIF
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    route_cd = request_main->route_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    frequency_cd = request_main->frequency_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    prn_ind = request_main->prn_ind
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    prn_reason_cd = request_main->prn_reason_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    infuse_over = request_main->infuse_over
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    infuse_over_cd = request_main->infuse_over_units_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    duration = request_main->duration
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    duration_unit_cd = request_main->duration_units_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    stop_type_cd = request_main->stop_type_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    dispense_category_cd = request_main->dispense_category_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    alternate_dispense_category_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment1_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment1_type = comment1_type
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment2_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    comment2_type = comment2_type
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    price_sched_id = request_main->price_schedule_id
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    active_ind = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    updt_cnt = 4
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    rx_qty = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    daw_cd = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    sig_codes = ""
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    nbr_labels = 1
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    ord_as_synonym_id = 0
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].rate
     = request_main->rate
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    rate_cd = request_main->rate_units_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    normalized_rate = request_main->normal_rate
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    normalized_rate_cd = request_main->normal_rate_units_code_value
    SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
    freetext_rate = request_main->freetext_rate
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
     medproductqual,0)
    SET stat = alterlist(request->meddefqual[1].medingredqual,x)
    SET request->meddefqual[1].medingredqual[x].med_ingred_set_id = 0
    SET request->meddefqual[1].medingredqual[x].parent_item_id = 0
    SET request->meddefqual[1].medingredqual[x].sequence = x
    SET request->meddefqual[1].medingredqual[x].child_item_id = request_main->ingredients[x].id
    SET request->meddefqual[1].medingredqual[x].child_med_prod_id = 0
    SET request->meddefqual[1].medingredqual[x].child_pkg_type_id = 0
    SET request->meddefqual[1].medingredqual[x].inc_in_total_ind = 0
    SET request->meddefqual[1].medingredqual[x].base_ind = 0
    SET request->meddefqual[1].medingredqual[x].cmpd_qty = 0
    SET request->meddefqual[1].medingredqual[x].default_action_cd = 0
    SET request->meddefqual[1].medingredqual[x].updt_cnt = 0
    SET request->meddefqual[1].medingredqual[x].normalized_rate_ind = request_main->ingredients[x].
    norm_rate_ind
    SET request->meddefqual[1].medingredqual[x].strength = 0
    SET request->meddefqual[1].medingredqual[x].strength_unit_cd = 0
    SET request->meddefqual[1].medingredqual[x].volume = 0
    SET request->meddefqual[1].medingredqual[x].volume_unit_cd = 0
  ENDFOR
  SET stat = alterlist(request->meddefqual[1].tpn_group_qual,0)
  SET request->meddefqual[1].premix_ind = 0
  SET request->meddefqual[1].inv_factor_nbr = 0
  SET request->meddefqual[1].inv_base_pkg_uom_cd = 0
  SET request->meddefqual[1].inv_tracking_level = 0
  SET stat = alterlist(request->qual,0)
  SET stat = alterlist(request->add_id_qual,0)
  SET stat = alterlist(request->chg_id_qual,0)
  SET stat = alterlist(request->del_id_qual,0)
  SET stat = alterlist(request->add_pack_qual,0)
  SET stat = alterlist(request->chg_pack_qual,0)
  SET stat = alterlist(request->rmv_pack_qual,0)
  SET stat = alterlist(request->del_pack_qual,0)
  SET request->total_ids_to_add = 0
  SET request->total_ids_to_chg = 0
  SET request->total_ids_to_del = 0
  SET request->total_packs_to_add = 0
  SET request->total_packs_to_chg = 0
  SET request->total_packs_to_del = 0
  SET request->total_packs_to_rmv = 0
  SET request->item_id = 0
  SET request->consent_form_ind = 0
  SET request->active_ind = 0
  SET request->catalog_cd = 0
  SET request->catalog_type_cd = 0
  SET request->activity_type_cd = 0
  SET request->activity_subtype_cd = 0
  SET request->requisition_format_cd = 0
  SET request->requisition_routing_cd = 0
  SET request->inst_restriction_ind = 0
  SET request->schedule_ind = 0
  SET request->description = ""
  SET request->print_req_ind = 0
  SET request->oe_format_id = 0
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
  SET request->mdx_gcr_nomen_id = 0
  SET request->mnemonic = ""
  SET request->mnemonic_type_cd = 0
  SET request->order_sentence_id = 0
  SET request->mnem_active_ind = 0
  SET request->cki = ""
  SET request->syn_add_cnt = 0
  SET request->syn_upd_cnt = 0
  SET stat = alterlist(request->add_qual,0)
  SET stat = alterlist(request->upd_qual,0)
  SET request->sent_cnt = 0
  SET stat = alterlist(request->sent_qual,0)
  SET request->updt_cnt = 0
  SET request->location_group_type_cd = 0
  SET request->root_loc_cd = 0
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
  SET request->replacement_upn_id = 0
  SET stat = alterlist(request->addqual,0)
  SET stat = alterlist(request->updqual,0)
  SET stat = alterlist(request->del_qual,0)
  SET request->synonym_id = 0
  SET request->synonym_cki = ""
  SET request->nbr_of_add_locator = 0
  SET request->nbr_of_del_locator = 0
  SET request->view_type_cd = 0
  EXECUTE rxa_add_medproduct
  IF ((reply->status_data.status="F"))
   SET error_flag = "Y"
  ENDIF
 ELSEIF ((request_main->action_flag=2))
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
  SET stat = alterlist(rxa_get_req->qual,1)
  SET rxa_get_req->pharm_type_cd = inpatient_cd
  SET rxa_get_req->qual[1].item_id = request_main->item_id
  EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",request)
  SET request->prod_rec_status = 1
  SET request->prod_id_rec_status = 3
  SET request->oc_rec_status = 0
  SET request->sent_rec_status = 1
  SET request->meddefqual[1].db_rec_status = 1
  SET ncnt = size(request_main->notes,5)
  IF (ncnt > 0)
   SET comment1_text = request_main->notes[1].text
   IF ((request_main->notes[1].mar_ind=1))
    SET comment1_type = (comment1_type+ 2)
   ENDIF
   IF ((request_main->notes[1].fill_list_ind=1))
    SET comment1_type = (comment1_type+ 1)
   ENDIF
   IF ((request_main->notes[1].label_ind=1))
    SET comment1_type = (comment1_type+ 4)
   ENDIF
  ENDIF
  IF (ncnt=2)
   SET comment2_text = request_main->notes[2].text
   IF ((request_main->notes[2].mar_ind=1))
    SET comment2_type = (comment2_type+ 2)
   ENDIF
   IF ((request_main->notes[2].fill_list_ind=1))
    SET comment2_type = (comment2_type+ 1)
   ENDIF
   IF ((request_main->notes[2].label_ind=1))
    SET comment2_type = (comment2_type+ 4)
   ENDIF
  ENDIF
  IF (comment1_text > " ")
   SET request->meddefqual[1].comment1_text = comment1_text
  ENDIF
  IF (comment2_text > " ")
   SET request->meddefqual[1].comment2_text = comment2_text
  ENDIF
  FOR (y = 1 TO size(request->meddefqual[1].meddefflexqual,5))
    IF ((request->meddefqual[1].meddefflexqual[y].flex_type_cd=system_cd))
     FOR (x = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5))
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].db_rec_status = 1
      FOR (z = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].
       medoedefaultsqual,5))
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        comment1_text = comment1_text
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        comment2_text = comment2_text
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        route_cd = request_main->route_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        frequency_cd = request_main->frequency_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        prn_ind = request_main->prn_ind
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        prn_reason_cd = request_main->prn_reason_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        infuse_over = request_main->infuse_over
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        infuse_over_cd = request_main->infuse_over_units_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        duration = request_main->duration
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        duration_unit_cd = request_main->duration_units_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        stop_type_cd = request_main->stop_type_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        dispense_category_cd = request_main->dispense_category_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        comment1_type = comment1_type
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        comment2_type = comment2_type
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        price_sched_id = request_main->price_schedule_id
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].rate
         = request_main->rate
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        rate_cd = request_main->rate_units_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        normalized_rate = request_main->normal_rate
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        normalized_rate_cd = request_main->normal_rate_units_code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[x].medoedefaultsqual[z].
        freetext_rate = request_main->freetext_rate
      ENDFOR
     ENDFOR
    ENDIF
    IF ((request->meddefqual[1].meddefflexqual[y].flex_type_cd=syspkg_cd))
     SET request->meddefqual[1].meddefflexqual[y].db_rec_status = 1
     FOR (l = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5))
       IF ((request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].flex_object_type_cd=
       dispense_cd))
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].db_rec_status = 1
        FOR (d = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].
         meddispensequal,5))
          SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].meddispensequal[d].
          db_rec_status = 1
          SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].meddispensequal[d].
          oe_format_flag = request_main->default_flag
          SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].meddispensequal[d].
          med_filter_ind = 0
          SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].meddispensequal[d].
          continuous_filter_ind = request_main->continuous_ind
          SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].meddispensequal[d].
          intermittent_filter_ind = request_main->intermittent_ind
        ENDFOR
       ENDIF
     ENDFOR
     FOR (l = 1 TO size(request_main->facilities,5))
       IF ((request_main->facilities[l].action_flag=1))
        IF (size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5) > 0)
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,
            5))
          PLAN (d
           WHERE (request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].
           flex_object_type_cd=ord_cd)
            AND (request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].parent_entity_id=0
           ))
          ORDER BY d.seq
          DETAIL
           request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].db_rec_status = 2,
           request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].active_ind = 0
          WITH nocounter
         ;end select
        ENDIF
        SET fac_cnt = (size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5)+ 1)
        SET stat = alterlist(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,fac_cnt)
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].active_ind = 1
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].db_rec_status = 3
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].flex_object_type_cd
         = ord_cd
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].med_def_flex_id =
        request->meddefqual[1].meddefflexqual[y].med_def_flex_id
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].med_flex_object_id =
        0
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].parent_entity =
        "CODE_VALUE"
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].parent_entity_id =
        request_main->facilities[l].code_value
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].sequence = 0
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].update_value_ind = 1
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].updt_cnt = 0
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].value = 0
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[fac_cnt].value_unit = 0
       ELSEIF ((request_main->facilities[l].action_flag=3))
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5
           ))
         PLAN (d
          WHERE (request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].
          flex_object_type_cd=ord_cd)
           AND (request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].parent_entity_id=
          request_main->facilities[l].code_value))
         ORDER BY d.seq
         DETAIL
          request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].db_rec_status = 2,
          request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[d.seq].active_ind = 0
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
    ENDIF
    IF ((request->meddefqual[1].meddefflexqual[y].flex_type_cd=system_cd))
     SET request->meddefqual[1].meddefflexqual[y].db_rec_status = 1
     FOR (l = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5))
       IF ((request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].flex_object_type_cd=
       alert_cd)
        AND (request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].sequence=0))
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[l].db_rec_status = 2
       ENDIF
     ENDFOR
     IF ((request_main->order_alert_code_value > 0))
      SET stat = alterlist(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,(l+ 1))
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].db_rec_status = 3
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].med_def_flex_id = 0
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].med_flex_object_id = 0
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].parent_entity_id =
      request_main->order_alert_code_value
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].sequence = 0
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].parent_entity =
      "CODE_VALUE"
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].flex_object_type_cd =
      alert_cd
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].value = 0
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].value_unit = 0
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].active_ind = 1
      SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].updt_cnt = 0
      SET stat = alterlist(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].
       meddispensequal,0)
      SET stat = alterlist(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].
       medoedefaultsqual,0)
      SET stat = alterlist(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[(l+ 1)].
       medproductqual,0)
     ENDIF
     FOR (l = 1 TO size(request->meddefqual[1].meddefflexqual[y].medidentifierqual,5))
       IF ((request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].primary_ind=true))
        IF ((request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].med_identifier_type_cd=
        desc_short_cd))
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].db_rec_status = 1
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].value = request_main->
         short_description
        ENDIF
        IF ((request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].med_identifier_type_cd=
        desc_cd))
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].db_rec_status = 1
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].value = request_main->
         description
        ENDIF
        IF ((request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].med_identifier_type_cd=
        unique_cd))
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].db_rec_status = 1
         SET request->meddefqual[1].meddefflexqual[y].medidentifierqual[l].value = unique_id_text
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  FOR (x = 1 TO size(request_main->ingredients,5))
   SELECT INTO "nl:"
    FROM med_ingred_set m
    PLAN (m
     WHERE (m.parent_item_id=request_main->item_id)
      AND (m.child_item_id=request_main->ingredients[x].id))
    DETAIL
     request_main->ingredients[x].mis_id = m.med_ingred_set_id, request_main->ingredients[x].mis_seq
      = m.sequence
    WITH nocounter
   ;end select
   FOR (y = 1 TO size(request->meddefqual[1].meddefflexqual,5))
     IF ((request->meddefqual[1].meddefflexqual[y].flex_type_cd=syspkg_cd)
      AND (request->meddefqual[1].meddefflexqual[y].sequence > 0))
      IF ((request->meddefqual[1].meddefflexqual[y].sequence=request_main->ingredients[x].mis_seq))
       SET request_main->ingredients[x].y_idx = y
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
  FOR (x = 1 TO size(request_main->ingredients,5))
    IF ((request_main->ingredients[x].action_flag=1))
     SET stat = alterlist(request->meddefqual[1].medingredqual,x)
     SET request->meddefqual[1].medingredqual[x].med_ingred_set_id = request_main->ingredients[x].
     mis_id
     SET request->meddefqual[1].medingredqual[x].parent_item_id = 0
     SET request->meddefqual[1].medingredqual[x].sequence = request_main->ingredients[x].sequence
     SET request->meddefqual[1].medingredqual[x].child_item_id = request_main->ingredients[x].id
     SET request->meddefqual[1].medingredqual[x].child_med_prod_id = 0
     SET request->meddefqual[1].medingredqual[x].child_pkg_type_id = 0
     SET request->meddefqual[1].medingredqual[x].inc_in_total_ind = 0
     SET request->meddefqual[1].medingredqual[x].base_ind = 0
     SET request->meddefqual[1].medingredqual[x].cmpd_qty = 0
     SET request->meddefqual[1].medingredqual[x].default_action_cd = 0
     SET request->meddefqual[1].medingredqual[x].updt_cnt = 0
     SET request->meddefqual[1].medingredqual[x].normalized_rate_ind = request_main->ingredients[x].
     norm_rate_ind
     SET request->meddefqual[1].medingredqual[x].strength = 0
     SET request->meddefqual[1].medingredqual[x].strength_unit_cd = 0
     SET request->meddefqual[1].medingredqual[x].volume = 0
     SET request->meddefqual[1].medingredqual[x].volume_unit_cd = 0
    ENDIF
    SET y = request_main->ingredients[x].y_idx
    IF ((request->meddefqual[1].meddefflexqual[y].sequence != request_main->ingredients[x].sequence))
     FOR (yyy = 1 TO size(request->meddefqual[1].meddefflexqual,5))
       IF ((request->meddefqual[1].meddefflexqual[yyy].flex_type_cd=syspkg_cd)
        AND (request->meddefqual[1].meddefflexqual[yyy].sequence > 0))
        IF ((request->meddefqual[1].meddefflexqual[yyy].sequence=request_main->ingredients[x].
        sequence))
         SET y = yyy
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF ((request_main->ingredients[x].action_flag=3))
     IF ((request->meddefqual[1].meddefflexqual[y].db_rec_status=1))
      SET request->meddefqual[1].meddefflexqual[y].db_rec_status = 2
     ENDIF
    ENDIF
    IF ((request_main->ingredients[x].action_flag=1))
     SET request->meddefqual[1].meddefflexqual[y].db_rec_status = 0
     FOR (q = 1 TO size(request->meddefqual[1].meddefflexqual[y].medflexobjidxqual,5))
       IF ((request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].flex_object_type_cd=
       oedef_cd))
        SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].db_rec_status = 1
        IF ((request_main->ingredients[x].strength_ind=1))
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         strength = request_main->ingredients[x].dose
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         strength_unit_cd = request_main->ingredients[x].dose_unit_code_value
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         volume = 0
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         volume_unit_cd = 0
        ELSEIF ((request_main->ingredients[x].volume_ind=1))
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         strength = 0
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         strength_unit_cd = 0
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         volume = request_main->ingredients[x].dose
         SET request->meddefqual[1].meddefflexqual[y].medflexobjidxqual[q].medoedefaultsqual[1].
         volume_unit_cd = request_main->ingredients[x].dose_unit_code_value
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF ((request_main->ingredients[x].mis_seq=0))
     SET z = size(request->meddefqual[1].meddefflexqual,5)
     SET stat = alterlist(request->meddefqual[1].meddefflexqual,(z+ 1))
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].sequence = 99
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].med_def_flex_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_entity_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_entity = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].flex_type_cd = syspkg_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].flex_sort_flag = 500
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pharmacy_type_cd = inpatient_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].parent_med_def_flex_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].package_type_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].updt_cnt = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].active_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].active_status_cd = active_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].item_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].package_type_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].description = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].uom_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].base_uom_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].qty = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].base_package_type_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].active_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].pack[1].updt_cnt = 0
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medidentifierqual,0)
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual,2)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].med_def_flex_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].med_flex_object_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].parent_entity_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].sequence = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].parent_entity =
     "MED_DISPENSE"
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].flex_object_type_cd =
     dispense_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].value = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].value_unit = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].active_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].updt_cnt = 0
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
      meddispensequal,1)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     pharmacy_type_cd = inpatient_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     pat_orderable_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     med_dispense_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     item_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     package_type_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     package_type_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     parent_entity_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     parent_entity = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     flex_type_cd = syspkg_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     flex_sort_flag = 500
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     legal_status_cd = legend_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     formulary_status_cd = formulary_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     oe_format_flag = request_main->default_flag
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     med_filter_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     continuous_filter_ind = request_main->continuous_ind
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     intermittent_filter_ind = request_main->intermittent_ind
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_filter_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     max_par_supply = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     infinite_div_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     divisible_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     used_as_base_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     always_dispense_from_flag = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     dispense_qty = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     dispense_factor = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     label_ratio = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     reusable_ind = 0
     IF ((request_main->ingredients[x].strength_ind=1))
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
      strength = request_main->ingredients[x].dose
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
      strength_unit_cd = request_main->ingredients[x].dose_unit_code_value
     ELSEIF ((request_main->ingredients[x].volume_ind=1))
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
      volume = request_main->ingredients[x].dose
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
      volume_unit_cd = request_main->ingredients[x].dose_unit_code_value
     ENDIF
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     base_issue_factor = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     updt_cnt = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     pkg_qty_per_pkg = - (1)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     pkg_disp_more_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     override_clsfctn_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     rx_station_notes = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     rx_station_notes_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     witness_dispense_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     witness_return_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     witness_adhoc_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     witness_override_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     witness_waste_ind = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     workflow_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_balance_method_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_chloride_pct = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_default_ingred_item_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_fill_method_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_include_ions_flag = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_overfill_amt = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_overfill_unit_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_preferred_cation_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_product_type_flag = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     tpn_scale_flag = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].meddispensequal[1].
     lot_tracking_ind = 0
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
      medoedefaultsqual,0)
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[1].
      medproductqual,0)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].med_def_flex_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].med_flex_object_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].parent_entity_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].sequence = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].parent_entity =
     "MED_OE_DEFAULTS"
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].flex_object_type_cd =
     oedef_cd
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].value = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].value_unit = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].active_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].updt_cnt = 0
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
      meddispensequal,0)
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
      medoedefaultsqual,1)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     freetext_dose = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     diluent_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     diluent_volume = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment1_text = comment1_text
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment2_text = comment2_text
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     default_par_doses = - (1)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     max_par_supply = - (1)
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     db_rec_status = 3
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     med_oe_defaults_id = 0
     IF ((request_main->ingredients[x].strength_ind=1))
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
      strength = request_main->ingredients[x].dose
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
      strength_unit_cd = request_main->ingredients[x].dose_unit_code_value
     ELSEIF ((request_main->ingredients[x].volume_ind=1))
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
      volume = request_main->ingredients[x].dose
      SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
      volume_unit_cd = request_main->ingredients[x].dose_unit_code_value
     ENDIF
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     route_cd = request_main->route_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     frequency_cd = request_main->frequency_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     prn_ind = request_main->prn_ind
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     prn_reason_cd = request_main->prn_reason_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     infuse_over = request_main->infuse_over
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     infuse_over_cd = request_main->infuse_over_units_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     duration = request_main->duration
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     duration_unit_cd = request_main->duration_units_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     stop_type_cd = request_main->stop_type_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     dispense_category_cd = request_main->dispense_category_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment1_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment1_type = comment1_type
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment2_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     comment2_type = comment2_type
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     price_sched_id = request_main->price_schedule_id
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     active_ind = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     updt_cnt = 4
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     rx_qty = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     daw_cd = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     sig_codes = ""
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     nbr_labels = 1
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     ord_as_synonym_id = 0
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].rate
      = request_main->rate
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     rate_cd = request_main->rate_units_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     normalized_rate = request_main->normal_rate
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     normalized_rate_cd = request_main->normal_rate_units_code_value
     SET request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].medoedefaultsqual[1].
     freetext_rate = request_main->freetext_rate
     SET stat = alterlist(request->meddefqual[1].meddefflexqual[(z+ 1)].medflexobjidxqual[2].
      medproductqual,0)
    ENDIF
  ENDFOR
  SET add_seq = 0
  FOR (y = 1 TO size(request->meddefqual[1].meddefflexqual,5))
    IF ((request->meddefqual[1].meddefflexqual[y].flex_type_cd=syspkg_cd)
     AND (request->meddefqual[1].meddefflexqual[y].sequence > 0))
     IF ((request->meddefqual[1].meddefflexqual[y].db_rec_status != 2))
      SET add_seq = (add_seq+ 1)
      SET request->meddefqual[1].meddefflexqual[y].sequence = add_seq
     ENDIF
    ENDIF
  ENDFOR
  EXECUTE rxa_upd_medproduct
 ENDIF
#exit_script
 SET modify = noskipsrvmsg
 FREE SET reply
 RECORD reply(
   1 item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request_main->action_flag=2))
  SET reply->item_id = request_main->item_id
  FOR (x = 1 TO size(request_main->ingredients,5))
    IF (request_main->ingredients[x].diluent_ind)
     DELETE  FROM br_name_value b
      PLAN (b
       WHERE b.br_nv_key1="RX_IVSET_DILUENT"
        AND b.br_name=cnvtstring(reply->item_id))
      WITH nocounter
     ;end delete
     INSERT  FROM br_name_value b
      SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "RX_IVSET_DILUENT", b.br_name
        = cnvtstring(reply->item_id),
       b.br_value = cnvtstring(request_main->ingredients[x].id), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ELSE
  SELECT INTO "nl:"
   FROM med_identifier m
   PLAN (m
    WHERE (m.value=request_main->description)
     AND m.med_identifier_type_cd=desc_cd)
   DETAIL
    reply->item_id = m.item_id
   WITH nocounter
  ;end select
  FOR (x = 1 TO size(request_main->ingredients,5))
    IF (request_main->ingredients[x].diluent_ind)
     INSERT  FROM br_name_value b
      SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "RX_IVSET_DILUENT", b.br_name
        = cnvtstring(reply->item_id),
       b.br_value = cnvtstring(request_main->ingredients[x].id), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
