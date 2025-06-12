CREATE PROGRAM dm_add_sequence:dba
 SET dm_sname = cnvtupper(trim( $1))
 SET dm_min_val = 0.0
 SET dm_min_val =  $2
 SET dm_max_val = 0.0
 SET dm_max_val =  $3
 SET dm_cycle_flg = 0
 SET dm_cycle_flg =  $4
 SET dm_incr_by = 0
 SET dm_incr_by =  $5
 SELECT INTO "nl:"
  FROM user_tab_columns
  WHERE table_name="DM2_USER_SEQUENCES"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_seq_reply->msg = concat(
   "FAILED: sequence can not be created because dm2_user_sequences view does not exist")
  SET dm_seq_reply->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  u.sequence_name
  FROM dm2_user_sequences u
  WHERE u.sequence_name=dm_sname
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF (currdb="ORACLE")
   CALL parser(concat("rdb create sequence ",dm_sname))
   IF (dm_incr_by=0)
    CALL parser("increment by 1")
   ELSE
    CALL parser(concat("increment by ",cnvtstring(dm_incr_by)))
   ENDIF
   IF (dm_min_val > 0)
    CALL parser(concat("minvalue ",cnvtstring(dm_min_val)))
   ENDIF
   IF (dm_max_val > 0)
    CALL parser(concat("maxvalue ",cnvtstring(dm_max_val)))
   ENDIF
   IF (dm_cycle_flg=1)
    CALL parser("cycle")
   ENDIF
   IF (dm_cycle_flg=0
    AND dm_max_val >= 999999999)
    CALL parser("cache 2000")
   ELSE
    CALL parser("cache 20")
   ENDIF
   CALL parser("go")
  ELSEIF (currdb="DB2UDB")
   CALL parser(concat("rdb create sequence ",dm_sname," as bigint"))
   IF (dm_incr_by=0)
    CALL parser("increment by 1")
   ELSE
    CALL parser(concat("increment by ",cnvtstring(dm_incr_by)))
   ENDIF
   IF (dm_min_val > 0)
    CALL parser(concat("minvalue ",cnvtstring(dm_min_val)))
   ENDIF
   IF (dm_max_val > 0)
    CALL parser(concat("maxvalue ",cnvtstring(dm_max_val)))
   ENDIF
   IF (dm_cycle_flg=1)
    CALL parser("cycle")
   ENDIF
   IF (dm_cycle_flg=0
    AND dm_max_val >= 999999999)
    CALL parser("cache 2000")
   ELSE
    CALL parser("cache 20")
   ENDIF
   CALL parser("go")
  ENDIF
  SET dm_errcode = 0
  SET dm_errmsg = fillstring(132," ")
  SET dm_errcode = error(dm_errmsg,0)
  IF (dm_errcode != 0)
   SET dm_seq_reply->msg = concat("Could not create sequence ",dm_sname,": ",dm_errmsg)
   SET dm_seq_reply->status = "F"
  ELSE
   SET dm_seq_reply->status = "S"
   SET dm_seq_reply->msg = "Sequence created successfully."
  ENDIF
 ELSE
  SET dm_seq_reply->status = "S"
  SET dm_seq_reply->msg = "Sequence did not need to be created since it already existed."
 ENDIF
 IF ((dm_seq_reply->status="S"))
  SELECT INTO "nl:"
   FROM dm_sequences ds
   WHERE ds.sequence_name=cnvtupper(dm_sname)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dm_errcode = 0
   SET dm_errmsg = fillstring(132," ")
   INSERT  FROM dm_sequences ds
    (ds.sequence_name, ds.min_value, ds.max_value,
    ds.increment_by, ds.cycle)(SELECT
     d2s.sequence_name, d2s.min_value, d2s.max_value,
     d2s.increment_by, d2s.cycle_flag
     FROM dm2_user_sequences d2s
     WHERE d2s.sequence_name=cnvtupper(dm_sname))
    WITH nocounter
   ;end insert
   SET dm_errcode = error(dm_errmsg,0)
   IF (dm_errcode != 0)
    ROLLBACK
    SET dm_seq_reply->status = "F"
    SET dm_seq_reply->msg = concat("Could not insert sequence ",dm_sname," in dm_sequences table: ",
     dm_errmsg)
   ELSE
    COMMIT
    SET dm_seq_reply->status = "S"
    SET dm_seq_reply->msg = "Sequence recorded in admin successfully."
   ENDIF
  ENDIF
 ENDIF
#exit_script
END GO
