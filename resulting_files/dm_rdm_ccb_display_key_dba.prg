CREATE PROGRAM dm_rdm_ccb_display_key:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_ccb_display_key..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value cv
  SET cv.display_key = cnvtalphanum(cnvtupper(trim(cv.display,3)))
  WHERE cv.updt_dt_tm >= cnvtdatetime("27-JAN-2021")
   AND cv.updt_task=4171655
   AND cv.updt_id=0
   AND cv.display_key != cnvtalphanum(cnvtupper(trim(cv.display,3)))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update CODE_VALUE: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
