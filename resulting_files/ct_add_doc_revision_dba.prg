CREATE PROGRAM ct_add_doc_revision:dba
 RECORD reply(
   1 msgs[*]
     2 text = c100
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
 DECLARE cdf_consent = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_protocol = f8 WITH protect, noconstant(0.0)
 DECLARE protocol_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_amend_id = f8 WITH protect, noconstant(0.0)
 DECLARE revision_id = f8 WITH protect, noconstant(0.0)
 SET prot_amend_id = request->prot_amendment_id
 SET revision_id = request->revision_id
 SET true = 1
 SET false = 0
 SET revsync = false
 SET pdoinsert = false
 IF (((prot_amend_id=0) OR (revision_id=0)) )
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->msgs,1)
  SET reply->msgs[1].text = "Amendment ID or Revision ID Unknown"
  RETURN
 ENDIF
 RECORD newdoc(
   1 title = c40
   1 ct_document_id = f8
   1 docbegin = dq8
   1 docend = dq8
   1 description = vc
   1 document_type_cd = f8
   1 prot_amendment_id = f8
   1 ct_document_version_id = f8
   1 verbegin = dq8
   1 verend = dq8
   1 version_nbr = i4
   1 version_description = vc
   1 file_name = vc
   1 revision_id = f8
   1 long_blob_id = f8
   1 long_blob = vgc
   1 print_with_consent_ind = i2
   1 display_ind = i2
   1 utcmaxdate = dq8
 )
 SET stat = uar_get_meaning_by_codeset(17304,"PROTOCOL",1,cdf_protocol)
 SET stat = uar_get_meaning_by_codeset(17304,"CONSENT",1,cdf_consent)
 SET protocol_id = 0.0
 SELECT INTO "nl;"
  p.prot_master_id
  FROM prot_amendment p
  WHERE p.prot_amendment_id=prot_amend_id
  DETAIL
   protocol_id = p.prot_master_id
  WITH nocounter
 ;end select
 IF (protocol_id=0)
  RETURN
 ENDIF
 CALL echo(build("Protocol_ID=",protocol_id))
 CALL echo(build("Prot_Amend_Id=",prot_amend_id))
 SET datemax = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET datetoday = cnvtdatetime(sysdate)
 IF ((request->syncamendment=true))
  CALL echo(build("checking protocol amendments"))
  SELECT INTO "nl;"
   d.ct_document_id
   FROM ct_document d,
    ct_document_version v
   WHERE d.prot_amendment_id=prot_amend_id
    AND d.ct_document_id=v.ct_document_id
    AND v.revision_id > 0
    AND d.document_type_cd=cdf_protocol
  ;end select
  IF (curqual=0)
   SET pdoinsert = true
   CALL echo(build("There are no protocol documents that match this criteria"))
   SELECT INTO "nl;"
    d.*, v.*
    FROM ct_document d,
     ct_document_version v
    WHERE d.ct_document_id=v.ct_document_id
     AND v.revision_id > 0
     AND d.document_type_cd=cdf_protocol
     AND d.prot_amendment_id IN (
    (SELECT
     prot_amendment_id
     FROM prot_amendment
     WHERE prot_master_id=protocol_id))
    ORDER BY d.ct_document_id, v.end_effective_dt_tm
    FOOT  d.ct_document_id
     newdoc->title = d.title, newdoc->docbegin = datetoday, newdoc->docend = datemax,
     newdoc->description = d.description, newdoc->document_type_cd = cdf_protocol, newdoc->
     prot_amendment_id = prot_amend_id,
     newdoc->verbegin = datetoday, newdoc->verend = datemax, newdoc->version_nbr = 1,
     newdoc->version_description = v.version_description, newdoc->file_name = v.file_name, newdoc->
     revision_id = revision_id,
     newdoc->long_blob_id = v.long_blob_id, newdoc->print_with_consent_ind = v.print_with_consent_ind,
     newdoc->display_ind = v.display_ind,
     newdoc->utcmaxdate = request->utcmaxdate
    WITH counter
   ;end select
   IF (curqual=0)
    SET newdoc->title = "<untitled document>"
    SET newdoc->docbegin = datetoday
    SET newdoc->docend = datemax
    SET newdoc->description = "<untitled protocol document>"
    SET newdoc->document_type_cd = cdf_protocol
    SET newdoc->prot_amendment_id = prot_amend_id
    SET newdoc->verbegin = datetoday
    SET newdoc->verend = datemax
    SET newdoc->version_nbr = 1
    SET newdoc->version_description = "<untitled version description>"
    SET newdoc->file_name = "<untitled - default filename>"
    SET newdoc->revision_id = revision_id
    SET newdoc->print_with_consent_ind = 0
    SET newdoc->display_ind = 0
    SET newdoc->utcmaxdate = request->utcmaxdate
   ENDIF
   SET pnewdoc = true
   EXECUTE ct_add_doc_revision_ins
   IF (pdoinsert=false)
    CALL echo(build(" SAVING THE NEW DOCUMENT FAILED"))
    ROLLBACK
   ELSE
    CALL echo(build(" SUCCESSFULL AT SAVING THE NEW DOCUMENT"))
    COMMIT
   ENDIF
   SET pdoinsert = false
  ENDIF
  CALL echo(build("end of checking protocol amendments"))
  CALL echo(build("checking consent documents amendments"))
  SELECT INTO "nl;"
   d.ct_document_id
   FROM ct_document d,
    ct_document_version v
   WHERE d.prot_amendment_id=prot_amend_id
    AND d.ct_document_id=v.ct_document_id
    AND v.revision_id > 0
    AND d.document_type_cd=cdf_consent
  ;end select
  IF (curqual=0)
   SET pdoinsert = true
   SELECT INTO "nl;"
    d.*, v.*
    FROM ct_document d,
     ct_document_version v
    WHERE d.ct_document_id=v.ct_document_id
     AND v.revision_id > 0
     AND d.document_type_cd=cdf_consent
     AND d.prot_amendment_id IN (
    (SELECT
     prot_amendment_id
     FROM prot_amendment
     WHERE prot_master_id=protocol_id))
    ORDER BY d.ct_document_id, v.end_effective_dt_tm
    FOOT  d.ct_document_id
     newdoc->title = d.title, newdoc->docbegin = datetoday, newdoc->docend = datemax,
     newdoc->description = d.description, newdoc->document_type_cd = cdf_consent, newdoc->
     prot_amendment_id = prot_amend_id,
     newdoc->verbegin = datetoday, newdoc->verend = datemax, newdoc->version_nbr = 1,
     newdoc->version_description = v.version_description, newdoc->file_name = v.file_name, newdoc->
     revision_id = revision_id,
     newdoc->long_blob_id = v.long_blob_id, newdoc->print_with_consent_ind = v.print_with_consent_ind,
     newdoc->display_ind = v.display_ind,
     newdoc->utcmaxdate = request->utcmaxdate
    WITH counter
   ;end select
   IF (curqual=0)
    SET newdoc->title = "<untitled consent document>"
    SET newdoc->docbegin = datetoday
    SET newdoc->docend = datemax
    SET newdoc->description = "<untitled consent document>"
    SET newdoc->document_type_cd = cdf_consent
    SET newdoc->prot_amendment_id = prot_amend_id
    SET newdoc->verbegin = datetoday
    SET newdoc->verend = datemax
    SET newdoc->version_nbr = 1
    SET newdoc->version_description = "<untitled version description>"
    SET newdoc->file_name = "<untitled - default filename>"
    SET newdoc->revision_id = revision_id
    SET newdoc->print_with_consent_ind = 0
    SET newdoc->display_ind = 0
    SET newdoc->utcmaxdate = request->utcmaxdate
   ENDIF
   SET pnewdoc = truebe
   EXECUTE ct_add_doc_revision_ins
   IF (pdoinsert=false)
    CALL echo(build(" SAVING THE NEW DOCUMENT FAILED"))
    ROLLBACK
   ELSE
    CALL echo(build(" SUCCESSFULL AT SAVING THE NEW DOCUMENT"))
    COMMIT
   ENDIF
  ENDIF
  CALL echo(build("end of checking consent documents amendments"))
 ELSE
  RECORD newver(
    1 qual[*]
      2 prot_amendment_id = f8
      2 ct_document_id = f8
      2 revision_id = f8
      2 verbegin = dq8
      2 verend = dq8
      2 version_nbr = i4
      2 version_description = vc
      2 file_name = vc
      2 revision_id = f8
      2 long_blob_id = f8
      2 print_with_consent_ind = i2
      2 display_ind = i2
  )
  SET revnbr = 0.0
  CALL echo(" -Finding the RevNbr from REVISION")
  SELECT INTO "nl;"
   r.revision_nbr
   FROM revision r
   WHERE r.revision_id=revision_id
   DETAIL
    revnbr = r.revision_nbr
   WITH nocounter
  ;end select
  SET cnta = 0
  SET cntc = 0
  CALL echo(" -Calculating Target Doc/Ver Pairs")
  CALL echo(build("Revision_Id=",revision_id))
  CALL echo(build("Prot_Amend_Id=",prot_amend_id))
  SELECT INTO "nl;"
   d.prot_amendment_id, d.document_type_cd, v.*
   FROM ct_document d,
    ct_document_version v
   WHERE d.ct_document_id=v.ct_document_id
    AND d.prot_amendment_id=prot_amend_id
    AND v.revision_id > 0
   ORDER BY v.ct_document_id, v.revision_id
   FOOT  v.ct_document_id
    IF (v.revision_id < revision_id)
     cnta += 1
     IF (mod(cnta,10)=1)
      new = (cnta+ 10), stat = alterlist(newver->qual,new)
     ENDIF
     newver->qual[cnta].prot_amendment_id = d.prot_amendment_id, newver->qual[cnta].ct_document_id =
     v.ct_document_id, newver->qual[cnta].verbegin = cnvtdatetime(sysdate),
     newver->qual[cnta].verend = cnvtdatetime("31-DEC-2100 00:00:00.00"), newver->qual[cnta].
     version_nbr = revnbr, newver->qual[cnta].version_description = build("[Copy Of] ",v
      .version_description),
     newver->qual[cnta].file_name = v.file_name, newver->qual[cnta].revision_id = revision_id, newver
     ->qual[cnta].long_blob_id = v.long_blob_id,
     nwever->qual[cnta].print_with_consent_ind = v.print_with_consent_ind, newver->qual[cnta].
     display_ind = v.display_ind
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("Number that pased = ",cnta))
  SET pnewdoc = false
  SET pdoinsert = true
  FOR (cntb = 1 TO cnta)
    IF (pdoinsert=true)
     SET newdoc->prot_amendment_id = newver->qual[cntb].prot_amendment_id
     SET newdoc->ct_document_id = newver->qual[cntb].ct_document_id
     SET newdoc->revision_id = newver->qual[cntb].revision_id
     SET newdoc->verbegin = newver->qual[cntb].verbegin
     SET newdoc->verend = newver->qual[cntb].verend
     SET newdoc->version_nbr = newver->qual[cntb].version_nbr
     SET newdoc->version_description = newver->qual[cntb].version_description
     SET newdoc->file_name = newver->qual[cntb].file_name
     SET newdoc->revision_id = newver->qual[cntb].revision_id
     SET newdoc->long_blob_id = newver->qual[cntb].long_blob_id
     SET newdoc->print_with_consent_ind = newver->qual[cntb].print_with_consent_ind
     SET newdoc->display_ind = newver->qual[cntb].display_ind
     SET newdoc->utcmaxdate = request->utcmaxdate
     SET pdoinsert = true
     EXECUTE ct_add_doc_revision_ins
    ENDIF
  ENDFOR
 ENDIF
 SET revsync = pdoinsert
 SET reqinfo->commit_ind = pdoinsert
 IF (revsync=true)
  SET reply->status_data.status = "S"
  CALL echo(build("RevSync is = TRUE"))
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->msgs,1)
  SET reply->msgs[1].text = ""
  CALL echo(build("RevSync is = FALSE"))
 ENDIF
 SET last_mod = "002"
 SET mod_date = "March 5, 2008"
END GO
