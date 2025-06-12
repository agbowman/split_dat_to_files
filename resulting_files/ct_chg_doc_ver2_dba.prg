CREATE PROGRAM ct_chg_doc_ver2:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE doupdate = i2 WITH protect, noconstant(0)
 DECLARE curfilename = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE curverid = f8 WITH protect, noconstant(0.0)
 DECLARE curblobid = f8 WITH protect, noconstant(0.0)
 DECLARE blobsize = i4 WITH protect, noconstant(0)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET reply->status_data.status = "F"
 SET curupdtcnt = 0
 SET curfilename = ""
 SET curverid = request->ct_document_version_id
 SET curenddate = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET doupdate = false
 SET cnta = 0
 SELECT INTO "nl:"
  ver.*
  FROM ct_document_version ver,
   ct_document_blob b
  PLAN (ver
   WHERE ver.ct_document_version_id=curverid)
   JOIN (b
   WHERE (b.ct_document_version_id= Outerjoin(ver.ct_document_version_id))
    AND (b.active_ind= Outerjoin(1)) )
  DETAIL
   cnta += 1, curupdtcnt = ver.updt_cnt, curfilename = ver.file_name,
   curblobid = b.ct_document_blob_id, curenddate = ver.end_effective_dt_tm
  WITH nocounter, forupdate(ver)
 ;end select
 IF (cnta=1)
  IF ((curupdtcnt != request->updt_cnt))
   SET reply->status_data.status = "C"
   SET doupdate = false
   CALL echo(build("CurUpdtCnt = ",curupdtcnt))
  ELSE
   SET doupdate = true
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to lock the ct_document_version table for update."
  SET doupdate = false
 ENDIF
 IF (doupdate=true)
  SET cnta = 0
  IF ( NOT (((curenddate=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (curenddate=cnvtdatetime(request
   ->utcmaxdate))) ))
   SELECT INTO "nl:"
    v.*
    FROM ct_document_version v
    WHERE (v.ct_document_id=request->ct_document_id)
     AND (v.ct_document_version_id != request->ct_document_version_id)
     AND ((v.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (v.end_effective_dt_tm=
    cnvtdatetime(request->utcmaxdate)))
    DETAIL
     cnta += 1
    WITH nocounter
   ;end select
   IF (cnta > 0)
    SET reply->status_data.status = "M"
    SET doupdate = false
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Multple doc version records are active at the same time."
    CALL echo("failed in 2nd if")
   ENDIF
  ENDIF
 ENDIF
 IF (doupdate=true)
  IF ((request->file_name != curfilename))
   SELECT INTO "nl:"
    pt.ct_document_version_id
    FROM pt_consent pt
    WHERE pt.ct_document_version_id=curverid
     AND ((pt.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (pt.end_effective_dt_tm
    =cnvtdatetime(request->utcmaxdate)))
   ;end select
   IF (curqual > 0)
    SET doupdate = false
    SET reply->status_data.status = "R"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to change document version because it is has been referenced in the pt_consent table."
   ENDIF
  ENDIF
 ENDIF
 IF (doupdate=true)
  SET doupdate = false
  INSERT  FROM ct_document_version ver
   (ver.begin_effective_dt_tm, ver.ct_document_id, ver.ct_document_version_id,
   ver.display_ind, ver.end_effective_dt_tm, ver.file_name,
   ver.long_blob_id, ver.prev_ct_document_version_id, ver.print_with_consent_ind,
   ver.revision_id, ver.version_description, ver.version_nbr,
   ver.updt_applctx, ver.updt_cnt, ver.updt_dt_tm,
   ver.updt_id, ver.updt_task)(SELECT
    ver1.begin_effective_dt_tm, ver1.ct_document_id, seq(protocol_def_seq,nextval),
    ver1.display_ind, cnvtdatetime(script_date), ver1.file_name,
    ver1.long_blob_id, ver1.prev_ct_document_version_id, ver1.print_with_consent_ind,
    ver1.revision_id, ver1.version_description, ver1.version_nbr,
    ver1.updt_applctx, ver1.updt_cnt, ver1.updt_dt_tm,
    ver1.updt_id, ver1.updt_task
    FROM ct_document_version ver1
    WHERE (ver1.ct_document_version_id=request->ct_document_version_id))
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error inserting versioned record into the ct_document_blob table.",errmsg)
   GO TO check_error
  ELSE
   SET doinsert = true
  ENDIF
  UPDATE  FROM ct_document_version ver
   SET ver.begin_effective_dt_tm =
    IF ((request->verbegin != 0)) cnvtdatetime(request->verbegin)
    ELSE cnvtdatetime(script_date)
    ENDIF
    , ver.end_effective_dt_tm =
    IF ((request->verend != 0)) cnvtdatetime(request->verend)
    ELSE ver.end_effective_dt_tm
    ENDIF
    , ver.file_name =
    IF ((request->file_name != "")) request->file_name
    ELSE ver.file_name
    ENDIF
    ,
    ver.version_description =
    IF ((request->version_description != "")) request->version_description
    ELSE ver.version_description
    ENDIF
    , ver.version_nbr =
    IF ((request->version_nbr != 0)) request->version_nbr
    ELSE ver.version_nbr
    ENDIF
    , ver.ct_document_id =
    IF ((request->ct_document_id != 0.0)) request->ct_document_id
    ELSE ver.ct_document_id
    ENDIF
    ,
    ver.revision_id =
    IF ((request->revision_id != 0.0)) request->revision_id
    ELSE ver.revision_id
    ENDIF
    , ver.print_with_consent_ind = request->print_with_consent_ind, ver.display_ind = request->
    display_ind,
    ver.updt_cnt = (ver.updt_cnt+ 1), ver.updt_applctx = reqinfo->updt_applctx, ver.updt_task =
    reqinfo->updt_task,
    ver.updt_id = reqinfo->updt_id, ver.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE (ver.ct_document_version_id=request->ct_document_version_id)
  ;end update
  IF (curqual=1)
   SET doupdate = true
  ELSE
   SET doupdate = false
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to update the ct_document_version record."
  ENDIF
  CALL echo(build("After Update and DoUpdate is: ",doupdate))
  IF (doupdate=true)
   IF ((request->long_blob_del_ind=1))
    UPDATE  FROM ct_document_blob b
     SET b.active_ind = 0, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate),
      b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
      updt_task
     WHERE (b.ct_document_version_id=request->ct_document_version_id)
      AND b.active_ind=1
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "Error inactivating the record in the ct_document_blob table.",errmsg)
     GO TO check_error
    ELSE
     SET doinsert = true
    ENDIF
   ELSEIF (size(request->long_blob,1) > 0)
    IF (curblobid > 0)
     SET blobsize = size(request->long_blob,1)
     UPDATE  FROM ct_document_blob b
      SET b.active_ind = 1, b.blob_length = blobsize, b.long_blob = request->long_blob,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->
       updt_id,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
      WHERE b.ct_document_blob_id=curblobid
      WITH nocounter
     ;end update
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
       "Error updating the ct_document_blob table.",errmsg)
      GO TO check_error
     ELSE
      SET doinsert = true
     ENDIF
    ELSE
     SET blobsize = size(request->long_blob,1)
     INSERT  FROM ct_document_blob blob
      SET blob.active_ind = 1, blob.ct_document_blob_id = seq(protocol_def_seq,nextval), blob
       .ct_document_version_id = request->ct_document_version_id,
       blob.long_blob = request->long_blob, blob.blob_length = blobsize, blob.updt_cnt = 0,
       blob.updt_applctx = reqinfo->updt_applctx, blob.updt_task = reqinfo->updt_task, blob.updt_id
        = reqinfo->updt_id,
       blob.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
       "Error inserting into the ct_document_blob table.",errmsg)
      GO TO check_error
     ELSE
      SET doinsert = true
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = doupdate
 IF (doupdate=true)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Reply->status_data->status = ",reply->status_data.status))
#check_error
 SET last_mod = "005"
 SET mod_date = "Sept 15, 2021"
END GO
