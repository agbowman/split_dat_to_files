CREATE PROGRAM dm_rdm_check_log_row_reset:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_check_log_row_reset..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE insertind = i4 WITH public, noconstant(0)
 DECLARE idomain = vc WITH public, noconstant("ICD9 Interrogator")
 DECLARE iname = vc WITH public, noconstant("Large Long Text Row Reset")
 SELECT INTO "nl:"
  FROM dm_ocd_log dol
  WHERE dol.project_name="8106"
   AND dol.project_type="README"
   AND dol.status="SUCCESS"
   AND (dol.environment_id=
  (SELECT
   di.info_number
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_ID"))
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM dm_info di
   WHERE di.info_domain=idomain
    AND di.info_name=iname)))
  DETAIL
   insertind = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select readme history: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (insertind=1)
  INSERT  FROM dm_info di
   SET di.info_domain = idomain, di.info_name = iname, di.info_date = cnvtdatetime(curdate,curtime3),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("The DM_INFO Insert Failed: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
