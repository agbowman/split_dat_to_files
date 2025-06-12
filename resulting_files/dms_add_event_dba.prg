CREATE PROGRAM dms_add_event:dba
 CALL echo("<==================== Entering DMS_ADD_MEDIA_EVENT Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 long_text_id = f8
    1 event_id = f8
    1 event_ref_id = f8
    1 event_reason_id = f8
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
  nextdmsseqnum = seq(dms_seq,nextval)
  FROM dual
  DETAIL
   reply->event_id = cnvtreal(nextdmsseqnum)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_SEQ"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error getting next number from dms_seq."
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  d.dms_ref_id
  FROM dms_ref d
  WHERE d.ref_key=cnvtupper(request->event_key)
   AND d.ref_group="MEDIAEVENT"
  DETAIL
   reply->event_ref_id = d.dms_ref_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_REF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error: No qual from DMS_REF table for EVENT_KEY/MEDIAEVENT."
  GO TO end_script
 ENDIF
 IF (size(trim(request->event_reason_key)) > 0)
  SELECT INTO "nl:"
   d.dms_ref_id
   FROM dms_ref d
   WHERE d.ref_key=cnvtupper(request->event_reason_key)
    AND d.ref_group="REASON"
   DETAIL
    reply->event_reason_id = d.dms_ref_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_REF"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error: No qual from DMS_REF table for EVENT_KEY/REASON"
   GO TO end_script
  ENDIF
 ENDIF
 IF ((request->event_date=0))
  SET request->event_date = cnvtdatetime(sysdate)
 ENDIF
 IF ((request->event_requestor=0.0))
  SET request->event_requestor = reqinfo->updt_id
 ENDIF
 IF (size(trim(request->event_detail)) > 255)
  SELECT INTO "nl:"
   nextlongseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    reply->long_text_id = cnvtreal(nextlongseqnum)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_DATA_SEQ"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error getting next number from LONG_DATA_SEQ."
   GO TO end_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = reply->long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.updt_cnt = 0, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.parent_entity_name = "DMS_EVENT", lt
    .parent_entity_id = reply->event_id,
    lt.long_text = trim(request->event_detail)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting row into LONG_TEXT table."
   GO TO end_script
  ENDIF
  INSERT  FROM dms_event dme
   SET dme.dms_event_id = reply->event_id, dme.dms_media_instance_id = request->dms_media_instance_id,
    dme.dms_event_ref_id = reply->event_ref_id,
    dme.created_by_id = request->event_requestor, dme.event_dt_tm = cnvtdatetime(request->event_date),
    dme.event_detail = "",
    dme.long_text_id = reply->long_text_id, dme.dms_reason_ref_id = reply->event_reason_id, dme
    .event_comment = request->event_comment,
    dme.updt_dt_tm = cnvtdatetime(sysdate), dme.updt_id = reqinfo->updt_id, dme.updt_task = reqinfo->
    updt_task,
    dme.updt_applctx = reqinfo->updt_applctx, dme.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting row into DMS_EVENT table."
   GO TO end_script
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating row in DMS_EVENT table."
   GO TO end_script
  ENDIF
 ELSE
  INSERT  FROM dms_event dme
   SET dme.dms_event_id = reply->event_id, dme.dms_media_instance_id = request->dms_media_instance_id,
    dme.dms_event_ref_id = reply->event_ref_id,
    dme.created_by_id = request->event_requestor, dme.event_dt_tm = cnvtdatetime(request->event_date),
    dme.event_detail = trim(request->event_detail),
    dme.long_text_id = 0.0, dme.dms_reason_ref_id = reply->event_reason_id, dme.event_comment =
    request->event_comment,
    dme.updt_dt_tm = cnvtdatetime(sysdate), dme.updt_id = reqinfo->updt_id, dme.updt_task = reqinfo->
    updt_task,
    dme.updt_applctx = reqinfo->updt_applctx, dme.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting row into DMS_EVENT table."
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_EVENT Script ====================>")
END GO
