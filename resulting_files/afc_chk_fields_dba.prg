CREATE PROGRAM afc_chk_fields:dba
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
  p.seq
  FROM pm_rpt_field p
  WHERE p.field_report_type="A"
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (count <= 0)
  SET request->setup_proc[1].error_msg = "No AFC Fields added..."
  GO TO 2999_process_exit
 ENDIF
 SET request->setup_proc[1].success_ind = 1
#2999_process_exit
#3000_log
 EXECUTE dm_add_upt_setup_proc_log
#3999_log_exit
#9999_end_program
END GO
