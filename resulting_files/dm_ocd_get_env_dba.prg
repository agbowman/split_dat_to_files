CREATE PROGRAM dm_ocd_get_env:dba
 SET dm_env_id = 0.0
 SET dm_env_name = fillstring(30," ")
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i,
   dm_environment e
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
  DETAIL
   dm_env_id = i.info_number, dm_env_name = e.environment_name
  WITH nocounter
 ;end select
 IF (dm_env_id != 0)
  SET reply->status_data.status = "S"
  SET reply->ops_event = dm_env_name
 ELSE
  SELECT INTO "nl:"
   e.environment_id
   FROM dm_environment e,
    v$database v
   WHERE e.database_name=v.name
   DETAIL
    dm_env_name = e.environment_name, dm_env_id = e.environment_id
   WITH nocounter
  ;end select
  IF (dm_env_id != 0
   AND curqual=1)
   SET reply->status_data.status = "Z"
   SET reply->ops_event = dm_env_name
  ELSE
   SET reply->status_data.status = "D"
   SET reply->ops_event = " "
  ENDIF
 ENDIF
 SET dm_cnt = 0
 SELECT INTO "nl:"
  e.environment_name
  FROM dm_environment e
  ORDER BY e.environment_name
  DETAIL
   dm_cnt = (dm_cnt+ 1), stat = alter(reply->status_data.subeventstatus,dm_cnt), reply->status_data.
   subeventstatus[dm_cnt].operationname = "env",
   reply->status_data.subeventstatus[dm_cnt].targetobjectname = e.environment_name
  WITH nocounter
 ;end select
#end_program
END GO
