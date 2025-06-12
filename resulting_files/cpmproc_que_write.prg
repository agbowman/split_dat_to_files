CREATE PROGRAM cpmproc_que_write
 SET queuerecord->write_status = 1
 DECLARE que_id = i4
 SET que_id = 0
 SELECT INTO "nl:"
  quetemp = seq(cpmprocess_que_id,nextval)"##################;rp0"
  FROM dual
  DETAIL
   que_id = quetemp
  WITH format, nocounter
 ;end select
 IF ((queuerecord->que_id=0))
  SELECT INTO "nl:"
   quetemp = seq(cpmprocess_que_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    queuerecord->que_seq_id = quetemp
   WITH format, nocounter
  ;end select
 ELSE
  CALL echo(build("Write continuation queId:",queuerecord->que_id))
  UPDATE  FROM cpmprocess_que p
   SET p.next_que_id = que_id
   WHERE (p.que_id=queuerecord->que_id)
   WITH nocounter
  ;end update
 ENDIF
 CALL echo(build("writing que_id:",que_id," request nbr: ",queuerecord->request_number))
 CALL echo(build("que_seq_id: ",queuerecord->que_seq_id))
 UPDATE  FROM cpmprocess_que p
  SET p.que_id = que_id, p.que_seq = queuerecord->que_seq_id, p.next_que_id = 0,
   p.request_number = queuerecord->request_number, p.message_size = queuerecord->message_size, p
   .message = queuerecord->message,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE p.que_id=que_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM cpmprocess_que p
   SET p.que_id = que_id, p.que_seq = queuerecord->que_seq_id, p.next_que_id = 0,
    p.request_number = queuerecord->request_number, p.message_size = queuerecord->message_size, p
    .message = queuerecord->message,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (curqual != 0)
   SET queuerecord->write_status = 0
  ENDIF
 ELSE
  SET queuerecord->write_status = 0
 ENDIF
 SET queuerecord->que_id = que_id
 CALL echo(build("QueueRecord->que_id:",queuerecord->que_id))
 CALL echo(build("write status:",queuerecord->write_status))
 COMMIT
END GO
