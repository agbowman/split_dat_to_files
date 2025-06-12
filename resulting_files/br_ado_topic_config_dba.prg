CREATE PROGRAM br_ado_topic_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ado_topic_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_ado_topic t,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (t
   WHERE t.topic_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_ado_topic t,
   (dummyt d  WITH seq = value(cnt))
  SET t.br_ado_topic_id = seq(bedrock_seq,nextval), t.topic_display = requestin->list_0[d.seq].
   topic_display, t.topic_mean = cnvtupper(requestin->list_0[d.seq].topic_mean),
   t.updt_cnt = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id,
   t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (t)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart reports >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_topic t,
   (dummyt d  WITH seq = value(cnt))
  SET t.topic_display = requestin->list_0[d.seq].topic_display, t.updt_cnt = (t.updt_cnt+ 1), t
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (t
   WHERE t.topic_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Topics >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ado_topic_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
