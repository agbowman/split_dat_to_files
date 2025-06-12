CREATE PROGRAM br_run_recommendation_r_esm:dba
 DECLARE errormsg = vc WITH protect, noconstant("")
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
 SET readme_data->message = "Readme Failed: Starting <br_run_recommendation_r> script"
 IF ((((currev * 10000)+ ((currevminor * 100)+ currevminor2)) < 80205))
  SET readme_data->status = "S"
  SET readme_data->message = "Readme does not run in pre-8.2.5 CCL environments"
  GO TO exit_script
 ENDIF
 DELETE  FROM br_rec_r b
  WHERE b.rec_id > 0
  WITH nocounter
 ;end delete
 IF (error(errormsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from br_rec_r: ",errormsg)
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:br_recommendation_r.csv", "br_recommendation_r_config", 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
