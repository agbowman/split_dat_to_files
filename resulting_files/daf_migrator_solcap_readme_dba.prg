CREATE PROGRAM daf_migrator_solcap_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting script solcap_readme_example.prg..."
 DECLARE exists_ind = i2 WITH public, noconstant(0)
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_SOLCAP_SCRIPT"
   AND di.info_name="DAF_MIGRATOR_SOLCAP_COLLECTOR"
  DETAIL
   exists_ind = 1
  WITH nocounter
 ;end select
 IF (exists_ind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DM_STAT_SOLCAP_SCRIPT", di.info_name = "DAF_MIGRATOR_SOLCAP_COLLECTOR", di
    .info_number = 1,
    di.info_char = "EOD 1 NODE", di.info_date = cnvtdatetime(curdate,curtime3), di.updt_applctx =
    reqinfo->updt_applctx,
    di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id,
    di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Unable to Write DM_INFO Row:",errmsg)
   ROLLBACK
   GO TO exit_script
  ENDIF
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "SOLCAP Collector Row Written Successfully."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SOLCAP Collector Row Already Present."
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
