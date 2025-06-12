CREATE PROGRAM cp_chg_powcht_settings:dba
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
 SET readme_data->message = "Readme failure.  Starting cp_chg_powcht_settings script"
 UPDATE  FROM dm_application
  SET application_ini_ind = 1
  WHERE application_number=600005
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme failure.  Error occurred while updating PowerChart application settings!"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme successful.  Record updated, exiting cp_chg_powcht_settings script"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
