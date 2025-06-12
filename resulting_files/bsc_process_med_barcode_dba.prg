CREATE PROGRAM bsc_process_med_barcode:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 item_id = f8
     2 synonym_id = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 form_cd = f8
     2 event_cd = f8
     2 oe_format_flag = i2
     2 med_type_flag = i4
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 route_qual[*]
       3 route_cd = f8
     2 medproductqual[*]
       3 manf_item_id = f8
       3 label_description = vc
       3 manufacturer_cd = f8
       3 active_ind = i2
     2 synonym_qual[*]
       3 synonym_id = f8
     2 identification_ind = i2
     2 expiration_ind = i2
     2 ingred_qual[*]
       3 item_id = f8
       3 synonym_id = f8
       3 catalog_cd = f8
       3 event_cd = f8
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 synonym_qual[*]
         4 synonym_id = f8
       3 waste_charge_ind = i2
     2 barcode = vc
     2 barcode_source_cd = f8
     2 med_product_id = f8
     2 exp_date = dq8
     2 exp_date_tz = i4
     2 lot_number = vc
     2 compatable_form_qual[*]
       3 form_cd = f8
     2 inv_master_id = f8
     2 recalled_ind = i2
     2 waste_charge_ind = i2
     2 drug_ident = vc
   1 execution_notes[*]
     2 note = vc
   1 active_order_found_ind = i2
   1 inactive_order_found_ind = i2
   1 found_order_id = f8
   1 multi_found_ind = i2
   1 found_order_status = f8
   1 synonym_mismatch_id = f8
   1 mismatch_order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD barcode
 RECORD barcode(
   1 format[*]
     2 barcode_type_cd = f8
     2 prefix = vc
     2 z_data = vc
 )
 FREE RECORD items
 RECORD items(
   1 qual[*]
     2 item_id = f8
     2 barcode = vc
     2 med_product_id = f8
     2 inv_master_id = f8
 )
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 catalog_cd = f8
     2 item_id = f8
     2 synonym_id = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 form_cd = f8
     2 premix_ind = i2
     2 oe_format_flag = i2
     2 med_type_flag = i4
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 route_qual[*]
       3 route_cd = f8
     2 medproductqual[*]
       3 active_ind = i2
       3 manf_item_id = f8
       3 label_description = vc
       3 manufacturer_cd = f8
     2 synonym_qual[*]
       3 synonym_id = f8
     2 identification_ind = i2
     2 ingred_qual[*]
       3 item_id = f8
       3 synonym_id = f8
       3 catalog_cd = f8
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 synonym_qual[*]
         4 synonym_id = f8
       3 waste_charge_ind = i2
     2 barcode = vc
     2 med_product_id = f8
     2 inv_master_id = f8
     2 waste_charge_ind = i2
     2 drug_ident = vc
 )
 FREE RECORD parse_request
 RECORD parse_request(
   1 barcode = vc
   1 location_cd = f8
   1 debug_ind = i2
   1 processpreferreditems_ind = i2
   1 audit_solution_cd = f8
 )
 FREE RECORD processing_rules
 RECORD processing_rules(
   1 lot_number = vc
   1 exp_date = dq8
   1 exp_date_tz = i4
   1 expiration_ind = i2
   1 facility_cd = f8
   1 qual[*]
     2 search_string = vc
     2 ident_qual_cnt = i4
     2 ident_qual[*]
       3 identifier_type_cd = f8
       3 identifier_extraction_type = i2
     2 barcode_extraction_type = i2
   1 prefs
     2 bnewmodelchk = i2
     2 use_mltm_syn_match = i4
     2 scanning_lookup_level = i4
   1 execution_notes[*]
     2 note = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_ingred_inds
 RECORD temp_ingred_inds(
   1 array[*]
     2 ingred_found_ind = i2
 )
 DECLARE preferredtype = i2 WITH protect, constant(1)
 DECLARE gs1type = i2 WITH protect, constant(2)
 DECLARE gs1alttype = i2 WITH protect, constant(4)
 DECLARE ndctype = i2 WITH protect, constant(8)
 DECLARE ndcalttype = i2 WITH protect, constant(16)
 DECLARE mckessontype = i2 WITH protect, constant(32)
 DECLARE omnicelltype = i2 WITH protect, constant(64)
 DECLARE pocruletype = i2 WITH protect, constant(128)
 DECLARE rawtype = i2 WITH protect, constant(256)
 DECLARE prefixtype = i2 WITH protect, constant(512)
 DECLARE start_time = f8 WITH private, noconstant(curtime3)
 DECLARE elapsed_time = f8 WITH private, noconstant(0.0)
 DECLARE ntype = i2 WITH protect, noconstant(0)
 DECLARE nndc = i2 WITH protect, constant(1)
 DECLARE nidentifier = i2 WITH protect, constant(2)
 DECLARE nmckesson = i2 WITH protect, constant(3)
 DECLARE ncompound_med_type = i2 WITH protect, constant(2)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE sndcreturned = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE cfacility = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE cactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cmed_def = f8 WITH protect, constant(uar_get_code_by("MEANING",11001,"MED_DEF"))
 DECLARE multum_source_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002358,"MULTUM"))
 DECLARE csyspack_flex = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE cfacility_flex = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voided_wrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE medstudent_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE pending_rev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE unscheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE every_bag_cd = f8 WITH constant(uar_get_code_by("MEANING",4004,"EVERYBAG"))
 DECLARE recalled = f8 WITH constant(uar_get_code_by("MEANING",48,"RECALL"))
 DECLARE iv_med_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE rx_mnem_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE diluent_flag = i2 WITH constant(2)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE debug_ind = i2 WITH protect, noconstant(validate(request->debug_ind,0))
 DECLARE order_info_ind = i2 WITH protect, noconstant(validate(request->order_info_ind,0))
 DECLARE parse_info_ind = i2 WITH protect, noconstant(validate(request->use_parse_info,0))
 DECLARE code_set_value = i4 WITH public, constant(4003329)
 DECLARE expiration_ind = i2 WITH protect, noconstant(0)
 DECLARE exp_date = dq8 WITH protect, noconstant(0)
 DECLARE exp_date_tz = i4 WITH protect, noconstant(0)
 DECLARE lot_number = vc WITH protect, noconstant("")
 DECLARE dfacilitycd = f8 WITH protect, noconstant(0.0)
 DECLARE bnewmodelchk = i2 WITH protect, noconstant(0)
 DECLARE lchk14gs1 = i2 WITH protect, noconstant(0)
 DECLARE busemltmsynmatch = i4 WITH protect, noconstant(0)
 DECLARE barcode_source_cd = f8 WITH protect, noconstant(0)
 DECLARE itypecombine = i4 WITH protect, noconstant(0)
 DECLARE indexx = i4 WITH protect, noconstant(0)
 DECLARE indexy = i4 WITH protect, noconstant(0)
 SUBROUTINE (finditembyidentifiergeneric(sidentifierin=vc,didentifiertypecd=f8,lsrchidx=i4,
  ibarcodeextractiontypes=i2,iexcludetype=i2) =null)
   CALL echo(
    "bsc_process_med_generic.inc - ****** Entering FindItemByIdentifierGeneric Subroutine ******")
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   DECLARE lreplycnt = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lrtecnt = i4 WITH protect, noconstant(0)
   DECLARE dstatus = i2 WITH private, noconstant(0)
   DECLARE iexistingcnt = i4 WITH private, noconstant(0)
   DECLARE inewcnt = i4 WITH private, noconstant(0)
   DECLARE lidentcnt = i4 WITH private, noconstant(0)
   DECLARE formulary_source_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002358,
     "RXFORMULARY"))
   IF (debug_ind > 0)
    CALL echo(build("bsc_process_med_generic.inc - sIdentifierIn:",sidentifierin))
    CALL echo(build("bsc_process_med_generic.inc - dIdentifierTypeCd:",didentifiertypecd))
   ENDIF
   IF (textlen(sidentifierin) <= 0)
    RETURN
   ENDIF
   SET nobjstatus = checkprg("RX_GET_PRODUCT_SEARCH")
   IF (nobjstatus > 0
    AND bnewmodelchk=1)
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE litemcnt = i4 WITH protect, noconstant(0)
    DECLARE lreplysize = i4 WITH protect, noconstant(0)
    RECORD search_request(
      1 search_string = vc
      1 item_id_ind = i2
      1 item_id = f8
      1 ident_qual[*]
        2 identifier_type_cd = f8
      1 other_identifier_cd = f8
      1 med_type_qual[*]
        2 med_type_flag = i2
      1 med_filter_ind = i2
      1 intermittent_filter_ind = i2
      1 continuous_filter_ind = i2
      1 tpn_filter_ind = i2
      1 fac_qual[*]
        2 facility_cd = f8
      1 disp_loc_cd = f8
      1 show_all_ind = i2
      1 formulary_status_cd = f8
      1 set_items_ind = i2
      1 set_med_type_qual[*]
        2 set_med_type_flag = i2
      1 active_ind = i2
      1 pharmacy_type_cd = f8
      1 prev_item_id = f8
      1 max_rec = i4
      1 full_search_string = vc
      1 item_qual[*]
        2 item_id = f8
        2 med_product_id = f8
      1 exclude_fac_flex_ind = i2
      1 qoh_loc1_cd = f8
      1 qoh_loc2_cd = f8
      1 stock_pkg_for_qoh_ind = i2
      1 inv_track_level_ind = i2
      1 pharm_loc_cd = f8
    )
    RECORD search_reply(
      1 items[*]
        2 item_id = f8
        2 active_ind = i2
        2 manf_item_id = f8
        2 med_type_flag = i2
        2 med_filter_ind = i2
        2 intermittent_filter_ind = i2
        2 continuous_filter_ind = i2
        2 tpn_filter_ind = i2
        2 oe_format_flag = i2
        2 dispense_category_cd = f8
        2 formulary_status_cd = f8
        2 formulary_status = vc
        2 ndc = vc
        2 mnemonic = vc
        2 generic_name = vc
        2 description = vc
        2 brand_name = vc
        2 charge_number = vc
        2 other_identifier = vc
        2 strength_form = vc
        2 form_cd = f8
        2 form = vc
        2 strength = f8
        2 strength_unit_cd = f8
        2 strength_unit = vc
        2 volume = f8
        2 volume_unit_cd = f8
        2 volume_unit = vc
        2 primary_ind = i2
        2 brand_ind = i2
        2 divisble_ind = i2
        2 price_sched_id = f8
        2 dispense_qty = f8
        2 dispense_qty_unit_cd = f8
        2 manufacturer = vc
        2 facs[*]
          3 facility_cd = f8
          3 facility = vc
        2 med_product_id = f8
        2 inner_ndc = vc
        2 qoh_exists_ind_loc1 = i2
        2 qoh_loc1 = f8
        2 qoh_loc1_unit = vc
        2 qoh_exists_ind_loc2 = i2
        2 qoh_loc2 = f8
        2 qoh_loc2_unit = vc
      1 elapsed_time = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET search_request->search_string = cnvtupper(cnvtalphanum(sidentifierin))
    IF (didentifiertypecd > 0)
     SET dstat = alterlist(search_request->ident_qual,1)
     SET search_request->ident_qual[1].identifier_type_cd = didentifiertypecd
    ELSEIF (lsrchidx > 0)
     IF (debug_ind > 0)
      CALL echo(build("bsc_process_med_finditembyidentifier.inc - lSrchIdx:",lsrchidx))
     ENDIF
     SET lidentcnt = 0
     FOR (lcnt = 1 TO processing_rules->qual[lsrchidx].ident_qual_cnt)
       IF (((band(ibarcodeextractiontypes,processing_rules->qual[lsrchidx].ident_qual[lcnt].
        identifier_extraction_type) > 0
        AND iexcludetype=0) OR (band(ibarcodeextractiontypes,processing_rules->qual[lsrchidx].
        ident_qual[lcnt].identifier_extraction_type)=0
        AND iexcludetype=1)) )
        SET lidentcnt += 1
        IF (mod(lidentcnt,10)=1)
         SET dstat = alterlist(search_request->ident_qual,(lidentcnt+ 9))
        ENDIF
        SET search_request->ident_qual[lidentcnt].identifier_type_cd = processing_rules->qual[
        lsrchidx].ident_qual[lcnt].identifier_type_cd
       ENDIF
     ENDFOR
     SET dstat = alterlist(search_request->ident_qual,lidentcnt)
    ELSE
     FREE RECORD search_request
     FREE RECORD search_reply
     RETURN
    ENDIF
    SET dstat = alterlist(search_request->med_type_qual,2)
    SET search_request->med_type_qual[1].med_type_flag = 0
    SET search_request->med_type_qual[2].med_type_flag = 2
    SET search_request->med_filter_ind = 1
    SET search_request->intermittent_filter_ind = 1
    SET search_request->continuous_filter_ind = 1
    IF (dfacilitycd >= 0)
     SET dstat = alterlist(search_request->fac_qual,2)
     SET search_request->fac_qual[1].facility_cd = 0
     SET search_request->fac_qual[2].facility_cd = dfacilitycd
    ENDIF
    SET search_request->show_all_ind = 0
    SET search_request->set_items_ind = 0
    SET search_request->active_ind = 1
    SET search_request->pharmacy_type_cd = cinpatient
    SET search_request->max_rec = 10
    IF (debug_ind > 0)
     CALL echo("bsc_process_med_generic - Request to RX_GET_PRODUCT_SEARCH:")
     CALL echorecord(search_request)
    ENDIF
    SET modify = nopredeclare
    EXECUTE rx_get_product_search  WITH replace("REQUEST",search_request), replace("REPLY",
     search_reply)
    SET modify = predeclare
    IF (debug_ind > 0)
     CALL echo("bsc_process_med_generic - Reply from RX_GET_PRODUCT_SEARCH:")
     CALL echorecord(search_reply)
    ENDIF
    IF ((search_reply->status_data.status="S"))
     SET litemcnt = size(search_reply->items,5)
     SET sndcreturned = search_reply->items[1].ndc
    ENDIF
    SET inewcnt = size(search_reply->items,5)
    IF (inewcnt > 0)
     SET iexistingcnt = size(items->qual,5)
     SET dstat = alterlist(items->qual,(inewcnt+ iexistingcnt))
     FOR (lcnt = 1 TO inewcnt)
       SET items->qual[(iexistingcnt+ lcnt)].item_id = search_reply->items[lcnt].item_id
       SET items->qual[(iexistingcnt+ lcnt)].barcode = search_request->search_string
       SET items->qual[(iexistingcnt+ lcnt)].med_product_id = search_reply->items[lcnt].
       med_product_id
     ENDFOR
     SET barcode_source_cd = formulary_source_cd
    ELSE
     IF (debug_ind > 0)
      CALL echo("*** FindItemByIdentifierGeneric - No order catalogs could be found in the formulary"
       )
     ENDIF
    ENDIF
    FREE RECORD search_request
    FREE RECORD search_reply
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(items)
   ENDIF
   CALL echo(
    "bsc_process_med_generic.inc - ****** Exiting FindItemByIdentifierGeneric Subroutine ******")
 END ;Subroutine
 DECLARE getproductinfo(null) = null
 DECLARE getiteminfo(null) = null
 DECLARE populatereply(null) = null
 DECLARE getitemsynonyms(null) = null
 DECLARE getingredsynonyms(null) = null
 DECLARE geteventcodes(null) = null
 DECLARE getformroutes(null) = null
 DECLARE copyexecutionnotes(null) = null
 DECLARE checkforordersoutsidetimerange(null) = null
 DECLARE getformform(null) = null
 DECLARE getrecallstatus(null) = null
 CALL logdebug("*** Start of Script ***")
 SET reply->status_data.status = "F"
 SET parse_request->barcode = request->barcode
 SET parse_request->location_cd = request->location_cd
 SET parse_request->processpreferreditems_ind = 1
 SET parse_request->audit_solution_cd = validate(request->audit_solution_cd,0)
 SET parse_request->debug_ind = validate(request->debug_ind,0)
 IF (parse_info_ind=1)
  SET processing_rules->lot_number = request->parse_info[1].lot_number
  SET processing_rules->exp_date = request->parse_info[1].exp_date
  SET processing_rules->exp_date_tz = request->parse_info[1].exp_date_tz
  SET processing_rules->expiration_ind = request->parse_info[1].expiration_ind
  SET processing_rules->facility_cd = request->parse_info[1].facility_cd
  SET processing_rules->prefs.bnewmodelchk = request->parse_info[1].prefs.bnewmodelchk
  SET processing_rules->prefs.use_mltm_syn_match = request->parse_info[1].prefs.use_mltm_syn_match
  SET processing_rules->prefs.scanning_lookup_level = request->parse_info[1].prefs.
  scanning_lookup_level
  IF ((request->parse_info[1].gtin_identifier != null))
   CALL getproductinfo(null)
  ENDIF
  IF (size(items->qual,5) < 1)
   CALL extractparseinfo(null)
  ELSE
   SET barcode_source_cd = multum_source_cd
   SET ntype = nndc
   SET lchk14gs1 = 1
  ENDIF
 ELSE
  CALL extractmedidentifiers(null)
 ENDIF
 SET lot_number = validate(processing_rules->lot_number,0)
 SET exp_date = validate(processing_rules->exp_date,0)
 SET exp_date_tz = validate(processing_rules->exp_date_tz,0)
 SET expiration_ind = validate(processing_rules->expiration_ind,0)
 SET dfacilitycd = validate(processing_rules->facility_cd,0)
 SET bnewmodelchk = validate(processing_rules->prefs.bnewmodelchk,0)
 SET busemltmsynmatch = validate(processing_rules->prefs.use_mltm_syn_match,0)
 CALL copyexecutionnotes(null)
 IF (size(items->qual,5) < 1)
  CALL processextractedidentifiers(preferredtype,0)
  IF ((processing_rules->prefs.bnewmodelchk=1)
   AND size(items->qual,5)=0)
   SET itypecombine = ((((prefixtype+ mckessontype)+ omnicelltype)+ rawtype)+ ndctype)
   CALL processextractedidentifiers(itypecombine,0)
   IF (size(items->qual,5) < 1)
    SET itypecombine = ndcalttype
    CALL processextractedidentifiers(itypecombine,0)
   ENDIF
   IF (size(items->qual,5) < 1)
    SET itypecombine = gs1type
    CALL processextractedidentifiers(itypecombine,0)
   ENDIF
   IF (size(items->qual,5) < 1)
    SET itypecombine = gs1alttype
    CALL processextractedidentifiers(itypecombine,0)
   ENDIF
  ENDIF
  IF (size(items->qual,5) < 1)
   IF ((processing_rules->prefs.scanning_lookup_level=0))
    CALL processextractedidentifiers(ndctype,0)
    SET itypecombine = (ndcalttype+ mckessontype)
    CALL finditembyndc(itypecombine)
    IF (size(items->qual,5) < 1)
     CALL processextractedidentifiers(gs1type,0)
     CALL finditembyndc(gs1alttype)
    ENDIF
   ENDIF
  ENDIF
  IF (size(items->qual,5) < 1)
   CALL processextractedidentifiers(pocruletype,0)
  ENDIF
 ENDIF
 IF (size(items->qual,5) > 0)
  CALL getiteminfo(null)
  CALL populatereply(null)
 ENDIF
#exit_script
 FREE RECORD temp_reply
 FREE RECORD items
 FREE RECORD parse_reply
 FREE RECORD processing_rules
 FREE RECORD temp_ingred_inds
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (debug_ind > 0)
  CALL echorecord(reply)
 ENDIF
 SET elapsed_time = ((curtime3 - start_time)/ 100)
 CALL addexecutionnote(build("bsc_process_med_barcode elapsed time (seconds): ",elapsed_time))
 SUBROUTINE getproductinfo(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetProductInfo Subroutine ******")
   DECLARE req_num = i4 WITH protect, constant(395596)
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH public, noconstant(0)
   DECLARE hreply = i4 WITH public, noconstant(0)
   DECLARE srvstat = i4 WITH protect, noconstant(0)
   SET hmsg = uar_srvselectmessage(req_num)
   IF (hmsg=0)
    CALL logdebug("bsc_process_med_barcode: EJS transaction 395596 unavailable")
   ENDIF
   SET hrequest = uar_srvcreaterequest(hmsg)
   IF (hrequest=0)
    CALL logdebug("bsc_process_med_barcode: EJS transaction 395596 request construction error")
   ENDIF
   SET srvstat = uar_srvsetstring(hrequest,"gtin",nullterm(request->parse_info[1].gtin_identifier))
   SET srvstat = uar_srvsetdouble(hrequest,"facilityCd",request->parse_info[1].facility_cd)
   CALL logdebug(build("!@#$ request is ",request->parse_info[1].gtin_identifier," and ",request->
     parse_info[1].facility_cd))
   SET hreply = uar_srvcreatereply(hmsg)
   IF (hreply=0)
    CALL logdebug("bsc_process_med_barcode: EJS transaction 395596 reply construction error")
   ENDIF
   SET stat = uar_srvexecute(hmsg,hrequest,hreply)
   IF (stat=0)
    SET hstatus = uar_srvgetstruct(hreply,"transaction_status")
    SET successind = uar_srvgetshort(hstatus,"success_ind")
    IF (successind=1)
     DECLARE lcnt = i4 WITH protect, noconstant(0)
     DECLARE itemcnt = i4 WITH protect, noconstant(0)
     DECLARE curitem = i4 WITH protect, noconstant(0)
     SET itemcnt = uar_srvgetitemcount(hreply,"items")
     SET stat = alterlist(items->qual,itemcnt)
     FOR (lcnt = 1 TO itemcnt)
       SET curitem = uar_srvgetitem(hreply,nullterm("items"),(lcnt - 1))
       SET items->qual[lcnt].item_id = uar_srvgetdouble(curitem,"itemId")
       SET items->qual[lcnt].med_product_id = uar_srvgetdouble(curitem,"medProductId")
     ENDFOR
    ELSE
     SET errormsg = uar_srvgetstringptr(hstatus,"debug_error_message")
     CALL logdebug(build("bsc_process_med_barcode - Error message from service 395596: ",errormsg))
    ENDIF
   ELSE
    CALL logdebug("bsc_process_med_barcode - SrvExecute failed to call service 395596")
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetProductInfo Subroutine ******")
 END ;Subroutine
 SUBROUTINE (logdebug(smsg=vc) =null)
   IF (debug_ind > 0)
    CALL echo(smsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE extractmedidentifiers(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering ExtractMedIdentifiers Subroutine ******")
   SET modify = nopredeclare
   EXECUTE bsc_extract_med_identifiers  WITH replace("REQUEST",parse_request), replace("REPLY",
    parse_reply)
   SET modify = predeclare
   IF ((parse_reply->status_data.status="Z"))
    SET nscriptstatus = ndata_not_found
    GO TO exit_script
   ENDIF
   SET stat = moverec(parse_reply,processing_rules)
   CALL logdebug("bsc_process_med_barcode - ****** Exiting ExtractMedIdentifiers Subroutine ******")
 END ;Subroutine
 SUBROUTINE extractparseinfo(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering ExtractParseInfo Subroutine ******")
   DECLARE isearchsize = i4 WITH protect, noconstant(0)
   SET isearchsize = size(request->parse_info[1].qual,5)
   IF (isearchsize < 1)
    CALL extractmedidentifiers(null)
   ELSE
    SET stat = alterlist(processing_rules->qual,isearchsize)
    FOR (indexx = 1 TO size(request->parse_info[1].qual,5))
      SET processing_rules->qual[indexx].search_string = request->parse_info[1].qual[indexx].
      search_string
      SET processing_rules->qual[indexx].ident_qual_cnt = request->parse_info[1].qual[indexx].
      ident_qual_cnt
      SET processing_rules->qual[indexx].barcode_extraction_type = request->parse_info[1].qual[indexx
      ].barcode_extraction_type
      SET stat = alterlist(processing_rules->qual[indexx].ident_qual,size(request->parse_info[1].
        qual[indexx].ident_qual,5))
      FOR (indexy = 1 TO size(request->parse_info[1].qual[indexx].ident_qual,5))
       SET processing_rules->qual[indexx].ident_qual[indexy].identifier_type_cd = request->
       parse_info[1].qual[indexx].ident_qual[indexy].identifier_type_cd
       SET processing_rules->qual[indexx].ident_qual[indexy].identifier_extraction_type = request->
       parse_info[1].qual[indexx].ident_qual[indexy].identifier_extraction_type
      ENDFOR
    ENDFOR
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting ExtractParseInfo Subroutine ******")
 END ;Subroutine
 SUBROUTINE (finditembyndc(itypes=i4) =null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering FindItemByNDC Subroutine ******")
   RECORD temp_mmdc(
     1 qual_mmdc[*]
       2 mmdc = i4
       2 search_string = vc
   )
   RECORD nonformitems(
     1 qual[*]
       2 item_id = f8
       2 search_string = vc
   )
   DECLARE v500_ind = i2 WITH protect, noconstant(0)
   DECLARE mmdc_cnt = i4 WITH protect, noconstant(0)
   DECLARE mmdc_cki = vc WITH protect, noconstant(fillstring(255," "))
   DECLARE qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE sndc = vc WITH protect, noconstant(fillstring(255," "))
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lidx2 = i4 WITH protect, noconstant(0)
   DECLARE lidx3 = i4 WITH protect, noconstant(0)
   DECLARE lchkmckesson = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    d.owner
    FROM dba_tables d
    WHERE d.table_name="MLTM_NDC_CORE_DESCRIPTION"
     AND d.owner="V500"
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET v500_ind = 0
   ELSE
    SET v500_ind = 1
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(processing_rules)
   ENDIF
   FOR (x = 1 TO size(processing_rules->qual,5))
     CALL logdebug(build("barcode extraction type: ",processing_rules->qual[x].
       barcode_extraction_type))
     CALL logdebug(build("search_string: ",processing_rules->qual[x].search_string))
     CALL logdebug(build("text length: ",textlen(trim(processing_rules->qual[x].search_string))))
     IF (band(itypes,processing_rules->qual[x].barcode_extraction_type) > 0)
      CALL logdebug("Matched extraction type")
      IF (textlen(trim(processing_rules->qual[x].search_string)) IN (10, 11))
       IF (v500_ind=1)
        SELECT INTO "nl:"
         ncd.main_multum_drug_code
         FROM mltm_ndc_core_description ncd
         PLAN (ncd
          WHERE ncd.ndc_code=patstring(build(substring(1,9,processing_rules->qual[x].search_string),
            "*")))
         ORDER BY ncd.main_multum_drug_code
         HEAD ncd.main_multum_drug_code
          mmdc_cnt += 1
          IF (mod(mmdc_cnt,10)=1)
           dstat = alterlist(temp_mmdc->qual_mmdc,(mmdc_cnt+ 9))
          ENDIF
          temp_mmdc->qual_mmdc[mmdc_cnt].mmdc = ncd.main_multum_drug_code, temp_mmdc->qual_mmdc[
          mmdc_cnt].search_string = processing_rules->qual[x].search_string
         WITH nocounter
        ;end select
       ELSE
        SELECT INTO "nl:"
         ncd.main_multum_drug_code
         FROM (v500_ref.ndc_core_description ncd)
         PLAN (ncd
          WHERE ncd.ndc_code=patstring(build(substring(1,9,processing_rules->qual[x].search_string),
            "*")))
         ORDER BY ncd.main_multum_drug_code
         HEAD ncd.main_multum_drug_code
          mmdc_cnt += 1
          IF (mod(mmdc_cnt,10)=1)
           dstat = alterlist(temp_mmdc->qual_mmdc,(mmdc_cnt+ 9))
          ENDIF
          temp_mmdc->qual_mmdc[mmdc_cnt].mmdc = ncd.main_multum_drug_code, temp_mmdc->qual_mmdc[
          mmdc_cnt].search_string = processing_rules->qual[x].search_string
         WITH nocounter
        ;end select
       ENDIF
       IF (curqual=0)
        CALL logdebug("Searching for Inner NDC on the mltm_ndc_outer_inner_map table")
        SELECT
         IF (v500_ind=1)
          FROM mltm_ndc_outer_inner_map noim,
           mltm_ndc_core_description ncd
         ELSE
          FROM (v500_ref.ndc_outer_inner_map noim),
           (v500_ref.ndc_core_description ncd)
         ENDIF
         INTO "nl:"
         PLAN (noim
          WHERE noim.inner_ndc_code=patstring(build(substring(1,9,processing_rules->qual[x].
             search_string),"*")))
          JOIN (ncd
          WHERE ncd.ndc_code=noim.outer_ndc_code)
         ORDER BY ncd.main_multum_drug_code
         HEAD ncd.main_multum_drug_code
          IF (locateval(lidx1,1,mmdc_cnt,ncd.main_multum_drug_code,temp_mmdc->qual_mmdc[lidx1].mmdc)=
          0)
           mmdc_cnt += 1
           IF (mod(mmdc_cnt,10)=1)
            dstat = alterlist(temp_mmdc->qual_mmdc,(mmdc_cnt+ 9))
           ENDIF
           temp_mmdc->qual_mmdc[mmdc_cnt].mmdc = ncd.main_multum_drug_code, temp_mmdc->qual_mmdc[
           mmdc_cnt].search_string = processing_rules->qual[x].search_string
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
      ELSE
       CALL logdebug(build("search_string: ",processing_rules->qual[x].search_string))
       CALL logdebug("bsc_process_med_barcode - No multum lookup for invalid NDC length barcode")
       CALL addexecutionnote("Nonformulary - No multum lookup for invalid NDC length barcode")
      ENDIF
     ENDIF
   ENDFOR
   SET dstat = alterlist(temp_mmdc->qual_mmdc,mmdc_cnt)
   IF (mmdc_cnt=0)
    CALL logdebug("bsc_process_med_barcode - no mmdc found")
    CALL addexecutionnote("Nonformulary - no MMDC value found")
   ELSEIF (mmdc_cnt > 1)
    CALL logdebug("bsc_process_med_barcode - multiple mmdcs found")
    CALL addexecutionnote("Nonformulary - multiple MMDC values found")
   ELSE
    IF (debug_ind > 0)
     CALL echo(build("bsc_process_med_barcode - temp_mmdc:",temp_mmdc))
     CALL echorecord(temp_mmdc)
     CALL echo(build("Before mmdc_cki:",mmdc_cki))
     CALL echo(build("Before mmdc_cnt:",mmdc_cnt))
    ENDIF
    IF (bnewmodelchk=0)
     SET mmdc_cki = build("MUL.FRMLTN!",temp_mmdc->qual_mmdc[1].mmdc)
     SELECT INTO "nl:"
      md.item_id, ocir.catalog_cd
      FROM medication_definition md,
       order_catalog_item_r ocir,
       item_definition id
      PLAN (md
       WHERE md.cki=mmdc_cki
        AND md.item_id > 0)
       JOIN (ocir
       WHERE ocir.item_id=md.item_id)
       JOIN (id
       WHERE id.item_id=md.item_id
        AND id.active_ind > 0
        AND id.active_status_cd=cactive)
      ORDER BY ocir.item_id
      HEAD ocir.item_id
       qual_cnt = (size(nonformitems->qual,5)+ 1), dstat = alterlist(nonformitems->qual,qual_cnt),
       nonformitems->qual[qual_cnt].item_id = md.item_id,
       nonformitems->qual[qual_cnt].search_string = temp_mmdc->qual_mmdc[1].search_string
      WITH nocounter
     ;end select
    ELSE
     SET mmdc_cki = build("MUL.FRMLTN!",temp_mmdc->qual_mmdc[1].mmdc)
     SELECT INTO "nl:"
      md.item_id, ocir.catalog_cd
      FROM medication_definition md,
       order_catalog_item_r ocir,
       item_definition id,
       med_def_flex mdf,
       med_flex_object_idx mfoi
      PLAN (md
       WHERE md.cki=mmdc_cki
        AND md.item_id > 0)
       JOIN (ocir
       WHERE ocir.item_id=md.item_id)
       JOIN (id
       WHERE id.item_id=md.item_id
        AND id.active_ind > 0
        AND id.active_status_cd=cactive)
       JOIN (mdf
       WHERE mdf.item_id=id.item_id
        AND mdf.flex_type_cd=csyspack_flex
        AND mdf.pharmacy_type_cd=cinpatient)
       JOIN (mfoi
       WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
        AND mfoi.flex_object_type_cd=cfacility_flex
        AND mfoi.parent_entity_id IN (0.0, dfacilitycd))
      ORDER BY ocir.item_id
      HEAD ocir.item_id
       qual_cnt = (size(nonformitems->qual,5)+ 1), dstat = alterlist(nonformitems->qual,qual_cnt),
       nonformitems->qual[qual_cnt].item_id = md.item_id,
       nonformitems->qual[qual_cnt].search_string = temp_mmdc->qual_mmdc[1].search_string
      WITH nocounter
     ;end select
    ENDIF
    IF (debug_ind > 0)
     CALL echo(build("after mmdc_cki:",mmdc_cki))
     CALL echo(build("after mmdc_cnt:",mmdc_cnt))
     CALL echorecord(nonformitems)
    ENDIF
    SET sndc = cnvtupper(cnvtalphanum(request->barcode))
    IF (bnewmodelchk=0)
     SELECT INTO "nl:"
      FROM object_identifier_index oii,
       medication_definition md
      PLAN (oii
       WHERE oii.value_key=sndc
        AND oii.identifier_type_cd=cndc
        AND oii.object_type_cd=cmed_def
        AND oii.generic_object=0
        AND expand(lidx1,1,size(nonformitems->qual,5),oii.object_id,nonformitems->qual[lidx1].item_id
        )
        AND oii.active_ind=1)
       JOIN (md
       WHERE md.item_id=oii.object_id
        AND md.cki != "")
      ORDER BY oii.object_identifier_index_id
      HEAD REPORT
       qual_cnt = 0
      HEAD oii.object_identifier_index_id
       qual_cnt += 1, dstat = alterlist(items->qual,qual_cnt), items->qual[qual_cnt].item_id = oii
       .object_id,
       items->qual[qual_cnt].barcode = sndc, items->qual[qual_cnt].med_product_id = 0
      WITH nocounter
     ;end select
    ELSE
     SET dstat = alterlist(items->qual,size(nonformitems->qual,5))
     FOR (x = 1 TO size(nonformitems->qual,5))
       SET items->qual[x].item_id = nonformitems->qual[x].item_id
       SET items->qual[x].barcode = nonformitems->qual[x].search_string
       SET items->qual[x].med_product_id = 0
     ENDFOR
    ENDIF
    IF (size(items->qual,5) > 0)
     FOR (lidx3 = 1 TO size(processing_rules->qual,5))
       IF (band(processing_rules->qual[lidx3].barcode_extraction_type,mckessontype) > 0)
        SET lchkmckesson = 1
       ENDIF
     ENDFOR
     IF (lchkmckesson > 0)
      SET ntype = nmckesson
     ELSE
      SET ntype = nndc
     ENDIF
     SET barcode_source_cd = multum_source_cd
    ENDIF
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(items)
   ENDIF
   FREE RECORD nonformitems
   FREE RECORD temp_mmdc
   CALL logdebug("bsc_process_med_barcode - ****** Exiting FindItemByNDC Subroutine ******")
 END ;Subroutine
 SUBROUTINE getiteminfo(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetItemInfo Subroutine ******")
   IF (debug_ind > 0)
    CALL echo(
     "bsc_process_med_barcode - ****** Our list of items before calling RXA_GET_ITEM_INFO  ******")
    CALL echorecord(items)
   ENDIF
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   SET nobjstatus = checkprg("RXA_GET_ITEM_INFO")
   CALL logdebug(build("bsc_process_med_barcode - rxa_get_item_info script object status:",nobjstatus
     ))
   IF (nobjstatus > 0
    AND bnewmodelchk=1)
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
      1 parent_item_id = f8
      1 options_pref = i4
      1 birthdate = dq8
      1 financial_class_cd = f8
      1 funding_source_cd = f8
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
          3 ndc = vc
          3 brand = vc
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
          3 innerndcqual[*]
            4 inner_ndc = vc
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
          3 normalized_rate_ind = i2
        2 theraclassqual[*]
          3 alt_sel_category_id = f8
          3 ahfs_code = vc
        2 miscobjectqual[*]
          3 parent_entity_id = f8
          3 cdf_meaning = vc
        2 firstdoselocqual[*]
          3 location_cd = f8
        2 pkg_qty_per_pkg = f8
        2 pkg_disp_more_ind = i2
        2 dispcat_flex_ind = i4
        2 pricesch_flex_ind = i4
        2 workflow_cd = f8
        2 cmpd_qty = f8
        2 warning_labels[*]
          3 label_nbr = i4
          3 label_seq = i2
          3 label_text = vc
          3 label_default_print = i2
          3 label_exception_ind = i2
        2 premix_ind = i2
        2 ord_as_mnemonic = vc
        2 tpn_balance_method_cd = f8
        2 tpn_chloride_pct = f8
        2 tpn_default_ingred_item_id = f8
        2 tpn_fill_method_cd = f8
        2 tpn_include_ions_flag = i2
        2 tpn_overfill_amt = f8
        2 tpn_overfill_unit_cd = f8
        2 tpn_preferred_cation_cd = f8
        2 tpn_product_type_flag = i2
        2 lot_tracking_ind = i2
        2 rate = f8
        2 rate_cd = f8
        2 normalized_rate = f8
        2 normalized_rate_cd = f8
        2 freetext_rate = vc
        2 normalized_rate_ind = i2
        2 ord_detail_opts[*]
          3 facility_cd = f8
          3 age_range_id = f8
          3 oe_field_meaning_id = f8
          3 restrict_ind = i4
          3 opt_list[*]
            4 opt_txt = vc
            4 opt_cd = f8
            4 opt_nbr = f8
            4 default_ind = i4
            4 display_seq = i4
        2 poc_charge_flag = i2
        2 inventory_factor = f8
        2 prod_assign_flag = i2
        2 skip_dispense_flag = i2
        2 inv_master_id = f8
        2 grace_period_days = i4
        2 waste_charge_ind = i2
        2 cms_waste_billing_unit_amt = f8
        2 cms_waste_billing_unit_uom_cd = f8
        2 med_dispense_category_cd = f8
        2 cont_dispense_category_cd = f8
        2 int_dispense_category_cd = f8
        2 med_dispcat_flex_ind = i2
        2 int_dispcat_flex_ind = i2
        2 cont_dispcat_flex_ind = i2
        2 copay_tier_cd = f8
        2 max_dose_qty = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE newcnt = i4 WITH protect, noconstant(0)
    DECLARE lparentindex = i4 WITH protect, noconstant(0)
    DECLARE lchildcnt = i4 WITH protect, noconstant(0)
    DECLARE lparentidx = i4 WITH protect, noconstant(0)
    DECLARE litemidx = i4 WITH protect, noconstant(0)
    DECLARE lidx2 = i4 WITH protect, noconstant(0)
    DECLARE ifinalcnt = i4 WITH private, noconstant(0)
    DECLARE icompoundcnt = i4 WITH private, noconstant(0)
    SET newcnt = size(items->qual,5)
    SET dstat = alterlist(info_request->itemlist,newcnt)
    SET ifinalcnt = 0
    FOR (lcnt = 1 TO newcnt)
     SET litemidx = locateval(lidx2,1,ifinalcnt,items->qual[lcnt].item_id,info_request->itemlist[
      lidx2].item_id)
     IF (litemidx=0)
      SET ifinalcnt += 1
      SET info_request->itemlist[ifinalcnt].item_id = items->qual[lcnt].item_id
     ELSE
      CALL logdebug(build("bsc_process_med_barcode - item_id :",items->qual[lcnt].item_id,
        " already added to request"))
     ENDIF
    ENDFOR
    SET dstat = alterlist(info_request->itemlist,ifinalcnt)
    SET info_request->facility_cd = dfacilitycd
    SET info_request->pharm_type_cd = cinpatient
    SET info_request->med_all_ind = 1
    SET info_request->med_child_ind = 2
    SET info_request->med_def_ind = 1
    SET modify = nopredeclare
    EXECUTE rxa_get_item_info  WITH replace("REQUEST",info_request), replace("REPLY",info_reply)
    SET modify = predeclare
    IF (debug_ind > 0)
     CALL echo("bsc_process_med_barcode - ****** RxaGetItemInfo Request: ******")
     CALL echorecord(info_request)
     CALL echo("bsc_process_med_barcode - ****** RxaGetItemInfo Reply: ******")
     CALL echorecord(info_reply)
    ENDIF
    IF ((info_reply->status_data.status="S"))
     FOR (newcnt = 1 TO size(info_reply->itemlist,5))
       IF ((info_reply->itemlist[newcnt].parent_item_id=0))
        SET lparentindex = (size(temp_reply->qual,5)+ 1)
        SET dstat = alterlist(temp_reply->qual,lparentindex)
        SET temp_reply->qual[lparentindex].catalog_cd = info_reply->itemlist[newcnt].catalog_cd
        SET temp_reply->qual[lparentindex].item_id = info_reply->itemlist[newcnt].item_id
        SET temp_reply->qual[lparentindex].synonym_id = info_reply->itemlist[newcnt].synonym_id
        SET temp_reply->qual[lparentindex].strength = info_reply->itemlist[newcnt].med_disp_strength
        SET temp_reply->qual[lparentindex].strength_unit_cd = info_reply->itemlist[newcnt].
        med_disp_strength_unit_cd
        SET temp_reply->qual[lparentindex].volume = info_reply->itemlist[newcnt].med_disp_volume
        SET temp_reply->qual[lparentindex].volume_unit_cd = info_reply->itemlist[newcnt].
        med_disp_volume_unit_cd
        SET temp_reply->qual[lparentindex].form_cd = info_reply->itemlist[newcnt].form_cd
        SET temp_reply->qual[lparentindex].inv_master_id = info_reply->itemlist[newcnt].inv_master_id
        SET temp_reply->qual[lparentindex].oe_format_flag = info_reply->itemlist[newcnt].
        oe_format_flag
        SET temp_reply->qual[lparentindex].med_type_flag = info_reply->itemlist[newcnt].med_type_flag
        SET temp_reply->qual[lparentindex].order_mnemonic = info_reply->itemlist[newcnt].
        label_description
        SET temp_reply->qual[lparentindex].ordered_as_mnemonic = info_reply->itemlist[newcnt].
        ord_as_mnemonic
        SET temp_reply->qual[lparentindex].hna_order_mnemonic = info_reply->itemlist[newcnt].
        primarymnemonic
        SET temp_reply->qual[lparentindex].premix_ind = info_reply->itemlist[newcnt].premix_ind
        IF ((info_reply->itemlist[newcnt].med_type_flag=ncompound_med_type))
         SET temp_reply->qual[lparentindex].waste_charge_ind = 0
        ELSE
         SET temp_reply->qual[lparentindex].waste_charge_ind = info_reply->itemlist[newcnt].
         waste_charge_ind
        ENDIF
        SET litemidx = locateval(lidx2,1,size(items->qual,5),info_reply->itemlist[newcnt].item_id,
         items->qual[lidx2].item_id)
        IF (litemidx > 0)
         SET temp_reply->qual[lparentindex].barcode = items->qual[litemidx].barcode
         SET temp_reply->qual[lparentindex].med_product_id = items->qual[litemidx].med_product_id
        ELSE
         CALL addexecutionnote(build(
           "GetItemInfo - New Formulary Model - Unable to locate this item_id in items->qual: ",
           info_reply->itemlist[newcnt].item_id))
        ENDIF
        SET dstat = alterlist(temp_reply->qual[lparentindex].medproductqual,size(info_reply->
          itemlist[newcnt].medproductqual,5))
        FOR (lcnt = 1 TO size(info_reply->itemlist[newcnt].medproductqual,5))
          SET temp_reply->qual[lparentindex].medproductqual[lcnt].active_ind = info_reply->itemlist[
          newcnt].medproductqual[lcnt].active_ind
          SET temp_reply->qual[lparentindex].medproductqual[lcnt].manf_item_id = info_reply->
          itemlist[newcnt].medproductqual[lcnt].manf_item_id
          SET temp_reply->qual[lparentindex].medproductqual[lcnt].label_description = info_reply->
          itemlist[newcnt].medproductqual[lcnt].label_description
          SET temp_reply->qual[lparentindex].medproductqual[lcnt].manufacturer_cd = info_reply->
          itemlist[newcnt].medproductqual[lcnt].manufacturer_cd
          IF ((temp_reply->qual[lparentindex].med_product_id=info_reply->itemlist[newcnt].
          medproductqual[lcnt].med_product_id))
           SET temp_reply->qual[lparentindex].drug_ident = info_reply->itemlist[newcnt].
           medproductqual[lcnt].ndc
           IF (lchk14gs1=1)
            SET temp_reply->qual[lparentindex].barcode = info_reply->itemlist[newcnt].medproductqual[
            lcnt].ndc
           ENDIF
          ENDIF
        ENDFOR
        IF ((info_reply->itemlist[newcnt].med_type_flag=ncompound_med_type))
         CALL logdebug(
          "bsc_process_med_barcode - This is a compound product. Storing only compound parent item.")
         SET icompoundcnt = (size(temp_reply->qual[lparentidx].ingred_qual,5)+ 1)
         SET dstat = alterlist(temp_reply->qual[lparentidx].ingred_qual,icompoundcnt)
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].item_id = info_reply->itemlist[
         newcnt].item_id
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].synonym_id = info_reply->
         itemlist[newcnt].synonym_id
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].catalog_cd = info_reply->
         itemlist[newcnt].catalog_cd
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].strength = info_reply->itemlist[
         newcnt].strength
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].strength_unit_cd = info_reply->
         itemlist[newcnt].strength_unit_cd
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].volume = info_reply->itemlist[
         newcnt].volume
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].volume_unit_cd = info_reply->
         itemlist[newcnt].volume_unit_cd
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].order_mnemonic = info_reply->
         itemlist[newcnt].label_description
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].ordered_as_mnemonic = info_reply
         ->itemlist[newcnt].ord_as_mnemonic
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].hna_order_mnemonic = info_reply->
         itemlist[newcnt].primarymnemonic
         SET temp_reply->qual[lparentidx].ingred_qual[icompoundcnt].waste_charge_ind = 0
        ENDIF
       ENDIF
     ENDFOR
     FOR (newcnt = 1 TO size(info_reply->itemlist,5))
       IF ((info_reply->itemlist[newcnt].parent_item_id > 0))
        SET lparentidx = locateval(lidx2,1,size(temp_reply->qual,5),info_reply->itemlist[newcnt].
         parent_item_id,temp_reply->qual[lidx2].item_id)
        IF (lparentidx <= 0)
         CALL logdebug(
          "bsc_process_med_barcode - **** Premix parent/child mismatch - ingredient not loaded ****")
         CALL addexecutionnote(build("GetItemInfo Orphaned Premix ingredient - no parent item_id:",
           info_reply->itemlist[newcnt].parent_item_id))
         GO TO exit_script
        ELSEIF ((temp_reply->qual[lparentidx].med_type_flag != ncompound_med_type))
         SET lchildcnt = (size(temp_reply->qual[lparentidx].ingred_qual,5)+ 1)
         SET dstat = alterlist(temp_reply->qual[lparentidx].ingred_qual,lchildcnt)
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].item_id = info_reply->itemlist[
         newcnt].item_id
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].synonym_id = info_reply->itemlist[
         newcnt].synonym_id
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].catalog_cd = info_reply->itemlist[
         newcnt].catalog_cd
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].strength = info_reply->itemlist[
         newcnt].strength
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].strength_unit_cd = info_reply->
         itemlist[newcnt].strength_unit_cd
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].volume = info_reply->itemlist[newcnt
         ].volume
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].volume_unit_cd = info_reply->
         itemlist[newcnt].volume_unit_cd
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].order_mnemonic = info_reply->
         itemlist[newcnt].label_description
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].ordered_as_mnemonic = info_reply->
         itemlist[newcnt].ord_as_mnemonic
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].hna_order_mnemonic = info_reply->
         itemlist[newcnt].primarymnemonic
         SET temp_reply->qual[lparentidx].ingred_qual[lchildcnt].waste_charge_ind = info_reply->
         itemlist[newcnt].waste_charge_ind
         IF ((info_reply->itemlist[newcnt].waste_charge_ind=1))
          SET temp_reply->qual[lparentidx].waste_charge_ind = 1
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    FREE RECORD info_request
    FREE RECORD info_reply
   ELSE
    DECLARE lidx1 = i4 WITH protect, noconstant(0)
    DECLARE lidx2 = i4 WITH protect, noconstant(0)
    DECLARE lparentindex = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     md.item_id, oci.catalog_cd
     FROM medication_definition md,
      order_catalog_item_r oci,
      item_definition id
     PLAN (md
      WHERE expand(lidx1,1,size(items->qual,5),md.item_id,items->qual[lidx1].item_id))
      JOIN (oci
      WHERE oci.item_id=md.item_id)
      JOIN (id
      WHERE id.item_id=md.item_id
       AND id.active_ind > 0
       AND id.active_status_cd=cactive)
     ORDER BY md.item_id
     HEAD md.item_id
      lparentindex = (size(temp_reply->qual,5)+ 1), dstat = alterlist(temp_reply->qual,lparentindex),
      temp_reply->qual[lparentindex].catalog_cd = oci.catalog_cd,
      temp_reply->qual[lparentindex].item_id = md.item_id, temp_reply->qual[lparentindex].
      inv_master_id = md.inv_master_id, temp_reply->qual[lparentindex].strength = md.strength,
      temp_reply->qual[lparentindex].strength_unit_cd = md.strength_unit_cd, temp_reply->qual[
      lparentindex].volume = md.volume, temp_reply->qual[lparentindex].volume_unit_cd = md
      .volume_unit_cd,
      temp_reply->qual[lparentindex].form_cd = md.form_cd, temp_reply->qual[lparentindex].premix_ind
       = 0, temp_reply->qual[lparentindex].waste_charge_ind = 0,
      lidx2 = locateval(lidx1,1,size(items->qual,5),md.item_id,items->qual[lidx1].item_id)
      IF (lidx2 > 0)
       temp_reply->qual[lparentindex].barcode = items->qual[lidx2].barcode, temp_reply->qual[
       lparentindex].med_product_id = items->qual[lidx2].med_product_id
      ELSE
       CALL addexecutionnote(build(
        "GetItemInfo - Old Formulary Model - Unable to locate this item_id in items->qual: ",md
        .item_id))
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(temp_reply)
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetItemInfo Subroutine ******")
 END ;Subroutine
 SUBROUTINE checkforordersoutsidetimerange(null)
   DECLARE start_time_func = f8 WITH private, noconstant(curtime3)
   DECLARE elapsed_time_func = f8 WITH private, noconstant(0.0)
   DECLARE imatchcnt = i4 WITH noconstant(0)
   DECLARE inactiveordseqind = i2 WITH noconstant(0)
   DECLARE iscannedingredcnt = i4 WITH noconstant(0)
   DECLARE isyncount = i4 WITH noconstant(0)
   DECLARE lingredidx = i4 WITH noconstant(0)
   DECLARE lsynidx = i4 WITH noconstant(0)
   DECLARE ingredmatchind = i2 WITH noconstant(0)
   DECLARE iunmatcheddiluentcnt = i4 WITH noconstant(0)
   DECLARE ienc = i4 WITH noconstant(0)
   DECLARE iencsize = i4 WITH noconstant(size(request->encntr_list,5))
   DECLARE iordingreds = i4 WITH noconstant(0)
   DECLARE iallscannedingredsfound = i2 WITH noconstant(0)
   IF ((request->person_id=0))
    RETURN
   ENDIF
   CALL logdebug(
    "bsc_process_med_barcode - ****** Entering CheckForOrdersOutsideTimeRange Subroutine ******")
   SET iscannedingredcnt = size(reply->qual[1].ingred_qual,5)
   SET dstat = alterlist(temp_ingred_inds->array,iscannedingredcnt)
   SELECT
    IF (iencsize > 0)
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(ienc,1,iencsize,(o.encntr_id+ 0),request->encntr_list[ienc].encntr_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.projected_stop_dt_tm >= datetimeadd(cnvtdatetime(sysdate),- (1))) OR (o
      .projected_stop_dt_tm=null)) )
      JOIN (oi
      WHERE oi.order_id=o.order_id)
    ELSE
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.projected_stop_dt_tm >= datetimeadd(cnvtdatetime(sysdate),- (1))) OR (o
      .projected_stop_dt_tm=null)) )
      JOIN (oi
      WHERE oi.order_id=o.order_id)
    ENDIF
    INTO "nl:"
    FROM orders o,
     order_ingredient oi
    ORDER BY oi.order_id, oi.action_sequence DESC
    HEAD REPORT
     imatchcnt = 0
    HEAD oi.order_id
     inactiveordseqind = 0, imatchcnt = 0, iunmatcheddiluentcnt = 0,
     iordingreds = 0
     FOR (lingredidx = 1 TO iscannedingredcnt)
       temp_ingred_inds->array[lingredidx].ingred_found_ind = 0
     ENDFOR
    HEAD oi.action_sequence
     inactiveordseqind = inactiveordseqind
    DETAIL
     IF (inactiveordseqind=0)
      iordingreds += 1, ingredmatchind = 0
      IF (iscannedingredcnt=0)
       IF ((reply->qual[1].catalog_cd=oi.catalog_cd))
        isyncount = size(reply->qual[1].synonym_qual,5)
        IF (isyncount > 0)
         IF ((reply->active_order_found_ind=0)
          AND (reply->inactive_order_found_ind=0))
          reply->synonym_mismatch_id = oi.synonym_id, reply->mismatch_order_id = oi.order_id
         ENDIF
         FOR (lsynidx = 1 TO isyncount)
           IF ((reply->qual[1].synonym_qual[lsynidx].synonym_id=oi.synonym_id))
            imatchcnt += 1, reply->synonym_mismatch_id = 0, reply->mismatch_order_id = 0,
            ingredmatchind = 1, lsynidx = isyncount
           ENDIF
         ENDFOR
        ELSE
         imatchcnt += 1, ingredmatchind = 1
        ENDIF
       ENDIF
      ELSE
       FOR (lingredidx = 1 TO iscannedingredcnt)
         IF ((reply->qual[1].ingred_qual[lingredidx].catalog_cd=oi.catalog_cd))
          isyncount = size(reply->qual[1].ingred_qual[lingredidx].synonym_qual,5)
          IF (isyncount > 0)
           IF ((reply->active_order_found_ind=0)
            AND (reply->inactive_order_found_ind=0))
            reply->mismatch_order_id = oi.order_id
           ENDIF
           FOR (lsynidx = 1 TO isyncount)
             IF ((reply->qual[1].ingred_qual[lingredidx].synonym_qual[lsynidx].synonym_id=oi
             .synonym_id))
              imatchcnt += 1, reply->mismatch_order_id = 0, ingredmatchind = 1,
              lsynidx = isyncount, temp_ingred_inds->array[lingredidx].ingred_found_ind = 1,
              lingredidx = iscannedingredcnt
             ENDIF
           ENDFOR
          ELSE
           imatchcnt += 1, ingredmatchind = 1, temp_ingred_inds->array[lingredidx].ingred_found_ind
            = 1,
           lingredidx = iscannedingredcnt
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF (ingredmatchind=0
       AND oi.freq_cd != every_bag_cd
       AND oi.freq_cd != 0)
       imatchcnt += 1, ingredmatchind = 1
      ENDIF
      IF (ingredmatchind=0
       AND oi.ingredient_type_flag=diluent_flag)
       iunmatcheddiluentcnt += 1
      ENDIF
     ENDIF
    FOOT  oi.action_sequence
     inactiveordseqind = 1
    FOOT  oi.order_id
     iallscannedingredsfound = 1
     IF (iscannedingredcnt > 0)
      FOR (lingredidx = 1 TO iscannedingredcnt)
        IF ((temp_ingred_inds->array[lingredidx].ingred_found_ind=0))
         iallscannedingredsfound = 0
        ENDIF
      ENDFOR
     ENDIF
     CALL logdebug("----------------------------------------"),
     CALL logdebug(build("iScannedIngredCnt:",iscannedingredcnt)),
     CALL logdebug(build("iMatchCnt:",imatchcnt)),
     CALL logdebug(build("iOrdIngreds:",iordingreds)),
     CALL logdebug(build("iUnmatchedDiluentCnt:",iunmatcheddiluentcnt)),
     CALL logdebug(build("iAllScannedIngredsFound:",iallscannedingredsfound)),
     CALL logdebug(build("oi.order_id:",oi.order_id)),
     CALL logdebug("----------------------------------------")
     IF (iallscannedingredsfound=1
      AND ((iscannedingredcnt > 0
      AND (iordingreds=(iunmatcheddiluentcnt+ imatchcnt))) OR (iscannedingredcnt=0
      AND imatchcnt=1
      AND (iordingreds=(1+ iunmatcheddiluentcnt)))) )
      IF ((((request->multi_ingred_ind=1)) OR (iordingreds=imatchcnt)) )
       IF (o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
       pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd))
        IF ((reply->active_order_found_ind=1))
         reply->multi_found_ind = 1, reply->found_order_status = 0
        ELSE
         reply->multi_found_ind = 0, reply->found_order_id = o.order_id
        ENDIF
        reply->active_order_found_ind = 1, reply->found_order_status = o.order_status_cd, reply->
        synonym_mismatch_id = 0
       ELSE
        IF ((reply->active_order_found_ind=0))
         IF ((reply->inactive_order_found_ind=1))
          reply->multi_found_ind = 1, reply->found_order_status = 0
         ELSE
          reply->found_order_id = o.order_id, reply->found_order_status = o.order_status_cd
         ENDIF
        ENDIF
        reply->inactive_order_found_ind = 1, reply->synonym_mismatch_id = 0
       ENDIF
      ENDIF
     ENDIF
     inactiveordseqind = 0
    FOOT REPORT
     imatchcnt = 0
    WITH nocounter
   ;end select
   SET elapsed_time_func = ((curtime3 - start_time_func)/ 100)
   CALL addexecutionnote(build("Order Search Function elapsed time (seconds): ",elapsed_time_func))
   CALL logdebug(
    "bsc_process_med_barcode - ****** Exiting CheckForOrdersOutsideTimeRange Subroutine ******")
 END ;Subroutine
 SUBROUTINE populatereply(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering PopulateReply Subroutine ******")
   DECLARE reply_size = i2 WITH noconstant(0)
   DECLARE bmismatch = i2 WITH noconstant(0)
   DECLARE bpremix = i2 WITH noconstant(0)
   DECLARE medprodcnt = i4 WITH noconstant(0)
   DECLARE ingredcnt = i4 WITH noconstant(0)
   DECLARE ingredsyncnt = i4 WITH noconstant(0)
   DECLARE lcnt1 = i4 WITH protect, noconstant(0)
   DECLARE lcnt2 = i4 WITH protect, noconstant(0)
   DECLARE lcnt3 = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lfirstsir = i4 WITH protect, noconstant(0)
   DECLARE lfirstcnum = i4 WITH protect, noconstant(0)
   DECLARE lchkmckesson = i2 WITH protect, noconstant(0)
   DECLARE lidx3 = i4 WITH protect, noconstant(0)
   DECLARE lchkgs1 = i2 WITH protect, noconstant(0)
   DECLARE tempmanufacturercd = f8 WITH protect, noconstant(0.0)
   DECLARE tempmedprodcnt = i4 WITH protect, noconstant(0)
   CALL logdebug("bsc_process_med_barcode - Comparing all items in temp_reply")
   IF (size(temp_reply->qual,5) > 0)
    SET reply_size = (size(reply->qual,5)+ 1)
    SET dstat = alterlist(reply->qual,reply_size)
    IF ((temp_reply->qual[1].premix_ind=1))
     SET bpremix = 1
    ENDIF
    FOR (lidx3 = 1 TO size(processing_rules->qual,5))
      IF (band(processing_rules->qual[lidx3].barcode_extraction_type,(gs1type+ gs1alttype)) > 0
       AND (temp_reply->qual[1].barcode=processing_rules->qual[lidx3].search_string))
       SET lchkgs1 = 1
       CALL logdebug("GS1 Matched")
      ENDIF
    ENDFOR
    SET reply->qual[reply_size].catalog_cd = temp_reply->qual[1].catalog_cd
    SET reply->qual[reply_size].form_cd = temp_reply->qual[1].form_cd
    SET reply->qual[reply_size].strength = temp_reply->qual[1].strength
    SET reply->qual[reply_size].strength_unit_cd = temp_reply->qual[1].strength_unit_cd
    SET reply->qual[reply_size].item_id = temp_reply->qual[1].item_id
    SET reply->qual[reply_size].inv_master_id = temp_reply->qual[1].inv_master_id
    SET reply->qual[reply_size].volume = temp_reply->qual[1].volume
    SET reply->qual[reply_size].volume_unit_cd = temp_reply->qual[1].volume_unit_cd
    SET reply->qual[reply_size].oe_format_flag = temp_reply->qual[1].oe_format_flag
    SET reply->qual[reply_size].synonym_id = temp_reply->qual[1].synonym_id
    SET reply->qual[reply_size].identification_ind = ntype
    SET reply->qual[reply_size].order_mnemonic = temp_reply->qual[1].order_mnemonic
    SET reply->qual[reply_size].ordered_as_mnemonic = temp_reply->qual[1].ordered_as_mnemonic
    SET reply->qual[reply_size].hna_order_mnemonic = temp_reply->qual[1].hna_order_mnemonic
    SET reply->qual[reply_size].barcode = temp_reply->qual[1].barcode
    SET reply->qual[reply_size].med_product_id = temp_reply->qual[1].med_product_id
    SET reply->qual[reply_size].drug_ident = temp_reply->qual[1].drug_ident
    SET reply->qual[reply_size].barcode_source_cd = barcode_source_cd
    SET reply->qual[reply_size].med_type_flag = temp_reply->qual[1].med_type_flag
    SET reply->qual[reply_size].waste_charge_ind = evaluate(temp_reply->qual[1].waste_charge_ind,1,1,
     0)
    IF (ntype=nmckesson)
     SET reply->qual[reply_size].expiration_ind = expiration_ind
     SET reply->qual[reply_size].exp_date = exp_date
     SET reply->qual[reply_size].exp_date_tz = exp_date_tz
    ELSEIF (((lchkgs1=1) OR (lchk14gs1=1)) )
     SET reply->qual[reply_size].expiration_ind = expiration_ind
     SET reply->qual[reply_size].exp_date = exp_date
     SET reply->qual[reply_size].exp_date_tz = exp_date_tz
     SET reply->qual[reply_size].lot_number = lot_number
    ENDIF
    SET medprodcnt = size(temp_reply->qual[1].medproductqual,5)
    SET tempmedprodcnt = medprodcnt
    SET dstat = alterlist(reply->qual[reply_size].medproductqual,medprodcnt)
    FOR (lcnt2 = 1 TO medprodcnt)
      SET reply->qual[reply_size].medproductqual[lcnt2].manf_item_id = temp_reply->qual[1].
      medproductqual[lcnt2].manf_item_id
      SET reply->qual[reply_size].medproductqual[lcnt2].label_description = temp_reply->qual[1].
      medproductqual[lcnt2].label_description
      SET reply->qual[reply_size].medproductqual[lcnt2].active_ind = temp_reply->qual[1].
      medproductqual[lcnt2].active_ind
      IF ((temp_reply->qual[1].medproductqual[lcnt2].active_ind > 0)
       AND medprodcnt=1)
       SET tempmanufacturercd = temp_reply->qual[1].medproductqual[medprodcnt].manufacturer_cd
      ENDIF
      IF ((temp_reply->qual[1].medproductqual[lcnt2].active_ind > 0)
       AND lcnt2 < tempmedprodcnt)
       IF ((temp_reply->qual[1].medproductqual[1].manufacturer_cd=temp_reply->qual[1].medproductqual[
       lcnt2].manufacturer_cd))
        SET tempmanufacturercd = temp_reply->qual[1].medproductqual[lcnt2].manufacturer_cd
       ELSE
        SET tempmanufacturercd = 0.0
        SET tempmedprodcnt = lcnt2
       ENDIF
      ENDIF
    ENDFOR
    SET reply->qual[reply_size].medproductqual[1].manufacturer_cd = tempmanufacturercd
    SET ingredcnt = size(temp_reply->qual[1].ingred_qual,5)
    SET dstat = alterlist(reply->qual[reply_size].ingred_qual,ingredcnt)
    FOR (lcnt2 = 1 TO ingredcnt)
      SET reply->qual[reply_size].ingred_qual[lcnt2].item_id = temp_reply->qual[1].ingred_qual[lcnt2]
      .item_id
      SET reply->qual[reply_size].ingred_qual[lcnt2].synonym_id = temp_reply->qual[1].ingred_qual[
      lcnt2].synonym_id
      SET reply->qual[reply_size].ingred_qual[lcnt2].catalog_cd = temp_reply->qual[1].ingred_qual[
      lcnt2].catalog_cd
      SET reply->qual[reply_size].ingred_qual[lcnt2].strength = temp_reply->qual[1].ingred_qual[lcnt2
      ].strength
      SET reply->qual[reply_size].ingred_qual[lcnt2].strength_unit_cd = temp_reply->qual[1].
      ingred_qual[lcnt2].strength_unit_cd
      SET reply->qual[reply_size].ingred_qual[lcnt2].volume = temp_reply->qual[1].ingred_qual[lcnt2].
      volume
      SET reply->qual[reply_size].ingred_qual[lcnt2].volume_unit_cd = temp_reply->qual[1].
      ingred_qual[lcnt2].volume_unit_cd
      SET reply->qual[reply_size].ingred_qual[lcnt2].order_mnemonic = temp_reply->qual[1].
      ingred_qual[lcnt2].order_mnemonic
      SET reply->qual[reply_size].ingred_qual[lcnt2].ordered_as_mnemonic = temp_reply->qual[1].
      ingred_qual[lcnt2].ordered_as_mnemonic
      SET reply->qual[reply_size].ingred_qual[lcnt2].hna_order_mnemonic = temp_reply->qual[1].
      ingred_qual[lcnt2].hna_order_mnemonic
      SET reply->qual[reply_size].ingred_qual[lcnt2].waste_charge_ind = evaluate(temp_reply->qual[1].
       ingred_qual[lcnt2].waste_charge_ind,1,1,0)
    ENDFOR
   ENDIF
   IF (size(temp_reply->qual,5) > 1)
    FOR (lcnt1 = 2 TO size(temp_reply->qual,5))
      SET bmismatch = 0
      SET lchkgs1 = 0
      IF ((temp_reply->qual[lcnt1].premix_ind=1))
       SET bpremix = 1
      ENDIF
      IF (((bpremix=1) OR ((((temp_reply->qual[1].catalog_cd != temp_reply->qual[lcnt1].catalog_cd))
       OR ((((temp_reply->qual[1].form_cd != temp_reply->qual[lcnt1].form_cd)) OR ((((temp_reply->
      qual[1].strength != temp_reply->qual[lcnt1].strength)) OR ((((temp_reply->qual[1].
      strength_unit_cd != temp_reply->qual[lcnt1].strength_unit_cd)) OR ((((temp_reply->qual[1].
      volume != temp_reply->qual[lcnt1].volume)) OR ((temp_reply->qual[1].volume_unit_cd !=
      temp_reply->qual[lcnt1].volume_unit_cd))) )) )) )) )) )) )
       SET bmismatch = 1
       CALL logdebug("bsc_process_med_barcode - Found Mismatched Items")
       FOR (lidx3 = 1 TO size(processing_rules->qual,5))
         IF (band(processing_rules->qual[lidx3].barcode_extraction_type,(gs1type+ gs1alttype)) > 0
          AND (temp_reply->qual[lcnt1].barcode=processing_rules->qual[lidx3].search_string))
          SET lchkgs1 = 1
          CALL logdebug("GS1 Mismatch")
         ENDIF
       ENDFOR
      ELSE
       CALL logdebug("bsc_process_med_barcode - Found Duplicate  (Parent level) Items")
       FOR (lidx3 = 1 TO size(processing_rules->qual,5))
         IF (band(processing_rules->qual[lidx3].barcode_extraction_type,(gs1type+ gs1alttype)) > 0
          AND (temp_reply->qual[lcnt1].barcode=processing_rules->qual[lidx3].search_string))
          SET reply->qual[reply_size].expiration_ind = expiration_ind
          SET reply->qual[reply_size].exp_date = exp_date
          SET reply->qual[reply_size].exp_date_tz = exp_date_tz
          SET reply->qual[reply_size].lot_number = lot_number
          IF (debug_ind > 0)
           CALL logdebug("GS1 Dup Matched")
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF (bmismatch=1)
       SET reply_size = (size(reply->qual,5)+ 1)
       SET dstat = alterlist(reply->qual,reply_size)
       SET reply->qual[reply_size].catalog_cd = temp_reply->qual[lcnt1].catalog_cd
       SET reply->qual[reply_size].form_cd = temp_reply->qual[lcnt1].form_cd
       SET reply->qual[reply_size].strength = temp_reply->qual[lcnt1].strength
       SET reply->qual[reply_size].strength_unit_cd = temp_reply->qual[lcnt1].strength_unit_cd
       SET reply->qual[reply_size].item_id = temp_reply->qual[lcnt1].item_id
       SET reply->qual[reply_size].inv_master_id = temp_reply->qual[lcnt1].inv_master_id
       SET reply->qual[reply_size].volume = temp_reply->qual[lcnt1].volume
       SET reply->qual[reply_size].volume_unit_cd = temp_reply->qual[lcnt1].volume_unit_cd
       SET reply->qual[reply_size].oe_format_flag = temp_reply->qual[lcnt1].oe_format_flag
       SET reply->qual[reply_size].synonym_id = temp_reply->qual[lcnt1].synonym_id
       SET reply->qual[reply_size].identification_ind = ntype
       SET reply->qual[reply_size].order_mnemonic = temp_reply->qual[lcnt1].order_mnemonic
       SET reply->qual[reply_size].ordered_as_mnemonic = temp_reply->qual[lcnt1].ordered_as_mnemonic
       SET reply->qual[reply_size].hna_order_mnemonic = temp_reply->qual[lcnt1].hna_order_mnemonic
       SET reply->qual[reply_size].barcode = temp_reply->qual[lcnt1].barcode
       SET reply->qual[reply_size].med_product_id = temp_reply->qual[lcnt1].med_product_id
       SET reply->qual[reply_size].drug_ident = temp_reply->qual[lcnt1].drug_ident
       SET reply->qual[reply_size].barcode_source_cd = barcode_source_cd
       SET reply->qual[reply_size].med_type_flag = temp_reply->qual[lcnt1].med_type_flag
       SET reply->qual[reply_size].waste_charge_ind = evaluate(temp_reply->qual[lcnt1].
        waste_charge_ind,1,1,0)
       IF (ntype=nmckesson)
        SET reply->qual[reply_size].expiration_ind = expiration_ind
        SET reply->qual[reply_size].exp_date = exp_date
        SET reply->qual[reply_size].exp_date_tz = exp_date_tz
       ELSEIF (((lchkgs1=1) OR (lchk14gs1=1)) )
        SET reply->qual[reply_size].expiration_ind = expiration_ind
        SET reply->qual[reply_size].exp_date = exp_date
        SET reply->qual[reply_size].exp_date_tz = exp_date_tz
        SET reply->qual[reply_size].lot_number = lot_number
       ENDIF
       SET medprodcnt = size(temp_reply->qual[lcnt1].medproductqual,5)
       SET tempmedprodcnt = medprodcnt
       SET dstat = alterlist(reply->qual[reply_size].medproductqual,medprodcnt)
       SET tempmanufacturercd = 0.0
       FOR (lcnt2 = 1 TO medprodcnt)
         SET reply->qual[reply_size].medproductqual[lcnt2].manf_item_id = temp_reply->qual[lcnt1].
         medproductqual[lcnt2].manf_item_id
         SET reply->qual[reply_size].medproductqual[lcnt2].label_description = temp_reply->qual[lcnt1
         ].medproductqual[lcnt2].label_description
         IF ((temp_reply->qual[lcnt1].medproductqual[lcnt2].active_ind > 0)
          AND medprodcnt=1)
          SET tempmanufacturercd = temp_reply->qual[lcnt1].medproductqual[medprodcnt].manufacturer_cd
         ENDIF
         IF ((temp_reply->qual[lcnt1].medproductqual[lcnt2].active_ind > 0)
          AND lcnt2 < tempmedprodcnt)
          IF ((temp_reply->qual[lcnt1].medproductqual[lcnt2].manufacturer_cd=temp_reply->qual[lcnt1].
          medproductqual[lcnt2].manufacturer_cd))
           SET tempmanufacturercd = temp_reply->qual[lcnt1].medproductqual[lcnt2].manufacturer_cd
          ELSE
           SET tempmanufacturercd = 0.0
           SET tempmedprodcnt = lcnt2
          ENDIF
         ENDIF
       ENDFOR
       SET reply->qual[reply_size].medproductqual[1].manufacturer_cd = tempmanufacturercd
       SET ingredcnt = size(temp_reply->qual[reply_size].ingred_qual,5)
       SET dstat = alterlist(reply->qual[reply_size].ingred_qual,ingredcnt)
       FOR (lcnt2 = 1 TO ingredcnt)
         SET reply->qual[reply_size].ingred_qual[lcnt2].item_id = temp_reply->qual[reply_size].
         ingred_qual[lcnt2].item_id
         SET reply->qual[reply_size].ingred_qual[lcnt2].synonym_id = temp_reply->qual[reply_size].
         ingred_qual[lcnt2].synonym_id
         SET reply->qual[reply_size].ingred_qual[lcnt2].catalog_cd = temp_reply->qual[reply_size].
         ingred_qual[lcnt2].catalog_cd
         SET reply->qual[reply_size].ingred_qual[lcnt2].strength = temp_reply->qual[reply_size].
         ingred_qual[lcnt2].strength
         SET reply->qual[reply_size].ingred_qual[lcnt2].strength_unit_cd = temp_reply->qual[
         reply_size].ingred_qual[lcnt2].strength_unit_cd
         SET reply->qual[reply_size].ingred_qual[lcnt2].volume = temp_reply->qual[reply_size].
         ingred_qual[lcnt2].volume
         SET reply->qual[reply_size].ingred_qual[lcnt2].volume_unit_cd = temp_reply->qual[reply_size]
         .ingred_qual[lcnt2].volume_unit_cd
         SET reply->qual[reply_size].ingred_qual[lcnt2].order_mnemonic = temp_reply->qual[reply_size]
         .ingred_qual[lcnt2].order_mnemonic
         SET reply->qual[reply_size].ingred_qual[lcnt2].ordered_as_mnemonic = temp_reply->qual[
         reply_size].ingred_qual[lcnt2].ordered_as_mnemonic
         SET reply->qual[reply_size].ingred_qual[lcnt2].hna_order_mnemonic = temp_reply->qual[
         reply_size].ingred_qual[lcnt2].hna_order_mnemonic
         SET reply->qual[reply_size].ingred_qual[lcnt2].waste_charge_ind = evaluate(temp_reply->qual[
          reply_size].ingred_qual[lcnt2].waste_charge_ind,1,1,0)
       ENDFOR
      ENDIF
    ENDFOR
    IF (bpremix=1)
     CALL logdebug("bsc_process_med_barcode - Multiple premixes or premix/nonpremix mismatch found")
     CALL addexecutionnote(
      "Failure in PopulateReply - Multiple premixes or premix/nonpremix mismatch found.")
    ELSEIF (bmismatch=1)
     CALL logdebug("bsc_process_med_barcode - Mismatch Found")
     CALL addexecutionnote(
      "Failure in PopulateReply - Items varied in catalog, form, strength, volume, or units.")
    ENDIF
   ENDIF
   IF (size(reply->qual,5)=1)
    CALL getformroutes(null)
    CALL geteventcodes(null)
    CALL getformform(null)
    CALL getrecallstatus(null)
    IF (size(reply->qual[1].ingred_qual,5) > 0)
     CALL getingredsynonyms(null)
    ELSE
     CALL getitemsynonyms(null)
    ENDIF
    IF (order_info_ind=1)
     CALL checkforordersoutsidetimerange(null)
    ENDIF
   ELSE
    CALL addexecutionnote(
     "Med not uniquely identified - synonyms, routes, event codes were not gathered.")
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting PopulateReply Subroutine ******")
 END ;Subroutine
 SUBROUTINE getitemsynonyms(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetItemSynonyms Subroutine ******")
   IF (debug_ind > 0)
    CALL echorecord(temp_reply)
   ENDIF
   RECORD temp_synonyms(
     1 qual[*]
       2 synonym_id = f8
   )
   DECLARE bhassynonyms = i2 WITH protect, noconstant(0)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lidx2 = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lrepsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lcnt1 = i4 WITH protect, noconstant(0)
   DECLARE lcnt2 = i4 WITH protect, noconstant(0)
   DECLARE lcnt3 = i4 WITH protect, noconstant(0)
   DECLARE bsynitemfound = i2 WITH protect, noconstant(0)
   DECLARE lintsyncnt = i4 WITH protect, noconstant(0)
   DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
   DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
   DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
   DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
   SELECT INTO "nl:"
    FROM synonym_item_r sir,
     order_catalog_synonym ocs
    PLAN (sir
     WHERE expand(lidx1,1,size(temp_reply->qual,5),sir.item_id,temp_reply->qual[lidx1].item_id)
      AND sir.synonym_id > 0)
     JOIN (ocs
     WHERE ocs.synonym_id=sir.synonym_id
      AND ((ocs.active_ind+ 0) > 0))
    ORDER BY sir.item_id
    HEAD sir.item_id
     lidx = locateval(lidx2,1,size(temp_reply->qual,5),sir.item_id,temp_reply->qual[lidx2].item_id),
     lsyncnt = 0
    DETAIL
     IF (debug_ind > 0)
      CALL logdebug(build("Add to synonym list - sir.synonym_id:",sir.synonym_id))
     ENDIF
     bhassynonyms = 1, lsyncnt += 1, dstat = alterlist(temp_reply->qual[lidx].synonym_qual,lsyncnt),
     temp_reply->qual[lidx].synonym_qual[lsyncnt].synonym_id = sir.synonym_id
    WITH nocounter
   ;end select
   IF (bhassynonyms=0)
    IF (busemltmsynmatch=0)
     CALL logdebug("bsc_process_med_barcode - use_mltm_syn_match pref=OFF")
    ELSE
     CALL logdebug("bsc_process_med_barcode - use_mltm_syn_match pref=ON")
     SELECT INTO "nl:"
      FROM mltm_ndc_core_description mdc,
       mltm_mmdc_name_map mnm,
       med_identifier mdi,
       order_catalog_synonym ocs,
       order_catalog_item_r ocir
      PLAN (mdi
       WHERE expand(lidx1,1,size(temp_reply->qual,5),mdi.item_id,temp_reply->qual[lidx1].item_id)
        AND mdi.med_identifier_type_cd=cndc
        AND mdi.active_ind=1
        AND mdi.med_product_id > 0
        AND mdi.pharmacy_type_cd=cinpatient
        AND mdi.flex_type_cd IN (csystem, csyspkgtyp))
       JOIN (ocir
       WHERE mdi.item_id=ocir.item_id)
       JOIN (mdc
       WHERE mdi.value_key=mdc.ndc_code)
       JOIN (mnm
       WHERE mdc.main_multum_drug_code=mnm.main_multum_drug_code)
       JOIN (ocs
       WHERE concat("MUL.ORD-SYN!",cnvtstring(mnm.drug_synonym_id))=ocs.cki
        AND ocs.active_ind > 0
        AND ocs.synonym_id > 0)
      ORDER BY mdi.item_id
      HEAD mdi.item_id
       lidx = locateval(lidx2,1,size(temp_reply->qual,5),mdi.item_id,temp_reply->qual[lidx2].item_id),
       lsyncnt = size(temp_reply->qual[lidx].synonym_qual,5)
      DETAIL
       IF (debug_ind > 0)
        CALL logdebug(build("Add to synonym list - ocs.synonym_id:",ocs.synonym_id))
       ENDIF
       bhassynonyms = 1, lsyncnt += 1, dstat = alterlist(temp_reply->qual[lidx].synonym_qual,lsyncnt),
       temp_reply->qual[lidx].synonym_qual[lsyncnt].synonym_id = ocs.synonym_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (bhassynonyms=1)
    FOR (lcnt1 = 1 TO size(temp_reply->qual,5))
      IF (size(temp_reply->qual[lcnt].synonym_qual,5) > 0)
       IF (bsynitemfound=0)
        FOR (lcnt2 = 1 TO size(temp_reply->qual[lcnt1].synonym_qual,5))
          SET lintsyncnt = (size(temp_synonyms->qual,5)+ 1)
          SET dstat = alterlist(temp_synonyms->qual,lintsyncnt)
          SET temp_synonyms->qual[lintsyncnt].synonym_id = temp_reply->qual[lcnt1].synonym_qual[lcnt2
          ].synonym_id
        ENDFOR
        SET bsynitemfound = 1
       ELSE
        FOR (lcnt2 = 1 TO size(temp_synonyms->qual,5))
         SET lidx = locateval(lcnt3,1,size(temp_reply->qual[lcnt1].synonym_qual,5),temp_synonyms->
          qual[lcnt2].synonym_id,temp_reply->qual[lcnt1].synonym_qual[lcnt3].synonym_id)
         IF (lidx <= 0)
          CALL logdebug(build(
            "Removing SIR/CNUM record to due to intersection mismatch - synonym_id:",temp_synonyms->
            qual[lcnt2].synonym_id))
          CALL addexecutionnote(build(
            "PopulateReply - SIR/CNUM record removed due to mismatch - synonym_id:",temp_synonyms->
            qual[lcnt2].synonym_id))
          SET temp_synonyms->qual[lcnt2].synonym_id = 0
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   FOR (lcnt1 = 1 TO size(temp_synonyms->qual,5))
     IF ((temp_synonyms->qual[lcnt1].synonym_id > 0))
      SET lcnt2 = (size(reply->qual[1].synonym_qual,5)+ 1)
      SET dstat = alterlist(reply->qual[1].synonym_qual,lcnt2)
      SET reply->qual[1].synonym_qual[lcnt2].synonym_id = temp_synonyms->qual[lcnt1].synonym_id
     ENDIF
   ENDFOR
   IF (lsyncnt > 0)
    CALL logdebug("bsc_process_med_barcode - Synonyms mappings found, adding Rx Mnemonics")
    SET lrepsyncnt = size(reply->qual[1].synonym_qual,5)
    SET dstat = alterlist(reply->qual[1].synonym_qual,(lrepsyncnt+ size(temp_reply->qual,5)))
    FOR (lcnt1 = 1 TO size(temp_reply->qual,5))
      SET reply->qual[1].synonym_qual[(lrepsyncnt+ lcnt1)].synonym_id = temp_reply->qual[lcnt1].
      synonym_id
    ENDFOR
   ELSE
    CALL echo("No synonym mappings found for any items -  will be matched at catalog level")
   ENDIF
   IF (debug_ind > 0)
    CALL logdebug("Temp_Reply during exit of GetItemSynonyms, all item synonyms should be present:")
    CALL echorecord(temp_reply)
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetItemSynonyms Subroutine ******")
   FREE RECORD temp_synonyms
 END ;Subroutine
 SUBROUTINE getingredsynonyms(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetIngredSynonyms Subroutine ******")
   RECORD non_sir_ingreds(
     1 qual[*]
       2 item_id = f8
   )
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lidx2 = i4 WITH protect, noconstant(0)
   DECLARE lnonsircnt = i4 WITH protect, noconstant(0)
   DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
   DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
   DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
   DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
   SELECT INTO "nl:"
    FROM synonym_item_r sir,
     order_catalog_synonym ocs
    PLAN (sir
     WHERE expand(lidx1,1,size(temp_reply->qual[1].ingred_qual,5),sir.item_id,reply->qual[1].
      ingred_qual[lidx1].item_id)
      AND sir.synonym_id > 0)
     JOIN (ocs
     WHERE ocs.synonym_id=sir.synonym_id
      AND ocs.active_ind > 0)
    ORDER BY sir.item_id
    HEAD sir.item_id
     lsyncnt = 0, lidx = locateval(lidx2,1,size(reply->qual[1].ingred_qual,5),sir.item_id,reply->
      qual[1].ingred_qual[lidx2].item_id)
    DETAIL
     lsyncnt += 1, dstat = alterlist(reply->qual[1].ingred_qual[lidx].synonym_qual,lsyncnt), reply->
     qual[1].ingred_qual[lidx].synonym_qual[lsyncnt].synonym_id = sir.synonym_id
     IF (debug_ind > 0)
      CALL logdebug(build("Add to synonym list - sir.synonym_id:",sir.synonym_id))
     ENDIF
    WITH nocounter
   ;end select
   FOR (lcnt = 1 TO size(reply->qual[1].ingred_qual,5))
     IF (size(reply->qual[1].ingred_qual[lcnt1].synonym_qual,5)=0)
      SET lnonsircnt = (size(non_sir_ingreds->qual,5)+ 1)
      SET dstat = alterlist(non_sir_ingreds->qual,lnonsircnt)
      SET non_sir_ingreds->qual[lnonsircnt].item_id = reply->qual[1].ingred_qual[lcnt1].item_id
     ENDIF
   ENDFOR
   IF (lnonsircnt > 0)
    IF (debug_ind > 0)
     IF (busemltmsynmatch=1)
      CALL logdebug("bsc_process_med_barcode - use_mltm_syn_match pref is ON")
     ELSE
      CALL logdebug("bsc_process_med_barcode - use_mltm_syn_match pref is OFF")
     ENDIF
    ENDIF
    IF (busemltmsynmatch=1)
     IF (debug_ind > 0)
      CALL logdebug("bsc_process_med_barcode - Looking for CNUMS for ingredients")
     ENDIF
     SELECT INTO "nl:"
      FROM mltm_ndc_core_description mdc,
       mltm_mmdc_name_map mnm,
       med_identifier mdi,
       order_catalog_synonym ocs,
       order_catalog_item_r ocir
      PLAN (mdi
       WHERE expand(lidx1,1,size(non_sir_ingreds->qual,5),mdi.item_id,non_sir_ingreds->qual[lidx1].
        item_id)
        AND mdi.med_identifier_type_cd=cndc
        AND mdi.active_ind=1
        AND mdi.med_product_id > 0
        AND mdi.pharmacy_type_cd=cinpatient
        AND mdi.flex_type_cd IN (csystem, csyspkgtyp))
       JOIN (ocir
       WHERE mdi.item_id=ocir.item_id)
       JOIN (mdc
       WHERE mdi.value_key=mdc.ndc_code)
       JOIN (mnm
       WHERE mdc.main_multum_drug_code=mnm.main_multum_drug_code)
       JOIN (ocs
       WHERE concat("MUL.ORD-SYN!",cnvtstring(mnm.drug_synonym_id))=ocs.cki
        AND ocs.active_ind > 0
        AND ocs.synonym_id > 0)
      ORDER BY mdi.item_id
      HEAD mdi.item_id
       lsyncnt = 0, lidx = locateval(lidx2,1,size(reply->qual[1].ingred_qual,5),mdi.item_id,reply->
        qual[1].ingred_qual[lidx2].item_id)
      DETAIL
       IF (debug_ind > 0)
        CALL logdebug(build("Add CNUM to ingred synonym list - ocs.synonym_id:",ocs.synonym_id))
       ENDIF
       lsyncnt += 1, dstat = alterlist(reply->qual[1].ingred_qual[lidx].synonym_qual,lsyncnt), reply
       ->qual[1].ingred_qual[lidx].synonym_qual[lsyncnt].synonym_id = ocs.synonym_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   FOR (lcnt = 1 TO size(reply->qual[1].ingred_qual,5))
    SET lsyncnt = size(reply->qual[1].ingred_qual[lcnt].synonym_qual,5)
    IF (lsyncnt > 0)
     SET lsyncnt += 1
     SET dstat = alterlist(reply->qual[1].ingred_qual[lcnt].synonym_qual,lsyncnt)
     SET reply->qual[1].ingred_qual[lcnt].synonym_qual[lsyncnt].synonym_id = reply->qual[1].
     ingred_qual[lcnt].synonym_id
     IF (debug_ind > 0)
      CALL logdebug(build("Added an Ingredient Rx Mnemonic, item_id:",reply->qual[1].ingred_qual[lcnt
        ].synonym_id))
     ENDIF
    ENDIF
   ENDFOR
   IF (debug_ind > 0)
    CALL logdebug("Reply exiting GetIngredSynonyms, should have all ingredient synonyms")
    CALL echorecord(reply)
   ENDIF
   FREE RECORD non_sir_ingreds
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetIngredSynonyms Subroutine ******")
 END ;Subroutine
 SUBROUTINE geteventcodes(null)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lidx2 = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value_event_r cve
    WHERE (cve.parent_cd=reply->qual[1].catalog_cd)
    HEAD cve.event_cd
     reply->qual[1].event_cd = cve.event_cd
    WITH nocounter
   ;end select
   IF ((reply->qual[1].event_cd=0)
    AND (reply->qual[1].catalog_cd > 0))
    CALL logdebug(build("No event code found for catalog_cd:",reply->qual[1].catalog_cd))
    CALL addexecutionnote(build("No event code found for catalog_cd:",reply->qual[1].catalog_cd))
   ENDIF
   IF (size(reply->qual[1].ingred_qual,5) > 0)
    SELECT INTO "nl:"
     FROM code_value_event_r cve
     WHERE expand(lidx1,1,size(reply->qual[1].ingred_qual,5),cve.parent_cd,reply->qual[1].
      ingred_qual[lidx1].catalog_cd)
     HEAD cve.parent_cd
      lidx = locateval(lidx2,1,size(reply->qual[1].ingred_qual,5),cve.parent_cd,reply->qual[1].
       ingred_qual[lidx2].catalog_cd), reply->qual[1].ingred_qual[lidx].event_cd = cve.event_cd
     WITH nocounter
    ;end select
    FOR (lcnt = 1 TO size(reply->qual[1].ingred_qual,5))
      IF ((reply->qual[1].ingred_qual[lcnt].event_cd=0)
       AND (reply->qual[1].ingred_qual[lcnt].catalog_cd > 0))
       CALL logdebug(build("No event code found for ingredient catalog_cd:",reply->qual[1].
         ingred_qual[lcnt].catalog_cd))
       CALL addexecutionnote(build("No event code found for ingredient catalog_cd:",reply->qual[1].
         ingred_qual[lcnt].catalog_cd))
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE getformroutes(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetFormRoutes Subroutine ******")
   DECLARE lroutecnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM route_form_r rfr,
     code_value cv
    PLAN (rfr
     WHERE (rfr.form_cd=reply->qual[1].form_cd)
      AND rfr.route_cd > 0)
     JOIN (cv
     WHERE cv.code_value=rfr.route_cd
      AND cv.active_ind=1)
    ORDER BY rfr.form_cd
    DETAIL
     lroutecnt = (size(reply->qual[1].route_qual,5)+ 1), dstat = alterlist(reply->qual[1].route_qual,
      lroutecnt), reply->qual[1].route_qual[lroutecnt].route_cd = rfr.route_cd
    WITH nocounter
   ;end select
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetFormRoutes Subroutine ******")
 END ;Subroutine
 SUBROUTINE getformform(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetFormForm Subroutine ******")
   DECLARE lformcnt = i4 WITH protect, noconstant(0)
   SELECT
    cvg2.child_code_value
    FROM code_value_group cvg1,
     code_value_group cvg2,
     code_value cv
    PLAN (cvg1
     WHERE (cvg1.child_code_value=reply->qual[1].form_cd))
     JOIN (cv
     WHERE cv.code_value=cvg1.parent_code_value
      AND cv.code_set=code_set_value)
     JOIN (cvg2
     WHERE cvg2.parent_code_value=cv.code_value)
    HEAD REPORT
     stat = alterlist(reply->qual[1].compatable_form_qual,10), lformcnt = 0
    DETAIL
     lformcnt += 1
     IF (mod(lformcnt,10)=1)
      stat = alterlist(reply->qual[1].compatable_form_qual,(lformcnt+ 9))
     ENDIF
     reply->qual[1].compatable_form_qual[lformcnt].form_cd = cvg2.child_code_value
    FOOT REPORT
     stat = alterlist(reply->qual[1].compatable_form_qual,lformcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (processextractedidentifiers(ibarcodeextractiontypes=i2,iexcludetype=i2) =null)
   CALL logdebug(
    "bsc_process_med_barcode - ****** Entering ProcessExtractedIdentifiers Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lsearch = i4 WITH protect, noconstant(0)
   DECLARE lidx3 = i4 WITH protect, noconstant(0)
   DECLARE lchkmckesson = i2 WITH protect, noconstant(0)
   DECLARE lchkgs1 = i2 WITH protect, noconstant(0)
   FOR (lcnt = 1 TO size(processing_rules->qual,5))
     SET sndcreturned = ""
     IF (debug_ind > 0)
      CALL logdebug(build("barcode extraction type: ",processing_rules->qual[lcnt].
        barcode_extraction_type))
      CALL logdebug(build("search_string: ",processing_rules->qual[lcnt].search_string))
     ENDIF
     IF (((band(ibarcodeextractiontypes,processing_rules->qual[lcnt].barcode_extraction_type) > 0
      AND iexcludetype=0) OR (band(ibarcodeextractiontypes,processing_rules->qual[lcnt].
      barcode_extraction_type)=0
      AND iexcludetype=1)) )
      IF (debug_ind > 0)
       CALL logdebug(build("Matched extraction type - iExcludeType=",iexcludetype))
      ENDIF
      CALL finditembyidentifiergeneric(processing_rules->qual[lcnt].search_string,0.0,lcnt,
       ibarcodeextractiontypes,iexcludetype)
      IF (size(items->qual,5) >= 1)
       IF (debug_ind > 0)
        CALL logdebug("bsc_process_med_barcode - ****** Item_ids found: ******")
        CALL echorecord(items)
       ENDIF
       IF ((processing_rules->qual[lcnt].ident_qual_cnt > 0))
        IF (locateval(lsearch,1,size(processing_rules->qual[lcnt].ident_qual,5),cndc,processing_rules
         ->qual[lcnt].ident_qual[lsearch].identifier_type_cd) > 0)
         FOR (lidx3 = 1 TO size(processing_rules->qual,5))
           IF (band(processing_rules->qual[lidx3].barcode_extraction_type,mckessontype) > 0
            AND (cnvtalphanum(sndcreturned)=processing_rules->qual[lidx3].search_string))
            SET lchkmckesson = 1
           ENDIF
         ENDFOR
         IF (lchkmckesson=1)
          SET ntype = nmckesson
         ELSE
          SET ntype = nndc
         ENDIF
        ELSE
         SET ntype = nidentifier
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL logdebug(
    "bsc_process_med_barcode - ****** Exiting ProcessExtractedIdentifiers Subroutine ******")
 END ;Subroutine
 SUBROUTINE (addexecutionnote(snotein=vc) =null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering AddExecutionNote Subroutine ******")
   DECLARE lnotecnt = i4 WITH protect, noconstant(0)
   SET lnotecnt = (size(reply->execution_notes,5)+ 1)
   SET dstat = alterlist(reply->execution_notes,lnotecnt)
   SET reply->execution_notes[lnotecnt].note = snotein
   IF (debug_ind > 0)
    CALL logdebug(build("Execution note: ",snotein))
   ENDIF
   CALL logdebug("bsc_process_med_barcode - ****** Exiting AddExecutionNote Subroutine ******")
 END ;Subroutine
 SUBROUTINE copyexecutionnotes(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering CopyExecutionNote Subroutine ******")
   DECLARE identcnt = i4 WITH protect, noconstant(0)
   DECLARE barcnt = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   SET identcnt = size(processing_rules->execution_notes,5)
   SET barcnt = size(reply->execution_notes,5)
   SET dstat = alterlist(reply->execution_notes,(barcnt+ identcnt))
   FOR (lidx1 = 1 TO identcnt)
    SET barcnt += 1
    SET reply->execution_notes[barcnt].note = processing_rules->execution_notes[lidx1].note
   ENDFOR
   CALL logdebug("bsc_process_med_barcode - ****** Exiting CopyExecutionNote Subroutine ******")
 END ;Subroutine
 SUBROUTINE getrecallstatus(null)
   CALL logdebug("bsc_process_med_barcode - ****** Entering GetRecallStatus Subroutine ******")
   SELECT INTO "nl:"
    FROM lot_number_info lni,
     (dummyt d  WITH seq = value(size(reply->qual,5)))
    PLAN (d)
     JOIN (lni
     WHERE (((lni.item_id=reply->qual[d.seq].item_id)) OR ((lni.item_id=reply->qual[d.seq].
     inv_master_id)))
      AND lni.lot_number_txt=cnvtupper(reply->qual[d.seq].lot_number)
      AND lni.active_status_cd=recalled)
    HEAD lni.lot_number
     reply->qual[d.seq].recalled_ind = 1
    WITH nocounter
   ;end select
   CALL logdebug("bsc_process_med_barcode - ****** Exiting GetRecallStatus Subroutine ******")
 END ;Subroutine
 SET last_mod = "035"
 SET mod_date = "03/05/2024"
 SET modify = nopredeclare
END GO
