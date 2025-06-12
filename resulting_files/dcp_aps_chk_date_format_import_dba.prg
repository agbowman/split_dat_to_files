CREATE PROGRAM dcp_aps_chk_date_format_import:dba
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_group cvg
  PLAN (cvg
   WHERE cvg.code_set=6023.00)
   JOIN (cv1
   WHERE cv1.code_value=cvg.parent_code_value)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Date format import failed"
  GO TO exit_script
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Date format import successful"
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
