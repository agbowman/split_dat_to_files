CREATE PROGRAM aps_chk_case_spec_type_cleanup:dba
 SELECT INTO "nl:"
  c.case_type_cd
  FROM case_specimen_type_r c
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Case_Specimen_Type_R cleanup successful"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Case_Specimen_Type_R cleanup failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
