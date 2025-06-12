CREATE PROGRAM dcp_ver_pathway:dba
 RECORD pathway_copy FROM v500,pathway,pathway
 RECORD text_copy FROM v500,long_text,long_text
 RECORD time_frame(
   1 qual[*]
     2 act_time_frame_id = f8
     2 time_frame_id = f8
     2 sequence = i4
     2 description = vc
     2 duration_qty = i4
     2 age_units_cd = f8
     2 calc_start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
     2 continuous_ind = i2
     2 start_ind = i2
     2 end_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 ptf_seq = i4
     2 parent_tf_id = f8
 )
 RECORD care_category(
   1 qual[*]
     2 act_care_cat_id = f8
     2 care_category_id = f8
     2 description = vc
     2 sequence = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
 )
 RECORD pathway_comp(
   1 qual[*]
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 act_time_frame_id = f8
     2 act_care_cat_id = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_status_cd = f8
     2 ref_prnt_ent_id = f8
     2 ref_prnt_ent_name = vc
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 orig_prnt_ent_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 comp_label = vc
     2 existing_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 included_dt_tm = dq8
     2 repeat_ind = i2
     2 after_qty = i4
     2 age_units_cd = f8
     2 created_dt_tm = dq8
     2 related_comp_id = f8
     2 canceled_ind = i2
     2 canceled_dt_tm = dq8
     2 activated_ind = i2
     2 activated_prsnl_id = f8
     2 activated_dt_tm = dq8
     2 last_action_seq = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 rc_seq = i4
     2 tf_seq = i4
     2 cc_seq = i4
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
 SET pathway_id = 0.0
 SET pw_text_id = 0.0
 SET ncnt = 0
 SET tf_cnt = 0
 SET ver_cnt = 0
 SET pwc_cnt = 0
 SET comp_text_id = 0.0
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   pathway_id = cnvtint(nextseqnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 SELECT INTO "nl:"
  FROM pathway pw
  WHERE (pw.pathway_id=request->pathway_id)
  DETAIL
   x = 0, x = moverec(pw.seq,pathway_copy), pathway_copy->pathway_catalog_id = pw.pathway_catalog_id,
   pathway_copy->pw_status_cd = pw.pw_status_cd, pathway_copy->status_dt_tm = pw.status_dt_tm,
   pathway_copy->status_prsnl_id = pw.status_prsnl_id,
   pathway_copy->encntr_id = pw.encntr_id, pathway_copy->person_id = pw.person_id, pathway_copy->
   description = pw.description,
   pathway_copy->age_units_cd = pw.age_units_cd, pathway_copy->long_text_id = pw.long_text_id,
   pathway_copy->order_dt_tm = pw.order_dt_tm,
   pathway_copy->start_dt_tm = pw.start_dt_tm, pathway_copy->started_ind = pw.started_ind,
   pathway_copy->calc_end_dt_tm = pw.calc_end_dt_tm,
   pathway_copy->actual_end_dt_tm = pw.actual_end_dt_tm, pathway_copy->ended_ind = pw.ended_ind,
   pathway_copy->dc_reason_cd = pw.dc_reason_cd,
   pathway_copy->discontinued_ind = pw.discontinued_ind, pathway_copy->discontinued_dt_tm = pw
   .discontinued_dt_tm, pathway_copy->last_action_seq = pw.last_action_seq,
   pathway_copy->version = pw.version, pathway_copy->pathway_id = pw.pathway_id, pathway_copy->
   beg_effective_dt_tm = pw.beg_effective_dt_tm,
   pathway_copy->updt_dt_tm = pw.updt_dt_tm, pathway_copy->updt_id = pw.updt_id, pathway_copy->
   updt_cnt = pw.updt_cnt,
   pathway_copy->updt_task = pw.updt_task, pathway_copy->updt_applctx = pw.updt_applctx
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO pw_failed
 ENDIF
 IF ((pathway_copy->long_text_id != 0))
  SELECT INTO "nl:"
   FROM long_text lt
   WHERE (lt.long_text_id=pathway_copy->long_text_id)
   DETAIL
    x = 0, x = moverec(lt.seq,text_copy), text_copy->parent_entity_name = lt.parent_entity_name,
    text_copy->long_text = lt.long_text, text_copy->active_status_cd = lt.active_status_cd, text_copy
    ->active_status_dt_tm = lt.active_status_dt_tm,
    text_copy->active_status_prsnl_id = lt.active_status_prsnl_id, text_copy->updt_dt_tm = lt
    .updt_dt_tm, text_copy->updt_id = lt.updt_id,
    text_copy->updt_task = lt.updt_task, text_copy->updt_cnt = lt.updt_cnt, text_copy->updt_applctx
     = lt.updt_applctx
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO text_failed
  ENDIF
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    pw_text_id = cnvtint(nextseqnum)
   WITH format
  ;end select
  IF (pw_text_id=0.0)
   GO TO text_seq_failed
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = pw_text_id, lt.parent_entity_name = text_copy->parent_entity_name, lt
    .parent_entity_id = pathway_id,
    lt.long_text = text_copy->long_text, lt.active_ind = 0, lt.active_status_cd = text_copy->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(text_copy->active_status_dt_tm), lt.active_status_prsnl_id
     = text_copy->active_status_prsnl_id, lt.updt_dt_tm = cnvtdatetime(text_copy->updt_dt_tm),
    lt.updt_id = text_copy->updt_id, lt.updt_task = text_copy->updt_task, lt.updt_cnt = text_copy->
    updt_cnt,
    lt.updt_applctx = text_copy->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO text_failed
  ENDIF
 ENDIF
 INSERT  FROM pathway pw
  SET pw.pathway_id = pathway_id, pw.pathway_catalog_id = pathway_copy->pathway_catalog_id, pw
   .pw_status_cd = pathway_copy->pw_status_cd,
   pw.status_dt_tm = cnvtdatetime(pathway_copy->status_dt_tm), pw.status_prsnl_id = pathway_copy->
   status_prsnl_id, pw.encntr_id = pathway_copy->encntr_id,
   pw.person_id = pathway_copy->person_id, pw.description = pathway_copy->description, pw
   .age_units_cd = pathway_copy->age_units_cd,
   pw.long_text_id = pathway_copy->long_text_id, pw.order_dt_tm = cnvtdatetime(pathway_copy->
    order_dt_tm), pw.start_dt_tm = cnvtdatetime(pathway_copy->start_dt_tm),
   pw.started_ind = pathway_copy->started_ind, pw.calc_end_dt_tm = cnvtdatetime(pathway_copy->
    calc_end_dt_tm), pw.actual_end_dt_tm = cnvtdatetime(pathway_copy->actual_end_dt_tm),
   pw.ended_ind = pathway_copy->ended_ind, pw.dc_reason_cd = pathway_copy->dc_reason_cd, pw
   .discontinued_ind = pathway_copy->discontinued_ind,
   pw.discontinued_dt_tm = cnvtdatetime(pathway_copy->discontinued_dt_tm), pw.last_action_seq =
   pathway_copy->last_action_seq, pw.version = pathway_copy->version,
   pw.version_pathway_id = pathway_copy->pathway_id, pw.beg_effective_dt_tm = cnvtdatetime(
    pathway_copy->beg_effective_dt_tm), pw.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   pw.active_ind = 0, pw.updt_dt_tm = cnvtdatetime(pathway_copy->updt_dt_tm), pw.updt_id =
   pathway_copy->updt_id,
   pw.updt_task = pathway_copy->updt_task, pw.updt_cnt = pathway_copy->updt_cnt, pw.updt_applctx =
   pathway_copy->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO pw_failed
 ENDIF
 SET time_frame_cnt = cnvtint(size(request->qual_time_frame,5))
 FOR (x = 1 TO time_frame_cnt)
   IF ((request->qual_time_frame[x].act_time_frame_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(time_frame->qual,ver_cnt)
 FOR (x = 1 TO ver_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    time_frame->qual[x].act_time_frame_id = cnvtint(nextseqnum)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO atf_seq_failed
  ENDIF
 ENDFOR
 FOR (tf_cnt = 1 TO time_frame_cnt)
   IF ((request->qual_time_frame[tf_cnt].act_time_frame_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM act_time_frame atf
     WHERE (atf.act_time_frame_id=request->qual_time_frame[tf_cnt].act_time_frame_id)
     DETAIL
      time_frame->qual[ncnt].time_frame_id = atf.time_frame_id, time_frame->qual[ncnt].description =
      atf.description, time_frame->qual[ncnt].sequence = atf.sequence,
      time_frame->qual[ncnt].duration_qty = atf.duration_qty, time_frame->qual[ncnt].age_units_cd =
      atf.age_units_cd, time_frame->qual[ncnt].calc_start_dt_tm = atf.calc_start_dt_tm,
      time_frame->qual[ncnt].calc_end_dt_tm = atf.calc_end_dt_tm, time_frame->qual[ncnt].
      continuous_ind = atf.continuous_ind, time_frame->qual[ncnt].start_ind = atf.start_ind,
      time_frame->qual[ncnt].end_ind = atf.end_ind, time_frame->qual[ncnt].updt_dt_tm = atf
      .updt_dt_tm, time_frame->qual[ncnt].updt_id = atf.updt_id,
      time_frame->qual[ncnt].updt_task = atf.updt_task, time_frame->qual[ncnt].updt_cnt = atf
      .updt_cnt, time_frame->qual[ncnt].updt_applctx = atf.updt_applctx,
      time_frame->qual[ncnt].parent_tf_id = atf.parent_tf_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO atf_failed
    ENDIF
    SELECT INTO "nl:"
     FROM act_time_frame atf
     WHERE (time_frame->qual[ncnt].parent_tf_id=atf.act_time_frame_id)
     DETAIL
      time_frame->qual[ncnt].ptf_seq = atf.sequence
     WITH nocounter
    ;end select
    INSERT  FROM act_time_frame atf
     SET atf.act_time_frame_id = time_frame->qual[ncnt].act_time_frame_id, atf.time_frame_id =
      time_frame->qual[ncnt].time_frame_id, atf.description = time_frame->qual[ncnt].description,
      atf.pathway_id = pathway_id, atf.sequence = time_frame->qual[ncnt].sequence, atf.duration_qty
       = time_frame->qual[ncnt].duration_qty,
      atf.age_units_cd = time_frame->qual[ncnt].age_units_cd, atf.calc_start_dt_tm = cnvtdatetime(
       time_frame->qual[ncnt].calc_start_dt_tm), atf.calc_end_dt_tm = cnvtdatetime(time_frame->qual[
       ncnt].calc_end_dt_tm),
      atf.continuous_ind = time_frame->qual[ncnt].continuous_ind, atf.start_ind = time_frame->qual[
      ncnt].start_ind, atf.end_ind = time_frame->qual[ncnt].end_ind,
      atf.updt_dt_tm = cnvtdatetime(time_frame->qual[ncnt].updt_dt_tm), atf.updt_id = time_frame->
      qual[ncnt].updt_id, atf.updt_task = time_frame->qual[ncnt].updt_task,
      atf.updt_cnt = time_frame->qual[ncnt].updt_cnt, atf.updt_applctx = time_frame->qual[ncnt].
      updt_applctx, atf.parent_tf_id = time_frame->qual[time_frame->qual[ncnt].ptf_seq].
      act_time_frame_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO atf_failed
    ENDIF
   ENDIF
 ENDFOR
 SET ver_cnt = 0
 SET ncnt = 0
 SET care_category_cnt = cnvtint(size(request->qual_care_category,5))
 FOR (x = 1 TO care_category_cnt)
   IF ((request->qual_care_category[x].act_care_cat_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(care_category->qual,ver_cnt)
 FOR (cc_cnt = 1 TO care_category_cnt)
   IF ((request->qual_care_category[cc_cnt].act_care_cat_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM act_care_cat acc
     WHERE (acc.act_care_cat_id=request->qual_care_category[cc_cnt].act_care_cat_id)
     DETAIL
      care_category->qual[ncnt].care_category_id = acc.care_category_id, care_category->qual[ncnt].
      description = acc.description, care_category->qual[ncnt].sequence = acc.sequence,
      care_category->qual[ncnt].updt_dt_tm = acc.updt_dt_tm, care_category->qual[ncnt].updt_id = acc
      .updt_id, care_category->qual[ncnt].updt_task = acc.updt_task,
      care_category->qual[ncnt].updt_cnt = acc.updt_cnt, care_category->qual[ncnt].updt_applctx = acc
      .updt_applctx
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO acc_failed
    ENDIF
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      care_category->qual[ncnt].act_care_cat_id = cnvtint(nextseqnum)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO acc_seq_failed
    ENDIF
    INSERT  FROM act_care_cat acc
     SET acc.act_care_cat_id = care_category->qual[ncnt].act_care_cat_id, acc.care_category_id =
      care_category->qual[ncnt].care_category_id, acc.description = care_category->qual[ncnt].
      description,
      acc.pathway_id = pathway_id, acc.sequence = care_category->qual[ncnt].sequence, acc.active_ind
       = 0,
      acc.updt_dt_tm = cnvtdatetime(care_category->qual[ncnt].updt_dt_tm), acc.updt_id =
      care_category->qual[ncnt].updt_id, acc.updt_task = care_category->qual[ncnt].updt_task,
      acc.updt_cnt = care_category->qual[ncnt].updt_cnt, acc.updt_applctx = care_category->qual[ncnt]
      .updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO acc_failed
    ENDIF
   ENDIF
 ENDFOR
 SET ver_cnt = 0
 SET ncnt = 0
 SET component_cnt = cnvtint(size(request->qual_component,5))
 FOR (x = 1 TO component_cnt)
   IF ((request->qual_component[x].component_id != 0))
    SET ver_cnt = (ver_cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(pathway_comp->qual,ver_cnt)
 FOR (x = 1 TO ver_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    pathway_comp->qual[x].act_pw_comp_id = cnvtint(nextseqnum)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO apc_seq_failed
  ENDIF
 ENDFOR
 FOR (pwc_cnt = 1 TO component_cnt)
   IF ((request->qual_component[pwc_cnt].component_id != 0))
    SET ncnt = (ncnt+ 1)
    SELECT INTO "nl:"
     FROM act_pw_comp apc
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      pathway_comp->qual[ncnt].pathway_comp_id = apc.pathway_comp_id, pathway_comp->qual[ncnt].
      comp_type_cd = apc.comp_type_cd, pathway_comp->qual[ncnt].sequence = apc.sequence,
      pathway_comp->qual[ncnt].ref_prnt_ent_name = apc.ref_prnt_ent_name, pathway_comp->qual[ncnt].
      ref_prnt_ent_id = apc.ref_prnt_ent_id, pathway_comp->qual[ncnt].parent_entity_name = apc
      .parent_entity_name,
      pathway_comp->qual[ncnt].age_units_cd = apc.age_units_cd, pathway_comp->qual[ncnt].
      parent_entity_id = apc.parent_entity_id, pathway_comp->qual[ncnt].orig_prnt_ent_id = apc
      .orig_prnt_ent_id,
      pathway_comp->qual[ncnt].encntr_id = apc.encntr_id, pathway_comp->qual[ncnt].person_id = apc
      .person_id, pathway_comp->qual[ncnt].comp_label = apc.comp_label,
      pathway_comp->qual[ncnt].comp_status_cd = apc.comp_status_cd, pathway_comp->qual[ncnt].
      required_ind = apc.required_ind, pathway_comp->qual[ncnt].existing_ind = apc.existing_ind,
      pathway_comp->qual[ncnt].included_ind = apc.included_ind, pathway_comp->qual[ncnt].
      included_dt_tm = apc.included_dt_tm, pathway_comp->qual[ncnt].created_dt_tm = apc.created_dt_tm,
      pathway_comp->qual[ncnt].canceled_ind = apc.canceled_ind, pathway_comp->qual[ncnt].
      canceled_dt_tm = apc.canceled_dt_tm, pathway_comp->qual[ncnt].activated_ind = apc.activated_ind,
      pathway_comp->qual[ncnt].activated_prsnl_id = apc.activated_prsnl_id, pathway_comp->qual[ncnt].
      activated_dt_tm = apc.activated_dt_tm, pathway_comp->qual[ncnt].last_action_seq = apc
      .last_action_seq,
      pathway_comp->qual[ncnt].repeat_ind = apc.repeat_ind, pathway_comp->qual[ncnt].after_qty = apc
      .after_qty, pathway_comp->qual[ncnt].updt_dt_tm = apc.updt_dt_tm,
      pathway_comp->qual[ncnt].updt_id = apc.updt_id, pathway_comp->qual[ncnt].updt_task = apc
      .updt_task, pathway_comp->qual[ncnt].updt_cnt = apc.updt_cnt,
      pathway_comp->qual[ncnt].updt_applctx = apc.updt_applctx, pathway_comp->qual[ncnt].
      related_comp_id = apc.related_comp_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apc_failed
    ENDIF
    IF ((pathway_comp->qual[ncnt].parent_entity_name="NOTE"))
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
      nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
      FROM dual
      DETAIL
       comp_text_id = cnvtint(nextseqnum)
      WITH format
     ;end select
     IF (comp_text_id=0.0)
      GO TO comp_text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = comp_text_id, lt.parent_entity_name = comp_text->parent_entity_name, lt
       .parent_entity_id = pathway_comp->qual[ncnt].act_pw_comp_id,
       lt.long_text = comp_text->long_text, lt.active_ind = 0, lt.active_status_cd = comp_text->
       active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(comp_text->active_status_dt_tm), lt
       .active_status_prsnl_id = comp_text->active_status_prsnl_id, lt.updt_dt_tm = cnvtdatetime(
        comp_text->updt_dt_tm),
       lt.updt_id = comp_text->updt_id, lt.updt_task = comp_text->updt_task, lt.updt_cnt = comp_text
       ->updt_cnt,
       lt.updt_applctx = comp_text->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO comp_text_failed
     ENDIF
     SET pathway_comp->qual[ncnt].parent_entity_id = comp_text_id
    ENDIF
    SELECT INTO "nl:"
     FROM act_pw_comp apc
     WHERE (pathway_comp->qual[ncnt].related_comp_id=apc.act_pw_comp_id)
     DETAIL
      pathway_comp->qual[ncnt].rc_seq = apc.sequence
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM act_time_frame atf
     WHERE (pathway_comp->qual[ncnt].act_time_frame_id=atf.act_time_frame_id)
     DETAIL
      pathway_comp->qual[ncnt].tf_seq = atf.sequence
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM act_care_cat acc
     WHERE (pathway_comp->qual[ncnt].act_care_cat_id=acc.act_care_cat_id)
     DETAIL
      pathway_comp->qual[ncnt].cc_seq = acc.sequence
     WITH nocounter
    ;end select
    INSERT  FROM act_pw_comp apc
     SET apc.act_pw_comp_id = pathway_comp->qual[ncnt].act_pw_comp_id, apc.pathway_comp_id =
      pathway_comp->qual[ncnt].pathway_comp_id, apc.pathway_id = pathway_id,
      apc.act_care_cat_id = care_category->qual[pathway_comp->qual[ncnt].cc_seq].act_care_cat_id, apc
      .act_time_frame_id = time_frame->qual[pathway_comp->qual[ncnt].tf_seq].act_time_frame_id, apc
      .sequence = pathway_comp->qual[ncnt].sequence,
      apc.comp_type_cd = pathway_comp->qual[ncnt].comp_type_cd, apc.ref_prnt_ent_name = pathway_comp
      ->qual[ncnt].ref_prnt_ent_name, apc.ref_prnt_ent_id = pathway_comp->qual[ncnt].ref_prnt_ent_id,
      apc.parent_entity_name = pathway_comp->qual[ncnt].parent_entity_name, apc.age_units_cd =
      pathway_comp->qual[ncnt].age_units_cd, apc.parent_entity_id = pathway_comp->qual[ncnt].
      parent_entity_id,
      apc.orig_prnt_ent_id = pathway_comp->qual[ncnt].orig_prnt_ent_id, apc.comp_label = pathway_comp
      ->qual[ncnt].comp_label, apc.comp_status_cd = pathway_comp->qual[ncnt].comp_status_cd,
      apc.encntr_id = pathway_comp->qual[ncnt].encntr_id, apc.person_id = pathway_comp->qual[ncnt].
      person_id, apc.required_ind = pathway_comp->qual[ncnt].required_ind,
      apc.existing_ind = pathway_comp->qual[ncnt].existing_ind, apc.created_dt_tm = cnvtdatetime(
       pathway_comp->qual[ncnt].created_dt_tm), apc.included_ind = pathway_comp->qual[ncnt].
      included_ind,
      apc.included_dt_tm = cnvtdatetime(pathway_comp->qual[ncnt].included_dt_tm), apc.canceled_ind =
      pathway_comp->qual[ncnt].canceled_ind, apc.canceled_dt_tm = cnvtdatetime(pathway_comp->qual[
       ncnt].canceled_dt_tm),
      apc.activated_ind = pathway_comp->qual[ncnt].activated_ind, apc.activated_prsnl_id =
      pathway_comp->qual[ncnt].activated_prsnl_id, apc.activated_dt_tm = cnvtdatetime(pathway_comp->
       qual[ncnt].activated_dt_tm),
      apc.repeat_ind = pathway_comp->qual[ncnt].repeat_ind, apc.after_qty = pathway_comp->qual[ncnt].
      after_qty, apc.active_ind = 0,
      apc.last_action_seq = pathway_comp->qual[ncnt].last_action_seq, apc.updt_dt_tm = cnvtdatetime(
       pathway_comp->qual[ncnt].updt_dt_tm), apc.updt_id = pathway_comp->qual[ncnt].updt_id,
      apc.updt_task = pathway_comp->qual[ncnt].updt_task, apc.updt_cnt = pathway_comp->qual[ncnt].
      updt_cnt, apc.updt_applctx = pathway_comp->qual[ncnt].updt_applctx,
      apc.related_comp_id = pathway_comp->qual[pathway_comp->qual[ncnt].rc_seq].act_pw_comp_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO apc_failed
    ENDIF
   ENDIF
 ENDFOR
 SET ver_cnt = 0
 SET relationship_cnt = cnvtint(size(request->qual_relationship,5))
 FOR (x = 1 TO relationship_cnt)
   IF ((request->qual_relationship[x].pw_action_meaning != "NEW"))
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
    nextseqnum = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     ent_rel_id = cnvtint(nextseqnum)
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
#pw_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert pw cat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_catalog"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#atf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#atf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#acc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#acc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#apc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ver_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#apc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
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
