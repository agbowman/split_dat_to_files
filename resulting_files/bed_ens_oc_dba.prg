CREATE PROGRAM bed_ens_oc:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET overall_error_flag = "N"
 SET one_success = 0
 DECLARE fdsyncd = f8 WITH protect, noconstant(0.0)
 SET dept_name = fillstring(100," ")
 SET concept_cki = fillstring(255," ")
 SET cki = fillstring(255," ")
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
 SET ignore_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6001
   AND cv.cdf_meaning="IGNORE"
  DETAIL
   ignore_cd = cv.code_value
  WITH nocounter
 ;end select
 SET active_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET primary_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET auth_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET surgery_cat_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SURGERY"
   AND cv.active_ind=1
  DETAIL
   surgery_cat_value = cv.code_value
  WITH nocounter
 ;end select
 SET orc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->status_data.subeventstatus,orc_cnt)
 SET stat = alterlist(reply->oc_list,orc_cnt)
 FOR (x = 1 TO orc_cnt)
   IF ((request->oc_list[x].dept_name > " "))
    SET dept_name = trim(request->oc_list[x].dept_name)
   ELSE
    SET dept_name = trim(request->oc_list[x].primary_name)
   ENDIF
   IF (validate(request->oc_list[x].concept_cki))
    SET concept_cki = trim(request->oc_list[x].concept_cki)
   ELSE
    SET concept_cki = fillstring(255," ")
   ENDIF
   IF (validate(request->oc_list[x].cki))
    SET cki = trim(request->oc_list[x].cki)
   ELSE
    SET cki = fillstring(255," ")
   ENDIF
   SET error_flag = "N"
   SET reply->status_data.subeventstatus[x].operationname = "ENS"
   SET reply->status_data.subeventstatus[x].targetobjectname = "BED_ENS_OC"
   SET reply->oc_list[x].catalog_code_value = request->oc_list[x].catalog_code_value
   IF ((request->oc_list[x].action_flag=1))
    SET new_cv = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_cv = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM code_value cv
     SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
      cv.display = trim(substring(1,40,request->oc_list[x].primary_name)), cv.display_key = trim(
       cnvtupper(cnvtalphanum(substring(1,40,request->oc_list[x].primary_name)))), cv.description =
      IF ((request->oc_list[x].description > "   *")) trim(substring(1,60,request->oc_list[x].
         description))
      ELSE trim(substring(1,60,request->oc_list[x].primary_name))
      ENDIF
      ,
      cv.concept_cki =
      IF (concept_cki > " ") concept_cki
      ELSE " "
      ENDIF
      , cv.cki =
      IF (cki > " ") cki
      ELSE " "
      ENDIF
      , cv.data_status_cd = auth_code_value,
      cv.active_type_cd = active_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx,
      cv.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET clin_cat_cd = 0.0
    SET clin_cat_cd = request->oc_list[x].clin_cat_code_value
    IF (curqual > 0)
     SET reply->oc_list[x].catalog_code_value = new_cv
     INSERT  FROM order_catalog o
      SET o.catalog_cd = new_cv, o.active_ind = 1, o.description =
       IF ((request->oc_list[x].description > "   *")) trim(request->oc_list[x].description)
       ELSE trim(request->oc_list[x].primary_name)
       ENDIF
       ,
       o.primary_mnemonic = trim(request->oc_list[x].primary_name), o.dept_display_name = dept_name,
       o.catalog_type_cd = request->oc_list[x].catalog_type_code_value,
       o.activity_type_cd = request->oc_list[x].activity_type_code_value, o.activity_subtype_cd =
       request->oc_list[x].subactivity_type_code_value, o.oe_format_id = request->oc_list[x].
       oe_format_id,
       o.orderable_type_flag =
       IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
       ELSE 0
       ENDIF
       , o.dcp_clin_cat_cd = clin_cat_cd, o.schedule_ind = request->oc_list[x].schedule_ind,
       o.dup_checking_ind = request->oc_list[x].duplicate_ind, o.consent_form_ind = 0, o
       .inst_restriction_ind = 0,
       o.print_req_ind = 0, o.quick_chart_ind = 0, o.complete_upon_order_ind = 0,
       o.comment_template_flag = 0, o.bill_only_ind = 0, o.cont_order_method_flag = 0,
       o.order_review_ind = 0, o.ref_text_mask = 0, o.cki =
       IF (cki > " ") cki
       ELSE null
       ENDIF
       ,
       o.concept_cki =
       IF (concept_cki > " ") concept_cki
       ELSE null
       ENDIF
       , o.form_level = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_cnt = 0,
       o.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[x].targetobjectvalue = concat(reply->status_data.
       subeventstatus[x].targetobjectvalue,">>","Unable to insert ",trim(request->oc_list[x].
        primary_name)," into the order_catalog table.")
     ELSE
      SET one_success = 1
     ENDIF
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       fdsyncd = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (fdsyncd > 0)
      INSERT  FROM order_catalog_synonym ocs
       SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = request->oc_list[x].clin_cat_code_value, ocs
        .synonym_id = fdsyncd,
        ocs.catalog_cd = new_cv, ocs.order_sentence_id = 0, ocs.catalog_type_cd = request->oc_list[x]
        .catalog_type_code_value,
        ocs.activity_type_cd = request->oc_list[x].activity_type_code_value, ocs.activity_subtype_cd
         = request->oc_list[x].subactivity_type_code_value, ocs.oe_format_id = request->oc_list[x].
        oe_format_id,
        ocs.mnemonic = trim(request->oc_list[x].primary_name), ocs.mnemonic_key_cap = cnvtupper(
         request->oc_list[x].primary_name), ocs.mnemonic_type_cd = primary_code_value,
        ocs.active_ind = 1, ocs.orderable_type_flag =
        IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
        ELSE 0
        ENDIF
        , ocs.hide_flag = 0,
        ocs.cki = " ", ocs.ref_text_mask = 0, ocs.virtual_view = " ",
        ocs.health_plan_view = " ", ocs.concentration_volume = 0, ocs.concentration_volume_unit_cd =
        0,
        ocs.concentration_strength = 0, ocs.concentration_strength_unit_cd = 0, ocs.active_status_cd
         = active_code_value,
        ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id =
        reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx =
        reqinfo->updt_applctx,
        ocs.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[x].targetobjectvalue = concat(reply->status_data.
        subeventstatus[x].targetobjectvalue,">>","Unable to insert ",trim(request->oc_list[x].
         primary_name)," into the order_catalog_synonym table.")
      ELSE
       SET one_success = 1
       INSERT  FROM ocs_facility_r ofr
        SET ofr.synonym_id = fdsyncd, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->updt_applctx,
         ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
         updt_id,
         ofr.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
     ELSE
      SET reply->status_data.subeventstatus[x].targetobjectvalue = concat(reply->status_data.
       subeventstatus[x].targetobjectvalue,">>","Unable to assign synonym_id for ",trim(request->
        oc_list[x].primary_name))
     ENDIF
     IF ((request->oc_list[x].dept_name > " "))
      INSERT  FROM service_directory l
       SET l.short_description = trim(request->oc_list[x].dept_name), l.description = trim(request->
         oc_list[x].dept_name), l.catalog_cd = new_cv,
        l.synonym_id = 0, l.active_ind = 1, l.active_status_cd = active_code_value,
        l.bb_processing_cd = request->oc_list[x].procedure_type_code_value, l.bb_default_phases_cd =
        0, l.active_status_prsnl_id = reqinfo->updt_id,
        l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.beg_effective_dt_tm = cnvtdatetime(
         curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
        l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_cnt = 0,
        l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[x].targetobjectvalue = concat(reply->status_data.
        subeventstatus[x].targetobjectvalue,">>","Unable to insert ",trim(request->oc_list[x].
         primary_name)," into the service_directory table.")
      ELSE
       SET one_success = 1
      ENDIF
     ENDIF
     IF ((request->oc_list[x].duplicate_ind=1))
      SET dcnt = 0
      SET dcnt = size(request->oc_list[x].dlist,5)
      FOR (d = 1 TO dcnt)
        INSERT  FROM dup_checking dc
         SET dc.catalog_cd = new_cv, dc.dup_check_seq = request->oc_list[x].dlist[d].dup_check_level,
          dc.min_behind = request->oc_list[x].dlist[d].look_behind_minutes,
          dc.min_behind_action_cd = request->oc_list[x].dlist[d].look_behind_action_code_value, dc
          .min_ahead = request->oc_list[x].dlist[d].look_ahead_minutes, dc.min_ahead_action_cd =
          request->oc_list[x].dlist[d].look_ahead_action_code_value,
          dc.active_ind = 1, dc.updt_dt_tm = cnvtdatetime(curdate,curtime), dc.updt_id = reqinfo->
          updt_id,
          dc.updt_task = reqinfo->updt_task, dc.updt_cnt = 0, dc.updt_applctx = reqinfo->updt_applctx,
          dc.exact_hit_action_cd = request->oc_list[x].dlist[d].exact_match_action_code_value, dc
          .outpat_exact_hit_action_cd = ignore_cd, dc.outpat_flex_ind = 0,
          dc.outpat_min_ahead = 0, dc.outpat_min_ahead_action_cd = ignore_cd, dc.outpat_min_behind =
          0,
          dc.outpat_min_behind_action_cd = ignore_cd
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
     IF ((request->oc_list[x].schedule_ind=1))
      SET scnt = 0
      SET scnt = size(request->oc_list[x].slist,5)
      FOR (s = 1 TO scnt)
        SET ent_rel_id = 0.0
        SELECT INTO "nl:"
         z = seq(carenet_seq,nextval)
         FROM dual
         DETAIL
          ent_rel_id = cnvtreal(z)
         WITH format, nocounter
        ;end select
        INSERT  FROM dcp_entity_reltn der
         SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = "ORC/SCHENCTP", der
          .entity1_id = new_cv,
          der.entity1_display = null, der.entity2_id = request->oc_list[x].slist[s].
          pat_type_code_value, der.entity2_display = null,
          der.rank_sequence = 0, der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(curdate,
           curtime3),
          der.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), der.updt_dt_tm =
          cnvtdatetime(curdate,curtime), der.updt_id = reqinfo->updt_id,
          der.updt_task = reqinfo->updt_task, der.updt_cnt = 0, der.updt_applctx = reqinfo->
          updt_applctx,
          der.entity1_name = "CODE_VALUE", der.entity2_name = "CODE_VALUE"
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
     IF ((request->oc_list[x].filter_ind=1))
      SET scnt = 0
      SET scnt = size(request->oc_list[x].flist,5)
      FOR (s = 1 TO scnt)
        SET ent_rel_id = 0.0
        SELECT INTO "nl:"
         z = seq(carenet_seq,nextval)
         FROM dual
         DETAIL
          ent_rel_id = cnvtreal(z)
         WITH format, nocounter
        ;end select
        INSERT  FROM dcp_entity_reltn der
         SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = request->oc_list[x].flist[
          s].entity_reltn_mean, der.entity1_id = new_cv,
          der.entity1_display = request->oc_list[x].primary_name, der.entity2_id = request->oc_list[x
          ].flist[s].entity2_id, der.entity2_display = request->oc_list[x].flist[s].entity2_display,
          der.rank_sequence = request->oc_list[x].flist[s].rank_sequence, der.active_ind = 1, der
          .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          der.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), der.updt_dt_tm =
          cnvtdatetime(curdate,curtime), der.updt_id = reqinfo->updt_id,
          der.updt_task = reqinfo->updt_task, der.updt_cnt = 0, der.updt_applctx = reqinfo->
          updt_applctx,
          der.entity1_name = "ORDER_CATALOG", der.entity2_name = "CODE_VALUE"
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = new_cv, b
       .ext_parent_contributor_cd = ord_cat_value,
       b.ext_parent_entity_name = "CODE_VALUE", b.parent_qual_cd = 1.0, b.ext_child_reference_id =
       0.0,
       b.ext_child_contributor_cd = 0.0, b.ext_child_entity_name = null, b.ext_description =
       IF ((request->oc_list[x].description > "   *")) trim(request->oc_list[x].description)
       ELSE trim(request->oc_list[x].primary_name)
       ENDIF
       ,
       b.ext_owner_cd = request->oc_list[x].activity_type_code_value, b.ext_short_desc = substring(1,
        50,request->oc_list[x].primary_name), b.active_ind = 1,
       b.active_status_cd = active_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       b.active_status_prsnl_id = reqinfo->updt_id,
       b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
       b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value))
      INSERT  FROM surgical_procedure s
       SET s.catalog_cd = new_cv, s.def_proc_dur = null, s.surg_specialty_id = 0,
        s.def_wound_class_cd = 0, s.def_case_level_cd = 0, s.spec_req_ind = null,
        s.frozen_section_req_ind = null, s.def_anesth_type_cd = 0, s.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
        updt_applctx,
        s.updt_cnt = 0, s.create_dt_tm = null, s.create_prsnl_id = 0,
        s.create_task = null, s.create_applctx = null, s.setup_time = 0,
        s.cleanup_time = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].description),
        " into surgical_procedure.")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[x].targetobjectvalue = concat(reply->status_data.
      subeventstatus[x].targetobjectvalue,">>","Unable to insert ",trim(request->oc_list[x].
       primary_name)," into CodeSet 200.")
    ENDIF
   ENDIF
   SET trace = norecpersist
   IF (error_flag="N")
    SET reply->status_data.subeventstatus[x].operationstatus = "S"
   ELSE
    SET reply->status_data.subeventstatus[x].operationstatus = "F"
    SET overall_error_flag = "Y"
   ENDIF
 ENDFOR
#exit_script
 IF (overall_error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (overall_error_flag="Y")
  IF (one_success=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "P"
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
