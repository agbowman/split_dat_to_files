CREATE PROGRAM bed_ens_pharm_matched_items:dba
 SET modify = skipsrvmsg
 RECORD request_main(
   1 matches[*]
     2 legacy_ndc = vc
     2 legacy_description = vc
     2 legacy_facility_code_value = f8
     2 mill_ndc = vc
     2 data_ind = i2
 )
 SET stat = alterlist(request_main->matches,size(request->matches,5))
 FOR (x = 1 TO size(request->matches,5))
   SET request_main->matches[x].legacy_ndc = request->matches[x].legacy_ndc
   SET request_main->matches[x].legacy_description = request->matches[x].legacy_description
   SET request_main->matches[x].legacy_facility_code_value = request->matches[x].
   legacy_facility_code_value
   SET request_main->matches[x].mill_ndc = request->matches[x].mill_ndc
   SET request_main->matches[x].data_ind = request->matches[x].data_ind
 ENDFOR
 FREE SET mltm_request
 RECORD mltm_request(
   1 db_flag = i2
   1 ndc_5_4_2_format = vc
 )
 FREE SET mltm_reply
 RECORD mltm_reply(
   1 data_cnt = i4
   1 elapsed_time = f8
   1 data[*]
     2 measure_code = c1
     2 generic_formulation_code = i4
     2 route_of_administration_code = c30
     2 form_code = c30
     2 master_form_code = c5
     2 dea_class_code = c2
     2 generic_cross_reference_code = i4
     2 tclass[*]
       3 therapeutic_class_code = f8
       3 therapeutic_class_string = vc
     2 manufacturer_name = vc
     2 manufacturer_source_code = i4
     2 ndc_standard_10_format = c10
     2 ndc_5_4_2_format = vc
     2 previous_ndc_5_4_2_format = vc
     2 product_name = vc
     2 additional_description = vc
     2 strength = vc
     2 package_size = f8
     2 unit_dose_flag = c1
     2 package_quantity_code = c5
     2 standard_package_size = f8
     2 standard_unit_of_measure = c30
     2 solid_liquid_indicator = c2
     2 awp_current_price = f8
     2 awp_current_unit_price = f8
     2 awp_current_price_effective_dt = i4
     2 dp_current_price = f8
     2 dp_current_unit_price = f8
     2 dp_current_price_effective_date = i4
     2 ful_current_price = f8
     2 ful_current_unit_price = f8
     2 ful_current_price_effective_dt = i4
     2 srp_current_price = f8
     2 srp_current_unit_price = f8
     2 srp_current_price_effective_dt = i4
     2 orange_book_code = c2
     2 deactivate_indicator = c1
     2 obsolete_dt_tm = dq8
     2 metric_size = c20
     2 generic_name = vc
     2 gfc_nomen_id = f8
     2 gcr_nomen_id = f8
     2 gfc_cki = vc
     2 gcr_cki = vc
     2 mmdc_cki = vc
     2 otc_status = c1
     2 j_code = c10
     2 generic_name_cki = vc
     2 brand_name_cki = vc
     2 synonym_cki = vc
     2 rx_mnemonic_synonym = vc
     2 gb_ind = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET nomen_request
 RECORD nomen_request(
   1 nomenclature_id = f8
 )
 FREE SET nomen_reply
 RECORD nomen_reply(
   1 nomen_qual = i4
   1 source_string = vc
   1 source_identifier = vc
   1 principle_type_cd = f8
   1 principle_type_disp = c40
   1 principle_type_mean = c12
   1 active_ind = i2
   1 active_status_dt_tm = dq8
   1 active_status_cd = f8
   1 active_status_disp = c40
   1 active_status_mean = c12
   1 contributor_system_cd = f8
   1 contributor_system_disp = c40
   1 contributor_system_mean = c12
   1 vocab_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET manuf_request
 RECORD manuf_request(
   1 manuf_name = c35
 )
 FREE SET manuf_reply
 RECORD manuf_reply(
   1 manufacturer_cd = f8
   1 new_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET multum_contr_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="MULTUM"
   AND cv.active_ind=1
  DETAIL
   multum_contr_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_act_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_cat_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_cat_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET primary_mnem_type_cd = 0.0
 SET rx_mnem_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning IN ("PRIMARY", "RXMNEMONIC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="PRIMARY")
    primary_mnem_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RXMNEMONIC")
    rx_mnem_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET system_flex_type_cd = 0.0
 SET system_pkg_flex_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSTEM", "SYSPKGTYP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_flex_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSPKGTYP")
    system_pkg_flex_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET inpt_pharm_type_cd = 0.0
 SET inpt_pharm_type_disp = fillstring(40," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpt_pharm_type_cd = cv.code_value, inpt_pharm_type_disp = cv.display
  WITH nocounter
 ;end select
 SET generic_name_type_cd = 0.0
 SET desc_short_type_cd = 0.0
 SET desc_type_cd = 0.0
 SET pyxis_type_cd = 0.0
 SET cdm_type_cd = 0.0
 SET brand_name_type_cd = 0.0
 SET ndc_type_cd = 0.0
 SET rx_unique_id_type_cd = 0.0
 SET rx_device1_type_cd = 0.0
 SET rx_misc5_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("GENERIC_NAME", "DESC_SHORT", "DESC", "PYXIS", "CDM",
  "BRAND_NAME", "NDC", "RX_UNIQUEID", "RX DEVICE1", "RX MISC5")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="GENERIC_NAME")
    generic_name_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC_SHORT")
    desc_short_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC")
    desc_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PYXIS")
    pyxis_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CDM")
    cdm_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BRAND_NAME")
    brand_name_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="NDC")
    ndc_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RX_UNIQUEID")
    rx_unique_id_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RX DEVICE1")
    rx_device1_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RX MISC5")
    rx_misc5_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET oedef_type_cd = 0.0
 SET medproduct_type_cd = 0.0
 SET dispense_type_cd = 0.0
 SET orderable_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4063
   AND cv.cdf_meaning IN ("OEDEF", "MEDPRODUCT", "DISPENSE", "ORDERABLE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="OEDEF")
    oedef_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="MEDPRODUCT")
    medproduct_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPENSE")
    dispense_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ORDERABLE")
    orderable_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET ea_unit_cd = 0.0
 DECLARE ea_unit_disp = vc
 SET ea_unit_disp = " "
 DECLARE ea_unit_cki = vc
 SET ea_unit_cki = " "
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=54
   AND cv.cdf_meaning="EA"
   AND cv.active_ind=1
  DETAIL
   ea_unit_cd = cv.code_value, ea_unit_disp = cv.display, ea_unit_cki = cv.cki
  WITH nocounter
 ;end select
 SET formulary_status_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4512
   AND cv.cdf_meaning="FORMULARY"
   AND cv.active_ind=1
  DETAIL
   formulary_status_cd = cv.code_value
  WITH nocounter
 ;end select
 SET cost1_cost_basis_cd = 0.0
 SET awp_cost_basis_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4050
   AND cv.cdf_meaning IN ("COST1", "AWP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="COST1")
    cost1_cost_basis_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="AWP")
    awp_cost_basis_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET primary_oe_format_id = 0
 SELECT DISTINCT INTO "NL:"
  oe.oe_format_id
  FROM order_entry_format oe
  WHERE oe.oe_format_name="Primary Pharmacy"
  ORDER BY oe.oe_format_id
  DETAIL
   primary_oe_format_id = oe.oe_format_id
  WITH nocounter
 ;end select
 DECLARE pack_desc = vc
 DECLARE manu_desc = vc
 SET desc_name_pref = " "
 SET desc_nbr_chars_dose_form_pref = 0
 SET desc_strength_pref = 0
 SET mnem_name_pref = " "
 SET mnem_nbr_chars_dose_form_pref = 0
 SET mnem_nbr_chars_name_pref = 0
 DECLARE unique_id_text = vc
 DECLARE unique_id_pref = vc
 SET unique_id_pref = " "
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name IN ("RXLBLSTR", "RXLBLFORM", "RXLBLNAME", "RXNAMEDIG", "RXFRMDIG",
  "RXNAMEMNE", "RDDSFORMAT")
   AND dp.person_id=0
  DETAIL
   IF (dp.pref_name="RXLBLSTR")
    desc_strength_pref = dp.pref_nbr
   ELSEIF (dp.pref_name="RXLBLFORM")
    desc_nbr_chars_dose_form_pref = dp.pref_nbr
   ELSEIF (dp.pref_name="RXLBLNAME")
    desc_name_pref = substring(1,1,dp.pref_str)
   ELSEIF (dp.pref_name="RXNAMEDIG")
    mnem_nbr_chars_name_pref = dp.pref_nbr
   ELSEIF (dp.pref_name="RXFRMDIG")
    mnem_nbr_chars_dose_form_pref = dp.pref_nbr
   ELSEIF (dp.pref_name="RXNAMEMNE")
    mnem_name_pref = substring(1,1,dp.pref_str)
   ELSEIF (dp.pref_name="RDDSFORMAT")
    unique_id_pref = dp.pref_str
   ENDIF
  WITH nocounter
 ;end select
 SET charge_tier_pref = 0
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET-INPATIENT"
   AND dp.pref_section="BILLING"
   AND dp.pref_name="CDM OPTION"
   AND dp.person_id=0
  DETAIL
   charge_tier_pref = dp.pref_nbr
  WITH nocounter
 ;end select
 SET total_saves = 0
 SET mcnt = 0
 SET mcnt = size(request_main->matches,5)
 FOR (m = 1 TO mcnt)
   DECLARE legacy_ubc_ident = vc
   DECLARE legacy_charge_nbr = vc
   SET legacy_ubc_ident = " "
   SET legacy_charge_nbr = " "
   SET legacy_acq_cost = 0.0
   SELECT INTO "NL:"
    FROM br_pharm_product_work b
    WHERE (b.facility_cd=request_main->matches[m].legacy_facility_code_value)
     AND (b.ndc=request_main->matches[m].legacy_ndc)
     AND (b.description=request_main->matches[m].legacy_description)
    DETAIL
     legacy_ubc_ident = b.ubc_ident, legacy_charge_nbr = b.charge_nbr, legacy_acq_cost = b
     .acquisition_cost
    WITH nocounter
   ;end select
   FREE SET internal
   RECORD internal(
     1 brand_code = i4
     1 source_id = i4
     1 inner_pack_desc_code = i4
     1 orange_book_id = i4
     1 route_code = i4
     1 form_code = i4
     1 str_code = i4
     1 ndc_code = c11
     1 mmdc_string = c6
     1 dnum = c6
   )
   FREE SET errors
   RECORD errors(
     1 err_cnt = i4
     1 err[*]
       2 err_code = i4
       2 err_msg = vc
   )
   SET stat = initrec(mltm_reply)
   SET mltm_request->ndc_5_4_2_format = concat(substring(1,5,request_main->matches[m].mill_ndc),"-",
    substring(6,4,request_main->matches[m].mill_ndc),"-",substring(10,2,request_main->matches[m].
     mill_ndc))
   EXECUTE pha_get_multum  WITH replace("REQUEST",mltm_request), replace("REPLY",mltm_reply)
   IF (trim(mltm_reply->data[1].standard_unit_of_measure)=" ")
    SET mltm_reply->data[1].standard_unit_of_measure = "EA"
   ENDIF
   SET mltm_dose_form_cd = 0.0
   SET mltm_dose_form_display = fillstring(40," ")
   SET mltm_dose_form_divisible = 0
   SELECT INTO "NL:"
    FROM code_value_alias cva,
     code_value cv,
     code_value_extension cve
    PLAN (cva
     WHERE cva.code_set=4002
      AND cva.contributor_source_cd=multum_contr_cd
      AND cva.alias=cnvtstring(internal->form_code))
     JOIN (cv
     WHERE cv.code_value=cva.code_value)
     JOIN (cve
     WHERE cve.code_value=cv.code_value
      AND cve.field_name="DIVISIBLE")
    DETAIL
     mltm_dose_form_cd = cva.code_value, mltm_dose_form_display = cv.display,
     mltm_dose_form_divisible = cnvtint(cve.field_value)
    WITH nocounter
   ;end select
   SET mltm_standard_unit_measure_cd = 0.0
   DECLARE mltm_standard_unit_measure_cki = vc
   SET mltm_standard_unit_measure_cki = " "
   DECLARE mltm_standard_unit_measure_disp = vc
   SET mltm_standard_unit_measure_disp = " "
   SELECT INTO "NL:"
    FROM code_value_alias cva,
     code_value cv
    PLAN (cva
     WHERE cva.code_set=54
      AND cva.contributor_source_cd=multum_contr_cd
      AND trim(cnvtupper(cva.alias))=trim(cnvtupper(mltm_reply->data[1].standard_unit_of_measure)))
     JOIN (cv
     WHERE cv.code_value=cva.code_value)
    DETAIL
     mltm_standard_unit_measure_cd = cv.code_value, mltm_standard_unit_measure_cki = cv.cki,
     mltm_standard_unit_measure_disp = cv.display
    WITH nocounter
   ;end select
   SET mltm_route_cd = 0.0
   SELECT INTO "NL:"
    FROM mltm_product_route m,
     code_value_alias cva
    PLAN (m
     WHERE (m.route_code=internal->route_code))
     JOIN (cva
     WHERE cva.code_set=4001
      AND cva.contributor_source_cd=multum_contr_cd
      AND cva.alias=cnvtstring(m.route_abbr))
    DETAIL
     mltm_route_cd = cva.code_value
    WITH nocounter
   ;end select
   SET mltm_legal_status_cd = 0.0
   SELECT INTO "NL:"
    FROM code_value_alias cva,
     code_value cv
    PLAN (cva
     WHERE cva.code_set=4200
      AND cva.contributor_source_cd=multum_contr_cd
      AND (cva.alias=mltm_reply->data[1].dea_class_code))
     JOIN (cv
     WHERE cv.code_value=cva.code_value)
    DETAIL
     mltm_legal_status_cd = cv.code_value
    WITH nocounter
   ;end select
   SET manuf_request->manuf_name = mltm_reply->data[1].manufacturer_name
   EXECUTE pha_bld_manuf  WITH replace("REQUEST",manuf_request), replace("REPLY",manuf_reply)
   SET mltm_ord_cki = 0
   SET mltm_ord_cki = cnvtint(trim(substring(10,1000,mltm_reply->data[1].gcr_cki)))
   DECLARE mltm_generic_name = vc
   SET mltm_generic_name = " "
   DECLARE mltm_brand_name = vc
   SET mltm_brand_name = " "
   DECLARE auto_desc = vc
   SET auto_desc = " "
   SET mltm_product_type = fillstring(6," ")
   SET mltm_conc = 0.0
   SET mltm_conc_unit_cd = 0.0
   SET mltm_strength = 0.0
   SET mltm_strength_unit_cd = 0.0
   DECLARE mltm_strength_unit_disp = vc
   SET mltm_strength_unit_disp = " "
   SET mltm_volume = 0.0
   SET mltm_volume_unit_cd = 0.0
   DECLARE mltm_volume_unit_cki = vc
   SET mltm_volume_unit_cki = " "
   DECLARE mltm_volume_unit_disp = vc
   SET mltm_volume_unit_disp = " "
   SET mltm_dispense_qty = 0.0
   SET mltm_dispense_qty_unit_cd = 0.0
   DECLARE mltm_dispense_qty_unit_cki = vc
   SET mltm_dispense_qty_unit_cki = " "
   DECLARE mltm_dispense_qty_unit_disp = vc
   SET mltm_dispense_qty_unit_disp = " "
   SET mltm_dc_display_days = 0
   SET mltm_dc_inter_days = 0
   SET mltm_def_format = 0
   SET mltm_search_med = 0
   SET mltm_search_intermit = 0
   SET mltm_search_cont = 0
   SET mltm_divisible_ind = 0
   SET mltm_infinite_div_ind = 0
   SET mltm_min_dose_qty = 0.0
   SET autobuild_exists_ind = 0
   SET brand_name_from_auto_ind = 0
   SELECT INTO "NL:"
    FROM br_auto_multum b,
     code_value cv1,
     code_value cv2,
     code_value cv3,
     code_value cv4
    PLAN (b
     WHERE (b.mmdc=mltm_reply->data[1].gfc_cki))
     JOIN (cv1
     WHERE cv1.cki=outerjoin(b.concentration_unit_cki)
      AND cv1.cki > outerjoin(" ")
      AND cv1.active_ind=outerjoin(1))
     JOIN (cv2
     WHERE cv2.cki=outerjoin(b.strength_unit_cki)
      AND cv2.cki > outerjoin(" ")
      AND cv2.active_ind=outerjoin(1))
     JOIN (cv3
     WHERE cv3.cki=outerjoin(b.volume_unit_cki)
      AND cv3.cki > outerjoin(" ")
      AND cv3.active_ind=outerjoin(1))
     JOIN (cv4
     WHERE cv4.cki=outerjoin(b.dispense_qty_unit_cki)
      AND cv4.cki > outerjoin(" ")
      AND cv4.active_ind=outerjoin(1))
    DETAIL
     autobuild_exists_ind = 1, brand_name_from_auto_ind = 1, mltm_generic_name = b.generic_name,
     mltm_brand_name = b.brand_name, auto_desc = b.label_description, mltm_product_type = b
     .product_type,
     mltm_conc = b.concentration_per_ml, mltm_conc_unit_cd = cv1.code_value, mltm_strength = b
     .strength,
     mltm_strength_unit_cd = cv2.code_value, mltm_strength_unit_disp = cv2.display, mltm_volume = b
     .volume,
     mltm_volume_unit_cd = cv3.code_value, mltm_volume_unit_cki = b.volume_unit_cki,
     mltm_volume_unit_disp = cv3.display,
     mltm_dispense_qty = b.dispense_qty, mltm_dispense_qty_unit_cd = cv4.code_value,
     mltm_dispense_qty_unit_cki = b.dispense_qty_unit_cki,
     mltm_dispense_qty_unit_disp = cv4.display, mltm_dc_display_days = b.dc_display_days,
     mltm_dc_inter_days = b.dc_inter_days,
     mltm_def_format = b.def_format, mltm_search_med = b.search_med, mltm_search_intermit = b
     .search_intermit,
     mltm_search_cont = b.search_cont, mltm_divisible_ind = b.divisible_ind, mltm_infinite_div_ind =
     b.infinite_div_ind,
     mltm_min_dose_qty = b.minimum_dose_qty
    WITH nocounter
   ;end select
   IF (autobuild_exists_ind=1)
    IF ( NOT (trim(mltm_brand_name) > " "))
     SET brand_name_from_auto_ind = 0
     SET mltm_brand_name = mltm_reply->data[1].product_name
    ENDIF
    IF (mltm_product_type="CONC")
     IF (mltm_conc > 0
      AND (mltm_reply->data[1].standard_package_size > 0))
      SET mltm_strength = (mltm_conc * mltm_reply->data[1].standard_package_size)
      SET mltm_strength_unit_cd = mltm_conc_unit_cd
     ELSE
      SET mltm_strength = 0.0
      SET mltm_strength_unit_cd = 0.0
     ENDIF
     SET mltm_volume = mltm_reply->data[1].standard_package_size
     SET mltm_volume_unit_cd = mltm_standard_unit_measure_cd
     SET mltm_volume_unit_disp = mltm_standard_unit_measure_disp
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_value=mltm_volume_unit_cd
      DETAIL
       mltm_volume_unit_cki = cv.cki
      WITH nocounter
     ;end select
    ELSEIF (mltm_product_type="PKGVOL")
     SET mltm_strength = 0.0
     SET mltm_strength_unit_cd = 0.0
     SET mltm_volume = mltm_reply->data[1].standard_package_size
     SET mltm_volume_unit_cd = mltm_standard_unit_measure_cd
     SET mltm_volume_unit_disp = mltm_standard_unit_measure_disp
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_value=mltm_volume_unit_cd
      DETAIL
       mltm_volume_unit_cki = cv.cki
      WITH nocounter
     ;end select
    ENDIF
   ELSE
    SET nomen_request->nomenclature_id = mltm_reply->data[1].gcr_nomen_id
    EXECUTE cps_get_nomen  WITH replace("REQUEST",nomen_request), replace("REPLY",nomen_reply)
    SET mltm_generic_name = nomen_reply->source_string
    SET mltm_brand_name = mltm_reply->data[1].product_name
    SET mltm_strength = 0
    SET mltm_strength_unit_cd = 0
    SET mltm_volume = 0
    SET mltm_volume_unit_cd = 0
    SET mltm_volume_unit_cki = " "
    SET mltm_dispense_qty = 1
    SET mltm_dispense_qty_unit_cd = ea_unit_cd
    SET mltm_dispense_qty_unit_cki = ea_unit_cki
    SET mltm_dispense_qty_unit_disp = ea_unit_disp
    SET mltm_dc_display_days = 0
    SET mltm_dc_inter_days = 0
    SET mltm_def_format = 0
    SET mltm_search_med = 0
    SET mltm_search_intermit = 0
    SET mltm_search_cont = 0
    SET mltm_divisible_ind = 0
    SET mltm_infinite_div_ind = 0
    SET mltm_min_dose_qty = 0
   ENDIF
   DECLARE mltm_desc = vc
   SET mltm_desc = " "
   IF ((((request_main->matches[m].data_ind=3)) OR ((request_main->matches[m].data_ind=5))) )
    SET mltm_desc = request_main->matches[m].legacy_description
   ELSEIF (autobuild_exists_ind=1)
    IF (mltm_product_type="PKGVOL")
     SET mltm_desc = concat(auto_desc," ",trim(cnvtstring(mltm_volume))," ",trim(
       mltm_volume_unit_disp))
    ELSE
     SET mltm_desc = auto_desc
    ENDIF
   ELSE
    IF (desc_name_pref="B"
     AND textlen(mltm_brand_name) > 0)
     SET mltm_desc = mltm_brand_name
    ELSEIF (((desc_name_pref="G") OR (desc_name_pref="B"
     AND textlen(mltm_brand_name)=0)) )
     SET mltm_desc = mltm_generic_name
    ENDIF
    IF (desc_strength_pref=1
     AND textlen(mltm_reply->data[1].strength) > 0)
     IF (textlen(mltm_desc) > 0)
      SET mltm_desc = concat(trim(mltm_desc)," ",trim(mltm_reply->data[1].strength))
     ELSE
      SET mltm_desc = mltm_reply->data[1].strength
     ENDIF
    ENDIF
    IF (textlen(mltm_desc) > 0)
     IF (textlen(mltm_dose_form_display) > 0
      AND desc_nbr_chars_dose_form_pref > 0)
      SET mltm_desc = concat(trim(mltm_desc)," ",substring(1,desc_nbr_chars_dose_form_pref,
        mltm_dose_form_display))
     ENDIF
    ENDIF
    IF ((mltm_reply->data[1].unit_dose_flag="U"))
     IF (textlen(mltm_desc) > 0)
      SET mltm_desc = concat(trim(mltm_desc)," UD")
     ELSE
      SET mltm_desc = "UD"
     ENDIF
    ENDIF
    IF (textlen(mltm_reply->data[1].additional_description) > 0)
     IF (textlen(mltm_desc) > 0)
      SET mltm_desc = concat(trim(mltm_desc)," ",trim(mltm_reply->data[1].additional_description))
     ELSE
      SET mltm_desc = mltm_reply->data[1].additional_description
     ENDIF
    ENDIF
   ENDIF
   DECLARE mltm_mnem = vc
   IF (autobuild_exists_ind=0)
    SET mltm_mnem = mltm_desc
   ELSE
    IF (mnem_name_pref="B"
     AND textlen(mltm_brand_name) > 0)
     SET mltm_mnem = substring(1,mnem_nbr_chars_name_pref,mltm_brand_name)
    ELSEIF (mnem_name_pref="G"
     AND textlen(mltm_generic_name) > 0)
     SET mltm_mnem = substring(1,mnem_nbr_chars_name_pref,mltm_generic_name)
    ELSE
     SET mltm_mnem = ""
    ENDIF
    IF (mltm_strength > 0)
     DECLARE strength_string = vc
     DECLARE strength_size = i4
     SET strength_string = trim(build(mltm_strength))
     SET strength_size = size(strength_string,1)
     SET decimal_found = 0
     SET decimal_found = findstring(".",strength_string,1)
     IF (decimal_found=0)
      SET mltm_mnem = concat(trim(mltm_mnem),trim(cnvtstring(mltm_strength)))
     ELSE
      SET continue_ind = 1
      SET start_search = strength_size
      SET found_last = 0
      WHILE (continue_ind=1)
        IF (substring(start_search,1,strength_string)="0")
         SET start_search = (start_search - 1)
        ELSE
         SET found_last = start_search
         SET continue_ind = 0
        ENDIF
      ENDWHILE
      SET mltm_mnem = concat(trim(mltm_mnem),trim(substring(1,found_last,strength_string)))
     ENDIF
    ENDIF
    IF (textlen(mltm_dose_form_display) > 0)
     IF (textlen(mltm_dose_form_display) >= mnem_nbr_chars_dose_form_pref)
      SET mltm_mnem = concat(trim(mltm_mnem),substring(1,mnem_nbr_chars_dose_form_pref,
        mltm_dose_form_display))
     ELSE
      SET mltm_mnem = concat(trim(mltm_mnem),substring(1,textlen(mltm_dose_form_display),
        mltm_dose_form_display))
     ENDIF
    ENDIF
   ENDIF
   SET mltm_formatted_ndc = fillstring(13," ")
   IF ((request_main->matches[m].data_ind=1))
    SET mltm_formatted_ndc = concat(substring(1,5,request_main->matches[m].mill_ndc),"-",substring(6,
      4,request_main->matches[m].mill_ndc),"-",substring(10,2,request_main->matches[m].mill_ndc))
   ELSE
    SET mltm_formatted_ndc = concat(substring(1,5,request_main->matches[m].legacy_ndc),"-",substring(
      6,4,request_main->matches[m].legacy_ndc),"-",substring(10,2,request_main->matches[m].legacy_ndc
      ))
   ENDIF
   SET mltm_awp_factor = 1.0
   IF (autobuild_exists_ind=1)
    SET ea_unit_cki = "CKI.CODEVALUE!2724"
    SET ml_unit_cki = "CKI.CODEVALUE!3780"
    SET gm_unit_cki = "CKI.CODEVALUE!6123"
    SET mg_unit_cki = "CKI.CODEVALUE!2749"
    SET case_nbr = 0
    IF (mltm_standard_unit_measure_cki=ml_unit_cki
     AND mltm_dispense_qty_unit_cki=ml_unit_cki)
     SET case_nbr = 1
    ENDIF
    IF (mltm_standard_unit_measure_cki=ml_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki != mltm_volume_unit_cki)
     SET case_nbr = 2
    ENDIF
    IF (mltm_standard_unit_measure_cki=ml_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki=mltm_volume_unit_cki
     AND (mltm_volume=mltm_reply->data[1].standard_package_size))
     SET case_nbr = 3
    ENDIF
    IF (mltm_standard_unit_measure_cki=ml_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki=mltm_volume_unit_cki
     AND (mltm_volume != mltm_reply->data[1].standard_package_size))
     SET case_nbr = 4
    ENDIF
    IF (mltm_standard_unit_measure_cki=gm_unit_cki
     AND mltm_dispense_qty_unit_cki=gm_unit_cki)
     SET case_nbr = 5
    ENDIF
    IF (mltm_standard_unit_measure_cki=gm_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki != mltm_volume_unit_cki)
     SET case_nbr = 6
    ENDIF
    IF (mltm_standard_unit_measure_cki=gm_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki=mltm_volume_unit_cki
     AND (mltm_volume=mltm_reply->data[1].standard_package_size))
     SET case_nbr = 7
    ENDIF
    IF (mltm_standard_unit_measure_cki=gm_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki
     AND mltm_standard_unit_measure_cki=mltm_volume_unit_cki
     AND (mltm_volume != mltm_reply->data[1].standard_package_size))
     SET case_nbr = 8
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND mltm_dispense_qty_unit_cki=ea_unit_cki)
     SET case_nbr = 9
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND mltm_dispense_qty_unit_cki=ml_unit_cki)
     SET case_nbr = 10
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND cnvtupper(substring(1,3,mltm_volume_unit_disp))="CAP")
     SET case_nbr = 11
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND cnvtupper(substring(1,3,mltm_volume_unit_disp))="TAB")
     SET case_nbr = 12
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND mltm_dispense_qty_unit_cki=mg_unit_cki)
     SET case_nbr = 13
    ENDIF
    IF (mltm_standard_unit_measure_cki=ea_unit_cki
     AND mltm_dispense_qty_unit_cki=gm_unit_cki)
     SET case_nbr = 14
    ENDIF
    IF (mltm_standard_unit_measure_cki=ml_unit_cki
     AND mltm_volume_unit_cki=ml_unit_cki)
     SET case_nbr = 15
    ENDIF
    IF (case_nbr=1)
     SET mltm_awp_factor = 1
    ELSEIF (case_nbr=2)
     SET mltm_awp_factor = 0
    ELSEIF (case_nbr=3)
     SET mltm_awp_factor = mltm_reply->data[1].standard_package_size
    ELSEIF (case_nbr=4)
     SET mltm_awp_factor = mltm_volume
    ELSEIF (case_nbr=5)
     SET mltm_awp_factor = 1
    ELSEIF (case_nbr=6)
     SET mltm_awp_factor = 0
    ELSEIF (case_nbr=7)
     SET mltm_awp_factor = mltm_reply->data[1].standard_package_size
    ELSEIF (case_nbr=8)
     SET mltm_awp_factor = mltm_volume
    ELSEIF (case_nbr=9)
     SET mltm_awp_factor = 1
    ELSEIF (case_nbr=10)
     SET mltm_awp_factor = 0
    ELSEIF (case_nbr=11)
     SET mltm_awp_factor = 1
    ELSEIF (case_nbr=12)
     SET mltm_awp_factor = 1
    ELSEIF (case_nbr=13)
     SET mltm_awp_factor = 0
    ELSEIF (case_nbr=14)
     SET mltm_awp_factor = 0
    ELSEIF (case_nbr=15)
     SET mltm_awp_factor = mltm_volume
    ELSE
     SET mltm_awp_factor = 0
    ENDIF
   ENDIF
   SET match_catalog_cd = 0.0
   SELECT INTO "NL:"
    FROM order_catalog oc
    WHERE (oc.cki=mltm_reply->data[1].mmdc_cki)
     AND oc.catalog_type_cd=pharm_cat_type_cd
     AND oc.orderable_type_flag IN (0, 1)
     AND oc.active_ind=1
    DETAIL
     match_catalog_cd = oc.catalog_cd
    WITH nocounter
   ;end select
   IF (match_catalog_cd=0
    AND ((mltm_ord_cki < 4128) OR (mltm_ord_cki > 4134)) )
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.cki=mltm_reply->data[1].gcr_cki)
      AND oc.catalog_type_cd=pharm_cat_type_cd
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.active_ind=1
     DETAIL
      match_catalog_cd = oc.catalog_cd
     WITH nocounter
    ;end select
   ENDIF
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
   SET request->prod_rec_status = 3
   SET request->manf_rec_status = 0
   SET request->prod_id_rec_status = 3
   SET request->oc_rec_status = 3
   SET request->sent_rec_status = 3
   SET request->pack_rec_status = 3
   SET stat = alterlist(request->meddefqual,1)
   SET request->meddefqual[1].gfc_description = " "
   SET request->meddefqual[1].active_status_cd = active_cd
   SET request->meddefqual[1].updt_cnt = 0
   SET request->meddefqual[1].db_rec_status = 3
   SET request->meddefqual[1].med_type_flag = 0
   SET request->meddefqual[1].item_id = 0
   SET request->meddefqual[1].mdx_gfc_nomen_id = mltm_reply->data[1].gfc_nomen_id
   SET request->meddefqual[1].form_cd = mltm_dose_form_cd
   SET request->meddefqual[1].strength = 0
   SET request->meddefqual[1].strength_unit_cd = 0
   SET request->meddefqual[1].volume = 0
   SET request->meddefqual[1].volume_unit_cd = 0
   SET request->meddefqual[1].given_strength = mltm_reply->data[1].strength
   SET request->meddefqual[1].meq_factor = 0
   SET request->meddefqual[1].mmol_factor = 0
   SET request->meddefqual[1].compound_text_id = 0
   SET request->meddefqual[1].compound_text = " "
   SET request->meddefqual[1].comment1_text = " "
   SET request->meddefqual[1].comment2_text = " "
   SET request->meddefqual[1].comment1_id = 0
   SET request->meddefqual[1].comment2_id = 0
   SET request->meddefqual[1].cki = mltm_reply->data[1].gfc_cki
   SET request->meddefqual[1].schedulable_ind = 0
   SET request->meddefqual[1].reusable_ind = 0
   SET request->meddefqual[1].cdm = " "
   SET request->meddefqual[1].critical_ind = 0
   SET request->meddefqual[1].sub_account_cd = 0
   SET request->meddefqual[1].cost_center_cd = 0
   SET request->meddefqual[1].storage_requirement_cd = 0
   SET request->meddefqual[1].sterilization_required_ind = 0
   IF (autobuild_exists_ind=1
    AND mltm_min_dose_qty > 0)
    SET request->meddefqual[1].base_issue_factor = mltm_min_dose_qty
   ELSE
    IF (mltm_dose_form_divisible > 0)
     SET request->meddefqual[1].base_issue_factor = 0.5
    ELSE
     SET request->meddefqual[1].base_issue_factor = 1
    ENDIF
   ENDIF
   SET request->meddefqual[1].active_ind = 1
   SET request->meddefqual[1].package_type_id = 0
   SET request->meddefqual[1].template_catalog_cd = 0
   SET request->meddefqual[1].template_synonym_id = 0
   SET request->meddefqual[1].primary_synonym_mnemonic = " "
   SET stat = alterlist(request->meddefqual[1].locqual,0)
   SET stat = alterlist(request->meddefqual[1].pack,1)
   SET pack_desc = concat("1 ",trim(mltm_standard_unit_measure_disp))
   SET request->meddefqual[1].pack[1].db_rec_status = 3
   SET request->meddefqual[1].pack[1].item_id = 0
   SET request->meddefqual[1].pack[1].package_type_id = 0
   SET request->meddefqual[1].pack[1].description = pack_desc
   SET request->meddefqual[1].pack[1].uom_cd = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].pack[1].base_uom_cd = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].pack[1].qty = 1
   SET request->meddefqual[1].pack[1].base_package_type_ind = 1
   SET request->meddefqual[1].pack[1].active_ind = 1
   SET request->meddefqual[1].pack[1].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].ordcat,1)
   IF (match_catalog_cd=0)
    SET request->meddefqual[1].ordcat[1].catalog_cd = 0
    SET request->meddefqual[1].ordcat[1].db_rec_status = 3
    SET request->meddefqual[1].ordcat[1].prep_into_flag = 0
    SET request->meddefqual[1].ordcat[1].consent_form_ind = 0
    SET request->meddefqual[1].ordcat[1].active_ind = 1
    SET request->meddefqual[1].ordcat[1].catalog_type_cd = pharm_cat_type_cd
    SET request->meddefqual[1].ordcat[1].catalog_type_disp = " "
    SET request->meddefqual[1].ordcat[1].activity_type_cd = pharm_act_type_cd
    SET request->meddefqual[1].ordcat[1].activity_subtype_cd = 0
    SET request->meddefqual[1].ordcat[1].requisition_format_cd = 0
    SET request->meddefqual[1].ordcat[1].requisition_routing_cd = 0
    SET request->meddefqual[1].ordcat[1].inst_restriction_ind = 0
    SET request->meddefqual[1].ordcat[1].schedule_ind = 0
    IF (mltm_ord_cki > 4127
     AND mltm_ord_cki < 4133)
     SET request->meddefqual[1].ordcat[1].description = mltm_reply->data[1].rx_mnemonic_synonym
    ELSE
     SET request->meddefqual[1].ordcat[1].description = mltm_reply->data[1].generic_name
    ENDIF
    SET request->meddefqual[1].ordcat[1].iv_ingredient_ind = 0
    SET request->meddefqual[1].ordcat[1].print_req_ind = 0
    SET request->meddefqual[1].ordcat[1].oe_format_id = primary_oe_format_id
    SET request->meddefqual[1].ordcat[1].orderable_type_flag = 1
    SET request->meddefqual[1].ordcat[1].complete_upon_order_ind = 0
    SET request->meddefqual[1].ordcat[1].quick_chart_ind = 0
    SET request->meddefqual[1].ordcat[1].comment_template_flag = 0
    SET request->meddefqual[1].ordcat[1].prep_info_flag = 0
    SET request->meddefqual[1].ordcat[1].updt_cnt = 0
    SET request->meddefqual[1].ordcat[1].valid_iv_additive_ind = 0
    SET request->meddefqual[1].ordcat[1].dc_display_days = mltm_dc_display_days
    SET request->meddefqual[1].ordcat[1].dc_interaction_days = mltm_dc_inter_days
    SET request->meddefqual[1].ordcat[1].op_dc_display_days = 0
    SET request->meddefqual[1].ordcat[1].op_dc_interaction_days = 0
    SET request->meddefqual[1].ordcat[1].set_op_days = 0
    SET request->meddefqual[1].ordcat[1].mdx_gcr_nomen_id = 0
    IF (mltm_ord_cki > 4127
     AND mltm_ord_cki < 4133)
     SET request->meddefqual[1].ordcat[1].cki = mltm_reply->data[1].mmdc_cki
    ELSE
     SET request->meddefqual[1].ordcat[1].cki = mltm_reply->data[1].gcr_cki
    ENDIF
    SET request->meddefqual[1].ordcat[1].gcr_desc = " "
   ELSE
    SET request->meddefqual[1].ordcat[1].catalog_cd = match_catalog_cd
    SET request->meddefqual[1].ordcat[1].db_rec_status = 1
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE oc.catalog_cd=match_catalog_cd
     DETAIL
      request->meddefqual[1].ordcat[1].prep_into_flag = 0, request->meddefqual[1].ordcat[1].
      consent_form_ind = oc.consent_form_ind, request->meddefqual[1].ordcat[1].active_ind = oc
      .active_ind,
      request->meddefqual[1].ordcat[1].catalog_type_cd = oc.catalog_type_cd, request->meddefqual[1].
      ordcat[1].catalog_type_disp = " ", request->meddefqual[1].ordcat[1].activity_type_cd = oc
      .activity_type_cd,
      request->meddefqual[1].ordcat[1].activity_subtype_cd = oc.activity_subtype_cd, request->
      meddefqual[1].ordcat[1].requisition_format_cd = oc.requisition_format_cd, request->meddefqual[1
      ].ordcat[1].requisition_routing_cd = oc.requisition_routing_cd,
      request->meddefqual[1].ordcat[1].inst_restriction_ind = oc.inst_restriction_ind, request->
      meddefqual[1].ordcat[1].schedule_ind = oc.schedule_ind, request->meddefqual[1].ordcat[1].
      description = oc.description,
      request->meddefqual[1].ordcat[1].iv_ingredient_ind = 0, request->meddefqual[1].ordcat[1].
      print_req_ind = oc.print_req_ind, request->meddefqual[1].ordcat[1].oe_format_id = oc
      .oe_format_id,
      request->meddefqual[1].ordcat[1].orderable_type_flag = oc.orderable_type_flag, request->
      meddefqual[1].ordcat[1].complete_upon_order_ind = oc.complete_upon_order_ind, request->
      meddefqual[1].ordcat[1].quick_chart_ind = oc.quick_chart_ind,
      request->meddefqual[1].ordcat[1].comment_template_flag = oc.comment_template_flag, request->
      meddefqual[1].ordcat[1].prep_info_flag = oc.prep_info_flag, request->meddefqual[1].ordcat[1].
      updt_cnt = oc.updt_cnt,
      request->meddefqual[1].ordcat[1].valid_iv_additive_ind = 0, request->meddefqual[1].ordcat[1].
      dc_display_days = oc.dc_display_days, request->meddefqual[1].ordcat[1].dc_interaction_days = oc
      .dc_interaction_days,
      request->meddefqual[1].ordcat[1].op_dc_display_days = 0, request->meddefqual[1].ordcat[1].
      op_dc_interaction_days = 0, request->meddefqual[1].ordcat[1].set_op_days = 0,
      request->meddefqual[1].ordcat[1].mdx_gcr_nomen_id = 0, request->meddefqual[1].ordcat[1].cki =
      oc.cki, request->meddefqual[1].ordcat[1].gcr_desc = " "
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(request->meddefqual[1].ordcat[1].ahfs_qual,1)
   SET tclass_cnt = size(mltm_reply->data[1].tclass,5)
   IF (tclass_cnt > 0)
    SET request->meddefqual[1].ordcat[1].ahfs_qual[1].ahfs_code = cnvtstring(mltm_reply->data[1].
     tclass[1].therapeutic_class_code)
   ELSE
    SET request->meddefqual[1].ordcat[1].ahfs_qual[1].ahfs_code = "0"
   ENDIF
   IF (match_catalog_cd=0)
    SET stat = alterlist(request->meddefqual[1].ordcat[1].qual_mnemonic,2)
   ELSE
    SET stat = alterlist(request->meddefqual[1].ordcat[1].qual_mnemonic,1)
   ENDIF
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].db_rec_status = 3
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].item_id = 0
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].synonym_id = 0
   IF (autobuild_exists_ind=1)
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].mnemonic = mltm_mnem
   ELSE
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].mnemonic = mltm_desc
   ENDIF
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].mnemonic_type_cd = rx_mnem_type_cd
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].synonym_cki = " "
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].active_ind = 1
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].order_sentence_id = 0
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].orderable_type_flag = null
   SET request->meddefqual[1].ordcat[1].qual_mnemonic[1].updt_cnt = 0
   IF (match_catalog_cd=0)
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].db_rec_status = 3
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].item_id = 0
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].synonym_id = 0
    IF (mltm_ord_cki > 4127
     AND mltm_ord_cki < 4133)
     SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].mnemonic = mltm_reply->data[1].
     rx_mnemonic_synonym
    ELSE
     SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].mnemonic = mltm_reply->data[1].
     generic_name
    ENDIF
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].mnemonic_type_cd = primary_mnem_type_cd
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].synonym_cki = mltm_reply->data[1].
    generic_name_cki
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].active_ind = 1
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].order_sentence_id = 0
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].orderable_type_flag = 1
    SET request->meddefqual[1].ordcat[1].qual_mnemonic[2].updt_cnt = 0
   ENDIF
   SET stat = alterlist(request->meddefqual[1].meddefflexqual,2)
   SET request->meddefqual[1].meddefflexqual[1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].sequence = 0
   SET request->meddefqual[1].meddefflexqual[1].flex_type_cd = system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].flex_sort_flag = 600
   SET request->meddefqual[1].meddefflexqual[1].pharmacy_type_cd = inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].parent_med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].active_status_cd = active_cd
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].pack,1)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,4)
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
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].pharmacy_type_cd =
   inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].flex_type_cd =
   system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_identifier_type_cd =
   generic_name_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value = mltm_generic_name
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[1].med_type_flag = 0
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
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].pharmacy_type_cd =
   inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].flex_type_cd =
   system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_identifier_type_cd =
   desc_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value = mltm_desc
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[2].med_type_flag = 0
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
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].pharmacy_type_cd =
   inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].flex_type_cd =
   system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_identifier_type_cd =
   desc_short_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value = mltm_mnem
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].med_type_flag = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].primary_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[3].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].salable_by_vendor_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].salable_by_mfr_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].id_type_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].flex_sort_flag = 600
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].med_identifier_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].order_set_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].item_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].med_product_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].sequence = 1
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].pharmacy_type_cd =
   inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].flex_type_cd =
   system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].med_identifier_type_cd =
   rx_device1_type_cd
   IF (autobuild_exists_ind=1)
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].value = "AUTOBUILD"
   ELSE
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].value = "MULTUM"
   ENDIF
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].med_type_flag = 0
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].primary_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[4].updt_cnt = 0
   SET idx = 4
   IF (rx_unique_id_type_cd > 0
    AND unique_id_pref > " ")
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,idx)
    SET unique_id_text = unique_id_pref
    SET unique_id_text = replace(unique_id_text,"/f","All")
    SET unique_id_text = replace(unique_id_text,"/p",trim(inpt_pharm_type_disp))
    SET unique_id_text = replace(unique_id_text,"/d",trim(mltm_desc))
    SET unique_id_text = replace(unique_id_text,"/s",trim(mltm_mnem))
    SET unique_id_text = replace(unique_id_text,"/a","Active")
    SET dup_ind = 1
    SET dup_cnt = 0
    WHILE (dup_ind=1)
      SET dup_ind = 0
      SELECT INTO "NL:"
       FROM med_identifier m
       WHERE m.med_identifier_type_cd=rx_unique_id_type_cd
        AND m.value_key=cnvtalphanum(cnvtupper(unique_id_text))
       DETAIL
        dup_ind = 1
       WITH nocounter
      ;end select
      IF (dup_ind=1)
       SET dup_cnt = (dup_cnt+ 1)
       SET unique_id_text = unique_id_pref
       SET unique_id_text = replace(unique_id_text,"/f","All")
       SET unique_id_text = replace(unique_id_text,"/p",trim(inpt_pharm_type_disp))
       SET unique_id_text = replace(unique_id_text,"/d",trim(mltm_desc))
       SET unique_id_text = replace(unique_id_text,"/s",trim(mltm_mnem))
       SET unique_id_text = replace(unique_id_text,"/a","Active")
       SET unique_id_text = concat(trim(unique_id_text)," - ",trim(cnvtstring(dup_cnt)))
      ENDIF
    ENDWHILE
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].pharmacy_type_cd =
    inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_type_cd =
    system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_type_cd =
    rx_unique_id_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value = unique_id_text
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].updt_cnt = 0
   ENDIF
   IF (autobuild_exists_ind=1
    AND brand_name_from_auto_ind=1)
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,idx)
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].pharmacy_type_cd =
    inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_type_cd =
    system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_type_cd =
    brand_name_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value = mltm_brand_name
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].updt_cnt = 0
   ENDIF
   IF (trim(legacy_ubc_ident) > " ")
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,idx)
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].pharmacy_type_cd =
    inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_type_cd =
    system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_type_cd =
    pyxis_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value = legacy_ubc_ident
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].updt_cnt = 0
   ENDIF
   IF (trim(legacy_charge_nbr) > " ")
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,idx)
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].pharmacy_type_cd =
    inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_type_cd =
    system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_type_cd =
    cdm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value = legacy_charge_nbr
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].updt_cnt = 0
   ENDIF
   IF ((request_main->matches[m].data_ind=1))
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medidentifierqual,idx)
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].pharmacy_type_cd =
    inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].flex_type_cd =
    system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_identifier_type_cd =
    rx_misc5_type_cd
    SET formatted_ndc = fillstring(13," ")
    SET formatted_ndc = concat(substring(1,5,request_main->matches[m].legacy_ndc),"-",substring(6,4,
      request_main->matches[m].legacy_ndc),"-",substring(10,2,request_main->matches[m].legacy_ndc))
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value = formatted_ndc
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medidentifierqual[idx].updt_cnt = 0
   ENDIF
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual,2)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].med_flex_object_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].sequence = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].parent_entity =
   "MED_OE_DEFAULTS"
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].flex_object_type_cd =
   oedef_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].meddispensequal,
    0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].
    medoedefaultsqual,1)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   freetext_dose = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].diluent_id
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   diluent_volume = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment1_text = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment2_text = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   default_par_doses = - (1)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   max_par_supply = - (1)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   med_oe_defaults_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].strength =
   0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   strength_unit_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].volume = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   volume_unit_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].route_cd =
   mltm_route_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   frequency_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].prn_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   prn_reason_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].infuse_over
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   infuse_over_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].duration =
   0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   duration_unit_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   stop_type_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   dispense_category_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   alternate_dispense_category_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].comment1_id
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment1_type = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].comment2_id
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   comment2_type = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   price_sched_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].active_ind
    = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].updt_cnt =
   0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].rx_qty = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].daw_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].sig_codes
    = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].nbr_labels
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medoedefaultsqual[1].
   ord_as_synonym_id = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[1].medproductqual,
    0)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].med_flex_object_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].sequence = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].parent_entity = "MED_PRODUCT"
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].flex_object_type_cd =
   medproduct_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].value = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].meddispensequal,
    0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
    medoedefaultsqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual,
    1)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].primary_ind =
   1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].db_rec_status
    = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].med_product_id
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].manf_item_id
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].bio_equiv_ind
    = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].brand_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].med_def_cki =
   " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].unit_dose_ind
    = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   manufacturer_cd = manuf_reply->manufacturer_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].awp_factor = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   schedulable_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].reusable_ind
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].critical_ind
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].sub_account_cd
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].cost_center_cd
    = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   storage_requirement_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   sterilization_required_ind = 0
   IF (autobuild_exists_ind=1
    AND mltm_min_dose_qty > 0)
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    base_issue_factor = mltm_min_dose_qty
   ELSE
    IF (mltm_dose_form_divisible > 0)
     SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
     base_issue_factor = 0.5
    ELSE
     SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
     base_issue_factor = 1
    ENDIF
   ENDIF
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   formulary_status_cd = formulary_status_cd
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[
    1].medidentifierqual,2)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].salable_by_vendor_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].salable_by_mfr_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].id_type_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].flex_sort_flag = 600
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].med_identifier_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].order_set_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].item_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].med_product_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].sequence = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].pharmacy_type_cd = inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].flex_type_cd = system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].med_identifier_type_cd = ndc_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].value = mltm_formatted_ndc
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].med_type_flag = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].primary_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[1].updt_cnt = 0
   SET manu_desc = " "
   IF (mltm_strength > 0)
    DECLARE strength_text = vc
    DECLARE strength_string = vc
    DECLARE strength_size = i4
    SET strength_string = trim(build(mltm_strength))
    SET strength_size = size(strength_string,1)
    SET decimal_found = 0
    SET decimal_found = findstring(".",strength_string,1)
    IF (decimal_found=0)
     SET strength_text = trim(cnvtstring(mltm_strength))
    ELSE
     SET continue_ind = 1
     SET start_search = strength_size
     SET found_last = 0
     WHILE (continue_ind=1)
       IF (substring(start_search,1,strength_string)="0")
        SET start_search = (start_search - 1)
       ELSE
        SET found_last = start_search
        SET continue_ind = 0
       ENDIF
     ENDWHILE
     SET strength_text = trim(substring(1,found_last,strength_string))
    ENDIF
    SET manu_desc = concat(trim(mltm_generic_name)," ",trim(strength_text)," ",trim(
      mltm_strength_unit_disp),
     " ",trim(mltm_dose_form_display))
   ELSE
    SET manu_desc = concat(trim(mltm_generic_name)," ",trim(mltm_dose_form_display))
   ENDIF
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].salable_by_vendor_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].salable_by_mfr_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].id_type_cd = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].flex_sort_flag = 600
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].med_identifier_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].order_set_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].item_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].med_product_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].sequence = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].pharmacy_type_cd = inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].flex_type_cd = system_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].med_identifier_type_cd = desc_type_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].value = manu_desc
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].value_key = " "
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].med_type_flag = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].primary_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
   medidentifierqual[2].updt_cnt = 0
   SET idx = 2
   IF (rx_unique_id_type_cd > 0
    AND unique_id_pref > " ")
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
     medproductqual[1].medidentifierqual,idx)
    SET unique_id_text = unique_id_pref
    SET unique_id_text = replace(unique_id_text,"/f","All")
    SET unique_id_text = replace(unique_id_text,"/p",trim(inpt_pharm_type_disp))
    SET unique_id_text = replace(unique_id_text,"/d",trim(manu_desc))
    SET unique_id_text = replace(unique_id_text,"/s",trim(" "))
    SET unique_id_text = replace(unique_id_text,"/a","Active")
    SET unique_id_text = concat(trim(unique_id_text)," - ",trim(mltm_formatted_ndc))
    SET dup_ind = 1
    SET dup_cnt = 0
    WHILE (dup_ind=1)
      SET dup_ind = 0
      SELECT INTO "NL:"
       FROM med_identifier m
       WHERE m.med_identifier_type_cd=rx_unique_id_type_cd
        AND m.value_key=cnvtalphanum(cnvtupper(unique_id_text))
       DETAIL
        dup_ind = 1
       WITH nocounter
      ;end select
      IF (dup_ind=1)
       SET dup_cnt = (dup_cnt+ 1)
       SET unique_id_text = unique_id_pref
       SET unique_id_text = replace(unique_id_text,"/f","All")
       SET unique_id_text = replace(unique_id_text,"/p",trim(inpt_pharm_type_disp))
       SET unique_id_text = replace(unique_id_text,"/d",trim(manu_desc))
       SET unique_id_text = replace(unique_id_text,"/s",trim(" "))
       SET unique_id_text = replace(unique_id_text,"/a","Active")
       SET unique_id_text = concat(trim(unique_id_text)," - ",trim(mltm_formatted_ndc))
       SET unique_id_text = concat(trim(unique_id_text)," - ",trim(cnvtstring(dup_cnt)))
      ENDIF
    ENDWHILE
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].pharmacy_type_cd = inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].flex_type_cd = system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_identifier_type_cd = rx_unique_id_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].value = unique_id_text
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].updt_cnt = 0
   ENDIF
   IF (autobuild_exists_ind=1
    AND brand_name_from_auto_ind=1)
    SET idx = (idx+ 1)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
     medproductqual[1].medidentifierqual,idx)
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].salable_by_vendor_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].salable_by_mfr_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].id_type_cd = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_def_flex_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].flex_sort_flag = 600
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_identifier_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].order_set_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].sequence = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].pharmacy_type_cd = inpt_pharm_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].parent_entity = " "
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].flex_type_cd = system_flex_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_identifier_type_cd = brand_name_type_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].value = mltm_brand_name
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].value_key = " "
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].med_type_flag = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].primary_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medidentifierqual[idx].updt_cnt = 0
   ENDIF
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[
    1].pack,2)
   SET pack_desc = concat(trim(cnvtstring(mltm_dispense_qty))," ",trim(
     mltm_standard_unit_measure_disp))
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   item_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   description = pack_desc
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].uom_cd
    = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   base_uom_cd = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].qty =
   1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   base_package_type_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[1].
   updt_cnt = 0
   SET pack_desc = concat(trim(mltm_standard_unit_measure_disp)," of ",trim(cnvtstring(mltm_reply->
      data[1].standard_package_size))," ",trim(mltm_standard_unit_measure_disp))
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   item_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   description = pack_desc
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].uom_cd
    = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   base_uom_cd = mltm_standard_unit_measure_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].qty =
   mltm_reply->data[1].standard_package_size
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   base_package_type_ind = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[2].
   updt_cnt = 0
   IF ((mltm_reply->data[1].package_size > 0))
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
     medproductqual[1].pack,3)
    SET pack_desc = concat(trim(mltm_standard_unit_measure_disp)," of ",trim(cnvtstring(mltm_reply->
       data[1].package_size))," ",trim(mltm_standard_unit_measure_disp))
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    item_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    package_type_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    description = pack_desc
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    uom_cd = mltm_standard_unit_measure_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    base_uom_cd = mltm_standard_unit_measure_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].qty
     = (mltm_reply->data[1].package_size * mltm_reply->data[1].standard_package_size)
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    base_package_type_ind = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].pack[3].
    updt_cnt = 0
   ENDIF
   IF (legacy_acq_cost > 0)
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
     medproductqual[1].medcosthxqual,2)
   ELSE
    SET stat = alterlist(request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
     medproductqual[1].medcosthxqual,1)
   ENDIF
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].med_cost_hx_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].med_product_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].cost_type_cd = awp_cost_basis_cd
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].cost = mltm_reply->data[1].awp_current_unit_price
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].updt_id = 0
   SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].medcosthxqual[
   1].updt_dt_tm = 0
   IF (legacy_acq_cost > 0)
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].db_rec_status = 3
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].med_cost_hx_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].med_product_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].cost_type_cd = cost1_cost_basis_cd
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].cost = legacy_acq_cost
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].active_ind = 1
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].updt_cnt = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].updt_id = 0
    SET request->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].medproductqual[1].
    medcosthxqual[2].updt_dt_tm = 0
   ENDIF
   SET request->meddefqual[1].meddefflexqual[2].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[2].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[2].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[2].parent_entity = " "
   SET request->meddefqual[1].meddefflexqual[2].sequence = 0
   SET request->meddefqual[1].meddefflexqual[2].flex_type_cd = system_pkg_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[2].flex_sort_flag = 500
   SET request->meddefqual[1].meddefflexqual[2].pharmacy_type_cd = inpt_pharm_type_cd
   SET request->meddefqual[1].meddefflexqual[2].parent_med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[2].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[2].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[2].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].active_status_cd = active_cd
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].pack,1)
   SET request->meddefqual[1].meddefflexqual[2].pack[1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[2].pack[1].item_id = 0
   SET request->meddefqual[1].meddefflexqual[2].pack[1].package_type_id = 0
   SET request->meddefqual[1].meddefflexqual[2].pack[1].description = mltm_dispense_qty_unit_disp
   SET request->meddefqual[1].meddefflexqual[2].pack[1].uom_cd = mltm_dispense_qty_unit_cd
   SET request->meddefqual[1].meddefflexqual[2].pack[1].base_uom_cd = mltm_dispense_qty_unit_cd
   SET request->meddefqual[1].meddefflexqual[2].pack[1].qty = mltm_dispense_qty
   SET request->meddefqual[1].meddefflexqual[2].pack[1].base_package_type_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].pack[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].pack[1].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medidentifierqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual,2)
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].med_flex_object_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].sequence = 1
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].parent_entity = "MED_DISPENSE"
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].flex_object_type_cd =
   dispense_type_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal,
    1)
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pharmacy_type_cd = inpt_pharm_type_cd
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
    = " "
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].flex_type_cd
    = system_pkg_flex_type_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   flex_sort_flag = 500
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   legal_status_cd = mltm_legal_status_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   formulary_status_cd = formulary_status_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   oe_format_flag = mltm_def_format
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   med_filter_ind = mltm_search_med
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   continuous_filter_ind = mltm_search_cont
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   intermittent_filter_ind = mltm_search_intermit
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   tpn_filter_ind = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   max_par_supply = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   infinite_div_ind = mltm_infinite_div_ind
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].divisible_ind
    = mltm_divisible_ind
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   used_as_base_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   always_dispense_from_flag = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].dispense_qty
    = mltm_dispense_qty
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   dispense_factor = mltm_awp_factor
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].label_ratio
    = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].reusable_ind
    = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].strength =
   mltm_strength
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   strength_unit_cd = mltm_strength_unit_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].volume =
   mltm_volume
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   volume_unit_cd = mltm_volume_unit_cd
   IF (autobuild_exists_ind=1
    AND mltm_min_dose_qty > 0)
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
    base_issue_factor = mltm_min_dose_qty
   ELSE
    IF (mltm_dose_form_divisible > 0)
     SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
     base_issue_factor = 0.5
    ELSE
     SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
     base_issue_factor = 1
    ENDIF
   ENDIF
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].updt_cnt = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pkg_qty_per_pkg = - (1)
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   pkg_disp_more_ind = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   override_clsfctn_cd = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].
   rx_station_notes = " "
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
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].meddispensequal[1].workflow_cd
    = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].
    medoedefaultsqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[1].medproductqual,
    0)
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].db_rec_status = 3
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].med_def_flex_id = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].med_flex_object_id = 0
   IF ((request_main->matches[m].legacy_facility_code_value > 0))
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity_id = request_main
    ->matches[m].legacy_facility_code_value
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity = "CODE_VALUE"
   ELSE
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity_id = 0
    SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].parent_entity = " "
   ENDIF
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].sequence = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].flex_object_type_cd =
   orderable_type_cd
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].value = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].value_unit = 0
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].active_ind = 1
   SET request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].updt_cnt = 0
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].meddispensequal,
    0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].
    medoedefaultsqual,0)
   SET stat = alterlist(request->meddefqual[1].meddefflexqual[2].medflexobjidxqual[2].medproductqual,
    0)
   SET stat = alterlist(request->meddefqual[1].medingredqual,0)
   SET stat = alterlist(request->meddefqual[1].tpn_group_qual,0)
   SET hold_m = m
   CALL echo(
    "****************************** this is the request before the call to rxa_add_medproduct")
   CALL echorecord(request)
   EXECUTE rxa_add_medproduct
   IF ((reply->status_data.status="F"))
    SET match_ind = 4
   ELSE
    SET total_saves = (total_saves+ 1)
    SET match_ind = 1
   ENDIF
   UPDATE  FROM br_pharm_product_work b
    SET b.match_ind = match_ind, b.match_ndc = request_main->matches[hold_m].mill_ndc, b.match_option
      = request_main->matches[hold_m].data_ind,
     b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo
     ->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WHERE (b.facility_cd=request_main->matches[hold_m].legacy_facility_code_value)
     AND (b.ndc=request_main->matches[hold_m].legacy_ndc)
     AND (b.description=request_main->matches[hold_m].legacy_description)
    WITH nocounter
   ;end update
   IF (match_ind=1)
    SET hold_item_id = reply->meddefqual[1].item_id
    SET hold_catalog_cd = reply->meddefqual[1].ordcat[1].catalog_cd
    SET hold_manf_item_id = reply->meddefqual[1].meddefflexqual[1].medflexobjidxqual[2].
    medproductqual[1].manf_item_id
    SET hold_med_def_flex_id = reply->meddefqual[1].meddefflexqual[1].med_def_flex_id
    FREE SET request
    RECORD request(
      1 items[*]
        2 item_id = f8
        2 manf_cd = f8
        2 orc_cd = f8
        2 manf_item_id = f8
        2 med_def_flex_id = f8
    )
    FREE SET reply
    RECORD reply(
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
      1 bill_item_modifier[10]
        2 bill_item_mod_id = f8
      1 actioncnt = i2
      1 actionlist[*]
        2 action1 = vc
        2 action2 = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c15
          3 operationstatus = c20
          3 targetobjectname = c15
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(request->items,1)
    SET request->items[1].item_id = hold_item_id
    SET request->items[1].orc_cd = hold_catalog_cd
    SET request->items[1].manf_item_id = 0
    SET request->items[1].med_def_flex_id = 0
    EXECUTE pha_add_billitem
    FREE SET request
    RECORD request(
      1 items[*]
        2 item_id = f8
        2 manf_cd = f8
        2 orc_cd = f8
        2 manf_item_id = f8
        2 med_def_flex_id = f8
    )
    FREE SET reply
    RECORD reply(
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
      1 bill_item_modifier[10]
        2 bill_item_mod_id = f8
      1 actioncnt = i2
      1 actionlist[*]
        2 action1 = vc
        2 action2 = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c15
          3 operationstatus = c20
          3 targetobjectname = c15
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(request->items,1)
    SET request->items[1].item_id = hold_item_id
    SET request->items[1].orc_cd = 0
    IF (charge_tier_pref=1)
     SET request->items[1].manf_item_id = 0
     SET request->items[1].med_def_flex_id = hold_med_def_flex_id
    ELSE
     SET request->items[1].manf_item_id = hold_manf_item_id
     SET request->items[1].med_def_flex_id = 0
    ENDIF
    EXECUTE pha_add_billitem
   ENDIF
   SET m = hold_m
 ENDFOR
#exit_script
 SET modify = noskipsrvmsg
 FREE SET reply
 RECORD reply(
   1 total_success = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->total_success = total_saves
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 COMMIT
END GO
