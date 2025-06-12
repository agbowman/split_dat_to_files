CREATE PROGRAM dcp_upd_nomen_entity_id:dba
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
 SET readme_data->message = "Readme failed: Starting script dcp_upd_nomen_entity_id..."
 DECLARE error_msg = c132 WITH protected, noconstant("")
 DECLARE range_inc = i4 WITH protect, noconstant(10000)
 DECLARE range_var = f8 WITH protect, noconstant(0.0)
 DECLARE info_domain_nm = vc WITH protect, constant("DCP_UPD_NOMEN_ENTITY_ID")
 DECLARE batch_size_name = vc WITH protect, constant("DCP_UPD_NOMEN_ENTITY_ID BATCH SIZE")
 DECLARE complete = i2 WITH protect, noconstant(0)
 DECLARE invalid_pk_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE update_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE curr_seq_val = f8 WITH protect, noconstant(0.0)
 DECLARE getrelationseqid(null) = null WITH protect
 SUBROUTINE getrelationseqid(null)
  SELECT INTO "nl:"
   seq_val = seq(entity_reltn_seq,nextval)
   FROM dual
   DETAIL
    curr_seq_val = seq_val
   WITH format, counter
  ;end select
  IF (error(error_msg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error in getting entity_reltn_seq: ",error_msg)
   GO TO exit_program
  ENDIF
 END ;Subroutine
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
 CALL getrelationseqid(null)
 SELECT INTO "nl:"
  num_nomen_reltn = count(*)
  FROM nomen_entity_reltn n
  WHERE n.nomen_entity_reltn_id > curr_seq_val
  DETAIL
   invalid_pk_cnt = num_nomen_reltn
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving nomen_entity_reltn: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-success: No nomen_entity_reltn rows were affected with an invalid ENTITY_RELTN_SEQ sequence."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  max_id = min(n.nomen_entity_reltn_id)
  FROM nomen_entity_reltn n
  WHERE n.nomen_entity_reltn_id > curr_seq_val
  DETAIL
   range_var = max_id
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving initial max nomen_entity_reltn_id: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (range_var=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-success: No nomen_entity_reltn rows were affected with an invalid ENTITY_RELTN_SEQ sequence."
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt > 0.0)
  SET complete = 0
  WHILE (complete=0)
    CALL echo(concat("> Processing... batch of ",build(range_inc)," Using range_var: ",build(
       range_var)))
    UPDATE  FROM nomen_entity_reltn n
     SET n.nomen_entity_reltn_id = cnvtreal(seq(entity_reltn_seq,nextval)), n.updt_cnt = (n.updt_cnt
      + 1), n.updt_dt_tm = cnvtdatetime(update_dt_tm),
      n.updt_id = n.updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
     WHERE n.nomen_entity_reltn_id >= range_var
     WITH nocounter, maxqual(n,value(range_inc))
    ;end update
    SET total_updt_cnt = (curqual+ total_updt_cnt)
    IF (error(error_msg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("An error occurred while updating nomen_entity_reltn_id: ",
      error_msg)
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET complete = 1
    ELSE
     SET range_var = 0
     CALL getrelationseqid(null)
     SELECT INTO "nl:"
      max_id = min(n.nomen_entity_reltn_id)
      FROM nomen_entity_reltn n
      WHERE n.nomen_entity_reltn_id > curr_seq_val
      DETAIL
       range_var = max_id
      WITH nocounter
     ;end select
     IF (range_var=0)
      SET complete = 1
     ENDIF
     IF (error(error_msg,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Error retrieving max nomen_entity_reltn_id: ",error_msg)
      GO TO exit_program
     ENDIF
    ENDIF
  ENDWHILE
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-success: No nomen_entity_reltn rows were affected with an invalid ENTITY_RELTN_SEQ sequence."
  GO TO exit_program
 ENDIF
 SET invalid_pk_cnt = 0.0
 CALL getrelationseqid(null)
 SELECT INTO "nl:"
  num_ncr = count(*)
  FROM nomen_entity_reltn n
  WHERE n.nomen_entity_reltn_id > curr_seq_val
  DETAIL
   invalid_pk_cnt = num_ncr
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving nomen_entity_reltn: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (invalid_pk_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
   " record(s) successfully.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Invalid nomen_entity_reltn_id's still exist on the nomen_entity_reltn table:",trim(cnvtstring(
     invalid_pk_cnt)))
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET script_version = "001 11/24/2014 BP030748"
END GO
