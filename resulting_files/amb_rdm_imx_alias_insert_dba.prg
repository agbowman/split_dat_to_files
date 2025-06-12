CREATE PROGRAM amb_rdm_imx_alias_insert:dba
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
 SET readme_data->message = "Readme failed: starting script amb_rdm_imx_alias_insert..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cdffound = i2
 DECLARE cvfound = i2
 DECLARE next_code = f8
 SET cdffound = 0
 SET cvfound = 0
 SET next_code = 0.0
 SELECT INTO "nl:"
  FROM common_data_foundation cdf
  WHERE cdf.code_set=320.0
   AND cdf.cdf_meaning="IMXACCESSIND"
  DETAIL
   cdffound = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select data from table common_data_foundation : ",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (cdffound=0)
  INSERT  FROM common_data_foundation cdf
   SET cdf.code_set = 320, cdf.cdf_meaning = "IMXACCESSIND", cdf.display = "IMXACCESSIND",
    cdf.definition = "IMXACCESSIND", cdf.updt_applctx = reqinfo->updt_applctx, cdf.updt_cnt = 0,
    cdf.updt_dt_tm = cnvtdatetime(sysdate), cdf.updt_id = reqinfo->updt_id, cdf.updt_task = reqinfo->
    updt_task
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert row into common_data_foundation: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
   SET cdffound = 1
  ENDIF
 ENDIF
 IF (cdffound=1)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=320.0
    AND cv.cdf_meaning="IMXACCESSIND"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    cvfound = 1
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to select data from table code_value : ",errmsg)
   GO TO exit_script
  ENDIF
  IF (cvfound=0)
   CALL echo("Executing cpm_next_code")
   EXECUTE cpm_next_code
   CALL echo("next_code")
   IF (next_code > 0)
    INSERT  FROM code_value cv
     SET cv.code_value = next_code, cv.active_ind = 1, cv.active_type_cd = 188.00,
      cv.active_dt_tm = cnvtdatetime(sysdate), cv.active_status_prsnl_id = reqinfo->updt_id, cv
      .code_set = 320,
      cv.cdf_meaning = "IMXACCESSIND", cv.display = "InterMedx Access Ind", cv.display_key =
      "INTERMEDXACCESSIND",
      cv.definition = "InterMedx Access Ind", cv.description = "InterMedx Access Ind", cv
      .collation_seq = 0,
      cv.begin_effective_dt_tm = cnvtdatetime(sysdate), cv.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), cv.data_status_cd = 25.0,
      cv.data_status_dt_tm = cnvtdatetime(sysdate), cv.data_status_prsnl_id = reqinfo->updt_id, cv
      .updt_applctx = reqinfo->updt_applctx,
      cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(sysdate), cv.updt_id = reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to insert row into code_value: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ELSE
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to get next_code: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
