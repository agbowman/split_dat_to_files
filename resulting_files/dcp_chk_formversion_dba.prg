CREATE PROGRAM dcp_chk_formversion:dba
 SET request->setup_proc[1].process_id = 875
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_forms_ref
  WHERE dcp_form_instance_id=null
  WITH nocounter
 ;end select
 SET cnt = (cnt+ curqual)
 SELECT INTO "nl:"
  FROM dcp_forms_def
  WHERE dcp_form_instance_id=null
  WITH nocounter
 ;end select
 SET cnt = (cnt+ curqual)
 SELECT INTO "nl:"
  FROM dcp_section_ref
  WHERE dcp_section_instance_id=null
  WITH nocounter
 ;end select
 SET cnt = (cnt+ curqual)
 SELECT INTO "nl:"
  FROM dcp_input_ref
  WHERE dcp_section_instance_id=null
  WITH nocounter
 ;end select
 SET cnt = (cnt+ curqual)
 IF (cnt > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "One or more new fields did not get initialized properly."
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
