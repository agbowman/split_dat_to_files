CREATE PROGRAM ct_add_doc_revision_ins:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET pfalse = 0
 SET ptrue = 1
 SET pdocid = 0.0
 SET pverid = 0.0
 SET pblobid = 0.0
 IF (pnewdoc=ptrue)
  SELECT INTO "nl:"
   temp_seq = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    pdocid = temp_seq
   WITH format, counter
  ;end select
  SET pdoinsert = pfalse
  INSERT  FROM ct_document doc
   SET doc.begin_effective_dt_tm =
    IF ((newdoc->docbegin != 0)) cnvtdatetime(newdoc->docbegin)
    ELSE cnvtdatetime(sysdate)
    ENDIF
    , doc.end_effective_dt_tm =
    IF ((newdoc->docend != 0)) cnvtdatetime(newdoc->docend)
    ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    , doc.title = newdoc->title,
    doc.ct_document_id = pdocid, doc.description = newdoc->description, doc.document_type_cd = newdoc
    ->document_type_cd,
    doc.prot_amendment_id = newdoc->prot_amendment_id, doc.updt_cnt = 0, doc.updt_applctx = reqinfo->
    updt_applctx,
    doc.updt_task = reqinfo->updt_task, doc.updt_id = reqinfo->updt_id, doc.updt_dt_tm = cnvtdatetime
    (sysdate)
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET pdoinsert = ptrue
  ENDIF
 ENDIF
 CALL echo(build(" pDoInsert @ beging of include =",pdoinsert))
 IF (pdoinsert=pfalse)
  RETURN
 ENDIF
 SET lcurqual = 0
 SET pdoinsert = ptrue
 SET lcurqual = 0
 IF (pnewdoc=pfalse)
  CALL echo(build(" -for document =",newdoc->ct_document_id))
  CALL echo(build("Processing As An Old Document - Add the Version Only"))
  SELECT INTO "nl:"
   dv.ct_document_version_id
   FROM ct_document_version dv
   WHERE (dv.ct_document_id=newdoc->ct_document_id)
    AND ((dv.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")) OR (dv.end_effective_dt_tm
    >= cnvtdatetime(newdoc->utcmaxdate)))
   DETAIL
    lcurqual += 1, pverid = dv.ct_document_version_id
   WITH nocounter
  ;end select
  IF (lcurqual=1)
   UPDATE  FROM ct_document_version dv
    SET dv.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE dv.ct_document_version_id=pverid
   ;end update
  ELSE
   IF (lcurqual > 1)
    SET pdoinsert = pfalse
    CALL echo(build(" There Are Multiple Records With Open End Dates"))
   ENDIF
   CALL echo(build(" - n=",lcurqual))
  ENDIF
 ENDIF
 CALL echo(build(" pDoInsert @ end of rule =",pdoinsert))
 IF (pdoinsert=pfalse)
  RETURN
 ENDIF
 SELECT INTO "nl:"
  temp_seq = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   pverid = temp_seq
  WITH format, counter
 ;end select
 SET pdoinsert = pfalse
 CALL echo(build("Loading ct_document_version"))
 CALL echo(build(" -for document =",newdoc->ct_document_id))
 INSERT  FROM ct_document_version ver
  SET ver.begin_effective_dt_tm =
   IF ((newdoc->verbegin != 0)) cnvtdatetime(newdoc->verbegin)
   ELSE cnvtdatetime(sysdate)
   ENDIF
   , ver.end_effective_dt_tm =
   IF ((newdoc->verend != 0)) cnvtdatetime(newdoc->verend)
   ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
   ENDIF
   , ver.file_name = newdoc->file_name,
   ver.ct_document_version_id = pverid, ver.ct_document_id =
   IF (pnewdoc=ptrue) pdocid
   ELSE newdoc->ct_document_id
   ENDIF
   , ver.version_description = newdoc->version_description,
   ver.version_nbr = newdoc->version_nbr, ver.updt_cnt = 0, ver.updt_applctx = reqinfo->updt_applctx,
   ver.updt_task = reqinfo->updt_task, ver.updt_id = reqinfo->updt_id, ver.updt_dt_tm = cnvtdatetime(
    sysdate),
   ver.revision_id = newdoc->revision_id, ver.long_blob_id = pblobid, ver.print_with_consent_ind =
   newdoc->print_with_consent_ind,
   ver.display_ind = newdoc->display_ind
 ;end insert
 IF (curqual=1)
  SET pdoinsert = ptrue
 ENDIF
 CALL echo(build(" pDoInsert @ end of ver insert =",pdoinsert))
 SET last_mod = "003"
 SET mod_date = "Sept 19, 2021"
END GO
