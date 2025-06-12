CREATE PROGRAM charge_cmb_readme_error_check:dba
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
  dm.*
  FROM dm_cmb_exception dm
  WHERE dm.child_entity="CHARGE*"
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (count < 6)
  SET request->setup_proc[1].error_msg = "Error - import of charge.csv failed"
  SET request->setup_proc[1].success_ind = 0
  GO TO 2999_process_exit
 ELSE
  SET request->setup_proc[1].error_msg = "No Errors . . ."
  SET request->setup_proc[1].success_ind = 1
  GO TO 2999_process_exit
 ENDIF
#2999_process_exit
#3000_log
 EXECUTE dm_add_upt_setup_proc_log
#3999_log_exit
#9999_end_program
END GO
