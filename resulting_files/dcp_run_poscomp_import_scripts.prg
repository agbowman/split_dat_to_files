CREATE PROGRAM dcp_run_poscomp_import_scripts
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
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dcp_run_poscomp_import_scripts script"
 EXECUTE dm_dbimport "CER_INSTALL:dcp_config_comp.csv", "dcp_conf_comp_data_import", 5000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "CER_INSTALL:dcp_config_settings.csv", "dcp_conf_setting_data_import", 5000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "CER_INSTALL:dcp_comp_relation.csv", "dcp_confcomp_rel_data_import", 5000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 DELETE  FROM dcp_config_comp_reltn d
  WHERE d.dcp_config_setting_id IN (
  (SELECT
   dcp_config_setting_id
   FROM dcp_config_setting
   WHERE config_name="APP_NAME1"))
   AND d.dcp_config_comp_id IN (
  (SELECT
   dcp_config_comp_id
   FROM dcp_config_comp
   WHERE comp_name IN ("FLOWSHEET", "PTLISTLITE")))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure deleting dcp_config_comp_reltn data: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_dbimport "CER_INSTALL:dcp_config_comp_tree.csv", "dcp_confcomp_tree_data_import", 5000
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
