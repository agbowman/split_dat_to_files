CREATE PROGRAM dm_obs_idx_entity_lock:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script dm_obs_idx_entity_lock..."
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="OBS ENTITY LOCK RDM VER-001"
   WITH nocounter
  ;end select
  IF (curqual=0)
   DECLARE cnt = i4
   SET errmsg = fillstring(132," ")
   SET errcode = 0
   SET cnt = 0
   CALL echo("Running Obsolete Process on a list of Indexes...")
   EXECUTE dm_drop_obsolete_objects "XAK1ENTITY_LOCK", "INDEX", 1
   IF (errcode != 0)
    SET readme_data->message = build("Readme Failed: XIE1SCH_ACTION:",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE dm_drop_obsolete_objects "XAK2ENTITY_LOCK", "INDEX", 1
   IF (errcode != 0)
    SET readme_data->message = build("Readme Failed: XPKSCH_COMMENT:",errmsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = "OBS ENTITY LOCK RDM VER-001", di
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   COMMIT
   SET readme_data->status = "S"
   SET readme_data->message = "Success: All Indexes Dropped Successfully."
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "This version of dm_obs_sch_indexes has already executed successfully"
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
