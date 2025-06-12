CREATE PROGRAM dms_del_media_instance:dba
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
 FREE SET numqual
 DECLARE numqual = i4 WITH constant(size(request->qual,5))
 FREE SET qualcount
 DECLARE qualcount = i4 WITH noconstant(0)
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 IF (numqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 FREE RECORD reqmediainfo
 RECORD reqmediainfo(
   1 identifiers[*]
     2 media_identifier = vc
     2 dms_media_identifier_id = f8
   1 lt_ids[*]
     2 long_text_id = f8
     2 del_lt_ind = i2
   1 hasmetadata = c1
 )
 SET stat = alterlist(reqmediainfo->lt_ids,numqual)
 SET reqmediainfo->hasmetadata = "F"
 SELECT INTO "nl:"
  dmid.dms_media_identifier_id, dmi.identifier, dmi.long_text_id
  FROM (dummyt d  WITH seq = value(numqual)),
   dms_media_instance dmi,
   dms_media_identifier dmid
  PLAN (d)
   JOIN (dmi
   WHERE (dmi.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
   JOIN (dmid
   WHERE dmid.dms_media_identifier_id=dmi.dms_media_identifier_id)
  ORDER BY dmi.dms_media_identifier_id
  HEAD REPORT
   stat = alterlist(reqmediainfo->identifiers,numqual), qualcount = 0
  HEAD dmi.dms_media_identifier_id
   qualcount += 1, reqmediainfo->identifiers[qualcount].media_identifier = dmid
   .media_object_identifier, reqmediainfo->identifiers[qualcount].dms_media_identifier_id = dmi
   .dms_media_identifier_id
  DETAIL
   IF (dmi.long_text_id > 0)
    reqmediainfo->lt_ids[d.seq].long_text_id = dmi.long_text_id, reqmediainfo->hasmetadata = "T"
   ENDIF
  FOOT REPORT
   IF (qualcount < numqual)
    stat = alterlist(reqmediainfo->identifiers,qualcount)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "request has invalid dms_media_instance_id(s)"
  GO TO end_script
 ENDIF
 IF ((reqmediainfo->hasmetadata="T"))
  DELETE  FROM dms_media_metadata dmm,
    (dummyt d  WITH seq = value(numqual))
   SET dmm.seq = 1
   PLAN (d)
    JOIN (dmm
    WHERE (dmm.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
   WITH nocounter
  ;end delete
 ENDIF
 FREE RECORD deleventrequest
 RECORD deleventrequest(
   1 qual[*]
     2 dms_media_instance_id = f8
 )
 SET stat = alterlist(deleventrequest->qual,numqual)
 FOR (i = 1 TO numqual)
   SET deleventrequest->qual[i].dms_media_instance_id = request->qual[i].dms_media_instance_id
 ENDFOR
 EXECUTE dms_del_event  WITH replace("REQUEST","DELEVENTREQUEST")
 FREE RECORD deleventrequest
 FREE SET count
 DECLARE count = i4 WITH noconstant(0)
 FREE RECORD bloblist
 RECORD bloblist(
   1 qual[*]
     2 long_blob_id = f8
 )
 SELECT INTO "nl:"
  dms.signature_blob_id
  FROM dms_media_signature dms,
   (dummyt d  WITH seq = value(numqual))
  PLAN (d)
   JOIN (dms
   WHERE (dms.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
  HEAD REPORT
   count = 0
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alterlist(bloblist->qual,(count+ 9))
   ENDIF
   bloblist->qual[count].long_blob_id = dms.signature_blob_id
  FOOT REPORT
   stat = alterlist(bloblist->qual,count)
  WITH nocounter
 ;end select
 DELETE  FROM dms_media_signature dms,
   (dummyt d  WITH seq = value(numqual))
  SET dms.seq = 1
  PLAN (d)
   JOIN (dms
   WHERE (dms.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
  WITH nocounter
 ;end delete
 IF (count > 0)
  DELETE  FROM long_blob lb,
    (dummyt d  WITH seq = value(count))
   SET lb.seq = 1
   PLAN (d)
    JOIN (lb
    WHERE (lb.long_blob_id=bloblist->qual[d.seq].long_blob_id))
   WITH nocounter
  ;end delete
 ENDIF
 IF ((reqmediainfo->hasmetadata="T"))
  SELECT INTO "nl:"
   selnum = count(dmi.dms_media_instance_id)
   FROM dms_media_instance dmi,
    (dummyt d  WITH seq = value(numqual))
   PLAN (d)
    JOIN (dmi
    WHERE dmi.long_text_id > 0
     AND (dmi.long_text_id=reqmediainfo->lt_ids[d.seq].long_text_id))
   DETAIL
    IF (selnum < 2)
     reqmediainfo->lt_ids[d.seq].del_lt_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM dms_media_instance dmi,
   (dummyt d  WITH seq = value(numqual))
  SET dmi.seq = 1
  PLAN (d)
   JOIN (dmi
   WHERE (dmi.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
  WITH nocounter
 ;end delete
 IF ((reqmediainfo->hasmetadata="T"))
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(numqual))
   SET lt.seq = 1
   PLAN (d)
    JOIN (lt
    WHERE (reqmediainfo->lt_ids[d.seq].long_text_id > 0.0)
     AND (lt.long_text_id=reqmediainfo->lt_ids[d.seq].long_text_id)
     AND (reqmediainfo->lt_ids[d.seq].del_lt_ind=1))
   WITH nocounter
  ;end delete
 ENDIF
 FREE SET numidentifiers
 DECLARE numidentifiers = i4 WITH constant(size(reqmediainfo->identifiers,5))
 FREE RECORD delmediaxrefrequest
 RECORD delmediaxrefrequest(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 media_identifier = vc
     2 identifier_id = f8
 )
 FREE RECORD dms_media_ident_ids
 RECORD dms_media_ident_ids(
   1 ids[*]
     2 dms_media_identifier_id = f8
 )
 SELECT INTO "nl:"
  dmi.dms_media_identifier_id
  FROM (dummyt d  WITH seq = value(numidentifiers)),
   dms_media_instance dmi
  PLAN (d)
   JOIN (dmi
   WHERE (dmi.dms_media_identifier_id=reqmediainfo->identifiers[d.seq].dms_media_identifier_id))
  HEAD REPORT
   count = 0
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alterlist(delmediaxrefrequest->qual,(count+ 9)), stat = alterlist(dms_media_ident_ids->ids,
     (count+ 9))
   ENDIF
   delmediaxrefrequest->qual[count].media_identifier = reqmediainfo->identifiers[d.seq].
   media_identifier, dms_media_ident_ids->ids[count].dms_media_identifier_id = reqmediainfo->
   identifiers[d.seq].dms_media_identifier_id
  FOOT REPORT
   IF (count > 0)
    stat = alterlist(delmediaxrefrequest->qual,count), stat = alterlist(dms_media_ident_ids->ids,
     count)
   ENDIF
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF (size(delmediaxrefrequest->qual,5) > 0)
  EXECUTE dms_del_media_xref  WITH replace("REQUEST","DELMEDIAXREFREQUEST")
  IF ((reply->status_data.status="F"))
   GO TO end_script
  ENDIF
 ENDIF
 FREE RECORD delmediaxrefrequest
 FREE SET num_dmid_ids
 DECLARE num_dmid_ids = i4 WITH constant(size(dms_media_ident_ids->ids,5))
 IF (num_dmid_ids > 0)
  DELETE  FROM dms_media_identifier dmid,
    (dummyt d  WITH seq = value(num_dmid_ids))
   SET dmid.seq = 1
   PLAN (d)
    JOIN (dmid
    WHERE (dmid.dms_media_identifier_id=dms_media_ident_ids->ids[d.seq].dms_media_identifier_id))
   WITH nocounter
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
END GO
