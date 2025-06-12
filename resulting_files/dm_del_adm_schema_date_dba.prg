CREATE PROGRAM dm_del_adm_schema_date:dba
 DELETE  FROM dm_adm_index_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_adm_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_adm_indexes
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_adm_tables
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_adm_cons_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_adm_constraints
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
END GO
