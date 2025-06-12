CREATE PROGRAM dm_admin_dm_cleanup:dba
 DELETE  FROM dm_index_columns a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_columns a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_indexes a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_tables a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_cons_columns a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_constraints a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value_extension a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value_alias a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_set_extension a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_common_data_foundation a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_code_value_set a
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_schema_version b
   WHERE b.schema_date=a.schema_date)))
  WITH nocounter
 ;end delete
 COMMIT
END GO
