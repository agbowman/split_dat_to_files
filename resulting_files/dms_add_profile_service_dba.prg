CREATE PROGRAM dms_add_profile_service:dba
 CALL echo("<==================== Entering DMS_ADD_PROFILE_SERVICE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dms_profile_service_id = f8
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
 FREE SET contenttypeid
 DECLARE contenttypeid = f8 WITH noconstant(0.0)
 IF (trim(request->content_type) != "")
  SELECT INTO "nl:"
   dct.*
   FROM dms_content_type dct
   WHERE (dct.content_type_key=request->content_type)
   DETAIL
    contenttypeid = dct.dms_content_type_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
   SET reply->status_data.subeventstatus.targetobjectvalue = request->content_type
   GO TO end_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(dms_seq,nextval)
  FROM dual
  DETAIL
   reply->dms_profile_service_id = nextseqnum
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DUAL"
  SET reply->status_data.subeventstatus.targetobjectvalue = "DMS_SEQ"
  GO TO end_script
 ENDIF
 INSERT  FROM dms_profile_service dps
  SET dps.dms_profile_service_id = reply->dms_profile_service_id, dps.dms_profile_id = request->
   dms_profile_id, dps.dms_content_type_id = contenttypeid,
   dps.service_name = request->service_name, dps.from_position_cd = request->from_position_cd, dps
   .from_prsnl_id = request->from_prsnl_id,
   dps.updt_dt_tm = cnvtdatetime(curdate,curtime3), dps.updt_id = reqinfo->updt_id, dps.updt_task =
   reqinfo->updt_task,
   dps.updt_cnt = 0, dps.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_SERVICE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_profile_id,"/",request
   ->content_type,"/",request->service_name,
   "/",request->from_position_cd,"/",request->from_prsnl_id)
  GO TO end_script
 ENDIF
 IF (0 < size(request->servicedetail,5))
  INSERT  FROM dms_profile_detail dpd,
    (dummyt d  WITH seq = value(size(request->servicedetail,5)))
   SET dpd.dms_profile_detail_id = seq(dms_seq,nextval), dpd.dms_profile_service_id = reply->
    dms_profile_service_id, dpd.detail_name = request->servicedetail[d.seq].name,
    dpd.detail_value = request->servicedetail[d.seq].value, dpd.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), dpd.updt_id = reqinfo->updt_id,
    dpd.updt_task = reqinfo->updt_task, dpd.updt_cnt = 0, dpd.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dpd)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus.operationname = "INSERT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_DETAIL"
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_PROFILE_SERVICE Script ====================>")
END GO
