CREATE PROGRAM dcp_get_orc_from_barcode:dba
 SET modify = predeclare
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 item_id = f8
     2 synonym_qual[*]
       3 synonym_id = f8
     2 form_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 event_cd = f8
     2 route_qual[*]
       3 route_cd = f8
     2 medproductqual[*]
       3 manf_item_id = f8
       3 label_description = vc
     2 oe_format_flag = i2
     2 synonym_id = f8
     2 identification_ind = i2
     2 med_type_flag = i2
   1 expiration_ind = i2
   1 barcode_type_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD barcode(
   1 format[*]
     2 barcode_type_cd = f8
     2 prefix = vc
     2 z_data = vc
 )
 RECORD search(
   1 qual_cnt = i4
   1 qual[*]
     2 search_string = vc
     2 ident_qual_cnt = i4
     2 ident_qual[*]
       3 identifier_type_cd = f8
 )
 RECORD temp_ident(
   1 ident_qual_cnt = i4
   1 ident_qual[*]
     2 identifier_type_cd = f8
 )
 DECLARE nndc = i2 WITH protect, constant(1)
 DECLARE nidentifier = i2 WITH protect, constant(2)
 DECLARE nmckesson = i2 WITH protect, constant(3)
 DECLARE nunknown = i2 WITH protect, constant(0)
 DECLARE nexpired_date = i2 WITH protect, constant(1)
 DECLARE ninvalid_date = i2 WITH protect, constant(2)
 DECLARE nvalid_date = i2 WITH protect, constant(3)
 DECLARE sbarcode = vc WITH protect, noconstant("")
 DECLARE dorgid = f8 WITH protect, noconstant(0.0)
 DECLARE dfacilitycd = f8 WITH protect, noconstant(0.0)
 DECLARE lbarcodelength = i4 WITH protect, noconstant(0)
 DECLARE sbarcodeprefix = vc WITH protect, noconstant("")
 DECLARE sbarcodezdata = vc WITH protect, noconstant("")
 DECLARE lnewmodelchk = i4 WITH protect, noconstant(0)
 DECLARE lbcfrmtchk = i4 WITH protect, noconstant(0)
 DECLARE cfacility = f8 WITH protect, noconstant(0.0)
 DECLARE cndc = f8 WITH protect, noconstant(0.0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE sndcreturned = vc WITH protect, noconstant("")
 DECLARE smckessonndc = vc WITH protect, noconstant("")
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE ntype = i2 WITH protect, noconstant(0)
 DECLARE cactive = f8 WITH protect, noconstant(0.0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 DECLARE checkreply(null) = null
 DECLARE getbarcodeformats(null) = null
 DECLARE convertreplytypes(null) = null
 SET dstat = uar_get_meaning_by_codeset(222,"FACILITY",1,cfacility)
 SET dstat = uar_get_meaning_by_codeset(11000,"NDC",1,cndc)
 SET dstat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET dstat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 FREE RECORD return_reply
 RECORD return_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 form_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 item_id = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 event_cd = f8
     2 synonym_id = f8
     2 route_qual[*]
       3 route_cd = f8
     2 synonym_qual[*]
       3 synonym_id = f8
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 already_retrieved = i2
   1 use_mltm_syn_match = i4
 )
 DECLARE getpocprefs(null) = null
 SUBROUTINE getpocprefs(null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetPOCPrefs Subroutine ******")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   SET pref_reply->use_mltm_syn_match = 0
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL echo("bad hPref, try logging in")
   ELSE
    SET status = uar_prefaddcontext(hpref,"default","system")
    IF (status != 1)
     CALL echo("bad context")
    ELSE
     SET status = uar_prefsetsection(hpref,"component")
     IF (status != 1)
      CALL echo("bad section")
     ELSE
      SET hgroup = uar_prefcreategroup()
      SET status = uar_prefsetgroupname(hgroup,"pocscanningpolicies")
      IF (status != 1)
       CALL echo("bad group name")
      ELSE
       SET status = uar_prefaddgroup(hpref,hgroup)
       SET status = uar_prefperform(hpref)
       SET hsection = uar_prefgetsectionbyname(hpref,"component")
       SET hgroup2 = uar_prefgetgroupbyname(hsection,"pocscanningpolicies")
       SET entrycount = 0
       SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
       IF (validate(debug_ind)
        AND debug_ind > 0)
        CALL echo(build("entry count:",entrycount))
       ENDIF
       SET idxentry = 0
       DECLARE entryname = c100
       DECLARE namelen = i4 WITH noconstant(100)
       FOR (idxentry = 0 TO (entrycount - 1))
         SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
         SET namelen = 100
         SET status = uar_prefgetentryname(hentry,entryname,namelen)
         IF (validate(debug_ind)
          AND debug_ind > 0)
          CALL echo(build("entry name: ",entryname))
         ENDIF
         SET attrcount = 0
         SET status = uar_prefgetentryattrcount(hentry,attrcount)
         IF (status != 1)
          CALL echo("bad entryAttrCount")
         ELSE
          IF (validate(debug_ind)
           AND debug_ind > 0)
           CALL echo(build("attrCount:",attrcount))
          ENDIF
          SET idxattr = 0
          FOR (idxattr = 0 TO (attrcount - 1))
            SET hattr = uar_prefgetentryattr(hentry,idxattr)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("hAttr:",hattr))
            ENDIF
            DECLARE attrname = c100
            SET namelen = 100
            SET status = uar_prefgetattrname(hattr,attrname,namelen)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("   attribute name: ",attrname))
            ENDIF
            SET valcount = 0
            SET status = uar_prefgetattrvalcount(hattr,valcount)
            SET idxval = 0
            FOR (idxval = 0 TO (valcount - 1))
              DECLARE valname = c100
              SET namelen = 100
              SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
              IF (validate(debug_ind)
               AND debug_ind > 0)
               CALL echo(build("      val:",valname))
              ENDIF
              IF (cnvtupper(trim(entryname,3))="USE_MLTM_SYN_MATCH")
               SET pref_reply->use_mltm_syn_match = cnvtint(trim(valname,3))
              ENDIF
            ENDFOR
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("*** USE_MLTM_SYN_MATCH preference = ",pref_reply->use_mltm_syn_match))
   SET pref_reply->already_retrieved = 1
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetPOCPrefs Subroutine ******")
 END ;Subroutine
 SUBROUTINE (finditembyidentifier(sidentifierin=vc,didentifiertypecd=f8,lsrchidx=i4,lnewmodelchkln=i4,
  dfacilitycd=f8) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering FindItemByIdentifier Subroutine ******")
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   DECLARE lreplycnt = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lrtecnt = i4 WITH protect, noconstant(0)
   DECLARE dstatus = i2 WITH private, noconstant(0)
   DECLARE cactive = f8 WITH protect, noconstant(0.0)
   DECLARE itemidx = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   SET dstatus = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
   CALL echo(build("dcp_get_orc_from_barcode - sIdentifierIn:",sidentifierin))
   CALL echo(build("dcp_get_orc_from_barcode - dIdentifierTypeCd:",didentifiertypecd))
   IF (textlen(sidentifierin) <= 0)
    RETURN
   ENDIF
   SET nobjstatus = checkprg("RX_GET_PRODUCT_SEARCH")
   CALL echo(build("dcp_get_orc_from_barcode - rx_get_product_search script object status:",
     nobjstatus))
   IF (nobjstatus > 0
    AND lnewmodelchkln=1)
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
     CALL echo(build("dcp_get_orc_from_barcode - lSrchIdx:",lsrchidx))
     CALL echorecord(search)
     SET dstat = alterlist(search_request->ident_qual,search->qual[lsrchidx].ident_qual_cnt)
     FOR (lcnt = 1 TO search->qual[lsrchidx].ident_qual_cnt)
       SET search_request->ident_qual[lcnt].identifier_type_cd = search->qual[lsrchidx].ident_qual[
       lcnt].identifier_type_cd
     ENDFOR
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
    CALL echo("dcp_get_orc_from_barcode - calling rx_get_product_search")
    SET modify = nopredeclare
    EXECUTE rx_get_product_search  WITH replace("REQUEST","SEARCH_REQUEST"), replace("REPLY",
     "SEARCH_REPLY")
    SET modify = predeclare
    IF ((search_reply->status_data.status="S"))
     SET litemcnt = size(search_reply->items,5)
     SET sndcreturned = search_reply->items[1].ndc
    ENDIF
    FREE RECORD search_request
    IF (size(search_reply->items,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(search_reply->items,5))),
       order_catalog_item_r ocir,
       route_form_r rfr,
       code_value cv,
       code_value_event_r cve,
       synonym_item_r sir,
       order_catalog_synonym ocs,
       item_definition id1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocir
       WHERE (ocir.item_id=search_reply->items[d.seq].item_id))
       JOIN (id1
       WHERE id1.item_id=ocir.item_id
        AND id1.active_ind > 0
        AND id1.active_status_cd=cactive)
       JOIN (rfr
       WHERE (rfr.form_cd= Outerjoin(search_reply->items[d.seq].form_cd)) )
       JOIN (cv
       WHERE (cv.code_value= Outerjoin(rfr.route_cd)) )
       JOIN (cve
       WHERE (cve.parent_cd= Outerjoin(ocir.catalog_cd)) )
       JOIN (sir
       WHERE (sir.item_id= Outerjoin(id1.item_id)) )
       JOIN (ocs
       WHERE (ocs.synonym_id= Outerjoin(sir.synonym_id))
        AND (ocs.active_ind> Outerjoin(0)) )
      ORDER BY ocir.item_id, rfr.route_cd, ocs.synonym_id
      HEAD REPORT
       lreplycnt = return_reply->qual_cnt
      HEAD ocir.item_id
       lsyncnt = 0, lrtecnt = 0, nsynsfound = 0,
       lreplycnt += 1, dstat = alterlist(return_reply->qual,lreplycnt), return_reply->qual[lreplycnt]
       .form_cd = search_reply->items[d.seq].form_cd,
       return_reply->qual[lreplycnt].strength = search_reply->items[d.seq].strength, return_reply->
       qual[lreplycnt].strength_unit_cd = search_reply->items[d.seq].strength_unit_cd, return_reply->
       qual[lreplycnt].item_id = search_reply->items[d.seq].item_id,
       return_reply->qual[lreplycnt].volume = search_reply->items[d.seq].volume, return_reply->qual[
       lreplycnt].volume_unit_cd = search_reply->items[d.seq].volume_unit_cd, return_reply->qual[
       lreplycnt].catalog_cd = ocir.catalog_cd,
       return_reply->qual[lreplycnt].event_cd = cve.event_cd, return_reply->qual[lreplycnt].
       synonym_id = ocir.synonym_id
      HEAD rfr.route_cd
       IF (cv.active_ind=1)
        lrtecnt += 1
        IF (lrtecnt > size(return_reply->qual[lreplycnt].route_qual,5))
         dstat = alterlist(return_reply->qual[lreplycnt].route_qual,(lrtecnt+ 9))
        ENDIF
        return_reply->qual[lreplycnt].route_qual[lrtecnt].route_cd = rfr.route_cd
       ENDIF
      HEAD ocs.synonym_id
       IF (ocs.synonym_id > 0
        AND nsynsfound=0)
        lsyncnt += 1, stat = alterlist(return_reply->qual[d.seq].synonym_qual,lsyncnt)
        IF (validate(debug_ind)
         AND debug_ind > 0)
         CALL echo(build("dcp_find_product_by_identifier - Add to synonym list - ocs.synonym_id:",ocs
          .synonym_id))
        ENDIF
        return_reply->qual[d.seq].synonym_qual[lsyncnt].synonym_id = ocs.synonym_id
       ENDIF
      FOOT  rfr.route_cd
       dstat = alterlist(return_reply->qual[lreplycnt].route_qual,lrtecnt), nsynsfound = 1
      FOOT  ocir.item_id
       IF (lsyncnt > 0)
        IF (validate(debug_ind)
         AND debug_ind > 0)
         CALL echo(build("dcp_find_product_by_identifier - Add to synonym list - ocir.synonym_id:",
          ocir.synonym_id))
        ENDIF
        lsyncnt += 1, stat = alterlist(return_reply->qual[d.seq].synonym_qual,lsyncnt), return_reply
        ->qual[d.seq].synonym_qual[lsyncnt].synonym_id = ocir.synonym_id
       ENDIF
      WITH nocounter
     ;end select
     SET return_reply->qual_cnt = lreplycnt
     IF ((return_reply->qual_cnt=0))
      CALL echo("*** FindItemByIdentifier - No order catalogs could be found")
     ENDIF
     IF (lsyncnt <= 0)
      IF ((pref_reply->already_retrieved != 1))
       CALL getpocprefs(null)
      ENDIF
      IF ((pref_reply->use_mltm_syn_match=1))
       CALL echo("*** FindItemByIdentifier - Look for CNUMS")
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(size(search_reply->items,5))),
         mltm_ndc_core_description mdc,
         mltm_mmdc_name_map mnm,
         order_catalog_synonym ocs,
         code_value_event_r cve,
         route_form_r rfr,
         code_value cv
        PLAN (d
         WHERE d.seq > 0)
         JOIN (mdc
         WHERE (mdc.ndc_formatted=search_reply->items[d.seq].ndc))
         JOIN (mnm
         WHERE mdc.main_multum_drug_code=mnm.main_multum_drug_code)
         JOIN (ocs
         WHERE concat("MUL.ORD-SYN!",cnvtstring(mnm.drug_synonym_id))=ocs.cki
          AND ocs.active_ind > 0)
         JOIN (cve
         WHERE (cve.parent_cd= Outerjoin(ocs.catalog_cd)) )
         JOIN (rfr
         WHERE (rfr.form_cd= Outerjoin(search_reply->items[d.seq].form_cd)) )
         JOIN (cv
         WHERE (cv.code_value= Outerjoin(rfr.route_cd)) )
        ORDER BY mdc.ndc_code, rfr.route_cd, ocs.synonym_id
        HEAD REPORT
         lreplycnt = return_reply->qual_cnt
        HEAD mdc.ndc_code
         lsyncnt = 0, lrtecnt = 0, nsynsfound = 0,
         itemidx = 0, itemidx = locateval(y,1,lreplycnt,search_reply->items[d.seq].item_id,
          return_reply->qual[y].item_id)
         IF (itemidx <= 0)
          lreplycnt += 1, stat = alterlist(return_reply->qual,lreplycnt), itemidx = lreplycnt
         ENDIF
         return_reply->qual[itemidx].form_cd = search_reply->items[d.seq].form_cd, return_reply->
         qual[itemidx].strength = search_reply->items[d.seq].strength, return_reply->qual[itemidx].
         strength_unit_cd = search_reply->items[d.seq].strength_unit_cd,
         return_reply->qual[itemidx].item_id = search_reply->items[d.seq].item_id, return_reply->
         qual[itemidx].volume = search_reply->items[d.seq].volume, return_reply->qual[itemidx].
         volume_unit_cd = search_reply->items[d.seq].volume_unit_cd,
         return_reply->qual[itemidx].catalog_cd = ocs.catalog_cd, return_reply->qual[itemidx].
         event_cd = cve.event_cd, return_reply->qual[itemidx].synonym_id = 0
        HEAD rfr.route_cd
         IF (cv.active_ind=1)
          lrtecnt += 1
          IF (lrtecnt > size(return_reply->qual[lreplycnt].route_qual,5))
           stat = alterlist(return_reply->qual[lreplycnt].route_qual,(lrtecnt+ 9))
          ENDIF
          return_reply->qual[lreplycnt].route_qual[lrtecnt].route_cd = rfr.route_cd
         ENDIF
        HEAD ocs.synonym_id
         IF (ocs.synonym_id > 0
          AND nsynsfound=0)
          IF (validate(debug_ind)
           AND debug_ind > 0)
           CALL echo(build("Add to synonym list - ocs.synonym_id:",ocs.synonym_id))
          ENDIF
          lsyncnt += 1, stat = alterlist(return_reply->qual[d.seq].synonym_qual,lsyncnt),
          return_reply->qual[d.seq].synonym_qual[lsyncnt].synonym_id = ocs.synonym_id
         ENDIF
        FOOT  rfr.route_cd
         stat = alterlist(return_reply->qual[lreplycnt].route_qual,lrtecnt), nsynsfound = 1
        WITH nocounter
       ;end select
      ENDIF
      SET return_reply->qual_cnt = lreplycnt
     ENDIF
    ENDIF
    FREE RECORD search_reply
   ENDIF
   IF (validate(debug_ind)
    AND debug_ind > 0)
    CALL echorecord(return_reply)
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting FindItemByIdentifier Subroutine ******")
 END ;Subroutine
 SELECT INTO "nl:"
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.person_id=0
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_section="FRMLRYMGMT"
   AND dmp.pref_name="NEW MODEL"
  DETAIL
   IF (dmp.pref_nbr=1)
    lnewmodelchk = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("dcp_get_orc_from_barcode - lNewModelChk:",lnewmodelchk))
 SET reply->status_data.status = "F"
 CALL getorgidandfacilitycd(request->facility_cd)
 IF (textlen(trim(request->ndc,3)) > 0)
  CALL finditembyidentifier(trim(request->ndc,3),cndc,0,lnewmodelchk,dfacilitycd)
  IF ((return_reply->qual_cnt <= 0))
   CALL finditembyndc(trim(request->ndc,3))
  ELSE
   SET ntype = nndc
   CALL convertreplytypes(null)
  ENDIF
  SET reply->barcode_type_ind = nndc
 ELSEIF (textlen(trim(request->identifier,3)) > 0
  AND (request->identifier_type_cd > 0))
  CALL finditembyidentifier(trim(request->identifier,3),request->identifier_type_cd,0,lnewmodelchk,
   dfacilitycd)
  SET ntype = nidentifier
  CALL convertreplytypes(null)
  SET reply->barcode_type_ind = nidentifier
 ELSE
  SET sbarcode = trim(request->barcode,3)
  SET lbarcodelength = textlen(sbarcode)
  IF (debug_ind)
   CALL echo(build("dcp_get_orc_from_barcode - sBarcode:",request->barcode))
   CALL echo(build("dcp_get_orc_from_barcode - lBarcodeLength:",lbarcodelength))
   CALL echo(build("dcp_get_orc_from_barcode - request:",request))
  ENDIF
  IF (lbarcodelength <= 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Barcode"
   GO TO exit_script
  ENDIF
  CALL echo(build("dcp_get_orc_from_barcode - Barcode:",sbarcode))
  IF (lnewmodelchk=1)
   CALL getprefix(sbarcode,sbarcodeprefix)
   CALL getzdata(sbarcode,sbarcodezdata)
   IF (((textlen(trim(sbarcodeprefix,3)) > 0) OR (textlen(trim(sbarcodezdata,3)) > 0)) )
    CALL processidentifier(sbarcodeprefix,sbarcodezdata,sbarcode)
   ELSE
    CALL processndc(sbarcode)
    CALL processmckesson(sbarcode)
    CALL processomnicell(sbarcode)
   ENDIF
   CALL processidentifier("","",sbarcode)
   FOR (lcnt = 1 TO search->qual_cnt)
     SET sndcreturned = ""
     CALL finditembyidentifier(search->qual[lcnt].search_string,0.0,lcnt,lnewmodelchk,dfacilitycd)
     IF ((return_reply->qual_cnt >= 1))
      IF (debug_ind)
       CALL echo("dcp_get_orc_from_barcode - ****** main_return_reply ******")
       CALL echorecord(return_reply)
      ENDIF
      IF (cnvtalphanum(sndcreturned)=cnvtalphanum(sbarcode))
       SET ntype = nndc
       SET reply->barcode_type_ind = nndc
      ELSEIF (cnvtalphanum(sndcreturned)=smckessonndc)
       SET ntype = nmckesson
       SET reply->barcode_type_ind = nmckesson
      ELSE
       SET ntype = nidentifier
       SET reply->barcode_type_ind = nidentifier
      ENDIF
      CALL convertreplytypes(null)
     ENDIF
   ENDFOR
  ENDIF
  IF ((reply->qual_cnt <= 0))
   IF (textlen(trim(smckessonndc,3)) > 0)
    CALL finditembyndc(smckessonndc)
   ELSE
    CALL finditembyndc(sbarcode)
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->qual_cnt > 0))
  CALL getiteminfo(reply->qual_cnt)
  CALL checkreply(null)
 ENDIF
