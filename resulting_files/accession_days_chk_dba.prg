CREATE PROGRAM accession_days_chk:dba
 SET txt = fillstring(200," ")
 SET success = 1
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
   SET txt = "Accept and Assign future days are zero."
   SET success = 0
  ELSE
   IF (accept_future_days=0)
    SET txt = "Accept future days is zero"
   ELSEIF (assign_future_days=0)
    SET txt = "Assign future days is zero"
   ELSE
    SET txt = "Accept and Assign future days are valued"
   ENDIF
  ENDIF
 ELSE
  SET txt = "ACCESSION_SETUP table not initialized."
 ENDIF
 IF (validate(request,0))
  SET request->setup_proc[1].success_ind = success
  SET request->setup_proc[1].error_msg = txt
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo(build(txt," (status: ",success,")"))
 ENDIF
END GO
