CREATE PROGRAM dm_set_sequence:dba
 SET st_sname = cnvtupper(trim( $1))
 SET st_min_val = 0.0
 SET st_min_val =  $2
 SET st_max_val = 0.0
 SET st_max_val =  $3
 SET st_cycle_flg = 0
 SET st_cycle_flg =  $4
 SET st_incr_by = 0
 SET st_incr_by =  $5
 IF (st_incr_by=0)
  SET st_incr_by = 1
 ENDIF
 SET incr_amount = 0
 SET call_parser_string = fillstring(132," ")
 SET st_abort_cnt = 0
 SELECT
  IF (currdb="ORACLE")
   FROM user_sequences u
  ELSE
   FROM dm2_user_sequences u
  ENDIF
  INTO "nl:"
  u.sequence_name
  WHERE u.sequence_name=st_sname
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dcs_next_v = 0.0
  SET dcs_curr_v = 0.0
  SELECT INTO "nl:"
   dcs = parser(build("seq(",st_sname,", nextval)"))
   FROM dual
   DETAIL
    dcs_next_v = dcs
   WITH nocounter
  ;end select
  WHILE (dcs_next_v < st_min_val
   AND st_abort_cnt < 3)
    SET incr_amount = ((st_min_val - dcs_next_v)+ 1)
    SET call_parser_string = concat("rdb alter sequence ",st_sname," increment by ",cnvtstring(
      incr_amount)," go")
    CALL echo(call_parser_string)
    CALL parser(call_parser_string)
    IF (currdb != "ORACLE")
     COMMIT
    ENDIF
    SET st_abort_cnt = (st_abort_cnt+ 1)
    SELECT INTO "nl:"
     dnv = parser(build("seq(",st_sname,", nextval)"))
     FROM dual
     DETAIL
      dcs_next_v = dnv
     WITH nocounter
    ;end select
  ENDWHILE
  SET call_parser_string = concat("rdb alter sequence ",st_sname," increment by ",cnvtstring(
    st_incr_by)," go")
  CALL echo(call_parser_string)
  CALL parser(call_parser_string)
  IF (currdb != "ORACLE")
   COMMIT
  ENDIF
  IF (dcs_next_v >= st_min_val)
   SET dm_seq_reply->status = "S"
   SET dm_seq_reply->msg = "Sequence populated successfully."
  ELSE
   SET dm_seq_reply->msg = concat("Could not populate sequence ",st_sname)
   SET dm_seq_reply->status = "F"
   GO TO exit_program
  ENDIF
 ENDIF
 EXECUTE dm_add_sequence st_sname, st_min_val, st_max_val,
 st_cycle_flg, st_incr_by
#exit_program
END GO
