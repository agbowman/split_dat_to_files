CREATE PROGRAM cv_utl_del_ref_tables
 DELETE  FROM cv_xref_validation
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_response
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_xref_field
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_dataset_file
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_xref
  WHERE active_ind > 0
 ;end delete
 DELETE  FROM cv_dataset
  WHERE active_ind > 0
 ;end delete
 CALL echo("Please remember to commit your changes")
END GO
