CREATE PROGRAM cpm_srv_exp_log_request:dba
 DECLARE nextlogid = f8
 SELECT INTO "nl:"
  y = seq(cpmexpedite_log_id,nextval)"##################;rp0"
  FROM dual
  DETAIL
   nextlogid = cnvtreal(y)
  WITH nocounter
 ;end select
 IF ((logrecord->logid > 0))
  UPDATE  FROM expedite_log e
   SET e.next_log_id = nextlogid
   WHERE (e.log_id=logrecord->logid)
   WITH nocounter
  ;end update
 ENDIF
 UPDATE  FROM expedite_log e
  SET e.next_log_id = 0, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.encntr_id = logrecord->
   encntrid,
   e.accession = logrecord->accession, e.event_dt_tm = cnvtdatetime(logrecord->event.dttm), e
   .message_size = logrecord->size,
   e.message = logrecord->message
  WHERE e.log_id=nextlogid
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM expedite_log e
   SET e.log_id = nextlogid, e.next_log_id = 0, e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.encntr_id = logrecord->encntrid, e.accession = logrecord->accession, e.event_dt_tm =
    cnvtdatetime(logrecord->event.dttm),
    e.message_size = logrecord->size, e.message = logrecord->message
   WITH nocounter
  ;end insert
 ENDIF
 SET logrecord->logid = nextlogid
END GO
