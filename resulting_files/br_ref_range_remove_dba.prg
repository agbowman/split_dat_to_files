CREATE PROGRAM br_ref_range_remove:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ref_range_remove.prg> script"
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 DELETE  FROM br_step
  WHERE step_mean="REFRANGEWIZGL"
  WITH nocounter
 ;end delete
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_client_item_reltn
  WHERE item_type="STEP"
   AND item_mean="REFRANGEWIZGL"
  WITH nocounter
 ;end delete
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_client_sol_step
  WHERE step_mean="REFRANGEWIZGL"
  WITH nocounter
 ;end delete
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
#exit_script
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ref_range_remove.prg> script"
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
