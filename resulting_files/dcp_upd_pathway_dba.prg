CREATE PROGRAM dcp_upd_pathway:dba
 RECORD pathway(
   1 pathway_id = f8
   1 long_text_id = f8
   1 person_id = f8
   1 last_action_seq = i4
   1 updt_cnt = i4
   1 started_ind = i2
   1 orig_started_ind = i2
   1 dc_text_id = f8
 )
 RECORD act_time_ids(
   1 time_ids[*]
     2 time_id = f8
 )
 RECORD act_comp_ids(
   1 comp_ids[*]
     2 comp_id = f8
 )
 RECORD act_pw_comp(
   1 last_action_seq = i4
 )
 RECORD act_pw_focus(
   1 last_action_seq = i4
 )
 RECORD act_pw_focus_ids(
   1 focus_ids[*]
     2 act_pw_focus_id = f8
 )
 RECORD act_pw_comp_focus_ids(
   1 focus_ids[*]
     2 act_pw_comp_focus_r_id = f8
 )
 SET ncnt = 0
 SET pathway_nmr = 0.0
 SET ent_rel_id = 0.0
 SET variance_reltn_id = 0.0
 SET pw_event_cnt = 0
 SET comp_event_cnt = 0
 SET forms_ref_id = 0.0
 SET dc_text_id = 0.0
 SET comp_focus_id = 0.0
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->subeventstatus,1)
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pw_text_id = 0.0
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
 SET old_cnt = 0
 SET new_cnt = 0
 SET id_cnt = 0
 SET oldpc_cnt = 0
 SET newpc_cnt = 0
 SET relationship_cnt = 0
 SET new_text = 0
 SET comp_text_id = 0
 SET vcomp_type_mean = fillstring(20," ")
 SET pw_focus_cnt = 0
 SET comp_focus_cnt = 0
 SET newf_cnt = 0
 SET oldf_cnt = 0
 SET newcf_cnt = 0
 SET oldcf_cnt = 0
 SET vcond_note_id = 0.0
 SET cond_remove_ind = 0
 SET time_cnt = 0
 SET comp_cnt = 0
 SET cc_seq = 0
 SET tf_seq = 0
 SET rc_seq = 0
 SET ptf_id = 0
 SET code_set = 16769
 SET cdf_meaning = "STARTED"
 EXECUTE cpm_get_cd_for_cdf
 SET started_type_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_type_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET completed_type_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET discontinued_type_cd = code_value
 SET code_set = 16809
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_type_cd = code_value
 SET code_set = 16809
 SET cdf_meaning = "DISCONTINUE"
 EXECUTE cpm_get_cd_for_cdf
 SET discontinue_type_cd = code_value
 SET code_set = 16809
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_type_cd = code_value
 SET code_set = 16809
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_type_cd = code_value
 SET code_set = 16829
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modifyc_type_cd = code_value
 SET code_set = 16829
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_type_cd = code_value
 SET code_set = 16829
 SET cdf_meaning = "CREATE"
 EXECUTE cpm_get_cd_for_cdf
 SET create_type_cd = code_value
 SET code_set = 16829
 SET cdf_meaning = "REMOVE"
 EXECUTE cpm_get_cd_for_cdf
 SET remove_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "INCLUDED"
 EXECUTE cpm_get_cd_for_cdf
 SET included_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "EXCLUDED"
 EXECUTE cpm_get_cd_for_cdf
 SET excluded_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "ACTIVATED"
 EXECUTE cpm_get_cd_for_cdf
 SET activated_type_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_type_cd = code_value
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
 SET cdf_meaning = "RESULT OUTCO"
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = "TASK CREATE"
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SELECT INTO "nl:"
  FROM pathway pw
  WHERE (pw.pathway_id=request->pathway_id)
  DETAIL
   pathway->pathway_id = pw.pathway_id, pathway->long_text_id = pw.long_text_id, pathway->person_id
    = pw.person_id,
   pathway->last_action_seq = pw.last_action_seq, pathway->updt_cnt = pw.updt_cnt, pathway->
   started_ind = pw.started_ind,
   pathway->orig_started_ind = pw.started_ind, pathway->dc_text_id = pw.dc_text_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO pw_failed
 ENDIF
 IF ((request->version_flag > 0))
  EXECUTE dcp_ver_pathway
 ENDIF
 IF ((((request->pw_action_meaning="COMPLETE")) OR ((request->pw_action_meaning="DISCONTINUE"))) )
  SET reply->dc_ind = 1
 ELSE
  SET reply->dc_ind = 0
 ENDIF
 IF ((request->comment_ind > 0)
  AND (pathway->long_text_id != 0))
  SET reply->status_data.status = "F"
  SET cfailed = "F"
  SET text_updt_cnt = 0
  SELECT INTO "nl:"
   lt.*
   FROM long_text lt
   WHERE (lt.long_text_id=pathway->long_text_id)
   HEAD REPORT
    text_updt_cnt = lt.updt_cnt
   WITH forupdate(lt), nocounter
  ;end select
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  IF ((text_updt_cnt != request->comment_updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "locking"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM long_text lt
   SET lt.long_text = request->comment_text, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
    .updt_id = reqinfo->updt_id,
    lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
    updt_applctx
   WHERE (lt.long_text_id=pathway->long_text_id)
  ;end update
  IF (curqual=0)
   GO TO text_failed
  ENDIF
 ELSEIF ((request->comment_ind > 0)
  AND (pathway->long_text_id=0))
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
   SET lt.long_text_id = pw_text_id, lt.parent_entity_name = "PATHWAY", lt.parent_entity_id = pathway
    ->pathway_id,
    lt.long_text = request->comment_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET pathway->long_text_id = pw_text_id
  IF (curqual=0)
   GO TO text2_failed
  ENDIF
  SET new_text = 1
 ENDIF
 IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="COMPLETE")))
  AND (request->dc_text != null)
  AND (pathway->dc_text_id=0))
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    dc_text_id = nextseqnum
   WITH format
  ;end select
  IF (dc_text_id=0.0)
   GO TO dc_text_seq_failed
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = dc_text_id, lt.parent_entity_name = "PATHWAY", lt.parent_entity_id = pathway
    ->pathway_id,
    lt.long_text = request->dc_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET pathway->dc_text_id = dc_text_id
  IF (curqual=0)
   GO TO dc_text_failed
  ENDIF
 ENDIF
 IF ((((request->pw_action_meaning="MODIFY")) OR ((((request->pw_action_meaning="DISCONTINUE")) OR ((
 request->pw_action_meaning="COMPLETE"))) )) )
  SET comp_type_cd = 0.0
  IF ((request->pw_action_meaning="MODIFY")
   AND (request->started_ind=1))
   SET comp_status_cd = started_type_cd
   SET pathway->started_ind = 1
  ELSEIF ((request->pw_action_meaning="MODIFY")
   AND (request->started_ind=0))
   SET comp_status_cd = ordered_type_cd
   SET pathway->started_ind = 0
  ENDIF
  IF ((request->pw_action_meaning="DISCONTINUE"))
   SET comp_status_cd = discontinued_type_cd
  ENDIF
  IF ((request->pw_action_meaning="COMPLETE"))
   SET comp_status_cd = completed_type_cd
  ENDIF
  SET reply->status_data.status = "F"
  SET cfailed = "F"
  SET updt_cnt = 0
  SELECT INTO "nl:"
   pw.*
   FROM pathway pw
   WHERE (pw.pathway_id=request->pathway_id)
   HEAD REPORT
    updt_cnt = pw.updt_cnt
   WITH forupdate(pw), nocounter
  ;end select
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  IF ((updt_cnt != request->updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "locking1"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM pathway pw
   SET pw.pathway_id = request->pathway_id, pw.pw_status_cd = comp_status_cd, pw.status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pw.status_prsnl_id = reqinfo->updt_id, pw.description =
    IF ((request->description != null)) request->description
    ELSE pw.description
    ENDIF
    , pw.long_text_id = pathway->long_text_id,
    pw.started_ind = pathway->started_ind, pw.start_dt_tm =
    IF ((request->pw_action_meaning="MODIFY")
     AND (pathway->orig_started_ind=0)
     AND (pathway->started_ind=1)) cnvtdatetime(curdate,curtime3)
    ELSE pw.start_dt_tm
    ENDIF
    , pw.calc_end_dt_tm =
    IF ((request->calc_end_dt_tm != null)) cnvtdatetime(request->calc_end_dt_tm)
    ELSE pw.calc_end_dt_tm
    ENDIF
    ,
    pw.ended_ind =
    IF ((request->pw_action_meaning="COMPLETE")) 1
    ELSE pw.ended_ind
    ENDIF
    , pw.actual_end_dt_tm =
    IF ((((request->pw_action_meaning="COMPLETE")) OR ((request->pw_action_meaning="DISCONTINUE"))) )
      cnvtdatetime(curdate,curtime3)
    ELSE pw.actual_end_dt_tm
    ENDIF
    , pw.dc_reason_cd =
    IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="COMPLETE"))) )
      request->dc_reason_cd
    ELSE pw.dc_reason_cd
    ENDIF
    ,
    pw.discontinued_ind =
    IF ((request->pw_action_meaning="DISCONTINUE")) 1
    ELSE pw.discontinued_ind
    ENDIF
    , pw.discontinued_dt_tm =
    IF ((request->pw_action_meaning="DISCONTINUE")) cnvtdatetime(curdate,curtime3)
    ELSE pw.discontinued_dt_tm
    ENDIF
    , pw.last_action_seq = (pw.last_action_seq+ 1),
    pw.dc_text_id =
    IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="COMPLETE")))
     AND (request->dc_text != null)) dc_text_id
    ELSE pw.dc_text_id
    ENDIF
    , pw.version =
    IF ((request->version_flag > 0)) (pw.version+ 1)
    ELSE pw.version
    ENDIF
    , pw.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pw.updt_id = reqinfo->updt_id, pw.updt_task = reqinfo->updt_task, pw.updt_cnt = (pw.updt_cnt+ 1),
    pw.updt_applctx = reqinfo->updt_applctx
   WHERE (pw.pathway_id=request->pathway_id)
  ;end update
  IF (curqual=0)
   GO TO pw_updt_failed
  ENDIF
  SET pw_event_cnt = size(request->variance_event_list,5)
  FOR (x = 1 TO pw_event_cnt)
    SET var_reason_text_id = 0.0
    SET var_action_text_id = 0.0
    IF ((request->variance_event_list[x].pw_variance_reltn_id=0))
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       variance_reltn_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO pvr_seq_failed
     ENDIF
    ENDIF
    SET stat = alterlist(reply->variance_event_list,x)
    IF ((request->variance_event_list[x].pw_variance_reltn_id=0))
     SET reply->variance_event_list[x].pw_variance_reltn_id = variance_reltn_id
    ELSE
     SET reply->variance_event_list[x].pw_variance_reltn_id = request->variance_event_list[x].
     pw_variance_reltn_id
    ENDIF
    IF ((request->variance_event_list[x].reason_text != null)
     AND (request->variance_event_list[x].reason_text_id=0)
     AND (request->variance_event_list[x].remove_ind=0))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       var_reason_text_id = nextseqnum
      WITH format
     ;end select
     IF (var_reason_text_id=0.0)
      GO TO text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = var_reason_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
       .parent_entity_id =
       IF ((request->variance_event_list[x].pw_variance_reltn_id > 0)) request->variance_event_list[x
        ].pw_variance_reltn_id
       ELSE variance_reltn_id
       ENDIF
       ,
       lt.long_text = request->variance_event_list[x].reason_text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO text2_failed
     ENDIF
    ELSEIF ((request->variance_event_list[x].reason_text != null)
     AND (request->variance_event_list[x].reason_text_id != 0)
     AND (request->variance_event_list[x].remove_ind=0))
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE (lt.long_text_id=request->variance_event_list[x].reason_text_id)
      HEAD REPORT
       updt_cnt = lt.updt_cnt
      WITH forupdate(lt), nocounter
     ;end select
     IF (curqual=0)
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((updt_cnt != request->variance_event_list[x].reason_text_updt_cnt))
      SET reply->status_data.subeventstatus[1].operationname = "locking_UPDATE_VAR_NOTE"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM long_text lt
      SET lt.long_text = request->variance_event_list[x].reason_text, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
       updt_applctx
      WHERE (lt.long_text_id=request->variance_event_list[x].reason_text_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      GO TO var_text_upd_failed
     ENDIF
    ENDIF
    IF ((request->variance_event_list[x].action_text != null)
     AND (request->variance_event_list[x].action_text_id=0)
     AND (request->variance_event_list[x].remove_ind=0))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       var_action_text_id = nextseqnum
      WITH format
     ;end select
     IF (var_action_text_id=0.0)
      GO TO text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = var_action_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
       .parent_entity_id =
       IF ((request->variance_event_list[x].pw_variance_reltn_id > 0)) request->variance_event_list[x
        ].pw_variance_reltn_id
       ELSE variance_reltn_id
       ENDIF
       ,
       lt.long_text = request->variance_event_list[x].action_text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO text2_failed
     ENDIF
    ELSEIF ((request->variance_event_list[x].action_text != null)
     AND (request->variance_event_list[x].action_text_id != 0)
     AND (request->variance_event_list[x].remove_ind=0))
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE (lt.long_text_id=request->variance_event_list[x].action_text_id)
      HEAD REPORT
       updt_cnt = lt.updt_cnt
      WITH forupdate(lt), nocounter
     ;end select
     IF (curqual=0)
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((updt_cnt != request->variance_event_list[x].action_text_updt_cnt))
      SET reply->status_data.subeventstatus[1].operationname = "locking_UPDATE_VAR_NOTE"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM long_text lt
      SET lt.long_text = request->variance_event_list[x].action_text, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
       updt_applctx
      WHERE (lt.long_text_id=request->variance_event_list[x].action_text_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      GO TO var_text_upd_failed
     ENDIF
    ENDIF
    IF ((request->variance_event_list[x].pw_variance_reltn_id=0))
     INSERT  FROM pw_variance_reltn pvr
      SET pvr.pw_variance_reltn_id = variance_reltn_id, pvr.pathway_id = request->pathway_id, pvr
       .parent_entity_name = request->variance_event_list[x].parent_entity_name,
       pvr.parent_entity_id = request->variance_event_list[x].parent_entity_id, pvr.event_id =
       request->variance_event_list[x].event_id, pvr.variance_type_cd = request->variance_event_list[
       x].variance_type_cd,
       pvr.reason_cd = request->variance_event_list[x].reason_cd, pvr.reason_text_id =
       var_reason_text_id, pvr.action_cd = request->variance_event_list[x].action_cd,
       pvr.action_text_id = var_action_text_id, pvr.outcome_operator_cd = request->
       variance_event_list[x].outcome_operator_cd, pvr.result_value = request->variance_event_list[x]
       .result_value,
       pvr.result_units_cd = request->variance_event_list[x].result_units_cd, pvr.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), pvr.updt_id = reqinfo->updt_id,
       pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = 0, pvr.updt_applctx = reqinfo->updt_applctx,
       pvr.variance_dt_tm = cnvtdatetime(curdate,curtime3), pvr.active_ind = 1
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO pvr_failed
     ENDIF
    ELSEIF ((request->variance_event_list[x].pw_variance_reltn_id > 0)
     AND (request->variance_event_list[x].remove_ind=0))
     SET reply->status_data.status = "F"
     SET cfailed = "F"
     SET updt_cnt = 0
     SELECT INTO "nl:"
      pvr.*
      FROM pw_variance_reltn pvr
      WHERE (pvr.pw_variance_reltn_id=request->variance_event_list[x].pw_variance_reltn_id)
      HEAD REPORT
       updt_cnt = pvr.updt_cnt
      WITH forupdate(pvr), nocounter
     ;end select
     IF (curqual=0)
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((updt_cnt != request->variance_event_list[x].var_updt_cnt))
      SET reply->status_data.subeventstatus[1].operationname = "locking2"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM pw_variance_reltn pvr
      SET pvr.variance_type_cd =
       IF ((request->variance_event_list[x].variance_type_cd > 0)) request->variance_event_list[x].
        variance_type_cd
       ELSE pvr.variance_type_cd
       ENDIF
       , pvr.reason_cd =
       IF ((request->variance_event_list[x].reason_cd > 0)) request->variance_event_list[x].reason_cd
       ELSE pvr.reason_cd
       ENDIF
       , pvr.action_cd =
       IF ((request->variance_event_list[x].action_cd >= 0)) request->variance_event_list[x].
        action_cd
       ELSE pvr.action_cd
       ENDIF
       ,
       pvr.reason_text_id =
       IF ((request->variance_event_list[x].reason_text_id > 0)) request->variance_event_list[x].
        reason_text_id
       ELSEIF (var_reason_text_id > 0) var_reason_text_id
       ELSE pvr.reason_text_id
       ENDIF
       , pvr.action_text_id =
       IF ((request->variance_event_list[x].action_text_id > 0)) request->variance_event_list[x].
        action_text_id
       ELSEIF (var_action_text_id > 0) var_action_text_id
       ELSE pvr.action_text_id
       ENDIF
       , pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pvr.updt_id = reqinfo->updt_id, pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = (pvr
       .updt_cnt+ 1),
       pvr.updt_applctx = reqinfo->updt_applctx
      WHERE (pvr.pw_variance_reltn_id=request->variance_event_list[x].pw_variance_reltn_id)
     ;end update
     IF (curqual=0)
      GO TO pvr_updt_failed
     ENDIF
    ELSEIF ((request->variance_event_list[x].pw_variance_reltn_id > 0)
     AND (request->variance_event_list[x].remove_ind=1))
     SET reply->status_data.status = "F"
     SET cfailed = "F"
     SET updt_cnt = 0
     SELECT INTO "nl:"
      pvr.*
      FROM pw_variance_reltn pvr
      WHERE (pvr.pw_variance_reltn_id=request->variance_event_list[x].pw_variance_reltn_id)
      HEAD REPORT
       updt_cnt = pvr.updt_cnt
      WITH forupdate(pvr), nocounter
     ;end select
     IF (curqual=0)
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((updt_cnt != request->variance_event_list[x].var_updt_cnt))
      SET reply->status_data.subeventstatus[1].operationname = "locking2"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM pw_variance_reltn pvr
      SET pvr.active_ind = 0, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr.updt_id = reqinfo
       ->updt_id,
       pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = (pvr.updt_cnt+ 1), pvr.updt_applctx =
       reqinfo->updt_applctx
      WHERE (pvr.pw_variance_reltn_id=request->variance_event_list[x].pw_variance_reltn_id)
     ;end update
     IF (curqual=0)
      GO TO pvr_remove_failed
     ENDIF
     SET rmv_reason_text_id = 0.0
     SET rmv_action_text_id = 0.0
     SELECT INTO "nl:"
      pvr.*
      FROM pw_variance_reltn pvr
      WHERE (pvr.pw_variance_reltn_id=request->variance_event_list[x].pw_variance_reltn_id)
      HEAD REPORT
       rmv_reason_text_id = pvr.reason_text_id, rmv_action_text_id = pvr.action_text_id
      WITH nocounter
     ;end select
     IF (rmv_reason_text_id > 0)
      SELECT INTO "nl:"
       lt.*
       FROM long_text lt
       WHERE lt.long_text_id=rmv_reason_text_id
       HEAD REPORT
        updt_cnt = lt.updt_cnt
       WITH forupdate(lt), nocounter
      ;end select
      IF (curqual=0)
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      IF ((updt_cnt != request->variance_event_list[x].reason_text_updt_cnt))
       SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE_VAR_NOTE"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      UPDATE  FROM long_text lt
       SET lt.long_text = request->variance_event_list[x].reason_text, lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), lt.updt_id = reqinfo->updt_id,
        lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0,
        lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_applctx = reqinfo->updt_applctx
       WHERE lt.long_text_id=rmv_reason_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       GO TO var_text_rmv_failed
      ENDIF
     ENDIF
     IF (rmv_action_text_id > 0)
      SELECT INTO "nl:"
       lt.*
       FROM long_text lt
       WHERE lt.long_text_id=rmv_action_text_id
       HEAD REPORT
        updt_cnt = lt.updt_cnt
       WITH forupdate(lt), nocounter
      ;end select
      IF (curqual=0)
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      IF ((updt_cnt != request->variance_event_list[x].action_text_updt_cnt))
       SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE_VAR_NOTE"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      UPDATE  FROM long_text lt
       SET lt.long_text = request->variance_event_list[x].action_text, lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), lt.updt_id = reqinfo->updt_id,
        lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0,
        lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_applctx = reqinfo->updt_applctx
       WHERE lt.long_text_id=rmv_action_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       GO TO var_text_rmv_failed
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  INSERT  FROM pathway_action pa
   SET pa.pathway_id = pathway->pathway_id, pa.pw_action_seq = (pathway->last_action_seq+ 1), pa
    .pw_status_cd = comp_status_cd,
    pa.action_type_cd =
    IF ((request->pw_action_meaning="MODIFY")) modify_type_cd
    ELSEIF ((request->pw_action_meaning="DISCONTINUE")) discontinue_type_cd
    ELSEIF ((request->pw_action_meaning="COMPLETE")) complete_type_cd
    ENDIF
    , pa.action_dt_tm = cnvtdatetime(curdate,curtime3), pa.action_prsnl_id = reqinfo->updt_id,
    pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
    reqinfo->updt_task,
    pa.updt_cnt = (pathway->updt_cnt+ 1), pa.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ELSEIF (new_text=1)
  SET reply->status_data.status = "F"
  SET cfailed = "F"
  SET updt_cnt = 0
  SELECT INTO "nl:"
   pw.*
   FROM pathway pw
   WHERE (pw.pathway_id=request->pathway_id)
   HEAD REPORT
    updt_cnt = pw.updt_cnt
   WITH forupdate(pw), nocounter
  ;end select
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  IF ((updt_cnt != request->updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "locking"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM pathway pw
   SET pw.long_text_id = pw_text_id
   WHERE (pw.pathway_id=request->pathway_id)
  ;end update
  IF (curqual=0)
   GO TO pw_updt_lt_failed
  ENDIF
 ENDIF
 SET time_frame_cnt = size(request->qual_time_frame,5)
 FOR (x = 1 TO time_frame_cnt)
   IF ((request->qual_time_frame[x].act_time_frame_id=0))
    SET new_cnt = (new_cnt+ 1)
   ELSE
    SET old_cnt = (old_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO new_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(act_time_ids->time_ids,x), act_time_ids->time_ids[x].time_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO atf_seq_failed
  ENDIF
 ENDFOR
 FOR (tf_cnt = 1 TO time_frame_cnt)
   SET eh_temp = 0
   SET stat = alterlist(reply->qual_time_frame,tf_cnt)
   IF ((request->qual_time_frame[tf_cnt].act_time_frame_id=0))
    SET eh_temp = (eh_temp+ 1)
    SET reply->qual_time_frame[tf_cnt].act_time_frame_id = act_time_ids->time_ids[eh_temp].time_id
   ELSE
    SET reply->qual_time_frame[tf_cnt].act_time_frame_id = request->qual_time_frame[tf_cnt].
    act_time_frame_id
   ENDIF
   IF ((request->qual_time_frame[tf_cnt].pw_action_meaning="REMOVE")
    AND (request->qual_time_frame[tf_cnt].act_time_frame_id != 0))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     atf.*
     FROM act_time_frame atf
     WHERE (atf.act_time_frame_id=request->qual_time_frame[tf_cnt].act_time_frame_id)
     HEAD REPORT
      updt_cnt = atf.updt_cnt
     WITH forupdate(atf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_time_frame[tf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_time_frame"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_time_frame atf
     SET atf.active_ind = 0, atf.updt_dt_tm = cnvtdatetime(curdate,curtime3), atf.updt_id = reqinfo->
      updt_id,
      atf.updt_task = reqinfo->updt_task, atf.updt_cnt = (atf.updt_cnt+ 1), atf.updt_applctx =
      reqinfo->updt_applctx
     WHERE (atf.act_time_frame_id=request->qual_time_frame[tf_cnt].act_time_frame_id)
    ;end update
    IF (curqual=0)
     GO TO tf_failed
    ENDIF
   ELSEIF ((request->qual_time_frame[tf_cnt].pw_action_meaning="MODIFY")
    AND (request->qual_time_frame[tf_cnt].act_time_frame_id != 0))
    SET time_cnt = 0
    SET ptf_seq = request->qual_time_frame[tf_cnt].prnt_time_frame_seq
    IF (ptf_seq > 0
     AND ptf_seq <= time_frame_cnt)
     FOR (y = 1 TO time_frame_cnt)
      IF ((request->qual_time_frame[y].act_time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((ptf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_time_frame[y].act_time_frame_id != 0))
        SET ptf_id = request->qual_time_frame[y].act_time_frame_id
       ELSE
        SET ptf_id = act_time_ids->time_ids[time_cnt].time_id
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
     atf.*
     FROM act_time_frame atf
     WHERE (atf.act_time_frame_id=request->qual_time_frame[tf_cnt].act_time_frame_id)
     HEAD REPORT
      updt_cnt = atf.updt_cnt
     WITH forupdate(atf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_time_frame[tf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_time_frame"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_time_frame atf
     SET atf.act_time_frame_id = request->qual_time_frame[tf_cnt].act_time_frame_id, atf.description
       =
      IF ((request->qual_time_frame[tf_cnt].description != null)) request->qual_time_frame[tf_cnt].
       description
      ELSE atf.description
      ENDIF
      , atf.sequence =
      IF ((request->qual_time_frame[tf_cnt].sequence != null)) request->qual_time_frame[tf_cnt].
       sequence
      ELSE atf.sequence
      ENDIF
      ,
      atf.duration_qty = request->qual_time_frame[tf_cnt].duration_qty, atf.age_units_cd =
      IF ((request->qual_time_frame[tf_cnt].age_units_cd != null)) request->qual_time_frame[tf_cnt].
       age_units_cd
      ELSE atf.age_units_cd
      ENDIF
      , atf.parent_tf_id =
      IF (ptf_seq != null) ptf_id
      ELSE atf.parent_tf_id
      ENDIF
      ,
      atf.start_ind = request->qual_time_frame[tf_cnt].start_ind, atf.end_ind = request->
      qual_time_frame[tf_cnt].end_ind, atf.calc_start_dt_tm = cnvtdatetime(request->qual_time_frame[
       tf_cnt].calc_start_dt_tm),
      atf.calc_end_dt_tm = cnvtdatetime(request->qual_time_frame[tf_cnt].calc_end_dt_tm), atf
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), atf.updt_id = reqinfo->updt_id,
      atf.updt_task = reqinfo->updt_task, atf.updt_cnt = (atf.updt_cnt+ 1), atf.updt_applctx =
      reqinfo->updt_applctx
     WHERE (atf.act_time_frame_id=request->qual_time_frame[tf_cnt].act_time_frame_id)
    ;end update
    IF (curqual=0)
     GO TO atf_mod_failed
    ENDIF
   ELSEIF ((request->qual_time_frame[tf_cnt].act_time_frame_id=0)
    AND (request->qual_time_frame[tf_cnt].pw_action_meaning="ORDER"))
    SET id_cnt = (id_cnt+ 1)
    SET ptf_seq = request->qual_time_frame[tf_cnt].prnt_time_frame_seq
    SET time_cnt = 0
    IF (ptf_seq > 0
     AND ptf_seq <= time_frame_cnt)
     FOR (y = 1 TO time_frame_cnt)
      IF ((request->qual_time_frame[y].act_time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((ptf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_time_frame[y].act_time_frame_id != 0))
        SET ptf_id = request->qual_time_frame[y].act_time_frame_id
       ELSE
        SET ptf_id = act_time_ids->time_ids[time_cnt].time_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET ptf_id = 0
    ENDIF
    INSERT  FROM act_time_frame atf
     SET atf.time_frame_id = request->qual_time_frame[tf_cnt].time_frame_id, atf.act_time_frame_id =
      act_time_ids->time_ids[id_cnt].time_id, atf.description = request->qual_time_frame[tf_cnt].
      description,
      atf.pathway_id = request->pathway_id, atf.sequence = request->qual_time_frame[tf_cnt].sequence,
      atf.duration_qty = request->qual_time_frame[tf_cnt].duration_qty,
      atf.age_units_cd = request->qual_time_frame[tf_cnt].age_units_cd, atf.continuous_ind = request
      ->qual_time_frame[tf_cnt].continuous_ind, atf.start_ind = request->qual_time_frame[tf_cnt].
      start_ind,
      atf.end_ind = request->qual_time_frame[tf_cnt].end_ind, atf.active_ind = 1, atf
      .calc_start_dt_tm = cnvtdatetime(request->qual_time_frame[tf_cnt].calc_start_dt_tm),
      atf.calc_end_dt_tm = cnvtdatetime(request->qual_time_frame[tf_cnt].calc_end_dt_tm), atf
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), atf.updt_id = reqinfo->updt_id,
      atf.updt_task = reqinfo->updt_task, atf.updt_applctx = reqinfo->updt_applctx, atf.updt_cnt = 0,
      atf.parent_tf_id = ptf_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO atf_failed
    ENDIF
   ENDIF
 ENDFOR
 SET care_category_cnt = size(request->qual_care_category,5)
 FOR (cc_cnt = 1 TO care_category_cnt)
   IF ((request->qual_care_category[cc_cnt].pw_action_meaning="REMOVE")
    AND (request->qual_care_category[cc_cnt].act_care_cat_id != 0))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     acc.*
     FROM act_care_cat acc
     WHERE (acc.act_care_cat_id=request->qual_care_category[cc_cnt].act_care_cat_id)
     HEAD REPORT
      updt_cnt = acc.updt_cnt
     WITH forupdate(acc), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_care_category[cc_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_care_cat"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_care_cat acc
     SET acc.active_ind = 0, acc.updt_dt_tm = cnvtdatetime(curdate,curtime3), acc.updt_id = reqinfo->
      updt_id,
      acc.updt_task = reqinfo->updt_task, acc.updt_cnt = (acc.updt_cnt+ 1), acc.updt_applctx =
      reqinfo->updt_applctx
     WHERE (acc.act_care_cat_id=request->qual_care_category[cc_cnt].act_care_cat_id)
    ;end update
    IF (curqual=0)
     GO TO acc_failed
    ENDIF
   ELSEIF ((request->qual_care_category[cc_cnt].pw_action_meaning="MODIFY")
    AND (request->qual_care_category[cc_cnt].act_care_cat_id != 0))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     acc.*
     FROM act_care_cat acc
     WHERE (acc.act_care_cat_id=request->qual_care_category[cc_cnt].act_care_cat_id)
     HEAD REPORT
      updt_cnt = acc.updt_cnt
     WITH forupdate(acc), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_care_category[cc_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking_MODIFY"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_care_cat"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_care_cat acc
     SET acc.description =
      IF ((request->qual_care_category[cc_cnt].description != null)) request->qual_care_category[
       cc_cnt].description
      ELSE acc.description
      ENDIF
      , acc.sequence =
      IF ((request->qual_care_category[cc_cnt].sequence != null)) request->qual_care_category[cc_cnt]
       .sequence
      ELSE acc.sequence
      ENDIF
      , acc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      acc.updt_id = reqinfo->updt_id, acc.updt_task = reqinfo->updt_task, acc.updt_cnt = (acc
      .updt_cnt+ 1),
      acc.updt_applctx = reqinfo->updt_applctx
     WHERE (acc.act_care_cat_id=request->qual_care_category[cc_cnt].act_care_cat_id)
    ;end update
    IF (curqual=0)
     GO TO acc_failed
    ENDIF
   ELSEIF ((request->qual_care_category[cc_cnt].pw_action_meaning="ORDER")
    AND (request->qual_care_category[cc_cnt].act_care_cat_id=0))
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      request->qual_care_category[cc_cnt].act_care_cat_id = nextseqnum
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO acc_seq_failed
    ENDIF
    INSERT  FROM act_care_cat acc
     SET acc.act_care_cat_id = request->qual_care_category[cc_cnt].act_care_cat_id, acc
      .care_category_id = request->qual_care_category[cc_cnt].care_category_id, acc.care_category_cd
       = request->qual_care_category[cc_cnt].care_category_cd,
      acc.description = request->qual_care_category[cc_cnt].description, acc.pathway_id = request->
      pathway_id, acc.sequence = request->qual_care_category[cc_cnt].sequence,
      acc.active_ind = 1, acc.updt_dt_tm = cnvtdatetime(curdate,curtime3), acc.updt_id = reqinfo->
      updt_id,
      acc.updt_task = reqinfo->updt_task, acc.updt_applctx = reqinfo->updt_applctx, acc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO acc_failed
    ENDIF
   ENDIF
   SET stat = alterlist(reply->qual_care_category,cc_cnt)
   SET reply->qual_care_category[cc_cnt].act_care_cat_id = request->qual_care_category[cc_cnt].
   act_care_cat_id
 ENDFOR
 SET id_cnt = 0
 SET component_cnt = size(request->qual_component,5)
 FOR (x = 1 TO component_cnt)
   IF ((request->qual_component[x].act_pw_comp_id=0))
    SET newpc_cnt = (newpc_cnt+ 1)
   ELSE
    SET oldpc_cnt = (oldpc_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO newpc_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(act_comp_ids->comp_ids,x), act_comp_ids->comp_ids[x].comp_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO comp_seq_failed
  ENDIF
 ENDFOR
 FOR (pwc_cnt = 1 TO component_cnt)
   SET eh_temp = 0
   SET stat = alterlist(reply->qual_component,pwc_cnt)
   IF ((request->qual_component[pwc_cnt].act_pw_comp_id=0))
    SET eh_temp = (eh_temp+ 1)
    SET reply->qual_component[pwc_cnt].act_pw_comp_id = act_comp_ids->comp_ids[eh_temp].comp_id
   ELSE
    SET reply->qual_component[pwc_cnt].act_pw_comp_id = request->qual_component[pwc_cnt].
    act_pw_comp_id
   ENDIF
   IF ((request->qual_component[pwc_cnt].act_pw_comp_id != 0)
    AND (request->qual_component[pwc_cnt].pw_action_meaning="REMOVE"))
    SET parent_entity_name = ""
    SET parent_entity_id = 0.0
    SELECT INTO "nl:"
     FROM act_pw_comp apc
     WHERE (request->qual_component[pwc_cnt].act_pw_comp_id=apc.act_pw_comp_id)
     DETAIL
      parent_entity_name = apc.parent_entity_name, parent_entiyt_id = apc.parent_entity_id,
      act_pw_comp->last_action_seq = apc.last_action_seq
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apc_select_rmv_actn_failed
    ENDIF
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     apc.*
     FROM act_pw_comp apc
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
     HEAD REPORT
      updt_cnt = apc.updt_cnt
     WITH forupdate(apc), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_component[pwc_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F1"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_pw_comp apc
     SET apc.active_ind = 0, apc.updt_dt_tm = cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->
      updt_id,
      apc.updt_task = reqinfo->updt_task, apc.updt_applctx = reqinfo->updt_applctx, apc.updt_cnt = (
      apc.updt_cnt+ 1)
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
    ;end update
    IF (curqual=0)
     GO TO apc_update_rmv_failed
    ENDIF
    SELECT INTO "nl:"
     FROM act_pw_comp apc
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
     DETAIL
      comp_status_code = apc.comp_status_cd, comp_text_id = apc.parent_entity_id, vcomp_type_mean =
      apc.ref_prnt_ent_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apc_select_rmv_stts_failed
    ENDIF
    IF (vcomp_type_mean="LONG_TEXT")
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE lt.long_text_id=comp_text_id
      HEAD REPORT
       updt_cnt = lt.updt_cnt
      WITH forupdate(lt), nocounter
     ;end select
     IF (curqual=0)
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((updt_cnt != request->qual_component[pwc_cnt].text_updt_cnt))
      SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE_NOTE"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM long_text lt
      SET lt.long_text = request->qual_component[pwc_cnt].comp_text, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0,
       lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_applctx = reqinfo->updt_applctx
      WHERE lt.long_text_id=comp_text_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      GO TO comp_text_rmv_failed
     ENDIF
    ENDIF
   ELSEIF ((request->qual_component[pwc_cnt].act_pw_comp_id != 0)
    AND (((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")) OR ((request->
   qual_component[pwc_cnt].pw_action_meaning="CANCEL"))) )
    SET parent_entity_name = ""
    SET parent_entity_id = 0.0
    IF ((request->qual_component[pwc_cnt].comp_type_mean="NOTE")
     AND (request->qual_component[pwc_cnt].comp_text != null))
     SELECT INTO "nl:"
      FROM act_pw_comp apc
      WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
      DETAIL
       comp_text_id = apc.parent_entity_id
      WITH nocounter
     ;end select
     SET reply->status_data.status = "F"
     SET cfailed = "F"
     SET updt_cnt = 0
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE lt.long_text_id=comp_text_id
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
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
      SET cfailed = "T"
      GO TO exit_script
     ENDIF
     IF ((request->qual_component[pwc_cnt].pw_action_meaning="CANCEL"))
      UPDATE  FROM long_text lt
       SET lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt
        .updt_task = reqinfo->updt_task,
        lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0, lt.active_status_cd = reqdata->
        inactive_status_cd,
        lt.updt_applctx = reqinfo->updt_applctx
       WHERE lt.long_text_id=comp_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       GO TO comp_text_failed
      ENDIF
     ELSE
      UPDATE  FROM long_text lt
       SET lt.long_text = request->qual_component[pwc_cnt].comp_text, lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), lt.updt_id = reqinfo->updt_id,
        lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo
        ->updt_applctx
       WHERE lt.long_text_id=comp_text_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       GO TO comp_text2_failed
      ENDIF
     ENDIF
    ENDIF
    SET vcond_note_updt_cnt = null
    SET vcond_eval_result_ind = request->qual_component[pwc_cnt].cond_eval_result_ind
    IF ((request->qual_component[pwc_cnt].cond_ind=1)
     AND (request->qual_component[pwc_cnt].cond_note_text != null))
     SELECT INTO "nl:"
      FROM act_pw_comp apc
      WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
      DETAIL
       vcond_note_id = apc.cond_note_id
      WITH nocounter
     ;end select
     SET reply->status_data.status = "F"
     SET cfailed = "F"
     SET updt_cnt = 0
     IF (((vcond_note_id=null) OR (vcond_note_id=0)) )
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        vcond_note_id = nextseqnum
       WITH format
      ;end select
      IF (vcond_note_id=0.0)
       GO TO cond_note_text_seq_mod_failed
      ENDIF
      INSERT  FROM long_text lt
       SET lt.long_text_id = vcond_note_id, lt.parent_entity_name = "ACT_PW_COMP", lt
        .parent_entity_id = request->qual_component[pwc_cnt].act_pw_comp_id,
        lt.long_text = request->qual_component[pwc_cnt].cond_note_text, lt.active_ind = 1, lt
        .active_status_cd = reqdata->active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
        ->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
        lt.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       GO TO cond_note_text_failed
      ENDIF
     ELSEIF (vcond_note_id != null
      AND vcond_note_id != 0
      AND (request->qual_component[pwc_cnt].cond_note_text != null))
      SELECT INTO "nl:"
       lt.*
       FROM long_text lt
       WHERE lt.long_text_id=vcond_note_id
       HEAD REPORT
        updt_cnt = lt.updt_cnt
       WITH forupdate(lt), nocounter
      ;end select
      IF (curqual=0)
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      IF ((updt_cnt != request->qual_component[pwc_cnt].cond_note_updt_cnt))
       SET reply->status_data.subeventstatus[1].operationname = "locking(cond_note_updt)"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
       SET cfailed = "T"
       GO TO exit_script
      ENDIF
      UPDATE  FROM long_text lt
       SET lt.long_text = request->qual_component[pwc_cnt].cond_note_text, lt.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
        lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo
        ->updt_applctx
       WHERE lt.long_text_id=vcond_note_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       GO TO cond_note_text_upd_failed
      ENDIF
     ENDIF
    ENDIF
    FOR (y = 1 TO care_category_cnt)
      IF ((request->qual_care_category[y].sequence=request->qual_component[pwc_cnt].care_category_seq
      )
       AND (request->qual_care_category[y].pw_action_meaning != "REMOVE"))
       SET cc_seq = y
      ENDIF
    ENDFOR
    SET time_cnt = 0
    SET tf_seq = request->qual_component[pwc_cnt].time_frame_seq
    IF (tf_seq > 0
     AND tf_seq <= time_frame_cnt)
     FOR (y = 1 TO time_frame_cnt)
      IF ((request->qual_time_frame[y].act_time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((tf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_time_frame[y].act_time_frame_id != 0))
        SET tf_id = request->qual_time_frame[y].act_time_frame_id
       ELSE
        SET tf_id = act_time_ids->time_ids[time_cnt].time_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET tf_id = 0
    ENDIF
    SET comp_cnt = 0
    SET rc_seq = request->qual_component[pwc_cnt].related_comp_seq
    IF (rc_seq > 0
     AND rc_seq <= component_cnt)
     FOR (y = 1 TO component_cnt)
      IF ((request->qual_component[y].act_pw_comp_id=0))
       SET comp_cnt = (comp_cnt+ 1)
      ENDIF
      IF ((rc_seq=request->qual_component[y].sequence)
       AND (tf_seq=request->qual_component[y].time_frame_seq)
       AND (cc_seq=request->qual_component[y].care_category_seq)
       AND (request->qual_component[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_component[y].act_pw_comp_id != 0))
        SET rc_id = request->qual_component[y].act_pw_comp_id
       ELSE
        SET rc_id = act_comp_ids->comp_ids[comp_cnt].comp_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET rc_id = 0
    ENDIF
    IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
     AND (request->qual_component[pwc_cnt].activated_ind=1))
     SET comp_status_code = activated_type_cd
    ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
     AND (request->qual_component[pwc_cnt].included_ind=1))
     SET comp_status_code = included_type_cd
    ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY"))
     SET comp_status_code = excluded_type_cd
    ELSE
     SET comp_status_code = canceled_type_cd
    ENDIF
    SELECT INTO "nl:"
     FROM act_pw_comp apc
     WHERE (request->qual_component[pwc_cnt].act_pw_comp_id=apc.act_pw_comp_id)
     DETAIL
      act_pw_comp->last_action_seq = apc.last_action_seq
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apc_select_mod_actn_failed
    ENDIF
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     apc.*
     FROM act_pw_comp apc
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
     HEAD REPORT
      updt_cnt = apc.updt_cnt, parent_entity_name = apc.parent_entity_name, parent_entity_id =
      IF ((request->qual_component[pwc_cnt].parent_entity_id != null)) request->qual_component[
       pwc_cnt].parent_entity_id
      ELSE apc.parent_entity_id
      ENDIF
     WITH forupdate(apc), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_component[pwc_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_pw_comp apc
     SET apc.act_care_cat_id =
      IF (cc_seq != null) request->qual_care_category[cc_seq].act_care_cat_id
      ELSE apc.act_care_cat_id
      ENDIF
      , apc.act_time_frame_id =
      IF (tf_seq != null) tf_id
      ELSE apc.act_time_frame_id
      ENDIF
      , apc.sequence =
      IF ((request->qual_component[pwc_cnt].sequence != null)) request->qual_component[pwc_cnt].
       sequence
      ELSE apc.sequence
      ENDIF
      ,
      apc.comp_label =
      IF ((request->qual_component[pwc_cnt].comp_label != null)) request->qual_component[pwc_cnt].
       comp_label
      ELSE apc.comp_label
      ENDIF
      , apc.repeat_ind =
      IF ((request->qual_component[pwc_cnt].repeat_ind != null)) request->qual_component[pwc_cnt].
       repeat_ind
      ELSE apc.repeat_ind
      ENDIF
      , apc.existing_ind =
      IF ((request->qual_component[pwc_cnt].existing_ind != null)) request->qual_component[pwc_cnt].
       existing_ind
      ELSE apc.existing_ind
      ENDIF
      ,
      apc.parent_entity_id =
      IF ((request->qual_component[pwc_cnt].parent_entity_id != null)) request->qual_component[
       pwc_cnt].parent_entity_id
      ELSE apc.parent_entity_id
      ENDIF
      , apc.comp_status_cd = comp_status_code, apc.canceled_ind =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="CANCEL")) 1
      ELSE 0
      ENDIF
      ,
      apc.canceled_dt_tm =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="CANCEL")) cnvtdatetime(curdate,
        curtime3)
      ELSE apc.canceled_dt_tm
      ENDIF
      , apc.encntr_id =
      IF ((request->qual_component[pwc_cnt].encntr_id != null)) request->qual_component[pwc_cnt].
       encntr_id
      ELSE apc.encntr_id
      ENDIF
      , apc.included_ind =
      IF ((request->qual_component[pwc_cnt].included_ind=1)) 1
      ELSE 0
      ENDIF
      ,
      apc.included_dt_tm =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
       AND (request->qual_component[pwc_cnt].included_ind=1)
       AND (request->qual_component[pwc_cnt].activated_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE apc.included_dt_tm
      ENDIF
      , apc.activated_ind =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
       AND (request->qual_component[pwc_cnt].activated_ind=1)) 1
      ELSE 0
      ENDIF
      , apc.activated_dt_tm =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
       AND (request->qual_component[pwc_cnt].activated_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE apc.activated_dt_tm
      ENDIF
      ,
      apc.activated_prsnl_id =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")
       AND (request->qual_component[pwc_cnt].activated_ind=1)) reqinfo->updt_id
      ELSE apc.activated_prsnl_id
      ENDIF
      , apc.after_qty = request->qual_component[pwc_cnt].after_qty, apc.age_units_cd = request->
      qual_component[pwc_cnt].age_units_cd,
      apc.related_comp_id =
      IF (rc_seq != null) rc_id
      ELSE apc.related_comp_id
      ENDIF
      , apc.linked_to_tf_ind = request->qual_component[pwc_cnt].linked_to_tf_ind, apc.last_action_seq
       = (apc.last_action_seq+ 1),
      apc.updt_dt_tm = cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->updt_id, apc.updt_task
       = reqinfo->updt_task,
      apc.updt_applctx = reqinfo->updt_applctx, apc.updt_cnt = (apc.updt_cnt+ 1), apc.duration_qty =
      request->qual_component[pwc_cnt].duration_qty,
      apc.duration_unit_cd = request->qual_component[pwc_cnt].duration_unit_cd, apc.task_assay_cd =
      IF ((request->qual_component[pwc_cnt].task_assay_cd != null)) request->qual_component[pwc_cnt].
       task_assay_cd
      ELSE apc.task_assay_cd
      ENDIF
      , apc.event_cd = request->qual_component[pwc_cnt].event_cd,
      apc.result_type_cd =
      IF ((request->qual_component[pwc_cnt].result_type_cd != null)) request->qual_component[pwc_cnt]
       .result_type_cd
      ELSE apc.result_type_cd
      ENDIF
      , apc.outcome_operator_cd =
      IF ((request->qual_component[pwc_cnt].outcome_operator_cd != null)) request->qual_component[
       pwc_cnt].outcome_operator_cd
      ELSE apc.outcome_operator_cd
      ENDIF
      , apc.result_value = request->qual_component[pwc_cnt].result_value,
      apc.result_units_cd = request->qual_component[pwc_cnt].result_units_cd, apc
      .capture_variance_ind =
      IF ((request->qual_component[pwc_cnt].capture_variance_ind=1)) 1
      ELSEIF ((request->qual_component[pwc_cnt].capture_variance_ind=0)) 0
      ELSE apc.capture_variance_ind
      ENDIF
      , apc.variance_required_ind =
      IF ((request->qual_component[pwc_cnt].variance_required_ind=1)) 1
      ELSEIF ((request->qual_component[pwc_cnt].variance_required_ind=0)) 0
      ELSE apc.variance_required_ind
      ENDIF
      ,
      apc.dcp_forms_ref_id = request->qual_component[pwc_cnt].dcp_forms_ref_id, apc.reference_task_id
       = request->qual_component[pwc_cnt].reference_task_id, apc.outcome_forms_ref_id = request->
      qual_component[pwc_cnt].outcome_forms_ref_id,
      apc.start_dt_tm = cnvtdatetime(request->qual_component[pwc_cnt].start_dt_tm), apc.end_dt_tm =
      cnvtdatetime(request->qual_component[pwc_cnt].end_dt_tm), apc.rrf_age_qty =
      IF ((request->qual_component[pwc_cnt].rrf_age_qty != null)) request->qual_component[pwc_cnt].
       rrf_age_qty
      ELSE apc.rrf_age_qty
      ENDIF
      ,
      apc.rrf_age_units_cd =
      IF ((request->qual_component[pwc_cnt].rrf_age_units_cd != null)) request->qual_component[
       pwc_cnt].rrf_age_units_cd
      ELSE apc.rrf_age_units_cd
      ENDIF
      , apc.rrf_sex_cd =
      IF ((request->qual_component[pwc_cnt].rrf_sex_cd != null)) request->qual_component[pwc_cnt].
       rrf_sex_cd
      ELSE apc.rrf_sex_cd
      ENDIF
      , apc.cond_ind =
      IF ((request->qual_component[pwc_cnt].cond_remove_ind=1)) 0
      ELSEIF ((request->qual_component[pwc_cnt].cond_ind != null)) request->qual_component[pwc_cnt].
       cond_ind
      ELSE apc.cond_ind
      ENDIF
      ,
      apc.cond_desc =
      IF ((request->qual_component[pwc_cnt].cond_ind=1)
       AND (request->qual_component[pwc_cnt].cond_desc != null)) request->qual_component[pwc_cnt].
       cond_desc
      ELSE apc.cond_desc
      ENDIF
      , apc.cond_note_id =
      IF (vcond_note_id != null) vcond_note_id
      ELSE apc.cond_note_id
      ENDIF
      , apc.cond_module_name =
      IF ((request->qual_component[pwc_cnt].cond_ind=1)
       AND (request->qual_component[pwc_cnt].cond_module_name != null)) request->qual_component[
       pwc_cnt].cond_module_name
      ELSE apc.cond_module_name
      ENDIF
      ,
      apc.cond_false_ind =
      IF ((request->qual_component[pwc_cnt].cond_ind=1)) request->qual_component[pwc_cnt].
       cond_false_ind
      ELSE apc.cond_false_ind
      ENDIF
      , apc.cond_eval_dt_tm = cnvtdatetime(request->qual_component[pwc_cnt].cond_eval_dt_tm), apc
      .cond_eval_ind = request->qual_component[pwc_cnt].cond_eval_ind,
      apc.cond_eval_result_ind =
      IF ((request->qual_component[pwc_cnt].cond_eval_ind=1)) request->qual_component[pwc_cnt].
       cond_eval_result_ind
      ELSE apc.cond_eval_result_ind
      ENDIF
      , apc.cond_sys_eval_ind =
      IF ((request->qual_component[pwc_cnt].cond_eval_ind=1)) request->qual_component[pwc_cnt].
       cond_sys_eval_ind
      ELSE apc.cond_sys_eval_ind
      ENDIF
      , apc.cond_eval_prsnl_id =
      IF ((request->qual_component[pwc_cnt].cond_eval_ind=1)) request->qual_component[pwc_cnt].
       cond_eval_prsnl_id
      ELSE apc.cond_eval_prsnl_id
      ENDIF
     WHERE (apc.act_pw_comp_id=request->qual_component[pwc_cnt].act_pw_comp_id)
    ;end update
    IF (curqual=0)
     GO TO apc_update_mod_failed
    ENDIF
    SET fid_cnt = 0
    SET newcf_cnt = 0
    SET oldcf_cnt = 0
    SET comp_focus_cnt = size(request->qual_component[pwc_cnt].comp_focus_list,5)
    FOR (x = 1 TO comp_focus_cnt)
      IF ((request->qual_component[pwc_cnt].comp_focus_list[x].act_pw_comp_focus_r_id=0))
       SET newcf_cnt = (newcf_cnt+ 1)
      ELSE
       SET oldcf_cnt = (oldcf_cnt+ 1)
      ENDIF
    ENDFOR
    FOR (x = 1 TO newcf_cnt)
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       stat = alterlist(act_pw_comp_focus_ids->focus_ids,x), act_pw_comp_focus_ids->focus_ids[x].
       act_pw_comp_focus_r_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO pcf_seq_failed
     ENDIF
    ENDFOR
    FOR (cf_cnt = 1 TO comp_focus_cnt)
      IF ((request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].act_pw_comp_focus_r_id != 0)
       AND (request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].pw_action_meaning="REMOVE"))
       SET reply->status_data.status = "F"
       SET cfailed = "F"
       SET updt_cnt = 0
       SELECT INTO "nl:"
        apcf.*
        FROM act_pw_comp_focus_r apcf
        WHERE (apcf.act_pw_comp_focus_r_id=request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].
        act_pw_comp_focus_r_id)
        HEAD REPORT
         updt_cnt = apcf.updt_cnt
        WITH forupdate(apcf), nocounter
       ;end select
       IF (curqual=0)
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       IF ((updt_cnt != request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].updt_cnt))
        SET reply->status_data.subeventstatus[1].operationname = "locking"
        SET reply->status_data.subeventstatus[1].operationstatus = "F1"
        SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       UPDATE  FROM act_pw_comp_focus_r apcf
        SET apcf.active_ind = 0, apcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), apcf.updt_id =
         reqinfo->updt_id,
         apcf.updt_task = reqinfo->updt_task, apcf.updt_applctx = reqinfo->updt_applctx, apcf
         .updt_cnt = (apcf.updt_cnt+ 1)
        WHERE (apcf.act_pw_comp_focus_r_id=request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].
        act_pw_comp_focus_r_id)
       ;end update
       IF (curqual=0)
        GO TO apcf_update_rmv_failed
       ENDIF
      ELSEIF ((request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].act_pw_comp_focus_r_id=0)
       AND (request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].pw_action_meaning="CREATE"))
       SET fid_cnt = (fid_cnt+ 1)
       INSERT  FROM act_pw_comp_focus_r apcf
        SET apcf.act_pw_comp_focus_r_id = act_pw_comp_focus_ids->focus_ids[fid_cnt].
         act_pw_comp_focus_r_id, apcf.act_pw_comp_id = request->qual_component[pwc_cnt].
         act_pw_comp_id, apcf.nomenclature_id = request->qual_component[pwc_cnt].comp_focus_list[
         cf_cnt].nomenclature_id,
         apcf.primary_ind = request->qual_component[pwc_cnt].comp_focus_list[cf_cnt].primary_ind,
         apcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), apcf.updt_id = reqinfo->updt_id,
         apcf.updt_task = reqinfo->updt_task, apcf.updt_cnt = 0, apcf.updt_applctx = reqinfo->
         updt_applctx,
         apcf.active_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO pcf2_failed
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="CREATE")
    AND (request->qual_component[pwc_cnt].act_pw_comp_id=0))
    SET id_cnt = (id_cnt+ 1)
    SET temp_dt_tm = format(1,";;q")
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
      SET lt.long_text_id = comp_text_id, lt.parent_entity_name = "ACT_PW_COMP", lt.parent_entity_id
        = act_comp_ids->comp_ids[id_cnt].comp_id,
       lt.long_text = request->qual_component[pwc_cnt].comp_text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO comp_text3_failed
     ENDIF
    ENDIF
    IF ((request->qual_component[pwc_cnt].activated_ind=1))
     SET comp_status_code = activated_type_cd
     SET activated_id = reqinfo->updt_id
     SET activated_date_time = cnvtdatetime(curdate,curtime3)
     SET included_date_time = cnvtdatetime(curdate,curtime3)
    ELSE
     SET activated_date_time = cnvtdatetime(temp_dt_tm)
     IF ((request->qual_component[pwc_cnt].included_ind=1))
      SET comp_status_code = included_type_cd
      SET included_date_time = cnvtdatetime(curdate,curtime3)
     ELSE
      SET comp_status_code = excluded_type_cd
      SET included_date_time = cnvtdatetime(temp_dt_tm)
     ENDIF
    ENDIF
    IF ((request->qual_component[pwc_cnt].cond_ind=1))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       vcond_note_id = nextseqnum
      WITH format
     ;end select
     IF (vcond_note_id=0.0)
      GO TO cond_note_text_seq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = vcond_note_id, lt.parent_entity_name = "ACT_PW_COMP", lt.parent_entity_id
        = request->qual_component[pwc_cnt].act_pw_comp_id,
       lt.long_text = request->qual_component[pwc_cnt].cond_note_text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO cond_note_text_create_failed
     ENDIF
    ENDIF
    SET parent_entity_name = ""
    SET parent_entity_id = 0
    SET comp_type_cd = 0
    SET ref_prnt_ent_name = fillstring(32," ")
    SET ref_prnt_ent_id = 0.0
    SET comp_type_cd = 0.0
    IF ((request->qual_component[pwc_cnt].comp_type_mean="NOTE"))
     SET ref_prnt_ent_name = "LONG_TEXT"
     SET ref_prnt_ent_id = request->qual_component[pwc_cnt].ref_prnt_ent_id
     SET parent_entity_name = "LONG_TEXT"
     SET parent_entity_id = comp_text_id
     SET comp_type_cd = note_type_cd
    ENDIF
    IF ((request->qual_component[pwc_cnt].comp_type_mean="RESULT OUTCO"))
     SET ref_prnt_ent_name = ""
     SET ref_prnt_ent_id = 0.0
     SET parent_entity_name = ""
     SET parent_entity_id = 0.0
     SET comp_type_cd = result_outcome_type_cd
    ENDIF
    IF ((request->qual_component[pwc_cnt].comp_type_mean="ORDER CREATE"))
     SET ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
     SET ref_prnt_ent_id = request->qual_component[pwc_cnt].ref_prnt_ent_id
     SET parent_entity_name = "ORDERS"
     SET parent_entity_id = request->qual_component[pwc_cnt].parent_entity_id
     SET comp_type_cd = order_create_type_cd
    ENDIF
    IF ((request->qual_component[pwc_cnt].comp_type_mean="OUTCOME CREA"))
     SET ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
     SET ref_prnt_ent_id = request->qual_component[pwc_cnt].ref_prnt_ent_id
     SET parent_entity_name = "ORDERS"
     SET parent_entity_id = request->qual_component[pwc_cnt].parent_entity_id
     SET comp_type_cd = outcome_create_type_cd
    ENDIF
    IF ((request->qual_component[pwc_cnt].comp_type_mean="TASK CREATE"))
     SET ref_prnt_ent_name = "ORDER_TASK"
     SET ref_prnt_ent_id = request->qual_component[pwc_cnt].ref_prnt_ent_id
     SET parent_entity_name = "TASK_ACTIVITY"
     SET parent_entity_id = request->qual_component[pwc_cnt].parent_entity_id
     SET comp_type_cd = task_create_type_cd
    ENDIF
    IF ((request->qual_component[pwc_cnt].comp_type_mean="LABEL"))
     SET comp_type_cd = label_type_cd
    ENDIF
    FOR (y = 1 TO care_category_cnt)
      IF ((request->qual_care_category[y].sequence=request->qual_component[pwc_cnt].care_category_seq
      )
       AND (request->qual_care_category[y].pw_action_meaning != "REMOVE"))
       SET cc_seq = y
      ENDIF
    ENDFOR
    SET time_cnt = 0
    SET tf_seq = request->qual_component[pwc_cnt].time_frame_seq
    IF (tf_seq > 0
     AND tf_seq <= time_frame_cnt)
     FOR (y = 1 TO time_frame_cnt)
      IF ((request->qual_time_frame[y].act_time_frame_id=0))
       SET time_cnt = (time_cnt+ 1)
      ENDIF
      IF ((tf_seq=request->qual_time_frame[y].sequence)
       AND (request->qual_time_frame[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_time_frame[y].act_time_frame_id != 0))
        SET tf_id = request->qual_time_frame[y].act_time_frame_id
       ELSE
        SET tf_id = act_time_ids->time_ids[time_cnt].time_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET tf_id = 0
    ENDIF
    SET comp_cnt = 0
    SET rc_seq = request->qual_component[pwc_cnt].related_comp_seq
    IF (rc_seq > 0
     AND rc_seq <= component_cnt)
     FOR (y = 1 TO component_cnt)
      IF ((request->qual_component[y].act_pw_comp_id=0))
       SET comp_cnt = (comp_cnt+ 1)
      ENDIF
      IF ((rc_seq=request->qual_component[y].sequence)
       AND (tf_seq=request->qual_component[y].time_frame_seq)
       AND (cc_seq=request->qual_component[y].care_category_seq)
       AND (request->qual_component[y].pw_action_meaning != "REMOVE"))
       IF ((request->qual_component[y].act_pw_comp_id != 0))
        SET rc_id = request->qual_component[y].act_pw_comp_id
       ELSE
        SET rc_id = act_comp_ids->comp_ids[comp_cnt].comp_id
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET rc_id = 0
    ENDIF
    INSERT  FROM act_pw_comp apc
     SET apc.act_pw_comp_id = act_comp_ids->comp_ids[id_cnt].comp_id, apc.act_time_frame_id = tf_id,
      apc.act_care_cat_id = request->qual_care_category[cc_seq].act_care_cat_id,
      apc.pathway_comp_id = request->qual_component[pwc_cnt].pathway_comp_id, apc.comp_type_cd =
      comp_type_cd, apc.age_units_cd = request->qual_component[pwc_cnt].age_units_cd,
      apc.comp_status_cd = comp_status_code, apc.encntr_id = request->qual_component[pwc_cnt].
      encntr_id, apc.cond_sys_eval_ind = request->qual_component[pwc_cnt].cond_sys_eval_ind,
      apc.person_id = pathway->person_id, apc.activated_ind = request->qual_component[pwc_cnt].
      activated_ind, apc.activated_dt_tm = cnvtdatetime(activated_date_time),
      apc.activated_prsnl_id = reqinfo->updt_id, apc.repeat_ind = request->qual_component[pwc_cnt].
      repeat_ind, apc.required_ind = request->qual_component[pwc_cnt].required_ind,
      apc.existing_ind = request->qual_component[pwc_cnt].existing_ind, apc.comp_label = request->
      qual_component[pwc_cnt].comp_label, apc.last_action_seq = 1,
      apc.after_qty = request->qual_component[pwc_cnt].after_qty, apc.sequence = request->
      qual_component[pwc_cnt].sequence, apc.pathway_id = request->pathway_id,
      apc.parent_entity_id = parent_entity_id, apc.orig_prnt_ent_id = parent_entity_id, apc
      .ref_prnt_ent_id = ref_prnt_ent_id,
      apc.related_comp_id = rc_id, apc.parent_entity_name = parent_entity_name, apc.ref_prnt_ent_name
       = ref_prnt_ent_name,
      apc.created_dt_tm = cnvtdatetime(curdate,curtime3), apc.included_ind = request->qual_component[
      pwc_cnt].included_ind, apc.included_dt_tm = cnvtdatetime(included_date_time),
      apc.canceled_ind = 0, apc.canceled_dt_tm = cnvtdatetime(temp_dt_tm), apc.active_ind = 1,
      apc.updt_dt_tm = cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->updt_id, apc.updt_task
       = reqinfo->updt_task,
      apc.updt_cnt = 0, apc.updt_applctx = reqinfo->updt_applctx, apc.duration_qty = request->
      qual_component[pwc_cnt].duration_qty,
      apc.duration_unit_cd = request->qual_component[pwc_cnt].duration_unit_cd, apc.task_assay_cd =
      request->qual_component[pwc_cnt].task_assay_cd, apc.event_cd = request->qual_component[pwc_cnt]
      .event_cd,
      apc.result_type_cd = request->qual_component[pwc_cnt].result_type_cd, apc.outcome_operator_cd
       = request->qual_component[pwc_cnt].outcome_operator_cd, apc.result_value = request->
      qual_component[pwc_cnt].result_value,
      apc.result_units_cd = request->qual_component[pwc_cnt].result_units_cd, apc
      .capture_variance_ind = request->qual_component[pwc_cnt].capture_variance_ind, apc
      .variance_required_ind = request->qual_component[pwc_cnt].variance_required_ind,
      apc.dcp_forms_ref_id = request->qual_component[pwc_cnt].dcp_forms_ref_id, apc
      .outcome_forms_ref_id = request->qual_component[pwc_cnt].outcome_forms_ref_id, apc
      .reference_task_id = request->qual_component[pwc_cnt].reference_task_id,
      apc.start_dt_tm = cnvtdatetime(request->qual_component[pwc_cnt].start_dt_tm), apc.end_dt_tm =
      cnvtdatetime(request->qual_component[pwc_cnt].end_dt_tm), apc.linked_to_tf_ind = request->
      qual_component[pwc_cnt].linked_to_tf_ind,
      apc.cond_ind = request->qual_component[pwc_cnt].cond_ind, apc.cond_desc =
      IF ((request->qual_component[pwc_cnt].cond_ind=1)) request->qual_component[pwc_cnt].cond_desc
      ELSE null
      ENDIF
      , apc.cond_note_id = vcond_note_id,
      apc.cond_module_name =
      IF ((request->qual_component[pwc_cnt].cond_ind=1)) request->qual_component[pwc_cnt].
       cond_module_name
      ELSE null
      ENDIF
      , apc.cond_false_ind = request->qual_component[pwc_cnt].cond_false_ind, apc.cond_eval_dt_tm =
      cnvtdatetime(request->qual_component[pwc_cnt].cond_eval_dt_tm),
      apc.cond_eval_ind = request->qual_component[pwc_cnt].cond_eval_ind, apc.cond_eval_result_ind =
      request->qual_component[pwc_cnt].cond_eval_result_ind, apc.rrf_age_qty = request->
      qual_component[pwc_cnt].rrf_age_qty,
      apc.rrf_age_units_cd = request->qual_component[pwc_cnt].rrf_age_units_cd, apc.rrf_sex_cd =
      request->qual_component[pwc_cnt].rrf_sex_cd
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO apc_insert_failed
    ENDIF
    SET comp_focus_cnt = size(request->qual_component[pwc_cnt].comp_focus_list,5)
    FOR (y = 1 TO comp_focus_cnt)
      SELECT INTO "nl:"
       nextseqnum = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        comp_focus_id = nextseqnum
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       GO TO pcf2_seq_failed
      ENDIF
      INSERT  FROM act_pw_comp_focus_r pcf
       SET pcf.act_pw_comp_focus_r_id = comp_focus_id, pcf.act_pw_comp_id = act_comp_ids->comp_ids[
        id_cnt].comp_id, pcf.nomenclature_id = request->qual_component[pwc_cnt].comp_focus_list[y].
        nomenclature_id,
        pcf.primary_ind = request->qual_component[pwc_cnt].comp_focus_list[y].primary_ind, pcf
        .updt_dt_tm = cnvtdatetime(curdate,curtime3), pcf.updt_id = reqinfo->updt_id,
        pcf.updt_task = reqinfo->updt_task, pcf.updt_cnt = 0, pcf.updt_applctx = reqinfo->
        updt_applctx,
        pcf.active_ind = 1
       WITH nocounter
      ;end insert
      IF (curqual=0)
       GO TO pcf2_failed
      ENDIF
    ENDFOR
   ENDIF
   IF ((((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")) OR ((((request->
   qual_component[pwc_cnt].pw_action_meaning="CANCEL")) OR ((((request->qual_component[pwc_cnt].
   pw_action_meaning="CREATE")) OR ((request->qual_component[pwc_cnt].pw_action_meaning="REMOVE")))
   )) )) )
    INSERT  FROM pw_comp_action pca
     SET pca.act_pw_comp_id =
      IF ((request->qual_component[pwc_cnt].act_pw_comp_id != 0)) request->qual_component[pwc_cnt].
       act_pw_comp_id
      ELSE act_comp_ids->comp_ids[id_cnt].comp_id
      ENDIF
      , pca.pw_comp_action_seq =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="CREATE")) 1
      ELSE (act_pw_comp->last_action_seq+ 1)
      ENDIF
      , pca.comp_status_cd = comp_status_code,
      pca.action_type_cd =
      IF ((request->qual_component[pwc_cnt].pw_action_meaning="MODIFY")) modifyc_type_cd
      ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="CANCEL")) cancel_type_cd
      ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="REMOVE")) remove_type_cd
      ELSEIF ((request->qual_component[pwc_cnt].pw_action_meaning="CREATE")) create_type_cd
      ENDIF
      , pca.action_dt_tm = cnvtdatetime(curdate,curtime3), pca.action_prsnl_id = reqinfo->updt_id,
      pca.parent_entity_name = parent_entity_name, pca.parent_entity_id = parent_entity_id, pca
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pca.updt_id = reqinfo->updt_id, pca.updt_task = reqinfo->updt_task, pca.updt_cnt = 0,
      pca.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET comp_event_cnt = size(request->qual_component[pwc_cnt].variance_event_list,5)
    FOR (x = 1 TO comp_event_cnt)
      SET var_reason_text_id = 0.0
      SET var_action_text_id = 0.0
      IF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id=0))
       SELECT INTO "nl:"
        nextseqnum = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         variance_reltn_id = nextseqnum
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        GO TO pvr_seq_failed
       ENDIF
      ENDIF
      SET eh_temp1 = 0
      SET stat = alterlist(reply->qual_component[pwc_cnt].variance_event_list,x)
      IF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id=0))
       SET eh_temp1 = (eh_temp1+ 1)
       SET reply->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id =
       variance_reltn_id
      ELSE
       SET reply->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id = request->
       qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id
      ENDIF
      IF ((request->qual_component[pwc_cnt].variance_event_list[x].reason_text != null)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].reason_text_id=0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=0))
       SELECT INTO "nl:"
        nextseqnum = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         var_reason_text_id = nextseqnum
        WITH format
       ;end select
       IF (var_reason_text_id=0.0)
        GO TO text_seq_failed
       ENDIF
       INSERT  FROM long_text lt
        SET lt.long_text_id = var_reason_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
         .parent_entity_id =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id > 0))
          request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id
         ELSE variance_reltn_id
         ENDIF
         ,
         lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].reason_text, lt
         .active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
         lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
         ->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
         lt.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO text2_failed
       ENDIF
      ELSEIF ((request->qual_component[pwc_cnt].variance_event_list[x].reason_text != null)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].reason_text_id != 0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=0))
       SELECT INTO "nl:"
        lt.*
        FROM long_text lt
        WHERE (lt.long_text_id=request->qual_component[pwc_cnt].variance_event_list[x].reason_text_id
        )
        HEAD REPORT
         updt_cnt = lt.updt_cnt
        WITH forupdate(lt), nocounter
       ;end select
       IF (curqual=0)
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].reason_text_updt_cnt)
       )
        SET reply->status_data.subeventstatus[1].operationname = "locking_UPDATE_VAR_NOTE1"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text lt
        SET lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].reason_text, lt
         .updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
         lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo
         ->updt_applctx
        WHERE (lt.long_text_id=request->qual_component[pwc_cnt].variance_event_list[x].reason_text_id
        )
        WITH nocounter
       ;end update
       IF (curqual=0)
        GO TO var_text_upd_failed
       ENDIF
      ENDIF
      IF ((request->qual_component[pwc_cnt].variance_event_list[x].action_text != null)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].action_text_id=0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=0))
       SELECT INTO "nl:"
        nextseqnum = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         var_action_text_id = nextseqnum
        WITH format
       ;end select
       IF (var_action_text_id=0.0)
        GO TO text_seq_failed
       ENDIF
       INSERT  FROM long_text lt
        SET lt.long_text_id = var_action_text_id, lt.parent_entity_name = "PW_VARIANCE_RELTN", lt
         .parent_entity_id =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id > 0))
          request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id
         ELSE variance_reltn_id
         ENDIF
         ,
         lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].action_text, lt
         .active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
         lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
         ->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
         lt.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO text2_failed
       ENDIF
      ELSEIF ((request->qual_component[pwc_cnt].variance_event_list[x].action_text != null)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].action_text_id != 0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=0))
       SELECT INTO "nl:"
        lt.*
        FROM long_text lt
        WHERE (lt.long_text_id=request->qual_component[pwc_cnt].variance_event_list[x].action_text_id
        )
        HEAD REPORT
         updt_cnt = lt.updt_cnt
        WITH forupdate(lt), nocounter
       ;end select
       IF (curqual=0)
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].action_text_updt_cnt)
       )
        SET reply->status_data.subeventstatus[1].operationname = "locking_UPDATE_VAR_NOTE2"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text lt
        SET lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].action_text, lt
         .updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
         lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo
         ->updt_applctx
        WHERE (lt.long_text_id=request->qual_component[pwc_cnt].variance_event_list[x].action_text_id
        )
        WITH nocounter
       ;end update
       IF (curqual=0)
        GO TO var_text_upd_failed
       ENDIF
      ENDIF
      IF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id=0))
       INSERT  FROM pw_variance_reltn pvr
        SET pvr.pw_variance_reltn_id = variance_reltn_id, pvr.pathway_id = request->pathway_id, pvr
         .parent_entity_name = "ACT_PW_COMP",
         pvr.parent_entity_id =
         IF ((request->qual_component[pwc_cnt].act_pw_comp_id != 0)) request->qual_component[pwc_cnt]
          .act_pw_comp_id
         ELSE act_comp_ids->comp_ids[id_cnt].comp_id
         ENDIF
         , pvr.event_id = request->qual_component[pwc_cnt].variance_event_list[x].event_id, pvr
         .variance_type_cd = request->qual_component[pwc_cnt].variance_event_list[x].variance_type_cd,
         pvr.reason_cd = request->qual_component[pwc_cnt].variance_event_list[x].reason_cd, pvr
         .reason_text_id = var_reason_text_id, pvr.action_cd = request->qual_component[pwc_cnt].
         variance_event_list[x].action_cd,
         pvr.action_text_id = var_action_text_id, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         pvr.updt_id = reqinfo->updt_id,
         pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = 0, pvr.updt_applctx = reqinfo->
         updt_applctx,
         pvr.variance_dt_tm = cnvtdatetime(curdate,curtime3), pvr.active_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        GO TO pvr_failed
       ENDIF
      ELSEIF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id > 0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=0))
       SET reply->status_data.status = "F"
       SET cfailed = "F"
       SET updt_cnt = 0
       SELECT INTO "nl:"
        pvr.*
        FROM pw_variance_reltn pvr
        WHERE (pvr.pw_variance_reltn_id=request->qual_component[pwc_cnt].variance_event_list[x].
        pw_variance_reltn_id)
        HEAD REPORT
         updt_cnt = pvr.updt_cnt
        WITH forupdate(pvr), nocounter
       ;end select
       IF (curqual=0)
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].var_updt_cnt))
        SET reply->status_data.subeventstatus[1].operationname = "locking2"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       UPDATE  FROM pw_variance_reltn pvr
        SET pvr.variance_type_cd =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].variance_type_cd > 0)) request
          ->qual_component[pwc_cnt].variance_event_list[x].variance_type_cd
         ELSE pvr.variance_type_cd
         ENDIF
         , pvr.reason_cd =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].reason_cd > 0)) request->
          qual_component[pwc_cnt].variance_event_list[x].reason_cd
         ELSE pvr.reason_cd
         ENDIF
         , pvr.action_cd =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].action_cd >= 0)) request->
          qual_component[pwc_cnt].variance_event_list[x].action_cd
         ELSE pvr.action_cd
         ENDIF
         ,
         pvr.reason_text_id =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].reason_text_id > 0)) request->
          qual_component[pwc_cnt].variance_event_list[x].reason_text_id
         ELSEIF (var_reason_text_id > 0) var_reason_text_id
         ELSE pvr.reason_text_id
         ENDIF
         , pvr.action_text_id =
         IF ((request->qual_component[pwc_cnt].variance_event_list[x].action_text_id > 0)) request->
          qual_component[pwc_cnt].variance_event_list[x].action_text_id
         ELSEIF (var_action_text_id > 0) var_action_text_id
         ELSE pvr.action_text_id
         ENDIF
         , pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         pvr.updt_id = reqinfo->updt_id, pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = (pvr
         .updt_cnt+ 1),
         pvr.updt_applctx = reqinfo->updt_applctx
        WHERE (pvr.pw_variance_reltn_id=request->qual_component[pwc_cnt].variance_event_list[x].
        pw_variance_reltn_id)
       ;end update
       IF (curqual=0)
        GO TO pvr_updt_failed
       ENDIF
      ELSEIF ((request->qual_component[pwc_cnt].variance_event_list[x].pw_variance_reltn_id > 0)
       AND (request->qual_component[pwc_cnt].variance_event_list[x].remove_ind=1))
       SET reply->status_data.status = "F"
       SET cfailed = "F"
       SET updt_cnt = 0
       SELECT INTO "nl:"
        pvr.*
        FROM pw_variance_reltn pvr
        WHERE (pvr.pw_variance_reltn_id=request->qual_component[pwc_cnt].variance_event_list[x].
        pw_variance_reltn_id)
        HEAD REPORT
         updt_cnt = pvr.updt_cnt
        WITH forupdate(pvr), nocounter
       ;end select
       IF (curqual=0)
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].var_updt_cnt))
        SET reply->status_data.subeventstatus[1].operationname = "locking2"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "pathway"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
        SET cfailed = "T"
        GO TO exit_script
       ENDIF
       UPDATE  FROM pw_variance_reltn pvr
        SET pvr.active_ind = 0, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr.updt_id =
         reqinfo->updt_id,
         pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = (pvr.updt_cnt+ 1), pvr.updt_applctx =
         reqinfo->updt_applctx
        WHERE (pvr.pw_variance_reltn_id=request->qual_component[pwc_cnt].variance_event_list[x].
        pw_variance_reltn_id)
       ;end update
       IF (curqual=0)
        GO TO pvr_remove_failed
       ENDIF
       SET rmv_reason_text_id = 0.0
       SET rmv_action_text_id = 0.0
       SELECT INTO "nl:"
        pvr.*
        FROM pw_variance_reltn pvr
        WHERE (pvr.pw_variance_reltn_id=request->qual_component[pwc_cnt].variance_event_list[x].
        pw_variance_reltn_id)
        HEAD REPORT
         rmv_reason_text_id = pvr.reason_text_id, rmv_action_text_id = pvr.action_text_id
        WITH nocounter
       ;end select
       IF (rmv_reason_text_id > 0)
        SELECT INTO "nl:"
         lt.*
         FROM long_text lt
         WHERE lt.long_text_id=rmv_reason_text_id
         HEAD REPORT
          updt_cnt = lt.updt_cnt
         WITH forupdate(lt), nocounter
        ;end select
        IF (curqual=0)
         SET cfailed = "T"
         GO TO exit_script
        ENDIF
        IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].reason_text_updt_cnt
        ))
         SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE_VAR_NOTE1"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
         SET cfailed = "T"
         GO TO exit_script
        ENDIF
        UPDATE  FROM long_text lt
         SET lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].reason_text, lt
          .updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
          lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0,
          lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_applctx = reqinfo->updt_applctx
         WHERE lt.long_text_id=rmv_reason_text_id
         WITH nocounter
        ;end update
        IF (curqual=0)
         GO TO var_text_rmv_failed
        ENDIF
       ENDIF
       IF (rmv_action_text_id > 0)
        SELECT INTO "nl:"
         lt.*
         FROM long_text lt
         WHERE lt.long_text_id=rmv_action_text_id
         HEAD REPORT
          updt_cnt = lt.updt_cnt
         WITH forupdate(lt), nocounter
        ;end select
        IF (curqual=0)
         SET cfailed = "T"
         GO TO exit_script
        ENDIF
        IF ((updt_cnt != request->qual_component[pwc_cnt].variance_event_list[x].action_text_updt_cnt
        ))
         SET reply->status_data.subeventstatus[1].operationname = "locking_REMOVE_VAR_NOTE2"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
         SET cfailed = "T"
         GO TO exit_script
        ENDIF
        UPDATE  FROM long_text lt
         SET lt.long_text = request->qual_component[pwc_cnt].variance_event_list[x].action_text, lt
          .updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
          lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0,
          lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_applctx = reqinfo->updt_applctx
         WHERE lt.long_text_id=rmv_action_text_id
         WITH nocounter
        ;end update
        IF (curqual=0)
         GO TO var_text_rmv_failed
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET id_cnt = 0
 SET pw_focus_cnt = size(request->pw_focus_list,5)
 FOR (x = 1 TO pw_focus_cnt)
   IF ((request->pw_focus_list[x].act_pw_focus_id=0))
    SET newf_cnt = (newf_cnt+ 1)
   ELSE
    SET oldf_cnt = (oldf_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (x = 1 TO newf_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(act_pw_focus_ids->focus_ids,x), act_pw_focus_ids->focus_ids[x].act_pw_focus_id
     = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO pw_focus_seq_failed
  ENDIF
 ENDFOR
 FOR (pwf_cnt = 1 TO pw_focus_cnt)
   SET eh_temp = 0
   SET stat = alterlist(reply->pw_focus_list,pwf_cnt)
   IF ((request->pw_focus_list[pwf_cnt].act_pw_focus_id=0))
    SET eh_temp = (eh_temp+ 1)
    SET reply->pw_focus_list[pwf_cnt].act_pw_focus_id = act_pw_focus_ids->focus_ids[eh_temp].
    act_pw_focus_id
   ELSE
    SET reply->pw_focus_list[pwf_cnt].act_pw_focus_id = request->pw_focus_list[pwf_cnt].
    act_pw_focus_id
   ENDIF
   IF ((request->pw_focus_list[pwf_cnt].act_pw_focus_id != 0)
    AND (request->pw_focus_list[pwf_cnt].pw_action_meaning="REMOVE"))
    SELECT INTO "nl:"
     FROM act_pw_focus apf
     WHERE (request->pw_focus_list[pwf_cnt].act_pw_focus_id=apf.act_pw_focus_id)
     DETAIL
      act_pw_focus->last_action_seq = apf.last_action_seq
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apf_select_rmv_actn_failed
    ENDIF
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     apf.*
     FROM act_pw_focus apf
     WHERE (apf.act_pw_focus_id=request->pw_focus_list[pwf_cnt].act_pw_focus_id)
     HEAD REPORT
      updt_cnt = apf.updt_cnt
     WITH forupdate(apf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->pw_focus_list[pwf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F1"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_pw_focus apf
     SET apf.active_ind = 0, apf.last_action_seq = (apf.last_action_seq+ 1), apf.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      apf.updt_id = reqinfo->updt_id, apf.updt_task = reqinfo->updt_task, apf.updt_applctx = reqinfo
      ->updt_applctx,
      apf.updt_cnt = (apf.updt_cnt+ 1)
     WHERE (apf.act_pw_focus_id=request->pw_focus_list[pwf_cnt].act_pw_focus_id)
    ;end update
    IF (curqual=0)
     GO TO apf_update_rmv_failed
    ENDIF
   ELSEIF ((request->pw_focus_list[pwf_cnt].act_pw_focus_id != 0)
    AND (((request->pw_focus_list[pwf_cnt].pw_action_meaning="MODIFY")) OR ((request->pw_focus_list[
   pwf_cnt].pw_action_meaning="CANCEL"))) )
    SELECT INTO "nl:"
     FROM act_pw_focus apf
     WHERE (request->pw_focus_list[pwf_cnt].act_pw_focus_id=apf.act_pw_focus_id)
     DETAIL
      act_pw_focus->last_action_seq = apf.last_action_seq
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO apf_select_mod_actn_failed
    ENDIF
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     apf.*
     FROM act_pw_focus apf
     WHERE (apf.act_pw_focus_id=request->pw_focus_list[pwf_cnt].act_pw_focus_id)
     HEAD REPORT
      updt_cnt = apf.updt_cnt
     WITH forupdate(apf), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->pw_focus_list[pwf_cnt].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM act_pw_focus apf
     SET apf.status_cd =
      IF ((request->pw_focus_list[pwf_cnt].status_cd != null)) request->pw_focus_list[pwf_cnt].
       status_cd
      ELSE apf.status_cd
      ENDIF
      , apf.active_ind =
      IF ((request->pw_focus_list[pwf_cnt].active_ind != null)) request->pw_focus_list[pwf_cnt].
       active_ind
      ELSE apf.active_ind
      ENDIF
      , apf.pathway_level_ind = apf.pathway_level,
      apf.last_action_seq = (apf.last_action_seq+ 1), apf.status_dt_tm = cnvtdatetime(curdate,
       curtime3), apf.status_prsnl_id = reqinfo->updt_id,
      apf.sequence = apf.sequence, apf.updt_dt_tm = cnvtdatetime(curdate,curtime3), apf.updt_id =
      reqinfo->updt_id,
      apf.updt_task = reqinfo->updt_task, apf.updt_applctx = reqinfo->updt_applctx, apf.updt_cnt = (
      apf.updt_cnt+ 1)
     WHERE (apf.act_pw_focus_id=request->pw_focus_list[pwf_cnt].act_pw_focus_id)
    ;end update
    IF (curqual=0)
     GO TO apf_update_mod_failed
    ENDIF
   ELSEIF ((request->pw_focus_list[pwf_cnt].pw_action_meaning="CREATE")
    AND (request->pw_focus_list[pwf_cnt].act_pw_focus_id=0))
    SET id_cnt = (id_cnt+ 1)
    INSERT  FROM act_pw_focus apf
     SET apf.act_pw_focus_id = act_pw_focus_ids->focus_ids[id_cnt].act_pw_focus_id, apf.pathway_id =
      request->pathway_id, apf.nomenclature_id = request->pw_focus_list[pwf_cnt].nomenclature_id,
      apf.pathway_level_ind = request->pw_focus_list[pwf_cnt].pathway_level_ind, apf.active_ind = 1,
      apf.sequence = request->pw_focus_list[pwf_cnt].sequence,
      apf.status_cd = request->pw_focus_list[pwf_cnt].status_cd, apf.status_dt_tm = cnvtdatetime(
       curdate,curtime3), apf.status_prsnl_id = reqinfo->updt_id,
      apf.last_action_seq = 1, apf.updt_dt_tm = cnvtdatetime(curdate,curtime3), apf.updt_id = reqinfo
      ->updt_id,
      apf.updt_task = reqinfo->updt_task, apf.updt_applctx = reqinfo->updt_applctx, apf.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO apf_insert_failed
    ENDIF
   ENDIF
   IF ((((request->pw_focus_list[pwf_cnt].pw_action_meaning="MODIFY")) OR ((((request->pw_focus_list[
   pwf_cnt].pw_action_meaning="CANCEL")) OR ((((request->pw_focus_list[pwf_cnt].pw_action_meaning=
   "CREATE")) OR ((request->pw_focus_list[pwf_cnt].pw_action_meaning="REMOVE"))) )) )) )
    INSERT  FROM act_pw_focus_action pfa
     SET pfa.act_pw_focus_id =
      IF ((request->pw_focus_list[pwf_cnt].act_pw_focus_id != 0)) request->pw_focus_list[pwf_cnt].
       act_pw_focus_id
      ELSE act_pw_focus_ids->focus_ids[id_cnt].act_pw_focus_id
      ENDIF
      , pfa.action_seq =
      IF ((request->pw_focus_list[pwf_cnt].pw_action_meaning="CREATE")) 1
      ELSE (act_pw_focus->last_action_seq+ 1)
      ENDIF
      , pfa.status_cd = request->pw_focus_list[pwf_cnt].status_cd,
      pfa.action_dt_tm = cnvtdatetime(curdate,curtime3), pfa.action_prsnl_id = reqinfo->updt_id, pfa
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pfa.updt_id = reqinfo->updt_id, pfa.updt_task = reqinfo->updt_task, pfa.updt_cnt = 0,
      pfa.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SET relationship_cnt = size(request->qual_relationship,5)
 FOR (x = 1 TO relationship_cnt)
   IF ((request->qual_relationship[x].pw_action_meaning="NEW"))
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
      rel_type_meaning, der.entity1_id = request->pathway_id,
      der.entity1_display = request->description, der.entity2_id = request->qual_relationship[x].
      entity_id, der.entity2_display = request->qual_relationship[x].entity_display,
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
   ELSEIF ((request->qual_relationship[x].pw_action_meaning="REMOVE"))
    SET reply->status_data.status = "F"
    SET cfailed = "F"
    SET updt_cnt = 0
    SELECT INTO "nl:"
     der.*
     FROM dcp_entity_reltn der
     WHERE (der.entity2_id=request->qual_relatonship[x].entity_id)
      AND (der.entity_reltn_mean=request->qual_relationship[x].rel_type_meaning)
      AND (der.entity1_id=request->pathway_id)
     HEAD REPORT
      updt_cnt = der.updt_cnt
     WITH forupdate(der), nocounter
    ;end select
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    IF ((updt_cnt != request->qual_relationship[x].updt_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "locking_reltn"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "act_care_cat"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pathway"
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
    UPDATE  FROM dcp_entity_reltn der
     SET der.active_ind = 0, der.updt_dt_tm = cnvtdatetime(curdate,curtime3), der.updt_id = reqinfo->
      updt_id,
      der.updt_task = reqinfo->updt_task, der.updt_cnt = (der.updt_cnt+ 1), der.updt_applctx =
      reqinfo->updt_applctx
     WHERE (der.entity2_id=request->qual_relatonship[x].entity_id)
      AND (der.entity_reltn_mean=request->qual_relationship[x].rel_type_meaning)
      AND (der.entity1_id=request->pathway_id)
    ;end update
    IF (curqual=0)
     GO TO der2_failed
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#pw_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw not exist"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pw_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "update pw"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pw_updt_lt_failed
 SET reply->status_data.subeventstatus[1].operationname = "update lt in pw"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
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
#pvrc_seq2_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval2"
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
#pvrc2_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert22"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#text2_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert text2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#dc_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval_dc_text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#dc_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert dc_text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#atf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "tf sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#atf_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#atf_mod_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "mod_time_frame"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#acc_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cc sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_Pathway"
 SET cfailed = "T"
 GO TO exit_script
#acc_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "care_category"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp ref seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp text seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_text2_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_text3_failed
 SET reply->status_data.subeventstatus[1].operationname = "insrt comp text3"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#comp_text_rmv_failed
 SET reply->status_data.subeventstatus[1].operationname = "upd_comp_text (REMOVE)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_insert_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_update_rmv_failed
 SET reply->status_data.subeventstatus[1].operationname = "update_REMOVE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_update_mod_failed
 SET reply->status_data.subeventstatus[1].operationname = "update_MODIFY and CANCEL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_select_rmv_actn_failed
 SET reply->status_data.subeventstatus[1].operationname = "select_REMOVE_action_seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_select_rmv_stts_failed
 SET reply->status_data.subeventstatus[1].operationname = "select_REMOVE_status"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#apc_select_mod_actn_failed
 SET reply->status_data.subeventstatus[1].operationname = "select_MODIFY&CANCEL_action_seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#der_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "der sequence"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#der_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert der"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_entity_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#der2_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert der2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_entity_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_seq_mod_failed
 SET reply->status_data.subeventstatus[1].operationname = "cond_note_text_seq(MODIFY)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "cond_note_text"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "update cond note"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "cond_note_text_seq(CREATE)"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pathway_comp"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#cond_note_text_create_failed
 SET reply->status_data.subeventstatus[1].operationname = "CREATE cond note"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_pathway"
 SET cfailed = "T"
 GO TO exit_script
#pw_focus_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp focus seq"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf2_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp focus seq2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "ref_seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp focus"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pcf2_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp focus2"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apf_select_rmv_actn_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus select"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apf_update_rmv_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus rmv"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apcf_update_rmv_failed
 SET reply->status_data.subeventstatus[1].operationname = "comp focus rmv"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_comp_focus_r"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apf_select_mod_actn_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus select mod"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apf_update_mod_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus update mod"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pvr_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw variance reltn update mod"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#pvr_remove_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw variance reltn update rmv"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pw_variance_reltn"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#var_text_rmv_failed
 SET reply->status_data.subeventstatus[1].operationname = "variance long_text rmv"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#var_text_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "variance long_text upd"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
 SET cfailed = "T"
 GO TO exit_script
#apf_insert_failed
 SET reply->status_data.subeventstatus[1].operationname = "pw focus insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "act_pw_focus"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_upd_PATHWAY"
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
