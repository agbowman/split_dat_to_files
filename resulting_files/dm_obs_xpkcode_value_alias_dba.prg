CREATE PROGRAM dm_obs_xpkcode_value_alias:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_obs_XPKCODE_VALUE_ALIAS.prg..."
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  CALL echo("Running Obsolete Process on index XPKCODE_VALUE_ALIAS...")
  EXECUTE dm_drop_obsolete_objects "XPKCODE_VALUE_ALIAS", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Index XPKCODE_VALUE_ALIAS was dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
