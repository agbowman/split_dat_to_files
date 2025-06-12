CREATE PROGRAM ct_get_docs2:dba
 RECORD reply(
   1 prot_mnemonic = c30
   1 protocol_docs_required_ind = i2
   1 consent_docs_required_ind = i2
   1 doctypes[*]
     2 desc = vc
     2 disp = vc
     2 mean = c12
     2 value = f8
   1 amendments[*]
     2 nbr = i4
     2 id = f8
     2 revision_nbr_txt = c30
     2 revision_ind = i2
   1 revisions[*]
     2 amendment_id = f8
     2 revision_description = vc
     2 revision_id = f8
     2 revision_nbr = i4
   1 docs[*]
     2 title = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 ct_document_id = f8
     2 description = vc
     2 document_type_cd = f8
     2 document_type_cd_disp = vc
     2 document_type_cd_mean = vc
     2 prot_amendment_id = f8
     2 updt_cnt = i4
     2 versions[*]
       3 begin_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 ct_document_version_id = f8
       3 version_nbr = i4
       3 version_description = vc
       3 file_name = vc
       3 revision_id = f8
       3 blob_length = i4
       3 print_with_consent_ind = i2
       3 display_ind = i2
       3 updt_cnt = i4
     2 reltns[*]
       3 questionnaire_doc_id = f8
       3 prot_questionnaire_id = f8
       3 ct_document_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
   1 printable_docs[*]
     2 title = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 ct_document_id = f8
     2 description = vc
     2 prot_amendment_id = f8
     2 updt_cnt = i4
     2 versions[*]
       3 begin_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 ct_document_version_id = f8
       3 version_nbr = i4
       3 version_description = vc
       3 file_name = vc
       3 revision_id = f8
       3 blob_length = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE protid = f8 WITH protect, noconstant(0.0)
 DECLARE cval = f8 WITH protect, noconstant(0.0)
 DECLARE cur_amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE whrtype = c240 WITH protect, noconstant(fillstring(240," "))
 DECLARE whrbegv = vc WITH protect, noconstant("")
 DECLARE whrendv = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE ver_cnt = i4 WITH protect, noconstant(0)
 DECLARE cntd = i4 WITH protect, noconstant(0)
 DECLARE cntv = i4 WITH protect, noconstant(0)
 DECLARE cnta = i4 WITH protect, noconstant(0)
 DECLARE cntt = i4 WITH protect, noconstant(0)
 DECLARE cntr = i4 WITH protect, noconstant(0)
 DECLARE new = i4 WITH protect, noconstant(0)
 DECLARE protdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"PROTDOC"))
 DECLARE consentdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"CONSENTDOC"))
 DECLARE required_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"REQUIRED"))
 SET protid = 0.0
 SET cval = 0.0
 IF ((request->prot_master_id != 0))
  SET protid = request->prot_master_id
  SET whrid = build("pa.prot_master_id = ",request->prot_master_id)
 ELSE
  SELECT INTO "nl:"
   pr_am.prot_master_id
   FROM prot_amendment pr_am
   PLAN (pr_am
    WHERE (pr_am.prot_amendment_id=request->prot_amendment_id))
   DETAIL
    protid = pr_am.prot_master_id
   WITH nocounter
  ;end select
  SET whrid = build("pa.prot_amendment_id = ",request->prot_amendment_id)
 ENDIF
 IF ((request->document_type_mean != ""))
  CALL echo(build("Request->document_type_mean = ",request->document_type_mean))
  SET cval = uar_get_code_by("MEANING",17304,nullterm(request->document_type_mean))
  SET whrtype = build("doc.document_type_cd = ",cval)
 ELSE
  IF ((request->document_type_cd != 0))
   SET whrtype = build("doc.document_type_cd =",request->document_type_cd)
  ELSE
   SET whrtype = "1=1"
  ENDIF
 ENDIF
 CALL echo(build("whrType =",whrtype))
 CALL echo(build("whrId =",whrid))
 IF ((request->query_dt_tm=0))
  SET whrbegd = "1=1"
  SET whrendd = "doc.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)"
  SET whrbegv = "1=1"
  SET whrendv = "1=1"
 ELSE
  SET whrbegd = "doc.begin_effective_dt_tm <= cnvtdatetime(Request->query_dt_tm)"
  SET whrendd = "doc.end_effective_dt_tm >= cnvtdatetime(Request->query_dt_tm)"
  SET whrbegv = "1=1"
  SET whrendv = "1=1"
 ENDIF
 IF ((request->display_ind=1))
  SET whrbegv = "ver.begin_effective_dt_tm < cnvtdatetime(curdate, curtime3)"
  SET whrendv = "ver.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)"
 ENDIF
 CALL echo(build("whrBegD =",whrbegd))
 CALL echo(build("whrEndD =",whrendd))
 CALL echo(build("whrBegV =",whrbegv))
 CALL echo(build("whrEndV =",whrendv))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  pra.prot_amendment_id, pra.amendment_nbr, pra.revision_ind,
  pra.revision_nbr_txt
  FROM prot_amendment pra,
   prot_master pm,
   dummyt d1,
   ct_prot_type_config cfg
  PLAN (pra
   WHERE pra.prot_master_id=protid)
   JOIN (pm
   WHERE pm.prot_master_id=pra.prot_master_id)
   JOIN (d1)
   JOIN (cfg
   WHERE cfg.protocol_type_cd=pra.participation_type_cd
    AND ((cfg.item_cd=protdoc_cd) OR (cfg.item_cd=consentdoc_cd))
    AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY pra.amendment_nbr, pra.revision_seq
  HEAD pm.prot_master_id
   reply->prot_mnemonic = pm.primary_mnemonic
  HEAD pra.prot_amendment_id
   cnta += 1
   IF (mod(cnta,10)=1)
    new = (cnta+ 10), stat = alterlist(reply->amendments,new)
   ENDIF
   reply->amendments[cnta].nbr = pra.amendment_nbr, reply->amendments[cnta].id = pra
   .prot_amendment_id, reply->amendments[cnta].revision_nbr_txt = pra.revision_nbr_txt,
   reply->amendments[cnta].revision_ind = pra.revision_ind
   IF ((request->prot_amendment_id=0))
    IF (pra.amendment_status_cd=pm.prot_status_cd)
     cur_amendment_id = pra.prot_amendment_id, reply->consent_docs_required_ind = 0, reply->
     protocol_docs_required_ind = 0
    ENDIF
   ENDIF
  DETAIL
   CALL echo(build("cur_amendment_id = ",cur_amendment_id))
   IF (((cur_amendment_id=pra.prot_amendment_id) OR ((request->prot_amendment_id=pra
   .prot_amendment_id))) )
    IF (cfg.item_cd=consentdoc_cd
     AND cfg.config_value_cd=required_cd)
     reply->consent_docs_required_ind = 1
    ENDIF
    IF (cfg.item_cd=protdoc_cd
     AND cfg.config_value_cd=required_cd)
     reply->protocol_docs_required_ind = 1
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF ((request->prot_amendment_id > 0))
  SET cur_amendment_id = request->prot_amendment_id
 ENDIF
 SET stat = alterlist(reply->amendments,cnta)
 SELECT INTO "nl:"
  cv.cdf_meaning, cv.code_value, cv.description,
  cv.display
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=17304
    AND cv.active_ind=1)
  DETAIL
   cntt += 1
   IF (mod(cntt,10)=1)
    new = (cntt+ 10), stat = alterlist(reply->doctypes,new)
   ENDIF
   reply->doctypes[cntt].desc = cv.description, reply->doctypes[cntt].disp = cv.display, reply->
   doctypes[cntt].mean = cv.cdf_meaning,
   reply->doctypes[cntt].value = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->doctypes,cntt)
 SELECT
  IF ((request->prot_questionnaire_id=0))
   PLAN (pa
    WHERE parser(whrid))
    JOIN (doc
    WHERE doc.prot_amendment_id=pa.prot_amendment_id
     AND doc.ct_document_id=doc.prev_ct_document_id
     AND parser(whrtype)
     AND parser(whrbegd)
     AND parser(whrendd))
    JOIN (ver
    WHERE ver.ct_document_id=doc.ct_document_id
     AND ver.ct_document_version_id=ver.prev_ct_document_version_id
     AND parser(whrbegv)
     AND parser(whrendv)
     AND ((ver.display_ind=1) OR ((ver.display_ind=
    IF ((request->display_ind=1)) 1
    ELSE 0
    ENDIF
    )))
     AND ver.active_ind=1)
    JOIN (blob
    WHERE (blob.ct_document_version_id= Outerjoin(ver.ct_document_version_id))
     AND (blob.active_ind= Outerjoin(1)) )
    JOIN (d)
    JOIN (qd
    WHERE qd.prot_questionnaire_id <= 0)
  ELSEIF ((request->prot_questionnaire_id > 0))
   PLAN (pa
    WHERE parser(whrid))
    JOIN (doc
    WHERE doc.prot_amendment_id=pa.prot_amendment_id
     AND doc.ct_document_id=doc.prev_ct_document_id
     AND parser(whrtype)
     AND parser(whrbegd)
     AND parser(whrendd))
    JOIN (ver
    WHERE ver.ct_document_id=doc.ct_document_id
     AND ver.ct_document_version_id=ver.prev_ct_document_version_id
     AND parser(whrbegv)
     AND parser(whrendv)
     AND ((ver.display_ind=1) OR ((ver.display_ind=
    IF ((request->display_ind=1)) 1
    ELSE 0
    ENDIF
    )))
     AND ver.active_ind=1)
    JOIN (blob
    WHERE (blob.ct_document_version_id= Outerjoin(ver.ct_document_version_id))
     AND (blob.active_ind= Outerjoin(1)) )
    JOIN (qd
    WHERE (qd.ct_document_id= Outerjoin(ver.ct_document_id))
     AND (qd.prot_questionnaire_id=request->prot_questionnaire_id)
     AND qd.active_ind=1)
    JOIN (d)
  ELSE
  ENDIF
  INTO "nl:"
  doc.*, ver.*, qd.*
  FROM ct_document doc,
   ct_document_version ver,
   prot_amendment pa,
   questionnaire_doc_reltn qd,
   dummyt d,
   ct_document_blob blob
  ORDER BY ver.ct_document_id, pa.amendment_nbr, ver.version_nbr,
   ver.begin_effective_dt_tm
  HEAD ver.ct_document_id
   cntd += 1,
   CALL echo(build("docs are: ",cntd)), new = cntd,
   stat = alterlist(reply->docs,new), reply->docs[cntd].title = doc.title, reply->docs[cntd].
   begin_effective_dt_tm = doc.begin_effective_dt_tm,
   reply->docs[cntd].end_effective_dt_tm = doc.end_effective_dt_tm, reply->docs[cntd].ct_document_id
    = doc.ct_document_id, reply->docs[cntd].description = doc.description,
   reply->docs[cntd].document_type_cd = doc.document_type_cd, reply->docs[cntd].prot_amendment_id =
   doc.prot_amendment_id, reply->docs[cntd].updt_cnt = doc.updt_cnt,
   cntv = 0, cntr = 0
  HEAD qd.ct_document_id
   IF (qd.ct_document_id > 0)
    cntr += 1, new = cntr, stat = alterlist(reply->docs[cntd].reltns,new),
    reply->docs[cntd].reltns[cntr].questionnaire_doc_id = qd.questionnaire_doc_id, reply->docs[cntd].
    reltns[cntr].prot_questionnaire_id = qd.prot_questionnaire_id, reply->docs[cntd].reltns[cntr].
    ct_document_id = qd.ct_document_id,
    reply->docs[cntd].reltns[cntr].active_ind = qd.active_ind, reply->docs[cntd].reltns[cntr].
    updt_cnt = qd.updt_cnt
   ENDIF
  HEAD ver.ct_document_version_id
   cntv += 1, new = (cntv+ 1), stat = alterlist(reply->docs[cntd].versions,new),
   reply->docs[cntd].versions[cntv].begin_effective_dt_tm = ver.begin_effective_dt_tm, reply->docs[
   cntd].versions[cntv].end_effective_dt_tm = ver.end_effective_dt_tm, reply->docs[cntd].versions[
   cntv].ct_document_version_id = ver.ct_document_version_id,
   reply->docs[cntd].versions[cntv].version_nbr = ver.version_nbr, reply->docs[cntd].versions[cntv].
   version_description = ver.version_description, reply->docs[cntd].versions[cntv].file_name = ver
   .file_name,
   reply->docs[cntd].versions[cntv].updt_cnt = ver.updt_cnt, reply->docs[cntd].versions[cntv].
   revision_id = ver.revision_id, reply->docs[cntd].versions[cntv].print_with_consent_ind = ver
   .print_with_consent_ind,
   reply->docs[cntd].versions[cntv].display_ind = ver.display_ind, reply->docs[cntd].versions[cntv].
   blob_length = blob.blob_length
  FOOT  ver.ct_document_id
   stat = alterlist(reply->docs[cntd].versions,cntv), stat = alterlist(reply->docs[cntd].reltns,cntr)
  WITH nocounter, outerjoin(d)
 ;end select
 IF ((request->print_with_consent_ind=1))
  SET cnt = 0
  SELECT INTO "nl:"
   FROM ct_document doc,
    ct_document_version ver,
    ct_document_blob blob
   PLAN (doc
    WHERE doc.prot_amendment_id=cur_amendment_id
     AND doc.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (ver
    WHERE ver.ct_document_id=doc.ct_document_id
     AND ((ver.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")) OR (ver
    .end_effective_dt_tm >= cnvtdatetime(request->utcmaxdate)))
     AND ver.print_with_consent_ind=1
     AND ver.active_ind=1)
    JOIN (blob
    WHERE (blob.ct_document_version_id= Outerjoin(ver.ct_document_version_id))
     AND (blob.active_ind= Outerjoin(1)) )
   HEAD ver.ct_document_id
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->printable_docs,(cnt+ 9))
    ENDIF
    reply->printable_docs[cnt].title = doc.title, reply->printable_docs[cnt].begin_effective_dt_tm =
    doc.begin_effective_dt_tm, reply->printable_docs[cnt].end_effective_dt_tm = doc
    .end_effective_dt_tm,
    reply->printable_docs[cnt].ct_document_id = doc.ct_document_id, reply->printable_docs[cnt].
    description = doc.description, reply->printable_docs[cnt].prot_amendment_id = doc
    .prot_amendment_id,
    reply->printable_docs[cnt].updt_cnt = doc.updt_cnt, ver_cnt = 0
   HEAD ver.ct_document_version_id
    ver_cnt += 1
    IF (mod(ver_cnt,10)=1)
     stat = alterlist(reply->printable_docs[cnt].versions,(ver_cnt+ 9))
    ENDIF
    reply->printable_docs[cnt].versions[ver_cnt].begin_effective_dt_tm = ver.begin_effective_dt_tm,
    reply->printable_docs[cnt].versions[ver_cnt].end_effective_dt_tm = ver.end_effective_dt_tm, reply
    ->printable_docs[cnt].versions[ver_cnt].ct_document_version_id = ver.ct_document_version_id,
    reply->printable_docs[cnt].versions[ver_cnt].version_nbr = ver.version_nbr, reply->
    printable_docs[cnt].versions[ver_cnt].version_description = ver.version_description, reply->
    printable_docs[cnt].versions[ver_cnt].file_name = ver.file_name,
    reply->printable_docs[cnt].versions[ver_cnt].revision_id = ver.revision_id, reply->
    printable_docs[cnt].versions[ver_cnt].blob_length = blob.blob_length
   FOOT  ver.ct_document_id
    stat = alterlist(reply->printable_docs[cnt].versions,ver_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->printable_docs,cnt)
 ENDIF
 SET stat = alterlist(reply->docs,cntd)
 SET reply->status_data.status = "S"
 SET last_mod = "011"
 SET mod_date = "September 14, 2021"
END GO
