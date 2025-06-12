CREATE PROGRAM dcp_get_orc_from_ndc:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 ENDIF
 FREE RECORD temp_reply
 RECORD temp_reply(
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
 )
 RECORD temp(
   1 qual_ndc[*]
     2 ndc = c11
     2 ndc_no_pk = c10
     2 mmdc = i4
 )
 RECORD temp_mmdc(
   1 qual_mmdc[*]
     2 mmdc = i4
 )
 DECLARE v500_ind = i2
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
 DECLARE ndc_cnt = i4 WITH noconstant(0)
 DECLARE mmdc_cnt = i4 WITH noconstant(0)
 DECLARE char_cnt = i4 WITH noconstant(0)
 DECLARE orc_cnt = i4 WITH noconstant(0)
 DECLARE temp_ndc1 = c37 WITH noconstant(fillstring(37," "))
 DECLARE temp_ndc2 = c11 WITH noconstant(fillstring(11," "))
 DECLARE temp_ndc3 = c11 WITH noconstant(fillstring(11," "))
 DECLARE temp_pk = c2 WITH noconstant(fillstring(2," "))
 DECLARE mmdc_cki = vc WITH noconstant(fillstring(255," "))
 DECLARE lroutecnt = i4 WITH protect, noconstant(0)
 DECLARE mismatch_ind = i2 WITH noconstant(0)
 DECLARE lnewmodelchk = i4 WITH protect, noconstant(0)
 DECLARE routecnt = i4 WITH noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE cndc = f8 WITH protect, noconstant(0.0)
 DECLARE cmed_def = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE sndc = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE reply_size = i2 WITH noconstant(0)
 DECLARE return_reply_size = i2 WITH noconstant(0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE sndcreturned = vc WITH protect, noconstant("")
 DECLARE cactive = f8 WITH protect, noconstant(0.0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
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
 SET reply->status_data.status = "F"
 SET temp_ndc1 = trim(request->ndc)
 SET char_cnt = textlen(trim(temp_ndc1))
 SET stat = uar_get_meaning_by_codeset(11000,"NDC",1,cndc)
 SET stat = uar_get_meaning_by_codeset(11001,"MED_DEF",1,cmed_def)
 SET stat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 IF (char_cnt=10)
  SET temp_ndc2 = temp_ndc1
 ELSEIF (char_cnt=11)
  SET temp_ndc2 = temp_ndc1
 ELSEIF (char_cnt=12)
  SET temp_ndc2 = substring(2,10,temp_ndc1)
 ELSEIF (char_cnt=13)
  SET temp_ndc2 = substring(3,10,temp_ndc1)
 ELSEIF (char_cnt=14)
  SET temp_ndc2 = substring(4,10,temp_ndc1)
 ELSEIF (char_cnt=15)
  SET temp_ndc2 = substring(4,10,temp_ndc1)
 ELSEIF (char_cnt=16)
  SET temp_ndc2 = substring(6,10,temp_ndc1)
 ELSEIF (((char_cnt=35) OR (((char_cnt=37) OR (((char_cnt=32) OR (char_cnt=33)) )) )) )
  SET temp_ndc2 = substring(6,10,temp_ndc1)
 ENDIF
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
 ;end select
 SET char_cnt = textlen(trim(temp_ndc2))
 IF (char_cnt=10)
  SET temp_ndc3 = build("0",trim(temp_ndc2))
  SET ndc_cnt += 1
  SET stat = alterlist(temp->qual_ndc,ndc_cnt)
  SET temp->qual_ndc[ndc_cnt].ndc = temp_ndc3
  SET temp->qual_ndc[ndc_cnt].ndc_no_pk = build(substring(1,9,temp_ndc3),"*")
  SET temp_ndc3 = build(substring(1,5,temp_ndc2),"0",substring(6,5,temp_ndc2))
  SET ndc_cnt += 1
  SET stat = alterlist(temp->qual_ndc,ndc_cnt)
  SET temp->qual_ndc[ndc_cnt].ndc = temp_ndc3
  SET temp->qual_ndc[ndc_cnt].ndc_no_pk = build(substring(1,9,temp_ndc3),"*")
  SET temp_ndc3 = build(substring(1,9,temp_ndc2),"0",substring(10,1,temp_ndc2))
  SET ndc_cnt += 1
  SET stat = alterlist(temp->qual_ndc,ndc_cnt)
  SET temp->qual_ndc[ndc_cnt].ndc = temp_ndc3
  SET temp->qual_ndc[ndc_cnt].ndc_no_pk = build(substring(1,9,temp_ndc3),"*")
 ENDIF
 IF (char_cnt=11)
  SET temp_ndc3 = temp_ndc2
  SET ndc_cnt += 1
  SET stat = alterlist(temp->qual_ndc,ndc_cnt)
  SET temp->qual_ndc[ndc_cnt].ndc = temp_ndc3
  SET temp->qual_ndc[ndc_cnt].ndc_no_pk = build(substring(1,9,temp_ndc3),"*")
 ENDIF
 FOR (x = 1 TO ndc_cnt)
   SET stat = alterlist(return_reply->qual,0)
   CALL finditembyidentifier(temp->qual_ndc[x].ndc,cndc,0,lnewmodelchk,request->facility_cd)
   SET reply_size = size(reply->orc_qual,5)
   SET return_reply_size = size(return_reply->qual,5)
   SET stat = alterlist(reply->orc_qual,(return_reply_size+ reply_size))
   FOR (y = 1 TO return_reply_size)
     SET reply->orc_qual[(reply_size+ y)].catalog_cd = return_reply->qual[y].catalog_cd
     SET reply->orc_qual[(reply_size+ y)].form_cd = return_reply->qual[y].form_cd
     SET reply->orc_qual[(reply_size+ y)].strength = return_reply->qual[y].strength
     SET reply->orc_qual[(reply_size+ y)].strength_unit_cd = return_reply->qual[y].strength_unit_cd
     SET reply->orc_qual[(reply_size+ y)].item_id = return_reply->qual[y].item_id
     SET reply->orc_qual[(reply_size+ y)].volume = return_reply->qual[y].volume
     SET reply->orc_qual[(reply_size+ y)].volume_unit_cd = return_reply->qual[y].volume_unit_cd
     SET reply->orc_qual[(reply_size+ y)].event_cd = return_reply->qual[y].event_cd
     SET lroutecnt = size(return_reply->qual[y].route_qual,5)
     CALL echo(build("lRouteCnt:",lroutecnt))
     SET stat = alterlist(reply->orc_qual[(reply_size+ y)].route_qual,lroutecnt)
     FOR (cnt = 1 TO lroutecnt)
       SET reply->orc_qual[(reply_size+ y)].route_qual[cnt].route_cd = return_reply->qual[y].
       route_qual[cnt].route_cd
     ENDFOR
   ENDFOR
   SET reply_size = size(reply->orc_qual,5)
 ENDFOR
 FREE RECORD return_reply
 IF (reply_size > 0)
  GO TO exit_prg
 ENDIF
 FOR (x = 1 TO ndc_cnt)
   IF (v500_ind=1)
    SELECT INTO "nl:"
     ncd.main_multum_drug_code
     FROM mltm_ndc_core_description ncd
     PLAN (ncd
      WHERE ncd.ndc_code=patstring(temp->qual_ndc[x].ndc_no_pk))
     ORDER BY ncd.main_multum_drug_code
     HEAD ncd.main_multum_drug_code
      mmdc_cnt += 1, stat = alterlist(temp_mmdc->qual_mmdc,mmdc_cnt), temp_mmdc->qual_mmdc[mmdc_cnt].
      mmdc = ncd.main_multum_drug_code
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     ncd.main_multum_drug_code
     FROM (v500_ref.ndc_core_description ncd)
     PLAN (ncd
      WHERE ncd.ndc_code=patstring(temp->qual_ndc[x].ndc_no_pk))
     ORDER BY ncd.main_multum_drug_code
     HEAD ncd.main_multum_drug_code
      mmdc_cnt += 1, stat = alterlist(temp_mmdc->qual_mmdc,mmdc_cnt), temp_mmdc->qual_mmdc[mmdc_cnt].
      mmdc = ncd.main_multum_drug_code
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (mmdc_cnt=0)
  CALL echo(build("dcp_get_orc_from_ndc - no mmdc found for:",request->ndc))
 ENDIF
 IF (mmdc_cnt > 1)
  CALL echo(build("dcp_get_orc_from_ndc - multiple mmdc found for:",request->ndc))
  GO TO exit_prg
 ENDIF
 CALL echo(build("dcp_get_orc_from_ndc - temp_mmdc:",temp_mmdc))
 CALL echorecord(temp_mmdc)
 FOR (x = 1 TO mmdc_cnt)
  SET mmdc_cki = build("MUL.FRMLTN!",temp_mmdc->qual_mmdc[x].mmdc)
  SELECT INTO "nl:"
   md.item_id, oci.catalog_cd
   FROM medication_definition md,
    order_catalog_item_r oci,
    item_definition id,
    route_form_r rfr,
    code_value cv,
    code_value_event_r cve
   PLAN (md
    WHERE md.cki=mmdc_cki)
    JOIN (oci
    WHERE oci.item_id=md.item_id)
    JOIN (id
    WHERE id.item_id=md.item_id
     AND id.active_ind > 0
     AND id.active_status_cd=cactive)
    JOIN (rfr
    WHERE (rfr.form_cd= Outerjoin(md.form_cd)) )
    JOIN (cv
    WHERE (cv.code_value= Outerjoin(rfr.route_cd)) )
    JOIN (cve
    WHERE (cve.parent_cd= Outerjoin(oci.catalog_cd)) )
   ORDER BY oci.item_id, rfr.route_cd
   HEAD oci.item_id
    routecnt = 0, orc_cnt += 1, stat = alterlist(temp_reply->orc_qual,orc_cnt),
    temp_reply->orc_qual[orc_cnt].catalog_cd = oci.catalog_cd, temp_reply->orc_qual[orc_cnt].form_cd
     = md.form_cd, temp_reply->orc_qual[orc_cnt].strength = md.strength,
    temp_reply->orc_qual[orc_cnt].strength_unit_cd = md.strength_unit_cd, temp_reply->orc_qual[
    orc_cnt].item_id = md.item_id, temp_reply->orc_qual[orc_cnt].volume = md.volume,
    temp_reply->orc_qual[orc_cnt].volume_unit_cd = md.volume_unit_cd, temp_reply->orc_qual[orc_cnt].
    event_cd = cve.event_cd
   HEAD rfr.route_cd
    IF (cv.active_ind=1)
     routecnt += 1
     IF (routecnt > size(temp_reply->orc_qual[orc_cnt].route_qual,5))
      stat = alterlist(temp_reply->orc_qual[orc_cnt].route_qual,(routecnt+ 5))
     ENDIF
     temp_reply->orc_qual[orc_cnt].route_qual[routecnt].route_cd = rfr.route_cd
    ENDIF
   FOOT  rfr.route_cd
    stat = alterlist(temp_reply->orc_qual[orc_cnt].route_qual,routecnt)
   WITH nocounter
  ;end select
 ENDFOR
 CALL echorecord(temp_reply)
 IF (orc_cnt=1)
  SET qual_cnt = 1
  SET stat = alterlist(reply->orc_qual,1)
  SET reply->orc_qual[1].catalog_cd = temp_reply->orc_qual[1].catalog_cd
  SET reply->orc_qual[1].form_cd = temp_reply->orc_qual[1].form_cd
  SET reply->orc_qual[1].strength = temp_reply->orc_qual[1].strength
  SET reply->orc_qual[1].strength_unit_cd = temp_reply->orc_qual[1].strength_unit_cd
  SET reply->orc_qual[1].item_id = temp_reply->orc_qual[1].item_id
  SET reply->orc_qual[1].volume = temp_reply->orc_qual[1].volume
  SET reply->orc_qual[1].volume_unit_cd = temp_reply->orc_qual[1].volume_unit_cd
  SET reply->orc_qual[1].event_cd = temp_reply->orc_qual[1].event_cd
  SET routecnt = size(temp_reply->orc_qual[1].route_qual,5)
  SET stat = alterlist(reply->orc_qual[1].route_qual,routecnt)
  FOR (cnt = 1 TO routecnt)
    SET reply->orc_qual[1].route_qual[cnt].route_cd = temp_reply->orc_qual[1].route_qual[cnt].
    route_cd
  ENDFOR
 ELSEIF (orc_cnt > 1)
  IF (lnewmodelchk=0)
   SET sndc = cnvtupper(cnvtalphanum(request->ndc))
   SELECT INTO "nl:"
    FROM object_identifier_index oii
    PLAN (oii
     WHERE oii.value_key=sndc
      AND oii.identifier_type_cd=cndc
      AND oii.object_type_cd=cmed_def
      AND oii.generic_object=0
      AND expand(lidx1,1,orc_cnt,oii.object_id,temp_reply->orc_qual[lidx1].item_id)
      AND oii.active_ind=1)
    ORDER BY oii.object_identifier_index_id
    HEAD REPORT
     qual_cnt = 0
    HEAD oii.object_identifier_index_id
     lidx = locateval(lidx2,1,orc_cnt,oii.object_id,temp_reply->orc_qual[lidx2].item_id), qual_cnt
      += 1, stat = alterlist(reply->orc_qual,qual_cnt),
     reply->orc_qual[qual_cnt].catalog_cd = temp_reply->orc_qual[lidx].catalog_cd, reply->orc_qual[
     qual_cnt].form_cd = temp_reply->orc_qual[lidx].form_cd, reply->orc_qual[qual_cnt].strength =
     temp_reply->orc_qual[lidx].strength,
     reply->orc_qual[qual_cnt].strength_unit_cd = temp_reply->orc_qual[lidx].strength_unit_cd, reply
     ->orc_qual[qual_cnt].item_id = temp_reply->orc_qual[lidx].item_id, reply->orc_qual[qual_cnt].
     volume = temp_reply->orc_qual[lidx].volume,
     reply->orc_qual[qual_cnt].volume_unit_cd = temp_reply->orc_qual[lidx].volume_unit_cd, reply->
     orc_qual[qual_cnt].event_cd = temp_reply->orc_qual[lidx].event_cd, routecnt = size(temp_reply->
      orc_qual[lidx].route_qual,5),
     stat = alterlist(reply->orc_qual[qual_cnt].route_qual,routecnt)
     FOR (cnt = 1 TO routecnt)
       reply->orc_qual[qual_cnt].route_qual[cnt].route_cd = temp_reply->orc_qual[lidx].route_qual[cnt
       ].route_cd
     ENDFOR
    WITH nocounter
   ;end select
   SET mismatch_ind = 0
   IF (qual_cnt > 1)
    FOR (lcnt = 2 TO qual_cnt)
      IF ((((reply->orc_qual[1].catalog_cd != reply->orc_qual[lcnt].catalog_cd)) OR ((((reply->
      orc_qual[1].event_cd != reply->orc_qual[lcnt].event_cd)) OR ((((reply->orc_qual[1].form_cd !=
      reply->orc_qual[lcnt].form_cd)) OR ((((reply->orc_qual[1].strength != reply->orc_qual[lcnt].
      strength)) OR ((((reply->orc_qual[1].strength_unit_cd != reply->orc_qual[lcnt].strength_unit_cd
      )) OR ((((reply->orc_qual[1].volume != reply->orc_qual[lcnt].volume)) OR ((reply->orc_qual[1].
      volume_unit_cd != reply->orc_qual[lcnt].volume_unit_cd))) )) )) )) )) )) )
       SET mismatch_ind = 1
       SET lcnt = qual_cnt
      ENDIF
    ENDFOR
    IF (mismatch_ind=0)
     SET dstat = alterlist(reply->orc_qual,1)
    ENDIF
   ELSE
    FOR (lcnt = 2 TO orc_cnt)
      IF ((((temp_reply->orc_qual[1].catalog_cd != temp_reply->orc_qual[lcnt].catalog_cd)) OR ((((
      temp_reply->orc_qual[1].event_cd != temp_reply->orc_qual[lcnt].event_cd)) OR ((((temp_reply->
      orc_qual[1].form_cd != temp_reply->orc_qual[lcnt].form_cd)) OR ((((temp_reply->orc_qual[1].
      strength != temp_reply->orc_qual[lcnt].strength)) OR ((((temp_reply->orc_qual[1].
      strength_unit_cd != temp_reply->orc_qual[lcnt].strength_unit_cd)) OR ((((temp_reply->orc_qual[1
      ].volume != temp_reply->orc_qual[lcnt].volume)) OR ((temp_reply->orc_qual[1].volume_unit_cd !=
      temp_reply->orc_qual[lcnt].volume_unit_cd))) )) )) )) )) )) )
       SET mismatch_ind = 1
       SET lcnt = orc_cnt
      ENDIF
    ENDFOR
    IF (mismatch_ind=0)
     SET dstat = alterlist(reply->orc_qual,1)
     SET reply->orc_qual[1].catalog_cd = temp_reply->orc_qual[1].catalog_cd
     SET reply->orc_qual[1].form_cd = temp_reply->orc_qual[1].form_cd
     SET reply->orc_qual[1].strength = temp_reply->orc_qual[1].strength
     SET reply->orc_qual[1].strength_unit_cd = temp_reply->orc_qual[1].strength_unit_cd
     SET reply->orc_qual[1].item_id = temp_reply->orc_qual[1].item_id
     SET reply->orc_qual[1].volume = temp_reply->orc_qual[1].volume
     SET reply->orc_qual[1].volume_unit_cd = temp_reply->orc_qual[1].volume_unit_cd
     SET reply->orc_qual[1].event_cd = temp_reply->orc_qual[1].event_cd
     SET lroutecnt = size(temp_reply->orc_qual[1].route_qual,5)
     SET dstat = alterlist(reply->orc_qual[1].route_qual,lroutecnt)
     FOR (lcnt = 1 TO lroutecnt)
       SET reply->orc_qual[1].route_qual[lcnt].route_cd = temp_reply->orc_qual[1].route_qual[lcnt].
       route_cd
     ENDFOR
    ENDIF
   ENDIF
  ELSE
   SET dstat = alterlist(reply->orc_qual,orc_cnt)
   FOR (lcnt = 1 TO orc_cnt)
     SET reply->orc_qual[lcnt].catalog_cd = temp_reply->orc_qual[lcnt].catalog_cd
     SET reply->orc_qual[lcnt].form_cd = temp_reply->orc_qual[lcnt].form_cd
     SET reply->orc_qual[lcnt].strength = temp_reply->orc_qual[lcnt].strength
     SET reply->orc_qual[lcnt].strength_unit_cd = temp_reply->orc_qual[lcnt].strength_unit_cd
     SET reply->orc_qual[lcnt].item_id = temp_reply->orc_qual[lcnt].item_id
     SET reply->orc_qual[lcnt].volume = temp_reply->orc_qual[lcnt].volume
     SET reply->orc_qual[lcnt].volume_unit_cd = temp_reply->orc_qual[lcnt].volume_unit_cd
     SET reply->orc_qual[lcnt].event_cd = temp_reply->orc_qual[lcnt].event_cd
     SET lroutecnt = size(temp_reply->orc_qual[lcnt].route_qual,5)
     SET dstat = alterlist(reply->orc_qual[lcnt].route_qual,lroutecnt)
     FOR (lcnt2 = 1 TO lroutecnt)
       SET reply->orc_qual[lcnt].route_qual[lcnt2].route_cd = temp_reply->orc_qual[lcnt].route_qual[
       lcnt2].route_cd
     ENDFOR
   ENDFOR
  ENDIF
 ENDIF
#exit_prg
 FREE RECORD temp
 FREE RECORD temp_mmdc
 FREE RECORD temp_reply
 IF (size(reply->orc_qual,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug_ind)
  CALL echorecord(reply)
 ENDIF
 SET last_mod = "016"
 SET mod_date = "08/01/2006"
 SET modify = nopredeclare
END GO
