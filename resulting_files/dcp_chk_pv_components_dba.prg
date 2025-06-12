CREATE PROGRAM dcp_chk_pv_components:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6020
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 29
 IF (nbr_records < 200)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "pv_component rows not created correctly."
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
