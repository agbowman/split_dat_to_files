CREATE PROGRAM ct_add_doc2:dba
 RECORD reply(
   1 ct_document_id = f8
   1 ct_document_version_id = f8
   1 long_blob_id = f8
   1 blob_length = i4
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
 DECLARE doinsert = i2 WITH protect, noconstant(false)
 DECLARE newdoc = i2 WITH protect, noconstant(true)
 DECLARE blobid = f8 WITH protect, noconstant(0.0)
 DECLARE verid = f8 WITH protect, noconstant(0.0)
 DECLARE docid = f8 WITH protect, noconstant(0.0)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 SET reply->status_data.status = "F"
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SET docid = nextsequence(0)
 SET doinsert = false
 IF ((request->document_type_cd <= 0.0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = "document type CDF not set"
  GO TO endgo
 ENDIF
 INSERT  FROM ct_document doc
  SET doc.begin_effective_dt_tm = cnvtdatetime(script_date), doc.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 00:00:00.00"), doc.title = request->title,
   doc.ct_document_id = docid, doc.description = request->description, doc.document_type_cd = request
   ->document_type_cd,
   doc.prot_amendment_id = request->prot_amendment_id, doc.prev_ct_document_id = docid, doc.updt_cnt
    = 0,
   doc.updt_applctx = reqinfo->updt_applctx, doc.updt_task = reqinfo->updt_task, doc.updt_id =
   reqinfo->updt_id,
   doc.updt_dt_tm = cnvtdatetime(sysdate)
  WITH nocounter
 ;end insert
 IF (curqual=1)
  SET doinsert = true
 ENDIF
 CALL echo(build(" DoInsert @ beging of include =",doinsert))
 DECLARE blobsize = i4 WITH protect, noconstant(0)
 IF (doinsert=true)
  SET lcurqual = 0
  SET doinsert = true
  SET lcurqual = 0
  IF (newdoc=false)
   CALL echo(build("Processing As An Old Document - Add the Version Only"))
   SELECT INTO "nl:"
    dv.ct_document_version_id
    FROM ct_document_version dv
    WHERE (dv.ct_document_id=request->ct_document_id)
     AND dv.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     lcurqual += 1, verid = dv.ct_document_version_id
    WITH nocounter
   ;end select
   IF (lcurqual=0)
    CALL echo(build("There are no previous docs to match the new version"))
   ELSE
    IF (lcurqual=1)
     CALL echo(build("lCurQual = 1 so just change that record"))
     INSERT  FROM ct_document_version ver
      (ver.active_ind, ver.begin_effective_dt_tm, ver.ct_document_id,
      ver.ct_document_version_id, ver.display_ind, ver.end_effective_dt_tm,
      ver.file_name, ver.long_blob_id, ver.prev_ct_document_version_id,
      ver.print_with_consent_ind, ver.revision_id, ver.version_description,
      ver.version_nbr, ver.updt_applctx, ver.updt_cnt,
      ver.updt_dt_tm, ver.updt_id, ver.updt_task)(SELECT
       ver1.active_ind, ver1.begin_effective_dt_tm, ver1.ct_document_id,
       seq(protocol_def_seq,nextval), ver1.display_ind, cnvtdatetime(script_date),
       ver1.file_name, ver1.long_blob_id, ver1.prev_ct_document_version_id,
       ver1.print_with_consent_ind, ver1.revision_id, ver1.version_description,
       ver1.version_nbr, ver1.updt_applctx, ver1.updt_cnt,
       ver1.updt_dt_tm, ver1.updt_id, ver1.updt_task
       FROM ct_document_version ver1
       WHERE ver1.ct_document_version_id=verid)
     ;end insert
     UPDATE  FROM ct_document_version ver
      SET ver.begin_effective_dt_tm = cnvtdatetime(script_date), ver.end_effective_dt_tm =
       cnvtdatetime(script_date), ver.updt_applctx = reqinfo->updt_applctx,
       ver.updt_cnt = (ver.updt_cnt+ 1), ver.updt_dt_tm = cnvtdatetime(sysdate), ver.updt_id =
       reqinfo->updt_id,
       ver.updt_task = reqinfo->updt_task
      WHERE ver.ct_document_version_id=verid
      WITH nocounter
     ;end update
    ELSE
     SET doinsert = false
     CALL echo(build("There Are Multiple Records With Open End Dates"))
    ENDIF
   ENDIF
  ENDIF
  CALL echo(build(" DoInsert @ end of rule =",doinsert))
  IF (doinsert=true)
   SET verid = nextsequence(0)
   SET doinsert = false
   IF ((request->revision_id > 0))
    CALL echo(build(" where request->revision_id >zero",request->revision_id))
    INSERT  FROM ct_document_version ver
     SET ver.begin_effective_dt_tm = cnvtdatetime(sysdate), ver.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), ver.file_name = request->file_name,
      ver.ct_document_version_id = verid, ver.ct_document_id = docid, ver.prev_ct_document_version_id
       = verid,
      ver.version_description = request->version_description, ver.version_nbr = request->version_nbr,
      ver.updt_cnt = 0,
      ver.updt_applctx = reqinfo->updt_applctx, ver.updt_task = reqinfo->updt_task, ver.updt_id =
      reqinfo->updt_id,
      ver.updt_dt_tm = cnvtdatetime(sysdate), ver.revision_id = request->revision_id, ver
      .print_with_consent_ind = request->print_with_consent_ind,
      ver.display_ind = request->display_ind, ver.active_ind = 1
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET doinsert = true
    ENDIF
   ELSE
    CALL echo(build(" where request->revision_id = zero",request->revision_id))
    INSERT  FROM ct_document_version ver
     SET ver.begin_effective_dt_tm = cnvtdatetime(sysdate), ver.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), ver.file_name = request->file_name,
      ver.ct_document_version_id = verid, ver.ct_document_id = docid, ver.prev_ct_document_version_id
       = verid,
      ver.version_description = request->version_description, ver.version_nbr = request->version_nbr,
      ver.print_with_consent_ind = request->print_with_consent_ind,
      ver.display_ind = request->display_ind, ver.active_ind = 1, ver.updt_cnt = 0,
      ver.updt_applctx = reqinfo->updt_applctx, ver.updt_task = reqinfo->updt_task, ver.updt_id =
      reqinfo->updt_id,
      ver.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET doinsert = true
    ENDIF
   ENDIF
   SET reply->debug = "Right before the DoInsert for inserting the blob."
   IF (doinsert=true)
    CALL echo(build("size(Request->long_blob, 1) = ",size(request->long_blob,1)))
    SET reply->debug = build("size(Request->long_blob, 1) = ",size(request->long_blob,1))
    IF (size(request->long_blob,1) > 0)
     SET doinsert = false
     CALL echo("Inserting into long blob table")
     SET blobid = nextsequence(0)
     SET blobsize = size(request->long_blob,1)
     SET reply->blob_length = blobsize
     INSERT  FROM ct_document_blob blob
      SET blob.active_ind = 1, blob.ct_document_blob_id = blobid, blob.ct_document_version_id = verid,
       blob.long_blob = request->long_blob, blob.blob_length = blobsize, blob.updt_cnt = 0,
       blob.updt_applctx = reqinfo->updt_applctx, blob.updt_task = reqinfo->updt_task, blob.updt_id
        = reqinfo->updt_id,
       blob.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,0)
     IF (errcode > 0)
      SET reply->debug = concat("Error inserting record into the ct_document_blob table.",errmsg)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
       "Error inserting record into the ct_document_blob table.",errmsg)
      SET doinsert = false
     ELSE
      SET doinsert = true
     ENDIF
     IF (curqual=1)
      SET doinsert = true
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = doinsert
 IF (doinsert=true)
  SET reply->status_data.status = "S"
  SET reply->ct_document_id = docid
  SET reply->ct_document_version_id = verid
  SET reply->long_blob_id = blobid
 ENDIF
 CALL echo(build("DocID = ",docid))
 CALL echo(build("VerID = ",verid))
 CALL echo(build("Reply->status_data->status = ",reply->status_data.status))
 SET last_mod = "006"
 SET mod_date = "May 15, 2012"
#endgo
END GO
