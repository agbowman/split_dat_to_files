CREATE PROGRAM cv_util_sel_summary_tables:dba
 SELECT
  *
  FROM cv_case
 ;end select
 SELECT
  *
  FROM cv_case_abstr_data
 ;end select
 SELECT
  *
  FROM cv_procedure
 ;end select
 SELECT
  *
  FROM cv_proc_abstr_data
 ;end select
 SELECT
  *
  FROM cv_lesion
 ;end select
 SELECT
  *
  FROM cv_les_abstr_data
 ;end select
 SELECT
  *
  FROM cv_count_data
 ;end select
END GO
