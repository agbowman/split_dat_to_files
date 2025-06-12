CREATE PROGRAM dm_bmdi_seq_inc_alter:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_bmdi_seq_inc_alter.prg..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE seq_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE seq_cur_inc_by = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  us.increment_by
  FROM user_sequences us
  WHERE us.sequence_name="BMDI_SEQ"
  DETAIL
   seq_exists_ind = 1, seq_cur_inc_by = cnvtint(us.increment_by)
  WITH nocounter
 ;end select
 IF (seq_exists_ind=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Unable to find BMDI_SEQ on DM2_USER_SEQUENCES!"
  GO TO exit_script
 ELSEIF (seq_cur_inc_by=100)
  SET readme_data->status = "S"
  SET readme_data->message = "BMDI_SEQ is already set to increment by 100."
  GO TO exit_script
 ENDIF
 CALL parser("rdb asis(^ALTER SEQUENCE BMDI_SEQ INCREMENT BY 100^) go")
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter increment_by value: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: BMDI_SEQ now increments by 100"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
