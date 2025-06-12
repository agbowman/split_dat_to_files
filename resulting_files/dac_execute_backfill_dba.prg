CREATE PROGRAM dac_execute_backfill:dba
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
 SET readme_data->message = "Readme Failed: Starting script dac_execute_backfill..."
 DECLARE deb_err_msg = vc WITH protect, noconstant("")
 CALL parser(concat("rdb asis(^ ",request->update_stmt," ^) go"))
 IF (error(deb_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update ",request->table_name,": ",deb_err_msg)
  GO TO exit_script
 ELSE
  SET reply->update_count = curqual
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Successfully ran statement for ",request->table_name)
#exit_script
END GO
