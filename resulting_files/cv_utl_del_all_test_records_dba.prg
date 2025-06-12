CREATE PROGRAM cv_utl_del_all_test_records:dba
 DELETE  FROM cv_case_file_row
  WHERE case_dataset_r_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_case_field
  WHERE case_field_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_case_dataset_r
  WHERE case_dataset_r_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_count_data
  WHERE count_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_dev_abstr_data
  WHERE dev_abstr_data_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_device
  WHERE device_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_les_abstr_data
  WHERE lesion_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_lesion
  WHERE lesion_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_proc_abstr_data
  WHERE procedure_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_procedure
  WHERE procedure_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_case_abstr_data
  WHERE cv_case_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM cv_case
  WHERE cv_case_id > 0
  WITH nocounter
 ;end delete
 CALL echo(
  "Enter commit go if you are sure you want to delete non reference records in all cv tables!!")
END GO
