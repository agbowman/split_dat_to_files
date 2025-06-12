CREATE PROGRAM dms_add_distlist:dba
 CALL echo("<==================== Entering DMS_ADD_DISTLIST Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dms_distlist_id = f8
    1 created_by_id = f8
    1 created_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ((request->owner_id <= 0))
  SET request->owner_id = reqinfo->updt_id
 ENDIF
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  FROM dms_distlist ddl
  WHERE (ddl.name=request->name)
   AND (ddl.owner_id=request->owner_id)
   AND (ddl.private_ind=request->private_ind)
  DETAIL
   reply->dms_distlist_id = ddl.dms_distlist_id
  WITH nocounter
 ;end select
 IF (0 < curqual)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->name,
   "- Identical list already exists")
  GO TO end_script
 ENDIF
 IF ((request->private_ind=0))
  SELECT INTO "nl:"
   ddl.name
   FROM dms_distlist ddl
   WHERE (ddl.name=request->name)
   DETAIL
    reply->dms_distlist_id = ddl.dms_distlist_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   ddl.name
   FROM dms_distlist ddl
   WHERE (ddl.name=request->name)
    AND ddl.private_ind=0
   DETAIL
    reply->dms_distlist_id = ddl.dms_distlist_id
   WITH nocounter
  ;end select
 ENDIF
 IF (0 < curqual)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->name,
   "- List with same name exists")
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(dms_seq,nextval)
  FROM dual
  DETAIL
   reply->dms_distlist_id = nextseqnum
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DUAL"
  SET reply->status_data.subeventstatus.targetobjectvalue = "DMS_SEQ"
  GO TO end_script
 ENDIF
 SET reply->created_dt_tm = cnvtdatetime(curdate,curtime3)
 INSERT  FROM dms_distlist ddl
  SET ddl.dms_distlist_id = reply->dms_distlist_id, ddl.name = request->name, ddl.created_dt_tm =
   cnvtdatetime(reply->created_dt_tm),
   ddl.description = request->description, ddl.owner_id = request->owner_id, ddl.private_ind =
   request->private_ind,
   ddl.created_by_id = reqinfo->updt_id, ddl.created_dt_tm = cnvtdatetime(reply->created_dt_tm), ddl
   .updt_dt_tm = cnvtdatetime(reply->created_dt_tm),
   ddl.updt_id = reqinfo->updt_id, ddl.updt_task = reqinfo->updt_task, ddl.updt_cnt = 0,
   ddl.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = request->name
  GO TO end_script
 ENDIF
 SET reply->created_by_id = reqinfo->updt_id
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_DISTLIST Script ====================>")
END GO
