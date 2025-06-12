CREATE PROGRAM dms_upd_content_type:dba
 CALL echo("<==================== Entering DMS_UPD_CONTENT_TYPE Script ====================>")
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  FROM dms_content_type dct
  WHERE (dct.content_type_key=request->content_type_key)
  WITH nocounter, forupdate(dct)
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->content_type_key)
  GO TO end_script
 ENDIF
 UPDATE  FROM dms_content_type dct
  SET dct.display = request->display, dct.description = request->description, dct.max_versions =
   request->max_versions,
   dct.expiration_duration = request->expiration_duration, dct.signature_req_ind = request->
   signature_req_ind, dct.cerner_ind = request->cerner_ind,
   dct.updt_dt_tm = cnvtdatetime(sysdate), dct.updt_id = reqinfo->updt_id, dct.updt_task = reqinfo->
   updt_task,
   dct.updt_cnt = (dct.updt_cnt+ 1), dct.updt_applctx = reqinfo->updt_applctx
  WHERE (dct.content_type_key=request->content_type_key)
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "UPDATE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->content_type_key)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_UPD_CONTENT_TYPE Script ====================>")
END GO
