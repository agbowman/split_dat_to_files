CREATE PROGRAM ams_rxa_upd_medproduct:dba
 SET start_time = curtime3
 IF (validate(reply->status_data,"-1")="-1")
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
  ) WITH protect
 ENDIF
 RECORD hold_pkg_id(
   1 qual[*]
     2 package_type_id = f8
 ) WITH protect
 RECORD hold_reply(
   1 qual[*]
     2 object_id = f8
     2 comment1_id = f8
     2 comment2_id = f8
     2 compound_text_id = f8
     2 object_type_cd = f8
     2 order_sentence_id = f8
     2 id_qual[*]
       3 identifier_id = f8
       3 identifier_type_cd = f8
     2 pack_qual[*]
       3 package_type_id = f8
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD id_sync_request(
   1 item_qual[*]
     2 item_id = f8
 ) WITH protect
 RECORD tmp_seq_request(
   1 tpn_group[*]
     2 tpn_group_cd = f8
 ) WITH protect
 RECORD tmp_seq_reply(
   1 tpn_group[*]
     2 tpn_group_cd = f8
     2 reseq_ind = i2
   1 updated_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD sync_inv_req(
   1 pharmacy_type_cd = f8
   1 item_id = f8
   1 inv_factor_nbr = f8
   1 manf_qual[*]
     2 manf_item_id = f8
     2 inv_factor_nbr = f8
 ) WITH protect
 RECORD sync_inv_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD get_ocs_formulary_sts_req(
   1 qual[*]
     2 synonym_id = f8
 ) WITH protect
 RECORD get_ocs_formulary_sts_reply(
   1 syn_qual[*]
     2 synonym_id = f8
     2 facility_qual[*]
       3 facility_cd = f8
       3 inpatient_cd = f8
       3 outpatient_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD del_ocs_formulary_sts(
   1 qual[*]
     2 synonym_id = f8
     2 facility_cd = f8
 ) WITH protect
 RECORD upd_ocs_formulary_sts(
   1 qual[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 inpatient_cd = f8
     2 outpatient_cd = f8
     2 update_ind = i2
 ) WITH protect
 DECLARE addmsg(smsg=vc) = null
 DECLARE icnt = i4 WITH protect
 SUBROUTINE addmsg(smsg)
   SET icnt = value(size(reply->debug,5))
   SET icnt = (icnt+ 1)
   SET stat = alterlist(reply->debug,icnt)
   SET reply->debug[icnt].msg = smsg
 END ;Subroutine
 DECLARE hold_id = f8
 DECLARE ndc_qual = i2
 DECLARE failed = i2
 DECLARE item_cnt = i2
 DECLARE ditemmasterid = f8 WITH protect, noconstant(0.0)
 DECLARE dmanfitemid = f8 WITH protect, noconstant(0.0)
 DECLARE icreateitemmaster = i2 WITH noconstant(0)
 DECLARE iexecfromupd = i2 WITH protect, noconstant(0)
 DECLARE sobject_id_pe = c15 WITH protect, constant("ITEM_DEFINITION")
 DECLARE ninvtrackexist = i2 WITH protect, noconstant(0)
 DECLARE nsyncinvfactor = i2 WITH protect, noconstant(0)
 DECLARE dinvfactor = f8 WITH protect, noconstant(0.0)
 DECLARE cindc = f8
 DECLARE cocpharm = f8
 DECLARE cocrxmnemonic = f8
 DECLARE cocgeneric = f8
 DECLARE cocprimary = f8
 DECLARE hold_orc_id = f8
 DECLARE csyspkg = f8
 SET cnone = 0
 SET cadd = 3
 SET cupdate = 1
 SET cdelete = 2
 DECLARE cactive = f8
 DECLARE cinactive = f8
 DECLARE cmeddfn = f8
 DECLARE cmanf = f8
 DECLARE csystem = f8
 DECLARE cmeddisp = f8
 DECLARE cmedprod = f8
 DECLARE coedef = f8
 DECLARE csysnbr = f8
 DECLARE dnewcatcd = f8
 DECLARE nidentsync = i2 WITH noconstant(0)
 DECLARE dnewformpref = f8 WITH noconstant(0.0)
 DECLARE citemgroup = f8 WITH protect, noconstant(0.0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE csubst_attr = f8 WITH noconstant(0.0)
 DECLARE cingred_group = f8 WITH noconstant(0.0)
 DECLARE ccystprotocol = f8 WITH noconstant(0.0)
 DECLARE cretail = f8 WITH protect, noconstant(0.0)
 DECLARE cdesc = f8 WITH protect, noconstant(0.0)
 DECLARE cmedtypecompound = i4 WITH protect, constant(2)
 DECLARE doldcatcd = f8
 DECLARE nflexexists = i2 WITH protect, noconstant(0)
 DECLARE nmeddispdbrecsts = i2 WITH protect, noconstant(0)
 DECLARE ldelcnt = i4 WITH protect, noconstant(0)
 DECLARE lupdcnt = i4 WITH protect, noconstant(0)
 DECLARE lmfoicnt = i4 WITH protect, noconstant(0)
 DECLARE lmfoiidx = i4 WITH protect, noconstant(0)
 DECLARE drxmnemonicid = f8 WITH protect, noconstant(0.0)
 DECLARE dfacilitycd = f8 WITH protect, noconstant(0.0)
 DECLARE dtnfcd = f8 WITH protect, noconstant(0.0)
 DECLARE dnonformularycd = f8 WITH protect, noconstant(0.0)
 DECLARE dinpatientfrmstscd = f8 WITH protect, noconstant(0.0)
 DECLARE doutpatientfrmstscd = f8 WITH protect, noconstant(0.0)
 DECLARE drxfrmstscd = f8 WITH protect, noconstant(0.0)
 DECLARE dgroupedproditemid = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 CALL addmsg("Entering rxa_upd_medproduct...")
 CALL addmsg("Initializing constants...")
 SET stat = uar_get_meaning_by_codeset(11001,"MED_DEF",1,cmeddfn)
 SET stat = uar_get_meaning_by_codeset(11001,"ITEM_MANF",1,cmanf)
 SET stat = uar_get_meaning_by_codeset(11001,"ITEM_GROUP",1,citemgroup)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,cinactive)
 SET stat = uar_get_meaning_by_codeset(11000,"NDC",1,cindc)
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,cocpharm)
 SET stat = uar_get_meaning_by_codeset(6011,"RXMNEMONIC",1,cocrxmnemonic)
 SET stat = uar_get_meaning_by_codeset(6011,"GENERIC",1,cocgeneric)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,cocprimary)
 SET stat = uar_get_meaning_by_codeset(4062,"SYSTEM",1,csystem)
 SET stat = uar_get_meaning_by_codeset(4062,"SYSPKGTYP",1,csyspkg)
 SET stat = uar_get_meaning_by_codeset(4063,"DISPENSE",1,cmeddisp)
 SET stat = uar_get_meaning_by_codeset(4063,"MEDPRODUCT",1,cmedprod)
 SET stat = uar_get_meaning_by_codeset(4063,"OEDEF",1,coedef)
 SET stat = uar_get_meaning_by_codeset(11000,"ITEM_NBR_SYS",1,csysnbr)
 SET stat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET stat = uar_get_meaning_by_codeset(4063,"SUBST_ATTR",1,csubst_attr)
 SET stat = uar_get_meaning_by_codeset(4063,"INGRED_GROUP",1,cingred_group)
 SET stat = uar_get_meaning_by_codeset(4063,"CYSTPROTOCOL",1,ccystprotocol)
 SET stat = uar_get_meaning_by_codeset(4500,"RETAIL",1,cretail)
 SET stat = uar_get_meaning_by_codeset(11000,"DESC",1,cdesc)
 SET stat = uar_get_meaning_by_codeset(4512,"TNF",1,dtnfcd)
 SET stat = uar_get_meaning_by_codeset(4512,"NONFORMULARY",1,dnonformularycd)
 DECLARE cinv_at_drug_level = i2 WITH public, constant(0)
 DECLARE cinv_at_manf_level = i2 WITH public, constant(1)
 DECLARE gicurinvpreflevel = i2 WITH public, noconstant(0)
 DECLARE ctpnidx = i4 WITH protect, noconstant(0)
 DECLARE ctpngroupcnt = i4 WITH protect, noconstant(0)
 DECLARE ctotalgroupcnt = i4 WITH protect, noconstant(0)
 CALL addmsg(build("cMedDfn = ",cmeddfn))
 DECLARE lmpdcount = i4 WITH protect, noconstant(0)
 DECLARE lmpdidx = i4 WITH protect, noconstant(0)
 SET tstore = 0
 SET failed = false
 SET reply->status_data.status = "F"
 SET action_end = size(request->qual,5)
 SET stat = alterlist(request->qual,action_end)
 CALL addmsg(build("Prod status= ",request->prod_rec_status))
 IF ((request->prod_rec_status=1))
  SET nbr_of_items = size(request->meddefqual,5)
  SET stat = alterlist(request->qual,nbr_of_items)
  CALL addmsg(build("NBR_OF_ITEMS: ",nbr_of_items))
  SET stat = alterlist(id_sync_request->item_qual,nbr_of_items)
  SET stat = alterlist(get_ocs_formulary_sts_req->qual,1)
  FOR (cmeddef = 1 TO nbr_of_items)
    SET drxmnemonicid = 0
    SET id_sync_request->item_qual[cmeddef].item_id = request->meddefqual[cmeddef].item_id
    SET request->item_group_active_ind = 0
    SET request->qual[cmeddef].item_type_cd = cmeddfn
    SET request->item_type_cd = cmeddfn
    SET request->qual[cmeddef].item_level_flag = 1
    IF (gicurinvpreflevel=cinv_at_drug_level)
     CALL addmsg(build("Checking for Group on Item: ",request->meddefqual[cmeddef].item_id))
     SELECT INTO "NL:"
      *
      FROM medication_definition md
      PLAN (md
       WHERE (md.item_id=request->meddefqual[cmeddef].item_id))
      HEAD REPORT
       IF (md.inv_master_id > 0)
        request->qual[cmeddef].item_level_flag = 2
       ELSE
        request->qual[cmeddef].item_level_flag = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    CALL addmsg(build("ITEM_LEVEL_FLAG: ",request->qual[cmeddef].item_level_flag))
    CALL addmsg(build("ITEM_TYPE_CD1: ",request->qual[cmeddef].item_type_cd))
    SET request->qual[cmeddef].item_id = request->meddefqual[cmeddef].item_id
    SET request->qual[cmeddef].mdx_gfc_nomen_id = request->meddefqual[cmeddef].mdx_gfc_nomen_id
    SET request->qual[cmeddef].form_cd = request->meddefqual[cmeddef].form_cd
    SET request->qual[cmeddef].strength = request->meddefqual[cmeddef].strength
    SET request->qual[cmeddef].strength_unit_cd = request->meddefqual[cmeddef].strength_unit_cd
    SET request->qual[cmeddef].volume = request->meddefqual[cmeddef].volume
    SET request->qual[cmeddef].volume_unit_cd = request->meddefqual[cmeddef].volume_unit_cd
    SET request->qual[cmeddef].given_strength = request->meddefqual[cmeddef].given_strength
    SET request->qual[cmeddef].meq_factor = request->meddefqual[cmeddef].meq_factor
    SET request->qual[cmeddef].mmol_factor = request->meddefqual[cmeddef].mmol_factor
    SET request->qual[cmeddef].compound_text_id = request->meddefqual[cmeddef].compound_text_id
    SET request->qual[cmeddef].compound_text = request->meddefqual[cmeddef].compound_text
    SET request->qual[cmeddef].comment1_id = request->meddefqual[cmeddef].comment1_id
    SET request->qual[cmeddef].comment1_text = request->meddefqual[cmeddef].comment1_text
    SET request->qual[cmeddef].comment2_id = request->meddefqual[cmeddef].comment2_id
    SET request->qual[cmeddef].comment2_text = request->meddefqual[cmeddef].comment2_text
    CALL addmsg(build("comment2_text: ",request->meddefqual[cmeddef].comment2_text))
    SET request->qual[cmeddef].cki = request->meddefqual[cmeddef].cki
    SET request->qual[cmeddef].schedulable_ind = request->meddefqual[cmeddef].schedulable_ind
    SET request->qual[cmeddef].reusable_ind = request->meddefqual[cmeddef].reusable_ind
    SET request->qual[cmeddef].cdm = request->meddefqual[cmeddef].cdm
    SET request->qual[cmeddef].critical_ind = request->meddefqual[cmeddef].critical_ind
    SET request->qual[cmeddef].sub_account_cd = request->meddefqual[cmeddef].sub_account_cd
    SET request->qual[cmeddef].cost_center_cd = request->meddefqual[cmeddef].cost_center_cd
    SET request->qual[cmeddef].storage_requirement_cd = request->meddefqual[cmeddef].
    storage_requirement_cd
    SET request->qual[cmeddef].sterilization_required_ind = request->meddefqual[cmeddef].
    sterilization_required_ind
    SET request->qual[cmeddef].base_issue_factor = request->meddefqual[cmeddef].base_issue_factor
    SET request->qual[cmeddef].active_ind = request->meddefqual[cmeddef].active_ind
    SET request->qual[cmeddef].package_type_id = request->meddefqual[cmeddef].package_type_id
    SET request->qual[cmeddef].med_type_flag = request->meddefqual[cmeddef].med_type_flag
    SET request->qual[cmeddef].premix_ind = request->meddefqual[cmeddef].premix_ind
    IF ((request->meddefqual[cmeddef].meddefflexqual[1].pharmacy_type_cd=cretail))
     SET stat = assign(validate(request->qual[cmeddef].lot_tracking_ind),validate(request->
       meddefqual[cmeddef].lot_tracking_ind,0))
    ENDIF
    SELECT INTO "nl:"
     md.*
     FROM medication_definition md
     WHERE (md.item_id=request->meddefqual[cmeddef].item_id)
     DETAIL
      request->qual[cmeddef].oe_format_flag = md.oe_format_flag, request->qual[cmeddef].
      continuous_filter_ind = md.continuous_filter_ind, request->qual[cmeddef].
      intermittent_filter_ind = md.intermittent_filter_ind,
      request->qual[cmeddef].med_filter_ind = md.med_filter_ind, request->qual[cmeddef].
      order_sentence_id = md.order_sentence_id, request->qual[cmeddef].divisible_ind = md
      .divisible_ind,
      request->qual[cmeddef].formulary_status_cd = md.formulary_status_cd, request->qual[cmeddef].
      default_par_doses = md.default_par_doses, request->qual[cmeddef].max_par_supply = md
      .max_par_supply,
      request->qual[cmeddef].legal_status_cd = md.legal_status_cd, request->qual[cmeddef].
      dispense_category_cd = md.dispense_category_cd, request->qual[cmeddef].
      alternate_dispense_category_cd = md.alternate_dispense_category_cd,
      request->qual[cmeddef].used_as_base_ind = md.used_as_base_ind, request->qual[cmeddef].
      order_alert1_cd = md.order_alert1_cd, request->qual[cmeddef].order_alert2_cd = md
      .order_alert2_cd,
      request->qual[cmeddef].comment1_id = md.comment1_id, request->qual[cmeddef].comment1_type = md
      .comment1_type, request->qual[cmeddef].comment2_id = md.comment2_id,
      request->qual[cmeddef].comment2_type = md.comment2_type, request->qual[cmeddef].price_sched_id
       = md.price_sched_id, request->qual[cmeddef].always_dispense_from_flag = md
      .always_dispense_from_flag,
      request->qual[cmeddef].primary_manf_item_id = md.primary_manf_item_id, request->qual[cmeddef].
      side_effect_code = md.side_effect_code
      IF ((request->meddefqual[cmeddef].meddefflexqual[1].pharmacy_type_cd=cretail))
       request->qual[cmeddef].med_type_flag = md.med_type_flag, request->qual[cmeddef].meq_factor =
       md.meq_factor, request->qual[cmeddef].mmol_factor = md.mmol_factor,
       request->qual[cmeddef].premix_ind = md.premix_ind
      ENDIF
     WITH nocounter
    ;end select
    SET csystemrow = 0
    FOR (cmeddefflex = 1 TO value(size(request->meddefqual[cmeddef].meddefflexqual,5)))
      IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].flex_type_cd=csystem))
       SET tstore = cmeddefflex
       SET cmeddefflex = value(size(request->meddefqual[cmeddef].meddefflexqual,5))
      ENDIF
    ENDFOR
    SET gicurinvpreflevel = cinv_at_drug_level
    SELECT INTO "NL:"
     dm.pref_nbr
     FROM dm_prefs dm
     WHERE application_nbr=300000
      AND person_id=0
      AND (pref_domain=
     IF ((((request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd=cinpatient)) OR ((
     request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd=0))) ) "PHARMNET-INPATIENT"
     ELSE "PHARMNET-RETAIL"
     ENDIF
     )
      AND pref_section="FORMULARY"
      AND pref_name="PROCURE"
     DETAIL
      gicurinvpreflevel = dm.pref_nbr
     WITH nocounter
    ;end select
    IF (gicurinvpreflevel=cinv_at_drug_level)
     CALL addmsg(build("INV: preference set to DRUG LEVEL"))
    ELSE
     CALL addmsg(build("INV: preference set to MANF LEVEL"))
    ENDIF
    IF ((request->qual[cmeddef].med_type_flag=cmedtypecompound)
     AND cmeddefflex > 0
     AND (request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd != cinpatient))
     SELECT INTO "nl:"
      FROM med_identifier mi,
       (dummyt d1  WITH seq = value(size(request->meddefqual[cmeddef].meddefflexqual[tstore].
         medidentifierqual,5)))
      PLAN (d1
       WHERE (request->meddefqual[cmeddef].meddefflexqual[tstore].medidentifierqual[d1.seq].
       med_identifier_type_cd=cdesc))
       JOIN (mi
       WHERE mi.value_key=cnvtalphanum(cnvtupper(request->meddefqual[cmeddef].meddefflexqual[tstore].
         medidentifierqual[d1.seq].value))
        AND (mi.item_id != request->meddefqual[cmeddef].item_id))
     ;end select
     IF (curqual > 0)
      SET reqinfo->commit_ind = 0
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "DUPLICATE IDENTIFIER EXISTS"
      SET reply->status_data.subeventstatus[1].targetobjectname = "MED_IDENTIFIER"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->ifailure_type = 1
      GO TO exit_script
     ENDIF
    ENDIF
    SET ninvtrackexist = validate(request->meddefqual[cmeddef].inv_tracking_level)
    IF (ninvtrackexist=1)
     SET request->meddefqual[cmeddef].inv_tracking_level = gicurinvpreflevel
    ENDIF
    CALL addmsg(build("INV: nInvTrackExist=",ninvtrackexist))
    IF ((request->meddefqual[cmeddef].active_ind=0))
     SELECT INTO "nl:"
      *
      FROM med_def_flex mdf
      WHERE (mdf.item_id=request->meddefqual[cmeddef].item_id)
       AND mdf.active_ind=1
       AND (mdf.pharmacy_type_cd != request->meddefqual[cmeddef].meddefflexqual[tstore].
      pharmacy_type_cd)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET request->qual[cmeddef].active_ind = 1
      SET request->qual[cmeddef].active_status_cd = cactive
     ELSE
      SET request->qual[cmeddef].active_ind = 0
      SET request->qual[cmeddef].active_status_cd = cinactive
     ENDIF
    ELSE
     SET request->qual[cmeddef].active_ind = 1
     SET request->qual[cmeddef].active_status_cd = cactive
    ENDIF
    CALL addmsg(build("Active_Ind: ",request->qual[cmeddef].active_ind))
    CALL addmsg(build("Active_Status: ",request->qual[cmeddef].active_status_cd))
    SET cmeddefflex = tstore
    SET tstore = 0
    SET csystemrow = cmeddefflex
    SET request->total_ids_to_add = size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
     medidentifierqual,5)
    SET request->qual[cmeddef].nbr_ids_to_add = request->total_ids_to_add
    SET ccount1 = 0
    SET ccount2 = 0
    SET request->total_ids_to_add = 0
    SET request->total_ids_to_chg = 0
    SET request->total_ids_to_del = 0
    SET stat = alterlist(request->add_id_qual,0)
    SET stat = alterlist(request->chg_id_qual,0)
    SET stat = alterlist(request->add_id_qual,size(request->meddefqual[cmeddef].meddefflexqual[
      cmeddefflex].medidentifierqual,5))
    FOR (yme = 1 TO size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual,5
     ))
      IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual[yme].
      db_rec_status=3)
       AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual[yme].
      med_identifier_id=0.0)
       AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual[yme].
      primary_ind=1))
       SET ccount1 = (ccount1+ 1)
       SET request->total_ids_to_add = ccount1
       SET request->add_id_qual[ccount1].item_level_flag = request->qual[cmeddef].item_level_flag
       SET request->add_id_qual[ccount1].object_id = request->meddefqual[cmeddef].item_id
       SET request->add_id_qual[ccount1].object_id_pe = sobject_id_pe
       SET request->qual[1].nbr_ids_to_add = request->total_ids_to_add
       SET request->add_id_qual[ccount1].id_type_cd = request->meddefqual[cmeddef].meddefflexqual[
       cmeddefflex].medidentifierqual[yme].med_identifier_type_cd
       SET request->add_id_qual[ccount1].object_type_cd = cmeddfn
       SET request->add_id_qual[ccount1].object_active_ind = 1
       SET request->add_id_qual[ccount1].value = request->meddefqual[cmeddef].meddefflexqual[
       cmeddefflex].medidentifierqual[yme].value
       SET request->add_id_qual[ccount1].primary_ind = request->meddefqual[cmeddef].meddefflexqual[
       cmeddefflex].medidentifierqual[yme].primary_ind
       SET request->add_id_qual[ccount1].primary_nbr_ind = 0
       SET request->add_id_qual[ccount1].active_ind = 1
       SET request->add_id_qual[ccount1].active_status_cd = cactive
      ENDIF
    ENDFOR
    CALL addmsg(build("Total ids to add: ",request->total_ids_to_add))
    SET stat = alterlist(request->add_id_qual,ccount1)
    IF (((ccount1 > 0) OR (ccount2 > 0)) )
     CALL addmsg("Entering mm_upd_identifier1...")
     SET nidentsync = 1
     EXECUTE mm_upd_identifier
     CALL addmsg("Leaving mm_upd_identifier1...")
    ENDIF
    SET csyspkgrow = 0
    FOR (cmeddefflex = 1 TO value(size(request->meddefqual[cmeddef].meddefflexqual,5)))
      IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].flex_type_cd=csyspkg))
       SET tstore = cmeddefflex
       SET cmeddefflex = value(size(request->meddefqual[cmeddef].meddefflexqual,5))
      ENDIF
    ENDFOR
    SET cmeddefflex = tstore
    SET tstore = 0
    SET csyspkgrow = cmeddefflex
    SELECT INTO "nl:"
     FROM med_def_flex mdf
     WHERE (mdf.item_id=request->meddefqual[cmeddef].item_id)
      AND mdf.flex_type_cd=csystem
      AND ((mdf.pharmacy_type_cd+ 0) != request->meddefqual[cmeddef].meddefflexqual[tstore].
     pharmacy_type_cd)
      AND ((mdf.active_ind+ 0)=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET request->qual[cmeddef].pha_type_flag = 3
    ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd IN (cinpatient, 0))
    )
     SET request->qual[cmeddef].pha_type_flag = 1
    ELSE
     SET request->qual[cmeddef].pha_type_flag = 2
    ENDIF
    CALL addmsg(build("pha_type_flag:",request->qual[cmeddef].pha_type_flag))
    SELECT INTO "nl:"
     i.item_id
     FROM item_definition i
     WHERE (i.item_id=request->qual[1].item_id)
     DETAIL
      request->qual[1].updt_cnt = i.updt_cnt
     WITH nocounter
    ;end select
    SET prev_active_status = 0.0
    SELECT INTO "nl:"
     i.item_id
     FROM item_definition i
     WHERE (i.item_id=request->qual[1].item_id)
     DETAIL
      request->qual[1].updt_cnt = i.updt_cnt, prev_active_status = i.active_status_cd
     WITH nocounter
    ;end select
    CALL addmsg("=========================================")
    CALL addmsg(build("Prev_Active_status: ",prev_active_status))
    CALL addmsg(build("New status: ",request->qual[cmeddef].active_status_cd))
    CALL addmsg(build("cActive: ",cactive))
    CALL addmsg(build("cInactive: ",cinactive))
    IF ((request->meddefqual[cmeddef].db_rec_status=3))
     CALL addmsg("Entering mm_add_item1...")
     EXECUTE mm_add_item
     CALL addmsg("Leaving mm_add_item1...")
     SET nidentsync = 1
    ELSE
     IF ((request->qual[cmeddef].active_status_cd != prev_active_status))
      IF ((request->qual[cmeddef].active_status_cd != cactive))
       CALL addmsg("Entering mm_del_item...")
       EXECUTE mm_del_item
       CALL addmsg(build("Leaving mm_del_item...",reply->status_data.status))
       SET request->qual[1].updt_cnt = (request->qual[1].updt_cnt+ 1)
       SET nidentsync = 1
      ELSE
       CALL addmsg("Entering mm_und_item...")
       EXECUTE mm_und_item
       CALL addmsg(build("Leaving mm_und_item...",reply->status_data.status))
       SET request->qual[1].updt_cnt = (request->qual[1].updt_cnt+ 1)
       SET nidentsync = 1
      ENDIF
     ENDIF
     CALL addmsg("Entering mm_chg_item1...")
     EXECUTE mm_chg_item
     CALL addmsg("Leaving mm_chg_item1...")
     SET nidentsync = 1
    ENDIF
    CALL addmsg(build("Status after mm_chg_item1: ",reply->status_data.status))
    IF ((reply->status_data.status != "S"))
     SET reqinfo->commit_ind = 0
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "MEDICATION"
     SET reply->status_data.subeventstatus[1].targetobjectname = "1st pass"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     GO TO exit_script
    ELSE
     CALL addmsg("Passed mm_chg_item1...")
     SET hold_id = request->meddefqual[1].item_id
     SET request->meddefqual[1].compound_text_id = reply->qual[1].compound_text_id
     CALL addmsg(build("Hold_id: ",hold_id))
     CALL addmsg(build("comment1_id: ",reply->qual[1].comment1_id))
     CALL addmsg(build("comment2_id: ",reply->qual[1].comment2_id))
     SET item_cnt = (item_cnt+ 1)
     SET stat = alterlist(hold_reply->qual,item_cnt)
     SET hold_reply->qual[item_cnt].object_id = reply->qual[1].object_id
     SET hold_reply->qual[item_cnt].comment1_id = reply->qual[1].comment1_id
     SET hold_reply->qual[item_cnt].comment2_id = reply->qual[1].comment2_id
     SET hold_reply->qual[item_cnt].compound_text_id = reply->qual[1].component_text_id
     SET hold_reply->qual[item_cnt].object_type_cd = reply->qual[1].object_type_cd
     SET id_cnt = 0
     SET id_cnt = value(size(reply->qual[1].id_qual,5))
     SET cidentindex = 0
     SET cmeddefcnt = value(size(request->meddefqual,5))
     SET cmeddefidx = 0
     SET stat = alterlist(reply->meddefqual,cmeddefcnt)
     FOR (cmeddefidx = 1 TO cmeddefcnt)
       SET cflexcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual,5))
       SET cflexidx = 0
       SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual,cflexcnt)
       FOR (cflexidx = 1 TO cflexcnt)
         SET cflexidcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medidentifierqual,5))
         SET cflexididx = 0
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medidentifierqual,cflexidcnt)
         SET cflexobjcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual,5))
         SET cflexididx = 0
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual,cflexobjcnt)
         FOR (cflexobjidx = 1 TO cflexobjcnt)
          SET cflexobjcd = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].flex_object_type_cd
          IF (cflexobjcd=coedef)
           SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
            medflexobjidxqual[cflexobjidx].medoedefaultsqual,1)
           SET request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx
           ].medoedefaultsqual[1].comment1_id = reply->qual[1].comment1_id
           SET request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx
           ].medoedefaultsqual[1].comment2_id = reply->qual[1].comment2_id
          ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
     IF (id_cnt > 0)
      SET stat = alterlist(hold_reply->qual[item_cnt].id_qual,id_cnt)
      FOR (kia = 1 TO id_cnt)
        SET hold_reply->qual[item_cnt].id_qual[kia].identifier_id = reply->qual[1].id_qual[kia].
        identifier_id
        SET hold_reply->qual[item_cnt].id_qual[kia].identifier_type_cd = reply->qual[1].id_qual[kia].
        identifier_type_cd
        FOR (cidentindex = 1 TO value(size(request->meddefqual[cmeddef].meddefflexqual[csystemrow].
          medidentifierqual,5)))
          IF ((request->meddefqual[cmeddef].meddefflexqual[csystemrow].medidentifierqual[cidentindex]
          .med_identifier_id=0.0))
           SET request->meddefqual[cmeddef].meddefflexqual[csystemrow].medidentifierqual[cidentindex]
           .med_identifier_id = reply->qual[1].id_qual[kia].identifier_id
           SET request->meddefqual[cmeddef].meddefflexqual[csystemrow].medidentifierqual[cidentindex]
           .db_rec_status = 3
           SET cidentindex = (value(size(request->meddefqual[cmeddef].meddefflexqual[csystemrow].
             medidentifierqual,5))+ 1)
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     SET cidentindex = 0
     SET pack_cnt = 0
     SET pack_cnt = value(size(reply->qual[1].pack_qual,5))
     IF (pack_cnt > 0)
      SET stat = alterlist(hold_reply->qual[item_cnt].pack_qual,pack_cnt)
      FOR (wtf = 1 TO pack_cnt)
        SET hold_reply->qual[item_cnt].pack_qual[wtf].package_type_id = reply->qual[1].pack_qual[wtf]
        .package_type_id
      ENDFOR
     ENDIF
     IF ((request->oc_rec_status != 0))
      SET request->item_id = request->meddefqual[cmeddef].item_id
      SET request->db_rec_status = request->meddefqual[cmeddef].ordcat[1].db_rec_status
      SET request->catalog_cd = request->meddefqual[cmeddef].ordcat[1].catalog_cd
      SET request->consent_form_ind = request->meddefqual[cmeddef].ordcat[1].consent_form_ind
      SET request->active_ind = request->meddefqual[cmeddef].ordcat[1].active_ind
      SET request->catalog_type_cd = request->meddefqual[cmeddef].ordcat[1].catalog_type_cd
      SET request->catalog_type_disp = request->meddefqual[cmeddef].ordcat[1].catalog_type_disp
      SET request->activity_type_cd = request->meddefqual[cmeddef].ordcat[1].activity_type_cd
      SET request->activity_subtype_cd = request->meddefqual[cmeddef].ordcat[1].activity_subtype_cd
      SET request->requisition_format_cd = request->meddefqual[cmeddef].ordcat[1].
      requisition_format_cd
      SET request->requisition_routing_cd = request->meddefqual[cmeddef].ordcat[1].
      requisition_routing_cd
      SET request->inst_restriction_ind = request->meddefqual[cmeddef].ordcat[1].inst_restriction_ind
      SET request->schedule_ind = request->meddefqual[cmeddef].ordcat[1].schedule_ind
      SET request->description = request->meddefqual[cmeddef].ordcat[1].description
      SET request->iv_ingredient_ind = request->meddefqual[cmeddef].ordcat[1].iv_ingredient_ind
      SET request->print_req_ind = request->meddefqual[cmeddef].ordcat[1].print_req_ind
      SET request->oe_format_id = request->meddefqual[cmeddef].ordcat[1].oe_format_id
      SET request->orderable_type_flag = request->meddefqual[cmeddef].ordcat[1].orderable_type_flag
      SET request->complete_upon_order_ind = request->meddefqual[cmeddef].ordcat[1].
      complete_upon_order_ind
      SET request->quick_chart_ind = request->meddefqual[cmeddef].ordcat[1].quick_chart_ind
      SET request->comment_template_flag = request->meddefqual[cmeddef].ordcat[1].
      comment_template_flag
      SET request->prep_into_flag = request->meddefqual[cmeddef].ordcat[1].prep_into_flag
      SET request->updt_cnt = request->meddefqual[cmeddef].ordcat[1].updt_cnt
      SET request->valid_iv_additive_ind = request->meddefqual[cmeddef].ordcat[1].
      valid_iv_additive_ind
      SET request->dc_display_days = request->meddefqual[cmeddef].ordcat[1].dc_display_days
      SET request->dc_interaction_days = request->meddefqual[cmeddef].ordcat[1].dc_interaction_days
      IF (validate(request->meddefqual[cmeddef].ordcat[1].set_op_days,- (1))=1)
       SET request->op_dc_display_days = request->meddefqual[cmeddef].ordcat[1].op_dc_display_days
       SET request->op_dc_interaction_days = request->meddefqual[cmeddef].ordcat[1].
       op_dc_interaction_days
       SET request->set_op_days = 1
      ENDIF
      SET request->mdx_gcr_nomen_id = request->meddefqual[cmeddef].ordcat[1].mdx_gcr_nomen_id
      SET request->cki = request->meddefqual[cmeddef].ordcat[1].cki
      SET request->gcr_desc = request->meddefqual[cmeddef].ordcat[1].gcr_desc
      SET hold_orc_id = request->catalog_cd
      FOR (cmnemonic = 1 TO value(size(request->meddefqual[cmeddef].ordcat[1].qual_mnemonic,5)))
        IF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].mnemonic_type_cd=
        cocprimary))
         SET request->item_id = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         item_id
         SET request->db_rec_status = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic]
         .db_rec_status
         SET request->synonym_id = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         synonym_id
         SET request->mnemonic = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         mnemonic
         SET request->mnemonic_type_cd = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[
         cmnemonic].mnemonic_type_cd
         SET request->active_ind = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         active_ind
         SET request->order_sentence_id = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[
         cmnemonic].order_sentence_id
         SET request->synonym_cki = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         synonym_cki
         SET request->updt_cnt = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[cmnemonic].
         updt_cnt
        ENDIF
      ENDFOR
      IF ((request->oc_rec_status=3))
       CALL addmsg("Entering orm_add_rx_oc_info...")
       EXECUTE orm_add_rx_oc_info
       CALL addmsg("Leaving orm_add_rx_oc_info...")
       IF ((reply->status_data.status != "S"))
        CALL addmsg("Did not pass orm_add_rx_oc_info...")
        SET reqinfo->commit_ind = 0
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORM_ADD_RX_OC_INFO"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        GO TO failed_common
       ENDIF
       SET hold_orc_id = reply->catalog_cd
      ELSE
       IF (size(request->meddefqual[cmeddef].ordcat[1].cki,3) > 0
        AND (request->meddefqual[cmeddef].ordcat[1].cki != "IGNORE"))
        SELECT INTO "nl:"
         ocir.*
         FROM order_catalog_item_r ocir,
          order_catalog oc
         PLAN (ocir
          WHERE (ocir.item_id=request->meddefqual[cmeddef].item_id))
          JOIN (oc
          WHERE oc.catalog_cd=ocir.catalog_cd
           AND (oc.cki=request->meddefqual[cmeddef].ordcat[1].cki))
         DETAIL
          dnewcatcd = ocir.catalog_cd, doldcatcd = ocir.catalog_cd
         WITH nocounter
        ;end select
        IF (dnewcatcd <= 0)
         SELECT INTO "nl:"
          oc.*
          FROM order_catalog oc
          WHERE (oc.cki=request->meddefqual[cmeddef].ordcat[1].cki)
          ORDER BY oc.active_ind DESC
          HEAD REPORT
           dnewcatcd = oc.catalog_cd
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          ocir.*
          FROM order_catalog_item_r ocir
          WHERE (ocir.item_id=request->meddefqual[cmeddef].item_id)
          ORDER BY ocir.updt_dt_tm DESC
          HEAD REPORT
           doldcatcd = ocir.catalog_cd
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
       IF (dnewcatcd > 0)
        CALL addmsg(build("dNewCatCd: ",dnewcatcd))
        CALL addmsg(build("New Ord_Cat: ",request->meddefqual[cmeddef].ordcat[1].catalog_cd))
        CALL addmsg(build("Mnem Status: ",request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].
          db_rec_status))
        IF (doldcatcd != dnewcatcd
         AND (request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].db_rec_status=1))
         SET request->meddefqual[cmeddef].ordcat[1].catalog_cd = dnewcatcd
         UPDATE  FROM order_catalog_synonym ocs
          SET ocs.catalog_cd = dnewcatcd
          WHERE (ocs.synonym_id=request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].synonym_id)
          WITH nocounter
         ;end update
         UPDATE  FROM order_catalog_item_r oci
          SET oci.catalog_cd = dnewcatcd
          WHERE (oci.synonym_id=request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].synonym_id)
          WITH nocounter
         ;end update
         CALL addmsg(build("CurQual = ",curqual))
        ENDIF
        SET request->meddefqual[cmeddef].ordcat[1].catalog_cd = dnewcatcd
       ENDIF
       SET request->catalog_cd = request->meddefqual[cmeddef].ordcat[1].catalog_cd
       SET request->catalog_type_cd = request->meddefqual[cmeddef].ordcat[1].catalog_type_cd
       SET hold_orc_id = request->meddefqual[cmeddef].ordcat[1].catalog_cd
       SELECT INTO "nl:"
        oc.catalog_cd
        FROM order_catalog oc
        WHERE (oc.catalog_cd=request->meddefqual[cmeddef].ordcat[1].catalog_cd)
        DETAIL
         request->updt_cnt = oc.updt_cnt
        WITH nocounter
       ;end select
       CALL addmsg("Entering orm_chg_rx_oc_info...")
       EXECUTE orm_chg_rx_oc_info
       CALL addmsg(build("Leaving orm_chg_rx_oc_info...",reply->status_data.status))
       IF ((reply->status_data.status != "S"))
        CALL addmsg("Did not pass orm_chg_rx_oc_info...")
        SET reqinfo->commit_ind = 0
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORM_CHG_RX_OC_INFO"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        GO TO failed_common
       ELSE
        SET stat = alterlist(request->add_qual,1)
        SET stat = alterlist(request->upd_qual,1)
        SET request->syn_add_cnt = 0
        SET request->syn_upd_cnt = 0
        SET rrr = 0
        SET hold_synonym_cki = fillstring(25," ")
        FOR (a = 1 TO size(request->meddefqual[cmeddef].ordcat[1].qual_mnemonic,5))
          IF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].mnemonic_type_cd=cocrxmnemonic
          ))
           SET drxmnemonicid = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].synonym_id
           SET request->mnemonic = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].mnemonic
           SET request->mnemonic_type_cd = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].
           mnemonic_type_cd
           SET request->active_ind = 1
           SET request->order_sentence_id = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].
           order_sentence_id
           SET hold_synonym_cki = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[a].synonym_cki
          ENDIF
        ENDFOR
        IF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].db_rec_status=3))
         SET request->catalog_cd = request->meddefqual[cmeddef].ordcat[1].catalog_cd
         SET request->catalog_type_cd = request->meddefqual[cmeddef].ordcat[1].catalog_type_cd
         SET request->syn_add_cnt = 1
         SET stat = alterlist(request->add_qual,1)
         SET request->add_qual[1].mnemonic = request->mnemonic
         SET request->add_qual[1].mnemonic_type_cd = request->mnemonic_type_cd
         SET request->add_qual[1].active_ind = 1
         SET request->add_qual[1].order_sentence_id = request->order_sentence_id
         SET request->add_qual[1].item_id = request->meddefqual[cmeddef].item_id
         SET request->add_qual[1].synonym_cki = hold_synonym_cki
        ELSEIF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].db_rec_status=1))
         SET request->syn_upd_cnt = 1
         SET request->upd_qual[1].synonym_id = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1
         ].synonym_id
         SET request->upd_qual[1].mnemonic = request->mnemonic
         SET request->upd_qual[1].mnemonic_type_cd = request->mnemonic_type_cd
         SET request->upd_qual[1].order_sentence_id = request->order_sentence_id
         SET request->upd_qual[1].active_ind = 1
         SET request->upd_qual[1].item_id = hold_id
         SET request->upd_qual[1].synonym_cki = request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[
         1].synonym_cki
        ENDIF
        SELECT INTO "nl:"
         ocs.synonym_id
         FROM order_catalog_synonym ocs
         WHERE (ocs.synonym_id=request->upd_qual[1].synonym_id)
         DETAIL
          request->upd_qual[1].updt_cnt = ocs.updt_cnt
         WITH nocounter
        ;end select
        RECORD reply_os(
          1 qual[*]
            2 synonym_id = f8
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c15
              3 operationstatus = c1
              3 targetobjectname = c15
              3 targetobjectvalue = vc
        ) WITH protect
        CALL addmsg("Entering orm_upd_rx_oc_syn...")
        EXECUTE orm_upd_rx_oc_syn  WITH replace("REPLY","REPLY_OS")
        CALL addmsg("Done with orm_upd_rx_oc_syn...")
        IF ((reply_os->status_data.status != "S"))
         CALL addmsg("Did not pass orm_upd_rx_oc_syn...")
         SET reqinfo->commit_ind = 0
         SET reply->status_data.subeventstatus[1].operationname = "INSERT"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORM_UPD_RX_OC_SYN"
         SET reply->status_data.subeventstatus[1].targetobjectname = "ORM_UPD_RX_OC_SYN"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         GO TO failed_common
        ELSE
         CALL addmsg("Passed orm_upd_rx_oc_syn...")
         IF (value(size(request->meddefqual[1].ordcat[1].ahfs_qual,5))=0)
          SET stat = alterlist(request->meddefqual[1].ordcat[1].ahfs_qual,1)
          SET request->meddefqual[1].ordcat[1].ahfs_qual[1].ahfs_code = "000000"
         ENDIF
         SET reply->synonym_id = reply_os->qual[1].synonym_id
         RECORD ahfs_request(
           1 synonym_id = f8
           1 qual[*]
             2 sequence = i4
             2 short_description = vc
             2 class_id = f8
         ) WITH protect
         SET ahfs_request->synonym_id = reply->synonym_id
         SET stat = alterlist(ahfs_request->qual,size(request->meddefqual[1].ordcat[1].ahfs_qual,5))
         FOR (mia = 1 TO size(request->meddefqual[1].ordcat[1].ahfs_qual,5))
           SET ahfs_request->qual[mia].short_description = request->meddefqual[1].ordcat[1].
           ahfs_qual[mia].ahfs_code
         ENDFOR
         IF (size(request->meddefqual[1].ordcat[1].ahfs_qual,5) > 0)
          IF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].db_rec_status=3))
           CALL addmsg("Entering rx_add_ahfs_list...")
           EXECUTE rx_add_ahfs_list  WITH replace("REQUEST","AHFS_REQUEST")
           CALL addmsg(build("Leaving rx_add_ahfs_list...",reply->status_data.status))
          ELSEIF ((request->meddefqual[cmeddef].ordcat[1].qual_mnemonic[1].db_rec_status=1))
           SET ahfs_request->synonym_id = request->upd_qual[1].synonym_id
           CALL addmsg("Entering pha_upd_ahfs_list...")
           EXECUTE pha_upd_ahfs_list  WITH replace("REQUEST","AHFS_REQUEST")
           CALL addmsg(build("Leaving pha_upd_ahfs_list...",reply->status_data.status))
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       IF ((reply->status_data.status != "S"))
        CALL addmsg("Did not pass rx_add_ahfs_list...")
        SET reqinfo->commit_ind = 0
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "RX_ADD_AHFS_LIST"
        SET reply->status_data.subeventstatus[1].targetobjectname = "RX_ADD_AHFS_LIST"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        GO TO failed_common
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET get_ocs_formulary_sts_reply->status_data.status = "F"
    IF ((request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd=cinpatient)
     AND drxmnemonicid > 0)
     SET get_ocs_formulary_sts_req->qual[1].synonym_id = drxmnemonicid
     CALL addmsg("Calling get_ocs_formulary_status")
     EXECUTE get_ocs_formulary_status  WITH replace("REQUEST","GET_OCS_FORMULARY_STS_REQ"), replace(
      "REPLY","GET_OCS_FORMULARY_STS_REPLY")
    ELSE
     CALL addmsg("Skipping the call to get_ocs_formulary_status")
    ENDIF
    CALL addmsg(" Find existing package type that match...")
    FOR (x = 1 TO value(size(request->meddefqual[cmeddef].meddefflexqual,5)))
     CALL addmsg(build("Pkg UOM: ",request->meddefqual[cmeddef].meddefflexqual[x].pack[1].uom_cd))
     CALL addmsg(build("Pkg Status: ",request->meddefqual[cmeddef].meddefflexqual[x].pack[1].
       db_rec_status))
    ENDFOR
    SELECT INTO "nl:"
     pkg_hit = decode(p.seq,1,0), p.*
     FROM med_package_type p,
      (dummyt d  WITH seq = value(size(request->meddefqual[cmeddef].meddefflexqual,5)))
     PLAN (d)
      JOIN (p
      WHERE (p.uom_cd=request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].uom_cd)
       AND (p.dispense_qty=request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].qty)
       AND p.active_ind=1
       AND (request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].qty > 0))
     DETAIL
      IF (pkg_hit=1)
       request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].package_type_id = p
       .med_package_type_id
      ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].db_rec_status > 0.0))
       request->meddefqual[cmeddef].meddefflexqual[d.seq].pack[1].package_type_id = 0
      ENDIF
     WITH outerjoin = d
    ;end select
    SET cmeddefflexcnt = value(size(request->meddefqual[cmeddef].meddefflexqual,5))
    FOR (cmeddefflex = 1 TO cmeddefflexcnt)
      IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].package_type_id=0)
       AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].qty > 0))
       SELECT INTO "nl:"
        nextseq = seq(medflex_seq,nextval)"##############################;rp0"
        FROM dual
        DETAIL
         request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].package_type_id = cnvtreal(
          nextseq)
        WITH format, nocounter
       ;end select
       SET strdisp = fillstring(40," ")
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE (cv.code_value=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].uom_cd)
        DETAIL
         strdisp = trim(cv.display)
        WITH nocounter
       ;end select
       CALL addmsg(build("Adding package: ",strdisp))
       INSERT  FROM med_package_type mp
        SET mp.med_package_type_id = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1]
         .package_type_id, mp.description = strdisp, mp.dispense_qty = request->meddefqual[cmeddef].
         meddefflexqual[cmeddefflex].pack[1].qty,
         mp.uom_cd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].uom_cd, mp
         .base_uom_cd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].uom_cd, mp
         .updt_cnt = 0,
         mp.updt_dt_tm = cnvtdatetime(curdate,curtime3), mp.updt_task = reqinfo->updt_task, mp
         .updt_id = reqinfo->updt_id,
         mp.updt_applctx = reqinfo->updt_applctx, mp.active_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reqinfo->commit_ind = 0
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data[1].subeventstatus[1].targetobjectvalue = "MED_PACKAGE_TYPE"
        SET reply->status_data.status = "F"
        GO TO exit_script
       ELSE
        SET reply->status_data.status = "S"
       ENDIF
      ELSE
       CALL addmsg(build("Reusing package: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex]
         .pack[1].package_type_id))
      ENDIF
      SET request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].package_type_id = request->
      meddefqual[cmeddef].meddefflexqual[cmeddefflex].pack[1].package_type_id
      CALL addmsg(build("med_def_flex_id= ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
        med_def_flex_id))
      CALL addmsg(build("Status: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
        db_rec_status))
      IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].med_def_flex_id=0.0))
       EXECUTE rxa_add_meddefflex
       CALL addmsg(build("Done with rxa_add_meddefflex...",reply->status_data.status))
       IF ((reply->status_data.status != "S"))
        GO TO exit_script
       ENDIF
      ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].db_rec_status != 2))
       CALL addmsg(
        "================================ Update into MED_DEF_FLEX ==================================="
        )
       CALL addmsg(build("Med_Def_Flex_ID: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex]
         .med_def_flex_id))
       CALL addmsg(build("Package Type ID: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex]
         .package_type_id))
       CALL addmsg(build("Pharmacy Type CD: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex
         ].pharmacy_type_cd))
       CALL addmsg(build("Parent Entity ID: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex
         ].parent_entity_id))
       CALL addmsg(build("Package_type_id: ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex]
         .package_type_id))
       CALL addmsg(build("Active_Ind: ",request->meddefqual[cmeddef].active_ind))
       CALL addmsg(build("Updating med_def_flex: ",request->meddefqual[cmeddef].meddefflexqual[
         cmeddefflex].med_def_flex_id,"pkg:",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex]
         .package_type_id,"Pharmacy_Type:",
         request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].pharmacy_type_cd,"Parent_ID: ",
         request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].parent_entity_id))
       UPDATE  FROM med_def_flex mdf
        SET mdf.parent_entity_id = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         parent_entity_id, mdf.parent_entity_name = request->meddefqual[cmeddef].meddefflexqual[
         cmeddefflex].parent_entity, mdf.sequence = request->meddefqual[cmeddef].meddefflexqual[
         cmeddefflex].sequence,
         mdf.flex_type_cd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].flex_type_cd,
         mdf.flex_sort_flag = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].flex_sort_flag,
         mdf.pharmacy_type_cd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         pharmacy_type_cd,
         mdf.parent_med_def_flex_id = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         parent_med_def_flex_id, mdf.med_package_type_id = request->meddefqual[cmeddef].
         meddefflexqual[cmeddefflex].package_type_id, mdf.updt_cnt = (request->meddefqual[cmeddef].
         meddefflexqual[cmeddefflex].updt_cnt+ 1),
         mdf.updt_dt_tm = cnvtdatetime(curdate,curtime3), mdf.updt_task = reqinfo->updt_task, mdf
         .updt_id = reqinfo->updt_id,
         mdf.updt_applctx = reqinfo->updt_applctx, mdf.active_ind = request->meddefqual[cmeddef].
         meddefflexqual[cmeddefflex].active_ind, mdf.active_status_cd = request->meddefqual[cmeddef].
         meddefflexqual[cmeddefflex].active_status_cd,
         mdf.active_status_dt_tm = cnvtdatetime(curdate,curtime3), mdf.active_status_prsnl_id =
         reqinfo->updt_id
        WHERE (mdf.med_def_flex_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
        med_def_flex_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET reqinfo->commit_ind = 0
        SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
        SET reply->status_data[1].subeventstatus[1].targetobjectvalue = "MED_DEF_FLEX"
        SET reply->status_data.status = "F"
        GO TO exit_script
       ELSE
        SET reply->status_data.status = "S"
       ENDIF
       SET cmedflexidentcnt = value(size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         medidentifierqual,5))
       FOR (cmedidentindex = 1 TO cmedflexidentcnt)
         IF ((((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual[
         cmedidentindex].med_identifier_id=0.0)) OR ((request->meddefqual[cmeddef].meddefflexqual[
         cmeddefflex].medidentifierqual[cmedidentindex].db_rec_status=3))) )
          CALL addmsg("Calling rxa_add_medflexident...")
          EXECUTE rxa_add_medflexident
          CALL addmsg("Done with rxa_add_medflexident...")
          IF ((reply->status_data.status != "S"))
           GO TO exit_script
          ENDIF
          SET nidentsync = 1
         ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medidentifierqual[
         cmedidentindex].db_rec_status=1))
          CALL addmsg("Calling rxa_upd_medflexident...")
          EXECUTE rxa_upd_medflexident
          CALL addmsg("Done with rxa_upd_medflexident...")
          IF ((reply->status_data.status != "S"))
           GO TO exit_script
          ENDIF
          SET nidentsync = 1
         ENDIF
       ENDFOR
       SET cmedflexobjectcnt = value(size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         medflexobjidxqual,5))
       FOR (cmedflexobject = 1 TO cmedflexobjectcnt)
         CALL addmsg(build("med_flex_object_id = ",request->meddefqual[cmeddef].meddefflexqual[
           cmeddefflex].medflexobjidxqual[cmedflexobject].med_flex_object_id))
         CALL addmsg(build("db_rec_status = ",request->meddefqual[cmeddef].meddefflexqual[cmeddefflex
           ].medflexobjidxqual[cmedflexobject].db_rec_status))
         SET icreateitemmaster = 0
         SET ditemmasterid = 0.0
         SET iexecfromupd = 0
         IF (gicurinvpreflevel=cinv_at_manf_level)
          IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
          cmedflexobject].flex_object_type_cd=cmedprod)
           AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
          cmedflexobject].medproductqual[1].manf_item_id > 0.0))
           SELECT INTO "nl:"
            mi.item_master_id
            FROM manufacturer_item mi
            WHERE (mi.item_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
            medflexobjidxqual[cmedflexobject].medproductqual[1].manf_item_id)
            DETAIL
             IF (mi.item_master_id=0)
              icreateitemmaster = 1
             ENDIF
            WITH nocounter
           ;end select
          ENDIF
         ENDIF
         IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].med_flex_object_id=0.0)
          AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].db_rec_status=3))
          SET stat = alterlist(request->chg_id_qual,0)
          SET stat = alterlist(request->del_id_qual,0)
          SET stat = alterlist(request->add_pack_qual,0)
          SET stat = alterlist(request->chg_pack_qual,0)
          SET request->total_packs_to_add = 0
          SET request->total_packs_to_chg = 0
          SET request->total_ids_to_chg = 0
          SET request->total_ids_to_add = 0
          CALL addmsg("Calling rxa_add_medflexobj...")
          EXECUTE rxa_add_medflexobj
          CALL addmsg(build("Done with rxa_add_medflexobj...",reply->status_data.status))
          IF ((reply->status_data.status != "S"))
           GO TO exit_script
          ENDIF
         ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].db_rec_status=1)
          AND (request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].med_flex_object_id != 0))
          CALL addmsg("Entering rxa_upd_medflexobj...")
          SET stat = alterlist(request->addqual,0)
          SET stat = alterlist(request->updqual,0)
          EXECUTE rxa_upd_medflexobj
          CALL addmsg(build("Done with rxa_upd_medflexobj...",reply->status_data.status))
          IF ((reply->status_data.status != "S"))
           GO TO exit_script
          ENDIF
          IF (icreateitemmaster=1)
           SET iexecfromupd = 1
           CALL addmsg("Calling rxa_add_medflexobj inside update...")
           EXECUTE rxa_add_medflexobj
          ENDIF
         ELSEIF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].db_rec_status=2))
          CALL addmsg("Deleting med_flex_object_idx")
          DELETE  FROM med_flex_object_idx mfoi
           WHERE (mfoi.med_flex_object_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
           medflexobjidxqual[cmedflexobject].med_flex_object_id)
          ;end delete
          IF (curqual=0)
           SET reply->status_data.status = "F"
           SET reply->status_data.subeventstatus[1].operationname = "DELETE"
           SET reply->status_data.subeventstatus[1].operationstatus = "F"
           SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = "med_flex_object_idx"
           GO TO exit_script
          ENDIF
         ENDIF
         IF (ditemmasterid > 0
          AND dmanfitemid > 0)
          UPDATE  FROM manufacturer_item mi
           SET mi.item_master_id = ditemmasterid
           WHERE mi.item_id=dmanfitemid
           WITH nocounter
          ;end update
          IF (curqual=0)
           SET reqinfo->commit_ind = 0
           SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = "MANUFACTURER"
           SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
           SET reply->status_data.subeventstatus[1].operationstatus = "F"
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ELSE
       CALL addmsg("Deleting med_def_flex")
       DELETE  FROM med_def_flex
        WHERE (med_def_flex_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
        med_def_flex_id)
       ;end delete
       IF (curqual=0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "DELETE"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "med_del_flex"
        GO TO exit_script
       ENDIF
       SET cmedflexobjectcnt = value(size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         medflexobjidxqual,5))
       FOR (cmedflexobject = 1 TO cmedflexobjectcnt)
        IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
        cmedflexobject].med_flex_object_id > 0))
         CALL addmsg("Deleting med_flex_object_idx")
         DELETE  FROM med_flex_object_idx mfoi
          WHERE (mfoi.med_flex_object_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
          medflexobjidxqual[cmedflexobject].med_flex_object_id)
         ;end delete
         IF (curqual=0)
          SET reply->status_data.status = "F"
          SET reply->status_data.subeventstatus[1].operationname = "DELETE"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = "med_flex_object_idx"
          GO TO exit_script
         ENDIF
        ENDIF
        IF (value(size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
          cmedflexobject].meddispensequal,5))=1)
         IF ((request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[
         cmedflexobject].meddispensequal[1].med_dispense_id > 0))
          CALL addmsg("Deleting med_dispense")
          DELETE  FROM med_dispense mdp
           WHERE (mdp.med_dispense_id=request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
           medflexobjidxqual[cmedflexobject].meddispensequal[1].med_dispense_id)
          ;end delete
          IF (curqual=0)
           SET reply->status_data.status = "F"
           SET reply->status_data.subeventstatus[1].operationname = "DELETE"
           SET reply->status_data.subeventstatus[1].operationstatus = "F"
           SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = "med_dispense"
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
       ENDFOR
      ENDIF
      IF ((request->meddefqual[cmeddef].meddefflexqual[tstore].pharmacy_type_cd=cinpatient)
       AND (get_ocs_formulary_sts_reply->status_data.status != "F")
       AND drxmnemonicid > 0)
       SET lmfoicnt = value(size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
         medflexobjidxqual,5))
       FOR (lmfoiidx = 1 TO lmfoicnt)
         IF (size(request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].medflexobjidxqual[lmfoiidx
          ].meddispensequal,5) > 0)
          SET nflexexists = 0
          SET doutpatientfrmstscd = 0
          SET dinpatientfrmstscd = 0
          SET nmeddispdbrecsts = cnone
          SET dfacilitycd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
          medflexobjidxqual[lmfoiidx].meddispensequal[1].parent_entity_id
          FOR (i = 1 TO size(get_ocs_formulary_sts_reply->syn_qual[1].facility_qual,5))
            IF ((dfacilitycd=get_ocs_formulary_sts_reply->syn_qual[1].facility_qual[i].facility_cd))
             SET nflexexists = 1
             SET doutpatientfrmstscd = get_ocs_formulary_sts_reply->syn_qual[1].facility_qual[i].
             outpatient_cd
             SET dinpatientfrmstscd = get_ocs_formulary_sts_reply->syn_qual[1].facility_qual[i].
             inpatient_cd
             SET nmeddispdbrecsts = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
             medflexobjidxqual[lmfoiidx].meddispensequal[1].db_rec_status
             SET i = (size(get_ocs_formulary_sts_reply->syn_qual[1].facility_qual,5)+ 1)
            ENDIF
          ENDFOR
          IF ( NOT (nflexexists=0
           AND nmeddispdbrecsts=cdelete))
           IF (nmeddispdbrecsts=cdelete
            AND doutpatientfrmstscd=0)
            SET ldelcnt = (ldelcnt+ 1)
            SET stat = alterlist(del_ocs_formulary_sts->qual,ldelcnt)
            SET del_ocs_formulary_sts->qual[ldelcnt].facility_cd = dfacilitycd
            SET del_ocs_formulary_sts->qual[ldelcnt].synonym_id = drxmnemonicid
           ELSE
            SET drxfrmstscd = request->meddefqual[cmeddef].meddefflexqual[cmeddefflex].
            medflexobjidxqual[lmfoiidx].meddispensequal[1].formulary_status_cd
            IF (((dinpatientfrmstscd != drxfrmstscd) OR (nmeddispdbrecsts=cdelete)) )
             SET lupdcnt = (lupdcnt+ 1)
             SET stat = alterlist(upd_ocs_formulary_sts->qual,lupdcnt)
             SET upd_ocs_formulary_sts->qual[lupdcnt].facility_cd = dfacilitycd
             SET upd_ocs_formulary_sts->qual[lupdcnt].synonym_id = drxmnemonicid
             SET upd_ocs_formulary_sts->qual[lupdcnt].update_ind = nflexexists
             SET upd_ocs_formulary_sts->qual[lupdcnt].outpatient_cd = doutpatientfrmstscd
             IF (nmeddispdbrecsts=cdelete)
              SET upd_ocs_formulary_sts->qual[lupdcnt].inpatient_cd = 0
             ELSEIF (dinpatientfrmstscd != drxfrmstscd)
              SET upd_ocs_formulary_sts->qual[lupdcnt].inpatient_cd = drxfrmstscd
              IF ((upd_ocs_formulary_sts->qual[lupdcnt].inpatient_cd=dtnfcd))
               SET upd_ocs_formulary_sts->qual[lupdcnt].inpatient_cd = dnonformularycd
              ENDIF
             ENDIF
            ELSE
             CALL addmsg("Skipping formulary_status processing: Not changed")
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ELSE
       CALL addmsg("Skipping formulary_status processing")
      ENDIF
    ENDFOR
    RECORD tmp_bif(
      1 base_issue_factor = f8
      1 medprodqual[*]
        2 med_product_id = f8
      1 meddispqual[*]
        2 item_id = f8
      1 itemdefqual[*]
        2 item_id = f8
    ) WITH protect
    SELECT DISTINCT INTO "nl:"
     mi.med_product_id
     FROM med_identifier mi
     PLAN (mi
      WHERE (mi.item_id=request->meddefqual[cmeddef].item_id)
       AND mi.active_ind=1
       AND mi.med_product_id > 0)
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(tmp_bif->medprodqual,cnt), tmp_bif->medprodqual[cnt].
      med_product_id = mi.med_product_id
     WITH nocounter
    ;end select
    IF (value(size(tmp_bif->medprodqual,5)) > 0)
     SELECT DISTINCT INTO "nl:"
      id.item_id
      FROM (dummyt d  WITH seq = value(size(tmp_bif->medprodqual,5))),
       med_product mp,
       manufacturer_item manf,
       item_definition id
      PLAN (d)
       JOIN (mp
       WHERE (mp.med_product_id=tmp_bif->medprodqual[d.seq].med_product_id))
       JOIN (manf
       WHERE manf.item_id=mp.manf_item_id)
       JOIN (id
       WHERE id.item_id > 0
        AND id.item_id IN (manf.item_id, manf.item_master_id))
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(tmp_bif->itemdefqual,cnt), tmp_bif->itemdefqual[cnt].item_id
        = id.item_id
      WITH nocounter
     ;end select
     IF (value(size(tmp_bif->itemdefqual,5)) > 0)
      SELECT DISTINCT INTO "nl:"
       mi.item_id
       FROM (dummyt d  WITH seq = value(size(tmp_bif->medprodqual,5))),
        med_identifier mi
       PLAN (d)
        JOIN (mi
        WHERE (mi.med_product_id=tmp_bif->medprodqual[d.seq].med_product_id)
         AND mi.active_ind=1)
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(tmp_bif->meddispqual,cnt), tmp_bif->meddispqual[cnt].item_id
         = mi.item_id
       WITH nocounter
      ;end select
      IF (value(size(tmp_bif->meddispqual,5)) > 0)
       SELECT INTO "nl:"
        md.*
        FROM (dummyt d  WITH seq = value(size(tmp_bif->meddispqual,5))),
         med_def_flex mdf,
         med_flex_object_idx mfoi,
         med_dispense md
        PLAN (d)
         JOIN (mdf
         WHERE (mdf.item_id=tmp_bif->meddispqual[d.seq].item_id)
          AND mdf.flex_type_cd=csyspkg)
         JOIN (mfoi
         WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
          AND mfoi.flex_object_type_cd=cmeddisp)
         JOIN (md
         WHERE md.med_dispense_id=mfoi.parent_entity_id)
        HEAD REPORT
         tmp_bif->base_issue_factor = md.base_issue_factor
        DETAIL
         IF ((md.base_issue_factor < tmp_bif->base_issue_factor))
          tmp_bif->base_issue_factor = md.base_issue_factor
         ENDIF
        WITH nocounter
       ;end select
       CALL addmsg(build("Using BIF:",tmp_bif->base_issue_factor))
       UPDATE  FROM (dummyt d  WITH seq = value(size(tmp_bif->itemdefqual,5))),
         item_definition id
        SET id.base_issue_factor = tmp_bif->base_issue_factor
        PLAN (d)
         JOIN (id
         WHERE id.item_id > 0
          AND (id.item_id=tmp_bif->itemdefqual[d.seq].item_id))
        WITH nocounter
       ;end update
       UPDATE  FROM item_definition id
        SET id.base_issue_factor = request->meddefqual[cmeddef].base_issue_factor
        WHERE id.item_id > 0
         AND (id.item_id=request->meddefqual[cmeddef].item_id)
        WITH nocounter
       ;end update
      ELSE
       CALL addmsg(build("There Were No Item ID's Found To Check BIF For Item #",request->meddefqual[
         cmeddef].item_id))
      ENDIF
     ELSE
      CALL addmsg(build("There Are No Corresponding Rows On Item Definition For Item #",request->
        meddefqual[cmeddef].item_id))
     ENDIF
    ELSE
     CALL addmsg(build("No Rows Exist On Med Identifier Table For Item #",request->meddefqual[cmeddef
       ].item_id))
    ENDIF
    IF (gicurinvpreflevel=cinv_at_manf_level
     AND (request->meddefqual[cmeddef].meddefflexqual[1].pharmacy_type_cd=cretail))
     RECORD tmp_lot(
       1 medprodqual[*]
         2 med_product_id = f8
       1 itemdefqual[*]
         2 item_id = f8
     ) WITH protect
     SELECT DISTINCT INTO "nl:"
      mi.med_product_id
      FROM med_identifier mi
      PLAN (mi
       WHERE (mi.item_id=request->meddefqual[cmeddef].item_id)
        AND mi.active_ind=1
        AND mi.med_product_id > 0)
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt = (cnt+ 1), stat = alterlist(tmp_lot->medprodqual,cnt), tmp_lot->medprodqual[cnt].
       med_product_id = mi.med_product_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) != 0)
      CALL addmsg(errmsg)
      SET errmsg = ""
     ENDIF
     IF (value(size(tmp_lot->medprodqual,5)) > 0)
      SELECT DISTINCT INTO "nl:"
       id.item_id
       FROM (dummyt d  WITH seq = value(size(tmp_lot->medprodqual,5))),
        med_product mp,
        manufacturer_item manf,
        item_definition id
       PLAN (d)
        JOIN (mp
        WHERE (mp.med_product_id=tmp_lot->medprodqual[d.seq].med_product_id))
        JOIN (manf
        WHERE manf.item_id=mp.manf_item_id)
        JOIN (id
        WHERE id.item_id > 0
         AND id.item_id=manf.item_master_id)
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(tmp_lot->itemdefqual,cnt), tmp_lot->itemdefqual[cnt].item_id
         = id.item_id
       WITH nocounter
      ;end select
      IF (error(errmsg,0) != 0)
       CALL addmsg(errmsg)
       SET errmsg = ""
      ENDIF
      IF (value(size(tmp_lot->itemdefqual,5)) > 0)
       UPDATE  FROM (dummyt d  WITH seq = value(size(tmp_lot->itemdefqual,5))),
         item_definition id
        SET id.lot_tracking_ind = validate(request->meddefqual[cmeddef].lot_tracking_ind,0)
        PLAN (d)
         JOIN (id
         WHERE id.item_id > 0
          AND (id.item_id=tmp_lot->itemdefqual[d.seq].item_id))
        WITH nocounter
       ;end update
       IF (error(errmsg,0) != 0)
        CALL addmsg(errmsg)
        SET errmsg = ""
       ENDIF
      ELSE
       CALL addmsg(build("There Are No Corresponding Rows On Item Definition For Item #",request->
         meddefqual[cmeddef].item_id))
      ENDIF
     ELSE
      CALL addmsg(build("No Rows Exist On Med Identifier Table For Item #",request->meddefqual[
        cmeddef].item_id))
     ENDIF
    ENDIF
    IF (gicurinvpreflevel=cinv_at_drug_level
     AND (request->meddefqual[cmeddef].meddefflexqual[1].pharmacy_type_cd=cretail))
     SELECT INTO "NL:"
      *
      FROM medication_definition md
      PLAN (md
       WHERE (md.item_id=request->meddefqual[cmeddef].item_id))
      HEAD REPORT
       IF (md.inv_master_id > 0)
        dgroupedproditemid = md.inv_master_id
       ENDIF
      WITH nocounter
     ;end select
     IF (error(errmsg,0) != 0)
      CALL addmsg(errmsg)
      SET errmsg = ""
     ENDIF
     IF (dgroupedproditemid > 0.0)
      UPDATE  FROM item_definition id
       SET id.lot_tracking_ind = validate(request->meddefqual[cmeddef].lot_tracking_ind,0)
       WHERE id.item_id > 0
        AND id.item_id=dgroupedproditemid
       WITH nocounter
      ;end update
      IF (error(errmsg,0) != 0)
       CALL addmsg(errmsg)
       SET errmsg = ""
      ENDIF
     ELSE
      CALL addmsg(build("There Are No Corresponding Rows On Item Definition For Item #",
        dgroupedproditemid))
     ENDIF
    ENDIF
    IF ((((request->meddefqual[cmeddef].med_type_flag != 0)) OR ((request->meddefqual[cmeddef].
    premix_ind=1))) )
     CALL addmsg("Deleting rows from med_ingred_set table.....")
     DELETE  FROM med_ingred_set mis
      WHERE (mis.parent_item_id=request->meddefqual[cmeddef].item_id)
      WITH nocounter
     ;end delete
     CALL addmsg("Assigning new med_ingred_set_id to ingredients......")
     SET cingredcount = value(size(request->meddefqual[cmeddef].medingredqual,5))
     SET cingredidx = 0
     IF ((((request->meddefqual[cmeddef].med_type_flag != 0)) OR ((request->meddefqual[cmeddef].
     premix_ind=1))) )
      FOR (cingredidx = 1 TO cingredcount)
        SELECT INTO "nl:"
         nextseq = seq(medflex_seq,nextval)"##############################;rp0"
         FROM dual
         DETAIL
          request->meddefqual[cmeddef].medingredqual[cingredidx].med_ingred_set_id = cnvtreal(nextseq
           )
         WITH format, nocounter
        ;end select
      ENDFOR
     ENDIF
     CALL addmsg("Inserting rows to med_ingred_set table......")
     INSERT  FROM (dummyt d  WITH seq = value(cingredcount)),
       med_ingred_set mis
      SET mis.med_ingred_set_id = request->meddefqual[cmeddef].medingredqual[d.seq].med_ingred_set_id,
       mis.parent_item_id = request->meddefqual[cmeddef].item_id, mis.child_item_id = request->
       meddefqual[cmeddef].medingredqual[d.seq].child_item_id,
       mis.child_med_prod_id = request->meddefqual[cmeddef].medingredqual[d.seq].child_med_prod_id,
       mis.child_pkg_type_id = request->meddefqual[cmeddef].medingredqual[d.seq].child_pkg_type_id,
       mis.inc_in_total_ind = request->meddefqual[cmeddef].medingredqual[d.seq].inc_in_total_ind,
       mis.base_ind = request->meddefqual[cmeddef].medingredqual[d.seq].base_ind, mis.cmpd_qty =
       request->meddefqual[cmeddef].medingredqual[d.seq].cmpd_qty, mis.sequence = request->
       meddefqual[cmeddef].medingredqual[d.seq].sequence,
       mis.default_action_cd = request->meddefqual[cmeddef].medingredqual[d.seq].default_action_cd,
       mis.normalized_rate_ind = validate(request->meddefqual[cmeddef].medingredqual[d.seq].
        normalized_rate_ind,0), mis.updt_cnt = 0,
       mis.updt_dt_tm = cnvtdatetime(curdate,curtime3), mis.updt_task = reqinfo->updt_task, mis
       .updt_id = reqinfo->updt_id,
       mis.updt_applctx = reqinfo->updt_applctx, mis.strength = validate(request->meddefqual[cmeddef]
        .medingredqual[d.seq].strength,0), mis.strength_unit_cd = validate(request->meddefqual[
        cmeddef].medingredqual[d.seq].strength_unit_cd,0),
       mis.volume = validate(request->meddefqual[cmeddef].medingredqual[d.seq].volume,0), mis
       .volume_unit_cd = validate(request->meddefqual[cmeddef].medingredqual[d.seq].volume_unit_cd,0)
      PLAN (d)
       JOIN (mis)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reqinfo->commit_ind = 0
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
      SET reply->status_data[1].subeventstatus[1].targetobjectvalue = "MEDINGREDSET"
      SET reply->status_data.status = "F"
      GO TO exit_script
     ELSE
      SET reply->status_data.status = "S"
     ENDIF
    ENDIF
    SET ireusableind = 0
    SELECT INTO "nl:"
     *
     FROM med_dispense md
     WHERE (md.item_id=request->meddefqual[cmeddef].item_id)
     DETAIL
      IF (md.reusable_ind=1)
       ireusableind = 1
      ENDIF
     WITH nocounter
    ;end select
    UPDATE  FROM item_definition id
     SET id.reusable_ind = ireusableind
     WHERE (id.item_id=request->meddefqual[cmeddef].item_id)
     WITH nocounter
    ;end update
    IF (validate(request->meddefqual[cmeddef].tpn_group_qual[1].tpn_group_cd))
     SET ctpngroupcnt = size(request->meddefqual[cmeddef].tpn_group_qual,5)
     IF (ctpngroupcnt > 0)
      SET stat = alterlist(tmp_seq_request->tpn_group,(ctotalgroupcnt+ ctpngroupcnt))
      FOR (ctpnidx = 1 TO ctpngroupcnt)
       SET tmp_seq_request->tpn_group[(ctpnidx+ ctotalgroupcnt)].tpn_group_cd = request->meddefqual[
       cmeddef].tpn_group_qual[ctpnidx].tpn_group_cd
       CALL addmsg(build("Adding TPN Group..",request->meddefqual[cmeddef].tpn_group_qual[ctpnidx].
         tpn_group_cd,"..for Resequence..."))
      ENDFOR
      SET ctotalgroupcnt = (ctotalgroupcnt+ ctpngroupcnt)
     ELSE
      CALL addmsg("No TPN Groups to Resequence......")
     ENDIF
    ELSE
     CALL addmsg("No TPN_Group_Qual to Resequence......")
    ENDIF
  ENDFOR
  IF ((reply->status_data.status="S"))
   IF (((validate(request->total_ids_to_add,0)+ nidentsync) > 0))
    CALL addmsg("***Syncing identifiers***")
    EXECUTE rx_upd_sync_ident
    IF ((reply->status_data.status != "S"))
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF (size(tmp_seq_request->tpn_group,5) > 0)
   CALL addmsg("Executing rx_upd_tpn_group_seq......")
   EXECUTE rx_upd_tpn_group_seq  WITH replace("REQUEST","TMP_SEQ_REQUEST"), replace("REPLY",
    "TMP_SEQ_REPLY")
   IF ((tmp_seq_reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = "TPN SEQUENCE"
    SET reply->status_data[1].subeventstatus[1].targetobjectvalue = "TPN SEQUENCE"
    CALL addmsg("Resequence failed......")
    GO TO failed_common
   ELSE
    CALL addmsg("Resequenced successfully......")
   ENDIF
  ENDIF
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
#failed_common
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  SET cmeddefcnt = value(size(request->meddefqual,5))
  SET cmeddefidx = 0
  SET stat = alterlist(reply->meddefqual,cmeddefcnt)
  FOR (cmeddefidx = 1 TO cmeddefcnt)
    SET nsyncinvfactor = 0
    SET dinvfactor = 0
    IF (ninvtrackexist=1)
     IF ((request->meddefqual[cmeddefidx].inv_tracking_level=cinv_at_drug_level)
      AND validate(request->meddefqual[cmeddefidx].inv_factor_nbr,0) > 0)
      SET nsyncinvfactor = 1
      SET dinvfactor = request->meddefqual[cmeddefidx].inv_factor_nbr
      CALL addmsg(build("Sync inv factor for prod 1...dInvFactor=",dinvfactor))
     ENDIF
    ENDIF
    SET reply->meddefqual[cmeddefidx].item_id = request->meddefqual[cmeddefidx].item_id
    SET reply->meddefqual[cmeddefidx].compound_text_id = request->meddefqual[cmeddefidx].
    compound_text_id
    IF ((request->meddefqual[cmeddefidx].med_type_flag=2))
     SET cingredcnt = value(size(request->meddefqual[cmeddefidx].medingredqual,5))
     SET cingredidx = 0
     SET stat = alterlist(reply->meddefqual[cmeddefidx].medingredqual,cingredcnt)
     FOR (cingredidx = 1 TO cingredcnt)
       SET reply->meddefqual[cmeddefidx].medingredqual[cingredidx].med_ingred_set_id = request->
       meddefqual[cmeddefidx].medingredqual[cingredidx].med_ingred_set_id
     ENDFOR
    ENDIF
    SET reply->meddefqual[cmeddefidx].ordcat[1].catalog_cd = request->meddefqual[cmeddefidx].ordcat[1
    ].catalog_cd
    SET cmnemcnt = value(size(request->meddefqual[cmeddefidx].ordcat[1].qual_mnemonic,5))
    SET cmnemidx = 0
    SET stat = alterlist(reply->meddefqual[cmeddefidx].ordcat[1].qual_mnemonic,cmnemcnt)
    FOR (cmnemidx = 1 TO cmnemcnt)
      SET reply->meddefqual[cmeddefidx].ordcat[1].qual_mnemonic[cmnemidx].synonym_id = request->
      meddefqual[cmeddefidx].ordcat[1].qual_mnemonic[cmnemidx].synonym_id
    ENDFOR
    SET cflexcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual,5))
    SET cflexidx = 0
    SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual,cflexcnt)
    FOR (cflexidx = 1 TO cflexcnt)
      SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].med_def_flex_id = request->
      meddefqual[cmeddefidx].meddefflexqual[cflexidx].med_def_flex_id
      SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].parent_entity_id = request->
      meddefqual[cmeddefidx].meddefflexqual[cflexidx].parent_entity_id
      SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].package_type_id = request->
      meddefqual[cmeddefidx].meddefflexqual[cflexidx].package_type_id
      SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].pack[1].package_type_id = request->
      meddefqual[cmeddefidx].meddefflexqual[cflexidx].package_type_id
      SET cflexidcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
        medidentifierqual,5))
      SET cflexididx = 0
      SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medidentifierqual,
       cflexidcnt)
      FOR (cflexididx = 1 TO cflexidcnt)
       SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medidentifierqual[cflexididx].
       med_identifier_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
       medidentifierqual[cflexididx].med_identifier_id
       SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medidentifierqual[cflexididx].
       parent_entity_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medidentifierqual[
       cflexididx].parent_entity_id
      ENDFOR
      SET cflexobjcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
        medflexobjidxqual,5))
      SET cflexididx = 0
      SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual,
       cflexobjcnt)
      FOR (cflexobjidx = 1 TO cflexobjcnt)
        SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
        med_flex_object_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
        medflexobjidxqual[cflexobjidx].med_flex_object_id
        SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
        parent_entity_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
        medflexobjidxqual[cflexobjidx].parent_entity_id
        SET cflexobjcd = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[
        cflexobjidx].flex_object_type_cd
        IF (cflexobjcd=coedef)
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medoedefaultsqual,1)
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         medoedefaultsqual[1].med_oe_defaults_id = request->meddefqual[cmeddefidx].meddefflexqual[
         cflexidx].medflexobjidxqual[cflexobjidx].medoedefaultsqual[1].med_oe_defaults_id
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         medoedefaultsqual[1].comment1_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
         medflexobjidxqual[cflexobjidx].medoedefaultsqual[1].comment1_id
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         medoedefaultsqual[1].comment2_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
         medflexobjidxqual[cflexobjidx].medoedefaultsqual[1].comment2_id
        ELSEIF (cflexobjcd=cmedprod)
         IF (ninvtrackexist=1)
          IF ((request->meddefqual[cmeddefidx].inv_tracking_level=cinv_at_manf_level)
           AND validate(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[
           cflexobjidx].medproductqual[1].inv_factor_nbr,0) > 0)
           SET nsyncinvfactor = 1
           SET dinvfactor = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].inv_factor_nbr
           CALL addmsg(build("Sync inv factor for manf 1...dInvFactor=",dinvfactor))
          ELSEIF ((request->meddefqual[cmeddefidx].inv_tracking_level=cinv_at_manf_level))
           SET dinvfactor = 0
           SELECT INTO "NL:"
            mp.inv_factor_nbr
            FROM med_product mp
            PLAN (mp
             WHERE (mp.med_product_id=request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
             medflexobjidxqual[cflexobjidx].medproductqual[1].med_product_id)
              AND mp.med_product_id > 0
              AND ((mp.inv_factor_nbr+ 0) > 0))
            DETAIL
             dinvfactor = mp.inv_factor_nbr
            WITH nocounter
           ;end select
           IF (dinvfactor > 0)
            SET nsyncinvfactor = 1
            CALL addmsg(build("Sync inv factor for manf 2...dInvFactor=",dinvfactor))
           ENDIF
          ENDIF
          IF (nsyncinvfactor=1)
           SET lmanfcnt = (size(sync_inv_req->manf_qual,5)+ 1)
           SET stat = alterlist(sync_inv_req->manf_qual,lmanfcnt)
           SET sync_inv_req->manf_qual[lmanfcnt].manf_item_id = request->meddefqual[cmeddefidx].
           meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].manf_item_id
           SET sync_inv_req->manf_qual[lmanfcnt].inv_factor_nbr = dinvfactor
          ENDIF
         ENDIF
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medproductqual,1)
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         medproductqual[1].med_product_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
         medflexobjidxqual[cflexobjidx].medproductqual[1].med_product_id
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         medproductqual[1].manf_item_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
         medflexobjidxqual[cflexobjidx].medproductqual[1].manf_item_id
         SET cpackindex = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].pack,5))
         CALL addmsg(build("cPackIndex= ",cpackindex))
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medproductqual[1].pack,cpackindex)
         FOR (x = 1 TO cpackindex)
          CALL addmsg(build("med_product_id: ",reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx]
            .medflexobjidxqual[cflexobjidx].medproductqual[1].med_product_id))
          CALL addmsg(build("qty= ",request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
            medflexobjidxqual[cflexobjidx].medproductqual[1].pack[x].qty))
         ENDFOR
         SELECT INTO "NL:"
          *
          FROM manufacturer_item mi
          WHERE (mi.item_id=reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[
          cflexobjidx].medproductqual[1].manf_item_id)
          DETAIL
           reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].item_master_id = mi.item_master_id
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          FROM package_type pt,
           (dummyt d  WITH seq = value(cpackindex))
          PLAN (d)
           JOIN (pt
           WHERE (pt.item_id=reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].manf_item_id)
            AND (pt.qty=request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[
           cflexobjidx].medproductqual[1].pack[d.seq].qty))
          DETAIL
           reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].pack[d.seq].package_type_id = pt.package_type_id, reply->meddefqual[
           cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
           pack[d.seq].qty = pt.qty, reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].pack[d.seq].base_package_type_ind = pt
           .base_package_type_ind
          WITH nocounter
         ;end select
         SET cmanfidcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].medidentifierqual,5))
         SET cmanfididx = 0
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medproductqual[1].medidentifierqual,cmanfidcnt)
         FOR (cmanfididx = 1 TO cmanfidcnt)
          SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
          medproductqual[1].medidentifierqual[cmanfididx].med_identifier_id = request->meddefqual[
          cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
          medidentifierqual[cmanfididx].med_identifier_id
          SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
          medproductqual[1].medidentifierqual[cmanfididx].parent_entity_id = request->meddefqual[
          cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
          medidentifierqual[cmanfididx].parent_entity_id
         ENDFOR
         SET ccostidcnt = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].medcosthxqual,5))
         SET ccostididx = 0
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medproductqual[1].medcosthxqual,ccostidcnt)
         FOR (ccostididx = 1 TO ccostidcnt)
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medcosthxqual[ccostididx].med_cost_hx_id = request->meddefqual[
           cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
           medcosthxqual[ccostididx].med_cost_hx_id
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medcosthxqual[ccostididx].updt_id = request->meddefqual[cmeddefidx].
           meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].medcosthxqual[
           ccostididx].updt_id
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medcosthxqual[ccostididx].updt_dt_tm = request->meddefqual[cmeddefidx].
           meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].medcosthxqual[
           ccostididx].updt_dt_tm
         ENDFOR
         SET lmpdcount = value(size(request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
           medflexobjidxqual[cflexobjidx].medproductqual[1].medproddescqual,5))
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].medproductqual[1].medproddescqual,lmpdcount)
         FOR (lmpdidx = 1 TO lmpdcount)
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medproddescqual[lmpdidx].med_prod_desc_id = request->meddefqual[
           cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
           medproddescqual[lmpdidx].med_prod_desc_id
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medproddescqual[lmpdidx].updt_dt_tm = request->meddefqual[cmeddefidx].
           meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].medproddescqual[
           lmpdidx].updt_dt_tm
           SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
           medproductqual[1].medproddescqual[lmpdidx].field_type_cd = request->meddefqual[cmeddefidx]
           .meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].medproductqual[1].
           medproddescqual[lmpdidx].field_type_cd
         ENDFOR
        ELSEIF (cflexobjcd=cmeddisp)
         IF (ninvtrackexist=1)
          IF ((request->meddefqual[cmeddefidx].inv_tracking_level=cinv_at_drug_level)
           AND nsyncinvfactor=0)
           SET dinvfactor = 0
           SELECT INTO "NL:"
            md.inv_factor_nbr
            FROM med_dispense md
            PLAN (md
             WHERE (md.med_dispense_id=request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
             medflexobjidxqual[cflexobjidx].meddispensequal[1].med_dispense_id)
              AND md.med_dispense_id > 0
              AND ((md.inv_factor_nbr+ 0) > 0))
            DETAIL
             dinvfactor = md.inv_factor_nbr
            WITH nocounter
           ;end select
           IF (dinvfactor > 0)
            SET nsyncinvfactor = 1
            CALL addmsg(build("Sync inv factor for prod 2...dInvFactor=",dinvfactor))
           ENDIF
          ENDIF
         ENDIF
         SET stat = alterlist(reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].
          medflexobjidxqual[cflexobjidx].meddispensequal,1)
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         meddispensequal[1].med_dispense_id = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx
         ].medflexobjidxqual[cflexobjidx].meddispensequal[1].med_dispense_id
         SET reply->meddefqual[cmeddefidx].meddefflexqual[cflexidx].medflexobjidxqual[cflexobjidx].
         meddispensequal[1].parent_entity_id = request->meddefqual[cmeddefidx].meddefflexqual[
         cflexidx].medflexobjidxqual[cflexobjidx].meddispensequal[1].parent_entity_id
        ENDIF
      ENDFOR
      IF (nsyncinvfactor=1
       AND (sync_inv_req->item_id=0))
       CALL addmsg("Need to sync...Populate the product information")
       IF ((request->meddefqual[cmeddefidx].meddefflexqual[cflexidx].pharmacy_type_cd=0))
        SET sync_inv_req->pharmacy_type_cd = cinpatient
       ELSE
        SET sync_inv_req->pharmacy_type_cd = request->meddefqual[cmeddefidx].meddefflexqual[cflexidx]
        .pharmacy_type_cd
       ENDIF
       SET sync_inv_req->item_id = reply->meddefqual[cmeddefidx].item_id
       IF (gicurinvpreflevel=cinv_at_drug_level)
        SET sync_inv_req->inv_factor_nbr = dinvfactor
        SET stat = alterlist(sync_inv_req->manf_qual,0)
       ELSE
        SET sync_inv_req->inv_factor_nbr = 0
       ENDIF
      ENDIF
    ENDFOR
    IF (nsyncinvfactor=1)
     CALL addmsg("Calling rx_upd_sync_inv_factor...")
     EXECUTE rx_upd_sync_inv_factor  WITH replace("REQUEST","SYNC_INV_REQ"), replace("REPLY",
      "SYNC_INV_REP")
     CALL addmsg(build("Done with rx_upd_sync_inv_factor, status=",sync_inv_rep->status_data.status))
     IF ((sync_inv_rep->status_data.status != "S"))
      SET reply->status_data.status = sync_inv_rep->status_data.status
      SET reply->status_data.subeventstatus[1].operationname = sync_inv_rep->status_data.
      subeventstatus[1].operationname
      SET reply->status_data.subeventstatus[1].operationstatus = sync_inv_rep->status_data.
      subeventstatus[1].operationstatus
      SET reply->status_data.subeventstatus[1].targetobjectname = sync_inv_rep->status_data.
      subeventstatus[1].targetobjectname
      SET reply->status_data.subeventstatus[1].targetobjectvalue = sync_inv_rep->status_data.
      subeventstatus[1].targetobjectvalue
     ENDIF
     SET sync_inv_req->pharmacy_type_cd = 0
     SET sync_inv_req->item_id = 0
     SET sync_inv_req->inv_factor_nbr = 0
     SET stat = alterlist(sync_inv_req->manf_qual,0)
     SET nsyncinvfactor = 0
    ENDIF
    EXECUTE rx_maintain_meddef_org_rr_incl  WITH replace("REQUEST",i_request), replace("REPLY",
     i_reply)
    SET i_request->item_id = reply->meddefqual[cmeddefidx].item_id
    CALL addmsg("calling rx_maintain_meddef_org...")
    EXECUTE rx_maintain_meddef_org  WITH replace("REQUEST",i_request), replace("REPLY",i_reply)
    CALL addmsg(build("Done with calling rx_maintain_meddef_org, status=",i_reply->status_data.status
      ))
    IF (checkdic("MM_ADD_INITIAL_ORG_COST","P",0) > 0)
     IF ( NOT (validate(orgcostreq,0)))
      RECORD orgcostreq(
        1 item_id = f8
        1 reactivate_ind = i2
      ) WITH protect
     ENDIF
     SET orgcostreq->item_id = reply->meddefqual[cmeddefidx].item_id
     IF ((orgcostreq->item_id > 0))
      EXECUTE mm_add_initial_org_cost  WITH replace("REQUEST","ORGCOSTREQ")
     ENDIF
    ENDIF
  ENDFOR
  IF (ldelcnt > 0)
   CALL addmsg(build("Calling del_ocs_fromulary_status.  lDelCnt = ",ldelcnt))
   EXECUTE del_ocs_formulary_status  WITH replace("REQUEST","DEL_OCS_FORMULARY_STS")
  ENDIF
  IF (lupdcnt > 0)
   CALL addmsg(build("Calling update_ocs_fromulary_status.  lUpdCnt = ",lupdcnt))
   EXECUTE update_ocs_formulary_status  WITH replace("REQUEST","UPD_OCS_FORMULARY_STS")
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL addmsg(build("Final Status: ",reply->status_data.status))
 SET reply->elapsed_time = ((curtime3 - start_time)/ 100)
 CALL addmsg(build("elapsed time: ",reply->elapsed_time))
 CALL echo("last mod = 074")
 CALL echo("mod date = 09/17/2014")
END GO
