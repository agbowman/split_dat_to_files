CREATE PROGRAM dm_wrp_dm_refchg_trg_col:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_wrp_dm_refchg_trg_col.prg..."
 EXECUTE dm_dbimport "cer_install:dm_refchg_trg_col.csv", "dm_imp_dm_refchg_trg_col", 100
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
