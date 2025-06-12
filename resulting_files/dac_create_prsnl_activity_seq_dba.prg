CREATE PROGRAM dac_create_prsnl_activity_seq:dba
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
 SET readme_data->message = "Readme Failed: Starting script dac_create_prsnl_activity_seq..."
 DECLARE setincrement(increment=f8) = i2
 DECLARE createsequence(sequencename=vc) = null
 DECLARE refseqval = f8 WITH protect, noconstant(0.0)
 DECLARE fixseqval = f8 WITH protect, noconstant(0.0)
 DECLARE fixinc = f8 WITH protect, noconstant(0.0)
 DECLARE newfixseq = f8 WITH protect, noconstant(0.0)
 DECLARE seqdif = f8 WITH protect, noconstant(0.0)
 DECLARE dfrsr_errmsg = vc WITH protect, noconstant("")
 DECLARE seqexists = i2 WITH protect, noconstant(0)
 DECLARE multiplier = f8 WITH protect, constant(1.04)
 IF (validate(dfrsr_sequences->fixseq,"N")="N")
  FREE RECORD dfrsr_sequences
  RECORD dfrsr_sequences(
    1 fixseq = vc
    1 refseq = vc
  )
  SET dfrsr_sequences->fixseq = "PERSON_PRSNL_ACTIVITY_SEQ"
  SET dfrsr_sequences->refseq = "REFERENCE_SEQ"
 ENDIF
 DECLARE fixseq = vc WITH protect, constant(dfrsr_sequences->fixseq)
 DECLARE refseq = vc WITH protect, constant("REFERENCE_SEQ")
 CALL createsequence(fixseq)
 SELECT INTO "nl:"
  seqval = parser(concat("seq(",dfrsr_sequences->fixseq,", nextval)"))
  FROM dual
  DETAIL
   fixseqval = seqval
  WITH nocounter
 ;end select
 IF (error(dfrsr_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get next value from ",dfrsr_sequences->fixseq,": ",
   dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ds.increment_by
  FROM dba_sequences ds
  WHERE parser(concat('sequence_name = "',dfrsr_sequences->fixseq,'"'))
  DETAIL
   fixinc = ds.increment_by
  WITH nocounter
 ;end select
 IF (error(dfrsr_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get increment value from ",dfrsr_sequences->fixseq,
   ": ",dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seqval = parser(concat("seq(",refseq,", nextval)"))
  FROM dual
  DETAIL
   refseqval = seqval
  WITH nocounter
 ;end select
 IF (error(dfrsr_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get next value from ",refseq,": ",dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 SET seqdif = ((refseqval * multiplier) - fixseqval)
 IF (setincrement(seqdif)=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to increase increment value: ",dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seqval = parser(concat("seq(",dfrsr_sequences->fixseq,", nextval)"))
  FROM dual
  DETAIL
   newfixseq = seqval
  WITH nocounter
 ;end select
 IF (error(dfrsr_errmsg,0) != 0)
  CALL setincrement(fixinc)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to increase sequence ",dfrsr_sequences->fixseq,": ",
   dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 IF ((newfixseq=(refseqval * 1.04)))
  CALL setincrement(fixinc)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to increase sequence correctly",dfrsr_sequences->fixseq,
   ".")
  GO TO exit_script
 ENDIF
 IF (setincrement(fixinc)=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to reset increment value: ",dfrsr_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE setincrement(increment)
   CALL parser(concat("rdb asis(^ alter sequence ",dfrsr_sequences->fixseq," increment by ",
     cnvtstring(increment),"^) go"))
   IF (error(dfrsr_errmsg,0) != 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE createsequence(sequencename)
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
    SET readme_data->message = concat("Failed. ",sequencename," - DM_ADD_SEQUENCE: ",dm_seq_reply->
     msg)
    GO TO exit_script
   ENDIF
   CALL parser(concat("rdb alter sequence ",sequencename," cache 2000 go"))
   IF (error(dfrsr_errmsg,0))
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to alter cache for sequence ",sequencename,
     " correctly: ",dfrsr_errmsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM dm_sequences ds
    SET ds.cache = 2000, ds.updt_applctx = reqinfo->updt_applctx, ds.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ds.updt_id = reqinfo->updt_id, ds.updt_task = reqinfo->updt_task, ds.updt_cnt = (ds.updt_cnt+ 1)
    WHERE ds.sequence_name=cnvtupper(sequencename)
     AND ds.cache != 2000
    WITH nocounter
   ;end update
   IF (error(dfrsr_errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update dm_sequences for sequence ",sequencename,": ",
     dfrsr_errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
END GO
