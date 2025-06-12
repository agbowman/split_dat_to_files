CREATE PROGRAM ct_del_doc_or_ver:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD verlist(
   1 qual[*]
     2 ver_id = f8
 )
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE removedoc = i2 WITH protect, noconstant(false)
 DECLARE oktodelete = i2 WITH protect, noconstant(false)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE docid = f8 WITH protect, noconstant(0.0)
 DECLARE verid = f8 WITH protect, noconstant(0.0)
 DECLARE blobid = f8 WITH protect, noconstant(0.0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET reply->status_data.status = "F"
 SET docid = request->ct_document_id
 CALL echo(build("DocId = ",docid))
 SET verid = request->ct_document_version_id
 CALL echo(build("VerId = ",verid))
 IF (docid > 0)
  SET removedoc = true
 ENDIF
 IF (((verid > 0) OR (docid > 0)) )
  SET oktodelete = true
 ENDIF
 CALL echo(build("RemoveDoc =",removedoc))
 CALL echo(build("OkToDelete = ",oktodelete))
 IF (removedoc=false
  AND oktodelete=true)
  SET cnta = 0
  SELECT INTO "nl:"
   v.ct_document_id
   FROM ct_document_version v
   WHERE v.ct_document_id IN (
   (SELECT
    ct_document_id
    FROM ct_document_version
    WHERE ct_document_version_id=verid))
    AND v.prev_ct_document_version_id=v.ct_document_version_id
   DETAIL
    cnta += 1, docid = v.ct_document_id
   WITH nocounter
  ;end select
  CALL echo(build("curqual for multi vers  =",cnta))
  IF (cnta < 1)
   SET oktodelete = false
   CALL echo(build(" -hence the OktoDelete = ",oktodelete))
  ELSE
   IF (cnta=1)
    SET removedoc = true
   ENDIF
  ENDIF
  CALL echo(build(" -hence the RemoveDoc = ",removedoc))
 ENDIF
 CALL echo("ENTERING THE RULE AREA")
 IF (oktodelete=true)
  IF (verid > 0)
   SELECT INTO "nl:"
    pt.ct_document_version_id
    FROM pt_consent pt
    WHERE pt.ct_document_version_id=verid
     AND ((pt.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (pt.end_effective_dt_tm
     >= cnvtdatetime(request->utcmaxdate)))
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pt.ct_document_version_id
    FROM pt_consent pt,
     ct_document_version dv
    WHERE pt.ct_document_version_id=dv.ct_document_version_id
     AND dv.ct_document_id=docid
     AND ((pt.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")) OR (pt.end_effective_dt_tm
     >= cnvtdatetime(request->utcmaxdate)))
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build("The 'curqual' of pt_consent rules is =",curqual))
  IF (curqual > 0)
   SET oktodelete = false
   SET reply->status_data.status = "F"
  ENDIF
  CALL echo(build("The Result of the Rule Check is = ",oktodelete))
 ENDIF
 CALL echo("EXITING THE RULE AREA")
 CALL echo("ENTERING THE PROCESSING AREA")
 IF (oktodelete=true)
  IF (removedoc=true)
   CALL echo("ENTERING THE DELETION OF THE DOC AREA")
   UPDATE  FROM questionnaire_doc_reltn qd
    SET qd.active_ind = 0, qd.updt_cnt = (qd.updt_cnt+ 1), qd.updt_dt_tm = cnvtdatetime(sysdate),
     qd.updt_applctx = reqinfo->updt_applctx, qd.active_status_cd = reqdata->active_status_cd, qd
     .active_status_dt_tm = cnvtdatetime(sysdate),
     qd.active_status_prsnl_id = reqinfo->updt_id, qd.updt_id = reqinfo->updt_id, qd.updt_task =
     reqinfo->updt_task
    WHERE qd.ct_document_id=docid
    WITH nocounter
   ;end update
   INSERT  FROM ct_document doc
    (doc.begin_effective_dt_tm, doc.end_effective_dt_tm, doc.ct_document_id,
    doc.description, doc.document_type_cd, doc.prev_ct_document_id,
    doc.prot_amendment_id, doc.title, doc.updt_applctx,
    doc.updt_cnt, doc.updt_dt_tm, doc.updt_id,
    doc.updt_task)(SELECT
     doc1.begin_effective_dt_tm, cnvtdatetime(script_date), seq(protocol_def_seq,nextval),
     doc1.description, doc1.document_type_cd, doc1.prev_ct_document_id,
     doc1.prot_amendment_id, doc1.title, doc1.updt_applctx,
     doc1.updt_cnt, doc1.updt_dt_tm, doc1.updt_id,
     doc1.updt_task
     FROM ct_document doc1
     WHERE doc1.ct_document_id=docid)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "Error inserting versioned record into the ct_document table.",errmsg)
    SET oktodelete = false
   ELSE
    UPDATE  FROM ct_document d
     SET d.begin_effective_dt_tm = cnvtdatetime(script_date), d.end_effective_dt_tm = cnvtdatetime(
       script_date), d.updt_applctx = reqinfo->updt_applctx,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->
      updt_id,
      d.updt_task = reqinfo->updt_task
     WHERE d.ct_document_id=docid
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET oktodelete = true
    ELSE
     SET oktodelete = false
    ENDIF
   ENDIF
   CALL echo(build(" - so the OkToDelete is ",oktodelete))
  ENDIF
 ENDIF
 IF (oktodelete=true)
  IF (removedoc=true)
   CALL echo("GETTING LIST OF DOCUMENT VERSIONS")
   SELECT INTO "nl:"
    FROM ct_document_version ver
    WHERE ver.ct_document_id=docid
     AND ver.end_effective_dt_tm > cnvtdatetime(sysdate)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(verlist->qual,(cnt+ 10))
     ENDIF
     verlist->qual[cnt].ver_id = ver.ct_document_version_id
    FOOT REPORT
     stat = alterlist(verlist->qual,cnt)
    WITH nocounter
   ;end select
  ELSE
   SET stat = alterlist(verlist->qual,1)
   SET verlist->qual[1].ver_id = verid
   SET cnt = 1
  ENDIF
  CALL echo("ENTERING THE BLOB DEL AREA")
  FOR (idx = 1 TO cnt)
    UPDATE  FROM ct_document_blob b
     SET b.active_ind = 0, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate),
      b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
      updt_task
     WHERE (b.ct_document_version_id=verlist->qual[idx].ver_id)
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "Error updating the ct_document_blob table.",errmsg)
     SET oktodelete = false
    ENDIF
    CALL echo("ENTERING THE VERSION DELETION OVER THE PROCOTOL AREA")
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
      WHERE (ver1.ct_document_version_id=verlist->qual[idx].ver_id))
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "Error inserting versioned record into the ct_document_version table.",errmsg)
     SET oktodelete = false
    ELSE
     UPDATE  FROM ct_document_version ver
      SET ver.active_ind = 0, ver.begin_effective_dt_tm = cnvtdatetime(script_date), ver
       .end_effective_dt_tm = cnvtdatetime(script_date),
       ver.updt_applctx = reqinfo->updt_applctx, ver.updt_cnt = (ver.updt_cnt+ 1), ver.updt_dt_tm =
       cnvtdatetime(sysdate),
       ver.updt_id = reqinfo->updt_id, ver.updt_task = reqinfo->updt_task
      WHERE (ver.ct_document_version_id=verlist->qual[idx].ver_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET oktodelete = false
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error updating into ct_document_version. ()"
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET reqinfo->commit_ind = oktodelete
 IF (oktodelete=true)
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Sept 19, 2021"
END GO
