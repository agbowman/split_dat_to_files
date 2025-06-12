CREATE PROGRAM dm_alter_cpmapp_applctx_seq:dba
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
 DECLARE lastnbr = i4
 DECLARE posnbr = i4
 DECLARE cachenbr = i4
 SET parsestr = " "
 SET errcode = 0
 SET errmsg = " "
 SET hasseq = 0
 SET lastnbr = 0
 SET posnbr = 0
 SET cachenbr = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to alter sequence cpmapp_applctx correctly."
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name="CPMAPP_APPLCTX"
  DETAIL
   hasseq = 1, lastnbr = d.last_number, cachenbr = d.cache_size
  WITH nocounter
 ;end select
 SET posnbr = (2147483647 - cachenbr)
 IF (hasseq=1)
  IF (lastnbr > posnbr)
   SET parsestr = "rdb drop sequence cpmapp_applctx go"
   CALL parser(parsestr)
   EXECUTE dm_add_sequence "CPMAPP_APPLCTX", 0, 2147483647,
   1, 0
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Failed to drop and re-create sequence cpmapp_applctx correctly: ",errmsg)
   ENDIF
  ELSE
   SET parsestr = "rdb alter sequence cpmapp_applctx maxvalue 2147483647 cycle go"
   CALL parser(parsestr)
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to alter sequence cpmapp_applctx correctly: ",errmsg)
   ENDIF
  ENDIF
  UPDATE  FROM dm_sequences ds
   SET ds.cycle = "Y", ds.max_value = 2147483647, ds.updt_applctx = reqinfo->updt_applctx,
    ds.updt_cnt = (ds.updt_cnt+ 1), ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_id =
    reqinfo->updt_id,
    ds.updt_task = reqinfo->updt_task
   WHERE ds.sequence_name="CPMAPP_APPLCTX"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to alter sequence cpmapp_applctx correctly: ",errmsg)
   ROLLBACK
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Sequence cpmapp_applctx successfully altered"
   COMMIT
  ENDIF
 ELSE
  EXECUTE dm_add_sequence "CPMAPP_APPLCTX", 0, 2147483647,
  1, 0
  IF ((dm_seq_reply->status="F"))
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create sequence cpmapp_applctx correnctly: ",
    dm_seq_reply->msg)
   ROLLBACK
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Sequence cpmapp_applctx successfully created"
   COMMIT
  ENDIF
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
