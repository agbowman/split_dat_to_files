CREATE PROGRAM dcp_ver_pw_catalog:dba
 RECORD pw_catalog(
   1 description = vc
   1 pathway_catalog_id = f8
   1 description_key = vc
   1 age_units_cd = f8
   1 long_text_id = f8
   1 version = i4
   1 pw_forms_ref_id = f8
   1 comp_forms_ref_id = f8
   1 restrict_tf_add_ind = i2
   1 restrict_cc_add_ind = i2
   1 cross_encntr_ind = i2
   1 restrict_comp_add_ind = i2
   1 description_key_nls = vc
   1 beg_effective_dt_tm = dq8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_cnt = i4
   1 updt_applctx = i4
 )
 RECORD long_text(
   1 long_text = vc
   1 parent_entity_name = c32
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_cnt = i4
   1 updt_applctx = i4
 )
 RECORD time_frame(
   1 qual[*]
     2 time_frame_id = f8
     2 description = vc
     2 sequence = i4
     2 duration_qty = i4
     2 age_units_cd = f8
     2 continuous_ind = i2
     2 start_ind = i2
     2 end_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 ptf_seq = i4
     2 prnt_time_frame_id = f8
 )
 RECORD care_category(
   1 qual[*]
     2 care_category_id = f8
     2 care_category_cd = f8
     2 description = vc
     2 sequence = i4
     2 restrict_comp_add_ind = i2
     2 comp_add_variance_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
 )
 RECORD pathway_comp(
   1 qual[*]
     2 pathway_comp_id = f8
     2 time_frame_id = f8
     2 care_category_id = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 comp_label = vc
     2 order_sentence_id = f8
     2 required_ind = i2
     2 include_ind = i2
     2 repeat_ind = i2
     2 after_qty = i4
     2 age_units_cd = f8
     2 related_comp_id = f8
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 task_assay_cd = f8
     2 result_type_cd = f8
     2 outcome_operator_cd = f8
     2 result_value = f8
     2 result_units_cd = f8
     2 capture_variance_ind = i2
     2 variance_required_ind = i2
     2 dcp_forms_ref_id = f8
     2 cond_ind = i2
     2 cond_desc = vc
     2 cond_note_id = f8
     2 cond_module_name = vc
     2 cond_false_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 rc_seq = i4
     2 tf_seq = i4
     2 cc_seq = i4
     2 rrf_age_qty = i4
     2 rrf_age_units_cd = f8
     2 rrf_sex_cd = f8
     2 reference_task_id = f8
     2 event_cd = f8
     2 outcome_forms_ref_id = f8
     2 linked_to_tf_ind = i2
     2 nomen_comp_cnt = i4
     2 qual_comp_nomen[*]
       3 nomenclature_id = f8
       3 primary_ind = i2
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_task = i4
       3 updt_applctx = i4
 )
 RECORD pw_focus(
   1 nomen_cnt = i4
   1 qual_nomen[*]
     2 nomenclature_id = f8
     2 pathway_level_ind = i2
     2 default_status_cd = f8
     2 pw_focus_id = f8
     2 sequence = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 )
 RECORD comp_text(
   1 long_text = vc
   1 parent_entity_name = c32
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_cnt = i4
   1 updt_applctx = i4
 )
 RECORD relation(
   1 qual[*]
     2 relationship_mean = c12
     2 entity_id = f8
     2 entity_description = vc
     2 rank_sequence = i4
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
 )
 SET pathway_cat_id = 0.0
 SET pw_text_id = 0.0
 SET tf_cnt = 0
 SET ver_cnt = 0
 SET ncnt = 0
 SET pwc_cnt = 0
 SET pcf_cnt = 0
 SET comp_text_id = 0.0
 SET code_set = 16750
 SET cdf_meaning = "NOTE"
 EXECUTE cpm_get_cd_for_cdf
 SET note_id = code_value
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   pathway_cat_id = nextseqnum, pw_catalog->pathway_catalog_id = pathway_cat_id, ver_cat->
   version_pw_cat_id = pathway_cat_id,
   CALL echo(build("VERSION_CATALOG_ID = ",ver_cat->version_pw_cat_id))
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pc
  WHERE (pc.pathway_catalog_id=request->pathway_id)
  DETAIL
   pw_catalog->description = pc.description, pw_catalog->description_key = pc.description_key,
   pw_catalog->age_units_cd = pc.age_units_cd,
   pw_catalog->long_text_id = pc.long_text_id, pw_catalog->version = pc.version, ver_cat->version =
   pc.version,
   pw_catalog->beg_effective_dt_tm = pc.beg_effective_dt_tm, pw_catalog->updt_dt_tm = pc.updt_dt_tm,
   pw_catalog->updt_id = pc.updt_id,
   pw_catalog->updt_task = pc.updt_task, pw_catalog->updt_cnt = pc.updt_cnt, pw_catalog->updt_applctx
    = pc.updt_applctx,
   pw_catalog->pw_forms_ref_id = pc.pw_forms_ref_id, pw_catalog->comp_forms_ref_id = pc
   .comp_forms_ref_id, pw_catalog->cross_encntr_ind = pc.cross_encntr_ind,
   pw_catalog->restrict_tf_add_ind = pc.restrict_tf_add_ind, pw_catalog->restrict_cc_add_ind = pc
   .restrict_cc_add_ind, pw_catalog->restrict_comp_add_ind = pc.restrict_comp_add_ind,
   pw_catalog->description_key_nls = pc.description_key_nls,
   CALL echo(pw_catalog->description),
   CALL echo(build("pw_catalog->long_text_id = ",pw_catalog->long_text_id))
  WITH nocounter
 ;end select
 IF ((pw_catalog->long_text_id != 0.0))
  SELECT INTO "nl:"
   FROM long_text lt
   WHERE (lt.long_text_id=pw_catalog->long_text_id)
   DETAIL
    long_text->long_text = lt.long_text, long_text->parent_entity_name = lt.parent_entity_name,
    long_text->active_status_cd = lt.active_status_cd,
    long_text->active_status_dt_tm = lt.active_status_dt_tm, long_text->active_status_prsnl_id = lt
    .active_status_prsnl_id, long_text->updt_dt_tm = lt.updt_dt_tm,
    long_text->updt_id = lt.updt_id, long_text->updt_task = lt.updt_task, long_text->updt_cnt = lt
    .updt_cnt,
    long_text->updt_applctx = lt.updt_applctx
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    pw_text_id = nextseqnum,
    CALL echo(build("long_text_id = ",pw_text_id))
   WITH format
  ;end select
  IF (pw_text_id=0.0)
   GO TO text_seq_failed
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = pw_text_id, lt.parent_entity_name = long_text->parent_entity_name, lt
    .parent_entity_id = pathway_cat_id,
    lt.long_text = long_text->long_text, lt.active_ind = 1, lt.active_status_cd = long_text->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(long_text->active_status_dt_tm), lt.active_status_prsnl_id
     = long_text->active_status_prsnl_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = long_text->updt_id, lt.updt_task = long_text->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = long_text->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO text_failed
  ENDIF
 ENDIF
 INSERT  FROM pathway_catalog pc
  SET pc.pathway_catalog_id = pathway_cat_id, pc.description = pw_catalog->description, pc
   .description_key = pw_catalog->description_key,
   pc.age_units_cd = pw_catalog->age_units_cd, pc.long_text_id = pw_text_id, pc.version = 0,
   pc.version_pw_cat_id = request->pathway_id, pc.active_ind = 0, pc.beg_effective_dt_tm =
   cnvtdatetime(pw_catalog->beg_effective_dt_tm),
   pc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), pc.updt_id = pw_catalog->updt_id,
   pc.updt_task = pw_catalog->updt_task, pc.updt_cnt = 0, pc.updt_applctx = pw_catalog->updt_applctx,
   pc.pw_forms_ref_id = pw_catalog->pw_forms_ref_id, pc.comp_forms_ref_id = pw_catalog->
   comp_forms_ref_id, pc.cross_encntr_ind = pw_catalog->cross_encntr_ind,
   pc.restrict_tf_add_ind = pw_catalog->restrict_tf_add_ind, pc.restrict_cc_add_ind = pw_catalog->
   restrict_cc_add_ind, pc.restrict_comp_add_ind = pw_catalog->restrict_comp_add_ind,
   pc.description_key_nls = pw_catalog->description_key_nls
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO pc_failed
 ENDIF
 FOR (x = 1 TO request->time_frame_cnt)
   IF ((request->qual_time_frame[x].time_frame_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(time_frame->qual,ver_cnt)
 FOR (x = 1 TO ver_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    time_frame->qual[x].time_frame_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO tf_seq_failed
  ENDIF
 ENDFOR
 FOR (tf_cnt = 1 TO request->time_frame_cnt)
   IF ((request->qual_time_frame[tf_cnt].time_frame_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM time_frame tf
     WHERE (tf.time_frame_id=request->qual_time_frame[tf_cnt].time_frame_id)
     DETAIL
      time_frame->qual[ncnt].description = tf.description, time_frame->qual[ncnt].sequence = tf
      .sequence, time_frame->qual[ncnt].duration_qty = tf.duration_qty,
      time_frame->qual[ncnt].age_units_cd = tf.age_units_cd, time_frame->qual[ncnt].continuous_ind =
      tf.continuous_ind, time_frame->qual[ncnt].start_ind = tf.start_ind,
      time_frame->qual[ncnt].end_ind = tf.end_ind, time_frame->qual[ncnt].updt_dt_tm = tf.updt_dt_tm,
      time_frame->qual[ncnt].updt_id = tf.updt_id,
      time_frame->qual[ncnt].updt_task = tf.updt_task, time_frame->qual[ncnt].updt_cnt = tf.updt_cnt,
      time_frame->qual[ncnt].updt_applctx = tf.updt_applctx,
      time_frame->qual[ncnt].prnt_time_frame_id = tf.prnt_time_frame_id
     WITH nocounter
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      FROM time_frame tf
      WHERE (time_frame->qual[ncnt].prnt_time_frame_id=tf.time_frame_id)
      DETAIL
       time_frame->qual[ncnt].ptf_seq = tf.sequence,
       CALL echo(build("time_frame = ",request->qual_time_frame[tf_cnt].time_frame_id)),
       CALL echo(build("time_frame_seq = ",time_frame->qual[ncnt].ptf_seq))
      WITH nocounter
     ;end select
     IF (curqual=0)
      EXECUTE goto tf_seq_failed
     ENDIF
     INSERT  FROM time_frame tf
      SET tf.time_frame_id = time_frame->qual[tf_cnt].time_frame_id, tf.description = time_frame->
       qual[ncnt].description, tf.pathway_catalog_id = pathway_cat_id,
       tf.sequence = time_frame->qual[ncnt].sequence, tf.duration_qty = time_frame->qual[ncnt].
       duration_qty, tf.age_units_cd = time_frame->qual[ncnt].age_units_cd,
       tf.continuous_ind = time_frame->qual[ncnt].continuous_ind, tf.start_ind = time_frame->qual[
       ncnt].start_ind, tf.end_ind = time_frame->qual[ncnt].end_ind,
       tf.updt_dt_tm = cnvtdatetime(curdate,curtime3), tf.updt_id = time_frame->qual[ncnt].updt_id,
       tf.updt_task = time_frame->qual[ncnt].updt_task,
       tf.updt_cnt = 0, tf.updt_applctx = time_frame->qual[ncnt].updt_applctx, tf.prnt_time_frame_id
        = time_frame->qual[time_frame->qual[ncnt].ptf_seq].time_frame_id,
       tf.active_ind = 1
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO tf_failed
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET ver_cnt = 0
 SET ncnt = 0
 FOR (x = 1 TO request->care_category_cnt)
   IF ((request->qual_care_category[x].care_category_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(care_category->qual,ver_cnt)
 FOR (cc_cnt = 1 TO request->care_category_cnt)
   IF ((request->qual_care_category[cc_cnt].care_category_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM care_category cc
     WHERE (cc.care_category_id=request->qual_care_category[cc_cnt].care_category_id)
     DETAIL
      care_category->qual[ncnt].description = cc.description, care_category->qual[ncnt].sequence = cc
      .sequence, care_category->qual[ncnt].care_category_cd = cc.care_category_cd,
      care_category->qual[ncnt].restrict_comp_add_ind = cc.restrict_comp_add_ind, care_category->
      qual[ncnt].comp_add_variance_ind = cc.comp_add_variance_ind, care_category->qual[ncnt].
      updt_dt_tm = cc.updt_dt_tm,
      care_category->qual[ncnt].updt_id = cc.updt_id, care_category->qual[ncnt].updt_task = cc
      .updt_task, care_category->qual[ncnt].updt_cnt = cc.updt_cnt,
      care_category->qual[ncnt].updt_applctx = cc.updt_applctx
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO cc_failed
    ENDIF
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      care_category->qual[ncnt].care_category_id = nextseqnum
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO cc_seq_failed
    ENDIF
    INSERT  FROM care_category cc
     SET cc.care_category_id = care_category->qual[ncnt].care_category_id, cc.description =
      care_category->qual[ncnt].description, cc.pathway_catalog_id = pathway_cat_id,
      cc.sequence = care_category->qual[ncnt].sequence, cc.restrict_comp_add_ind = care_category->
      qual[ncnt].restrict_comp_add_ind, cc.comp_add_variance_ind = care_category->qual[ncnt].
      comp_add_variance_ind,
      cc.care_category_cd = care_category->qual[ncnt].care_category_cd, cc.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), cc.updt_id = care_category->qual[ncnt].updt_id,
      cc.updt_task = care_category->qual[ncnt].updt_task, cc.updt_cnt = 0, cc.updt_applctx =
      care_category->qual[ncnt].updt_applctx,
      cc.active_ind = 1
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO cc_failed
    ENDIF
   ENDIF
 ENDFOR
 SET ncnt = 0
 SELECT INTO "nl:"
  FROM pathway_focus pf
  WHERE (pf.pathway_catalog_id=request->pathway_id)
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(pw_focus->qual_nomen,5))
    stat = alterlist(pw_focus->qual_nomen,(ncnt+ 10))
   ENDIF
   pw_focus->qual_nomen[ncnt].nomenclature_id = pf.nomenclature_id, pw_focus->qual_nomen[ncnt].
   pathway_level_ind = pf.pathway_level_ind, pw_focus->qual_nomen[ncnt].default_status_cd = pf
   .default_status_cd,
   pw_focus->qual_nomen[ncnt].sequence = pf.sequence, pw_focus->qual_nomen[ncnt].updt_dt_tm = pf
   .updt_dt_tm, pw_focus->qual_nomen[ncnt].updt_id = pf.updt_id,
   pw_focus->qual_nomen[ncnt].updt_task = pf.updt_task, pw_focus->qual_nomen[ncnt].updt_applctx = pf
   .updt_applctx
  WITH nocounter
 ;end select
 SET stat = alterlist(pw_focus->qual_nomen,ncnt)
 SET pw_focus->nomen_cnt = ncnt
 FOR (x = 1 TO pw_focus->nomen_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    pw_focus->qual_nomen[x].pw_focus_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO pf_seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO pw_focus->nomen_cnt)
  INSERT  FROM pathway_focus pf
   SET pf.pathway_focus_id = pw_focus->qual_nomen[x].pw_focus_id, pf.nomenclature_id = pw_focus->
    qual_nomen[x].nomenclature_id, pf.pathway_level_ind = pw_focus->qual_nomen[x].pathway_level_ind,
    pf.sequence = pw_focus->qual_nomen[x].sequence, pf.default_status_cd = pw_focus->qual_nomen[x].
    default_status_cd, pf.pathway_catalog_id = pathway_cat_id,
    pf.updt_dt_tm = cnvtdatetime(pw_focus->qual_nomen[x].updt_dt_tm), pf.updt_id = pw_focus->
    qual_nomen[x].updt_id, pf.updt_task = pw_focus->qual_nomen[x].updt_task,
    pf.updt_applctx = pw_focus->qual_nomen[x].updt_applctx, pf.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO pf_failed
  ENDIF
 ENDFOR
 SET ver_cnt = 0
 SET ncnt = 0
 FOR (x = 1 TO request->component_cnt)
   IF ((request->qual_component[x].component_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(pathway_comp->qual,ver_cnt)
 FOR (x = 1 TO ver_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    pathway_comp->qual[x].pathway_comp_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO pwc_seq_failed
  ENDIF
 ENDFOR
 SET ncnt = 0
 FOR (pwc_cnt = 1 TO request->component_cnt)
   IF ((request->qual_component[pwc_cnt].component_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM pathway_comp pwc
     WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      pathway_comp->qual[ncnt].comp_type_cd = pwc.comp_type_cd, pathway_comp->qual[ncnt].
      time_frame_id = pwc.time_frame_id, pathway_comp->qual[ncnt].care_category_id = pwc
      .care_category_id,
      pathway_comp->qual[ncnt].sequence = pwc.sequence, pathway_comp->qual[ncnt].parent_entity_name
       = pwc.parent_entity_name, pathway_comp->qual[ncnt].age_units_cd = pwc.age_units_cd,
      pathway_comp->qual[ncnt].parent_entity_id = pwc.parent_entity_id, pathway_comp->qual[ncnt].
      comp_label = pwc.comp_label, pathway_comp->qual[ncnt].order_sentence_id = pwc.order_sentence_id,
      pathway_comp->qual[ncnt].required_ind = pwc.required_ind, pathway_comp->qual[ncnt].include_ind
       = pwc.include_ind, pathway_comp->qual[ncnt].repeat_ind = pwc.repeat_ind,
      pathway_comp->qual[ncnt].after_qty = pwc.after_qty, pathway_comp->qual[ncnt].duration_qty = pwc
      .duration_qty, pathway_comp->qual[ncnt].duration_unit_cd = pwc.duration_unit_cd,
      pathway_comp->qual[ncnt].task_assay_cd = pwc.task_assay_cd, pathway_comp->qual[ncnt].
      result_type_cd = pwc.result_type_cd, pathway_comp->qual[ncnt].outcome_operator_cd = pwc
      .outcome_operator_cd,
      pathway_comp->qual[ncnt].result_value = pwc.result_value, pathway_comp->qual[ncnt].
      result_units_cd = pwc.result_units_cd, pathway_comp->qual[ncnt].capture_variance_ind = pwc
      .capture_variance_ind,
      pathway_comp->qual[ncnt].variance_required_ind = pwc.variance_required_ind, pathway_comp->qual[
      ncnt].dcp_forms_ref_id = pwc.dcp_forms_ref_id, pathway_comp->qual[ncnt].cond_ind = pwc.cond_ind,
      pathway_comp->qual[ncnt].cond_desc = pwc.cond_desc, pathway_comp->qual[ncnt].cond_note_id = pwc
      .cond_note_id, pathway_comp->qual[ncnt].cond_module_name = pwc.cond_module_name,
      pathway_comp->qual[ncnt].cond_false_ind = pwc.cond_false_ind, pathway_comp->qual[ncnt].
      updt_dt_tm = pwc.updt_dt_tm, pathway_comp->qual[ncnt].updt_id = pwc.updt_id,
      pathway_comp->qual[ncnt].updt_task = pwc.updt_task, pathway_comp->qual[ncnt].updt_cnt = pwc
      .updt_cnt, pathway_comp->qual[ncnt].updt_applctx = pwc.updt_applctx,
      pathway_comp->qual[ncnt].related_comp_id = pwc.related_comp_id, pathway_comp->qual[ncnt].
      rrf_age_qty = pwc.rrf_age_qty, pathway_comp->qual[ncnt].rrf_age_units_cd = pwc.rrf_age_units_cd,
      pathway_comp->qual[ncnt].rrf_sex_cd = pwc.rrf_sex_cd, pathway_comp->qual[ncnt].
      reference_task_id = pwc.reference_task_id, pathway_comp->qual[ncnt].event_cd = pwc.event_cd,
      pathway_comp->qual[ncnt].outcome_forms_ref_id = pwc.outcome_forms_ref_id, pathway_comp->qual[
      ncnt].linked_to_tf_ind = pwc.linked_to_tf_ind
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO pwc_failed
    ENDIF
    SET pcf_cnt = 0
    SELECT INTO "nl:"
     FROM pathway_comp_focus_r pcf
     WHERE (pcf.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      pcf_cnt = (pcf_cnt+ 1)
      IF (pcf_cnt > size(pathway_comp->qual[ncnt].qual_comp_nomen,5))
       stat = alterlist(pathway_comp->qual[ncnt].qual_comp_nomen,(pcf_cnt+ 10))
      ENDIF
      pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].nomenclature_id = pcf.nomenclature_id,
      pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].primary_ind = pcf.primary_ind, pathway_comp->
      qual[ncnt].qual_comp_nomen[pcf_cnt].updt_dt_tm = pcf.updt_dt_tm,
      pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].updt_id = pcf.updt_id, pathway_comp->qual[
      ncnt].qual_comp_nomen[pcf_cnt].updt_task = pcf.updt_task, pathway_comp->qual[ncnt].
      qual_comp_nomen[pcf_cnt].updt_applctx = pcf.updt_applctx
     WITH nocounter
    ;end select
    SET stat = alterlist(pathway_comp->qual[ncnt].qual_comp_nomen,pcf_cnt)
    SET pathway_comp->qual[ncnt].nomen_comp_cnt = pcf_cnt
    IF ((pathway_comp->qual[ncnt].comp_type_cd=note_id))
     SELECT INTO "nl:"
      FROM long_text lt
      WHERE (pathway_comp->qual[ncnt].parent_entity_id=lt.long_text_id)
      DETAIL
       comp_text->parent_entity_name = lt.parent_entity_name, comp_text->long_text = lt.long_text,
       comp_text->active_status_cd = lt.active_status_cd,
       comp_text->active_status_dt_tm = lt.active_status_dt_tm, comp_text->active_status_prsnl_id =
       lt.active_status_prsnl_id, comp_text->updt_dt_tm = lt.updt_dt_tm,
       comp_text->updt_id = lt.updt_id, comp_text->updt_task = lt.updt_task, comp_text->updt_cnt = lt
       .updt_cnt,
       comp_text->updt_applctx = lt.updt_applctx
      WITH nocounter
     ;end select
     IF (curqual=0)
      GO TO comp_text_failed
     ENDIF
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
      SET lt.long_text_id = comp_text_id, lt.parent_entity_name = comp_text->parent_entity_name, lt
       .parent_entity_id = pathway_comp->qual[ncnt].pathway_comp_id,
       lt.long_text = comp_text->long_text, lt.active_ind = 1, lt.active_status_cd = comp_text->
       active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(comp_text->active_status_dt_tm), lt
       .active_status_prsnl_id = comp_text->active_status_prsnl_id, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       lt.updt_id = comp_text->updt_id, lt.updt_task = comp_text->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = comp_text->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO comp_text_failed
     ENDIF
     SET pathway_comp->qual[ncnt].parent_entity_id = comp_text_id
    ENDIF
    SELECT INTO "nl:"
     FROM pathway_comp pwc
     WHERE (pathway_comp->qual[ncnt].related_comp_id=pwc.pathway_comp_id)
     DETAIL
      pathway_comp->qual[ncnt].rc_seq = pwc.sequence
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM time_frame tf
     WHERE (pathway_comp->qual[ncnt].time_frame_id=tf.time_frame_id)
     DETAIL
      pathway_comp->qual[ncnt].tf_seq = tf.sequence
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM care_category cc
     WHERE (pathway_comp->qual[ncnt].care_category_id=cc.care_category_id)
     DETAIL
      pathway_comp->qual[ncnt].cc_seq = cc.sequence
     WITH nocounter
    ;end select
    INSERT  FROM pathway_comp pwc
     SET pwc.pathway_comp_id = pathway_comp->qual[ncnt].pathway_comp_id, pwc.pathway_catalog_id =
      pathway_cat_id, pwc.care_category_id = care_category->qual[pathway_comp->qual[ncnt].cc_seq].
      care_category_id,
      pwc.time_frame_id = time_frame->qual[pathway_comp->qual[ncnt].tf_seq].time_frame_id, pwc
      .sequence = pathway_comp->qual[ncnt].sequence, pwc.comp_type_cd = pathway_comp->qual[ncnt].
      comp_type_cd,
      pwc.parent_entity_name = pathway_comp->qual[ncnt].parent_entity_name, pwc.age_units_cd =
      pathway_comp->qual[ncnt].age_units_cd, pwc.parent_entity_id = pathway_comp->qual[ncnt].
      parent_entity_id,
      pwc.comp_label = pathway_comp->qual[ncnt].comp_label, pwc.order_sentence_id = pathway_comp->
      qual[ncnt].order_sentence_id, pwc.required_ind = pathway_comp->qual[ncnt].required_ind,
      pwc.include_ind = pathway_comp->qual[ncnt].include_ind, pwc.repeat_ind = pathway_comp->qual[
      ncnt].repeat_ind, pwc.after_qty = pathway_comp->qual[ncnt].after_qty,
      pwc.duration_qty = pathway_comp->qual[ncnt].duration_qty, pwc.duration_unit_cd = pathway_comp->
      qual[ncnt].duration_unit_cd, pwc.task_assay_cd = pathway_comp->qual[ncnt].task_assay_cd,
      pwc.result_type_cd = pathway_comp->qual[ncnt].result_type_cd, pwc.outcome_operator_cd =
      pathway_comp->qual[ncnt].outcome_operator_cd, pwc.result_value = pathway_comp->qual[ncnt].
      result_value,
      pwc.result_units_cd = pathway_comp->qual[ncnt].result_units_cd, pwc.capture_variance_ind =
      pathway_comp->qual[ncnt].capture_variance_ind, pwc.variance_required_ind = pathway_comp->qual[
      ncnt].variance_required_ind,
      pwc.dcp_forms_ref_id = pathway_comp->qual[ncnt].dcp_forms_ref_id, pwc.cond_ind = pathway_comp->
      qual[ncnt].cond_ind, pwc.cond_desc = pathway_comp->qual[ncnt].cond_desc,
      pwc.cond_note_id = pathway_comp->qual[ncnt].cond_note_id, pwc.cond_module_name = pathway_comp->
      qual[ncnt].cond_module_name, pwc.cond_false_ind = pathway_comp->qual[ncnt].cond_false_ind,
      pwc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pwc.updt_id = pathway_comp->qual[ncnt].updt_id,
      pwc.updt_task = pathway_comp->qual[ncnt].updt_task,
      pwc.updt_cnt = 0, pwc.updt_applctx = pathway_comp->qual[ncnt].updt_applctx, pwc.related_comp_id
       = pathway_comp->qual[pathway_comp->qual[ncnt].rc_seq].pathway_comp_id,
      pwc.rrf_age_qty = pathway_comp->qual[ncnt].rrf_age_qty, pwc.rrf_age_units_cd = pathway_comp->
      qual[ncnt].rrf_age_units_cd, pwc.rrf_sex_cd = pathway_comp->qual[ncnt].rrf_sex_cd,
      pwc.reference_task_id = pathway_comp->qual[ncnt].reference_task_id, pwc.event_cd = pathway_comp
      ->qual[ncnt].event_cd, pwc.outcome_forms_ref_id = pathway_comp->qual[ncnt].outcome_forms_ref_id,
      pwc.linked_to_tf_ind = pathway_comp->qual[ncnt].linked_to_tf_ind, pwc.active_ind = 1
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO pwc_failed
    ENDIF
    FOR (pcf_cnt = 1 TO pathway_comp->qual[ncnt].nomen_comp_cnt)
     INSERT  FROM pathway_comp_focus_r pcf
      SET pcf.pathway_comp_id = pathway_comp->qual[ncnt].pathway_comp_id, pcf.nomenclature_id =
       pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].nomenclature_id, pcf.primary_ind =
       pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].primary_ind,
       pcf.updt_cnt = 0, pcf.updt_dt_tm = cnvtdatetime(pathway_comp->qual[ncnt].qual_comp_nomen[
        pcf_cnt].updt_dt_tm), pcf.updt_id = pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].updt_id,
       pcf.updt_task = pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].updt_task, pcf.updt_applctx
        = pathway_comp->qual[ncnt].qual_comp_nomen[pcf_cnt].updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO pcf_failed
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET ver_cnt = 0
 FOR (x = 1 TO request->relationship_cnt)
   IF ((request->qual_relationship[x].dcp_entity_reltn_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(relation->qual,ver_cnt)
 FOR (x = 1 TO ver_cnt)
   SELECT INTO "nl:"
    FROM dcp_entity_reltn der
    WHERE (der.entity1_id=request->pathway_id)
    DETAIL
     relation->qual[x].relationship_mean = der.entity_reltn_mean, relation->qual[x].entity_id = der
     .entity2_id, relation->qual[x].entity_description = der.entity2_display,
     relation->qual[x].rank_sequence = der.rank_sequence, relation->qual[x].begin_effective_dt_tm =
     der.begin_effective_dt_tm, relation->qual[x].end_effective_dt_tm = der.end_effective_dt_tm,
     relation->qual[x].updt_dt_tm = der.updt_dt_tm, relation->qual[x].updt_id = der.updt_id, relation
     ->qual[x].updt_task = der.updt_task,
     relation->qual[x].updt_cnt = der.updt_cnt, relation->qual[x].updt_applctx = der.updt_applctx
    WITH nocounter
   ;end select
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
    SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = relation->qual[x].
     relationship_mean, der.entity1_id = pathway_cat_id,
     der.entity1_display = pw_catalog->description, der.entity2_id = relation->qual[x].entity_id, der
     .entity2_display = relation->qual[x].entity_description,
     der.rank_sequence = relation->qual[x].rank_sequence, der.active_ind = 0, der
     .begin_effective_dt_tm = cnvtdatetime(relation->qual[x].begin_effective_dt_tm),
     der.end_effective_dt_tm = cnvtdatetime(relation->qual[x].end_effective_dt_tm), der.updt_dt_tm =
     cnvtdatetime(relation->qual[x].updt_dt_tm), der.updt_id = relation->qual[x].updt_id,
     der.updt_task = relation->qual[x].updt_task, der.updt_applctx = relation->qual[x].updt_applctx,
     der.updt_cnt = relation->qual[x].updt_cnt
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO der_failed
   ENDIF
 ENDFOR
 EXECUTE dcp_ver_ref_text
 GO TO exit_script
#text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert pw cat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_catalog"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#tf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#tf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#tf_get_failed
 SET reply->status_data.subeventstatus[1].operationname = "get"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#cc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#cc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pwc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pwc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "pf id's"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "get pf id's"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pcf_failed
 SET reply->status_data.subeventstatus[1].operationname = "get"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#der_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "der sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#der_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert der"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_entity_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 CALL echo("exiting script")
 CALL echo(reply->status_data.subeventstatus[1].operationname)
 CALL echo(reply->status_data.subeventstatus[1].operationstatus)
 CALL echo(reply->status_data.subeventstatus[1].targetobjectname)
 CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 CALL echo(build("failed_ind = ",cfailed))
 IF (cfailed="T")
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->pathway_id = 0
  SET ver_cat->cfailed = "T"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "S"
  SET reply->pathway_id = request->pathway_id
 ENDIF
END GO
