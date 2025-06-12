CREATE PROGRAM bsc_rpt_med_waste:dba
 PROMPT
  "Output to file/printer/MINE:" = "MINE",
  "Starting date(mm/dd/yyyy):" = "SYSDATE",
  "Ending date(mm/dd/yyyy):" = "SYSDATE",
  "Facility:" = 0
  WITH outdev, startdate, enddate,
  facility
 IF ((reqinfo->updt_applctx <= 0))
  CALL echo("Report must be ran from Discern Explorer: Explorer Menu")
  GO TO exit_script
 ENDIF
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF ( NOT (validate(errorrec,0)))
  RECORD errorrec(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  )
 ENDIF
 DECLARE lretval = i2 WITH private, noconstant(0)
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE nowaste = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"noWaste","NO WASTE"))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 FREE RECORD temp_rpt
 RECORD temp_rpt(
   1 qual[*]
     2 waste_status_flag = i2
     2 person_id = f8
     2 name_full_formatted = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 mrn = vc
     2 encntr_id = f8
     2 fin = vc
     2 facility_cd = f8
     2 nurse_unit_cd = f8
     2 dept_misc_line = vc
     2 event_title_text = vc
     2 order_id = f8
     2 catalog_cd = f8
     2 order_status_cd = f8
     2 disp_event_type_cd = f8
     2 waste_qty = f8
     2 available_waste_qty = f8
     2 available_waste_charge_qty = f8
     2 dispense_qty_uom_cd = f8
     2 rxs_waste_qty = f8
     2 event_id = f8
     2 med_event_id = f8
     2 parent_event_id = f8
     2 rn_waste_amount = vc
     2 ndc = vc
     2 bag_nbr = vc
     2 waste_event_dt_tm = dq8
     2 item_qual[*]
       3 item_idx = i4
       3 barcode_scanned = vc
 ) WITH protect
 FREE RECORD items
 RECORD items(
   1 qual[*]
     2 item_id = f8
     2 label_desc = vc
     2 drug_identifier = vc
     2 waste_charge_ind = i2
 ) WITH protect
 FREE RECORD bscrequest
 RECORD bscrequest(
   1 med_event_qual[*]
     2 parent_event_id = f8
   1 facility_cd = f8
   1 begin_search_date_tm = dq8
   1 end_search_date_tm = dq8
 )
 RECORD bscreply(
   1 qual[*]
     2 encntr_id = f8
     2 parent_event_id = f8
     2 person_id = f8
     2 nurse_unit_cd = f8
     2 order_id = f8
     2 bag_nbr = vc
     2 dta_waste_string = vc
     2 vol_waste_val = f8
     2 vol_waste_unit_cd = f8
     2 waste_event_dt_tm = dq8
     2 related_med_event_id = f8
     2 event_title = vc
     2 ingred_qual[*]
       3 waste_val = f8
       3 waste_unit_cd = f8
       3 catalog_cd = f8
       3 event_title = vc
       3 ingred_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dfin = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE dpharm_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE dmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE dmed_type = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE sndc_cki = vc WITH protect, constant("CERNER!421B3B96-643D-417A-8125-4B3713BD697E")
 DECLARE sseparator = vc WITH protect, constant("|")
 DECLARE dstarttime = dq8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE nprodcount = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH private, noconstant(0)
 DECLARE sscriptstatus = c1 WITH private, noconstant("F")
 DECLARE eventcnt = i4 WITH protect, noconstant(0)
 DECLARE eventidx = i4 WITH protect, noconstant(0)
 DECLARE prodidx = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE sitemid = vc WITH protect, noconstant("")
 DECLARE sbarcodescanned = vc WITH protect, noconstant("")
 DECLARE sutcdatetime = vc WITH protect, noconstant(" ")
 DECLARE dutcdatetime = f8 WITH protect, noconstant(0.0)
 DECLARE cutc = i2 WITH protect, constant(curutc)
 SUBROUTINE (utcdatetime(sdatetime=vc,lindex=i4,bshowtz=i2,sformat=vc) =vc)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
   IF (lindex > 0)
    SET lnewindex = lindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,sformat)
   IF (cutc=1
    AND bshowtz=1)
    IF (size(trim(snewdatetime)) > 0)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE (utcshorttz(lindex=i4) =vc)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewshorttz = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = i2 WITH protect, constant(7)
   IF (cutc=1)
    IF (lindex > 0)
     SET lnewindex = lindex
    ENDIF
    SET snewshorttz = datetimezonebyindex(lnewindex,offset,daylight,ctime_zone_format)
   ENDIF
   SET snewshorttz = trim(snewshorttz)
   RETURN(snewshorttz)
 END ;Subroutine
 CALL echo("********** BEGIN BSC_RPT_MED_WASTE **********")
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationname = "GET"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = curprog
 SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 SET bscrequest->facility_cd =  $FACILITY
 SET bscrequest->begin_search_date_tm = cnvtdatetime( $STARTDATE)
 SET bscrequest->end_search_date_tm = cnvtdatetime( $ENDDATE)
 SUBROUTINE (getstring(dfieldvalue=f8) =vc)
   DECLARE sreturnstring = vc WITH protect, noconstant("0")
   IF (dfieldvalue > 0)
    SET sreturnstring = cnvtstring(dfieldvalue,11,4)
   ENDIF
   RETURN(sreturnstring)
 END ;Subroutine
 SUBROUTINE (parse_products(index=i4) =vc WITH protect)
   DECLARE slabeldesc = vc WITH protect, noconstant("")
   SET sitemid = ""
   SET sbarcodescanned = ""
   SET slabeldesc = ""
   DECLARE nitemindex = i4 WITH private, noconstant(0.0)
   IF (size(temp_rpt->qual[index].item_qual,5) >= 1)
    SET slabeldesc = items->qual[temp_rpt->qual[index].item_qual[1].item_idx].label_desc
    SET sitemid = cnvtstring(items->qual[temp_rpt->qual[index].item_qual[1].item_idx].item_id)
    SET sbarcodescanned = temp_rpt->qual[index].item_qual[1].barcode_scanned
    FOR (x = 2 TO size(temp_rpt->qual[index].item_qual,5))
      SET nitemindex = temp_rpt->qual[index].item_qual[x].item_idx
      SET slabeldesc = concat(slabeldesc,sseparator,items->qual[nitemindex].label_desc)
      SET sitemid = concat(sitemid,sseparator,cnvtstring(items->qual[nitemindex].item_id))
      SET sbarcodescanned = concat(sbarcodescanned,sseparator,temp_rpt->qual[index].item_qual[x].
       barcode_scanned)
    ENDFOR
   ENDIF
   RETURN(slabeldesc)
 END ;Subroutine
 EXECUTE bsc_retrieve_waste_results  WITH replace("REQUEST","BSCREQUEST"), replace("REPLY","BSCREPLY"
  )
 FOR (eventidx = 1 TO size(bscreply->qual,5))
   SET eventcnt += 1
   IF (mod(eventcnt,10)=1)
    SET stat = alterlist(temp_rpt->qual,(eventcnt+ 9))
   ENDIF
   IF (size(trim(bscreply->qual[eventidx].dta_waste_string),1) > 1)
    SET temp_rpt->qual[eventcnt].rn_waste_amount = bscreply->qual[eventidx].dta_waste_string
   ELSE
    SET temp_rpt->qual[eventcnt].rn_waste_amount = substring(1,80,concat(trim(substring(1,40,
        getstring(bscreply->qual[eventidx].vol_waste_val)))," ",trim(substring(1,40,
        uar_get_code_display(bscreply->qual[eventidx].vol_waste_unit_cd)))))
   ENDIF
   SET temp_rpt->qual[eventcnt].encntr_id = bscreply->qual[eventidx].encntr_id
   SET temp_rpt->qual[eventcnt].event_id = bscreply->qual[eventidx].parent_event_id
   SET temp_rpt->qual[eventcnt].med_event_id = bscreply->qual[eventidx].related_med_event_id
   SET temp_rpt->qual[eventcnt].order_id = bscreply->qual[eventidx].order_id
   SET temp_rpt->qual[eventcnt].bag_nbr = bscreply->qual[eventidx].bag_nbr
   SET temp_rpt->qual[eventcnt].nurse_unit_cd = bscreply->qual[eventidx].nurse_unit_cd
   SET temp_rpt->qual[eventcnt].person_id = bscreply->qual[eventidx].person_id
   SET temp_rpt->qual[eventcnt].waste_event_dt_tm = bscreply->qual[eventidx].waste_event_dt_tm
   SET temp_rpt->qual[eventcnt].event_title_text = bscreply->qual[eventidx].event_title
   IF (size(bscreply->qual[eventidx].ingred_qual,5) > 0)
    FOR (idx = 1 TO size(bscreply->qual[eventidx].ingred_qual,5))
      SET eventcnt += 1
      IF (mod(eventcnt,10)=1)
       SET stat = alterlist(temp_rpt->qual,(eventcnt+ 9))
      ENDIF
      SET temp_rpt->qual[eventcnt].encntr_id = bscreply->qual[eventidx].encntr_id
      SET temp_rpt->qual[eventcnt].order_id = bscreply->qual[eventidx].order_id
      SET temp_rpt->qual[eventcnt].bag_nbr = bscreply->qual[eventidx].bag_nbr
      SET temp_rpt->qual[eventcnt].nurse_unit_cd = bscreply->qual[eventidx].nurse_unit_cd
      SET temp_rpt->qual[eventcnt].person_id = bscreply->qual[eventidx].person_id
      SET temp_rpt->qual[eventcnt].waste_event_dt_tm = bscreply->qual[eventidx].waste_event_dt_tm
      SET temp_rpt->qual[eventcnt].parent_event_id = bscreply->qual[eventidx].parent_event_id
      SET temp_rpt->qual[eventcnt].med_event_id = bscreply->qual[eventidx].ingred_qual[idx].
      med_event_id
      SET temp_rpt->qual[eventcnt].catalog_cd = bscreply->qual[eventidx].ingred_qual[idx].catalog_cd
      SET temp_rpt->qual[eventcnt].event_id = bscreply->qual[eventidx].ingred_qual[idx].
      ingred_event_id
      SET temp_rpt->qual[eventcnt].rn_waste_amount = substring(1,80,concat(trim(substring(1,40,
          getstring(bscreply->qual[eventidx].ingred_qual[idx].waste_val)))," ",trim(substring(1,40,
          uar_get_code_display(bscreply->qual[eventidx].ingred_qual[idx].waste_unit_cd)))))
      SET temp_rpt->qual[eventcnt].event_title_text = bscreply->qual[eventidx].ingred_qual[idx].
      event_title
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_rpt->qual,eventcnt)
 CALL echo("Looking up Patient Demographics")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(eventcnt)),
   person p,
   orders o,
   encntr_alias ea,
   encntr_alias ea2
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp_rpt->qual[d.seq].person_id))
   JOIN (o
   WHERE (o.order_id=temp_rpt->qual[d.seq].order_id))
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(o.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(dfin))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(o.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(dmrn))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ea2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY d.seq
  DETAIL
   temp_rpt->qual[d.seq].name_full_formatted = p.name_full_formatted, temp_rpt->qual[d.seq].mrn = ea2
   .alias, temp_rpt->qual[d.seq].fin = ea.alias,
   temp_rpt->qual[d.seq].dept_misc_line = trim(o.dept_misc_line), temp_rpt->qual[d.seq].
   order_status_cd = o.order_status_cd
  WITH nocounter
 ;end select
 CALL echo("Looking up product information")
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
 SELECT INTO "NL:"
  FROM clinical_event ce,
   ce_med_admin_ident_reltn cmair,
   ce_med_admin_ident cmai,
   prod_dispense_hx pdh
  PLAN (ce
   WHERE ((expand(lidx,1,eventcnt,ce.parent_event_id,temp_rpt->qual[lidx].med_event_id)) OR (expand(
    lidx2,1,eventcnt,ce.event_id,temp_rpt->qual[lidx2].med_event_id)))
    AND ce.event_class_cd=dmed_type)
   JOIN (cmair
   WHERE cmair.event_id=ce.event_id)
   JOIN (cmai
   WHERE cmai.ce_med_admin_ident_id=cmair.ce_med_admin_ident_id)
   JOIN (pdh
   WHERE pdh.dispense_hx_id=cmai.dispense_hx_id)
  ORDER BY ce.parent_event_id
  HEAD ce.parent_event_id
   nprodeventcount = 0, leventidx = locateval(lidx2,1,eventcnt,ce.parent_event_id,temp_rpt->qual[
    lidx2].med_event_id)
  DETAIL
   IF (leventidx > 0)
    nprodcount += 1
    IF (mod(nprodcount,10)=1)
     stat = alterlist(info_request->itemlist,(nprodcount+ 9)), stat = alterlist(items->qual,(
      nprodcount+ 9))
    ENDIF
    nprodeventcount += 1, stat = alterlist(temp_rpt->qual[leventidx].item_qual,nprodeventcount)
    IF (cmai.item_id > 0.0)
     ditemid = cmai.item_id
    ELSE
     ditemid = pdh.item_id
    ENDIF
    lidx = locateval(lidx2,1,nprodcount,ditemid,items->qual[lidx2].item_id)
    IF (lidx > 0)
     nprodcount -= 1
    ELSE
     info_request->itemlist[nprodcount].item_id = ditemid, items->qual[nprodcount].item_id = ditemid,
     lidx = nprodcount
    ENDIF
    temp_rpt->qual[leventidx].item_qual[nprodeventcount].item_idx = lidx, temp_rpt->qual[leventidx].
    item_qual[nprodeventcount].barcode_scanned = cmai.med_admin_barcode
   ENDIF
  WITH nocounter
 ;end select
 IF (nprodcount > 0)
  SET stat = alterlist(info_request->itemlist,nprodcount)
  SET stat = alterlist(items->qual,nprodcount)
  SET info_request->facility_cd = bscrequest->facility_cd
  SET info_request->pharm_type_cd = dpharm_type_cd
  SET info_request->med_all_ind = 1
  SET modify = nopredeclare
  EXECUTE rxa_get_item_info  WITH replace("REQUEST",info_request), replace("REPLY",info_reply)
  SET modify = predeclare
  FOR (prodidx = 1 TO size(info_reply->itemlist,5))
   SET lidx = locateval(lidx2,1,nprodcount,info_reply->itemlist[prodidx].item_id,items->qual[lidx2].
    item_id)
   IF (lidx > 0)
    SET items->qual[lidx].label_desc = info_reply->itemlist[prodidx].label_description
    IF (validate(info_reply->itemlist[prodidx].waste_charge_ind)=1)
     SET items->qual[lidx].waste_charge_ind = info_reply->itemlist[prodidx].waste_charge_ind
    ENDIF
   ENDIF
  ENDFOR
  CALL echorecord(items)
 ENDIF
 CALL echo("Looking up NDC DTA's")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(eventcnt)),
   clinical_event ce,
   discrete_task_assay dta
  PLAN (d)
   JOIN (ce
   WHERE (ce.parent_event_id= Outerjoin(temp_rpt->qual[d.seq].event_id)) )
   JOIN (dta
   WHERE dta.event_cd=ce.event_cd
    AND dta.concept_cki=sndc_cki)
  ORDER BY d.seq
  DETAIL
   IF (size(temp_rpt->qual[d.seq].item_qual,5) <= 0)
    temp_rpt->qual[d.seq].ndc = ce.result_val
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("****** TEMP_RPT RECORD ******")
 CALL echorecord(temp_rpt)
 SET sscriptstatus = "S"
