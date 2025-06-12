CREATE PROGRAM dm_obs_xie2messaging_favorites:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_obs_xie2messaging_favorites..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 IF (currdb="ORACLE")
  EXECUTE dm_drop_obsolete_objects "XIE2MESSAGING_FAVORITES", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = concat("Readme Failed: XIE2MESSAGING_FAVORITES: ",errmsg)
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Index XIE2MESSAGING_FAVORITES dropped successfully."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
