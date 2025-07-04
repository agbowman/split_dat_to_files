CREATE PROGRAM afc_chk_tier_sequences:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_process TO 2999_process_exit
 EXECUTE FROM 3000_log TO 3999_log_exit
 GO TO 9999_end_program
#1000_initialize
 SET request->setup_proc[1].success_ind = 0
#1999_initialize_exit
#2000_process
 SET count = 0
 SELECT INTO "nl:"
  cv.cdf_meaning, cv.collation_seq
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning="CLNTRPTTYPE"
   AND cv.code_set=13036
  DETAIL
   count = cv.collation_seq
  WITH nocounter
 ;end select
 CALL echo(build("count should be 32: ",count))
 IF (count=32)
  SET request->setup_proc[1].error_msg = "No errors ..."
  SET request->setup_proc[1].success_ind = 1
  GO TO 2999_process_exit
 ENDIF
#2999_process_exit
#3000_log
 EXECUTE dm_add_upt_setup_proc_log
#3999_log_exit
#9999_end_program
END GO
