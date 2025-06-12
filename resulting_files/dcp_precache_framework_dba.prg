CREATE PROGRAM dcp_precache_framework:dba
 DECLARE execution_script = vc
 DECLARE precache_script = vc
 DECLARE view_prefs_id = f8
 DECLARE precachestart_time = f8
 DECLARE ltjson = vc
 DECLARE view_name = vc
 DECLARE view_seq = i2
 DECLARE default_display_seq = vc
 DECLARE frame_type_in = vc
 RECORD precache_stats(
   1 msecs = i4
   1 script_name = vc
   1 nvp_id = f8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 updt_app = f8
   1 updt_id = f8
   1 position_cd = f8
 )
 IF (logical("pc precache disabled") > " ")
  GO TO exit_script
 ENDIF
 SET precache_script = trim(request->preload_script)
 IF (precache_script="")
  GO TO exit_script
 ENDIF
 CALL echo(build("executing: ",precache_script))
 SET precachestart_time = curtime3
 SET precache_stats->start_dt_tm = cnvtdatetime(curdate,curtime3)
 SET execution_script = concat("execute ",precache_script," go")
 CALL parser(execution_script)
 SET precache_stats->end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET precache_stats->msecs = cnvtint((curtime3 - precachestart_time))
 SET precache_stats->position_cd = reqinfo->position_cd
 SET precache_stats->updt_id = reqinfo->updt_id
 SET precache_stats->updt_app = reqinfo->updt_app
 SET precache_stats->script_name = execution_script
 SET ltjson = cnvtrectojson(precache_stats)
 INSERT  FROM long_text lt
  SET lt.long_text_id = seq(long_data_seq,nextval), lt.parent_entity_name = "PC PRECACHE SCRIPT", lt
   .parent_entity_id = reqinfo->updt_applctx,
   lt.long_text = ltjson, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
   lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
   updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
   lt.updt_applctx = reqinfo->updt_applctx
 ;end insert
 SET curday = datetimepart(cnvtdatetime(curdate,curtime),3)
 IF (((curday=7) OR (curday=21))
  AND curtime > 400
  AND curtime < 1200)
  CALL echo("Purging Records for cache...")
  DELETE  FROM long_text lt
   WHERE lt.parent_entity_name="PC PRECACHE SCRIPT"
    AND lt.updt_dt_tm < cnvtdatetime((curdate - 120),2359)
  ;end delete
 ENDIF
#exit_script
 COMMIT
END GO
