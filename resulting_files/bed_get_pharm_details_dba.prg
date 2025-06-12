CREATE PROGRAM bed_get_pharm_details:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 dispense_factor = f8
     2 strength = f8
     2 strength_unit_code_value = f8
     2 volume = f8
     2 volume_unit_code_value = f8
     2 medication_ind = i2
     2 continuous_ind = i2
     2 tpn_ind = i2
     2 intermittent_ind = i2
     2 legal_status_code_value = f8
     2 formulary_status_code_value = f8
     2 divisibility_ind = i2
     2 infinitely_divisible_ind = i2
     2 divisible_factor = f8
     2 total_volume_flag = i2
     2 dose = f8
     2 dose_unit_code_value = f8
     2 freetext_dose = vc
     2 duration = f8
     2 duration_unit_code_value = f8
     2 stop_type_code_value = f8
     2 route_code_value = f8
     2 frequency_code_value = f8
     2 infuse_over = f8
     2 infuse_over_code_value = f8
     2 prn_ind = i2
     2 prn_reason_code_value = f8
     2 dispense_cat_code_value = f8
     2 price_sched_id = f8
     2 price_sched_display = vc
     2 dosage_form_code_value = f8
     2 order_alerts[*]
       3 order_alert_id = f8
       3 order_alert_display = vc
       3 order_alert_description = vc
       3 order_alert_meaning = vc
     2 order_type_code_value = f8
     2 dc_interaction = f8
     2 dc_display = f8
     2 therapeutic_code_value = f8
     2 therapeutic_display = vc
     2 identifiers[*]
       3 identifier_id = f8
       3 value = vc
       3 primary_ind = i2
       3 identifier_type
         4 code_value = f8
         4 display = vc
     2 dispense_qty = f8
     2 dispense_qty_unit_code_value = f8
     2 dispense_factor_unit_code_value = f8
     2 note1 = vc
     2 note1_type = i2
     2 note2 = vc
     2 note2_type = i2
     2 invalid_ind = i2
     2 rate = f8
     2 rate_units_code_value = f8
     2 normal_rate = f8
     2 normal_rate_units_code_value = f8
     2 freetext_rate = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET rxa_get_req
 FREE SET rxa_get_reply
 EXECUTE rxa_get_medprod_rr_incl  WITH replace("REQUEST","RXA_GET_REQ"), replace("REPLY",
  "RXA_GET_REPLY")
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET system_code_value = 0.0
 SET system_package_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSTEM", "SYSPKGTYP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSPKGTYP")
    system_package_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET med_product_code_value = 0.0
 SET med_oe_defaults_code_value = 0.0
 SET order_alert_code_value = 0.0
 SET med_dispense_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4063
   AND cv.cdf_meaning IN ("MEDPRODUCT", "OEDEF", "ORDERALERT", "DISPENSE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="MEDPRODUCT")
    med_product_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="OEDEF")
    med_oe_defaults_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="ORDERALERT")
    order_alert_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPENSE")
    med_dispense_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET cnt = 0
 SET stat = alterlist(reply->items,size(request->items,5))
 FOR (main_i = 1 TO size(request->items,5))
   SET main_skip_ind = 0
   SET stat = initrec(rxa_get_reply)
   SET stat = initrec(rxa_get_req)
   SET stat = alterlist(rxa_get_req->qual,1)
   SET rxa_get_req->pharm_type_cd = inpatient_code_value
   SET rxa_get_req->qual[1].item_id = request->items[main_i].item_id
   EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",rxa_get_reply)
   IF ((rxa_get_reply->status_data.status="Z"))
    SET reply->items[main_i].invalid_ind = 1
    SET main_skip_ind = 1
    SET reply->items[main_i].item_id = request->items[main_i].item_id
   ENDIF
   SET cnt = size(rxa_get_reply->meddefqual,5)
   IF (main_skip_ind=0)
    FOR (x = 1 TO cnt)
      SET reply->items[main_i].item_id = rxa_get_reply->meddefqual[x].item_id
      SET reply->items[main_i].dosage_form_code_value = rxa_get_reply->meddefqual[x].form_cd
      FOR (y = 1 TO size(rxa_get_reply->meddefqual[x].ordcat,5))
        SET reply->items[main_i].dc_display = rxa_get_reply->meddefqual[x].ordcat[y].dc_display_days
        SET reply->items[main_i].dc_interaction = rxa_get_reply->meddefqual[x].ordcat[y].
        dc_interaction_days
        FOR (z = 1 TO size(rxa_get_reply->meddefqual[x].ordcat[y].ahfs_qual,5))
         SET reply->items[main_i].therapeutic_code_value = rxa_get_reply->meddefqual[x].ordcat[y].
         ahfs_qual[z].alt_sel_category_id
         SELECT INTO "nl:"
          FROM alt_sel_cat a
          WHERE (a.alt_sel_category_id=reply->items[main_i].therapeutic_code_value)
          DETAIL
           reply->items[main_i].therapeutic_display = a.long_description
          WITH nocounter
         ;end select
        ENDFOR
      ENDFOR
      FOR (y = 1 TO size(rxa_get_reply->meddefqual[x].meddefflexqual,5))
        IF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].flex_type_cd=system_code_value))
         IF (size(rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual,5) > 0)
          SET stat = alterlist(reply->items[main_i].identifiers,size(rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medidentifierqual,5))
          SELECT INTO "nl:"
           FROM (dummyt d  WITH seq = size(rxa_get_reply->meddefqual[x].meddefflexqual[y].
             medidentifierqual,5)),
            code_value cv
           PLAN (d
            WHERE (rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].active_ind
            =1))
            JOIN (cv
            WHERE (cv.code_value=rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d
            .seq].med_identifier_type_cd))
           ORDER BY d.seq
           HEAD REPORT
            ident_cnt = 0
           DETAIL
            ident_cnt = (ident_cnt+ 1), reply->items[main_i].identifiers[ident_cnt].identifier_id =
            rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].med_identifier_id,
            reply->items[main_i].identifiers[ident_cnt].identifier_type.code_value = rxa_get_reply->
            meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].med_identifier_type_cd,
            reply->items[main_i].identifiers[ident_cnt].identifier_type.display = cv.display, reply->
            items[main_i].identifiers[ident_cnt].primary_ind = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medidentifierqual[d.seq].primary_ind, reply->items[main_i].identifiers[
            ident_cnt].value = rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq
            ].value
           FOOT REPORT
            stat = alterlist(reply->items[main_i].identifiers,ident_cnt)
           WITH nocounter
          ;end select
         ENDIF
         FOR (z = 1 TO size(rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual,5))
           IF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
           flex_object_type_cd=med_product_code_value))
            SET reply->items[main_i].dispense_factor_unit_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medproductqual[1].base_uom_cd
           ELSEIF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
           flex_object_type_cd=med_oe_defaults_code_value))
            IF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
            medoedefaultsqual[1].freetext_dose > " "))
             SET reply->items[main_i].freetext_dose = rxa_get_reply->meddefqual[x].meddefflexqual[y].
             medflexobjidxqual[z].medoedefaultsqual[1].freetext_dose
            ELSEIF ((((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
            medoedefaultsqual[1].strength > 0)) OR ((rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].strength_unit_cd > 0))) )
             SET reply->items[main_i].dose = rxa_get_reply->meddefqual[x].meddefflexqual[y].
             medflexobjidxqual[z].medoedefaultsqual[1].strength
             SET reply->items[main_i].dose_unit_code_value = rxa_get_reply->meddefqual[x].
             meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].strength_unit_cd
            ELSEIF ((((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
            medoedefaultsqual[1].volume > 0)) OR ((rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].volume_unit_cd > 0))) )
             SET reply->items[main_i].dose = rxa_get_reply->meddefqual[x].meddefflexqual[y].
             medflexobjidxqual[z].medoedefaultsqual[1].volume
             SET reply->items[main_i].dose_unit_code_value = rxa_get_reply->meddefqual[x].
             meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].volume_unit_cd
            ENDIF
            SET reply->items[main_i].duration = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].duration
            SET reply->items[main_i].duration_unit_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].duration_unit_cd
            SET reply->items[main_i].stop_type_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].stop_type_cd
            SET reply->items[main_i].route_code_value = rxa_get_reply->meddefqual[x].meddefflexqual[y
            ].medflexobjidxqual[z].medoedefaultsqual[1].route_cd
            SET reply->items[main_i].frequency_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].frequency_cd
            SET reply->items[main_i].infuse_over = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].infuse_over
            SET reply->items[main_i].infuse_over_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].infuse_over_cd
            SET reply->items[main_i].prn_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].prn_ind
            SET reply->items[main_i].prn_reason_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].prn_reason_cd
            SET reply->items[main_i].dispense_cat_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].medoedefaultsqual[1].dispense_category_cd
            SET reply->items[main_i].price_sched_id = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].price_sched_id
            SET reply->items[main_i].note1 = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].comment1_text
            SET reply->items[main_i].note1_type = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].comment1_type
            SET reply->items[main_i].note2 = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].comment2_text
            SET reply->items[main_i].note2_type = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].medoedefaultsqual[1].comment2_type
            IF ((reply->items[main_i].price_sched_id > 0))
             SELECT INTO "nl:"
              FROM price_sched p
              WHERE (p.price_sched_id=reply->items[main_i].price_sched_id)
              DETAIL
               reply->items[main_i].price_sched_display = p.price_sched_desc
              WITH nocounter
             ;end select
            ENDIF
           ELSEIF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
           flex_object_type_cd=order_alert_code_value))
            SET alrt_len = size(reply->items[main_i].order_alerts,5)
            SET stat = alterlist(reply->items[main_i].order_alerts,(alrt_len+ 1))
            SET reply->items[main_i].order_alerts[(alrt_len+ 1)].order_alert_id = rxa_get_reply->
            meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].parent_entity_id
            SELECT INTO "nl:"
             FROM code_value cv
             WHERE (cv.code_value=reply->items[main_i].order_alerts[(alrt_len+ 1)].order_alert_id)
              AND cv.code_value > 0
             DETAIL
              reply->items[main_i].order_alerts[(alrt_len+ 1)].order_alert_display = cv.display,
              reply->items[main_i].order_alerts[(alrt_len+ 1)].order_alert_description = cv
              .description, reply->items[main_i].order_alerts[(alrt_len+ 1)].order_alert_meaning = cv
              .cdf_meaning
             WITH nocounter
            ;end select
           ENDIF
         ENDFOR
        ELSEIF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].flex_type_cd=
        system_package_code_value))
         SET reply->items[main_i].dispense_qty = rxa_get_reply->meddefqual[x].meddefflexqual[y].pack[
         1].qty
         SET reply->items[main_i].dispense_qty_unit_code_value = rxa_get_reply->meddefqual[x].
         meddefflexqual[y].pack[1].base_uom_cd
         FOR (z = 1 TO size(rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual,5))
           IF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].medflexobjidxqual[z].
           flex_object_type_cd=med_dispense_code_value))
            SET reply->items[main_i].strength = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].meddispensequal[1].strength
            SET reply->items[main_i].strength_unit_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].meddispensequal[1].strength_unit_cd
            SET reply->items[main_i].volume = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].meddispensequal[1].volume
            SET reply->items[main_i].volume_unit_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].meddispensequal[1].volume_unit_cd
            SET reply->items[main_i].medication_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].meddispensequal[1].med_filter_ind
            SET reply->items[main_i].continuous_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].meddispensequal[1].continuous_filter_ind
            SET reply->items[main_i].tpn_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y].
            medflexobjidxqual[z].meddispensequal[1].tpn_filter_ind
            SET reply->items[main_i].intermittent_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y
            ].medflexobjidxqual[z].meddispensequal[1].intermittent_filter_ind
            SET reply->items[main_i].legal_status_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].meddispensequal[1].legal_status_cd
            SET reply->items[main_i].formulary_status_code_value = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].meddispensequal[1].formulary_status_cd
            SET reply->items[main_i].divisibility_ind = rxa_get_reply->meddefqual[x].meddefflexqual[y
            ].medflexobjidxqual[z].meddispensequal[1].divisible_ind
            SET reply->items[main_i].infinitely_divisible_ind = rxa_get_reply->meddefqual[x].
            meddefflexqual[y].medflexobjidxqual[z].meddispensequal[1].infinite_div_ind
            SET reply->items[main_i].divisible_factor = rxa_get_reply->meddefqual[x].meddefflexqual[y
            ].medflexobjidxqual[z].meddispensequal[1].base_issue_factor
            SET reply->items[main_i].total_volume_flag = rxa_get_reply->meddefqual[x].meddefflexqual[
            y].medflexobjidxqual[z].meddispensequal[1].used_as_base_ind
            SET reply->items[main_i].dispense_factor = rxa_get_reply->meddefqual[x].meddefflexqual[y]
            .medflexobjidxqual[z].meddispensequal[1].dispense_factor
            SET order_flag = trim(cnvtstring(rxa_get_reply->meddefqual[x].meddefflexqual[y].
              medflexobjidxqual[z].meddispensequal[1].oe_format_flag))
            SELECT INTO "nl:"
             FROM code_value cv
             WHERE cv.code_set=4037
              AND cv.cdf_meaning=order_flag
             DETAIL
              reply->items[main_i].order_type_code_value = cv.code_value
             WITH nocounter
            ;end select
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      SET rate_found_ind = 0
      RANGE OF m IS med_oe_defaults
      SET rate_found_ind = validate(m.rate_nbr)
      FREE RANGE m
      IF (rate_found_ind=1)
       SELECT INTO "nl:"
        FROM med_def_flex mdf,
         med_flex_object_idx mfoi,
         med_oe_defaults mod
        PLAN (mdf
         WHERE (mdf.item_id=reply->items[main_i].item_id)
          AND mdf.flex_type_cd=system_code_value
          AND mdf.sequence=0
          AND mdf.active_ind=1)
         JOIN (mfoi
         WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
          AND mfoi.flex_object_type_cd=med_oe_defaults_code_value
          AND mfoi.active_ind=1)
         JOIN (mod
         WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
          AND mod.active_ind=1)
        DETAIL
         reply->items[main_i].rate = mod.rate_nbr, reply->items[main_i].rate_units_code_value = mod
         .rate_unit_cd, reply->items[main_i].normal_rate = mod.normalized_rate_nbr,
         reply->items[main_i].normal_rate_units_code_value = mod.normalized_rate_unit_cd, reply->
         items[main_i].freetext_rate = mod.freetext_rate_txt
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
