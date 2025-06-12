CREATE PROGRAM bed_ens_oc_synonyms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD primary_vv(
   1 vvlist[*]
     2 facility_cd = f8
 )
 RECORD prim_syn_siblings(
   1 synlist[*]
     2 syn_id = f8
 )
 DECLARE activateprimarysynonym(ordercatalogindex=i4) = null
 DECLARE prim_syn_siblings_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET primary_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  DETAIL
   primary_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ord_cat_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD CAT"
   AND cv.active_ind=1
  DETAIL
   ord_cat_value = cv.code_value
  WITH nocounter
 ;end select
 SET ccnt = size(request->clist,5)
 FOR (c = 1 TO ccnt)
   SET curr_ord_desc = fillstring(100," ")
   SET curr_ord_dept_name = fillstring(100," ")
   SET curr_ord_status = 0
   SET curr_cat_type_cd = 0.0
   SET curr_act_type_cd = 0.0
   SET curr_primary = fillstring(100," ")
   SELECT INTO "NL:"
    FROM order_catalog oc
    WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
    DETAIL
     curr_ord_desc = oc.description, curr_ord_dept_name = oc.dept_display_name, curr_ord_status = oc
     .active_ind,
     curr_cat_type_cd = oc.catalog_type_cd, curr_act_type_cd = oc.activity_type_cd, curr_primary = oc
     .primary_mnemonic
    WITH nocounter
   ;end select
   SET sd_row_exists = 0
   SELECT INTO "NL:"
    FROM service_directory sd
    WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET sd_row_exists = 1
   ENDIF
   IF ((request->clist[c].description > " "))
    IF ((curr_ord_desc != request->clist[c].description))
     SET update_dept_name = fillstring(100," ")
     SET update_dept_name = curr_ord_dept_name
     IF (substring(1,2,request->clist[c].description)="zz"
      AND substring(1,2,curr_ord_dept_name) != "zz")
      SET update_dept_name = concat("zz",curr_ord_dept_name)
     ELSEIF (substring(1,2,request->clist[c].description) != "zz"
      AND substring(1,2,curr_ord_dept_name)="zz")
      SET update_dept_name = substring(3,98,curr_ord_dept_name)
     ENDIF
     UPDATE  FROM order_catalog oc
      SET oc.description = request->clist[c].description, oc.dept_display_name = update_dept_name, oc
       .updt_cnt = (oc.updt_cnt+ 1),
       oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task =
       reqinfo->updt_task,
       oc.updt_applctx = reqinfo->updt_applctx
      WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
      WITH nocounter
     ;end update
     UPDATE  FROM bill_item bi
      SET bi.ext_description = request->clist[c].description, bi.active_ind = 1, bi.active_status_cd
        = active_cd,
       bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(
        curdate,curtime),
       bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->updt_applctx
      WHERE (bi.ext_parent_reference_id=request->clist[c].catalog_cd)
       AND bi.parent_qual_cd=1.0
       AND bi.ext_parent_contributor_cd=ord_cat_value
       AND bi.ext_child_reference_id=0.0
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM bill_item bi
       SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->clist[
        c].catalog_cd, bi.ext_parent_contributor_cd = ord_cat_value,
        bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi.ext_child_reference_id
         = 0.0,
        bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
        IF ((request->clist[c].description > "   *")) trim(request->clist[c].description)
        ELSE trim(curr_ord_desc)
        ENDIF
        ,
        bi.ext_owner_cd = curr_act_type_cd, bi.ext_short_desc = substring(1,50,curr_primary), bi
        .active_ind = 1,
        bi.active_status_cd = active_cd, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi
        .active_status_prsnl_id = reqinfo->updt_id,
        bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
        bi.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
     IF (sd_row_exists=1)
      UPDATE  FROM service_directory sd
       SET sd.description = update_dept_name, sd.short_description = update_dept_name, sd.updt_cnt =
        (sd.updt_cnt+ 1),
        sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task =
        reqinfo->updt_task,
        sd.updt_applctx = reqinfo->updt_applctx
       WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
       WITH nocounter
      ;end update
     ENDIF
     UPDATE  FROM code_value cv
      SET cv.description = substring(1,60,request->clist[c].description), cv.updt_cnt = (cv.updt_cnt
       + 1), cv.updt_id = reqinfo->updt_id,
       cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
       .updt_applctx = reqinfo->updt_applctx
      WHERE (code_value=request->clist[c].catalog_cd)
     ;end update
    ENDIF
   ENDIF
   IF ((request->clist[c].dept_name > " ")
    AND (curr_ord_dept_name != request->clist[c].dept_name))
    UPDATE  FROM order_catalog oc
     SET oc.dept_display_name = request->clist[c].dept_name, oc.updt_cnt = (oc.updt_cnt+ 1), oc
      .updt_id = reqinfo->updt_id,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
      .updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
     WITH nocounter
    ;end update
    IF (sd_row_exists=1)
     UPDATE  FROM service_directory sd
      SET sd.description = request->clist[c].dept_name, sd.short_description = request->clist[c].
       dept_name, sd.updt_cnt = (sd.updt_cnt+ 1),
       sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task =
       reqinfo->updt_task,
       sd.updt_applctx = reqinfo->updt_applctx
      WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
      WITH nocounter
     ;end update
    ELSE
     SET catalog_type_mean = fillstring(12," ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_value=curr_cat_type_cd
      DETAIL
       catalog_type_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (((catalog_type_mean="GENERAL LAB") OR (catalog_type_mean="RADIOLOGY")) )
      INSERT  FROM service_directory sd
       SET sd.catalog_cd = request->clist[c].catalog_cd, sd.description = request->clist[c].dept_name,
        sd.short_description = request->clist[c].dept_name,
        sd.active_ind = 1, sd.active_status_cd = active_cd, sd.active_status_dt_tm = cnvtdatetime(
         curdate,curtime),
        sd.active_dt_tm = cnvtdatetime(curdate,curtime), sd.inactive_dt_tm = cnvtdatetime(curdate,
         curtime), sd.updt_cnt = 0,
        sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task =
        reqinfo->updt_task,
        sd.updt_applctx = reqinfo->updt_applctx, sd.synonym_id = 0, sd.bb_processing_cd = 0,
        sd.bb_default_phases_cd = 0, sd.active_status_prsnl_id = reqinfo->updt_id, sd
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        sd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sd.end_effective_dt_tm =
        cnvtdatetime("31-dec-2100 00:00:00.00")
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
   SET scnt = size(request->clist[c].slist,5)
   SET inserts_in_list = 0
   FOR (s = 1 TO scnt)
     IF ((request->clist[c].slist[s].action_flag=1))
      SET inserts_in_list = 1
      SET s = (scnt+ 1)
     ENDIF
   ENDFOR
   IF (inserts_in_list=1)
    SET primary_synonym_id = 0.0
    SET primary_catalog_type_cd = 0.0
    SET primary_order_sentence_id = 0.0
    SET primary_activity_type_cd = 0.0
    SET primary_activity_subtype_cd = 0.0
    SET primary_orderable_type_flag = 0
    SET primary_ref_text_mask = 0
    SET primary_cs_index_cd = 0.0
    SET primary_multiple_ord_sent_ind = 0.0
    SET primary_dcp_clin_cat_cd = 0.0
    SET primary_filtered_od_ind = 0.0
    SET primary_item_id = 0.0
    DECLARE primary_cki = vc
    DECLARE primary_virtual_view = vc
    DECLARE primary_health_plan_view = vc
    DECLARE primary_concept_cki = vc
    SET primary_cki = " "
    SET primary_virtual_view = " "
    SET primary_health_plan_view = " "
    SET primary_concept_cki = " "
    SET primary_concentration_strength = 0.0
    SET primary_concentration_strength_unit_cd = 0.0
    SET primary_concentration_volume = 0.0
    SET primary_concentration_volume_unit_cd = 0.0
    SET primary_template_mnemonic_flag = 0
    SET primary_ingredient_rate_conversion_ind = 0
    SET primary_witness_flag = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym o
     WHERE (o.catalog_cd=request->clist[c].catalog_cd)
      AND o.mnemonic_type_cd=primary_cd
     DETAIL
      primary_synonym_id = o.synonym_id, primary_catalog_type_cd = o.catalog_type_cd,
      primary_order_sentence_id = o.order_sentence_id,
      primary_activity_type_cd = o.activity_type_cd, primary_activity_subtype_cd = o
      .activity_subtype_cd, primary_orderable_type_flag = o.orderable_type_flag,
      primary_ref_text_mask = o.ref_text_mask, primary_cs_index_cd = o.cs_index_cd,
      primary_multiple_ord_sent_ind = o.multiple_ord_sent_ind,
      primary_dcp_clin_cat_cd = o.dcp_clin_cat_cd, primary_filtered_od_ind = o.filtered_od_ind,
      primary_item_id = o.item_id,
      primary_cki = o.cki, primary_virtual_view = o.virtual_view, primary_health_plan_view = o
      .health_plan_view,
      primary_concept_cki = o.concept_cki, primary_concentration_strength = o.concentration_strength,
      primary_concentration_strength_unit_cd = o.concentration_strength_unit_cd,
      primary_concentration_volume = o.concentration_volume, primary_concentration_volume_unit_cd = o
      .concentration_volume_unit_cd, primary_template_mnemonic_flag = o.template_mnemonic_flag,
      primary_ingredient_rate_conversion_ind = o.ingredient_rate_conversion_ind, primary_witness_flag
       = o.witness_flag
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO exit_script
    ENDIF
    SET vvcnt = 0
    SELECT INTO "NL:"
     FROM ocs_facility_r ofr
     WHERE ofr.synonym_id=primary_synonym_id
     DETAIL
      vvcnt = (vvcnt+ 1), stat = alterlist(primary_vv->vvlist,vvcnt), primary_vv->vvlist[vvcnt].
      facility_cd = ofr.facility_cd
     WITH nocounter
    ;end select
   ENDIF
   FOR (s = 1 TO scnt)
     IF ((request->clist[c].slist[s].active_ind=1))
      SET active_status_cd = active_cd
     ELSE
      SET active_status_cd = inactive_cd
     ENDIF
     SET upd_titratable = 0
     IF (validate(request->clist[c].slist[s].titratable_ind))
      SET upd_titratable = 1
     ENDIF
     IF ((request->clist[c].slist[s].action_flag=1))
      IF (upd_titratable=1)
       SET titratable_value = request->clist[c].slist[s].titratable_ind
      ELSE
       SET titratable_value = primary_ingredient_rate_conversion_ind
      ENDIF
      SET new_synonym_id = 0.0
      SELECT INTO "nl:"
       z = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        new_synonym_id = cnvtreal(z)
       WITH format, nocounter
      ;end select
      IF (new_synonym_id=0.0)
       GO TO exit_script
      ENDIF
      INSERT  FROM order_catalog_synonym ocs
       SET ocs.synonym_id = new_synonym_id, ocs.catalog_cd = request->clist[c].catalog_cd, ocs
        .catalog_type_cd = primary_catalog_type_cd,
        ocs.mnemonic = request->clist[c].slist[s].synonym_name, ocs.mnemonic_key_cap = cnvtupper(
         request->clist[c].slist[s].synonym_name), ocs.mnemonic_type_cd = request->clist[c].slist[s].
        synonym_type_cd,
        ocs.oe_format_id = request->clist[c].slist[s].order_entry_format_id, ocs.order_sentence_id =
        primary_order_sentence_id, ocs.active_ind = request->clist[c].slist[s].active_ind,
        ocs.activity_type_cd = primary_activity_type_cd, ocs.updt_applctx = reqinfo->updt_applctx,
        ocs.updt_cnt = 0,
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
         = reqinfo->updt_task,
        ocs.activity_subtype_cd = primary_activity_subtype_cd, ocs.orderable_type_flag =
        primary_orderable_type_flag, ocs.active_status_cd = active_status_cd,
        ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime), ocs.active_status_prsnl_id = 0.0,
        ocs.ref_text_mask = primary_ref_text_mask,
        ocs.cs_index_cd = primary_cs_index_cd, ocs.multiple_ord_sent_ind =
        primary_multiple_ord_sent_ind, ocs.hide_flag = request->clist[c].slist[s].hide_flag,
        ocs.rx_mask = request->clist[c].slist[s].med_admin_mask, ocs.dcp_clin_cat_cd =
        primary_dcp_clin_cat_cd, ocs.filtered_od_ind = primary_filtered_od_ind,
        ocs.item_id = primary_item_id, ocs.mnemonic_key_cap_nls = null, ocs.virtual_view =
        primary_virtual_view,
        ocs.health_plan_view = primary_health_plan_view, ocs.ingredient_rate_conversion_ind =
        titratable_value
       WITH nocounter
      ;end insert
      SET fsize = 0
      IF (validate(request->clist[c].slist[s].facilities) > 0)
       SET fsize = size(request->clist[c].slist[s].facilities,5)
      ENDIF
      IF (fsize > 0)
       INSERT  FROM ocs_facility_r ofr,
         (dummyt d  WITH seq = value(fsize))
        SET ofr.synonym_id = new_synonym_id, ofr.facility_cd = request->clist[c].slist[s].facilities[
         d.seq].facility_code_value, ofr.updt_applctx = reqinfo->updt_applctx,
         ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
         updt_id,
         ofr.updt_task = reqinfo->updt_task
        PLAN (d)
         JOIN (ofr)
        WITH nocounter
       ;end insert
      ELSE
       FOR (v = 1 TO vvcnt)
         INSERT  FROM ocs_facility_r ofr
          SET ofr.synonym_id = new_synonym_id, ofr.facility_cd = primary_vv->vvlist[v].facility_cd,
           ofr.updt_applctx = reqinfo->updt_applctx,
           ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
           updt_id,
           ofr.updt_task = reqinfo->updt_task
          WITH nocounter
         ;end insert
       ENDFOR
      ENDIF
      IF ((request->clist[c].slist[s].synonym_type_cd=primary_cd))
       SET hold_desc = fillstring(100," ")
       IF ((request->clist[c].description > " "))
        SET hold_desc = request->clist[c].description
       ELSE
        SET hold_desc = request->clist[c].slist[s].synonym_name
       ENDIF
       UPDATE  FROM order_catalog oc
        SET oc.primary_mnemonic = request->clist[c].slist[s].synonym_name, oc.description = hold_desc,
         oc.dept_display_name = request->clist[c].slist[s].synonym_name,
         oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(
          curdate,curtime),
         oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx
        WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
        WITH nocounter
       ;end update
       UPDATE  FROM bill_item bi
        SET bi.ext_short_desc = substring(1,50,request->clist[c].slist[s].synonym_name), bi
         .ext_description = hold_desc, bi.active_ind = 1,
         bi.active_status_cd = active_cd, bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_id = reqinfo->
         updt_id,
         bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task = reqinfo->updt_task, bi
         .updt_applctx = reqinfo->updt_applctx
        WHERE (bi.ext_parent_reference_id=request->clist[c].catalog_cd)
         AND bi.parent_qual_cd=1.0
         AND bi.ext_parent_contributor_cd=ord_cat_value
         AND bi.ext_child_reference_id=0.0
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM bill_item bi
         SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
          clist[c].catalog_cd, bi.ext_parent_contributor_cd = ord_cat_value,
          bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi
          .ext_child_reference_id = 0.0,
          bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
          hold_desc,
          bi.ext_owner_cd = curr_act_type_cd, bi.ext_short_desc = substring(1,50,request->clist[c].
           slist[s].synonym_name), bi.active_ind = 1,
          bi.active_status_cd = active_cd, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.active_status_prsnl_id = reqinfo->updt_id,
          bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
          bi.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
       ENDIF
       UPDATE  FROM code_value cv
        SET cv.display = substring(1,40,request->clist[c].slist[s].synonym_name), cv.display_key =
         cnvtupper(cnvtalphanum(substring(1,40,request->clist[c].slist[s].synonym_name))), cv
         .description = substring(1,60,hold_desc),
         cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(
          curdate,curtime),
         cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx
        WHERE (code_value=request->clist[c].catalog_cd)
       ;end update
       IF (sd_row_exists=1)
        UPDATE  FROM service_directory sd
         SET sd.description = request->clist[c].slist[s].synonym_name, sd.short_description = request
          ->clist[c].slist[s].synonym_name, sd.updt_cnt = (sd.updt_cnt+ 1),
          sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task
           = reqinfo->updt_task,
          sd.updt_applctx = reqinfo->updt_applctx
         WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
     ELSEIF ((request->clist[c].slist[s].action_flag=2))
      UPDATE  FROM order_catalog_synonym ocs
       SET ocs.mnemonic_type_cd = request->clist[c].slist[s].synonym_type_cd, ocs.mnemonic = request
        ->clist[c].slist[s].synonym_name, ocs.mnemonic_key_cap = cnvtupper(request->clist[c].slist[s]
         .synonym_name),
        ocs.oe_format_id = request->clist[c].slist[s].order_entry_format_id, ocs.hide_flag = request
        ->clist[c].slist[s].hide_flag, ocs.rx_mask = request->clist[c].slist[s].med_admin_mask,
        ocs.active_ind = request->clist[c].slist[s].active_ind, ocs.active_status_cd =
        active_status_cd, ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime),
        ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs
        .ingredient_rate_conversion_ind =
        IF (upd_titratable=1) request->clist[c].slist[s].titratable_ind
        ELSE ocs.ingredient_rate_conversion_ind
        ENDIF
       WHERE (ocs.catalog_cd=request->clist[c].catalog_cd)
        AND (ocs.synonym_id=request->clist[c].slist[s].synonym_id)
       WITH nocounter
      ;end update
      IF ((request->clist[c].slist[s].synonym_type_cd != primary_cd)
       AND (request->clist[c].slist[s].active_ind=1))
       CALL activateprimarysynonym(c)
      ENDIF
      IF ((request->clist[c].slist[s].synonym_type_cd=primary_cd)
       AND (request->clist[c].slist[s].active_ind=0))
       SELECT INTO "nl:"
        FROM order_catalog_synonym ocs
        WHERE (ocs.catalog_cd=request->clist[c].catalog_cd)
         AND ocs.active_ind=1
        DETAIL
         prim_syn_siblings_cnt = (prim_syn_siblings_cnt+ 1), stat = alterlist(prim_syn_siblings->
          synlist,prim_syn_siblings_cnt), prim_syn_siblings->synlist[prim_syn_siblings_cnt].syn_id =
         ocs.synonym_id
        WITH nocounter
       ;end select
       FOR (i = 1 TO prim_syn_siblings_cnt)
         UPDATE  FROM order_catalog_synonym ocs
          SET ocs.active_ind = 0, ocs.active_status_cd = active_status_cd, ocs.active_status_dt_tm =
           cnvtdatetime(curdate,curtime),
           ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm =
           cnvtdatetime(curdate,curtime),
           ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx
          WHERE (ocs.synonym_id=prim_syn_siblings->synlist[i].syn_id)
           AND ocs.active_ind=1
           AND ocs.mnemonic_type_cd != primary_cd
          WITH nocounter
         ;end update
       ENDFOR
      ENDIF
      IF ((request->clist[c].slist[s].synonym_type_cd=primary_cd))
       UPDATE  FROM order_catalog oc
        SET oc.primary_mnemonic = request->clist[c].slist[s].synonym_name, oc.oe_format_id = request
         ->clist[c].slist[s].order_entry_format_id, oc.updt_cnt = (oc.updt_cnt+ 1),
         oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task
          = reqinfo->updt_task,
         oc.updt_applctx = reqinfo->updt_applctx
        WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
        WITH nocounter
       ;end update
       UPDATE  FROM bill_item bi
        SET bi.ext_short_desc = substring(1,50,request->clist[c].slist[s].synonym_name), bi
         .ext_description =
         IF ((request->clist[c].description > "   *")) trim(request->clist[c].description)
         ELSE trim(curr_ord_desc)
         ENDIF
         , bi.active_ind = 1,
         bi.active_status_cd = active_cd, bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_id = reqinfo->
         updt_id,
         bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task = reqinfo->updt_task, bi
         .updt_applctx = reqinfo->updt_applctx
        WHERE (bi.ext_parent_reference_id=request->clist[c].catalog_cd)
         AND bi.parent_qual_cd=1.0
         AND bi.ext_parent_contributor_cd=ord_cat_value
         AND bi.ext_child_reference_id=0.0
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM bill_item bi
         SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
          clist[c].catalog_cd, bi.ext_parent_contributor_cd = ord_cat_value,
          bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi
          .ext_child_reference_id = 0.0,
          bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
          IF ((request->clist[c].description > "   *")) trim(request->clist[c].description)
          ELSE trim(curr_ord_desc)
          ENDIF
          ,
          bi.ext_owner_cd = curr_act_type_cd, bi.ext_short_desc = substring(1,50,request->clist[c].
           slist[s].synonym_name), bi.active_ind = 1,
          bi.active_status_cd = active_cd, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.active_status_prsnl_id = reqinfo->updt_id,
          bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
          bi.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
       ENDIF
       UPDATE  FROM code_value cv
        SET cv.display = substring(1,40,request->clist[c].slist[s].synonym_name), cv.display_key =
         cnvtupper(cnvtalphanum(substring(1,40,request->clist[c].slist[s].synonym_name))), cv
         .updt_cnt = (cv.updt_cnt+ 1),
         cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task
          = reqinfo->updt_task,
         cv.updt_applctx = reqinfo->updt_applctx
        WHERE (code_value=request->clist[c].catalog_cd)
       ;end update
      ENDIF
      IF ((request->clist[c].slist[s].active_ind=1)
       AND curr_ord_status=0)
       UPDATE  FROM order_catalog oc
        SET oc.active_ind = 1, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id,
         oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
         .updt_applctx = reqinfo->updt_applctx
        WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
        WITH nocounter
       ;end update
       UPDATE  FROM bill_item bi
        SET bi.active_ind = 1, bi.active_status_cd = active_cd, bi.updt_cnt = (bi.updt_cnt+ 1),
         bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task
          = reqinfo->updt_task,
         bi.updt_applctx = reqinfo->updt_applctx
        WHERE (bi.ext_parent_reference_id=request->clist[c].catalog_cd)
         AND bi.parent_qual_cd=1.0
         AND bi.ext_parent_contributor_cd=ord_cat_value
         AND bi.ext_child_reference_id=0.0
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM bill_item bi
         SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
          clist[c].catalog_cd, bi.ext_parent_contributor_cd = ord_cat_value,
          bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi
          .ext_child_reference_id = 0.0,
          bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
          IF ((request->clist[c].description > "   *")) trim(request->clist[c].description)
          ELSE trim(curr_ord_desc)
          ENDIF
          ,
          bi.ext_owner_cd = curr_act_type_cd, bi.ext_short_desc =
          IF ((request->clist[c].slist[s].synonym_name > "    *")) substring(1,50,request->clist[c].
            slist[s].synonym_name)
          ELSE substring(1,50,curr_primary)
          ENDIF
          , bi.active_ind = 1,
          bi.active_status_cd = active_cd, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.active_status_prsnl_id = reqinfo->updt_id,
          bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
          bi.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
       ENDIF
       IF (sd_row_exists=1)
        UPDATE  FROM service_directory sd
         SET sd.active_ind = 1, sd.updt_cnt = (sd.updt_cnt+ 1), sd.updt_id = reqinfo->updt_id,
          sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task = reqinfo->updt_task, sd
          .updt_applctx = reqinfo->updt_applctx
         WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
         WITH nocounter
        ;end update
       ENDIF
       UPDATE  FROM code_value cv
        SET cv.active_ind = 1, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id,
         cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
         .updt_applctx = reqinfo->updt_applctx
        WHERE (code_value=request->clist[c].catalog_cd)
       ;end update
       SET curr_ord_status = 1
      ENDIF
      IF ((request->clist[c].slist[s].active_ind=0)
       AND (request->clist[c].slist[s].synonym_type_cd=primary_cd)
       AND curr_ord_status=1)
       UPDATE  FROM order_catalog oc
        SET oc.active_ind = 0, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id,
         oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
         .updt_applctx = reqinfo->updt_applctx
        WHERE (oc.catalog_cd=request->clist[c].catalog_cd)
        WITH nocounter
       ;end update
       UPDATE  FROM bill_item bi
        SET bi.active_ind = 0, bi.active_status_cd = inactive_cd, bi.updt_cnt = (bi.updt_cnt+ 1),
         bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task
          = reqinfo->updt_task,
         bi.updt_applctx = reqinfo->updt_applctx
        WHERE (bi.ext_parent_reference_id=request->clist[c].catalog_cd)
         AND bi.active_ind=1
         AND bi.parent_qual_cd=1.0
         AND bi.ext_parent_contributor_cd=ord_cat_value
         AND bi.ext_child_reference_id=0.0
        WITH nocounter
       ;end update
       IF (sd_row_exists=1)
        UPDATE  FROM service_directory sd
         SET sd.updt_cnt = (sd.updt_cnt+ 1), sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm =
          cnvtdatetime(curdate,curtime),
          sd.updt_task = reqinfo->updt_task, sd.updt_applctx = reqinfo->updt_applctx
         WHERE (sd.catalog_cd=request->clist[c].catalog_cd)
         WITH nocounter
        ;end update
       ENDIF
       UPDATE  FROM code_value cv
        SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id,
         cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
         .updt_applctx = reqinfo->updt_applctx
        WHERE (code_value=request->clist[c].catalog_cd)
       ;end update
       SET curr_ord_status = 0
      ENDIF
     ENDIF
   ENDFOR
   IF ((request->clist[c].name_review_ind=1))
    SET skip_ind = 0
    SELECT INTO "nl:"
     FROM br_name_value bnv
     PLAN (bnv
      WHERE bnv.br_nv_key1="ORCNAMEREVIEWED"
       AND bnv.br_name=cnvtstring(request->clist[c].catalog_cd))
     DETAIL
      skip_ind = 1
     WITH nocounter
    ;end select
    IF (skip_ind=0)
     INSERT  FROM br_name_value b
      SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "ORCNAMEREVIEWED", b.br_value
        = " ",
       b.br_name = cnvtstring(request->clist[c].catalog_cd), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE activateprimarysynonym(ordercatalogindex)
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.active_ind = 1, ocs.active_status_cd = active_cd, ocs.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     ocs.mnemonic = substring(3,textlen(ocs.mnemonic),ocs.mnemonic), ocs.mnemonic_key_cap = substring
     (3,textlen(ocs.mnemonic_key_cap),ocs.mnemonic_key_cap), ocs.updt_cnt = (ocs.updt_cnt+ 1),
     ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_task =
     reqinfo->updt_task,
     ocs.updt_applctx = reqinfo->updt_applctx
    WHERE (ocs.catalog_cd=request->clist[ordercatalogindex].catalog_cd)
     AND ocs.active_ind=0
     AND ocs.mnemonic_type_cd=primary_cd
    WITH nocounter
   ;end update
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
