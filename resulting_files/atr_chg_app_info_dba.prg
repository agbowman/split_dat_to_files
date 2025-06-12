CREATE PROGRAM atr_chg_app_info:dba
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
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET i = size(reply->status_data.subeventstatus,5)
 SUBROUTINE result_status(opname,opstat,targetname,targetvalue)
   SET stat = alter(reply->status_data.subeventstatus[i],i)
   SET reply->status_data.subeventstatus[i].operationname = opname
   SET reply->status_data.subeventstatus[i].operationstatus = opstat
   SET reply->status_data.subeventstatus[i].targetobjectname = targetname
   SET reply->status_data.subeventstatus[i].targetobjectvalue = targetvalue
   SET i += 1
 END ;Subroutine
 IF ((request->feature_number=0))
  SELECT INTO "nl:"
   a.*
   FROM application a
   WHERE (request->application_number=a.application_number)
   DETAIL
    cur_updt_cnt = a.updt_cnt
   WITH nocounter, forupdate(a)
  ;end select
  IF (((curqual=0) OR ((cur_updt_cnt != request->updt_cnt))) )
   GO TO lock_failed
  ENDIF
  UPDATE  FROM application a
   SET a.owner = request->owner, a.object_name = request->object_name, a.description = request->
    description,
    a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a
    .direct_access_ind = request->direct_access_ind,
    a.application_ini_ind = request->application_ini_ind, a.log_level = request->log_level, a
    .request_log_level = request->request_log_level,
    a.min_version_required = request->min_version_required, a.active_dt_tm =
    IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
    ELSE a.active_dt_tm
    ENDIF
    , a.inactive_dt_tm =
    IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
    ELSE a.inactive_dt_tm
    ENDIF
    ,
    a.last_localized_dt_tm =
    IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
    ELSE a.last_localized_dt_tm
    ENDIF
    , a.text = request->text, a.disable_cache_ind = request->disable_cache_ind,
    a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task, a.updt_cnt = (a.updt_cnt
    + 1),
    a.updt_id = reqinfo->updt_id, a.updt_applctx = reqinfo->updt_applctx
   WHERE (a.application_number=request->application_number)
   WITH nocounter
  ;end update
  IF (curqual=0)
   GO TO update_failed
  ENDIF
 ELSE
  SELECT INTO "nl:"
   a.*
   FROM dm_application a
   WHERE (a.application_number=request->application_number)
    AND (a.feature_number=request->feature_number)
   DETAIL
    cur_updt_cnt = a.updt_cnt
   WITH nocounter, forupdate(a)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_application a
    SET a.owner = request->owner, a.object_name = request->object_name, a.description = request->
     description,
     a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a
     .direct_access_ind = request->direct_access_ind,
     a.application_ini_ind = request->application_ini_ind, a.log_level = request->log_level, a
     .request_log_level = request->request_log_level,
     a.min_version_required = request->min_version_required, a.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE a.active_dt_tm
     ENDIF
     , a.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE a.inactive_dt_tm
     ENDIF
     ,
     a.last_localized_dt_tm =
     IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
     ELSE a.last_localized_dt_tm
     ENDIF
     , a.text = request->text, a.updt_dt_tm = cnvtdatetime(sysdate),
     a.updt_task = reqinfo->updt_task, a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id,
     a.updt_applctx = reqinfo->updt_applctx, a.feature_number = request->feature_number, a
     .schema_date = cnvtdatetimeutc(request->schema_date,2),
     a.disable_cache_ind = request->disable_cache_ind
    WHERE (a.application_number=request->application_number)
     AND (a.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_application","Update failed.")
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM dm_application a
    SET a.application_number = request->application_number, a.owner = request->owner, a.object_name
      = request->object_name,
     a.description = request->description, a.active_ind = request->active_ind, a.log_access_ind =
     request->log_access_ind,
     a.direct_access_ind = request->direct_access_ind, a.application_ini_ind = request->
     application_ini_ind, a.log_level = request->log_level,
     a.request_log_level = request->request_log_level, a.min_version_required = request->
     min_version_required, a.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     ,
     a.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
     ENDIF
     , a.last_localized_dt_tm =
     IF ((request->last_localized_dt_tm > 0)) cnvtdatetime(request->last_localized_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , a.text = request->text,
     a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task, a.updt_cnt = 0,
     a.updt_id = reqinfo->updt_id, a.updt_applctx = reqinfo->updt_applctx, a.deleted_ind = 0,
     a.feature_number = request->feature_number, a.schema_date = cnvtdatetimeutc(request->schema_date,
      2), a.disable_cache_ind = request->disable_cache_ind
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_application","Insert failed.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "forupdat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "table"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "application"
 SET failed = "T"
 GO TO exit_script
#update_failed
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "table"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "application"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
