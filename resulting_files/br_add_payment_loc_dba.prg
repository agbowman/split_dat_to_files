CREATE PROGRAM br_add_payment_loc:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_add_payment_loc.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errorcheck(failmsg=vc) = i2
 SUBROUTINE errorcheck(failmsg)
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(failmsg,":",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE wizard_name = vc
 SET wizard_name = "Payment Locations Setup"
 DECLARE wizard_mean = vc
 SET wizard_mean = "REVCYCLEPAYMENTLOC"
 DECLARE step_cat_mean = vc
 SET step_cat_mean = "PATACCT"
 DECLARE step_cat_disp = vc
 SET step_cat_disp = "Patient Accounting"
 DECLARE solution_mean = vc
 SET solution_mean = "PATACCT"
 DECLARE solution_name = vc
 SET solution_name = "Patient Accounting"
 DECLARE sol_found = vc
 DECLARE step_found = vc
 DECLARE last_seq = i4
 SELECT INTO "nl:"
  FROM br_step bs
  PLAN (bs
   WHERE bs.step_mean=wizard_mean)
  WITH nocounter
 ;end select
 CALL errorcheck("Selecting from br_step failed")
 IF (curqual=0)
  INSERT  FROM br_step bs
   SET bs.step_mean = wizard_mean, bs.step_disp = wizard_name, bs.step_type = "IMPMAINT",
    bs.step_cat_mean = step_cat_mean, bs.step_cat_disp = step_cat_disp, bs.default_seq = 5000
   WITH nocounter
  ;end insert
  CALL errorcheck("Inserting into br_step failed")
 ENDIF
 SET sol_found = "N"
 SET step_found = "N"
 SET last_seq = 0
 SELECT INTO "nl:"
  FROM br_client_item_reltn bcir
  PLAN (bcir
   WHERE bcir.item_type="SOLUTION"
    AND bcir.br_client_id=1)
  ORDER BY bcir.solution_seq
  DETAIL
   last_seq = bcir.solution_seq
   IF (bcir.item_mean=solution_mean)
    sol_found = "Y"
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end select
 CALL errorcheck("Selecting solution from br_client_item_reltn failed")
 IF (sol_found="N")
  INSERT  FROM br_client_item_reltn bcir
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "SOLUTION",
    bcir.item_mean = solution_mean, bcir.item_display = solution_name, bcir.solution_seq = (last_seq
    + 10),
    bcir.solution_type_flag = 0
   WITH nocounter, skipbedrock = 1
  ;end insert
  CALL errorcheck("Inserting solution into br_client_item_reltn failed")
 ENDIF
 SELECT INTO "nl:"
  FROM br_client_item_reltn bcir
  PLAN (bcir
   WHERE bcir.item_type="STEP"
    AND bcir.br_client_id=1)
  DETAIL
   IF (bcir.item_mean=wizard_mean)
    step_found = "Y"
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end select
 CALL errorcheck("Selecting wizard from br_client_item_reltn failed")
 IF (step_found="N")
  INSERT  FROM br_client_item_reltn bcir
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "STEP",
    bcir.item_mean = wizard_mean, bcir.item_display = wizard_name, bcir.step_cat_mean = step_cat_mean,
    bcir.step_cat_disp = step_cat_disp, bcir.solution_type_flag = 0
   WITH nocounter, skipbedrock = 1
  ;end insert
  CALL errorcheck("Inserting wizard into br_client_item_reltn failed")
 ENDIF
 SET last_step_seq = 0
 SELECT INTO "nl:"
  FROM br_client_sol_step bcss
  PLAN (bcss
   WHERE bcss.br_client_id=1
    AND bcss.solution_mean=solution_mean)
  ORDER BY bcss.sequence
  DETAIL
   last_step_seq = bcss.sequence
  WITH nocounter
 ;end select
 CALL errorcheck("Selecting seq from br_client_sol_step failed")
 SELECT INTO "nl:"
  FROM br_client_sol_step bcss
  PLAN (bcss
   WHERE bcss.br_client_id=1
    AND bcss.step_mean=wizard_mean
    AND bcss.solution_mean=solution_mean)
  WITH nocounter
 ;end select
 CALL errorcheck("Selecting row from br_client_sol_step failed")
 IF (curqual=0)
  INSERT  FROM br_client_sol_step bcss
   SET bcss.br_client_id = 1, bcss.solution_mean = solution_mean, bcss.step_mean = wizard_mean,
    bcss.sequence = (last_step_seq+ 10)
   WITH nocounter, skipbedrock = 1
  ;end insert
  CALL errorcheck("Inserting into br_client_sol_step failed")
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
