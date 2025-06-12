CREATE PROGRAM br_run_dmart_filter_acm_wl:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_dmart_filter_acm_wl> script"
 EXECUTE dm_dbimport "cer_install:datamart_filter_amb_care_mgt.csv", "br_datamart_filter_config",
 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
