CREATE PROGRAM dm_ocd_set_env:dba
 SET dm_env_id = 0.0
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=cnvtupper(request->output_dist)
  DETAIL
   dm_env_id = e.environment_id
  WITH nocounter
 ;end select
 IF (curqual=1)
  UPDATE  FROM dm_info
   SET info_number = dm_env_id, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = (updt_cnt+ 1),
    updt_task = reqinfo->updt_task, updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx
   WHERE info_name="DM_ENV_ID"
    AND info_domain="DATA MANAGEMENT"
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_name = "DM_ENV_ID", info_domain = "DATA MANAGEMENT", info_number = dm_env_id,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   COMMIT
   SET reply->status_data.status = "S"
   SET reply->ops_event = " "
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Could not update or insert into dm_info"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
   SET reply->ops_event = " "
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET errstr = concat("Could not find environment name ",request->output_dist,
   " in dm_environment.  Select another name.")
  SET reply->ops_event = errstr
 ENDIF
#end_program
END GO
