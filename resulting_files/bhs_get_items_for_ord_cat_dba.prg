CREATE PROGRAM bhs_get_items_for_ord_cat:dba
 RECORD info_request(
   1 itemlist[*]
     2 item_id = f8
   1 pharm_type_cd = f8
   1 facility_cd = f8
   1 pharm_loc_cd = f8
   1 pat_loc_cd = f8
   1 encounter_type_cd = f8
   1 package_type_id = f8
   1 med_all_ind = i2
   1 med_pha_flex_ind = i2
   1 med_identifier_ind = i2
   1 med_dispense_ind = i2
   1 med_oe_default_ind = i2
   1 med_def_ind = i2
   1 ther_class_ind = i2
   1 med_product_ind = i2
   1 med_product_prim_ind = i2
   1 med_product_ident_ind = i2
   1 med_cost_ind = i2
   1 misc_object_ind = i2
   1 med_cost_type_cd = f8
   1 med_child_ind = i2
 )
 RECORD info_reply(
   1 itemlist[*]
     2 parent_item_id = f8
     2 sequence = i4
     2 active_ind = i2
     2 med_def_flex_sys_id = f8
     2 med_def_flex_syspkg_id = f8
     2 item_id = f8
     2 package_type_id = f8
     2 form_cd = f8
     2 cki = vc
     2 med_type_flag = i2
     2 mdx_gfc_nomen_id = f8
     2 base_issue_factor = f8
     2 given_strength = vc
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 compound_text_id = f8
     2 mixing_instructions = vc
     2 pkg_qty = f8
     2 pkg_qty_cd = f8
     2 catalog_cd = f8
     2 catalog_cki = vc
     2 synonym_id = f8
     2 oeformatid = f8
     2 orderabletypeflag = i2
     2 catalogdescription = vc
     2 catalogtypecd = f8
     2 mnemonicstr = vc
     2 primarymnemonic = vc
     2 label_description = vc
     2 brand_name = vc
     2 mnemonic = vc
     2 generic_name = vc
     2 profile_desc = vc
     2 cdm = vc
     2 rx_mask = i4
     2 med_oe_defaults_id = f8
     2 med_oe_strength = f8
     2 med_oe_strength_unit_cd = f8
     2 med_oe_volume = f8
     2 med_oe_volume_unit_cd = f8
     2 freetext_dose = vc
     2 frequency_cd = f8
     2 route_cd = f8
     2 prn_ind = i2
     2 infuse_over = f8
     2 infuse_over_cd = f8
     2 duration = f8
     2 duration_unit_cd = f8
     2 stop_type_cd = f8
     2 default_par_doses = i4
     2 max_par_supply = i4
     2 dispense_category_cd = f8
     2 alternate_dispense_category_cd = f8
     2 comment1_id = f8
     2 comment1_type = i2
     2 comment2_id = f8
     2 comment2_type = i2
     2 comment1_text = vc
     2 comment2_text = vc
     2 price_sched_id = f8
     2 nbr_labels = i4
     2 ord_as_synonym_id = f8
     2 rx_qty = f8
     2 daw_cd = f8
     2 sig_codes = vc
     2 med_dispense_id = f8
     2 med_disp_package_type_id = f8
     2 med_disp_strength = f8
     2 med_disp_strength_unit_cd = f8
     2 med_disp_volume = f8
     2 med_disp_volume_unit_cd = f8
     2 legal_status_cd = f8
     2 formulary_status_cd = f8
     2 oe_format_flag = i2
     2 med_filter_ind = i2
     2 continuous_filter_ind = i2
     2 intermittent_filter_ind = i2
     2 divisible_ind = i2
     2 used_as_base_ind = i2
     2 always_dispense_from_flag = i2
     2 floorstock_ind = i2
     2 dispense_qty = f8
     2 dispense_factor = f8
     2 label_ratio = f8
     2 prn_reason_cd = f8
     2 infinite_div_ind = f8
     2 reusable_ind = i2
     2 base_pkg_type_id = f8
     2 base_pkg_qty = f8
     2 base_pkg_uom_cd = f8
     2 medidqual[*]
       3 identifier_id = f8
       3 identifier_type_cd = f8
       3 value = vc
       3 value_key = vc
       3 sequence = i4
     2 medproductqual[*]
       3 active_ind = i2
       3 med_product_id = f8
       3 manf_item_id = f8
       3 inner_pkg_type_id = f8
       3 inner_pkg_qty = f8
       3 inner_pkg_uom_cd = f8
       3 bio_equiv_ind = i2
       3 brand_ind = i2
       3 unit_dose_ind = i2
       3 manufacturer_cd = f8
       3 manufacturer_name = vc
       3 label_description = vc
       3 ndc = c13
       3 sequence = i2
       3 awp = f8
       3 awp_factor = f8
       3 formulary_status_cd = f8
       3 item_master_id = f8
       3 base_pkg_type_id = f8
       3 base_pkg_qty = f8
       3 base_pkg_uom_cd = f8
       3 medcostqual[*]
         4 cost_type_cd = f8
         4 cost = f8
     2 medingredqual[*]
       3 med_ingred_set_id = f8
       3 sequence = i2
       3 child_item_id = f8
       3 child_med_prod_id = f8
       3 child_pkg_type_id = f8
       3 base_ind = i2
       3 cmpd_qty = f8
       3 default_action_cd = f8
       3 cost1 = f8
       3 cost2 = f8
       3 awp = f8
       3 inc_in_total_ind = i2
     2 theraclassqual[*]
       3 alt_sel_category_id = f8
       3 ahfs_code = c6
     2 miscobjectqual[*]
       3 parent_entity_id = f8
       3 cdf_meaning = vc
     2 firstdoselocqual[*]
       3 location_cd = f8
     2 dispcat_flex_ind = i4
     2 pricesch_flex_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nnew_model_check = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE cdesc = f8 WITH protect, noconstant(0.0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE nmed = i2 WITH protect, constant(1)
 DECLARE ncont = i2 WITH protect, constant(2)
 DECLARE nint = i2 WITH protect, constant(3)
 DECLARE ditem_id = f8 WITH protect, noconstant(0.0)
 DECLARE ntier_level = i2 WITH protect, noconstant(0)
 DECLARE catalogitem = vc WITH protect, noconstant("")
 DECLARE i = i4 WITH protected, noconstant(0)
 DECLARE j = i4 WITH protected, noconstant(0)
 SET lstat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET lstat = uar_get_meaning_by_codeset(11000,"DESC",1,cdesc)
 DECLARE csyspack = f8 WITH protected, noconstant(0.0)
 DECLARE cfac = f8 WITH protected, noconstant(0.0)
 DECLARE cmeddisp = f8 WITH protected, noconstant(0.0)
 DECLARE n = i4 WITH protected, noconstant(0)
 DECLARE bonetrueproduct = i2 WITH protect, noconstant(0)
 RECORD tempitems(
   1 itemlist[*]
     2 item_id = f8
 )
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_name="NEW MODEL"
   AND dmp.person_id=0
   AND dmp.pref_section="FRMLRYMGMT"
  DETAIL
   IF (dmp.pref_nbr=1)
    nnew_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("new model:",nnew_model_check))
 SET reply->status_data.status = "F"
 SET nmultiformulary = 0
 SELECT INTO "nl:"
  dm.pref_nbr
  FROM dm_prefs dm
  WHERE dm.application_nbr=300000
   AND dm.pref_domain="PHARMNET"
   AND dm.person_id=0
   AND dm.pref_section="MULTI FORMULARY FLEX"
   AND dm.pref_name="ENABLE MULTI FORMULARY FLEX"
  DETAIL
   CALL echo("found pref"), nmultiformulary = dm.pref_nbr
  WITH nocounter
 ;end select
 CALL echo(build("multifacility:",nmultiformulary))
 IF ((request->facility_cd=0)
  AND nmultiformulary=1)
  SET nmultiformulary = 0
 ENDIF
 SET cdesc = 0.0
 SET cdf_meaning = fillstring(25," ")
 DECLARE dresult = f8
 DECLARE iresult = i4
 DECLARE count1 = i4
 DECLARE bfailedtofindany = i2
 SET dresult = 0.0
 SET iresult = 0
 SET code_value = 0.0
 SET code_set = 11000
 SET bfailedtofindany = 0
 SET count1 = 0
 SET bfailedtomatchdose = 0
 SET cactive = 0.0
 SET qty_check = 0
 SET uom_check = 0
 DECLARE nretry = i2 WITH protected, noconstant(0)
 CALL echo("Checking to see if dispense_qty exists on med_def",1)
 SELECT INTO "NL:"
  c.column_name
  FROM dba_tab_columns c
  WHERE c.table_name="MEDICATION_DEFINITION"
   AND c.column_name="DISPENSE_QTY"
   AND c.owner="V500"
  DETAIL
   qty_check = (qty_check+ 1)
  WITH check
 ;end select
 CALL echo(build("qty_check :",qty_check))
 CALL echo("Checking to see if dispense_qty_unit_cd exists on med_def",1)
 SELECT INTO "NL:"
  c.column_name
  FROM dba_tab_columns c
  WHERE c.table_name="MEDICATION_DEFINITION"
   AND c.column_name="DISPENSE_QTY_UNIT_CD"
   AND c.owner="V500"
  DETAIL
   uom_check = (uom_check+ 1)
  WITH check
 ;end select
 CALL echo(build("uom_check :",uom_check))
 DECLARE bskipformandroute = i2 WITH protected, noconstant(0)
 DECLARE creturn_products_by_all_tier_logic = i2 WITH private, constant(0)
 DECLARE creturn_products_by_tier_level_3 = i2 WITH private, constant(1)
 DECLARE creturn_products_by_tier_level_1 = i2 WITH private, constant(2)
 SET cdf_meaning = "DESC"
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value > 0)
  SET cdesc = code_value
 ELSE
  GO TO cv_lookup_failure
 ENDIF
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value <= 0.0)
  GO TO cv_lookup_failure
 ENDIF
 SET cactive = code_value
 IF ((((request->order_type < 1)) OR ((request->order_type > 3)))
  AND (request->med_filter_ind=0)
  AND (request->cont_filter_ind=0)
  AND (request->int_filter_ind=0))
  SET request->order_type = 4
 ENDIF
 IF ((request->order_type=nmed)
  AND (request->med_filter_ind=0))
  SET request->med_filter_ind = 1
 ELSEIF ((request->order_type=ncont)
  AND (request->cont_filter_ind=0))
  SET request->cont_filter_ind = 1
 ELSEIF ((request->order_type=nint)
  AND (request->int_filter_ind=0))
  SET request->int_filter_ind = 1
 ENDIF
 IF ((request->tier_level=4))
  SET request->tier_level = 0
  SET ntier_level = 4
 ENDIF
 CASE (request->tier_level)
  OF creturn_products_by_all_tier_logic:
   CALL echo("Normal product assignment logic...")
  OF creturn_products_by_tier_level_3:
   CALL echo("Returning products at the catalog, facility, and order type level...")
   SET bfailedtomatchdose = 1
   IF ((request->maintain_route_form_ind=0))
    SET bskipformandroute = 1
   ENDIF
  OF creturn_products_by_tier_level_1:
   CALL echo("Returning products at the catalog level...")
   SET bfailedtomatchdose = 1
   SET bfailedtofindany = 1
 ENDCASE
 SET reply->actual_tier_level = request->tier_level
 CALL echo(build("facility:",request->facility_cd))
 CALL echo(build("strength:",request->strength))
 CALL echo(build("strengthunit:",request->strength_unit))
 CALL echo(build("volume:",request->volume))
 CALL echo(build("volumeUnit:",request->volume_unit))
