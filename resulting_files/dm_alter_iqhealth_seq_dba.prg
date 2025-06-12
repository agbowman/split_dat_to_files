CREATE PROGRAM dm_alter_iqhealth_seq:dba
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
 DECLARE parsestr = vc
 DECLARE errcode = i4
 DECLARE errmsg = vc
 DECLARE hasseq = i4
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to alter sequence iqhealth_seq correctly."
 SET hasseq = 0
 SELECT INTO "nl:"
  FROM dba_sequences
  WHERE sequence_name="IQHEALTH_SEQ"
  DETAIL
   hasseq = 1
  WITH nocounter
 ;end select
 IF (hasseq=1)
  SET parsestr = "rdb alter sequence iqhealth_seq increment by 200 go"
  CALL parser(parsestr)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to alter sequence iqhealth_seq correctly: ",errmsg)
  ELSE
   UPDATE  FROM dm_sequences ds
    SET ds.increment_by = 200
    WHERE ds.sequence_name="IQHEALTH_SEQ"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to alter sequence iqhealth_seq correctly: ",errmsg)
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = "Success: Sequence iqhealth_seq successfully altered"
   ENDIF
  ENDIF
 ELSE
  EXECUTE dm_add_sequence "IQHEALTH_SEQ", 0, 0,
  0, 200
  IF ((dm_seq_reply->status="F"))
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create sequence iqhealth correnctly: ",dm_seq_reply->
    msg)
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Sequence iqhealth_seq successfully created"
  ENDIF
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
