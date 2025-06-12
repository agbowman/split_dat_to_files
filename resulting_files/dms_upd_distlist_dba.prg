CREATE PROGRAM dms_upd_distlist:dba
 CALL echo("<==================== Entering DMS_UPD_DISTLIST Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET modify = predeclare
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 FREE SET tempowner
 DECLARE tempowner = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  dl.*
  FROM dms_distlist dl
  WHERE (dl.dms_distlist_id=request->dms_distlist_id)
  DETAIL
   tempowner = dl.owner_id
  WITH nocounter
 ;end select
 IF ((request->owner_id <= 0))
  SET request->owner_id = reqinfo->updt_id
 ENDIF
 IF ((request->owner_id != tempowner))
  SELECT INTO ":nl"
   ddl.*, dl.*
   FROM dms_distlist ddl,
    dms_distlist dl
   PLAN (ddl
    WHERE (ddl.dms_distlist_id=request->id))
    JOIN (dl
    WHERE dl.name=ddl.name
     AND (dl.owner_id=request->owner_id))
   WITH nocounter
  ;end select
  IF (0 < curqual)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "S"
   SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
   SET reply->status_data.subeventstatus.targetobjectvalue = build(request->id,
    "List already exists for owner")
   GO TO end_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dms_distlist ddl
  WHERE (ddl.dms_distlist_id=request->dms_distlist_id)
  WITH nocounter, forupdate(ddl)
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_distlist_id)
  GO TO end_script
 ENDIF
 UPDATE  FROM dms_distlist ddl
  SET ddl.description = request->description, ddl.owner_id = request->owner_id, ddl.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ddl.updt_id = reqinfo->updt_id, ddl.updt_task = reqinfo->updt_task, ddl.updt_cnt = (ddl.updt_cnt+
   1),
   ddl.updt_applctx = reqinfo->updt_applctx
  WHERE (ddl.dms_distlist_id=request->dms_distlist_id)
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "UPDATE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_distlist_id)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_UPD_DISTLIST Script ====================>")
END GO
