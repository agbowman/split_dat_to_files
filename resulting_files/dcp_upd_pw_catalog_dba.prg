CREATE PROGRAM dcp_upd_pw_catalog:dba
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
 RECORD pw_cat(
   1 pathway_catalog_id = f8
   1 long_text_id = f8
 )
 RECORD ver_cat(
   1 version_pw_cat_id = f8
   1 version = i4
   1 cfailed = c1
 )
 RECORD time_ids(
   1 time_ids[*]
     2 time_id = f8
 )
 RECORD nomen_comp_ids(
   1 nomen_comp_ids[*]
     2 nomen_comp_id = f8
 )
 RECORD focus_ids(
   1 focus_ids[*]
     2 focus_id = f8
 )
 RECORD comp_ids(
   1 comp_ids[*]
     2 comp_id = f8
 )
 RECORD comp_text_ids(
   1 comp_text_id = f8
   1 cond_note_id = f8
 )
 SET y = 0
 SET ncnt = 0
 SET new_cnt = 0
 SET old_cnt = 0
 SET id_cnt = 0
 SET newpc_cnt = 0
 SET oldpc_cnt = 0
 SET time_cnt = 0
 SET idpathway = 0
 SET idlongtext = 0
 SET idtimeframe = 0
 SET idcarecategory = 0
 SET idcomponent = 0
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SET ver_cat->cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pw_text_id = 0.0
 SET comp_text_id = 0.0
 SET cond_note_id = 0.0
 SET ent_rel_id = 0.0
 SET parent_entity_name = fillstring(32," ")
 SET tf_cnt = 0
 SET pf_cnt = 0
 SET tmpcompid = 0.0
 SET nomenclature_cnt = 0
 SET tmpnomencompcnt = 0
 SET found_ind = 0
 SET cc_cnt = 0
 SET pwc_cnt = 0
 SET ptf_seq = 0
 SET rc_seq = 0
 SET rc_id = 0
 SET tf_id = 0
 SET new_text = 0
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
  FROM pathway_catalog pc
  WHERE (pc.pathway_catalog_id=request->pathway_id)
  DETAIL
   pw_cat->pathway_catalog_id = pc.pathway_catalog_id, pw_cat->long_text_id = pc.long_text_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO pw_failed
 ENDIF
 IF ((request->version_flag > 0))
  EXECUTE dcp_ver_pw_catalog
 ENDIF
 IF ((request->pw_text != null)
  AND (pw_cat->long_text_id != 0))
  SET reply->status_data.status = "F"
  SET cfailed = "F"
  SET text_updt_cnt = 0
  SELECT INTO "nl:"
   lt.*
   FROM long_text lt
   WHERE (lt.long_text_id=pw_cat->long_text_id)
   HEAD REPORT
    text_updt_cnt = lt.updt_cnt
   WITH forupdate(lt), nocounter
  ;end select
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  IF ((text_updt_cnt != request->text_updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "locking"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM long_text lt
   SET lt.long_text = request->pw_text, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id =
    reqinfo->updt_id,
    lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
    updt_applctx
   WHERE (lt.long_text_id=pw_cat->long_text_id)
  ;end update
  IF (curqual=0)
   GO TO text_failed
  ENDIF
 ELSEIF ((request->pw_text != null)
  AND (pw_cat->long_text_id=0))
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
     = pw_cat->pathway_catalog_id,
    lt.long_text = request->pw_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET pw_cat->long_text_id = pw_text_id
  IF (curqual=0)
   GO TO text_failed
  ENDIF
  SET new_text = 1
 ELSEIF ((request->remove_text_ind=1))
  UPDATE  FROM long_text lt
   SET lt.active_ind = 0
   WHERE (lt.long_text_id=pw_cat->long_text_id)
  ;end update
  SET pw_cat->long_text_id = 0.0
 ENDIF
 IF ((request->modify_ind > 0))
  SET reply->status_data.status = "F"
  SET cfailed = "F"
  SET updt_cnt = 0
  SELECT INTO "nl:"
   pc.*
   FROM pathway_catalog pc
   WHERE (pc.pathway_catalog_id=request->pathway_id)
   HEAD REPORT
    updt_cnt = pc.updt_cnt
   WITH forupdate(pc), nocounter
  ;end select
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  IF ((updt_cnt != request->updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "locking"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_catalog"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM pathway_catalog pc
   SET pc.pathway_catalog_id = request->pathway_id, pc.cross_encntr_ind = request->cross_encntr_ind,
    pc.active_ind = request->active_ind,
    pc.description =
    IF ((request->description != null)) request->description
    ELSE pc.description
    ENDIF
    , pc.description_key =
    IF ((request->description != null)) trim(cnvtupper(request->description))
    ELSE pc.description_key
    ENDIF
    , pc.age_units_cd =
    IF ((request->age_units_cd != null)) request->age_units_cd
    ELSE pc.age_units_cd
    ENDIF
    ,
    pc.long_text_id = pw_cat->long_text_id, pc.version =
    IF ((request->version_flag > 0)) (pc.version+ 1)
    ELSE pc.version
    ENDIF
    , pc.beg_effective_dt_tm =
    IF ((request->version_flag > 0)) cnvtdatetime(curdate,curtime3)
    ELSE pc.beg_effective_dt_tm
    ENDIF
    ,
    pc.restrict_comp_add_ind = request->restrict_comp_add_ind, pc.restrict_tf_add_ind = request->
    restrict_tf_add_ind, pc.restrict_cc_add_ind = request->restrict_cc_add_ind,
    pc.pw_forms_ref_id =
    IF ((request->pw_forms_ref_id != null)) request->pw_forms_ref_id
    ELSE pc.pw_forms_ref_id
    ENDIF
    , pc.comp_forms_ref_id =
    IF ((request->comp_forms_ref_id != null)) request->comp_forms_ref_id
    ELSE pc.comp_forms_ref_id
    ENDIF
    , pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_cnt = (pc.updt_cnt+ 1),
    pc.updt_applctx = reqinfo->updt_applctx
   WHERE (pc.pathway_catalog_id=request->pathway_id)
  ;end update
  IF (curqual=0)
   GO TO pc_failed
  ENDIF
 ELSEIF ((request->modify_ind=0)
  AND new_text=1)
  UPDATE  FROM pathway_catalog pc
   SET pc.long_text_id = pw_text_id
   WHERE (pc.pathway_catalog_id=request->pathway_id)
  ;end update
  IF (curqual=0)
   GO TO pc_failed
  ENDIF
 ENDIF
 FOR (x = 1 TO request->nomen_cnt)
   IF ((request->qual_nomen[x].pathway_focus_id=0))
    SET new_cnt = (new_cnt+ 1)
   ELSE
    SET old_cnt = (old_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO new_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(focus_ids->focus_ids,x), focus_ids->focus_ids[x].focus_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO pf_seq_failed
  ENDIF
 ENDFOR
 FOR (pf_cnt = 1 TO request->nomen_cnt)
   CALL echo(build("MODIFTY_IND = ",request->qual_nomen[pf_cnt].modify_ind))
   CALL echo(build("PATHWAY_FOCUS_ID = ",request->qual_nomen[pf_cnt].pathway_focus_id))
   IF ((request->qual_nomen[pf_cnt].modify_ind > 0)
    AND (request->qual_nomen[pf_cnt].pathway_focus_id != 0)
    AND (request->qual_nomen[pf_cnt].remove_ind != 1))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     pf.*
     FROM pathway_focus pf
     WHERE (pf.pathway_focus_id=request->qual_nomen[pf_cnt].pathway_focus_id)
     HEAD REPORT
      updt_cnt = pf.updt_cnt
     WITH forupdate(pf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_nomen[pf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_focus"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM pathway_focus pf
     SET pf.pathway_level_ind = request->qual_nomen[pf_cnt].pathway_level_ind, pf.default_status_cd
       = request->qual_nomen[pf_cnt].default_status_cd, pf.sequence = request->qual_nomen[pf_cnt].
      sequence,
      pf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pf.updt_id = reqinfo->updt_id, pf.updt_task =
      reqinfo->updt_task,
      pf.updt_cnt = (pf.updt_cnt+ 1), pf.updt_applctx = reqinfo->updt_applctx
     WHERE (pf.pathway_focus_id=request->qual_nomen[pf_cnt].pathway_focus_id)
    ;end update
    IF (curqual=0)
     GO TO pf_failed
    ENDIF
   ELSEIF ((request->qual_nomen[pf_cnt].pathway_focus_id=0)
    AND (request->qual_nomen[pf_cnt].modify_ind > 0)
    AND (request->qual_nomen[pf_cnt].remove_ind=0))
    SET id_cnt = (id_cnt+ 1)
    SET focus_id = focus_ids->focus_ids[id_cnt].focus_id
    CALL echo(build("PATHWAY_FOCUS_ID = ",focus_id))
    CALL echo(build("PF_CNT",pf_cnt))
    INSERT  FROM pathway_focus pf
     SET pf.pathway_focus_id = focus_id, pf.pathway_level_ind = request->qual_nomen[pf_cnt].
      pathway_level_ind, pf.sequence = request->qual_nomen[pf_cnt].sequence,
      pf.pathway_catalog_id = request->pathway_id, pf.default_status_cd = request->qual_nomen[pf_cnt]
      .default_status_cd, pf.nomenclature_id = request->qual_nomen[pf_cnt].nomenclature_id,
      pf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pf.updt_id = reqinfo->updt_id, pf.updt_task =
      reqinfo->updt_task,
      pf.updt_cnt = 0, pf.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO pf_failed
    ENDIF
   ELSEIF ((request->qual_nomen[pf_cnt].pathway_focus_id > 0)
    AND (request->qual_nomen[pf_cnt].remove_ind=1))
    DELETE  FROM pathway_focus pf
     WHERE (pf.pathway_focus_id=request->qual_nomen[pf_cnt].pathway_focus_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     GO TO pf_del_failed
    ENDIF
   ENDIF
 ENDFOR
 SET new_cnt = 0
 SET old_cnt = 0
 SET id_cnt = 0
 FOR (x = 1 TO request->time_frame_cnt)
   IF ((request->qual_time_frame[x].time_frame_id=0))
    SET new_cnt = (new_cnt+ 1)
   ELSE
    SET old_cnt = (old_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO new_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(time_ids->time_ids,x), time_ids->time_ids[x].time_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO tf_seq_failed
  ENDIF
 ENDFOR
 FOR (tf_cnt = 1 TO request->time_frame_cnt)
   IF ((request->qual_time_frame[tf_cnt].modify_ind > 0)
    AND (request->qual_time_frame[tf_cnt].time_frame_id != 0))
    SET time_cnt = 0
    SET ptf_seq = request->qual_time_frame[tf_cnt].parent_tf_seq
    IF (ptf_seq > 0
     AND (ptf_seq <= request->time_frame_cnt))
     FOR (y = 1 TO request->time_frame_cnt)
      IF ((request->qual_time_frame[y].time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((ptf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].active_ind=1))
       IF ((request->qual_time_frame[y].time_frame_id != 0))
        SET ptf_id = request->qual_time_frame[y].time_frame_id
       ELSE
        SET ptf_id = time_ids->time_ids[time_cnt].time_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET ptf_id = 0
    ENDIF
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     tf.*
     FROM time_frame tf
     WHERE (tf.time_frame_id=request->qual_time_frame[tf_cnt].time_frame_id)
     HEAD REPORT
      updt_cnt = tf.updt_cnt
     WITH forupdate(tf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_time_frame[tf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM time_frame tf
     SET tf.time_frame_id = request->qual_time_frame[tf_cnt].time_frame_id, tf.description =
      IF ((request->qual_time_frame[tf_cnt].description != null)) request->qual_time_frame[tf_cnt].
       description
      ELSE tf.description
      ENDIF
      , tf.sequence =
      IF ((request->qual_time_frame[tf_cnt].sequence != null)) request->qual_time_frame[tf_cnt].
       sequence
      ELSE tf.sequence
      ENDIF
      ,
      tf.active_ind = request->qual_time_frame[tf_cnt].active_ind, tf.duration_qty =
      IF ((request->qual_time_frame[tf_cnt].duration_qty != null)) request->qual_time_frame[tf_cnt].
       duration_qty
      ELSE 0
      ENDIF
      , tf.age_units_cd =
      IF ((request->qual_time_frame[tf_cnt].age_units_cd != null)) request->qual_time_frame[tf_cnt].
       age_units_cd
      ELSE tf.age_units_cd
      ENDIF
      ,
      tf.continuous_ind =
      IF ((request->qual_time_frame[tf_cnt].continuous_ind != null)) request->qual_time_frame[tf_cnt]
       .continuous_ind
      ELSE tf.continuous_ind
      ENDIF
      , tf.start_ind =
      IF ((request->qual_time_frame[tf_cnt].start_ind != null)) request->qual_time_frame[tf_cnt].
       start_ind
      ELSE tf.start_ind
      ENDIF
      , tf.end_ind =
      IF ((request->qual_time_frame[tf_cnt].end_ind != null)) request->qual_time_frame[tf_cnt].
       end_ind
      ELSE tf.end_ind
      ENDIF
      ,
      tf.prnt_time_frame_id = ptf_id, tf.updt_dt_tm = cnvtdatetime(curdate,curtime3), tf.updt_id =
      reqinfo->updt_id,
      tf.updt_task = reqinfo->updt_task, tf.updt_cnt = (tf.updt_cnt+ 1), tf.updt_applctx = reqinfo->
      updt_applctx
     WHERE (tf.time_frame_id=request->qual_time_frame[tf_cnt].time_frame_id)
    ;end update
    IF (curqual=0)
     GO TO tf_failed
    ENDIF
   ELSEIF ((request->qual_time_frame[tf_cnt].time_frame_id=0)
    AND (request->qual_time_frame[tf_cnt].modify_ind > 0))
    SET id_cnt = (id_cnt+ 1)
    SET ptf_seq = request->qual_time_frame[tf_cnt].parent_tf_seq
    SET time_cnt = 0
    IF (ptf_seq > 0
     AND (ptf_seq <= request->time_frame_cnt))
     FOR (y = 1 TO request->time_frame_cnt)
      IF ((request->qual_time_frame[y].time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((ptf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].active_ind=1))
       IF ((request->qual_time_frame[y].time_frame_id != 0))
        SET ptf_id = request->qual_time_frame[y].time_frame_id
       ELSE
        SET ptf_id = time_ids->time_ids[time_cnt].time_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET ptf_id = 0
    ENDIF
    INSERT  FROM time_frame tf
     SET tf.time_frame_id = time_ids->time_ids[id_cnt].time_id, tf.description = request->
      qual_time_frame[tf_cnt].description, tf.pathway_catalog_id = request->pathway_id,
      tf.sequence = request->qual_time_frame[tf_cnt].sequence, tf.active_ind = request->
      qual_time_frame[tf_cnt].active_ind, tf.duration_qty = request->qual_time_frame[tf_cnt].
      duration_qty,
      tf.age_units_cd = request->qual_time_frame[tf_cnt].age_units_cd, tf.continuous_ind = request->
      qual_time_frame[tf_cnt].continuous_ind, tf.start_ind = request->qual_time_frame[tf_cnt].
      start_ind,
      tf.end_ind = request->qual_time_frame[tf_cnt].end_ind, tf.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), tf.updt_id = reqinfo->updt_id,
      tf.updt_task = reqinfo->updt_task, tf.updt_applctx = reqinfo->updt_applctx, tf.updt_cnt = 0,
      tf.prnt_time_frame_id = ptf_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO tf_failed
    ENDIF
   ENDIF
 ENDFOR
 FOR (cc_cnt = 1 TO request->care_category_cnt)
   IF ((request->qual_care_category[cc_cnt].modify_ind > 0)
    AND (request->qual_care_category[cc_cnt].care_category_id != 0))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     cc.*
     FROM care_category cc
     WHERE (cc.care_category_id=request->qual_care_category[cc_cnt].care_category_id)
     HEAD REPORT
      updt_cnt = cc.updt_cnt
     WITH forupdate(cc), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_care_category[cc_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "care_category"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM care_category cc
     SET cc.care_category_id = request->qual_care_category[cc_cnt].care_category_id, cc
      .care_category_cd =
      IF ((request->qual_care_category[cc_cnt].care_category_cd != null)) request->
       qual_care_category[cc_cnt].care_category_cd
      ELSE cc.care_category_cd
      ENDIF
      , cc.description =
      IF ((request->qual_care_category[cc_cnt].description != null)) request->qual_care_category[
       cc_cnt].description
      ELSE cc.description
      ENDIF
      ,
      cc.sequence =
      IF ((request->qual_care_category[cc_cnt].sequence != null)) request->qual_care_category[cc_cnt]
       .sequence
      ELSE cc.sequence
      ENDIF
      , cc.restrict_comp_add_ind = request->qual_care_category[cc_cnt].restrict_comp_add_ind, cc
      .comp_add_variance_ind = request->qual_care_category[cc_cnt].comp_add_variance_ind,
      cc.active_ind = request->qual_care_category[cc_cnt].active_ind, cc.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), cc.updt_id = reqinfo->updt_id,
      cc.updt_task = reqinfo->updt_task, cc.updt_cnt = (cc.updt_cnt+ 1), cc.updt_applctx = reqinfo->
      updt_applctx
     WHERE (cc.care_category_id=request->qual_care_category[cc_cnt].care_category_id)
    ;end update
    IF (curqual=0)
     GO TO cc_failed
    ENDIF
   ELSEIF ((request->qual_care_category[cc_cnt].modify_ind > 0)
    AND (request->qual_care_category[cc_cnt].care_category_id=0))
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      request->qual_care_category[cc_cnt].care_category_id = nextseqnum
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO cc_seq_failed
    ENDIF
    INSERT  FROM care_category cc
     SET cc.care_category_id = request->qual_care_category[cc_cnt].care_category_id, cc
      .care_category_cd = request->qual_care_category[cc_cnt].care_category_cd, cc.description =
      request->qual_care_category[cc_cnt].description,
      cc.pathway_catalog_id = request->pathway_id, cc.sequence = request->qual_care_category[cc_cnt].
      sequence, cc.restrict_comp_add_ind = request->qual_care_category[cc_cnt].restrict_comp_add_ind,
      cc.comp_add_variance_ind = request->qual_care_category[cc_cnt].comp_add_variance_ind, cc
      .active_ind = request->qual_care_category[cc_cnt].active_ind, cc.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cc.updt_id = reqinfo->updt_id, cc.updt_task = reqinfo->updt_task, cc.updt_applctx = reqinfo->
      updt_applctx,
      cc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO cc_failed
    ENDIF
   ENDIF
 ENDFOR
 SET id_cnt = 0
 FOR (x = 1 TO request->component_cnt)
   IF ((request->qual_component[x].component_id=0))
    SET newpc_cnt = (newpc_cnt+ 1)
   ELSE
    SET oldpc_cnt = (oldpc_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO newpc_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(comp_ids->comp_ids,x), comp_ids->comp_ids[x].comp_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO comp_seq_failed
  ENDIF
 ENDFOR
 FOR (pwc_cnt = 1 TO request->component_cnt)
  IF ((request->qual_component[pwc_cnt].modify_ind > 0)
   AND (request->qual_component[pwc_cnt].component_id != 0))
   IF ((request->qual_component[pwc_cnt].comp_type_mean="NOTE")
    AND (request->qual_component[pwc_cnt].comp_text != null))
    SELECT INTO "nl:"
     FROM pathway_comp pwc
     WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      comp_text_ids->comp_text_id = pwc.parent_entity_id
     WITH nocounter
    ;end select
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     lt.*
     FROM long_text lt
     WHERE (lt.long_text_id=comp_text_ids->comp_text_id)
     HEAD REPORT
      updt_cnt = lt.updt_cnt
     WITH forupdate(lt), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_component[pwc_cnt].text_updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.long_text = request->qual_component[pwc_cnt].comp_text, lt.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
      updt_applctx
     WHERE (lt.long_text_id=comp_text_ids->comp_text_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO comp_text_failed
    ENDIF
   ENDIF
   IF ((request->qual_component[pwc_cnt].cond_ind=1)
    AND (request->qual_component[pwc_cnt].cond_note_id != 0.0)
    AND (request->qual_component[pwc_cnt].cond_note != null))
    SELECT INTO "nl:"
     FROM pathway_comp pwc
     WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      comp_text_ids->cond_note_id = pwc.cond_note_id
     WITH nocounter
    ;end select
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     lt.*
     FROM long_text lt
     WHERE (lt.long_text_id=comp_text_ids->cond_note_id)
     HEAD REPORT
      updt_cnt = lt.updt_cnt
     WITH forupdate(lt), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_component[pwc_cnt].ctext_updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.long_text = request->qual_component[pwc_cnt].cond_note, lt.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
      updt_applctx
     WHERE (lt.long_text_id=comp_text_ids->cond_note_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO comp_text_failed
    ENDIF
   ELSEIF ((request->qual_component[pwc_cnt].cond_ind=1)
    AND (request->qual_component[pwc_cnt].cond_note != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      comp_text_ids->cond_note_id = nextseqnum
     WITH format
    ;end select
    IF ((comp_text_ids->cond_note_id=0.0))
     GO TO comp_text_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = comp_text_ids->cond_note_id, lt.parent_entity_name = "PATHWAY_COMP", lt
      .parent_entity_id = request->qual_component[pwc_cnt].component_id,
      lt.long_text = request->qual_component[pwc_cnt].cond_note, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO comp_text_failed
    ENDIF
   ELSEIF ((request->qual_component[pwc_cnt].cond_note != null)
    AND (request->qual_component[pwc_cnt].cond_ind=0))
    SELECT INTO "nl:"
     FROM pathway_comp pwc
     WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
     DETAIL
      comp_text_ids->cond_note_id = pwc.cond_note_id
     WITH nocounter
    ;end select
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     lt.*
     FROM long_text lt
     WHERE (lt.long_text_id=comp_text_ids->cond_note_id)
     HEAD REPORT
      updt_cnt = lt.updt_cnt
     WITH forupdate(lt), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_component[pwc_cnt].ctext_updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.active_ind = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
      updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
      updt_applctx
     WHERE (lt.long_text_id=comp_text_ids->cond_note_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO comp_text_failed
    ENDIF
    SET comp_text_ids->cond_note_id = 0.0
   ENDIF
   FOR (y = 1 TO request->care_category_cnt)
     IF ((request->qual_care_category[y].sequence=request->qual_component[pwc_cnt].care_category_seq)
      AND (request->qual_care_category[y].active_ind=1))
      SET cc_seq = y
     ENDIF
   ENDFOR
   SET time_cnt = 0
   SET tf_seq = request->qual_component[pwc_cnt].time_frame_seq
   IF (tf_seq > 0
    AND (tf_seq <= request->time_frame_cnt))
    FOR (y = 1 TO request->time_frame_cnt)
     IF ((request->qual_time_frame[y].time_frame_id=0))
      SET time_cnt = (time_cnt+ 1)
     ENDIF
     IF ((tf_seq=request->qual_time_frame[y].sequence)
      AND (request->qual_time_frame[y].active_ind=1))
      IF ((request->qual_time_frame[y].time_frame_id != 0))
       SET tf_id = request->qual_time_frame[y].time_frame_id
      ELSE
       SET tf_id = time_ids->time_ids[time_cnt].time_id
      ENDIF
     ENDIF
    ENDFOR
   ELSE
    SET tf_id = 0
   ENDIF
   SET rc_seq = request->qual_component[pwc_cnt].related_comp_seq
   IF (rc_seq > 0
    AND (rc_seq <= request->component_cnt)
    AND rc_seq <= oldpc_cnt)
    SET rc_id = request->qual_component[rc_seq].component_id
   ELSEIF (rc_seq > 0
    AND (rc_seq <= request->component_cnt)
    AND rc_seq > oldpc_cnt)
    SET rc_id = comp_ids->comp_ids[(rc_seq - oldpc_cnt)].comp_id
   ELSE
    SET rc_id = 0
   ENDIF
   SET reply->status_data.status = "F"
   SET cfailed = "F"
   SET updt_cnt = 0
   SELECT INTO "nl:"
    pwc.*
    FROM pathway_comp pwc
    WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
    HEAD REPORT
     updt_cnt = pwc.updt_cnt
    WITH forupdate(pwc), nocounter
   ;end select
   IF (curqual=0)
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   IF ((updt_cnt != request->qual_component[pwc_cnt].updt_cnt))
    SET reply->status_data.subeventstatus[1].operationname = "locking"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_catalog"
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM pathway_comp pwc
    SET pwc.pathway_comp_id = request->qual_component[pwc_cnt].component_id, pwc.care_category_id =
     request->qual_care_category[cc_seq].care_category_id, pwc.time_frame_id = tf_id,
     pwc.sequence =
     IF ((request->qual_component[pwc_cnt].sequence != null)) request->qual_component[pwc_cnt].
      sequence
     ELSE pwc.sequence
     ENDIF
     , pwc.active_ind = request->qual_component[pwc_cnt].active_ind, pwc.comp_label =
     IF ((request->qual_component[pwc_cnt].comp_label != null)) request->qual_component[pwc_cnt].
      comp_label
     ELSE pwc.comp_label
     ENDIF
     ,
     pwc.required_ind = request->qual_component[pwc_cnt].required_ind, pwc.include_ind = request->
     qual_component[pwc_cnt].include_ind, pwc.repeat_ind =
     IF ((request->qual_component[pwc_cnt].repeat_ind != null)) request->qual_component[pwc_cnt].
      repeat_ind
     ELSE pwc.repeat_ind
     ENDIF
     ,
     pwc.order_sentence_id = request->qual_component[pwc_cnt].order_sentence_id, pwc.after_qty =
     IF ((request->qual_component[pwc_cnt].after_qty != null)) request->qual_component[pwc_cnt].
      after_qty
     ELSE 0
     ENDIF
     , pwc.age_units_cd =
     IF ((request->qual_component[pwc_cnt].age_units_cd != null)) request->qual_component[pwc_cnt].
      age_units_cd
     ELSE 0
     ENDIF
     ,
     pwc.related_comp_id =
     IF (rc_seq != null) rc_id
     ELSE pwc.related_comp_id
     ENDIF
     , pwc.duration_qty =
     IF ((request->qual_component[pwc_cnt].duration_qty != null)) request->qual_component[pwc_cnt].
      duration_qty
     ELSE 0
     ENDIF
     , pwc.duration_unit_cd =
     IF ((request->qual_component[pwc_cnt].duration_unit_cd != null)) request->qual_component[pwc_cnt
      ].duration_unit_cd
     ELSE 0
     ENDIF
     ,
     pwc.linked_to_tf_ind =
     IF ((request->qual_component[pwc_cnt].linked_to_tf_ind != null)) request->qual_component[pwc_cnt
      ].linked_to_tf_ind
     ELSE 0
     ENDIF
     , pwc.task_assay_cd =
     IF ((request->qual_component[pwc_cnt].task_assay_cd != null)) request->qual_component[pwc_cnt].
      task_assay_cd
     ELSE pwc.task_assay_cd
     ENDIF
     , pwc.event_cd = request->qual_component[pwc_cnt].event_cd,
     pwc.result_type_cd =
     IF ((request->qual_component[pwc_cnt].result_type_cd != null)) request->qual_component[pwc_cnt].
      result_type_cd
     ELSE pwc.result_type_cd
     ENDIF
     , pwc.outcome_operator_cd =
     IF ((request->qual_component[pwc_cnt].outcome_operator_cd != null)) request->qual_component[
      pwc_cnt].outcome_operator_cd
     ELSE pwc.outcome_operator_cd
     ENDIF
     , pwc.result_value =
     IF ((request->qual_component[pwc_cnt].result_value != null)) request->qual_component[pwc_cnt].
      result_value
     ELSE 0
     ENDIF
     ,
     pwc.result_units_cd =
     IF ((request->qual_component[pwc_cnt].result_units_cd != null)) request->qual_component[pwc_cnt]
      .result_units_cd
     ELSE pwc.result_units_cd
     ENDIF
     , pwc.capture_variance_ind =
     IF ((request->qual_component[pwc_cnt].capture_variance_ind != null)) request->qual_component[
      pwc_cnt].capture_variance_ind
     ELSE pwc.capture_variance_ind
     ENDIF
     , pwc.variance_required_ind =
     IF ((request->qual_component[pwc_cnt].variance_required_ind != null)) request->qual_component[
      pwc_cnt].variance_required_ind
     ELSE pwc.variance_required_ind
     ENDIF
     ,
     pwc.dcp_forms_ref_id =
     IF ((request->qual_component[pwc_cnt].dcp_forms_ref_id != null)) request->qual_component[pwc_cnt
      ].dcp_forms_ref_id
     ELSE 0
     ENDIF
     , pwc.outcome_forms_ref_id =
     IF ((request->qual_component[pwc_cnt].outcome_forms_ref_id != null)) request->qual_component[
      pwc_cnt].outcome_forms_ref_id
     ELSE 0
     ENDIF
     , pwc.cond_ind = request->qual_component[pwc_cnt].cond_ind,
     pwc.cond_desc = request->qual_component[pwc_cnt].cond_desc, pwc.cond_note_id = comp_text_ids->
     cond_note_id, pwc.cond_module_name = request->qual_component[pwc_cnt].cond_module_name,
     pwc.cond_false_ind = request->qual_component[pwc_cnt].cond_false_ind, pwc.rrf_age_qty =
     IF ((request->qual_component[pwc_cnt].rrf_age_qty != null)) request->qual_component[pwc_cnt].
      rrf_age_qty
     ELSE pwc.rrf_age_qty
     ENDIF
     , pwc.rrf_age_units_cd =
     IF ((request->qual_component[pwc_cnt].rrf_age_units_cd != null)) request->qual_component[pwc_cnt
      ].rrf_age_units_cd
     ELSE pwc.rrf_age_units_cd
     ENDIF
     ,
     pwc.rrf_sex_cd =
     IF ((request->qual_component[pwc_cnt].rrf_sex_cd != null)) request->qual_component[pwc_cnt].
      rrf_sex_cd
     ELSE pwc.rrf_sex_cd
     ENDIF
     , pwc.reference_task_id =
     IF ((request->qual_component[pwc_cnt].var_reference_task_id != null)) request->qual_component[
      pwc_cnt].var_reference_task_id
     ELSE pwc.reference_task_id
     ENDIF
     , pwc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pwc.updt_id = reqinfo->updt_id, pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->
     updt_applctx,
     pwc.updt_cnt = (pwc.updt_cnt+ 1)
    WHERE (pwc.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
   ;end update
   IF (curqual=0)
    GO TO pwc_failed
   ENDIF
  ELSEIF ((request->qual_component[pwc_cnt].modify_ind > 0)
   AND (request->qual_component[pwc_cnt].component_id=0))
   SET id_cnt = (id_cnt+ 1)
   IF ((request->qual_component[pwc_cnt].comp_type_mean="NOTE")
    AND (request->qual_component[pwc_cnt].comp_text != null))
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
       = comp_ids->comp_ids[id_cnt].comp_id,
      lt.long_text = request->qual_component[pwc_cnt].comp_text, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
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
   IF ((request->qual_component[pwc_cnt].cond_ind=1)
    AND (request->qual_component[pwc_cnt].cond_note != null))
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
       = comp_ids->comp_ids[id_cnt].comp_id,
      lt.long_text = request->qual_component[pwc_cnt].cond_note, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
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
   SET parent_entity_name = fillstring(32," ")
   SET parent_entity_id = 0.0
   SET comp_type_cd = 0.0
   IF ((request->qual_component[pwc_cnt].comp_type_mean="NOTE"))
    SET parent_entity_name = "LONG_TEXT"
    SET parent_entity_id = comp_text_id
    SET comp_type_cd = note_type_cd
   ENDIF
   IF ((request->qual_component[pwc_cnt].comp_type_mean="ORDER CREATE"))
    SET parent_entity_name = "ORDER_CATALOG_SYNONYM"
    SET parent_entity_id = request->qual_component[pwc_cnt].order_catalog_synonym
    SET comp_type_cd = order_create_type_cd
   ENDIF
   IF ((request->qual_component[pwc_cnt].comp_type_mean="OUTCOME CREA"))
    SET parent_entity_name = "ORDER_CATALOG_SYNONYM"
    SET parent_entity_id = request->qual_component[pwc_cnt].order_catalog_synonym
    SET comp_type_cd = outcome_create_type_cd
   ENDIF
   IF ((request->qual_component[pwc_cnt].comp_type_mean="TASK CREATE"))
    SET parent_entity_name = "ORDER_TASK"
    SET parent_entity_id = request->qual_component[pwc_cnt].reference_task_id
    SET comp_type_cd = task_create_type_cd
   ENDIF
   IF ((request->qual_component[pwc_cnt].comp_type_mean="RESULT OUTCO"))
    SET comp_type_cd = result_outcome_type_cd
   ENDIF
   IF ((request->qual_component[pwc_cnt].comp_type_mean="LABEL"))
    SET comp_type_cd = label_type_cd
   ENDIF
   FOR (y = 1 TO request->care_category_cnt)
     IF ((request->qual_care_category[y].sequence=request->qual_component[pwc_cnt].care_category_seq)
      AND (request->qual_care_category[y].active_ind=1))
      SET cc_seq = y
     ENDIF
   ENDFOR
   SET time_cnt = 0
   SET tf_seq = request->qual_component[pwc_cnt].time_frame_seq
   IF (tf_seq > 0
    AND (tf_seq <= request->time_frame_cnt))
    FOR (y = 1 TO request->time_frame_cnt)
     IF ((request->qual_time_frame[y].time_frame_id=0))
      SET time_cnt = (time_cnt+ 1)
     ENDIF
     IF ((tf_seq=request->qual_time_frame[y].sequence)
      AND (request->qual_time_frame[y].active_ind=1))
      IF ((request->qual_time_frame[y].time_frame_id != 0))
       SET tf_id = request->qual_time_frame[y].time_frame_id
      ELSE
       SET tf_id = time_ids->time_ids[time_cnt].time_id
      ENDIF
     ENDIF
    ENDFOR
   ELSE
    SET tf_id = 0
   ENDIF
   SET rc_seq = request->qual_component[pwc_cnt].related_comp_seq
   IF (rc_seq > 0
    AND (rc_seq <= request->component_cnt)
    AND rc_seq <= oldpc_cnt)
    SET rc_id = request->qual_component[rc_seq].component_id
   ELSEIF (rc_seq > 0
    AND (rc_seq <= request->component_cnt)
    AND rc_seq > oldpc_cnt)
    SET rc_id = comp_ids->comp_ids[(rc_seq - oldpc_cnt)].comp_id
   ELSE
    SET rc_id = 0
   ENDIF
   SET tmpcompid = comp_ids->comp_ids[id_cnt].comp_id
   INSERT  FROM pathway_comp pwc
    SET pwc.pathway_comp_id = comp_ids->comp_ids[id_cnt].comp_id, pwc.pathway_catalog_id = request->
     pathway_id, pwc.care_category_id = request->qual_care_category[cc_seq].care_category_id,
     pwc.time_frame_id = tf_id, pwc.sequence = request->qual_component[pwc_cnt].sequence, pwc
     .active_ind = request->qual_component[pwc_cnt].active_ind,
     pwc.comp_type_cd = comp_type_cd, pwc.parent_entity_name = parent_entity_name, pwc
     .parent_entity_id = parent_entity_id,
     pwc.comp_label = request->qual_component[pwc_cnt].comp_label, pwc.required_ind = request->
     qual_component[pwc_cnt].required_ind, pwc.include_ind = request->qual_component[pwc_cnt].
     include_ind,
     pwc.repeat_ind = request->qual_component[pwc_cnt].repeat_ind, pwc.order_sentence_id = request->
     qual_component[pwc_cnt].order_sentence_id, pwc.after_qty = request->qual_component[pwc_cnt].
     after_qty,
     pwc.age_units_cd = request->qual_component[pwc_cnt].age_units_cd, pwc.duration_qty = request->
     qual_component[pwc_cnt].duration_qty, pwc.duration_unit_cd = request->qual_component[pwc_cnt].
     duration_unit_cd,
     pwc.task_assay_cd = request->qual_component[pwc_cnt].task_assay_cd, pwc.event_cd = request->
     qual_component[pwc_cnt].event_cd, pwc.result_type_cd = request->qual_component[pwc_cnt].
     result_type_cd,
     pwc.outcome_operator_cd = request->qual_component[pwc_cnt].outcome_operator_cd, pwc.result_value
      = request->qual_component[pwc_cnt].result_value, pwc.result_units_cd = request->qual_component[
     pwc_cnt].result_units_cd,
     pwc.capture_variance_ind = request->qual_component[pwc_cnt].capture_variance_ind, pwc
     .variance_required_ind = request->qual_component[pwc_cnt].variance_required_ind, pwc
     .dcp_forms_ref_id = request->qual_component[pwc_cnt].dcp_forms_ref_id,
     pwc.cond_ind = request->qual_component[pwc_cnt].cond_ind, pwc.cond_desc = request->
     qual_component[pwc_cnt].cond_desc, pwc.cond_note_id = cond_note_id,
     pwc.cond_module_name = request->qual_component[pwc_cnt].cond_module_name, pwc.cond_false_ind =
     request->qual_component[pwc_cnt].cond_false_ind, pwc.rrf_age_qty = request->qual_component[
     pwc_cnt].rrf_age_qty,
     pwc.rrf_age_units_cd = request->qual_component[pwc_cnt].rrf_age_units_cd, pwc.rrf_sex_cd =
     request->qual_component[pwc_cnt].rrf_sex_cd, pwc.related_comp_id = rc_id,
     pwc.reference_task_id = request->qual_component[pwc_cnt].var_reference_task_id, pwc.updt_dt_tm
      = cnvtdatetime(curdate,curtime3), pwc.updt_id = reqinfo->updt_id,
     pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->updt_applctx, pwc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO pwc_failed
   ENDIF
  ENDIF
  IF ((request->qual_component[pwc_cnt].nomen_comp_cnt > 0)
   AND (request->qual_component[pwc_cnt].component_id != 0))
   SELECT INTO "nl:"
    FROM pathway_comp_focus_r pcf
    WHERE (pcf.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
    HEAD REPORT
     x = 0
    DETAIL
     x = (x+ 1), stat = alterlist(nomen_comp_ids->nomen_comp_ids,x), nomen_comp_ids->nomen_comp_ids[x
     ].nomen_comp_id = pcf.nomenclature_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET tmpnomencompcnt = 0
   ELSE
    SET tmpnomencompcnt = size(nomen_comp_ids->nomen_comp_ids,5)
   ENDIF
   FOR (nomvar = 1 TO request->qual_component[pwc_cnt].nomen_comp_cnt)
     IF ((request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].remove_ind > 0)
      AND (request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].nomenclature_id > 0)
      AND (request->qual_component[pwc_cnt].component_id > 0)
      AND (request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].modify_ind=0))
      DELETE  FROM pathway_comp_focus_r pcf
       WHERE (pcf.nomenclature_id=request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].
       nomenclature_id)
        AND (pcf.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       GO TO nomen_c_del_failed
      ENDIF
     ELSEIF ((request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].modify_ind > 0))
      SET found_ind = 0
      FOR (x = 1 TO tmpnomencompcnt)
        IF ((request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].nomenclature_id=nomen_comp_ids
        ->nomen_comp_ids[x].nomen_comp_id))
         SET found_ind = 1
        ENDIF
      ENDFOR
      IF (found_ind != 1)
       INSERT  FROM pathway_comp_focus_r pcf
        SET pcf.pathway_comp_id = request->qual_component[pwc_cnt].component_id, pcf.nomenclature_id
          = request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].nomenclature_id, pcf.primary_ind
          = request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].primary_ind,
         pcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcf.updt_id = reqinfo->updt_id, pcf
         .updt_task = reqinfo->updt_task,
         pcf.updt_cnt = 0, pcf.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO nomen_c_insert_fail
       ENDIF
      ELSEIF (found_ind=1)
       UPDATE  FROM pathway_comp_focus_r pcf
        SET pcf.primary_ind = request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].primary_ind,
         pcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcf.updt_id = reqinfo->updt_id,
         pcf.updt_task = reqinfo->updt_task, pcf.updt_cnt = (pcf.updt_cnt+ 1), pcf.updt_applctx =
         reqinfo->updt_applctx
        WHERE (pcf.nomenclature_id=request->qual_component[pwc_cnt].qual_comp_nomen[nomvar].
        nomenclature_id)
         AND (pcf.pathway_comp_id=request->qual_component[pwc_cnt].component_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        GO TO nomen_c_upd_failed
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 FOR (x = 1 TO request->relationship_cnt)
   IF ((request->qual_relationship[x].dcp_entity_reltn_id=0))
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
     SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = request->qual_relationship[x].
      relationship_mean, der.entity1_id = request->pathway_id,
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
   ELSEIF ((request->qual_relationship[x].remove_ind=1)
    AND (request->qual_relationship[x].dcp_entity_reltn_id > 0))
    UPDATE  FROM dcp_entity_reltn der
     SET der.active_ind = 0
     WHERE (der.dcp_entity_reltn_id=request->qual_relatonship[x].dcp_entity_reltn_id)
    ;end update
   ENDIF
 ENDFOR
 IF ((request->version_flag > 0))
  IF ((ver_cat->version_pw_cat_id > 0)
   AND (ver_cat->version > 0))
   UPDATE  FROM pathway_catalog pc
    SET pc.version = ver_cat->version
    WHERE (pc.pathway_catalog_id=ver_cat->version_pw_cat_id)
   ;end update
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#nomen_c_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "delete comp nomen"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_id"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#nomen_c_insert_fail
 SET reply->status_data.subeventstatus[1].operationname = "insert comp nomen"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_id"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#nomen_c_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "update comp nomen"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_id"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert pw cat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_catalog"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#der_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "der sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#der_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert der"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_entity_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#tf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "pathway focus sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "focus_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#tf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pf_failed
 SET reply->status_data.subeventstatus[1].operationname = "update/insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pf_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "delete"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#cc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cc sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#cc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "care_category"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#comp_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp ref seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pwc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#pw_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw_id"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_id"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pw_catalog"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 CALL echo("exiting script")
 CALL echo(reply->status_data.subeventstatus[1].operationname)
 CALL echo(reply->status_data.subeventstatus[1].operationstatus)
 CALL echo(reply->status_data.subeventstatus[1].targetobjectname)
 CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 IF (((cfailed="T") OR ((ver_cat->cfailed="T"))) )
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->pathway_id = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->pathway_id = request->pathway_id
 ENDIF
END GO
