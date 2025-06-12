CREATE PROGRAM dcp_chk_matrix_prefs:dba
 SET nbr_code_values = 0
 SET nbr_alt_sel_folders = 0
 SET nbr_dcp_clin_cats = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=16389
  WITH check
 ;end select
 SET nbr_code_values = (curqual - 2)
 SELECT INTO "nl:"
  a.long_description
  FROM alt_sel_cat a
  WHERE a.long_description="Matrix*"
  WITH check
 ;end select
 SET nbr_alt_sel_folders = curqual
 SELECT INTO "nl:"
  d.dcp_clin_cat_cd
  FROM dcp_clinical_category d
  WHERE d.dcp_clin_cat_cd > 0.0
  WITH check
 ;end select
 SET nbr_dcp_clin_cats = curqual
 SET request->setup_proc[1].process_id = 665
 IF (nbr_alt_sel_folders >= nbr_code_values
  AND nbr_dcp_clin_cats=nbr_code_values)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Alternate selection folders build SUCCEEDED, dcp_clinical_category table build SUCCEEDED"
 ELSEIF (nbr_alt_sel_folders >= nbr_code_values)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Alternate selection folders build SUCCEEDED, dcp_clinical_category table build FAILED"
 ELSEIF (nbr_dcp_clin_cats=nbr_code_values)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Alternate selection folders build FAILED, dcp_clinical_category table build SUCCEEDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Alternate selection folders build FAILED, dcp_clinical_category table build FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
