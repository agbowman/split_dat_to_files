CREATE PROGRAM dm_dcm_add_seq_rdm:dba
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
 FREE RECORD dm_seq_reply
 RECORD dm_seq_reply(
   1 status = c1
   1 msg = vc
 )
 DECLARE dasr_error = i4 WITH protect, noconstant(0)
 DECLARE dasr_error_msg = vc WITH protect, noconstant("")
 DECLARE dasr_seq_ind = i2 WITH protect, noconstant(0)
 DECLARE dasr_seq_name = vc WITH protect, constant("CHANGE_MGMT_SEQ")
 SET readme_data->status = "F"
 SET readme_data->message = "Starting DM_DCM_ADD_SEQ_RDM..."
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name=dasr_seq_name
  DETAIL
   dasr_seq_ind = 1
  WITH nocounter
 ;end select
 SET dasr_error = error(dasr_error_msg,0)
 IF (dasr_error > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to query for existance of ",dasr_seq_name,": ",
   dasr_error_msg)
  GO TO exit_script
 ENDIF
 IF (dasr_seq_ind=1)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: sequence ",dasr_seq_name," already exists.")
  GO TO exit_script
 ENDIF
 EXECUTE dm_add_sequence dasr_seq_name, 0, 0,
 0, 0
 IF ((dm_seq_reply->status="F"))
  SET readme_data->status = dm_seq_reply->status
  SET readme_data->message = concat("Failed. ",dasr_seq_name," - DM_ADD_SEQUENCE: ",dm_seq_reply->msg
   )
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb alter sequence ",dasr_seq_name," cache 2000 go"))
 IF (error(dasr_error_msg,0))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter cache for sequence ",dasr_seq_name,
   " correctly: ",dasr_error_msg)
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb create or replace public synonym ",dasr_seq_name),0)
 CALL parser(concat("for ",dasr_seq_name),0)
 CALL parser("go",1)
 IF (error(dasr_error_msg,0))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create public synonym ",dasr_seq_name,": ",
   dasr_error_msg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_sequences ds
  SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task, ds.updt_cnt = (ds.updt_cnt+ 1)
  WHERE ds.sequence_name=dasr_seq_name
  WITH nocounter
 ;end update
 IF (error(dasr_error_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update dm_sequences for sequence ",dasr_seq_name,": ",
   dasr_error_msg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "CHANGE_MGMT_SEQ has been created."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
