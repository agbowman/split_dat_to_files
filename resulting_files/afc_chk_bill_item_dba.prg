CREATE PROGRAM afc_chk_bill_item:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_process TO 2999_process_exit
 EXECUTE FROM 3000_log TO 3999_log_exit
 GO TO 9999_end_program
#1000_initialize
 SET request->setup_proc[1].success_ind = 0
#1999_initialize_exit
#2000_process
 SET count = 0
 SET task_cat_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="TASKCAT"
   AND cv.active_ind=1
  DETAIL
   task_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE b.ext_child_entity_name="ORDER_TASK"
   AND b.ext_child_contributor_cd=task_cat_cd
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (count=count)
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
