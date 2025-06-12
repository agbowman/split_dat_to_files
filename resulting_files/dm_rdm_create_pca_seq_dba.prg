CREATE PROGRAM dm_rdm_create_pca_seq:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_create_pca_seq..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE seqexists = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name="PCA_SEQ"
  DETAIL
   seqexists = 1
  WITH nocounter
 ;end select
 IF (seqexists=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Sequence PCA_SEQ already exists."
  GO TO exit_script
 ENDIF
 EXECUTE dm_add_sequence "PCA_SEQ", 0, 0,
 0, 0
 SET readme_data->status = dm_seq_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = concat("Failed. PCA_SEQ - DM_ADD_SEQUENCE: ",dm_seq_reply->msg)
  GO TO exit_script
 ENDIF
 SET readme_data->message = "Success: Sequence PCA_SEQ added."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
