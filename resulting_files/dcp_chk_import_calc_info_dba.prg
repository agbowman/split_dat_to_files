CREATE PROGRAM dcp_chk_import_calc_info:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  d.dcp_equation_id
  FROM dcp_equation
  WHERE dcp_equation_id > 0.0
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 482
 IF (nbr_records=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "All of the equations have not been defined."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "All of the equations have been defined."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
