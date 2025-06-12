CREATE PROGRAM dms_add_media_instance:dba
 CALL echo("<==================== Entering DMS_ADD_MEDIA_INSTANCE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dms_media_instance_id = f8
    1 identifier = vc
    1 groupid = vc
    1 version = i4
    1 created_by_id = f8
    1 created_dt_tm = dq8
    1 long_text_id = f8
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
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 IF ((request->max_versions=0))
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 FREE SET i
 DECLARE i = i4 WITH noconstant(0)
 FREE SET dms_media_identifier_id
 DECLARE dms_media_identifier_id = f8 WITH noconstant(0.0)
 FREE SET dms_media_identifier_group_id
 DECLARE dms_media_identifier_group_id = f8 WITH noconstant(0.0)
 FREE SET has_content
 DECLARE has_content = i2 WITH noconstant(1)
 IF ((request->long_blob_id=0.0)
  AND size(trim(request->content_uid,3))=0)
  SET has_content = 0
 ENDIF
 FREE SET mv_one_updt
 DECLARE mv_one_updt = i2 WITH noconstant(0)
 IF ((request->max_versions=1))
  SET mv_one_updt = 1
 ENDIF
 IF (size(trim(request->group_identifier,3)) > 0)
  SELECT INTO "nl:"
   dmid.dms_media_identifier_id
   FROM dms_media_identifier dmid
   WHERE (dmid.media_object_identifier=request->group_identifier)
   DETAIL
    dms_media_identifier_group_id = dmid.dms_media_identifier_id
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
 ENDIF
 FREE RECORD dmsversion
 RECORD dmsversion(
   1 qual[*]
     2 dms_media_instance_id = f8
     2 version = i4
     2 long_text_id = f8
     2 long_blob_id = f8
     2 content_uid = vc
     2 dms_repository_id = f8
 )
 FREE SET versionqual
 DECLARE versionqual = i4 WITH noconstant(0)
 SET reply->identifier = request->identifier
 SELECT INTO "nl:"
  *
  FROM dms_media_identifier dmid,
   dms_media_instance dmi
  PLAN (dmid
   WHERE (dmid.media_object_identifier=request->identifier))
   JOIN (dmi
   WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id)
  ORDER BY dmi.version
  HEAD REPORT
   versionqual = 0
  DETAIL
   versionqual += 1
   IF (mod(versionqual,10)=1)
    stat = alterlist(dmsversion->qual,(versionqual+ 9))
   ENDIF
   dmsversion->qual[versionqual].dms_media_instance_id = dmi.dms_media_instance_id, dmsversion->qual[
   versionqual].version = dmi.version, dmsversion->qual[versionqual].long_text_id = dmi.long_text_id,
   dmsversion->qual[versionqual].long_blob_id = dmi.long_blob_id, dmsversion->qual[versionqual].
   content_uid = dmi.content_uid, dmsversion->qual[versionqual].dms_repository_id = dmi
   .dms_repository_id,
   dms_media_identifier_id = dmi.dms_media_identifier_id
   IF ((reply->version < dmi.version))
    reply->version = dmi.version
   ENDIF
  FOOT REPORT
   stat = alterlist(dmsversion->qual,versionqual)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "dms_add_media_instance failed: ",errmsg)
  GO TO end_script
 ENDIF
 IF ((request->register_ind=1)
  AND versionqual=0)
  SELECT INTO "nl:"
   FROM dms_media_instance dmi,
    dms_media_identifier dmid
   PLAN (dmi
    WHERE (dmi.content_uid=request->content_uid))
    JOIN (dmid
    WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id)
   ORDER BY dmi.version
   HEAD REPORT
    versionqual = 0
   DETAIL
    versionqual += 1
    IF (mod(versionqual,10)=1)
     stat = alterlist(dmsversion->qual,(versionqual+ 9))
    ENDIF
    dmsversion->qual[versionqual].dms_media_instance_id = dmi.dms_media_instance_id, dmsversion->
    qual[versionqual].version = dmi.version, dmsversion->qual[versionqual].long_text_id = dmi
    .long_text_id,
    dmsversion->qual[versionqual].long_blob_id = dmi.long_blob_id, dmsversion->qual[versionqual].
    content_uid = dmi.content_uid, dmsversion->qual[versionqual].dms_repository_id = dmi
    .dms_repository_id,
    dms_media_identifier_id = dmi.dms_media_identifier_id, reply->identifier = dmid
    .media_object_identifier
    IF ((reply->version < dmi.version))
     reply->version = dmi.version
    ENDIF
   FOOT REPORT
    stat = alterlist(dmsversion->qual,versionqual)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
 ENDIF
 CALL echorecord(dmsversion)
 IF (versionqual=0)
  SET request->disable_versioning = 0
  SET mv_one_updt = 0
 ELSE
  SELECT INTO "nl:"
   *
   FROM dms_media_instance dmi
   WHERE dmi.dms_media_identifier_id=dms_media_identifier_id
   WITH nocounter, forupdate(dmi)
  ;end select
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to lock row"
   GO TO end_script
  ENDIF
 ENDIF
 IF ((request->disable_versioning=0))
  SET reply->version += 1
 ENDIF
 IF ((0.0 < request->created_by_id))
  SET reply->created_by_id = request->created_by_id
 ELSE
  SET reply->created_by_id = reqinfo->updt_id
 ENDIF
 SET reply->created_dt_tm = cnvtdatetime(sysdate)
 IF ((((request->disable_versioning=1)) OR (mv_one_updt=1)) )
  SET reply->dms_media_instance_id = dmsversion->qual[versionqual].dms_media_instance_id
 ELSE
  SELECT INTO "nl:"
   nextseqnum = seq(dms_seq,nextval)
   FROM dual
   DETAIL
    reply->dms_media_instance_id = nextseqnum
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failed to retrieve the next available dms_seq"
   GO TO end_script
  ENDIF
 ENDIF
 IF (versionqual=0)
  SET dms_media_identifier_id = reply->dms_media_instance_id
  INSERT  FROM dms_media_identifier dmid
   SET dmid.dms_media_identifier_id = dms_media_identifier_id, dmid.media_object_identifier = request
    ->identifier, dmid.updt_dt_tm = cnvtdatetime(sysdate),
    dmid.updt_id = reqinfo->updt_id, dmid.updt_task = reqinfo->updt_task, dmid.updt_cnt = 0,
    dmid.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
 ENDIF
 FREE SET ins_meta_ind
 DECLARE ins_meta_ind = i2 WITH noconstant(1)
 FREE SET olddmsidmeta
 DECLARE olddmsidmeta = f8 WITH noconstant(0.0)
 IF (size(trim(request->metadata,3)) > 0)
  FREE SET oldltidmeta
  DECLARE oldltidmeta = f8 WITH noconstant(0.0)
  IF (versionqual > 0)
   SET i = versionqual
   WHILE (i >= 1)
    IF ((dmsversion->qual[i].long_text_id != 0.0))
     SET olddmsidmeta = dmsversion->qual[i].dms_media_instance_id
     SET oldltidmeta = dmsversion->qual[i].long_text_id
     SET i = 1
    ENDIF
    SET i -= 1
   ENDWHILE
  ENDIF
  IF (olddmsidmeta != 0.0)
   FREE SET oldmeta
   DECLARE oldmeta = vc WITH noconstant("")
   SELECT INTO "nl:"
    lt.long_text
    FROM long_text lt
    WHERE lt.long_text_id=oldltidmeta
    DETAIL
     oldmeta = lt.long_text
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
   IF (oldmeta=trim(request->metadata,3))
    SET reply->long_text_id = oldltidmeta
    SET ins_meta_ind = 0
   ENDIF
   IF ((dmsversion->qual[versionqual].long_text_id != 0.0)
    AND (((request->disable_versioning=1)) OR (mv_one_updt=1)) )
    SET reply->long_text_id = dmsversion->qual[versionqual].long_text_id
   ENDIF
  ENDIF
  IF (ins_meta_ind=1)
   IF ((((request->disable_versioning=1)) OR (mv_one_updt=1))
    AND (reply->long_text_id != 0.0))
    DELETE  FROM dms_media_metadata dmm
     WHERE (dmm.dms_media_instance_id=reply->dms_media_instance_id)
     WITH nocounter
    ;end delete
    SELECT INTO "nl:"
     lt.long_text_id
     FROM long_text lt
     WHERE (lt.long_text_id=reply->long_text_id)
     WITH nocounter, forupdate(lt)
    ;end select
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
    IF (curqual <= 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to lock the long_text metadata row"
     GO TO end_script
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.long_text = trim(request->metadata,3), lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id
       = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
      updt_applctx
     WHERE (lt.long_text_id=reply->long_text_id)
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
    IF (curqual <= 0)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to update metadata on locked row"
     GO TO end_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      reply->long_text_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to retrieve the next available long_data_seq"
     GO TO end_script
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->long_text_id, lt.parent_entity_name = "DMS_MEDIA_INSTANCE", lt
      .parent_entity_id = 0.0,
      lt.long_text = trim(request->metadata,3), lt.updt_id = reqinfo->updt_id, lt.updt_dt_tm =
      cnvtdatetime(sysdate),
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0,
      lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
      cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert the metadata"
     GO TO end_script
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF ((((request->disable_versioning=1)) OR (mv_one_updt=1))
   AND (dmsversion->qual[versionqual].long_text_id > 0.0))
   DELETE  FROM dms_media_metadata dmm
    WHERE (dmm.dms_media_instance_id=dmsversion->qual[versionqual].dms_media_instance_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((((request->disable_versioning=1)) OR (mv_one_updt=1)) )
  FREE SET lb_del_ind
  DECLARE lb_del_ind = i2 WITH noconstant(0)
  IF ((request->disable_versioning=0))
   FREE RECORD deleventrequest
   RECORD deleventrequest(
     1 qual[1]
       2 dms_media_instance_id = f8
   )
   SET deleventrequest->qual[1].dms_media_instance_id = reply->dms_media_instance_id
   EXECUTE dms_del_event  WITH replace("REQUEST","DELEVENTREQUEST")
   FREE RECORD deleventrequest
  ENDIF
  IF ((((request->content_uid != dmsversion->qual[versionqual].content_uid)) OR ((request->
  long_blob_id != dmsversion->qual[versionqual].long_blob_id))) )
   FREE SET numrefs
   DECLARE numrefs = i4 WITH noconstant(0)
   IF (size(trim(dmsversion->qual[versionqual].content_uid,3)) > 0)
    SELECT INTO "nl:"
     selnum = count(dmi.dms_media_instance_id)
     FROM dms_media_instance dmi
     WHERE dmi.dms_media_identifier_id=dms_media_identifier_id
      AND (dmi.content_uid=dmsversion->qual[versionqual].content_uid)
     HEAD REPORT
      numrefs = selnum
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
   ELSEIF ((dmsversion->qual[versionqual].long_blob_id != 0.0))
    SELECT INTO "nl:"
     selnum = count(dmi.dms_media_instance_id)
     FROM dms_media_instance dmi
     WHERE dmi.dms_media_identifier_id=dms_media_identifier_id
      AND (dmi.long_blob_id=dmsversion->qual[versionqual].long_blob_id)
     HEAD REPORT
      numrefs = selnum
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dms_add_media_instance failed: ",errmsg)
     GO TO end_script
    ENDIF
    IF (numrefs=1)
     FREE RECORD delmediacontentrequest
     RECORD delmediacontentrequest(
       1 long_blob_id = f8
       1 dms_media_instance_id = f8
     )
     SET delmediacontentrequest->long_blob_id = dmsversion->qual[versionqual].long_blob_id
     SET lb_del_ind = 1
    ENDIF
   ENDIF
  ENDIF
  IF (((has_content=1) OR ((request->register_ind=1))) )
   UPDATE  FROM dms_media_instance dmi
    SET dmi.version = reply->version, dmi.content_type = " ", dmi.content_uid = request->content_uid,
     dmi.content_size = request->content_size, dmi.media_type = request->media_type, dmi
     .thumbnail_uid = request->thumbnail_uid,
     dmi.created_by_id = reply->created_by_id, dmi.created_dt_tm = cnvtdatetime(reply->created_dt_tm),
     dmi.updt_dt_tm = cnvtdatetime(sysdate),
     dmi.updt_id = reqinfo->updt_id, dmi.updt_task = reqinfo->updt_task, dmi.updt_cnt = (dmi.updt_cnt
     + 1),
     dmi.updt_applctx = reqinfo->updt_applctx, dmi.dms_content_type_id = request->dms_content_type_id,
     dmi.name = trim(substring(1,60,request->name)),
     dmi.metadata_version = request->metadata_ver, dmi.long_text_id = reply->long_text_id, dmi
     .status_flag = request->status_flag,
     dmi.checksum = request->checksum, dmi.dms_repository_id = request->dms_repository_id, dmi
     .long_blob_id = request->long_blob_id,
     dmi.dms_media_identifier_group_id = dms_media_identifier_group_id, dmi.servicestart_dt_tm =
     cnvtdatetime(request->servicestart_date), dmi.servicestop_dt_tm = cnvtdatetime(request->
      servicestop_date),
     dmi.consumercreated_dt_tm = cnvtdatetime(request->consumercreated_date), dmi.stored_as_dicom_ind
      = request->dicom_ind
    WHERE (dmi.dms_media_instance_id=reply->dms_media_instance_id)
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
   IF (curqual <= 0)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to update a locked row"
    GO TO end_script
   ENDIF
  ELSE
   UPDATE  FROM dms_media_instance dmi
    SET dmi.version = reply->version, dmi.content_type = " ", dmi.content_uid = request->content_uid,
     dmi.content_size = request->content_size, dmi.media_type = request->media_type, dmi
     .thumbnail_uid = request->thumbnail_uid,
     dmi.updt_dt_tm = cnvtdatetime(sysdate), dmi.updt_id = reqinfo->updt_id, dmi.updt_task = reqinfo
     ->updt_task,
     dmi.updt_cnt = (dmi.updt_cnt+ 1), dmi.updt_applctx = reqinfo->updt_applctx, dmi
     .dms_content_type_id = request->dms_content_type_id,
     dmi.name = trim(substring(1,60,request->name)), dmi.metadata_version = request->metadata_ver,
     dmi.long_text_id = reply->long_text_id,
     dmi.status_flag = request->status_flag, dmi.checksum = request->checksum, dmi.dms_repository_id
      = request->dms_repository_id,
     dmi.long_blob_id = request->long_blob_id, dmi.dms_media_identifier_group_id =
     dms_media_identifier_group_id, dmi.servicestart_dt_tm = cnvtdatetime(request->servicestart_date),
     dmi.servicestop_dt_tm = cnvtdatetime(request->servicestop_date), dmi.consumercreated_dt_tm =
     cnvtdatetime(request->consumercreated_date), dmi.stored_as_dicom_ind = request->dicom_ind
    WHERE (dmi.dms_media_instance_id=reply->dms_media_instance_id)
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
   IF (curqual <= 0)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to update a locked row"
    GO TO end_script
   ENDIF
  ENDIF
  IF (size(trim(request->metadata,3)) <= 0
   AND (dmsversion->qual[versionqual].long_text_id > 0.0))
   DELETE  FROM long_text lt
    WHERE (lt.long_text_id=dmsversion->qual[versionqual].long_text_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
  ENDIF
  IF (lb_del_ind=1)
   EXECUTE mmf_delete_media_content  WITH replace("REQUEST","DELMEDIACONTENTREQUEST")
   IF ((reply->status_data.status="F"))
    GO TO end_script
   ENDIF
  ENDIF
 ELSE
  INSERT  FROM dms_media_instance dmi
   SET dmi.dms_media_instance_id = reply->dms_media_instance_id, dmi.version = reply->version, dmi
    .content_type = " ",
    dmi.content_uid = request->content_uid, dmi.content_size = request->content_size, dmi.media_type
     = request->media_type,
    dmi.thumbnail_uid = request->thumbnail_uid, dmi.created_by_id = reply->created_by_id, dmi
    .created_dt_tm = cnvtdatetime(reply->created_dt_tm),
    dmi.updt_dt_tm = cnvtdatetime(reply->created_dt_tm), dmi.updt_id = reqinfo->updt_id, dmi
    .updt_task = reqinfo->updt_task,
    dmi.updt_cnt = 0, dmi.updt_applctx = reqinfo->updt_applctx, dmi.dms_content_type_id = request->
    dms_content_type_id,
    dmi.name = trim(substring(1,60,request->name)), dmi.metadata_version = request->metadata_ver, dmi
    .long_text_id = reply->long_text_id,
    dmi.status_flag = request->status_flag, dmi.checksum = request->checksum, dmi.dms_repository_id
     = request->dms_repository_id,
    dmi.long_blob_id = request->long_blob_id, dmi.dms_media_identifier_id = dms_media_identifier_id,
    dmi.dms_media_identifier_group_id = dms_media_identifier_group_id,
    dmi.servicestart_dt_tm = cnvtdatetime(request->servicestart_date), dmi.servicestop_dt_tm =
    cnvtdatetime(request->servicestop_date), dmi.consumercreated_dt_tm = cnvtdatetime(request->
     consumercreated_date),
    dmi.stored_as_dicom_ind = request->dicom_ind
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "dms_add_media_instance failed: ",errmsg)
   GO TO end_script
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert the media instance"
   GO TO end_script
  ENDIF
 ENDIF
 IF ((reply->long_text_id > 0)
  AND  NOT (ins_meta_ind=0
  AND (((request->disable_versioning=1)) OR (mv_one_updt=1))
  AND (reply->dms_media_instance_id=olddmsidmeta)))
  FREE SET numtags
  DECLARE numtags = i4 WITH noconstant(0)
  SET numtags = size(request->metadata_tags,5)
  IF (numtags > 0)
   INSERT  FROM dms_media_metadata dmm,
     (dummyt d  WITH seq = value(numtags))
    SET dmm.dms_media_metadata_id = cnvtreal(seq(dms_seq,nextval)), dmm.dms_media_instance_id = reply
     ->dms_media_instance_id, dmm.tag_name = request->metadata_tags[d.seq].tag_name,
     dmm.tag_path = request->metadata_tags[d.seq].tag_path, dmm.tag_value = request->metadata_tags[d
     .seq].tag_value, dmm.tag_seq = request->metadata_tags[d.seq].tag_seq,
     dmm.updt_id = reqinfo->updt_id, dmm.updt_dt_tm = cnvtdatetime(sysdate), dmm.updt_task = reqinfo
     ->updt_task,
     dmm.updt_applctx = reqinfo->updt_applctx, dmm.updt_cnt = 0
    PLAN (d)
     JOIN (dmm)
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "dms_add_media_instance failed: ",errmsg)
    GO TO end_script
   ENDIF
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_METADATA"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to insert the parsed metadata"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->max_versions >= 0))
  FREE SET purgebound
  DECLARE purgebound = i4 WITH noconstant((reply->version - request->max_versions))
  IF (0 < purgebound
   AND mv_one_updt=0)
   CALL echo(build("purgeBound=",purgebound))
   FREE SET delrequest
   RECORD delrequest(
     1 dms_media_instance_id = f8
     1 identifier = vc
     1 version = i4
   )
   FREE SET delgrprequest
   RECORD delgrprequest(
     1 identifier = vc
     1 version = i4
     1 delete_members = i2
   )
   FOR (i = 1 TO versionqual)
     IF ((dmsversion->qual[i].version <= purgebound))
      IF ((request->identifier=request->group_identifier))
       SET delgrprequest->identifier = request->identifier
       SET delgrprequest->version = dmsversion->qual[i].version
       SET delgrprequest->delete_members = 0
       EXECUTE mmf_delete_media_group  WITH replace("REQUEST","DELGRPREQUEST")
      ELSE
       SET delrequest->dms_media_instance_id = dmsversion->qual[i].dms_media_instance_id
       EXECUTE mmf_delete_media_object  WITH replace("REQUEST","DELREQUEST")
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_MEDIA_INSTANCE Script ====================>")
END GO
