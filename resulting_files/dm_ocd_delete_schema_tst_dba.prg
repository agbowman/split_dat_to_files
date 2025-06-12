CREATE PROGRAM dm_ocd_delete_schema_tst:dba
 DELETE  FROM dm_afd_tables
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_constraints
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_cons_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_indexes
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_index_columns
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 COMMIT
END GO
