CREATE PROGRAM dms_add_profile:dba
 CALL echo("<==================== Entering DMS_ADD_PROFILE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dms_profile_id = f8
    1 display = vc
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
  dp.parent_entity_id, dp.parent_entity_name
  FROM dms_profile dp
  WHERE (dp.parent_entity_id=request->parent_entity_id)
   AND (dp.parent_entity_name=request->parent_entity_name)
  DETAIL
   reply->dms_profile_id = dp.dms_profile_id
  WITH nocounter
 ;end select
 IF (0 < curqual)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->parent_entity_id,"/",
   request->parent_entity_name)
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(dms_seq,nextval)
  FROM dual
  DETAIL
   reply->dms_profile_id = nextseqnum
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DUAL"
  SET reply->status_data.subeventstatus.targetobjectvalue = "DMS_SEQ"
  GO TO end_script
 ENDIF
 INSERT  FROM dms_profile dp
  SET dp.dms_profile_id = reply->dms_profile_id, dp.parent_entity_id = request->parent_entity_id, dp
   .parent_entity_name = request->parent_entity_name,
   dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id, dp.updt_task =
   reqinfo->updt_task,
   dp.updt_cnt = 0, dp.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->parent_entity_id,"/",
   request->parent_entity_name)
  GO TO end_script
 ENDIF
 IF ((request->parent_entity_name="PERSON"))
  SELECT INTO "nl:"
   p.person_id, p.username
   FROM prsnl p
   WHERE (p.person_id=request->parent_entity_id)
   DETAIL
    reply->display = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSEIF ((request->parent_entity_name="ORGANIZATION"))
  SELECT INTO "nl:"
   o.organization_id, o.org_name
   FROM organization o
   WHERE (o.organization_id=request->parent_entity_id)
   DETAIL
    reply->display = o.org_name
   WITH nocounter
  ;end select
 ELSEIF ((((request->parent_entity_name="SERVICERESOURCE")) OR ((request->parent_entity_name=
 "LOCATION"))) )
  SET reply->display = uar_get_code_display(request->parent_entity_id)
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_PROFILE Script ====================>")
END GO
