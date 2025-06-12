CREATE PROGRAM dms_get_media_by_xref:dba
 CALL echo("<=============== Entering DMS_GET_MEDIA_BY_XREF Script ===============>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 dms_media_instance_id = f8
      2 identifier = vc
      2 version = i4
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
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 dms_media_instance_id = f8
     2 identifier = vc
     2 version = i4
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
     2 long_blob_id = f8
     2 status_flag = i2
     2 group_id = vc
     2 section_num = i4
     2 checksum = f8
     2 dms_repository_id = f8
     2 current_version = i4
     2 dicom_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE num_qual = i4 WITH private, constant(size(request->qual,5))
 DECLARE countmedia = i4 WITH public, noconstant(0)
 FOR (i = 1 TO value(num_qual))
   IF (size(request->qual[i].content_types,5) > 0)
    SELECT INTO "nl:"
     *
     FROM (dummyt d  WITH seq = value(size(request->qual[i].content_types,5))),
      dms_media_identifier dmid,
      dms_media_identifier dmid2,
      dms_media_xref dmx,
      dms_media_instance dmi,
      dms_media_group dmg,
      long_text lt
     PLAN (d)
      JOIN (dmx
      WHERE (dmx.parent_entity_id=request->qual[i].parent_entity_id)
       AND (dmx.parent_entity_name=request->qual[i].parent_entity_name))
      JOIN (dmid
      WHERE dmid.dms_media_identifier_id=dmx.dms_media_identifier_id)
      JOIN (dmi
      WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id
       AND (dmi.dms_content_type_id=request->qual[i].content_types[d.seq].dms_content_type_id))
      JOIN (dmid2
      WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
      JOIN (lt
      WHERE lt.long_text_id=dmi.long_text_id)
      JOIN (dmg
      WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
     ORDER BY dmi.dms_media_identifier_id, dmi.version DESC
     HEAD dmi.dms_media_identifier_id
      countmedia += 1, stat = alterlist(temp_reply->qual,countmedia), temp_reply->qual[countmedia].
      dms_media_instance_id = dmi.dms_media_instance_id,
      temp_reply->qual[countmedia].identifier = dmid.media_object_identifier, temp_reply->qual[
      countmedia].version = dmi.version, temp_reply->qual[countmedia].dms_content_type_id = dmi
      .dms_content_type_id,
      temp_reply->qual[countmedia].content_uid = dmi.content_uid, temp_reply->qual[countmedia].
      content_size = dmi.content_size, temp_reply->qual[countmedia].media_type = dmi.media_type,
      temp_reply->qual[countmedia].thumbnail_uid = dmi.thumbnail_uid, temp_reply->qual[countmedia].
      created_dt_tm = dmi.created_dt_tm, temp_reply->qual[countmedia].created_by_id = dmi
      .created_by_id,
      temp_reply->qual[countmedia].name = dmi.name, temp_reply->qual[countmedia].metadata_ver = dmi
      .metadata_version, temp_reply->qual[countmedia].long_blob_id = dmi.long_blob_id,
      temp_reply->qual[countmedia].status_flag = dmi.status_flag, temp_reply->qual[countmedia].
      group_id = dmid2.media_object_identifier, temp_reply->qual[countmedia].section_num = dmg
      .dms_media_sequence,
      temp_reply->qual[countmedia].checksum = dmi.checksum, temp_reply->qual[countmedia].
      dms_repository_id = dmi.dms_repository_id, temp_reply->qual[countmedia].current_version = dmi
      .version,
      temp_reply->qual[countmedia].dicom_ind = dmi.stored_as_dicom_ind
      IF (dmi.long_text_id > 0)
       temp_reply->qual[countmedia].metadata = lt.long_text
      ENDIF
    ;end select
   ELSE
    SELECT INTO "nl:"
     *
     FROM dms_media_xref dmx,
      dms_media_identifier dmid,
      dms_media_identifier dmid2,
      dms_media_instance dmi,
      dms_media_group dmg,
      long_text lt
     PLAN (dmx
      WHERE (dmx.parent_entity_id=request->qual[i].parent_entity_id)
       AND (dmx.parent_entity_name=request->qual[i].parent_entity_name))
      JOIN (dmid
      WHERE dmid.dms_media_identifier_id=dmx.dms_media_identifier_id)
      JOIN (dmi
      WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id)
      JOIN (dmid2
      WHERE dmid2.dms_media_identifier_id=dmi.dms_media_identifier_group_id)
      JOIN (lt
      WHERE lt.long_text_id=dmi.long_text_id)
      JOIN (dmg
      WHERE (dmg.dms_media_child_id= Outerjoin(dmi.dms_media_instance_id)) )
     ORDER BY dmi.dms_media_identifier_id, dmi.version DESC
     HEAD dmi.dms_media_identifier_id
      countmedia += 1, stat = alterlist(temp_reply->qual,countmedia), temp_reply->qual[countmedia].
      dms_media_instance_id = dmi.dms_media_instance_id,
      temp_reply->qual[countmedia].identifier = dmid.media_object_identifier, temp_reply->qual[
      countmedia].version = dmi.version, temp_reply->qual[countmedia].dms_content_type_id = dmi
      .dms_content_type_id,
      temp_reply->qual[countmedia].content_uid = dmi.content_uid, temp_reply->qual[countmedia].
      content_size = dmi.content_size, temp_reply->qual[countmedia].media_type = dmi.media_type,
      temp_reply->qual[countmedia].thumbnail_uid = dmi.thumbnail_uid, temp_reply->qual[countmedia].
      created_dt_tm = dmi.created_dt_tm, temp_reply->qual[countmedia].created_by_id = dmi
      .created_by_id,
      temp_reply->qual[countmedia].name = dmi.name, temp_reply->qual[countmedia].metadata_ver = dmi
      .metadata_version, temp_reply->qual[countmedia].long_blob_id = dmi.long_blob_id,
      temp_reply->qual[countmedia].status_flag = dmi.status_flag, temp_reply->qual[countmedia].
      group_id = dmid2.media_object_identifier, temp_reply->qual[countmedia].section_num = dmg
      .dms_media_sequence,
      temp_reply->qual[countmedia].checksum = dmi.checksum, temp_reply->qual[countmedia].
      dms_repository_id = dmi.dms_repository_id, temp_reply->qual[countmedia].current_version = dmi
      .version,
      temp_reply->qual[countmedia].dicom_ind = dmi.stored_as_dicom_ind
      IF (dmi.long_text_id > 0)
       temp_reply->qual[countmedia].metadata = lt.long_text
      ENDIF
    ;end select
   ENDIF
 ENDFOR
 IF (countmedia=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "curqual=0; no media instances qualified"
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  old_dms_id = temp_reply->qual[d.seq].dms_media_instance_id
  FROM (dummyt d  WITH seq = value(size(temp_reply->qual,5)))
  ORDER BY old_dms_id
  HEAD REPORT
   stat = alterlist(reply->qual,size(temp_reply->qual,5)), countunique = 0
  HEAD old_dms_id
   countunique += 1, reply->qual[countunique].dms_media_instance_id = temp_reply->qual[d.seq].
   dms_media_instance_id, reply->qual[countunique].identifier = temp_reply->qual[d.seq].identifier,
   reply->qual[countunique].version = temp_reply->qual[d.seq].version, reply->qual[countunique].
   dms_content_type_id = temp_reply->qual[d.seq].dms_content_type_id, reply->qual[countunique].
   content_uid = temp_reply->qual[d.seq].content_uid,
   reply->qual[countunique].content_size = temp_reply->qual[d.seq].content_size, reply->qual[
   countunique].media_type = temp_reply->qual[d.seq].media_type, reply->qual[countunique].
   thumbnail_uid = temp_reply->qual[d.seq].thumbnail_uid,
   reply->qual[countunique].created_dt_tm = temp_reply->qual[d.seq].created_dt_tm, reply->qual[
   countunique].created_by_id = temp_reply->qual[d.seq].created_by_id, reply->qual[countunique].name
    = temp_reply->qual[d.seq].name,
   reply->qual[countunique].metadata_ver = temp_reply->qual[d.seq].metadata_ver, reply->qual[
   countunique].metadata = temp_reply->qual[d.seq].metadata, reply->qual[countunique].long_blob_id =
   temp_reply->qual[d.seq].long_blob_id,
   reply->qual[countunique].status_flag = temp_reply->qual[d.seq].status_flag, reply->qual[
   countunique].group_id = temp_reply->qual[d.seq].group_id, reply->qual[countunique].section_num =
   temp_reply->qual[d.seq].section_num,
   reply->qual[countunique].checksum = temp_reply->qual[d.seq].checksum, reply->qual[countunique].
   dms_repository_id = temp_reply->qual[d.seq].dms_repository_id, reply->qual[countunique].
   current_version = temp_reply->qual[d.seq].current_version,
   reply->qual[countunique].dicom_ind = temp_reply->qual[d.seq].dicom_ind
  FOOT REPORT
   stat = alterlist(reply->qual,countunique)
 ;end select
 DECLARE xrefcount = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  dmid.dms_media_identifier_id, dmx.parent_entity_name, dmx.parent_entity_id
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   dms_media_identifier dmid,
   dms_media_xref dmx
  PLAN (d)
   JOIN (dmid
   WHERE (dmid.media_object_identifier=reply->qual[d.seq].identifier))
   JOIN (dmx
   WHERE dmx.dms_media_identifier_id=dmid.dms_media_identifier_id)
  ORDER BY d.seq
  HEAD d.seq
   xrefcount = 0
  DETAIL
   xrefcount += 1
   IF (mod(xrefcount,10)=1)
    stat = alterlist(reply->qual[d.seq].xref,(xrefcount+ 9))
   ENDIF
   reply->qual[d.seq].xref[xrefcount].parent_entity_name = dmx.parent_entity_name, reply->qual[d.seq]
   .xref[xrefcount].parent_entity_id = dmx.parent_entity_id
  FOOT  d.seq
   stat = alterlist(reply->qual[d.seq].xref,xrefcount)
  WITH nocounter
 ;end select
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
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<============== Exiting DMS_GET_MEDIA_BY_XREF Script ===============>")
END GO
