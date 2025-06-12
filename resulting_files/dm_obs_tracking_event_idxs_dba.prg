CREATE PROGRAM dm_obs_tracking_event_idxs:dba
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
  CALL echo("Running Obsolete Process on indexes for table TRACKING_EVENT...")
  EXECUTE dm_drop_obsolete_objects "XIE1TRACKING_EVENT", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE2TRACKING_EVENT", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE4TRACKING_EVENT", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE5TRACKING_EVENT", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Indexes for table TRACKING_EVENT were dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
