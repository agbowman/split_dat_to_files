CREATE PROGRAM bmdi_starterdata_import:dba
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
 DECLARE count = i4
 DECLARE serror = vc WITH public, noconstant("")
 SET count = 0
 EXECUTE dm_dbimport "cer_install:strt_supplier.csv", "mdi_strt_supplier_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_supplier.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:strt_mfg.csv", "mdi_strt_mfg_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_mfg.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:strt_supplier_mfg.csv", "mdi_strt_supplier_mfg_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_supplier_mfg.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:strt_model.csv", "mdi_strt_model_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_model.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:strt_mfg_model.csv", "mdi_strt_mfg_model_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_mfg_model.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:strt_model_custom.csv", "mdi_strt_model_cust_import", 100
 IF ((readme_data->status="F"))
  SET serror = "strt_model_custom.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:bmdi_strt_model_lab_type_r.csv", "bmdi_lab_type_r_import", 100
 IF ((readme_data->status="F"))
  SET serror = "bmdi_strt_model_lab_type_r.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:bmdi_strt_model_format.csv", "bmdi_strt_model_format_import", 100
 IF ((readme_data->status="F"))
  SET serror = "bmdi_strt_model_format.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:bmdi_strt_model_hl7_map.csv", "bmdi_strt_model_hl7_map_import", 100
 IF ((readme_data->status="F"))
  SET serror = "bmdi_strt_model_hl7_map.csv failed to import"
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:bmdi_strt_bmdi_model_parameter.csv", "bmdi_model_parameter_import",
 100
 IF ((readme_data->status="F"))
  SET serror = "bmdi_strt_bmdi_model_parameter.csv failed to import"
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->message = serror
 CALL echo(serror)
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
