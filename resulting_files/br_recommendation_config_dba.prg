CREATE PROGRAM br_recommendation_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_recommendation_config.prg> script"
 FREE SET temp_prg
 RECORD temp_prg(
   1 programs[*]
     2 action_flag = i2
     2 id = f8
     2 mean = vc
     2 name = vc
     2 short_desc = vc
     2 long_desc = vc
     2 dtl_prg_name = vc
     2 grp_mean = vc
     2 subgrp_mean = vc
     2 sequence = i2
     2 active_ind = i2
     2 design_decision_id = f8
     2 design_decision = vc
     2 recommendation_id = f8
     2 recommendation = vc
     2 rationale_id = f8
     2 rationale = vc
     2 resolution_id = f8
     2 resolution = vc
     2 code_level_id = f8
     2 code_level = vc
     2 client_view_ind = i2
     2 special_considerations_id = f8
     2 special_considerations = vc
     2 date_released = vc
     2 release_number = vc
     2 high_impact_designation = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET cnt = 0
 SET req_cnt = size(requestin->list_0,5)
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
  HEAD REPORT
   cnt = 0, stat = alterlist(temp_prg->programs,req_cnt)
  DETAIL
   IF ((requestin->list_0[d.seq].bedrock_prog_meaning > " "))
    cnt = (cnt+ 1), temp_prg->programs[cnt].mean = requestin->list_0[d.seq].bedrock_prog_meaning,
    temp_prg->programs[cnt].action_flag = 1,
    temp_prg->programs[cnt].dtl_prg_name = requestin->list_0[d.seq].detail_prog_name, temp_prg->
    programs[cnt].grp_mean = requestin->list_0[d.seq].category, temp_prg->programs[cnt].long_desc =
    requestin->list_0[d.seq].long_description,
    temp_prg->programs[cnt].name = requestin->list_0[d.seq].bedrock_prog_name, temp_prg->programs[cnt
    ].sequence = cnvtint(trim(requestin->list_0[d.seq].sequence)), temp_prg->programs[cnt].short_desc
     = requestin->list_0[d.seq].short_description,
    temp_prg->programs[cnt].subgrp_mean = requestin->list_0[d.seq].subcategory, temp_prg->programs[
    cnt].active_ind = cnvtint(trim(requestin->list_0[d.seq].active_ind)), temp_prg->programs[cnt].
    design_decision = requestin->list_0[d.seq].design_decision,
    temp_prg->programs[cnt].recommendation = requestin->list_0[d.seq].recommendation, temp_prg->
    programs[cnt].rationale = requestin->list_0[d.seq].rationale, temp_prg->programs[cnt].resolution
     = requestin->list_0[d.seq].resolution,
    temp_prg->programs[cnt].code_level = requestin->list_0[d.seq].code_level, temp_prg->programs[cnt]
    .special_considerations = requestin->list_0[d.seq].special_considerations, temp_prg->programs[cnt
    ].date_released = requestin->list_0[d.seq].date_released,
    temp_prg->programs[cnt].release_number = requestin->list_0[d.seq].release_number, temp_prg->
    programs[cnt].high_impact_designation = requestin->list_0[d.seq].high_impact_designation
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_prg->programs,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_rec b
   PLAN (d)
    JOIN (b
    WHERE b.program_name=cnvtupper(temp_prg->programs[d.seq].name))
   DETAIL
    IF (b.rec_mean=cnvtupper(temp_prg->programs[d.seq].mean))
     temp_prg->programs[d.seq].action_flag = 2, temp_prg->programs[d.seq].id = b.rec_id
    ENDIF
    IF (b.client_view_ind=1)
     temp_prg->programs[d.seq].client_view_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  FOR (x = 1 TO cnt)
    IF ((temp_prg->programs[x].action_flag=1))
     SELECT INTO "NL:"
      j = seq(bedrock_seq,nextval)"##################;rp0"
      FROM dual du
      PLAN (du)
      DETAIL
       temp_prg->programs[x].id = cnvtreal(j)
      WITH format, counter
     ;end select
    ENDIF
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_prg->programs[x].design_decision_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_prg->programs[x].recommendation_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_prg->programs[x].resolution_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_prg->programs[x].rationale_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_prg->programs[x].code_level_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF ((temp_prg->programs[x].special_considerations > " "))
     SELECT INTO "NL:"
      j = seq(bedrock_seq,nextval)"##################;rp0"
      FROM dual du
      PLAN (du)
      DETAIL
       temp_prg->programs[x].special_considerations_id = cnvtreal(j)
      WITH format, counter
     ;end select
    ENDIF
  ENDFOR
  INSERT  FROM br_rec b,
    (dummyt d  WITH seq = value(cnt))
   SET b.rec_id = temp_prg->programs[d.seq].id, b.rec_mean = trim(substring(1,50,temp_prg->programs[d
      .seq].mean)), b.category_mean = trim(substring(1,50,temp_prg->programs[d.seq].grp_mean)),
    b.subcategory_mean = trim(substring(1,50,temp_prg->programs[d.seq].subgrp_mean)), b.program_name
     = trim(cnvtupper(substring(1,50,temp_prg->programs[d.seq].name))), b.detail_program_name = trim(
     cnvtupper(substring(1,50,temp_prg->programs[d.seq].dtl_prg_name))),
    b.short_desc = trim(substring(1,100,temp_prg->programs[d.seq].short_desc)), b.long_desc = trim(
     substring(1,256,temp_prg->programs[d.seq].long_desc)), b.sequence = temp_prg->programs[d.seq].
    sequence,
    b.active_ind = temp_prg->programs[d.seq].active_ind, b.design_decision_txt_id = temp_prg->
    programs[d.seq].design_decision_id, b.recommendation_txt_id = temp_prg->programs[d.seq].
    recommendation_id,
    b.rationale_txt_id = temp_prg->programs[d.seq].rationale_id, b.resolution_txt_id = temp_prg->
    programs[d.seq].resolution_id, b.client_view_ind = temp_prg->programs[d.seq].client_view_ind,
    b.code_lvl_txt_id = temp_prg->programs[d.seq].code_level_id, b.spec_cons_txt_id = temp_prg->
    programs[d.seq].special_considerations_id, b.release_date_txt = temp_prg->programs[d.seq].
    date_released,
    b.release_nbr_txt = temp_prg->programs[d.seq].release_number, b.high_impact_ind =
    IF (trim(cnvtupper(temp_prg->programs[d.seq].high_impact_designation))="YES") 1
    ELSE 0
    ENDIF
    , b.updt_cnt = 0,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
    reqinfo->updt_applctx,
    b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting recommendations >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].design_decision_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].design_decision), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting design decisions >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].recommendation_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].recommendation), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting recommendation text >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].rationale_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].rationale), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting rationales >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].resolution_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].resolution), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting resolutions >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].code_level_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].code_level), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting code level >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(cnt))
   SET b.long_text_id = temp_prg->programs[d.seq].special_considerations_id, b.parent_entity_name =
    "BR_RECOMMENDATION", b.parent_entity_id = temp_prg->programs[d.seq].id,
    b.long_text = trim(temp_prg->programs[d.seq].special_considerations), b.updt_cnt = 0, b
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].special_considerations_id > 0))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting special considerations >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  UPDATE  FROM br_rec b,
    (dummyt d  WITH seq = value(cnt))
   SET b.category_mean = trim(substring(1,50,temp_prg->programs[d.seq].grp_mean)), b.subcategory_mean
     = trim(substring(1,50,temp_prg->programs[d.seq].subgrp_mean)), b.program_name = trim(cnvtupper(
      substring(1,50,temp_prg->programs[d.seq].name))),
    b.detail_program_name = trim(cnvtupper(substring(1,50,temp_prg->programs[d.seq].dtl_prg_name))),
    b.short_desc = trim(substring(1,100,temp_prg->programs[d.seq].short_desc)), b.long_desc = trim(
     substring(1,256,temp_prg->programs[d.seq].long_desc)),
    b.sequence = temp_prg->programs[d.seq].sequence, b.active_ind = temp_prg->programs[d.seq].
    active_ind, b.design_decision_txt_id = temp_prg->programs[d.seq].design_decision_id,
    b.recommendation_txt_id = temp_prg->programs[d.seq].recommendation_id, b.rationale_txt_id =
    temp_prg->programs[d.seq].rationale_id, b.resolution_txt_id = temp_prg->programs[d.seq].
    resolution_id,
    b.client_view_ind = temp_prg->programs[d.seq].client_view_ind, b.code_lvl_txt_id = temp_prg->
    programs[d.seq].code_level_id, b.spec_cons_txt_id = temp_prg->programs[d.seq].
    special_considerations_id,
    b.release_date_txt = temp_prg->programs[d.seq].date_released, b.release_nbr_txt = temp_prg->
    programs[d.seq].release_number, b.high_impact_ind =
    IF (trim(cnvtupper(temp_prg->programs[d.seq].high_impact_designation))="YES") 1
    ELSE 0
    ENDIF
    ,
    b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo
    ->updt_id,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (temp_prg->programs[d.seq].action_flag=2))
    JOIN (b
    WHERE (b.rec_id=temp_prg->programs[d.seq].id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure updating recommendations >> ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_recommendation_config.prg> script"
#exit_script
 FREE SET temp_prg
END GO
