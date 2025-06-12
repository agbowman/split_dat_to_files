CREATE PROGRAM accession_days:dba
 SET accession_setup_id = 0.0
 SET accept_future_days = 0
 SET assign_future_days = 0
 SELECT INTO "nl:"
  a.accession_setup_id
  FROM accession_setup a
  WHERE a.accession_setup_id=72696
  DETAIL
   accession_setup_id = a.accession_setup_id, accept_future_days = a.accept_future_days,
   assign_future_days = a.assign_future_days
  WITH nocounter
 ;end select
 IF (accession_setup_id > 0)
  IF (accept_future_days=0
   AND assign_future_days=0)
   UPDATE  FROM accession_setup a
    SET a.accept_future_days = 30, a.assign_future_days = 1825, a.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     a.updt_id = 0, a.updt_task = 0, a.updt_applctx = 0,
     a.updt_cnt = (a.updt_cnt+ 1)
    WHERE a.accession_setup_id=72696
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
 ENDIF
END GO
