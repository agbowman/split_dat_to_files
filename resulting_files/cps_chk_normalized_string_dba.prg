CREATE PROGRAM cps_chk_normalized_string:dba
 SET false = 0
 SET true = 1
 SET failed = false
 SELECT INTO "nl:"
  n.normalized_string_id, n.normalized_string
  FROM normalized_string_index n
  PLAN (n
   WHERE n.normalized_string_id > 0)
  FOOT REPORT
   IF (textlen(n.normalized_string) > textlen(trim(n.normalized_string)))
    failed = false
   ELSE
    failed = true
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(" ")
 IF (curqual=0)
  SET failed = true
 ENDIF
 IF (failed=true)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(
   "FAILURE : Adding a space to the end of the normalized_string   ",format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm;;q"))
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat(
   "SUCCESS : Adding a space to the end of the normalized_string   ",format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm;;q"))
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
