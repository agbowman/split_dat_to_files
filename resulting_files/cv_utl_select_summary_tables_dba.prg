CREATE PROGRAM cv_utl_select_summary_tables:dba
 SELECT
  *
  FROM cv_case
  WHERE cv_case_id > 0
  ORDER BY beg_effective_dt_tm
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_case_abstr_data
  WHERE cv_case_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_procedure
  WHERE procedure_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_proc_abstr_data
  WHERE procedure_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_lesion
  WHERE lesion_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_les_abstr_data
  WHERE lesion_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_case_dataset_r
  WHERE case_dataset_r_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_case_field
  WHERE case_field_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_case_file_row
  WHERE case_dataset_r_id > 0
  WITH nocounter
 ;end select
 SELECT
  *
  FROM long_text
  WHERE parent_entity_name="CV_CASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM cv_count_data
  WHERE count_id > 0
  WITH nocounter
 ;end select
END GO
