CREATE PROGRAM atr_add_task:dba
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
 IF ((request->feature_number=0))
  SELECT INTO "nl:"
   t.task_number
   FROM application_task t
   WHERE (request->task_number=t.task_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL result_status("Insert","D","application_task","Task already exists.")
   SET reply->status_data.status = "D"
   GO TO exit_script
  ENDIF
  INSERT  FROM application_task t
   SET t.task_number = request->task_number, t.description = request->description, t.active_dt_tm =
    cnvtdatetime(sysdate),
    t.active_ind = request->active_ind, t.inactive_dt_tm =
    IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
    ELSE null
    ENDIF
    , t.optional_required_flag = request->optional_required_flag,
    t.text = request->text, t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task,
    t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx, t.subordinate_task_ind =
    request->subordinate_task_ind,
    t.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL result_status("Insert","F","application_task","Insert failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   t.task_number
   FROM task_access t
   WHERE (t.task_number=request->task_number)
    AND (t.app_group_cd=request->app_group_cd)
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM task_access
    SET app_group_cd = request->app_group_cd, task_number = request->task_number, updt_dt_tm =
     cnvtdatetime(sysdate),
     updt_task = reqinfo->updt_task, updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","P","task_access","Insert partially failed")
    SET reply->status_data.status = "P"
    SET reqinfo->commit_ind = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   t.task_number
   FROM dm_application_task t
   WHERE (request->task_number=t.task_number)
    AND (request->feature_number=t.feature_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_application_task t
    SET t.description = request->description, t.active_dt_tm = cnvtdatetime(sysdate), t.active_ind =
     request->active_ind,
     t.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , t.optional_required_flag = request->optional_required_flag, t.text = request->text,
     t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
     updt_id,
     t.updt_applctx = reqinfo->updt_applctx, t.subordinate_task_ind = request->subordinate_task_ind,
     t.updt_cnt = 0,
     t.deleted_ind = 0, t.feature_number = request->feature_number, t.schema_date = cnvtdatetimeutc(
      request->schema_date,2)
    WHERE (t.task_number=request->task_number)
     AND (t.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_application_task","Update failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM dm_application_task t
    SET t.task_number = request->task_number, t.description = request->description, t.active_dt_tm =
     cnvtdatetime(sysdate),
     t.active_ind = request->active_ind, t.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , t.optional_required_flag = request->optional_required_flag,
     t.text = request->text, t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task,
     t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx, t.subordinate_task_ind =
     request->subordinate_task_ind,
     t.updt_cnt = 0, t.deleted_ind = 0, t.feature_number = request->feature_number,
     t.schema_date = cnvtdatetimeutc(request->schema_date,2)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_application_task","Insert failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    t.task_number
    FROM task_access t
    WHERE (t.task_number=request->task_number)
     AND (t.app_group_cd=request->app_group_cd)
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM task_access
     SET app_group_cd = request->app_group_cd, task_number = request->task_number, updt_dt_tm =
      cnvtdatetime(sysdate),
      updt_task = reqinfo->updt_task, updt_id = reqinfo->updt_id, updt_applctx = reqinfo->
      updt_applctx,
      updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL result_status("Insert","P","task_access","Insert partially failed")
     SET reply->status_data.status = "P"
     SET reqinfo->commit_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
#exit_script
END GO
