CREATE PROGRAM cpmproc_error_write
 DECLARE errid = i4
 DECLARE recover_cnt = i2
 SET errid = 0
 SET recover_cnt = 0
 IF ((errorrecord->error_id > 0))
  SELECT INTO "nl:"
   e.retry_attempts
   FROM cpmprocess_error e
   WHERE (e.error_id=errorrecord->error_id)
   DETAIL
    recover_cnt = (e.retry_attempts+ 1)
   WITH nocounter
  ;end select
 ENDIF
 SET errorrecord->write_status = 1
 SELECT INTO "nl:"
  errtemp = seq(cpmprocess_error_id,nextval)"##################;rp0"
  FROM dual
  DETAIL
   errid = errtemp
  WITH format, nocounter
 ;end select
 CALL echo(build("writing errId:",errid,", request nbr: ",errorrecord->request_number,
   ", error code: ",
   errorrecord->error_code))
 UPDATE  FROM cpmprocess_error p
  SET p.error_id = errid, p.que_id = errorrecord->que_id, p.que_seq = errorrecord->que_seq_id,
   p.request_number = errorrecord->request_number, p.destination_step_id = errorrecord->
   destination_step_id, p.target_request_number = errorrecord->target_request_number,
   p.format_script = errorrecord->format_script, p.service = errorrecord->service, p.error_code =
   errorrecord->error_code,
   p.srvexec_status = errorrecord->srvexec_status, p.recover_seq = errorrecord->recover_seq, p
   .retry_attempts = recover_cnt,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task = reqinfo->updt_app, p.updt_applctx =
   reqinfo->updt_applctx,
   p.updt_id = reqinfo->updt_id, p.updt_cnt = 0
  WHERE p.error_id=errid
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM cpmprocess_error p
   SET p.error_id = errid, p.que_id = errorrecord->que_id, p.que_seq = errorrecord->que_seq_id,
    p.request_number = errorrecord->request_number, p.destination_step_id = errorrecord->
    destination_step_id, p.target_request_number = errorrecord->target_request_number,
    p.format_script = errorrecord->format_script, p.service = errorrecord->service, p.error_code =
    errorrecord->error_code,
    p.srvexec_status = errorrecord->srvexec_status, p.recover_seq = errorrecord->recover_seq, p
    .retry_attempts = recover_cnt,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task = reqinfo->updt_app, p.updt_applctx =
    reqinfo->updt_applctx,
    p.updt_id = reqinfo->updt_id, p.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual != 0)
   SET errorrecord->write_status = 0
  ENDIF
 ELSE
  SET errorrecord->write_status = 0
 ENDIF
#exit_script
 CALL echo(build("write status:",errorrecord->write_status))
 COMMIT
END GO
