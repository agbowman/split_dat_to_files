CREATE PROGRAM ced_rdm_import_format_scripts:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: Starting ced_rdm_import_format_scripts."
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE csvfilepath = vc
 SET csvfilepath = "cer_install:ced_rdm_rqp.csv"
 CALL echo("***")
 CALL echo(concat("***   Importing the ",csvfilepath," file"))
 CALL echo("***")
 EXECUTE dm_dbimport csvfilepath, "rqp_import", 100
 IF ((readme_data->status != "S"))
  GO TO exitscript
 ENDIF
 EXECUTE dm_rqp_check "ced_rdm_rqp.csv"
 IF ((readme_data->status != "S"))
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = build("Readme succeeded. row(s) were imported.")
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
#exitscript
 CALL echorecord(readme_data)
END GO
