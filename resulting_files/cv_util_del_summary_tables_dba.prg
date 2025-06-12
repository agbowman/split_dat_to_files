CREATE PROGRAM cv_util_del_summary_tables:dba
 DELETE  FROM cv_les_abstr_data
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_lesion
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_proc_abstr_data
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_procedure
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_case_abstr_data
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_case
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_case_field
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_case_file_row
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_case_dataset_r
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_count_data
  WHERE active_ind > 0
 ;end delete
 CALL echo("Please do a commit to commit changes to the database")
END GO
