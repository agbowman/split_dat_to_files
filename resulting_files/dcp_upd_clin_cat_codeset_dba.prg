CREATE PROGRAM dcp_upd_clin_cat_codeset:dba
 UPDATE  FROM code_value_set
  SET display_key_dup_ind = 0
  WHERE code_set=16389
  WITH check
 ;end update
 COMMIT
END GO
