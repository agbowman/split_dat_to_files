CREATE PROGRAM br_ado_prop_detail_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ado_prop_detail_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 top_scenario_id = f8
     2 category_id = f8
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_ado_topic_scenario ts,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (ts
   WHERE ts.scenario_mean=cnvtupper(requestin->list_0[d.seq].scenario_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].top_scenario_id = ts.br_ado_topic_scenario_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_ado_category c,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (c
   WHERE c.category_mean=cnvtupper(requestin->list_0[d.seq].category_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].category_id = c.br_ado_category_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_ado_proposed_detail apd,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (apd
   WHERE (apd.br_ado_topic_scenario_id=br_existsinfo->list_0[d.seq].top_scenario_id)
    AND (apd.br_ado_category_id=br_existsinfo->list_0[d.seq].category_id))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_ado_proposed_detail apd,
   (dummyt d  WITH seq = value(cnt))
  SET apd.br_ado_proposed_detail_id = seq(bedrock_seq,nextval), apd.br_ado_topic_scenario_id =
   br_existsinfo->list_0[d.seq].top_scenario_id, apd.br_ado_category_id = br_existsinfo->list_0[d.seq
   ].category_id,
   apd.select_ind = cnvtint(requestin->list_0[d.seq].select_ind), apd.note_txt = requestin->list_0[d
   .seq].notes, apd.updt_cnt = 0,
   apd.updt_dt_tm = cnvtdatetime(curdate,curtime3), apd.updt_id = reqinfo->updt_id, apd.updt_task =
   reqinfo->updt_task,
   apd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (apd)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_proposed_detail apd,
   (dummyt d  WITH seq = value(cnt))
  SET apd.select_ind = cnvtint(requestin->list_0[d.seq].select_ind), apd.note_txt = requestin->
   list_0[d.seq].notes, apd.updt_cnt = (apd.updt_cnt+ 1),
   apd.updt_dt_tm = cnvtdatetime(curdate,curtime3), apd.updt_id = reqinfo->updt_id, apd.updt_task =
   reqinfo->updt_task,
   apd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (apd
   WHERE (apd.br_ado_topic_scenario_id=br_existsinfo->list_0[d.seq].top_scenario_id)
    AND (apd.br_ado_category_id=br_existsinfo->list_0[d.seq].category_id))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating Advisor Order Details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ado_prop_detail_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
