CREATE PROGRAM br_search_settings_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_search_settings_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 INSERT  FROM br_person_search_settings b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_person_search_settings_id = seq(bedrock_seq,nextval), b.setting_mean = requestin->list_0[d
   .seq].setting_mean, b.display = requestin->list_0[d.seq].display,
   b.description = requestin->list_0[d.seq].description, b.data_type_flag = cnvtint(requestin->
    list_0[d.seq].data_type_flag), b.meaning = requestin->list_0[d.seq].meaning,
   b.codeset = cnvtint(requestin->list_0[d.seq].codeset), b.updt_id = reqinfo->updt_id, b.updt_cnt =
   0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx =
   reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting search settings >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_search_settings_config.prg> script"
#exit_script
END GO
