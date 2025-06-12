CREATE PROGRAM dms_get_media_instance:dba
 CALL echo("<==================== Entering DMS_GET_MEDIA_INSTANCE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 identifier = vc
    1 version = i4
    1 content_type = vc
    1 content_uid = vc
    1 content_size = i4
    1 media_type = vc
    1 thumbnail_uid = vc
    1 created_dt_tm = dq8
    1 created_by_id = f8
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
 IF ((0 < request->version))
  SELECT INTO "nl:"
   dmi.*
   FROM dms_media_instance dmi
   WHERE (dmi.identifier=request->identifier)
    AND (dmi.version=request->version)
   DETAIL
    reply->identifier = dmi.identifier, reply->version = dmi.version, reply->content_type = dmi
    .content_type,
    reply->content_uid = dmi.content_uid, reply->content_size = dmi.content_size, reply->media_type
     = dmi.media_type,
    reply->thumbnail_uid = dmi.thumbnail_uid, reply->created_dt_tm = dmi.created_dt_tm, reply->
    created_by_id = dmi.created_by_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   dmi.*
   FROM dms_media_instance dmi
   WHERE (dmi.identifier=request->identifier)
   ORDER BY dmi.version DESC
   DETAIL
    reply->identifier = dmi.identifier, reply->version = dmi.version, reply->content_type = dmi
    .content_type,
    reply->content_uid = dmi.content_uid, reply->content_size = dmi.content_size, reply->media_type
     = dmi.media_type,
    reply->thumbnail_uid = dmi.thumbnail_uid, reply->created_dt_tm = dmi.created_dt_tm, reply->
    created_by_id = dmi.created_by_id
   WITH maxqual(dmi,1), nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_MEDIA_INSTANCE Script ====================>")
END GO
