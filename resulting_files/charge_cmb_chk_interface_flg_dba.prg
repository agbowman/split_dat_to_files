CREATE PROGRAM charge_cmb_chk_interface_flg:dba
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
  di.info_domain
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="COMBINE INTERFACE FLAG"
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (count > 0)
  SET request->setup_proc[1].error_msg = "No errors ..."
  SET request->setup_proc[1].success_ind = 1
  GO TO 2999_process_exit
 ELSE
  SET request->setup_proc[1].error_msg = "Error - charge_cmb_add_interface_flg didn't work"
  GO TO 2999_process_exit
 ENDIF
#2999_process_exit
#3000_log
 EXECUTE dm_add_upt_setup_proc_log
#3999_log_exit
#9999_end_program
END GO
