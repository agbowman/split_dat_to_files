CREATE PROGRAM dm_create_bmdi_seq:dba
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
 DECLARE errmsg = vc WITH protect, noconstant("")
 EXECUTE dm_add_sequence "bmdi_seq", 0, 0,
 0, 100
 IF ((dm_seq_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_seq_reply->msg
  GO TO exit_script
 ENDIF
 CALL parser("rdb asis(^alter sequence bmdi_seq cache 2000^) go")
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter cache to 2000: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = dm_seq_reply->msg
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
