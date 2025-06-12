CREATE PROGRAM dm_create_dm_cmb_warning_seq:dba
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
 DECLARE parsestr = c255
 DECLARE errcode = i4
 DECLARE errmsg = c255
 DECLARE hasseq = i4
 DECLARE cachenbr = i4
 SET parsestr = " "
 SET errcode = 0
 SET errmsg = " "
 SET hasseq = 0
 SET cachenbr = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to create sequence dm_cmb_warning_seq."
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name="DM_CMB_WARNING_SEQ"
  DETAIL
   hasseq = 1
  WITH nocounter
 ;end select
 IF (hasseq=1)
  SET parserstr = "rdb alter sequence DM_CMB_WARNING_SEQ cycle go"
  CALL parser(parserstr)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to establish cycling for DM_CMB_WARNING_SEQ: ",errmsg)
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Sequence dm_cmb_warning_seq altered for Cycling"
   GO TO exit_script
  ENDIF
 ELSE
  EXECUTE dm_add_sequence "DM_CMB_WARNING_SEQ", 0, 100000,
  1, 0
  IF ((dm_seq_reply->status="F"))
   GO TO exit_script
  ENDIF
  SET parsestr = "rdb alter sequence DM_CMB_WARNING_SEQ cache 2 go"
  CALL parser(parsestr)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Failed to alter cache for sequence DM_CMB_WARNING_SEQ correctly: ",errmsg)
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_sequences ds
   SET ds.cache = 2, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task
   WHERE ds.sequence_name="DM_CMB_WARNING_SEQ"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Failed to update dm_sequences for sequence DM_CMB_WARNING_SEQ: ",errmsg)
   ROLLBACK
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Updated dm_sequences for Sequence DM_CMB_WARNING_SEQ successfully"
   COMMIT
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
