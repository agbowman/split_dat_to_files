CREATE PROGRAM ctp_pha_formulary_cls:dba
 CREATE CLASS rxa_product_startup FROM ctp_ip_script_ccl
 init
 RECORD _::reply(
   1 oeformat_id = f8
   1 consrc_cd = f8
   1 srcvoc_cd = f8
   1 genname_cd = f8
   1 genform_cd = f8
   1 brand_cd = f8
   1 generic_cd = f8
   1 yes_cd = f8
   1 active_cd = f8
   1 rxformdigits = i4
   1 frmstatus_cd = f8
   1 rxlabelform = i4
   1 rxlabelname = vc
   1 rxlabelnamedigits = i4
   1 rxlabelstrength = i4
   1 rxnamemnemonic = vc
   1 rxseparator = vc
   1 builddupes = i4
   1 idformat = i4
   1 adddeactivated = i4
   1 usedesc = i4
   1 usebillcode = i4
   1 usemnemonic = i4
   1 cdmoptionind = i4
   1 sharendc = i4
   1 refdatabase = i4
   1 rxgenname_cd = f8
   1 rxprimarymnem_cd = f8
   1 rxbrandname_cd = f8
   1 rxmnemonic_cd = f8
   1 rxcatalog_cd = f8
   1 rxactivitytype_cd = f8
   1 rxmeddefitem_cd = f8
   1 rxmanfitem_cd = f8
   1 rxmanfitem_cd = f8
   1 rxactivestatus_cd = f8
   1 rxinactivestatus_cd = f8
   1 newmodel = i2
   1 usephaenhprodsearch = i2
   1 inpatientinventorytrackinglevel = i2
   1 retailinventorytrackinglevel = i2
   1 procuregroup = i2
   1 donotupddcdays = i2
   1 elapsed_time = f8
   1 qualfac[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualpharm[*]
     2 display = c40
     2 code_value = f8
     2 description = c60
     2 active_ind = i2
   1 qualamb[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualpha[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualinv[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualnur[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualflextype[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 collation_seq = i4
     2 active_ind = i2
   1 qualobjecttype[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 active_ind = i2
   1 qualdaw[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 collation_seq = i4
     2 active_ind = i2
   1 qualalert[*]
     2 cdf_meaning = c12
     2 display = c40
     2 description = c60
     2 code_value = f8
     2 collation_seq = i4
     2 active_ind = i2
   1 rx_station_ind = i2
   1 rddsrequireunique = i2
   1 rddsuniqueformat = vc
   1 procuresyncident = i2
   1 retailcomppricelevel = i2
   1 retailcompinvlevel = i2
   1 idformatstr = vc
   1 writelevelaccessind = i2
   1 mfnsendchange = i2
   1 mfnsendone = i2
   1 shareproducts = i2
   1 useingredvolumepref = i2
   1 rxaduplicatendc = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rxa_product_startup"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS him_get_prsnl_orgs FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 userid = vc
   1 prsnl_id = f8
 )
 RECORD _::reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 confid_level_cd = f8
     2 confid_level_disp = vc
     2 confid_level_mean = vc
     2 alias_pool_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("him_get_prsnl_orgs"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rx_get_facilities_by_org FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 inc_outpt_fac_ind = i2
   1 inc_inact_fac_ind = i2
   1 organization_list[*]
     2 organization_id = f8
 )
 RECORD _::reply(
   1 facility_list[*]
     2 organization_id = f8
     2 facility_cd = f8
     2 cdf_meaning = c12
     2 description = vc
     2 child_ind = i2
     2 active_ind = i2
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rx_get_facilities_by_org"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rx_get_loc_by_facility FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 qual[*]
     2 facility_cd = f8
     2 qual_cdf[*]
       3 cdf_meaning = c12
   1 inc_inact_loc_ind = i2
 )
 RECORD _::reply(
   1 facility[*]
     2 facility_cd = f8
     2 building[*]
       3 building_cd = f8
       3 display = vc
       3 description = vc
       3 lg_active_ind = i2
       3 location[*]
         4 location_cd = f8
         4 display = vc
         4 description = vc
         4 cdf_meaning = c12
         4 active_ind = i2
         4 lg_active_ind = i2
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rx_get_loc_by_facility"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_generic FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 code_set = i4
   1 code_value = f8
   1 meaning = c12
   1 batch_mode = i2
   1 index_code_value = f8
 )
 RECORD _::reply(
   1 code_set = i4
   1 qual[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 definition = vc
     2 meaning = c12
     2 display_key = vc
     2 cki = vc
     2 activeind = i2
     2 coll_seq = i4
     2 updt_cnt = i4
   1 index_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_generic"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_dispcat FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 dispense_category_cd = f8
 )
 RECORD _::reply(
   1 data_cnt = i4
   1 data[*]
     2 compcnt = i4
     2 dispense_category_cd = f8
     2 disp_fill_qty_ind = i2
     2 interim_disp_qty_ind = i2
     2 round_disp_qty_ind = i2
     2 disp_from_phlocn_ind = i2
     2 charge_pt_sch_ind = i2
     2 charge_pt_prn_ind = i2
     2 disp_qty_ratio_ind = i2
     2 dispcat_updt_cnt = i4
     2 last_resort_fill_hrs = i4
     2 last_resort_fill_time = i4
     2 order_type_flag = i2
     2 price_sched_id = f8
     2 label_format_cd = f8
     2 preview_format_cd = f8
     2 report_format_cd = f8
     2 fill_list_format_cd = f8
     2 interim_days_supply_ind = i2
     2 interim_days_supply_amt = i4
     2 interim_prod_pkg_ind = i2
     2 interim_days_sup_pkg_ind = i2
     2 interim_lbl_printing_flag = i2
     2 disp_fill_days_supply_ind = i2
     2 disp_fill_days_supply_amt = i4
     2 disp_fill_prod_pkg_ind = i2
     2 disp_fill_days_sup_pkg_ind = i2
     2 disp_fill_lbl_printing_flag = i2
     2 unsupported_doses_ind = i2
     2 unsupported_doses_amt = i4
     2 unsupported_days_supply_ind = i2
     2 unsupported_days_supply_amt = i4
     2 unsupported_prod_pkg_ind = i2
     2 unsupported_days_sup_pkg_ind = i2
     2 unsupported_lbl_printing_flag = i2
     2 refill_notify_format_cd = f8
     2 printer_data[*]
       3 location_cd = f8
       3 device_cd = f8
       3 leaflet_device_cd = f8
       3 validation_device_cd = f8
       3 trans_notify_device_cd = f8
       3 refill_notify_device_cd = f8
       3 denial_report_device_cd = f8
     2 leaflet_format_cd = f8
     2 validation_format_cd = f8
     2 pharm_type_cd = f8
     2 replace_every = i4
     2 lbl_per_dose = i2
     2 tpn_ind = i2
     2 code_value = f8
     2 code_set = i4
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 codeval_updt_cnt = i4
     2 temp_stock_ind = i2
     2 charge_on_sched_admin_ind = i2
     2 auto_credit_ind = i2
     2 skip_dispense_flag = i2
     2 patient_denial_format_cd = f8
     2 workflow_cd = f8
     2 individual_dose_dispensing_ind = i2
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_dispcat"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_dispcat_form_r FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 dispense_category_cd = f8
   1 form_cd = f8
 )
 RECORD _::reply(
   1 data_cnt = i4
   1 data[10]
     2 dispense_category_cd = f8
     2 form_cd = f8
     2 usage_flag = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_dispcat_form_r"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_form FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 active_ind = i2
   1 form_cd = f8
   1 long_description = c50
   1 field_name = c32
 )
 RECORD _::reply(
   1 data_cnt = i4
   1 data[*]
     2 form_cd = f8
     2 short_description = vc
     2 long_description = vc
     2 divisible = i4
     2 active_ind = i2
     2 codeval_updt_cnt = i4
     2 codevalext_updt_cnt = i4
     2 field_name = vc
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_form"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_frq FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 active_ind = i2
   1 frequency_cd = f8
   1 activity_type_cd = f8
 )
 RECORD _::reply(
   1 data_cnt = i4
   1 data[*]
     2 frequency_cd = f8
     2 types[*]
       3 activity_type_cd = f8
     2 freq_desc = vc
     2 freq_display = c40
     2 freq_meaning = c12
     2 active_ind = i2
     2 codeval_updt_cnt = i4
     2 codealias_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_frq"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rx_get_price_sched FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 pharm_type_cd = f8
   1 fac_list[*]
     2 facility_cd = f8
 )
 RECORD _::reply(
   1 qual[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 price_sched_short_desc = vc
     2 formula_type_flg = i4
     2 markup_level_flg = i4
     2 apply_svc_fee_ind = i2
     2 cost_basis_cd = f8
     2 warning_type_cd = f8
     2 pharm_type_cd = f8
     2 active_ind = i2
     2 apply_markup_to_flag = i2
   1 security_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rx_get_price_sched"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_route FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 route_cd = f8
 )
 RECORD _::reply(
   1 data_cnt = i4
   1 data[*]
     2 route_cd = f8
     2 short_description = vc
     2 long_description = vc
     2 order_category = i4
     2 active_ind = i2
     2 updt_cnt = i4
     2 codeval_updt_cnt = i4
     2 codevalext_updt_cnt = i4
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_route"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_route_type FROM pha_get_route
 init
 RECORD _::routetype(
   1 list[*]
     2 item = i4
 )
 SUBROUTINE (_::parseroutetype(list=vc) =i2 WITH protect)
   DECLARE medication = i4 WITH protect, constant(0)
   DECLARE continuous = i4 WITH protect, constant(1)
   DECLARE intermittent = i4 WITH protect, constant(2)
   DECLARE notfound = vc WITH protect, constant("%NOTFOUND%")
   DECLARE delim = vc WITH protect, constant("|")
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE item = vc WITH protect, noconstant(" ")
   SET item = piece(list,delim,idx,notfound)
   WHILE (item != notfound)
     SET stat = alterlist(_::routetype->list,idx)
     SET _::routetype->list[idx].item = parser(item)
     SET idx += 1
     SET item = piece(list,delim,idx,notfound)
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_pharmunit FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 pharm_ind = i2
   1 code_value = f8
   1 meaning = c12
 )
 RECORD _::reply(
   1 code_set = i4
   1 qual[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 definition = vc
     2 meaning = c12
     2 display_key = vc
     2 cki = vc
     2 activeind = i2
     2 updt_cnt = i4
     2 ext_updt_cnt = i4
     2 pharm_unit = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_get_pharmunit"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_get_pharmunit_type FROM pha_get_pharmunit
 init
 RECORD _::unittype(
   1 list[*]
     2 item = i4
 )
 SUBROUTINE (_::parseunittype(list=vc) =i2 WITH protect)
   DECLARE strength = i4 WITH protect, constant(0)
   DECLARE volume = i4 WITH protect, constant(1)
   DECLARE quantity = i4 WITH protect, constant(2)
   DECLARE duration = i4 WITH protect, constant(3)
   DECLARE rate = i4 WITH protect, constant(4)
   DECLARE normalized_rate = i4 WITH protect, constant(5)
   DECLARE documentation_rate = i4 WITH protect, constant(6)
   DECLARE notfound = vc WITH protect, constant("%NOTFOUND%")
   DECLARE delim = vc WITH protect, constant("|")
   DECLARE idx = i4 WITH protect, noconstant(1)
   DECLARE item = vc WITH protect, noconstant(" ")
   SET item = piece(list,delim,idx,notfound)
   WHILE (item != notfound)
     SET stat = alterlist(_::unittype->list,idx)
     SET _::unittype->list[idx].item = parser(item)
     SET idx += 1
     SET item = piece(list,delim,idx,notfound)
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rxa_add_medproduct FROM ctp_ip_script_ccl
 init
 RECORD _::request(
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
         4 ahfs_code_new = vc
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
           5 waste_charge_ind = i2
           5 cms_waste_billing_unit_amt = f8
           5 cms_waste_billing_unit_uom_cd = f8
           5 medcopaytierhxqual[*]
             6 db_rec_status = i2
             6 med_copay_tier_hx_id = f8
             6 item_id = f8
             6 copay_tier_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 updt_cnt = i4
             6 updt_id = f8
             6 copay_tier_tz = i4
           5 mail_order_prod_cd = f8
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
           5 med_dispense_category_cd = f8
           5 int_dispense_category_cd = f8
           5 cont_dispense_category_cd = f8
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
           5 cost_factor_nbr = f8
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
 RECORD _::reply(
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
           5 medcopaytierhxqual[*]
             6 med_copay_tier_hx_id = f8
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
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rxa_add_medproduct"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(true)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rxa_get_medproduct FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 pharm_type_cd = f8
   1 qual[*]
     2 item_id = f8
   1 do_not_load_cost_ind = i2
 )
 RECORD _::reply(
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
           5 waste_charge_ind = i2
           5 cms_waste_billing_unit_amt = f8
           5 cms_waste_billing_unit_uom_cd = f8
           5 medcopaytierhxqual[*]
             6 med_copay_tier_hx_id = f8
             6 item_id = f8
             6 copay_tier_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 updt_cnt = i4
             6 updt_id = f8
             6 updt_name = vc
             6 updt_dt_tm = dq8
             6 copay_tier_tz = i4
           5 mail_order_prod_cd = f8
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
           5 ord_as_syn_active_ind = i2
           5 ord_as_mnemonic = vc
           5 rate = f8
           5 rate_cd = f8
           5 normalized_rate = f8
           5 normalized_rate_cd = f8
           5 freetext_rate = vc
           5 grace_period_days = i4
           5 med_dispense_category_cd = f8
           5 int_dispense_category_cd = f8
           5 cont_dispense_category_cd = f8
         4 medproductqual[*]
           5 med_product_id = f8
           5 manf_item_id = f8
           5 item_master_id = f8
           5 inner_pkg_type_id = f8
           5 outer_pkg_type_id = f8
           5 bio_equiv_ind = i2
           5 brand_ind = i2
           5 cost_factor_nbr = f8
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
     2 tempingredqual[*]
       3 ndc = vc
       3 desc = vc
     2 premix_ind = i2
     2 volunitusedincompvolcalc = i2
     2 prodbaseuomcd = f8
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
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rxa_get_medproduct"))
 DECLARE PRIVATE::success_status = vc WITH constant("S|Z|F")
 END; class scope:init
 WITH copy = 1
 CREATE CLASS rxa_upd_medproduct FROM ctp_ip_script_ccl
 init
 RECORD _::request(
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
         4 ahfs_code_new = vc
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
           5 divisible_ind = i2
           5 infinite_div_ind = i2
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
           5 waste_charge_ind = i2
           5 cms_waste_billing_unit_amt = f8
           5 cms_waste_billing_unit_uom_cd = f8
           5 medcopaytierhxqual[*]
             6 db_rec_status = i2
             6 med_copay_tier_hx_id = f8
             6 item_id = f8
             6 copay_tier_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 updt_cnt = i4
             6 updt_id = f8
             6 copay_tier_tz = i4
           5 mail_order_prod_cd = f8
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
           5 rate = f8
           5 rate_cd = f8
           5 normalized_rate = f8
           5 normalized_rate_cd = f8
           5 freetext_rate = vc
           5 grace_period_days = i4
           5 med_dispense_category_cd = f8
           5 int_dispense_category_cd = f8
           5 cont_dispense_category_cd = f8
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
     2 lot_tracking_ind = i2
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
 ) WITH protect
 RECORD _::reply(
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
           5 medcopaytierhxqual[*]
             6 med_copay_tier_hx_id = f8
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
   1 ifailure_type = i2
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
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("rxa_upd_medproduct"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(true)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_pha_add_billitem FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 items[*]
     2 item_id = f8
     2 manf_cd = f8
     2 orc_cd = f8
     2 manf_item_id = f8
     2 med_def_flex_id = f8
 ) WITH protect
 RECORD _::reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("ctp_pha_add_billitem"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(true)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_formulary_query FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 pharmacy_type[*]
     2 code_value = f8
   1 item[*]
     2 id = f8
   1 med_type[*]
     2 flag = i2
   1 facility_limit = i2
   1 facility_sort = i2
   1 facility[*]
     2 code_value = f8
   1 pharmacy_limit = i2
   1 pharmacy_sort = i2
   1 pharmacy[*]
     2 code_value = f8
   1 ident_type[*]
     2 code_value = f8
   1 ident_search_str = vc
   1 ident_search_type = f8
   1 item_active_ind = i2
   1 ndc_active_ind = i2
   1 ndc_primary_ind = i2
   1 facil_flex_limit = i2
   1 qry_ingredients = i2
   1 qry_oe_defaults = i2
   1 qry_dispense = i2
   1 qry_facilities = i2
   1 qry_pharmacies = i2
   1 qry_medproducts = i2
   1 qry_order_catalog = i2
   1 qry_thera_class = i2
   1 qry_immunization = i2
   1 qry_drc = i2
   1 qry_identifiers = i2
   1 qry_order_alerts = i2
   1 qry_flex_by_facil = i2
   1 qry_flex_by_ndc = i2
   1 qry_linking = i2
   1 qry_misc_details = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 pharmacy_type_cd = f8
     2 item_id = f8
     2 med_type_flag = i2
     2 label_desc = vc
     2 sys_med_def_flex_id = f8
     2 sysp_med_def_flex_id = f8
     2 active_ind = i2
     2 ref_dose = vc
     2 legal_status_cd = f8
     2 form_cd = f8
     2 md_updt_id = f8
     2 md_updt_dttm = dq8
     2 mdf_updt_id = f8
     2 mdf_updt_dttm = dq8
     2 mod_med_flex_object_id = f8
     2 daw_cd = f8
     2 rx_qty = f8
     2 oe_str = f8
     2 oe_str_unit_cd = f8
     2 oe_vol = f8
     2 oe_vol_unit_cd = f8
     2 freetext_dose = vc
     2 route_cd = f8
     2 frequency_cd = f8
     2 infuse_over = f8
     2 infuse_over_unit_cd = f8
     2 rate = f8
     2 rate_unit_cd = f8
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 freetext_rate = vc
     2 duration = f8
     2 duration_unit_cd = f8
     2 stop_type_cd = f8
     2 prn = i2
     2 prn_reason_cd = f8
     2 order_as_synonym_id = f8
     2 order_as_synonym = vc
     2 sig = vc
     2 notes1_id = f8
     2 notes1 = vc
     2 notes1_comment_type = i4
     2 notes2_id = f8
     2 notes2 = vc
     2 notes2_comment_type = i4
     2 def_format = i4
     2 medication = i2
     2 continuous = i2
     2 tpn = i2
     2 intermittent = i2
     2 mod_updt_id = f8
     2 mod_updt_dttm = dq8
     2 mdisp_med_flex_object_id = f8
     2 str = f8
     2 str_unit_cd = f8
     2 vol = f8
     2 vol_unit_cd = f8
     2 disp_qty = f8
     2 disp_qty_unit_cd = f8
     2 disp_category_cd = f8
     2 disp_factor = f8
     2 used_in_tot_volume = i4
     2 workflow_sequence_cd = f8
     2 divisible = i2
     2 divisible_factor = f8
     2 infinite_divisible = i2
     2 label_ratio = i4
     2 per_pkg = f8
     2 allow_pkg_broken = i2
     2 formulary_status_cd = f8
     2 price_schedule_id = f8
     2 price_schedule = vc
     2 billing_factor = f8
     2 billing_factor_unit_cd = f8
     2 default_par_doses = i4
     2 max_par_supply = i4
     2 poc_charge_setting = i2
     2 cms_billing_unit = f8
     2 dispense_from = i2
     2 reusable = i2
     2 track_lot_numbers = i2
     2 disable_apa_aps = i2
     2 skip_dispense = i2
     2 waste_charging = i2
     2 all_facil_ind = i2
     2 mdisp_updt_id = f8
     2 mdisp_updt_dttm = dq8
     2 fac[*]
       3 med_flex_object_id = f8
       3 facility_cd = f8
       3 updt_id = f8
       3 updt_dttm = dq8
     2 pha[*]
       3 pharmacy_cd = f8
       3 updt_id = f8
       3 updt_dttm = dq8
     2 fac_flex[*]
       3 med_def_flex_id = f8
       3 med_flex_object_id = f8
       3 facility_cd = f8
       3 formulary_status_cd = f8
       3 track_lot_numbers = i2
       3 disable_apa_aps = i2
       3 skip_dispense = i2
       3 waste_charging = i2
       3 updt_id = f8
       3 updt_dttm = dq8
     2 ndc[*]
       3 med_flex_object_id = f8
       3 med_product_id = f8
       3 manf_item_id = f8
       3 ndc_code = vc
       3 active_ind = i2
       3 sequence = i4
       3 manufacturer_cd = f8
       3 formulary_status_cd = f8
       3 base_pkg_unit_cd = f8
       3 pkg_size = f8
       3 pkg_unit_cd = f8
       3 outer_pkg_size = f8
       3 outer_pkg_unit_cd = f8
       3 unit_dose_ind = i2
       3 bio_ind = i2
       3 brand_ind = i2
       3 cost_factor = f8
       3 inv_factor = f8
       3 multum_ndc_ind = i2
       3 mfoi_updt_id = f8
       3 mfoi_updt_dttm = dq8
       3 mp_updt_id = f8
       3 mp_updt_dttm = dq8
       3 mfi_updt_id = f8
       3 mfi_updt_dttm = dq8
       3 ptb_updt_id = f8
       3 ptb_updt_dttm = dq8
       3 pti_updt_id = f8
       3 pti_updt_dttm = dq8
       3 pto_updt_id = f8
       3 pto_updt_dttm = dq8
       3 prod_desc[*]
         4 type_cd = f8
         4 value = vc
         4 updt_id = f8
         4 updt_dttm = dq8
       3 ident[*]
         4 ident_type_cd = f8
         4 value = vc
         4 active_ind = i2
         4 primary_ind = i2
         4 updt_id = f8
         4 updt_dttm = dq8
       3 flex[*]
         4 med_def_flex_id = f8
         4 med_flex_object_id = f8
         4 type_cd = f8
         4 location_cd = f8
         4 primary_ind = i2
         4 active_ind = i2
         4 updt_id = f8
         4 updt_dttm = dq8
       3 cost[*]
         4 type_cd = f8
         4 value = f8
         4 updt_id = f8
         4 updt_dttm = dq8
     2 suppress_multum_ind = i2
     2 generic_formulation_code = vc
     2 generic_formulation = vc
     2 drug_formulation_code = vc
     2 drug_formulation = vc
     2 therapeutic_class = vc
     2 therapeutic_class_display = vc
     2 dc_inter_days = i4
     2 dc_display_days = i4
     2 cki_numeric = i2
     2 ord_alerts[*]
       3 med_flex_object_id = f8
       3 order_alert_cd = f8
       3 updt_id = f8
       3 updt_dttm = dq8
     2 ident[*]
       3 ident_type_cd = f8
       3 value = vc
       3 active_ind = i2
       3 primary_ind = i2
       3 updt_id = f8
       3 updt_dttm = dq8
     2 ingred[*]
       3 mfoi_med_flex_object_id = f8
       3 mod_med_flex_object_id = f8
       3 sequence = i4
       3 item_id = f8
       3 label_desc = vc
       3 catalog_cd = f8
       3 rx_mask = i4
       3 cki = vc
       3 str = f8
       3 str_unit_cd = f8
       3 vol = f8
       3 vol_unit_cd = f8
       3 freetext_dose = vc
       3 normalized_rate_ind = i2
       3 mis_updt_id = f8
       3 mis_updt_dttm = dq8
       3 mod_updt_id = f8
       3 mod_updt_dttm = dq8
     2 linking[*]
       3 synonym_id = f8
       3 synonym = vc
       3 synonym_type_cd = f8
       3 active_ind = i2
       3 updt_id = f8
       3 updt_dttm = dq8
     2 catalog_cd = f8
     2 system_number = vc
     2 inv_base_pkg_unit_cd = f8
     2 premix_ind = i2
     2 creation_user = vc
     2 creation_dt_tm = dq8
     2 primary_mnemonic = vc
     2 oc_desc = vc
     2 oc_cki = vc
     2 titrate_ind = i2
     2 witness_flag = i2
     2 immunization_ind = i2
     2 drc_grouper = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("ctp_pha_formulary_qry"))
 END; class scope:init
 WITH copy = 1
 SET last_mod = "002 02/20/20 RS2823 Add INDIVIDUAL_DOSE_DISPENSING_IND"
END GO
