CREATE PROGRAM cp_chk_def_chart:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SET nbr_records3 = 0
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
  WHERE c.param_type_flag=16
   AND active_ind=1
  WITH nocounter
 ;end select
 SET nbr_records2 = curqual
 CALL echo(build("curqual = ",curqual))
 SELECT DISTINCT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=6
   AND active_ind=1
  HEAD REPORT
   nbr_records3 = 0
  HEAD c.charting_operations_id
   nbr_records3 += 1
  DETAIL
   do_nothing = 0
  WITH nocounter
 ;end select
 CALL echo(build("nbr_records3 = ",nbr_records3))
 IF (nbr_records1=nbr_records2)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "SUCCESSFUL - PARAM_TYPE_FLAG 16 ADDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "FAILED - PARAM_TYPE_FLAG 16 NOT ADDED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
