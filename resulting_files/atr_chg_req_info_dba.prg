CREATE PROGRAM atr_chg_req_info:dba
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
   r.request_number
   FROM request r
   WHERE (r.request_number=request->request_number)
   DETAIL
    cur_updt_cnt = r.updt_cnt
   WITH counter, forupdate(r)
  ;end select
  IF (curqual=0)
   CALL result_status("Select","F","request","Select for lock failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  IF ((cur_updt_cnt != request->updt_cnt))
   CALL result_status("Lock","F","request","Update count does not match.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  UPDATE  FROM request r
   SET r.description = request->description, r.active_ind = request->active_ind, r.active_dt_tm =
    IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
    ELSE cnvtdatetime(sysdate)
    ENDIF
    ,
    r.inactive_dt_tm =
    IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
    ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
    ENDIF
    , r.request_name = request->request_module, r.requestclass = request->requestclass,
    r.text = request->text, r.write_to_que_ind = request->write_to_que_ind, r.prolog_script = request
    ->prologue_script,
    r.epilog_script = request->epilogue_script, r.cachetime = request->cachetime, r.cachegrace =
    request->cachegrace,
    r.cachestale = request->cachestale, r.cachetrim = request->cachetrim, r.processclass = request->
    processclass,
    r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo
    ->updt_task,
    r.updt_cnt = (r.updt_cnt+ 1), r.updt_applctx = reqinfo->updt_applctx, r.binding_override =
    IF (textlen(trim(request->binding_override)) > 0) request->binding_override
    ELSE null
    ENDIF
   WHERE (r.request_number=request->request_number)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL result_status("Update","F","request","Update failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   r.request_number
   FROM dm_request r
   WHERE (r.request_number=request->request_number)
    AND (r.feature_number=request->feature_number)
   DETAIL
    cur_updt_cnt = r.updt_cnt
   WITH nocounter, forupdate(r)
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_request r
    SET r.request_number = request->request_number, r.description = request->description, r
     .active_ind = request->active_ind,
     r.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , r.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
     ENDIF
     , r.request_name = request->request_module,
     r.requestclass = request->requestclass, r.text = request->text, r.write_to_que_ind = request->
     write_to_que_ind,
     r.prolog_script = request->prologue_script, r.epilog_script = request->epilogue_script, r
     .cachetime = request->cachetime,
     r.cachegrace = request->cachegrace, r.cachestale = request->cachestale, r.cachetrim = request->
     cachetrim,
     r.processclass = request->processclass, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id =
     reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx,
     r.deleted_ind = 0, r.feature_number = request->feature_number, r.schema_date = cnvtdatetimeutc(
      request->schema_date,2),
     r.binding_override =
     IF (textlen(trim(request->binding_override)) > 0) request->binding_override
     ELSE null
     ENDIF
    WITH nocounter
   ;end insert
  ELSE
   UPDATE  FROM dm_request r
    SET r.description = request->description, r.active_ind = request->active_ind, r.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE cnvtdatetime(sysdate)
     ENDIF
     ,
     r.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE cnvtdatetime("31-dec-2100 00:00:00.00")
     ENDIF
     , r.request_name = request->request_module, r.requestclass = request->requestclass,
     r.text = request->text, r.write_to_que_ind = request->write_to_que_ind, r.prolog_script =
     request->prologue_script,
     r.epilog_script = request->epilogue_script, r.cachetime = request->cachetime, r.cachegrace =
     request->cachegrace,
     r.cachestale = request->cachestale, r.cachetrim = request->cachetrim, r.processclass = request->
     processclass,
     r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_applctx = reqinfo->updt_applctx, r.deleted_ind = 0,
     r.feature_number = request->feature_number, r.schema_date = cnvtdatetimeutc(request->schema_date,
      2), r.binding_override =
     IF (textlen(trim(request->binding_override)) > 0) request->binding_override
     ELSE null
     ENDIF
    WHERE (r.request_number=request->request_number)
     AND (r.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_request","Update failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
