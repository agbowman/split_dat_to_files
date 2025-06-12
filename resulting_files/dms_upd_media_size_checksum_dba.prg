CREATE PROGRAM dms_upd_media_size_checksum:dba
 CALL echo("<=================== Entering DMS_UPD_CONTENT_SIZE_CHECKSUM Script ===================>")
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
 DECLARE dms_media_instance_id = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  FROM dms_media_identifier dmii,
   dms_media_instance dmi
  PLAN (dmii
   WHERE (dmii.media_object_identifier=request->identifier))
   JOIN (dmi
   WHERE dmi.dms_media_identifier_id=dmii.dms_media_identifier_id)
  DETAIL
   dms_media_instance_id = dmi.dms_media_instance_id
  WITH nocounter, forupdate(dct)
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_MEDIA_INSTANCE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->media_instance_id)
  GO TO end_script
 ENDIF
 CALL echo(build("dms_media_instance_id:",dms_media_instance_id))
 UPDATE  FROM dms_media_instance dmi
  SET dmi.content_size = request->content_size, dmi.checksum = request->checksum
  WHERE dmi.dms_media_instance_id=dms_media_instance_id
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "UPDATE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->media_instance_id)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
END GO
