CREATE PROGRAM bed_run_rem_pat_kiosk_prf_wiz:dba
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
 DECLARE step_mean = vc WITH protect, constant("KIOSKPROFILES")
 DECLARE step_cat_mean = vc WITH protect, constant("REVCYC")
 DECLARE step_type = vc WITH protect, constant("IMPMAINT")
 DECLARE item_type = vc WITH protect, constant("STEP")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <bed_run_rem_pat_kiosk_prf_wiz.prg> script"
 DELETE  FROM br_step bs
  WHERE bs.step_mean=step_mean
   AND bs.step_type=step_type
   AND bs.step_cat_mean=step_cat_mean
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting br_step: ",errmsg)
  GO TO exit_program
 ENDIF
 DELETE  FROM br_client_item_reltn bcir
  WHERE bcir.item_type=item_type
   AND bcir.item_mean=step_mean
   AND bcir.step_cat_mean=step_cat_mean
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting br_client_item_reltn: ",errmsg)
  GO TO exit_program
 ENDIF
 DELETE  FROM br_client_sol_step bcss
  WHERE bcss.step_mean=step_mean
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting br_client_sol_step: ",errmsg)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Successful: Ending <bed_run_rem_pat_kiosk_prf_wiz.prg> script"
 IF (errcode=0)
  COMMIT
 ENDIF
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
