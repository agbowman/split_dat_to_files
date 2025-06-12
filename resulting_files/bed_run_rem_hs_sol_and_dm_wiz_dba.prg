CREATE PROGRAM bed_run_rem_hs_sol_and_dm_wiz:dba
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
 DECLARE br_nv_key = vc WITH protect, constant("WIZARDSECURITY")
 DECLARE removebedrockwizard(step_mean=vc,step_cat_mean=vc,step_type=vc,item_type=vc) = i4
 DECLARE removebedrocksolution(item_mean=vc,sol_item_type=vc) = i4
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SUBROUTINE removebedrockwizard(step_mean,step_cat_mean,step_type,item_type)
   DELETE  FROM br_step bs
    WHERE bs.step_mean=step_mean
     AND bs.step_type=step_type
     AND bs.step_cat_mean=step_cat_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script:Deleting br_step: ",errmsg)
    SET readme_data->status = "F"
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
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script:Deleting wizard in br_client_item_reltn: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   DELETE  FROM br_client_sol_step bcss
    WHERE bcss.step_mean=step_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script: Deleting wizard in br_client_sol_step: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   DELETE  FROM br_name_value bnv
    WHERE bnv.br_nv_key1=br_nv_key
     AND bnv.br_value=step_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script: Deleting solution in br_name_value: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   RETURN(errcode)
 END ;Subroutine
 SUBROUTINE removebedrocksolution(item_mean,sol_item_type)
   DELETE  FROM br_client_item_reltn bcir
    WHERE bcir.item_type=sol_item_type
     AND bcir.item_mean=item_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script:Deleting solution in br_client_item_reltn: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   DELETE  FROM br_client_sol_step bcss
    WHERE bcss.solution_mean=item_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script: Deleting solution in br_client_sol_step: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   DELETE  FROM br_name_value bnv
    WHERE bnv.br_value=item_mean
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat(
     "Readme Failed <bed_remove_solution_and_wizard.inc> script: Deleting solution in br_name_value: ",
     errmsg)
    SET readme_data->status = "F"
    GO TO exit_program
   ENDIF
   RETURN(errcode)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script bed_run_rem_hs_sol_and_dm_wiz..."
 DECLARE step_mean = vc WITH protect, constant("DATAMAPPINGWIZ")
 DECLARE step_cat_mean = vc WITH protect, constant("CORE")
 DECLARE item_mean = vc WITH protect, constant("COREHS")
 DECLARE step_type = vc WITH protect, constant("IMPMAINT")
 DECLARE wiz_item_type = vc WITH protect, constant("STEP")
 DECLARE sol_item_type = vc WITH protect, constant("SOLUTION")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET errcode = removebedrockwizard(step_mean,step_cat_mean,step_type,wiz_item_type)
 SET errcode = removebedrocksolution(item_mean,sol_item_type)
 IF (errcode=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme script successfully executed"
  COMMIT
 ENDIF
#exit_program
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
