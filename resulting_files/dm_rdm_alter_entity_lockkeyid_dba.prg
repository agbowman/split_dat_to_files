CREATE PROGRAM dm_rdm_alter_entity_lockkeyid:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_alter_entity_lockkeyid..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE seqexists = i2 WITH protect, noconstant(0)
 DECLARE parsestr = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM user_sequences us
  WHERE us.sequence_name="ENTITY_LOCKKEYID"
  DETAIL
   seqexists = 1
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from user_sequences: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (seqexists=0)
  SET readme_data->status = "S"
  SET readme_data->message = "ENTITY_LOCKKEYID doesn't exist, succeeding."
  GO TO exit_script
 ENDIF
 SET parsestr = "rdb alter sequence ENTITY_LOCKKEYID maxvalue 2147483647 cycle go"
 CALL parser(parsestr)
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to alter maxvalue for ENTITY_LOCKKEYID: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_sequences ds
  SET ds.max_value = 2147483647, ds.cycle = "Y", ds.updt_applctx = reqinfo->updt_applctx,
   ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_id = reqinfo->updt_id, ds.updt_task =
   reqinfo->updt_task,
   ds.updt_cnt = (ds.updt_cnt+ 1)
  WHERE ds.sequence_name="ENTITY_LOCKKEYID"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update dm_sequences for ENTITY_LOCKKEYID: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Sequence(s) altered."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
