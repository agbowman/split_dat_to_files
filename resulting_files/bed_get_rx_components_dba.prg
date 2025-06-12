CREATE PROGRAM bed_get_rx_components:dba
 FREE SET reply
 RECORD reply(
   1 components[*]
     2 id = f8
     2 description = vc
     2 iv_set_ind = i2
     2 dose = f8
     2 dose_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 strength_ind = i2
     2 volume_ind = i2
     2 ordered_as_synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 default_ind = i2
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
 DECLARE syspkg_cd = f8
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET ndc_cd = uar_get_code_by("MEANING",11000,"NDC")
 SET generic_cd = uar_get_code_by("MEANING",11000,"GENERIC_NAME")
 SET cdm_cd = uar_get_code_by("MEANING",11000,"CDM")
 SET brand_cd = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET desc_short_cd = uar_get_code_by("MEANING",11000,"DESC_SHORT")
 SET inpt_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET brandname_cd = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_cd = uar_get_code_by("MEANING",6011,"DCP")
 SET dispdrug_cd = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET generictop_cd = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET ivname_cd = uar_get_code_by("MEANING",6011,"IVNAME")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET tradetop_cd = uar_get_code_by("MEANING",6011,"TRADETOP")
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
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ENDIF
 FREE SET temp
 RECORD temp(
   1 components[*]
     2 id = f8
     2 description = vc
     2 iv_set_ind = i2
     2 dose = f8
     2 dose_units
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 strength_ind = i2
     2 volume_ind = i2
     2 flex_id = f8
     2 add_ind = i2
     2 fac[*]
       3 cd = f8
     2 intermittent_ind = i2
     2 continuous_ind = i2
     2 medication_ind = i2
     2 ordered_as_synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 default_ind = i2
 )
 SELECT INTO "nl:"
  FROM med_identifier mi,
   med_def_flex mdf
  PLAN (mi
   WHERE mi.pharmacy_type_cd=inpt_cd
    AND parser(mi_parse)
    AND mi.med_identifier_type_cd=desc_cd
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.med_type_flag+ 0) IN (0, 2, 3))
    AND ((mi.active_ind+ 0)=1))
   JOIN (mdf
   WHERE mdf.item_id=mi.item_id
    AND mdf.active_ind=1)
  ORDER BY mi.item_id
  HEAD mi.item_id
   cnt = (cnt+ 1), stat = alterlist(temp->components,cnt), temp->components[cnt].id = mi.item_id,
   temp->components[cnt].description = mi.value
   IF (mi.med_type_flag=3)
    temp->components[cnt].iv_set_ind = 1
   ENDIF
   temp->components[cnt].flex_id = mi.med_def_flex_id, temp->components[cnt].add_ind = 1
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
   WHERE md.pharmacy_type_cd=inpt_cd
    AND (md.item_id=temp->components[d.seq].id))
  ORDER BY d.seq, md.item_id
  DETAIL
   IF (md.strength > 0)
    temp->components[d.seq].dose = md.strength, temp->components[d.seq].dose_units.code_value = md
    .strength_unit_cd, temp->components[d.seq].dose_units.display = uar_get_code_display(md
     .strength_unit_cd),
    temp->components[d.seq].dose_units.mean = uar_get_code_meaning(md.strength_unit_cd), temp->
    components[d.seq].strength_ind = 1
   ELSEIF (md.volume > 0)
    temp->components[d.seq].dose = md.volume, temp->components[d.seq].dose_units.code_value = md
    .volume_unit_cd, temp->components[d.seq].dose_units.display = uar_get_code_display(md
     .volume_unit_cd),
    temp->components[d.seq].dose_units.mean = uar_get_code_meaning(md.volume_unit_cd), temp->
    components[d.seq].volume_ind = 1
   ELSE
    temp->components[d.seq].dose = 0, temp->components[d.seq].dose_units.code_value = 0, temp->
    components[d.seq].dose_units.display = "",
    temp->components[d.seq].dose_units.mean = ""
   ENDIF
   temp->components[d.seq].intermittent_ind = md.intermittent_filter_ind, temp->components[d.seq].
   continuous_ind = md.continuous_filter_ind, temp->components[d.seq].medication_ind = md
   .med_filter_ind
  WITH nocounter
 ;end select
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->components[d.seq].id)
    AND mdf.flex_type_cd=syspkg_cd
    AND mdf.sequence=0
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=ord_cd
    AND mfoi.active_ind=1)
  ORDER BY d.seq, mdf.item_id, mfoi.parent_entity_id DESC
  HEAD d.seq
   fcnt = 0
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(temp->components[d.seq].fac,fcnt), temp->components[d.seq].fac[
   fcnt].cd = mfoi.parent_entity_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  SET fcnt = size(temp->components[x].fac,5)
  IF (((size(request->facilities,5)=0) OR ((request->facilities[1].code_value=0))) )
   FOR (y = 1 TO fcnt)
     IF ((temp->components[x].fac[y].cd=0)
      AND (temp->components[x].add_ind != 0))
      SET temp->components[x].add_ind = 1
     ELSE
      SET temp->components[x].add_ind = 0
     ENDIF
   ENDFOR
  ELSE
   FOR (z = 1 TO size(request->facilities,5))
     SET fac_found = 0
     IF (fcnt=0)
      SET fac_found = 1
     ENDIF
     FOR (y = 1 TO fcnt)
       IF ((temp->components[x].fac[y].cd IN (request->facilities[z].code_value, 0)))
        SET fac_found = 1
       ELSE
        IF (fac_found != 1)
         SET fac_found = 0
        ENDIF
       ENDIF
     ENDFOR
     IF (fac_found=0)
      SET temp->components[x].add_ind = 0
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog_item_r ocir,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (ocir
   WHERE (ocir.item_id=temp->components[d.seq].id))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.mnemonic_type_cd IN (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd, ivname_cd,
   primary_cd, tradetop_cd)
    AND ocs.orderable_type_flag IN (0, 1, 2, 3, 6,
   8, 9, 10, 11, 13)
    AND ocs.hide_flag IN (0, null)
    AND ocs.active_ind=1)
  ORDER BY d.seq, ocir.item_id, ocs.synonym_id
  HEAD d.seq
   ordcnt = 0
  HEAD ocs.synonym_id
   check_mask = 0
   IF ((temp->components[d.seq].medication_ind=1))
    check_mask = (4+ 2)
   ENDIF
   IF ((temp->components[d.seq].continuous_ind=1))
    IF (check_mask=0)
     check_mask = (1+ 2)
    ELSE
     check_mask = ((1+ 2)+ 4)
    ENDIF
   ENDIF
   IF ((temp->components[d.seq].intermittent_ind=1))
    check_mask = ((1+ 2)+ 4)
   ENDIF
   IF (band(ocs.rx_mask,check_mask) > 0)
    ordcnt = (ordcnt+ 1), stat = alterlist(temp->components[d.seq].ordered_as_synonyms,ordcnt), temp
    ->components[d.seq].ordered_as_synonyms[ordcnt].id = ocs.synonym_id,
    temp->components[d.seq].ordered_as_synonyms[ordcnt].mnemonic = ocs.mnemonic, temp->components[d
    .seq].ordered_as_synonyms[ordcnt].default_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=temp->components[d.seq].id)
    AND mdf.flex_type_cd=system_cd
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=oedef_cd
    AND mfoi.active_ind=1)
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND mod.active_ind=1)
  ORDER BY d.seq, mdf.item_id, mfoi.med_def_flex_id,
   mod.med_oe_defaults_id
  DETAIL
   ocnt = size(temp->components[d.seq].ordered_as_synonyms,5), found_ind = 0, start = 1,
   num = 0
   IF (ocnt > 0)
    found_ind = locateval(num,start,ocnt,mod.ord_as_synonym_id,temp->components[d.seq].
     ordered_as_synonyms[num].id)
   ENDIF
   IF (found_ind > 0)
    temp->components[d.seq].ordered_as_synonyms[found_ind].default_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->components[x].add_ind=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->components,rcnt)
    SET reply->components[rcnt].id = temp->components[x].id
    SET reply->components[rcnt].description = temp->components[x].description
    SET reply->components[rcnt].iv_set_ind = temp->components[x].iv_set_ind
    SET reply->components[rcnt].dose = temp->components[x].dose
    SET reply->components[rcnt].dose_units.code_value = temp->components[x].dose_units.code_value
    SET reply->components[rcnt].dose_units.display = temp->components[x].dose_units.display
    SET reply->components[rcnt].dose_units.mean = temp->components[x].dose_units.mean
    SET reply->components[rcnt].strength_ind = temp->components[x].strength_ind
    SET reply->components[rcnt].volume_ind = temp->components[x].volume_ind
    SET ocnt = size(temp->components[x].ordered_as_synonyms,5)
    SET stat = alterlist(reply->components[rcnt].ordered_as_synonyms,ocnt)
    FOR (o = 1 TO ocnt)
      SET reply->components[rcnt].ordered_as_synonyms[o].id = temp->components[x].
      ordered_as_synonyms[o].id
      SET reply->components[rcnt].ordered_as_synonyms[o].mnemonic = temp->components[x].
      ordered_as_synonyms[o].mnemonic
      SET reply->components[rcnt].ordered_as_synonyms[o].default_ind = temp->components[x].
      ordered_as_synonyms[o].default_ind
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (rcnt > max_cnt)
  SET stat = alterlist(reply->components,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
