CREATE PROGRAM dm_backfill_nomen_a_nls:dba
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
 IF (validate(backfill_request->table_name,"Z")="Z")
  RECORD backfill_request(
    1 table_name = vc
    1 do_nls_backfill_ind = i2
    1 columns[*]
      2 column_name = vc
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_backfill_nomen_a_nls..."
 SET backfill_request->table_name = "NOMENCLATURE"
 EXECUTE dac_backfill_a_nls_table
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
