CREATE PROGRAM dm_obs_scheduled_indexes:dba
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
  CALL echo("Running Obsolete Process on scheduled table indexes...")
  EXECUTE dm_drop_obsolete_objects "XIE1SCH_NOTIFY", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE2SCH_NOTIFY", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE2SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE3SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE4SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE5SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE6SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE7SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XAK2SCH_TEXT_LINK", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE2SCH_ACTION_LOC", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE1SCH_APPT", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE2SCH_BOOKING", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XAK2SCH_LIST_ROLE", "INDEX", 1
  EXECUTE dm_drop_obsolete_objects "XIE4SCH_DATE_COMMENT", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Schedule table indexes were dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
