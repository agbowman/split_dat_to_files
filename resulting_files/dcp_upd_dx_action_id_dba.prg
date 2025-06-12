CREATE PROGRAM dcp_upd_dx_action_id:dba
 DECLARE program_version = vc WITH private, constant("002")
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
 SET readme_data->message = "Readme failed: Starting script dcp_upd_dx_action_id..."
 DECLARE error_msg = c132 WITH protected, noconstant("")
 DECLARE max_dx_action_id = f8 WITH protect, noconstant(0.0)
 DECLARE curr_code = f8 WITH public, noconstant(0.0)
 DECLARE invalid_pk_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE getnewproblemid(null) = null WITH protect
 SUBROUTINE getnewproblemid(null)
  SELECT INTO "nl:"
   x = seq(problem_seq,nextval)
   FROM dual
   DETAIL
    curr_code = x
   WITH format, counter
  ;end select
  IF (((error(error_msg,0) != 0) OR (curr_code < 1)) )
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error in generating problem sequence: ",error_msg)
   GO TO exit_program
  ENDIF
 END ;Subroutine
 CALL getnewproblemid(null)
 SELECT INTO "nl:"
  max_id = max(da.diagnosis_action_id)
  FROM diagnosis_action da
  WHERE da.diagnosis_action_id > curr_code
  DETAIL
   max_dx_action_id = max_id
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving diagnosis: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (max_dx_action_id > 0.0)
  WHILE (max_dx_action_id > curr_code)
    CALL getnewproblemid(null)
  ENDWHILE
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat(
   "Auto-success: No diagnosis rows found with invalid diagnosis_action_id")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  num_dx = count(*)
  FROM diagnosis_action da
  WHERE da.diagnosis_action_id > curr_code
  DETAIL
   invalid_pk_cnt = num_dx
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving diagnosis: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Readme updated successfully.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Invalid diagnosis_action_id's still exist on the diagnosis_action table:",invalid_pk_cnt)
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
