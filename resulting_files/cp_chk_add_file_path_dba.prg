CREATE PROGRAM cp_chk_add_file_path:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SELECT DISTINCT INTO "nl:"
  c.charting_operations_id
  FROM charting_operations c
  WHERE active_ind=1
  ORDER BY c.charting_operations_id
  WITH nocounter
 ;end select
 SET nbr_records1 = curqual
 CALL echo(build("curqual = ",curqual))
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=17
   AND active_ind=1
  WITH nocounter
 ;end select
 SET nbr_records2 = curqual
 CALL echo(build("curqual = ",curqual))
 IF (nbr_records1=nbr_records2)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "SUCCESSFUL - PARAM_TYPE_FLAG 17 ADDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "FAILED - PARAM_TYPE_FLAG 17 NOT ADDED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
