CREATE PROGRAM bb_dm_dce_chk:dba
 DECLARE all_found_ind = i4
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
 SELECT INTO "nl:"
  dce.script_name
  FROM dm_cmb_exception dce
  PLAN (dce
   WHERE dce.script_name IN ("PERSON_CMB_ASSIGN", "PERSON_CMB_BB_EXCEPTION", "PERSON_CMB_CROSSMATCH",
   "PERSON_CMB_PATIENT_DISPENSE", "PERSON_CMB_TRANSFUSION"))
  DETAIL
   all_found_ind = (all_found_ind+ 1)
  WITH nocounter
 ;end select
 IF (all_found_ind != 5)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Error updating BB rows on DM_CMB_EXCEPTION."
  SET readme_data->message = "Readme failed."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "BB rows on DM_CMB_EXCEPTION have been updated successfully."
  SET readme_data->status = "S"
  SET readme_data->message = "Readme successful."
 ENDIF
 IF (curenv=0)
  CALL echo(request->setup_proc[1].error_msg)
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 EXECUTE dm_readme_status
END GO
