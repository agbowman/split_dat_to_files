CREATE PROGRAM dm_ins_env_info:dba
 SET src_environment = fillstring(30," ")
 SELECT INTO "nl:"
  x = logical("ENVIRONMENT")
  FROM dual
  DETAIL
   src_environment = x
  WITH nocounter
 ;end select
 DELETE  FROM dm_info dm
  WHERE dm.info_domain="DATA MANAGEMENT"
   AND dm.info_name="ENVIRONMENT_ID"
 ;end delete
 SET cur_env_id = 0
 SELECT INTO "NL:"
  env.environment_id
  FROM dm_environment env
  WHERE env.environment_name=src_environment
  DETAIL
   cur_env_id = env.environment_id
  WITH nocounter
 ;end select
 INSERT  FROM dm_info dm
  SET dm.info_domain = "DATA MANAGEMENT", dm.info_name = "DM_ENV_ID", dm.info_number = cur_env_id,
   dm.updt_id = 90001, dm.updt_task = 90001, dm.updt_cnt = 0,
   dm.updt_applctx = 90001, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
END GO
