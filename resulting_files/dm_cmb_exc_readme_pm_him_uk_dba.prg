CREATE PROGRAM dm_cmb_exc_readme_pm_him_uk:dba
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
 FREE RECORD dm_rdm_err
 RECORD dm_rdm_err(
   1 err_msg = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Starting DM_CMB_EXC_README_PM_HIM_UK..."
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ENDIF
 IF (checkprg("ENCNTR_CMB_ENCNTR_ACP") > 0)
  EXECUTE encntr_cmb_encntr_acp
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
  IF (checkprg("ENCNTR_CMB_ENCNTR_ACP_HIST") > 0)
   EXECUTE encntr_cmb_encntr_acp_hist
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("ENCNTR_CMB_ENCNTR_LOC_HIST") > 0)
   EXECUTE encntr_cmb_encntr_loc_hist
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("ENCNTR_CMB_ENCNTR_SLICE") > 0)
   EXECUTE encntr_cmb_encntr_slice
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("ENCNTR_CMB_PM_POST_DOC") > 0)
   EXECUTE encntr_cmb_pm_post_doc
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("ENCNTR_UCB_PM_POST_DOC") > 0)
   EXECUTE encntr_ucb_pm_post_doc
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("PERSON_CMB_ENCNTR_ACP_HIST") > 0)
   EXECUTE person_cmb_encntr_acp_hist
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("PERSON_CMB_PM_POST_DOC") > 0)
   EXECUTE person_cmb_pm_post_doc
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (checkprg("PERSON_UCB_PM_POST_DOC") > 0)
   EXECUTE person_ucb_pm_post_doc
   IF ((readme_data->status != "S"))
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_CODING") > 0)
  EXECUTE encntr_cmb_coding
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_CODING") > 0)
  EXECUTE encntr_ucb_coding
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_DIAGNOSIS") > 0)
  EXECUTE encntr_cmb_diagnosis
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_DIAGNOSIS") > 0)
  EXECUTE encntr_ucb_diagnosis
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_PROCEDURE") > 0)
  EXECUTE encntr_cmb_procedure
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_PROCEDURE") > 0)
  EXECUTE encntr_ucb_procedure
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("PERSON_CMB_DRG") > 0)
  EXECUTE person_cmb_drg
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("PERSON_UCB_DRG") > 0)
  EXECUTE person_ucb_drg
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_DRG") > 0)
  EXECUTE encntr_cmb_drg
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_DRG") > 0)
  EXECUTE encntr_ucb_drg
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_DRG_ENCNTR_EXT") > 0)
  EXECUTE encntr_cmb_drg_encntr_ext
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_DRG_ENCNTR_EXT") > 0)
  EXECUTE encntr_ucb_drg_encntr_ext
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_NE_DESC") > 0)
  EXECUTE encntr_cmb_ne_desc
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_ABSTRACTING") > 0)
  EXECUTE encntr_cmb_abstracting
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_UCB_ABSTRACTING") > 0)
  EXECUTE encntr_ucb_abstracting
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (checkprg("ENCNTR_CMB_ABSTRACT_DATA") > 0)
  EXECUTE encntr_cmb_abstract_data
  IF ((readme_data->status != "S"))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (error(dm_rdm_err->err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_rdm_err->err_msg)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: dm_cmb_exception table successfully maintained"
#exit_program
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ENDIF
 CALL echorecord(readme_data)
 FREE RECORD dm_rdm_err
END GO
