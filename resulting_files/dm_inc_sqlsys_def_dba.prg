CREATE PROGRAM dm_inc_sqlsys_def:dba
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
 DECLARE dm_row_ind = i4
 SET dm_row_ind = 0
 SET readme_data->status = "F"
 UPDATE  FROM dfile d
  SET d.file_name = "SQLSYSTEM", d.file_glos = "SQLSYSTEM", d.rdb_schema_name = "SQLSYSTEM"
  WHERE d.file_name="ORACLESYSTEM"
  WITH nocounter, copy
 ;end update
 SELECT INTO "nl:"
  FROM dfile d
  WHERE d.file_name="SQLSYSTEM"
  DETAIL
   dm_row_ind = 1
  WITH nocounter
 ;end select
 IF (dm_row_ind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: SQLSYSTEM row added to the DFILE table"
 ELSE
  SET readme_data->message = "Failure: SQLSYSTEM row not added to the DFILE table"
 ENDIF
 EXECUTE dm_readme_status
END GO