#exit_script
 FREE RECORD barcode
 FREE RECORD search
 FREE RECORD temp_ident
 SET reply->status_data.status = "Z"
 IF ((reply->qual_cnt > 0))
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE (addtosearchstructure(ssearchstring=vc,didentifiertypecd=f8) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering AddToSearchStructure Subroutine ******")
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lprevcnt = i4 WITH protect, noconstant(0)
   IF (textlen(ssearchstring) > 0)
    SET lidx = locateval(lcnt,1,search->qual_cnt,ssearchstring,search->qual[lcnt].search_string)
    IF (lidx=0)
     SET search->qual_cnt += 1
     SET dstat = alterlist(search->qual,search->qual_cnt)
     SET lidx = search->qual_cnt
     SET search->qual[lidx].search_string = trim(ssearchstring,3)
    ENDIF
    SET lprevcnt = search->qual[lidx].ident_qual_cnt
    IF (didentifiertypecd > 0)
     SET search->qual[lidx].ident_qual_cnt = (lprevcnt+ 1)
     SET dstat = alterlist(search->qual[lidx].ident_qual,(lprevcnt+ 1))
     SET search->qual[lidx].ident_qual[(lprevcnt+ 1)].identifier_type_cd = didentifiertypecd
    ELSEIF ((temp_ident->ident_qual_cnt > 0))
     SET search->qual[lidx].ident_qual_cnt = (lprevcnt+ temp_ident->ident_qual_cnt)
     SET dstat = alterlist(search->qual[lidx].ident_qual,search->qual[lidx].ident_qual_cnt)
     FOR (lcnt = 1 TO temp_ident->ident_qual_cnt)
       SET search->qual[lidx].ident_qual[(lprevcnt+ lcnt)].identifier_type_cd = temp_ident->
       ident_qual[lcnt].identifier_type_cd
     ENDFOR
     SET dstat = alterlist(temp_ident->ident_qual,0)
    ENDIF
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting AddToSearchStructure Subroutine ******")
 END ;Subroutine
 SUBROUTINE checkreply(null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering CheckReply Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lmismatchind = i4 WITH protect, noconstant(0)
   IF ((reply->qual_cnt > 1))
    CALL echo("dcp_get_orc_from_barcode - Checking all items in reply")
    FOR (lcnt = 2 TO reply->qual_cnt)
      IF ((((reply->qual[1].catalog_cd != reply->qual[lcnt].catalog_cd)) OR ((((reply->qual[1].
      event_cd != reply->qual[lcnt].event_cd)) OR ((((reply->qual[1].form_cd != reply->qual[lcnt].
      form_cd)) OR ((((reply->qual[1].strength != reply->qual[lcnt].strength)) OR ((((reply->qual[1].
      strength_unit_cd != reply->qual[lcnt].strength_unit_cd)) OR ((((reply->qual[1].volume != reply
      ->qual[lcnt].volume)) OR ((reply->qual[1].volume_unit_cd != reply->qual[lcnt].volume_unit_cd)
      )) )) )) )) )) )) )
       CALL echo("dcp_get_orc_from_barcode - Found Mismatch")
       SET lmismatchind = 1
       SET lcnt = reply->qual_cnt
      ENDIF
    ENDFOR
    IF (lmismatchind=0)
     CALL echo("dcp_get_orc_from_barcode - Returning first item")
     SET reply->qual_cnt = 1
     SET dstat = alterlist(reply->qual,1)
     SET reply->barcode_type_ind = reply->qual[1].identification_ind
    ENDIF
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting CheckReply Subroutine ******")
 END ;Subroutine
 SUBROUTINE (determineidentifiertypes(sbcprefix=vc,sbczdata=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering DetermineIdentifierTypes Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lformatcnt = i4 WITH protect, noconstant(0)
   DECLARE lmatchcnt = i4 WITH protect, noconstant(0)
   DECLARE dbarcodetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE sidentmeaning = c12 WITH protect, noconstant("")
   DECLARE didenttypecd = f8 WITH protect, noconstant(0.0)
   SET dstat = alterlist(temp_ident->ident_qual,0)
   SET lformatcnt = size(barcode->format,5)
   FOR (lcnt = 1 TO lformatcnt)
     IF ((sbcprefix=barcode->format[lcnt].prefix)
      AND (sbczdata=barcode->format[lcnt].z_data))
      CALL echo(build(
        "dcp_get_orc_from_barcode - Successfully matched prefix and z-data with barcode format:",
        barcode->format[lcnt].barcode_type_cd))
      SET dbarcodetypecd = barcode->format[lcnt].barcode_type_cd
      SET sidentmeaning = trim(uar_get_code_meaning(dbarcodetypecd),3)
      SET dstat = uar_get_meaning_by_codeset(11000,sidentmeaning,1,didenttypecd)
      IF (didenttypecd > 0)
       SET lmatchcnt += 1
       SET dstat = alterlist(temp_ident->ident_qual,lmatchcnt)
       SET temp_ident->ident_qual[lmatchcnt].identifier_type_cd = didenttypecd
      ENDIF
     ENDIF
   ENDFOR
   SET temp_ident->ident_qual_cnt = lmatchcnt
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting DetermineIdentifierTypes Subroutine ******")
 END ;Subroutine
 SUBROUTINE (finditembyndc(sndcin=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering FindItemByNDC Subroutine ******")
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   SET nobjstatus = checkprg("DCP_GET_ORC_FROM_NDC")
   CALL echo(build("dcp_get_orc_from_barcode - dcp_get_orc_from_ndc script object status:",nobjstatus
     ))
   IF (nobjstatus > 0)
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE lcnt2 = i4 WITH protect, noconstant(0)
    DECLARE lqualcnt = i4 WITH protect, noconstant(0)
    DECLARE lroutecnt = i4 WITH protect, noconstant(0)
    DECLARE nhassynonyms = i2 WITH protect, noconstant(0)
    DECLARE lidx = i4 WITH protect, noconstant(0)
    DECLARE lidx1 = i4 WITH protect, noconstant(0)
    DECLARE lidx2 = i4 WITH protect, noconstant(0)
    DECLARE lsyncnt = i4 WITH protect, noconstant(0)
    DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
    DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
    DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
    DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
    RECORD ndc_request(
      1 ndc = vc
      1 facility_cd = f8
      1 debug_ind = i2
    )
    RECORD ndc_reply(
      1 orc_qual[*]
        2 catalog_cd = f8
        2 form_cd = f8
        2 strength = f8
        2 strength_unit_cd = f8
        2 item_id = f8
        2 volume = f8
        2 volume_unit_cd = f8
        2 event_cd = f8
        2 route_qual[*]
          3 route_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET ndc_request->ndc = sndcin
    SET ndc_request->facility_cd = dfacilitycd
    SET ndc_request->debug_ind = debug_ind
    CALL echo("dcp_get_orc_from_barcode - calling dcp_get_orc_from_ndc")
    SET modify = nopredeclare
    EXECUTE dcp_get_orc_from_ndc  WITH replace("REQUEST","NDC_REQUEST"), replace("REPLY","NDC_REPLY")
    SET modify = predeclare
    IF ((ndc_reply->status_data.status="S"))
     CALL echo(build("dcp_get_orc_from_barcode - Found NDC:",sndcin))
     SET lqualcnt = size(ndc_reply->orc_qual,5)
     SET dstat = alterlist(reply->qual,lqualcnt)
     SET reply->qual_cnt = lqualcnt
     FOR (lcnt = 1 TO lqualcnt)
       SET reply->qual[lcnt].catalog_cd = ndc_reply->orc_qual[lcnt].catalog_cd
       SET reply->qual[lcnt].form_cd = ndc_reply->orc_qual[lcnt].form_cd
       SET reply->qual[lcnt].strength = ndc_reply->orc_qual[lcnt].strength
       SET reply->qual[lcnt].strength_unit_cd = ndc_reply->orc_qual[lcnt].strength_unit_cd
       SET reply->qual[lcnt].item_id = ndc_reply->orc_qual[lcnt].item_id
       SET reply->qual[lcnt].volume = ndc_reply->orc_qual[lcnt].volume
       SET reply->qual[lcnt].volume_unit_cd = ndc_reply->orc_qual[lcnt].volume_unit_cd
       SET reply->qual[lcnt].event_cd = ndc_reply->orc_qual[lcnt].event_cd
       SET lroutecnt = size(ndc_reply->orc_qual[lcnt].route_qual,5)
       SET dstat = alterlist(reply->qual[lcnt].route_qual,lroutecnt)
       FOR (lcnt2 = 1 TO lroutecnt)
         SET reply->qual[lcnt].route_qual[lcnt2].route_cd = ndc_reply->orc_qual[lcnt].route_qual[
         lcnt2].route_cd
       ENDFOR
     ENDFOR
     IF ((reply->qual_cnt > 0))
      SET nhassynonyms = 0
      SELECT INTO "nl:"
       FROM synonym_item_r sir,
        order_catalog_synonym ocs
       PLAN (sir
        WHERE expand(lidx1,1,reply->qual_cnt,sir.item_id,reply->qual[lidx1].item_id))
        JOIN (ocs
        WHERE ocs.synonym_id=sir.synonym_id
         AND ocs.active_ind > 0)
       ORDER BY sir.item_id
       HEAD sir.item_id
        lidx = locateval(lidx2,1,reply->qual_cnt,sir.item_id,reply->qual[lidx2].item_id), lsyncnt = 0
       DETAIL
        IF (debug_ind)
         CALL echo(build("Add to synonym list - sir.synonym_id:",sir.synonym_id))
        ENDIF
        lsyncnt += 1, nhassynonyms = 1, dstat = alterlist(reply->qual[lidx].synonym_qual,lsyncnt),
        reply->qual[lidx].synonym_qual[lsyncnt].synonym_id = sir.synonym_id
       WITH nocounter
      ;end select
      IF ((pref_reply->already_retrieved != 1))
       CALL getpocprefs(null)
      ENDIF
      IF ((pref_reply->use_mltm_syn_match=1))
       CALL echo("*** dcp_get_orc_from_barcode - Look for CNUMS")
       SELECT INTO "nl:"
        FROM mltm_ndc_core_description mdc,
         mltm_mmdc_name_map mnm,
         med_identifier mdi,
         order_catalog_synonym ocs,
         order_catalog_item_r ocir
        PLAN (mdi
         WHERE expand(lidx1,1,reply->qual_cnt,mdi.item_id,reply->qual[lidx1].item_id)
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
          AND ocs.active_ind > 0)
        ORDER BY mdi.item_id
        HEAD mdi.item_id
         lidx = locateval(lidx2,1,reply->qual_cnt,mdi.item_id,reply->qual[lidx2].item_id), lsyncnt =
         size(reply->qual[lidx].synonym_qual,5)
         IF (lsyncnt=0)
          nhassynonyms = 0
         ENDIF
        DETAIL
         IF (nhassynonyms=0)
          IF (debug_ind)
           CALL echo(build("Add to synonym list - ocs.synonym_id:",ocs.synonym_id))
          ENDIF
          lsyncnt += 1, stat = alterlist(reply->qual[lidx1].synonym_qual,lsyncnt), reply->qual[lidx1]
          .synonym_qual[lsyncnt].synonym_id = ocs.synonym_id
         ENDIF
        FOOT  mdi.item_id
         IF (lsyncnt > 0)
          IF (debug_ind)
           CALL echo(build("Add to synonym list - ocir.synonym_id:",ocir.synonym_id))
          ENDIF
          lsyncnt += 1, stat = alterlist(reply->qual[lidx1].synonym_qual,lsyncnt), reply->qual[lidx1]
          .synonym_qual[lsyncnt].synonym_id = ocir.synonym_id
         ENDIF
        WITH nocounter
       ;end select
      ELSEIF (nhassynonyms <= 0)
       CALL echo("*** dcp_get_orc_from_barcode - use_mltm_syn_match pref=OFF and nHasSynonyms=0")
      ELSE
       CALL echo("*** dcp_get_orc_from_barcode - use_mltm_syn_match pref=OFF and nHasSynonyms>0")
       SET lidx = 0
       SELECT INTO "nl:"
        FROM order_catalog_item_r ocir
        PLAN (ocir
         WHERE expand(lidx1,1,reply->qual_cnt,ocir.item_id,reply->qual[lidx1].item_id))
        ORDER BY ocir.item_id
        HEAD ocir.item_id
         lidx = locateval(lidx2,1,reply->qual_cnt,ocir.item_id,reply->qual[lidx2].item_id), lsyncnt
          = size(reply->qual[lidx].synonym_qual,5)
        DETAIL
         IF (lsyncnt > 0)
          IF (debug_ind)
           CALL echo(build("Add to synonym list - ocir.synonym_id:",ocir.synonym_id))
          ENDIF
          lsyncnt += 1, dstat = alterlist(reply->qual[lidx].synonym_qual,lsyncnt), reply->qual[lidx].
          synonym_qual[lsyncnt].synonym_id = ocir.synonym_id
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
     CALL echorecord(ndc_reply)
     CALL echorecord(reply)
    ENDIF
    FREE RECORD ndc_request
    FREE RECORD ndc_reply
   ENDIF
   IF ((reply->qual_cnt > 0))
    CALL echo(build("####FindItemByNDC - reply->qual_cnt:",reply->qual_cnt))
    IF (textlen(trim(smckessonndc,3)) > 0)
     SET reply->barcode_type_ind = nmckesson
     SET ntype = nmckesson
     CALL populatebarcodeindicator(ntype)
    ELSE
     SET reply->barcode_type_ind = nndc
     SET ntype = nndc
     CALL populatebarcodeindicator(ntype)
    ENDIF
   ENDIF
   CALL echo(build("####FindItemByNDC - nType:",ntype))
   CALL echo("**********************after set identification_ind *************************")
   CALL echorecord(reply)
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting FindItemByNDC Subroutine ******")
 END ;Subroutine
 SUBROUTINE getbarcodeformats(null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetBarcodeFormats Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   IF (lbcfrmtchk=0)
    SET lbcfrmtchk = 1
    IF (dorgid > 0)
     SELECT INTO "nl:"
      FROM org_barcode_org obo,
       org_barcode_format obf
      PLAN (obo
       WHERE obo.scan_organization_id IN (0, dorgid))
       JOIN (obf
       WHERE ((obf.organization_id=obo.label_organization_id
        AND obo.scan_organization_id > 0) OR (obf.organization_id=dorgid
        AND obo.scan_organization_id=0)) )
      HEAD REPORT
       lcnt = 0
      DETAIL
       IF (uar_get_code_meaning(obf.barcode_type_cd) IN ("CDM", "DESC", "DESC_SHORT", "GENERIC_NAME",
       "BRAND_NAME",
       "PYXIS", "UB92", "HCPCS", "RX MISC1", "RX MISC2",
       "RX MISC3", "RX MISC4", "RX MISC5", "RX DEVICE1", "RX DEVICE2",
       "RX DEVICE3", "RX DEVICE4", "RX DEVICE5"))
        lcnt += 1
        IF (mod(lcnt,10)=1)
         dstat = alterlist(barcode->format,(lcnt+ 9))
        ENDIF
        barcode->format[lcnt].barcode_type_cd = obf.barcode_type_cd, barcode->format[lcnt].prefix =
        trim(obf.prefix), barcode->format[lcnt].z_data = trim(obf.z_data)
       ENDIF
      FOOT REPORT
       dstat = alterlist(barcode->format,lcnt)
      WITH nocounter
     ;end select
     IF (lcnt=0)
      CALL echo(concat("*** No identifier barcode formats qualified for organization_id: ",cnvtstring
        (dorgid,20,2)))
      RETURN
     ENDIF
    ENDIF
    CALL echorecord(barcode)
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetBarcodeFormats Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getiteminfo(litemcntin=i4) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetItemInfo Subroutine ******")
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   SET nobjstatus = checkprg("RXA_GET_ITEM_INFO")
   CALL echo(build("dcp_get_orc_from_barcode - rxa_get_item_info script object status:",nobjstatus))
   IF (nobjstatus > 0
    AND lnewmodelchk=1)
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
    DECLARE lidx = i4 WITH protect, noconstant(0)
    DECLARE lqualcnt = i4 WITH protect, noconstant(0)
    SET dstat = alterlist(info_request->itemlist,litemcntin)
    FOR (lcnt = 1 TO litemcntin)
      SET info_request->itemlist[lcnt].item_id = reply->qual[lcnt].item_id
    ENDFOR
    SET info_request->pharm_type_cd = cinpatient
    SET info_request->med_def_ind = 1
    SET info_request->med_dispense_ind = 1
    SET info_request->med_product_ind = 1
    SET info_request->med_product_ident_ind = 1
    CALL echo("dcp_get_orc_from_barcode - calling rxa_get_item_info")
    SET modify = nopredeclare
    EXECUTE rxa_get_item_info  WITH replace("REQUEST","INFO_REQUEST"), replace("REPLY","INFO_REPLY")
    SET modify = predeclare
    IF ((info_reply->status_data.status="S"))
     FOR (lcnt = 1 TO size(info_reply->itemlist,5))
       SET reply->qual[lcnt].form_cd = info_reply->itemlist[lcnt].form_cd
       SET reply->qual[lcnt].strength = info_reply->itemlist[lcnt].med_disp_strength
       SET reply->qual[lcnt].strength_unit_cd = info_reply->itemlist[lcnt].med_disp_strength_unit_cd
       SET reply->qual[lcnt].volume = info_reply->itemlist[lcnt].med_disp_volume
       SET reply->qual[lcnt].volume_unit_cd = info_reply->itemlist[lcnt].med_disp_volume_unit_cd
       SET lqualcnt = size(info_reply->itemlist[lcnt].medproductqual,5)
       SET dstat = alterlist(reply->qual[lcnt].medproductqual,lqualcnt)
       FOR (lidx = 1 TO lqualcnt)
        SET reply->qual[lcnt].medproductqual[lidx].manf_item_id = info_reply->itemlist[lcnt].
        medproductqual[lidx].manf_item_id
        SET reply->qual[lcnt].medproductqual[lidx].label_description = info_reply->itemlist[lcnt].
        medproductqual[lidx].label_description
       ENDFOR
       SET reply->qual[lcnt].oe_format_flag = info_reply->itemlist[lcnt].oe_format_flag
       SET reply->qual[lcnt].synonym_id = info_reply->itemlist[lcnt].synonym_id
       SET reply->qual[lcnt].med_type_flag = info_reply->itemlist[lcnt].med_type_flag
     ENDFOR
    ENDIF
    FREE RECORD info_request
    FREE RECORD info_reply
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetItemInfo Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getorgidandfacilitycd(dlocationcd=f8) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetOrgIdAndFacilityCd Subroutine ******")
   SELECT INTO "nl:"
    FROM location l
    WHERE l.location_cd=dlocationcd
     AND l.active_ind=1
    DETAIL
     dorgid = l.organization_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(concat("*** Organization not found for location_cd: ",cnvtstring(dlocationcd,20,2)))
   ELSEIF (curqual > 1)
    SET dorgid = 0
    CALL echo(concat("*** Multiple orgs found for location_cd: ",cnvtstring(dlocationcd,20,2)))
   ENDIF
   IF (uar_get_code_meaning(dlocationcd)="FACILITY")
    SET dfacilitycd = dlocationcd
   ELSE
    DECLARE nobjstatus = i2 WITH private, noconstant(0)
    SET nobjstatus = checkprg("DCP_GET_LOC_PARENT_HIERARCHY")
    CALL echo(build("dcp_get_orc_from_barcode - dcp_get_loc_parent_hierarchy script object status:",
      nobjstatus))
    IF (nobjstatus > 0)
     RECORD loc_request(
       1 locations[*]
         2 location_cd = f8
       1 skip_org_security_ind = i2
     )
     RECORD loc_reply(
       1 facilities[*]
         2 facility_cd = f8
         2 facility_disp = c40
         2 facility_desc = c60
         2 buildings[*]
           3 building_cd = f8
           3 building_disp = c40
           3 building_desc = c60
           3 units[*]
             4 unit_cd = f8
             4 unit_disp = c40
             4 unit_desc = c60
             4 rooms[*]
               5 room_cd = f8
               5 room_disp = c40
               5 room_desc = c60
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET dstat = alterlist(loc_request->locations,1)
     SET loc_request->locations[1].location_cd = dlocationcd
     CALL echo("dcp_get_orc_from_barcode - calling dcp_get_loc_parent_hierarchy")
     SET modify = nopredeclare
     EXECUTE dcp_get_loc_parent_hierarchy  WITH replace("REQUEST","LOC_REQUEST"), replace("REPLY",
      "LOC_REPLY")
     SET modify = predeclare
     IF ((loc_reply->status_data.status="S"))
      DECLARE lsize = i4 WITH protect, noconstant(0)
      SET lsize = size(loc_reply->facilities,5)
      IF (lsize=1)
       SET dfacilitycd = loc_reply->facilities[1].facility_cd
      ELSEIF (lsize=0)
       CALL echo(concat("*** Facility not found for location_cd: ",cnvtstring(dlocationcd,20,2)))
      ELSE
       CALL echo(concat("*** Multiple facilities found for location_cd: ",cnvtstring(dlocationcd,20,2
          )))
      ENDIF
     ENDIF
     FREE RECORD temp
     FREE RECORD loc_request
     FREE RECORD loc_reply
    ENDIF
   ENDIF
   CALL echo(concat("dcp_get_orc_from_barcode - dOrgId: ",cnvtstring(dorgid,20,2)))
   CALL echo(concat("dcp_get_orc_from_barcode - dFacilityCd: ",cnvtstring(dfacilitycd,20,2)))
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetOrgIdAndFacilityCd Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getprefix(sbarcodein=vc,sprefix=vc(ref)) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetPrefix Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE schar = c1 WITH protect, noconstant("")
   FOR (lcnt = 1 TO textlen(sbarcodein))
    SET schar = substring(lcnt,1,sbarcodein)
    IF (isnumeric(schar)=1)
     SET sprefix = substring(1,(lcnt - 1),sbarcodein)
     SET lcnt = textlen(sbarcodein)
    ENDIF
   ENDFOR
   CALL echo(build("dcp_get_orc_from_barcode - Prefix:",sprefix))
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetPrefix Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getzdata(sbarcodein=vc,szdata=vc(ref)) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering GetZData Subroutine ******")
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET lpos = findstring("/Z",sbarcodein)
   IF (lpos > 0)
    SET szdata = substring((lpos+ 2),(textlen(sbarcodein) - (lpos+ 1)),sbarcodein)
   ENDIF
   CALL echo(build("dcp_get_orc_from_barcode - Z-data:",szdata))
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting GetZData Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processidentifier(sbcprefix=vc,sbczdata=vc,sidentifierin=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ProcessIdentifier Subroutine ******")
   DECLARE dbarcodetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE lprefixlength = i4 WITH protect, noconstant(0)
   DECLARE lzdatalength = i4 WITH protect, noconstant(0)
   DECLARE sidentifier = vc WITH protect, noconstant("")
   DECLARE lidentlength = i4 WITH protect, noconstant(0)
   CALL getbarcodeformats(null)
   IF (size(barcode->format,5) > 0)
    CALL determineidentifiertypes(sbcprefix,sbczdata)
    IF ((temp_ident->ident_qual_cnt > 0))
     SET sidentifier = sidentifierin
     SET lprefixlength = textlen(trim(sbcprefix))
     SET lzdatalength = textlen(trim(sbczdata))
     IF (((lprefixlength > 0) OR (lzdatalength > 0)) )
      SET lidentlength = (textlen(trim(sidentifierin,3)) - lprefixlength)
      IF (lzdatalength > 0)
       SET lidentlength = ((lidentlength - lzdatalength) - 2)
      ENDIF
      SET sidentifier = substring((lprefixlength+ 1),lidentlength,sidentifierin)
     ENDIF
     CALL addtosearchstructure(sidentifier,0.0)
    ENDIF
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ProcessIdentifier Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processmckesson(sbarcodein=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ProcessMcKesson Subroutine ******")
   DECLARE sndc = c14 WITH protect, noconstant("")
   DECLARE sformatind = c1 WITH protect, noconstant("")
   DECLARE sexpdate = c6 WITH protect, noconstant("")
   IF (isnumeric(sbarcodein)=1
    AND lbarcodelength IN (16, 18)
    AND substring(1,1,sbarcodein)="3")
    SET sformatind = substring(12,1,sbarcodein)
    IF (sformatind="1")
     SET sndc = build("0",substring(2,10,sbarcodein))
    ELSEIF (sformatind="2")
     SET sndc = build(substring(2,5,sbarcodein),"0",substring(7,5,sbarcodein))
    ELSEIF (sformatind="3")
     SET sndc = build(substring(2,9,sbarcodein),"0",substring(11,1,sbarcodein))
    ENDIF
    SET sexpdate = trim(substring(13,(lbarcodelength - 12),sbarcodein))
    CALL validateexpirationdate(sexpdate)
    SET smckessonndc = sndc
    CALL addtosearchstructure(sndc,cndc)
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ProcessMcKesson Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processndc(sbarcodein=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ProcessNDC Subroutine ******")
   IF (isnumeric(cnvtalphanum(sbarcodein))=1)
    CALL addtosearchstructure(sbarcodein,cndc)
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ProcessNDC Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processomnicell(sbarcodein=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ProcessOmnicell Subroutine ******")
   IF (isnumeric(sbarcodein)=1
    AND lbarcodelength=10
    AND substring(1,1,sbarcodein) IN ("0", "1"))
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE schar = c1 WITH protect, noconstant("")
    DECLARE nvalid = i2 WITH protect, noconstant(1)
    FOR (lcnt = 6 TO lbarcodelength)
     SET schar = substring(lcnt,1,sbarcodein)
     IF ( NOT (schar IN ("0", "1")))
      SET nvalid = 0
      SET lcnt = lbarcodelength
     ENDIF
    ENDFOR
    IF (nvalid=1)
     CALL processidentifier("","",substring(2,4,sbarcodein))
    ENDIF
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ProcessOmnicell Subroutine ******")
 END ;Subroutine
 SUBROUTINE (validateexpirationdate(sexpdatein=vc) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ValidateExpirationDate Subroutine ******")
   DECLARE ldatelength = i4 WITH protect, noconstant(0)
   DECLARE lmonth = i4 WITH protect, noconstant(0)
   DECLARE lday = i4 WITH protect, noconstant(0)
   DECLARE ldaysinmonth = i4 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE syear = c2 WITH protect, noconstant("")
   DECLARE scentury = c2 WITH protect, noconstant("")
   DECLARE scurdate = c8 WITH protect, noconstant("")
   DECLARE sexpiredate = c8 WITH protect, noconstant("")
   SET ldatelength = textlen(trim(sexpdatein))
   IF (isnumeric(sexpdatein)=1
    AND ldatelength IN (4, 6))
    SET syear = substring((ldatelength - 1),2,sexpdatein)
    SET lyear = cnvtint(syear)
    SET scentury = "20"
    IF (lyear >= 90)
     SET scentury = "19"
    ENDIF
    SET lyear = cnvtint(concat(scentury,syear))
    SET lmonth = cnvtint(substring(1,2,sexpdatein))
    IF (((lmonth < 1) OR (lmonth > 12)) )
     SET reply->expiration_ind = ninvalid_date
    ELSEIF (ldatelength=6)
     SET lday = cnvtint(substring(3,2,sexpdatein))
     IF (lmonth IN (1, 3, 5, 7, 8,
     10, 12))
      SET ldaysinmonth = 31
     ELSEIF (lmonth IN (4, 6, 9, 11))
      SET ldaysinmonth = 30
     ELSEIF (lmonth=2)
      SET ldaysinmonth = 28
      IF (mod(lyear,4)=0)
       SET ldaysinmonth = 29
      ENDIF
     ENDIF
     IF (((lday < 1) OR (lday > ldaysinmonth)) )
      SET reply->expiration_ind = ninvalid_date
     ENDIF
    ENDIF
    IF ((reply->expiration_ind=nunknown))
     IF (ldatelength=4)
      SET scurdate = build(year(curdate),format(month(curdate),"##;P0"))
      SET sexpiredate = build(scentury,syear,substring(1,2,sexpdatein))
     ELSEIF (ldatelength=6)
      SET scurdate = build(year(curdate),format(month(curdate),"##;P0"),format(day(curdate),"##;P0"))
      SET sexpiredate = build(scentury,syear,substring(1,2,sexpdatein),substring(3,2,sexpdatein))
     ENDIF
     CALL echo(build("dcp_get_orc_from_barcode - sCurDate:",scurdate))
     CALL echo(build("dcp_get_orc_from_barcode - sExpireDate:",sexpiredate))
     SET reply->expiration_ind = nvalid_date
     IF (trim(scurdate) > trim(sexpiredate))
      SET reply->expiration_ind = nexpired_date
      CALL echo("dcp_get_orc_from_barcode - set expiration indicator")
     ENDIF
    ENDIF
   ELSE
    SET reply->expiration_ind = ninvalid_date
    CALL echo("dcp_get_orc_from_barcode - Invalid Expiration Date Format")
   ENDIF
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ValidateExpirationDate Subroutine ******")
 END ;Subroutine
 SUBROUTINE (populatebarcodeindicator(ntype=i2) =null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering PopulateBarcodeIndicator Subroutine ******")
   FOR (y = 1 TO reply->qual_cnt)
     SET reply->qual[y].identification_ind = ntype
   ENDFOR
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting PopulateBarcodeIndicator Subroutine ******")
 END ;Subroutine
 SUBROUTINE convertreplytypes(null)
   CALL echo("dcp_get_orc_from_barcode - ****** Entering ConvertReplyTypes Subroutine ******")
   DECLARE reply_size = i2 WITH noconstant(0)
   DECLARE route_size = i2 WITH noconstant(0)
   DECLARE synonym_size = i2 WITH noconstant(0)
   SET reply_size = size(return_reply->qual,5)
   SET dstat = alterlist(reply->qual,reply_size)
   SET reply->qual_cnt = return_reply->qual_cnt
   FOR (y = 1 TO reply_size)
     SET reply->qual[y].catalog_cd = return_reply->qual[y].catalog_cd
     SET reply->qual[y].form_cd = return_reply->qual[y].form_cd
     SET reply->qual[y].strength = return_reply->qual[y].strength
     SET reply->qual[y].strength_unit_cd = return_reply->qual[y].strength_unit_cd
     SET reply->qual[y].item_id = return_reply->qual[y].item_id
     SET reply->qual[y].volume = return_reply->qual[y].volume
     SET reply->qual[y].volume_unit_cd = return_reply->qual[y].volume_unit_cd
     SET reply->qual[y].event_cd = return_reply->qual[y].event_cd
     SET reply->qual[y].identification_ind = ntype
     SET route_size = size(return_reply->qual[y].route_qual,5)
     SET dstat = alterlist(reply->qual[y].route_qual,route_size)
     FOR (cnt = 1 TO route_size)
       SET reply->qual[y].route_qual[cnt].route_cd = return_reply->qual[y].route_qual[cnt].route_cd
     ENDFOR
     SET synonym_size = size(return_reply->qual[y].synonym_qual,5)
     SET dstat = alterlist(reply->qual[y].synonym_qual,synonym_size)
     FOR (cnt = 1 TO synonym_size)
       SET reply->qual[y].synonym_qual[cnt].synonym_id = return_reply->qual[y].synonym_qual[cnt].
       synonym_id
     ENDFOR
   ENDFOR
   CALL echorecord(reply)
   CALL echo("dcp_get_orc_from_barcode - ****** Exiting ConvertReplyTypes Subroutine ******")
 END ;Subroutine
 SET last_mod = "012"
 SET mod_date = "10/16/2006"
 SET modify = nopredeclare
END GO
