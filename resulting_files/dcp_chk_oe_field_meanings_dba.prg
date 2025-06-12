CREATE PROGRAM dcp_chk_oe_field_meanings:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  o.oe_field_meaning_id
  FROM oe_field_meaning o
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 32
 IF (nbr_records < 120)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "oe field meanings not created properly. "
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
