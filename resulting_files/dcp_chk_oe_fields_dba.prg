CREATE PROGRAM dcp_chk_oe_fields:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  o.oe_field_id
  FROM order_entry_fields o
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 33
 IF (nbr_records < 132)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "order_entry_field rows not created correctly."
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
