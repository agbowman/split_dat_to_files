CREATE PROGRAM br_run_gpro_reltn:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_gpro_reltn.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 UPDATE  FROM br_gpro_reltn b
  SET b.aci_excluded_ind = 0
  WHERE b.br_gpro_reltn_id > 0
   AND b.aci_excluded_ind=1
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating into br_run_gpro_reltn: ",errmsg)
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  COMMIT
 ENDIF
 IF ((readme_data->status != "F"))
  SET readme_data->message = "Readme Succeeded: <br_run_gpro_reltn> script"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
