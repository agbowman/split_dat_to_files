CREATE PROGRAM dm_purge_table_root_backfill_w:dba
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
 SET readme_data->message = "Readme Failure: Starting dm_purge_table_root_backfill_w.prg script."
 DECLARE dptrbw_errmsg = c132
 EXECUTE dm_dbimport "cer_install:dm_purge_table_root.csv", "dm_purge_table_root_backfill", 500
 IF (error(dptrbw_errmsg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build(dptrbw_errmsg,"- Readme Failed.")
  ROLLBACK
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Backfill of DM_PURGE_TABLE has completed successfully..."
  COMMIT
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