#exit_script
 IF (size(temp_rpt->qual,5)=0)
  SELECT INTO  $OUTDEV
   "There is no data to output. Consider changing the prompt selections."
   FROM dummyt
   WITH nocounter, format, separator = " ",
    maxcol = 5000, append, formfeed = none
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   patient_name = substring(1,100,temp_rpt->qual[d.seq].name_full_formatted), mrn = substring(1,200,
    temp_rpt->qual[d.seq].mrn), fin = substring(1,200,temp_rpt->qual[d.seq].fin),
   facility = substring(1,40,uar_get_code_display( $FACILITY)), location = replace(replace(build2(
      trim(uar_get_code_display(temp_rpt->qual[d.seq].nurse_unit_cd),3)),char(13)," "),char(10)," "),
   order_sentence = substring(1,100,temp_rpt->qual[d.seq].dept_misc_line),
   catalog_description = substring(1,40,uar_get_code_display(temp_rpt->qual[d.seq].catalog_cd)),
   order_id = substring(1,40,cnvtstring(temp_rpt->qual[d.seq].order_id)), event_title = substring(1,
    40,temp_rpt->qual[d.seq].event_title_text),
   bag_number = substring(1,40,temp_rpt->qual[d.seq].bag_nbr), order_status = substring(1,40,
    uar_get_code_display(temp_rpt->qual[d.seq].order_status_cd)), nurse_waste = substring(1,40,
    temp_rpt->qual[d.seq].rn_waste_amount),
   waste_event_dt_tm = substring(1,40,format(temp_rpt->qual[d.seq].waste_event_dt_tm,";;Q")),
   med_event_id = substring(1,40,cnvtstring(temp_rpt->qual[d.seq].med_event_id)), waste_event_id =
   substring(1,40,cnvtstring(temp_rpt->qual[d.seq].event_id)),
   label_description = substring(1,200,parse_products(d.seq)), item_id = substring(1,100,sitemid),
   barcode_scanned = substring(1,200,sbarcodescanned),
   typed_ndc = substring(1,40,temp_rpt->qual[d.seq].ndc)
   FROM (dummyt d  WITH seq = size(temp_rpt->qual,5))
   WITH nocounter, format, separator = " ",
    maxcol = 5000, append, formfeed = none
  ;end select
 ENDIF
 CALL echo("******************************")
 CALL echo("Checking for errors...")
 CALL echo("******************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt += 1
   IF (errcnt > size(errorrec->err,5))
    SET stat = alterlist(errorrec->err,(errcnt+ 5))
   ENDIF
   SET errorrec->err[errcnt].err_code = errcode
   SET errorrec->err[errcnt].err_msg = errmsg
   SET errorrec->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errorrec->err,errcnt)
 IF (errcnt > 0)
  SET sscriptstatus = "F"
  CALL echorecord(errorrec)
 ELSEIF (eventcnt=0)
  SET sscriptstatus = "Z"
 ENDIF
 SET reply->status_data.status = sscriptstatus
 IF (((sscriptstatus="S") OR (sscriptstatus="Z")) )
  SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errorrec->err[1].err_msg
 ENDIF
 FREE RECORD errorrec
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("bsc_rpt_med_waste - Elapsed time in seconds: ",delapsedtime))
 SET reply->elapsed_time = delapsedtime
 CALL echo("****** REPLY RECORD ******")
 CALL echorecord(reply)
 CALL echo("********** END bsc_rpt_med_waste **********")
 SET modify = nopredeclare
 CALL echo("LastMod = 000")
 CALL echo("ModDate = 11/01/2016")
END GO
