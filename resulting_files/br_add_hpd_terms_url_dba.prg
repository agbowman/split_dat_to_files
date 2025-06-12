CREATE PROGRAM br_add_hpd_terms_url:dba
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
 SET readme_data->message = "Readme failed: starting script br_add_hpd_terms_url..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="HPD_DIRECTORY_POLICY_URL"
    AND di.info_name="POLICY_URL")
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select row: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "HPD_DIRECTORY_POLICY_URL", di.info_name = "POLICY_URL", di.info_char =
    "http://www.cerner.com/health_care_directory_policy/",
    di.info_domain_id = 0.0, di.info_date = cnvtdatetime(curdate,curtime3), di.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
    updt_task,
    di.updt_cnt = 0
  ;end insert
 ENDIF
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert row into dm_info: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
