CREATE PROGRAM ctp_pha_formulary_qry:dba
 DECLARE 4062_facil_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2548616"))
 DECLARE 4062_sys_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2548614"))
 DECLARE 4062_sysp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2548615"))
 DECLARE 4063_disp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2553256"))
 DECLARE 4063_medprod_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2553258"))
 DECLARE 4063_orderable_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2553254"))
 DECLARE 4500_inpt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!101131"))
 DECLARE 4500_retl_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!101132"))
 DECLARE 11000_desc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3290"))
 DECLARE 11000_ndc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3295"))
 DECLARE query_item_ids(null) = null
 SUBROUTINE query_item_ids(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE idx4 = i4 WITH protect, noconstant(0)
   DECLARE idx5 = i4 WITH protect, noconstant(0)
   DECLARE active_ind_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE item_id_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE med_type_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE facility_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE pharmacy_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE pharmacy_type_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE ident_search_type_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE ident_search_str_parser = vc WITH protect, noconstant("1 = 1")
   IF (size(request->pharmacy_type,5) > 0)
    SET pharmacy_type_parser = concat("expand(idx, 1, size(request->pharmacy_type, 5)",
     ", mdf.pharmacy_type_cd",", request->pharmacy_type[idx].code_value)")
   ENDIF
   IF (size(request->item,5) > 0)
    SET item_id_parser =
    "expand(idx2, 1, size(request->item, 5), md.item_id, request->item[idx2].id)"
   ENDIF
   IF (size(request->med_type,5) > 0)
    SET med_type_parser =
    "expand(idx3, 1, size(request->med_type, 5), md.med_type_flag, request->med_type[idx3].flag)"
   ENDIF
   IF (size(request->facility,5) > 0)
    SET facility_parser = concat("(expand(idx4, 1, size(request->facility, 5)",
     ", mfoi.parent_entity_id",", request->facility[idx4].code_value)",
     " or mfoi.parent_entity_id = 0)")
   ENDIF
   IF (size(request->pharmacy,5) > 0)
    SET pharmacy_parser = concat("expand(idx5, 1, size(request->pharmacy, 5)",", sa.location_cd",
     ", request->pharmacy[idx5].code_value)")
   ENDIF
   IF ((request->item_active_ind=0))
    SET active_ind_parser = "mdf.active_ind = 0"
   ELSEIF ((request->item_active_ind=1))
    SET active_ind_parser = "mdf.active_ind = 1"
   ENDIF
   IF ((request->ident_search_type > 0))
    SET ident_search_type_parser = build("mi.med_identifier_type_cd = ",request->ident_search_type)
   ENDIF
   IF (textlen(trim(request->ident_search_str)) > 0)
    SET ident_search_str_parser = build("mi.value = patstring(",request->ident_search_str,")")
   ENDIF
   SELECT
    IF (textlen(trim(request->ident_search_str))=0
     AND (request->ident_search_type=0)
     AND size(request->facility,5)=0
     AND size(request->pharmacy,5)=0)
     FROM medication_definition md,
      med_def_flex mdf
     PLAN (md
      WHERE parser(med_type_parser)
       AND parser(item_id_parser))
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.flex_type_cd=4062_sys_cd
       AND parser(active_ind_parser)
       AND parser(pharmacy_type_parser))
    ELSEIF (textlen(trim(request->ident_search_str))=0
     AND (request->ident_search_type=0)
     AND ((size(request->facility,5) > 0) OR (size(request->pharmacy,5) > 0)) )
     FROM medication_definition md,
      med_def_flex mdf,
      (
      (
      (SELECT
       pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
       FROM med_def_flex mdf,
        med_flex_object_idx mfoi
       WHERE mdf.item_id=mdf.item_id
        AND mdf.flex_type_cd=4062_sysp_cd
        AND parser(pharmacy_type_parser)
        AND mdf.med_package_type_id != 0
        AND mfoi.med_def_flex_id=mdf.med_def_flex_id
        AND mfoi.flex_object_type_cd=4063_orderable_cd
        AND ((parser(facility_parser)) UNION (
       (SELECT
        pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
        FROM med_def_flex mdf,
         stored_at sa
        WHERE mdf.flex_type_cd=4062_sys_cd
         AND mdf.pharmacy_type_cd=4500_inpt_cd
         AND sa.item_id=mdf.item_id
         AND ((parser(pharmacy_parser)) UNION (
        (SELECT
         pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
         FROM med_def_flex mdf,
          med_flex_object_idx mfoi,
          med_product mp,
          stored_at sa
         WHERE mdf.flex_type_cd=4062_sys_cd
          AND mdf.pharmacy_type_cd=4500_retl_cd
          AND mfoi.med_def_flex_id=mdf.med_def_flex_id
          AND mfoi.flex_object_type_cd=4063_medprod_cd
          AND mp.med_product_id=mfoi.parent_entity_id
          AND mp.active_ind=1
          AND sa.item_id=mp.manf_item_id
          AND parser(pharmacy_parser)))) )))
       WITH sqltype("f8","f8"), rdbunion, expand = 2))
      locs)
     PLAN (md
      WHERE parser(med_type_parser))
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.flex_type_cd=4062_sys_cd
       AND parser(active_ind_parser)
       AND parser(pharmacy_type_parser)
       AND parser(item_id_parser))
      JOIN (locs
      WHERE locs.pharmacy_type_cd=mdf.pharmacy_type_cd
       AND locs.item_id=mdf.item_id)
    ELSEIF (((textlen(trim(request->ident_search_str)) > 0) OR ((request->ident_search_type > 0)))
     AND ((size(request->facility,5)=0) OR (size(request->pharmacy,5)=0)) )
     FROM medication_definition md,
      med_def_flex mdf,
      med_identifier mi
     PLAN (md
      WHERE parser(med_type_parser)
       AND parser(item_id_parser))
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.flex_type_cd=4062_sys_cd
       AND parser(active_ind_parser)
       AND parser(pharmacy_type_parser))
      JOIN (mi
      WHERE mi.item_id=mdf.item_id
       AND mi.pharmacy_type_cd=mdf.pharmacy_type_cd
       AND mi.med_product_id=0
       AND parser(ident_search_type_parser)
       AND parser(ident_search_str_parser))
    ELSE
     FROM medication_definition md,
      med_def_flex mdf,
      med_identifier mi,
      (
      (
      (SELECT
       pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
       FROM med_def_flex mdf,
        med_flex_object_idx mfoi
       WHERE mdf.item_id=mdf.item_id
        AND mdf.flex_type_cd=4062_sysp_cd
        AND parser(pharmacy_type_parser)
        AND mdf.med_package_type_id != 0
        AND mfoi.med_def_flex_id=mdf.med_def_flex_id
        AND mfoi.flex_object_type_cd=4063_orderable_cd
        AND ((parser(facility_parser)) UNION (
       (SELECT
        pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
        FROM med_def_flex mdf,
         stored_at sa
        WHERE mdf.flex_type_cd=4062_sys_cd
         AND mdf.pharmacy_type_cd=4500_inpt_cd
         AND sa.item_id=mdf.item_id
         AND ((parser(pharmacy_parser)) UNION (
        (SELECT
         pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id
         FROM med_def_flex mdf,
          med_flex_object_idx mfoi,
          med_product mp,
          stored_at sa
         WHERE mdf.flex_type_cd=4062_sys_cd
          AND mdf.pharmacy_type_cd=4500_retl_cd
          AND mfoi.med_def_flex_id=mdf.med_def_flex_id
          AND mfoi.flex_object_type_cd=4063_medprod_cd
          AND mp.med_product_id=mfoi.parent_entity_id
          AND mp.active_ind=1
          AND sa.item_id=mp.manf_item_id
          AND parser(pharmacy_parser)))) )))
       WITH sqltype("f8","f8"), rdbunion, expand = 2))
      locs)
     PLAN (md
      WHERE parser(med_type_parser))
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.flex_type_cd=4062_sys_cd
       AND parser(active_ind_parser)
       AND parser(pharmacy_type_parser)
       AND parser(item_id_parser))
      JOIN (mi
      WHERE mi.item_id=mdf.item_id
       AND mi.pharmacy_type_cd=mdf.pharmacy_type_cd
       AND mi.med_product_id=0
       AND parser(ident_search_type_parser)
       AND parser(ident_search_str_parser))
      JOIN (locs
      WHERE locs.pharmacy_type_cd=mi.pharmacy_type_cd
       AND locs.item_id=mi.item_id)
    ENDIF
    INTO "nl:"
    ORDER BY mdf.pharmacy_type_cd, md.item_id
    HEAD REPORT
     cnt = 0
    HEAD mdf.pharmacy_type_cd
     null
    HEAD md.item_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(reply->qual,(cnt+ 9999))
     ENDIF
     reply->qual[cnt].pharmacy_type_cd = mdf.pharmacy_type_cd, reply->qual[cnt].item_id = md.item_id,
     reply->qual[cnt].med_type_flag = md.med_type_flag,
     reply->qual[cnt].sys_med_def_flex_id = mdf.med_def_flex_id, reply->qual[cnt].active_ind = mdf
     .active_ind, reply->qual[cnt].ref_dose = md.given_strength,
     reply->qual[cnt].form_cd = md.form_cd, reply->qual[cnt].md_updt_id = md.updt_id, reply->qual[cnt
     ].md_updt_dttm = md.updt_dt_tm,
     reply->qual[cnt].mdf_updt_id = mdf.updt_id, reply->qual[cnt].mdf_updt_dttm = mdf.updt_dt_tm
     IF (isnumeric(substring(12,64,md.cki)))
      reply->qual[cnt].cki_numeric = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,cnt)
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_ingredients(null) = null
 SUBROUTINE query_ingredients(null)
  DECLARE idx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    med_ingred_set mis,
    med_identifier mi,
    order_catalog_item_r ocir,
    order_catalog_synonym ocs,
    order_catalog oc
   PLAN (mdf
    WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id)
     AND mdf.flex_type_cd=4062_sys_cd)
    JOIN (mis
    WHERE mis.parent_item_id=mdf.item_id
     AND mis.sequence > 0)
    JOIN (mi
    WHERE mi.item_id=mis.child_item_id
     AND mi.primary_ind=1
     AND mi.med_product_id=0
     AND mi.pharmacy_type_cd=4500_inpt_cd
     AND mi.med_identifier_type_cd=11000_desc_cd)
    JOIN (ocir
    WHERE ocir.item_id=mis.child_item_id)
    JOIN (ocs
    WHERE ocs.synonym_id=ocir.synonym_id)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   ORDER BY mdf.pharmacy_type_cd, mdf.item_id, mis.sequence
   HEAD mdf.pharmacy_type_cd
    null
   HEAD mdf.item_id
    pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
     pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id), cnt = 0
   DETAIL
    IF (pos > 0)
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual[pos].ingred,(cnt+ 9))
     ENDIF
     reply->qual[pos].ingred[cnt].sequence = mis.sequence, reply->qual[pos].ingred[cnt].item_id = mis
     .child_item_id, reply->qual[pos].ingred[cnt].label_desc = mi.value,
     reply->qual[pos].ingred[cnt].normalized_rate_ind = mis.normalized_rate_ind, reply->qual[pos].
     ingred[cnt].catalog_cd = oc.catalog_cd, reply->qual[pos].ingred[cnt].rx_mask = ocs.rx_mask,
     reply->qual[pos].ingred[cnt].cki = oc.cki, reply->qual[pos].ingred[cnt].mis_updt_id = mis
     .updt_id, reply->qual[pos].ingred[cnt].mis_updt_dttm = mis.updt_dt_tm
    ENDIF
   FOOT  mdf.item_id
    stat = alterlist(reply->qual[pos].ingred,cnt)
   FOOT  mdf.pharmacy_type_cd
    null
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 DECLARE query_oe_defaults(null) = null
 SUBROUTINE query_oe_defaults(null)
   DECLARE 4063_oedef_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2553255"))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     price_sched ps,
     order_catalog_synonym ocs,
     long_text lt,
     long_text lt2
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd IN (4062_sys_cd, 4062_sysp_cd))
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_oedef_cd)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
     JOIN (ps
     WHERE (ps.price_sched_id= Outerjoin(mod.price_sched_id)) )
     JOIN (ocs
     WHERE (ocs.synonym_id= Outerjoin(mod.ord_as_synonym_id)) )
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(mod.comment1_id)) )
     JOIN (lt2
     WHERE (lt2.long_text_id= Outerjoin(mod.comment2_id)) )
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id, mdf.sequence
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
     IF (pos > 0
      AND mdf.sequence=0)
      reply->qual[pos].mod_med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos].daw_cd =
      mod.daw_cd, reply->qual[pos].rx_qty = mod.rx_qty,
      reply->qual[pos].oe_str = mod.strength, reply->qual[pos].oe_str_unit_cd = mod.strength_unit_cd,
      reply->qual[pos].oe_vol = mod.volume,
      reply->qual[pos].oe_vol_unit_cd = mod.volume_unit_cd, reply->qual[pos].freetext_dose = mod
      .freetext_dose, reply->qual[pos].route_cd = mod.route_cd,
      reply->qual[pos].frequency_cd = mod.frequency_cd, reply->qual[pos].infuse_over = mod
      .infuse_over, reply->qual[pos].infuse_over_unit_cd = mod.infuse_over_cd,
      reply->qual[pos].rate = mod.rate_nbr, reply->qual[pos].rate_unit_cd = mod.rate_unit_cd, reply->
      qual[pos].normalized_rate = mod.normalized_rate_nbr,
      reply->qual[pos].normalized_rate_unit_cd = mod.normalized_rate_unit_cd, reply->qual[pos].
      freetext_rate = mod.freetext_rate_txt, reply->qual[pos].duration = mod.duration,
      reply->qual[pos].duration_unit_cd = mod.duration_unit_cd, reply->qual[pos].stop_type_cd = mod
      .stop_type_cd, reply->qual[pos].prn = mod.prn_ind,
      reply->qual[pos].prn_reason_cd = mod.prn_reason_cd, reply->qual[pos].order_as_synonym_id = ocs
      .synonym_id, reply->qual[pos].order_as_synonym = ocs.mnemonic,
      reply->qual[pos].sig = mod.sig_codes, reply->qual[pos].notes1_id = mod.comment1_id, reply->
      qual[pos].notes1 = lt.long_text,
      reply->qual[pos].notes1_comment_type = mod.comment1_type, reply->qual[pos].notes2_id = mod
      .comment2_id, reply->qual[pos].notes2 = lt2.long_text,
      reply->qual[pos].notes2_comment_type = mod.comment2_type, reply->qual[pos].disp_category_cd =
      mod.dispense_category_cd, reply->qual[pos].price_schedule_id = ps.price_sched_id,
      reply->qual[pos].price_schedule = ps.price_sched_desc, reply->qual[pos].default_par_doses = mod
      .default_par_doses, reply->qual[pos].max_par_supply = mod.max_par_supply,
      reply->qual[pos].mod_updt_id = mod.updt_id, reply->qual[pos].mod_updt_dttm = mod.updt_dt_tm
     ENDIF
     pos2 = 0
    HEAD mdf.sequence
     IF (pos > 0
      AND mdf.sequence > 0)
      pos2 = locatevalsort(idx2,1,size(reply->qual[pos].ingred,5),mdf.sequence,reply->qual[pos].
       ingred[idx2].sequence)
      IF (pos2 > 0)
       reply->qual[pos].ingred[pos2].mfoi_med_flex_object_id = mfoi.med_flex_object_id, reply->qual[
       pos].ingred[pos2].str = mod.strength, reply->qual[pos].ingred[pos2].str_unit_cd = mod
       .strength_unit_cd,
       reply->qual[pos].ingred[pos2].vol = mod.volume, reply->qual[pos].ingred[pos2].vol_unit_cd =
       mod.volume_unit_cd, reply->qual[pos].ingred[pos2].freetext_dose = mod.freetext_dose,
       reply->qual[pos].ingred[pos2].mod_updt_id = mod.updt_id, reply->qual[pos].ingred[pos2].
       mod_updt_dttm = mod.updt_dt_tm
      ENDIF
     ENDIF
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_dispense(null) = null
 SUBROUTINE query_dispense(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cms_fld_exists = i4 WITH protect, noconstant(0)
   DECLARE cms_fld_parser = vc WITH protect, noconstant(" ")
   DECLARE waste_fld_parser = vc WITH protect, noconstant(" ")
   SET cms_fld_exists = checkdic("MED_DISPENSE.CMS_WASTE_BILLING_UNIT_AMT","A",0)
   IF (cms_fld_exists != 0)
    SET cms_fld_parser = build("mdisp.cms_waste_billing_unit_amt")
    SET waste_fld_parser = build("mdisp.waste_charge_ind")
   ELSE
    SET cms_fld_parser = build("0")
    SET waste_fld_parser = build("0")
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense mdisp,
     med_package_type mpt
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sysp_cd
      AND mdf.sequence=0)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_disp_cd)
     JOIN (mdisp
     WHERE mdisp.med_dispense_id=mfoi.parent_entity_id
      AND mdisp.pharmacy_type_cd=mdf.pharmacy_type_cd)
     JOIN (mpt
     WHERE (mpt.med_package_type_id= Outerjoin(mdf.med_package_type_id)) )
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
     IF (pos > 0)
      reply->qual[pos].sysp_med_def_flex_id = mdf.med_def_flex_id, reply->qual[pos].
      mdisp_med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos].legal_status_cd = mdisp
      .legal_status_cd,
      reply->qual[pos].def_format = mdisp.oe_format_flag, reply->qual[pos].medication = mdisp
      .med_filter_ind, reply->qual[pos].continuous = mdisp.continuous_filter_ind,
      reply->qual[pos].tpn = mdisp.tpn_filter_ind, reply->qual[pos].intermittent = mdisp
      .intermittent_filter_ind, reply->qual[pos].str = mdisp.strength,
      reply->qual[pos].str_unit_cd = mdisp.strength_unit_cd, reply->qual[pos].vol = mdisp.volume,
      reply->qual[pos].vol_unit_cd = mdisp.volume_unit_cd,
      reply->qual[pos].disp_qty = mpt.qty, reply->qual[pos].disp_qty_unit_cd = mpt.uom_cd, reply->
      qual[pos].disp_factor = mdisp.dispense_factor,
      reply->qual[pos].used_in_tot_volume = mdisp.used_as_base_ind, reply->qual[pos].
      workflow_sequence_cd = mdisp.workflow_cd, reply->qual[pos].divisible = mdisp.divisible_ind,
      reply->qual[pos].divisible_factor = mdisp.base_issue_factor, reply->qual[pos].
      infinite_divisible = mdisp.infinite_div_ind, reply->qual[pos].label_ratio = mdisp.label_ratio,
      reply->qual[pos].per_pkg = mdisp.pkg_qty_per_pkg, reply->qual[pos].allow_pkg_broken = mdisp
      .pkg_disp_more_ind, reply->qual[pos].formulary_status_cd = mdisp.formulary_status_cd,
      reply->qual[pos].billing_factor = mdisp.billing_factor_nbr, reply->qual[pos].
      billing_factor_unit_cd = mdisp.billing_uom_cd, reply->qual[pos].poc_charge_setting = mdisp
      .poc_charge_flag,
      reply->qual[pos].dispense_from = mdisp.always_dispense_from_flag, reply->qual[pos].reusable =
      mdisp.reusable_ind, reply->qual[pos].track_lot_numbers = mdisp.lot_tracking_ind,
      reply->qual[pos].disable_apa_aps = mdisp.prod_assign_flag, reply->qual[pos].skip_dispense =
      mdisp.skip_dispense_flag, reply->qual[pos].waste_charging = parser(waste_fld_parser),
      reply->qual[pos].cms_billing_unit = parser(cms_fld_parser), reply->qual[pos].mdisp_updt_id =
      mdisp.updt_id, reply->qual[pos].mdisp_updt_dttm = mdisp.updt_dt_tm
     ENDIF
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_facilities(null) = null
 SUBROUTINE query_facilities(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE sort_parser = vc WITH protect, noconstant("mfoi.parent_entity_id")
   DECLARE limit_parser = vc WITH protect, noconstant("1 = 1")
   IF (request->facility_limit)
    SET limit_parser = concat("(expand(idx2, 1, size(request->facility, 5)",", mfoi.parent_entity_id",
     ", request->facility[idx2].code_value)"," or mfoi.parent_entity_id = 0)")
   ENDIF
   IF (request->facility_sort)
    SET sort_parser = "cnvtupper(uar_get_code_display(mfoi.parent_entity_id))"
   ENDIF
   SELECT INTO "nl:"
    facility = parser(sort_parser)
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sysp_cd
      AND mdf.med_package_type_id != 0)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_orderable_cd
      AND parser(limit_parser))
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id, facility
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
     IF (pos > 0)
      reply->qual[pos].sysp_med_def_flex_id = mdf.med_def_flex_id
     ENDIF
     cnt = 0
    HEAD facility
     IF (pos > 0)
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(reply->qual[pos].fac,(cnt+ 99))
      ENDIF
      reply->qual[pos].fac[cnt].med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos].fac[
      cnt].facility_cd = mfoi.parent_entity_id, reply->qual[pos].fac[cnt].updt_id = mfoi.updt_id,
      reply->qual[pos].fac[cnt].updt_dttm = mfoi.updt_dt_tm
      IF (mfoi.parent_entity_id=0
       AND mfoi.med_flex_object_id > 0)
       reply->qual[pos].all_facil_ind = 1
      ENDIF
     ENDIF
    FOOT  facility
     null
    FOOT  mdf.item_id
     stat = alterlist(reply->qual[pos].fac,cnt)
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_pharmacies(null) = null
 SUBROUTINE query_pharmacies(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE sort_parser = vc WITH protect, noconstant("pha.location_cd")
   DECLARE limit_parser = vc WITH protect, noconstant("1 = 1")
   IF (request->pharmacy_limit)
    SET limit_parser = concat("expand(idx2, 1, size(request->pharmacy, 5)",", sa.location_cd",
     ", request->pharmacy[idx2].code_value)")
   ENDIF
   IF (request->pharmacy_sort)
    SET sort_parser = "cnvtupper(uar_get_code_display(sa.location_cd))"
   ENDIF
   SELECT INTO "nl:"
    pharmacy = parser(sort_parser)
    FROM med_def_flex mdf,
     (
     (
     (SELECT
      pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id, location_cd = sa.location_cd,
      updt_id = sa.updt_id, updt_dttm = sa.updt_dt_tm
      FROM med_def_flex mdf,
       stored_at sa
      WHERE mdf.flex_type_cd=4062_sys_cd
       AND mdf.pharmacy_type_cd=4500_inpt_cd
       AND sa.item_id=mdf.item_id
       AND ((parser(limit_parser)) UNION (
      (SELECT
       pharmacy_type_cd = mdf.pharmacy_type_cd, item_id = mdf.item_id, location_cd = sa.location_cd,
       updt_id = sa.updt_id, updt_dttm = sa.updt_dt_tm
       FROM med_def_flex mdf,
        med_flex_object_idx mfoi,
        med_product mp,
        stored_at sa
       WHERE mdf.flex_type_cd=4062_sys_cd
        AND mdf.pharmacy_type_cd=4500_retl_cd
        AND mfoi.med_def_flex_id=mdf.med_def_flex_id
        AND mfoi.flex_object_type_cd=4063_medprod_cd
        AND mp.med_product_id=mfoi.parent_entity_id
        AND mp.active_ind=1
        AND sa.item_id=mp.manf_item_id
        AND parser(limit_parser))))
      WITH sqltype("f8","f8","f8","f8","dq8"), rdbunion))
     pha)
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (pha
     WHERE pha.pharmacy_type_cd=mdf.pharmacy_type_cd
      AND pha.item_id=mdf.item_id)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id, pharmacy
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id), cnt = 0
    HEAD pharmacy
     IF (pos > 0)
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(reply->qual[pos].pha,(cnt+ 99))
      ENDIF
      reply->qual[pos].pha[cnt].pharmacy_cd = pha.location_cd, reply->qual[pos].pha[cnt].updt_id =
      pha.updt_id, reply->qual[pos].pha[cnt].updt_dttm = pha.updt_dttm
     ENDIF
    FOOT  pharmacy
     null
    FOOT  mdf.item_id
     stat = alterlist(reply->qual[pos].pha,cnt)
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_medproducts(null) = null
 SUBROUTINE query_medproducts(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE costfactor_fld_exists = i4 WITH protect, noconstant(0)
   DECLARE costfactor_fld_parser = vc WITH protect, noconstant(" ")
   DECLARE active_ind_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE primary_ind_parser = vc WITH protect, noconstant("1 = 1")
   SET costfactor_fld_exists = checkdic("MED_PRODUCT.COST_FACTOR_NBR","A",0)
   IF (costfactor_fld_exists != 0)
    SET costfactor_fld_parser = build("mp.cost_factor_nbr")
   ELSE
    SET costfactor_fld_parser = build("0")
   ENDIF
   IF ((request->ndc_active_ind=0))
    SET active_ind_parser = "mfoi.active_ind = 0"
   ELSEIF ((request->item_active_ind=1))
    SET active_ind_parser = "mfoi.active_ind = 1"
   ENDIF
   IF ((request->ndc_primary_ind=0))
    SET primary_ind_parser = "mfoi.sequence != 1"
   ELSEIF ((request->ndc_primary_ind=1))
    SET primary_ind_parser = "mfoi.sequence = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_product mp,
     manufacturer_item mfi,
     package_type ptb,
     package_type pti,
     package_type pto,
     med_cost_hx mch,
     rx_med_prod_desc rmpd
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_medprod_cd
      AND parser(active_ind_parser)
      AND parser(primary_ind_parser))
     JOIN (mp
     WHERE mp.med_product_id=mfoi.parent_entity_id)
     JOIN (mfi
     WHERE mfi.item_id=mp.manf_item_id)
     JOIN (ptb
     WHERE ptb.item_id=mfi.item_id
      AND ptb.base_package_type_ind=1)
     JOIN (pti
     WHERE pti.package_type_id=mp.inner_pkg_type_id)
     JOIN (pto
     WHERE pto.package_type_id=mp.outer_pkg_type_id)
     JOIN (rmpd
     WHERE (rmpd.med_product_id= Outerjoin(mp.med_product_id)) )
     JOIN (mch
     WHERE (mch.med_product_id= Outerjoin(mp.med_product_id))
      AND (mch.active_ind= Outerjoin(1))
      AND (mch.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (mch.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id, mp.med_product_id,
     rmpd.med_prod_desc_id, mch.cost_type_cd
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id), cnt = 0
    HEAD mp.med_product_id
     IF (pos > 0)
      cnt += 1
      IF (mod(cnt,20)=1)
       stat = alterlist(reply->qual[pos].ndc,(cnt+ 19))
      ENDIF
      reply->qual[pos].ndc[cnt].med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos].ndc[
      cnt].med_product_id = mp.med_product_id, reply->qual[pos].ndc[cnt].manf_item_id = mp
      .manf_item_id,
      reply->qual[pos].ndc[cnt].active_ind = mfoi.active_ind, reply->qual[pos].ndc[cnt].sequence =
      mfoi.sequence, reply->qual[pos].ndc[cnt].manufacturer_cd = mfi.manufacturer_cd,
      reply->qual[pos].ndc[cnt].formulary_status_cd = mp.formulary_status_cd, reply->qual[pos].ndc[
      cnt].base_pkg_unit_cd = ptb.uom_cd, reply->qual[pos].ndc[cnt].pkg_size = pti.qty,
      reply->qual[pos].ndc[cnt].pkg_unit_cd = pti.uom_cd, reply->qual[pos].ndc[cnt].outer_pkg_size =
      pto.qty, reply->qual[pos].ndc[cnt].outer_pkg_unit_cd = pto.uom_cd,
      reply->qual[pos].ndc[cnt].unit_dose_ind = mp.unit_dose_ind, reply->qual[pos].ndc[cnt].bio_ind
       = mp.bio_equiv_ind, reply->qual[pos].ndc[cnt].brand_ind = mp.brand_ind,
      reply->qual[pos].ndc[cnt].cost_factor = parser(costfactor_fld_parser), reply->qual[pos].ndc[cnt
      ].inv_factor = mp.inv_factor_nbr, reply->qual[pos].ndc[cnt].mfoi_updt_id = mfoi.updt_id,
      reply->qual[pos].ndc[cnt].mfoi_updt_dttm = mfoi.updt_dt_tm, reply->qual[pos].ndc[cnt].
      mp_updt_id = mp.updt_id, reply->qual[pos].ndc[cnt].mp_updt_dttm = mp.updt_dt_tm,
      reply->qual[pos].ndc[cnt].ptb_updt_id = ptb.updt_id, reply->qual[pos].ndc[cnt].ptb_updt_dttm =
      ptb.updt_dt_tm, reply->qual[pos].ndc[cnt].pti_updt_id = pti.updt_id,
      reply->qual[pos].ndc[cnt].pti_updt_dttm = pti.updt_dt_tm, reply->qual[pos].ndc[cnt].pto_updt_id
       = pto.updt_id, reply->qual[pos].ndc[cnt].pto_updt_dttm = pto.updt_dt_tm
     ENDIF
     desc_cnt = 0, cost_cnt = 0
    HEAD rmpd.med_prod_desc_id
     IF (pos > 0
      AND rmpd.med_prod_desc_id > 0)
      desc_cnt += 1
      IF (mod(desc_cnt,10)=1)
       stat = alterlist(reply->qual[pos].ndc[cnt].prod_desc,(desc_cnt+ 9))
      ENDIF
      reply->qual[pos].ndc[cnt].prod_desc[desc_cnt].type_cd = rmpd.field_type_cd, reply->qual[pos].
      ndc[cnt].prod_desc[desc_cnt].value = rmpd.field_value_str_txt, reply->qual[pos].ndc[cnt].
      prod_desc[desc_cnt].updt_id = rmpd.updt_id,
      reply->qual[pos].ndc[cnt].prod_desc[desc_cnt].updt_dttm = rmpd.updt_dt_tm
     ENDIF
    HEAD mch.cost_type_cd
     IF (pos > 0
      AND mch.cost_type_cd > 0)
      pos2 = locateval(idx2,1,size(reply->qual[pos].ndc[cnt].cost,5),mch.cost_type_cd,reply->qual[pos
       ].ndc[cnt].cost[idx2].type_cd)
      IF (pos2=0)
       cost_cnt += 1
       IF (mod(cost_cnt,10)=1)
        stat = alterlist(reply->qual[pos].ndc[cnt].cost,(cost_cnt+ 9))
       ENDIF
       reply->qual[pos].ndc[cnt].cost[cost_cnt].type_cd = mch.cost_type_cd, reply->qual[pos].ndc[cnt]
       .cost[cost_cnt].value = mch.cost, reply->qual[pos].ndc[cnt].cost[cost_cnt].updt_id = mch
       .updt_id,
       reply->qual[pos].ndc[cnt].cost[cost_cnt].updt_dttm = mch.updt_dt_tm
      ENDIF
     ENDIF
    FOOT  mch.cost_type_cd
     null
    FOOT  rmpd.med_prod_desc_id
     null
    FOOT  mp.med_product_id
     IF (pos > 0)
      stat = alterlist(reply->qual[pos].ndc[cnt].prod_desc,desc_cnt), stat = alterlist(reply->qual[
       pos].ndc[cnt].cost,cost_cnt)
     ENDIF
    FOOT  mdf.item_id
     stat = alterlist(reply->qual[pos].ndc,cnt)
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_order_catalog(null) = null
 SUBROUTINE query_order_catalog(null)
  DECLARE idx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    medication_definition md,
    order_catalog_item_r ocir,
    order_catalog oc,
    order_catalog_synonym ocs,
    nomenclature ng,
    nomenclature nd
   PLAN (mdf
    WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id)
     AND mdf.flex_type_cd=4062_sys_cd)
    JOIN (md
    WHERE md.item_id=mdf.item_id)
    JOIN (ocir
    WHERE ocir.item_id=mdf.item_id)
    JOIN (ocs
    WHERE ocs.synonym_id=ocir.synonym_id)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (ng
    WHERE (ng.source_identifier= Outerjoin(substring(9,20,oc.cki)))
     AND (ng.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ng.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (ng.primary_vterm_ind= Outerjoin(1)) )
    JOIN (nd
    WHERE (nd.nomenclature_id= Outerjoin(md.mdx_gfc_nomen_id)) )
   ORDER BY mdf.pharmacy_type_cd, mdf.item_id
   HEAD mdf.pharmacy_type_cd
    null
   HEAD mdf.item_id
    pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
     pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id)
    IF (pos > 0)
     IF (oc.cki="IGNORE")
      reply->qual[pos].suppress_multum_ind = 1
     ENDIF
     reply->qual[pos].generic_formulation_code = oc.cki
     IF (substring(1,7,oc.cki)="MUL.ORD")
      reply->qual[pos].generic_formulation = ng.source_string
     ELSEIF (substring(1,8,oc.cki)="MUL.MMDC")
      reply->qual[pos].generic_formulation = nd.source_string
     ENDIF
     reply->qual[pos].drug_formulation = nd.source_string, reply->qual[pos].drug_formulation_code =
     concat("MUL.FRMLTN!",nd.source_identifier), reply->qual[pos].dc_inter_days = oc
     .dc_interaction_days,
     reply->qual[pos].dc_display_days = oc.dc_display_days, reply->qual[pos].catalog_cd = oc
     .catalog_cd, reply->qual[pos].primary_mnemonic = oc.primary_mnemonic,
     reply->qual[pos].oc_desc = oc.description, reply->qual[pos].oc_cki = oc.cki, reply->qual[pos].
     titrate_ind = ocs.ingredient_rate_conversion_ind,
     reply->qual[pos].witness_flag = ocs.witness_flag
    ENDIF
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 DECLARE query_thera_class(null) = null
 SUBROUTINE query_thera_class(null)
  DECLARE idx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    order_catalog_item_r ocir,
    alt_sel_list al,
    alt_sel_cat ac
   PLAN (mdf
    WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id)
     AND mdf.flex_type_cd=4062_sys_cd)
    JOIN (ocir
    WHERE ocir.item_id=mdf.item_id)
    JOIN (al
    WHERE al.synonym_id=ocir.synonym_id
     AND al.list_type=2)
    JOIN (ac
    WHERE ac.alt_sel_category_id=al.alt_sel_category_id
     AND ac.ahfs_ind=1)
   ORDER BY mdf.pharmacy_type_cd, mdf.item_id
   HEAD mdf.pharmacy_type_cd
    null
   HEAD mdf.item_id
    pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
     pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id)
    IF (pos > 0)
     reply->qual[pos].therapeutic_class = ac.short_description, reply->qual[pos].
     therapeutic_class_display = ac.long_description
    ENDIF
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 DECLARE query_immunization(null) = null
 SUBROUTINE query_immunization(null)
   DECLARE immunization_fld = vc WITH protect, constant("IMMUNIZATIONIND")
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     order_catalog_item_r ocir,
     code_value_extension cve
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (ocir
     WHERE ocir.item_id=mdf.item_id)
     JOIN (cve
     WHERE cve.code_value=ocir.catalog_cd
      AND cve.field_name=immunization_fld)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
     IF (pos > 0)
      reply->qual[pos].immunization_ind = cnvtint(cve.field_value)
     ENDIF
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_drc(null) = null
 SUBROUTINE query_drc(null)
   DECLARE mltm_product_generic = f8 WITH protect, constant(59.00)
   DECLARE mltm_product_brand = f8 WITH protect, constant(60.00)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     medication_definition md,
     mltm_mmdc_name_map mmnm,
     drc_group_reltn dgr,
     drc_form_reltn dfr,
     dose_range_check drc
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id,1,reply->qual[idx].cki_numeric)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (md
     WHERE md.item_id=mdf.item_id)
     JOIN (mmnm
     WHERE mmnm.main_multum_drug_code=cnvtreal(substring(12,64,md.cki))
      AND ((mmnm.function_id=mltm_product_generic) OR (mmnm.function_id=mltm_product_brand)) )
     JOIN (dgr
     WHERE dgr.drug_synonym_id=mmnm.drug_synonym_id)
     JOIN (dfr
     WHERE dfr.drc_group_id=dgr.drc_group_id)
     JOIN (drc
     WHERE drc.dose_range_check_id=dfr.dose_range_check_id)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id,1,reply->qual[idx].cki_numeric)
     IF (pos > 0)
      reply->qual[idx].drc_grouper = drc.dose_range_check_name
     ENDIF
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_identifiers(null) = null
 SUBROUTINE query_identifiers(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE ident_type_parser = vc WITH protect, noconstant("1 = 1")
   IF (size(request->ident_type,5) > 0)
    SET ident_type_parser = concat("expand(idx3, 1, size(request->ident_type, 5)",
     ", mi.med_identifier_type_cd",", request->ident_type[idx3].code_value)")
   ENDIF
   SELECT INTO "nl:"
    FROM med_identifier mi
    PLAN (mi
     WHERE expand(idx,1,size(reply->qual,5),mi.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mi.item_id,reply->qual[idx].item_id)
      AND parser(ident_type_parser))
    ORDER BY mi.pharmacy_type_cd, mi.item_id, mi.med_product_id,
     mi.med_identifier_id
    HEAD mi.pharmacy_type_cd
     null
    HEAD mi.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mi.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mi.item_id,reply->qual[idx].item_id), cnt = 0
    HEAD mi.med_product_id
     IF (pos > 0)
      pos2 = locatevalsort(idx2,1,size(reply->qual[pos].ndc,5),mi.med_product_id,reply->qual[pos].
       ndc[idx2].med_product_id), ndc_cnt = 0
     ENDIF
    HEAD mi.med_identifier_id
     IF (pos > 0
      AND mi.med_product_id=0)
      cnt += 1
      IF (mod(cnt,20)=1)
       stat = alterlist(reply->qual[pos].ident,(cnt+ 19))
      ENDIF
      reply->qual[pos].ident[cnt].ident_type_cd = mi.med_identifier_type_cd, reply->qual[pos].ident[
      cnt].value = mi.value, reply->qual[pos].ident[cnt].active_ind = mi.active_ind,
      reply->qual[pos].ident[cnt].primary_ind = mi.primary_ind, reply->qual[pos].ident[cnt].updt_id
       = mi.updt_id, reply->qual[pos].ident[cnt].updt_dttm = mi.updt_dt_tm
      IF (mi.primary_ind=1
       AND mi.med_identifier_type_cd=11000_desc_cd)
       reply->qual[pos].label_desc = mi.value
      ENDIF
     ELSEIF (pos > 0
      AND pos2 > 0)
      ndc_cnt += 1
      IF (mod(ndc_cnt,20)=1)
       stat = alterlist(reply->qual[pos].ndc[pos2].ident,(ndc_cnt+ 19))
      ENDIF
      reply->qual[pos].ndc[pos2].ident[ndc_cnt].ident_type_cd = mi.med_identifier_type_cd, reply->
      qual[pos].ndc[pos2].ident[ndc_cnt].value = mi.value, reply->qual[pos].ndc[pos2].ident[ndc_cnt].
      active_ind = mi.active_ind,
      reply->qual[pos].ndc[pos2].ident[ndc_cnt].primary_ind = mi.primary_ind, reply->qual[pos].ndc[
      pos2].ident[ndc_cnt].updt_id = mi.updt_id, reply->qual[pos].ndc[pos2].ident[ndc_cnt].updt_dttm
       = mi.updt_dt_tm
      IF (mi.primary_ind=1
       AND mi.med_identifier_type_cd=11000_ndc_cd)
       reply->qual[pos].ndc[pos2].ndc_code = mi.value
      ENDIF
     ENDIF
    FOOT  mi.med_identifier_id
     null
    FOOT  mi.med_product_id
     IF (pos > 0)
      stat = alterlist(reply->qual[pos].ident,cnt)
     ENDIF
     IF (pos > 0
      AND pos2 > 0)
      stat = alterlist(reply->qual[pos].ndc[pos2].ident,ndc_cnt)
     ENDIF
    FOOT  mi.item_id
     null
    FOOT  mi.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_order_alerts(null) = null
 SUBROUTINE query_order_alerts(null)
   DECLARE 4063_ordalert_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2553257"))
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_ordalert_cd)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id), cnt = 0
    DETAIL
     IF (pos > 0)
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual[pos].ord_alerts,(cnt+ 9))
      ENDIF
      reply->qual[pos].ord_alerts[cnt].med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos]
      .ord_alerts[cnt].order_alert_cd = mfoi.parent_entity_id, reply->qual[pos].ord_alerts[cnt].
      updt_id = mfoi.updt_id,
      reply->qual[pos].ord_alerts[cnt].updt_dttm = mfoi.updt_dt_tm
     ENDIF
    FOOT  mdf.item_id
     stat = alterlist(reply->qual[pos].ord_alerts,cnt)
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 SUBROUTINE (query_flex_by_facil(null=vc) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE waste_fld_exists = i4 WITH protect, noconstant(0)
   DECLARE waste_fld_parser = vc WITH protect, noconstant(" ")
   DECLARE limit_parser = vc WITH protect, noconstant("1 = 1")
   IF (request->facil_flex_limit)
    SET limit_parser = concat("expand(idx2, 1, size(request->facility, 5)",", mdf.parent_entity_id",
     ", request->facility[idx2].code_value)")
   ENDIF
   SET waste_fld_exists = checkdic("MDISP.WASTE_CHARGE_IND","A",0)
   IF (waste_fld_exists != 0)
    SET waste_fld_parser = build("mdisp.waste_charge_ind")
   ELSE
    SET waste_fld_parser = build("0")
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense mdisp
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND parser(limit_parser)
      AND mdf.flex_type_cd=4062_facil_cd
      AND mdf.med_package_type_id=0)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_disp_cd)
     JOIN (mdisp
     WHERE mdisp.med_dispense_id=mfoi.parent_entity_id
      AND mdisp.pharmacy_type_cd=mdf.pharmacy_type_cd)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id), cnt = 0
    DETAIL
     IF (pos > 0)
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(reply->qual[pos].fac_flex,(cnt+ 99))
      ENDIF
      reply->qual[pos].fac_flex[cnt].med_def_flex_id = mdf.med_def_flex_id, reply->qual[pos].
      fac_flex[cnt].med_flex_object_id = mfoi.med_flex_object_id, reply->qual[pos].fac_flex[cnt].
      facility_cd = mdf.parent_entity_id,
      reply->qual[pos].fac_flex[cnt].formulary_status_cd = mdisp.formulary_status_cd, reply->qual[pos
      ].fac_flex[cnt].track_lot_numbers = mdisp.lot_tracking_ind, reply->qual[pos].fac_flex[cnt].
      disable_apa_aps = mdisp.prod_assign_flag,
      reply->qual[pos].fac_flex[cnt].skip_dispense = mdisp.skip_dispense_flag, reply->qual[pos].
      fac_flex[cnt].waste_charging = parser(waste_fld_parser), reply->qual[pos].fac_flex[cnt].updt_id
       = mdisp.updt_id,
      reply->qual[pos].fac_flex[cnt].updt_dttm = mdisp.updt_dt_tm
     ENDIF
    FOOT  mdf.item_id
     stat = alterlist(reply->qual[pos].fac_flex,cnt)
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_flex_by_ndc(null) = null
 SUBROUTINE query_flex_by_ndc(null)
   DECLARE 4062_pharm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2548619"))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE facility_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE pharmacy_parser = vc WITH protect, noconstant("1 = 1")
   IF (size(request->facility,5) > 0)
    SET facility_parser = concat("expand(idx2, 1, size(request->facility, 5)",
     ", mdf.parent_entity_id",", request->facility[idx2].code_value)")
   ENDIF
   IF (size(request->pharmacy,5) > 0)
    SET pharmacy_parser = concat("expand(idx3, 1, size(request->pharmacy, 5)",
     ", mdf.parent_entity_id",", request->pharmacy[idx3].code_value)")
   ENDIF
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_product mp
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND ((parser(facility_parser)) OR (parser(pharmacy_parser)))
      AND mdf.flex_type_cd IN (4062_pharm_cd, 4062_facil_cd))
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=4063_medprod_cd)
     JOIN (mp
     WHERE mp.med_product_id=mfoi.parent_entity_id
      AND mp.active_ind=1)
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id, mp.med_product_id,
     mdf.parent_entity_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
    HEAD mp.med_product_id
     IF (pos > 0)
      pos2 = locatevalsort(idx2,1,size(reply->qual[pos].ndc,5),mp.med_product_id,reply->qual[pos].
       ndc[idx2].med_product_id)
     ENDIF
     cnt = 0
    HEAD mdf.parent_entity_id
     IF (pos > 0
      AND pos2 > 0)
      cnt += 1
      IF (mod(cnt,50)=1)
       stat = alterlist(reply->qual[pos].ndc[pos2].flex,(cnt+ 49))
      ENDIF
      reply->qual[pos].ndc[pos2].flex[cnt].type_cd = mdf.flex_type_cd, reply->qual[pos].ndc[pos2].
      flex[cnt].location_cd = mdf.parent_entity_id, reply->qual[pos].ndc[pos2].flex[cnt].
      med_def_flex_id = mdf.med_def_flex_id,
      reply->qual[pos].ndc[pos2].flex[cnt].med_flex_object_id = mfoi.med_flex_object_id, reply->qual[
      pos].ndc[pos2].flex[cnt].primary_ind =
      IF (mfoi.sequence=1) 1
      ELSE 0
      ENDIF
      , reply->qual[pos].ndc[pos2].flex[cnt].active_ind = mfoi.active_ind,
      reply->qual[pos].ndc[pos2].flex[cnt].updt_id = mfoi.updt_id, reply->qual[pos].ndc[pos2].flex[
      cnt].updt_dttm = mfoi.updt_dt_tm
     ENDIF
    FOOT  mdf.parent_entity_id
     null
    FOOT  mp.med_product_id
     IF (pos > 0
      AND pos2 > 0)
      stat = alterlist(reply->qual[pos].ndc[pos2].flex,cnt)
     ENDIF
    FOOT  mdf.item_id
     null
    FOOT  mdf.pharmacy_type_cd
     null
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 DECLARE query_linking(null) = null
 SUBROUTINE query_linking(null)
  DECLARE idx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM med_def_flex mdf,
    synonym_item_r sir,
    order_catalog_synonym ocs
   PLAN (mdf
    WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id))
    JOIN (sir
    WHERE sir.item_id=mdf.item_id)
    JOIN (ocs
    WHERE ocs.synonym_id=sir.synonym_id)
   ORDER BY mdf.pharmacy_type_cd, mdf.item_id, ocs.synonym_id
   HEAD mdf.pharmacy_type_cd
    null
   HEAD mdf.item_id
    pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
     pharmacy_type_cd,
     mdf.item_id,reply->qual[idx].item_id), cnt = 0
   HEAD ocs.synonym_id
    IF (pos > 0)
     cnt += 1
     IF (mod(cnt,50)=1)
      stat = alterlist(reply->qual[pos].linking,(cnt+ 49))
     ENDIF
     reply->qual[pos].linking[cnt].synonym_id = ocs.synonym_id, reply->qual[pos].linking[cnt].synonym
      = ocs.mnemonic, reply->qual[pos].linking[cnt].synonym_type_cd = ocs.mnemonic_type_cd,
     reply->qual[pos].linking[cnt].active_ind = ocs.active_ind, reply->qual[pos].linking[cnt].
     updt_dttm = sir.updt_dt_tm, reply->qual[pos].linking[cnt].updt_id = sir.updt_id
    ENDIF
   FOOT  ocs.synonym_id
    null
   FOOT  mdf.item_id
    stat = alterlist(reply->qual[pos].linking,cnt)
   FOOT  mdf.pharmacy_type_cd
    null
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 DECLARE query_misc_details(null) = null
 SUBROUTINE query_misc_details(null)
   DECLARE 11000_item_nbr_sys_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3743"
     ))
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     item_definition id,
     package_type pt,
     identifier i,
     prsnl p
    PLAN (mdf
     WHERE expand(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
      AND mdf.flex_type_cd=4062_sys_cd)
     JOIN (id
     WHERE id.item_id=mdf.item_id)
     JOIN (pt
     WHERE (pt.item_id= Outerjoin(mdf.item_id))
      AND (pt.active_ind= Outerjoin(1))
      AND (pt.base_package_type_ind= Outerjoin(1)) )
     JOIN (i
     WHERE (i.parent_entity_id= Outerjoin(mdf.item_id))
      AND (i.parent_entity_name= Outerjoin("ITEM_DEFINITION"))
      AND (i.identifier_type_cd= Outerjoin(11000_item_nbr_sys_cd)) )
     JOIN (p
     WHERE (p.person_id= Outerjoin(id.create_id)) )
    ORDER BY mdf.pharmacy_type_cd, mdf.item_id
    HEAD mdf.pharmacy_type_cd
     null
    HEAD mdf.item_id
     pos = locatevalsort(idx,1,size(reply->qual,5),mdf.pharmacy_type_cd,reply->qual[idx].
      pharmacy_type_cd,
      mdf.item_id,reply->qual[idx].item_id)
     IF (pos > 0)
      reply->qual[pos].inv_base_pkg_unit_cd = pt.uom_cd, reply->qual[pos].system_number = i.value,
      reply->qual[pos].creation_user = p.name_full_formatted,
      reply->qual[pos].creation_dt_tm = id.create_dt_tm
     ENDIF
    WITH nocounter, expand = 2
   ;end select
 END ;Subroutine
 IF (query_item_ids(0))
  IF (request->qry_ingredients)
   CALL query_ingredients(0)
  ENDIF
  IF (request->qry_oe_defaults)
   CALL query_oe_defaults(0)
  ENDIF
  IF (request->qry_dispense)
   CALL query_dispense(0)
  ENDIF
  IF (request->qry_facilities)
   CALL query_facilities(0)
  ENDIF
  IF (request->qry_pharmacies)
   CALL query_pharmacies(0)
  ENDIF
  IF (request->qry_medproducts)
   CALL query_medproducts(0)
  ENDIF
  IF (request->qry_order_catalog)
   CALL query_order_catalog(0)
  ENDIF
  IF (request->qry_thera_class)
   CALL query_thera_class(0)
  ENDIF
  IF (request->qry_immunization)
   CALL query_immunization(0)
  ENDIF
  IF (request->qry_drc)
   CALL query_drc(0)
  ENDIF
  IF ((request->qry_identifiers=1))
   CALL query_identifiers(0)
  ENDIF
  IF (request->qry_order_alerts)
   CALL query_order_alerts(0)
  ENDIF
  IF (request->qry_flex_by_facil)
   CALL query_flex_by_facil(0)
  ENDIF
  IF (request->qry_flex_by_ndc)
   CALL query_flex_by_ndc(0)
  ENDIF
  IF (request->qry_linking)
   CALL query_linking(0)
  ENDIF
  IF (request->qry_misc_details)
   CALL query_misc_details(0)
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
END GO
