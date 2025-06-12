CREATE PROGRAM dm_rdm_ehi_model_load_wrp:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_ehi_model_load_wrp..."
 EXECUTE dm_dbimport "cer_install:dm_rdm_ehi_model_sets.csv", "dm_rdm_ehi_prop_set_load", 1000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:dm_rdm_ehi_model_config.csv", "dm_rdm_ehi_model_load", 1000
 IF ((readme_data->status != "F"))
  SET readme_data->status = "S"
  SET readme_data->message = "Success: EHI model properties and sets loaded successfully"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
