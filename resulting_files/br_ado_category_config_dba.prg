CREATE PROGRAM br_ado_category_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ado_category_config.prg> script"
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
  FROM br_ado_category c,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (c
   WHERE ((c.category_mean=cnvtupper(requestin->list_0[d.seq].category_mean)) OR (c.category_name_key
   =cnvtupper(requestin->list_0[d.seq].category_name)
    AND c.category_mean=" ")) )
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_ado_category c,
   (dummyt d  WITH seq = value(cnt))
  SET c.br_ado_category_id = seq(bedrock_seq,nextval), c.category_name = requestin->list_0[d.seq].
   category_name, c.category_mean = cnvtupper(requestin->list_0[d.seq].category_mean),
   c.category_name_key = cnvtupper(requestin->list_0[d.seq].category_name), c.updt_cnt = 0, c
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (c)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_category c,
   (dummyt d  WITH seq = value(cnt))
  SET c.category_name = requestin->list_0[d.seq].category_name, c.category_name_key = cnvtupper(
    requestin->list_0[d.seq].category_name), c.updt_cnt = (c.updt_cnt+ 1),
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
   ->updt_task,
   c.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (c
   WHERE c.category_mean=cnvtupper(requestin->list_0[d.seq].category_mean))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating Advisor Order Categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_category c,
   (dummyt d  WITH seq = value(cnt))
  SET c.category_mean = cnvtupper(requestin->list_0[d.seq].category_mean), c.updt_cnt = (c.updt_cnt+
   1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (c
   WHERE c.category_name_key=cnvtupper(requestin->list_0[d.seq].category_name)
    AND c.category_mean=" ")
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating Advisor Order Categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ado_category_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
