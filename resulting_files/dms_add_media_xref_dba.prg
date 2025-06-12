CREATE PROGRAM dms_add_media_xref:dba
 CALL echo("<===================== Entering DMS_ADD_MEDIA_XREF Script =====================>")
 SET modify = predeclare
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
 DECLARE number_to_add = i4 WITH private, noconstant(0)
 FREE SET num_dmid
 DECLARE num_dmid = i4 WITH noconstant(0)
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 FREE RECORD rec_dmids
 RECORD rec_dmids(
   1 qual[*]
     2 dms_media_identifier_id = f8
 )
 SET number_to_add = size(request->qual,5)
 IF (number_to_add <= 0)
  GO TO end_script
 ENDIF
 SET stat = alterlist(rec_dmids->qual,number_to_add)
 SELECT INTO "nl:"
  dmid.dms_media_identifier_id
  FROM dms_media_identifier dmid,
   (dummyt d  WITH seq = value(number_to_add))
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
 IF (num_dmid != number_to_add)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_IDENTIFIER"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to select the dms_media_identifier_ids"
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(number_to_add)),
   dms_media_xref x
  SET x.parent_entity_id = request->qual[d.seq].parent_entity_id, x.parent_entity_name = request->
   qual[d.seq].parent_entity_name, x.dms_media_identifier_id = rec_dmids->qual[d.seq].
   dms_media_identifier_id,
   x.dms_media_xref_id = seq(dms_seq,nextval), x.updt_dt_tm = cnvtdatetime(sysdate), x.updt_id =
   reqinfo->updt_id,
   x.updt_cnt = 0, x.updt_task = reqinfo->updt_task, x.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (x)
  WITH nocounter
 ;end insert
 IF (curqual != number_to_add)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert the cross-reference"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
 CALL echorecord(reply)
 CALL echo("<===================== Exiting DMS_ADD_MEDIA_XREF Script ======================>")
END GO
