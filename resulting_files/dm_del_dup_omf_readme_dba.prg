CREATE PROGRAM dm_del_dup_omf_readme:dba
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
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="OMF Readme"
   AND d.info_name="0"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No rows with info_domain = OMF Readme and info_name = 0 was found"
  GO TO exit_script
 ELSE
  DELETE  FROM dm_info d
   WHERE d.info_domain="OMF Readme"
    AND d.info_name="0"
  ;end delete
  IF (curqual=0)
   SET readme_data->status = "F"
   SET readme_data->message = "Error removing row with info_domain = OMF Readme and info_name = 0"
   GO TO exit_script
  ELSE
   COMMIT
   SET readme_data->status = "S"
   SET readme_data->message =
   "Successfully removed row with info_domain = OMF Readme and info_name = 0"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
