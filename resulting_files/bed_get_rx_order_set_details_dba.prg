CREATE PROGRAM bed_get_rx_order_set_details:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 short_description = vc
     2 components[*]
       3 id = f8
       3 sequence = i4
       3 description = vc
       3 iv_set_ind = i2
       3 dose = f8
       3 dose_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 freetext_dose = vc
       3 strength_ind = i2
       3 volume_ind = i2
       3 action_ind = i2
       3 intermittent_ind = i2
       3 continuous_ind = i2
       3 medication_ind = i2
       3 default_flag = i2
       3 route
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 frequency
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 prn_ind = i2
       3 prn_reason
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 rate = f8
       3 rate_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 normal_rate = f8
       3 normal_rate_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 infuse_over = f8
       3 infuse_over_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 freetext_rate = vc
       3 stop_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 duration = f8
       3 duration_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 dispense_category
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 order_alert
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 price_schedule
         4 id = f8
         4 description = vc
       3 notes[*]
         4 text = vc
         4 mar_ind = i2
         4 label_ind = i2
         4 fill_list_ind = i2
       3 ordered_as_synonyms[*]
         4 id = f8
         4 mnemonic = vc
         4 selected_ind = i2
     2 facilities[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
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
 DECLARE include_cd = f8
 DECLARE exclude_cd = f8
 DECLARE review_cd = f8
 DECLARE comment1_id = f8
 DECLARE comment1_type = i4
 DECLARE comment2_id = f8
 DECLARE comment2_type = i4
 DECLARE system_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE dispense_cd = f8
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET alert_cd = uar_get_code_by("MEANING",4063,"ORDERALERT")
 SET include_cd = uar_get_code_by("MEANING",4056,"INCLUDE")
 SET exclude_cd = uar_get_code_by("MEANING",4056,"EXCLUDE")
 SET review_cd = uar_get_code_by("MEANING",4056,"REVIEW")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET dispense_cd = uar_get_code_by("MEANING",4063,"DISPENSE")
 SET brandname_cd = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_cd = uar_get_code_by("MEANING",6011,"DCP")
 SET dispdrug_cd = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET generictop_cd = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET ivname_cd = uar_get_code_by("MEANING",6011,"IVNAME")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET tradetop_cd = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET rate_found_ind = 0
 RANGE OF m IS med_oe_defaults
 SET rate_found_ind = validate(m.rate_nbr)
 FREE RANGE m
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
   SET ccnt = 0
   SELECT INTO "nl:"
    FROM med_ingred_set mis,
     med_identifier mi
    PLAN (mis
     WHERE (mis.parent_item_id=reply->items[x].item_id))
     JOIN (mi
     WHERE mi.item_id=mis.child_item_id
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND ((mi.active_ind+ 0)=1)
      AND mi.primary_ind=1)
    ORDER BY mis.sequence
    DETAIL
     ccnt = (ccnt+ 1), stat = alterlist(reply->items[x].components,ccnt), reply->items[x].components[
     ccnt].id = mis.child_item_id,
     reply->items[x].components[ccnt].sequence = mis.sequence
     IF (mis.default_action_cd=include_cd)
      reply->items[x].components[ccnt].action_ind = 1
     ELSEIF (mis.default_action_cd=exclude_cd)
      reply->items[x].components[ccnt].action_ind = 2
     ELSEIF (mis.default_action_cd=review_cd)
      reply->items[x].components[ccnt].action_ind = 3
     ENDIF
     reply->items[x].components[ccnt].description = mi.value
     IF (mi.med_type_flag=3)
      reply->items[x].components[ccnt].iv_set_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (ccnt=0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt)),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense md
    PLAN (d)
     JOIN (mdf
     WHERE (mdf.item_id=reply->items[x].item_id)
      AND (mdf.sequence=reply->items[x].components[d.seq].sequence))
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=dispense_cd)
     JOIN (md
     WHERE md.med_dispense_id=mfoi.parent_entity_id)
    ORDER BY d.seq
    HEAD d.seq
     reply->items[x].components[d.seq].default_flag = md.oe_format_flag, reply->items[x].components[d
     .seq].intermittent_ind = md.intermittent_filter_ind, reply->items[x].components[d.seq].
     continuous_ind = md.continuous_filter_ind,
     reply->items[x].components[d.seq].medication_ind = md.med_filter_ind
    WITH nocounter
   ;end select
   SET fcnt = 0
   SELECT INTO "nl:"
    FROM med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (mi
     WHERE (mi.item_id=reply->items[x].item_id)
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND ((mi.active_ind+ 0)=1))
     JOIN (mdf
     WHERE mdf.item_id=mi.item_id
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=0)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=ord_cd
      AND mfoi.active_ind=1)
    DETAIL
     fcnt = (fcnt+ 1), stat = alterlist(reply->items[x].facilities,fcnt), reply->items[x].facilities[
     fcnt].code_value = mfoi.parent_entity_id,
     reply->items[x].facilities[fcnt].display = uar_get_code_display(mfoi.parent_entity_id), reply->
     items[x].facilities[fcnt].mean = uar_get_code_meaning(mfoi.parent_entity_id)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt)),
     med_ingred_set mis,
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (d)
     JOIN (mis
     WHERE (mis.parent_item_id=reply->items[x].item_id)
      AND (mis.child_item_id=reply->items[x].components[d.seq].id)
      AND (mis.sequence=reply->items[x].components[d.seq].sequence))
     JOIN (mdf
     WHERE mdf.item_id=mis.parent_item_id
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=mis.sequence
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=alert_cd
      AND mfoi.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     reply->items[x].components[d.seq].order_alert.code_value = mfoi.parent_entity_id, reply->items[x
     ].components[d.seq].order_alert.display = uar_get_code_display(mfoi.parent_entity_id), reply->
     items[x].components[d.seq].order_alert.mean = uar_get_code_meaning(mfoi.parent_entity_id)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt)),
     med_ingred_set mis,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     price_sched ps,
     long_text lt1,
     long_text lt2
    PLAN (d)
     JOIN (mis
     WHERE (mis.parent_item_id=reply->items[x].item_id)
      AND (mis.child_item_id=reply->items[x].components[d.seq].id)
      AND (mis.sequence=reply->items[x].components[d.seq].sequence))
     JOIN (mdf
     WHERE mdf.item_id=mis.parent_item_id
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=mis.sequence
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=oedef_cd
      AND mfoi.active_ind=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
      AND mod.active_ind=1)
     JOIN (ps
     WHERE ps.price_sched_id=outerjoin(mod.price_sched_id))
     JOIN (lt1
     WHERE lt1.long_text_id=outerjoin(mod.comment1_id))
     JOIN (lt2
     WHERE lt2.long_text_id=outerjoin(mod.comment2_id))
    ORDER BY d.seq
    HEAD d.seq
     ncnt = 0
    DETAIL
     reply->items[x].components[d.seq].route.code_value = mod.route_cd, reply->items[x].components[d
     .seq].route.display = uar_get_code_display(mod.route_cd), reply->items[x].components[d.seq].
     route.mean = uar_get_code_meaning(mod.route_cd),
     reply->items[x].components[d.seq].frequency.code_value = mod.frequency_cd, reply->items[x].
     components[d.seq].frequency.display = uar_get_code_display(mod.frequency_cd), reply->items[x].
     components[d.seq].frequency.mean = uar_get_code_meaning(mod.frequency_cd),
     reply->items[x].components[d.seq].prn_ind = mod.prn_ind, reply->items[x].components[d.seq].
     prn_reason.code_value = mod.prn_reason_cd, reply->items[x].components[d.seq].prn_reason.display
      = uar_get_code_display(mod.prn_reason_cd),
     reply->items[x].components[d.seq].prn_reason.mean = uar_get_code_meaning(mod.prn_reason_cd),
     reply->items[x].components[d.seq].infuse_over = mod.infuse_over, reply->items[x].components[d
     .seq].infuse_over_units.code_value = mod.infuse_over_cd,
     reply->items[x].components[d.seq].infuse_over_units.display = uar_get_code_display(mod
      .infuse_over_cd), reply->items[x].components[d.seq].infuse_over_units.mean =
     uar_get_code_meaning(mod.infuse_over_cd), reply->items[x].components[d.seq].duration = mod
     .duration,
     reply->items[x].components[d.seq].duration_units.code_value = mod.duration_unit_cd, reply->
     items[x].components[d.seq].duration_units.display = uar_get_code_display(mod.duration_unit_cd),
     reply->items[x].components[d.seq].duration_units.mean = uar_get_code_meaning(mod
      .duration_unit_cd),
     reply->items[x].components[d.seq].stop_type.code_value = mod.stop_type_cd, reply->items[x].
     components[d.seq].stop_type.display = uar_get_code_display(mod.stop_type_cd), reply->items[x].
     components[d.seq].stop_type.mean = uar_get_code_meaning(mod.stop_type_cd),
     reply->items[x].components[d.seq].dispense_category.code_value = mod.dispense_category_cd, reply
     ->items[x].components[d.seq].dispense_category.display = uar_get_code_display(mod
      .dispense_category_cd), reply->items[x].components[d.seq].dispense_category.mean =
     uar_get_code_meaning(mod.dispense_category_cd),
     reply->items[x].components[d.seq].price_schedule.id = mod.price_sched_id, reply->items[x].
     components[d.seq].price_schedule.description = ps.price_sched_desc
     IF (mod.strength > 0)
      reply->items[x].components[d.seq].dose = mod.strength, reply->items[x].components[d.seq].
      dose_units.code_value = mod.strength_unit_cd, reply->items[x].components[d.seq].dose_units.
      display = uar_get_code_display(mod.strength_unit_cd),
      reply->items[x].components[d.seq].dose_units.mean = uar_get_code_meaning(mod.strength_unit_cd),
      reply->items[x].components[d.seq].strength_ind = 1
     ELSE
      reply->items[x].components[d.seq].dose = mod.volume, reply->items[x].components[d.seq].
      dose_units.code_value = mod.volume_unit_cd, reply->items[x].components[d.seq].dose_units.
      display = uar_get_code_display(mod.volume_unit_cd),
      reply->items[x].components[d.seq].dose_units.mean = uar_get_code_meaning(mod.volume_unit_cd),
      reply->items[x].components[d.seq].volume_ind = 1
     ENDIF
     IF (mod.comment1_id > 0)
      ncnt = (ncnt+ 1), stat = alterlist(reply->items[x].components[d.seq].notes,ncnt), reply->items[
      x].components[d.seq].notes[ncnt].text = lt1.long_text
      IF (band(mod.comment1_type,1) > 0)
       reply->items[x].components[d.seq].notes[ncnt].fill_list_ind = 1
      ENDIF
      IF (band(mod.comment1_type,4) > 0)
       reply->items[x].components[d.seq].notes[ncnt].label_ind = 1
      ENDIF
      IF (band(mod.comment1_type,2) > 0)
       reply->items[x].components[d.seq].notes[ncnt].mar_ind = 1
      ENDIF
     ENDIF
     IF (mod.comment2_id > 0)
      ncnt = (ncnt+ 1), stat = alterlist(reply->items[x].components[d.seq].notes,ncnt), reply->items[
      x].components[d.seq].notes[ncnt].text = lt2.long_text
      IF (band(mod.comment2_type,1) > 0)
       reply->items[x].components[d.seq].notes[ncnt].fill_list_ind = 1
      ENDIF
      IF (band(mod.comment2_type,4) > 0)
       reply->items[x].components[d.seq].notes[ncnt].label_ind = 1
      ENDIF
      IF (band(mod.comment2_type,2) > 0)
       reply->items[x].components[d.seq].notes[ncnt].mar_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (rate_found_ind=1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(ccnt)),
      med_ingred_set mis,
      med_def_flex mdf,
      med_flex_object_idx mfoi,
      med_oe_defaults mod
     PLAN (d)
      JOIN (mis
      WHERE (mis.parent_item_id=reply->items[x].item_id)
       AND (mis.child_item_id=reply->items[x].components[d.seq].id)
       AND (mis.sequence=reply->items[x].components[d.seq].sequence))
      JOIN (mdf
      WHERE mdf.item_id=mis.parent_item_id
       AND mdf.flex_type_cd=syspkg_cd
       AND mdf.sequence=mis.sequence
       AND mdf.active_ind=1)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=oedef_cd
       AND mfoi.active_ind=1)
      JOIN (mod
      WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
       AND mod.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      reply->items[x].components[d.seq].rate = mod.rate_nbr, reply->items[x].components[d.seq].
      rate_units.code_value = mod.rate_unit_cd, reply->items[x].components[d.seq].rate_units.display
       = uar_get_code_display(mod.rate_unit_cd),
      reply->items[x].components[d.seq].rate_units.mean = uar_get_code_meaning(mod.rate_unit_cd),
      reply->items[x].components[d.seq].normal_rate = mod.normalized_rate_nbr, reply->items[x].
      components[d.seq].normal_rate_units.code_value = mod.normalized_rate_unit_cd,
      reply->items[x].components[d.seq].normal_rate_units.display = uar_get_code_display(mod
       .normalized_rate_unit_cd), reply->items[x].components[d.seq].normal_rate_units.mean =
      uar_get_code_meaning(mod.normalized_rate_unit_cd), reply->items[x].components[d.seq].
      freetext_rate = mod.freetext_rate_txt
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt)),
     order_catalog_item_r ocir,
     order_catalog_synonym ocs
    PLAN (d)
     JOIN (ocir
     WHERE (ocir.item_id=reply->items[x].components[d.seq].id))
     JOIN (ocs
     WHERE ocs.catalog_cd=ocir.catalog_cd
      AND ocs.mnemonic_type_cd IN (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd, ivname_cd,
     primary_cd, tradetop_cd)
      AND ocs.orderable_type_flag IN (0, 1, 2, 3, 6,
     8, 9, 10, 11, 13)
      AND ocs.hide_flag IN (0, null)
      AND ocs.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     ordcnt = 0
    DETAIL
     check_mask = 0
     IF ((reply->items[x].components[d.seq].medication_ind=1))
      check_mask = (4+ 2)
     ENDIF
     IF ((reply->items[x].components[d.seq].continuous_ind=1))
      IF (check_mask=0)
       check_mask = (1+ 2)
      ELSE
       check_mask = ((1+ 2)+ 4)
      ENDIF
     ENDIF
     IF ((reply->items[x].components[d.seq].intermittent_ind=1))
      check_mask = ((1+ 2)+ 4)
     ENDIF
     IF (band(ocs.rx_mask,check_mask) > 0)
      ordcnt = (ordcnt+ 1), stat = alterlist(reply->items[x].components[d.seq].ordered_as_synonyms,
       ordcnt), reply->items[x].components[d.seq].ordered_as_synonyms[ordcnt].id = ocs.synonym_id,
      reply->items[x].components[d.seq].ordered_as_synonyms[ordcnt].mnemonic = ocs.mnemonic, reply->
      items[x].components[d.seq].ordered_as_synonyms[ordcnt].selected_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt)),
     med_ingred_set mis,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod
    PLAN (d)
     JOIN (mis
     WHERE (mis.parent_item_id=reply->items[x].item_id)
      AND (mis.child_item_id=reply->items[x].components[d.seq].id)
      AND (mis.sequence=reply->items[x].components[d.seq].sequence))
     JOIN (mdf
     WHERE mdf.item_id=mis.parent_item_id
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=mis.sequence
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=oedef_cd
      AND mfoi.active_ind=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
      AND mod.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     ocnt = size(reply->items[x].components[d.seq].ordered_as_synonyms,5), found_ind = 0, start = 1,
     num = 0
     IF (ocnt > 0)
      found_ind = locateval(num,start,ocnt,mod.ord_as_synonym_id,reply->items[x].components[d.seq].
       ordered_as_synonyms[num].id)
     ENDIF
     IF (found_ind > 0)
      reply->items[x].components[d.seq].ordered_as_synonyms[found_ind].selected_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
