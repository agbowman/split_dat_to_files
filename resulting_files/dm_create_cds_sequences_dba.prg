CREATE PROGRAM dm_create_cds_sequences:dba
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
 DECLARE hasseq1 = i4
 DECLARE hasseq2 = i4
 DECLARE cachenbr = i4
 SET parsestr = " "
 SET errcode = 0
 SET errmsg = " "
 SET hasseq1 = 0
 SET hasseq2 = 0
 SET cachenbr = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed.  Starting script dm_create_cds_sequences..."
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name IN ("CDS_BATCH_SEQ", "CDS_BATCH_CONTENT_SEQ")
  HEAD REPORT
   hasseq1 = 0, hasseq2 = 0
  DETAIL
   IF (d.sequence_name="CDS_BATCH_SEQ")
    hasseq1 = 1
   ELSEIF (d.sequence_name="CDS_BATCH_CONTENT_SEQ")
    hasseq2 = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (hasseq1=1
  AND hasseq2=1)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Sequences CDS_BATCH_SEQ and CDS_BATCH_CONTENT_SEQ already exist."
  GO TO exit_script
 ELSE
  IF (hasseq1 != 1)
   EXECUTE dm_add_sequence "CDS_BATCH_SEQ", 0, 0,
   0, 0
   IF ((dm_seq_reply->status="F"))
    SET readme_data->message = concat("Failed. CDS_BATCH_SEQ - DM_ADD_SEQUENCE: ",dm_seq_reply->
     message)
    GO TO exit_script
   ENDIF
   SET parsestr = "rdb alter sequence CDS_BATCH_SEQ cache 2000 go"
   CALL parser(parsestr)
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to alter cache for sequence CDS_BATCH_SEQ correctly: ",
     errmsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM dm_sequences ds
    SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task
    WHERE ds.sequence_name="CDS_BATCH_SEQ"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update dm_sequences for sequence CDS_BATCH_SEQ: ",
     errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (hasseq2 != 1)
   EXECUTE dm_add_sequence "CDS_BATCH_CONTENT_SEQ", 0, 0,
   0, 0
   IF ((dm_seq_reply->status="F"))
    SET readme_data->message = concat("Failed. CDS_BATCH_CONTENT_SEQ - DM_ADD_SEQUENCE: ",
     dm_seq_reply->message)
    GO TO exit_script
   ENDIF
   SET parsestr = "rdb alter sequence CDS_BATCH_CONTENT_SEQ cache 2000 go"
   CALL parser(parsestr)
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Failed to alter cache for sequence CDS_BATCH_CONTENT_SEQ correctly: ",errmsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM dm_sequences ds
    SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task
    WHERE ds.sequence_name="CDS_BATCH_CONTENT_SEQ"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Failed to update dm_sequences for sequence CDS_BATCH_CONTENT_SEQ: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Sequences CDS_BATCH_SEQ and CDS_BATCH_CONTENT_SEQ created successfully"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
