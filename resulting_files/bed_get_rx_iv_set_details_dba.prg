CREATE PROGRAM bed_get_rx_iv_set_details:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 short_description = vc
     2 intermittent_ind = i2
     2 continuous_ind = i2
     2 default_flag = i2
     2 route
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 frequency
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 prn_ind = i2
     2 prn_reason
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 rate = f8
     2 rate_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 normal_rate = f8
     2 normal_rate_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 infuse_over = f8
     2 infuse_over_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 freetext_rate = vc
     2 stop_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 duration = f8
     2 duration_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 dispense_category
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 order_alert
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 price_schedule
       3 id = f8
       3 description = vc
     2 ingredients[*]
       3 id = f8
       3 description = vc
       3 dose = f8
       3 dose_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 freetext_dose = vc
       3 strength_ind = i2
       3 volume_ind = i2
       3 rx_mask = i4
       3 titrate_ind = i2
       3 norm_rate_ind = i2
       3 diluent_ind = i2
       3 sequence = i4
     2 facilities[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 notes[*]
       3 text = vc
       3 mar_ind = i2
       3 label_ind = i2
       3 fill_list_ind = i2
     2 intermittent_warn_ind = i2
     2 continuous_warn_ind = i2
     2 diluent_warn_ind = i2
     2 rx_mask_warn_ind = i2
     2 duplicates[*]
       3 cpoe_iv_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET itemcnt = 0
 DECLARE flex_id = f8
 DECLARE desc_cd = f8
 DECLARE desc_short_cd = f8
 DECLARE ord_cd = f8
 DECLARE oedef_cd = f8
 DECLARE alert_cd = f8
 DECLARE comment1_id = f8
 DECLARE comment1_type = i4
 DECLARE comment2_id = f8
 DECLARE comment2_type = i4
 DECLARE system_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE dispense_cd = f8
 DECLARE pharmacy_cd = f8
 DECLARE primary_cd = f8
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET alert_cd = uar_get_code_by("MEANING",4063,"ORDERALERT")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET dispense_cd = uar_get_code_by("MEANING",4063,"DISPENSE")
 SET pharmacy_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET rate_found_ind = 0
 RANGE OF m IS med_oe_defaults
 SET rate_found_ind = validate(m.rate_nbr)
 FREE RANGE m
 SET vd_id = 0
 SET vdu_id = 0
 SET sd_id = 0
 SET sdu_id = 0
 SELECT INTO "nl:"
  FROM oe_field_meaning m,
   order_entry_fields o
  PLAN (m
   WHERE m.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE", "STRENGTHDOSEUNIT"))
   JOIN (o
   WHERE o.oe_field_meaning_id=m.oe_field_meaning_id)
  DETAIL
   IF (m.oe_field_meaning="VOLUMEDOSE")
    vd_id = o.oe_field_id
   ENDIF
   IF (m.oe_field_meaning="VOLUMEDOSEUNIT")
    vdu_id = o.oe_field_id
   ENDIF
   IF (m.oe_field_meaning="STRENGTHDOSE")
    sd_id = o.oe_field_id
   ENDIF
   IF (m.oe_field_meaning="STRENGTHDOSEUNIT")
    sdu_id = o.oe_field_id
   ENDIF
  WITH nocounter
 ;end select
 SET itemcnt = size(request->items,5)
 FOR (x = 1 TO itemcnt)
   SET stat = alterlist(reply->items,x)
   SET reply->items[x].item_id = request->items[x].item_id
   SELECT INTO "nl:"
    FROM med_identifier mi
    PLAN (mi
     WHERE (mi.item_id=reply->items[x].item_id)
      AND mi.med_identifier_type_cd IN (desc_cd, desc_short_cd))
    DETAIL
     flex_id = mi.med_def_flex_id
     IF (mi.med_identifier_type_cd=desc_cd)
      reply->items[x].description = mi.value
     ENDIF
     IF (mi.med_identifier_type_cd=desc_short_cd)
      reply->items[x].short_description = mi.value
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense md
    PLAN (mdf
     WHERE (mdf.item_id=reply->items[x].item_id)
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=0
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=dispense_cd
      AND mfoi.active_ind=1)
     JOIN (md
     WHERE md.med_dispense_id=mfoi.parent_entity_id)
    DETAIL
     reply->items[x].default_flag = md.oe_format_flag, reply->items[x].intermittent_ind = md
     .intermittent_filter_ind, reply->items[x].continuous_ind = md.continuous_filter_ind
    WITH nocounter
   ;end select
   SET icnt = 0
   SELECT INTO "nl:"
    FROM med_ingred_set mis,
     med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     order_catalog_item_r ocir,
     order_catalog_synonym ocs
    PLAN (mis
     WHERE (mis.parent_item_id=reply->items[x].item_id))
     JOIN (mi
     WHERE mi.item_id=mis.child_item_id
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND ((mi.active_ind+ 0)=1))
     JOIN (mdf
     WHERE mdf.item_id=mis.parent_item_id
      AND mdf.sequence=mis.sequence)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=oedef_cd
      AND mfoi.active_ind=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
      AND mod.active_ind=1)
     JOIN (ocir
     WHERE ocir.item_id=outerjoin(mis.child_item_id))
     JOIN (ocs
     WHERE ocs.synonym_id=outerjoin(ocir.synonym_id))
    ORDER BY mis.sequence
    HEAD mis.child_item_id
     icnt = (icnt+ 1), stat = alterlist(reply->items[x].ingredients,icnt), reply->items[x].
     ingredients[icnt].id = mis.child_item_id,
     reply->items[x].ingredients[icnt].norm_rate_ind = mis.normalized_rate_ind, reply->items[x].
     ingredients[icnt].description = mi.value
     IF (mod.strength > 0)
      reply->items[x].ingredients[icnt].dose = mod.strength, reply->items[x].ingredients[icnt].
      dose_units.code_value = mod.strength_unit_cd, reply->items[x].ingredients[icnt].dose_units.
      display = uar_get_code_display(mod.strength_unit_cd),
      reply->items[x].ingredients[icnt].dose_units.mean = uar_get_code_meaning(mod.strength_unit_cd),
      reply->items[x].ingredients[icnt].strength_ind = 1
     ELSEIF (mod.volume > 0)
      reply->items[x].ingredients[icnt].dose = mod.volume, reply->items[x].ingredients[icnt].
      dose_units.code_value = mod.volume_unit_cd, reply->items[x].ingredients[icnt].dose_units.
      display = uar_get_code_display(mod.volume_unit_cd),
      reply->items[x].ingredients[icnt].dose_units.mean = uar_get_code_meaning(mod.volume_unit_cd),
      reply->items[x].ingredients[icnt].volume_ind = 1
     ENDIF
     reply->items[x].ingredients[icnt].rx_mask = ocs.rx_mask
     IF (ocs.ingredient_rate_conversion_ind=1)
      reply->items[x].ingredients[icnt].titrate_ind = 1
     ENDIF
     reply->items[x].ingredients[icnt].sequence = mis.sequence
    WITH nocounter
   ;end select
   IF (icnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(icnt)),
      br_name_value b
     PLAN (d)
      JOIN (b
      WHERE b.br_nv_key1="RX_IVSET_DILUENT"
       AND b.br_name=cnvtstring(reply->items[x].item_id)
       AND b.br_value=cnvtstring(reply->items[x].ingredients[d.seq].id))
     ORDER BY d.seq
     HEAD d.seq
      reply->items[x].ingredients[d.seq].diluent_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   FREE SET ord
   RECORD ord(
     1 qual[*]
       2 cd = f8
       2 name = vc
       2 dup_ind = i2
       2 syn[*]
         3 id = f8
         3 found_ind = i2
         3 v_dose = f8
         3 v_dose_unit_cd = f8
         3 s_dose = f8
         3 s_dose_unit_cd = f8
   )
   SET occnt = 0
   SET cscnt = 0
   SELECT INTO "nl:"
    FROM order_catalog oc,
     cs_component cc,
     order_sentence_detail osd
    PLAN (oc
     WHERE oc.catalog_type_cd=pharmacy_cd
      AND ((oc.orderable_type_flag+ 0)=8)
      AND ((oc.active_ind+ 0)=1))
     JOIN (cc
     WHERE cc.catalog_cd=oc.catalog_cd)
     JOIN (osd
     WHERE osd.order_sentence_id=cc.order_sentence_id
      AND ((osd.oe_field_id+ 0) IN (vd_id, vdu_id, sd_id, sdu_id)))
    HEAD oc.catalog_cd
     cscnt = 0, occnt = (occnt+ 1), stat = alterlist(ord->qual,occnt),
     ord->qual[occnt].cd = oc.catalog_cd, ord->qual[occnt].name = oc.primary_mnemonic, ord->qual[
     occnt].dup_ind = 1
    HEAD cc.comp_id
     cscnt = (cscnt+ 1), stat = alterlist(ord->qual[occnt].syn,cscnt), ord->qual[occnt].syn[cscnt].id
      = cc.comp_id,
     ord->qual[occnt].syn[cscnt].found_ind = 0
    DETAIL
     IF (osd.oe_field_id=vd_id)
      ord->qual[occnt].syn[cscnt].v_dose = osd.oe_field_value
     ENDIF
     IF (osd.oe_field_id=vdu_id)
      ord->qual[occnt].syn[cscnt].v_dose_unit_cd = osd.default_parent_entity_id
     ENDIF
     IF (osd.oe_field_id=sd_id)
      ord->qual[occnt].syn[cscnt].s_dose = osd.oe_field_value
     ENDIF
     IF (osd.oe_field_id=sdu_id)
      ord->qual[occnt].syn[cscnt].s_dose_unit_cd = osd.default_parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   IF (icnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(icnt)),
      order_catalog_item_r ocir,
      order_catalog_synonym ocs
     PLAN (d)
      JOIN (ocir
      WHERE (ocir.item_id=reply->items[x].ingredients[d.seq].id))
      JOIN (ocs
      WHERE ocs.catalog_cd=ocir.catalog_cd
       AND ocs.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      ingred_found = 0
     DETAIL
      FOR (j = 1 TO size(ord->qual,5))
        FOR (k = 1 TO size(ord->qual[j].syn,5))
          IF ((ocs.synonym_id=ord->qual[j].syn[k].id))
           IF ((reply->items[x].ingredients[d.seq].volume_ind=1))
            IF ((reply->items[x].ingredients[d.seq].dose=ord->qual[j].syn[k].v_dose)
             AND (reply->items[x].ingredients[d.seq].dose_units.code_value=ord->qual[j].syn[k].
            v_dose_unit_cd))
             ord->qual[j].syn[k].found_ind = 1
            ENDIF
           ENDIF
           IF ((reply->items[x].ingredients[d.seq].strength_ind=1))
            IF ((reply->items[x].ingredients[d.seq].dose=ord->qual[j].syn[k].s_dose)
             AND (reply->items[x].ingredients[d.seq].dose_units.code_value=ord->qual[j].syn[k].
            s_dose_unit_cd))
             ord->qual[j].syn[k].found_ind = 1
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
   SET dcnt = 0
   FOR (j = 1 TO size(ord->qual,5))
     SET fac_found = 0
     SET faccnt = size(request->facilities,5)
     IF (faccnt=0)
      SET faccnt = 1
      SET stat = alterlist(request->facilities,1)
      SET request->facilities[1].code_value = 0
     ENDIF
     SELECT INTO "nl:"
      FROM order_catalog_synonym s,
       ocs_facility_r o
      PLAN (s
       WHERE (s.catalog_cd=ord->qual[j].cd)
        AND s.mnemonic_type_cd=primary_cd)
       JOIN (o
       WHERE o.synonym_id=s.synonym_id)
      DETAIL
       FOR (y = 1 TO faccnt)
         IF ((((request->facilities[y].code_value=o.facility_cd)) OR (o.facility_cd=0)) )
          fac_found = 1
         ENDIF
       ENDFOR
       IF (faccnt=0)
        fac_found = 1
       ENDIF
      WITH nocounter
     ;end select
     FOR (k = 1 TO size(ord->qual[j].syn,5))
       IF ((ord->qual[j].syn[k].found_ind=0))
        SET ord->qual[j].dup_ind = 0
       ENDIF
     ENDFOR
     IF (size(reply->items[x].ingredients,5) != size(ord->qual[j].syn,5))
      SET ord->qual[j].dup_ind = 0
     ENDIF
     IF ((ord->qual[j].dup_ind=1)
      AND fac_found=1)
      SET dcnt = (dcnt+ 1)
      SET stat = alterlist(reply->items[x].duplicates,dcnt)
      SET reply->items[x].duplicates[dcnt].cpoe_iv_set_name = ord->qual[j].name
     ENDIF
   ENDFOR
   IF ((request->load_warning_ind=1))
    IF ((reply->items[x].continuous_ind=1))
     SET additive_found = 0
     SET diluent_found = 0
     SET dilcnt = 0
     FOR (y = 1 TO icnt)
      IF (band(reply->items[x].ingredients[y].rx_mask,2) > 0)
       SET additive_found = 1
      ENDIF
      IF (band(reply->items[x].ingredients[y].rx_mask,1) > 0)
       SET diluent_found = 1
       SET dilcnt = (dilcnt+ 1)
      ENDIF
     ENDFOR
     IF (((additive_found=0) OR (((diluent_found=0) OR (dilcnt > 1)) )) )
      SET reply->items[x].continuous_warn_ind = 1
     ENDIF
    ENDIF
    SET diluent_found = 0
    FOR (y = 1 TO icnt)
      IF (band(reply->items[x].ingredients[y].rx_mask,1) > 0)
       SET diluent_found = 1
      ENDIF
    ENDFOR
    IF (diluent_found=0)
     SET reply->items[x].diluent_warn_ind = 1
    ENDIF
    SET rx_found = 1
    FOR (y = 1 TO icnt)
      IF ((reply->items[x].ingredients[y].rx_mask=0))
       SET rx_found = 0
      ENDIF
    ENDFOR
    IF (rx_found=0)
     SET reply->items[x].rx_mask_warn_ind = 1
    ENDIF
   ELSE
    SET fcnt = 0
    SELECT INTO "nl:"
     FROM med_def_flex mdf,
      med_flex_object_idx mfoi
     PLAN (mdf
      WHERE (mdf.item_id=reply->items[x].item_id)
       AND mdf.flex_type_cd=syspkg_cd
       AND mdf.sequence=0
       AND mdf.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=ord_cd
       AND mfoi.active_ind=1)
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->items[x].facilities,fcnt), reply->items[x].
      facilities[fcnt].code_value = mfoi.parent_entity_id,
      reply->items[x].facilities[fcnt].display = uar_get_code_display(mfoi.parent_entity_id), reply->
      items[x].facilities[fcnt].mean = uar_get_code_meaning(mfoi.parent_entity_id)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM med_def_flex mdf,
      med_flex_object_idx mfoi
     PLAN (mdf
      WHERE (mdf.item_id=reply->items[x].item_id)
       AND mdf.flex_type_cd=system_cd
       AND mdf.sequence=0
       AND mdf.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=alert_cd
       AND mfoi.active_ind=1)
     DETAIL
      reply->items[x].order_alert.code_value = mfoi.parent_entity_id, reply->items[x].order_alert.
      display = uar_get_code_display(mfoi.parent_entity_id), reply->items[x].order_alert.mean =
      uar_get_code_meaning(mfoi.parent_entity_id)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM med_def_flex mdf,
      med_flex_object_idx mfoi,
      med_oe_defaults mod,
      price_sched ps,
      long_text lt1,
      long_text lt2
     PLAN (mdf
      WHERE (mdf.item_id=reply->items[x].item_id)
       AND mdf.flex_type_cd=system_cd
       AND mdf.sequence=0
       AND mdf.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=oedef_cd
       AND mfoi.active_ind=1)
      JOIN (mod
      WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
       AND mod.active_ind=1)
      JOIN (ps
      WHERE ps.price_sched_id=mod.price_sched_id)
      JOIN (lt1
      WHERE lt1.parent_entity_name=outerjoin("MED_OE_DEFAULTS")
       AND lt1.long_text_id=outerjoin(mod.comment1_id))
      JOIN (lt2
      WHERE lt2.parent_entity_name=outerjoin("MED_OE_DEFAULTS")
       AND lt2.long_text_id=outerjoin(mod.comment2_id))
     HEAD REPORT
      ncnt = 0
     DETAIL
      reply->items[x].route.code_value = mod.route_cd, reply->items[x].route.display =
      uar_get_code_display(mod.route_cd), reply->items[x].route.mean = uar_get_code_meaning(mod
       .route_cd),
      reply->items[x].frequency.code_value = mod.frequency_cd, reply->items[x].frequency.display =
      uar_get_code_display(mod.frequency_cd), reply->items[x].frequency.mean = uar_get_code_meaning(
       mod.frequency_cd),
      reply->items[x].prn_ind = mod.prn_ind, reply->items[x].prn_reason.code_value = mod
      .prn_reason_cd, reply->items[x].prn_reason.display = uar_get_code_display(mod.prn_reason_cd),
      reply->items[x].prn_reason.mean = uar_get_code_meaning(mod.prn_reason_cd), reply->items[x].
      infuse_over = mod.infuse_over, reply->items[x].infuse_over_units.code_value = mod
      .infuse_over_cd,
      reply->items[x].infuse_over_units.display = uar_get_code_display(mod.infuse_over_cd), reply->
      items[x].infuse_over_units.mean = uar_get_code_meaning(mod.infuse_over_cd), reply->items[x].
      duration = mod.duration,
      reply->items[x].duration_units.code_value = mod.duration_unit_cd, reply->items[x].
      duration_units.display = uar_get_code_display(mod.duration_unit_cd), reply->items[x].
      duration_units.mean = uar_get_code_meaning(mod.duration_unit_cd),
      reply->items[x].stop_type.code_value = mod.stop_type_cd, reply->items[x].stop_type.display =
      uar_get_code_display(mod.stop_type_cd), reply->items[x].stop_type.mean = uar_get_code_meaning(
       mod.stop_type_cd),
      reply->items[x].dispense_category.code_value = mod.dispense_category_cd, reply->items[x].
      dispense_category.display = uar_get_code_display(mod.dispense_category_cd), reply->items[x].
      dispense_category.mean = uar_get_code_meaning(mod.dispense_category_cd),
      reply->items[x].price_schedule.id = mod.price_sched_id, reply->items[x].price_schedule.
      description = ps.price_sched_desc
      IF (mod.comment1_id > 0)
       ncnt = (ncnt+ 1), stat = alterlist(reply->items[x].notes,ncnt), reply->items[x].notes[ncnt].
       text = lt1.long_text
       IF (band(mod.comment1_type,1) > 0)
        reply->items[x].notes[ncnt].fill_list_ind = 1
       ENDIF
       IF (band(mod.comment1_type,4) > 0)
        reply->items[x].notes[ncnt].label_ind = 1
       ENDIF
       IF (band(mod.comment1_type,2) > 0)
        reply->items[x].notes[ncnt].mar_ind = 1
       ENDIF
      ENDIF
      IF (mod.comment2_id > 0)
       ncnt = (ncnt+ 1), stat = alterlist(reply->items[x].notes,ncnt), reply->items[x].notes[ncnt].
       text = lt2.long_text
       IF (band(mod.comment2_type,1) > 0)
        reply->items[x].notes[ncnt].fill_list_ind = 1
       ENDIF
       IF (band(mod.comment2_type,4) > 0)
        reply->items[x].notes[ncnt].label_ind = 1
       ENDIF
       IF (band(mod.comment2_type,2) > 0)
        reply->items[x].notes[ncnt].mar_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (rate_found_ind=1)
     SELECT INTO "nl:"
      FROM med_def_flex mdf,
       med_flex_object_idx mfoi,
       med_oe_defaults mod
      PLAN (mdf
       WHERE (mdf.item_id=reply->items[x].item_id)
        AND mdf.flex_type_cd=system_cd
        AND mdf.sequence=0
        AND mdf.active_ind=1)
       JOIN (mfoi
       WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
        AND mfoi.flex_object_type_cd=oedef_cd
        AND mfoi.active_ind=1)
       JOIN (mod
       WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
        AND mod.active_ind=1)
      DETAIL
       reply->items[x].rate = mod.rate_nbr, reply->items[x].rate_units.code_value = mod.rate_unit_cd,
       reply->items[x].rate_units.display = uar_get_code_display(mod.rate_unit_cd),
       reply->items[x].rate_units.mean = uar_get_code_meaning(mod.rate_unit_cd), reply->items[x].
       normal_rate = mod.normalized_rate_nbr, reply->items[x].normal_rate_units.code_value = mod
       .normalized_rate_unit_cd,
       reply->items[x].normal_rate_units.display = uar_get_code_display(mod.normalized_rate_unit_cd),
       reply->items[x].normal_rate_units.mean = uar_get_code_meaning(mod.normalized_rate_unit_cd),
       reply->items[x].freetext_rate = mod.freetext_rate_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
