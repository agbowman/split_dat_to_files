CREATE PROGRAM dm_feature_tbl_status_report:dba
 SET env = fillstring(20," ")
 SELECT INTO "nl:"
  de.environment_name
  FROM dm_info di,
   dm_environment de
  WHERE di.info_name="DM_ENV_ID"
   AND di.info_domain="DATA MANAGEMENT"
   AND de.environment_id=di.info_number
  DETAIL
   env = de.environment_name
  WITH nocounter
 ;end select
 SET cnt = 0
 SELECT
  d.feature_number, d.table_name, d.table_env_status
  FROM dm_feature_tables_env d,
   dm_features f
  WHERE d.feature_number=f.feature_number
   AND f.feature_status="2b"
   AND d.environment=env
  ORDER BY d.feature_number, d.table_name, d.schema_dt_tm
  HEAD REPORT
   col 35, "Feature Table Status Report", row + 1
  HEAD PAGE
   var = fillstring(80,"="), col 8, "Feature",
   col 30, "Table Name", col 63,
   "Status", row + 1, var,
   row + 1
  HEAD d.feature_number
   col 0, d.feature_number
  HEAD d.table_name
   col 30, d.table_name, col 65,
   d.table_env_status, row + 1
  DETAIL
   x = 0
  WITH nocounter
 ;end select
END GO
