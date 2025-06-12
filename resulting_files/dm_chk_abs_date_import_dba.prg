CREATE PROGRAM dm_chk_abs_date_import:dba
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
 SET table_count = 0
 SELECT INTO "nl:"
  "x"
  FROM dm_info
  WHERE info_domain="ABSOLUTE DATE"
  DETAIL
   table_count = (table_count+ 1)
  WITH nocounter
 ;end select
 IF (table_count > 50)
  SET readme_data->message = " Absolute Date Import Readme Successful."
  SET readme_data->status = "S"
  CALL echo("Absolute Date CSV File has been successfully loaded!")
  CALL echo(build("Table Count:",table_count))
 ELSE
  SET readme_data->message = "Absolute Date Import Readme NOT Successful."
  SET readme_data->status = "F"
  CALL echo("Absolute Date import failed!")
  CALL echo(build("Table Count:",table_count))
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
