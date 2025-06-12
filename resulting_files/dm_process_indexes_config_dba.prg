CREATE PROGRAM dm_process_indexes_config:dba
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
 SET readme_data->message = "Readme Failed: Starting dm_process_indexes_config script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE dt_parserstmt = vc WITH protect, noconstant("")
 DECLARE cur_date = dq8
 DECLARE domain_name = vc WITH protect, constant("DAS_UNUSED_INDEXES")
 DECLARE default_ddl_time = vc WITH protect, noconstant("")
 DECLARE ignore_action_flag = i4 WITH public, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 SET cur_date = cnvtdatetime(curdate,curtime3)
 FREE RECORD index_info
 RECORD index_info(
   1 list_0[*]
     2 index_name = vc
     2 time_to_live = i4
     2 active_ind = i2
     2 last_updated = dq8
 )
 SET stat = alterlist(index_info->list_0,cnt)
 FOR (i = 1 TO cnt)
   SET index_info->list_0[i].index_name = cnvtupper(requestin->list_0[i].index_name)
   SET index_info->list_0[i].time_to_live = cnvtint(requestin->list_0[i].time_to_live)
   SET index_info->list_0[i].active_ind = cnvtint(requestin->list_0[i].active_ind)
   SET index_info->list_0[i].last_updated = 0
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_info d1
  WHERE d1.info_domain=domain_name
   AND expand(num,1,cnt,d1.info_name,cnvtupper(index_info->list_0[num].index_name))
  HEAD d1.info_name
   pos = locateval(num,1,cnt,d1.info_name,cnvtupper(index_info->list_0[num].index_name))
  DETAIL
   IF (pos > 0)
    index_info->list_0[pos].last_updated = d1.info_date
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get inactive indexes from dm_info ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM v$parameter vp
  PLAN (vp
   WHERE vp.name="ddl_lock_timeout")
  DETAIL
   default_ddl_time = vp.value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get default ddl_lock_timeout value ",errmsg)
  GO TO exit_script
 ENDIF
 CALL parser("rdb ALTER SESSION SET ddl_lock_timeout = 60 go")
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed set the ddl_lock_timeout",errmsg)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO cnt)
  SET ignore_action_flag = 0
  IF ((index_info->list_0[i].active_ind=0))
   IF ((index_info->list_0[i].last_updated > 0))
    IF (cur_date > cnvtlookahead(build('"',index_info->list_0[i].time_to_live,',M"'),index_info->
     list_0[i].last_updated))
     SELECT INTO "nl:"
      FROM user_indexes ui
      WHERE (ui.index_name=index_info->list_0[i].index_name)
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat(
       "Failed to select inactive indexes, passed TTL on user_indexes ",errmsg)
      GO TO exit_script
     ENDIF
     IF (curqual=1)
      SET dt_parserstmt = concat("rdb asis(^ DROP INDEX ",index_info->list_0[i].index_name," ^) go")
      CALL parser(dt_parserstmt)
      IF (error(errmsg,0) != 0)
       IF (findstring("ORA-00054",errmsg) != 0)
        SET ignore_action_flag = 1
       ELSEIF (findstring("ORA-01418",errmsg) != 0)
        SET ignore_action_flag = 0
       ELSE
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop index ",errmsg)
        GO TO exit_script
       ENDIF
      ENDIF
      IF (ignore_action_flag=0)
       SELECT INTO "nl:"
        FROM dba_indexes di
        WHERE (di.index_name=index_info->list_0[i].index_name)
        WITH nocounter
       ;end select
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to select dropped indexes",errmsg)
        GO TO exit_script
       ELSEIF (curqual=0)
        UPDATE  FROM dm_info di
         SET di.info_long_id = 1, di.updt_dt_tm = cnvtdatetime(cur_date), di.updt_applctx = reqinfo->
          updt_applctx,
          di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
          updt_task,
          di.info_char = "DROPPED"
         WHERE (di.info_name=index_info->list_0[i].index_name)
          AND di.info_domain=domain_name
         WITH nocounter
        ;end update
        IF (error(errmsg,0) > 0)
         ROLLBACK
         SET readme_data->status = "F"
         SET readme_data->message = concat("Failed to update dropped indexes on dm_info ",errmsg)
         GO TO exit_script
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM user_indexes ui
      WHERE (ui.index_name=index_info->list_0[i].index_name)
       AND ui.visibility="VISIBLE"
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat(
       "Failed to select inactive indexes, not passed TTL on user_indexes ",errmsg)
      GO TO exit_script
     ENDIF
     IF (curqual=1)
      SET dt_parserstmt = concat("rdb asis(^ ALTER INDEX ",index_info->list_0[i].index_name,
       " INVISIBLE ^) go")
      CALL parser(dt_parserstmt)
      IF (error(errmsg,0) != 0)
       IF (findstring("ORA-00054",errmsg) != 0)
        SET ignore_action_flag = 1
       ELSEIF (findstring("ORA-01418",errmsg) != 0)
        SET ignore_action_flag = 0
       ELSE
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to alter index to invisible",errmsg)
        GO TO exit_script
       ENDIF
      ENDIF
      IF (ignore_action_flag=0)
       SELECT INTO "nl:"
        FROM user_indexes ui
        WHERE (ui.index_name=index_info->list_0[i].index_name)
         AND ui.visibility="INVISIBLE"
        WITH nocounter
       ;end select
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to select invisible indexes",errmsg)
        GO TO exit_script
       ELSEIF (curqual=1)
        UPDATE  FROM dm_info di
         SET di.info_long_id = 0, di.updt_dt_tm = cnvtdatetime(cur_date), di.updt_applctx = reqinfo->
          updt_applctx,
          di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
          updt_task,
          di.info_char = "INVISIBLE"
         WHERE (di.info_name=index_info->list_0[i].index_name)
          AND di.info_domain=domain_name
         WITH nocounter
        ;end update
        IF (error(errmsg,0) > 0)
         ROLLBACK
         SET readme_data->status = "F"
         SET readme_data->message = concat("Failed to update invisible indexes on dm_info ",errmsg)
         GO TO exit_script
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM user_indexes ui
     WHERE (ui.index_name=index_info->list_0[i].index_name)
      AND ui.visibility="VISIBLE"
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to select visible indexes from user_tables ",errmsg)
     GO TO exit_script
    ENDIF
    IF (curqual=1)
     SET dt_parserstmt = concat("rdb asis(^ ALTER INDEX ",index_info->list_0[i].index_name,
      " INVISIBLE ^) go")
     CALL parser(dt_parserstmt)
     IF (error(errmsg,0) != 0)
      IF (findstring("ORA-00054",errmsg) != 0)
       SET ignore_action_flag = 1
      ELSEIF (findstring("ORA-01418",errmsg) != 0)
       SET ignore_action_flag = 0
      ELSE
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to alter index ",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (ignore_action_flag=0)
      SELECT INTO "nl:"
       FROM user_indexes ui
       WHERE (ui.index_name=index_info->list_0[i].index_name)
        AND ui.visibility="INVISIBLE"
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to select invisible indexes from user_indexes",
        errmsg)
       GO TO exit_script
      ELSEIF (curqual=1)
       INSERT  FROM dm_info di
        SET di.info_domain = domain_name, di.info_name = index_info->list_0[i].index_name, di
         .info_date = cnvtdatetime(cur_date),
         di.info_long_id = 0, di.info_number = index_info->list_0[i].time_to_live, di.updt_dt_tm =
         cnvtdatetime(cur_date),
         di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
         di.updt_task = reqinfo->updt_task, di.info_char = "INVISIBLE"
        WITH nocounter
       ;end insert
       IF (error(errmsg,0) > 0)
        ROLLBACK
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to insert missing indexes on dm_info ",errmsg)
        GO TO exit_script
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM user_indexes ui
    WHERE (ui.index_name=index_info->list_0[i].index_name)
     AND ui.visibility="INVISIBLE"
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select visible indexes from user_tables ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=1)
    SET dt_parserstmt = concat("rdb asis(^ ALTER INDEX ",index_info->list_0[i].index_name,
     " VISIBLE ^) go")
    CALL parser(dt_parserstmt)
    IF (error(errmsg,0) != 0)
     IF (findstring("ORA-00054",errmsg) != 0)
      SET ignore_action_flag = 1
     ELSEIF (findstring("ORA-01418",errmsg) != 0)
      SET ignore_action_flag = 0
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to alter index to visible ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
    IF (ignore_action_flag=0)
     SELECT INTO "nl:"
      FROM user_indexes ui
      WHERE (ui.index_name=index_info->list_0[i].index_name)
       AND ui.visibility="VISIBLE"
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to select invisible indexes from user_indexes",errmsg
       )
      GO TO exit_script
     ELSEIF (curqual=1)
      UPDATE  FROM dm_info di
       SET di.info_long_id = 0, di.updt_dt_tm = cnvtdatetime(cur_date), di.updt_applctx = reqinfo->
        updt_applctx,
        di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
        updt_task,
        di.info_char = "VISIBLE"
       WHERE (di.info_name=index_info->list_0[i].index_name)
        AND di.info_domain=domain_name
       WITH nocounter
      ;end update
      IF (error(errmsg,0) > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed alter active indexes on dm_info ",errmsg)
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SET dt_parserstmt = concat("rdb asis(^ ALTER SESSION SET ddl_lock_timeout = ",default_ddl_time,
  " ^) go")
 CALL parser(dt_parserstmt)
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed reset the ddl_lock_timeout",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: dm_load_indexes_to_process.prg script"
#exit_script
 FREE RECORD index_info
END GO
