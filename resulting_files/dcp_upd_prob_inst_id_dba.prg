CREATE PROGRAM dcp_upd_prob_inst_id:dba
 DECLARE program_version = vc WITH private, constant("001")
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
 SET readme_data->message = "Readme failed: Starting script dcp_upd_prob_inst_id..."
 DECLARE error_msg = c132 WITH protected, noconstant("")
 DECLARE range_inc = i4 WITH protect, noconstant(10000)
 DECLARE range_var = f8 WITH protect, noconstant(0.0)
 DECLARE info_domain_nm = vc WITH protect, constant("DCP_UPD_PROB_INST_ID")
 DECLARE batch_size_name = vc WITH protect, constant("DCP_UPD_PROB_INST_ID BATCH SIZE")
 DECLARE complete = i2 WITH protect, noconstant(0)
 DECLARE invalid_pk_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE update_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  custom_batchsize = info_number
  FROM dm_info
  WHERE info_domain=info_domain_nm
   AND info_name=batch_size_name
  DETAIL
   IF (custom_batchsize > 0)
    range_inc = custom_batchsize
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving user-defined batch size from DM_INFO: ",
   error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  num_prob = count(*)
  FROM problem p
  WHERE (p.problem_instance_id >
  (SELECT
   us.last_number
   FROM user_sequences us
   WHERE us.sequence_name="PROBLEM_SEQ"))
  DETAIL
   invalid_pk_cnt = num_prob
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving problems: ",error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  max_id = max(p.problem_instance_id)
  FROM problem p
  WHERE (p.problem_instance_id <=
  (SELECT
   us.last_number
   FROM user_sequences us
   WHERE us.sequence_name="PROBLEM_SEQ"))
  DETAIL
   range_var = max_id
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving initial max problem instance id: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt > 0.0)
  SET complete = 0
  WHILE (complete=0)
    CALL echo(concat("> Processing... batch of ",build(range_inc)," Using range_var: ",build(
       range_var)))
    UPDATE  FROM problem p
     SET p.problem_instance_id = cnvtreal(seq(problem_seq,nextval)), p.updt_cnt = (p.updt_cnt+ 1), p
      .updt_dt_tm = cnvtdatetime(update_dt_tm),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx
     WHERE p.problem_instance_id > range_var
     WITH nocounter, maxqual(p,value(range_inc))
    ;end update
    SET total_updt_cnt = (curqual+ total_updt_cnt)
    IF (error(error_msg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("An error occurred while updating problems: ",error_msg)
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET complete = 1
    ELSE
     SELECT INTO "nl:"
      max_id = max(p.problem_instance_id)
      FROM problem p
      WHERE (p.problem_instance_id <=
      (SELECT
       us.last_number
       FROM user_sequences us
       WHERE us.sequence_name="PROBLEM_SEQ"))
      DETAIL
       range_var = max_id
      WITH nocounter
     ;end select
     IF (error(error_msg,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Error retrieving max problem instance id: ",error_msg)
      GO TO exit_program
     ENDIF
    ENDIF
  ENDWHILE
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat(
   "Auto-success: No problem rows were affected with an invalid problem sequence.")
  GO TO exit_program
 ENDIF
 SET invalid_pk_cnt = 0.0
 SELECT INTO "nl:"
  num_prob = count(*)
  FROM problem p
  WHERE (p.problem_instance_id >
  (SELECT
   us.last_number
   FROM user_sequences us
   WHERE us.sequence_name="PROBLEM_SEQ"))
  DETAIL
   invalid_pk_cnt = num_prob
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving problems: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
   " record(s) successfully.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Invalid problem_instance_id's still exist on the problem table:",
   invalid_pk_cnt)
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
