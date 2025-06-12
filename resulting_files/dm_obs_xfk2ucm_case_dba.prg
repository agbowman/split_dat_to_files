CREATE PROGRAM dm_obs_xfk2ucm_case:dba
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
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET readme_data->status = "F"
 SET readme_data->message = "dm_obs_xfk2ucm_case failed"
 IF (currdb="ORACLE")
  CALL echo("Running Obsolete Process on constraint XFK2UCM_CASE...")
  EXECUTE dm_drop_obsolete_objects "XFK2UCM_CASE", "CONSTRAINT", 1
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Constraint XFK2UCM_CASE was dropped successfully"
   CALL echo("Completed Obsolete Process on constraint XFK2UCM_CASE...")
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
