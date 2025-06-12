CREATE PROGRAM dms_get_metadata_def:dba
 CALL echo("<==================== Entering DMS_GET_METADATA_DEF Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 metadata_def = vc
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
 IF ((0 < request->metadata_version))
  SELECT INTO "nl:"
   l.long_text
   FROM dms_media_metadata_ref d,
    long_text_reference l
   PLAN (d
    WHERE (d.dms_content_type_id=request->dms_content_type_id)
     AND (d.version=request->metadata_version))
    JOIN (l
    WHERE l.long_text_id=d.long_text_id)
   DETAIL
    reply->metadata_def = l.long_text
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   l.long_text
   FROM dms_media_metadata_ref d,
    long_text_reference l
   PLAN (d
    WHERE (d.dms_content_type_id=request->dms_content_type_id))
    JOIN (l
    WHERE l.long_text_id=d.long_text_id)
   ORDER BY d.version DESC
   HEAD d.dms_content_type_id
    reply->metadata_def = l.long_text
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_METADATA_DEF Script ====================>")
END GO
