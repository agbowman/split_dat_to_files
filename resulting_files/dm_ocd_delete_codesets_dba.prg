CREATE PROGRAM dm_ocd_delete_codesets:dba
 DELETE  FROM dm_afd_code_value_set
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value_alias
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_value_extension
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_code_set_extension
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_common_data_foundation
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 COMMIT
END GO
