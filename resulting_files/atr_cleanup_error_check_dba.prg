CREATE PROGRAM atr_cleanup_error_check:dba
 SET checkstatus = 9
 SELECT INTO "nl:"
  atr.application_number
  FROM application_task_r atr
  WHERE ((atr.application_number BETWEEN 0 AND 99999) OR (((atr.application_number BETWEEN 200000
   AND 2100000) OR (atr.application_number > 2199999)) ))
  WITH nocounter, maxqual(atr,1)
 ;end select
 IF (curqual=0)
  SET checkstatus = 1
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 SELECT INTO "nl:"
  trr.task_number
  FROM task_request_r trr
  WHERE ((trr.task_number BETWEEN 0 AND 99999) OR (((trr.task_number BETWEEN 200000 AND 2100000) OR (
  trr.task_number > 2199999)) ))
  WITH nocounter, maxqual(trr,1)
 ;end select
 IF (curqual=0)
  IF (checkstatus != 0)
   SET checkstatus = 1
  ENDIF
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 SELECT INTO "nl:"
  rp.request_number
  FROM request_processing rp
  WHERE rp.request_number >= 0
  WITH nocounter, maxqual(rp,1)
 ;end select
 IF (curqual=0)
  IF (checkstatus != 0)
   SET checkstatus = 1
  ENDIF
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 SELECT INTO "nl:"
  a.application_number
  FROM application a
  WHERE ((a.application_number BETWEEN 0 AND 99999) OR (((a.application_number BETWEEN 200000 AND
  2100000) OR (a.application_number > 2199999)) ))
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (curqual=0)
  IF (checkstatus != 0)
   SET checkstatus = 1
  ENDIF
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 SELECT INTO "nl:"
  a.task_number
  FROM application_task a
  WHERE ((a.task_number BETWEEN 0 AND 99999) OR (((a.task_number BETWEEN 200000 AND 2100000) OR (a
  .task_number > 2199999)) ))
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (curqual=0)
  IF (checkstatus != 0)
   SET checkstatus = 1
  ENDIF
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 SELECT INTO "nl:"
  r.request_number
  FROM request r
  WHERE ((r.request_number BETWEEN 0 AND 99999) OR (((r.request_number BETWEEN 200000 AND 2100000)
   OR (r.request_number > 2199999)) ))
  WITH nocounter, maxqual(r,1)
 ;end select
 IF (curqual=0)
  IF (checkstatus != 0)
   SET checkstatus = 1
  ENDIF
 ELSE
  CALL echo("failed..")
  SET checkstatus = 0
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "rows still remain on the table: application_task_r"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
 IF (checkstatus=1)
  CALL echo("success!")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "atr_cleanup_error_check completed successfully"
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo("some errors where found, atr_cleanup check failed..")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "atr_cleanup_error_check completed failed"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
END GO
