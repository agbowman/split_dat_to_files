CREATE PROGRAM cdi_sequence_readme:dba
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
 SET last_num = 0
 SELECT INTO "nl:"
  FROM user_sequences us
  WHERE us.sequence_name="CDI_SEQ"
  DETAIL
   CALL echo("Found CDI_Seq"), last_num = us.last_number
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL echo("Adding CDI_Seq")
  EXECUTE dm_add_sequence "CDI_SEQ", last_num, 0,
  0, 0
 ENDIF
 IF ((dm_seq_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_seq_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_seq_reply->msg
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "CDI_SEQ sequence exists in database."
 ENDIF
 EXECUTE dm_readme_status
END GO
