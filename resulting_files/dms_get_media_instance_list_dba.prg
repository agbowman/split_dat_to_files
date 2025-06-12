CREATE PROGRAM dms_get_media_instance_list:dba
 CALL echo("<================== Entering DMS_GET_MEDIA_INSTANCE_LIST Script =================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 dms_media_instance_id = f8
      2 identifier = vc
      2 version = i4
      2 content_type = vc
      2 dms_content_type_id = f8
      2 content_uid = vc
      2 content_size = i4
      2 media_type = vc
      2 thumbnail_uid = vc
      2 created_dt_tm = dq8
      2 created_by_id = f8
      2 name = vc
      2 metadata_ver = i4
      2 metadata = vc
      2 xref[*]
        3 parent_entity_name = vc
        3 parent_entity_id = f8
      2 signatures[*]
        3 signature = vgc
      2 long_blob_id = f8
      2 status_flag = i2
      2 group_id = vc
      2 section_num = i4
      2 checksum = f8
      2 dms_repository_id = f8
      2 current_version = i4
      2 dms_media_identifier_id = f8
      2 service_start_dt = dq8
      2 service_stop_dt = dq8
      2 consumer_created_dt = dq8
      2 dicom_ind = i2
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
 DECLARE num_qual = i4 WITH public, constant(size(request->qual,5))
 DECLARE num_ids = i4 WITH public, constant(size(request->ids,5))
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE size = i4 WITH public, noconstant(0)
 DECLARE countmedia = i4 WITH public, noconstant(0)
 IF (num_qual > 0)
  SET size = num_qual
 ELSE
  SET size = num_ids
 ENDIF
 IF ((request->excludemeta=0))
  SELECT
   IF (num_ids=0)
    PLAN (d)
     JOIN (dmid
     WHERE (dmid.media_object_identifier=request->qual[d.seq].identifier))
     JOIN (dmi
     WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id
      AND (((request->qual[d.seq].version > 0)
      AND (dmi.version=request->qual[d.seq].version)) OR ((((request->qual[d.seq].version=0)
      AND (dmi.version=
     (SELECT
      max(dmi2.version)
      FROM dms_media_instance dmi2
      WHERE dmi2.dms_media_identifier_id=dmid.dms_media_identifier_id))) OR ((request->qual[d.seq].
     version=- (1)))) )) )
     JOIN (dmid2
     WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
     JOIN (dct
     WHERE dct.dms_content_type_id=dmi.dms_content_type_id)
     JOIN (lt
     WHERE lt.long_text_id=dmi.long_text_id)
     JOIN (dmg
     WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
   ELSE
    PLAN (d)
     JOIN (dmi
     WHERE (dmi.dms_media_instance_id=request->ids[d.seq].id))
     JOIN (dmid
     WHERE dmid.dms_media_identifier_id=dmi.dms_media_identifier_id)
     JOIN (dmid2
     WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
     JOIN (dct
     WHERE dct.dms_content_type_id=dmi.dms_content_type_id)
     JOIN (lt
     WHERE lt.long_text_id=dmi.long_text_id)
     JOIN (dmg
     WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
   ENDIF
   INTO "nl:"
   *
   FROM (dummyt d  WITH seq = value(size)),
    dms_media_identifier dmid,
    dms_media_identifier dmid2,
    dms_media_instance dmi,
    dms_media_group dmg,
    dms_content_type dct,
    long_text lt
   ORDER BY dmi.dms_media_instance_id, dmg.dms_media_group_id DESC
   HEAD REPORT
    countmedia = 0
   HEAD dmi.dms_media_instance_id
    countmedia += 1
    IF (mod(countmedia,10)=1)
     stat = alterlist(reply->qual,(countmedia+ 9))
    ENDIF
    reply->qual[countmedia].dms_media_instance_id = dmi.dms_media_instance_id, reply->qual[countmedia
    ].identifier = dmid.media_object_identifier, reply->qual[countmedia].version = dmi.version,
    reply->qual[countmedia].content_type = dct.content_type_key, reply->qual[countmedia].
    dms_content_type_id = dmi.dms_content_type_id, reply->qual[countmedia].content_uid = dmi
    .content_uid,
    reply->qual[countmedia].content_size = dmi.content_size, reply->qual[countmedia].media_type = dmi
    .media_type, reply->qual[countmedia].thumbnail_uid = dmi.thumbnail_uid,
    reply->qual[countmedia].created_dt_tm = dmi.created_dt_tm, reply->qual[countmedia].created_by_id
     = dmi.created_by_id, reply->qual[countmedia].name = dmi.name,
    reply->qual[countmedia].metadata_ver = dmi.metadata_version, reply->qual[countmedia].long_blob_id
     = dmi.long_blob_id, reply->qual[countmedia].status_flag = dmi.status_flag,
    reply->qual[countmedia].group_id = dmid2.media_object_identifier, reply->qual[countmedia].
    checksum = dmi.checksum, reply->qual[countmedia].dms_repository_id = dmi.dms_repository_id,
    reply->qual[countmedia].dms_media_identifier_id = dmi.dms_media_identifier_id, reply->qual[
    countmedia].service_start_dt = dmi.servicestart_dt_tm, reply->qual[countmedia].service_stop_dt =
    dmi.servicestop_dt_tm,
    reply->qual[countmedia].consumer_created_dt = dmi.consumercreated_dt_tm, reply->qual[countmedia].
    dicom_ind = dmi.stored_as_dicom_ind
    IF (num_qual > 0)
     IF ((request->qual[d.seq].version=0))
      reply->qual[countmedia].current_version = dmi.version
     ENDIF
    ENDIF
    IF (dmi.dms_media_identifier_group_id != 0.0)
     reply->qual[countmedia].section_num = dmg.dms_media_sequence
    ENDIF
    IF (dmi.long_text_id > 0)
     reply->qual[countmedia].metadata = lt.long_text
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,countmedia)
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF (num_ids=0)
    PLAN (d)
     JOIN (dmid
     WHERE (dmid.media_object_identifier=request->qual[d.seq].identifier))
     JOIN (dmi
     WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id
      AND (((request->qual[d.seq].version > 0)
      AND (dmi.version=request->qual[d.seq].version)) OR ((((request->qual[d.seq].version=0)
      AND (dmi.version=
     (SELECT
      max(dmi2.version)
      FROM dms_media_instance dmi2
      WHERE dmi2.dms_media_identifier_id=dmid.dms_media_identifier_id))) OR ((request->qual[d.seq].
     version=- (1)))) )) )
     JOIN (dmid2
     WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
     JOIN (dct
     WHERE dct.dms_content_type_id=dmi.dms_content_type_id)
     JOIN (dmg
     WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
   ELSE
    PLAN (d)
     JOIN (dmi
     WHERE (dmi.dms_media_instance_id=request->ids[d.seq].id))
     JOIN (dmid
     WHERE dmid.dms_media_identifier_id=dmi.dms_media_identifier_id)
     JOIN (dmid2
     WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
     JOIN (dct
     WHERE dct.dms_content_type_id=dmi.dms_content_type_id)
     JOIN (dmg
     WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
   ENDIF
   INTO "nl:"
   *
   FROM (dummyt d  WITH seq = value(size)),
    dms_media_identifier dmid,
    dms_media_identifier dmid2,
    dms_media_instance dmi,
    dms_media_group dmg,
    dms_content_type dct
   ORDER BY dmi.dms_media_instance_id, dmg.dms_media_group_id DESC
   HEAD REPORT
    countmedia = 0
   HEAD dmi.dms_media_instance_id
    countmedia += 1
    IF (mod(countmedia,10)=1)
     stat = alterlist(reply->qual,(countmedia+ 9))
    ENDIF
    reply->qual[countmedia].dms_media_instance_id = dmi.dms_media_instance_id, reply->qual[countmedia
    ].identifier = dmid.media_object_identifier, reply->qual[countmedia].version = dmi.version,
    reply->qual[countmedia].content_type = dct.content_type_key, reply->qual[countmedia].
    dms_content_type_id = dmi.dms_content_type_id, reply->qual[countmedia].content_uid = dmi
    .content_uid,
    reply->qual[countmedia].content_size = dmi.content_size, reply->qual[countmedia].media_type = dmi
    .media_type, reply->qual[countmedia].thumbnail_uid = dmi.thumbnail_uid,
    reply->qual[countmedia].created_dt_tm = dmi.created_dt_tm, reply->qual[countmedia].created_by_id
     = dmi.created_by_id, reply->qual[countmedia].name = dmi.name,
    reply->qual[countmedia].metadata_ver = dmi.metadata_version, reply->qual[countmedia].long_blob_id
     = dmi.long_blob_id, reply->qual[countmedia].status_flag = dmi.status_flag,
    reply->qual[countmedia].group_id = dmid2.media_object_identifier, reply->qual[countmedia].
    checksum = dmi.checksum, reply->qual[countmedia].dms_repository_id = dmi.dms_repository_id,
    reply->qual[countmedia].dms_media_identifier_id = dmi.dms_media_identifier_id, reply->qual[
    countmedia].service_start_dt = dmi.servicestart_dt_tm, reply->qual[countmedia].service_stop_dt =
    dmi.servicestop_dt_tm,
    reply->qual[countmedia].consumer_created_dt = dmi.consumercreated_dt_tm, reply->qual[countmedia].
    dicom_ind = dmi.stored_as_dicom_ind
    IF (num_qual > 0)
     IF ((request->qual[d.seq].version=0))
      reply->qual[countmedia].current_version = dmi.version
     ENDIF
    ENDIF
    IF (dmi.dms_media_identifier_group_id != 0.0)
     reply->qual[countmedia].section_num = dmg.dms_media_sequence
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,countmedia)
   WITH nocounter
  ;end select
 ENDIF
 IF (countmedia <= 0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(countmedia)),
   dms_media_instance dmi
  PLAN (d
   WHERE (reply->qual[d.seq].current_version=0))
   JOIN (dmi
   WHERE (dmi.dms_media_identifier_id=reply->qual[d.seq].dms_media_identifier_id))
  ORDER BY d.seq, dmi.version DESC
  HEAD d.seq
   reply->qual[d.seq].current_version = dmi.version
  WITH nocounter
 ;end select
 IF ((request->excludexref=0))
  DECLARE xrefcount = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   dmx.parent_entity_name, dmx.parent_entity_id
   FROM (dummyt d  WITH seq = value(countmedia)),
    dms_media_xref dmx
   PLAN (d)
    JOIN (dmx
    WHERE (dmx.dms_media_identifier_id=reply->qual[d.seq].dms_media_identifier_id))
   ORDER BY d.seq
   HEAD d.seq
    xrefcount = 0
   DETAIL
    xrefcount += 1
    IF (mod(xrefcount,10)=1)
     stat = alterlist(reply->qual[d.seq].xref,(xrefcount+ 9))
    ENDIF
    reply->qual[d.seq].xref[xrefcount].parent_entity_name = dmx.parent_entity_name, reply->qual[d.seq
    ].xref[xrefcount].parent_entity_id = dmx.parent_entity_id
   FOOT  d.seq
    stat = alterlist(reply->qual[d.seq].xref,xrefcount)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->excludesignatures=0))
  DECLARE sigcount = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   lb.long_blob
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    dms_media_signature dms,
    long_blob lb
   PLAN (d)
    JOIN (dms
    WHERE (dms.dms_media_instance_id=reply->qual[d.seq].dms_media_instance_id))
    JOIN (lb
    WHERE lb.long_blob_id=dms.signature_blob_id)
   ORDER BY d.seq
   HEAD d.seq
    sigcount = 0
   DETAIL
    sigcount += 1
    IF (mod(sigcount,10)=1)
     stat = alterlist(reply->qual[d.seq].signatures,(sigcount+ 9))
    ENDIF
    reply->qual[d.seq].signatures[sigcount].signature = lb.long_blob
   FOOT  d.seq
    stat = alterlist(reply->qual[d.seq].signatures,sigcount)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<================== Exiting DMS_GET_MEDIA_INSTANCE_LIST Script ==================>")
END GO
