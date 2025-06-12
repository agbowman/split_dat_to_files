CREATE PROGRAM cpmproc_recover
 SET trace = callecho
 SET trace flush 1
 DECLARE que_id = i4
 DECLARE que_seq = i4
 DECLARE error_code = i2
 DECLARE request_number = i4
 SET que_id = 0
 SET que_seq = 0
 SET error_code = 0
 SET request_number = 0
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
    AND e.error_code > 0
   DETAIL
    que_id = e.que_id, que_seq = e.que_seq, error_code = e.error_code,
    request_number = e.request_number, errorrecord->recover_seq = e.recover_seq
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Can not find error number")
   GO TO exit_error
  ENDIF
  UPDATE  FROM cpmprocess_error e
   SET e.retry_attempts = (e.retry_attempts+ 1), e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
    .updt_task = 6051,
    e.original_error_code = error_code, e.error_code = 0, e.updt_cnt = (e.updt_cnt+ 1)
   WHERE (e.error_id=options->error_id)
   WITH nocounter
  ;end update
  COMMIT
  GO TO get_que_id
 ENDIF
 IF ((options->mode=3))
  SET options->que_id = 0
  SELECT INTO "nl:"
   e.que_id, e.que_seq, e.request_number
   FROM cpmprocess_error e
   WHERE (e.destination_step_id=options->destination_step_id)
    AND e.error_code > 0
    AND (((e.error_code=options->error_code)) OR ((options->error_code=0)))
   DETAIL
    que_id = e.que_id, que_seq = e.que_seq, options->que_id = e.que_id,
    options->error_id = e.error_id, errorrecord->recover_seq = e.recover_seq, request_number = e
    .request_number
   WITH nocounter, maxqual(e,1)
  ;end select
  UPDATE  FROM cpmprocess_error e
   SET e.retry_attempts = (e.retry_attempts+ 1), e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
    .updt_task = 6051,
    e.original_error_code = error_code, e.error_code = 0, e.updt_cnt = (e.updt_cnt+ 1)
   WHERE (e.error_id=options->error_id)
   WITH nocounter
  ;end update
  COMMIT
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
    = q.message,
   queuerecord->que_seq_id = que_seq, queuerecord->request_number = request_number
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
