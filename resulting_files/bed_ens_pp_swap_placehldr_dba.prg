CREATE PROGRAM bed_ens_pp_swap_placehldr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET placeholderdata
 RECORD placeholderdata(
   1 items[*]
     2 required = i2
     2 included = i2
     2 new_uuid = vc
     2 component_id = f8
     2 new_synonym_id = f8
     2 comp_type = f8
     2 pathway_catalog_id = f8
     2 sequence = i4
     2 new_comp_id = f8
     2 clinical_category = f8
     2 clinical_sub_category = f8
 )
 FREE SET tempaddosdet
 RECORD tempaddosdet(
   1 fielddetail[*]
     2 componentid = f8
     2 sentenceid = f8
     2 oef_id = f8
     2 value = f8
     2 display = vc
     2 field_type_flag = i4
     2 oe_field_meaning_id = f8
     2 sequence = i4
 )
 FREE SET tempaddsynos
 RECORD tempaddsynos(
   1 ordersentence[*]
     2 componentid = f8
     2 id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 usage_flag = i2
     2 comment = vc
     2 commentid = f8
     2 rx_type_mean = vc
     2 intermittent_ind = i2
 )
 FREE SET tempaddingos
 RECORD tempaddingos(
   1 ordersentence[*]
     2 componentid = f8
     2 synonymid = f8
     2 id = f8
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 comment = vc
     2 commentid = f8
 )
 FREE SET tempaddosfilter
 RECORD tempaddosfilter(
   1 filters[*]
     2 order_sentence_filter_id = f8
     2 sentence_id = f8
     2 age_min_value = f8
     2 age_max_value = f8
     2 age_code_value = f8
     2 pma_min_value = f8
     2 pma_max_value = f8
     2 pma_code_value = f8
     2 weight_min_value = f8
     2 weight_max_value = f8
     2 weight_code_value = f8
 )
 FREE SET cleanupreply
 RECORD cleanupreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE createnewcomponents(var=i2) = null
 DECLARE saveos(var=i2) = null
 DECLARE saveiv(var=i2) = null
 DECLARE saveosivdetails(var=i2) = null
 DECLARE componentscount = i4 WITH noconstant(0), protect
 DECLARE compid = f8
 DECLARE tempcount = i4 WITH noconstant(0), protect
 DECLARE addoscnt = i4 WITH noconstant(0), protect
 DECLARE addosdetcnt = i4 WITH noconstant(0), protect
 DECLARE addosfiltercnt = i4 WITH noconstant(0), protect
 DECLARE addivcnt = i4 WITH noconstant(0), protect
 DECLARE intermittent_oe_field_meaning_id = f8 WITH constant(2070.0), protect
 DECLARE intermittent_oe_field_id = f8 WITH protect
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET componentscount = size(request->components,5)
 IF (componentscount=0)
  GO TO exit_script
 ENDIF
 SET intermittent_oe_field_id = 0.0
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.oe_field_meaning_id=intermittent_oe_field_meaning_id
  DETAIL
   intermittent_oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 IF (intermittent_oe_field_id=0.0)
  CALL logerror("intermittent_oe_field_id","Intermittent oe_field_id not found")
 ENDIF
 SET stat = alterlist(placeholderdata->items,componentscount)
 SET tempcnt = 0
 SELECT INTO "nl:"
  FROM pathway_comp pc,
   br_pw_comp_placehldr_r plhldr_rel,
   (dummyt d  WITH seq = componentscount)
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_comp_id=request->components[d.seq].component_id))
   JOIN (plhldr_rel
   WHERE plhldr_rel.pathway_uuid=pc.pathway_uuid)
  DETAIL
   placeholderdata->items[d.seq].pathway_catalog_id = pc.pathway_catalog_id, placeholderdata->items[d
   .seq].sequence = pc.sequence, placeholderdata->items[d.seq].included = plhldr_rel.include_ind,
   placeholderdata->items[d.seq].required = plhldr_rel.required_ind, placeholderdata->items[d.seq].
   clinical_category = pc.dcp_clin_cat_cd, placeholderdata->items[d.seq].clinical_sub_category = pc
   .dcp_clin_sub_cat_cd,
   placeholderdata->items[d.seq].new_synonym_id = request->components[d.seq].new_synonym_id
   IF ((request->components[d.seq].component_type IN (1, 2)))
    placeholderdata->items[d.seq].comp_type = order_comp_cd
   ELSE
    placeholderdata->items[d.seq].comp_type = prescription_comp_cd
   ENDIF
   placeholderdata->items[d.seq].component_id = request->components[d.seq].component_id,
   placeholderdata->items[d.seq].new_uuid = request->components[d.seq].new_uuid, tempcnt = (tempcnt+
   1)
  WITH nocounter
 ;end select
 IF (tempcnt != componentscount)
  CALL logerror("Error loading","Error loading component details")
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM pathway_comp pc,
   (dummyt d  WITH seq = componentscount)
  SET pc.active_ind = 0, pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3
    ),
   pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_comp_id=placeholderdata->items[d.seq].component_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error removing components",serrmsg)
 ENDIF
 SET ierrcode = 0
 DELETE  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = componentscount)
  SET per.seq = 1
  PLAN (d
   WHERE (placeholderdata->items[d.seq].component_id > 0))
   JOIN (per
   WHERE (placeholderdata->items[d.seq].component_id=per.pathway_comp_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error removing evidence",serrmsg)
 ENDIF
 SET ierrcode = 0
 DELETE  FROM pw_comp_os_reltn os,
   (dummyt d  WITH seq = componentscount)
  SET os.seq = 1
  PLAN (d)
   JOIN (os
   WHERE (os.pathway_comp_id=placeholderdata->items[d.seq].component_id)
    AND (placeholderdata->items[d.seq].component_id > 0))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error removing osr",serrmsg)
 ENDIF
 FOR (i = 1 TO componentscount)
   SELECT INTO "nl:"
    tempid = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     compid = cnvtreal(tempid)
    WITH nocounter
   ;end select
   SET placeholderdata->items[i].new_comp_id = compid
   SET tempcount = size(request->components[i].order_sentences,5)
   FOR (j = 1 TO tempcount)
     SET addoscnt = (addoscnt+ 1)
     SET stat = alterlist(tempaddsynos->ordersentence,addoscnt)
     SET newid = 0.0
     SELECT INTO "nl:"
      tempid = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       newid = cnvtreal(tempid)
      WITH nocounter
     ;end select
     SET tempaddsynos->ordersentence[addoscnt].componentid = placeholderdata->items[i].new_comp_id
     SET tempaddsynos->ordersentence[addoscnt].order_sentence_id = request->components[i].
     order_sentences[j].order_sentence_id
     SET tempaddsynos->ordersentence[addoscnt].os_oe_format_id = request->components[i].
     order_sentences[j].os_oe_format_id
     SET tempaddsynos->ordersentence[addoscnt].order_sentence_display_line = request->components[i].
     order_sentences[j].order_sentence_display_line
     SET tempaddsynos->ordersentence[addoscnt].id = newid
     SET tempaddsynos->ordersentence[addoscnt].usage_flag = request->components[i].component_type
     SET tempaddsynos->ordersentence[addoscnt].rx_type_mean = request->components[i].order_sentences[
     j].rx_type_mean
     SET tempaddsynos->ordersentence[addoscnt].sequence = request->components[i].order_sentences[j].
     sequence
     IF ((request->components[i].order_sentences[j].comment > " "))
      SET tempaddsynos->ordersentence[addoscnt].comment = request->components[i].order_sentences[j].
      comment
      SELECT INTO "nl:"
       tempid = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        tempaddsynos->ordersentence[addoscnt].commentid = cnvtreal(tempid)
       WITH nocounter
      ;end select
     ENDIF
     SET detailcount = size(request->components[i].order_sentences[j].details,5)
     SET high_seq = 0
     FOR (tempind = 1 TO detailcount)
       SET addosdetcnt = (addosdetcnt+ 1)
       SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
       SET tempaddosdet->fielddetail[addosdetcnt].display = request->components[i].order_sentences[j]
       .details[tempind].display
       SET tempaddosdet->fielddetail[addosdetcnt].oef_id = request->components[i].order_sentences[j].
       details[tempind].oef_id
       SET tempaddosdet->fielddetail[addosdetcnt].value = request->components[i].order_sentences[j].
       details[tempind].value
       SET tempaddosdet->fielddetail[addosdetcnt].sequence = request->components[i].order_sentences[j
       ].details[tempind].sequence
       SET tempaddosdet->fielddetail[addosdetcnt].componentid = placeholderdata->items[i].new_comp_id
       SET tempaddosdet->fielddetail[addosdetcnt].sentenceid = tempaddsynos->ordersentence[addoscnt].
       id
       IF ((request->components[i].order_sentences[j].details[tempind].sequence > high_seq))
        SET high_seq = request->components[i].order_sentences[j].details[tempind].sequence
       ENDIF
     ENDFOR
     IF ((request->components[i].order_sentences[j].intermittent_ind > 0)
      AND (request->components[i].component_type=1))
      SET addosdetcnt = (addosdetcnt+ 1)
      SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
      SET tempaddosdet->fielddetail[addosdetcnt].componentid = placeholderdata->items[i].new_comp_id
      SET tempaddosdet->fielddetail[addosdetcnt].field_type_flag = 1
      SET tempaddosdet->fielddetail[addosdetcnt].oe_field_meaning_id =
      intermittent_oe_field_meaning_id
      SET tempaddosdet->fielddetail[addosdetcnt].oef_id = intermittent_oe_field_id
      SET tempaddosdet->fielddetail[addosdetcnt].sentenceid = tempaddsynos->ordersentence[addoscnt].
      id
      SET tempaddosdet->fielddetail[addosdetcnt].sequence = (highseq+ 1)
      IF ((request->components[i].order_sentences[j].intermittent_ind=1))
       SET tempaddosdet->fielddetail[addosdetcnt].display = "Intermittent"
       SET tempaddosdet->fielddetail[addosdetcnt].value = 3
      ELSE
       SET tempaddosdet->fielddetail[addosdetcnt].display = "Continuous"
       SET tempaddosdet->fielddetail[addosdetcnt].value = 2
      ENDIF
     ENDIF
     SET filtercount = size(request->components[i].order_sentences[j].filters,5)
     FOR (tempfilterind = 1 TO filtercount)
       SET addosfiltercnt = (addosfiltercnt+ 1)
       SET stat = alterlist(tempaddosfilter->filters,addosfiltercnt)
       IF ((request->components[i].order_sentences[j].filters[tempfilterind].order_sentence_filter_id
       =0))
        SET newfilterid = 0.0
        SELECT INTO "nl:"
         tempid = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          newfilterid = cnvtreal(tempid)
         WITH nocounter
        ;end select
        SET tempaddosfilter->filters[addosfiltercnt].order_sentence_filter_id = newfilterid
       ELSE
        SET tempaddosfilter->filters[addosfiltercnt].order_sentence_filter_id = request->components[i
        ].order_sentences[j].filters[tempfilterind].order_sentence_filter_id
       ENDIF
       SET tempaddosfilter->filters[addosfiltercnt].sentence_id = newid
       SET tempaddosfilter->filters[addosfiltercnt].age_min_value = request->components[i].
       order_sentences[j].filters[tempfilterind].age_min_value
       SET tempaddosfilter->filters[addosfiltercnt].age_max_value = request->components[i].
       order_sentences[j].filters[tempfilterind].age_max_value
       SET tempaddosfilter->filters[addosfiltercnt].age_code_value = request->components[i].
       order_sentences[j].filters[tempfilterind].age_code_value
       SET tempaddosfilter->filters[addosfiltercnt].pma_min_value = request->components[i].
       order_sentences[j].filters[tempfilterind].pma_min_value
       SET tempaddosfilter->filters[addosfiltercnt].pma_max_value = request->components[i].
       order_sentences[j].filters[tempfilterind].pma_max_value
       SET tempaddosfilter->filters[addosfiltercnt].pma_code_value = request->components[i].
       order_sentences[j].filters[tempfilterind].pma_code_value
       SET tempaddosfilter->filters[addosfiltercnt].weight_min_value = request->components[i].
       order_sentences[j].filters[tempfilterind].weight_min_value
       SET tempaddosfilter->filters[addosfiltercnt].weight_max_value = request->components[i].
       order_sentences[j].filters[tempfilterind].weight_max_value
       SET tempaddosfilter->filters[addosfiltercnt].weight_code_value = request->components[i].
       order_sentences[j].filters[tempfilterind].weight_code_value
     ENDFOR
   ENDFOR
   SET tempcount = size(request->components[i].iv_ingredients,5)
   FOR (k = 1 TO tempcount)
     SET addivcnt = (addivcnt+ 1)
     SET stat = alterlist(tempaddingos->ordersentence,addivcnt)
     SET newid = 0.0
     SELECT INTO "nl:"
      tempid = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       newid = cnvtreal(tempid)
      WITH nocounter
     ;end select
     SET tempaddingos->ordersentence[addivcnt].id = newid
     SET tempaddingos->ordersentence[addivcnt].componentid = placeholderdata->items[i].new_comp_id
     SET tempaddingos->ordersentence[addivcnt].order_sentence_display_line = request->components[i].
     iv_ingredients[k].iv_order_sentence.order_sentence_display_line
     SET tempaddingos->ordersentence[addivcnt].order_sentence_id = request->components[i].
     iv_ingredients[k].iv_order_sentence.order_sentence_id
     SET tempaddingos->ordersentence[addivcnt].os_oe_format_id = request->components[i].
     iv_ingredients[k].iv_order_sentence.os_oe_format_id
     SET tempaddingos->ordersentence[addivcnt].synonymid = request->components[i].iv_ingredients[k].
     synonym_id
     IF ((request->components[i].iv_ingredients[k].iv_order_sentence.comment > " "))
      SET tempaddingos->ordersentence[ivsize].comment = request->components[i].iv_ingredients[k].
      iv_order_sentence.comment
      SELECT INTO "nl:"
       tempid = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        tempaddingos->ordersentence[addivcnt].commentid = cnvtreal(tempid)
       WITH nocounter
      ;end select
     ENDIF
     SET ivdetcount = size(request->components[i].iv_ingredients[k].iv_order_sentence.details,5)
     FOR (tempind = 1 TO ivdetcount)
       SET addosdetcnt = (addosdetcnt+ 1)
       SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
       SET tempaddosdet->fielddetail[addosdetcnt].display = request->components[i].iv_ingredients[k].
       iv_order_sentence.details[tempind].display
       SET tempaddosdet->fielddetail[addosdetcnt].oef_id = request->components[i].iv_ingredients[k].
       iv_order_sentence.details[tempind].oef_id
       SET tempaddosdet->fielddetail[addosdetcnt].value = request->components[i].iv_ingredients[k].
       iv_order_sentence.details[tempind].value
       SET tempaddosdet->fielddetail[addosdetcnt].sequence = request->components[i].iv_ingredients[k]
       .iv_order_sentence.details[tempind].sequence
       SET tempaddosdet->fielddetail[addosdetcnt].componentid = placeholderdata->items[i].new_comp_id
       SET tempaddosdet->fielddetail[addosdetcnt].sentenceid = tempaddingos->ordersentence[addivcnt].
       id
     ENDFOR
   ENDFOR
 ENDFOR
 IF (componentscount > 0)
  SET ierrcode = 0
  INSERT  FROM pathway_comp pc,
    (dummyt d  WITH seq = componentscount)
   SET pc.parent_entity_name = "ORDER_CATALOG_SYNONYM", pc.parent_entity_id = placeholderdata->items[
    d.seq].new_synonym_id, pc.pathway_comp_id = placeholderdata->items[d.seq].new_comp_id,
    pc.pathway_catalog_id = placeholderdata->items[d.seq].pathway_catalog_id, pc.pathway_uuid =
    placeholderdata->items[d.seq].new_uuid, pc.required_ind = placeholderdata->items[d.seq].required,
    pc.include_ind = placeholderdata->items[d.seq].included, pc.sequence = placeholderdata->items[d
    .seq].sequence, pc.dcp_clin_cat_cd = placeholderdata->items[d.seq].clinical_category,
    pc.dcp_clin_sub_cat_cd = placeholderdata->items[d.seq].clinical_sub_category, pc.default_os_ind
     = 0, pc.persistent_ind = 0,
    pc.offset_quantity = 0, pc.offset_unit_cd = 0.0, pc.comp_type_cd = placeholderdata->items[d.seq].
    comp_type,
    pc.active_ind = 1, pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
   PLAN (d)
    JOIN (pc)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding components",serrmsg)
  ENDIF
 ENDIF
 IF (addoscnt > 0)
  SET ierrcode = 0
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addoscnt)
   SET os.oe_format_id = tempaddsynos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddsynos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddsynos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.rx_type_mean = tempaddsynos->ordersentence[d.seq].rx_type_mean,
    os.ord_comment_long_text_id = tempaddsynos->ordersentence[d.seq].commentid, os.usage_flag =
    tempaddsynos->ordersentence[d.seq].usage_flag, os.updt_id = reqinfo->updt_id,
    os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task = reqinfo->updt_task, os
    .updt_applctx = reqinfo->updt_applctx,
    os.updt_cnt = 0
   PLAN (d)
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding sentences",serrmsg)
  ENDIF
  SET ierrcode = 0
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addoscnt)
   SET lt.long_text = tempaddsynos->ordersentence[d.seq].comment, lt.long_text_id = tempaddsynos->
    ordersentence[d.seq].commentid, lt.parent_entity_id = tempaddsynos->ordersentence[d.seq].id,
    lt.parent_entity_name = "ORDER_SENTENCE", lt.active_ind = 1, lt.active_status_cd = active_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_task = reqinfo->updt_task,
    lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].commentid > 0.0))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding comment",serrmsg)
  ENDIF
  SET ierrcode = 0
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addoscnt)
   SET pw.iv_comp_syn_id = 0, pw.order_sentence_id = tempaddsynos->ordersentence[d.seq].id, pw
    .order_sentence_seq = tempaddsynos->ordersentence[d.seq].sequence,
    pw.os_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddsynos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d)
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding os relnt",serrmsg)
  ENDIF
 ENDIF
 IF (addivcnt > 0)
  SET ierrcode = 0
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addivcnt)
   SET os.oe_format_id = tempaddingos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddingos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddingos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.parent_entity2_id = tempaddingos->ordersentence[d.seq].synonymid,
    os.parent_entity2_name = "ORDER_CATALOG_SYNONYM", os.usage_flag = 1, os.ord_comment_long_text_id
     = tempaddingos->ordersentence[d.seq].commentid,
    os.updt_id = reqinfo->updt_id, os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task =
    reqinfo->updt_task,
    os.updt_applctx = reqinfo->updt_applctx, os.updt_cnt = 0
   PLAN (d)
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding iv OS",serrmsg)
  ENDIF
  SET ierrcode = 0
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addivcnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddingos->ordersentence[d.seq].
    comment, lt.long_text_id = tempaddingos->ordersentence[d.seq].commentid,
    lt.parent_entity_id = tempaddingos->ordersentence[d.seq].id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_id = reqinfo->updt_id,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_task = reqinfo->updt_task, lt
    .updt_applctx = reqinfo->updt_applctx,
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].commentid > 0.0))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding iv comment",serrmsg)
  ENDIF
  SET ierrcode = 0
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addivcnt)
   SET pw.iv_comp_syn_id = tempaddingos->ordersentence[d.seq].synonymid, pw.order_sentence_id =
    tempaddingos->ordersentence[d.seq].id, pw.order_sentence_seq = 0,
    pw.os_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddingos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d)
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding ivOs reltn",serrmsg)
  ENDIF
 ENDIF
 IF (addosdetcnt > 0)
  SELECT INTO "nl:"
   FROM order_entry_fields oef,
    (dummyt d  WITH seq = addosdetcnt)
   PLAN (d)
    JOIN (oef
    WHERE (oef.oe_field_id=tempaddosdet->fielddetail[d.seq].oef_id))
   DETAIL
    tempaddosdet->fielddetail[d.seq].oe_field_meaning_id = oef.oe_field_meaning_id, tempaddosdet->
    fielddetail[d.seq].field_type_flag = oef.field_type_flag
   WITH nocounter
  ;end select
  SET ierrcode = 0
  INSERT  FROM order_sentence_detail osd,
    (dummyt d  WITH seq = addosdetcnt)
   SET osd.default_parent_entity_name =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) ""
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 9))) "CODE_VALUE"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (12)))
     IF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=48)) "RESEARCH_ACCOUNT"
     ELSEIF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=123)) "SCH_BOOK_INSTR"
     ELSE "CODE_VALUE"
     ENDIF
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (8, 13))) "PERSON"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (10))) "NOMENCLATURE"
    ENDIF
    , osd.default_parent_entity_id =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) 0
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 8, 9, 10, 12,
    13))) tempaddosdet->fielddetail[d.seq].value
    ENDIF
    , osd.field_type_flag = tempaddosdet->fielddetail[d.seq].field_type_flag,
    osd.oe_field_display_value = tempaddosdet->fielddetail[d.seq].display, osd.oe_field_id =
    tempaddosdet->fielddetail[d.seq].oef_id, osd.oe_field_meaning_id = tempaddosdet->fielddetail[d
    .seq].oe_field_meaning_id,
    osd.oe_field_value = tempaddosdet->fielddetail[d.seq].value, osd.order_sentence_id = tempaddosdet
    ->fielddetail[d.seq].sentenceid, osd.sequence = tempaddosdet->fielddetail[d.seq].sequence,
    osd.updt_id = reqinfo->updt_id, osd.updt_dt_tm = cnvtdatetime(curdate,curtime3), osd.updt_task =
    reqinfo->updt_task,
    osd.updt_applctx = reqinfo->updt_applctx, osd.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosdet->fielddetail[d.seq].oef_id > 0))
    JOIN (osd)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding details",serrmsg)
  ENDIF
 ENDIF
 IF (addosfiltercnt > 0)
  INSERT  FROM order_sentence_filter f,
    (dummyt d  WITH seq = addosfiltercnt)
   SET f.order_sentence_filter_id = tempaddosfilter->filters[d.seq].order_sentence_filter_id, f
    .order_sentence_id = tempaddosfilter->filters[d.seq].sentence_id, f.age_max_value =
    tempaddosfilter->filters[d.seq].age_max_value,
    f.age_min_value = tempaddosfilter->filters[d.seq].age_min_value, f.age_unit_cd = tempaddosfilter
    ->filters[d.seq].age_code_value, f.pma_max_value = tempaddosfilter->filters[d.seq].pma_max_value,
    f.pma_min_value = tempaddosfilter->filters[d.seq].pma_min_value, f.pma_unit_cd = tempaddosfilter
    ->filters[d.seq].pma_code_value, f.weight_max_value = tempaddosfilter->filters[d.seq].
    weight_max_value,
    f.weight_min_value = tempaddosfilter->filters[d.seq].weight_min_value, f.weight_unit_cd =
    tempaddosfilter->filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
    f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_task = reqinfo->updt_task, f.updt_applctx
     = reqinfo->updt_applctx,
    f.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosfilter->filters[d.seq].order_sentence_filter_id > 0))
    JOIN (f)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error adding filter",serrmsg)
  ENDIF
 ENDIF
 EXECUTE bed_ens_pp_placehldr_cleanup  WITH replace("REPLY",cleanupreply)
 IF ((cleanupreply->status_data.status != "S"))
  CALL logerror(cleanupreply->status_data.subeventstatus[1].targetobjectname,cleanupreply->
   status_data.subeventstatus[1].targetobjectvalue)
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
