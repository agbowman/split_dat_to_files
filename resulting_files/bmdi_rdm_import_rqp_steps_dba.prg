CREATE PROGRAM bmdi_rdm_import_rqp_steps:dba
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
 SET readme_data->message = "Readme Failed: Starting bmdi_rdm_import_rqp_steps.prg script"
 EXECUTE dm_dbimport "cer_install:bmdi_rqp.csv", "rqp_import", 1000
 EXECUTE dm_rqp_check "bmdi_rqp.csv"
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
