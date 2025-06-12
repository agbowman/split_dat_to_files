CREATE PROGRAM atr_add_app:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET i = size(reply->status_data.subeventstatus,5)
 SUBROUTINE result_status(opname,opstat,targetname,targetvalue)
   SET stat = alter(reply->status_data.subeventstatus[i],i)
   SET reply->status_data.subeventstatus[i].operationname = opname
   SET reply->status_data.subeventstatus[i].operationstatus = opstat
   SET reply->status_data.subeventstatus[i].targetobjectname = targetname
   SET reply->status_data.subeventstatus[i].targetobjectvalue = targetvalue
   SET i += 1
 END ;Subroutine
 IF ((request->feature_number > 0))
  SELECT INTO "nl:"
   a.application_number
   FROM dm_application a
   WHERE (a.application_number=request->application_number)
    AND (a.feature_number=request->feature_number)
   WITH nocounter, forupdate(a)
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_application a
    SET a.application_number = request->application_number, a.owner = request->owner, a.description
      = request->description,
     a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a
     .direct_access_ind = request->direct_access_ind,
     a.application_ini_ind = request->application_ini_ind, a.log_level = request->log_level, a
     .request_log_level = request->request_log_level,
     a.min_version_required = request->min_version_required, a.object_name = request->object_name, a
     .active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE null
     ENDIF
     ,
     a.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , a.last_localized_dt_tm =
     IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
     ELSE null
     ENDIF
     , a.text = request->text,
     a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task, a.updt_id = reqinfo->
     updt_id,
     a.updt_cnt = 0, a.deleted_ind = 0, a.updt_applctx = reqinfo->updt_applctx,
     a.feature_number = request->feature_number, a.schema_date = cnvtdatetimeutc(request->schema_date,
      2), a.disable_cache_ind = request->disable_cache_ind
    WITH nocounter
   ;end insert
  ELSE
   UPDATE  FROM dm_application a
    SET a.application_number = request->application_number, a.owner = request->owner, a.description
      = request->description,
     a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a
     .direct_access_ind = request->direct_access_ind,
     a.application_ini_ind = request->application_ini_ind, a.log_level = request->log_level, a
     .request_log_level = request->request_log_level,
     a.min_version_required = request->min_version_required, a.object_name = request->object_name, a
     .active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE null
     ENDIF
     ,
     a.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , a.last_localized_dt_tm =
     IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
     ELSE null
     ENDIF
     , a.text = request->text,
     a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task, a.updt_id = reqinfo->
     updt_id,
     a.updt_cnt = 0, a.deleted_ind = 0, a.updt_applctx = reqinfo->updt_applctx,
     a.feature_number = request->feature_number, a.schema_date = cnvtdatetimeutc(request->schema_date,
      2), a.disable_cache_ind = request->disable_cache_ind
    WHERE (a.application_number=request->application_number)
     AND (a.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_application","Update failed.")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   a.application_number
   FROM application a
   WHERE (a.application_number=request->application_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL result_status("Insert","D","application","Application already exists.")
   SET reply->status_data.status = "D"
   GO TO exit_script
  ENDIF
  INSERT  FROM application a
   SET a.application_number = request->application_number, a.owner = request->owner, a.description =
    request->description,
    a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a
    .direct_access_ind = request->direct_access_ind,
    a.application_ini_ind = request->application_ini_ind, a.log_level = request->log_level, a
    .request_log_level = request->request_log_level,
    a.min_version_required = request->min_version_required, a.object_name = request->object_name, a
    .active_dt_tm =
    IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
    ELSE null
    ENDIF
    ,
    a.inactive_dt_tm =
    IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
    ELSE null
    ENDIF
    , a.last_localized_dt_tm =
    IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
    ELSE null
    ENDIF
    , a.text = request->text,
    a.disable_cache_ind = request->disable_cache_ind, a.updt_dt_tm = cnvtdatetime(sysdate), a
    .updt_task = reqinfo->updt_task,
    a.updt_id = reqinfo->updt_id, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual > 0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
