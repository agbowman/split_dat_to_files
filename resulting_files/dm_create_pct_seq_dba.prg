CREATE PROGRAM dm_create_pct_seq:dba
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
 SET readme_data->message = "Readme failed: starting script dm_create_pct_seq..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE seqexists = i2 WITH protect, noconstant(0)
 DECLARE sequencename = vc WITH protect, noconstant("PCT_SEQ")
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name=cnvtupper(sequencename)
  DETAIL
   seqexists = 1
  WITH nocounter
 ;end select
 IF (seqexists=1)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: sequence ",sequencename," already exists.")
  GO TO exit_script
 ENDIF
 EXECUTE dm_add_sequence value(sequencename), 0, 0,
 0, 0
 IF ((dm_seq_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed. ",sequencename," - DM_ADD_SEQUENCE: ",dm_seq_reply->msg)
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb alter sequence ",sequencename," cache 2000 go"))
 IF (error(errmsg,0))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter cache for sequence ",sequencename," correctly: ",
   errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_sequences ds
  SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task
  WHERE ds.sequence_name=cnvtupper(sequencename)
   AND ds.cache != 2000
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update dm_sequences for sequence ",sequencename,": ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Sequence(s) added."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
