CREATE PROGRAM bed_ens_cpoe_set_details:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET fields
 RECORD fields(
   1 fields[*]
     2 oe_field_id = f8
     2 field_disp_value = vc
     2 field_code_value = f8
     2 seq = i4
     2 field_type_flag = i2
     2 dname = vc
     2 dvalue = f8
     2 meaning_id = f8
     2 sent_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET field_found = 0
 SET intermittent_search_ind = 0
 RANGE OF o IS order_catalog_synonym
 SET field_found = validate(o.intermittent_ind)
 FREE RANGE o
 IF (field_found=1)
  SET intermittent_search_ind = 1
 ENDIF
 SET scnt = size(request->sets,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
 SET clin_cat_cd = uar_get_code_by("MEANING",16389,"IVSOLUTIONS")
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET inactive_cd = uar_get_code_by("MEANING",48,"INACTIVE")
 SET ord_cd = uar_get_code_by("MEANING",13016,"ORD CAT")
 SET cs_ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET ord_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET ordsent_cd = uar_get_code_by("MEANING",30620,"ORDERSENT")
 SET active_code_value = active_cd
 SET over_all_active_ind = 1
 DECLARE primary_m = vc
 DECLARE modifiable_flag_value = i2
 DECLARE orderable_type_flag_value = i2
 FOR (x = 1 TO scnt)
   IF (validate(request->sets[x].modifiable_flag))
    SET modifiable_flag_value = request->sets[x].modifiable_flag
   ELSE
    SET modifiable_flag_value = 1
   ENDIF
   IF (validate(request->sets[x].orderable_type_flag))
    SET orderable_type_flag_value = request->sets[x].orderable_type_flag
   ELSE
    SET orderable_type_flag_value = 8
   ENDIF
   SET curr_ord_status = 0
   IF ((request->sets[x].catalog_code_value > 0))
    SELECT INTO "nl:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
     DETAIL
      curr_ord_status = oc.active_ind
     WITH nocounter
    ;end select
   ENDIF
   SET syn_cnt = size(request->sets[x].synonyms,5)
   FOR (s = 1 TO syn_cnt)
     IF ((request->sets[x].synonyms[s].mnemonic_type_code_value=primary_cd))
      SET primary_m = request->sets[x].synonyms[s].mnemonic
      IF ((request->sets[x].synonyms[s].active_ind=0))
       SET active_code_value = inactive_cd
       SET over_all_active_ind = 0
      ENDIF
     ENDIF
   ENDFOR
   IF ((request->sets[x].action_flag=1))
    SET new_cv = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_cv = cnvtreal(j)
     WITH format, counter
    ;end select
    SET request->sets[x].catalog_code_value = new_cv
    SET ierrcode = 0
    INSERT  FROM code_value cv
     SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = over_all_active_ind,
      cv.cki = null, cv.concept_cki = " ", cv.display_key_nls = null,
      cv.display = trim(substring(1,40,primary_m)), cv.display_key = trim(cnvtupper(cnvtalphanum(
         substring(1,40,primary_m)))), cv.description = trim(substring(1,60,request->sets[x].
        description)),
      cv.definition = null, cv.data_status_cd = 0, cv.data_status_prsnl_id = 0,
      cv.active_type_cd = active_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
      .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), cv.updt_id = reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to insert ",trim(
       request->sets[x].description)," into codeset 200.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM order_catalog oc
     SET oc.catalog_cd = new_cv, oc.abn_review_ind = null, oc.activity_type_cd = activity_type_cd,
      oc.activity_subtype_cd = 0, oc.resource_route_lvl = null, oc.active_ind = over_all_active_ind,
      oc.prompt_ind = null, oc.catalog_type_cd = catalog_type_cd, oc.requisition_format_cd = 0,
      oc.requisition_routing_cd = 0, oc.description = trim(substring(1,60,request->sets[x].
        description)), oc.print_req_ind = 0,
      oc.orderable_type_flag = orderable_type_flag_value, oc.oe_format_id = 0, oc.prep_info_flag = 0,
      oc.cont_order_method_flag = 0, oc.primary_mnemonic = trim(substring(1,100,primary_m)), oc
      .dept_display_name = trim(substring(1,60,primary_m)),
      oc.ref_text_mask = null, oc.source_vocab_ident = null, oc.source_vocab_mean = null,
      oc.dcp_clin_cat_cd = clin_cat_cd, oc.cki = null, oc.concept_cki = null,
      oc.consent_form_ind = 0, oc.inst_restriction_ind = 0, oc.schedule_ind = 0,
      oc.quick_chart_ind = 0, oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0,
      oc.dup_checking_ind = null, oc.bill_only_ind = 0, oc.form_level = null,
      oc.modifiable_flag = modifiable_flag_value, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc
      .updt_id = reqinfo->updt_id,
      oc.updt_task = reqinfo->updt_task, oc.updt_cnt = 0, oc.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to insert ",trim(
       request->sets[x].description)," into the order catalog table.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET new_bill_id = 0.0
    SELECT INTO "NL:"
     j = seq(bill_item_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_bill_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET ierrcode = 0
    INSERT  FROM bill_item b
     SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = new_cv, b
      .ext_parent_contributor_cd = ord_cd,
      b.ext_child_reference_id = 0, b.ext_child_contributor_cd = 0, b.ext_description = trim(request
       ->sets[x].description),
      b.ext_owner_cd = activity_type_cd, b.parent_qual_cd = 1, b.charge_point_cd = 0,
      b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = over_all_active_ind,
      b.ext_short_desc = trim(substring(1,50,primary_m)), b.ext_parent_entity_name = "CODE_VALUE", b
      .ext_child_entity_name = null,
      b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
      b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
      b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
      b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
      b.active_status_cd = active_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      b.active_status_prsnl_id = reqinfo->updt_id,
      b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100")
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to insert ",trim(
       request->sets[x].description)," into the bill item table.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ELSEIF ((request->sets[x].action_flag=2))
    SET ierrcode = 0
    UPDATE  FROM code_value cv
     SET cv.display = trim(substring(1,40,primary_m)), cv.display_key = trim(cnvtupper(cnvtalphanum(
         substring(1,40,primary_m)))), cv.description = trim(substring(1,60,request->sets[x].
        description)),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
     WHERE (cv.code_value=request->sets[x].catalog_code_value)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to update ",trim(
       request->sets[x].description)," into codeset 200.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM order_catalog oc
     SET oc.description = trim(substring(1,60,request->sets[x].description)), oc.primary_mnemonic =
      trim(substring(1,100,primary_m)), oc.dept_display_name = trim(substring(1,60,primary_m)),
      oc.orderable_type_flag = orderable_type_flag_value, oc.modifiable_flag = modifiable_flag_value,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1
      ),
      oc.updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to update ",trim(
       request->sets[x].description)," into the order catalog table.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF (intermittent_search_ind=1)
     SET ierrcode = 0
     UPDATE  FROM order_catalog_synonym ocs
      SET ocs.intermittent_ind = request->sets[x].intermittent_ind, ocs.updt_applctx = reqinfo->
       updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1),
       ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
        = reqinfo->updt_task
      WHERE (ocs.catalog_cd=request->sets[x].catalog_code_value)
       AND (ocs.intermittent_ind != request->sets[x].intermittent_ind)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Unable to update order set synonym: ",trim(request->sets[x].synonyms[y].mnemonic),
       " on the order_catalog_synonym table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM bill_item b
     SET b.ext_description = trim(request->sets[x].description), b.ext_short_desc = trim(substring(1,
        50,primary_m)), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
      b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->sets[x].catalog_code_value)
      AND b.ext_parent_contributor_cd=ord_cd
      AND b.ext_child_reference_id=0
      AND b.ext_child_contributor_cd=0
      AND b.child_seq=0
      AND b.active_ind=1
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Unable to update ",trim(
       request->sets[x].description)," into the bill item table.")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (y = 1 TO syn_cnt)
     IF ((request->sets[x].synonyms[y].action_flag=1))
      SET new_order_synonym_id = 0.0
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_order_synonym_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET request->sets[x].synonyms[y].synonym_id = new_order_synonym_id
      IF (intermittent_search_ind=0)
       SET ierrcode = 0
       INSERT  FROM order_catalog_synonym ocs
        SET ocs.synonym_id = new_order_synonym_id, ocs.catalog_cd = request->sets[x].
         catalog_code_value, ocs.catalog_type_cd = catalog_type_cd,
         ocs.mnemonic = request->sets[x].synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
          request->sets[x].synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->sets[x].synonyms[y]
         .mnemonic_type_code_value,
         ocs.oe_format_id = 0, ocs.active_ind = request->sets[x].synonyms[y].active_ind, ocs
         .activity_type_cd = activity_type_cd,
         ocs.activity_subtype_cd = 0, ocs.orderable_type_flag = orderable_type_flag_value, ocs
         .concentration_strength = null,
         ocs.concentration_volume = null, ocs.active_status_cd =
         IF ((request->sets[x].synonyms[y].active_ind=1)) active_cd
         ELSE inactive_cd
         ENDIF
         , ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.ref_text_mask = null, ocs
         .multiple_ord_sent_ind = null,
         ocs.hide_flag = 0, ocs.rx_mask = 3, ocs.dcp_clin_cat_cd = clin_cat_cd,
         ocs.filtered_od_ind = null, ocs.cki = null, ocs.mnemonic_key_cap_nls = null,
         ocs.virtual_view = " ", ocs.health_plan_view = null, ocs.concept_cki = null,
         ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = 0, ocs.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Unable to insert order set synonym: ",trim(request->sets[x].synonyms[y].mnemonic),
         " on the order_catalog_synonym table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       INSERT  FROM order_catalog_synonym ocs
        SET ocs.synonym_id = new_order_synonym_id, ocs.catalog_cd = request->sets[x].
         catalog_code_value, ocs.catalog_type_cd = catalog_type_cd,
         ocs.mnemonic = request->sets[x].synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
          request->sets[x].synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->sets[x].synonyms[y]
         .mnemonic_type_code_value,
         ocs.oe_format_id = 0, ocs.active_ind = request->sets[x].synonyms[y].active_ind, ocs
         .activity_type_cd = activity_type_cd,
         ocs.activity_subtype_cd = 0, ocs.orderable_type_flag = orderable_type_flag_value, ocs
         .concentration_strength = null,
         ocs.concentration_volume = null, ocs.active_status_cd =
         IF ((request->sets[x].synonyms[y].active_ind=1)) active_cd
         ELSE inactive_cd
         ENDIF
         , ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.ref_text_mask = null, ocs
         .multiple_ord_sent_ind = null,
         ocs.hide_flag = 0, ocs.rx_mask = 3, ocs.dcp_clin_cat_cd = clin_cat_cd,
         ocs.filtered_od_ind = null, ocs.cki = null, ocs.mnemonic_key_cap_nls = null,
         ocs.virtual_view = " ", ocs.health_plan_view = null, ocs.concept_cki = null,
         ocs.intermittent_ind = request->sets[x].intermittent_ind, ocs.updt_applctx = reqinfo->
         updt_applctx, ocs.updt_cnt = 0,
         ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
         .updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Unable to insert order set synonym: ",trim(request->sets[x].synonyms[y].mnemonic),
         " on the order_catalog_synonym table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->sets[x].synonyms[y].action_flag=2))
      IF (intermittent_search_ind=0)
       SET ierrcode = 0
       UPDATE  FROM order_catalog_synonym ocs
        SET ocs.mnemonic = request->sets[x].synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
          request->sets[x].synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->sets[x].synonyms[y]
         .mnemonic_type_code_value,
         ocs.active_ind = request->sets[x].synonyms[y].active_ind, ocs.orderable_type_flag =
         orderable_type_flag_value, ocs.active_status_cd =
         IF ((request->sets[x].synonyms[y].active_ind=1)) active_cd
         ELSE inactive_cd
         ENDIF
         ,
         ocs.active_status_dt_tm =
         IF ((request->sets[x].synonyms[y].active_ind != ocs.active_ind)) cnvtdatetime(curdate,
           curtime3)
         ELSE ocs.active_status_dt_tm
         ENDIF
         , ocs.active_status_prsnl_id =
         IF ((request->sets[x].synonyms[y].active_ind != ocs.active_ind)) reqinfo->updt_id
         ELSE ocs.active_status_prsnl_id
         ENDIF
         , ocs.updt_applctx = reqinfo->updt_applctx,
         ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs
         .updt_id = reqinfo->updt_id,
         ocs.updt_task = reqinfo->updt_task
        WHERE (ocs.synonym_id=request->sets[x].synonyms[y].synonym_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Unable to update order set synonym: ",trim(request->sets[x].synonyms[y].mnemonic),
         " on the order_catalog_synonym table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       UPDATE  FROM order_catalog_synonym ocs
        SET ocs.mnemonic = request->sets[x].synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
          request->sets[x].synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->sets[x].synonyms[y]
         .mnemonic_type_code_value,
         ocs.active_ind = request->sets[x].synonyms[y].active_ind, ocs.orderable_type_flag =
         orderable_type_flag_value, ocs.active_status_cd =
         IF ((request->sets[x].synonyms[y].active_ind=1)) active_cd
         ELSE inactive_cd
         ENDIF
         ,
         ocs.active_status_dt_tm =
         IF ((request->sets[x].synonyms[y].active_ind != ocs.active_ind)) cnvtdatetime(curdate,
           curtime3)
         ELSE ocs.active_status_dt_tm
         ENDIF
         , ocs.active_status_prsnl_id =
         IF ((request->sets[x].synonyms[y].active_ind != ocs.active_ind)) reqinfo->updt_id
         ELSE ocs.active_status_prsnl_id
         ENDIF
         , ocs.intermittent_ind = request->sets[x].intermittent_ind,
         ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_dt_tm
          = cnvtdatetime(curdate,curtime3),
         ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
        WHERE (ocs.synonym_id=request->sets[x].synonyms[y].synonym_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Unable to update order set synonym: ",trim(request->sets[x].synonyms[y].mnemonic),
         " on the order_catalog_synonym table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->sets[x].synonyms[y].mnemonic_type_code_value=primary_cd))
       SET cat_active_ind = 0
       SELECT INTO "nl:"
        FROM order_catalog oc
        WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
        DETAIL
         cat_active_ind = oc.active_ind
        WITH nocounter
       ;end select
       SET sd_row_exists = 0
       SELECT INTO "NL:"
        FROM service_directory sd
        WHERE (sd.catalog_cd=request->sets[x].catalog_code_value)
        WITH nocounter
       ;end select
       IF (curqual=1)
        SET sd_row_exists = 1
       ENDIF
       UPDATE  FROM order_catalog oc
        SET oc.primary_mnemonic = request->sets[x].synonyms[y].mnemonic, oc.updt_cnt = (oc.updt_cnt+
         1), oc.updt_id = reqinfo->updt_id,
         oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
         .updt_applctx = reqinfo->updt_applctx
        WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
        WITH nocounter
       ;end update
       UPDATE  FROM bill_item bi
        SET bi.ext_short_desc = substring(1,50,request->sets[x].synonyms[y].mnemonic), bi
         .ext_description = request->sets[x].description, bi.active_ind = 1,
         bi.active_status_cd = active_cd, bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_id = reqinfo->
         updt_id,
         bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task = reqinfo->updt_task, bi
         .updt_applctx = reqinfo->updt_applctx
        WHERE (bi.ext_parent_reference_id=request->sets[x].catalog_code_value)
         AND bi.parent_qual_cd=1.0
         AND bi.ext_parent_contributor_cd=ord_cd
         AND bi.ext_child_reference_id=0.0
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM bill_item bi
         SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
          sets[x].catalog_code_value, bi.ext_parent_contributor_cd = ord_cd,
          bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi
          .ext_child_reference_id = 0.0,
          bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
          request->sets[x].description,
          bi.ext_owner_cd = activity_type_cd, bi.ext_short_desc = substring(1,50,request->sets[x].
           synonyms[y].mnemonic), bi.active_ind = 1,
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
        SET cv.display = substring(1,40,request->sets[x].synonyms[y].mnemonic), cv.display_key =
         cnvtupper(cnvtalphanum(substring(1,40,request->sets[x].synonyms[y].mnemonic))), cv.updt_cnt
          = (cv.updt_cnt+ 1),
         cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task
          = reqinfo->updt_task,
         cv.updt_applctx = reqinfo->updt_applctx
        WHERE (code_value=request->sets[x].catalog_code_value)
        WITH nocounter
       ;end update
       IF (curr_ord_status=0
        AND (request->sets[x].synonyms[y].active_ind=1))
        UPDATE  FROM order_catalog oc
         SET oc.active_ind = 1, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id,
          oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
          .updt_applctx = reqinfo->updt_applctx
         WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
         WITH nocounter
        ;end update
        UPDATE  FROM bill_item bi
         SET bi.active_ind = 1, bi.active_status_cd = active_cd, bi.updt_cnt = (bi.updt_cnt+ 1),
          bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task
           = reqinfo->updt_task,
          bi.updt_applctx = reqinfo->updt_applctx
         WHERE (bi.ext_parent_reference_id=request->sets[x].catalog_code_value)
          AND bi.ext_parent_contributor_cd=ord_cd
          AND bi.ext_child_reference_id=0
          AND bi.ext_child_contributor_cd=0
          AND bi.child_seq=0
         WITH nocounter
        ;end update
        IF (curqual=0)
         INSERT  FROM bill_item bi
          SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
           sets[x].catalog_code_value, bi.ext_parent_contributor_cd = ord_cd,
           bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi
           .ext_child_reference_id = 0.0,
           bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
           trim(request->sets[x].description),
           bi.ext_owner_cd = activity_type_cd, bi.ext_short_desc = trim(substring(1,50,request->sets[
             x].synonyms[y].mnemonic)), bi.active_ind = 1,
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
          WHERE (sd.catalog_cd=request->sets[x].catalog_code_value)
          WITH nocounter
         ;end update
        ENDIF
        UPDATE  FROM code_value cv
         SET cv.active_ind = 1, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id,
          cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
          .updt_applctx = reqinfo->updt_applctx
         WHERE (code_value=request->sets[x].catalog_code_value)
        ;end update
        SET curr_ord_status = 1
       ENDIF
       IF ((request->sets[x].synonyms[y].active_ind=0)
        AND curr_ord_status=1)
        UPDATE  FROM order_catalog oc
         SET oc.active_ind = 0, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id,
          oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
          .updt_applctx = reqinfo->updt_applctx
         WHERE (oc.catalog_cd=request->sets[x].catalog_code_value)
         WITH nocounter
        ;end update
        UPDATE  FROM bill_item bi
         SET bi.active_ind = 0, bi.active_status_cd = inactive_cd, bi.updt_cnt = (bi.updt_cnt+ 1),
          bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task
           = reqinfo->updt_task,
          bi.updt_applctx = reqinfo->updt_applctx
         WHERE (bi.ext_parent_reference_id=request->sets[x].catalog_code_value)
          AND bi.active_ind=1
          AND bi.parent_qual_cd=1.0
          AND bi.ext_parent_contributor_cd=ord_cd
          AND bi.ext_child_reference_id=0.0
         WITH nocounter
        ;end update
        IF (sd_row_exists=1)
         UPDATE  FROM service_directory sd
          SET sd.updt_cnt = (sd.updt_cnt+ 1), sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm =
           cnvtdatetime(curdate,curtime),
           sd.updt_task = reqinfo->updt_task, sd.updt_applctx = reqinfo->updt_applctx
          WHERE (sd.catalog_cd=request->sets[x].catalog_code_value)
          WITH nocounter
         ;end update
        ENDIF
        UPDATE  FROM code_value cv
         SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id,
          cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
          .updt_applctx = reqinfo->updt_applctx
         WHERE (code_value=request->sets[x].catalog_code_value)
        ;end update
        SET curr_ord_status = 0
       ENDIF
      ENDIF
     ENDIF
     SET fcnt = size(request->sets[x].synonyms[y].facilities,5)
     IF (fcnt > 0)
      SET ierrcode = 0
      INSERT  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = value(fcnt))
       SET ofr.synonym_id = request->sets[x].synonyms[y].synonym_id, ofr.facility_cd = request->sets[
        x].synonyms[y].facilities[d.seq].code_value, ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       PLAN (d
        WHERE (request->sets[x].synonyms[y].facilities[d.seq].action_flag=1))
        JOIN (ofr)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Unable to insert order set synonyms "," on the ocs_facility_r table")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      DELETE  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = value(fcnt))
       SET ofr.seq = 1
       PLAN (d
        WHERE (request->sets[x].synonyms[y].facilities[d.seq].action_flag=3))
        JOIN (ofr
        WHERE (ofr.synonym_id=request->sets[x].synonyms[y].synonym_id)
         AND (ofr.facility_cd=request->sets[x].synonyms[y].facilities[d.seq].code_value))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Unable to delete order set synonyms "," from the ocs_facility_r table")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      DELETE  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = value(fcnt))
       SET ofr.seq = 1
       PLAN (d
        WHERE (request->sets[x].synonyms[y].facilities[d.seq].action_flag=1)
         AND (request->sets[x].synonyms[y].facilities[d.seq].code_value > 0))
        JOIN (ofr
        WHERE (ofr.synonym_id=request->sets[x].synonyms[y].synonym_id)
         AND ofr.facility_cd=0)
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Unable to delete order set synonyms "," default zero row from the ocs_facility_r table")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET icnt = size(request->sets[x].ingredients,5)
   IF (icnt > 0)
    SET ierrcode = 0
    DELETE  FROM order_sentence_detail o,
      (dummyt d  WITH seq = value(icnt))
     SET o.seq = 1
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id > 0)
       AND (((request->sets[x].ingredients[d.seq].order_sentence.action_flag IN (2, 3))) OR ((request
      ->sets[x].ingredients[d.seq].action_flag=3))) )
      JOIN (o
      WHERE (o.order_sentence_id=request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id
      ))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to delete ingredients "," from the order_sentence_detail table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM order_sentence o,
      (dummyt d  WITH seq = value(icnt))
     SET o.seq = 1
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id > 0)
       AND (request->sets[x].ingredients[d.seq].action_flag=3))
      JOIN (o
      WHERE (o.order_sentence_id=request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id
      ))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to delete ingredients "," from the order_sentence table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM long_text l,
      (dummyt d  WITH seq = value(icnt))
     SET l.seq = 1
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.comment_id > 0)
       AND (request->sets[x].ingredients[d.seq].action_flag=3))
      JOIN (l
      WHERE (l.long_text_id=request->sets[x].ingredients[d.seq].order_sentence.comment_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to delete ingredients "," from the long_text table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM cs_component c,
      (dummyt d  WITH seq = value(icnt))
     SET c.seq = 1
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].action_flag IN (2, 3)))
      JOIN (c
      WHERE (c.catalog_cd=request->sets[x].catalog_code_value)
       AND (c.comp_id=request->sets[x].ingredients[d.seq].synonym_id)
       AND c.comp_type_cd=cs_ord_cd)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to delete ingredients "," from the cs_component table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    FOR (a = 1 TO icnt)
     IF ((request->sets[x].ingredients[a].order_sentence.action_flag=1))
      SELECT INTO "nl:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        request->sets[x].ingredients[a].order_sentence.order_sentence_id = cnvtreal(j)
       WITH format, counter
      ;end select
     ENDIF
     IF ((request->sets[x].ingredients[a].order_sentence.comment_action_flag=1))
      SELECT INTO "nl:"
       j = seq(long_data_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        request->sets[x].ingredients[a].order_sentence.comment_id = cnvtreal(j)
       WITH format, counter
      ;end select
     ENDIF
    ENDFOR
    SET ierrcode = 0
    INSERT  FROM order_sentence o,
      (dummyt d  WITH seq = value(icnt))
     SET o.order_sentence_id = request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id,
      o.order_sentence_display_line = request->sets[x].ingredients[d.seq].order_sentence.display, o
      .oe_format_id = request->sets[x].ingredients[d.seq].order_sentence.oe_format_id,
      o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
      reqinfo->updt_task,
      o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = 1,
      o.order_encntr_group_cd = 0, o.ord_comment_long_text_id = request->sets[x].ingredients[d.seq].
      order_sentence.comment_id, o.parent_entity_name = "ORDER_CATALOG_SYNONYM",
      o.parent_entity_id = request->sets[x].ingredients[d.seq].synonym_id, o.parent_entity2_name =
      "ORDER_CATALOG", o.parent_entity2_id = request->sets[x].catalog_code_value,
      o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = ""
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.action_flag=1))
      JOIN (o)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT OS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM long_text l,
      (dummyt d  WITH seq = value(icnt))
     SET l.long_text_id = request->sets[x].ingredients[d.seq].order_sentence.comment_id, l.updt_id =
      reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime),
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
      l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
       curtime),
      l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
      .parent_entity_id = request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id,
      l.long_text = request->sets[x].ingredients[d.seq].order_sentence.comment_txt
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.comment_action_flag=1)
       AND (request->sets[x].ingredients[d.seq].order_sentence.comment_id > 0))
      JOIN (l)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT LT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM order_sentence o,
      (dummyt d  WITH seq = value(icnt))
     SET o.order_sentence_display_line = request->sets[x].ingredients[d.seq].order_sentence.display,
      o.oe_format_id = request->sets[x].ingredients[d.seq].order_sentence.oe_format_id, o.updt_id =
      reqinfo->updt_id,
      o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
       = reqinfo->updt_applctx,
      o.updt_cnt = (o.updt_cnt+ 1), o.usage_flag = 1, o.ord_comment_long_text_id = request->sets[x].
      ingredients[d.seq].order_sentence.comment_id,
      o.parent_entity_name = "ORDER_CATALOG_SYNONYM", o.parent_entity_id = request->sets[x].
      ingredients[d.seq].synonym_id, o.parent_entity2_name = "ORDER_CATALOG",
      o.parent_entity2_id = request->sets[x].catalog_code_value, o.ic_auto_verify_flag = 0, o
      .discern_auto_verify_flag = 0
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.action_flag=2))
      JOIN (o
      WHERE (o.order_sentence_id=request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id
      ))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE OS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM long_text l,
      (dummyt d  WITH seq = value(icnt))
     SET l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_task =
      reqinfo->updt_task,
      l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1), l.long_text = request->
      sets[x].ingredients[d.seq].order_sentence.comment_txt
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.comment_action_flag=2)
       AND (request->sets[x].ingredients[d.seq].order_sentence.comment_id > 0))
      JOIN (l
      WHERE (l.long_text_id=request->sets[x].ingredients[d.seq].order_sentence.comment_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE LT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM cs_component cc,
      (dummyt d  WITH seq = value(icnt))
     SET cc.order_sentence_id = 0, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = (cc
      .updt_cnt+ 1),
      cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.action_flag=3))
      JOIN (cc
      WHERE (cc.catalog_cd=request->sets[x].catalog_code_value)
       AND (cc.comp_id=request->sets[x].ingredients[d.seq].synonym_id)
       AND cc.comp_type_cd=cs_ord_cd)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to update ingredients "," on the cs_component table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM cs_component cc,
      (dummyt d  WITH seq = value(icnt))
     SET cc.order_sentence_id = request->sets[x].ingredients[d.seq].order_sentence.order_sentence_id,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = (cc.updt_cnt+ 1),
      cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (request->sets[x].ingredients[d.seq].order_sentence.action_flag=1)
       AND (request->sets[x].ingredients[d.seq].synonym_id > 0))
      JOIN (cc
      WHERE (cc.catalog_cd=request->sets[x].catalog_code_value)
       AND (cc.comp_id=request->sets[x].ingredients[d.seq].synonym_id)
       AND cc.comp_type_cd=cs_ord_cd)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to update ingredients "," on the cs_component table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (i = 1 TO icnt)
     SET cc_seq = 0
     SET format_id = 0.0
     SET af_id = 0.0
     SET inact_bill_id = 0.0
     SET inact_description = fillstring(100," ")
     SET inact_mnemonic = fillstring(100," ")
     SET inact_act_type = 0.0
     IF ((request->sets[x].ingredients[i].action_flag IN (1, 2)))
      SELECT INTO "nl:"
       FROM order_entry_format o
       PLAN (o
        WHERE o.oe_format_name="IV Ingredient")
       DETAIL
        af_id = o.oe_format_id
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs,
        order_catalog oc,
        bill_item b
       PLAN (ocs
        WHERE (ocs.synonym_id=request->sets[x].ingredients[i].synonym_id))
        JOIN (oc
        WHERE oc.catalog_cd=ocs.catalog_cd)
        JOIN (b
        WHERE b.ext_child_reference_id=ocs.catalog_cd
         AND (b.ext_parent_reference_id=request->sets[x].catalog_code_value)
         AND b.active_ind=0)
       ORDER BY b.child_seq
       DETAIL
        inact_bill_id = b.bill_item_id, inact_description = oc.description, inact_mnemonic = oc
        .primary_mnemonic,
        inact_act_type = ocs.activity_type_cd
        IF (band(ocs.rx_mask,1)=1)
         format_id = ocs.oe_format_id
        ELSE
         format_id = af_id
        ENDIF
       WITH nocounter, maxrec = 1
      ;end select
      IF (inact_bill_id > 0)
       SET ierrcode = 0
       UPDATE  FROM bill_item b
        SET b.active_ind = 1, b.ext_description = trim(inact_description), b.ext_owner_cd =
         inact_act_type,
         b.ext_short_desc = trim(substring(1,50,inact_mnemonic)), b.active_status_cd = active_cd, b
         .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_applctx = reqinfo->updt_applctx,
         b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
        PLAN (b
         WHERE b.bill_item_id=inact_bill_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = build(
         "Unable to update ingredient: ",request->sets[x].ingredients[i].synonym_id,
         " to the bill_item table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET sequence = 0
       SELECT INTO "nl:"
        temp_seq = max(b.child_seq)
        FROM bill_item b,
         order_catalog_synonym o
        PLAN (o
         WHERE (o.synonym_id=request->sets[x].ingredients[i].synonym_id))
         JOIN (b
         WHERE b.ext_child_reference_id=o.catalog_cd
          AND (b.ext_parent_reference_id=request->sets[x].catalog_code_value))
        DETAIL
         sequence = temp_seq
        WITH nocounter
       ;end select
       SET catalog_code_value = 0.0
       SET syn_description = fillstring(100," ")
       SET syn_mnemonic = fillstring(100," ")
       SET syn_act_type = 0.0
       SELECT INTO "nl:"
        FROM order_catalog_synonym ocs,
         order_catalog oc
        PLAN (ocs
         WHERE (ocs.synonym_id=request->sets[x].ingredients[i].synonym_id))
         JOIN (oc
         WHERE oc.catalog_cd=ocs.catalog_cd)
        DETAIL
         catalog_code_value = ocs.catalog_cd, syn_mnemonic = oc.primary_mnemonic, syn_description =
         oc.description,
         syn_act_type = ocs.activity_type_cd
         IF (band(ocs.rx_mask,1)=1)
          format_id = ocs.oe_format_id
         ELSE
          format_id = af_id
         ENDIF
        WITH nocounter
       ;end select
       SET new_bill_id = 0.0
       SELECT INTO "NL:"
        j = seq(bill_item_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_bill_id = cnvtreal(j)
        WITH format, counter
       ;end select
       INSERT  FROM bill_item b
        SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->sets[x].
         catalog_code_value, b.ext_parent_contributor_cd = ord_cd,
         b.ext_child_reference_id = catalog_code_value, b.ext_child_contributor_cd = ord_cd, b
         .ext_description = trim(syn_description),
         b.ext_owner_cd = syn_act_type, b.parent_qual_cd = 1, b.charge_point_cd = 0,
         b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
         b.ext_short_desc = trim(substring(1,50,syn_mnemonic)), b.ext_parent_entity_name =
         "CODE_VALUE", b.ext_child_entity_name = "CODE_VALUE",
         b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
         b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = (sequence+ 1),
         b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
         b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
         updt_applctx,
         b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
         b.active_status_cd = active_cd, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b
         .active_status_prsnl_id = reqinfo->updt_id,
         b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime
         ("31-DEC-2100")
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = build(
         "Unable to insert ingredient: ",request->sets[x].ingredients[i].synonym_id,
         " to the bill_item table")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     IF ((request->sets[x].ingredients[i].order_sentence.action_flag IN (1, 2)))
      SET fsize = size(request->sets[x].ingredients[i].order_sentence.details,5)
      SET stat = initrec(fields)
      SET stat = alterlist(fields->fields,fsize)
      IF (fsize > 0)
       SELECT INTO "nl:"
        a = request->sets[x].ingredients[i].order_sentence.details[d.seq].group_seq, b = request->
        sets[x].ingredients[i].order_sentence.details[d.seq].field_seq
        FROM (dummyt d  WITH seq = value(fsize)),
         order_entry_fields o
        PLAN (d)
         JOIN (o
         WHERE (o.oe_field_id=request->sets[x].ingredients[i].order_sentence.details[d.seq].
         oe_field_id))
        ORDER BY a, b
        HEAD REPORT
         cnt = 0
        DETAIL
         cnt = (cnt+ 1), fields->fields[cnt].field_code_value = request->sets[x].ingredients[i].
         order_sentence.details[d.seq].field_code_value, fields->fields[cnt].field_disp_value =
         request->sets[x].ingredients[i].order_sentence.details[d.seq].field_disp_value,
         fields->fields[cnt].field_type_flag = request->sets[x].ingredients[i].order_sentence.
         details[d.seq].field_type_flag, fields->fields[cnt].oe_field_id = request->sets[x].
         ingredients[i].order_sentence.details[d.seq].oe_field_id, fields->fields[cnt].meaning_id = o
         .oe_field_meaning_id,
         fields->fields[cnt].seq = cnt, fields->fields[cnt].sent_id = request->sets[x].ingredients[i]
         .order_sentence.order_sentence_id
        WITH nocounter
       ;end select
       FOR (y = 1 TO fsize)
         IF ((fields->fields[y].field_type_flag IN (0, 1, 2, 3, 5,
         7, 11, 14, 15)))
          SET fields->fields[y].dname = " "
          SET fields->fields[y].dvalue = 0
          IF ((fields->fields[y].field_type_flag=5))
           SET fields->fields[y].field_code_value = - (99999)
          ELSEIF ((fields->fields[y].field_type_flag=7)
           AND (fields->fields[y].field_disp_value="Yes"))
           SET fields->fields[y].field_code_value = 1
          ENDIF
         ELSEIF ((fields->fields[y].field_type_flag IN (6, 9)))
          SET fields->fields[y].dname = "CODE_VALUE"
          SET fields->fields[y].dvalue = fields->fields[y].field_code_value
         ELSEIF ((fields->fields[y].field_type_flag=12))
          IF ((fields->fields[y].meaning_id=48))
           SET fields->fields[y].dname = "RESEARCH_ACCOUNT"
          ELSEIF ((fields->fields[y].meaning_id=123))
           SET fields->fields[y].dname = "SCH_BOOK_INSTR"
          ELSE
           SET fields->fields[y].dname = "CODE_VALUE"
          ENDIF
          SET fields->fields[y].dvalue = fields->fields[y].field_code_value
         ELSEIF ((fields->fields[y].field_type_flag IN (8, 13)))
          SET fields->fields[y].dname = "PERSON"
          SET fields->fields[y].dvalue = fields->fields[y].field_code_value
         ELSEIF ((fields->fields[y].field_type_flag=10))
          SET fields->fields[y].dname = "NOMENCLATURE"
          SET fields->fields[y].dvalue = fields->fields[y].field_code_value
         ENDIF
       ENDFOR
       SET ierrcode = 0
       INSERT  FROM order_sentence_detail o,
         (dummyt d  WITH seq = value(fsize))
        SET o.order_sentence_id = fields->fields[d.seq].sent_id, o.sequence = fields->fields[d.seq].
         seq, o.oe_field_value = fields->fields[d.seq].field_code_value,
         o.oe_field_id = fields->fields[d.seq].oe_field_id, o.oe_field_display_value = fields->
         fields[d.seq].field_disp_value, o.oe_field_meaning_id = fields->fields[d.seq].meaning_id,
         o.field_type_flag = fields->fields[d.seq].field_type_flag, o.updt_id = reqinfo->updt_id, o
         .updt_dt_tm = cnvtdatetime(curdate,curtime),
         o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
         o.default_parent_entity_name = fields->fields[d.seq].dname, o.default_parent_entity_id =
         fields->fields[d.seq].dvalue
        PLAN (d)
         JOIN (o)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT OSD"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (icnt > 0)
    SET lock_exists = 0
    IF (validate(request->sets[x].ingredients[1].lock_details_flag))
     SET lock_exists = 1
    ENDIF
    SET auto_exists = 0
    IF (validate(request->sets[x].ingredients[1].auto_verification_optional_ind))
     SET auto_exists = 1
    ENDIF
    IF (lock_exists=1
     AND auto_exists=1)
     SET ierrcode = 0
     INSERT  FROM cs_component cc,
       (dummyt d  WITH seq = value(icnt))
      SET cc.catalog_cd = request->sets[x].catalog_code_value, cc.comp_seq = request->sets[x].
       ingredients[d.seq].sequence, cc.comp_type_cd = cs_ord_cd,
       cc.comp_id = request->sets[x].ingredients[d.seq].synonym_id, cc.long_text_id = 0, cc
       .required_ind = 0,
       cc.include_exclude_ind = 1, cc.comp_label = " ", cc.order_sentence_id = request->sets[x].
       ingredients[d.seq].order_sentence.order_sentence_id,
       cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
       cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
       cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
       cc.comp_mask = null, cc.comp_reference = null, cc.lockdown_details_flag = request->sets[x].
       ingredients[d.seq].lock_details_flag,
       cc.av_optional_ingredient_ind = request->sets[x].ingredients[d.seq].
       auto_verification_optional_ind, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
       cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (request->sets[x].ingredients[d.seq].action_flag IN (1, 2)))
       JOIN (cc)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = build(
       "Unable to insert ingredients "," to the cs_component table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ELSE
     SET ierrcode = 0
     INSERT  FROM cs_component cc,
       (dummyt d  WITH seq = value(icnt))
      SET cc.catalog_cd = request->sets[x].catalog_code_value, cc.comp_seq = request->sets[x].
       ingredients[d.seq].sequence, cc.comp_type_cd = cs_ord_cd,
       cc.comp_id = request->sets[x].ingredients[d.seq].synonym_id, cc.long_text_id = 0, cc
       .required_ind = 0,
       cc.include_exclude_ind = 1, cc.comp_label = " ", cc.order_sentence_id = request->sets[x].
       ingredients[d.seq].order_sentence.order_sentence_id,
       cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
       cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
       cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
       cc.comp_mask = null, cc.comp_reference = null, cc.lockdown_details_flag = 0,
       cc.av_optional_ingredient_ind = 0, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
       cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (request->sets[x].ingredients[d.seq].action_flag IN (1, 2)))
       JOIN (cc)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = build(
       "Unable to insert ingredients "," to the cs_component table")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET stat = alterlist(reply->status_data.subeventstatus,0)
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
