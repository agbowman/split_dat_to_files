CREATE PROGRAM dms_del_media_xref:dba
 SET modify = predeclare
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
 FREE SET number_to_del
 DECLARE number_to_del = i4 WITH private, noconstant(size(request->qual,5))
 FREE SET num_dmid
 DECLARE num_dmid = i4 WITH noconstant(0)
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 FREE RECORD rec_dmids
 RECORD rec_dmids(
   1 qual[*]
     2 dms_media_identifier_id = f8
 )
 SET stat = alterlist(rec_dmids->qual,number_to_del)
 SELECT INTO "nl:"
  dmid.dms_media_identifier_id
  FROM dms_media_identifier dmid,
   (dummyt d  WITH seq = value(number_to_del))
  PLAN (d)
   JOIN (dmid
   WHERE ((trim(request->qual[d.seq].media_identifier) != ""
    AND (dmid.media_object_identifier=request->qual[d.seq].media_identifier)) OR ((request->qual[d
   .seq].identifier_id > 0)
    AND (dmid.dms_media_identifier_id=request->qual[d.seq].identifier_id))) )
  DETAIL
   rec_dmids->qual[d.seq].dms_media_identifier_id = dmid.dms_media_identifier_id, num_dmid += 1
  WITH nocounter
 ;end select
 IF (num_dmid != number_to_del)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_IDENTIFIER"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to select the dms_media_identifier_ids"
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ENDIF
 DELETE  FROM dms_media_xref dmx,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dmx.seq = 1
  PLAN (d)
   JOIN (dmx
   WHERE (dmx.dms_media_identifier_id=rec_dmids->qual[d.seq].dms_media_identifier_id)
    AND (((request->qual[d.seq].parent_entity_id <= 0.0)) OR ((dmx.parent_entity_name=request->qual[d
   .seq].parent_entity_name)
    AND (dmx.parent_entity_id=request->qual[d.seq].parent_entity_id))) )
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "curqual=0; no media instances qualify on the request's data"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
END GO
