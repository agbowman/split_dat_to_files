CREATE PROGRAM atr_chg_task_info:dba
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
   t.*
   FROM application_task t
   WHERE (request->task_number=t.task_number)
   DETAIL
    cur_updt_cnt = t.updt_cnt
   WITH counter, forupdate(t)
  ;end select
  IF (curqual=0)
   CALL result_status("Lock","F","application_task","Row lock failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  IF ((request->updt_cnt != cur_updt_cnt))
   CALL result_status("Lock","C","application_task","Update counts do not match.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  UPDATE  FROM application_task t
   SET t.updt_dt_tm = cnvtdatetime(curdate,curtime), t.updt_id = reqinfo->updt_id, t.updt_task =
    reqinfo->updt_task,
    t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = (t.updt_cnt+ 1), t.description = request->
    description,
    t.active_ind = request->active_ind, t.active_dt_tm =
    IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
    ELSE t.active_dt_tm
    ENDIF
    , t.inactive_dt_tm =
    IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
    ELSE t.inactive_dt_tm
    ENDIF
    ,
    t.optional_required_flag = request->optional_required_flag, t.text = request->text, t
    .subordinate_task_ind = request->subordinate_task_ind
   WHERE (t.task_number=request->task_number)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL result_status("Update","F","application_task","Update failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   t.task_number
   FROM dm_application_task t
   WHERE (t.task_number=request->task_number)
    AND (t.feature_number=request->feature_number)
   DETAIL
    cur_updt_cnt = t.updt_cnt
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_application_task t
    SET t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->
     updt_task,
     t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = (t.updt_cnt+ 1), t.description = request->
     description,
     t.active_ind = request->active_ind, t.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , t.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
     ENDIF
     ,
     t.optional_required_flag = request->optional_required_flag, t.text = request->text, t
     .subordinate_task_ind = request->subordinate_task_ind,
     t.feature_number = request->feature_number, t.schema_date = cnvtdatetimeutc(request->schema_date,
      2)
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
    SET t.task_number = request->task_number, t.description = request->description, t.active_ind =
     request->active_ind,
     t.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , t.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
     ENDIF
     , t.optional_required_flag = request->optional_required_flag,
     t.text = request->text, t.subordinate_task_ind = request->subordinate_task_ind, t.feature_number
      = request->feature_number,
     t.schema_date = cnvtdatetimeutc(request->schema_date,2), t.deleted_ind = 0, t.updt_dt_tm =
     cnvtdatetime(sysdate),
     t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
     updt_applctx,
     t.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_application_task","Insert failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
