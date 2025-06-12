CREATE PROGRAM atr_add_req:dba
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
   r.request_number
   FROM dm_request r
   WHERE (r.request_number=request->request_number)
    AND (r.feature_number=request->feature_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_request r
    SET r.request_number = request->request_number, r.description = request->description, r.text =
     request->text,
     r.request_name = request->request_module, r.requestclass = request->requestclass, r.active_ind
      = request->active_ind,
     r.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE null
     ENDIF
     , r.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , r.updt_dt_tm = cnvtdatetime(sysdate),
     r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->updt_id, r.feature_number = request->
     feature_number,
     r.deleted_ind = 0, r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.cachetime =
     request->cachetime,
     r.cachegrace = request->cachegrace, r.cachestale = request->cachestale, r.cachetrim = request->
     cachetrim,
     r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.binding_override =
     IF (textlen(trim(request->binding_override)) > 0) request->binding_override
     ELSE null
     ENDIF
    WHERE (r.request_number=request->request_number)
     AND (r.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_request","Update failed.")
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM dm_request r
    SET r.request_number = request->request_number, r.description = request->description, r.text =
     request->text,
     r.request_name = request->request_module, r.requestclass = request->requestclass, r.active_ind
      = request->active_ind,
     r.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE null
     ENDIF
     , r.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , r.updt_dt_tm = cnvtdatetime(sysdate),
     r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->updt_id, r.feature_number = request->
     feature_number,
     r.deleted_ind = 0, r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.cachetime =
     request->cachetime,
     r.cachegrace = request->cachegrace, r.cachestale = request->cachestale, r.cachetrim = request->
     cachetrim,
     r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.binding_override =
     IF (textlen(trim(request->binding_override)) > 0) request->binding_override
     ELSE null
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_request","Insert failed.")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   r.request_number
   FROM request r
   WHERE (request->request_number=r.request_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL result_status("Select","D","request","Request already exists.")
   SET reply->status_data.status = "D"
   GO TO exit_script
  ELSE
   INSERT  FROM request r
    SET r.request_number = request->request_number, r.description = request->description, r.text =
     request->text,
     r.request_name = request->request_module, r.requestclass = request->requestclass, r
     .prolog_script = request->prolog_script,
     r.epilog_script = request->epilog_script, r.active_ind = request->active_ind, r.active_dt_tm =
     IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
     ELSE null
     ENDIF
     ,
     r.inactive_dt_tm =
     IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
     ELSE null
     ENDIF
     , r.cachetime = request->cachetime, r.cachegrace = request->cachegrace,
     r.cachestale = request->cachestale, r.cachetrim = request->cachetrim, r.updt_dt_tm =
     cnvtdatetime(sysdate),
     r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->updt_id, r.updt_cnt = 0,
     r.updt_applctx = reqinfo->updt_applctx, r.binding_override =
     IF (textlen(trim(request->binding_override)) > 0) request->binding_override
     ELSE null
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","request","Insert failed.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
