CREATE PROGRAM dac_fix_rdds_seq_rdm:dba
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
 SET readme_data->message = "Readme Failed: Starting script dac_fix_rdds_seq_rdm..."
 DECLARE setincrement(increment=f8) = i2
 DECLARE refseqval = f8 WITH protect, noconstant(0.0)
 DECLARE fixseqval = f8 WITH protect, noconstant(0.0)
 DECLARE fixinc = f8 WITH protect, noconstant(0.0)
 DECLARE newfixseq = f8 WITH protect, noconstant(0.0)
 DECLARE seqdif = f8 WITH protect, noconstant(0.0)
 DECLARE dfrsr_errmsg = vc WITH protect, noconstant("")
 IF (validate(dfrsr_sequences->fixseq,"N")="N")
  FREE RECORD dfrsr_sequences
  RECORD dfrsr_sequences(
    1 fixseq = vc
    1 refseq = vc
  )
  SET dfrsr_sequences->fixseq = "SCH_DEF_APPLY_SEQ"
  SET dfrsr_sequences->refseq = "SCH_CANDIDATE_SEQ"
 ENDIF
 DECLARE fixseq = vc WITH protect, constant(dfrsr_sequences->fixseq)
 DECLARE refseq = vc WITH protect, constant(dfrsr_sequences->refseq)
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
 IF (fixseqval < refseqval)
  SET seqdif = (refseqval - fixseqval)
  SET seqdif = (seqdif+ 10000)
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
  IF ((newfixseq < (refseqval+ 10000)))
   CALL setincrement(fixinc)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to increase sequence ",dfrsr_sequences->fixseq,".")
   GO TO exit_script
  ENDIF
  IF (setincrement(fixinc)=0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to reset increment value: ",dfrsr_errmsg)
   GO TO exit_script
  ENDIF
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
END GO
