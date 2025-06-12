CREATE PROGRAM br_activity_group_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_activity_group_config.prg> script"
 FREE SET temp_bp
 RECORD temp_bp(
   1 act_grp[*]
     2 action_flag = i2
     2 act_action_flag = i2
     2 ag_id = f8
     2 meaning = vc
     2 disp = vc
     2 desc = vc
     2 type_flag = i2
     2 long_text_id = f8
     2 bp_ind = i2
     2 cat_mean = vc
     2 cat_disp = vc
     2 version = i4
     2 activities[*]
       3 action_flag = i2
       3 act_id = f8
       3 meaning = vc
       3 long_text_id = f8
       3 disp = vc
       3 desc = vc
       3 version = i4
       3 disp_seq = i4
     2 child_act_grp[*]
       3 chld_mean = vc
       3 disp_seq = i4
       3 cag_id = f8
 )
 FREE SET temp_act
 RECORD temp_act(
   1 activitites[*]
     2 action_flag = i2
     2 act_id = f8
     2 meaning = vc
     2 long_text_id = f8
     2 disp = vc
     2 desc = vc
     2 version = i4
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
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    grp_cnt = 0, grp_tot_cnt = 0, stat = alterlist(temp_bp->act_grp,100),
    act_cnt = 0, act_tot_cnt = 0, chld_cnt = 0,
    chld_tot_cnt = 0
   DETAIL
    IF ((requestin->list_0[d.seq].activity_group_mean > " "))
     IF (grp_tot_cnt > 0)
      stat = alterlist(temp_bp->act_grp[grp_tot_cnt].activities,act_tot_cnt), stat = alterlist(
       temp_bp->act_grp[grp_tot_cnt].child_act_grp,chld_tot_cnt)
     ENDIF
     grp_cnt = (grp_cnt+ 1), grp_tot_cnt = (grp_tot_cnt+ 1), act_cnt = 0,
     act_tot_cnt = 0, chld_cnt = 0, chld_tot_cnt = 0
     IF (grp_cnt > 100)
      stat = alterlist(temp_bp->act_grp,(grp_tot_cnt+ 100)), grp_cnt = 1
     ENDIF
     temp_bp->act_grp[grp_tot_cnt].meaning = requestin->list_0[d.seq].activity_group_mean, temp_bp->
     act_grp[grp_tot_cnt].disp = requestin->list_0[d.seq].activity_group_display, temp_bp->act_grp[
     grp_tot_cnt].desc = requestin->list_0[d.seq].activity_group_display2,
     temp_bp->act_grp[grp_tot_cnt].type_flag = cnvtint(trim(requestin->list_0[d.seq].
       activity_group_type_flag)), temp_bp->act_grp[grp_tot_cnt].bp_ind = cnvtint(trim(requestin->
       list_0[d.seq].blueprint_ind)), temp_bp->act_grp[grp_tot_cnt].cat_mean = requestin->list_0[d
     .seq].cat_mean,
     temp_bp->act_grp[grp_tot_cnt].cat_disp = requestin->list_0[d.seq].cat_display, stat = alterlist(
      temp_bp->act_grp[grp_tot_cnt].child_act_grp,100), stat = alterlist(temp_bp->act_grp[grp_tot_cnt
      ].activities,100)
    ENDIF
    IF ((requestin->list_0[d.seq].child_activity_group_mean > " "))
     chld_cnt = (chld_cnt+ 1), chld_tot_cnt = (chld_tot_cnt+ 1)
     IF (chld_cnt > 100)
      stat = alterlist(temp_bp->act_grp[grp_tot_cnt].activities,(chld_tot_cnt+ 100)), chld_cnt = 1
     ENDIF
     temp_bp->act_grp[grp_tot_cnt].child_act_grp[chld_tot_cnt].chld_mean = requestin->list_0[d.seq].
     child_activity_group_mean, temp_bp->act_grp[grp_tot_cnt].child_act_grp[chld_tot_cnt].disp_seq =
     cnvtint(trim(requestin->list_0[d.seq].display_sequence))
    ELSEIF ((requestin->list_0[d.seq].activity_mean > " "))
     act_cnt = (act_cnt+ 1), act_tot_cnt = (act_tot_cnt+ 1)
     IF (act_cnt > 100)
      stat = alterlist(temp_bp->act_grp[grp_tot_cnt].activities,(act_tot_cnt+ 100)), act_cnt = 1
     ENDIF
     temp_bp->act_grp[grp_tot_cnt].activities[act_tot_cnt].meaning = requestin->list_0[d.seq].
     activity_mean, temp_bp->act_grp[grp_tot_cnt].activities[act_tot_cnt].disp = requestin->list_0[d
     .seq].activity_display, temp_bp->act_grp[grp_tot_cnt].activities[act_tot_cnt].desc = requestin->
     list_0[d.seq].activity_display2,
     temp_bp->act_grp[grp_tot_cnt].activities[act_tot_cnt].disp_seq = cnvtint(trim(requestin->list_0[
       d.seq].display_sequence))
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_bp->act_grp,grp_tot_cnt), stat = alterlist(temp_bp->act_grp[grp_tot_cnt].
     activities,act_tot_cnt), stat = alterlist(temp_bp->act_grp[grp_tot_cnt].child_act_grp,
     chld_tot_cnt)
   WITH nocounter
  ;end select
  IF (grp_tot_cnt=0)
   SET readme_data->status = "F"
   SET readme_data->message = "Readme Failed: Error while loading temp structure."
   GO TO exit_script
  ENDIF
  FOR (a = 1 TO grp_tot_cnt)
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_bp->act_grp[a].ag_id = cnvtreal(j)
     WITH format, counter
    ;end select
  ENDFOR
  INSERT  FROM br_bp_act_group b,
    (dummyt d  WITH seq = value(grp_tot_cnt))
   SET b.br_bp_act_group_id = temp_bp->act_grp[d.seq].ag_id, b.act_group_mean = temp_bp->act_grp[d
    .seq].meaning, b.blueprint_ind = temp_bp->act_grp[d.seq].bp_ind,
    b.cat_disp = temp_bp->act_grp[d.seq].cat_disp, b.cat_mean = temp_bp->act_grp[d.seq].cat_mean, b
    .create_dt_tm = cnvtdatetime(curdate,curtime3),
    b.create_prsnl_id = reqinfo->updt_id, b.description = temp_bp->act_grp[d.seq].desc, b.display =
    temp_bp->act_grp[d.seq].disp,
    b.type_flag = temp_bp->act_grp[d.seq].type_flag, b.version_nbr = 0, b.updt_applctx = reqinfo->
    updt_applctx,
    b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
    b.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting activity groups >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  FOR (x = 1 TO grp_tot_cnt)
    SET act_size = size(temp_bp->act_grp[x].activities,5)
    SET chld_size = size(temp_bp->act_grp[x].child_act_grp,5)
    IF (act_size > 0)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(act_size)),
       br_bp_activity b
      PLAN (d1)
       JOIN (b
       WHERE (b.activity_mean=temp_bp->act_grp[x].activities[d1.seq].meaning))
      ORDER BY d1.seq
      HEAD d1.seq
       temp_bp->act_grp[x].activities[d1.seq].act_id = b.br_bp_activity_id
      WITH nocounter
     ;end select
     FOR (y = 1 TO act_size)
       IF ((temp_bp->act_grp[x].activities[y].act_id=0))
        SET temp_bp->act_grp[x].activities[y].action_flag = 1
        SELECT INTO "NL:"
         j = seq(bedrock_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          temp_bp->act_grp[x].activities[y].act_id = cnvtreal(j)
         WITH format, counter
        ;end select
       ENDIF
     ENDFOR
     SET errcode = 0
     INSERT  FROM br_bp_activity b,
       (dummyt d  WITH seq = value(act_size))
      SET b.br_bp_activity_id = temp_bp->act_grp[x].activities[d.seq].act_id, b.activity_mean =
       temp_bp->act_grp[x].activities[d.seq].meaning, b.description = temp_bp->act_grp[x].activities[
       d.seq].desc,
       b.display = temp_bp->act_grp[x].activities[d.seq].disp, b.version_nbr = 0, b.updt_applctx =
       reqinfo->updt_applctx,
       b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task
      PLAN (d
       WHERE (temp_bp->act_grp[x].activities[d.seq].action_flag=1))
       JOIN (b)
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure inserting new activities for ",trim(temp_bp->
        act_grp[x].meaning),">> ",serrmsg)
      GO TO exit_script
     ENDIF
     SET errcode = 0
     INSERT  FROM br_bp_act_group_r b,
       (dummyt d  WITH seq = value(act_size))
      SET b.br_bp_act_group_r_id = seq(bedrock_seq,nextval), b.br_bp_act_group_id = temp_bp->act_grp[
       x].ag_id, b.activity_status = 0,
       b.child_entity_id = temp_bp->act_grp[x].activities[d.seq].act_id, b.child_entity_name =
       "BR_BP_ACTIVITY", b.display_seq = temp_bp->act_grp[x].activities[d.seq].disp_seq,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (b)
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure inserting activity/activity group relation for ",
       trim(temp_bp->act_grp[x].meaning),">> ",serrmsg)
      GO TO exit_script
     ENDIF
    ENDIF
    IF (chld_size > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(chld_size)),
       br_bp_act_group b
      PLAN (d)
       JOIN (b
       WHERE (b.act_group_mean=temp_bp->act_grp[x].child_act_grp[d.seq].chld_mean))
      ORDER BY d.seq
      HEAD d.seq
       temp_bp->act_grp[x].child_act_grp[d.seq].cag_id = b.br_bp_act_group_id
      WITH nocounter
     ;end select
     SET errcode = 0
     INSERT  FROM br_bp_act_group_r b,
       (dummyt d  WITH seq = value(chld_size))
      SET b.br_bp_act_group_r_id = seq(bedrock_seq,nextval), b.br_bp_act_group_id = temp_bp->act_grp[
       x].ag_id, b.activity_status = 0,
       b.child_entity_id = temp_bp->act_grp[x].child_act_grp[d.seq].cag_id, b.child_entity_name =
       "BR_BP_ACT_GROUP", b.display_seq = temp_bp->act_grp[x].child_act_grp[d.seq].disp_seq,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
      PLAN (d
       WHERE (temp_bp->act_grp[x].child_act_grp[d.seq].cag_id > 0))
       JOIN (b)
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat(
       "Failure inserting activity group/child activity group relation for ",trim(temp_bp->act_grp[x]
        .meaning),">> ",serrmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_activity_group_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
