CREATE PROGRAM aps_rqp_import:dba
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
 SET readme_data->message = "Readme Failed: Starting script aps_rqp_import..."
 DECLARE csvname = vc WITH protect, noconstant("aps_rqp.csv")
 EXECUTE dm_dbimport value(build("cer_install:",csvname)), "rqp_import", 1000
 EXECUTE dm_rqp_check value(csvname)
 IF ((readme_data->status != "F"))
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme performed all required tasks"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
