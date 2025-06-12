CREATE PROGRAM br_ado_topic_scenario_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ado_topic_scenario_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE sectionexist = i2 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 section = vc
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 IF (cnt > 0)
  IF (validate(requestin->list_0[0].section))
   FOR (ind = 1 TO cnt)
     SET br_existsinfo->list_0[ind].section = requestin->list_0[ind].section
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM br_ado_topic_scenario ts,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (ts
   WHERE ts.scenario_mean=cnvtupper(requestin->list_0[d.seq].scenario_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_ado_topic_scenario ts,
   (dummyt d  WITH seq = value(cnt))
  SET ts.br_ado_topic_scenario_id = seq(bedrock_seq,nextval), ts.br_ado_topic_id =
   (SELECT
    t.br_ado_topic_id
    FROM br_ado_topic t
    WHERE t.topic_mean=cnvtupper(requestin->list_0[d.seq].topic_mean)), ts.scenario_display =
   requestin->list_0[d.seq].scenario_display,
   ts.scenario_mean = cnvtupper(requestin->list_0[d.seq].scenario_mean), ts.scenario_seq = cnvtint(
    requestin->list_0[d.seq].sequence), ts.scenario_section_name = br_existsinfo->list_0[d.seq].
   section,
   ts.updt_cnt = 0, ts.updt_dt_tm = cnvtdatetime(curdate,curtime3), ts.updt_id = reqinfo->updt_id,
   ts.updt_task = reqinfo->updt_task, ts.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (ts)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Scenarios >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_topic_scenario ts,
   (dummyt d  WITH seq = value(cnt))
  SET ts.scenario_display = requestin->list_0[d.seq].scenario_display, ts.scenario_seq = cnvtint(
    requestin->list_0[d.seq].sequence), ts.scenario_section_name = br_existsinfo->list_0[d.seq].
   section,
   ts.updt_cnt = (ts.updt_cnt+ 1), ts.updt_dt_tm = cnvtdatetime(curdate,curtime3), ts.updt_id =
   reqinfo->updt_id,
   ts.updt_task = reqinfo->updt_task, ts.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (ts
   WHERE ts.scenario_mean=cnvtupper(requestin->list_0[d.seq].scenario_mean))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Scenarios >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ado_topic_scenario_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
