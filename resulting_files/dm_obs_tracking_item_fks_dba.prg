CREATE PROGRAM dm_obs_tracking_item_fks:dba
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
 SET readme_data->message = "Failed to execute obsolete process"
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  CALL echo("Running Obsolete Process on index XFK5TRACKING_ITEM...")
  EXECUTE dm_drop_obsolete_objects "XFK5TRACKING_ITEM", "INDEX", 1
  CALL echo("Running Obsolete Process on index XFK6TRACKING_ITEM...")
  EXECUTE dm_drop_obsolete_objects "XFK6TRACKING_ITEM", "INDEX", 1
  CALL echo("Running Obsolete Process on index XFK7TRACKING_ITEM...")
  EXECUTE dm_drop_obsolete_objects "XFK7TRACKING_ITEM", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,
    "- Readme Failed. One or more of the indexes failed to obsolete")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message =
  "XFK5TRACKING_ITEM,XFK6TRACKING_ITEM,XFK7TRACKING_ITEM obsoleted successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
