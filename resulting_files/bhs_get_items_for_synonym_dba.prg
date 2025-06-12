CREATE PROGRAM bhs_get_items_for_synonym:dba
 SET modify = predeclare
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
 RECORD temp_items(
   1 synlist[*]
     2 synonym_id = f8
     2 item_cnt = i2
     2 itemlist[*]
       3 item_id = f8
 )
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 ) WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 DECLARE cdesc = f8 WITH protect, noconstant(0.0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE csyspack = f8 WITH protect, noconstant(0.0)
 DECLARE cfac = f8 WITH protect, noconstant(0.0)
 DECLARE cmeddisp = f8 WITH protect, noconstant(0.0)
 DECLARE cactive = f8 WITH protect, noconstant(0.0)
 DECLARE nmultiformulary = i2 WITH protect, noconstant(0)
 DECLARE nsizeofsynlist = i2 WITH protect, noconstant(0)
 DECLARE synreqcnt = i2 WITH protect, noconstant(0)
 DECLARE syncount = i2 WITH protect, noconstant(0)
 DECLARE itemcount = i2 WITH protect, noconstant(0)
 DECLARE ncnt = i2 WITH private, noconstant(0)
 DECLARE i = i2 WITH private, noconstant(0)
 DECLARE j = i2 WITH private, noconstant(0)
 DECLARE nstat = i2 WITH private, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET nstat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET nstat = uar_get_meaning_by_codeset(11000,"DESC",1,cdesc)
 SET nstat = uar_get_meaning_by_codeset(4062,"SYSPKGTYP",1,csyspack)
 SET nstat = uar_get_meaning_by_codeset(4063,"ORDERABLE",1,cfac)
 SET nstat = uar_get_meaning_by_codeset(4063,"DISPENSE",1,cmeddisp)
 SET nstat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 CALL echo("-")
 CALL echo("<----- BEGIN rx_get_items_for_synonym ----->")
 CALL echo("-")
 SELECT INTO "NL:"
  dm.pref_nbr
  FROM dm_prefs dm
  WHERE dm.application_nbr=300000
   AND dm.pref_domain="PHARMNET"
   AND dm.person_id=0
   AND dm.pref_section="MULTI FORMULARY FLEX"
   AND dm.pref_name="ENABLE MULTI FORMULARY FLEX"
  DETAIL
   nmultiformulary = dm.pref_nbr
  WITH nocounter
 ;end select
 CALL echo(build("MultiFacility Pref:",nmultiformulary))
 CALL echo("******************************")
 CALL echo("Retrieving items for each synonym...")
 CALL echo("******************************")
 SET nsizeofsynlist = size(request->synonym_list,5)
 SELECT
  IF ((request->return_all_ind=1))
   FROM (dummyt d  WITH seq = value(nsizeofsynlist)),
    synonym_item_r sir,
    medication_definition md,
    item_definition id
   PLAN (d)
    JOIN (sir
    WHERE (request->synonym_list[d.seq].synonym_id=sir.synonym_id))
    JOIN (md
    WHERE sir.item_id=md.item_id)
    JOIN (id
    WHERE md.item_id=id.item_id
     AND id.active_ind > 0
     AND id.active_status_cd=cactive)
  ELSE
   FROM (dummyt d  WITH seq = value(nsizeofsynlist)),
    synonym_item_r sir,
    medication_definition md,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_flex_object_idx mfoi2,
    med_dispense mdsp,
    route_form_r rfr,
    item_definition id
   PLAN (d)
    JOIN (sir
    WHERE (request->synonym_list[d.seq].synonym_id=sir.synonym_id))
    JOIN (md
    WHERE sir.item_id=md.item_id
     AND (((request->synonym_list[d.seq].form_cd=md.form_cd)) OR ((request->synonym_list[d.seq].
    form_cd=0))) )
    JOIN (mdf
    WHERE md.item_id=mdf.item_id
     AND ((mdf.pharmacy_type_cd+ 0)=cinpatient)
     AND ((mdf.flex_type_cd+ 0)=csyspack))
    JOIN (mfoi2
    WHERE ((nmultiformulary=0
     AND mfoi2.med_flex_object_id=0) OR (nmultiformulary=1
     AND mfoi2.med_def_flex_id=mdf.med_def_flex_id
     AND ((mfoi2.flex_object_type_cd+ 0)=cfac)
     AND ((mfoi2.parent_entity_id+ 0) IN (0, request->synonym_list[d.seq].facility_cd))
     AND mfoi2.active_ind=1)) )
    JOIN (mfoi
    WHERE mdf.med_def_flex_id=mfoi.med_def_flex_id
     AND ((mfoi.flex_object_type_cd+ 0)=cmeddisp)
     AND ((mfoi.sequence+ 0)=1))
    JOIN (mdsp
    WHERE mfoi.parent_entity_id=mdsp.med_dispense_id
     AND (((request->synonym_list[d.seq].med_filter_ind=1)
     AND mdsp.med_filter_ind > 0) OR ((((request->synonym_list[d.seq].cont_filter_ind=1)
     AND mdsp.continuous_filter_ind > 0) OR ((request->synonym_list[d.seq].int_filter_ind=1)
     AND mdsp.intermittent_filter_ind > 0)) )) )
    JOIN (id
    WHERE md.item_id=id.item_id
     AND ((id.active_ind+ 0) > 0)
     AND ((id.active_status_cd+ 0)=cactive))
    JOIN (rfr
    WHERE md.form_cd=rfr.form_cd
     AND (((request->synonym_list[d.seq].route_cd=rfr.route_cd)) OR ((request->synonym_list[d.seq].
    route_cd=0))) )
  ENDIF
  INTO "nl:"
  ORDER BY sir.synonym_id
  HEAD REPORT
   syncount = 0, itemcount = 0
  HEAD sir.synonym_id
   syncount = (syncount+ 1)
   IF (mod(syncount,10)=1)
    nstat = alterlist(temp_items->synlist,(syncount+ 9))
   ENDIF
   temp_items->synlist[syncount].synonym_id = sir.synonym_id, itemcount = 0
  HEAD md.item_id
   itemcount = (itemcount+ 1)
   IF (mod(itemcount,10)=1)
    nstat = alterlist(temp_items->synlist[syncount].itemlist,(itemcount+ 9))
   ENDIF
   temp_items->synlist[syncount].itemlist[itemcount].item_id = md.item_id, temp_items->synlist[
   syncount].item_cnt = itemcount
  FOOT REPORT
   nstat = alterlist(temp_items->synlist,syncount)
   FOR (ncnt = 1 TO syncount)
     nstat = alterlist(temp_items->synlist[ncnt].itemlist,temp_items->synlist[ncnt].item_cnt)
   ENDFOR
  WITH nocounter
 ;end select
 IF (syncount > 0)
  CALL echo("******************************")
  CALL echo("Retrieving detailed info for each item...")
  CALL echo("******************************")
  CALL echo(build("SynonymId with Items : ",syncount))
  SET nstat = alterlist(reply->synonym_list,syncount)
  FOR (synreqcnt = 1 TO syncount)
    SET reply->synonym_list[synreqcnt].synonym_id = temp_items->synlist[synreqcnt].synonym_id
    SET nstat = alterlist(info_request->itemlist,value(size(temp_items->synlist[synreqcnt].itemlist,5
       )))
    FOR (i = 1 TO value(size(temp_items->synlist[synreqcnt].itemlist,5)))
      SET info_request->itemlist[i].item_id = temp_items->synlist[synreqcnt].itemlist[i].item_id
    ENDFOR
    SET info_request->med_identifier_ind = 1
    SET info_request->med_child_ind = 0
    SET info_request->med_def_ind = 1
    IF ((request->return_all_ind=1))
     SET info_request->med_dispense_ind = 0
     SET info_request->med_oe_default_ind = 0
     SET info_request->misc_object_ind = 0
     SET info_request->med_pha_flex_ind = 0
    ELSE
     SET info_request->med_dispense_ind = 1
     SET info_request->med_oe_default_ind = 1
     SET info_request->misc_object_ind = 1
     SET info_request->med_pha_flex_ind = 1
    ENDIF
    IF ((request->pharm_type_cd > 0))
     SET info_request->pharm_type_cd = request->pharm_type_cd
    ELSE
     SET info_request->pharm_type_cd = cinpatient
    ENDIF
    SET info_request->pat_loc_cd = request->synonym_list[synreqcnt].pat_loc_cd
    SET info_request->encounter_type_cd = request->synonym_list[synreqcnt].encounter_type_cd
    SET info_request->facility_cd = request->synonym_list[synreqcnt].facility_cd
    SET modify = nopredeclare
    EXECUTE rxa_get_item_info  WITH replace("REQUEST","INFO_REQUEST"), replace("REPLY","INFO_REPLY")
    SET modify = predeclare
    SET itemcount = value(size(info_reply->itemlist,5))
    SET nstat = alterlist(reply->synonym_list[synreqcnt].product,itemcount)
    SET ncnt = 0
    FOR (j = 1 TO itemcount)
      IF ((info_reply->itemlist[j].catalog_cd > 0))
       SET ncnt = (ncnt+ 1)
       SET reply->synonym_list[synreqcnt].product[ncnt].item_id = info_reply->itemlist[j].item_id
       FOR (i = 1 TO value(size(info_reply->itemlist[j].medidqual,5)))
         IF ((info_reply->itemlist[j].medidqual[i].identifier_type_cd=cdesc))
          SET reply->synonym_list[synreqcnt].product[ncnt].description = info_reply->itemlist[j].
          medidqual[i].value
          SET i = value(size(info_reply->itemlist[j].medidqual,5))
         ENDIF
       ENDFOR
       SET reply->synonym_list[synreqcnt].product[ncnt].product_info = concat(trim(info_reply->
         itemlist[j].given_strength)," ",uar_get_code_display(info_reply->itemlist[j].form_cd))
       SET reply->synonym_list[synreqcnt].product[ncnt].route_cd = info_reply->itemlist[j].route_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].form_cd = info_reply->itemlist[j].form_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].divisible_ind = info_reply->itemlist[j].
       divisible_ind
       SET reply->synonym_list[synreqcnt].product[ncnt].base_factor = info_reply->itemlist[j].
       base_issue_factor
       SET reply->synonym_list[synreqcnt].product[ncnt].disp_qty = info_reply->itemlist[j].pkg_qty
       SET reply->synonym_list[synreqcnt].product[ncnt].disp_qty_cd = info_reply->itemlist[j].
       pkg_qty_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].strength = info_reply->itemlist[j].
       med_disp_strength
       SET reply->synonym_list[synreqcnt].product[ncnt].strength_unit_cd = info_reply->itemlist[j].
       med_disp_strength_unit_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].volume = info_reply->itemlist[j].
       med_disp_volume
       SET reply->synonym_list[synreqcnt].product[ncnt].volume_unit_cd = info_reply->itemlist[j].
       med_disp_volume_unit_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].dispense_category_cd = info_reply->itemlist[j
       ].dispense_category_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].formulary_status_cd = info_reply->itemlist[j]
       .formulary_status_cd
       SET reply->synonym_list[synreqcnt].product[ncnt].dispense_factor = info_reply->itemlist[j].
       dispense_factor
       SET reply->synonym_list[synreqcnt].product[ncnt].infinite_div_ind = info_reply->itemlist[j].
       infinite_div_ind
       SET reply->synonym_list[synreqcnt].product[ncnt].med_filter_ind = info_reply->itemlist[j].
       med_filter_ind
       SET reply->synonym_list[synreqcnt].product[ncnt].int_filter_ind = info_reply->itemlist[j].
       intermittent_filter_ind
       SET reply->synonym_list[synreqcnt].product[ncnt].cont_filter_ind = info_reply->itemlist[j].
       continuous_filter_ind
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 CALL echo("******************************")
 CALL echo("Checking for errors...")
 CALL echo("******************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 5)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET nstat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET nstat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  CALL echorecord(errors)
 ENDIF
 IF (errcnt > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SYNONYM_ITEM_R"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSEIF ((info_reply->status_data.status="F"))
  SET reply->status_data.status = info_reply->status_data.status
  SET reply->status_data.subeventstatus[1].operationname = "RXA_GET_ITEM_INFO"
  SET reply->status_data.subeventstatus[1].targetobjectname = info_reply->status_data.subeventstatus[
  1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = info_reply->status_data.
  subeventstatus[1].targetobjectvalue
  SET reply->status_data.subeventstatus[1].operationstatus = info_reply->status_data.subeventstatus[1
  ].operationstatus
 ELSEIF (((size(reply->synonym_list,5)=0) OR (syncount=0)) )
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SYNONYM_ITEM_R"
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSEIF ((info_reply->status_data.status="Z"))
  IF (value(size(info_reply->itemlist,5)) > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = info_reply->status_data.status
   SET reply->status_data.subeventstatus[1].operationname = "RXA_GET_ITEM_INFO"
   SET reply->status_data.subeventstatus[1].targetobjectname = info_reply->status_data.
   subeventstatus[1].targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = info_reply->status_data.
   subeventstatus[1].targetobjectvalue
   SET reply->status_data.subeventstatus[1].operationstatus = info_reply->status_data.subeventstatus[
   1].operationstatus
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD temp_items
 FREE RECORD info_reply
 FREE RECORD info_request
 FREE RECORD errors
 SET mod_date = "March 05, 2005"
 SET last_mod = "003"
 CALL echo("-")
 CALL echo("<----- END rx_get_items_for_synonym ----->")
 CALL echo("-")
END GO
