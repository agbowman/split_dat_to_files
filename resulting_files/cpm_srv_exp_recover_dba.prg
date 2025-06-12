CREATE PROGRAM cpm_srv_exp_recover:dba
 SELECT INTO "nl:"
  FROM expedite_log e
  WHERE (e.log_id=logrecord->logid)
  DETAIL
   logrecord->encntrid = e.encntr_id, logrecord->accession = e.accession, logrecord->event.dttm = e
   .event_dt_tm,
   logrecord->size = e.message_size, logrecord->message = e.message
  WITH nocounter
 ;end select
END GO
