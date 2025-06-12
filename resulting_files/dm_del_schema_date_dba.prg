CREATE PROGRAM dm_del_schema_date:dba
 DELETE  FROM dm_index_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_indexes
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_tables
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_cons_columns
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_constraints
  WHERE schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
END GO
