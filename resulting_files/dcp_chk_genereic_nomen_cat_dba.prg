CREATE PROGRAM dcp_chk_genereic_nomen_cat:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  FROM dcp_nomencategory
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 526
 IF (nbr_records != 11)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "DCP Nomnclature categories have not been built succesfully."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "DCP Nomnclature categories have been built succesfully."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
