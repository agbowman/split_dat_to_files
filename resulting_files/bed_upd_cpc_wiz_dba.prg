CREATE PROGRAM bed_upd_cpc_wiz:dba
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
 SET readme_data->message = "Readme Failed: Starting <bed_upd_cpc_wiz.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM br_step br
  SET br.step_disp = "CPC and PCF Setup"
  WHERE br.step_mean="CPC"
  WITH nocounter
 ;end update
 IF (error(errmsg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: ",errmsg)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme updated the BR_STEP table"
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
