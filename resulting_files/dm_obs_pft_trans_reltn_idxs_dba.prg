CREATE PROGRAM dm_obs_pft_trans_reltn_idxs:dba
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
 SET readme_data->message = "Failed to execute obsolete process"
 SET ver_str = "OBS OBJ PFT_TRANS_RELTN 001"
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm_info
   WHERE info_domain="DATA MANAGEMENT"
    AND info_name=ver_str
  ;end select
  IF (curqual=0)
   DECLARE cnt = i4
   SET errmsg = fillstring(132," ")
   SET errcode = 0
   SET cnt = 0
   EXECUTE dm_drop_obsolete_objects "XIE1PFT_TRANS_RELTN", "INDEX", 1
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->message = build("Index Obsoletion Failure: XIE1PFT_TRANS_RELTN:",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE dm_drop_obsolete_objects "XIE2PFT_TRANS_RELTN", "INDEX", 1
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->message = build("Index Obsoletion Failure: XIE2PFT_TRANS_RELTN:",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE dm_drop_obsolete_objects "XIF6PFT_TRANS_RELTN", "INDEX", 1
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->message = build("Index Obsoletion Failure: XIF6PFT_TRANS_RELTN:",errmsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM dm_info
    SET info_domain = "DATA MANAGEMENT", info_name = ver_str, updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->message = build("Error Inserting Version Row to DM_INFO:",errmsg)
    GO TO exit_script
   ENDIF
   SET readme_data->status = "S"
   SET readme_data->message = "Obsolesced Indexes were dropped successfully"
   COMMIT
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message =
   "This version of consolidated obs objs has already executed successfully"
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echo(ver_str)
 CALL echorecord(readme_data)
END GO
