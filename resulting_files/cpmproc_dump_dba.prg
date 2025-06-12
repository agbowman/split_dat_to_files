CREATE PROGRAM cpmproc_dump:dba
 SET trace = callecho
 SET trace flush 1
 DECLARE que_id = i4
 DECLARE que_seq = i4
 DECLARE error_code = i2
 SET que_id = 0
 SET que_seq = 0
 SET error_code = 0
 CALL echo(build("Mode:",options->mode))
 IF ((((options->mode=1)) OR ((options->more_data=1))) )
  SET que_id = options->que_id
  GO TO get_que_id
 ENDIF
 IF ((options->mode=2))
  CALL echo(build("Error Id:",options->error_id))
  SELECT INTO "nl:"
   e.*
   FROM cpmprocess_error e
   WHERE (e.error_id=options->error_id)
   DETAIL
    que_id = e.que_id, que_seq = e.que_seq, error_code = e.error_code,
    errorrecord->recover_seq = e.recover_seq
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Can not find error number")
   GO TO exit_error
  ENDIF
  GO TO get_que_id
 ENDIF
 IF ((options->mode=3))
  SET options->que_id = 0
  SELECT INTO "nl:"
   e.que_id, e.que_seq
   FROM cpmprocess_error e
   WHERE (e.destination_step_id=options->destination_step_id)
    AND e.error_code > 0
    AND (((e.error_code=options->error_code)) OR ((options->error_code=0)))
   DETAIL
    que_id = e.que_id, que_seq = e.que_seq, options->que_id = e.que_id,
    options->error_id = e.error_id, errorrecord->recover_seq = e.recover_seq
   WITH nocounter, maxqual(e,1)
  ;end select
  GO TO get_que_id
 ENDIF
#get_que_id
 CALL echo(build("Getting QueId:",que_id))
 SET options->more_data = 0
 SET options->que_id = 0
 SELECT INTO "nl:"
  q.*
  FROM cpmprocess_que q
  WHERE q.que_id=que_id
   AND ((q.que_seq=que_seq) OR (que_seq=0))
  DETAIL
   IF (q.next_que_id > 0)
    options->more_data = 1, options->que_id = q.next_que_id
   ENDIF
   queuerecord->que_id = q.que_id, queuerecord->message_size = q.message_size, queuerecord->message
    = q.message
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_error
 ENDIF
 CALL echo(build("Size:",queuerecord->message_size))
 CALL echo(build("MoreData:",options->more_data))
 CALL echo(build("NextQueID:",options->que_id))
 GO TO exit_script
#exit_error
 CALL echo("ERROR")
#exit_script
END GO
