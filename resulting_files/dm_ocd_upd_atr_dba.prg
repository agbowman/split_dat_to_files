CREATE PROGRAM dm_ocd_upd_atr:dba
 SET atr_ocd_number = 0
 IF (validate(ocd_number,0) != 0)
  SET atr_ocd_number = ocd_number
 ELSE
  IF (validate(readme_data->ocd,0) != 0)
   SET atr_ocd_number = readme_data->ocd
  ENDIF
 ENDIF
 IF (atr_ocd_number=0)
  GO TO end_program
 ENDIF
 FREE RECORD atr_info
 RECORD atr_info(
   1 atr_type = vc
   1 atr_number = i4
 )
 SET atr_info->atr_type = cnvtupper( $1)
 SET atr_info->atr_number = cnvtint( $2)
 SET dou_env_id = 0
 CASE (atr_info->atr_type)
  OF "APPLICATION":
  OF "APP":
   CALL echo(" ")
   CALL echo(build("DM_OCD_UPD_ATR: Updating Application (",atr_info->atr_number,")"))
   CALL echo(" ")
   SELECT INTO "nl:"
    FROM dm_ocd_application
    WHERE alpha_feature_nbr=atr_ocd_number
     AND (application_number=atr_info->atr_number)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dou_env_id = di.info_number
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_ocd_application a,
      dm_alpha_features_env e
     WHERE e.environment_id=dou_env_id
      AND a.alpha_feature_nbr=e.alpha_feature_nbr
      AND (a.application_number=atr_info->atr_number)
     ORDER BY a.schema_date
     FOOT REPORT
      atr_ocd_number = a.alpha_feature_nbr
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual != 0)
    FREE RECORD atr
    RECORD atr(
      1 application_number = i4
      1 owner = c20
      1 description = vc
      1 last_localized_dt_tm = dq8
      1 active_ind = i2
      1 active_dt_tm = dq8
      1 inactive_dt_tm = dq8
      1 disable_cache_ind = i2
      1 log_level = i2
      1 request_log_level = i2
      1 min_version_required = vc
      1 log_access_ind = i2
      1 direct_access_ind = i2
      1 application_ini_ind = i2
      1 object_name = vc
      1 text = vc
      1 common_application_ind = i2
      1 feature_number = i4
      1 schema_date = dq8
      1 deleted_ind = i2
    )
    SELECT INTO "nl:"
     FROM dm_ocd_application d
     WHERE d.alpha_feature_nbr=atr_ocd_number
      AND (d.application_number=atr_info->atr_number)
     DETAIL
      atr->application_number = d.application_number, atr->owner = d.owner, atr->description = d
      .description,
      atr->active_dt_tm = d.active_dt_tm, atr->inactive_dt_tm = d.inactive_dt_tm, atr->
      last_localized_dt_tm = d.last_localized_dt_tm,
      atr->active_ind = d.active_ind, atr->log_level = d.log_level, atr->request_log_level = d
      .request_log_level,
      atr->min_version_required = d.min_version_required, atr->log_access_ind = d.log_access_ind, atr
      ->direct_access_ind = d.direct_access_ind,
      atr->application_ini_ind = d.application_ini_ind, atr->object_name = d.object_name, atr->
      disable_cache_ind = d.disable_cache_ind,
      atr->text = d.text, atr->common_application_ind = d.common_application_ind, atr->feature_number
       = d.feature_number,
      atr->schema_date = d.schema_date, atr->deleted_ind = d.deleted_ind
     WITH nocounter
    ;end select
    UPDATE  FROM application a
     SET a.owner = atr->owner, a.description = atr->description, a.log_access_ind = atr->
      log_access_ind,
      a.direct_access_ind = atr->direct_access_ind, a.application_ini_ind = atr->application_ini_ind,
      a.min_version_required = atr->min_version_required,
      a.object_name = atr->object_name, a.last_localized_dt_tm = cnvtdatetime(atr->
       last_localized_dt_tm), a.active_ind = atr->active_ind,
      a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a.inactive_dt_tm =
      IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
      ELSE null
      ENDIF
      , a.disable_cache_ind = atr->disable_cache_ind,
      a.text = atr->text, a.common_application_ind = atr->common_application_ind, a.updt_id = 0.0,
      a.updt_task = 0, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      a.updt_cnt = (a.updt_cnt+ 1)
     WHERE (a.application_number=atr_info->atr_number)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM application a
      SET a.application_number = atr->application_number, a.owner = atr->owner, a.description = atr->
       description,
       a.log_access_ind = atr->log_access_ind, a.direct_access_ind = atr->direct_access_ind, a
       .application_ini_ind = atr->application_ini_ind,
       a.log_level = 0, a.request_log_level = 0, a.min_version_required = atr->min_version_required,
       a.object_name = atr->object_name, a.last_localized_dt_tm = cnvtdatetime(atr->
        last_localized_dt_tm), a.active_ind = atr->active_ind,
       a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a.inactive_dt_tm =
       IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
       ELSE null
       ENDIF
       , a.disable_cache_ind = atr->disable_cache_ind,
       a.text = atr->text, a.common_application_ind = atr->common_application_ind, a.updt_id = 0.0,
       a.updt_task = 0, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       a.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
  OF "TASK":
   CALL echo(" ")
   CALL echo(build("DM_OCD_UPD_ATR: Updating Task (",atr_info->atr_number,")"))
   CALL echo(" ")
   SELECT INTO "nl:"
    FROM dm_ocd_task
    WHERE alpha_feature_nbr=atr_ocd_number
     AND (task_number=atr_info->atr_number)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dou_env_id = di.info_number
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_ocd_task a,
      dm_alpha_features_env e
     WHERE e.environment_id=dou_env_id
      AND a.alpha_feature_nbr=e.alpha_feature_nbr
      AND (a.task_number=atr_info->atr_number)
     ORDER BY a.schema_date
     FOOT REPORT
      atr_ocd_number = a.alpha_feature_nbr
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual != 0)
    FREE RECORD atr
    RECORD atr(
      1 task_number = i4
      1 description = vc
      1 active_ind = i2
      1 active_dt_tm = dq8
      1 inactive_dt_tm = dq8
      1 optional_required_flag = i2
      1 subordinate_task_ind = i2
      1 text = vc
      1 old_task_number = i4
      1 feature_number = i4
      1 schema_date = dq8
      1 deleted_ind = i2
    )
    SELECT INTO "nl:"
     FROM dm_ocd_task d
     WHERE d.alpha_feature_nbr=atr_ocd_number
      AND (d.task_number=atr_info->atr_number)
     DETAIL
      atr->task_number = d.task_number, atr->description = d.description, atr->active_ind = d
      .active_ind,
      atr->active_dt_tm = d.active_dt_tm, atr->inactive_dt_tm = d.inactive_dt_tm, atr->
      optional_required_flag = d.optional_required_flag,
      atr->subordinate_task_ind = d.subordinate_task_ind, atr->text = d.text, atr->old_task_number =
      d.old_task_number,
      atr->feature_number = d.feature_number, atr->schema_date = d.schema_date, atr->deleted_ind = d
      .deleted_ind
     WITH nocounter
    ;end select
    UPDATE  FROM application_task a
     SET a.description = atr->description, a.active_ind = atr->active_ind, a.active_dt_tm =
      cnvtdatetime(atr->active_dt_tm),
      a.inactive_dt_tm =
      IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
      ELSE null
      ENDIF
      , a.optional_required_flag = atr->optional_required_flag, a.subordinate_task_ind = atr->
      subordinate_task_ind,
      a.text = atr->text, a.old_task_number = atr->old_task_number, a.updt_id = 0.0,
      a.updt_task = 0, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      a.updt_cnt = (a.updt_cnt+ 1)
     WHERE (a.task_number=atr_info->atr_number)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM application_task a
      SET a.task_number = atr->task_number, a.description = atr->description, a.active_ind = atr->
       active_ind,
       a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a.inactive_dt_tm =
       IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
       ELSE null
       ENDIF
       , a.optional_required_flag = atr->optional_required_flag,
       a.subordinate_task_ind = atr->subordinate_task_ind, a.text = atr->text, a.old_task_number =
       atr->old_task_number,
       a.updt_id = 0.0, a.updt_task = 0, a.updt_applctx = 0,
       a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
  OF "REQUEST":
  OF "REQ":
   CALL echo(" ")
   CALL echo(build("DM_OCD_UPD_ATR: Updating Request (",atr_info->atr_number,")"))
   CALL echo(" ")
   SELECT INTO "nl:"
    FROM dm_ocd_request
    WHERE alpha_feature_nbr=atr_ocd_number
     AND (request_number=atr_info->atr_number)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dou_env_id = di.info_number
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_ocd_request a,
      dm_alpha_features_env e
     WHERE e.environment_id=dou_env_id
      AND a.alpha_feature_nbr=e.alpha_feature_nbr
      AND (a.request_number=atr_info->atr_number)
     ORDER BY a.schema_date
     FOOT REPORT
      atr_ocd_number = a.alpha_feature_nbr
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual != 0)
    FREE RECORD atr
    RECORD atr(
      1 request_number = i4
      1 description = vc
      1 request_name = c20
      1 cachetime = i4
      1 epilog_script = c30
      1 prolog_script = c30
      1 write_to_que_ind = i2
      1 text = vc
      1 active_ind = i2
      1 active_dt_tm = dq8
      1 inactive_dt_tm = dq8
      1 feature_number = i4
      1 schema_date = dq8
      1 deleted_ind = i2
      1 cachegrace = i4
      1 cachestale = i4
      1 cachetrim = c20
      1 requestclass = i4
    )
    SELECT INTO "nl:"
     FROM dm_ocd_request d
     WHERE d.alpha_feature_nbr=atr_ocd_number
      AND (d.request_number=atr_info->atr_number)
     DETAIL
      atr->request_number = d.request_number, atr->description = d.description, atr->request_name = d
      .request_name,
      atr->cachetime = d.cachetime, atr->cachegrace = d.cachegrace, atr->cachestale = d.cachestale,
      atr->cachetrim = d.cachetrim, atr->requestclass = d.requestclass, atr->epilog_script = d
      .epilog_script,
      atr->prolog_script = d.prolog_script, atr->write_to_que_ind = d.write_to_que_ind, atr->text = d
      .text,
      atr->active_ind = d.active_ind, atr->active_dt_tm = d.active_dt_tm, atr->inactive_dt_tm = d
      .inactive_dt_tm,
      atr->feature_number = d.feature_number, atr->schema_date = d.schema_date, atr->deleted_ind = d
      .deleted_ind
     WITH nocounter
    ;end select
    SET new_cache_col_ind = 0
    SELECT INTO "nl:"
     FROM user_tab_columns u
     WHERE u.table_name="REQUEST"
      AND u.column_name IN ("CACHEGRACE", "CACHESTALE", "CACHETRIM")
     WITH nocounter
    ;end select
    IF (curqual=3)
     SET new_cache_col_ind = 1
    ENDIF
    IF (new_cache_col_ind=1)
     UPDATE  FROM request a
      SET a.description = atr->description, a.text = atr->text, a.request_name = atr->request_name,
       a.cachetime = atr->cachetime, a.cachegrace = atr->cachegrace, a.cachestale = atr->cachestale,
       a.cachetrim = atr->cachetrim, a.requestclass = atr->requestclass, a.epilog_script = atr->
       epilog_script,
       a.prolog_script = atr->prolog_script, a.write_to_que_ind = atr->write_to_que_ind, a.active_ind
        = atr->active_ind,
       a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a.inactive_dt_tm =
       IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
       ELSE null
       ENDIF
       , a.updt_id = 0.0,
       a.updt_task = 0, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       a.updt_cnt = (a.updt_cnt+ 1)
      WHERE (a.request_number=atr_info->atr_number)
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM request a
       SET a.request_number = atr->request_number, a.description = atr->description, a.text = atr->
        text,
        a.request_name = atr->request_name, a.cachetime = atr->cachetime, a.cachegrace = atr->
        cachegrace,
        a.cachestale = atr->cachestale, a.cachetrim = atr->cachetrim, a.requestclass = atr->
        requestclass,
        a.epilog_script = atr->epilog_script, a.prolog_script = atr->prolog_script, a
        .write_to_que_ind = atr->write_to_que_ind,
        a.active_ind = atr->active_ind, a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a
        .inactive_dt_tm =
        IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
        ELSE null
        ENDIF
        ,
        a.updt_id = 0.0, a.updt_task = 0, a.updt_applctx = 0,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ELSE
     UPDATE  FROM request a
      SET a.description = atr->description, a.text = atr->text, a.request_name = atr->request_name,
       a.cachetime = atr->cachetime, a.requestclass = atr->requestclass, a.epilog_script = atr->
       epilog_script,
       a.prolog_script = atr->prolog_script, a.write_to_que_ind = atr->write_to_que_ind, a.active_ind
        = atr->active_ind,
       a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a.inactive_dt_tm =
       IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
       ELSE null
       ENDIF
       , a.updt_id = 0.0,
       a.updt_task = 0, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       a.updt_cnt = (a.updt_cnt+ 1)
      WHERE (a.request_number=atr_info->atr_number)
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM request a
       SET a.request_number = atr->request_number, a.description = atr->description, a.text = atr->
        text,
        a.request_name = atr->request_name, a.cachetime = atr->cachetime, a.requestclass = atr->
        requestclass,
        a.epilog_script = atr->epilog_script, a.prolog_script = atr->prolog_script, a
        .write_to_que_ind = atr->write_to_que_ind,
        a.active_ind = atr->active_ind, a.active_dt_tm = cnvtdatetime(atr->active_dt_tm), a
        .inactive_dt_tm =
        IF ((atr->inactive_dt_tm > 0)) cnvtdatetime(atr->inactive_dt_tm)
        ELSE null
        ENDIF
        ,
        a.updt_id = 0.0, a.updt_task = 0, a.updt_applctx = 0,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL echo("***")
   CALL echo(build("DM_OCD_UPD_ATR: Invalid ATR type specified (",atr_info->atr_type,")"))
   CALL echo(build("ATR number (",atr_info->atr_number,") not updated!"))
   CALL echo("***")
 ENDCASE
 COMMIT
#end_program
#end_script
END GO
