CREATE PROGRAM dm_feature_cs_status_report:dba
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
 SELECT
  d.feature_number, d.code_set, d.code_set_env_status
  FROM dm_feature_code_sets_env d,
   dm_features f
  WHERE d.feature_number=f.feature_number
   AND f.feature_status="2b"
   AND d.environment=env
  ORDER BY d.feature_number, d.code_set, d.schema_dt_tm
  HEAD REPORT
   col 35, "Feature Code Set Status Report", row + 1
  HEAD PAGE
   var = fillstring(80,"="), col 8, "Feature",
   col 35, "Code Set", col 45,
   "Status", row + 1, var,
   row + 1
  HEAD d.feature_number
   col 0, d.feature_number
  HEAD d.code_set
   col 30, d.code_set, col 47,
   d.code_set_env_status, row + 1
  DETAIL
   x = 0
  WITH nocounter
 ;end select
END GO
