CREATE PROGRAM bed_get_rx_ingredients:dba
 FREE SET reply
 RECORD reply(
   1 ingredients[*]
     2 id = f8
     2 description = vc
     2 rx_mask = i4
     2 titrate_ind = i2
     2 dose = f8
     2 dose_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 strength_ind = i2
     2 volume_ind = i2
   1 too_many_results_ind = i2
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
 SET rcnt = 0
 DECLARE desc_cd = f8
 DECLARE ndc_cd = f8
 DECLARE generic_cd = f8
 DECLARE cdm_cd = f8
 DECLARE brand_cd = f8
 DECLARE desc_short_cd = f8
 DECLARE inpt_cd = f8
 DECLARE ord_cd = f8
 DECLARE oedef_cd = f8
 DECLARE inpatient_cd = f8
 DECLARE syspkg_cd = f8
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET ndc_cd = uar_get_code_by("MEANING",11000,"NDC")
 SET generic_cd = uar_get_code_by("MEANING",11000,"GENERIC_NAME")
 SET cdm_cd = uar_get_code_by("MEANING",11000,"CDM")
 SET brand_cd = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET inpt_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET inpatient_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET wcard = "*"
 DECLARE med_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(cnvtalphanum(request->search_string))),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(cnvtalphanum(request->search_string))),wcard)
  ENDIF
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ENDIF
 FREE SET temp
 RECORD temp(
   1 ingredients[*]
     2 id = f8
     2 description = vc
     2 rx_mask = i4
     2 titrate_ind = i2
     2 flex_id = f8
     2 add_ind = i2
     2 fac[*]
       3 cd = f8
     2 dose = f8
     2 dose_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 strength_ind = i2
     2 volume_ind = i2
 )
 SELECT INTO "nl:"
  FROM med_identifier mi,
   med_def_flex mdf,
   order_catalog_item_r ir,
   order_catalog_synonym ocs
  PLAN (mi
   WHERE mi.pharmacy_type_cd=inpt_cd
    AND parser(mi_parse)
    AND mi.med_identifier_type_cd=desc_cd
    AND mi.med_product_id=0
    AND ((mi.med_type_flag+ 0)=0)
    AND ((mi.active_ind+ 0)=1))
   JOIN (mdf
   WHERE mdf.item_id=mi.item_id
    AND mdf.active_ind=1)
   JOIN (ir
   WHERE ir.item_id=outerjoin(mi.item_id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(ir.synonym_id)
    AND ocs.active_ind=outerjoin(1))
  ORDER BY mi.item_id
  HEAD mi.item_id
   IF ((request->rx_mask > 0))
    IF (band(ocs.rx_mask,request->rx_mask) > 0)
     cnt = (cnt+ 1), stat = alterlist(temp->ingredients,cnt), temp->ingredients[cnt].id = mi.item_id,
     temp->ingredients[cnt].description = mi.value, temp->ingredients[cnt].rx_mask = ocs.rx_mask,
     temp->ingredients[cnt].titrate_ind = ocs.ingredient_rate_conversion_ind,
     temp->ingredients[cnt].flex_id = mi.med_def_flex_id, temp->ingredients[cnt].add_ind = 1
    ENDIF
   ELSE
    cnt = (cnt+ 1), stat = alterlist(temp->ingredients,cnt), temp->ingredients[cnt].id = mi.item_id,
    temp->ingredients[cnt].description = mi.value, temp->ingredients[cnt].rx_mask = ocs.rx_mask, temp
    ->ingredients[cnt].titrate_ind = ocs.ingredient_rate_conversion_ind,
    temp->ingredients[cnt].flex_id = mi.med_def_flex_id, temp->ingredients[cnt].add_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   med_dispense md
  PLAN (d)
   JOIN (md
   WHERE md.pharmacy_type_cd=inpatient_cd
    AND (md.item_id=temp->ingredients[d.seq].id))
  ORDER BY d.seq
  HEAD d.seq
   IF (md.strength > 0)
    temp->ingredients[d.seq].dose = md.strength, temp->ingredients[d.seq].dose_units.code_value = md
    .strength_unit_cd, temp->ingredients[d.seq].dose_units.display = uar_get_code_display(md
     .strength_unit_cd),
    temp->ingredients[d.seq].dose_units.mean = uar_get_code_meaning(md.strength_unit_cd), temp->
    ingredients[d.seq].strength_ind = 1
   ELSEIF (md.volume > 0)
    temp->ingredients[d.seq].dose = md.volume, temp->ingredients[d.seq].dose_units.code_value = md
    .volume_unit_cd, temp->ingredients[d.seq].dose_units.display = uar_get_code_display(md
     .volume_unit_cd),
    temp->ingredients[d.seq].dose_units.mean = uar_get_code_meaning(md.volume_unit_cd), temp->
    ingredients[d.seq].volume_ind = 1
   ELSE
    temp->ingredients[d.seq].dose = 0, temp->ingredients[d.seq].dose_units.code_value = 0, temp->
    ingredients[d.seq].dose_units.display = "",
    temp->ingredients[d.seq].dose_units.mean = ""
   ENDIF
   IF ((request->intermittent_ind > 0))
    IF (md.intermittent_filter_ind=0)
     temp->ingredients[d.seq].add_ind = 0
    ENDIF
   ENDIF
   IF ((request->continuous_ind > 0))
    IF (md.continuous_filter_ind=0)
     temp->ingredients[d.seq].add_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->ingredients[d.seq].id)
    AND mdf.flex_type_cd=syspkg_cd
    AND mdf.sequence=0
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=ord_cd
    AND mfoi.active_ind=1)
  ORDER BY d.seq, mfoi.parent_entity_id DESC
  HEAD d.seq
   fcnt = 0
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(temp->ingredients[d.seq].fac,fcnt), temp->ingredients[d.seq].
   fac[fcnt].cd = mfoi.parent_entity_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  SET fcnt = size(temp->ingredients[x].fac,5)
  IF (((size(request->facilities,5)=0) OR ((request->facilities[1].code_value=0))) )
   FOR (y = 1 TO fcnt)
     IF ((temp->ingredients[x].fac[y].cd=0)
      AND (temp->ingredients[x].add_ind != 0))
      SET temp->ingredients[x].add_ind = 1
     ELSE
      SET temp->ingredients[x].add_ind = 0
     ENDIF
   ENDFOR
  ELSE
   FOR (z = 1 TO size(request->facilities,5))
     SET fac_found = 0
     IF (fcnt=0)
      SET fac_found = 1
     ENDIF
     FOR (y = 1 TO fcnt)
       IF ((temp->ingredients[x].fac[y].cd IN (request->facilities[z].code_value, 0)))
        SET fac_found = 1
       ELSE
        IF (fac_found != 1)
         SET fac_found = 0
        ENDIF
       ENDIF
     ENDFOR
     IF (fac_found=0)
      SET temp->ingredients[x].add_ind = 0
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 FOR (x = 1 TO cnt)
   IF ((temp->ingredients[x].add_ind=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->ingredients,rcnt)
    SET reply->ingredients[rcnt].id = temp->ingredients[x].id
    SET reply->ingredients[rcnt].description = temp->ingredients[x].description
    SET reply->ingredients[rcnt].rx_mask = temp->ingredients[x].rx_mask
    SET reply->ingredients[rcnt].titrate_ind = temp->ingredients[x].titrate_ind
    SET reply->ingredients[rcnt].dose = temp->ingredients[x].dose
    SET reply->ingredients[rcnt].dose_units.code_value = temp->ingredients[x].dose_units.code_value
    SET reply->ingredients[rcnt].dose_units.display = temp->ingredients[x].dose_units.display
    SET reply->ingredients[rcnt].dose_units.mean = temp->ingredients[x].dose_units.mean
    SET reply->ingredients[rcnt].strength_ind = temp->ingredients[x].strength_ind
    SET reply->ingredients[rcnt].volume_ind = temp->ingredients[x].volume_ind
   ENDIF
 ENDFOR
#exit_script
 IF (rcnt > max_cnt)
  SET stat = alterlist(reply->ingredients,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
