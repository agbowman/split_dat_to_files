CREATE PROGRAM dm_rdm_alter_entity_lock_seq:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_alter_entity_lock_seq..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE seqexists = i2 WITH protect, noconstant(0)
 DECLARE parsestr = vc WITH protect, noconstant("")
 DECLARE currentmaxvalue = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM user_sequences us
  WHERE us.sequence_name="ENTITY_LOCK_SEQ"
  DETAIL
   seqexists = 1, currentmaxvalue = us.max_value
  WITH nocounter
 ;end select
 IF (seqexists=0)
  SET readme_data->status = "S"
  SET readme_data->message = "ENTITY_LOCK_SEQ doesn't exist, succeeding."
  GO TO exit_script
 ENDIF
 IF (currentmaxvalue >= 10000)
  SET readme_data->status = "S"
  SET readme_data->message = concat("ENTITY_LOCK_SEQ is at a MAXVALUE of ",build(currentmaxvalue),
   " and does not need to be altered")
  GO TO exit_script
 ENDIF
 SET parsestr = "rdb alter sequence ENTITY_LOCK_SEQ maxvalue 10000 go"
 CALL parser(parsestr)
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter maxvalue for ENTITY_LOCK_SEQ: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_sequences ds
  SET ds.max_value = 10000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task, ds.updt_cnt = (ds.updt_cnt+ 1)
  WHERE ds.sequence_name="ENTITY_LOCK_SEQ"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update dm_sequences for ENTITY_LOCK_SEQ: ",errmsg)
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
