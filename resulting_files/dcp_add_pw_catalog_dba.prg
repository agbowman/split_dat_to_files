CREATE PROGRAM dcp_add_pw_catalog:dba
 RECORD reply(
   1 pathway_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 DECLARE idpathway = f8
 DECLARE idlongtext = f8
 DECLARE idtimeframe = f8
 DECLARE idcarecategory = f8
 DECLARE idcomponent = f8
 SET idpathway = 0
 SET idlongtext = 0
 SET idtimeframe = 0
 SET idcarecategory = 0
 SET idcomponent = 0
 DECLARE pw_text_id = f8
 DECLARE comp_text_id = f8
 DECLARE cond_note_id = f8
 DECLARE ent_rel_id = f8
 DECLARE ptf_id = f8
 DECLARE ptf_seq = f8
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pw_text_id = 0
 SET comp_text_id = 0
 SET cond_note_id = 0
 SET ent_rel_id = 0
 SET ptf_id = 0
 SET ptf_seq = 0
 SET parent_entity_name = fillstring(32," ")
 SET pw_focus_id = 0.0
 SET nomvar = 0
 SET code_set = 16750
 SET cdf_meaning = "NOTE"
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "ORDER CREATE"
 EXECUTE cpm_get_cd_for_cdf
 SET order_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "LABEL"
 EXECUTE cpm_get_cd_for_cdf
 SET label_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "OUTCOME CREA"
 EXECUTE cpm_get_cd_for_cdf
 SET outcome_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "TASK CREATE"
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "RESULT OUTCO"
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   request->pathway_id = nextseqnum
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 IF ((request->pw_text != null))
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    pw_text_id = nextseqnum
   WITH format
  ;end select
  IF (pw_text_id=0.0)
   GO TO text_seq_failed
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = pw_text_id, lt.parent_entity_name = "PATHWAY_CATALOG", lt.parent_entity_id
     = request->pathway_id,
    lt.long_text = request->pw_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO text_failed
  ENDIF
 ENDIF
 INSERT  FROM pathway_catalog pc
  SET pc.pathway_catalog_id = request->pathway_id, pc.active_ind = request->active_ind, pc
   .cross_encntr_ind = request->cross_encntr_ind,
   pc.description = trim(request->description), pc.description_key = trim(cnvtupper(request->
     description)), pc.age_units_cd = request->age_units_cd,
   pc.long_text_id = pw_text_id, pc.version = 1, pc.version_pw_cat_id = 0.0,
   pc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.end_effective_dt_tm = cnvtdatetime(
    "31-Dec-2100"), pc.restrict_comp_add_ind = request->restrict_comp_add_ind,
   pc.restrict_tf_add_ind = request->restrict_tf_add_ind, pc.restrict_cc_add_ind = request->
   restrict_cc_add_ind, pc.pw_forms_ref_id = request->pw_forms_ref_id,
   pc.comp_forms_ref_id = request->comp_forms_ref_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pc.updt_id = reqinfo->updt_id,
   pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO pc_failed
 ENDIF
 FOR (x = 1 TO request->relationship_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     ent_rel_id = nextseqnum
    WITH format
   ;end select
   IF (curqual=0)
    GO TO der_seq_failed
   ENDIF
   INSERT  FROM dcp_entity_reltn der
    SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = request->relationship_mean, der
     .entity1_id = request->pathway_id,
     der.entity1_display = request->description, der.entity2_id = request->qual_relationship[x].
     entity_id, der.entity2_display = request->qual_relationship[x].entity_description,
     der.rank_sequence = 0, der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(curdate,
      curtime3),
     der.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), der.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), der.updt_id = reqinfo->updt_id,
     der.updt_task = reqinfo->updt_task, der.updt_applctx = reqinfo->updt_applctx, der.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO der_failed
   ENDIF
 ENDFOR
 FOR (x = 1 TO request->time_frame_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    request->qual_time_frame[x].time_frame_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO tf_seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO request->time_frame_cnt)
   SET ptf_seq = request->qual_time_frame[x].parent_tf_seq
   IF (ptf_seq > 0
    AND (ptf_seq <= request->time_frame_cnt))
    FOR (y = 1 TO request->time_frame_cnt)
      IF ((ptf_seq=request->qual_time_frame[y].sequence))
       SET ptf_id = request->qual_time_frame[y].time_frame_id
      ENDIF
    ENDFOR
   ELSE
    SET ptf_id = 0
   ENDIF
   INSERT  FROM time_frame tf
    SET tf.time_frame_id = request->qual_time_frame[x].time_frame_id, tf.description = request->
     qual_time_frame[x].description, tf.pathway_catalog_id = request->pathway_id,
     tf.sequence = request->qual_time_frame[x].sequence, tf.active_ind = 1, tf.duration_qty = request
     ->qual_time_frame[x].duration_qty,
     tf.age_units_cd = request->qual_time_frame[x].age_units_cd, tf.continuous_ind = request->
     qual_time_frame[x].continuous_ind, tf.start_ind = request->qual_time_frame[x].start_ind,
     tf.end_ind = request->qual_time_frame[x].end_ind, tf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     tf.updt_id = reqinfo->updt_id,
     tf.updt_task = reqinfo->updt_task, tf.updt_applctx = reqinfo->updt_applctx, tf.updt_cnt = 0,
     tf.prnt_time_frame_id = ptf_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO tf_failed
   ENDIF
 ENDFOR
 FOR (x = 1 TO request->nomen_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     pw_focus_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO pf_seq_failed
   ENDIF
   INSERT  FROM pathway_focus pf
    SET pf.pathway_focus_id = pw_focus_id, pf.pathway_level_ind = request->qual_nomen[x].
     pathway_level_ind, pf.sequence = request->qual_nomen[x].sequence,
     pf.pathway_catalog_id = request->pathway_id, pf.nomenclature_id = request->qual_nomen[x].
     nomenclature_id, pf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pf.updt_id = reqinfo->updt_id, pf.updt_task = reqinfo->updt_task, pf.updt_applctx = reqinfo->
     updt_applctx,
     pf.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO pf_failed
   ENDIF
 ENDFOR
 FOR (x = 1 TO request->care_category_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     request->qual_care_category[x].care_category_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO cc_seq_failed
   ENDIF
   INSERT  FROM care_category cc
    SET cc.care_category_id = request->qual_care_category[x].care_category_id, cc.care_category_cd =
     request->qual_care_category[x].care_category_cd, cc.description = request->qual_care_category[x]
     .description,
     cc.pathway_catalog_id = request->pathway_id, cc.sequence = request->qual_care_category[x].
     sequence, cc.restrict_comp_add_ind = request->qual_care_category[x].restrict_comp_add_ind,
     cc.comp_add_variance_ind = request->qual_care_category[x].comp_add_variance_ind, cc.active_ind
      = 1, cc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cc.updt_id = reqinfo->updt_id, cc.updt_task = reqinfo->updt_task, cc.updt_applctx = reqinfo->
     updt_applctx,
     cc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO cc_failed
   ENDIF
 ENDFOR
 FOR (x = 1 TO request->component_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     request->qual_component[x].component_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO comp_seq_failed
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="NOTE"))
    IF ((request->qual_component[x].comp_text != null))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       comp_text_id = nextseqnum
      WITH format
     ;end select
     IF (comp_text_id=0.0)
      GO TO comp_text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = comp_text_id, lt.parent_entity_name = "PATHWAY_COMP", lt.parent_entity_id
        = request->qual_component[x].component_id,
       lt.long_text = request->qual_component[x].comp_text, lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO comp_text_failed
     ENDIF
    ENDIF
   ENDIF
   IF ((request->qual_component[x].cond_ind=1))
    IF ((request->qual_component[x].cond_note != null))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       cond_note_id = nextseqnum
      WITH format
     ;end select
     IF (cond_note_id=0.0)
      GO TO comp_text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = cond_note_id, lt.parent_entity_name = "PATHWAY_COMP", lt.parent_entity_id
        = request->qual_component[x].component_id,
       lt.long_text = request->qual_component[x].cond_note, lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO comp_text_failed
     ENDIF
    ENDIF
   ENDIF
   SET parent_entity_name = fillstring(32," ")
   SET parent_entity_id = 0.0
   SET comp_type_cd = 0.0
   IF ((request->qual_component[x].comp_type_mean="NOTE"))
    SET parent_entity_name = "LONG_TEXT"
    SET parent_entity_id = comp_text_id
    SET comp_type_cd = note_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="ORDER CREATE"))
    SET parent_entity_name = "ORDER_CATALOG_SYNONYM"
    SET parent_entity_id = request->qual_component[x].synonym_id
    SET comp_type_cd = order_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="OUTCOME CREA"))
    SET parent_entity_name = "ORDER_CATALOG_SYNONYM"
    SET parent_entity_id = request->qual_component[x].synonym_id
    SET comp_type_cd = outcome_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="TASK CREATE"))
    SET parent_entity_name = "ORDER_TASK"
    SET parent_entity_id = request->qual_component[x].reference_task_id
    SET comp_type_cd = task_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="RESULT OUTCO"))
    SET comp_type_cd = result_outcome_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="LABEL"))
    SET comp_type_cd = label_type_cd
   ENDIF
   FOR (y = 1 TO request->care_category_cnt)
     IF ((request->qual_component[x].care_category_seq=request->qual_care_category[y].sequence))
      SET cc_seq = y
     ENDIF
   ENDFOR
   FOR (y = 1 TO request->time_frame_cnt)
     IF ((request->qual_component[x].time_frame_seq=request->qual_time_frame[y].sequence))
      SET tf_seq = y
     ENDIF
   ENDFOR
   INSERT  FROM pathway_comp pwc
    SET pwc.pathway_comp_id = request->qual_component[x].component_id, pwc.pathway_catalog_id =
     request->pathway_id, pwc.care_category_id = request->qual_care_category[cc_seq].care_category_id,
     pwc.time_frame_id = request->qual_time_frame[tf_seq].time_frame_id, pwc.sequence = request->
     qual_component[x].sequence, pwc.active_ind = 1,
     pwc.comp_type_cd = comp_type_cd, pwc.parent_entity_name = parent_entity_name, pwc
     .parent_entity_id = parent_entity_id,
     pwc.comp_label = request->qual_component[x].comp_label, pwc.required_ind = request->
     qual_component[x].required_ind, pwc.include_ind = request->qual_component[x].include_ind,
     pwc.after_qty = request->qual_component[x].after_qty, pwc.age_units_cd = request->
     qual_component[x].age_units_cd, pwc.related_comp_id = 0.0,
     pwc.order_sentence_id = request->qual_component[x].order_sentence_id, pwc.duration_qty = request
     ->qual_component[x].duration_qty, pwc.duration_unit_cd = request->qual_component[x].
     duration_unit_cd,
     pwc.linked_to_tf_ind = request->qual_component[x].linked_to_tf_ind, pwc.task_assay_cd = request
     ->qual_component[x].task_assay_cd, pwc.event_cd = request->qual_component[x].event_cd,
     pwc.result_type_cd = request->qual_component[x].result_type_cd, pwc.outcome_operator_cd =
     request->qual_component[x].outcome_operator_cd, pwc.result_value = request->qual_component[x].
     result_value,
     pwc.result_units_cd = request->qual_component[x].result_units_cd, pwc.capture_variance_ind =
     request->qual_component[x].capture_variance_ind, pwc.variance_required_ind = request->
     qual_component[x].variance_required_ind,
     pwc.dcp_forms_ref_id = request->qual_component[x].dcp_forms_ref_id, pwc.outcome_forms_ref_id =
     request->qual_component[x].outcome_forms_ref_id, pwc.cond_ind = request->qual_component[x].
     cond_ind,
     pwc.cond_desc = request->qual_component[x].cond_desc, pwc.cond_note_id = cond_note_id, pwc
     .cond_module_name = request->qual_component[x].cond_module_name,
     pwc.cond_false_ind = request->qual_component[x].cond_false_ind, pwc.rrf_age_qty = request->
     qual_component[x].rrf_age_qty, pwc.rrf_age_units_cd = request->qual_component[x].
     rrf_age_units_cd,
     pwc.rrf_sex_cd = request->qual_component[x].rrf_sex_cd, pwc.reference_task_id = request->
     qual_component[x].var_reference_task_id, pwc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pwc.updt_id = reqinfo->updt_id, pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->
     updt_applctx,
     pwc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO pwc_failed
   ENDIF
   FOR (nomvar = 1 TO request->qual_component[x].nomen_comp_cnt)
    INSERT  FROM pathway_comp_focus_r pcf
     SET pcf.pathway_comp_id = request->qual_component[x].component_id, pcf.nomenclature_id = request
      ->qual_component[x].qual_comp_nomen[nomvar].nomenclature_id, pcf.primary_ind = request->
      qual_component[x].qual_comp_nomen[nomvar].primary_ind,
      pcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcf.updt_id = reqinfo->updt_id, pcf.updt_task
       = reqinfo->updt_task,
      pcf.updt_cnt = 0, pcf.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO pwc_focus_failed
    ENDIF
   ENDFOR
 ENDFOR
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#pc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert pw cat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_catalog"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#der_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "der sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#der_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert der"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_entity_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#tf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#tf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#cc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cc sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#cc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "care_category"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#pf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "pf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#pf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#comp_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp ref seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#pwc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#pwc_focus_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PW_CATALOG"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 IF (cfailed="T")
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->pathway_id = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->pathway_id = request->pathway_id
 ENDIF
END GO
