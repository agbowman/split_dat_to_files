CREATE PROGRAM dm_rdm_refresh_r_indexes:dba
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
 SET readme_data->message = "FAIL: $R indexes were not refreshed"
 DECLARE drrri_schema_prefix = vc WITH protect, noconstant("")
 DECLARE drrri_file_prefix = vc WITH protect, noconstant("")
 DECLARE drrri_process_option = vc WITH protect, noconstant("")
 FREE RECORD drri_reply
 RECORD drri_reply(
   1 status = c1
   1 message = vc
 )
 IF (validate(dm2_install_schema->schema_prefix,"Validate schema Prefix") != "Validate schema Prefix"
 )
  SET drrri_schema_prefix = dm2_install_schema->schema_prefix
  SET drrri_file_prefix = dm2_install_schema->file_prefix
  SET drrri_process_option = dm2_install_schema->process_option
 ENDIF
 IF (validate(dm2_install_pkg->source_rdbms,"Validate source rdbms") != "Validate source rdbms")
  SET dm2_install_pkg->source_rdbms = ""
  SET dm2_install_pkg->admin_load_ind = 0
 ENDIF
 EXECUTE dm_refresh_r_indexes  WITH replace("REPLY","DRRI_REPLY")
 SET readme_data->status = drri_reply->status
 SET readme_data->message = drri_reply->message
 IF (validate(dm2_install_schema->schema_prefix,"Validate schema Prefix") != "Validate schema Prefix"
 )
  SET dm2_install_schema->schema_prefix = drrri_schema_prefix
  SET dm2_install_schema->file_prefix = drrri_file_prefix
  SET dm2_install_schema->process_option = drrri_process_option
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD drri_reply
END GO
