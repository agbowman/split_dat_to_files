CREATE PROGRAM br_blueprint_desc_config:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_blueprint_desc_config.prg> script"
 FREE SET temp_bp
 RECORD temp_bp(
   1 desc[*]
     2 cat_mean = vc
     2 mean = vc
     2 desc = vc
     2 action_flag = i2
     2 br_long_text = f8
     2 id = f8
 )
 FREE SET temp_act
 RECORD temp_act(
   1 desc[*]
     2 cat_mean = vc
     2 mean = vc
     2 desc = vc
     2 action_flag = i2
     2 br_long_text = f8
     2 id = f8
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cur_ag_mean = vc
 SET act_cnt = 0
 SET ag_mean_ind = 0
 SET cur_ag_id = 0.0
 SET cur_ag_ver = 0
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt > 0)
  SET grp_tot_cnt = 0
  SET act_tot_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    grp_cnt = 0, grp_tot_cnt = 0, stat = alterlist(temp_bp->desc,100),
    act_cnt = 0, act_tot_cnt = 0, stat = alterlist(temp_act->desc,100)
   DETAIL
    IF ((requestin->list_0[d.seq].activity_group_mean > " ")
     AND (requestin->list_0[d.seq].activity_group_long_desc > " "))
     grp_cnt = (grp_cnt+ 1), grp_tot_cnt = (grp_tot_cnt+ 1)
     IF (grp_cnt > 100)
      stat = alterlist(temp_bp->desc,(grp_tot_cnt+ 100)), grp_cnt = 1
     ENDIF
     temp_bp->desc[grp_tot_cnt].cat_mean = requestin->list_0[d.seq].cat_mean, temp_bp->desc[
     grp_tot_cnt].mean = requestin->list_0[d.seq].activity_group_mean, temp_bp->desc[grp_tot_cnt].
     desc = requestin->list_0[d.seq].activity_group_long_desc
    ENDIF
    IF ((requestin->list_0[d.seq].activity_mean > " ")
     AND (requestin->list_0[d.seq].activity_long_desc > " "))
     act_cnt = (act_cnt+ 1), act_tot_cnt = (act_tot_cnt+ 1)
     IF (act_cnt > 100)
      stat = alterlist(temp_act->desc,(act_tot_cnt+ 100)), act_cnt = 1
     ENDIF
     temp_act->desc[act_tot_cnt].cat_mean = requestin->list_0[d.seq].cat_mean, temp_act->desc[
     act_tot_cnt].mean = requestin->list_0[d.seq].activity_mean, temp_act->desc[act_tot_cnt].desc =
     requestin->list_0[d.seq].activity_long_desc
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_bp->desc,grp_tot_cnt), stat = alterlist(temp_act->desc,act_tot_cnt)
   WITH nocounter
  ;end select
  IF (grp_tot_cnt > 0)
   FOR (x = 1 TO grp_tot_cnt)
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_bp->desc[x].id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_bp->desc[x].br_long_text = cnvtreal(j)
     WITH format, counter
    ;end select
   ENDFOR
   SET errcode = 0
   INSERT  FROM br_bp_act_long_desc b,
     (dummyt d  WITH seq = value(grp_tot_cnt))
    SET b.br_bp_act_long_desc_id = temp_bp->desc[d.seq].id, b.act_group_mean = temp_bp->desc[d.seq].
     mean, b.cat_mean = temp_bp->desc[d.seq].cat_mean,
     b.br_long_text_id = temp_bp->desc[d.seq].br_long_text, b.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = errmsg
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET errcode = 0
   INSERT  FROM br_long_text b,
     (dummyt d  WITH seq = value(grp_tot_cnt))
    SET b.long_text_id = temp_bp->desc[d.seq].br_long_text, b.parent_entity_name =
     "BR_BP_ACT_LONG_DESC", b.parent_entity_id = temp_bp->desc[d.seq].id,
     b.long_text = temp_bp->desc[d.seq].desc, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = errmsg
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (act_tot_cnt > 0)
   FOR (x = 1 TO act_tot_cnt)
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_act->desc[x].id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_act->desc[x].br_long_text = cnvtreal(j)
     WITH format, counter
    ;end select
   ENDFOR
   SET errcode = 0
   INSERT  FROM br_bp_act_long_desc b,
     (dummyt d  WITH seq = value(act_tot_cnt))
    SET b.br_bp_act_long_desc_id = temp_act->desc[d.seq].id, b.activity_mean = temp_act->desc[d.seq].
     mean, b.cat_mean = temp_act->desc[d.seq].cat_mean,
     b.br_long_text_id = temp_act->desc[d.seq].br_long_text, b.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = errmsg
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET errcode = 0
   INSERT  FROM br_long_text b,
     (dummyt d  WITH seq = value(act_tot_cnt))
    SET b.long_text_id = temp_act->desc[d.seq].br_long_text, b.parent_entity_name =
     "BR_BP_ACT_LONG_DESC", b.parent_entity_id = temp_act->desc[d.seq].id,
     b.long_text = temp_act->desc[d.seq].desc, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = errmsg
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_blueprint_desc_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
