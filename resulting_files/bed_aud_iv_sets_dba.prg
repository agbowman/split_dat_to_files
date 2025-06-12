CREATE PROGRAM bed_aud_iv_sets:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 RECORD temp(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 short_description = vc
     2 rx_unique_id = vc
     2 active_ind = i2
     2 intermittent_ind = i2
     2 continuous_ind = i2
     2 formulary_status = vc
     2 route = vc
     2 frequency = vc
     2 prn_ind = i2
     2 prn_reason = vc
     2 rate = f8
     2 rate_units = vc
     2 normal_rate = f8
     2 normal_rate_units = vc
     2 infuse_over = f8
     2 infuse_over_units = vc
     2 freetext_rate = vc
     2 stop_type = vc
     2 duration = f8
     2 duration_units = vc
     2 dispense_category = vc
     2 order_alert = vc
     2 price_schedule = vc
     2 components[*]
       3 id = f8
       3 description = vc
       3 short_description = vc
       3 dose = f8
       3 dose_units = vc
       3 titrate_ind = i2
       3 sequence = i4
     2 facilities[*]
       3 display = vc
     2 note1 = vc
     2 note1_mar_ind = i2
     2 note1_label_ind = i2
     2 note1_fill_list_ind = i2
     2 note2 = vc
     2 note2_mar_ind = i2
     2 note2_label_ind = i2
     2 note2_fill_list_ind = i2
 )
 DECLARE rate_found_ind = i4
 DECLARE ivsetsize = i4
 DECLARE ivsetparse = vc
 DECLARE facilitysize = i4
 DECLARE facilityparse = vc
 DECLARE high_volume_cnt = i4
 DECLARE icnt = i4
 DECLARE ccnt = i4
 DECLARE high_volume_fac = i4
 DECLARE rcnt = i4
 DECLARE fcnt = i4
 DECLARE true = i2 WITH protect, constant(1)
 DECLARE false = i2 WITH protect, constant(0)
 DECLARE trim_pos = i2
 DECLARE trim_flag = i2
 DECLARE trim_finished = i2
 DECLARE decimal_loc = i2
 DECLARE cur_pos = i2
 DECLARE num_to_str(inc_num=f8,is_rate=i2) = vc
 SET rate_found_ind = 0
 RANGE OF m IS med_oe_defaults
 SET rate_found_ind = validate(m.rate_nbr)
 FREE RANGE m
 DECLARE desc_cd = f8
 DECLARE desc_short_cd = f8
 DECLARE rx_uniqueid_cd = f8
 DECLARE inpt_cd = f8
 DECLARE ord_cd = f8
 DECLARE dispense_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE oedef_cd = f8
 DECLARE alert_cd = f8
 DECLARE system_cd = f8
 DECLARE all = vc WITH protect, constant("1 = 1")
 DECLARE max_facility_count = i4 WITH noconstant(0)
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET rx_uniqueid_cd = uar_get_code_by("MEANING",11000,"RX_UNIQUEID")
 SET inpt_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET dispense_cd = uar_get_code_by("MEANING",4063,"DISPENSE")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET alert_cd = uar_get_code_by("MEANING",4063,"ORDERALERT")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET ivsetsize = size(request->ivset,5)
 IF (ivsetsize > 0)
  SET ivsetparse = build(ivsetparse,"md.item_id IN ( ")
  FOR (pt = 1 TO ivsetsize)
    SET ivsetparse = build(ivsetparse,request->ivset[pt].ivset_cd,",")
  ENDFOR
  SET ivsetparse = replace(ivsetparse,",","",2)
  SET ivsetparse = build(ivsetparse,")")
 ELSE
  SET ivsetparse = "1 = 1"
 ENDIF
 SET facilitysize = size(request->facility,5)
 IF (facilitysize > 0
  AND (request->show_all_facility_ind=0))
  SET facilityparse = build(facilityparse,"mfoi.parent_entity_id IN ( ")
  FOR (pt = 1 TO facilitysize)
    SET facilityparse = build(facilityparse,request->facility[pt].facility_cd,",")
  ENDFOR
  SET facilityparse = replace(facilityparse,",","",2)
  SET facilityparse = build(facilityparse,")")
 ELSE
  SET facilityparse = "1=1"
 ENDIF
 SET high_volume_cnt = 0
 SET icnt = 0
 SELECT INTO "nl:"
  FROM medication_definition md,
   med_identifier mi1,
   med_identifier mi2,
   med_identifier mi3,
   med_ingred_set mis,
   med_identifier mi4,
   med_identifier mi5,
   med_flex_object_idx mfoi,
   med_def_flex mdf,
   med_def_flex mdf1
  PLAN (md
   WHERE parser(ivsetparse)
    AND md.med_type_flag=3)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND parser(facilityparse))
   JOIN (mdf1
   WHERE mdf1.med_def_flex_id=mfoi.med_def_flex_id)
   JOIN (mi1
   WHERE mi1.item_id=mdf1.item_id
    AND mi1.pharmacy_type_cd=inpt_cd
    AND mi1.med_identifier_type_cd=desc_cd
    AND ((mi1.med_product_id+ 0)=0)
    AND ((mi1.active_ind+ 0)=1)
    AND mi1.primary_ind=1)
   JOIN (mi2
   WHERE mi2.item_id=mdf1.item_id
    AND mi2.pharmacy_type_cd=inpt_cd
    AND mi2.med_identifier_type_cd=desc_short_cd
    AND ((mi2.med_product_id+ 0)=0)
    AND ((mi2.active_ind+ 0)=1)
    AND mi2.primary_ind=1)
   JOIN (mi3
   WHERE mi3.item_id=mdf1.item_id
    AND mi3.pharmacy_type_cd=inpt_cd
    AND mi3.med_identifier_type_cd=rx_uniqueid_cd
    AND ((mi3.med_product_id+ 0)=0)
    AND ((mi3.active_ind+ 0)=1))
   JOIN (mis
   WHERE mis.parent_item_id=mdf1.item_id)
   JOIN (mi4
   WHERE mi4.item_id=mis.child_item_id
    AND mi4.med_identifier_type_cd=desc_cd
    AND mi4.med_product_id=0
    AND mi4.primary_ind=1
    AND ((mi4.active_ind+ 0)=1))
   JOIN (mi5
   WHERE mi5.item_id=mis.child_item_id
    AND mi5.med_identifier_type_cd=desc_short_cd
    AND mi5.med_product_id=0
    AND mi5.primary_ind=1
    AND ((mi5.active_ind+ 0)=1))
  ORDER BY md.item_id, cnvtupper(mi1.value), mis.sequence,
   mis.child_item_id
  HEAD mdf1.item_id
   icnt = (icnt+ 1), stat = alterlist(temp->items,icnt), temp->items[icnt].item_id = mdf1.item_id,
   temp->items[icnt].description = mi1.value, temp->items[icnt].short_description = mi2.value, temp->
   items[icnt].rx_unique_id = mi3.value,
   temp->items[icnt].active_ind = mi1.active_ind, ccnt = 0, high_volume_cnt = (high_volume_cnt+ 1)
  HEAD mis.child_item_id
   ccnt = (ccnt+ 1), stat = alterlist(temp->items[icnt].components,ccnt), temp->items[icnt].
   components[ccnt].id = mis.child_item_id,
   temp->items[icnt].components[ccnt].description = mi4.value, temp->items[icnt].components[ccnt].
   short_description = mi5.value, temp->items[icnt].components[ccnt].sequence = mis.sequence,
   high_volume_cnt = (high_volume_cnt+ 1)
  WITH nocounter
 ;end select
 IF (icnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_dispense md
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->items[d.seq].item_id)
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
   temp->items[d.seq].intermittent_ind = md.intermittent_filter_ind, temp->items[d.seq].
   continuous_ind = md.continuous_filter_ind, temp->items[d.seq].formulary_status =
   uar_get_code_display(md.formulary_status_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->items[d.seq].item_id)
    AND mdf.flex_type_cd=system_cd
    AND mdf.sequence=0
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=alert_cd
    AND mfoi.active_ind=1)
  DETAIL
   temp->items[d.seq].order_alert = uar_get_code_display(mfoi.parent_entity_id)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod,
   price_sched ps,
   long_text lt1,
   long_text lt2
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->items[d.seq].item_id)
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
  DETAIL
   temp->items[d.seq].route = uar_get_code_display(mod.route_cd), temp->items[d.seq].frequency =
   uar_get_code_display(mod.frequency_cd), temp->items[d.seq].prn_ind = mod.prn_ind,
   temp->items[d.seq].prn_reason = uar_get_code_display(mod.prn_reason_cd), temp->items[d.seq].
   infuse_over = mod.infuse_over, temp->items[d.seq].infuse_over_units = uar_get_code_display(mod
    .infuse_over_cd),
   temp->items[d.seq].duration = mod.duration, temp->items[d.seq].duration_units =
   uar_get_code_display(mod.duration_unit_cd), temp->items[d.seq].stop_type = uar_get_code_display(
    mod.stop_type_cd),
   temp->items[d.seq].dispense_category = uar_get_code_display(mod.dispense_category_cd), temp->
   items[d.seq].price_schedule = ps.price_sched_desc
   IF (mod.comment1_id > 0)
    temp->items[d.seq].note1 = lt1.long_text
    IF (band(mod.comment1_type,1) > 0)
     temp->items[d.seq].note1_fill_list_ind = 1
    ENDIF
    IF (band(mod.comment1_type,4) > 0)
     temp->items[d.seq].note1_label_ind = 1
    ENDIF
    IF (band(mod.comment1_type,2) > 0)
     temp->items[d.seq].note1_mar_ind = 1
    ENDIF
   ENDIF
   IF (mod.comment2_id > 0)
    temp->items[d.seq].note2 = lt2.long_text
    IF (band(mod.comment2_type,1) > 0)
     temp->items[d.seq].note2_fill_list_ind = 1
    ENDIF
    IF (band(mod.comment2_type,4) > 0)
     temp->items[d.seq].note2_label_ind = 1
    ENDIF
    IF (band(mod.comment2_type,2) > 0)
     temp->items[d.seq].note2_mar_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (rate_found_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(icnt)),
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_oe_defaults mod
   PLAN (d)
    JOIN (mdf
    WHERE (mdf.item_id=temp->items[d.seq].item_id)
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
    temp->items[d.seq].rate = mod.rate_nbr, temp->items[d.seq].rate_units = uar_get_code_display(mod
     .rate_unit_cd), temp->items[d.seq].normal_rate = mod.normalized_rate_nbr,
    temp->items[d.seq].normal_rate_units = uar_get_code_display(mod.normalized_rate_unit_cd), temp->
    items[d.seq].freetext_rate = mod.freetext_rate_txt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   code_value cv
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->items[d.seq].item_id)
    AND mdf.flex_type_cd=syspkg_cd
    AND mdf.sequence=0
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=ord_cd
    AND mfoi.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=mfoi.parent_entity_id
    AND cv.active_ind=1)
  ORDER BY d.seq, cv.display
  HEAD d.seq
   fcnt = 0
  DETAIL
   IF (mfoi.parent_entity_id > 0)
    fcnt = (fcnt+ 1), stat = alterlist(temp->items[d.seq].facilities,fcnt), temp->items[d.seq].
    facilities[fcnt].display = cv.display
   ENDIF
   IF (fcnt > max_facility_count)
    max_facility_count = fcnt
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (max_facility_count > 250
   AND (request->show_all_facility_ind=0))
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 2000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   (dummyt d2  WITH seq = 1),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs
  PLAN (d
   WHERE maxrec(d2,size(temp->items[d.seq].components,5)) > 0)
   JOIN (d2)
   JOIN (mdf
   WHERE (mdf.item_id=temp->items[d.seq].item_id)
    AND (mdf.sequence=temp->items[d.seq].components[d2.seq].sequence)
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=oedef_cd
    AND mfoi.active_ind=1)
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND mod.active_ind=1)
   JOIN (ocir
   WHERE ocir.item_id=outerjoin(temp->items[d.seq].components[d2.seq].id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(ocir.synonym_id))
  ORDER BY d.seq
  DETAIL
   IF (mod.strength > 0)
    temp->items[d.seq].components[d2.seq].dose = mod.strength, temp->items[d.seq].components[d2.seq].
    dose_units = uar_get_code_display(mod.strength_unit_cd)
   ELSEIF (mod.volume > 0)
    temp->items[d.seq].components[d2.seq].dose = mod.volume, temp->items[d.seq].components[d2.seq].
    dose_units = uar_get_code_display(mod.volume_unit_cd)
   ENDIF
   IF (ocs.ingredient_rate_conversion_ind=1)
    temp->items[d.seq].components[d2.seq].titrate_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,39)
 SET reply->collist[1].header_text = "Group ID"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Active Indicator"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Mnemonic"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Unique Rx Id"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Continuous"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Intermittent"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Formulary Status"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Dispense Category"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Route"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Frequency"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Rate"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Rate Unit"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Infuse Over"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Infuse Over Unit"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Normalized Rate"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Normalized Rate Unit"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Freetext Rate"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Stop Type"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Duration"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Duration Unit"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Order Alert"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Price Schedule"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "PRN"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "PRN Reason"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Note 1"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Note Applies to Fill List"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Note Applies to Label"
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = "Note Applies to MAR"
 SET reply->collist[29].data_type = 1
 SET reply->collist[29].hide_ind = 0
 SET reply->collist[30].header_text = "Note 2"
 SET reply->collist[30].data_type = 1
 SET reply->collist[30].hide_ind = 0
 SET reply->collist[31].header_text = "Note Applies to Fill List"
 SET reply->collist[31].data_type = 1
 SET reply->collist[31].hide_ind = 0
 SET reply->collist[32].header_text = "Note Applies to Label"
 SET reply->collist[32].data_type = 1
 SET reply->collist[32].hide_ind = 0
 SET reply->collist[33].header_text = "Note Applies to MAR"
 SET reply->collist[33].data_type = 1
 SET reply->collist[33].hide_ind = 0
 SET reply->collist[34].header_text = "Component Description"
 SET reply->collist[34].data_type = 1
 SET reply->collist[34].hide_ind = 0
 SET reply->collist[35].header_text = "Component Mnemonic"
 SET reply->collist[35].data_type = 1
 SET reply->collist[35].hide_ind = 0
 SET reply->collist[36].header_text = "Sequence"
 SET reply->collist[36].data_type = 1
 SET reply->collist[36].hide_ind = 0
 SET reply->collist[37].header_text = "Titratable Indicator"
 SET reply->collist[37].data_type = 1
 SET reply->collist[37].hide_ind = 0
 SET reply->collist[38].header_text = "Dose"
 SET reply->collist[38].data_type = 1
 SET reply->collist[38].hide_ind = 0
 SET reply->collist[39].header_text = "Facilities"
 SET reply->collist[39].data_type = 1
 SET reply->collist[39].hide_ind = 0
 SET rcnt = 0
 FOR (i = 1 TO icnt)
  SET fcnt = size(temp->items[i].facilities,5)
  IF (facilitysize=0
   AND (request->show_all_facility_ind=1))
   IF (fcnt=0)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,39)
    SET reply->rowlist[rcnt].celllist[39].string_value = "All Facilities"
    SET rcnt = populatereply(rcnt,i)
   ENDIF
  ELSEIF (facilitysize > 0
   AND (request->show_all_facility_ind=0))
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->rowlist,rcnt)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,39)
   IF (fcnt > 0)
    FOR (f = 1 TO fcnt)
     SET reply->rowlist[rcnt].celllist[39].string_value = build(reply->rowlist[rcnt].celllist[39].
      string_value,temp->items[i].facilities[f].display)
     IF (f < fcnt)
      SET reply->rowlist[rcnt].celllist[39].string_value = build(reply->rowlist[rcnt].celllist[39].
       string_value,",")
     ENDIF
    ENDFOR
    SET rcnt = populatereply(rcnt,i)
   ENDIF
  ELSE
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->rowlist,rcnt)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,39)
   IF (fcnt=0)
    SET reply->rowlist[rcnt].celllist[39].string_value = "All Facilities"
   ELSE
    FOR (f = 1 TO fcnt)
     SET reply->rowlist[rcnt].celllist[39].string_value = build(reply->rowlist[rcnt].celllist[39].
      string_value,temp->items[i].facilities[f].display)
     IF (f < fcnt)
      SET reply->rowlist[rcnt].celllist[39].string_value = build(reply->rowlist[rcnt].celllist[39].
       string_value,",")
     ENDIF
    ENDFOR
   ENDIF
   SET rcnt = populatereply(rcnt,i)
  ENDIF
 ENDFOR
 SUBROUTINE populatereply(rcnt,i)
   SET reply->rowlist[rcnt].celllist[1].string_value = cnvtstring(temp->items[i].item_id)
   SET reply->rowlist[rcnt].celllist[2].string_value = cnvtstring(temp->items[i].active_ind)
   SET reply->rowlist[rcnt].celllist[3].string_value = temp->items[i].description
   SET reply->rowlist[rcnt].celllist[4].string_value = temp->items[i].short_description
   SET reply->rowlist[rcnt].celllist[5].string_value = temp->items[i].rx_unique_id
   IF ((temp->items[i].continuous_ind=1))
    SET reply->rowlist[rcnt].celllist[6].string_value = "Yes"
   ELSE
    SET reply->rowlist[rcnt].celllist[6].string_value = "No"
   ENDIF
   IF ((temp->items[i].intermittent_ind=1))
    SET reply->rowlist[rcnt].celllist[7].string_value = "Yes"
   ELSE
    SET reply->rowlist[rcnt].celllist[7].string_value = "No"
   ENDIF
   SET reply->rowlist[rcnt].celllist[8].string_value = temp->items[i].formulary_status
   SET reply->rowlist[rcnt].celllist[9].string_value = temp->items[i].dispense_category
   SET reply->rowlist[rcnt].celllist[10].string_value = temp->items[i].route
   SET reply->rowlist[rcnt].celllist[11].string_value = temp->items[i].frequency
   IF ((temp->items[i].rate > 0))
    SET reply->rowlist[rcnt].celllist[12].string_value = num_to_str(temp->items[i].rate,1)
    SET reply->rowlist[rcnt].celllist[13].string_value = temp->items[i].rate_units
   ENDIF
   IF ((temp->items[i].infuse_over > 0))
    SET reply->rowlist[rcnt].celllist[14].string_value = cnvtstring(temp->items[i].infuse_over)
    SET reply->rowlist[rcnt].celllist[15].string_value = temp->items[i].infuse_over_units
   ENDIF
   IF ((temp->items[i].normal_rate > 0))
    SET reply->rowlist[rcnt].celllist[16].string_value = num_to_str(temp->items[i].normal_rate,1)
    SET reply->rowlist[rcnt].celllist[17].string_value = temp->items[i].normal_rate_units
   ENDIF
   SET reply->rowlist[rcnt].celllist[18].string_value = temp->items[i].freetext_rate
   IF ((temp->items[i].duration > 0))
    SET reply->rowlist[rcnt].celllist[19].string_value = temp->items[i].stop_type
    SET reply->rowlist[rcnt].celllist[20].string_value = cnvtstring(temp->items[i].duration)
    SET reply->rowlist[rcnt].celllist[21].string_value = temp->items[i].duration_units
   ENDIF
   SET reply->rowlist[rcnt].celllist[22].string_value = temp->items[i].order_alert
   SET reply->rowlist[rcnt].celllist[23].string_value = temp->items[i].price_schedule
   IF ((temp->items[i].prn_ind=1))
    SET reply->rowlist[rcnt].celllist[24].string_value = "Yes"
    SET reply->rowlist[rcnt].celllist[25].string_value = temp->items[i].prn_reason
   ELSE
    SET reply->rowlist[rcnt].celllist[24].string_value = " "
   ENDIF
   SET reply->rowlist[rcnt].celllist[26].string_value = temp->items[i].note1
   IF ((temp->items[i].note1 > " "))
    IF ((temp->items[i].note1_fill_list_ind=1))
     SET reply->rowlist[rcnt].celllist[27].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[27].string_value = "No"
    ENDIF
    IF ((temp->items[i].note1_label_ind=1))
     SET reply->rowlist[rcnt].celllist[28].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[28].string_value = "No"
    ENDIF
    IF ((temp->items[i].note1_mar_ind=1))
     SET reply->rowlist[rcnt].celllist[29].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[29].string_value = "No"
    ENDIF
   ENDIF
   SET reply->rowlist[rcnt].celllist[30].string_value = temp->items[i].note2
   IF ((temp->items[i].note2 > " "))
    IF ((temp->items[i].note2_fill_list_ind=1))
     SET reply->rowlist[rcnt].celllist[31].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[31].string_value = "No"
    ENDIF
    IF ((temp->items[i].note2_label_ind=1))
     SET reply->rowlist[rcnt].celllist[32].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[32].string_value = "No"
    ENDIF
    IF ((temp->items[i].note2_mar_ind=1))
     SET reply->rowlist[rcnt].celllist[33].string_value = "Yes"
    ELSE
     SET reply->rowlist[rcnt].celllist[33].string_value = "No"
    ENDIF
   ENDIF
   SET ccnt = size(temp->items[i].components,5)
   FOR (c = 1 TO ccnt)
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->rowlist,rcnt)
     SET stat = alterlist(reply->rowlist[rcnt].celllist,39)
     SET reply->rowlist[rcnt].celllist[1].string_value = cnvtstring(temp->items[i].item_id)
     SET reply->rowlist[rcnt].celllist[34].string_value = temp->items[i].components[c].description
     SET reply->rowlist[rcnt].celllist[35].string_value = temp->items[i].components[c].
     short_description
     SET reply->rowlist[rcnt].celllist[36].string_value = cnvtstring(temp->items[i].components[c].
      sequence)
     IF ((temp->items[i].components[c].titrate_ind=1))
      SET reply->rowlist[rcnt].celllist[37].string_value = "Yes"
     ELSE
      SET reply->rowlist[rcnt].celllist[37].string_value = "No"
     ENDIF
     IF ((temp->items[i].components[c].dose > 0))
      SET reply->rowlist[rcnt].celllist[38].string_value = concat(build(num_to_str(temp->items[i].
         components[c].dose,0))," ",trim(temp->items[i].components[c].dose_units))
     ENDIF
   ENDFOR
   RETURN(rcnt)
 END ;Subroutine
 SUBROUTINE num_to_str(inc_num,is_rate)
   DECLARE cur_string = c15
   SET decimal_loc = 0
   IF (is_rate=0)
    SET cur_string = cnvtstring(inc_num,15,3)
    SET cur_pos = textlen(cnvtstring(inc_num,15,3))
   ELSE
    SET cur_string = cnvtstring(inc_num,15,10)
    SET cur_pos = textlen(cnvtstring(inc_num,15,10))
   ENDIF
   SET decimal_loc = findstring(".",cur_string,1)
   SET trim_flag = false
   SET trim_finished = false
   SET trim_pos = 0
   WHILE (cur_pos > 1
    AND cur_pos >= decimal_loc
    AND decimal_loc > 0
    AND trim_finished=false)
    IF (isnumeric(substring(cur_pos,1,cur_string))
     AND trim_finished=false)
     IF (substring(cur_pos,1,cur_string)="0"
      AND trim_finished=false)
      SET trim_flag = true
      SET trim_pos = cur_pos
     ELSE
      SET trim_finished = true
      SET trim_pos = cur_pos
     ENDIF
    ENDIF
    SET cur_pos = (cur_pos - 1)
   ENDWHILE
   IF (substring(trim_pos,1,cur_string)=".")
    SET trim_pos = (trim_pos - 1)
   ENDIF
   RETURN(substring(1,trim_pos,cur_string))
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iv_sets.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
