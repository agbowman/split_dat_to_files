CREATE PROGRAM dm_export_adm_factory:dba
 SELECT INTO "dm_feature_code_sets.csv"
  str_data = build(a.feature_number,",",format(a.code_set,"#######"),",",a.environment,
   ",",a.code_set_env_status)
  FROM dm_features b,
   dm_feature_code_sets_env a
  PLAN (a)
   JOIN (b
   WHERE b.feature_number=a.feature_number
    AND b.feature_status != "5 "
    AND b.feature_status >= "2B")
  ORDER BY a.feature_number, a.code_set, a.environment,
   a.schema_dt_tm
  HEAD REPORT
   "feature_number,code_set,environment,code_set_env_status"
  HEAD a.feature_number
   x = 0
  HEAD a.code_set
   x = 0
  HEAD a.environment
   row + 1, col 0, str_data
  HEAD a.schema_dt_tm
   x = 0
  DETAIL
   x = 0
  WITH nocounter, maxcol = 132, maxrow = 1,
   noformfeed, noformat, noheading
 ;end select
 SELECT INTO "dm_feature_tables.csv"
  str2_data = build(a.feature_number,",",a.table_name,",",a.environment,
   ",",a.table_env_status)
  FROM dm_features b,
   dm_feature_tables_env a
  PLAN (a)
   JOIN (b
   WHERE b.feature_number=a.feature_number
    AND b.feature_status != "5 "
    AND b.feature_status >= "2B")
  HEAD REPORT
   "feature_number,table_name,environment,table_build_status"
  HEAD a.feature_number
   x = 0
  HEAD a.table_name
   x = 0
  HEAD a.environment
   row + 1, col 0, str2_data
  HEAD a.schema_dt_tm
   x = 0
  DETAIL
   x = 0
  WITH nocounter, maxcol = 132, maxrow = 1,
   noformfeed, noformat, noheading
 ;end select
END GO
