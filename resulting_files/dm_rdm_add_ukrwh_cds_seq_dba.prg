CREATE PROGRAM dm_rdm_add_ukrwh_cds_seq:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_add_ukrwh_cds_seq..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE seqexists = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dba_sequences d
  WHERE d.sequence_name="UKRWH_CDS_SEQ"
  DETAIL
   seqexists = 1
  WITH nocounter
 ;end select
 IF (seqexists=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Sequence UKRWH_CDS_SEQ already exists."
  GO TO exit_script
 ENDIF
 EXECUTE dm_add_sequence "UKRWH_CDS_SEQ", 0, 0,
 0, 0
 SET readme_data->status = dm_seq_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = concat("Failed. UKRWH_CDS_SEQ - DM_ADD_SEQUENCE: ",dm_seq_reply->msg)
  GO TO exit_script
 ENDIF
 SET parsestr = "rdb alter sequence UKRWH_CDS_SEQ cache 2000 go"
 CALL parser(parsestr)
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to alter cache for sequence <insert sequence name here> correctly: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_sequences ds
  SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task
  WHERE ds.sequence_name="UKRWH_CDS_SEQ"
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to update dm_sequences for sequence <insert sequence name here>: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->message = "Success: Sequence(s) added."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