#retry
 CALL echo(build("tier level: ",request->tier_level))
 IF (nnew_model_check=0)
  CALL echo("Working with Old Model")
  SELECT
   IF ((((request->facility_cd IN (null, 0))) OR (nmultiformulary=0)) )
    FROM order_catalog_item_r ocir,
     medication_definition md,
     route_form_r rfr,
     package_type pt,
     object_identifier_index oii1,
     item_definition id,
     manufacturer_item mi
    PLAN (ocir
     WHERE (request->catalog_cd=ocir.catalog_cd))
     JOIN (md
     WHERE ocir.item_id=md.item_id
      AND (((((request->order_type=1)
      AND md.med_filter_ind > 0) OR ((((request->order_type=2)
      AND md.continuous_filter_ind > 0) OR ((((request->order_type=3)
      AND md.intermittent_filter_ind > 0) OR ((request->order_type=4))) )) ))
      AND ((bskipformandroute=1) OR ((((request->form_cd=md.form_cd)) OR ((request->form_cd=0))) )) )
      OR (bfailedtofindany=1)) )
     JOIN (id
     WHERE id.item_id=md.item_id
      AND id.active_ind > 0
      AND id.active_status_cd=cactive)
     JOIN (pt
     WHERE md.item_id=pt.item_id)
     JOIN (rfr
     WHERE md.form_cd=rfr.form_cd
      AND ((bskipformandroute=1) OR ((((request->route_cd=rfr.route_cd)) OR ((((request->route_cd=0))
      OR (bfailedtofindany=1)) )) )) )
     JOIN (oii1
     WHERE oii1.object_id=pt.item_id
      AND oii1.identifier_type_cd=cdesc
      AND oii1.generic_object=0
      AND oii1.active_ind=1
      AND oii1.active_status_cd=cactive
      AND ((oii1.primary_ind+ 0)=1))
     JOIN (mi
     WHERE mi.item_id=md.primary_manf_item_id)
   ELSE
    FROM order_catalog_item_r ocir,
     medication_definition md,
     route_form_r rfr,
     package_type pt,
     object_identifier_index oii1,
     med_def_loc_r mdlr,
     item_definition id,
     manufacturer_item mi
    PLAN (ocir
     WHERE (request->catalog_cd=ocir.catalog_cd))
     JOIN (md
     WHERE ocir.item_id=md.item_id
      AND (((((request->order_type=1)
      AND md.med_filter_ind > 0) OR ((((request->order_type=2)
      AND md.continuous_filter_ind > 0) OR ((((request->order_type=3)
      AND md.intermittent_filter_ind > 0) OR ((request->order_type=4))) )) ))
      AND ((bskipformandroute=1) OR ((((request->form_cd=md.form_cd)) OR ((request->form_cd=0))) )) )
      OR (bfailedtofindany=1)) )
     JOIN (id
     WHERE md.item_id=id.item_id
      AND id.active_ind > 0
      AND id.active_status_cd=cactive)
     JOIN (mdlr
     WHERE md.item_id=mdlr.med_def_item_id
      AND (((mdlr.location_cd=request->facility_cd)) OR (mdlr.location_cd=0)) )
     JOIN (pt
     WHERE md.item_id=pt.item_id)
     JOIN (rfr
     WHERE md.form_cd=rfr.form_cd
      AND ((bskipformandroute=1) OR ((((request->route_cd=rfr.route_cd)) OR ((((request->route_cd=0))
      OR (bfailedtofindany=1)) )) )) )
     JOIN (oii1
     WHERE oii1.object_id=pt.item_id
      AND oii1.identifier_type_cd=cdesc
      AND oii1.generic_object=0
      AND oii1.active_ind=1
      AND oii1.active_status_cd=cactive)
     JOIN (mi
     WHERE mi.item_id=md.primary_manf_item_id)
   ENDIF
   DISTINCT INTO "nl:"
   catalogitem = build(oii1.value,":",cnvtstring(md.item_id)), form = uar_get_code_display(md.form_cd
    )
   ORDER BY catalogitem, form
   HEAD catalogitem
    binclude = 0,
    CALL echo("**************************"),
    CALL echo("*****Possible product*****"),
    CALL echo(build("md.item_id :",md.item_id)),
    CALL echo(build("md.strength :",md.strength)),
    CALL echo(build("md.strengthunit :",md.strength_unit_cd)),
    CALL echo(build("md.volume :",md.volume)),
    CALL echo(build("md.volumeUnit :",md.volume_unit_cd)),
    CALL echo(build("description :",oii1.value)),
    CALL echo(build("med_filter_ind :",md.med_filter_ind)),
    CALL echo(build("continuous_filter_ind :",md.continuous_filter_ind)),
    CALL echo(build("intermittent_filter_ind :",md.intermittent_filter_ind)),
    CALL echo("**************************")
    IF (bfailedtomatchdose=1)
     binclude = 1,
     CALL echo("failed to match dose = 1")
    ELSE
     IF ((request->strength=0)
      AND (request->volume=0))
      CALL echo("req->strength and req->volume = 0"), binclude = 1
     ELSEIF ((request->strength > 0)
      AND (request->strength_unit > 0)
      AND (request->volume > 0)
      AND (request->volume_unit > 0))
      CALL echo("have both str and vol")
      IF ((request->strength=md.strength)
       AND (request->strength_unit=md.strength_unit_cd)
       AND (request->volume=md.volume)
       AND (request->volume_unit=md.volume_unit_cd))
       CALL echo("both str and vol match"), binclude = 1
      ENDIF
     ELSEIF ((request->strength > 0)
      AND (request->strength_unit > 0))
      CALL echo("have only strength")
      IF ((md.strength=request->strength)
       AND (md.strength_unit_cd=request->strength_unit))
       CALL echo("str matches"), binclude = 1
      ENDIF
     ELSEIF ((request->volume > 0)
      AND (request->volume_unit > 0))
      CALL echo("have only vol")
      IF ((request->volume=md.volume)
       AND (request->volume_unit=md.volume_unit_cd))
       CALL echo("vol matches"), binclude = 1
      ENDIF
     ENDIF
    ENDIF
    CALL echo(build("binclude::",binclude))
    IF (binclude=1)
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(reply->product,(count1+ 9))
     ENDIF
     reply->product[count1].item_id = ocir.item_id, reply->product[count1].item_id = md.item_id,
     reply->product[count1].disp_qty = pt.qty,
     reply->product[count1].disp_qty_cd = pt.uom_cd, reply->product[count1].product_info = concat(
      trim(md.given_strength)," ",trim(form)), reply->product[count1].identifier_type_cd = oii1
     .identifier_type_cd
     IF (oii1.identifier_type_cd=cdesc)
      reply->product[count1].description = oii1.value
     ENDIF
     reply->product[count1].strength = md.strength, reply->product[count1].strength_unit_cd = md
     .strength_unit_cd, reply->product[count1].volume = md.volume,
     reply->product[count1].volume_unit_cd = md.volume_unit_cd, reply->product[count1].form_cd = md
     .form_cd, reply->product[count1].divisible_ind = md.divisible_ind,
     reply->product[count1].route_cd = rfr.route_cd, reply->product[count1].dispense_category_cd = md
     .dispense_category_cd, reply->product[count1].price_sched_id = md.price_sched_id,
     reply->product[count1].base_factor = id.base_issue_factor, reply->product[count1].
     formulary_status_cd = md.formulary_status_cd, reply->product[count1].order_alert1_cd = md
     .order_alert1_cd,
     reply->product[count1].order_alert2_cd = md.order_alert2_cd
     IF ((reply->product[count1].item_id=ditem_id))
      reply->product[count1].true_product = 1
     ENDIF
     CALL echo(build("description :",oii1.value)),
     CALL echo(build("med_filter_ind :",md.med_filter_ind)),
     CALL echo(build("continuous_filter_ind :",md.continuous_filter_ind)),
     CALL echo(build("intermittent_filter_ind :",md.intermittent_filter_ind)),
     CALL echo("=====================")
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->product,count1)
    IF (nretry=0
     AND count1=1)
     reply->product[1].true_product = 1,
     CALL echo("Found one true product match...")
    ELSE
     CALL echo("NO one true product match found...")
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("count1 :",count1))
  CALL echo(build("nRetry :",nretry))
  CALL echo(build("bFailedToMatchDose :",bfailedtomatchdose))
  CALL echo(build("bFailedToFindAny :",bfailedtofindany))
  IF (ntier_level=4
   AND count1=1)
   SET ditem_id = reply->product[1].item_id
   CALL echo(build("dItem_id: ",ditem_id))
   SET count1 = 0
   SET stat = alterlist(reply->product,count1)
   SET ntier_level = 0
   SET bfailedtomatchdose = 1
   SET bskipformandroute = 1
   SET request->tier_level = 1
   SET nretry = (nretry+ 1)
   GO TO retry
  ELSEIF (((count1 > 1
   AND nretry=0) OR (bfailedtomatchdose=0
   AND count1=0)) )
   SET bfailedtomatchdose = 1
   SET bskipformandroute = 1
   SET reply->actual_tier_level = creturn_products_by_tier_level_1
   IF (count1 > 1)
    CALL echo("=====================")
    CALL echo("too many matches")
    CALL echo("=====================")
   ELSE
    CALL echo("=====================")
    CALL echo("failed to match dose and count =0")
    CALL echo("=====================")
   ENDIF
   SET count1 = 0
   SET stat = alterlist(reply->product,count1)
   SET nretry = (nretry+ 1)
   GO TO retry
  ENDIF
  IF (qty_check > 0
   AND uom_check > 0)
   IF (size(reply->product,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(reply->product,5))),
      medication_definition md
     PLAN (d1)
      JOIN (md
      WHERE (md.item_id=reply->product[d1.seq].item_id))
     DETAIL
      reply->product[d1.seq].disp_qty = md.dispense_qty, reply->product[d1.seq].disp_qty_cd = md
      .dispense_qty_unit_cd
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ELSE
  CALL echo("Working with New Model")
  SET stat = uar_get_meaning_by_codeset(4062,"SYSPKGTYP",1,csyspack)
  SET stat = uar_get_meaning_by_codeset(4063,"ORDERABLE",1,cfac)
  SET stat = uar_get_meaning_by_codeset(4063,"DISPENSE",1,cmeddisp)
  CALL echo(build("bSkipFormAndRoute: ",bskipformandroute))
  CALL echo(build("bFailedToFindAny: ",bfailedtofindany))
  CALL echo(build("nMultiFormulary: ",nmultiformulary))
  SELECT INTO "nl:"
   form = uar_get_code_display(md.form_cd)
   FROM order_catalog_item_r ocir,
    medication_definition md,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_flex_object_idx mfoi2,
    med_dispense mdsp,
    route_form_r rfr,
    item_definition id
   PLAN (ocir
    WHERE (request->catalog_cd=ocir.catalog_cd))
    JOIN (md
    WHERE ocir.item_id=md.item_id
     AND ((((bskipformandroute=1) OR ((((request->form_cd=md.form_cd)) OR ((request->form_cd=0))) ))
    ) OR (bfailedtofindany=1)) )
    JOIN (mdf
    WHERE md.item_id=mdf.item_id
     AND mdf.pharmacy_type_cd=cinpatient
     AND mdf.flex_type_cd=csyspack)
    JOIN (mfoi2
    WHERE ((nmultiformulary=0
     AND mfoi2.med_flex_object_id=0) OR (nmultiformulary=1
     AND mfoi2.med_def_flex_id=mdf.med_def_flex_id
     AND ((mfoi2.flex_object_type_cd+ 0)=cfac)
     AND ((mfoi2.parent_entity_id+ 0) IN (0, request->facility_cd))
     AND mfoi2.active_ind=1)) )
    JOIN (mfoi
    WHERE mdf.med_def_flex_id=mfoi.med_def_flex_id
     AND mfoi.flex_object_type_cd=cmeddisp
     AND ((mfoi.sequence+ 0)=1))
    JOIN (mdsp
    WHERE mfoi.parent_entity_id=mdsp.med_dispense_id
     AND (((((request->med_filter_ind=1)
     AND mdsp.med_filter_ind > 0) OR ((((request->cont_filter_ind=1)
     AND mdsp.continuous_filter_ind > 0) OR ((((request->int_filter_ind=1)
     AND mdsp.intermittent_filter_ind > 0) OR ((request->order_type=4))) )) )) ) OR (bfailedtofindany
    =1)) )
    JOIN (id
    WHERE md.item_id=id.item_id
     AND ((id.active_ind+ 0) > 0)
     AND ((id.active_status_cd+ 0)=cactive))
    JOIN (rfr
    WHERE md.form_cd=rfr.form_cd
     AND (((request->route_cd=rfr.route_cd)) OR (((bskipformandroute=1) OR ((((request->route_cd=0))
     OR (bfailedtofindany=1)) )) )) )
   ORDER BY md.item_id
   HEAD md.item_id
    binclude = 0,
    CALL echo("**************************"),
    CALL echo("*****Possible product*****"),
    CALL echo(build("md.item_id :",md.item_id)),
    CALL echo(build("mdsp.strength :",mdsp.strength)),
    CALL echo(build("mdsp.strengthunit :",mdsp.strength_unit_cd)),
    CALL echo(build("mdsp.volume :",mdsp.volume)),
    CALL echo(build("mdsp.volumeUnit :",mdsp.volume_unit_cd)),
    CALL echo(build("med_filter_ind :",mdsp.med_filter_ind)),
    CALL echo(build("continuous_filter_ind :",mdsp.continuous_filter_ind)),
    CALL echo(build("intermittent_filter_ind :",mdsp.intermittent_filter_ind)),
    CALL echo("**************************")
    IF (bfailedtomatchdose=1)
     binclude = 1,
     CALL echo("failed to match dose = 1")
    ELSE
     IF ((request->strength=0)
      AND (request->volume=0))
      CALL echo("req->strength and req->volume = 0"), binclude = 1
     ELSEIF ((request->strength > 0)
      AND (request->strength_unit > 0)
      AND (request->volume > 0)
      AND (request->volume_unit > 0))
      CALL echo("have both str and vol")
      IF ((request->strength=mdsp.strength)
       AND (request->strength_unit=mdsp.strength_unit_cd)
       AND (request->volume=mdsp.volume)
       AND (request->volume_unit=mdsp.volume_unit_cd))
       CALL echo("both str and vol match"), binclude = 1
      ENDIF
     ELSEIF ((request->strength > 0)
      AND (request->strength_unit > 0))
      CALL echo("have only strength")
      IF ((mdsp.strength=request->strength)
       AND (mdsp.strength_unit_cd=request->strength_unit))
       CALL echo("str matches"), binclude = 1
      ENDIF
     ELSEIF ((request->volume > 0)
      AND (request->volume_unit > 0))
      CALL echo("have only vol")
      IF ((request->volume=mdsp.volume)
       AND (request->volume_unit=mdsp.volume_unit_cd))
       CALL echo("vol matches"), binclude = 1
      ENDIF
     ENDIF
    ENDIF
    CALL echo(build("binclude::",binclude))
    IF (binclude=1)
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(tempitems->itemlist,(count1+ 9))
     ENDIF
     tempitems->itemlist[count1].item_id = md.item_id,
     CALL echo(build("med_filter_ind :",md.med_filter_ind)),
     CALL echo(build("continuous_filter_ind :",md.continuous_filter_ind)),
     CALL echo(build("intermittent_filter_ind :",md.intermittent_filter_ind)),
     CALL echo("=====================")
    ENDIF
   FOOT REPORT
    stat = alterlist(tempitems->itemlist,count1)
    IF (nretry=0
     AND count1=1)
     bonetrueproduct = 1,
     CALL echo("Found one true product match...")
    ELSE
     CALL echo("NO one true product match found...")
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("Count after ocir join: ",count1))
  IF (ntier_level=4
   AND count1=1)
   SET ditem_id = tempitems->itemlist[1].item_id
   CALL echo(build("dItem_id: ",ditem_id))
   SET count1 = 0
   SET stat = alterlist(tempitems->itemlist,count1)
   SET ntier_level = 0
   SET bfailedtomatchdose = 1
   SET bskipformandroute = 1
   SET request->tier_level = 1
   SET nretry = (nretry+ 1)
   GO TO retry
  ELSEIF (((count1 > 1
   AND nretry=0) OR (bfailedtomatchdose=0
   AND count1=0)) )
   SET bfailedtomatchdose = 1
   SET bskipformandroute = 1
   SET reply->actual_tier_level = creturn_products_by_tier_level_1
   IF (count1 > 1)
    CALL echo("=====================")
    CALL echo("too many matches")
    CALL echo("=====================")
   ELSE
    CALL echo("=====================")
    CALL echo("2 failed to match dose and count =0")
    CALL echo("=====================")
   ENDIF
   SET count1 = 0
   IF ((request->tier_level != creturn_products_by_tier_level_3))
    SET stat = alterlist(tempitems->itemlist,count1)
    SET nretry = (nretry+ 1)
    GO TO retry
   ENDIF
  ENDIF
  IF (size(tempitems->itemlist,5) > 0)
   SET stat = alterlist(info_request->itemlist,value(size(tempitems->itemlist,5)))
   FOR (i = 1 TO value(size(tempitems->itemlist,5)))
     SET info_request->itemlist[i].item_id = tempitems->itemlist[i].item_id
   ENDFOR
   SET info_request->med_dispense_ind = 1
   SET info_request->med_identifier_ind = 1
   SET info_request->med_oe_default_ind = 1
   SET info_request->med_def_ind = 1
   SET info_request->misc_object_ind = 1
   SET info_request->med_pha_flex_ind = 1
   SET info_request->med_child_ind = 0
   SET info_request->pharm_type_cd = cinpatient
   SET info_request->pat_loc_cd = request->pat_loc_cd
   SET info_request->encounter_type_cd = request->encounter_type_cd
   SET info_request->facility_cd = request->facility_cd
   CALL echorecord(info_request)
   EXECUTE rxa_get_item_info  WITH replace("REQUEST","INFO_REQUEST"), replace("REPLY","INFO_REPLY")
   CALL echorecord(info_reply)
   SET ncount1 = value(size(info_reply->itemlist,5))
   SET lcnt = 0
   FOR (j = 1 TO ncount1)
     IF ((info_reply->itemlist[j].catalog_cd > 0))
      SET lcnt = (lcnt+ 1)
      SET stat = alterlist(reply->product,lcnt)
      SET reply->product[lcnt].item_id = info_reply->itemlist[j].item_id
      FOR (i = 1 TO value(size(info_reply->itemlist[j].medidqual,5)))
        IF ((info_reply->itemlist[j].medidqual[i].identifier_type_cd=cdesc))
         SET reply->product[lcnt].description = info_reply->itemlist[j].medidqual[i].value
         SET reply->product[lcnt].identifier_type_cd = info_reply->itemlist[j].medidqual[i].
         identifier_type_cd
        ENDIF
      ENDFOR
      SET reply->product[lcnt].product_info = concat(trim(info_reply->itemlist[j].given_strength)," ",
       uar_get_code_display(info_reply->itemlist[j].form_cd))
      SET reply->product[lcnt].route_cd = info_reply->itemlist[j].route_cd
      SET reply->product[lcnt].form_cd = info_reply->itemlist[j].form_cd
      SET reply->product[lcnt].divisible_ind = info_reply->itemlist[j].divisible_ind
      SET reply->product[lcnt].base_factor = info_reply->itemlist[j].base_issue_factor
      SET reply->product[lcnt].disp_qty = info_reply->itemlist[j].pkg_qty
      SET reply->product[lcnt].disp_qty_cd = info_reply->itemlist[j].pkg_qty_cd
      SET reply->product[lcnt].strength = info_reply->itemlist[j].med_disp_strength
      SET reply->product[lcnt].strength_unit_cd = info_reply->itemlist[j].med_disp_strength_unit_cd
      SET reply->product[lcnt].volume = info_reply->itemlist[j].med_disp_volume
      SET reply->product[lcnt].volume_unit_cd = info_reply->itemlist[j].med_disp_volume_unit_cd
      SET reply->product[lcnt].dispense_category_cd = info_reply->itemlist[j].dispense_category_cd
      SET reply->product[lcnt].formulary_status_cd = info_reply->itemlist[j].formulary_status_cd
      IF ((reply->product[lcnt].item_id=ditem_id))
       SET reply->product[lcnt].true_product = bonetrueproduct
      ENDIF
      SET reply->product[lcnt].dispense_factor = info_reply->itemlist[j].dispense_factor
      SET reply->product[lcnt].infinite_div_ind = info_reply->itemlist[j].infinite_div_ind
      SET reply->product[lcnt].med_filter_ind = info_reply->itemlist[j].med_filter_ind
      SET reply->product[lcnt].cont_filter_ind = info_reply->itemlist[j].continuous_filter_ind
      SET reply->product[lcnt].int_filter_ind = info_reply->itemlist[j].intermittent_filter_ind
      SET n = 0
      FOR (i = 1 TO value(size(info_reply->itemlist[j].miscobjectqual,5)))
        IF ((info_reply->itemlist[j].miscobjectqual[i].cdf_meaning="ORDERALERT"))
         SET n = (n+ 1)
         SET stat = alterlist(reply->product[lcnt].alert_qual,n)
         SET reply->product[lcnt].alert_qual[n].order_alert_cd = info_reply->itemlist[j].
         miscobjectqual[i].parent_entity_id
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  FREE RECORD tempitems
  FREE RECORD info_reply
  FREE RECORD info_request
 ENDIF
 IF (value(size(reply->product,5)) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#cv_lookup_failure
END GO
