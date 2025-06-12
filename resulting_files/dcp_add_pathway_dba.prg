CREATE PROGRAM dcp_add_pathway:dba
 SET ncnt = 0
 SET ent_rel_id = 0.0
 SET idpathway = 0
 SET idpathwayaction = 0
 SET idacttimeframe = 0
 SET idactcarecat = 0
 SET idactpwcomp = 0
 SET idpwcompaction = 0
 SET idactpwfocus = 0
 SET idactpwcompfocus = 0
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->subeventstatus,1)
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pw_text_id = 0.0
 SET reason_text_id = 0.0
 SET action_text_id = 0.0
 SET pw_status_code = 0.0
 SET start_date_time = 0.0
 SET temp_dt_tm = fillstring(22," ")
 SET cnt1 = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET comp_status_code = 0.0
 SET activated_date_time = 0.0
 SET activated_id = 0
 SET parent_entity_id = 0.0
 SET parent_entity_name = fillstring(32," ")
 SET ref_prnt_ent_name = fillstring(32," ")
 SET pw_cond_note_id = 0
 SET pw_event_cnt = 0
 SET comp_event_cnt = 0
 SET code_set = 16769
 SET cdf_meaning = "STARTED"
 EXECUTE cpm_get_cd_for_cdf
 SET started_type_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "INCLUDED"
 EXECUTE cpm_get_cd_for_cdf
 SET included_type_cd = code_value
 SET code_set = 16809
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_type_cd = code_value
 SET code_set = 16829
 SET cdf_meaning = "CREATE"
 EXECUTE cpm_get_cd_for_cdf
 SET create_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "EXCLUDED"
 EXECUTE cpm_get_cd_for_cdf
 SET excluded_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "ACTIVATED"
 EXECUTE cpm_get_cd_for_cdf
 SET activated_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "NOTE"
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "RESULT OUTCO"
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
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
 IF ((request->comment_text != null))
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
   SET lt.long_text_id = pw_text_id, lt.parent_entity_name = "PATHWAY", lt.parent_entity_id = request
    ->pathway_id,
    lt.long_text = request->comment_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO text_cmmnt_failed
  ENDIF
 ENDIF
 SET temp_dt_tm = format(1,";;q")
 IF ((request->started_ind=1))
  SET pw_status_code = started_type_cd
  SET start_date_time = cnvtdatetime(curdate,curtime3)
 ELSE
  SET pw_status_code = ordered_type_cd
  SET start_date_time = cnvtdatetime(temp_dt_tm)
 ENDIF
 DECLARE cross_encntr_ind = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM pathway_catalog pc
  WHERE (pc.pathway_catalog_id=request->pathway_catalog_id)
  DETAIL
   cross_encntr_ind = pc.cross_encntr_ind
  WITH nocounter
 ;end select
 INSERT  FROM pathway pw
  SET pw.pathway_id = request->pathway_id, pw.cross_encntr_ind = cross_encntr_ind, pw.person_id =
   request->person_id,
   pw.started_ind = request->started_ind, pw.pathway_catalog_id = request->pathway_catalog_id, pw
   .pw_cat_version = request->pw_cat_version,
   pw.description = request->description, pw.age_units_cd = request->age_units_cd, pw
   .restrict_comp_add_ind = request->restrict_comp_add_ind,
   pw.restrict_tf_add_ind = request->restrict_tf_add_ind, pw.restrict_cc_add_ind = request->
   restrict_cc_add_ind, pw.pw_forms_ref_id = request->pw_forms_ref_id,
   pw.comp_forms_ref_id = request->comp_forms_ref_id, pw.calc_end_dt_tm = cnvtdatetime(request->
    calc_end_dt_tm), pw.pw_status_cd = pw_status_code,
   pw.long_text_id = pw_text_id, pw.start_dt_tm = cnvtdatetime(start_date_time), pw.status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   pw.status_prsnl_id = reqinfo->updt_id, pw.order_dt_tm = cnvtdatetime(curdate,curtime3), pw
   .dc_reason_cd = 0,
   pw.actual_end_dt_tm = cnvtdatetime(temp_dt_tm), pw.ended_ind = 0, pw.discontinued_ind = 0,
   pw.discontinued_dt_tm = cnvtdatetime(temp_dt_tm), pw.last_action_seq = 1, pw.version = 1,
   pw.version_pathway_id = 0, pw.beg_effective_dt_tm = cnvtdatetime(temp_dt_tm), pw
   .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   pw.active_ind = 1, pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_id = reqinfo->updt_id,
   pw.updt_task = reqinfo->updt_task, pw.updt_cnt = 0, pw.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO text_pw_failed
 ENDIF
 SET pw_event_cnt = size(request->variance_event_list,5)
 SET stat = alterlist(reply->variance_event_list,pw_event_cnt)
 FOR (x = 1 TO pw_event_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     reply->variance_event_list[x].pw_variance_reltn_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO pvr_seq_failed
   ENDIF
   IF ((request->variance_event_list[x].reason_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      reason_text_id = nextseqnum
     WITH format
    ;end select
    IF (reason_text_id=0.0)
     GO TO text_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = reason_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
      .parent_entity_id = reply->variance_event_list[x].pw_variance_reltn_id,
      lt.long_text = request->variance_event_list[x].reason_text, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO var_reason_text_failed
    ENDIF
   ENDIF
   IF ((request->variance_event_list[x].action_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      action_text_id = nextseqnum
     WITH format
    ;end select
    IF (action_text_id=0.0)
     GO TO text_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = action_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
      .parent_entity_id = reply->variance_event_list[x].pw_variance_reltn_id,
      lt.long_text = request->variance_event_list[x].action_text, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO var_action_text_failed
    ENDIF
   ENDIF
   INSERT  FROM pw_variance_reltn pvr
    SET pvr.pw_variance_reltn_id = reply->variance_event_list[x].pw_variance_reltn_id, pvr
     .parent_entity_name = request->variance_event_list[x].parent_entity_name, pvr.parent_entity_id
      = request->variance_event_list[x].parent_entity_id,
     pvr.event_id = request->variance_event_list[x].event_id, pvr.pathway_id = request->pathway_id,
     pvr.variance_type_cd = request->variance_event_list[x].variance_type_cd,
     pvr.reason_cd = request->variance_event_list[x].reason_cd, pvr.reason_text_id = reason_text_id,
     pvr.action_cd = request->variance_event_list[x].action_cd,
     pvr.action_text_id = action_text_id, pvr.outcome_operator_cd = request->variance_event_list[x].
     outcome_operator_cd, pvr.result_value = request->variance_event_list[x].result_value,
     pvr.result_units_cd = request->variance_event_list[x].result_units_cd, pvr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), pvr.updt_id = reqinfo->updt_id,
     pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = 0, pvr.updt_applctx = reqinfo->updt_applctx,
     pvr.variance_dt_tm = cnvtdatetime(curdate,curtime3), pvr.active_ind = 1
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO pvr_failed
   ENDIF
 ENDFOR
 INSERT  FROM pathway_action pa
  SET pa.pathway_id = request->pathway_id, pa.pw_action_seq = 1, pa.pw_status_cd = pw_status_code,
   pa.action_type_cd = order_type_cd, pa.action_dt_tm = cnvtdatetime(curdate,curtime3), pa
   .action_prsnl_id = reqinfo->updt_id,
   pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
   reqinfo->updt_task,
   pa.updt_cnt = 0, pa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 SET cnt1 = request->time_frame_cnt
 SET stat = alterlist(reply->qual_time_frame,cnt1)
 SET reply->time_frame_cnt = cnt1
 FOR (x = 1 TO request->time_frame_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    reply->qual_time_frame[x].act_time_frame_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO atf_seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO request->time_frame_cnt)
   SET ptf_seq = request->qual_time_frame[x].parent_tf_seq
   IF (ptf_seq > 0
    AND (ptf_seq <= request->time_frame_cnt))
    SET ptf_id = reply->qual_time_frame[ptf_seq].act_time_frame_id
   ELSE
    SET ptf_id = 0
   ENDIF
   INSERT  FROM act_time_frame atf
    SET atf.act_time_frame_id = reply->qual_time_frame[x].act_time_frame_id, atf.time_frame_id =
     request->qual_time_frame[x].time_frame_id, atf.description = request->qual_time_frame[x].
     description,
     atf.sequence = request->qual_time_frame[x].sequence, atf.duration_qty = request->
     qual_time_frame[x].duration_qty, atf.age_units_cd = request->qual_time_frame[x].age_units_cd,
     atf.start_ind = request->qual_time_frame[x].start_ind, atf.calc_start_dt_tm = cnvtdatetime(
      request->qual_time_frame[x].calc_start_dt_tm), atf.calc_end_dt_tm = cnvtdatetime(request->
      qual_time_frame[x].calc_end_dt_tm),
     atf.continuous_ind = request->qual_time_frame[x].continuous_ind, atf.end_ind = request->
     qual_time_frame[x].end_ind, atf.parent_tf_id = ptf_id,
     atf.pathway_id = request->pathway_id, atf.active_ind = request->qual_time_frame[x].active_ind,
     atf.actual_start_dt_tm = cnvtdatetime(temp_dt_tm),
     atf.actual_end_dt_tm = cnvtdatetime(temp_dt_tm), atf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     atf.updt_id = reqinfo->updt_id,
     atf.updt_task = reqinfo->updt_task, atf.updt_cnt = 0, atf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO atf_failed
   ENDIF
 ENDFOR
 SET cnt2 = request->care_category_cnt
 SET stat = alterlist(reply->qual_care_category,cnt2)
 SET reply->care_category_cnt = cnt2
 FOR (x = 1 TO request->care_category_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     reply->qual_care_category[x].act_care_cat_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO cc_seq_failed
   ENDIF
   INSERT  FROM act_care_cat acc
    SET acc.act_care_cat_id = reply->qual_care_category[x].act_care_cat_id, acc.care_category_id =
     request->qual_care_category[x].care_category_id, acc.pathway_id = request->pathway_id,
     acc.care_category_cd = request->qual_care_category[x].care_category_cd, acc.description =
     request->qual_care_category[x].description, acc.sequence = request->qual_care_category[x].
     sequence,
     acc.active_ind = request->qual_care_category[x].active_ind, acc.restrict_comp_add_ind = request
     ->qual_care_category[x].restrict_comp_add_ind, acc.comp_add_variance_ind = request->
     qual_care_category[x].comp_add_variance_ind,
     acc.updt_dt_tm = cnvtdatetime(curdate,curtime3), acc.updt_id = reqinfo->updt_id, acc.updt_task
      = reqinfo->updt_task,
     acc.updt_cnt = 0, acc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO cc_failed
   ENDIF
 ENDFOR
 SET cnt3 = request->component_cnt
 SET stat = alterlist(reply->qual_component,cnt3)
 SET reply->component_cnt = cnt3
 FOR (x = 1 TO request->component_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    reply->qual_component[x].act_pw_comp_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO apc_seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO request->component_cnt)
   SET rc_seq = request->qual_component[x].related_comp_seq
   IF (rc_seq > 0
    AND (rc_seq <= request->component_cnt))
    SET rc_id = reply->qual_component[rc_seq].act_pw_comp_id
   ELSE
    SET rc_id = 0
   ENDIF
   SET tf_seq = request->qual_component[x].time_frame_seq
   IF (tf_seq > 0
    AND (tf_seq <= request->component_cnt))
    SET tf_id = reply->qual_time_frame[tf_seq].act_time_frame_id
   ELSE
    SET tf_id = 0
   ENDIF
   SET cc_seq = request->qual_component[x].care_category_seq
   IF (cc_seq > 0
    AND (cc_seq <= request->component_cnt))
    SET cc_id = reply->qual_care_category[cc_seq].act_care_cat_id
   ELSE
    SET cc_id = 0
   ENDIF
   IF ((request->qual_component[x].activated_ind=1))
    SET comp_status_code = activated_type_cd
    SET activated_id = reqinfo->updt_id
    SET activated_date_time = cnvtdatetime(curdate,curtime3)
    SET included_date_time = cnvtdatetime(curdate,curtime3)
   ELSE
    SET activated_date_time = cnvtdatetime(temp_dt_tm)
    IF ((request->qual_component[x].included_ind=1))
     SET comp_status_code = included_type_cd
     SET included_date_time = cnvtdatetime(curdate,curtime3)
    ELSE
     SET comp_status_code = excluded_type_cd
     SET included_date_time = cnvtdatetime(temp_dt_tm)
    ENDIF
   ENDIF
   SET pw_text_id = 0
   IF ((request->qual_component[x].comp_type_mean="NOTE"))
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
     SET lt.long_text_id = pw_text_id, lt.parent_entity_name = "ACT_PW_COMP", lt.parent_entity_id =
      reply->qual_component[x].act_pw_comp_id,
      lt.long_text = request->qual_component[x].comp_text, lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO text_note_failed
    ENDIF
   ENDIF
   IF ((request->qual_component[x].cond_ind=1))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      pw_cond_note_id = nextseqnum
     WITH format
    ;end select
    IF (pw_cond_note_id=0.0)
     GO TO cond_note_text_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = pw_cond_note_id, lt.parent_entity_name = "ACT_PW_COMP", lt
      .parent_entity_id = reply->qual_component[x].act_pw_comp_id,
      lt.long_text = request->qual_component[x].cond_note_text, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO cond_note_text_failed
    ENDIF
   ENDIF
   SET parent_entity_name = ""
   SET parent_entity_id = 0
   SET comp_type_cd = 0
   SET ref_prnt_ent_name = fillstring(32," ")
   SET ref_prnt_ent_id = 0.0
   SET comp_type_cd = 0.0
   IF ((request->qual_component[x].comp_type_mean="NOTE"))
    SET ref_prnt_ent_name = "LONG_TEXT"
    SET ref_prnt_ent_id = request->qual_component[x].ref_prnt_ent_id
    SET parent_entity_name = "LONG_TEXT"
    SET parent_entity_id = pw_text_id
    SET comp_type_cd = note_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="RESULT OUTCO"))
    SET ref_prnt_ent_name = ""
    SET ref_prnt_ent_id = 0.0
    SET parent_entity_name = ""
    SET parent_entity_id = 0.0
    SET comp_type_cd = result_outcome_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="ORDER CREATE"))
    SET ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
    SET ref_prnt_ent_id = request->qual_component[x].ref_prnt_ent_id
    SET parent_entity_name = "ORDERS"
    SET parent_entity_id = request->qual_component[x].parent_entity_id
    SET comp_type_cd = order_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="OUTCOME CREA"))
    SET ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
    SET ref_prnt_ent_id = request->qual_component[x].ref_prnt_ent_id
    SET parent_entity_name = "ORDERS"
    SET parent_entity_id = request->qual_component[x].parent_entity_id
    SET comp_type_cd = outcome_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="TASK CREATE"))
    SET ref_prnt_ent_name = "ORDER_TASK"
    SET ref_prnt_ent_id = request->qual_component[x].ref_prnt_ent_id
    SET parent_entity_name = "TASK_ACTIVITY"
    SET parent_entity_id = request->qual_component[x].parent_entity_id
    SET comp_type_cd = task_create_type_cd
   ENDIF
   IF ((request->qual_component[x].comp_type_mean="LABEL"))
    SET comp_type_cd = label_type_cd
   ENDIF
   INSERT  FROM act_pw_comp apc
    SET apc.act_pw_comp_id = reply->qual_component[x].act_pw_comp_id, apc.act_time_frame_id = tf_id,
     apc.act_care_cat_id = cc_id,
     apc.pathway_comp_id = request->qual_component[x].pathway_comp_id, apc.comp_type_cd =
     comp_type_cd, apc.age_units_cd = request->qual_component[x].age_units_cd,
     apc.comp_status_cd = comp_status_code, apc.encntr_id = request->qual_component[x].encntr_id, apc
     .person_id = request->person_id,
     apc.activated_ind = request->qual_component[x].activated_ind, apc.activated_dt_tm = cnvtdatetime
     (activated_date_time), apc.activated_prsnl_id = activated_id,
     apc.repeat_ind = request->qual_component[x].repeat_ind, apc.required_ind = request->
     qual_component[x].required_ind, apc.existing_ind = request->qual_component[x].existing_ind,
     apc.comp_label = request->qual_component[x].comp_label, apc.last_action_seq = 1, apc.after_qty
      = request->qual_component[x].after_qty,
     apc.sequence = request->qual_component[x].sequence, apc.pathway_id = request->pathway_id, apc
     .parent_entity_id = parent_entity_id,
     apc.orig_prnt_ent_id = parent_entity_id, apc.ref_prnt_ent_id = ref_prnt_ent_id, apc
     .related_comp_id = rc_id,
     apc.parent_entity_name = parent_entity_name, apc.ref_prnt_ent_name = ref_prnt_ent_name, apc
     .created_dt_tm = cnvtdatetime(curdate,curtime3),
     apc.included_ind = request->qual_component[x].included_ind, apc.included_dt_tm = cnvtdatetime(
      included_date_time), apc.canceled_ind = 0,
     apc.canceled_dt_tm = cnvtdatetime(temp_dt_tm), apc.active_ind = request->qual_component[x].
     active_ind, apc.cond_sys_eval_ind = request->qual_component[x].cond_sys_eval_ind,
     apc.cond_eval_prsnl_id = request->qual_component[x].cond_eval_prsnl_id, apc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->updt_id,
     apc.updt_task = reqinfo->updt_task, apc.updt_cnt = 0, apc.updt_applctx = reqinfo->updt_applctx,
     apc.duration_qty = request->qual_component[x].duration_qty, apc.duration_unit_cd = request->
     qual_component[x].duration_unit_cd, apc.task_assay_cd = request->qual_component[x].task_assay_cd,
     apc.event_cd = request->qual_component[x].event_cd, apc.result_type_cd = request->
     qual_component[x].result_type_cd, apc.outcome_operator_cd = request->qual_component[x].
     outcome_operator_cd,
     apc.result_value = request->qual_component[x].result_value, apc.result_units_cd = request->
     qual_component[x].result_units_cd, apc.outcome_forms_ref_id = request->qual_component[x].
     outcome_forms_ref_id,
     apc.capture_variance_ind = request->qual_component[x].capture_variance_ind, apc
     .variance_required_ind = request->qual_component[x].variance_required_ind, apc.dcp_forms_ref_id
      = request->qual_component[x].dcp_forms_ref_id,
     apc.reference_task_id = request->qual_component[x].reference_task_id, apc.start_dt_tm =
     cnvtdatetime(request->qual_component[x].start_dt_tm), apc.end_dt_tm = cnvtdatetime(request->
      qual_component[x].end_dt_tm),
     apc.cond_ind = request->qual_component[x].cond_ind, apc.cond_desc = request->qual_component[x].
     cond_desc, apc.cond_note_id = pw_cond_note_id,
     apc.cond_module_name = request->qual_component[x].cond_module_name, apc.cond_false_ind = request
     ->qual_component[x].cond_false_ind, apc.cond_eval_dt_tm = cnvtdatetime(request->qual_component[x
      ].cond_eval_dt_tm),
     apc.cond_eval_ind = request->qual_component[x].cond_eval_ind, apc.cond_eval_result_ind = request
     ->qual_component[x].cond_eval_result_ind, apc.rrf_age_qty = request->qual_component[x].
     rrf_age_qty,
     apc.rrf_age_units_cd = request->qual_component[x].rrf_age_units_cd, apc.linked_to_tf_ind =
     request->qual_component[x].linked_to_tf_ind, apc.rrf_sex_cd = request->qual_component[x].
     rrf_sex_cd
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO apc_failed
   ENDIF
   SET comp_event_cnt = size(request->qual_component[x].variance_event_list,5)
   SET stat = alterlist(reply->qual_component[x].variance_event_list,comp_event_cnt)
   FOR (y = 1 TO comp_event_cnt)
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       reply->qual_component[x].variance_event_list[y].pw_variance_reltn_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO pvrc_seq_failed
     ENDIF
     SET reason_text_id = 0.0
     SET action_text_id = 0.0
     IF ((request->qual_component[x].variance_event_list[y].reason_text != null))
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        reason_text_id = nextseqnum
       WITH format
      ;end select
      IF (reason_text_id=0.0)
       GO TO text_seq_failed
      ENDIF
      INSERT  FROM long_text lt
       SET lt.long_text_id = reason_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
        .parent_entity_id = reply->qual_component[x].variance_event_list[y].pw_variance_reltn_id,
        lt.long_text = request->qual_component[x].variance_event_list[y].reason_text, lt.active_ind
         = 1, lt.active_status_cd = reqdata->active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
        ->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
        lt.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       GO TO var_reason_text_failed
      ENDIF
     ENDIF
     IF ((request->qual_component[x].variance_event_list[y].action_text != null))
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        action_text_id = nextseqnum
       WITH format
      ;end select
      IF (action_text_id=0.0)
       GO TO text_seq_failed
      ENDIF
      INSERT  FROM long_text lt
       SET lt.long_text_id = action_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
        .parent_entity_id = reply->qual_component[x].variance_event_list[y].pw_variance_reltn_id,
        lt.long_text = request->qual_component[x].variance_event_list[y].action_text, lt.active_ind
         = 1, lt.active_status_cd = reqdata->active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
        ->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
        lt.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       GO TO var_action_text_failed
      ENDIF
     ENDIF
     INSERT  FROM pw_variance_reltn pvr
      SET pvr.pw_variance_reltn_id = reply->qual_component[x].variance_event_list[y].
       pw_variance_reltn_id, pvr.parent_entity_name = "ACT_PW_COMP", pvr.parent_entity_id = reply->
       qual_component[x].act_pw_comp_id,
       pvr.event_id = request->qual_component[x].variance_event_list[y].event_id, pvr.pathway_id =
       request->pathway_id, pvr.variance_type_cd = request->qual_component[x].variance_event_list[y].
       variance_type_cd,
       pvr.reason_cd = request->qual_component[x].variance_event_list[y].reason_cd, pvr
       .reason_text_id = reason_text_id, pvr.action_cd = request->qual_component[x].
       variance_event_list[y].action_cd,
       pvr.action_text_id = action_text_id, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr
       .updt_id = reqinfo->updt_id,
       pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = 0, pvr.updt_applctx = reqinfo->updt_applctx,
       pvr.variance_dt_tm = cnvtdatetime(curdate,curtime3), pvr.active_ind = 1
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO pvrc_failed
     ENDIF
   ENDFOR
   SET comp_focus_cnt = request->qual_component[x].comp_focus_cnt
   SET stat = alterlist(reply->qual_component[x].comp_focus_list,comp_focus_cnt)
   SET comp_focus_cnt1 = size(request->qual_component[x].comp_focus_list,5)
   FOR (y = 1 TO comp_focus_cnt)
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       reply->qual_component[x].comp_focus_list[y].act_pw_comp_focus_r_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO pcf_seq_failed
     ENDIF
     INSERT  FROM act_pw_comp_focus_r pcf
      SET pcf.act_pw_comp_focus_r_id = reply->qual_component[x].comp_focus_list[y].
       act_pw_comp_focus_r_id, pcf.act_pw_comp_id = reply->qual_component[x].act_pw_comp_id, pcf
       .nomenclature_id = request->qual_component[x].comp_focus_list[y].nomenclature_id,
       pcf.primary_ind = request->qual_component[x].comp_focus_list[y].primary_ind, pcf.active_ind =
       request->qual_component[x].comp_focus_list[y].active_ind, pcf.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       pcf.updt_id = reqinfo->updt_id, pcf.updt_task = reqinfo->updt_task, pcf.updt_cnt = 0,
       pcf.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO pcf_failed
     ENDIF
   ENDFOR
   INSERT  FROM pw_comp_action pca
    SET pca.act_pw_comp_id = reply->qual_component[x].act_pw_comp_id, pca.pw_comp_action_seq = 1, pca
     .comp_status_cd = comp_status_code,
     pca.action_type_cd = create_type_cd, pca.action_dt_tm = cnvtdatetime(curdate,curtime3), pca
     .action_prsnl_id = reqinfo->updt_id,
     pca.parent_entity_id = parent_entity_id, pca.parent_entity_name = parent_entity_name, pca
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pca.updt_id = reqinfo->updt_id, pca.updt_task = reqinfo->updt_task, pca.updt_cnt = 0,
     pca.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET stat = alterlist(reply->pw_focus_list,request->pw_focus_cnt)
 SET reply->pw_focus_cnt = request->pw_focus_cnt
 FOR (x = 1 TO request->pw_focus_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    reply->pw_focus_list[x].act_pw_focus_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO apf_seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO request->pw_focus_cnt)
   INSERT  FROM act_pw_focus apf
    SET apf.act_pw_focus_id = reply->pw_focus_list[x].act_pw_focus_id, apf.pathway_id = request->
     pathway_id, apf.nomenclature_id = request->pw_focus_list[x].nomenclature_id,
     apf.pathway_level_ind = request->pw_focus_list[x].pathway_level_ind, apf.status_cd = request->
     pw_focus_list[x].status_cd, apf.status_dt_tm = cnvtdatetime(curdate,curtime3),
     apf.status_prsnl_id = reqinfo->updt_id, apf.last_action_seq = 1, apf.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     apf.updt_id = reqinfo->updt_id, apf.updt_task = reqinfo->updt_task, apf.updt_cnt = 0,
     apf.updt_applctx = reqinfo->updt_applctx, apf.active_ind = request->pw_focus_list[x].active_ind,
     apf.sequence = request->pw_focus_list[x].sequence
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO apf_failed
   ENDIF
   INSERT  FROM act_pw_focus_action pfa
    SET pfa.act_pw_focus_id = reply->pw_focus_list[x].act_pw_focus_id, pfa.action_seq = 1, pfa
     .status_cd = request->pw_focus_list[x].status_cd,
     pfa.action_dt_tm = cnvtdatetime(curdate,curtime3), pfa.action_prsnl_id = reqinfo->updt_id, pfa
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pfa.updt_id = reqinfo->updt_id, pfa.updt_task = reqinfo->updt_task, pfa.updt_cnt = 0,
     pfa.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO pfa_failed
   ENDIF
 ENDFOR
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
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_cmmnt_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text (comment)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#var_reason_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text (variance reason text)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#var_action_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text (variance action text)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_pw_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text (pw)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "long text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cond text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#pvr_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pvr_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pvrc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pvrc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp_focus seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_note_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text (note)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert cond_note_text "
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#atf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#atf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#cc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cc sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "act pw comp sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#apf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "act pw focus sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#apf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#pfa_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus_action"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#der_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "der sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 IF (cfailed="T")
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->pathway_id = 0
 ELSE
  COMMIT
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
