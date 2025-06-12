CREATE PROGRAM br_run_br_prefs:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_bb_prodcat.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DELETE  FROM br_prefs b
  WHERE b.br_prefs_id > 0.0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_prefs: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET filename = "cer_install:br_prefs.csv"
 SET scriptname = "br_prefs_config"
 EXECUTE dm_dbimport filename, scriptname, 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
